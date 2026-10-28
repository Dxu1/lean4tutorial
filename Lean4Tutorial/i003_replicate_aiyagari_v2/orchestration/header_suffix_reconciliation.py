"""Explicit, hash-bound E02 infrastructure resume. Never dispatches any model."""
import copy,json
from pathlib import Path
from shared_imports import sha,certify
from shared_suffix import CLASSIFICATION

INFRA = {'orchestration/shared_suffix.py','orchestration/shared_imports.py',
         'orchestration/context_shared.py','orchestration/shared_provenance.py',
         'orchestration/gate_context.py','orchestration/shared_lifecycle.py',
         'orchestration/header_suffix_reconciliation.py',
         'orchestration/tests/test_header_suffix.py',
         'reports/e02_header_suffix_reconciliation.md'}
BASE = 'a070cfc574abc1fbd6fdabe735784cc173b938ae'


def need(ok, message):
    if not ok:
        from orchestrate import Stop
        raise Stop('E02_HEADER_SUFFIX_RECONCILIATION: '+message)


def eligible(s):
    invocation = dict(attempt=1,gate_id='M10B2',invocation_number=1,
                      model='gpt-5.6-sol',outcome='COMPLETED',reason='INITIAL',
                      reasoning_effort='medium',substantive_round=1)
    need(s.get('status')=='HUMAN_STOP' and s.get('gate')=='M10B2'
         and s.get('diagnostic')=='UNAUTHORIZED_SUFFIX_COMMAND','wrong incident')
    need(s.get('baseline')==BASE and s.get('attempt')==1 and s.get('revisions')==0
         and s.get('executor_effort_index')==0 and s.get('executor_history')==[invocation],
         'execution identity')
    need(not s.get('snapshot_sha256') and not s.get('reviewer_verdict')
         and not s.get('acceptance_committed'),'review already reached')


def rebind_valid(c, record, state):
    from shared_lifecycle import blob
    raw=Path(state['header_suffix_reconciliation']).read_bytes();r=json.loads(raw)
    need(sha(raw)==state['header_suffix_reconciliation_sha256'],'reconciliation hash')
    need(r['classification']==CLASSIFICATION and r['old_baseline']==record['baseline']==BASE
         and r['head']==state['baseline'],'baseline rebind')
    a=c.attempt_directory({'id':state['gate']},1)/'shared_candidate.json'
    need(r['candidate_receipt_sha256']==sha(a.read_bytes()),'original candidate receipt')
    prefix=c.git('rev-parse','--show-prefix').strip()
    need(c.git('rev-list','--parents','-n','1',state['baseline']).split()==[state['baseline'],BASE],'repair history')
    need(set(c.git('diff','--name-only',BASE,state['baseline']).splitlines())=={prefix+n for n in INFRA},'repair scope')
    need(blob(c,BASE,'Aiyagari1994/Extensions/BorrowingCap.lean')==blob(c,state['baseline'],'Aiyagari1994/Extensions/BorrowingCap.lean'),'baseline source')
    return True


def resume(c,receipt_path,receipt_sha,head):
    from orchestrate import atomic_json
    from shared_lifecycle import phase,blob
    from root_aggregators import accepted_provenance
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status();eligible(s)
        need(sha(raw)==receipt_sha and sha(c.state_path.read_bytes())==r['state_sha256'],'receipt/state')
        need(r['head']==BASE and c.git('rev-parse','HEAD').strip()==head
             and c.git('rev-list','--parents','-n','1',head).split()==[head,BASE],'repair history')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',BASE,head).splitlines())=={prefix+n for n in INFRA},'repair scope')
        need(not c.git('diff','--cached','--name-only').strip(),'dirty index')
        files=c.project_files();select=lambda d:{n:h for n,h in d.items() if n not in INFRA}
        need(select(files)==select(r['files']),'mathematical submission changed')
        for n,h in r['runtime_hashes'].items():need(sha(Path(n).read_bytes())==h,'original evidence changed: '+n)
        for n in INFRA:need(files[n]==sha(blob(c,head,n)),'dirty infrastructure')
        need(not list((c.runtime/'runs/M10B2').rglob('reviewer_invocation.json')),'review already started')
        need(not list((c.runtime/'runs/M10B3').rglob('*invocation*.json')),'E03 started')
        states={t['id']:t['status'] for t in json.loads((c.root/'contracts/theorems.json').read_text())['theorems']}
        need(states['E01']=='GREEN' and states['E02']=='REVIEW_READY' and states['E03']=='UNFORMALIZED'
             and sum(x=='GREEN' for x in states.values())==55,'status mutation')
        c.preserve();gate=next(g for g in c.gates if g['id']=='M10B2')
        need(phase(c,gate,s)=='POST_EXECUTOR','candidate lifecycle')
        # Certify against the original accepted baseline before changing runtime state.
        certificate=certify(c,gate,force=True)
        need(certificate['result']=='PASS','certificate failed')
        root=accepted_provenance(c)
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:candidate['initial_files'][n]=files[n]
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        need(outer==s['outer_status'],'unrelated work changed')
        path=Path(receipt_path).parent/'reconciliation.json';need(not path.exists(),'already reconciled')
        a=c.attempt_directory(gate,1)
        atomic_json(path,{'classification':CLASSIFICATION,'old_baseline':BASE,'head':head,
                         'receipt_sha256':receipt_sha,'original_status':s['status'],
                         'original_diagnostic':s['diagnostic'],
                         'history':['UNAUTHORIZED_SUFFIX_COMMAND','prior byte-zero requirement corrected',CLASSIFICATION],
                         'candidate_receipt_sha256':sha((a/'shared_candidate.json').read_bytes()),
                         'mathematical_hashes':select(files),'certificate':certificate,'root_aggregator':root,
                         'model_calls':0,'executor_rerun':False,'substantive_revisions':0})
        candidate['header_suffix_reconciliation']=str(path)
        candidate['header_suffix_reconciliation_sha256']=sha(path.read_bytes())
        need(phase(c,gate,candidate)=='POST_EXECUTOR','rebound lifecycle')
        c._semantic_scope(gate,candidate,candidate['initial_files'])
        candidate.setdefault('incident_history',[]).append({'classification':CLASSIFICATION,
            'status':s['status'],'diagnostic':s['diagnostic'],'receipt_sha256':receipt_sha,'reconciliation':str(path)})
        candidate['owned_files']=files
        for k in ('diagnostic','stop_class','verification_directory'):candidate.pop(k,None)
        c.save(candidate,'POST_EXECUTOR_RECONCILED')
        return {'status':candidate['status'],'executor_rerun':False,'model_calls':0,'revisions':0}

if __name__=='__main__':
    import argparse
    from stage10b import Stage10bController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage10bController(),a.receipt,a.sha256,a.head),indent=2))
