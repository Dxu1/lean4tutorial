"""Three isolated exact extension gates; full Stage10 checkpoint, no release audit."""
import json,shutil,time,subprocess
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest,canonical,decision
from stage10a import Stage10aController
BASE='4b347559e2937b6dd8629c857ef27d076aded32b'
REG='reviews/stage10b_authorization.json'
IDS=['E01','E02','E03']
AUTHORITY=(Path(__file__).parent/'stage10b_authority.md').read_text()
SHARED=set()
class Stage10bController(Stage10aController):
    stage_authority=AUTHORITY
    def __init__(self,root=PROJECT):
        super().__init__(root)
        ts={t['id']:t for t in read_json(self.root/'contracts/theorems.json')['theorems']}
        self.gates += [{'id':f'M10B{i}','contracts':[cid],'accepted':False,'module':ts[cid]['module'],'signature_probe':f'Probes/M10B{i}Signatures.lean','report':f'reports/m10b{i}_milestone.md','analytical_audit':f'reports/m10b{i}_analytical_audit.md'} for i,cid in enumerate(IDS,1)]
        self.checkpoint='STAGE10_COMPLETE_HUMAN_CHECKPOINT';self.config['stage_checkpoint']=self.checkpoint
        self.runtime=self.root/'tmp_orchestration/stage10b';self.state_path=self.runtime/'state.json'
    def usage_report_path(self,gate):return 'reports/stage10b_usage_metrics.json'
    def gate_prompt(self,gate,state):return Controller.gate_prompt(self,gate,state)+'\n'+AUTHORITY+'\n'
    def preserve(self):
        for n,h in read_json(self.root/REG)['protected_files'].items():
            if digest((self.root/n).read_bytes())!=h:raise Stop('STAGE10B_ACCEPTED_PREDECESSOR_CHANGED: '+n)
        for t in read_json(self.root/'contracts/theorems.json')['theorems']:
            if t['stage']=='11' and (t['status']!='UNFORMALIZED' or (self.root/t['module']).exists()):raise Stop('STAGE10_LEAKAGE')
    def checks(self,gate,directory):
        from stage09c_semantics import certify_g01
        from shared_imports import certify,POLICIES
        self.evidence_text(directory,'g01_semantics',json.dumps(certify_g01(self,gate),sort_keys=True)+'\n')
        if gate['id'] in POLICIES:self.evidence_text(directory,'accepted_semantics',json.dumps(certify(self,gate,force=True),sort_keys=True)+'\n')
        if gate['id'] in ('M10B1','M10B3'):
            from root_aggregators import certify as certify_aggregator
            self.evidence_text(directory,'root_aggregator',json.dumps(certify_aggregator(self,gate,force=True),sort_keys=True)+'\n')
        return Controller.checks(self,gate,directory)
    def finish_stage(self,state):
        integration(self,state);self.save(state,self.checkpoint);return state

