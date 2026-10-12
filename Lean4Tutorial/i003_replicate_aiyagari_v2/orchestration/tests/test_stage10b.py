import json,sys,unittest,copy
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage10b import Stage10bController,IDS,AUTHORITY
from stage10b_sources import resolve,resolve_stage10
from gate_context import ROUTES,extract
from shared_imports import POLICIES,structure
from root_aggregators import REGISTRY,CONTRACTS,ACCEPTED_COUNTS,accepted_provenance
from orchestrate import Stop
class Stage10bTests(unittest.TestCase):
 def setUp(self):
  self.c=Stage10bController();self.ts={t['id']:t for t in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={t['id']:t for t in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_gates(self):self.assertEqual([g['contracts'] for g in self.c.gates[-3:]],[[x] for x in IDS])
 def test_six(self):self.assertEqual([g['contracts'] for g in self.c.gates[-6:]],[['NP01'],['NP02'],['NP03'],['E01'],['E02'],['E03']])
 def test_checkpoint(self):self.assertEqual(self.c.checkpoint,'STAGE10_COMPLETE_HUMAN_CHECKPOINT')
 def test_deps(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[['P02','H02','H04','S05','A02'],['P02','H02','H04','S05'],['P01','H05']])
 def test_sources(self):
  for x,pages in [('E01',{9,15,16}),('E02',{9,15,16}),('E03',{16,17})]:self.assertEqual(resolve(self.c.root,self.cat,[self.ts[x]],'A94')[0],pages)
 def test_scan_fallback(self):
  for x in IDS:
   pages,notes,full=resolve(self.c.root,self.cat,[self.ts[x]],'A93');self.assertEqual(pages,set(range(1,52)));self.assertTrue(full);self.assertIn('no invented',notes[0])
 def test_source_mutation(self):
  t=dict(self.ts['E02'],source_locator='wrong');self.assertRaises(ValueError,resolve,self.c.root,self.cat,[t],'A94')
 def test_wrong_source(self):self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts['E03']],'SLP89')
 def test_old_source(self):self.assertEqual(resolve_stage10(self.c.root,self.cat,[self.ts['NP01']],'A93')[0],{38})
 def test_routes(self):
  for x in IDS:
   a,b=ROUTES[x];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=a));self.assertTrue(extract(self.c.root,'prompts/10_no_ponzi_and_exact_extensions.md',heading=b))
 def test_medium(self):
  for g in self.c.gates[-3:]:self.assertEqual(self.c.executor_plan({'accepted':[x['id'] for x in self.c.gates[:self.c.gates.index(g)]],'gate':g['id'],'attempt':1,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]})['reasoning_effort'],'medium')
 def test_reviewer(self):self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['reviewer_model'],'gpt-6-astra')
 def test_shared(self):
  p=POLICIES['M10B2'];self.assertEqual(p['contract'],'E02');old=b'import Base\n';new=('import '+p['imports'][0]+'\n').encode()+old+b'\nnamespace Aiyagari1994\ntheorem caps_above_naturalLimit_equivalent : True := by trivial\nend Aiyagari1994\n';self.assertEqual(structure(old,new,p),p['imports'])
 def test_registry(self):
  for g,c,n in [('M10A1','NP01',51),('M10B1','E01',54),('M10B3','E03',56)]:self.assertIn(g,REGISTRY['All.lean']);self.assertEqual(CONTRACTS[g],c);self.assertEqual(ACCEPTED_COUNTS[g],n)
 def test_unregistered_e02_root(self):self.assertNotIn('M10B2',REGISTRY['All.lean'])
 def test_protected(self):
  with patch('stage10b.read_json',return_value={'protected_files':{'Aiyagari1994/Budget/NoPonzi.lean':'bad'}}):self.assertRaises(Stop,self.c.preserve)
 def test_authority(self):
  for text in ['NOT A02 or E01','NOT F01,G01-G08,S05,NP01-NP03','POSITIVE','SAME','D01-D20','Do NOT start the final release audit','REVIEW_CONTEXT_COMPLETE','only','x=a-d']:self.assertIn(text,AUTHORITY)
 def test_usage(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage10b_usage_metrics.json')
 def test_historical_aggregator(self):self.assertEqual(accepted_provenance(self.c)['result'],'PASS')
