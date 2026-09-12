import copy
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

MODULE=Path(__file__).resolve().parents[1]/'orchestrate.py'
spec=importlib.util.spec_from_file_location('orchestrate',MODULE)
o=importlib.util.module_from_spec(spec); spec.loader.exec_module(o)

GATE={'id':'M03B1','contracts':['H09']}
SHA='a'*64

def verdict(**changes):
    v={'gate_id':'M03B1','attempt':1,'snapshot_sha256':SHA,'verdict':'PASS','confidence':'HIGH','requires_human_review':False,
       'contract_assessments':[{'contract_id':'H09','adequate':True,'assessment':'Fixture adequacy assessment, not a mathematical review.'}],
       'dimension_assessments':[{'dimension_id':d,'status':'PASS','evidence':f'Inspected fixture evidence for {d}; the synthetic contract and its audit agree on the assigned test obligation.'} for d in o.DIMENSIONS],
       'blocking_findings':[],'nonblocking_findings':[],'qualifications':[o.QUALIFICATION],'revision_prompt':None}
    v.update(changes); return v

def response(stdout='',stderr='',returncode=0):
    return subprocess.CompletedProcess([],returncode,stdout,stderr)

class VerdictTests(unittest.TestCase):
    def decide(self,v,attempt=1,**kw): return o.decision(v,GATE,attempt,SHA,True,**kw)
    def test_pass(self): self.assertEqual(self.decide(verdict()),'ACCEPTANCE_RECORDING')
    def test_revise_same_gate(self): self.assertEqual(self.decide(verdict(verdict='REVISE',revision_prompt='Repair H09 only.')),'READY_TO_EXECUTE')
    def test_block(self): self.assertEqual(self.decide(verdict(verdict='BLOCK')),'HUMAN_STOP')
    def test_low_confidence_pass(self): self.assertEqual(self.decide(verdict(confidence='LOW')),'HUMAN_STOP')
    def test_human_required(self): self.assertEqual(self.decide(verdict(requires_human_review=True)),'HUMAN_STOP')
    def test_malformed_json(self):
        for v in [None,[],{},verdict(attempt=True),verdict(requires_human_review=0),verdict(contract_assessments=['ok']),dict(verdict(),extra='x')]:
            with self.subTest(v=v),self.assertRaises(o.Stop): self.decide(v)
    def test_snapshot_mismatch(self):
        with self.assertRaisesRegex(o.Stop,'IDENTITY'): self.decide(verdict(snapshot_sha256='b'*64))
    def test_gate_mismatch(self):
        with self.assertRaises(o.Stop): self.decide(verdict(gate_id='M03B2'))
    def test_max_revisions(self): self.assertEqual(self.decide(verdict(attempt=3,verdict='REVISE',revision_prompt='Repair same gate.'),attempt=3),'HUMAN_STOP')
    def test_usage_attempts_do_not_consume_revisions(self):
        self.assertEqual(self.decide(verdict(attempt=4,verdict='REVISE',revision_prompt='Repair same gate.'),attempt=4,revisions=1),'READY_TO_EXECUTE')
    def test_inadequate_assessment(self): self.assertEqual(self.decide(verdict(contract_assessments=[])),'HUMAN_STOP')
    def test_duplicate_assessment(self): self.assertEqual(self.decide(verdict(contract_assessments=verdict()['contract_assessments']*2)),'HUMAN_STOP')
    def test_blocking_pass(self): self.assertEqual(self.decide(verdict(blocking_findings=['Missing proof.'])),'HUMAN_STOP')
    def test_no_revision_instruction(self): self.assertEqual(self.decide(verdict(verdict='REVISE',revision_prompt=' ')),'HUMAN_STOP')
    def test_failed_checks_never_accept(self): self.assertEqual(o.decision(verdict(),GATE,1,SHA,False),'HUMAN_STOP')

class AuthTests(unittest.TestCase):
    def test_missing_codex(self):
        with self.assertRaisesRegex(o.Stop,'MISSING'): o.authenticate(None)
    def test_api_key_rejected(self):
        with patch.object(o,'invoke',side_effect=[response('codex-cli 0.154.0'),response('Logged in using an API key')]), self.assertRaisesRegex(o.Stop,'codex login'): o.authenticate('/fake/codex')
    def test_ambiguous_auth_rejected(self):
        with patch.object(o,'invoke',side_effect=[response('codex-cli 0.154.0'),response('Authenticated')]), self.assertRaises(o.Stop): o.authenticate('/fake/codex')
    def test_subscription_accepted(self):
        with patch.object(o,'invoke',side_effect=[response('codex-cli 0.154.0-alpha.6.2'),response(stderr='Logged in using ChatGPT\n'),response('--ignore-user-config')]):
            self.assertEqual(o.authenticate('/fake/codex')['authentication'],'ChatGPT subscription')
    def test_old_cli_rejected(self):
        with patch.object(o,'invoke',return_value=response('codex-cli 0.152.9')),self.assertRaisesRegex(o.Stop,'VERSION'): o.authenticate('/fake/codex')
    def test_environment_strips_credentials(self):
        self.assertEqual(o.clean_environment({'PATH':'x','HOME':'y','OPENAI_API_KEY':'secret','AZURE_OPENAI_API_KEY':'secret','CODEX_API_KEY':'secret','OPENAI_BASE_URL':'other','ANTHROPIC_API_KEY':'secret','OPENAI_ACCESS_TOKEN':'secret'}),{'PATH':'x','HOME':'y'})
    def test_role_cli_isolation(self):
        a=o.codex_command('/fake/codex','gpt-6-astra','xhigh','/snapshot','read-only','/result','/schema')
        for flag in ['--ignore-user-config','--ignore-rules','--ephemeral','--output-schema','read-only','forced_login_method="chatgpt"','model_provider="openai"']: self.assertIn(flag,a)
        for flag in ['--yolo','resume','--dangerously-bypass-approvals-and-sandbox','--oss']: self.assertNotIn(flag,a)
        self.assertEqual(a[-1],'-')

class ControllerTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.outer=Path(self.temp.name); self.root=self.outer/'project'; self.root.mkdir()
        shutil.copytree(MODULE.parent,self.root/'orchestration',ignore=shutil.ignore_patterns('__pycache__'))
        self.write('.gitignore','tmp_orchestration/\n__pycache__/\n')
        self.write('contracts/theorems.json',json.dumps({'theorems':[{'id':'H09','status':'UNFORMALIZED','declaration':'Fixture.target','module':'Fixture.lean','statement':'unchanged fixture contract','sources':[]},{'id':'H07','status':'GREEN'},{'id':'H08','status':'GREEN'}]}))
        for n in ['AGENTS.md','prompts/03_household_analysis.md','docs/architecture.md','docs/lean_interfaces.md','docs/dependency_graph.md','contracts/assumptions.json','reviews/03a_acceptance.md']:
            self.write(n,'Fixture authority; not an economic implementation.\n')
        self.write('contracts/source_manifest.json',json.dumps({'sources':[]}))
        self.write('reviews/03a_acceptance.md','# M03A external acceptance\n\nDecision: ACCEPT.\n\nSHA-256: '+SHA+'\n\n## Mandatory qualification\n\n'+o.QUALIFICATION+'\n')
        self.write('docs/proof_ledger.md','# Fixture\n\n**Economic status:** H09 UNFORMALIZED\n\n## H09 — fixture\n\n**Status:** UNFORMALIZED.\n')
        self.write('All.lean','-- Accepted fixture source\n')
        self.write('orchestration/gates.json',json.dumps({'gates':[{'id':'M03A','contracts':['H07','H08'],'accepted':True},dict(GATE,module='Fixture.lean',signature_probe='Probes/Fixture.lean',report='reports/m03b1_milestone.md',analytical_audit='reports/m03b1_analytical_audit.md')],'after_last':o.CHECKPOINT}))
        self.git('init','-q'); self.git('config','user.email','test@example.invalid'); self.git('config','user.name','Test')
        self.git('add','.'); self.git('commit','-qm','Fixture baseline')
        self.c=o.Controller(self.root)
        self.c.gates=[{'id':'M03A','contracts':['H07','H08'],'accepted':True},dict(GATE,module='Fixture.lean',signature_probe='Probes/Fixture.lean',report='reports/m03b1_milestone.md',analytical_audit='reports/m03b1_analytical_audit.md')]
    def write(self,n,s):
        p=self.root/n; p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
    def git(self,*args): return subprocess.check_output(['git',*args],cwd=self.outer,text=True,stderr=subprocess.STDOUT).strip()
    def fixture_submission(self):
        t=o.read_json(self.root/'contracts/theorems.json');t['theorems'][0]['status']='REVIEW_READY';self.write('contracts/theorems.json',json.dumps(t))
        self.write('Fixture.lean','-- Test-only placeholder text; no theorem implementation.\n')
        self.write('Probes/Fixture.lean','-- Test-only signature fixture.\n')
        self.write('reports/m03b1_milestone.md','Fixture report\n'); self.write('reports/m03b1_analytical_audit.md','Fixture audit\n')
        self.write('docs/proof_ledger.md','# Fixture\n\n**Economic status:** H09 REVIEW_READY\n\n## H09 — fixture\n\n**Status:** REVIEW_READY.\n')
    def fake_checks(self,gate,directory):
        directory.mkdir(parents=True,exist_ok=True);(directory/'checks.json').write_text('{"passed":true}\n');return True
    def fake_model(self,role,prompt,cwd,attempt_dir):
        if role=='executor': self.fixture_submission(); return 'REVIEW_READY fixture'
        state=self.c.status(); return json.dumps(verdict(snapshot_sha256=state['snapshot_sha256'],attempt=state['attempt']))
    def test_dirty_project_stops(self):
        self.write('unexpected.txt','preserve me')
        with self.assertRaisesRegex(o.Stop,'DIRTY'): self.c.ensure_clean()
        self.assertEqual((self.root/'unexpected.txt').read_text(),'preserve me')
    def test_outer_untracked_preserved(self):
        (self.outer/'unrelated.txt').write_text('untouched'); self.c.ensure_clean()
    def test_status_is_read_only(self):
        a=self.c.status(); self.assertFalse(self.c.runtime.exists());self.assertEqual(a['gate'],'M03B1')
    def test_atomic_restart(self):
        s=self.c.status();s['attempt']=2;self.c.save(s)
        self.assertEqual(o.Controller(self.root).status(),s)
    def test_next_gate_and_checkpoint(self):
        self.assertEqual(o.next_gate(self.c.gates,['M03A'])['id'],'M03B1')
        self.assertIsNone(o.next_gate(self.c.gates,['M03A','M03B1']))
    def test_dry_run_has_no_model_calls(self):
        with patch.object(self.c,'model_run',side_effect=AssertionError('model call forbidden')):
            self.assertEqual(self.c.dry_run()['gate'],'M03B1')
        p=(self.c.runtime/'dry_run/executor_prompt.md').read_text()
        for text in ['additional initial h','nonnegative extended integral','conditional finiteness','all R > 0','zeroRightMarginal','ONLY contracts']: self.assertIn(text,p)
    def test_astra_unavailable(self):
        with patch.object(o,'authenticate',return_value={'version':'test'}),patch.object(o,'model_catalog'),patch.object(o,'invoke',return_value=response(returncode=1)),self.assertRaisesRegex(o.Stop,'ASTRA_UNAVAILABLE'):
            self.c.preflight()
        self.assertFalse((self.c.runtime/'preflight.json').exists())
    def test_contract_semantics_frozen(self):
        s=self.c.status();initial=self.c.project_files(); self.fixture_submission()
        self.c.frozen_scope(self.c.gates[1],s,initial)
        d=o.read_json(self.root/'contracts/theorems.json'); d['theorems'][0]['statement']='weakened';self.write('contracts/theorems.json',json.dumps(d))
        with self.assertRaisesRegex(o.Stop,'CONTRACT'): self.c.frozen_scope(self.c.gates[1],s,initial)
    def test_infrastructure_frozen(self):
        s=self.c.status();initial=self.c.project_files();self.fixture_submission();self.write('orchestration/config.json','{}')
        with self.assertRaisesRegex(o.Stop,'UNEXPECTED'): self.c.frozen_scope(self.c.gates[1],s,initial)
    def test_accepted_source_frozen(self):
        s=self.c.status();initial=self.c.project_files();self.fixture_submission();self.write('All.lean','-- Replaced accepted source\n')
        with self.assertRaisesRegex(o.Stop,'ACCEPTED_LEAN_CHANGED'): self.c.frozen_scope(self.c.gates[1],s,initial)
    def test_snapshot_integrity_and_exclusions(self):
        s=self.c.status();s['attempt']=1;d=self.c.runtime/'runs/test';self.fake_checks({},d/'pre_review_checks')
        self.write('docs/source.pdf','excluded');self.write('reports/old.zip','excluded')
        dest,sha=self.c.snapshot(self.c.gates[1],s,d)
        self.addCleanup(lambda: [p.chmod(0o755 if p.is_dir() else 0o644) for p in [dest]+list(dest.rglob('*'))])
        self.assertFalse((dest/'docs/source.pdf').exists());self.assertFalse((dest/'reports/old.zip').exists());self.c.verify_snapshot(s)
        p=dest/'AGENTS.md';p.chmod(0o644);p.write_text('tampered')
        with self.assertRaisesRegex(o.Stop,'SNAPSHOT_CHANGED'): self.c.verify_snapshot(s)
    def test_interrupted_executor_stops_without_rerun(self):
        s=self.c.status();self.c.save(s,'EXECUTOR_RUNNING')
        with patch.object(self.c,'model_run',side_effect=AssertionError('no rerun')),self.assertRaisesRegex(o.Stop,'INTERRUPTED'): self.c.run()
    def test_full_mocked_pass_acceptance_commit_and_idempotence(self):
        # Run the real deterministic controller/Git/snapshot/recorder, mocking only model and Lean subprocess work.
        (self.outer/'unrelated.txt').write_text('untouched')
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=self.fake_model):
            result=self.c.run()
        self.assertEqual(result['status'],o.CHECKPOINT);self.assertTrue(result['acceptance_committed'])
        self.assertEqual(o.read_json(self.root/'contracts/theorems.json')['theorems'][0]['status'],'GREEN')
        self.assertTrue((self.root/'reviews/m03b1_acceptance.md').exists())
        count=self.git('rev-list','--count','HEAD');self.assertEqual(count,'2')
        self.assertEqual(self.c.run()['status'],o.CHECKPOINT);self.assertEqual(self.git('rev-list','--count','HEAD'),count)
        self.assertEqual((self.outer/'unrelated.txt').read_text(),'untouched')
        # Permit temporary-directory cleanup of the deliberately frozen snapshot.
        for p in (self.c.runtime/'review_snapshots').rglob('*'): p.chmod(0o755 if p.is_dir() else 0o644)
    def unfreeze(self):
        for p in self.c.runtime.rglob('*'):
            p.chmod(0o755 if p.is_dir() else 0o644)
    def test_real_loop_revision_limit(self):
        self.addCleanup(self.unfreeze)
        calls=[]
        def model(role,prompt,cwd,directory):
            calls.append(role)
            if role=='executor': self.fixture_submission();return 'fixture'
            st=self.c.status()
            return json.dumps(verdict(attempt=st['attempt'],snapshot_sha256=st['snapshot_sha256'],verdict='REVISE',revision_prompt='Repair only this fixture gate.'))
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=model): result=self.c.run()
        self.assertEqual(result['status'],'HUMAN_STOP');self.assertEqual(result['revisions'],2)
        self.assertEqual(calls.count('executor'),3);self.assertEqual(calls.count('reviewer'),3)
        self.assertEqual(self.git('rev-list','--count','HEAD'),'1')
    def test_reviewer_usage_resume_never_reexecutes(self):
        self.addCleanup(self.unfreeze)
        calls=[]
        def failing(role,prompt,cwd,directory):
            calls.append(role)
            if role=='executor': self.fixture_submission();return 'fixture'
            raise o.Stop('MODEL_FAILED_OR_USAGE_LIMIT')
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=failing),self.assertRaises(o.Stop): self.c.run()
        self.assertEqual(self.c.status()['resume_phase'],'REVIEW_RETRY')
        def restored(role,prompt,cwd,directory):
            calls.append(role);self.assertEqual(role,'reviewer');st=self.c.status()
            return json.dumps(verdict(snapshot_sha256=st['snapshot_sha256'],attempt=st['attempt']))
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=restored): result=self.c.run(resume=True)
        self.assertEqual(result['status'],o.CHECKPOINT);self.assertEqual(calls.count('executor'),1)
        self.assertIn('reviewer_retry_',result['review_output_dir'])
        persisted=o.read_json(self.root/'reports/logs/m03b1/review/reviewer_final.json')
        self.assertEqual(persisted,result['reviewer_verdict'])
    def test_post_commit_crash_recovery_is_idempotent(self):
        self.addCleanup(self.unfreeze); pending=[];original_save=self.c.save
        def save(state,status=None):
            original_save(state,status)
            if status=='ACCEPTANCE_COMMIT_PENDING': pending.append(copy.deepcopy(state))
        with patch.object(self.c,'save',side_effect=save),patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=self.fake_model): self.c.run()
        self.assertEqual(len(pending),1)
        # Simulate disk state still showing pending, while the Git commit already exists.
        original_save(pending[0])
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'model_run',side_effect=AssertionError('must not call model')): result=self.c.run()
        self.assertEqual(result['status'],o.CHECKPOINT);self.assertEqual(self.git('rev-list','--count','HEAD'),'2')
    def test_deterministic_failure_never_calls_reviewer(self):
        calls=[]
        def model(role,*args): calls.append(role);self.fixture_submission();return 'fixture'
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=o.Stop('DETERMINISTIC_CHECK_FAILED')),patch.object(self.c,'model_run',side_effect=model),self.assertRaises(o.Stop): self.c.run()
        self.assertEqual(calls,['executor']);self.assertEqual(self.c.status()['status'],'HUMAN_STOP')

    def test_acceptance_cannot_modify_lean(self):
        s=self.c.status();initial=self.c.project_files();self.fixture_submission();d=self.c.runtime/'runs/test';self.fake_checks({},d/'pre_review_checks')
        dest,sha=self.c.snapshot(self.c.gates[1],s,d)
        self.addCleanup(lambda: [p.chmod(0o755 if p.is_dir() else 0o644) for p in [dest]+list(dest.rglob('*'))])
        s['reviewed_files']=self.c.project_files();s['reviewer_verdict']=verdict(snapshot_sha256=sha)
        o.atomic_json(d/'reviewer_final.json',s['reviewer_verdict'])
        o.atomic_json(d/'controller_decision.json',{'action':'ACCEPTANCE_RECORDING','snapshot_sha256':sha})
        (d/'review_prompt.md').write_text('Fixture review prompt')
        def corrupt(g,dr): self.write('All.lean','-- changed by acceptance check\n');self.fake_checks(g,dr)
        with patch.object(self.c,'checks',side_effect=corrupt),self.assertRaisesRegex(o.Stop,'ALLOWLIST'): self.c.record_acceptance(self.c.gates[1],s,d)
        self.assertEqual(self.git('rev-list','--count','HEAD'),'1')

    def configure_full_gates(self):
        configuration=o.read_json(MODULE.parent/'gates.json')
        self.c.gates=configuration['gates']
        self.write('orchestration/gates.json',json.dumps(configuration))
        data=o.read_json(self.root/'contracts/theorems.json');ids={t['id'] for t in data['theorems']}
        for g in self.c.gates:
            for cid in g['contracts']:
                if cid not in ids: data['theorems'].append({'id':cid,'status':'UNFORMALIZED','sources':[]})
        self.write('contracts/theorems.json',json.dumps(data));self.git('add','.');self.git('commit','-qm','Configure full fixture stage')
    def acceptance_fixture(self,index,qualification='Preserve this synthetic review qualification.',green=True,records=True,commit=True):
        g=self.c.gates[index];data=o.read_json(self.root/'contracts/theorems.json')
        if green:
            for t in data['theorems']:
                if t['id'] in g['contracts']: t['status']='GREEN'
        self.write('contracts/theorems.json',json.dumps(data))
        if records:
            stem=g['id'].lower()
            self.write(f'reviews/{stem}_acceptance.md',f"# {g['id']} independent automated acceptance\n\nDecision: ACCEPT.\n\nSnapshot SHA-256: {SHA}\n")
            self.write(f'reviews/{stem}_acceptance.json',json.dumps({'gate_id':g['id'],'contract_ids':g['contracts'],'snapshot_sha256':SHA,'reviewer_type':'independent fresh Codex reviewer','reviewer_model':'gpt-6-astra','final_verdict':'PASS','qualifications':[qualification],'nonblocking_findings':['Preserve the fixture diagnostic.'],'accepted_commit_sha':None,'evidence_directory':f"reports/logs/{stem}/review"}))
        if commit: self.git('add','.');self.git('commit','-qm','Accept synthetic fixture gate')
    def test_reconstruct_absent_runtime_after_m03a(self):
        self.configure_full_gates();self.assertEqual(self.c.status()['accepted'],['M03A']);self.assertEqual(self.c.status()['gate'],'M03B1')
    def test_reconstruct_absent_runtime_after_h09(self):
        self.configure_full_gates();self.acceptance_fixture(1)
        state=self.c.status();self.assertEqual(state['accepted'],['M03A','M03B1']);self.assertEqual(state['gate'],'M03B2')
    def test_reconstruct_absent_runtime_after_multiple(self):
        self.configure_full_gates()
        for i in (1,2,3): self.acceptance_fixture(i)
        self.assertEqual(self.c.status()['gate'],'M03C')
    def test_reconstruct_fresh_clone(self):
        self.configure_full_gates()
        for i in (1,2): self.acceptance_fixture(i)
        dest=Path(self.temp.name)/'clone'
        subprocess.check_call(['git','clone','-q',str(self.outer),str(dest)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        self.assertEqual(o.Controller(dest/'project').status()['gate'],'M03B3')
    def test_reconstruct_all_accepted_checkpoint_no_model(self):
        self.configure_full_gates()
        for i in range(1,len(self.c.gates)): self.acceptance_fixture(i)
        with patch.object(self.c,'model_run',side_effect=AssertionError('must not rerun accepted mathematics')),patch.object(self.c,'preflight',side_effect=AssertionError('no model needed')):
            self.assertEqual(self.c.run()['status'],o.CHECKPOINT)
        self.assertEqual(self.c.status()['gate'],None)
    def test_reconstruct_green_without_record(self):
        self.configure_full_gates();self.acceptance_fixture(1,records=False)
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*missing tracked'): self.c.status()
    def test_reconstruct_record_without_green(self):
        self.configure_full_gates();self.acceptance_fixture(1,green=False)
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*without GREEN'): self.c.status()
    def test_reconstruct_noncontiguous(self):
        self.configure_full_gates();self.acceptance_fixture(2)
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*noncontiguous'): self.c.status()
    def test_reconstruct_untracked_record_rejected(self):
        self.configure_full_gates();self.acceptance_fixture(1,commit=False)
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*tracked'): self.c.status()
    def test_reconstruct_wrong_gate_record(self):
        self.configure_full_gates();self.acceptance_fixture(1)
        path='reviews/m03b1_acceptance.json';record=o.read_json(self.root/path);record['gate_id']='M03B2';self.write(path,json.dumps(record))
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*identity'): self.c.status()
    def test_reconstruct_invalid_review_hash(self):
        self.configure_full_gates();self.acceptance_fixture(1);self.write('reviews/m03b1_acceptance.md','# M03B1 acceptance\nDecision: ACCEPT\nSnapshot SHA-256: invalid\n')
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*SHA-256'): self.c.status()
    def test_stale_ready_runtime_cannot_override_repository_acceptance(self):
        self.configure_full_gates();state=self.c.status();self.c.save(state);self.acceptance_fixture(1)
        with self.assertRaisesRegex(o.Stop,'ACCEPTANCE_STATE_INCONSISTENT.*cache disagrees'): self.c.status()
        with patch.object(self.c,'model_run',side_effect=AssertionError('must not rerun')),self.assertRaises(o.Stop): self.c.run()
        self.assertEqual(o.read_json(self.root/'contracts/theorems.json')['theorems'][0]['status'],'GREEN')
    def test_green_gate_cannot_be_downgraded_or_prompted(self):
        self.configure_full_gates();old=self.c.status();initial=self.c.project_files();self.acceptance_fixture(1)
        before=(self.root/'contracts/theorems.json').read_bytes()
        with self.assertRaisesRegex(o.Stop,'refusing to rerun or downgrade'): self.c.gate_prompt(self.c.gates[1],old)
        with self.assertRaisesRegex(o.Stop,'refusing to rerun or downgrade'): self.c.frozen_scope(self.c.gates[1],old,initial)
        self.assertEqual(before,(self.root/'contracts/theorems.json').read_bytes())
    def test_predecessor_qualification_in_next_prompt(self):
        self.configure_full_gates();q='DISTINCTIVE H09 FIXTURE: retain extended boundary objects until conditional finiteness is proved.';self.acceptance_fixture(1,q)
        prompt=self.c.gate_prompt(self.c.gates[2],self.c.status())
        self.assertIn('MANDATORY CARRY-FORWARD QUALIFICATIONS',prompt);self.assertIn(q,prompt);self.assertIn('zeroRightMarginal',prompt)
        self.assertIn('Preserve the fixture diagnostic.',prompt)
        self.assertEqual(self.c.acceptance_record(self.c.gates[1])['accepted_commit_sha'],self.git('rev-parse','HEAD'))
    def test_manual_executor_zip_override(self):
        prompt=self.c.gate_prompt(self.c.gates[1],self.c.status())
        self.assertIn(o.MANUAL_ZIP_OVERRIDE,prompt);self.assertNotIn('prepare the required review ZIP',prompt)
    def test_durable_review_evidence_survives_runtime_deletion(self):
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=self.fake_model): result=self.c.run()
        directory=self.root/'reports/logs/m03b1/review'
        expected={'snapshot_manifest.json','reviewer_final.json','controller_decision.json','review_prompt.md','executor_final.md','executor_invocations.json'}
        self.assertEqual({p.name for p in directory.iterdir()},expected)
        self.assertTrue(all(self.c.tracked(str(p.relative_to(self.root))) for p in directory.iterdir()))
        self.assertEqual(o.digest(o.canonical(o.read_json(directory/'snapshot_manifest.json'))),result['snapshot_sha256'])
        self.unfreeze();shutil.rmtree(self.c.runtime)
        self.assertEqual(self.c.status()['status'],o.CHECKPOINT)
        self.assertTrue(all((directory/n).is_file() for n in expected))
        with patch.object(self.c,'model_run',side_effect=AssertionError('no rerun')): self.assertEqual(self.c.run()['status'],o.CHECKPOINT)
    def source_fixture(self):
        data=o.read_json(self.root/'contracts/theorems.json');data['theorems'][0]['sources']=['TEST'];data['theorems'][0]['source_locator']='Fixture section 2, printed 3 / PDF 4';self.write('contracts/theorems.json',json.dumps(data))
        paper=b'%PDF-1.4 synthetic source fixture only';name='approved.pdf'
        self.write('sources/papers/'+name,paper.decode());self.write('sources/papers/unrelated.pdf','unrelated source must not be copied')
        self.write('.gitignore',(self.root/'.gitignore').read_text()+'sources/papers/*.pdf\n')
        self.write('contracts/source_manifest.json',json.dumps({'sources':[{'id':'TEST','local_name':name,'sha256':o.digest(paper)}]}))
        return paper
    def test_source_evidence_only_assigned_approved_pdf(self):
        paper=self.source_fixture();s=self.c.status();d=self.c.runtime/'source_test';self.fake_checks({},d/'pre_review_checks')
        dest,sha=self.c.snapshot(self.c.gates[1],s,d);self.addCleanup(self.unfreeze)
        self.assertEqual((dest/'source_evidence/approved.pdf').read_bytes(),paper)
        self.assertFalse((dest/'source_evidence/unrelated.pdf').exists());self.assertFalse((dest/'sources').exists())
        self.assertEqual(o.read_json(dest/'source_evidence/index.json')[0]['source_id'],'TEST')
        self.assertIn('source_evidence/approved.pdf',o.read_json(dest/'snapshot_manifest.json')['files'])
        self.assertTrue((dest/'predecessor_acceptances.json').is_file());self.c.verify_snapshot(s)
        self.assertEqual((dest/'source_evidence/approved.pdf').stat().st_mode & 0o222,0)
    def test_source_missing_fails_closed(self):
        self.source_fixture();(self.root/'sources/papers/approved.pdf').unlink()
        with self.assertRaisesRegex(o.Stop,'APPROVED_SOURCE_EVIDENCE_INVALID.*missing'): self.c.approved_source_evidence(self.c.gates[1])
    def test_source_hash_mismatch_fails_closed(self):
        self.source_fixture();self.write('sources/papers/approved.pdf','corrupted')
        with self.assertRaisesRegex(o.Stop,'APPROVED_SOURCE_EVIDENCE_INVALID.*SHA-256'): self.c.approved_source_evidence(self.c.gates[1])
    def test_source_unknown_id_fails_closed(self):
        self.source_fixture();self.write('contracts/source_manifest.json','{"sources":[]}')
        with self.assertRaisesRegex(o.Stop,'APPROVED_SOURCE_EVIDENCE_INVALID.*unknown'): self.c.approved_source_evidence(self.c.gates[1])
    def test_source_locator_missing_fails_closed(self):
        self.source_fixture();data=o.read_json(self.root/'contracts/theorems.json');data['theorems'][0].pop('source_locator');self.write('contracts/theorems.json',json.dumps(data))
        with self.assertRaisesRegex(o.Stop,'APPROVED_SOURCE_EVIDENCE_INVALID.*locator'): self.c.approved_source_evidence(self.c.gates[1])
    def test_credentials_not_committed_in_compact_review(self):
        self.addCleanup(self.unfreeze)
        def model(role,prompt,cwd,directory):
            if role=='executor': self.fixture_submission();return 'fixture'
            state=self.c.status()
            return json.dumps(verdict(snapshot_sha256=state['snapshot_sha256'],qualifications=['sk-'+'x'*30]))
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=model),self.assertRaisesRegex(o.Stop,'CREDENTIAL_PATTERN'): self.c.run()
        self.assertEqual(self.git('rev-list','--count','HEAD'),'1')
        self.assertFalse((self.root/'reports/logs/m03b1/review').exists())
    def test_source_path_escape_fails_closed(self):
        self.source_fixture();self.write('contracts/source_manifest.json',json.dumps({'sources':[{'id':'TEST','local_name':'../forbidden.pdf','sha256':SHA}]}))
        with self.assertRaisesRegex(o.Stop,'APPROVED_SOURCE_EVIDENCE_INVALID.*invalid'): self.c.approved_source_evidence(self.c.gates[1])
    def test_source_symlink_fails_closed(self):
        self.source_fixture();path=self.root/'sources/papers/approved.pdf';path.unlink();path.symlink_to(self.root/'sources/papers/unrelated.pdf')
        with self.assertRaisesRegex(o.Stop,'APPROVED_SOURCE_EVIDENCE_INVALID.*symlink'): self.c.approved_source_evidence(self.c.gates[1])

    def completed_policy_attempt(self,state):
        directory=self.c.runtime/f"policy_fixture_{len(state.get('executor_history',[]))}"
        directory.mkdir(parents=True)
        self.c.begin_executor_invocation(state,directory)
        self.c.finish_executor_invocation(state,directory,'COMPLETED')
    def test_policy_new_gate_medium(self):
        state=self.c.status();self.assertEqual(self.c.executor_plan(state)['reasoning_effort'],'medium')
        self.assertEqual(state['next_executor_model'],'gpt-5.6-sol')
    def test_policy_first_substantive_retry_high(self):
        state=self.c.status();self.completed_policy_attempt(state)
        self.c.authorize_executor_revision(state,'REVIEWER_REVISION')
        self.assertEqual(self.c.executor_plan(state)['reasoning_effort'],'high')
    def test_policy_second_substantive_retry_xhigh_and_limit(self):
        state=self.c.status()
        for _ in range(2):
            self.completed_policy_attempt(state);self.c.authorize_executor_revision(state,'REVIEWER_REVISION')
        self.assertEqual(self.c.executor_plan(state)['reasoning_effort'],'xhigh')
        self.completed_policy_attempt(state)
        with self.assertRaisesRegex(o.Stop,'MAXIMUM_REVISIONS'): self.c.authorize_executor_revision(state,'REVIEWER_REVISION')
        self.assertEqual(state['revisions'],2);self.assertEqual(self.c.executor_plan(state)['reasoning_effort'],'xhigh')
    def test_policy_authorized_deterministic_repair(self):
        state=self.c.status();self.completed_policy_attempt(state);self.c.authorize_executor_revision(state,'DETERMINISTIC_REPAIR')
        self.assertEqual(self.c.executor_plan(state)['reasoning_effort'],'high');self.assertEqual(state['executor_invocation_reason'],'DETERMINISTIC_REPAIR')
    def test_policy_infrastructure_cannot_authorize_escalation(self):
        state=self.c.status()
        with self.assertRaisesRegex(o.Stop,'no completed executor'): self.c.authorize_executor_revision(state,'REVIEWER_REVISION')
        with self.assertRaisesRegex(o.Stop,'infrastructure failure'): self.c.authorize_executor_revision(state,'USAGE_LIMIT')
        self.assertEqual(self.c.executor_plan(state)['reasoning_effort'],'medium')
    def test_policy_restart_preserves_high(self):
        state=self.c.status();self.completed_policy_attempt(state);self.c.authorize_executor_revision(state,'REVIEWER_REVISION');self.c.save(state)
        self.assertEqual(o.Controller(self.root).status()['next_executor_effort'],'high')
    def test_policy_restart_preserves_xhigh(self):
        state=self.c.status()
        for _ in range(2):
            self.completed_policy_attempt(state);self.c.authorize_executor_revision(state,'REVIEWER_REVISION')
        self.c.save(state);self.assertEqual(o.Controller(self.root).status()['next_executor_effort'],'xhigh')
    def test_policy_acceptance_resets_next_gate_medium(self):
        self.configure_full_gates();state=self.c.status();self.acceptance_fixture(1)
        state.update(accepted=['M03A','M03B1'],status='GATE_ACCEPTED',executor_effort_index=2,executor_invocation_reason='REVIEWER_REVISION',revisions=2)
        self.c.save(state);result=self.c.status()
        self.assertEqual(result['next_executor_gate'],'M03B2');self.assertEqual(result['next_executor_effort'],'medium')
    def test_policy_reconstructed_next_gate_medium(self):
        self.configure_full_gates();self.acceptance_fixture(1)
        state=self.c.status();self.assertEqual(state['gate'],'M03B2');self.assertEqual(state['next_executor_effort'],'medium')
    def test_policy_dry_run_medium_command(self):
        result=self.c.dry_run();self.assertEqual(result['executor']['model'],'gpt-5.6-sol');self.assertEqual(result['executor']['reasoning_effort'],'medium')
        self.assertIn('model_reasoning_effort="medium"',result['planned_executor_command'])
    def policy_failure(self,error):
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'model_run',side_effect=error),self.assertRaises(o.Stop): self.c.run()
        state=self.c.status();self.assertEqual(state['next_executor_effort'],'medium');self.assertEqual(state['revisions'],0)
        self.assertEqual(state['executor_history'][-1]['outcome'],'INFRASTRUCTURE_FAILURE')
        self.assertEqual(state['resume_phase'],'READY_TO_EXECUTE')
    def test_policy_usage_failure_same_effort_on_resume(self):
        self.policy_failure(o.Stop('MODEL_FAILED_OR_USAGE_LIMIT'))
        self.addCleanup(self.unfreeze)
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=self.fake_model): result=self.c.run(resume=True)
        history=o.read_json(self.root/'reports/logs/m03b1/review/executor_invocations.json')
        self.assertEqual([x['reasoning_effort'] for x in history],['medium','medium'])
        self.assertEqual([x['outcome'] for x in history],['INFRASTRUCTURE_FAILURE','COMPLETED'])
    def test_policy_authentication_failure_no_escalation(self):
        with patch.object(self.c,'preflight',side_effect=o.Stop('CHATGPT_AUTH_REQUIRED')),self.assertRaises(o.Stop): self.c.run()
        state=self.c.status();self.assertEqual(state['next_executor_effort'],'medium');self.assertEqual(state['executor_history'],[])
    def test_policy_interrupt_no_escalation(self): self.policy_failure(KeyboardInterrupt())
    def test_policy_os_failure_no_escalation(self): self.policy_failure(OSError('fixture OS unavailable'))
    def test_policy_codex_unavailable_no_escalation(self): self.policy_failure(o.Stop('CODEX_MISSING'))
    def test_policy_corrupt_state_stops_without_escalation(self):
        state=self.c.status();state['executor_effort_index']=99;o.atomic_json(self.c.state_path,state)
        with self.assertRaisesRegex(o.Stop,'EXECUTOR_POLICY_STATE_INVALID'): self.c.status()
        self.assertEqual(o.read_json(self.c.state_path)['executor_effort_index'],99)
    def test_policy_cli_requests_effort_and_reviewer_stays_xhigh(self):
        state=self.c.status();directory=self.c.runtime/'cli_fixture';directory.mkdir(parents=True)
        self.c.begin_executor_invocation(state,directory);self.c.save(state,'EXECUTOR_RUNNING')
        commands=[]
        def fake_run(args,**kwargs):
            commands.append(args);Path(args[args.index('--output-last-message')+1]).write_text('fixture');return response()
        with patch.object(self.c,'preflight',return_value={}),patch.object(o.subprocess,'run',side_effect=fake_run):
            self.c.model_run('executor','fixture prompt',self.root,directory)
            self.c.model_run('reviewer','fixture prompt',self.root,directory)
        self.assertIn('gpt-5.6-sol',commands[0]);self.assertIn('model_reasoning_effort="medium"',commands[0])
        self.assertIn('gpt-6-astra',commands[1]);self.assertIn('model_reasoning_effort="xhigh"',commands[1]);self.assertIn('read-only',commands[1])
    def test_policy_real_revision_loop_effort_and_durable_history(self):
        self.addCleanup(self.unfreeze)
        def model(role,prompt,cwd,directory):
            if role=='executor': self.fixture_submission();return 'fixture completed'
            state=self.c.status();revise=state['revisions']<2
            return json.dumps(verdict(attempt=state['attempt'],snapshot_sha256=state['snapshot_sha256'],verdict='REVISE' if revise else 'PASS',revision_prompt='Repair this same gate.' if revise else None))
        with patch.object(self.c,'preflight',return_value={}),patch.object(self.c,'checks',side_effect=self.fake_checks),patch.object(self.c,'model_run',side_effect=model): self.c.run()
        history=o.read_json(self.root/'reports/logs/m03b1/review/executor_invocations.json')
        self.assertEqual([x['reasoning_effort'] for x in history],['medium','high','xhigh'])
        self.assertEqual([x['reason'] for x in history],['INITIAL','REVIEWER_REVISION','REVIEWER_REVISION'])
        self.assertEqual([x['invocation_number'] for x in history],[1,2,3])
        self.assertTrue(all(x['gate_id']=='M03B1' and x['model']=='gpt-5.6-sol' for x in history))
    def test_policy_legacy_interrupted_effort_not_inferred(self):
        state=self.c.status();state.pop('executor_effort_index');state['status']='EXECUTOR_RUNNING';o.atomic_json(self.c.state_path,state)
        with self.assertRaisesRegex(o.Stop,'old active runtime'): self.c.status()
    def test_policy_history_rejects_within_gate_downgrade(self):
        state=self.c.status();self.completed_policy_attempt(state);self.c.authorize_executor_revision(state,'REVIEWER_REVISION');self.completed_policy_attempt(state)
        state['executor_effort_index']=0;o.atomic_json(self.c.state_path,state)
        with self.assertRaisesRegex(o.Stop,'within-gate downgrade'): self.c.status()
    def test_policy_configuration_rejects_downgrade_or_above_xhigh(self):
        for sequence in (['xhigh','medium'],['medium','ultra'],[]):
            config=o.read_json(self.root/'orchestration/config.json');config['executor_reasoning_effort_sequence']=sequence;self.write('orchestration/config.json',json.dumps(config))
            with self.assertRaisesRegex(o.Stop,'INVALID_EXECUTOR_REASONING_POLICY'): o.Controller(self.root)

