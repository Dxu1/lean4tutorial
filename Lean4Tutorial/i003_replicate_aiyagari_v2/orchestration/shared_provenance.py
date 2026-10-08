"""Validate accepted shared-module deltas using hash-bound review provenance."""
import json,subprocess,tempfile,time
from pathlib import Path
from shared_imports import POLICIES,sha,canonical,structure,compare,import_graph
CLASSIFICATION='INTEGRATION_REVIEW_BASELINE_PROVENANCE_ERROR'
INFRA={'orchestration/stage09c.py','orchestration/shared_provenance.py','orchestration/shared_imports.py','orchestration/tests/test_shared_provenance.py','reports/stage09c_integration_provenance_repair.md'}

def need(ok,reason):
    if not ok:raise ValueError('SHARED_PROVENANCE_'+reason)

def validate_chain(nodes,current,head,ancestor,module_changes):
    """Pure fail-closed chain validation; nodes have already hash-bound evidence."""
    need(bool(nodes),'MISSING_CERTIFICATE');seen=set();previous=None
    for n in nodes:
        cert=n['certificate'];policy=n['policy'];base=n['baseline'];candidate=n['candidate']
        need(n['gate'] not in seen,'FORK_OR_DUPLICATE_GATE');seen.add(n['gate'])
        need(cert['result']=='PASS' and cert['module']==policy['module'],'INVALID_CERTIFICATE')
        need(sha(base)==n['baseline_sha256'],'BASELINE_HASH')
        need(sha(candidate)==cert['source_sha256']==n['reviewed_candidate_sha256'],'CANDIDATE_HASH')
        need(structure(base,candidate,policy)==cert['authorized_imports'],'IMPORT_DELTA')
        need(ancestor(cert['baseline_commit'],n['review_baseline']) and ancestor(n['review_baseline'],n['acceptance_commit']) and ancestor(n['acceptance_commit'],head),'ANCESTRY')
        compare(n['baseline_raw'],n['candidate_raw'],policy,n['contracts'])
        need(n['baseline_accepted']==n['candidate_accepted'],'ACCEPTED_FINGERPRINT')
        need(n['baseline_accepted']==[x for x in sorted(n['baseline_raw'],key=lambda x:x['name'])],'BASELINE_FINGERPRINT')
        names={x['name'] for x in n['baseline_raw']}
        need(n['candidate_accepted']==[x for x in sorted(n['candidate_raw'],key=lambda x:x['name']) if x['name'] in names],'CANDIDATE_FINGERPRINT')
        if previous:
            need(base==previous['candidate'],'CHAIN_GAP_OR_FORK')
            need(n['baseline_raw']==previous['candidate_raw'],'CHAIN_SEMANTIC_GAP')
            need(ancestor(previous['acceptance_commit'],cert['baseline_commit']),'CHAIN_ORDER')
        previous=n
    need(module_changes==[n['acceptance_commit'] for n in nodes],'UNCERTIFIED_MODULE_HISTORY')
    need(current==nodes[-1]['candidate'],'CURRENT_CANDIDATE_HASH')
    return [{'gate':n['gate'],'contract':n['policy'].get('contract','G03'),'baseline_commit':n['certificate']['baseline_commit'],'baseline_sha256':n['baseline_sha256'],'review_baseline':n['review_baseline'],'candidate_sha256':sha(n['candidate']),'acceptance_commit':n['acceptance_commit'],'snapshot_sha256':n['snapshot_sha256'],'authorized_imports':n['certificate']['authorized_imports'],'authorized_declarations':n['policy']['new_declarations'],'artifacts':n['certificate']['artifacts']} for n in nodes]

