import sys,unittest,json
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import orchestrate as o
from gate_context import ROUTES,extract
import stage05
class Stage05Tests(unittest.TestCase):
    def test_exact_gates(self):
        c=o.Controller();self.assertEqual([(g['id'],g['contracts']) for g in c.gates[-5:]],[(f'M05{x}',[f'S0{i}']) for i,x in enumerate('ABCDE',1)])
        self.assertFalse(any(g['id'].startswith('M06') for g in c.gates))
    def test_each_gate_medium(self):
        c=o.Controller();accepted=[g['id'] for g in c.gates[:-5]]
        for gate in c.gates[-5:]:
            self.assertEqual(c.executor_plan({'accepted':accepted,'gate':'previous','executor_history':[]})['reasoning_effort'],'medium');accepted.append(gate['id'])
    def test_routes_resolve(self):
        for cid in stage05.IDS:
            heading,prompt=ROUTES[cid];self.assertTrue(extract(o.PROJECT,'docs/architecture.md',heading=heading)['text']);self.assertTrue(extract(o.PROJECT,'prompts/05_kernel_mixing_and_stationarity.md',heading=prompt)['text'])
    def test_integration_failure_prevents_checkpoint(self):
        c=o.Controller();c.save=Mock()
        with patch('stage05.integration',side_effect=o.Stop('FAILED')):
            with self.assertRaises(o.Stop):c.finish_stage({})
        c.save.assert_not_called()
    def test_integration_precedes_checkpoint(self):
        c=o.Controller();calls=[];c.save=lambda *a:calls.append('checkpoint')
        with patch('stage05.integration',side_effect=lambda *a:calls.append('integration')):c.finish_stage({})
        self.assertEqual(calls,['integration','checkpoint'])
    def test_dependencies_exact(self):
        ts={t['id']:t['dependencies'] for t in o.read_json(o.PROJECT/'contracts/theorems.json')['theorems']}
        self.assertEqual({k:ts[k] for k in stage05.IDS},{'S01':['H04','H07'],'S02':['H04','H08','H12'],'S03':['D03','S01','S02'],'S04':[],'S05':['D03','S01','S03','S04']})
