import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from ledger_reconciliation import repaired_text,reconcile
from global_status import overview
class LedgerReconciliationTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
        self.baseline={'theorems':[{'id':'F01','status':'GREEN','stage':'09'},{'id':'G01','status':'UNFORMALIZED','stage':'09'},{'id':'F02','status':'UNFORMALIZED','stage':'09'}]}
        self.contracts=copy.deepcopy(self.baseline);self.contracts['theorems'][1]['status']='REVIEW_READY'
        self.gate={'id':'M09A2','contracts':['G01']}
        self.state={'status':'DETERMINISTIC_CHECKS','gate':'M09A2','attempt':1,'revisions':0,'initial_files':{},'executor_history':[{'model':'gpt-5.6-sol','reasoning_effort':'medium','outcome':'COMPLETED','invocation_number':1}]}
        self.text='**Economic status:** F01 is **GREEN**; G01, F02 are **UNFORMALIZED**.\n\n'+''.join('## '+t['id']+' — fixture\n**Status:** '+t['status']+'.\nExact mathematical prose.\n' for t in self.contracts['theorems'])
        self.c=Mock();self.c.root=self.root;self.c.runtime=self.root/'runtime';self.c.error=ValueError
        self.c.baseline_contracts.return_value=self.baseline;self.state['baseline']='baseline'
        for n,data in [('contracts/theorems.json',json.dumps(self.contracts)),('docs/proof_ledger.md',self.text),('docs/proof_ledger.tex','old tex'),('docs/proof_ledger.pdf','old pdf'),('G01.lean','theorem unchanged')]:
            p=self.root/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(data)
        import hashlib
        self.c.project_files.side_effect=lambda:{str(p.relative_to(self.root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in self.root.rglob('*') if p.is_file() and 'runtime' not in p.parts}
        def build(*args):
            for ext in ('tex','pdf'):(self.root/('docs/proof_ledger.'+ext)).write_text((self.root/'docs/proof_ledger.md').read_text())
        self.c.command_log.side_effect=build
    def repair(self):return repaired_text(self.text,self.contracts,self.baseline,self.gate,self.state)
    def reject(self):self.assertRaises(ValueError,self.repair)
    def test_exact_g01_fixture(self):self.assertIn('G01 are **REVIEW_READY**',self.repair())
    def test_only_overview_changes(self):self.assertEqual(self.text.split('\n',1)[1],self.repair().split('\n',1)[1])
    def test_detail_disagreement(self):self.text=self.text.replace('**Status:** REVIEW_READY','**Status:** UNFORMALIZED');self.reject()
    def test_stale_green_never_grants(self):self.text=self.text.replace('G01, F02 are **UNFORMALIZED**','G01 is **GREEN**; F02 is **UNFORMALIZED**');self.reject()
    def test_unrelated_manifest_drift(self):self.contracts['theorems'][2]['status']='REVIEW_READY';self.reject()
    def test_multiple_mismatches(self):self.text=self.text.replace('F01 is **GREEN**','F01 is **UNFORMALIZED**');self.reject()
    def test_unauthorized_state(self):self.state['status']='READY_TO_EXECUTE';self.reject()
    def test_authorized_transition(self):self.assertNotEqual(self.text,self.repair())
    def test_semantic_contract_mutation(self):self.contracts['theorems'][1]['assumptions']=['extra'];self.reject()
    def test_lean_hashes_unchanged(self):
        before=(self.root/'G01.lean').read_bytes();reconcile(self.c,self.gate,self.state);self.assertEqual(before,(self.root/'G01.lean').read_bytes())
    def test_executor_one_medium_no_call(self):
        reconcile(self.c,self.gate,self.state);self.assertEqual(self.state['executor_history'],[{'model':'gpt-5.6-sol','reasoning_effort':'medium','outcome':'COMPLETED','invocation_number':1}]);self.c.model_run.assert_not_called()
    def test_revisions_zero(self):reconcile(self.c,self.gate,self.state);self.assertEqual(self.state['revisions'],0);self.c.authorize_executor_revision.assert_not_called()
    def test_no_review_during_repair(self):reconcile(self.c,self.gate,self.state);self.c.review_submission.assert_not_called();self.c.snapshot.assert_not_called()
    def test_global_json_consistent(self):
        reconcile(self.c,self.gate,self.state);v=overview(self.root,self.gate);self.assertEqual(v['contracts']['G01'],'REVIEW_READY');self.assertIn('G01 are **REVIEW_READY**',v['canonical_ledger_overview'])
    def test_regeneration_preserves_contract(self):
        before=(self.root/'contracts/theorems.json').read_bytes();reconcile(self.c,self.gate,self.state);self.assertEqual(before,(self.root/'contracts/theorems.json').read_bytes());self.c.command_log.assert_called_once()
    def test_unexpected_semantic_scope_fails_before_write(self):
        self.c._semantic_scope.side_effect=ValueError('scope');self.assertRaises(ValueError,reconcile,self.c,self.gate,self.state);self.assertEqual((self.root/'docs/proof_ledger.md').read_text(),self.text)
    def test_review_already_started(self):self.state['snapshot_sha256']='hash';self.reject()
    def test_duplicate_overview(self):self.text=self.text.split('\n')[0]+'\n'+self.text;self.reject()
    def test_green_inference_forbidden(self):self.contracts['theorems'][1]['status']='GREEN';self.reject()
    def test_missing_executor(self):self.state['executor_history']=[];self.reject()
    def test_idempotent(self):self.text=self.repair();self.assertEqual(self.text,self.repair())
