"""Three isolated final Stage09 gates; complete Stage09 human checkpoint only."""
import json,shutil,time,subprocess
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest,canonical,decision
from stage09c import Stage09cController
BASE='82c1662ef8b71b4b910203222c0a096432e5be53'
REG='reviews/stage09d_authorization.json'
IDS=['G06','G07','G08']
AUTHORITY=(Path(__file__).parent/'stage09d_authority.md').read_text()
SHARED={'Aiyagari1994/Equilibrium/MainTheorem.lean','Aiyagari1994/Equilibrium/Saving.lean'}
class Stage09dController(Stage09cController):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        ts={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates += [{'id':f'M09D{i}','contracts':[cid],'accepted':False,'module':ts[cid]['module'],'signature_probe':f'Probes/M09D{i}Signatures.lean','report':f'reports/m09d{i}_milestone.md','analytical_audit':f'reports/m09d{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE09_COMPLETE_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage09d';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage09d_usage_metrics.json'
    def gate_prompt(self,gate,state):return Controller.gate_prompt(self,gate,state)+'\n'+AUTHORITY+'\n'
    def preserve(self):
        for n,h in read_json(self.root/REG)['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE09D_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        for t in read_json(self.root/'contracts/theorems.json')['theorems']:
            if t['stage'] in ('10','11') and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE10_LEAKAGE')
    def checks(self,gate,directory):
        from stage09c_semantics import certify_g01
        from shared_imports import certify,POLICIES
        self.evidence_text(directory,'g01_semantics',json.dumps(certify_g01(self,gate),sort_keys=True)+'\n')
        if gate['id'] in POLICIES:self.evidence_text(directory,'accepted_semantics',json.dumps(certify(self,gate,force=True),sort_keys=True)+'\n')
        return Controller.checks(self,gate,directory)
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage09cController(root)
    with old.lock():
        old.ensure_clean();s=old.status()
        if s['status']!='STAGE09C_CERTAINTY_FOUNDATIONS_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE09C_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(old.root/'reports/stage09c_integration_audit.json')['result']!='PASS':raise Stop('STAGE09C_INTEGRATION_REQUIRED')
        if old.git('ls-remote','origin','refs/heads/issue3').split()[0]!=old.git('rev-parse','HEAD').strip():raise Stop('STAGE09D_REMOTE_MISMATCH')
        if (old.root/REG).exists():raise Stop('STAGE09D_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if sum(t['status']=='GREEN' for t in ts)!=48 or any(t['status']!='UNFORMALIZED' for t in ts if t['id'] in IDS or t['stage']=='10'):raise Stop('STAGE09D_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M09D*/**/*invocation.json')):raise Stop('STAGE09D_RUNTIME_ALREADY_EXISTS')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in SHARED|{'Audit.lean','All.lean','Aiyagari1994.lean'}) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage09dController(root);c.runtime.mkdir(parents=True,exist_ok=True)
        (c.runtime/'g01_fingerprints').mkdir(exist_ok=True)
        for n in ['baseline.json','existence_baseline.json']:shutil.copyfile(old.runtime/'g01_fingerprints'/n,c.runtime/'g01_fingerprints'/n)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-3:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize three final Stage 09 gates after accepted Stage 09c checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M09D1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE09_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE09_ACCEPTANCE_CHAIN')
    for p in (c.root/'tmp_orchestration').glob('**/*invocation.json'):
        if any(part.startswith(('M10','M11')) for part in p.parts):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-12:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE09_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    d=c.runtime/'integration'/str(time.time_ns());d.mkdir(parents=True)
    from stage09c_semantics import certify_existence
    existence=certify_existence(c);atomic_json(d/'existence_semantics.json',existence)
    c.checks(c.gates[-1],d)
    from shared_imports import POLICIES
    from shared_provenance import certify
    chains={g['id']: (read_json(d/'accepted_semantics.json') if g['id']==c.gates[-1]['id'] else certify(c,g)) for g in c.gates if g['id'] in POLICIES and c.tracked(f"reviews/{g['id'].lower()}_acceptance.json")}
    atomic_json(d/'shared_provenance_chain.json',{'result':'PASS','gates':chains})
    for g in c.gates[-12:]:
        r=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True);(d/(g['id']+'_signatures.log')).write_text(r.stdout+r.stderr)
        if r.returncode:raise Stop('STAGE09_SIGNATURE_FAILED')
    atomic_json(c.root/'reports/stage09_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(d/'deterministic_summary.json'),'global_status':read_json(d/'global_status_overview.json'),'all_twelve_stage09_green':True,'prior_48_green':True,'contracts_and_dependencies_frozen':True,'Stage10_unstarted':True,'G01_semantic_fingerprint':read_json(d/'g01_semantics.json'),'G02_G03_semantic_fingerprint':existence,'shared_module_provenance_chains':chains})
    (c.root/'reports/stage09_integration_audit.md').write_text('# Full Stage-09 integration\n\nPASS. All twelve Stage09 contracts and all earlier contracts are GREEN. Unrestricted G01 and accepted G02/G03/G04/G05 semantics preserved, including universal rate comparison, critical certainty optimality, gross investment interpretation and derived integrable goods clearing. Contracts, dependencies, qualifications, shared-module provenance, builds, audits, signatures, allowed axioms, source hashes and ledger/global status pass. Stage10 and NP01/NP02/NP03/E01/E02/E03 remain unstarted.\n')
    c.git('add','--','reports/stage09_integration_audit.json','reports/stage09_integration_audit.md');c.git('commit','-m','Record passing full Stage 09 integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