class DimensionTests(unittest.TestCase):
    def decide(self,v): return o.decision(v,GATE,1,SHA,True)
    def test_shallow_pass_without_dimensions_rejected(self):
        v=verdict();v.pop('dimension_assessments');v['contract_assessments'][0]['assessment']='Looks correct.'
        with self.assertRaises(o.Stop): self.decide(v)
    def test_duplicate_or_missing_dimension_rejected(self):
        for mutate in (lambda x:x.pop(),lambda x:x.__setitem__(19,copy.deepcopy(x[0]))):
            v=verdict();mutate(v['dimension_assessments'])
            with self.assertRaises(o.Stop): self.decide(v)
    def test_empty_or_generic_dimension_evidence_rejected(self):
        for text in ('',' ','Looks correct.'):
            v=verdict();v['dimension_assessments'][0]['evidence']=text
            with self.assertRaises(o.Stop): self.decide(v)
    def test_fail_and_uncertain_cannot_pass(self):
        for status in ('FAIL','UNCERTAIN'):
            for did in o.DIMENSIONS:
                v=verdict();next(x for x in v['dimension_assessments'] if x['dimension_id']==did)['status']=status
                self.assertEqual(self.decide(v),'HUMAN_STOP')
    def test_source_uncertainty_cannot_auto_revise(self):
        v=verdict(verdict='REVISE',revision_prompt='Try again on the same gate.')
        v['dimension_assessments'][3]['status']='UNCERTAIN'
        self.assertEqual(self.decide(v),'HUMAN_STOP')
    def test_core_dimensions_cannot_be_not_applicable(self):
        for did in o.CORE_DIMENSIONS:
            v=verdict();item=next(x for x in v['dimension_assessments'] if x['dimension_id']==did);item.update(status='NOT_APPLICABLE',evidence='Not applicable because this synthetic fixture has no relevant obligation in this test.')
            with self.assertRaises(o.Stop): self.decide(v)
    def test_not_applicable_requires_specific_explanation(self):
        v=verdict();v['dimension_assessments'][10].update(status='NOT_APPLICABLE',evidence='This dimension is not applicable to the given gate and was therefore omitted.')
        with self.assertRaises(o.Stop): self.decide(v)
        v['dimension_assessments'][10]['evidence']='Inspected the fixture contract: no convergence theorem is required because its conclusion is purely a finite algebraic equality.'
        self.assertEqual(self.decide(v),'ACCEPTANCE_RECORDING')
    def test_schema_matches_twenty_dimension_contract(self):
        schema=o.read_json(MODULE.parent/'schemas/review.schema.json')
        self.assertIn('dimension_assessments',schema['required']);d=schema['properties']['dimension_assessments']
        self.assertEqual(d['minItems'],20);self.assertEqual(d['maxItems'],20)
        self.assertEqual(d['items']['properties']['dimension_id']['enum'],list(o.DIMENSIONS))
    def test_pdf_unreadable_reviewer_instruction(self):
        prompt=(MODULE.parent/'prompts/reviewer.md').read_text()
        self.assertIn('D04 UNCERTAIN',prompt);self.assertIn('return BLOCK',prompt);self.assertIn('ONLY the sections/pages',prompt)

if __name__=='__main__': unittest.main()
