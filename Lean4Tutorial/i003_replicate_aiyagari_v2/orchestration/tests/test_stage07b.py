import sys,json,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage07b import Stage07bController,IDS,AUTHORITY
from stage07b_sources import resolve
from gate_context import ROUTES
class Stage07bTests(unittest.TestCase):
 def test_exact_gates(self):
  c=Stage07bController();self.assertEqual([(g['id'],g['contracts']) for g in c.gates[-3:]],[(f'M07B{i}',[f'N0{i+4}']) for i in range(1,4)]);self.assertEqual(c.gates[-4]['id'],'M07A4');self.assertEqual(c.checkpoint,'STAGE07B_COMPLETE_HUMAN_CHECKPOINT')
 def test_exact_dependencies(self):
  c=Stage07bController();ts={t['id']:t for t in json.loads((c.root/'contracts/theorems.json').read_text())['theorems']};self.assertEqual([ts[x]['dependencies'] for x in IDS],[[],['S01','N04','N05'],['N03','N06']])
 def test_new_gates_medium(self):
  c=Stage07bController()
  for g in c.gates[-3:]:
   state={'accepted':[x['id'] for x in c.gates[:c.gates.index(g)]],'gate':g['id'],'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(c.executor_plan(state)['reasoning_effort'],'medium')
 def test_no_stage08(self):
  c=Stage07bController();self.assertFalse(any(g['id'].startswith('M08') for g in c.gates));self.assertTrue(all(i in ROUTES for i in IDS))
 def test_source_locators(self):
  c=Stage07bController();cat={s['id']:s for s in json.loads((c.root/'contracts/source_manifest.json').read_text())['sources']};ts=[t for t in json.loads((c.root/'contracts/theorems.json').read_text())['theorems'] if t['id']=='N06'];self.assertEqual(resolve(c.root,cat,ts,'CW00')[0],set(range(4,19)));self.assertEqual(resolve(c.root,cat,ts,'A94')[0],{12});self.assertEqual(resolve(c.root,cat,ts,'A93')[0],set(range(12,24))|set(range(38,42)));self.assertRaises(ValueError,resolve,c.root,cat,ts,'UNKNOWN')
 def test_isolated_usage_runtime(self):
  c=Stage07bController();self.assertEqual(c.runtime,c.root/'tmp_orchestration/stage07b');self.assertEqual(c.usage_report_path(c.gates[-1]),'reports/stage07b_usage_metrics.json')
 def test_no_moment_and_ae_authority(self):
  self.assertIn('no household assumptions',AUTHORITY);self.assertIn('a.e. equality under pi.compProd(P^n)',AUTHORITY);self.assertIn('variance positivity proved',AUTHORITY)
