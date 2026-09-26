import sys,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import orchestrate as o
from gate_context import ContextBuilder,ROUTES,extract
from stage06_sources import resolve
class Stage06Tests(unittest.TestCase):
 def test_gates_and_medium(self):
  c=o.Controller();self.assertEqual([(g['id'],g['contracts']) for g in c.gates[-4:]],list(zip(['M06A','M06B','M06C','M06D'],[['S06'],['A01'],['A02'],['A03']])))
  a=[g['id'] for g in c.gates[:-4]]
  for g in c.gates[-4:]:
   self.assertEqual(c.executor_plan({'accepted':a,'gate':'previous','executor_history':[]})['reasoning_effort'],'medium');a.append(g['id'])
 def test_routes_and_sources(self):
  c=o.Controller();b=ContextBuilder(c)
  for cid in ('S06','A01','A02','A03'):
   h,p=ROUTES[cid];self.assertTrue(extract(c.root,'docs/architecture.md',heading=h)['text']);self.assertTrue(extract(c.root,'prompts/06_stationary_continuity_and_aggregation.md',heading=p)['text'])
   self.assertEqual(resolve(c.root,b.catalog,[b.by[cid]],'A93')[0],{40,41})
  self.assertEqual(resolve(c.root,b.catalog,[b.by['S06']],'SLP89')[0],{394,395})
  pages,notes,full=resolve(c.root,b.catalog,[b.by['A03']],'C90');self.assertTrue(full);self.assertEqual(len(pages),17)
 def test_failure_prevents_checkpoint(self):
  c=o.Controller();c.save=Mock()
  with patch('stage06.integration',side_effect=o.Stop('FAIL')):
   with self.assertRaises(o.Stop):c.finish_stage({})
  c.save.assert_not_called()
 def test_exact_dependencies(self):
  t={x['id']:x['dependencies'] for x in o.read_json(o.PROJECT/'contracts/theorems.json')['theorems']}
  self.assertEqual({k:t[k] for k in ('S06','A01','A02','A03')},{'S06':['H06','D03','S05'],'A01':['P01','S05'],'A02':['S05','A01'],'A03':['H06','D03','S06','A02']})
