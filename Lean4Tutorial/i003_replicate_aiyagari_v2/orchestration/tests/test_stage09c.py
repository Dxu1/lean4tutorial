"""Stage09c gates, authority and protected semantic evidence; no real model calls."""
import json,sys,unittest,copy
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage09c import Stage09cController,IDS,AUTHORITY
from stage09c_sources import resolve,resolve_stage09
from gate_context import ROUTES,extract
from shared_imports import POLICIES,structure,compare
from orchestrate import Stop
class Stage09cTests(unittest.TestCase):
 def setUp(self):
  self.c=Stage09cController();self.ts={t['id']:t for t in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={s['id']:s for s in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_exact_gates(self):self.assertEqual([(g['id'],g['contracts']) for g in self.c.gates[-4:]],[('M09C1',['A04']),('M09C2',['A05']),('M09C3',['G04']),('M09C4',['G05'])]);self.assertEqual(self.c.gates[-5]['id'],'M09B2')
 def test_dependencies(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[['H04','H10','H12','S02'],['P02','A02','A04','B02'],['N07','G01'],['P01','H05','F01']])
 def test_exact_exports(self):self.assertEqual([self.ts[x]['declaration'].split('.')[-1] for x in IDS],['certainty_stationary_assets_at_limit','risky_assets_above_certainty_near_impatience','every_equilibrium_rate_below_impatience','certainty_benchmark_verified'])
 def test_medium_resets(self):
  for g in self.c.gates[-4:]:
   s={'accepted':[x['id'] for x in self.c.gates[:self.c.gates.index(g)]],'gate':g['id'],'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium')
 def test_checkpoint(self):self.assertEqual(self.c.checkpoint,'STAGE09C_CERTAINTY_FOUNDATIONS_HUMAN_CHECKPOINT');self.assertEqual(self.c.runtime,self.c.root/'tmp_orchestration/stage09c')
 def test_usage(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage09c_usage_metrics.json')
 def test_routes(self):
  for cid in IDS:
   a,b=ROUTES[cid];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=a)['text']);self.assertTrue(extract(self.c.root,'prompts/09_stationary_general_equilibrium.md',heading=b)['text'])
 def test_a94_sources(self):
  for cid in IDS:self.assertEqual(resolve(self.c.root,self.cat,[self.ts[cid]],'A94')[0],{12,13,14} if cid.startswith('A') else {13,14})
 def test_a93_sources(self):
  for cid in ('A04','G04'):self.assertEqual(resolve(self.c.root,self.cat,[self.ts[cid]],'A93')[0],set(range(12,24))|set(range(38,42)))
 def test_sources_fail_closed(self):
  for cid,sid in [('A05','A93'),('G05','A93'),('G06','A94'),('A04','UNKNOWN')]:self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts[cid]],sid)
 def test_prior_resolvers_unchanged(self):
  for cid in ['F01','G01','F02','G02']:self.assertEqual(resolve_stage09(self.c.root,self.cat,[self.ts[cid]],'A94')[0],{13,14})
  self.assertEqual(resolve_stage09(self.c.root,self.cat,[self.ts['G03']],'A94')[0],{15,16})
 def test_review_policy(self):self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['reviewer_policy_version'],1);self.assertEqual(self.c.config['max_revisions'],2)
 def test_shared_policy(self):
  p=POLICIES['M09C4'];self.assertEqual(p['module'],self.ts['A04']['module']);self.assertEqual(p['new_declarations'],[self.ts['G05']['declaration']]);self.assertEqual(p['contract'],'G05')
 def test_shared_structural_guard(self):
  p=POLICIES['M09C4'];old=b'import Base\n\nnamespace Aiyagari1994\ntheorem certainty_stationary_assets_at_limit : True := True.intro\nend Aiyagari1994\n';extra=('import '+p['imports'][0]+'\n').encode();suffix=b'\nnamespace Aiyagari1994\ntheorem certainty_benchmark_verified : True := True.intro\nend Aiyagari1994\n';new=extra+old+suffix;self.assertEqual(structure(old,new,p),p['imports']);self.assertRaises(ValueError,structure,old,new.replace(b': True',b': False',1),p)
 def test_protected_g01(self):
  with patch('stage09c.read_json',return_value={'protected_files':{'Aiyagari1994/Analysis/M09A2/EquilibriumDefinition.lean':'bad'}}):self.assertRaises(Stop,self.c.preserve)
 def test_critical_proof_authority(self):
  for t in ['No IncomeNondegenerate','dominated convergence','actual risky mean','ANY StationaryEquilibrium','not Euler sufficiency','No Stage-10 No-Ponzi','no impatience/rate-upper-bound field']:self.assertIn(t,AUTHORITY)
 def test_no_later_gates(self):self.assertFalse(any(g['contracts']==[x] for g in self.c.gates for x in ('G06','G07','G08','NP01','NP02','NP03')))
 def test_capacity_no_escalation(self):
  s={'accepted':[x['id'] for x in self.c.gates[:-4]],'gate':'M09C1','attempt':2,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[{'model':'gpt-5.6-sol','reasoning_effort':'medium','outcome':'INFRASTRUCTURE_FAILURE'}]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium');self.assertRaises(Stop,self.c.authorize_executor_revision,s,'DETERMINISTIC_REPAIR');self.assertEqual(s['revisions'],0)
 def test_shared_file_does_not_authorize_deferred_declaration(self):
  import tempfile
  from unittest.mock import Mock
  with tempfile.TemporaryDirectory() as tmp:
   c=Mock();c.root=Path(tmp);p=c.root/'Shared.lean';p.write_text('theorem allowed : True := True.intro\n')
   ts=[dict(self.ts['G04'],module='Shared.lean'),dict(self.ts['G06'],module='Shared.lean')]
   with patch('stage09c.read_json',side_effect=[{'protected_files':{}},{'theorems':ts}]):Stage09cController.preserve(c)
   p.write_text('theorem '+self.ts['G06']['declaration'].split('.')[-1]+' : True := True.intro\n')
   with patch('stage09c.read_json',side_effect=[{'protected_files':{}},{'theorems':ts}]):self.assertRaisesRegex(Stop,'LATER_DECLARATION',Stage09cController.preserve,c)
 def test_g01_semantic_difference_fails_closed(self):
  import tempfile
  from unittest.mock import Mock
  from stage09c_semantics import certify_g01
  from orchestrate import canonical,digest
  with tempfile.TemporaryDirectory() as tmp:
   c=Mock();c.root=Path(tmp);c.runtime=c.root/'runtime';p=c.runtime/'g01_fingerprints/baseline.json';p.parent.mkdir(parents=True);p.write_text('[{"type":"original"}]');r=c.root/'reviews/stage09c_authorization.json';r.parent.mkdir();r.write_text(json.dumps({'G01_baseline_sha256':digest(canonical([{'type':'original'}]))}))
   with patch('stage09c_semantics.collect',return_value=[{'type':'changed'}]):self.assertRaisesRegex(Stop,'G01_ELABORATED',certify_g01,c,{'module':'Gate.lean'})
