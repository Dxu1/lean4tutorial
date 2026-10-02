"""Three authorized Stage-08 gates; isolated runtime and no Stage-09 dispatch."""
import json,re,shutil,subprocess,time
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
from stage07b import Stage07bController
BASE='afc5a552d1efd87acac2b98e78ae40273ee90380'
REG='reviews/stage08_authorization.json'
IDS=['B01','B02','B03']
AUTHORITY="""Stage 08 only. Each gate implements exactly its assigned B01/B02/B03 contract and directly necessary helpers; no later gate early and no Stage 09. Preserve all contract semantics and declared dependencies: B01 [], B02 [H06,A02,B01,N07], B03 [D03,A02]. New gates start GPT-5.6 Sol Medium; genuine substantive revisions only escalate High then XHigh. Infrastructure/capacity failures consume no mathematical revision and allow no fallback. Fresh read-only Astra High examines actual proof bodies on a complete immutable snapshot, with independent XHigh on any non-clean result.
B01 is generic Feller probability kernels on noncompact NNReal. Prove the bounded-test compact/tail split from local uniform kernel convergence and tightness; use Feller continuity of the limiting expectation to pass weak convergence, then bounded-continuous separation for invariance. No household assumptions, globally uniform convergence, compact state space, bounded supports, or moments.
B02: sequential upper-boundary divergence first, then contracted one-sided/filter formulation. From failure of S_n tending to positive infinity extract a bounded-above subsequence. A02 gives integrability and E[A]=S+phi and E[z]=R E[A]+E[e]; derive the uniform nonnegative resource first-moment bound and Markov tightness. Extract a weak subsequence via Prokhorov. H06 and canonical kernel interfaces must actually derive locally uniform bounded-test convergence on compact resource intervals; instantiate B01 at the exactly critical limiting kernel and contradict N07. Never assume tightness, means, kernel convergence, boundary invariant continuity, exploding support or pathwise divergence in lieu of these derivations. S06 does not extend to the critical boundary.
B03: use the normalized family R=1+r, effective income w*(l-l_min), intercept -w*l_min. The raw shift phi=w*l_min/r diverges and must stay OUTSIDE household continuity/drift parameters. D03 gives local strictly impatient common compact control; derive a uniform stationary shifted-saving mean bound, respecting its weak-drift qualification, and use A02 with integrability. Prove phi tends to positive infinity from positive minimum labor, positive wage limit and r tending to zero from above; conclude S=E[A]-phi tends to negative infinity. No B02/N07, monotonicity, equilibrium, or finite institutional cap substitute. Prove sequential result before the contracted filter formulation.
All applicable predecessor qualifications remain operative. The noncompact limit and boundary proofs are project reconstructions, not literal SLP/C90/A94 proofs. C90 Proposition 2.4 is stated without proof. Audit every new export with #check/assert_no_sorry/#print axioms; synchronize ledger Markdown/TeX/PDF and global status. Executor stops at REVIEW_READY, never GREEN. Astra must inspect that every intermediate bridge is derived, not assumed."""

class Stage08Controller(Controller):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.gates=Stage07bController(root).gates
        by={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates=self.gates+[{'id':f'M08{chr(64+i)}','contracts':[cid],'accepted':False,'module':by[cid]['module'],'signature_probe':f'Probes/M08{chr(64+i)}Signatures.lean','report':f'reports/m08{chr(96+i)}_milestone.md','analytical_audit':f'reports/m08{chr(96+i)}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE08_COMPLETE_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage08';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage08_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored);self.preserve();return result
    def preserve(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE08_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        ts=read_json(self.root/'contracts/theorems.json')['theorems']
        for t in ts:
            if t['stage'] in ('09','10','11') and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE08_LATER_STAGE_LEAKAGE')
    def commit_acceptance(self,state):
        super().commit_acceptance(state)
        self.git('push','origin','issue3')
        remote=self.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=self.git('rev-parse','HEAD').strip():raise Stop('REMOTE_ACCEPTANCE_MISMATCH')
        atomic_json(self.runtime/'accepted'/(state['gate']+'_remote.json'),{'remote':remote})
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage07bController(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE07B_COMPLETE_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE08_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(old.root/'reports/stage07b_integration_audit.json')['result']!='PASS':raise Stop('STAGE07_INTEGRATION_REQUIRED')
        remote=old.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=old.git('rev-parse','HEAD').strip():raise Stop('STAGE08_REMOTE_MISMATCH')
        if (old.root/REG).exists():raise Stop('STAGE08_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if any(t['status']!='UNFORMALIZED' for t in ts if t['id'] in IDS+['A04','A05','F01','F02']):raise Stop('STAGE08_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M08*/**/*invocation.json')):raise Stop('STAGE08_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in ('Audit.lean','All.lean','Aiyagari1994.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage08Controller(root);c.runtime.mkdir(parents=True,exist_ok=True)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-3:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize three isolated Stage 08 gates after accepted Stage 07 checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M08A','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    from orchestrate import canonical,decision
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE08_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE08_ACCEPTANCE_CHAIN')
    if any(any(re.fullmatch(r'M(?:09|10|11).*',part) for part in p.parts) for p in (c.root/'tmp_orchestration').glob('**/*invocation.json')):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-10:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE08_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    directory=c.runtime/'integration'/str(time.time_ns());directory.mkdir(parents=True);c.checks(c.gates[-1],directory)
    for g in c.gates[-10:]:
        result=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(g['id']+'_signatures.log')).write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('STAGE08_SIGNATURE_CHECK_FAILED')
    atomic_json(c.root/'reports/stage08_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(directory/'deterministic_summary.json'),'global_status':read_json(directory/'global_status_overview.json'),'stage09_unstarted':True,'B01_B03_green':True,'N01_N07_green':True})
    (c.root/'reports/stage08_integration_audit.md').write_text('# Stage-08 integration\n\nPASS. B01–B03 and N01–N07 independently accepted; contracts, dependencies and accepted predecessors preserved. Builds, audits, signatures, allowed axioms, sources and global ledger synchronization pass. Stage 09 and later stages remain unstarted.\n')
    c.git('add','--','reports/stage08_integration_audit.json','reports/stage08_integration_audit.md');c.git('commit','-m','Record passing Stage 08 integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
