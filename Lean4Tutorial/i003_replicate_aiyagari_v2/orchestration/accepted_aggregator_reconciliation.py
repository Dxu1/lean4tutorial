"""Integration-only recovery: no dispatch or availability/model probes."""
import copy,json
from pathlib import Path
from orchestrate import Stop,atomic_json,digest
from accepted_aggregators import CLASSIFICATION,certify
BASE='074e9d70b7ef3b70d5839b77a14156fe403b92c7'
INFRA={'orchestration/accepted_aggregators.py','orchestration/accepted_aggregator_reconciliation.py',
       'orchestration/root_aggregators.py','orchestration/stage10b.py',
       'orchestration/tests/test_accepted_aggregators.py','reports/stage10_accepted_aggregator_reconciliation.md'}
def need(ok,why):
    if not ok:raise Stop('ACCEPTED_AGGREGATOR_RECONCILIATION: '+why)
def resume(c,receipt,receipt_sha,head):
    with c.lock():
        p=Path(receipt);raw=p.read_bytes();r=json.loads(raw);s=c.status()
        need(s['status']=='HUMAN_STOP' and s['diagnostic']=='AGGREGATOR_UNAUTHORIZED_IMPORT' and s['gate']=='M10B3' and s['acceptance_committed'],'wrong stop')
        need(s['baseline']==r['head']==BASE and s['revisions']==1 and s['attempt']==2,'accepted identity')
        need(digest(raw)==receipt_sha and digest(c.state_path.read_bytes())==r['state_sha256'],'receipt/state changed')
        need(c.git('branch','--show-current').strip()=='issue3' and c.git('rev-parse','HEAD').strip()==head and c.git('rev-list','--parents','-n','1',head).split()==[head,BASE],'repair history')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',BASE,head).splitlines())=={prefix+n for n in INFRA},'repair scope')
        c.ensure_clean();c.preserve();files=c.project_files()
        select=lambda x:{n:h for n,h in x.items() if n not in INFRA}
        need(select(files)==select(r['files']),'accepted files changed')
        for n,h in r['runtime_hashes'].items():need(digest(Path(n).read_bytes())==h,'preserved runtime changed: '+n)
        ts=json.loads((c.root/'contracts/theorems.json').read_text())['theorems']
        need(len(ts)==57 and all(t['status']=='GREEN' for t in ts),'not 57 GREEN')
        need(s['accepted']==c.reconstruct_accepted() and len(s['accepted'])==len(c.gates),'acceptance chain')
        cert=certify(c,c.gates[-1]);rec=c.acceptance_record(c.gates[-1]);need(rec['accepted_commit_sha']==BASE,'E03 acceptance changed')
        v=json.loads((c.root/rec['evidence_directory']/'reviewer_final.json').read_text())
        need(v['verdict']=='PASS' and v['confidence']=='HIGH' and not v['requires_human_review'],'operative verdict')
        path=p.parent/'reconciliation.json';need(not path.exists(),'already reconciled')
        atomic_json(path,{'classification':CLASSIFICATION,'old_baseline':BASE,'head':head,'receipt_sha256':receipt_sha,'accepted_provenance':cert,'model_calls':0,'executor_calls':0,'reviewer_calls':0,'substantive_revisions_consumed':0})
        candidate=copy.deepcopy(s);candidate['baseline']=head
        candidate.setdefault('incident_history',[]).append({'classification':CLASSIFICATION,'path':str(path),'sha256':digest(path.read_bytes())})
        candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        c.save(candidate,'GATE_ACCEPTED')
        try:
            # Bypass neither a check nor a stop: restart the entire authorized
            # integration function, without entering the executor/reviewer loop.
            return c.finish_stage(candidate)
        except (Exception,KeyboardInterrupt) as e:
            candidate['diagnostic']=str(e) or 'INTERRUPTED';candidate['stop_class']='INTEGRATION'
            c.save(candidate,'HUMAN_STOP');raise
if __name__=='__main__':
    import argparse
    from stage10b import Stage10bController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    result=resume(Stage10bController(),a.receipt,a.sha256,a.head)
    print(json.dumps({'status':result['status'],'integration_commit':result.get('integration_commit'),'model_calls':0},indent=2))