def load_node(c,gate,policy):
    from orchestrate import decision
    rec=c.acceptance_record(gate);commit=rec['accepted_commit_sha'];prefix=c.git('rev-parse','--show-prefix').strip()
    def blob(ref,n):return subprocess.check_output(['git','show',ref+':'+prefix+n],cwd=c.root)
    def accepted(n):
        raw=blob(commit,n);need((c.root/n).read_bytes()==raw,'ACCEPTANCE_EVIDENCE_CHANGED');return raw
    directory=rec['evidence_directory'];manifest=json.loads(accepted(directory+'/snapshot_manifest.json'))
    need(sha(canonical(manifest))==rec['snapshot_sha256'],'SNAPSHOT_HASH')
    summary_raw=accepted(directory+'/deterministic_summary.json')
    need(sha(summary_raw)==manifest['files']['verification/deterministic_summary.json'],'CERTIFICATE_NOT_REVIEW_BOUND')
    cert=json.loads(summary_raw).get('accepted_shared_declarations');need(isinstance(cert,dict),'MISSING_CERTIFICATE')
    v=json.loads(accepted(directory+'/reviewer_final.json'))
    need(decision(v,gate,v['attempt'],rec['snapshot_sha256'],True)=='ACCEPTANCE_RECORDING','REVIEW_VERDICT')
    need(rec['operative_reviewer']['phase']==rec['reviewer_history']['operative'] and rec['reviewer_history'][rec['operative_reviewer']['phase']]['verdict']==v,'OPERATIVE_VERDICT')
    # Require immutable reviewed certificate artifacts, not a newly inferred delta.
    artifact_dir=Path(cert['evidence_directory']);artifacts={}
    for name,h in cert['artifacts'].items():
        raw=(artifact_dir/name).read_bytes();need(sha(raw)==h,'CERTIFICATE_ARTIFACT_HASH');artifacts[name]=json.loads(raw)
    need(json.loads((artifact_dir/'certificate.json').read_text())==cert,'CERTIFICATE_CHANGED')
    base=blob(cert['baseline_commit'],policy['module']);candidate=blob(commit,policy['module'])
    need(base==blob(manifest['baseline'],policy['module']),'REVIEW_BASELINE_CHANGED')
    need(sha(candidate)==manifest['files'][policy['module']],'REVIEW_CANDIDATE_CHANGED')
    # All captured semantic helper inputs remain exact. Later wrapper extensions are
    # handled by the ordered chain rather than excused by an import-error category.
    shared={p['module'] for p in POLICIES.values()}
    for name,h in manifest['files'].items():
        if name.endswith('.lean') and name not in shared|{'All.lean','Audit.lean'}:
            need(sha((c.root/name).read_bytes())==h,'REVIEWED_DEPENDENCY_CHANGED')
    contracts=json.loads(blob(commit,'contracts/theorems.json'))
    need(import_graph(c.root,cert['authorized_imports'])==artifacts['import_graph.json'],'IMPORT_GRAPH_CHANGED')
    return {'gate':gate['id'],'policy':policy,'certificate':cert,'baseline':base,'candidate':candidate,'baseline_sha256':sha(base),'reviewed_candidate_sha256':manifest['files'][policy['module']],'review_baseline':manifest['baseline'],'acceptance_commit':commit,'snapshot_sha256':rec['snapshot_sha256'],'contracts':contracts,'baseline_raw':artifacts['baseline_raw.json'],'candidate_raw':artifacts['candidate_raw.json'],'baseline_accepted':artifacts['accepted_shared_declarations_baseline.json'],'candidate_accepted':artifacts['accepted_shared_declarations_candidate.json']}

