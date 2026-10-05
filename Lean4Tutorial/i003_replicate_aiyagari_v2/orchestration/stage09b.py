"""Isolated Stage-09b existence; no unassigned equilibrium gates."""
import json,re,shutil,subprocess,time
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
from stage09a import Stage09aController
BASE='2a7d0f7323634220227acdb530544ac00c8c98b0'
REG='reviews/stage09b_authorization.json'
IDS=['G02','G03']
AUTHORITY="Stage 09b only: M09B1=G02 then M09B2=G03, each separately reviewed and accepted, then STAGE09B_EXISTENCE_HUMAN_CHECKPOINT. No A04/A05/G04-G08 or Stage 10. Full Stage-09 prompt is context, not later implementation authority. Preserve exact manifest semantics and dependencies: G02 [P02,A03,B02,F02,G01]; G03 [P02,A03,B02,B03,F01,G01]. Execution order adds no dependency. Shared Existence.lean must preserve G02 byte-for-byte when appending G03; put gate-local helpers in Analysis/M09B1 or M09B2. Do not implement G03 during G02.\nEach new gate starts GPT-5.6 Sol Medium; only substantive same-gate revisions escalate High then XHigh. Infrastructure, capacity, parser and evidence failures consume no revision. Retain exact telemetry and every existing parser, global-status, source-union and stale-overview guard. Fresh read-only Astra High assesses D01-D20 on a complete immutable compact snapshot; any non-clean outcome receives fresh independent XHigh on the SAME snapshot without High prose as authority. Executor stops at REVIEW_READY, never GREEN.\nG02 must construct an actual accepted G01 StationaryEquilibrium for every finite b>=0 with -delta<r<lambda, lambda=1/beta-1. It is not merely a scalar root. Define the actual finite-cap household family along optimizing firm K(r),w(r) from F01 (a transitive accepted predecessor); P02 gives phi_b=min(b,w*l_min/r) for r>0, b otherwise and continuity through zero. Derive R=1+r>0, positive wage and beta*R<1 on (-delta,lambda) BEFORE invoking canonical stationary laws. Define actual excess NET asset supply X=S-K. Prove continuity by complete composition of F01, P02 and repaired A03 stationaryAssetSupply_joint_continuous in normalized prices and independent shift. Do not assume continuity or monotonicity as fields. F02 supplies an actual negative-rate lower endpoint with X<0. B02 supplies the upper sign along the actual firm wage schedule: prove w(r)->w(lambda)>0, normalized prices converge to critical admissible prices, finite-cap shift tends to a finite limit, and K(r)->K(lambda)<infinity. Only then derive X>0 at an actual r_U<lambda with r_L<r_U. Apply IVT on [r_L,r_U]; strict endpoint signs imply an interior root. From clearing X=0 construct ALL G01 fields: unchanged primitives, correct finite-cap original/normalized prices, canonical H05 lifetime optimality, actual kernel, invariant resource law, integrable resource/net-asset first moments, mean-one labor, budget normalization, firm optimization and capital clearing. Do not restrict the finite-cap root to positive rates.\nG03 uses natural-limit P02 prices only on 0<r<lambda; phi=w*l_min/r is never evaluated at zero. Prove actual X_N=S_N-K continuous on this open domain via F01/P02/A03 joint continuity. For the lower sign instantiate B03 along the actual firm wage schedule, proving w(r)->w(0)>0 and K(r)->K(0)<infinity as r->0+. Choose a finite positive r_L with X_N<0. B02 gives the upper sign with w(r)->w(lambda)>0, phi->w(lambda)*l_min/lambda finite, and K(r)->K(lambda); choose r_L<r_U<lambda. IVT on the actual compact positive-rate interval gives a strict interior root and 0<r<lambda. Construct all fields of the unchanged G01 equilibrium, with integrability, invariance and clearing proved. No F02/G02 negative-rate bracket substitution or new formal dependency. Generic accepted helpers may be reused only with their mathematical hypotheses discharged.\nBoth gates establish existence of one equilibrium only, not uniqueness, supply monotonicity, comparisons, every-equilibrium positivity/subcriticality, or G04. Preserve G01 and its noncircular unrestricted rate domain byte-for-byte. Stationarity at the constructed roots is legitimate only after deriving impatience. Do not assume any equilibrium/clearing/sign conclusion as primitive input. Preserve all predecessor qualifications, including finite moments for economic integrals, no moment convergence from weak convergence, no finite-time entry from weak drift, and fresh labor versus predetermined assets. Audit every new exported declaration and synchronize the full ledger Markdown/TeX/PDF INCLUDING the opening overview. Source evidence: approved A94 G02 printed670-671/PDF13-14 notes24-27; G03 printed673/PDF16 note30 with adjacent PDF15. G03's structured A93 source is resolved using its approved priority context and hash, not a web substitute. A94 motivates conclusions; the complete IVT construction and Lean bridges are project proofs, not literal source proofs."

