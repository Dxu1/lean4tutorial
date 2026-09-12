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
        self.write('contracts/theorems.json',json.dumps({'theorems':[{'id':'H09','status':'UNFORMALIZED','declaration':'Fixture.target','module':'Fixture.lean','statement':'unchanged fixture contract'}]}))
        for n in ['AGENTS.md','prompts/03_household_analysis.md','docs/architecture.md','docs/lean_interfaces.md','docs/dependency_graph.md','contracts/assumptions.json','reviews/03a_acceptance.md']:
            self.write(n,'Fixture authority; not an economic implementation.\n')
        self.write('docs/proof_ledger.md','# Fixture\n\n**Economic status:** H09 UNFORMALIZED\n\n## H09 — fixture\n\n**Status:** UNFORMALIZED.\n')
        self.write('All.lean','-- Accepted fixture source\n')
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
        def corrupt(g,dr): self.write('All.lean','-- changed by acceptance check\n');self.fake_checks(g,dr)
        with patch.object(self.c,'checks',side_effect=corrupt),self.assertRaisesRegex(o.Stop,'ALLOWLIST'): self.c.record_acceptance(self.c.gates[1],s,d)
        self.assertEqual(self.git('rev-list','--count','HEAD'),'1')

if __name__=='__main__': unittest.main()
