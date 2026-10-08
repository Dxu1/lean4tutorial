import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from shared_provenance import validate_chain,load_node,certify
from shared_imports import sha,structure,certify as dispatch

def fingerprint(name):
 return {'name':name,'kind':'theorem','unsafe':False,'partial':False,'reducibility':'opaque theorem','mutual_block':[name],'levels':[],'type':'exact type','value':'exact proof','project_dependencies':[],'axioms':['propext']}
class ProvenanceTests(unittest.TestCase):
 def setUp(self):
  self.base=b'import Mathlib\n\nnamespace Aiyagari1994\ntheorem old : True := by trivial\nend Aiyagari1994\n'
  self.p={'module':'Shared.lean','imports':['Aiyagari1994.Analysis.G05'],'new_declarations':['Aiyagari1994.new'],'contract':'G05'}
  self.candidate=b'import Aiyagari1994.Analysis.G05\n'+self.base+b'\nnamespace Aiyagari1994\ntheorem new : True := by trivial\nend Aiyagari1994\n'
  b=[fingerprint('Aiyagari1994.old')];a=b+[fingerprint('Aiyagari1994.new')]
  cert={'result':'PASS','module':'Shared.lean','source_sha256':sha(self.candidate),'authorized_imports':self.p['imports'],'baseline_commit':'B','artifacts':{}}
  self.n={'gate':'M09C4','policy':self.p,'certificate':cert,'baseline':self.base,'candidate':self.candidate,'baseline_sha256':sha(self.base),'reviewed_candidate_sha256':sha(self.candidate),'review_baseline':'R','acceptance_commit':'H','snapshot_sha256':'snapshot','baseline_raw':b,'candidate_raw':a,'baseline_accepted':copy.deepcopy(b),'candidate_accepted':copy.deepcopy(b),'contracts':{'theorems':[{'id':'G05','dependencies':[],'declaration':'Aiyagari1994.new'}]}}
  self.nodes=[self.n];self.current=self.candidate;self.changes=['H'];self.order=['B','R','H','B2','R2','H2','HEAD'];self.ancestor=lambda a,b:self.order.index(a)<=self.order.index(b)
 def check(self):return validate_chain(self.nodes,self.current,'HEAD',self.ancestor,self.changes)
 def reject(self):self.assertRaises((ValueError,KeyError),self.check)
 def test_exact_G05_incident(self):
  self.assertRaisesRegex(ValueError,'UNAUTHORIZED_OR_DUPLICATE_IMPORT',structure,self.current,self.current,self.p);self.assertEqual(self.check()[0]['baseline_commit'],'B')
 def test_pre_gate_baseline(self):self.assertEqual(self.check()[0]['review_baseline'],'R')
 def test_head_never_used_as_baseline(self):self.assertNotEqual(self.check()[0]['baseline_commit'],'HEAD')
 def test_authorized_import_not_duplicate(self):self.assertEqual(self.check()[0]['authorized_imports'],self.p['imports'])
 def test_missing_certificate(self):self.nodes=[];self.reject()
 def test_wrong_baseline_hash(self):self.n['baseline_sha256']='bad';self.reject()
 def test_wrong_candidate_hash(self):self.n['reviewed_candidate_sha256']='bad';self.reject()
 def test_proof_changed(self):self.n['candidate_raw'][0]=dict(self.n['candidate_raw'][0],value='changed');self.reject()
 def test_dependency_changed(self):self.n['candidate_raw'][0]=dict(self.n['candidate_raw'][0],project_dependencies=['other']);self.reject()
 def test_axiom_changed(self):self.n['candidate_raw'][0]=dict(self.n['candidate_raw'][0],axioms=['bad']);self.reject()
 def test_extra_import(self):self.current=b'import Unauthorized\n'+self.current;self.reject()
 def two(self):
  n=copy.deepcopy(self.n);n.update(gate='M_NEXT',baseline=self.candidate,baseline_sha256=sha(self.candidate),review_baseline='R2',acceptance_commit='H2')
  p=copy.deepcopy(self.p);p['imports']=['Aiyagari1994.Analysis.Next'];p['new_declarations']=['Aiyagari1994.next'];n['policy']=p
  candidate=b'import Aiyagari1994.Analysis.Next\n'+self.candidate+b'\nnamespace Aiyagari1994\ntheorem next : True := by trivial\nend Aiyagari1994\n'
  n.update(candidate=candidate,reviewed_candidate_sha256=sha(candidate),baseline_raw=copy.deepcopy(self.n['candidate_raw']))
  n['baseline_accepted']=sorted(copy.deepcopy(n['baseline_raw']),key=lambda x:x['name']);n['candidate_accepted']=copy.deepcopy(n['baseline_accepted']);n['candidate_raw']=copy.deepcopy(n['baseline_raw'])+[fingerprint('Aiyagari1994.next')]
  n['certificate'].update(baseline_commit='B2',source_sha256=sha(candidate),authorized_imports=p['imports'])
  self.nodes.append(n);self.changes.append('H2');self.current=candidate
 def test_two_sequential_extensions(self):self.two();self.assertEqual(len(self.check()),2)
 def test_missing_intermediate(self):self.two();self.nodes=self.nodes[1:];self.reject()
 def test_reordered(self):self.two();self.nodes.reverse();self.reject()
 def test_ancestry_mismatch(self):self.n['review_baseline']='HEAD';self.reject()
 def test_gap(self):self.two();self.nodes[1]['baseline']=b'other';self.reject()
 def test_fork(self):self.two();self.nodes[1]['gate']='M09C4';self.reject()
 def test_unknown_module_commit(self):self.changes=['H','unreviewed'];self.reject()
 def test_current_math_unchanged(self):before=self.current;self.check();self.assertEqual(before,self.current)
 def test_review_identity_unchanged(self):before=copy.deepcopy(self.n);self.check();self.assertEqual(before,self.n)
 def test_new_declaration_unauthorized(self):self.n['candidate_raw'].append(fingerprint('Aiyagari1994.bad'));self.reject()
 def test_failed_certificate(self):self.n['certificate']['result']='FAIL';self.reject()
 def test_fingerprint_chain_gap(self):
  self.two();self.nodes[1]['baseline_raw'][0]['value']='changed';self.reject()
 def test_extra_authorized_import_rejected(self):self.n['certificate']['authorized_imports']=['other'];self.reject()

