"""Parser fixtures and mocked control flow only; no model calls."""
import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import patch,Mock
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from gate_context import signatures,signature_header
from signature_repair import eligible,BASE,DIAGNOSTIC
from stage07a import Stage07Controller
from orchestrate import Stop
NAME='Aiyagari1994.foo'
class SignatureTests(unittest.TestCase):
 def parse(self,s):return signatures(s,[NAME])[NAME]
 def test_bare(self):self.assertEqual(self.parse(NAME+' : True'),NAME+' : True')
 def test_one(self):self.assertEqual(signature_header(NAME+'.{u} : True',NAME)['universes'],['u'])
 def test_multiple(self):self.assertEqual(signature_header(NAME+'.{u,v} : True',NAME)['universes'],['u','v'])
 def test_spaces(self):self.assertEqual(signature_header(NAME+'.{u, v} : True',NAME)['universes'],['u','v'])
 def test_generated(self):self.assertEqual(signature_header(NAME+'.{u_1, u_2} : True',NAME)['universes'],['u_1','u_2'])
 def test_exact_base(self):self.assertEqual(signature_header(NAME+'.{u_1} : True',NAME)['base_name'],NAME)
 def test_multiline(self):
  x=NAME+'.{u_1} {X : Type u_1}\n  (x : X) : x = x';self.assertEqual(self.parse(x),x)
 def test_wrapped_name(self):self.assertEqual(self.parse(NAME+'.{u}\n  : True'),NAME+'.{u}\n  : True')
 def test_indented(self):
  x='  '+NAME+'.{u}\n    {X : Type u} : X → X\nOther.foo : True';self.assertEqual(self.parse(x),x.split('\nOther')[0])
 def test_same_indent_colon(self):self.assertEqual(self.parse(NAME+'.{u}\n: True'),NAME+'.{u}\n: True')
 def test_wrong_namespace(self):self.assertRaises(ValueError,self.parse,'Other.foo.{u} : True')
 def test_wrong_name(self):self.assertRaises(ValueError,self.parse,'Aiyagari1994.bar.{u} : True')
 def test_name_suffix(self):self.assertRaises(ValueError,self.parse,NAME+'_extra.{u} : True')
 def test_malformed(self):
  for suffix in ('.{}','.{u,}','.{,u}','.{u,,v}','.{u v}','.{u;bad}','.{u+1}','.{u}evil','.{u}.other'):
   with self.subTest(suffix=suffix):self.assertRaises(ValueError,self.parse,NAME+suffix+' : True')
 def test_unclosed(self):self.assertRaises(ValueError,self.parse,NAME+'.{u_1 : True')
 def test_arbitrary_suffix(self):self.assertRaises(ValueError,self.parse,NAME+'.other : True')
 def test_duplicate(self):self.assertRaises(ValueError,self.parse,NAME+' : True\n'+NAME+'.{u} : True')
 def test_truncated(self):self.assertRaises(ValueError,self.parse,NAME+'.{u}')
 def test_type_not_normalized(self):self.assertNotEqual(self.parse(NAME+'.{u} : True'),self.parse(NAME+'.{u} : False'))
 def test_exact_n02(self):
  p=Path(__file__).parent/'fixtures/n02_signature.log';n='Aiyagari1994.stationary_bounded_jensen_equality';v=signatures(p.read_text(),[n])[n];self.assertIn('.{u_1}',v);self.assertIn('γ = 1 ∧',v);self.assertIn('π.compProd P',v)
 def test_accepted_universe_fixtures(self):
  root=Path(__file__).resolve().parents[2]
  text=(root/'reports/logs/02b_acceptance/audit.log').read_text()
  for name in ('Aiyagari1994.compactMax','Aiyagari1994.compactMax_continuous'):
   self.assertIn('.{u_1, u_2}',signatures(text,[name])[name])
 def test_accepted_fixture_style(self):
  text='Aiyagari1994.foo (m : HouseholdModel)\n  (z : Resources) : True\n\'Aiyagari1994.foo\' depends on axioms: [propext]\n';self.assertEqual(self.parse(text),text.split("\n'")[0])
class ResumeTests(unittest.TestCase):
 def state(self):return {'status':'HUMAN_STOP','gate':'M07A2','diagnostic':DIAGNOSTIC,'baseline':BASE,'attempt':1,'revisions':0,'executor_effort_index':0,'acceptance_committed':False,'reviewer_verdict':None,'snapshot_sha256':None,'executor_history':[{'attempt':1,'gate_id':'M07A2','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}]}
 def test_identity(self):self.assertTrue(eligible(self.state()))
 def test_escalation_rejected(self):
  s=self.state();s['executor_history'][0]['reasoning_effort']='high';self.assertFalse(eligible(s))
 def test_extra_executor_rejected(self):
  s=self.state();s['executor_history']*=2;self.assertFalse(eligible(s))
 def test_revision_rejected(self):
  s=self.state();s['revisions']=1;self.assertFalse(eligible(s))
 def test_other_stop_rejected(self):
  s=self.state();s['diagnostic']='GENUINE_SIGNATURE_MISMATCH';self.assertFalse(eligible(s))
 def test_resume_checks_before_models(self):
  c=Stage07Controller();s=self.state();s.update(status='POST_EXECUTOR_RECONCILED',initial_files={'file':'hash'},owned_files={'file':'hash'},accepted=[g['id'] for g in c.gates[:c.gates.index(next(g for g in c.gates if g['id']=='M07A2'))]])
  with tempfile.TemporaryDirectory() as tmp:
   c.runtime=Path(tmp);c.mechanical=None
   with patch.object(c,'status',return_value=s),patch.object(c,'git',return_value=BASE),patch.object(c,'project_files',return_value={'file':'hash'}),patch.object(c,'frozen_scope'),patch.object(c,'save'),patch.object(c,'checks'),patch.object(c,'preflight'),patch.object(c,'snapshot',side_effect=ValueError('REVIEW_CONTEXT_INCOMPLETE: fixture')),patch.object(c,'model_run') as model,patch.object(c,'review_submission') as review:
    self.assertRaises(Stop,c.run);model.assert_not_called();review.assert_not_called();self.assertEqual(s['revisions'],0);self.assertEqual(len(s['executor_history']),1);self.assertEqual(s['executor_history'][0]['reasoning_effort'],'medium')