def activate(root=PROJECT):
    old=Stage10aController(root)
    with old.lock():
        old.ensure_clean();s=old.status();old.preserve()
        if s['status']!='STAGE10A_NOPONZI_HUMAN_CHECKPOINT' or old.git('branch','--show-current').strip()!='issue3':raise Stop('STAGE10A_CHECKPOINT_REQUIRED')
        old.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(old.root/'reports/stage10a_integration_audit.json')['result']!='PASS':raise Stop('STAGE10A_INTEGRATION_REQUIRED')
        if old.git('ls-remote','origin','refs/heads/issue3').split()[0]!=old.git('rev-parse','HEAD').strip():raise Stop('STAGE10B_REMOTE_MISMATCH')
        if (old.root/REG).exists():raise Stop('STAGE10B_ALREADY_AUTHORIZED')
        ts=read_json(old.root/'contracts/theorems.json')['theorems']
        if sum(t['status']=='GREEN' for t in ts)!=54 or any(t['status']!='UNFORMALIZED' for t in ts if t['id'] in IDS):raise Stop('STAGE10B_NOT_UNSTARTED')
        if list((old.root/'tmp_orchestration').glob('**/M10B*/**/*invocation.json')):raise Stop('STAGE10B_RUNTIME_ALREADY_EXISTS')
        prefix=old.git('rev-parse','--show-prefix').strip()
        if read_json(old.root/'contracts/theorems.json')!=json.loads(old.git('show',BASE+':'+prefix+'contracts/theorems.json')):raise Stop('STAGE10A_CONTRACT_MUTATION')
        if list((old.root/'tmp_orchestration').glob('**/M11*/**/*invocation.json')):raise Stop('FINAL_RELEASE_ALREADY_STARTED')
        for commit in ['29a54a6f86d0f69538e4a2e67ede00b46639d558','b0ae1b1e109b0f7c7d8f7a31904de8ce423b4c09','b3c789a256b53c65b977a461336d864722a15951']:
            old.git('merge-base','--is-ancestor',commit,'HEAD')
        files=old.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in SHARED|{'Audit.lean','All.lean','Aiyagari1994.lean'}) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md','lean-toolchain','lake-manifest.json')}
        c=Stage10bController(root);c.runtime.mkdir(parents=True,exist_ok=True)
        (c.runtime/'g01_fingerprints').mkdir(exist_ok=True)
        for n in ['baseline.json','existence_baseline.json']:shutil.copyfile(old.runtime/'g01_fingerprints'/n,c.runtime/'g01_fingerprints'/n)
        if (old.runtime/'preflight.json').exists():shutil.copyfile(old.runtime/'preflight.json',c.runtime/'preflight.json')
        atomic_json(c.root/REG,{'baseline':BASE,'contracts':IDS,'gates':c.gates[-3:],'protected_files':protected,'authority':AUTHORITY,'checkpoint':c.checkpoint})
        old.git('add','--',REG);old.git('commit','-m','Authorize E01 E02 E03 after completed Stage 10a checkpoint')
        state={'status':'READY_TO_EXECUTE','gate':'M10B1','attempt':1,'baseline':old.git('rev-parse','HEAD').strip(),'accepted':s['accepted'],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        c.save(state,'READY_TO_EXECUTE');return state

def integration(c,state):
    c.ensure_clean();c.preserve();prefix=c.git('rev-parse','--show-prefix').strip()
    expected=json.loads(c.git('show',BASE+':'+prefix+'contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE10B_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE10B_ACCEPTANCE_CHAIN')
    for p in (c.root/'tmp_orchestration').glob('**/*invocation.json'):
        if any((part.startswith('M11') or (part.startswith('M10') and part not in {'M10A1','M10A2','M10A3','M10B1','M10B2','M10B3'})) for part in p.parts):raise Stop('LATER_RUNTIME_LEAKAGE')
    acceptance={}
    for g in c.gates[-6:]:
        rec=c.acceptance_record(g);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD');d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,g,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE10B_ACCEPTANCE_EVIDENCE')
        acceptance[g['id']]=rec['accepted_commit_sha']
    d=c.runtime/'integration'/str(time.time_ns());d.mkdir(parents=True)
    from stage09c_semantics import certify_existence
    existence=certify_existence(c);atomic_json(d/'existence_semantics.json',existence)
    c.checks(c.gates[-1],d)
    from root_aggregators import accepted_provenance
    aggregator=accepted_provenance(c);atomic_json(d/'root_aggregator_provenance.json',aggregator)
    from shared_imports import POLICIES
    from shared_provenance import certify
    chains={g['id']: (read_json(d/'accepted_semantics.json') if g['id']==c.gates[-1]['id'] else certify(c,g)) for g in c.gates if g['id'] in POLICIES and c.tracked(f"reviews/{g['id'].lower()}_acceptance.json")}
    atomic_json(d/'shared_provenance_chain.json',{'result':'PASS','gates':chains})
    for g in c.gates[-6:]:
        r=subprocess.run(['lake','env','lean',g['signature_probe']],cwd=c.root,text=True,capture_output=True);(d/(g['id']+'_signatures.log')).write_text(r.stdout+r.stderr)
        if r.returncode:raise Stop('STAGE10B_SIGNATURE_FAILED')
    atomic_json(c.root/'reports/stage10_integration_audit.json',{'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'summary':read_json(d/'deterministic_summary.json'),'global_status':read_json(d/'global_status_overview.json'),'all_six_stage10_green':True,'green_contract_count':57,'prior_51_green':True,'contracts_and_dependencies_frozen':True,'final_release_audit_unstarted':True,'G01_semantic_fingerprint':read_json(d/'g01_semantics.json'),'G02_G03_semantic_fingerprint':existence,'shared_module_provenance_chains':chains,'root_aggregator_provenance':aggregator})
    (c.root/'reports/stage10_integration_audit.md').write_text('# Full Stage-10 integration\n\nPASS. All 57 contracts GREEN, including NP01-NP03 and E01-E03. Frozen contracts and exact dependency graph preserved. E01 proves zero-rate primitive/policy/law equality and exact net-supply translation. E02 separates unconditional policy equality above the natural limit from subcritical stationary conclusions. E03 is the pure-exchange x=a-d budget/floor, feasible-plan/lifetime-optimality, invariant-law pushforward and integrable bond-clearing correspondence, with no fixed-cap or capital-economy neutrality claim. Independent operative reviews establish adequacy. Fresh builds, audits, signatures, approved axioms, source hashes, ledger/global status and all accepted provenance chains pass. Final release audit NOT started.\n')
    c.git('add','--','reports/stage10_integration_audit.json','reports/stage10_integration_audit.md');c.git('commit','-m','Record passing full Stage 10 integration checkpoint');state['integration_commit']=c.git('rev-parse','HEAD').strip()
