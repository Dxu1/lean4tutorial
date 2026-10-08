import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from acceptance_status import repair,promote_metadata,resume
from review_evidence import ledger_errors

class AcceptanceStatusTests(unittest.TestCase):
    def setUp(self):
        self.g={'id':'M09C2','contracts':['A05']}
        self.r={'theorems':[{'id':'A04','status':'GREEN','dependencies':[]},{'id':'A05','status':'REVIEW_READY','dependencies':['A04']},{'id':'G04','status':'UNFORMALIZED','dependencies':[]}]}
        self.c=copy.deepcopy(self.r);self.c['theorems'][1]['status']='GREEN'
        self.s={'status':'ACCEPTANCE_RECORDING','gate':'M09C2','snapshot_sha256':'frozen','reviewer_verdict':{'verdict':'PASS','confidence':'HIGH','requires_human_review':False,'snapshot_sha256':'frozen','blocking_findings':[]},'executor_history':[{'model':'gpt-5.6-sol','reasoning_effort':'medium','invocation_number':1}],'revisions':0}
        self.old='**Economic status:** A04 is **GREEN**; A05 is **REVIEW_READY**; G04 is **UNFORMALIZED**.\n\n## A04 — Certainty\n**Status:** GREEN.\nExact mathematical proof. A05 is separately REVIEW_READY below.\n\n## A05 — Comparison\n**Status:** REVIEW_READY.\nExact comparison proof.\n\n## G04 — Bound\n**Status:** UNFORMALIZED.\n'
        self.text=promote_metadata(self.old,self.c,self.g)
    def fix(self):return repair(self.text,self.old,self.c,self.r,self.g,self.s)
    def reject(self):self.assertRaisesRegex(ValueError,'AMBIGUOUS_ACCEPTANCE_STATUS_CONFLICT',self.fix)
    def test_exact_fixture(self):self.assertIn('A05 is addressed separately below.',self.fix())
    def test_pass_green_stale_reconciles(self):self.assertEqual(ledger_errors(self.fix(),self.c['theorems']),[])
    def test_no_independent_pass(self):self.s['reviewer_verdict']['verdict']='FAIL';self.reject()
    def test_before_acceptance(self):self.s['status']='DETERMINISTIC_CHECKS';self.reject()
    def test_cannot_grant_green(self):self.c['theorems'][1]['status']='REVIEW_READY';self.reject()
    def test_detail_conflict(self):self.text=self.text.replace('**Status:** GREEN. Independent','**Status:** REVIEW_READY. Independent');self.reject()
    def test_math_mutation(self):self.text=self.text.replace('Exact mathematical proof','Different mathematical proof');self.reject()
    def test_contract_mutation(self):self.c['theorems'][1]['dependencies']=[];self.reject()
    def test_unrelated_drift(self):self.c['theorems'][2]['status']='GREEN';self.reject()
    def test_historical_is_not_rewritten(self):
        self.old=self.old.replace('A05 is separately REVIEW_READY below.','Historically, A05 is separately REVIEW_READY below.')
        self.text=promote_metadata(self.old,self.c,self.g);self.assertEqual(self.fix(),self.text)
    def test_current_metadata_generated(self):
        self.assertIn('A04, A05 are **GREEN**',self.text);self.assertIn('**Status:** GREEN. Independent Astra acceptance:',self.text)
    def test_snapshot_binding(self):self.s['reviewer_verdict']['snapshot_sha256']='other';self.reject()
    def test_operative_verdict_unchanged(self):
        v=copy.deepcopy(self.s['reviewer_verdict']);self.fix();self.assertEqual(v,self.s['reviewer_verdict'])
    def test_executor_one_medium_unchanged(self):
        v=copy.deepcopy(self.s['executor_history']);self.fix();self.assertEqual(v,self.s['executor_history'])
    def test_no_substantive_revision(self):self.fix();self.assertEqual(self.s['revisions'],0)
    def test_only_status_sentence_changes(self):self.assertEqual(self.fix(),self.text.replace('A05 is separately REVIEW_READY below.','A05 is addressed separately below.'))
    def test_qualifications_unchanged(self):self.assertIn('Exact comparison proof.',self.fix())
    def test_multiple_statuses_rejected(self):self.text+='\nG04 is GREEN.\n';self.reject()
    def test_sentence_with_math_rejected(self):
        self.old=self.old.replace('A05 is separately REVIEW_READY below.','A05 is separately REVIEW_READY below and proves stronger mathematics.')
        self.text=promote_metadata(self.old,self.c,self.g);self.reject()
    def test_no_pass_low_confidence(self):self.s['reviewer_verdict']['confidence']='LOW';self.reject()
    def test_human_flag(self):self.s['reviewer_verdict']['requires_human_review']=True;self.reject()
    def test_blockers(self):self.s['reviewer_verdict']['blocking_findings']=['block'];self.reject()
    def test_duplicate_sentence(self):self.old=self.old.replace('below.','below. A05 is separately REVIEW_READY below.');self.text=promote_metadata(self.old,self.c,self.g);self.reject()
    def test_active_section_not_allowed(self):
        self.old=self.old.replace(' A05 is separately REVIEW_READY below.','').replace('Exact comparison proof.','Exact comparison proof. A05 is separately REVIEW_READY below.')
        self.text=promote_metadata(self.old,self.c,self.g);self.reject()

