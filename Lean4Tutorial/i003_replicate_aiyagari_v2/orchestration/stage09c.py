"""Isolated Stage-09c certainty foundations; no unassigned equilibrium gates."""
import json,re,shutil,subprocess,time
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
from stage09b import Stage09bController
BASE='ca1bd0748618cc64a4dac64865c1cfc4cdd1baf5'
REG='reviews/stage09c_authorization.json'
IDS=['A04','A05','G04','G05']
AUTHORITY=(Path(__file__).parent/'stage09c_authority.md').read_text()

class Stage09cController(Controller):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.gates=Stage09bController(root).gates
        by={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates=self.gates+[{'id':f'M09C{i}','contracts':[cid],'accepted':False,'module':by[cid]['module'],'signature_probe':f'Probes/M09C{i}Signatures.lean','report':f'reports/m09c{i}_milestone.md','analytical_audit':f'reports/m09c{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE09C_CERTAINTY_FOUNDATIONS_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage09c';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage09c_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored);self.preserve();return result
    def checks(self,gate,directory):
        from stage09c_semantics import certify_g01
        certificate=certify_g01(self,gate)
        self.evidence_text(directory,'g01_semantics',json.dumps(certificate,sort_keys=True)+'\n')
        if gate['id']=='M09C4':
            from shared_imports import certify
            if self.acceptance_record(self.gates[-4]):
                certificate=certify(self,gate,force=True)
                self.evidence_text(directory,'accepted_semantics',json.dumps(certificate,sort_keys=True)+'\n')
        return super().checks(gate,directory)
    def preserve(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE09C_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        ts=read_json(self.root/'contracts/theorems.json')['theorems']
        assigned_modules={t['module'] for t in ts if t['id'] in IDS}
        for t in ts:
            if t['stage'] in ('09','10','11') and t['id'] not in IDS+['F01','G01','F02','G02','G03'] and (t['status']!='UNFORMALIZED' or ((self.root/t['module']).exists() and t['module'] not in assigned_modules)):raise Stop('STAGE09C_LATER_STAGE_LEAKAGE')
            if t['id'] in ('G06','G07','G08') and (self.root/t['module']).exists():
                from orchestrate import strip_lean_comments
                if re.search(r'\b(?:theorem|lemma|def|abbrev)\s+(?:Aiyagari1994\.)?'+re.escape(t['declaration'].split('.')[-1])+r'\b',strip_lean_comments((self.root/t['module']).read_text())):raise Stop('STAGE09C_LATER_DECLARATION_LEAKAGE')
    def commit_acceptance(self,state):
        super().commit_acceptance(state)
        self.git('push','origin','issue3')
        remote=self.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=self.git('rev-parse','HEAD').strip():raise Stop('REMOTE_ACCEPTANCE_MISMATCH')
        atomic_json(self.runtime/'accepted'/(state['gate']+'_remote.json'),{'remote':remote})
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage09bController(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE09B_EXISTENCE_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE09C_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(old.root/'reports/stage09b_integration_audit.json')['result']!='PASS':raise Stop('STAGE09B_INTEGRATION_REQUIRED')
        remote=old.git('ls-remote','origin','refs/heads/issue3').split()[0]
        if remote!=old.git('rev-parse','HEAD').strip():raise Stop('STAGE09C_REMOTE_MISMATCH')
        if (old.root/REG).exists():raise Stop('STAGE09C_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if any(t['status']!='UNFORMALIZED' for t in ts if t['stage'] in ('09','10','11') and t['id'] not in ['F01','G01','F02','G02','G03']):raise Stop('STAGE09C_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M09C*/**/*invocation.json')):raise Stop('STAGE09C_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in ('Audit.lean','All.lean','Aiyagari1994.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage09cController(root);c.runtime.mkdir(parents=True,exist_ok=True)
        from stage09c_semantics import initialize_g01
        g01_hash=initialize_g01(c)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'G01_baseline_sha256':g01_hash['G01'],'G02_G03_baseline_sha256':g01_hash['G02_G03'],'contracts':IDS,'gates':c.gates[-4:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize four isolated Stage 09c certainty gates after accepted Stage 09b checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M09C1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    from orchestrate import canonical,decision
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE09C_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE09C_ACCEPTANCE_CHAIN')
    if any(any((re.fullmatch(r'M(?:09|10|11).*',part) and part not in {'M09A1','M09A2','M09A3','M09B1','M09B2','M09C1','M09C2','M09C3','M09C4'}) for part in p.parts) for p in (c.root/'tmp_orchestration').glob('**/*invocation.json')):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-9:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE09C_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    directory=c.runtime/'integration'/str(time.time_ns());directory.mkdir(parents=True)
    from stage09c_semantics import certify_existence
    existence=certify_existence(c)
    atomic_json(directory/'existence_semantics.json',existence)
    c.checks(c.gates[-1],directory)
    for g in c.gates[-9:]:
        result=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(g['id']+'_signatures.log')).write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('STAGE09C_SIGNATURE_CHECK_FAILED')
    atomic_json(c.root/'reports/stage09c_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(directory/'deterministic_summary.json'),'global_status':read_json(directory/'global_status_overview.json'),'unassigned_stage09_and_stage10_unstarted':True,'A04_A05_G04_G05_green':True,'prior_44_green':True,'G01_byte_identical':True,'G01_semantic_fingerprint':read_json(directory/'g01_semantics.json'),'A04_semantic_fingerprint':read_json(directory/'accepted_semantics.json'),'G02_G03_source_and_semantics_preserved':True,'G02_G03_semantic_fingerprint':existence})
    (c.root/'reports/stage09c_integration_audit.md').write_text('# Stage-09c certainty foundations integration\n\nPASS. A04/A05/G04/G05 independently accepted; all 44 prior GREEN contracts and the unrestricted G01 definition preserved; contracts, dependencies and accepted predecessors preserved. Builds, audits, signatures, allowed axioms, sources and global ledger synchronization pass. Unassigned Stage-09 contracts and Stage 10 remain unstarted.\n')
    c.git('add','--','reports/stage09c_integration_audit.json','reports/stage09c_integration_audit.md');c.git('commit','-m','Record passing Stage 09c certainty foundations integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
