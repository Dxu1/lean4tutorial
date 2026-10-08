"""Status-only acceptance reconciliation; immutable adequacy evidence is never replaced."""
import copy,json,re,shutil
from pathlib import Path
from review_evidence import ledger_errors

CLASSIFICATION='ACCEPTANCE_PHASE_CROSS_REFERENCE_STATUS_STALE'
INFRA={'orchestration/acceptance_status.py','orchestration/orchestrate.py',
       'orchestration/tests/test_acceptance_status.py','reports/a05_acceptance_status_reconciliation.md'}
DOCS={'docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf'}

def fail():raise ValueError('AMBIGUOUS_ACCEPTANCE_STATUS_CONFLICT')

def promote_metadata(text,contracts,gate):
    """Generate detailed and overview lifecycle metadata from structured state."""
    path=f"reviews/{gate['id'].lower()}_acceptance.md"
    for cid in gate['contracts']:
        pat=r'(^## '+re.escape(cid)+r'\b.*?\n)(.*?)(?=^## |\Z)'
        def promote(m):
            section,n=re.subn(r'\*\*Status:\*\* REVIEW_READY\.',f'**Status:** GREEN. Independent Astra acceptance: `{path}`.',m[2],count=1)
            if n!=1:fail()
            return m[1]+section
        text,n=re.subn(pat,promote,text,flags=re.M|re.S)
        if n!=1:fail()
    statuses={status:[t['id'] for t in contracts['theorems'] if t['status']==status] for status in ('GREEN','REVIEW_READY','UNFORMALIZED')}
    overview='**Economic status:** '+ '; '.join(', '.join(ids)+' are **'+status+'**' for status,ids in statuses.items() if ids)+'. M00 bootstrap acceptance remains infrastructure only. Exact acceptance records are in `reviews/`. Proposed proof plans remain proposed until checked.'
    text,n=re.subn(r'^\*\*Economic status:\*\*[^\n]*',lambda _:overview,text,count=1,flags=re.M)
    if n!=1:fail()
    return text

def repair(text,reviewed_text,contracts,reviewed_contracts,gate,state):
    """Only a complete standalone lifecycle sentence in another GREEN section.

    No arbitrary prose rewriting: unsupported grammar, multiple mismatches, historical
    assertions, changed mathematics or contract drift all fail closed.
    """
    errors=ledger_errors(text,contracts['theorems'])
    if not errors:return text
    v=state.get('reviewer_verdict') or {}
    if state.get('status')!='ACCEPTANCE_RECORDING' or state.get('gate')!=gate['id']:fail()
    if v.get('verdict')!='PASS' or v.get('confidence')!='HIGH' or v.get('requires_human_review') is not False or v.get('blocking_findings'):fail()
    if v.get('snapshot_sha256')!=state.get('snapshot_sha256') or not state.get('snapshot_sha256'):fail()
    expected=copy.deepcopy(reviewed_contracts)
    for t in expected['theorems']:
        if t['id'] in gate['contracts']:
            if t['status']!='REVIEW_READY':fail()
            t['status']='GREEN'
    if expected!=contracts or ledger_errors(reviewed_text,reviewed_contracts['theorems']):fail()
    if text!=promote_metadata(reviewed_text,contracts,gate):fail()
    if len(gate['contracts'])!=1:fail()
    cid=gate['contracts'][0]
    if errors!=['current prose '+cid+' claims REVIEW_READY']:fail()
    states={t['id']:t['status'] for t in contracts['theorems']}
    pattern=r'(?<=[.\n]) '+re.escape(cid)+r' is separately REVIEW_READY below\.'
    matches=[]
    for sec in re.finditer(r'^## ([A-Z]+\d+)\b[^\n]*\n(.*?)(?=^## |\Z)',text,re.M|re.S):
        for m in re.finditer(pattern,sec[2]):
            if sec[1]==cid or states.get(sec[1])!='GREEN':fail()
            matches.append((sec.start(2)+m.start(),sec.start(2)+m.end()))
    if len(matches)!=1:fail()
    start,end=matches[0]
    result=text[:start]+' '+cid+' is addressed separately below.'+text[end:]
    if ledger_errors(result,contracts['theorems']):fail()
    return result

