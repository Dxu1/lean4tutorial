import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import root_aggregators as a
from orchestrate import Stop,digest,canonical
from gate_context import validate_aggregator_context
from shared_imports import structure,POLICIES
G={'id':'M10A1','contracts':['NP01'],'module':'Aiyagari1994/Budget/NoPonzi.lean'}
M='Aiyagari1994.Budget.NoPonzi'
OLD=b'import Aiyagari1994.A\nimport Aiyagari1994.B\n'
NEW=b'import Aiyagari1994.A\nimport Aiyagari1994.Budget.NoPonzi\nimport Aiyagari1994.B\n'
ROOT=Path(__file__).resolve().parents[2]
class AggregatorTests(unittest.TestCase):
 def delta(self,x=NEW,y=OLD):return a.import_delta(y,x,[M])
 def sources(self):return {'All.lean':NEW,'Aiyagari1994/A.lean':b'', 'Aiyagari1994/B.lean':b'',G['module']:b'import Aiyagari1994.A\n','Audit.lean':b'import All\n#check Nat'}
 def graph(self,s):return a.graph_check(s,{n:v for n,v in s.items() if n!=G['module']},G,[M])
 def test_exact_fixture(self):
  d=ROOT/'tmp_orchestration/stage10a/aggregator_repair'
  if not d.exists():self.skipTest('historical runtime fixture unavailable')
  v=a.import_delta((d/'accepted_All.lean').read_bytes(),(d/'candidate_All.lean').read_bytes(),[M]);self.assertEqual(v['added_imports'],[M]);self.assertEqual(v['candidate_imports'][3],M)
 def test_authorized_terminal(self):self.assertTrue(self.graph(self.sources())['terminal_semantic_root'])
 def test_inserted_header(self):self.assertEqual(self.delta()['added_imports'],[M])
 def test_order(self):self.assertTrue(self.delta()['relative_order_preserved'])
 def test_removed(self):self.assertRaisesRegex(Stop,'REMOVED',self.delta,NEW.replace(b'import Aiyagari1994.B\n',b''))
 def test_reordered(self):self.assertRaisesRegex(Stop,'REORDERED',self.delta,b'import Aiyagari1994.B\nimport Aiyagari1994.A\nimport '+M.encode()+b'\n')
 def test_unauthorized(self):self.assertRaisesRegex(Stop,'UNAUTHORIZED',self.delta,NEW+b'import Evil\n')
 def test_duplicate(self):self.assertRaisesRegex(Stop,'DUPLICATE',self.delta,NEW+b'import Aiyagari1994.A\n')
 def test_cycle(self):
  s=self.sources();s['Probes.Cycle.lean']=b'import Probes.Cycle\n';self.assertRaisesRegex(Stop,'CYCLE',self.graph,s)
 def test_future(self):
  s=self.sources();s[G['module']]=b'import Aiyagari1994.Future\n';s['Aiyagari1994/Future.lean']=b'';base={n:v for n,v in s.items() if n not in (G['module'],'Aiyagari1994/Future.lean')};self.assertRaisesRegex(Stop,'FUTURE',a.graph_check,s,base,G,[M])
 def test_nonimport(self):self.assertRaisesRegex(Stop,'NOT_PURE',self.delta,NEW+b'open Nat\n')
 def test_theorem_ineligible(self):self.assertRaisesRegex(Stop,'NOT_PURE',a.pure_imports,OLD+b'theorem x : True := by trivial\n')
 def test_active_commands(self):
  for cmd in ('def','lemma','instance','abbrev','structure','class','axiom','opaque','notation','macro','namespace','#eval'):
   with self.subTest(cmd=cmd):self.assertRaises(Stop,a.pure_imports,OLD+cmd.encode()+b' x\n')
 def test_reverse(self):
  s=self.sources();s['Aiyagari1994/A.lean']=b'import All\n';self.assertRaisesRegex(Stop,'REVERSE',self.graph,s)
 def test_indirect_reverse(self):
  s=self.sources();s['Aiyagari1994/A.lean']=b'import Audit\n';self.assertRaisesRegex(Stop,'REVERSE',self.graph,s)
 def test_comment_boundaries(self):self.assertEqual(a.source_imports(b'import/- nested /- x -/ -/All\n'),['All'])
 def test_comments(self):self.assertEqual(a.pure_imports(b'/- doc -/\n'+OLD+b'-- end\n'),a.pure_imports(OLD))
 def test_comments_do_not_hide_commands(self):self.assertRaises(Stop,a.pure_imports,OLD+b'/-x-/theorem x : True := by trivial\n')
 def make_cert(self,tmp):
  records=[{'name':'old','type':'type','value':'proof','project_dependencies':['old'],'axioms':['propext'],'unsafe':False,'partial':False}]
  c=Mock();c.runtime=Path(tmp);d=c.runtime/'aggregator_certificates/key';d.mkdir(parents=True)
  for n in ('baseline_fingerprints.json','candidate_fingerprints.json'):(d/n).write_text(json.dumps(records))
  expected={'aggregator':'All.lean','input_sha256':'key','gate':'M10A1','candidate_sha256':digest(NEW),'added_imports':[M]}
  cert={**expected,'evidence_directory':str(d),'accepted_declaration_count':1,'accepted_declarations':['old'],'baseline_fingerprints_sha256':digest(canonical(records)),'candidate_fingerprints_sha256':digest(canonical(records)),'artifacts':{n:digest((d/n).read_bytes()) for n in ('baseline_fingerprints.json','candidate_fingerprints.json')}}
  return c,cert,expected,records
 def cert_case(self,mutate=lambda v:None):
  with tempfile.TemporaryDirectory() as tmp:
   c,v,e,rs=self.make_cert(tmp);mutate(v)
   with patch.object(a,'inputs',return_value=(e,OLD,['old'])):return a.validate(c,G,v)
 def test_valid_certificate(self):self.assertEqual(self.cert_case()['gate'],'M10A1')
 def test_stale_candidate(self):self.assertRaisesRegex(Stop,'STALE',self.cert_case,lambda v:v.update(candidate_sha256='changed'))
 def test_wrong_gate(self):self.assertRaisesRegex(Stop,'WRONG',self.cert_case,lambda v:v.update(gate='M10A2'))
 def test_unlisted_import(self):self.assertRaisesRegex(Stop,'STALE',self.cert_case,lambda v:v.update(added_imports=[]))
 def test_semantic_change(self):
  b=[{'name':'old','type':'A'}];self.assertRaisesRegex(Stop,'SEMANTICS',a.compare_fingerprints,b,[{'name':'old','type':'B'}],['old'])
 def test_context_accepts(self):
  with patch.object(a,'validate',return_value={'result':'PASS'}) as v:validate_aggregator_context(Mock(),G,{'checks':{'root_aggregator':{}},'root_aggregator':{'result':'PASS'}});v.assert_called_once()
 def test_context_missing(self):self.assertRaises(ValueError,validate_aggregator_context,Mock(),G,{'checks':{}})
 def test_context_bad(self):
  with patch.object(a,'validate',side_effect=Stop('STALE')):self.assertRaises(Stop,validate_aggregator_context,Mock(),G,{'checks':{'root_aggregator':{}},'root_aggregator':{}})
 def test_shared_path(self):
  p=POLICIES['M10A2'];b=b'import Base\n';n=('import '+p['imports'][0]+'\n').encode()+b+b'\nnamespace Aiyagari1994\ntheorem naturalBound_implies_noPonzi : True := by trivial\nend Aiyagari1994\n';self.assertEqual(structure(b,n,p),p['imports'])
 def state(self):return {'status':'HUMAN_STOP','gate':'M10A1','diagnostic':'ACCEPTED_LEAN_CHANGED: All.lean','attempt':1,'revisions':0,'executor_effort_index':0,'executor_history':[{'attempt':1,'gate_id':'M10A1','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}]}
 def test_invocation_one_medium(self):a.eligible(self.state())
 def test_no_executor_rerun(self):
  s=self.state();s['executor_history']*=2;self.assertRaises(Stop,a.eligible,s)
 def test_no_escalation(self):
  s=self.state();s['executor_history'][0]['reasoning_effort']='high';self.assertRaises(Stop,a.eligible,s)
 def test_zero_revisions(self):
  s=self.state();s['revisions']=1;self.assertRaises(Stop,a.eligible,s)
 def test_no_review_before_reconcile(self):
  s=self.state();s['reviewer_verdict']={'verdict':'PASS'};self.assertRaises(Stop,a.eligible,s)
 def test_availability_separate(self):
  from usage import ledger
  with tempfile.TemporaryDirectory() as tmp:
   c=Mock();c.runtime=Path(tmp);c.root=Path(tmp);c.config={'stage_checkpoint':'STAGE10A_NOPONZI_HUMAN_CHECKPOINT'};c.gates=[G];p=c.runtime/'usage/PREFLIGHT';p.mkdir(parents=True);(p/'reviewer_high_001.json').write_text('{}');self.assertEqual(ledger(c)['gates'],[])
 def test_preserved_math(self):
  p=ROOT/'tmp_orchestration/stage10a/aggregator_repair/receipt.json'
  if not p.exists():self.skipTest('historical receipt unavailable')
  if (ROOT/'reviews/m10a1_acceptance.json').exists():self.skipTest('submission legitimately promoted after review')
  for n,h in json.loads(p.read_text())['files'].items():
   if n.endswith('.lean') or n in ('docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf','contracts/theorems.json'):self.assertEqual(digest((ROOT/n).read_bytes()),h,n)
 def test_nonregistered(self):
  c=Mock();self.assertRaisesRegex(Stop,'UNREGISTERED',a.inputs,c,G,'Other.lean')

 def test_appended_authorized(self):self.assertEqual(self.delta(OLD+b'import '+M.encode()+b'\n')['added_imports'],[M])
 def test_appended_unauthorized(self):self.assertRaises(Stop,self.delta,OLD+b'import Evil\n')
 def test_semantic_fields(self):
  b=[{'name':'old','type':'A','value':'proof','levels':['u'],'metadata':'opaque','project_dependencies':['old'],'axioms':[],'unsafe':False,'partial':False}]
  for k in ('value','levels','metadata','project_dependencies','axioms'):
   after=copy.deepcopy(b);after[0][k]='changed'
   with self.subTest(field=k):self.assertRaisesRegex(Stop,'SEMANTICS',a.compare_fingerprints,b,after,['old'])
 def test_context_validation_precedes_review(self):
  c=Mock()
  with patch.object(a,'validate',side_effect=Stop('invalid')):
   with self.assertRaises(Stop):validate_aggregator_context(c,G,{'checks':{'root_aggregator':{}},'root_aggregator':{}})
  c.model_run.assert_not_called()
