"""Stage-08 policy/context wiring only; no model calls."""
import json,sys,unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage08 import Stage08Controller,IDS,AUTHORITY
from gate_context import ContextBuilder,ROUTES,extract
from stage08_sources import resolve
from orchestrate import Stop
class Stage08Tests(unittest.TestCase):
 def setUp(self):
  self.c=Stage08Controller();self.ts={t['id']:t for t in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={s['id']:s for s in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_exact_gates(self):
  self.assertEqual([(g['id'],g['contracts']) for g in self.c.gates[-3:]],[('M08A',['B01']),('M08B',['B02']),('M08C',['B03'])]);self.assertEqual(self.c.gates[-4]['id'],'M07B3')
 def test_exact_dependencies(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[[],['H06','A02','B01','N07'],['D03','A02']])
 def test_new_gates_medium(self):
  for g in self.c.gates[-3:]:
   s={'accepted':[x['id'] for x in self.c.gates[:self.c.gates.index(g)]],'gate':g['id'],'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium')
 def test_isolation_checkpoint(self):
  self.assertEqual(self.c.runtime,self.c.root/'tmp_orchestration/stage08');self.assertEqual(self.c.checkpoint,'STAGE08_COMPLETE_HUMAN_CHECKPOINT');self.assertFalse(any(g['id'].startswith('M09') for g in self.c.gates))
 def test_usage(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage08_usage_metrics.json')
 def test_routes_exist(self):
  for cid in IDS:
   heading,step=ROUTES[cid];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=heading)['text']);self.assertTrue(extract(self.c.root,'prompts/08_asset_supply_boundaries.md',heading=step)['text'])
 def test_metadata_prompt(self):
  m=json.loads((self.c.root/'contracts/milestones.json').read_text());self.assertEqual(next(x for x in m['milestones'] if x['stage']=='08')['file'],'prompts/08_asset_supply_boundaries.md')
 def test_sources(self):
  expected=[('B01','SLP89',{394,395}),('B02','A94',{11,12}),('B02','C90',{6,7}),('B03','A94',{15,16}),('B03','C90',{6,7})]
  for cid,sid,pages in expected:self.assertEqual(resolve(self.c.root,self.cat,[self.ts[cid]],sid)[0],pages)
  self.assertEqual(resolve(self.c.root,self.cat,[self.ts['B03']],'A93')[0],set(range(12,24))|set(range(38,42)))
 def test_unknown_source_fails_closed(self):self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts['B01']],'UNKNOWN')
 def test_generic_route_and_no_moment_authority(self):
  for text in ['No household assumptions','compact/tail split','Prokhorov','OUTSIDE household','No B02/N07','REVIEW_READY']:self.assertIn(text,AUTHORITY)
 def test_capacity_does_not_escalate(self):
  g=self.c.gates[-3];s={'accepted':[x['id'] for x in self.c.gates[:-3]],'gate':g['id'],'attempt':2,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[{'model':'gpt-5.6-sol','reasoning_effort':'medium','outcome':'INFRASTRUCTURE_FAILURE'}]}
  self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium');self.assertRaises(Stop,self.c.authorize_executor_revision,s,'DETERMINISTIC_REPAIR');self.assertEqual(s['revisions'],0)
 def test_inherited_review_policy(self):
  self.assertEqual(self.c.config['reviewer_model'],'gpt-6-astra');self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['max_revisions'],2)
 def test_accepted_hash_guard(self):
  with patch('stage08.read_json',return_value={'protected_files':{'AGENTS.md':'bad'}}):self.assertRaises(Stop,self.c.preserve)
