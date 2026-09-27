import sys,json,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage07a import Stage07Controller,IDS,AUTHORITY
from stage07a_sources import resolve
from gate_context import ROUTES
class Stage07aTests(unittest.TestCase):
 def test_exact_gates(self):
  c=Stage07Controller();self.assertEqual([(g['id'],g['contracts']) for g in c.gates[-4:]],[(f'M07A{i}',[f'N0{i}']) for i in range(1,5)]);self.assertEqual(c.gates[-5]['id'],'M06DR');self.assertEqual(c.checkpoint,'STAGE07A_COMPLETE_HUMAN_CHECKPOINT')
 def test_exact_dependency_lists(self):
  c=Stage07Controller();ts={t['id']:t for t in json.load(open(c.root/'contracts/theorems.json'))['theorems']};self.assertEqual(ts['N01']['dependencies'],['H04','H08','H09','S01']);self.assertEqual(ts['N02']['dependencies'],[]);self.assertEqual(ts['N03']['dependencies'],['H09','S01','N01','N02']);self.assertEqual(ts['N04']['dependencies'],['H11','H09','N01','N02'])
 def test_medium_reset(self):
  c=Stage07Controller()
  for g in c.gates[-4:]:
   i=c.gates.index(g);state={'accepted':[x['id'] for x in c.gates[:i]],'gate':g['id'],'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(c.executor_plan(state)['reasoning_effort'],'medium')
 def test_no_later_dispatch(self):
  c=Stage07Controller();self.assertFalse(any(set(g['contracts'])&{'N05','N06','N07'} for g in c.gates));self.assertTrue(all(cid in ROUTES for cid in IDS))
 def test_sources_approved_sections(self):
  c=Stage07Controller();catalog={s['id']:s for s in json.load(open(c.root/'contracts/source_manifest.json'))['sources']};ts=[t for t in json.load(open(c.root/'contracts/theorems.json'))['theorems'] if t['id']=='N01'];self.assertEqual(resolve(c.root,catalog,ts,'CW00')[0],set(range(4,19)));self.assertEqual(resolve(c.root,catalog,ts,'A94')[0],{12});self.assertRaises(ValueError,resolve,c.root,catalog,ts,'UNKNOWN')
 def test_arbitrary_return_qualification(self):self.assertIn('arbitrary R>0',AUTHORITY);self.assertIn('zeroRightMarginal',AUTHORITY)
 def test_runtime_and_usage_separate(self):
  c=Stage07Controller();self.assertEqual(c.runtime,c.root/'tmp_orchestration/stage07a');self.assertEqual(c.usage_report_path(c.gates[-1]),'reports/stage07a_usage_metrics.json')
