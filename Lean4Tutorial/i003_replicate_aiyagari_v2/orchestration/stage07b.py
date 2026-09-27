"""Three authorized Stage-07b gates; isolated runtime and no Stage-08 dispatch."""
import json,re,shutil,subprocess,time
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
from stage07a import Stage07Controller
BASE='f07b205b9d7889613a07004017ee6f8e02f87cc6'
REG='reviews/stage07b_authorization.json'
IDS=['N05','N06','N07']
AUTHORITY='''Stage 07b only: implement the assigned N05/N06/N07 gate, never later gates or Stage 08 early. Preserve exact formal dependencies. N05 is generic finite-product mathematics with no household assumptions: common initial state and independent finite iid shock strings, exact discounted difference identity, tightness/union-bound convergence without state moments, bounded shock second moments and the exact 2*Var(e)*sum R^(-2j) identity with variance positivity proved from nondegeneracy. No infinite path space, stationary resource moments, bounded stationary support, strict impatience, assumed positive critical consumption, or S05 invariant-law existence. N04 gives only a.e. equality under pi.compProd(P^n), never equality on every shock history; N05's interface must be legitimately dischargeable from that accepted conclusion. N06 uses c+A=z and the actual canonical transition R*A+e, derives R>1 from beta*R=1 and 0<beta<1, and introduces pi only under contradiction. N07 only assembles N03 and N06. The two-string proof is a new reconstruction, not copied from CW00/A94. Preserve boundary ENNReal qualifications. New gates start Sol Medium (overriding historical Extra-high recommendation); only genuine substantive revisions escalate. Synchronize global status and exact ledger status **Status:** REVIEW_READY. Include #check, assert_no_sorry and #print axioms for all new exports; no trailing empty probe lines.'''

class Stage07bController(Controller):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.gates=Stage07Controller(root).gates
        by={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates=self.gates+[{'id':f'M07B{i}','contracts':[cid],'accepted':False,'module':by[cid]['module'],'signature_probe':f'Probes/M07B{i}Signatures.lean','report':f'reports/m07b{i}_milestone.md','analytical_audit':f'reports/m07b{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE07B_COMPLETE_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage07b';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage07b_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored);self.preserve();return result
    def preserve(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE07B_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        ts=read_json(self.root/'contracts/theorems.json')['theorems']
        for t in ts:
            if t['stage'] in ('08','09','10','11') and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE07B_LATER_STAGE_LEAKAGE')
    def commit_acceptance(self,state):
        super().commit_acceptance(state)
        self.git('push','origin','issue3')
        remote=self.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=self.git('rev-parse','HEAD').strip():raise Stop('REMOTE_ACCEPTANCE_MISMATCH')
        atomic_json(self.runtime/'accepted'/(state['gate']+'_remote.json'),{'remote':remote})
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage07Controller(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE07A_COMPLETE_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE07B_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if (old.root/REG).exists():raise Stop('STAGE07B_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if any(t['status']!='UNFORMALIZED' for t in ts if t['id'] in IDS+['B01','B02','B03']):raise Stop('STAGE07B_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M07B*/**/*invocation.json')):raise Stop('STAGE07B_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in ('Audit.lean','All.lean','Aiyagari1994.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage07bController(root);c.runtime.mkdir(parents=True,exist_ok=True)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-3:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize three isolated Stage 07b gates after accepted Stage 07a checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M07B1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    from orchestrate import canonical,decision
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE07B_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE07B_ACCEPTANCE_CHAIN')
    if any(any(re.fullmatch(r'M(?:08|09|10|11).*',part) for part in p.parts) for p in (c.root/'tmp_orchestration').glob('**/*invocation.json')):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-7:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE07B_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    directory=c.runtime/'integration'/str(time.time_ns());directory.mkdir(parents=True);c.checks(c.gates[-1],directory)
    for g in c.gates[-7:]:
        result=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(g['id']+'_signatures.log')).write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('STAGE07B_SIGNATURE_CHECK_FAILED')
    atomic_json(c.root/'reports/stage07b_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(directory/'deterministic_summary.json'),'global_status':read_json(directory/'global_status_overview.json'),'stage08_unstarted':True,'N01_N07_green':True})
    (c.root/'reports/stage07b_integration_audit.md').write_text('# Stage-07b integration\n\nPASS. N01–N07 independently accepted; contracts, dependencies and accepted predecessors preserved. Builds, audits, signatures, allowed axioms, sources and global ledger synchronization pass. Stage 08 and later stages remain unstarted.\n')
    c.git('add','--','reports/stage07b_integration_audit.json','reports/stage07b_integration_audit.md');c.git('commit','-m','Record passing Stage 07b integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
