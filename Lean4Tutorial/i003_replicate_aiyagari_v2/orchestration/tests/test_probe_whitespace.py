import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from probe_whitespace import compare,expected,normalize,registered,reconcile,producer

class ProbeTests(unittest.TestCase):
 def setUp(self):
  self.e={'path':'Probes/TestSignatures.lean','producer':'completed_executor_file_change','imports':['Aiyagari1994.Test','Mathlib.Util.AssertNoSorry'],'declarations':['Aiyagari1994.test']};self.good=expected(self.e)
 def bad(self,raw):self.assertRaises(ValueError,compare,raw,self.e)
 def test_exact_np03_fixture(self):
  root=Path(__file__).resolve().parents[2];e=json.loads((root/'orchestration/artifacts.json').read_text())['generated_probes']['M10A3'];raw=(root/'Probes/M10A3Signatures.lean').read_bytes();self.assertEqual(compare(raw,e),expected(e))
 def test_one_blank_eof(self):self.assertEqual(compare(self.good+b'\n',self.e),self.good)
 def test_multiple_blank_eof(self):self.assertEqual(compare(self.good+b'\n\n\n',self.e),self.good)
 def test_trailing_spaces(self):self.assertEqual(compare(self.good.replace(b'\n',b' \t\n'),self.e),self.good)
 def test_missing_final_newline(self):self.assertEqual(compare(self.good[:-1],self.e),self.good)
 def test_changed_theorem_name(self):self.bad(self.good.replace(b'Aiyagari1994.test',b'Aiyagari1994.other'))
 def test_changed_check_target(self):self.bad(self.good.replace(b'#check Aiyagari1994.test',b'#check Aiyagari1994.other'))
 def test_changed_axioms_target(self):self.bad(self.good.replace(b'#print axioms Aiyagari1994.test',b'#print axioms Aiyagari1994.other'))
 def test_changed_no_sorry_target(self):self.bad(self.good.replace(b'assert_no_sorry Aiyagari1994.test',b'assert_no_sorry Aiyagari1994.other'))
 def test_added_import(self):self.bad(b'import Foo\n'+self.good)
 def test_removed_import(self):self.bad(self.good.split(b'\n',1)[1])
 def test_added_declaration(self):self.bad(self.good+b'theorem other : True := True.intro\n')
 def test_comment_rejected(self):self.bad(self.good+b'-- meaningful comment\n')
 def test_strings_rejected(self):self.bad(self.good+b'#eval "text  "\n')
 def test_expression_whitespace_not_erased(self):self.bad(self.good.replace(b'#check ',b'#check  '))
 def test_crlf_fails_closed(self):self.bad(self.good.replace(b'\n',b'\r\n'))
 def test_leading_indent_significant(self):self.bad(b' '+self.good)
 def test_pure_comparison_does_not_mutate(self):before=copy.deepcopy(self.e);raw=self.good+b'\n';compare(raw,self.e);self.assertEqual(self.e,before);self.assertEqual(raw,self.good+b'\n')

class RuntimeTests(unittest.TestCase):
 def setUp(self):
  ProbeTests.setUp(self);self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.c=Mock();self.c.root=Path(self.tmp.name);self.c.o=self.c.root/'orchestration';self.c.o.mkdir();self.g={'id':'Test','signature_probe':self.e['path']};self.c.tracked.return_value=False
  (self.c.o/'artifacts.json').write_text(json.dumps({'generated_probes':{'Test':self.e}}))
  p=self.c.root/self.e['path'];p.parent.mkdir();p.write_bytes(self.good+b'\n');self.p=p
  self.d=self.c.root/'runtime/Test/attempt_001';self.d.mkdir(parents=True);self.c.attempt_directory.return_value=self.d
  self.h={'gate_id':'Test','outcome':'COMPLETED','attempt':1,'reasoning_effort':'medium','invocation_number':1}
  self.s={'attempt':1,'revisions':0,'executor_history':[self.h]}
  (self.d/'executor_invocation.json').write_text(json.dumps(self.h));self.ev={'type':'item.completed','item':{'id':'event','type':'file_change','status':'completed','changes':[{'path':str(p),'kind':'add'}]}}
  (self.d/'executor_events.jsonl').write_text(json.dumps(self.ev)+'\n')
 def test_registered_normalizes(self):self.assertEqual(reconcile(self.c,self.g,self.s)['result'],'PASS');self.assertEqual(self.p.read_bytes(),self.good)
 def test_unregistered_probe_no_lane(self):self.assertIsNone(reconcile(self.c,{'id':'Other'},self.s));self.assertEqual(self.p.read_bytes(),self.good+b'\n')
 def test_theorem_file_no_lane(self):
  self.g['signature_probe']='Aiyagari1994/Test.lean';self.assertRaises(ValueError,reconcile,self.c,self.g,self.s)
 def test_accepted_file_no_lane(self):self.c.tracked.return_value=True;self.assertRaises(ValueError,reconcile,self.c,self.g,self.s)
 def test_missing_producer_rejected(self):
  (self.d/'executor_events.jsonl').write_text('');self.assertRaises(ValueError,reconcile,self.c,self.g,self.s)
 def test_wrong_producer_gate(self):self.s['executor_history'][0]['gate_id']='Other';self.assertRaises(ValueError,reconcile,self.c,self.g,self.s)
 def test_incomplete_executor_rejected(self):self.s['executor_history'][0]['outcome']='STARTED';self.assertRaises(ValueError,reconcile,self.c,self.g,self.s)
 def test_invocation_metadata_mismatch(self):(self.d/'executor_invocation.json').write_text('{}');self.assertRaises(ValueError,reconcile,self.c,self.g,self.s)
 def test_math_hash_unchanged(self):
  p=self.c.root/'theorem.lean';p.write_bytes(b'theorem x : True := True.intro\n\n');before=p.read_bytes();reconcile(self.c,self.g,self.s);self.assertEqual(p.read_bytes(),before)
 def test_medium_one_call_unchanged(self):
  before=copy.deepcopy(self.s);reconcile(self.c,self.g,self.s);self.assertEqual(self.s,before);self.assertEqual(self.s['executor_history'][0]['invocation_number'],1)
 def test_zero_revision(self):reconcile(self.c,self.g,self.s);self.assertEqual(self.s['revisions'],0)
 def test_no_model_dispatch(self):reconcile(self.c,self.g,self.s);self.c.model_run.assert_not_called()
 def test_original_preserved(self):
  r=reconcile(self.c,self.g,self.s);self.assertEqual(Path(r['original']).read_bytes(),self.good+b'\n')
 def test_canonical_is_idempotent(self):
  reconcile(self.c,self.g,self.s);self.assertFalse(reconcile(self.c,self.g,self.s)['changed'])