def certify(c,gate):
    from orchestrate import Stop,atomic_json,clean_environment
    try:
        module=POLICIES[gate['id']]['module'];nodes=[]
        for g in c.gates:
            p=POLICIES.get(g['id'])
            if p and p['module']==module and c.tracked(f"reviews/{g['id'].lower()}_acceptance.json"):
                nodes.append(load_node(c,g,p))
        need(any(n['gate']==gate['id'] for n in nodes),'MISSING_GATE_CERTIFICATE')
        head=c.git('rev-parse','HEAD').strip()
        def ancestor(a,b):return subprocess.run(['git','merge-base','--is-ancestor',a,b],cwd=c.root,capture_output=True).returncode==0
        changes=c.git('log','--reverse','--format=%H',nodes[0]['certificate']['baseline_commit']+'..'+head,'--',module).splitlines()
        chain=validate_chain(nodes,(c.root/module).read_bytes(),head,ancestor,changes)
        # Re-elaborate current accepted declarations; validate actual type/value,
        # metadata, project dependency and axiom closures against reviewed records.
        d=c.runtime/'shared_provenance'/str(time.time_ns());d.mkdir(parents=True)
        c.command_log('targeted_build',['lake','build',module[:-5].replace('/','.')],d)
        with tempfile.TemporaryDirectory(prefix='shared-provenance-') as tmp:
            p=Path(tmp)/'Fingerprint.lean';p.write_text('import '+module[:-5].replace('/','.')+'\nimport Lean\n'+(c.root/'orchestration/semantic_fingerprint.txt').read_text().replace('`Aiyagari1994.Equilibrium.Existence','`'+module[:-5].replace('/','.')))
            r=subprocess.run(['lake','env','lean',str(p)],cwd=c.root,env=clean_environment(),capture_output=True,text=True)
            (d/'fingerprint.log').write_text(r.stdout+r.stderr);need(r.returncode==0,'FRESH_FINGERPRINT_FAILED');actual=json.loads(r.stdout)
        need(actual==nodes[-1]['candidate_raw'],'CURRENT_ELABORATED_SEMANTICS_CHANGED')
        atomic_json(d/'current_raw.json',actual)
        result=dict(nodes[-1]['certificate']);result.update(provenance_validation='PASS',provenance_chain=chain,current_head=head,fresh_candidate_sha256=sha(canonical(actual)),fresh_evidence_directory=str(d),model_calls=0)
        atomic_json(d/'provenance_chain.json',result);return result
    except (ValueError,KeyError,OSError,TypeError) as e:raise Stop(str(e)) from e

def resume(c,receipt_path,receipt_sha,expected_head):
    """Human-authorized stopped-integration recovery; no gate/model execution."""
    from orchestrate import atomic_json
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status()
        need(sha(raw)==receipt_sha and sha(c.state_path.read_bytes())==r['state_sha256'],'RECEIPT_CHANGED')
        need(s['status']=='HUMAN_STOP' and s['gate']=='M09C4' and s['diagnostic']=='UNAUTHORIZED_OR_DUPLICATE_IMPORT' and s['acceptance_committed'],'WRONG_STOP')
        c.ensure_clean();head=c.git('rev-parse','HEAD').strip();prefix=c.git('rev-parse','--show-prefix').strip()
        need(head==expected_head and c.git('rev-list','--parents','-n','1','HEAD').split()==[head,r['head']],'REPAIR_HISTORY')
        need(set(c.git('diff','--name-only',r['head'],head).splitlines())=={prefix+n for n in INFRA},'REPAIR_SCOPE')
        select=lambda d:{n:h for n,h in d.items() if n not in INFRA}
        need(select(c.project_files())==select(r['files']),'ACCEPTED_FILES_CHANGED')
        for n,h in r['runtime_hashes'].items():need(sha(Path(n).read_bytes())==h,'FROZEN_RUNTIME_CHANGED')
        c.preserve();need(s['accepted']==c.reconstruct_accepted(),'ACCEPTANCE_CHAIN')
        cert=certify(c,c.gates[-1]);atomic_json(Path(receipt_path).parent/'reconciliation.json',{'classification':CLASSIFICATION,'original_stop':s['diagnostic'],'infrastructure_commit':head,'receipt_sha256':receipt_sha,'certificate':cert,'model_calls':0,'mathematical_revisions':0})
        # Start the entire integration audit, not the failed check's successor.
        # finish_stage performs all checks then records the checkpoint only on PASS.
        s.pop('diagnostic',None);s.pop('stop_class',None)
        try:return c.finish_stage(s)
        except Exception as e:
            s['diagnostic']=str(e);s['stop_class']='INFRASTRUCTURE';c.save(s,'HUMAN_STOP');raise

if __name__=='__main__':
    import argparse
    from stage09c import Stage09cController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    s=resume(Stage09cController(),a.receipt,a.sha256,a.head);print(json.dumps({'status':s['status'],'integration_commit':s.get('integration_commit')},indent=2))
