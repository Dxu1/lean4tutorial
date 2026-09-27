"""Explicit one-shot A03 post-acceptance repair, isolated from historical Stage-06 runs."""
import json,re,subprocess,shutil
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
BASE='f6761a7e0ae0d6d5404598cd7331db85a943d647'
REG='reviews/a03_repair_registration.json'
MODULE='Aiyagari1994/Aggregate/ParameterContinuity.lean'
AUTHORITY='''User-authorized same-contract A03 completion only. Expose genuine joint continuity on ImpatientPrices m × Real with independent normalized price and debt-shift coordinates, for the actual stationaryAssetSupply integral. Reuse the accepted stationaryMeanShiftedAssets_continuous and integrability/decomposition proofs byte-for-byte. Preserve the existing graph theorem; add an audited graph corollary by composition if useful. Add only append-only declarations to the A03 public module, reopening its namespace as necessary. Do not change any other accepted Lean body, contract semantics, or Stage-07 work. Update only the A03 ledger section plus generated status overview. Explain zero-net-rate nonidentification concisely, and retain economic normalization/nonnegative-debt qualifications. The previous graph-only coverage acceptance is historical and superseded for interface coverage by this explicit request; all other predecessor qualifications remain operative. Review independently whether joint (q, phi) variation is now covered throughout the strictly impatient region. No preference for any historical reviewer verdict is prescribed. Include the unchanged contract anchor and every new export in the exact signature probe. Synchronize the global ledger status overview. Use exact ledger status line **Status:** REVIEW_READY. (including the period).'''

def ledger_status(text,status,contracts):
    pat=r'(^## A03\b[^\n]*\n)(.*?)(?=^## |\Z)'
    def change(m):
        body,n=re.subn(r'^\*\*Status:\*\*[^\n]*',f'**Status:** {status}. **Scope:** core. **Milestone:** 06. **Gate:** M06DR.',m[2],count=1,flags=re.M)
        if n!=1:raise Stop('REPAIR_LEDGER_STATUS_AMBIGUOUS')
        return m[1]+body
    text,n=re.subn(pat,change,text,flags=re.M|re.S)
    if n!=1:raise Stop('REPAIR_LEDGER_SECTION_AMBIGUOUS')
    statuses={status:[t['id'] for t in contracts['theorems'] if t['status']==status] for status in ('GREEN','IN_PROGRESS','REVIEW_READY','UNFORMALIZED')}
    overview='**Economic status:** '+ '; '.join(', '.join(ids)+' are **'+status+'**' for status,ids in statuses.items() if ids)+'. M00 bootstrap acceptance remains infrastructure only. Exact acceptance records are in `reviews/`. Proposed proof plans remain proposed until checked.'
    text,n=re.subn(r'^\*\*Economic status:\*\*[^\n]*',lambda _:overview,text,count=1,flags=re.M)
    if n!=1:raise Stop('REPAIR_OVERVIEW_AMBIGUOUS')
    return text

