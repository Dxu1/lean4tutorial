import json,sys,unittest
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage09d import Stage09dController,IDS,AUTHORITY
from stage09d_sources import resolve,resolve_stage09
from gate_context import ROUTES,extract
from shared_imports import POLICIES,structure
from orchestrate import Stop
class Stage09dTests(unittest.TestCase):
 def setUp(self):
  self.c=Stage09dController();self.ts={t['id']:t for t in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={t['id']:t for t in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_exact_gates(self):self.assertEqual([g['contracts'] for g in self.c.gates[-3:]],[[i] for i in IDS])
 def test_prior_gates(self):self.assertEqual(len(self.c.gates),len(__import__('stage09c').Stage09cController().gates)+3)
 def test_checkpoint(self):self.assertEqual(self.c.checkpoint,'STAGE09_COMPLETE_HUMAN_CHECKPOINT')
 def test_dependencies(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[['F01','G04','G05'],['F01','G06'],['G01','F01']])
 def test_sources(self):
  for cid in IDS:self.assertEqual(resolve(self.c.root,self.cat,[self.ts[cid]],'A94')[0],{13,14})
 def test_source_rejections(self):
  for cid,sid in [('G06','A93'),('G05','A94'),('G08','UNKNOWN')]:self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts[cid]],sid)
 def test_prior_sources(self):self.assertEqual(resolve_stage09(self.c.root,self.cat,[self.ts['A04']],'A94')[0],{12,13,14});self.assertEqual(resolve_stage09(self.c.root,self.cat,[self.ts['G03']],'A94')[0],{15,16})
 def test_routes(self):
  for cid in IDS:
   a,b=ROUTES[cid];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=a)['text']);self.assertTrue(extract(self.c.root,'prompts/09_stationary_general_equilibrium.md',heading=b)['text'])
 def test_medium_new_gate(self):
  s={'accepted':[g['id'] for g in self.c.gates[:-3]],'gate':'M09D1','attempt':1,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium')
 def test_high_review(self):self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['reviewer_policy_version'],1)
 def test_shared_policies(self):
  for gate,cid in [('M09D1','G06'),('M09D3','G08')]:p=POLICIES[gate];self.assertEqual(p['contract'],cid);self.assertEqual(p['module'],self.ts[cid]['module']);self.assertEqual(p['new_declarations'],[self.ts[cid]['declaration']])
 def test_shared_structure(self):
  for gate in ['M09D1','M09D3']:
   p=POLICIES[gate];old=b'import Base\n\nnamespace Aiyagari1994\ntheorem old : True := by trivial\nend Aiyagari1994\n';new=('import '+p['imports'][0]+'\n').encode()+old+('\nnamespace Aiyagari1994\ntheorem '+p['new_declarations'][0].split('.')[-1]+' : True := by trivial\nend Aiyagari1994\n').encode();self.assertEqual(structure(old,new,p),p['imports']);self.assertRaises(ValueError,structure,old,new.replace(b'theorem old',b'theorem mutated'),p)
 def test_no_stage10(self):self.assertFalse(any(g['contracts']==[i] for g in self.c.gates for i in ['NP01','NP02','NP03','E01','E02','E03']))
 def test_authority(self):
  for x in ['EVERY','G01+F01','GROSS','integrability','Stage10','SAME complete immutable snapshot','status-neutral','No G02/G03'] :self.assertIn(x,AUTHORITY)
 def test_protection(self):
  with patch('stage09d.read_json',return_value={'protected_files':{'Aiyagari1994/Equilibrium/Definition.lean':'wrong'}}):self.assertRaises(Stop,self.c.preserve)
 def test_metrics(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage09d_usage_metrics.json')
