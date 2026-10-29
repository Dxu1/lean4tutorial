"""Guarded recovery of the preserved, genuinely revised E03 submission."""
import copy,json
from pathlib import Path
from shared_imports import sha
from revision_probe import CLASSIFICATION,certificate
BASE='3bd22d702ca5090e0c418c24d76868d33c0984e3'
INFRA={'orchestration/revision_probe.py','orchestration/revision_probe_reconciliation.py',
 'orchestration/probe_inventory.txt','orchestration/probe_whitespace.py','orchestration/signature_probe.py',
 'orchestration/artifacts.json','orchestration/probe_manifests/m10b3_revision0.json',
 'orchestration/probe_manifests/m10b3_revision1.json','orchestration/tests/test_revision_probe.py',
 'reports/e03_revision_probe_reconciliation.md','orchestration/tests/test_signature_probe.py'}
def need(ok,reason):
    if not ok:
        from orchestrate import Stop
        raise Stop('REVISION_PROBE_RECONCILIATION: '+reason)
def eligible(s):
    need(s.get('status')=='HUMAN_STOP' and s.get('gate')=='M10B3' and s.get('baseline')==BASE
         and s.get('diagnostic')=='NON_MECHANICAL_PROBE_CHANGE: probe command sequence differs','incident identity')
    need(s.get('attempt')==2 and s.get('revisions')==1 and s.get('executor_effort_index')==1,'revision identity')
    h=s['executor_history'];need(len(h)==2,'executor count')
    for i,(effort,reason) in enumerate([('medium','INITIAL'),('high','REVIEWER_REVISION')],1):
        need(h[i-1]==dict(attempt=i,gate_id='M10B3',invocation_number=i,model='gpt-5.6-sol',outcome='COMPLETED',reason=reason,reasoning_effort=effort,substantive_round=i),'executor identity')
    need(s['reviewer_verdict']['verdict']=='REVISE' and s['reviewer_verdict']['confidence']=='HIGH'
         and not s['reviewer_verdict']['requires_human_review'],'operative revision authority')
def resume(c,receipt,receipt_sha,head):
    from orchestrate import atomic_json
    from shared_lifecycle import blob
    with c.lock():
        p=Path(receipt);raw=p.read_bytes();r=json.loads(raw);s=c.status();eligible(s)
        need(sha(raw)==receipt_sha and sha(c.state_path.read_bytes())==r['state_sha256'],'receipt/state')
        need(c.git('rev-parse','HEAD').strip()==head and r['head']==BASE and c.git('rev-list','--parents','-n','1',head).split()==[head,BASE],'repair history')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',BASE,head).splitlines())=={prefix+n for n in INFRA},'infrastructure scope')
        need(not c.git('diff','--cached','--name-only').strip(),'dirty index')
        files=c.project_files();select=lambda x:{n:h for n,h in x.items() if n not in INFRA}
        need(select(files)==select(r['files']),'candidate changed')
        for n,h in r['runtime_hashes'].items():need(sha(Path(n).read_bytes())==h,'evidence changed: '+n)
        for n in INFRA:need(files[n]==sha(blob(c,head,n)),'dirty infrastructure')
        g=c.gates[-1];a=c.attempt_directory(g,2)
        need(not list(a.rglob('reviewer_invocation.json')),'current candidate reviewed')
        c.preserve();entry=json.loads((c.o/'artifacts.json').read_text())['generated_probes'][g['id']]
        cert=certificate(c,g,entry)
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        need(outer==s['outer_status'],'unrelated changes')
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:candidate['initial_files'][n]=files[n]
        c._semantic_scope(g,candidate,candidate['initial_files'])
        path=p.parent/'reconciliation.json';need(not path.exists(),'already reconciled')
        atomic_json(path,{'classification':CLASSIFICATION,'old_baseline':BASE,'head':head,'receipt_sha256':receipt_sha,'certificate':cert,'candidate_files':select(files),'model_calls':0,'executor_rerun':False,'additional_substantive_revisions':0,'substantive_revisions':1})
        candidate.setdefault('incident_history',[]).append({'classification':CLASSIFICATION,'reconciliation':str(path),'sha256':sha(path.read_bytes())})
        candidate['owned_files']=files
        for k in ('diagnostic','stop_class','verification_directory'):candidate.pop(k,None)
        c.save(candidate,'POST_EXECUTOR_RECONCILED')
        return {'status':candidate['status'],'model_calls':0,'executor_rerun':False,'substantive_revisions':1}
if __name__=='__main__':
    import argparse
    from stage10b import Stage10bController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage10bController(),a.receipt,a.sha256,a.head),indent=2))
