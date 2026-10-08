"""Exact gate policy with synthetic Lean fingerprints; no model invocation."""
import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from context_shared import validate,preservation,eligible
from shared_imports import POLICIES,CLASSIFICATION,sha,canonical,import_graph
from orchestrate import Stop

class ContextSharedTests(unittest.TestCase):
 def setUp(self):
  self.p=copy.deepcopy(POLICIES['M09D1']);self.old=b'import Base\n\nnamespace Aiyagari1994\ntheorem every_equilibrium_rate_below_impatience : True := True.intro\nend Aiyagari1994\n'
  self.new=self.old.replace(b'\n',b'\nimport '+self.p['imports'][0].encode()+b'\n',1)+b'\nnamespace Aiyagari1994\ntheorem equilibrium_capital_above_certainty : True := True.intro\nend Aiyagari1994\n'
  b=[dict(name='Aiyagari1994.every_equilibrium_rate_below_impatience',kind='theorem',unsafe=False,partial=False,reducibility='opaque theorem',mutual_block=[],levels=[],type='True',value='True.intro',project_dependencies=['base'],axioms=['propext'])]
  a=copy.deepcopy(b)+[dict(b[0],name=self.p['new_declarations'][0])]
  self.art={'baseline_raw.json':b,'candidate_raw.json':a,'accepted_shared_declarations_baseline.json':copy.deepcopy(b),'accepted_shared_declarations_candidate.json':copy.deepcopy(b),'import_graph.json':{self.p['imports'][0]:[]}}
  self.ts={'theorems':[dict(id='G04',status='GREEN',module=self.p['module'],declaration=b[0]['name'],dependencies=[]),dict(id='G06',status='REVIEW_READY',module=self.p['module'],declaration=a[1]['name'],dependencies=['G04'])]};self.bt=copy.deepcopy(self.ts);self.bt['theorems'][1]['status']='UNFORMALIZED'
  compact=lambda xs:[{k:(sha(canonical(v)) if k in ('type','value','project_dependencies') else v) for k,v in x.items()} for x in xs]
  self.cert=dict(classification=CLASSIFICATION,result='PASS',module=self.p['module'],baseline_commit='base',input_sha256='key',source_sha256=sha(self.new),source_prefix_unchanged=True,authorized_imports=self.p['imports'],accepted_declarations=[b[0]['name']],baseline_fingerprints=compact(b),candidate_fingerprints=compact(b))
  self.state=dict(status='HUMAN_STOP',gate='M09D1',diagnostic='REVIEW_CONTEXT_INCOMPLETE: accepted implementation changed G04',attempt=1,revisions=0,executor_effort_index=0,executor_history=[dict(attempt=1,gate_id='M09D1',invocation_number=1,model='gpt-5.6-sol',outcome='COMPLETED',reason='INITIAL',reasoning_effort='medium',substantive_round=1)])
 def check(self):return validate(self.cert,self.p,'M09D1','base',self.old,self.new,self.art,self.ts,self.bt,self.art['import_graph.json'],'key')
 def bad(self):self.assertRaises(ValueError,self.check)
 def test_exact_g06_incident(self):self.assertFalse(self.new.startswith(self.old));self.assertEqual(len(self.check()),1)
 def test_gate_owned_append(self):self.check()
 def test_raw_unchanged(self):
  with tempfile.TemporaryDirectory() as d:
   c=Mock();c.root=Path(d);(c.root/'m').write_bytes(self.old);self.assertIsNone(preservation(c,{'module':'m'},'commit',self.old));c.status.assert_not_called()
 def test_missing_certificate(self):
  with tempfile.TemporaryDirectory() as d:
   c=Mock();c.root=Path(d);c.runtime=c.root;c.gates=[dict(id='M09D1')];c.status.return_value={'gate':'M09D1','baseline':'base'};c.tracked.return_value=False;c.git.return_value='';p=c.root/self.p['module'];p.parent.mkdir(parents=True);p.write_bytes(self.new)
   with patch('context_shared.certificate_location',return_value=('key',c.root/'missing')):self.assertRaises(Stop,preservation,c,{'module':self.p['module']},'commit',self.old)
   c.model_run.assert_not_called()
 def test_stale_candidate(self):self.cert['source_sha256']='stale';self.bad()
 def test_wrong_baseline(self):self.cert['baseline_commit']='wrong';self.bad()
 def test_wrong_baseline_input_hash(self):self.cert['input_sha256']='wrong';self.bad()
 def test_wrong_gate(self):self.assertRaises(ValueError,validate,self.cert,self.p,'M09D3','base',self.old,self.new,self.art,self.ts,self.bt,self.art['import_graph.json'],'key')
 def test_unauthorized_import(self):self.cert['authorized_imports']=['evil'];self.bad()
 def test_import_cycle(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d)/'Aiyagari1994';p.mkdir();(p/'X.lean').write_text('import Aiyagari1994.X\n');self.assertRaisesRegex(ValueError,'IMPORT_CYCLE',import_graph,d,['Aiyagari1994.X'])
 def test_source_body(self):self.new=self.new.replace(b': True',b': False',1);self.cert['source_sha256']=sha(self.new);self.bad()
 def mutate(self,k,v):self.art['candidate_raw.json'][0][k]=v;self.bad()
 def test_type(self):self.mutate('type','False')
 def test_value(self):self.mutate('value','different')
 def test_dependencies(self):self.mutate('project_dependencies',['new'])
 def test_axioms(self):self.mutate('axioms',['bad'])
 def test_levels(self):self.mutate('levels',['u'])
 def test_metadata(self):self.mutate('unsafe',True)
 def test_missing_accepted(self):self.cert['accepted_declarations']=[];self.bad()
 def test_removed_declaration(self):self.art['candidate_raw.json'].pop(0);self.bad()
 def test_partial_baseline(self):self.art['baseline_raw.json']=[];self.bad()
 def test_later_append(self):self.new=self.new.replace(b'theorem equilibrium_capital_above_certainty',b'theorem later');self.cert['source_sha256']=sha(self.new);self.bad()
 def test_arbitrary_header(self):self.new=b'open Foo\n'+self.new;self.cert['source_sha256']=sha(self.new);self.bad()
 def test_accepted_contract_mutation(self):self.ts['theorems'][0]['status']='REVIEW_READY';self.bad()
 def test_compact_tamper(self):self.cert['candidate_fingerprints']=[];self.bad()
 def test_same_medium(self):before=copy.deepcopy(self.state);eligible(self.state);self.assertEqual(before,self.state)
 def test_no_rerun(self):self.state['executor_history']*=2;self.assertRaises(ValueError,eligible,self.state)
 def test_no_revision(self):self.state['revisions']=1;self.assertRaises(ValueError,eligible,self.state)
 def test_no_review_yet(self):self.state['snapshot_sha256']='hash';self.assertRaises(ValueError,eligible,self.state)
 def test_no_high(self):self.state['executor_history'][0]['reasoning_effort']='high';self.assertRaises(ValueError,eligible,self.state)
 def test_snapshot_validation_before_model(self):
  from gate_context import validate_context
  c=Mock()
  with tempfile.TemporaryDirectory() as d:self.assertRaises(Exception,validate_context,Path(d),c,{'id':'M09D1'},'base')
  c.model_run.assert_not_called()
 def context_fixture(self,d):
  c=Mock();c.root=Path(d);c.runtime=c.root/'runtime';c.gates=[dict(id='M09D1')];c.status.return_value={'gate':'M09D1','baseline':'base'};c.tracked.return_value=False;c.git.return_value=''
  p=c.root/self.p['module'];p.parent.mkdir(parents=True);p.write_bytes(self.new);(c.root/'contracts').mkdir();(c.root/'contracts/theorems.json').write_text(json.dumps(self.ts));ev=c.root/'cert';ev.mkdir()
  cert=copy.deepcopy(self.cert);cert.update(evidence_directory=str(ev),artifacts={})
  for n,v in self.art.items():b=json.dumps(v).encode();(ev/n).write_bytes(b);cert['artifacts'][n]=sha(b)
  (ev/'certificate.json').write_text(json.dumps(cert));return c,ev,cert
 def get_context(self,c,ev,cert):
  def blob(args,**kwargs):return json.dumps(self.bt).encode() if args[-1].endswith('contracts/theorems.json') else self.old
  with patch('context_shared.certificate_location',return_value=('key',ev)),patch('context_shared.subprocess.check_output',side_effect=blob),patch('context_shared.import_graph',return_value=self.art['import_graph.json']),patch('context_shared.certify',return_value=cert):return preservation(c,dict(module=self.p['module'],declaration=self.cert['accepted_declarations'][0]),'accepted',self.old)
 def test_certified_context_evidence(self):
  with tempfile.TemporaryDirectory() as d:
   c,ev,cert=self.context_fixture(d);out=self.get_context(c,ev,cert);self.assertTrue(out['semantic_preservation_verified']);self.assertEqual(out['accepted_fingerprints'],cert['baseline_fingerprints']);self.assertEqual(out['acceptance_commit'],'accepted');self.assertEqual(out['authorized_imports'],self.p['imports']);c.model_run.assert_not_called()
 def test_context_no_false_byte_identity(self):
  with tempfile.TemporaryDirectory() as d:
   c,ev,cert=self.context_fixture(d);self.assertFalse(self.get_context(c,ev,cert)['whole_file_byte_identity'])
 def test_artifact_tamper(self):
  with tempfile.TemporaryDirectory() as d:
   c,ev,cert=self.context_fixture(d);(ev/'baseline_raw.json').write_text('[]');self.assertRaises(Stop,self.get_context,c,ev,cert)
 def test_math_bytes_unchanged(self):
  with tempfile.TemporaryDirectory() as d:
   c,ev,cert=self.context_fixture(d);before=sha((c.root/self.p['module']).read_bytes());self.get_context(c,ev,cert);self.assertEqual(before,sha((c.root/self.p['module']).read_bytes()))