def authorize(c,gate,state):
    from orchestrate import decision,read_json
    from compact_review import dimensions
    c.verify_snapshot(state)
    v=state['reviewer_verdict'];history=state['reviewer_history'];op=state['operative_reviewer']
    if op['phase']!=history['operative'] or history[op['phase']]['verdict']!=v:fail()
    dimensions(v,read_json(Path(state['snapshot_path'])/'evidence_aliases.json'))
    if decision(v,gate,state['attempt'],state['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':fail()

def resume(c,receipt_path,receipt_sha,expected_head):
    """Explicit hash-bound recovery of this interrupted post-review transaction."""
    from orchestrate import read_json,atomic_json,digest
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status()
        if digest(raw)!=receipt_sha or digest(c.state_path.read_bytes())!=r['state_sha256']:fail()
        if s['status']!='HUMAN_STOP' or s['gate']!='M09C2' or s['diagnostic']!='LEDGER_STATUS_MISMATCH: current prose A05 claims REVIEW_READY':fail()
        if s['attempt']!=1 or s['revisions']!=0 or s['executor_history']!=r['state']['executor_history'] or len(s['executor_history'])!=1:fail()
        h=s['executor_history'][0]
        if h['model']!='gpt-5.6-sol' or h['reasoning_effort']!='medium' or h['outcome']!='COMPLETED':fail()
        head=c.git('rev-parse','HEAD').strip();prefix=c.git('rev-parse','--show-prefix').strip()
        if head!=expected_head:fail()
        c.git('merge-base','--is-ancestor',r['head'],head)
        for commit in c.git('rev-list',r['head']+'..'+head).split():
            if not set(c.git('diff-tree','--no-commit-id','--name-only','-r',commit).splitlines())<={prefix+n for n in INFRA}:fail()
        if set(c.git('diff','--name-only',r['head'],head).splitlines())!={prefix+n for n in INFRA}:fail()
        if c.git('diff','--cached','--name-only').strip():fail()
        current=c.project_files();select=lambda d:{n:v for n,v in d.items() if n not in INFRA}
        if select(current)!=select(r['files']):fail()
        for n in INFRA:
            if digest(c.git('show',head+':'+prefix+n).encode())!=current[n]:fail()
        if s['reviewer_verdict']!=r['reviewer_verdict'] or s['snapshot_sha256']!=r['snapshot_sha256']:fail()
        gate=next(g for g in c.gates if g['id']==s['gate']);authorize(c,gate,s);c.preserve()
        # Every project Lean file, including helpers, Audit and probes, retains reviewed bytes.
        if {n:h for n,h in current.items() if n.endswith('.lean')}!={n:h for n,h in s['reviewed_files'].items() if n.endswith('.lean')}:fail()
        m=read_json(Path(s['snapshot_path'])/'snapshot_manifest.json')
        if any(current.get(n)!=h for n,h in m['files'].items() if n.endswith('.lean')):fail()
        d=Path(receipt_path).parent;reviewed=(d/'reviewed_ledger.md').read_text()
        if digest(reviewed.encode())!=s['reviewed_files']['docs/proof_ledger.md']:fail()
        contracts=read_json(c.root/'contracts/theorems.json');reviewed_contracts=copy.deepcopy(contracts)
        for t in reviewed_contracts['theorems']:
            if t['id']=='A05':t['status']='REVIEW_READY'
        if digest((json.dumps(reviewed_contracts,indent=2,ensure_ascii=False)+'\n').encode())!=s['reviewed_files']['contracts/theorems.json']:fail()
        expected=c.baseline_contracts(r['head'])
        for t in expected['theorems']:
            if t['id']=='A05':t['status']='GREEN'
        if contracts!=expected:fail()
        # Every original reviewed artifact other than derived acceptance outputs is preserved.
        allowed=DOCS|{'contracts/theorems.json'}|INFRA
        for n,h in s['reviewed_files'].items():
            if n not in allowed and current.get(n)!=h:fail()
        evidence=read_json(c.root/'reviews/m09c2_acceptance.json')['evidence_directory']
        new_allowed={'reviews/m09c2_acceptance.json','reviews/m09c2_acceptance.md'}|INFRA
        if any(n not in new_allowed and not n.startswith(evidence+'/') for n in current.keys()-s['reviewed_files'].keys()):fail()
        rec=read_json(c.root/'reviews/m09c2_acceptance.json')
        if rec['snapshot_sha256']!=s['snapshot_sha256'] or rec['final_verdict']!='PASS' or read_json(c.root/evidence/'reviewer_final.json')!=s['reviewer_verdict']:fail()
        candidate=copy.deepcopy(s);candidate['status']='ACCEPTANCE_RECORDING'
        ledger=c.root/'docs/proof_ledger.md';before=ledger.read_text()
        after=repair(before,reviewed,contracts,reviewed_contracts,gate,candidate)
        if before==after:fail()
        candidate['baseline']=head
        for n in INFRA:candidate['initial_files'][n]=current[n]
        c._semantic_scope(gate,candidate,candidate['initial_files'],ready=False,ignored=set(current)-set(s['reviewed_files'])|DOCS)
        ledger.write_text(after)
        directory=c.check_directory(gate,candidate,'acceptance')
        c.command_log('documentation',['bash','tools/build_docs.sh','proof_ledger'],directory/'regenerate_tracked_docs')
        c.checks(gate,directory);authorize(c,gate,s);c.preserve()
        final=c.project_files()
        if {n:h for n,h in final.items() if n not in DOCS}!={n:h for n,h in current.items() if n not in DOCS}:fail()
        if ledger.read_text()!=after:fail()
        shutil.copyfile(directory/'deterministic_summary.json',c.root/evidence/'acceptance_summary.json')
        atomic_json(d/'reconciliation.json',{'classification':CLASSIFICATION,'original_stop':r['state']['diagnostic'],'infrastructure_commit':head,'receipt_sha256':receipt_sha,'snapshot_sha256':s['snapshot_sha256'],'operative_verdict':s['reviewer_verdict'],'executor_history':s['executor_history'],'substantive_revisions':0,'new_model_calls':0,'checks':str(directory),'before_ledger':digest(before.encode()),'after_ledger':digest(after.encode()),'all_reviewed_lean_unchanged':True})
        candidate['acceptance_files']=c.project_files();candidate['acceptance_message']=f"Accept Aiyagari {gate['id']} after independent Astra review {s['snapshot_sha256']}"
        candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        c.save(candidate,'ACCEPTANCE_COMMIT_PENDING');c.commit_acceptance(candidate)
        return {'status':candidate['status'],'commit':candidate['baseline'],'classification':CLASSIFICATION,'new_model_calls':0}

if __name__=='__main__':
    import argparse
    from stage09c import Stage09cController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha256');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage09cController(),a.receipt,a.sha256,a.head),indent=2))
