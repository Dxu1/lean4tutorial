import json,sys,unittest
from pathlib import Path
from unittest.mock import Mock
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import test_compact_context as fixtures
import gate_context as g
from global_status import overview
from a03_repair import RepairController
class GlobalStatusTests(unittest.TestCase):
    setUp=fixtures.ContextTests.setUp;put=fixtures.ContextTests.put;build=fixtures.ContextTests.build;rehash=fixtures.ContextTests.rehash;validate=fixtures.ContextTests.validate
    def test_snapshot_contains_overview(self):self.build();self.assertTrue((self.dest/'global_status_overview.json').exists())
    def test_exact_manifest_statuses(self):self.build();self.assertEqual(g.read(self.dest/'global_status_overview.json')['contracts'],{t['id']:t['status'] for t in g.read(self.root/'contracts/theorems.json')['theorems']})
    def test_ledger_consistency(self):self.build();self.assertEqual(g.read(self.dest/'global_status_overview.json')['global_consistency']['result'],'PASS')
    def test_a03_repair_statuses(self):
        ts=[{'id':x,'stage':'06','status':'REVIEW_READY' if x=='A03' else 'GREEN'} for x in ('S06','A01','A02','A03')]
        g.write(self.root/'contracts/theorems.json',{'theorems':ts});self.put('docs/proof_ledger.md','**Economic status:** S06, A01, A02 are **GREEN**; A03 is **REVIEW_READY**.\n'+''.join('\n## '+t['id']+' — test\n**Status:** '+t['status']+'.\n' for t in ts))
        self.assertEqual(overview(self.root,{'id':'M06DR','contracts':['A03']})['contracts']['A03'],'REVIEW_READY')
    def test_stale_overview_fails(self):
        p=self.root/'docs/proof_ledger.md';p.write_text(p.read_text().replace('H12 is **REVIEW_READY**','H12 is **GREEN**'));self.assertRaises(ValueError,self.build)
    def test_missing_overview_prevents_review(self):
        self.build();(self.dest/'global_status_overview.json').unlink();self.rehash();model=Mock()
        with self.assertRaises((ValueError,OSError)):
            self.validate();model()
        model.assert_not_called()
    def test_hash_mismatch_fails(self):
        self.build();p=self.dest/'global_status_overview.json';d=g.read(p);d['hashes']['proof_ledger_md']='0'*64;g.write(p,d);self.rehash();self.assertRaises(ValueError,self.validate)
    def test_future_stage_leakage(self):
        p=self.root/'contracts/theorems.json';d=g.read(p);d['theorems'][2]['stage']='07a';g.write(p,d);self.assertRaises(ValueError,self.build)
    def test_historical_prose_allowed(self):
        p=self.root/'docs/proof_ledger.md';p.write_text(p.read_text()+'\nHistorically, H11 is UNFORMALIZED.\n');self.build();self.assertEqual(self.validate(),'REVIEW_CONTEXT_COMPLETE')
    def test_gate_ledger_alone_insufficient(self):
        self.build();self.assertTrue((self.dest/'ledger.md').exists());(self.dest/'global_status_overview.json').unlink();self.rehash();self.assertRaises((ValueError,OSError),self.validate)
    def test_full_ledger_not_packaged(self):self.build();self.assertFalse((self.dest/'docs/proof_ledger.md').exists());self.assertNotIn('## H99',(self.dest/'ledger.md').read_text())
    def test_mathematics_unchanged(self):
        before={str(p):p.read_bytes() for p in self.root.rglob('*.lean')};self.build();self.assertEqual(before,{str(p):p.read_bytes() for p in self.root.rglob('*.lean')})
    def test_no_models_or_executor_revisions(self):
        self.build();self.c.model_run.assert_not_called();self.c.authorize_executor_revision.assert_not_called()
    def test_missing_tex_fails(self):
        (self.root/'docs/proof_ledger.tex').unlink();self.assertRaises(OSError,self.build)
    def test_accepted_prose_stale_fails(self):
        p=self.root/'docs/proof_ledger.md';p.write_text(p.read_text()+'\nH11 is REVIEW_READY.\n');self.assertRaises(ValueError,self.build)
    def test_review_ready_claim_green_fails(self):
        p=self.root/'docs/proof_ledger.md';p.write_text(p.read_text().replace('Exact proof.','This contract is GREEN.'));self.assertRaises(ValueError,self.build)
    def test_policy_unchanged(self):
        c=RepairController();self.assertEqual(c.config['reviewer_reasoning'],'high');self.assertEqual(c.config['reviewer_policy_version'],1);self.assertEqual(c.config['executor_reasoning_effort_sequence'],['medium','high','xhigh'])
    def test_registered_runtime_overview(self):
        from mechanical import MechanicalEvidence
        self.c.error=ValueError;m=MechanicalEvidence(self.c);root=self.root/'runtime_checks';d=root/'pre_review_001';d.mkdir(parents=True)
        (d/'process_records.json').write_text('{}');(d/'global_status_overview.json').write_text(json.dumps(overview(self.root,self.gate)))
        m.paths=Mock(return_value={'checks':root});m.validate_runtime(self.gate,1)
        (d/'unknown.json').write_text('{}');self.assertRaises(ValueError,m.validate_runtime,self.gate,1)
