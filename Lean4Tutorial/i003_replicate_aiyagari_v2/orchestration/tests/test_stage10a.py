import json,sys,unittest,copy
from pathlib import Path
from unittest.mock import patch,Mock
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage10a import Stage10aController,IDS,AUTHORITY
from stage10a_sources import resolve
from shared_imports import POLICIES,structure
from gate_context import ROUTES,extract
from review_evidence import required_sources
from context_shared import baseline_history
from orchestrate import Stop
class Stage10aTests(unittest.TestCase):
 def setUp(self):
  self.c=Stage10aController();self.ts={x['id']:x for x in json.loads((self.c.root/'contracts/theorems.json').read_text())['theorems']};self.cat={x['id']:x for x in json.loads((self.c.root/'contracts/source_manifest.json').read_text())['sources']}
 def test_gates(self):self.assertEqual([g['contracts'] for g in self.c.gates[-3:]],[[x] for x in IDS])
 def test_prior(self):self.assertEqual(len(self.c.gates),len(__import__('stage09d').Stage09dController().gates)+3)
 def test_reports(self):self.assertEqual([g['report'] for g in self.c.gates[-3:]],[f'reports/m10a{i}_milestone.md' for i in range(1,4)])
 def test_checkpoint(self):self.assertEqual(self.c.checkpoint,'STAGE10A_NOPONZI_HUMAN_CHECKPOINT')
 def test_deps(self):self.assertEqual([self.ts[x]['dependencies'] for x in IDS],[['P01'],['NP01'],['NP01']])
 def test_sources(self):
  for cid in IDS:
   for sid,pages in [('A93',{38}),('A94',{9})]:self.assertEqual(resolve(self.c.root,self.cat,[self.ts[cid]],sid)[0],pages)
 def test_source_union(self):
  for cid in IDS:self.assertEqual(set(required_sources(self.ts[cid],self.cat)),{'A93','A94'})
 def test_bad_source(self):self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts['NP01']],'SLP89')
 def test_later_source(self):self.assertRaises(ValueError,resolve,self.c.root,self.cat,[self.ts['E01']],'A94')
 def test_changed_locator(self):t=dict(self.ts['NP01'],source_locator='PDF 39');self.assertRaises(ValueError,resolve,self.c.root,self.cat,[t],'A93')
 def test_routes(self):
  for cid in IDS:
   a,b=ROUTES[cid];self.assertTrue(extract(self.c.root,'docs/architecture.md',heading=a));self.assertTrue(extract(self.c.root,'prompts/10_no_ponzi_and_exact_extensions.md',heading=b))
 def test_medium(self):
  for n,g in enumerate(self.c.gates[-3:]):
   s={'accepted':[x['id'] for x in self.c.gates[:len(self.c.gates)-3+n]],'gate':g['id'],'attempt':1,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]};self.assertEqual(self.c.executor_plan(s)['reasoning_effort'],'medium')
 def test_high(self):self.assertEqual(self.c.config['reviewer_reasoning'],'high');self.assertEqual(self.c.config['reviewer_policy_version'],1)
 def test_no_extensions(self):self.assertFalse(any(g['contracts']==[x] for g in self.c.gates for x in ['E01','E02','E03']))
 def test_policies(self):
  for gid,cid in [('M10A2','NP02'),('M10A3','NP03')]:p=POLICIES[gid];self.assertEqual(p['contract'],cid);self.assertEqual(p['new_declarations'],[self.ts[cid]['declaration']])
 def test_shared_delta(self):
  p=POLICIES['M10A3'];old=b'import Base\n\nnamespace Aiyagari1994\ntheorem old : True := by trivial\nend Aiyagari1994\n';new=('import '+p['imports'][0]+'\n').encode()+old+('\nnamespace Aiyagari1994\ntheorem '+p['new_declarations'][0].split('.')[-1]+' : True := by trivial\nend Aiyagari1994\n').encode();self.assertEqual(structure(old,new,p),p['imports'])
 def test_authority(self):
  for x in ['not zero','BEFORE','FINITE','NOT NP02','w*h/r','project reconstructions','E01/E02/E03']:self.assertIn(x,AUTHORITY)
 def test_prior_protection(self):
  with patch('stage10a.read_json',return_value={'protected_files':{'Aiyagari1994/Equilibrium/Saving.lean':'bad'}}):self.assertRaises(Stop,self.c.preserve)
 def test_metrics(self):self.assertEqual(self.c.usage_report_path(self.c.gates[-1]),'reports/stage10a_usage_metrics.json')
 def test_identical_baseline(self):self.assertEqual(baseline_history(Mock(),{},'accepted',b'old','base',b'old',[]),[])
 def test_uncertified_history_fails(self):
  c=Mock();c.gates=[];self.assertRaisesRegex(ValueError,'missing baseline',baseline_history,c,{'module':'m'},'accepted',b'old','base',b'new',[])
 def chain(self,raw):
  c=Mock();c.root=Path('/unused');c.gates=[{'id':'M10A2'}];c.tracked.return_value=True;c.git.return_value='commit';node={'baseline':b'old','candidate':b'new','candidate_raw':['accepted'],'certificate':{'baseline_commit':'prior'}}
  with patch('shared_provenance.load_node',return_value=node),patch('shared_provenance.validate_chain',return_value=['certified']) as valid,patch('context_shared.subprocess.run',return_value=Mock(returncode=0)):
   result=baseline_history(c,{'module':POLICIES['M10A2']['module']},'accept',b'old','base',b'new',raw);valid.assert_called_once();return result
 def test_np01_np02_np03_chain(self):self.assertEqual(self.chain(['accepted']),['certified'])
 def test_semantic_gap_fails(self):self.assertRaisesRegex(ValueError,'semantic chain gap',self.chain,['changed'])
