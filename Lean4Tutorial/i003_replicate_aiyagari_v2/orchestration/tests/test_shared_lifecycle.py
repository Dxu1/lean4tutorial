"""Lifecycle evidence is explicit, immutable and independent of status labels."""
import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from shared_lifecycle import phase,record_candidate,accepted_baseline,context_preflight,eligible_repair
from shared_imports import POLICIES,sha,compare
from context_shared import preservation
from orchestrate import Stop

class LifecycleTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup)
  self.c=Mock();self.c.root=Path(self.tmp.name);self.c.runtime=self.c.root/'runtime'
  self.g={'id':'M10A3'};self.prev={'id':'M10A2'};self.c.gates=[self.prev,self.g]
  self.p=POLICIES[self.g['id']];self.m=self.c.root/self.p['module'];self.m.parent.mkdir(parents=True)
  self.old=b'import NP01\n';self.accepted=b'import NP02\n'+self.old;self.m.write_bytes(self.accepted)
  self.s={'gate':'M10A3','baseline':'NP02_ACCEPTED','status':'HUMAN_STOP','attempt':1,'revisions':0,'executor_effort_index':0,'executor_history':[]}
  self.c.status.return_value=self.s;self.c.git.return_value=''
  self.c.tracked.side_effect=lambda n:n=='reviews/m10a2_acceptance.json'
  self.d=self.c.runtime/'runs/M10A3/attempt_001';self.d.mkdir(parents=True)
  self.c.attempt_directory.side_effect=lambda g,n:self.c.runtime/'runs'/g['id']/f'attempt_{n:03d}'
  self.bp=patch('shared_lifecycle.blob',return_value=self.accepted);self.bp.start();self.addCleanup(self.bp.stop)
  self.cert={'source_sha256':sha(self.accepted),'provenance_chain':[{'gate':'M10A2','baseline_commit':'NP01','acceptance_commit':'NP02'}],'candidate_fingerprints':['NP01','NP02'],'authorized_imports':POLICIES['M10A2']['imports']}
 def check(self):return phase(self.c,self.g,self.s)
 def bad(self):self.assertRaises((ValueError,OSError,KeyError),self.check)
 def candidate(self):
  h={'gate_id':'M10A3','outcome':'COMPLETED','attempt':1,'invocation_number':1,'reasoning_effort':'medium','substantive_round':1}
  self.s['executor_history']=[h];(self.d/'executor_invocation.json').write_text(json.dumps(h));(self.d/'executor_final.md').write_text('REVIEW_READY')
  self.m.write_bytes(self.accepted+b'candidate\n')
  helper=self.c.root/(self.p['imports'][0].replace('.','/')+'.lean');helper.parent.mkdir(parents=True);helper.write_text('helper')
  record_candidate(self.c,self.g,self.s,self.d)
 def accepted_check(self,cert=None):
  with patch('shared_provenance.certify',return_value=cert or self.cert) as fn:
   result=accepted_baseline(self.c,self.g,self.s,self.p['module'],self.m.read_bytes())
   fn.assert_called_once_with(self.c,self.prev);return result
 def accepted_direct(self):return accepted_baseline(self.c,self.g,self.s,self.p['module'],self.m.read_bytes())
 def context(self):
  with patch('shared_provenance.certify',return_value=self.cert),patch('context_shared.subprocess.check_output',return_value=self.old):
   return preservation(self.c,{'module':self.p['module'],'declaration':'NP01'},'NP01',self.old)
 def test_exact_np03_predispatch_incident(self):
  e=self.context();self.assertEqual(e['lifecycle'],'PRE_EXECUTOR');self.assertTrue(e['semantic_preservation_verified'])
 def test_latest_accepted_certificate(self):self.assertEqual(self.accepted_check(),self.cert)
 def test_np02_valid_baseline(self):self.assertEqual(self.check(),'PRE_EXECUTOR')
 def test_missing_predecessor(self):
  self.c.tracked.return_value=False;self.c.tracked.side_effect=None;self.assertRaises(ValueError,self.accepted_check)
 def test_wrong_accepted_hash(self):
  cert=copy.deepcopy(self.cert);cert['source_sha256']='wrong';self.assertRaises(ValueError,self.accepted_check,cert)
 def test_broken_chain_propagates(self):
  with patch('shared_provenance.certify',side_effect=ValueError('broken chain')):self.assertRaises(ValueError,self.accepted_direct)
 def test_empty_attempt_not_candidate(self):self.assertEqual(self.check(),'PRE_EXECUTOR')
 def test_reserved_directory_not_invocation(self):
  (self.d/'reservation.json').write_text('{}');self.check();self.assertEqual(self.s['executor_history'],[])
 def test_no_future_certificate_required(self):
  with patch('context_shared.certificate_location',side_effect=AssertionError('future cert')):self.context()
 def test_completed_materialized_recorded_candidate(self):self.candidate();self.assertEqual(self.check(),'POST_EXECUTOR')
 def test_post_executor_missing_certificate(self):
  self.candidate()
  with patch('context_shared.certificate_location',return_value=('key',self.c.root/'missing')):
   self.assertRaisesRegex(Stop,'missing current certificate',self.context)
 def test_post_acceptance_is_distinct(self):
  self.c.tracked.side_effect=lambda n:True;self.assertEqual(self.check(),'POST_ACCEPTANCE')
 def test_wrong_predecessor_selection(self):
  cert=copy.deepcopy(self.cert);cert['provenance_chain'][0]['gate']='M10A1';self.assertRaises(ValueError,self.accepted_check,cert)
 def test_future_acceptance_rejected(self):
  self.c.gates=[self.g,self.prev];self.assertRaises(ValueError,self.accepted_check)
 def test_stale_candidate_hash(self):self.candidate();self.m.write_bytes(b'changed');self.bad()
 def test_stale_helper_hash(self):
  self.candidate();(self.c.root/(self.p['imports'][0].replace('.','/')+'.lean')).write_text('changed');self.bad()
 def test_predispatch_semantic_change(self):self.m.write_bytes(b'changed');self.bad()
 def test_predispatch_helper_leak(self):
  h=self.c.root/'Aiyagari1994/Analysis/M10A3/Other.lean';h.parent.mkdir(parents=True);h.write_text('leak');self.bad()
 def test_zero_calls_in_repair(self):self.context();self.c.model_run.assert_not_called();self.assertEqual(self.s['executor_history'],[])
 def test_zero_revisions_in_repair(self):
  before=copy.deepcopy(self.s);self.context();self.assertEqual(self.s,before);self.assertEqual(self.s['revisions'],0)
 def test_math_hashes_preserved(self):
  before=sha(self.m.read_bytes());self.context();self.assertEqual(sha(self.m.read_bytes()),before)
 def test_unrecorded_runtime_invocation(self):(self.d/'executor_invocation.json').write_text('{}');self.bad()
 def test_unrecorded_runtime_final(self):(self.d/'executor_final.md').write_text('done');self.bad()
 def test_unrecorded_candidate_receipt(self):(self.d/'shared_candidate.json').write_text('{}');self.bad()
 def test_status_cannot_fake_candidate(self):
  self.s['status']='REVIEW_READY';self.assertEqual(self.check(),'PRE_EXECUTOR')
 def test_status_cannot_hide_candidate(self):
  self.candidate();self.s['status']='READY_TO_EXECUTE';self.assertEqual(self.check(),'POST_EXECUTOR')
 def test_incomplete_invocation(self):self.s['executor_history']=[{'gate_id':'M10A3','outcome':'STARTED'}];self.bad()
 def test_missing_candidate_receipt(self):self.candidate();(self.d/'shared_candidate.json').unlink();self.bad()
 def test_invocation_state_mismatch(self):self.candidate();(self.d/'executor_invocation.json').write_text('{}');self.bad()
 def test_completion_hash_mismatch(self):self.candidate();(self.d/'executor_final.md').write_text('changed');self.bad()
 def test_candidate_baseline_mismatch(self):
  self.candidate();r=json.loads((self.d/'shared_candidate.json').read_text());r['baseline']='wrong';(self.d/'shared_candidate.json').write_text(json.dumps(r));self.bad()
 def test_missing_candidate_helpers(self):
  self.candidate();(self.c.root/(self.p['imports'][0].replace('.','/')+'.lean')).unlink();self.bad()
 def test_no_change_completion_rejected(self):
  self.candidate();self.m.write_bytes(self.accepted);record_candidate(self.c,self.g,self.s,self.d);self.bad()
 def test_generic_gate_not_hardcoded(self):
  p=copy.deepcopy(self.p);p['imports']=['Aiyagari1994.Analysis.Future.Proof']
  with patch.dict(POLICIES,{'Future':p}):
   self.g={'id':'Future'};self.s['gate']='Future';self.assertEqual(self.check(),'PRE_EXECUTOR')
 def test_context_preflight_validates_accepted_even_if_prefix_fastpath(self):
  with patch('shared_provenance.certify',return_value=self.cert) as f:
   self.assertEqual(context_preflight(self.c,self.g,self.s),'PRE_EXECUTOR');f.assert_called_once()
 def test_non_shared_gate_is_unchanged(self):
  self.assertIsNone(context_preflight(self.c,{'id':'Other'},self.s))
 def test_formal_np03_manifest_np01_only(self):
  root=Path(__file__).resolve().parents[2];ts=json.loads((root/'contracts/theorems.json').read_text())['theorems'];t=next(t for t in ts if t['id']=='NP03');self.assertEqual(t['dependencies'],['NP01'])
 def test_np02_dependency_rejected(self):
  from test_shared_provenance import fingerprint
  base=[fingerprint('NP01'),fingerprint('NP02')];new=fingerprint(self.p['new_declarations'][0]);new['project_dependencies']=['NP02']
  ts={'theorems':[{'id':'NP01','declaration':'NP01','dependencies':[]},{'id':'NP02','declaration':'NP02','dependencies':['NP01']},{'id':'NP03','declaration':new['name'],'dependencies':['NP01']}]}
  self.assertRaisesRegex(ValueError,'UNAUTHORIZED_DEPENDENCY: NP02',compare,base,base+[new],self.p,ts)

class RepairGuards(unittest.TestCase):
 def setUp(self):self.s=dict(status='HUMAN_STOP',gate='M10A3',diagnostic='REVIEW_CONTEXT_INCOMPLETE: shared certificate missing current certificate',attempt=1,revisions=0,executor_effort_index=0,executor_history=[])
 def test_exact_stop_eligible(self):eligible_repair(self.s)
 def test_no_other_incident(self):self.s['diagnostic']='proof failure';self.assertRaises(ValueError,eligible_repair,self.s)
 def test_no_prior_execution(self):self.s['executor_history']=[{}];self.assertRaises(ValueError,eligible_repair,self.s)
 def test_no_revision_consumed(self):self.s['revisions']=1;self.assertRaises(ValueError,eligible_repair,self.s)
 def test_no_effort_escalation(self):self.s['executor_effort_index']=1;self.assertRaises(ValueError,eligible_repair,self.s)
 def test_no_reviewer_rerun(self):self.s['snapshot_sha256']='reviewed';self.assertRaises(ValueError,eligible_repair,self.s)