class RepairController(Controller):
    repair_authority=AUTHORITY
    repair_export='Aiyagari1994.stationaryAssetSupply_joint_continuous'
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.runtime=self.root/'tmp_orchestration/a03_repair';self.state_path=self.runtime/'state.json'
        g=dict(self.gates[-1]);g.update(id='M06DR',signature_probe='Probes/M06DRSignatures.lean',report='reports/m06dr_milestone.md',analytical_audit='reports/m06dr_analytical_audit.md')
        self.gates=self.gates[:-1]+[g]
    def usage_report_path(self,gate):return 'reports/stage06_a03_repair_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored)
        self.preserve_predecessors()
        return result
    def preserve_predecessors(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if not (self.root/n).is_file() or digest((self.root/n).read_bytes())!=h:raise Stop('REPAIR_PREDECESSOR_CHANGED: '+n)
        # The mean-continuity proof and all accepted helper modules are protected above.
        prefix=self.git('rev-parse','--show-prefix').strip()
        old=self.git('show',BASE+':'+prefix+'docs/proof_ledger.md');new=(self.root/'docs/proof_ledger.md').read_text()
        def strip(s):
            s=re.sub(r'^\*\*Economic status:\*\*[^\n]*','',s,flags=re.M)
            return re.sub(r'^## A03\b.*?(?=^## |\Z)','',s,flags=re.M|re.S)
        if strip(old)!=strip(new):raise Stop('REPAIR_UNRELATED_LEDGER_CHANGED')
    def reconcile_export_name(self,expected_head):
        """Repair only the uncommunicated export-name expectation, never the Lean submission."""
        with self.lock():
            state=self.status()
            if not export_name_resume_eligible(state):raise Stop('REPAIR_EXPORT_RECONCILIATION_INELIGIBLE')
            head=self.git('rev-parse','HEAD').strip();old=state['baseline']
            if head!=expected_head or self.git('rev-list','--parents','-n','1','HEAD').split()!=[head,old]:raise Stop('REPAIR_INFRASTRUCTURE_BASELINE')
            allowed={'orchestration/a03_repair.py','orchestration/orchestrate.py','orchestration/tests/test_a03_repair.py'}
            prefix=self.git('rev-parse','--show-prefix').strip()
            changed=set(self.git('diff','--name-only',old,head).splitlines())
            if not changed or not changed<={prefix+n for n in allowed}:raise Stop('REPAIR_NON_INFRASTRUCTURE_COMMIT')
            if self.git('diff','--cached','--name-only').strip():raise Stop('REPAIR_STAGED_FILES')
            current=self.project_files();select=lambda d:{n:h for n,h in d.items() if n not in allowed}
            if select(current)!=select(state['owned_files']) or select(current)!=select(state['reviewed_files']):raise Stop('REPAIR_SUBMISSION_CHANGED')
            attempt=self.attempt_directory(self.gates[-1],state['attempt'])
            if list(attempt.rglob('reviewer_invocation.json')):raise Stop('REPAIR_REVIEW_ALREADY_STARTED')
            summary=read_json(attempt/state['verification_directory']/'deterministic_summary.json')
            if any(x['exit_code']!=0 for x in summary['checks'].values()):raise Stop('REPAIR_CHECKS_NOT_PASSED')
            initial=dict(state['initial_files'])
            for n in allowed:
                if n in current:
                    blob=subprocess.check_output(['git','show',head+':'+prefix+n],cwd=self.root)
                    if digest(blob)!=current[n]:raise Stop('REPAIR_UNCOMMITTED_INFRASTRUCTURE')
                    initial[n]=current[n]
            outer=sorted(x for x in self.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
            if outer!=state['outer_status']:raise Stop('OUTER_REPOSITORY_CHANGED')
            candidate=json.loads(json.dumps(state));candidate.update(baseline=head,initial_files=initial)
            self._semantic_scope(self.gates[-1],candidate,initial)
            evidence=self.runtime/'export_name_reconciliation.json'
            if evidence.exists():raise Stop('REPAIR_RECONCILIATION_ALREADY_RECORDED')
            atomic_json(evidence,{'classification':'INFRASTRUCTURE_EXPORT_NAME_MISMATCH','old_state':state,'old_baseline':old,'infrastructure_commit':head,'preserved_submission_hashes':select(current),'new_export':self.repair_export,'executor_reinvoked':False,'substantive_revisions':state['revisions']})
            candidate['owned_files']=current;candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
            self.save(candidate,'POST_EXECUTOR_RECONCILED');return candidate
    def authorize_executor_revision(self,state,reason):
        if (self.runtime/'global_status_reconciliation.json').exists():
            raise Stop('EVIDENCE_ONLY_AUTHORIZATION: mathematical revision requires human review')
        return super().authorize_executor_revision(state,reason)
    def reconcile_global_status(self,receipt_path,receipt_sha256,expected_head):
        with self.lock():
            raw=Path(receipt_path).read_bytes()
            if digest(raw)!=receipt_sha256:raise Stop('RECONCILE_RECEIPT_HASH_MISMATCH')
            receipt=json.loads(raw);state=self.status()
            if digest(self.state_path.read_bytes())!=receipt['state_sha256']:raise Stop('RECONCILE_STATE_CHANGED')
            if not global_status_resume_eligible(state):raise Stop('GLOBAL_STATUS_REPAIR_INELIGIBLE')
            self.verify_snapshot(state);self.preserve_predecessors()
            for n,h in receipt['executor_evidence'].items():
                if digest(Path(n).read_bytes())!=h:raise Stop('RECONCILE_EXECUTOR_EVIDENCE_CHANGED')
            head=self.git('rev-parse','HEAD').strip();old=state['baseline'];prefix=self.git('rev-parse','--show-prefix').strip()
            if head!=expected_head or self.git('rev-list','--parents','-n','1','HEAD').split()!=[head,old]:raise Stop('RECONCILE_BASELINE_MISMATCH')
            changed={n[len(prefix):] for n in self.git('diff','--name-only',old,head).splitlines() if n.startswith(prefix)}
            allowed={'orchestration/global_status.py','orchestration/mechanical.py','orchestration/gate_context.py','orchestration/a03_repair.py','orchestration/orchestrate.py','orchestration/tests/test_compact_context.py','orchestration/tests/test_global_status.py','orchestration/README.md'}
            if not changed or not changed<=allowed:raise Stop('RECONCILE_NON_INFRASTRUCTURE_COMMIT')
            current=self.project_files();select=lambda d:{n:h for n,h in d.items() if n not in allowed}
            if select(current)!=select(receipt['files']):raise Stop('RECONCILE_MATHEMATICAL_SUBMISSION_CHANGED')
            initial=dict(state['initial_files'])
            for n in changed:
                if digest(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=self.root))!=current[n]:raise Stop('RECONCILE_UNCOMMITTED_INFRASTRUCTURE')
                initial[n]=current[n]
            if self.git('diff','--cached','--name-only').strip():raise Stop('RECONCILE_STAGED_FILES')
            candidate=json.loads(json.dumps(state));candidate.update(baseline=head,initial_files=initial,owned_files=current,evidence_repair=True)
            self._semantic_scope(self.gates[-1],candidate,initial)
            from global_status import overview
            overview(self.root,self.gates[-1])
            record=self.runtime/'global_status_reconciliation.json'
            if record.exists():
                prior=read_json(record)
                if select(current)!=prior['unchanged_submission_hashes'] or 'UNREGISTERED_RUNTIME_EVIDENCE:' not in state.get('diagnostic','') or not state['diagnostic'].endswith('/global_status_overview.json'):raise Stop('RECONCILIATION_ALREADY_EXISTS')
                record=self.runtime/'global_status_registry_reconciliation.json'
                if record.exists():raise Stop('RECONCILIATION_ALREADY_EXISTS')
            atomic_json(record,{'classification':'REVIEW_CONTEXT_GLOBAL_STATUS_EVIDENCE_MISSING','receipt_sha256':receipt_sha256,'old_state':state,'infrastructure_commit':head,'unchanged_submission_hashes':select(current),'executor_rerun':False,'substantive_revisions':0})
            candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
            self.save(candidate,'POST_EXECUTOR_RECONCILED');return candidate
    def finish_stage(self,state):
        self.preserve_predecessors()
        from stage06 import integration
        integration(self,state)
        self.save(state,self.checkpoint)
        return state

def export_name_resume_eligible(state):
    return (state.get('status')=='HUMAN_STOP' and state.get('gate')=='M06DR'
        and state.get('diagnostic')=='REVIEW_CONTEXT_INCOMPLETE: new contract export coverage'
        and state.get('attempt')==1 and state.get('revisions')==0
        and state.get('reviewer_verdict') is None and state.get('snapshot_sha256') is None
        and state.get('acceptance_committed') is False
        and len(state.get('executor_history',[]))==1)

def activate(c):
    with c.lock():
        c.ensure_clean()
        if (c.root/REG).exists():raise Stop('A03_REPAIR_ALREADY_REGISTERED')
        old=c.status()
        if old['status']!='STAGE06_COMPLETE_HUMAN_CHECKPOINT' or old['accepted']!=c.reconstruct_accepted():raise Stop('A03_REPAIR_CHECKPOINT_REQUIRED')
        if c.git('branch','--show-current').strip()!='issue3':raise Stop('A03_REPAIR_BRANCH')
        c.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(c.root/'reports/stage06_integration_audit.json')['result']!='PASS':raise Stop('A03_REPAIR_INTEGRATION_REQUIRED')
        files=c.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in (MODULE,'Audit.lean','All.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('reports/stage06_usage_metrics.json','reports/stage06_usage_report.md','contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md')}
        record=c.acceptance_record(c.gates[-1]);contracts=read_json(c.root/'contracts/theorems.json');target=next(t for t in contracts['theorems'] if t['id']=='A03')
        if target['status']!='GREEN':raise Stop('A03_REPAIR_ACCEPTED_TARGET_REQUIRED')
        rc=RepairController(c.root);rc.runtime.mkdir(parents=True,exist_ok=True)
        if (c.runtime/'preflight.json').exists():shutil.copyfile(c.runtime/'preflight.json',rc.runtime/'preflight.json')
        atomic_json(rc.runtime/'original_state.json',old);atomic_json(rc.runtime/'original_files.json',files)
        for n in ('contracts/theorems.json','docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf'):
            p=rc.runtime/'activation_backup'/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(c.root/n,p)
        atomic_json(c.root/REG,{'kind':'A03_SAME_CONTRACT_REPAIR','historical_acceptance':record,'historical_checkpoint':BASE,'activation_parent':c.git('rev-parse','HEAD').strip(),'protected_files':protected,'authority':AUTHORITY,'new_gate':'M06DR','new_acceptance_path':'reviews/m06dr_acceptance.json','stop_checkpoint':c.checkpoint})
        target['status']='IN_PROGRESS';(c.root/'contracts/theorems.json').write_text(json.dumps(contracts,indent=2,ensure_ascii=False)+'\n')
        p=c.root/'docs/proof_ledger.md';p.write_text(ledger_status(p.read_text(),'IN_PROGRESS',contracts))
        result=subprocess.run(['bash','tools/build_docs.sh','proof_ledger'],cwd=c.root,text=True,capture_output=True)
        (rc.runtime/'activation_documentation.log').write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('A03_REPAIR_ACTIVATION_DOCUMENTATION')
        c.git('add','--',REG,'contracts/theorems.json','docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf');c.git('commit','-m','Register A03 joint-continuity repair and reopen review status')
        state={'status':'READY_TO_EXECUTE','gate':'M06DR','attempt':1,'baseline':c.git('rev-parse','HEAD').strip(),'accepted':old['accepted'][:-1],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        rc.save(state,'READY_TO_EXECUTE');rc.preserve_predecessors();return state

def global_status_resume_eligible(state):
    v=state.get('reviewer_verdict') or {};dims={d['dimension_id']:d['status'] for d in v.get('dimension_assessments',[])}
    h=state.get('executor_history',[])
    return (state.get('status')=='HUMAN_STOP' and state.get('gate')=='M06DR'
        and state.get('attempt')==1 and state.get('revisions')==0 and state.get('executor_effort_index')==0
        and len(h)==1 and h[0].get('model')=='gpt-5.6-sol' and h[0].get('reasoning_effort')=='medium' and h[0].get('outcome')=='COMPLETED'
        and v.get('verdict')=='BLOCK' and v.get('requires_human_review') is True
        and state.get('snapshot_sha256')=='c2a37a66c0ffb9729b769efb5aeaa19e36f97c0f9a9f275f4dcc5f8daeaa99d7'
        and set(dims)=={f'D{i:02d}' for i in range(1,21)} and all(dims[d]=='PASS' for d in dims if d not in ('D16','D20'))
        and len(v.get('blocking_findings',[]))==1 and 'global ledger status overview' in v['blocking_findings'][0])
