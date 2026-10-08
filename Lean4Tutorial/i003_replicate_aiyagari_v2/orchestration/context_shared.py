"""Consume the existing shared-import certificate; never waive uncertified changes."""
import json,subprocess
from pathlib import Path
from shared_imports import (POLICIES,CLASSIFICATION,BASE,sha,canonical,structure,
    compare,import_graph,certificate_location,certify)

def need(ok,reason):
    if not ok:raise ValueError('REVIEW_CONTEXT_INCOMPLETE: shared certificate '+reason)

def validate(cert,policy,gate,base,original,current,artifacts,contracts,baseline_contracts,graph,key):
    """Pure validation of current deterministic evidence; no second fingerprinter."""
    need(cert['classification']==CLASSIFICATION and cert['result']=='PASS','classification')
    need(POLICIES.get(gate)==policy and cert['module']==policy['module'],'gate/module')
    need(cert['baseline_commit']==base and cert['input_sha256']==key,'baseline/input binding')
    need(cert['source_sha256']==sha(current),'stale candidate')
    need(cert['source_prefix_unchanged'] is True,'source preservation')
    added=structure(original,current,policy)
    need(added==cert['authorized_imports']==policy['imports'],'authorized imports')
    need(graph==artifacts['import_graph.json'],'import graph')
    accepted=compare(artifacts['baseline_raw.json'],artifacts['candidate_raw.json'],policy,contracts)
    names=[x['name'] for x in accepted]
    need(names==cert['accepted_declarations'],'partial accepted declaration inventory')
    need(accepted==artifacts['accepted_shared_declarations_baseline.json']==artifacts['accepted_shared_declarations_candidate.json'],'accepted fingerprints')
    old={t['id']:t for t in baseline_contracts['theorems']};now={t['id']:t for t in contracts['theorems']}
    need(all(now.get(i)==t for i,t in old.items() if t['status']=='GREEN'),'accepted contract mutation')
    required={t['declaration'] for t in old.values() if t['status']=='GREEN' and t['module']==policy['module']}
    need(required<=set(names),'accepted contract coverage')
    compact=lambda values:[{k:(sha(canonical(v)) if k in ('type','value','project_dependencies') else v) for k,v in x.items()} for x in values]
    need(cert['baseline_fingerprints']==cert['candidate_fingerprints']==compact(accepted),'compact fingerprints')
    return accepted

def preservation(c,t,acceptance_commit,accepted):
    current=(c.root/t['module']).read_bytes()
    if current.startswith(accepted):return None
    try:
        state=c.status();gate=next(g for g in c.gates if g['id']==state['gate'])
        policy=POLICIES.get(gate['id']);prefix=c.git('rev-parse','--show-prefix').strip()
        def blob(ref,n):return subprocess.check_output(['git','show',ref+':'+prefix+n],cwd=c.root)
        if policy and policy['module']==t['module'] and not c.tracked(f"reviews/{gate['id'].lower()}_acceptance.json"):
            base=BASE if gate['id']=='M09B2' else state['baseline'];key,d=certificate_location(c,base)
            need((d/'certificate.json').is_file(),'missing current certificate')
            raw=(d/'certificate.json').read_bytes();cert=json.loads(raw)
            expected={'baseline_raw.json','candidate_raw.json','accepted_shared_declarations_baseline.json','accepted_shared_declarations_candidate.json','import_graph.json'}
            need(set(cert['artifacts'])==expected,'artifact inventory')
            need(Path(cert['evidence_directory']).resolve()==d.resolve(),'controller evidence directory')
            artifacts={}
            for n,h in cert['artifacts'].items():
                b=(d/n).read_bytes();need(sha(b)==h,'artifact hash');artifacts[n]=json.loads(b)
            original=blob(base,t['module'])
            need(original==accepted,'historical accepted baseline')
            c.git('merge-base','--is-ancestor',acceptance_commit,base)
            validate(cert,policy,gate['id'],base,original,current,artifacts,
                     json.loads((c.root/'contracts/theorems.json').read_text()),json.loads(blob(base,'contracts/theorems.json')),
                     import_graph(c.root,policy['imports']),key)
            # Existing authoritative tool additionally verifies sibling source inputs and preservation.
            need(certify(c,gate)==cert,'authoritative certificate mismatch')
            evidence={'classification':CLASSIFICATION,'gate':gate['id'],'baseline_commit':base,'baseline_source_sha256':sha(original),'candidate_sha256':sha(current),'certificate_sha256':sha(raw),'input_sha256':key,'authorized_imports':cert['authorized_imports'],'accepted_fingerprints':cert['baseline_fingerprints']}
        else:
            # Already accepted extensions use immutable reviewed provenance, never active HEAD as baseline.
            from shared_provenance import certify as accepted_certify
            matches=[g for g in c.gates if POLICIES.get(g['id'],{}).get('module')==t['module'] and c.tracked(f"reviews/{g['id'].lower()}_acceptance.json")]
            need(bool(matches),'missing accepted chain');cert=accepted_certify(c,matches[-1])
            chain=cert['provenance_chain'];need(cert['source_sha256']==sha(current),'accepted candidate')
            need(any(blob(n['baseline_commit'],t['module'])==accepted or blob(n['acceptance_commit'],t['module'])==accepted for n in chain),'acceptance chain origin')
            evidence={'classification':CLASSIFICATION,'candidate_sha256':sha(current),'provenance_chain':chain,'accepted_fingerprints':cert['candidate_fingerprints'],'authorized_imports':cert['authorized_imports']}
        evidence.update(acceptance_commit=acceptance_commit,accepted_declaration=t['declaration'],semantic_preservation_verified=True,whole_file_byte_identity=False,scope='Accepted predecessor preservation only; not adequacy of the active theorem.')
        return evidence
    except (KeyError,OSError,ValueError,StopIteration) as e:
        from orchestrate import Stop
        raise Stop('REVIEW_CONTEXT_INCOMPLETE: '+str(e)) from e