class ResumeFixtureTests(unittest.TestCase):
    """Mocked resumed transaction exercises preservation and actual commit handoff."""
    def test_resume_receipt_tamper_fails_before_writes(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'freeze.json';p.write_text('{}');c=Mock();c.lock.return_value.__enter__=Mock();c.lock.return_value.__exit__=Mock(return_value=False);c.status.return_value={}
            self.assertRaises(ValueError,resume,c,p,'wrong','head');c.commit_acceptance.assert_not_called();c.model_run.assert_not_called()

class GuardedResumeTests(unittest.TestCase):
    def setUp(self):
        import hashlib
        from contextlib import nullcontext
        from acceptance_status import INFRA
        self.sha=lambda b:hashlib.sha256(b).hexdigest()
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
        f=AcceptanceStatusTests();f.setUp();self.g=f.g;self.contracts=f.c;self.reviewed=f.r;self.old=f.old;self.text=f.text
        def put(n,v):
            p=self.root/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(v)
        self.put=put;self.dumps=lambda v:json.dumps(v,indent=2,ensure_ascii=False)+'\n'
        put('docs/proof_ledger.md',self.old);put('docs/proof_ledger.tex','tex');put('docs/proof_ledger.pdf','pdf')
        put('contracts/theorems.json',self.dumps(self.reviewed));put('A05.lean','theorem unchanged');put('Audit.lean','audit unchanged')
        self.files=lambda:{str(p.relative_to(self.root)):self.sha(p.read_bytes()) for p in self.root.rglob('*') if p.is_file() and 'runtime' not in p.relative_to(self.root).parts}
        reviewed_files=self.files();put('docs/proof_ledger.md',self.text);put('contracts/theorems.json',self.dumps(self.contracts))
        self.s=copy.deepcopy(f.s);self.s.update(status='HUMAN_STOP',diagnostic='LEDGER_STATUS_MISMATCH: current prose A05 claims REVIEW_READY',attempt=1,baseline='old',initial_files={},reviewed_files=reviewed_files,snapshot_path=str(self.root/'runtime/snapshot'))
        self.s['executor_history'][0].update(outcome='COMPLETED');self.v=self.s['reviewer_verdict'];self.s['operative_reviewer']={'phase':'initial'};self.s['reviewer_history']={'operative':'initial','initial':{'verdict':self.v}}
        put('runtime/snapshot/snapshot_manifest.json',self.dumps({'files':{n:h for n,h in reviewed_files.items() if n.endswith('.lean')}}))
        put('reviews/m09c2_acceptance.json',self.dumps({'evidence_directory':'reports/logs/m09c2/review','snapshot_sha256':'frozen','final_verdict':'PASS'}))
        put('reviews/m09c2_acceptance.md','accepted');put('reports/logs/m09c2/review/reviewer_final.json',self.dumps(self.v))
        put('runtime/state.json',self.dumps(self.s));put('runtime/repair/reviewed_ledger.md',self.old)
        self.receipt=self.root/'runtime/repair/freeze.json';self.r={'state_sha256':self.sha((self.root/'runtime/state.json').read_bytes()),'state':copy.deepcopy(self.s),'head':'old','files':self.files(),'reviewer_verdict':copy.deepcopy(self.v),'snapshot_sha256':'frozen'}
        for n in INFRA:put(n,'infrastructure\n')
        self.c=Mock();self.c.root=self.root;self.c.runtime=self.root/'runtime';self.c.state_path=self.root/'runtime/state.json';self.c.gates=[self.g];self.c.lock.side_effect=nullcontext;self.c.status.side_effect=lambda:copy.deepcopy(self.s);self.c.project_files.side_effect=self.files
        def git(*args):
            if args==('rev-parse','HEAD'):return 'new\n'
            if args==('rev-parse','--show-prefix'):return 'project/'
            if args==('merge-base','--is-ancestor','old','new'):return ''
            if args==('rev-list','old..new'):return 'new'
            if args==('diff-tree','--no-commit-id','--name-only','-r','new'):return '\n'.join('project/'+n for n in INFRA)
            if args==('diff','--name-only','old','new'):return '\n'.join('project/'+n for n in INFRA)
            if args==('diff','--cached','--name-only'):return ''
            if args[0]=='show':return 'infrastructure\n'
            raise AssertionError(args)
        self.c.git.side_effect=git;self.c.baseline_contracts.return_value=copy.deepcopy(self.reviewed)
        d=self.root/'runtime/checks';d.mkdir();(d/'deterministic_summary.json').write_text('{"passed":true}')
        self.c.check_directory.side_effect=lambda gate,state,phase: d if phase=='acceptance' else (_ for _ in ()).throw(ValueError('UNKNOWN_CHECK_PHASE'))
        self.c.save.side_effect=lambda state,status:state.update(status=status)
        self.c.commit_acceptance.side_effect=lambda state:state.update(status='GATE_ACCEPTED')
        self.auth=patch('acceptance_status.authorize');self.mock_auth=self.auth.start();self.addCleanup(self.auth.stop)
    def run_resume(self):
        self.receipt.write_text(self.dumps(self.r));return resume(self.c,self.receipt,self.sha(self.receipt.read_bytes()),'new')
    def test_acceptance_resumes_without_models(self):
        result=self.run_resume();self.assertEqual(result['status'],'GATE_ACCEPTED');self.c.commit_acceptance.assert_called_once();self.c.model_run.assert_not_called()
    def test_document_generation_has_distinct_evidence_path(self):
        self.run_resume();self.assertNotEqual(self.c.command_log.call_args.args[2],self.c.checks.call_args.args[1])
    def test_math_hashes_unchanged(self):
        before=(self.root/'A05.lean').read_bytes();self.run_resume();self.assertEqual(before,(self.root/'A05.lean').read_bytes())
    def test_changed_math_rejected(self):
        self.put('A05.lean','changed');self.assertRaises(ValueError,self.run_resume);self.c.commit_acceptance.assert_not_called()
    def test_snapshot_unchanged(self):
        p=self.root/'runtime/snapshot/snapshot_manifest.json';before=p.read_bytes();self.run_resume();self.assertEqual(before,p.read_bytes());self.c.snapshot.assert_not_called()
    def test_snapshot_failure_blocks_resume(self):
        self.mock_auth.side_effect=ValueError('SNAPSHOT_CHANGED');self.assertRaises(ValueError,self.run_resume);self.c.commit_acceptance.assert_not_called()
    def test_verdict_preserved(self):
        before=copy.deepcopy(self.s['reviewer_verdict']);self.run_resume();self.assertEqual(before,self.s['reviewer_verdict']);self.c.review_submission.assert_not_called()
    def test_calls_revisions_preserved(self):
        before=copy.deepcopy(self.s['executor_history']);self.run_resume();self.assertEqual(before,self.s['executor_history']);self.assertEqual(self.s['revisions'],0)
    def test_contract_tamper_rejected(self):
        self.contracts['theorems'][1]['dependencies']=[];self.put('contracts/theorems.json',self.dumps(self.contracts));self.assertRaises(ValueError,self.run_resume)
