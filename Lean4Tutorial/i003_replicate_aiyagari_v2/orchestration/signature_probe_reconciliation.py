"""Hash-bound E03 probe-only infrastructure recovery; no model dispatch."""
import copy,json
from pathlib import Path
from shared_imports import sha
from signature_probe import CLASSIFICATION,commands,certificate
from probe_whitespace import compare,registered,reconcile
BASE='97c8e041bf9a5cf79b4cebf47638148c2469bc95'
INFRA={'orchestration/signature_probe.py','orchestration/probe_whitespace.py',
       'orchestration/artifacts.json','orchestration/stage10b.py','orchestration/gate_context.py',
       'orchestration/signature_probe_reconciliation.py','orchestration/tests/test_signature_probe.py',
       'reports/e03_signature_probe_reconciliation.md'}

def need(ok,reason):
    if not ok:
        from orchestrate import Stop
        raise Stop('E03_PROBE_RECONCILIATION: '+reason)

def eligible(s):
    expected=dict(attempt=1,gate_id='M10B3',invocation_number=1,model='gpt-5.6-sol',outcome='COMPLETED',reason='INITIAL',reasoning_effort='medium',substantive_round=1)
    need(s.get('status')=='HUMAN_STOP' and s.get('gate')=='M10B3' and s.get('baseline')==BASE
         and s.get('diagnostic')=='NEW_FILE_DIFF_CHECK: Probes/M10B3Signatures.lean','wrong incident')
    need(s.get('attempt')==1 and s.get('revisions')==0 and s.get('executor_effort_index')==0
         and s.get('executor_history')==[expected],'execution identity')
    need(not s.get('snapshot_sha256') and not s.get('reviewer_verdict')
         and not s.get('acceptance_committed'),'review already reached')

def resume(c,receipt_path,receipt_sha,head):
    from orchestrate import atomic_json
    from shared_lifecycle import blob
    with c.lock():
        p=Path(receipt_path);raw=p.read_bytes();r=json.loads(raw);s=c.status();eligible(s)
        need(sha(raw)==receipt_sha and sha(c.state_path.read_bytes())==r['state_sha256'],'receipt/state changed')
        need(c.git('rev-parse','HEAD').strip()==head and r['head']==BASE
             and c.git('rev-list','--parents','-n','1',head).split()==[head,BASE],'repair history')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',BASE,head).splitlines())=={prefix+n for n in INFRA},'repair scope')
        need(not c.git('diff','--cached','--name-only').strip(),'dirty index')
        files=c.project_files();select=lambda x:{n:h for n,h in x.items() if n not in INFRA}
        need(select(files)==select(r['files']),'submission changed before reconciliation')
        for n,h in r['runtime_hashes'].items():need(sha(Path(n).read_bytes())==h,'original runtime changed: '+n)
        for n in INFRA:need(files[n]==sha(blob(c,head,n)),'dirty infrastructure')
        a=c.attempt_directory({'id':'M10B3'},1);need(not list(a.rglob('reviewer_invocation.json')),'review started')
        gate=next(g for g in c.gates if g['id']=='M10B3');entry=registered(c,gate)
        original=(p.parent/'original_probe.lean').read_bytes();need(sha(original)==r['files'][entry['path']],'probe receipt')
        normalized=compare(original,entry)
        need(original==normalized+b'\n\n\n','not precisely three terminal newlines')
        need(commands(original)==commands(normalized),'command sequence changed')
        states={t['id']:t['status'] for t in json.loads((c.root/'contracts/theorems.json').read_text())['theorems']}
        need(states['E03']=='REVIEW_READY' and sum(v=='GREEN' for v in states.values())==56,'contract status')
        c.preserve()
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        need(outer==s['outer_status'],'unrelated work changed')
        normalization=reconcile(c,gate,s);cert=certificate(c,gate)
        current=c.project_files();excluded=INFRA|{entry['path']}
        need({n:h for n,h in files.items() if n not in excluded}=={n:h for n,h in current.items() if n not in excluded},'nonprobe source changed')
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:candidate['initial_files'][n]=current[n]
        c._semantic_scope(gate,candidate,candidate['initial_files'])
        path=p.parent/'reconciliation.json';need(not path.exists(),'already reconciled')
        atomic_json(path,{'classification':CLASSIFICATION,'history':['NEW_FILE_DIFF_CHECK','redundant EOF and unrecognized display options','command sequence verified',CLASSIFICATION],
                         'old_baseline':BASE,'head':head,'receipt_sha256':receipt_sha,'normalization':normalization,
                         'certificate':cert,'mathematical_hashes':{n:h for n,h in current.items() if n not in excluded},
                         'original_status':s['status'],'original_diagnostic':s['diagnostic'],'model_calls':0,
                         'executor_rerun':False,'substantive_revisions':0})
        candidate.setdefault('incident_history',[]).append({'classification':CLASSIFICATION,'status':s['status'],'diagnostic':s['diagnostic'],'reconciliation':str(path),'sha256':sha(path.read_bytes())})
        candidate['owned_files']=current
        for k in ('diagnostic','stop_class','verification_directory'):candidate.pop(k,None)
        c.save(candidate,'POST_EXECUTOR_RECONCILED')
        return {'status':candidate['status'],'model_calls':0,'executor_rerun':False,'substantive_revisions':0}

if __name__=='__main__':
    import argparse
    from stage10b import Stage10bController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage10bController(),a.receipt,a.sha256,a.head),indent=2))
