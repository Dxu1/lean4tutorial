"""Hash-bound, one-shot N02 parser reconciliation; no model invocation."""
import json,subprocess
from pathlib import Path
from orchestrate import Stop,read_json,atomic_json,digest
BASE='a3c2afc8018b0182b671436a8c6c44793f36711c'
DIAGNOSTIC='REVIEW_CONTEXT_INCOMPLETE: signature missing/duplicate Aiyagari1994.stationary_bounded_jensen_equality'
ALLOWED={'orchestration/gate_context.py','orchestration/signature_repair.py','orchestration/orchestrate.py','orchestration/tests/test_signature_repair.py','orchestration/tests/test_compact_context.py','orchestration/tests/fixtures/n02_signature.log','orchestration/README.md','reports/n02_signature_parser_incident.md'}
def eligible(state):
    history=state.get('executor_history',[])
    return (state.get('status')=='HUMAN_STOP' and state.get('gate')=='M07A2'
        and state.get('diagnostic')==DIAGNOSTIC and state.get('baseline')==BASE
        and state.get('attempt')==1 and state.get('revisions')==0
        and state.get('executor_effort_index')==0 and not state.get('acceptance_committed')
        and state.get('reviewer_verdict') is None and state.get('snapshot_sha256') is None
        and len(history)==1 and history[0]=={'attempt':1,'gate_id':'M07A2','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1})
def reconcile(c,receipt_path,receipt_sha256,expected_head):
    with c.lock():
        raw=Path(receipt_path).read_bytes()
        if digest(raw)!=receipt_sha256:raise Stop('SIGNATURE_REPAIR_RECEIPT_HASH')
        receipt=json.loads(raw);state=c.status()
        if digest(c.state_path.read_bytes())!=receipt['state_sha256'] or not eligible(state):raise Stop('SIGNATURE_REPAIR_IDENTITY')
        if receipt['classification']!='LEAN_UNIVERSE_SIGNATURE_PARSER_DEFECT' or receipt['baseline']!=BASE:raise Stop('SIGNATURE_REPAIR_CLASSIFICATION')
        if receipt['executor_history']!=state['executor_history']:raise Stop('SIGNATURE_REPAIR_EXECUTOR_CHANGED')
        attempt=c.runtime/'runs/M07A2/attempt_001'
        current_runtime={str(p.relative_to(c.root)):digest(p.read_bytes()) for p in attempt.rglob('*') if p.is_file()}
        if current_runtime!=receipt['runtime_evidence'] or list(attempt.rglob('reviewer_invocation.json')):raise Stop('SIGNATURE_REPAIR_EVIDENCE_CHANGED')
        head=c.git('rev-parse','HEAD').strip();prefix=c.git('rev-parse','--show-prefix').strip()
        if head!=expected_head or c.git('rev-list','--parents','-n','1','HEAD').split()!=[head,BASE]:raise Stop('SIGNATURE_REPAIR_BASELINE')
        changed=set(c.git('diff','--name-only',BASE,head).splitlines())
        if not changed or not changed<={prefix+n for n in ALLOWED}:raise Stop('SIGNATURE_REPAIR_NON_INFRASTRUCTURE_COMMIT')
        if c.git('diff','--cached','--name-only').strip():raise Stop('SIGNATURE_REPAIR_STAGED_FILES')
        current=c.project_files();select=lambda fs:{n:h for n,h in fs.items() if n not in ALLOWED}
        if select(current)!=select(receipt['files']) or select(current)!=select(state['owned_files']):raise Stop('SIGNATURE_REPAIR_SUBMISSION_CHANGED')
        if state['accepted']!=c.reconstruct_accepted() or state['accepted'][-1]!='M07A1':raise Stop('SIGNATURE_REPAIR_PREDECESSOR')
        gate=next(g for g in c.gates if g['id']=='M07A2')
        if gate['contracts']!=['N02']:raise Stop('SIGNATURE_REPAIR_CONTRACT')
        summary=read_json(attempt/state['verification_directory']/'deterministic_summary.json')
        if not summary['passed'] or any(x['exit_code'] for x in summary['checks'].values()):raise Stop('SIGNATURE_REPAIR_CHECKS_FAILED')
        from gate_context import signatures
        name='Aiyagari1994.stationary_bounded_jensen_equality'
        log=(attempt/state['verification_directory']/'signatures.log').read_text()
        signatures(log,[name]) # Fixed parser must accept actual preserved Lean output.
        initial=dict(state['initial_files'])
        for n in ALLOWED:
            if n in current:
                if digest(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=c.root))!=current[n]:raise Stop('SIGNATURE_REPAIR_UNCOMMITTED_INFRASTRUCTURE')
                initial[n]=current[n]
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        if outer!=state['outer_status']:raise Stop('OUTER_REPOSITORY_CHANGED')
        candidate=json.loads(json.dumps(state));candidate.update(baseline=head,initial_files=initial,owned_files=current)
        c._semantic_scope(gate,candidate,initial)
        evidence=c.runtime/'signature_reconciliation.json'
        if evidence.exists():raise Stop('SIGNATURE_REPAIR_ALREADY_RECONCILED')
        atomic_json(evidence,{'classification':'LEAN_UNIVERSE_SIGNATURE_PARSER_DEFECT','receipt_sha256':receipt_sha256,'old_state':state,'infrastructure_commit':head,'unchanged_submission_hashes':select(current),'executor_rerun':False,'repair_model_invocations':0,'substantive_revisions':0})
        candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        c.save(candidate,'POST_EXECUTOR_RECONCILED');return candidate
