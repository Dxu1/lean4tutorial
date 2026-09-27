"""Four authorized Stage-07a gates; isolated runtime and no Stage-07b dispatch."""
import json,re,shutil,subprocess,time
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
from a03_repair import RepairController
BASE='e76856be222603445817ad482196b4e319d90fa0'
REG='reviews/stage07a_authorization.json'
IDS=['N01','N02','N03','N04']
AUTHORITY='''Stage 07a only: execute assigned N01/N02/N03/N04 gate, never another contract early, N05/N06/N07, Stage 07b or Stage 08. Preserve all predecessor qualifications. Candidate invariant laws at arbitrary R>0 are hypotheses, never supplied by S05 outside strict impatience. At zero use zeroRightMarginal : ENNReal, never rightMarginalValue m 0. H09 unconditional extended inequality is valid at arbitrary returns; its real form requires finite initial marginal. Distinguish conditional integrability from stationary E[q]; no stationary marginal moment assumption. H11 is local to positive consumption; H10/H12 strict impatience cannot handle critical corners. Follow exact authoritative proof route and dependency list. Initial executor Medium overrides historical Extra-high recommendation. Synchronize global overview and use exact ledger status **Status:** REVIEW_READY. Include #check, assert_no_sorry and #print axioms for every new export; avoid trailing empty probe lines. This is a new reconstruction motivated by approved sources, not a literal source theorem.'''
class Stage07Controller(Controller):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.gates=RepairController(root).gates
        by={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates=self.gates+[{'id':f'M07A{i}','contracts':[cid],'accepted':False,'module':by[cid]['module'],'signature_probe':f'Probes/M07A{i}Signatures.lean','report':f'reports/m07a{i}_milestone.md','analytical_audit':f'reports/m07a{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE07A_COMPLETE_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage07a';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage07a_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored);self.preserve();return result
    def preserve(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE07A_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        ts=read_json(self.root/'contracts/theorems.json')['theorems']
        for t in ts:
            if t['stage'] in ('07b','08','09','10','11') and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE07A_LATER_STAGE_LEAKAGE')
    def commit_acceptance(self,state):
        super().commit_acceptance(state)
        self.git('push','origin','issue3')
        remote=self.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=self.git('rev-parse','HEAD').strip():raise Stop('REMOTE_ACCEPTANCE_MISMATCH')
        atomic_json(self.runtime/'accepted'/(state['gate']+'_remote.json'),{'remote':remote})
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=RepairController(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE06_COMPLETE_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE07A_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if (old.root/REG).exists():raise Stop('STAGE07A_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if any(t['status']!='UNFORMALIZED' for t in ts if t['id'] in IDS+['N05','N06','N07']):raise Stop('STAGE07A_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M07*/**/*invocation.json')):raise Stop('STAGE07A_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in ('Audit.lean','All.lean','Aiyagari1994.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage07Controller(root);c.runtime.mkdir(parents=True,exist_ok=True)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-4:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize four isolated Stage 07a gates after repaired Stage 06 checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M07A1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    from orchestrate import canonical,decision
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE07A_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE07A_ACCEPTANCE_CHAIN')
    if any(p.parts[-3].startswith(('M07B','M08')) for p in (c.root/'tmp_orchestration').glob('**/*invocation.json')):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-4:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE07A_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    directory=c.runtime/'integration'/str(time.time_ns());directory.mkdir(parents=True);c.checks(c.gates[-1],directory)
    for g in c.gates[-4:]:
        result=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(g['id']+'_signatures.log')).write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('STAGE07A_SIGNATURE_CHECK_FAILED')
    atomic_json(c.root/'reports/stage07a_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(directory/'deterministic_summary.json'),'global_status':read_json(directory/'global_status_overview.json'),'N05_N06_N07_unstarted':True})
    (c.root/'reports/stage07a_integration_audit.md').write_text('# Stage-07a integration\n\nPASS. N01–N04 independently accepted; contracts, dependencies and accepted predecessors preserved. Builds, audits, signatures, allowed axioms, sources and global ledger synchronization pass. N05/N06/N07 and later stages remain unstarted.\n')
    c.git('add','--','reports/stage07a_integration_audit.json','reports/stage07a_integration_audit.md');c.git('commit','-m','Record passing Stage 07a integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
