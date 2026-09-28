"""User-authorized, hash-bound N05 reconciliation and separate coverage revision.
No model invocation is possible here. Run the ordinary controller only afterward.
"""
import argparse,json,subprocess
from pathlib import Path
from orchestrate import Stop,read_json,atomic_json,digest
BASE='31b36f34f25d0ef7c21f7ce1c24d9d138b6199e6'
DIAGNOSTIC='REVIEW_CONTEXT_INCOMPLETE: signature missing/duplicate Aiyagari1994.M07B1.TwoStringSpace'
REPORT='reports/n05_parser_and_coverage_incident.md'
ALLOWED={'orchestration/gate_context.py','orchestration/orchestrate.py','orchestration/stage07b.py','orchestration/n05_repair.py','orchestration/tests/test_n05_repair.py','orchestration/tests/fixtures/n05_signature.log',REPORT}
def eligible(s):
    return (s.get('status')=='HUMAN_STOP' and s.get('gate')=='M07B1' and s.get('baseline')==BASE
        and s.get('diagnostic')==DIAGNOSTIC and s.get('attempt')==1 and s.get('revisions')==0
        and s.get('executor_effort_index')==0 and not s.get('reviewer_verdict') and not s.get('snapshot_sha256')
        and s.get('executor_history')==[{'attempt':1,'gate_id':'M07B1','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}])
def require(ok,msg):
    if not ok:raise Stop('N05_REPAIR_'+msg)
def select(files):return {n:h for n,h in files.items() if n not in ALLOWED}
def reconcile(c,receipt_sha,head):
    d=c.runtime/'n05_repair';receipt=read_json(d/'receipt.json');s=c.status()
    require(digest((d/'receipt.json').read_bytes())==receipt_sha,'RECEIPT_HASH')
    require(eligible(s) and digest(c.state_path.read_bytes())==receipt['state_sha256'],'IDENTITY')
    require(receipt['classification']=='SIGNATURE_RECORD_BOUNDARY_PARSER_DEFECT','CLASSIFICATION')
    require(s['executor_history']==receipt['executor_history'],'HISTORY')
    for n,h in receipt['runtime_evidence'].items():require(digest((c.root/n).read_bytes())==h,'EVIDENCE_CHANGED '+n)
    require(not list((c.runtime/'runs').glob('**/reviewer_invocation.json')),'REVIEW_ALREADY_OCCURRED')
    require(not any((c.runtime/'runs'/g).exists() for g in ('M07B2','M07B3')),'LATER_GATE')
    require(c.git('branch','--show-current').strip()=='issue3','BRANCH')
    require(c.git('rev-parse','HEAD').strip()==head and c.git('rev-list','--parents','-n','1','HEAD').split()==[head,BASE],'BASELINE')
    prefix=c.git('rev-parse','--show-prefix').strip();changed=set(c.git('diff','--name-only',BASE,head).splitlines())
    require(changed and changed<={prefix+n for n in ALLOWED},'NON_INFRA_COMMIT')
    require(not c.git('diff','--cached','--name-only').strip(),'STAGED_FILES')
    current=c.project_files();require(select(current)==select(receipt['files']),'SUBMISSION_CHANGED')
    initial=dict(s['initial_files'])
    for n in ALLOWED:
        require(n in current and digest(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=c.root))==current[n],'UNCOMMITTED_INFRA '+n)
        initial[n]=current[n]
    require(s['accepted']==c.reconstruct_accepted() and s['accepted'][-1]=='M07A4','PREDECESSORS')
    outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
    require(outer==s['outer_status'],'OUTER_CHANGED')
    gate=next(g for g in c.gates if g['id']=='M07B1');require(gate['contracts']==['N05'],'CONTRACT')
    candidate=json.loads(json.dumps(s));candidate.update(baseline=head,initial_files=initial,owned_files=current)
    c._semantic_scope(gate,candidate,initial)
    require(not (d/'reconciliation.json').exists(),'ALREADY_RECONCILED')
    atomic_json(d/'reconciliation.json',{'classification':receipt['classification'],'old_state':s,'infrastructure_commit':head,'receipt_sha256':receipt_sha,'unchanged_submission_hashes':select(current),'repair_model_invocations':0,'substantive_revisions':0})
    candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
    c.save(candidate,'N05_PARSER_RECONCILED');return candidate

def verify(c):
    s=c.status();require(s['status']=='N05_PARSER_RECONCILED','VERIFY_STATE')
    r=read_json(c.runtime/'n05_repair/reconciliation.json')
    require(select(c.project_files())==r['unchanged_submission_hashes'],'SUBMISSION_CHANGED')
    require(s['executor_history']==r['old_state']['executor_history'] and s['revisions']==0,'HISTORY')
    gate=next(g for g in c.gates if g['id']=='M07B1');attempt=c.attempt_directory(gate,1)
    directory=c.check_directory(gate,s,'pre_review');c.checks(gate,directory)
    s['verification_directory']=str(directory.relative_to(attempt))
    snapshot,sha=c.snapshot(gate,s,attempt) # validates REVIEW_CONTEXT_COMPLETE; no reviewer dispatch
    require(select(c.project_files())==r['unchanged_submission_hashes'],'SUBMISSION_CHANGED_AFTER_CHECKS')
    atomic_json(c.runtime/'n05_repair/validated_medium.json',{'snapshot':str(snapshot),'sha256':sha,'checks':str(directory),'executor_history':s['executor_history'],'model_calls':0,'substantive_revisions':0})
    s['owned_files']=c.project_files();c.save(s,'N05_COVERAGE_AUDIT_PENDING');return s

def authorize(c):
    s=c.status();d=c.runtime/'n05_repair';r=read_json(d/'reconciliation.json');v=read_json(d/'validated_medium.json')
    require(s['status']=='N05_COVERAGE_AUDIT_PENDING' and s['snapshot_sha256']==v['sha256'],'NOT_VALIDATED')
    require(select(c.project_files())==r['unchanged_submission_hashes'],'SUBMISSION_CHANGED')
    require(s['executor_history']==r['old_state']['executor_history'] and s['revisions']==0,'HISTORY')
    report=(c.root/REPORT).read_text();require('N05_CONTRACT_COVERAGE_DEFECT — CONFIRMED' in report,'COVERAGE_NOT_CONFIRMED')
    require(not (d/'coverage_authorization.json').exists(),'ALREADY_AUTHORIZED')
    c.authorize_executor_revision(s,'USER_COVERAGE_REVISION')
    s.update(revision_prompt='User-authorized N05 substantive revision #1. The original Medium attempt is undercovered. Repair N05 only according to this exact coverage audit and the stage authority. Do not defer the missing bridge to N06.\n'+report,snapshot_sha256=None,reviewer_verdict=None,acceptance_committed=False)
    require(c.executor_plan(s)['reasoning_effort']=='high' and s['revisions']==1 and s['attempt']==2,'EFFORT')
    atomic_json(d/'coverage_authorization.json',{'classification':'N05_CONTRACT_COVERAGE_DEFECT','audit_sha256':digest(report.encode()),'preserved_history':s['executor_history'],'next_effort':'high','substantive_revision':1,'medium_context_sha256':v['sha256']})
    c.save(s,'READY_TO_EXECUTE');return s
if __name__=='__main__':
    from stage07b import Stage07bController
    p=argparse.ArgumentParser();p.add_argument('action',choices=['reconcile','verify','authorize']);p.add_argument('--receipt-sha');p.add_argument('--head');a=p.parse_args();c=Stage07bController()
    with c.lock():
        s=reconcile(c,a.receipt_sha,a.head) if a.action=='reconcile' else verify(c) if a.action=='verify' else authorize(c)
    print(json.dumps({k:s[k] for k in ('status','gate','attempt','revisions','executor_history')},indent=2))
