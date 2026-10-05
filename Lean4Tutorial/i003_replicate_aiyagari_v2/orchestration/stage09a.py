"""Isolated Stage-09 foundations; no unassigned equilibrium gates."""
import json,re,shutil,subprocess,time
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
from stage08 import Stage08Controller
BASE='d89b2bf213091a80f5db4d25d0a092de55ce1e0e'
REG='reviews/stage09a_authorization.json'
IDS=['F01','G01','F02']
AUTHORITY="""Stage 09a foundations only: M09A1=F01, M09A2=G01, M09A3=F02, then STAGE09A_FOUNDATIONS_HUMAN_CHECKPOINT. The full Stage-09 prompt is context, not authorization for other contracts. Never implement G02/G03/A04/A05/G04-G08 or Stage 10. Do not change contracts/milestones.json. Exact dependencies remain F01 [], G01 [P01,H05,S01,A01,F01], F02 [P02,A02,F01]. No hidden later-economic prerequisites.
Every new gate starts GPT-5.6 Sol Medium. Only substantive same-gate revisions escalate High then XHigh. Infrastructure, schema, parser, evidence and capacity failures consume no substantive revision. No automatic model fallback. Fresh read-only Astra High reviews actual proof bodies and all D01-D20 dimensions on a complete immutable snapshot; any non-clean outcome receives independent XHigh adjudication of the SAME snapshot, without High prose as authority.
F01 uses exactly PRODUCTION: f(0)=0, continuous on nonnegative capital, C2 on positive capital, f'>0, f''<0, Inada at zero, derivative tending to zero at infinity, 0<delta<1. Construct the unique positive solution f'(K)=r+delta for every r>-delta from the derivative range and strict decrease. Prove global unique profit-maximizing capital ratio, not merely the FOC; derive wage f(K)-K*f'(K)>0 from strict concavity and f(0)=0. Prove continuity of K and wage and strict decrease of K. Do not assume demand/wage fields or restrict the general theorem to Cobb-Douglas. Separately verify sqrt(K), delta=1/2 as a full production witness and combine with accepted P03 for nonempty full equilibrium primitives. P03 is a consistency witness, not an added formal dependency of the firm theorem.
G01 defines equilibrium for untruncated r>-delta with ordinary household admissibility, not r<lambda or beta*(1+r)<1. An equilibrium witness supplies its invariant probability law and finite first moments; never obtain it by defining equilibrium through the strictly impatient S05/S06/M06C constructor. Include F01 firm optimization, H05 canonical lifetime optimality against all feasible plans, S01 actual kernel, P01 exact original/normalized budgets, labor mean one, integrability and capital clearing. Prove resource-law versus net-asset/current-labor equivalence using A01, with predetermined assets paired with the fresh labor draw by product law. Resource law is not asset law, and contemporaneous policy choices are not assumed independent of contemporaneous income. No N07/B02/equilibrium existence, uniqueness, asset-supply monotonicity, positive-rate premise, or uncontracted debt-rule specialization.
F02 first derives f(K)/K tending to zero from the tangent bound and vanishing marginal product. Choose large K_L with f'(K_L)<delta and f(K_L)<delta*K_L; set r_L=f'(K_L)-delta and derive -delta<r_L<0, K(r_L)=K_L and wage positivity. For EVERY finite b>=0 derive 1+r_L>0 and beta*(1+r_L)<1 before using canonical stationarity. P02 gives phi=b at negative rates; construct admissible original/normalized prices. A02 supplies integrability and E[c]=w_L+r_L*S with mean-one labor; nonnegative consumption gives S<=w_L/(-r_L)<K_L. The strict sign must be derived, never a conclusion-like premise. No B02/B03/G02/G03 or equilibrium existence. No average-product decay assumption.
All accepted predecessor qualifications remain operative, including weak drift not implying finite-time entry, a.e. versus pointwise restrictions, and economic integrals requiring integrability. Use only approved hash-verified A94 printed 670-671/PDF 13-14. Primitive packages, sqrt witness, exact cross-sectional formal equivalence and lower-bracket proof are project constructions, not literal A94 claims. Audit every new export with #check/assert_no_sorry/#print axioms, synchronize ledger Markdown/TeX/PDF and global status. Executor stops at REVIEW_READY, never GREEN."""

class Stage09aController(Controller):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.gates=Stage08Controller(root).gates
        by={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates=self.gates+[{'id':f'M09A{i}','contracts':[cid],'accepted':False,'module':by[cid]['module'],'signature_probe':f'Probes/M09A{i}Signatures.lean','report':f'reports/m09a{i}_milestone.md','analytical_audit':f'reports/m09a{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE09A_FOUNDATIONS_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage09a';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage09a_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored);self.preserve();return result
    def preserve(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE09A_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        ts=read_json(self.root/'contracts/theorems.json')['theorems']
        for t in ts:
            if t['stage'] in ('09','10','11') and t['id'] not in IDS and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE09A_LATER_STAGE_LEAKAGE')
    def commit_acceptance(self,state):
        super().commit_acceptance(state)
        self.git('push','origin','issue3')
        remote=self.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=self.git('rev-parse','HEAD').strip():raise Stop('REMOTE_ACCEPTANCE_MISMATCH')
        atomic_json(self.runtime/'accepted'/(state['gate']+'_remote.json'),{'remote':remote})
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage08Controller(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE08_COMPLETE_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE09A_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(old.root/'reports/stage08_integration_audit.json')['result']!='PASS':raise Stop('STAGE08_INTEGRATION_REQUIRED')
        remote=old.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=old.git('rev-parse','HEAD').strip():raise Stop('STAGE09A_REMOTE_MISMATCH')
        if (old.root/REG).exists():raise Stop('STAGE09A_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if any(t['status']!='UNFORMALIZED' for t in ts if t['stage'] in ('09','10','11')):raise Stop('STAGE09A_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M09*/**/*invocation.json')):raise Stop('STAGE09A_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in ('Audit.lean','All.lean','Aiyagari1994.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage09aController(root);c.runtime.mkdir(parents=True,exist_ok=True)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-3:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize three isolated Stage 09a foundation gates after accepted Stage 08 checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M09A1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    from orchestrate import canonical,decision
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE09A_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE09A_ACCEPTANCE_CHAIN')
    if any(any((re.fullmatch(r'M(?:09|10|11).*',part) and part not in {'M09A1','M09A2','M09A3'}) for part in p.parts) for p in (c.root/'tmp_orchestration').glob('**/*invocation.json')):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-6:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE09A_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    directory=c.runtime/'integration'/str(time.time_ns());directory.mkdir(parents=True);c.checks(c.gates[-1],directory)
    for g in c.gates[-6:]:
        result=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(g['id']+'_signatures.log')).write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('STAGE09A_SIGNATURE_CHECK_FAILED')
    atomic_json(c.root/'reports/stage09a_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(directory/'deterministic_summary.json'),'global_status':read_json(directory/'global_status_overview.json'),'unassigned_stage09_and_stage10_unstarted':True,'F01_G01_F02_green':True,'prior_39_green':True})
    (c.root/'reports/stage09a_integration_audit.md').write_text('# Stage-09a foundation integration\n\nPASS. F01, G01 and F02 independently accepted; all 39 prior GREEN contracts preserved; contracts, dependencies and accepted predecessors preserved. Builds, audits, signatures, allowed axioms, sources and global ledger synchronization pass. Unassigned Stage-09 contracts and Stage 10 remain unstarted.\n')
    c.git('add','--','reports/stage09a_integration_audit.json','reports/stage09a_integration_audit.md');c.git('commit','-m','Record passing Stage 09a foundation integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