class Stage09bController(Controller):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.gates=Stage09aController(root).gates
        by={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates=self.gates+[{'id':f'M09B{i}','contracts':[cid],'accepted':False,'module':by[cid]['module'],'signature_probe':f'Probes/M09B{i}Signatures.lean','report':f'reports/m09b{i}_milestone.md','analytical_audit':f'reports/m09b{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE09B_EXISTENCE_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage09b';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage09b_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored);self.preserve();return result
    def preserve(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE09B_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        ts=read_json(self.root/'contracts/theorems.json')['theorems']
        for t in ts:
            if t['stage'] in ('09','10','11') and t['id'] not in IDS+['F01','G01','F02'] and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE09B_LATER_STAGE_LEAKAGE')
    def commit_acceptance(self,state):
        super().commit_acceptance(state)
        self.git('push','origin','issue3')
        remote=self.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=self.git('rev-parse','HEAD').strip():raise Stop('REMOTE_ACCEPTANCE_MISMATCH')
        atomic_json(self.runtime/'accepted'/(state['gate']+'_remote.json'),{'remote':remote})
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage09aController(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE09A_FOUNDATIONS_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE09B_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(old.root/'reports/stage09a_integration_audit.json')['result']!='PASS':raise Stop('STAGE09A_INTEGRATION_REQUIRED')
        remote=old.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=old.git('rev-parse','HEAD').strip():raise Stop('STAGE09B_REMOTE_MISMATCH')
        if (old.root/REG).exists():raise Stop('STAGE09B_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if any(t['status']!='UNFORMALIZED' for t in ts if t['stage'] in ('09','10','11') and t['id'] not in ['F01','G01','F02']):raise Stop('STAGE09B_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M09B*/**/*invocation.json')):raise Stop('STAGE09B_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in ('Audit.lean','All.lean','Aiyagari1994.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage09bController(root);c.runtime.mkdir(parents=True,exist_ok=True)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-2:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize two isolated Stage 09b existence gates after accepted Stage 09a checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M09B1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    from orchestrate import canonical,decision
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE09B_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE09B_ACCEPTANCE_CHAIN')
    if any(any((re.fullmatch(r'M(?:09|10|11).*',part) and part not in {'M09A1','M09A2','M09A3','M09B1','M09B2'}) for part in p.parts) for p in (c.root/'tmp_orchestration').glob('**/*invocation.json')):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-5:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE09B_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    directory=c.runtime/'integration'/str(time.time_ns());directory.mkdir(parents=True);c.checks(c.gates[-1],directory)
    for g in c.gates[-5:]:
        result=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(g['id']+'_signatures.log')).write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('STAGE09B_SIGNATURE_CHECK_FAILED')
    atomic_json(c.root/'reports/stage09b_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(directory/'deterministic_summary.json'),'global_status':read_json(directory/'global_status_overview.json'),'unassigned_stage09_and_stage10_unstarted':True,'F01_G01_F02_G02_G03_green':True,'prior_42_green':True,'G01_byte_identical':True})
    (c.root/'reports/stage09b_integration_audit.md').write_text('# Stage-09b existence integration\n\nPASS. G02 and G03 independently accepted; all 42 prior GREEN contracts and the unrestricted G01 definition preserved; contracts, dependencies and accepted predecessors preserved. Builds, audits, signatures, allowed axioms, sources and global ledger synchronization pass. Unassigned Stage-09 contracts and Stage 10 remain unstarted.\n')
    c.git('add','--','reports/stage09b_integration_audit.json','reports/stage09b_integration_audit.md');c.git('commit','-m','Record passing Stage 09b existence integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