class DispatchTests(unittest.TestCase):
 def test_active_gate_keeps_original_guard(self):
  with tempfile.TemporaryDirectory() as t:
   c=Mock();c.root=Path(t);c.status.return_value={'baseline':'active'};c.error=ValueError;c.git.return_value='project/'
   with patch('shared_provenance.certify') as accepted,patch('shared_imports.subprocess.check_output',side_effect=RuntimeError('original active guard')):
    self.assertRaisesRegex(RuntimeError,'original active guard',dispatch,c,{'id':'M09C4','module':'Aiyagari1994/Equilibrium/CertaintyBenchmark.lean'})
    accepted.assert_not_called();c.model_run.assert_not_called()
 def test_accepted_dispatch_never_selects_head(self):
  with tempfile.TemporaryDirectory() as t:
   c=Mock();c.root=Path(t);p=c.root/'reviews/m09c4_acceptance.json';p.parent.mkdir();p.write_text('{}');c.tracked.return_value=True
   with patch('shared_provenance.certify',return_value={'result':'PASS'}) as accepted:
    self.assertEqual(dispatch(c,{'id':'M09C4','module':'Aiyagari1994/Equilibrium/CertaintyBenchmark.lean'}),{'result':'PASS'});c.status.assert_not_called();c.model_run.assert_not_called();accepted.assert_called_once()
