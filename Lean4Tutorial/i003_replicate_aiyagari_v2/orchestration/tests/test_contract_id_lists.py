import copy,json,sys,unittest,hashlib
from pathlib import Path
from unittest.mock import Mock
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from contract_id_lists import parse_ids,prose_claims
from review_evidence import ledger_errors,STATUSES
from ledger_reconciliation import conjunction_eligible,resume_conjunction
ROOT=Path(__file__).resolve().parents[2]
class ContractListTests(unittest.TestCase):
 def setUp(self):self.ids={'E01','E02','E03'};self.ts=[{'id':x,'status':'UNFORMALIZED'} for x in sorted(self.ids)]
 def fixture(self,refs='E01, E02, E03',prose=''):
  return '**Economic status:** '+refs+' are **UNFORMALIZED**.\n'+''.join('## '+t['id']+' — fixture\n**Status:** '+t['status']+'.\n'+prose+'\n' for t in self.ts)
 def test_forms(self):
  for raw,expected in [('E02',['E02']),('E02, E03',['E02','E03']),('E02 and E03',['E02','E03']),('E02 & E03',['E02','E03']),('E01, E02, and E03',['E01','E02','E03']),('E01, E02 and E03',['E01','E02','E03'])]:
   with self.subTest(raw=raw):self.assertEqual(parse_ids(raw,self.ids),expected)
 def test_unknown(self):self.assertRaises(ValueError,parse_ids,'E02 and E99',self.ids)
 def test_malformed(self):
  for raw in ['',',E02','E02,','E02,,E03','E02 and','E02 or E03','E02 E03','E02 and E03, E01','E02; E03','E02 and and E03']:
   with self.subTest(raw=raw):self.assertRaises(ValueError,parse_ids,raw,self.ids)
 def test_duplicate(self):self.assertRaisesRegex(ValueError,'duplicate',parse_ids,'E02 and E02',self.ids)
 def test_arbitrary_prose(self):self.assertEqual(list(prose_claims('E02 proves X and preserves Y',self.ids,STATUSES)),[])
 def test_prose_list(self):self.assertEqual(list(prose_claims('E02 and E03 remain UNFORMALIZED.',self.ids,STATUSES)),[(['E02','E03'],'UNFORMALIZED')])
 def test_prose_unknown(self):self.assertTrue(ledger_errors(self.fixture(prose='E02 and E99 remain UNFORMALIZED.'),self.ts))
 def test_overview_unknown(self):self.assertTrue(ledger_errors(self.fixture('E01, E02 and E99'),self.ts))
 def test_overview_duplicate(self):self.assertTrue(ledger_errors(self.fixture('E01, E02, E02 and E03'),self.ts))
 def test_overview_empty(self):self.assertTrue(ledger_errors(self.fixture('E01,, E02 and E03'),self.ts))
 def test_status_mismatch(self):
  text=self.fixture(prose='E02 and E03 remain GREEN.');errors=ledger_errors(text,self.ts)
  self.assertIn('current prose E02 claims GREEN',errors);self.assertIn('current prose E03 claims GREEN',errors)
 def test_detail_mismatch(self):self.assertTrue(ledger_errors(self.fixture().replace('**Status:** UNFORMALIZED','**Status:** GREEN',1),self.ts))
 def test_manifest_disagreement(self):
  text=self.fixture();self.ts[0]['status']='GREEN';self.assertTrue(ledger_errors(text,self.ts))
 def test_historical(self):self.assertEqual(ledger_errors(self.fixture(prose='Historically, E02 and E03 remain GREEN.'),self.ts),[])
 def test_historical_not_next(self):self.assertTrue(ledger_errors(self.fixture(prose='Historically, E02 and E03 remain GREEN. E02 and E03 remain GREEN.'),self.ts))
 def receipt(self):
  p=ROOT/'tmp_orchestration/stage10b/ledger_parser_repair/receipt.json'
  if not p.exists():self.skipTest('local incident fixture absent')
  return json.loads(p.read_text())
 def test_exact_preserved_fixture(self):
  r=self.receipt();d=ROOT/'tmp_orchestration/stage10b/ledger_parser_repair';text=(d/'original_ledger.md').read_text();ts=json.loads((ROOT/'contracts/theorems.json').read_text())['theorems']
  # Freeze manifest status at this historical incident; later acceptance is legitimate.
  for t in ts:
   if t['id'] in self.ids:t['status']='REVIEW_READY' if t['id']=='E01' else 'UNFORMALIZED'
  self.assertIn('E02 and E03',text);self.assertEqual(ledger_errors(text,ts),[])
 def test_preserved_candidate(self):
  r=self.receipt()
  if (ROOT/'reviews/m10b1_acceptance.json').exists():self.skipTest('candidate subsequently independently accepted')
  for n,h in r['files'].items():
   if n.endswith('.lean'):self.assertEqual(hashlib.sha256((ROOT/n).read_bytes()).hexdigest(),h,n)
 def test_original_identity(self):
  r=self.receipt();self.assertTrue(conjunction_eligible(r['state']));self.assertEqual(r['state']['revisions'],0);self.assertEqual(r['state']['executor_history'][0]['reasoning_effort'],'medium')
 def test_wrong_identity(self):
  r=self.receipt()
  for k,v in [('revisions',1),('attempt',2),('snapshot_sha256','review'),('reviewer_verdict',{'verdict':'PASS'})]:
   s=copy.deepcopy(r['state']);s[k]=v;self.assertFalse(conjunction_eligible(s))
 def test_resume_has_no_model_dispatch(self):
  import inspect
  source=inspect.getsource(resume_conjunction)
  for forbidden in ['model_run(','review_submission(','authorize_executor_revision(']:self.assertNotIn(forbidden,source)
  self.assertIn("'POST_EXECUTOR_RECONCILED'",source)
 def test_verification_precedes_review(self):
  from orchestrate import Controller
  import inspect
  source=inspect.getsource(Controller.run)
  phase=source[source.index("if state['status']=='POST_EXECUTOR_RECONCILED':"):]
  self.assertLess(phase.index('self.checks('),phase.index('self.review_submission('))