INFRA={'orchestration/context_shared.py','orchestration/shared_imports.py','orchestration/gate_context.py','orchestration/tests/test_context_shared.py','orchestration/tests/test_stage09c.py','reports/g06_context_guard_repair.md'}

def eligible(s):
    h=s.get('executor_history',[])
    need(s['status']=='HUMAN_STOP' and s['gate']=='M09D1' and s['diagnostic']=='REVIEW_CONTEXT_INCOMPLETE: accepted implementation changed G04','wrong incident')
    need(s['attempt']==1 and s['revisions']==0 and s['executor_effort_index']==0 and len(h)==1,'attempt/revision')
    need(h[0]=={'attempt':1,'gate_id':'M09D1','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1},'executor identity')
    need(not s.get('snapshot_sha256') and not s.get('reviewer_verdict') and not s.get('acceptance_committed'),'review already started')

def resume(c,receipt_path,receipt_sha,expected_head):
    """One explicit human-authorized infrastructure transition; never invoke Sol."""
    import copy
    from orchestrate import atomic_json
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status();eligible(s)
        need(sha(raw)==receipt_sha and sha(c.state_path.read_bytes())==r['state_sha256'],'receipt/state changed')
        head=c.git('rev-parse','HEAD').strip();prefix=c.git('rev-parse','--show-prefix').strip()
        need(head==expected_head and c.git('rev-list','--parents','-n','1','HEAD').split()==[head,r['head']],'repair history')
        need(set(c.git('diff','--name-only',r['head'],head).splitlines())=={prefix+n for n in INFRA},'repair scope')
        need(not c.git('diff','--cached','--name-only').strip(),'dirty index')
        current=c.project_files();select=lambda d:{n:h for n,h in d.items() if n not in INFRA}
        need(select(current)==select(r['files']),'mathematical submission changed')
        for n,h in r['runtime_hashes'].items():need(sha(Path(n).read_bytes())==h,'original evidence changed')
        need(not list((c.runtime/'runs/M09D1').rglob('reviewer_invocation.json')),'review invocation exists')
        ts=json.loads((c.root/'contracts/theorems.json').read_text())['theorems']
        need(all(t['status']=='UNFORMALIZED' for t in ts if t['id'] in ['G07','G08'] or t['stage'] in ('10','11')),'later status')
        need(not (c.root/'Aiyagari1994/Equilibrium/Saving.lean').exists(),'later implementation')
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:
            need(sha(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=c.root))==current[n],'dirty infrastructure')
            candidate['initial_files'][n]=current[n]
        # Pre-existing observational stop reports are frozen, not executor edits.
        for n in ('reports/stage09d_usage_metrics.json','reports/stage09d_usage_report.md'):
            need(current[n]==r['files'][n],'usage report changed')
            candidate['initial_files'][n]=current[n]
        gate=next(g for g in c.gates if g['id']=='M09D1')
        c._semantic_scope(gate,candidate,candidate['initial_files']);c.preserve()
        cert=certify(c,gate,force=True)
        from gate_context import ContextBuilder
        interface=ContextBuilder(c).interface('G04')
        need(interface['certified_preservation']['semantic_preservation_verified'],'context interface')
        candidate['owned_files']=c.project_files();candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        atomic_json(Path(receipt_path).parent/'reconciliation.json',{'classification':'CONTEXT_GUARD_IGNORES_SHARED_MODULE_SEMANTIC_CERTIFICATE','original_stop':s['diagnostic'],'infrastructure_commit':head,'receipt_sha256':receipt_sha,'certificate':cert,'certified_interface':interface,'executor_rerun':False,'substantive_revisions':0,'model_calls':0})
        c.save(candidate,'POST_EXECUTOR_RECONCILED');return {'status':candidate['status'],'executor_rerun':False}

if __name__=='__main__':
    import argparse
    from stage09d import Stage09dController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage09dController(),a.receipt,a.sha256,a.head)))
