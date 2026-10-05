"""Fail-closed repair of one derived overview label; never adjudicates adequacy."""
import copy,json,re,subprocess
from pathlib import Path
from review_evidence import STATUSES,ledger_errors
CLASSIFICATION='DERIVED_LEDGER_OVERVIEW_STALE'
DOCS={'docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf'}
INFRA={'orchestration/ledger_reconciliation.py','orchestration/orchestrate.py','orchestration/tests/test_ledger_reconciliation.py','reports/g01_ledger_reconciliation.md'}

def repaired_text(text,contracts,baseline,gate,state):
    def fail():raise ValueError('AMBIGUOUS_LEDGER_STATUS_CONFLICT')
    errors=ledger_errors(text,contracts['theorems'])
    if not errors:return text
    if errors!=['global overview differs from contracts']:fail()
    if state.get('status') not in ('DETERMINISTIC_CHECKS','POST_EXECUTOR_RECONCILED','HUMAN_STOP') or state.get('gate')!=gate['id']:fail()
    if state.get('snapshot_sha256') or state.get('reviewer_verdict') or state.get('acceptance_committed'):fail()
    history=state.get('executor_history',[])
    if not history or history[-1].get('outcome')!='COMPLETED':fail()
    expected=copy.deepcopy(baseline)
    for t in expected['theorems']:
        if t['id'] in gate['contracts']:t['status']='REVIEW_READY'
    if expected!=contracts:fail()
    lines=re.findall(r'^\*\*Economic status:\*\* (.*)$',text,re.M)
    if len(lines)!=1:fail()
    observed={}
    for ids,status in re.findall(r'([A-Z0-9, ]+) (?:is|are) \*\*('+STATUSES+r')\*\*',lines[0]):
        for sid in re.findall(r'\b[A-Z]+\d+\b',ids):
            if sid in observed:fail()
            observed[sid]=status
    states={t['id']:t['status'] for t in contracts['theorems']}
    if len(states)!=len(contracts['theorems']) or set(states)!=set(observed):fail()
    mismatches=[sid for sid in states if states[sid]!=observed[sid]]
    if len(mismatches)!=1:fail()
    sid=mismatches[0]
    old={t['id']:t['status'] for t in baseline['theorems']}
    if sid not in gate['contracts'] or states[sid]!='REVIEW_READY' or observed[sid] not in ('UNFORMALIZED','IN_PROGRESS','KERNEL_CHECKED') or old[sid]=='GREEN':fail()
    order=('GREEN','IN_PROGRESS','KERNEL_CHECKED','REVIEW_READY','UNFORMALIZED','BLOCKED')
    line='**Economic status:** '+'; '.join(', '.join(t['id'] for t in contracts['theorems'] if t['status']==status)+' are **'+status+'**' for status in order if status in states.values())+'. M00 bootstrap acceptance remains infrastructure only. Exact acceptance records are in `reviews/`. Proposed proof plans remain proposed until checked.'
    result=re.sub(r'^\*\*Economic status:\*\*[^\n]*',lambda _:line,text,flags=re.M)
    if ledger_errors(result,contracts['theorems']):fail()
    return result

def reconcile(c,gate,state):
    """Called only after normal semantic scope checks, before any review context."""
    from orchestrate import read_json,atomic_json,digest
    p=c.root/'docs/proof_ledger.md';before=p.read_text()
    after=repaired_text(before,read_json(c.root/'contracts/theorems.json'),c.baseline_contracts(state['baseline']),gate,state)
    if after==before:return False
    c._semantic_scope(gate,state,state['initial_files'])
    files=c.project_files();identity=copy.deepcopy(state)
    directory=c.runtime/'derived_ledger_reconciliation'/gate['id']/('attempt_%03d'%state['attempt'])
    directory.mkdir(parents=True,exist_ok=False)
    for n in DOCS:(directory/Path(n).name).write_bytes((c.root/n).read_bytes())
    atomic_json(directory/'before.json',{'files':files,'state':identity,'classification':CLASSIFICATION})
    p.write_text(after)
    c.command_log('documentation',['bash','tools/build_docs.sh','proof_ledger'],directory)
    current=c.project_files()
    if {n:h for n,h in files.items() if n not in DOCS}!={n:h for n,h in current.items() if n not in DOCS} or state!=identity:raise c.error('LEDGER_REPAIR_UNEXPECTED_MUTATION')
    from global_status import overview
    overview(c.root,gate)
    atomic_json(directory/'result.json',{'classification':CLASSIFICATION,'before_md':digest(before.encode()),'after_md':digest(after.encode()),'executor_rerun':False,'revisions':state['revisions'],'files':current})
    return True

