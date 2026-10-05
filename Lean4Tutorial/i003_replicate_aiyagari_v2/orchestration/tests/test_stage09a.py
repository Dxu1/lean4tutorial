"""Stage-09a policy/context wiring only; no model calls."""
import json,sys,unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage09a import Stage09aController,IDS,AUTHORITY
from gate_context import ContextBuilder,ROUTES,extract
from stage09a_sources import resolve
from orchestrate import Stop
class Stage09aTests(unittest.TestCase):
 def setUp(self):
  self.c=Stage09aController();self.ts={t['id']:t for t in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={s['id']:s for s in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_exact_gates(self):
  self.assertEqual([(g['id'],g['contracts']) for g in self.c.gates[-3:]],[('M09A1',['F01']),('M09A2',['G01']),('M09A3',['F02'])]);self.assertEqual(self.c.gates[-4]['id'],'M08C')
 def test_exact_dependencies(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[[],['P01','H05','S01','A01','F01'],['P02','A02','F01']])
 def test_new_gates_medium(self):
  for g in self.c.gates[-3:]:
   s={'accepted':[x['id'] for x in self.c.gates[:self.c.gates.index(g)]],'gate':g['id'],'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium')
 def test_isolation_checkpoint(self):
  self.assertEqual(self.c.runtime,self.c.root/'tmp_orchestration/stage09a');self.assertEqual(self.c.checkpoint,'STAGE09A_FOUNDATIONS_HUMAN_CHECKPOINT');self.assertEqual([g['id'] for g in self.c.gates if g['id'].startswith('M09')],['M09A1','M09A2','M09A3'])
 def test_usage(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage09a_usage_metrics.json')
 def test_routes_exist(self):
  for cid in IDS:
   heading,step=ROUTES[cid];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=heading)['text']);self.assertTrue(extract(self.c.root,'prompts/09_stationary_general_equilibrium.md',heading=step)['text'])
 def test_metadata_prompt(self):
  m=json.loads((self.c.root/'contracts/milestones.json').read_text());self.assertEqual(next(x for x in m['milestones'] if x['stage']=='09')['file'],'prompts/09_stationary_general_equilibrium.md')
 def test_sources(self):
  for cid in IDS:self.assertEqual(resolve(self.c.root,self.cat,[self.ts[cid]],'A94')[0],{13,14})
 def test_unknown_source_fails_closed(self):self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts['F01']],'UNKNOWN')
 def test_generic_route_and_no_moment_authority(self):
  for text in ['untruncated','global unique profit-maximizing','sqrt','No B02/B03','finite first moments','REVIEW_READY']:self.assertIn(text,AUTHORITY)
 def test_capacity_does_not_escalate(self):
  g=self.c.gates[-3];s={'accepted':[x['id'] for x in self.c.gates[:-3]],'gate':g['id'],'attempt':2,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[{'model':'gpt-5.6-sol','reasoning_effort':'medium','outcome':'INFRASTRUCTURE_FAILURE'}]}
  self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium');self.assertRaises(Stop,self.c.authorize_executor_revision,s,'DETERMINISTIC_REPAIR');self.assertEqual(s['revisions'],0)
 def test_inherited_review_policy(self):
  self.assertEqual(self.c.config['reviewer_model'],'gpt-6-astra');self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['max_revisions'],2)
 def test_accepted_hash_guard(self):
  with patch('stage09a.read_json',return_value={'protected_files':{'AGENTS.md':'bad'}}):self.assertRaises(Stop,self.c.preserve)
