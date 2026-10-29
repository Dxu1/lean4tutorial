"""Candidate/revision provenance tests with zero model invocations."""
import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from revision_probe import *
from signature_probe import template
from revision_probe_reconciliation import eligible,BASE
from orchestrate import Stop
ROOT=Path(__file__).resolve().parents[2]
class RevisionProbeTests(unittest.TestCase):
 def setUp(self):
  self.m=json.loads((ROOT/'orchestration/probe_manifests/m10b3_revision1.json').read_text());self.old=json.loads((ROOT/'orchestration/probe_manifests/m10b3_revision0.json').read_text());self.e=copy.deepcopy(self.old['template'])
  self.g={'id':'M10B3','contracts':['E03'],'module':'Aiyagari1994/Extensions/GovernmentDebt.lean','signature_probe':self.e['path']}
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
  needed=set(self.m['candidate_files'])|set(self.m['dependency_sources'])|{'contracts/assumptions.json','contracts/theorems.json','Audit.lean',self.e['path']}
  for n in needed:
   p=self.root/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((ROOT/n).read_bytes())
  self.c=Mock();self.c.root=self.root
 def valid(self,m=None,rev=1):return validate(self.c,self.g,self.e,m or self.m,rev)
 def bad(self,fn):self.assertRaises(ValueError,fn)
 def test_exact_revision1(self):t,out=self.valid();self.assertEqual(len(t['declarations']),95);self.assertEqual(out,(self.root/self.e['path']).read_bytes())
 def test_historical69(self):self.assertEqual(len(self.old['template']['declarations']),69);self.assertEqual(self.old['substantive_revision'],0);self.assertTrue(self.old['historical_only'])
 def test_stale_template(self):self.bad(lambda:compare((self.root/self.e['path']).read_bytes(),self.e))
 def test_changed_candidate_hash(self):self.m['candidate_sha256']='bad';self.bad(self.valid)
 def test_changed_source(self):p=self.root/self.g['module'];p.write_bytes(p.read_bytes()+b'\n');self.bad(self.valid)
 def test_revision0_invalid(self):self.bad(lambda:self.valid(rev=0))
 def test_revision2_invalid(self):self.bad(lambda:self.valid(rev=2))
 def test_missing_public(self):self.remove_audit('Aiyagari1994.naturalBound_governmentDebt_correspondence');self.bad(self.valid)
 def remove_audit(self,n):
  p=self.root/'Audit.lean';p.write_text('\n'.join(l for l in p.read_text().splitlines() if not l.endswith(' '+n))+'\n')
 def test_missing_old_target(self):self.remove_audit(self.e['declarations'][0]);self.bad(self.valid)
 def test_authorized_helper(self):self.assertTrue(any(x['name'].endswith('.taxedTransition_input_nonneg') for x in self.m['kernel_inventory']));self.valid()
 def test_foreign_owner(self):self.m['kernel_inventory'][0]['owner']='Aiyagari1994.Extensions.BorrowingCap';self.bad(self.valid)
 def test_future_owner(self):self.m['kernel_inventory'][0]['owner']='Aiyagari1994.Analysis.M11.Release';self.bad(self.valid)
 def test_unauthorized_dependency(self):
  ts=json.loads((self.root/'contracts/theorems.json').read_text())['theorems'];n=next(t['declaration'] for t in ts if t['id']=='S05');self.m['kernel_inventory'][0]['project_dependencies'].append(n);self.bad(self.valid)
 def test_duplicate_target(self):self.m['template']['declarations'].append(self.m['template']['declarations'][0]);self.bad(self.valid)
 def test_removed_axiom(self):p=self.root/self.e['path'];p.write_text(p.read_text().replace('#print axioms '+self.e['declarations'][0]+'\n','',1));self.bad(self.valid)
 def test_command_mode(self):p=self.root/self.e['path'];p.write_text(p.read_text().replace('#check ','#print ',1));self.bad(self.valid)
 def test_changed_option(self):p=self.root/self.e['path'];p.write_text(p.read_text().replace('width 72','width 100'));self.bad(self.valid)
 def test_width(self):self.assertIn(['set_option','format.width','72'],self.m['command_sequence']);self.valid()
 def test_binders(self):self.assertIn(['set_option','pp.funBinderTypes','true'],self.m['command_sequence']);self.valid()
 def test_unchanged_math_and_no_model(self):
  before=candidate(self.c,self.g);self.valid();self.assertEqual(before,candidate(self.c,self.g));self.c.model_run.assert_not_called()
 def test_contract_mutation(self):p=self.root/'contracts/theorems.json';d=json.loads(p.read_text());next(t for t in d['theorems'] if t['id']=='E03')['dependencies'].append('S05');p.write_text(json.dumps(d));self.bad(self.valid)
 def test_status_promotion_allowed(self):p=self.root/'contracts/theorems.json';d=json.loads(p.read_text());next(t for t in d['theorems'] if t['id']=='E03')['status']='GREEN';p.write_text(json.dumps(d));self.valid()
 def test_assumption_mutation(self):p=self.root/'contracts/assumptions.json';p.write_bytes(p.read_bytes()+b'\n');self.bad(self.valid)
 def test_dependency_changed(self):p=self.root/next(iter(self.m['dependency_sources']));p.write_bytes(p.read_bytes()+b'\n');self.bad(self.valid)
 def test_unknown_option(self):p=self.root/self.e['path'];p.write_text(p.read_text()+'set_option autoImplicit false\n');self.bad(self.valid)
 def test_extra_theorem(self):p=self.root/self.e['path'];p.write_text(p.read_text()+'theorem x : True := True.intro\n');self.bad(self.valid)
 def test_whitespace_separate(self):p=self.root/self.e['path'];p.write_bytes(p.read_bytes()+b'\n\n');t,out=self.valid();self.assertNotEqual(out,p.read_bytes());self.assertEqual(commands(out),commands(p.read_bytes()))
 def test_all26_classified(self):xs=[x for x in self.m['target_classifications'] if x['classification']!='retained'];self.assertEqual(len(xs),26);self.assertTrue(all(x['classification'] in 'ABC' and x['axiom_evidence_category']=='D' for x in xs))
 def test_registered_resolve(self):
  p=self.root/'manifest.json';p.write_text(json.dumps(self.m));self.e['candidate_manifests']=[dict(path='manifest.json',sha256=sha(p.read_bytes()),candidate_sha256=self.m['candidate_sha256'],substantive_revision=1)]
  self.assertEqual(resolve(self.c,self.g,self.e,{'revisions':1})[1],self.m)
 def test_unregistered_resolve(self):self.bad(lambda:resolve(self.c,self.g,self.e,{'revisions':1}))
 def state(self):
  return dict(status='HUMAN_STOP',gate='M10B3',baseline=BASE,diagnostic='NON_MECHANICAL_PROBE_CHANGE: probe command sequence differs',attempt=2,revisions=1,executor_effort_index=1,executor_history=[dict(attempt=i,gate_id='M10B3',invocation_number=i,model='gpt-5.6-sol',outcome='COMPLETED',reason=reason,reasoning_effort=effort,substantive_round=i) for i,effort,reason in [(1,'medium','INITIAL'),(2,'high','REVIEWER_REVISION')]],reviewer_verdict=dict(verdict='REVISE',confidence='HIGH',requires_human_review=False))
 def test_execution_identity_unchanged(self):s=self.state();before=copy.deepcopy(s);eligible(s);self.assertEqual(s,before)
 def test_extra_executor_rejected(self):s=self.state();s['executor_history'].append(s['executor_history'][-1]);self.assertRaises(Stop,eligible,s)
 def test_second_revision_rejected(self):s=self.state();s['revisions']=2;self.assertRaises(Stop,eligible,s)
 def test_wrong_review_authority(self):s=self.state();s['reviewer_verdict']['verdict']='PASS';self.assertRaises(Stop,eligible,s)