def resume(c,receipt_path,receipt_sha,expected_head):
    from orchestrate import digest,read_json,atomic_json,Stop
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status()
        if digest(raw)!=receipt_sha or digest(c.state_path.read_bytes())!=r['state_sha256']:raise Stop('LEDGER_REPAIR_RECEIPT_CHANGED')
        h=s.get('executor_history',[])
        if not (s['status']=='HUMAN_STOP' and s['gate']=='M09A2' and s['diagnostic']=='LEDGER_STATUS_MISMATCH: global overview differs from contracts' and s['attempt']==1 and s['revisions']==0 and s['executor_effort_index']==0 and len(h)==1 and h[0]['model']=='gpt-5.6-sol' and h[0]['reasoning_effort']=='medium' and h[0]['outcome']=='COMPLETED' and not s.get('snapshot_sha256') and not s.get('reviewer_verdict')):raise Stop('LEDGER_REPAIR_INELIGIBLE')
        for n,v in r['executor_evidence'].items():
            if digest(Path(n).read_bytes())!=v:raise Stop('LEDGER_REPAIR_EXECUTOR_EVIDENCE_CHANGED')
        head=c.git('rev-parse','HEAD').strip();prefix=c.git('rev-parse','--show-prefix').strip()
        if head!=expected_head or c.git('rev-list','--parents','-n','1','HEAD').split()!=[head,s['baseline']]:raise Stop('LEDGER_REPAIR_BASELINE_CHANGED')
        changes=set(c.git('diff','--name-only',s['baseline'],head).splitlines())
        if changes!={prefix+n for n in INFRA}:raise Stop('LEDGER_REPAIR_COMMIT_SCOPE')
        if c.git('diff','--cached','--name-only').strip():raise Stop('LEDGER_REPAIR_INDEX_DIRTY')
        current=c.project_files();select=lambda d:{n:v for n,v in d.items() if n not in INFRA}
        if select(current)!=select(r['files']):raise Stop('LEDGER_REPAIR_SUBMISSION_CHANGED')
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:
            if digest(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=c.root))!=current[n]:raise Stop('LEDGER_REPAIR_INFRA_DIRTY')
            candidate['initial_files'][n]=current[n]
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        if outer!=s['outer_status']:raise Stop('LEDGER_REPAIR_OUTER_CHANGED')
        gate=next(g for g in c.gates if g['id']=='M09A2')
        c._semantic_scope(gate,candidate,candidate['initial_files']);c.preserve()
        if not reconcile(c,gate,candidate):raise Stop('LEDGER_REPAIR_NOT_STALE')
        candidate['owned_files']=c.project_files();candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        atomic_json(c.runtime/'ledger_overview_repair/reconciliation.json',{'classification':CLASSIFICATION,'receipt_sha256':receipt_sha,'infrastructure_commit':head,'executor_history':h,'substantive_revisions':0,'executor_rerun':False})
        c.save(candidate,'POST_EXECUTOR_RECONCILED')
        return {'status':candidate['status'],'gate':candidate['gate'],'executor_rerun':False}

if __name__=='__main__':
    import argparse
    from stage09a import Stage09aController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage09aController(),a.receipt,a.sha256,a.head),indent=2))
