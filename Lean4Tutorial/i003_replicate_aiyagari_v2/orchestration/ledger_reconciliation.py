"""Fail-closed repair of one derived overview label; never adjudicates adequacy."""
import copy,json,re,subprocess
from pathlib import Path
from review_evidence import STATUSES,ledger_errors
from contract_id_lists import parse_overview
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
    states={t['id']:t['status'] for t in contracts['theorems']}
    try:observed=parse_overview(lines[0],states,STATUSES)
    except ValueError:fail()
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

# User-authorized, incident-specific recovery. No executor or reviewer call is made here.
CONJUNCTION_CLASS='LEDGER_CONTRACT_ID_LIST_CONJUNCTION_PARSER_DEFECT'
CONJUNCTION_INFRA={'orchestration/contract_id_lists.py','orchestration/review_evidence.py',
    'orchestration/ledger_reconciliation.py','orchestration/tests/test_contract_id_lists.py',
    'reports/e01_ledger_parser_repair.md','orchestration/tests/test_compact_context.py','orchestration/tests/test_stage10b.py'}
def conjunction_eligible(s):
    expected=[{'attempt':1,'gate_id':'M10B1','invocation_number':1,'model':'gpt-5.6-sol',
        'outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}]
    return (s.get('status')=='HUMAN_STOP' and s.get('gate')=='M10B1'
        and s.get('diagnostic')=='AMBIGUOUS_LEDGER_STATUS_CONFLICT'
        and s.get('attempt')==1 and s.get('revisions')==0 and s.get('executor_effort_index')==0
        and s.get('executor_history')==expected and not s.get('snapshot_sha256')
        and not s.get('reviewer_verdict') and not s.get('acceptance_committed'))

def resume_conjunction(c,receipt_path,receipt_sha,head):
    """Rebind only a parser-only child commit, preserving the original stopped attempt."""
    from orchestrate import digest,atomic_json,Stop
    from root_aggregators import certify
    def need(ok,msg):
        if not ok:raise Stop('E01_LEDGER_PARSER_REPAIR: '+msg)
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status()
        need(digest(raw)==receipt_sha and digest(c.state_path.read_bytes())==r['state_sha256'],'receipt/state changed')
        need(conjunction_eligible(s),'wrong incident/executor/review identity')
        need(s['baseline']==r['head'] and c.git('rev-parse','HEAD').strip()==head,'baseline/head')
        need(c.git('rev-list','--parents','-n','1',head).split()==[head,r['head']],'non-child repair commit')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',r['head'],head).splitlines())=={prefix+n for n in CONJUNCTION_INFRA},'repair commit scope')
        need(not c.git('diff','--cached','--name-only').strip(),'dirty index')
        files=c.project_files();select=lambda d:{n:h for n,h in d.items() if n not in CONJUNCTION_INFRA}
        need(select(files)==select(r['files']),'submission changed')
        for n,h in r['runtime_hashes'].items():need(digest(Path(n).read_bytes())==h,'original evidence changed: '+n)
        for n in CONJUNCTION_INFRA:need(digest(c.git('show',head+':'+prefix+n).encode())==files[n],'dirty infrastructure')
        need(not list((c.runtime/'runs/M10B1').rglob('reviewer_invocation.json')),'review already started')
        need(not list((c.runtime/'runs').glob('M10B[23]/**/*invocation.json')),'later gate started')
        ts=json.loads((c.root/'contracts/theorems.json').read_text())['theorems'];states={t['id']:t['status'] for t in ts}
        need(states['E01']=='REVIEW_READY' and states['E02']==states['E03']=='UNFORMALIZED' and sum(v=='GREEN' for v in states.values())==54,'status mutation')
        need(not (c.root/'Aiyagari1994/Analysis/M10B2').exists() and not (c.root/'Aiyagari1994/Extensions/GovernmentDebt.lean').exists(),'later implementation')
        ledger=(c.root/'docs/proof_ledger.md').read_text()
        need('E02 and E03 are **UNFORMALIZED**' in ledger and not ledger_errors(ledger,ts),'corrected parser does not validate unchanged ledger')
        c.preserve();gate=next(g for g in c.gates if g['id']=='M10B1')
        certificate=certify(c,gate)
        need(certificate['result']=='PASS' and certificate['accepted_declaration_count']==54,'root certificate')
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in CONJUNCTION_INFRA:candidate['initial_files'][n]=files[n]
        c._semantic_scope(gate,candidate,candidate['initial_files'])
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        need(outer==s['outer_status'],'unrelated work changed')
        path=Path(receipt_path).parent/'reconciliation.json';need(not path.exists(),'already reconciled')
        atomic_json(path,{'classification':CONJUNCTION_CLASS,'original_status':'HUMAN_STOP','original_diagnostic':s['diagnostic'],'old_baseline':r['head'],'infrastructure_commit':head,'receipt_sha256':receipt_sha,'mathematical_and_ledger_hashes':select(files),'root_certificate':certificate,'model_calls':0,'executor_rerun':False,'substantive_revisions':0})
        candidate.setdefault('incident_history',[]).append({'classification':CONJUNCTION_CLASS,'status':s['status'],'diagnostic':s['diagnostic'],'receipt_sha256':receipt_sha,'reconciliation':str(path)})
        candidate['owned_files']=files;candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        candidate.pop('verification_directory',None)
        c.save(candidate,'POST_EXECUTOR_RECONCILED')
        return {'status':candidate['status'],'executor_rerun':False,'model_calls':0,'substantive_revisions':0}
