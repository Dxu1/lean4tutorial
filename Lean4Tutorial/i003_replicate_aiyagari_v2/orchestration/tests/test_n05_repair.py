"""Model-free N05 boundary and guarded repair regressions."""
import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from gate_context import signatures
from n05_repair import eligible,BASE,DIAGNOSTIC,verify,authorize
from orchestrate import Stop
N='Aiyagari1994.M07B1.TwoStringSpace'
F='Aiyagari1994.M07B1.twoStringDifference'
class Boundaries(unittest.TestCase):
 def test_exact_n05_fixture(self):
  text=(Path(__file__).parent/'fixtures/n05_signature.log').read_text();s=signatures(text,[N,F]);self.assertIn('Type u_1',s[N]);self.assertIn(N+' E n → ℝ',s[F])
 def test_reference(self):
  text=N+'.{u} (E : Type u) : Type u\n'+F+'.{u} :\n  '+N+' E n → ℝ';self.assertEqual(signatures(text,[N])[N],text.split('\n')[0])
 def test_duplicate(self):self.assertRaises(ValueError,signatures,N+' : Type\n'+N+' : Type',[N])
 def test_universes(self):self.assertIn('.{u, v}',signatures(N+'.{u, v} : Type',[N])[N])
 def test_multiline(self):
  text=N+'.{u}\n  (E : Type u)\n  : E → E';self.assertEqual(signatures(text,[N])[N],text)
 def test_binders(self):
  text=N+' {E : Type}\n  [MeasurableSpace E]\n  (x : E) : E';self.assertEqual(signatures(text,[N])[N],text)
 def test_wrong_name(self):self.assertRaises(ValueError,signatures,N+'_extra : Type',[N])
 def test_changed_type(self):self.assertNotEqual(signatures(N+' : True',[N]),signatures(N+' : False',[N]))
 def test_malformed(self):
  for text in (N+'.{u,} : Type',N+' :',N+' E n → ℝ'):
   self.assertRaises(ValueError,signatures,text,[N])
 def test_whitespace(self):
  text=N+' :\n  \n    E → E';self.assertEqual(signatures(text,[N])[N],text)
 def test_nested_namespace(self):
  text=N+' : Type\n'+F+' :\n  '+N+'\n    → Other.Namespace.Type';self.assertEqual(len(signatures(text,[N,F])),2)
 def test_no_drop(self):
  text=N+' : Type\n'+F+' :\n  '+N+' E n →\n    (x : E) → Other.Type x';self.assertTrue(signatures(text,[F])[F].endswith('Other.Type x'))
class Guards(unittest.TestCase):
 def state(self):return {'status':'HUMAN_STOP','gate':'M07B1','baseline':BASE,'diagnostic':DIAGNOSTIC,'attempt':1,'revisions':0,'executor_effort_index':0,'executor_history':[{'attempt':1,'gate_id':'M07B1','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}]}
 def test_medium_identity(self):
  s=self.state();old=copy.deepcopy(s);self.assertTrue(eligible(s));self.assertEqual(s,old)
  s['executor_history'][0]['reasoning_effort']='high';self.assertFalse(eligible(s))
 def test_extra_invocation_rejected(self):
  s=self.state();s['executor_history']*=2;self.assertFalse(eligible(s))
 def test_revision_rejected(self):
  s=self.state();s['revisions']=1;self.assertFalse(eligible(s))
 def test_context_failure_no_review(self):
  with tempfile.TemporaryDirectory() as t:
   c=Mock();c.runtime=Path(t);c.gates=[{'id':'M07B1'}];s=self.state();s['status']='N05_PARSER_RECONCILED';c.status.return_value=s;c.project_files.return_value={};c.attempt_directory.return_value=Path(t);c.check_directory.return_value=Path(t)/'checks';c.snapshot.side_effect=Stop('REVIEW_CONTEXT_INCOMPLETE')
   r={'unchanged_submission_hashes':{},'old_state':copy.deepcopy(s)}
   with patch('n05_repair.read_json',return_value=r):self.assertRaises(Stop,verify,c)
   c.model_run.assert_not_called();c.review_submission.assert_not_called();self.assertEqual(s['revisions'],0)
 def test_global_overview_still_required(self):
  from gate_context import validate_context
  import inspect
  self.assertIn('global_status_overview',inspect.getsource(validate_context))
 def test_coverage_needs_validation(self):
  c=Mock();c.runtime=Path('/unused');c.status.return_value=self.state()
  with patch('n05_repair.read_json',return_value={}):self.assertRaises(Stop,authorize,c)
  c.authorize_executor_revision.assert_not_called();c.model_run.assert_not_called()
