"""Stage09b isolation and compact source wiring. No real model calls."""
import json,sys,unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage09b import Stage09bController,IDS,AUTHORITY
from gate_context import ROUTES,extract
from stage09b_sources import resolve,resolve_stage09
from orchestrate import Stop
class Stage09bTests(unittest.TestCase):
 def setUp(self):
  self.c=Stage09bController();self.ts={t['id']:t for t in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={s['id']:s for s in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_exact_gates(self):self.assertEqual([(g['id'],g['contracts']) for g in self.c.gates[-2:]],[('M09B1',['G02']),('M09B2',['G03'])]);self.assertEqual(self.c.gates[-3]['id'],'M09A3')
 def test_exact_dependencies(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[['P02','A03','B02','F02','G01'],['P02','A03','B02','B03','F01','G01']])
 def test_medium_resets(self):
  for g in self.c.gates[-2:]:
   s={'accepted':[x['id'] for x in self.c.gates[:self.c.gates.index(g)]],'gate':g['id'],'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium')
 def test_checkpoint(self):self.assertEqual(self.c.checkpoint,'STAGE09B_EXISTENCE_HUMAN_CHECKPOINT');self.assertEqual(self.c.runtime,self.c.root/'tmp_orchestration/stage09b')
 def test_usage(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage09b_usage_metrics.json')
 def test_routes(self):
  for cid in IDS:
   heading,step=ROUTES[cid];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=heading)['text']);self.assertTrue(extract(self.c.root,'prompts/09_stationary_general_equilibrium.md',heading=step)['text'])
 def test_g02_source(self):self.assertEqual(resolve(self.c.root,self.cat,[self.ts['G02']],'A94')[0],{13,14})
 def test_g03_source(self):self.assertEqual(resolve(self.c.root,self.cat,[self.ts['G03']],'A94')[0],{15,16})
 def test_g03_structured_a93(self):self.assertEqual(resolve(self.c.root,self.cat,[self.ts['G03']],'A93')[0],set(range(12,24))|set(range(38,42)))
 def test_source_fail_closed(self):
  for cid,sid in [('G02','A93'),('G03','UNKNOWN'),('G04','A94')]:self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts[cid]],sid)
 def test_stage09a_unchanged_sources(self):
  for cid in ['F01','G01','F02']:self.assertEqual(resolve_stage09(self.c.root,self.cat,[self.ts[cid]],'A94')[0],{13,14})
 def test_capacity_no_escalation(self):
  s={'accepted':[x['id'] for x in self.c.gates[:-2]],'gate':'M09B1','attempt':2,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[{'model':'gpt-5.6-sol','reasoning_effort':'medium','outcome':'INFRASTRUCTURE_FAILURE'}]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium');self.assertRaises(Stop,self.c.authorize_executor_revision,s,'DETERMINISTIC_REPAIR');self.assertEqual(s['revisions'],0)
 def test_review_policy(self):self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['reviewer_policy_version'],1);self.assertEqual(self.c.config['max_revisions'],2)
 def test_preserve_g01_hash(self):
  with patch('stage09b.read_json',return_value={'protected_files':{'Aiyagari1994/Analysis/M09A2/EquilibriumDefinition.lean':'bad'}}):self.assertRaises(Stop,self.c.preserve)
 def test_shared_module(self):self.assertEqual(self.c.gates[-2]['module'],self.c.gates[-1]['module']);self.assertIn('preserve G02 byte-for-byte',AUTHORITY)
 def test_non_circular_full_witness(self):
  for text in ['actual accepted G01 StationaryEquilibrium','stationaryAssetSupply_joint_continuous','K(r)->K(lambda)','No F02/G02 negative-rate bracket','never evaluated at zero','Preserve G01','No A04/A05/G04-G08']:self.assertIn(text,AUTHORITY)
