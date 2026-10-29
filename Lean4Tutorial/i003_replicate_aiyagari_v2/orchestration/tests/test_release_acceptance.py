import copy,json,sys,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'orchestration'))
from release_acceptance import validate_legacy,validate_modern,ALLOWED
POLICY=json.loads((ROOT/'orchestration/legacy_acceptance_policy.json').read_text())['gates']
class Legacy(unittest.TestCase):
 def args(self,g='M01'):
  p=copy.deepcopy(POLICY[g]);return [g,p,(ROOT/p['record']).read_text(),p['archive_sha256'],True,True]
 def test_m01(self):self.assertTrue(validate_legacy(*self.args('M01'))['release_eligible'])
 def test_m02a(self):self.assertTrue(validate_legacy(*self.args('M02A'))['release_eligible'])
 def test_m02b(self):self.assertTrue(validate_legacy(*self.args('M02B'))['release_eligible'])
 def test_m03a(self):self.assertTrue(validate_legacy(*self.args('M03A'))['release_eligible'])
 def test_confidence_null(self):self.assertIsNone(validate_legacy(*self.args())['confidence'])
 def test_human_flag_null(self):self.assertIsNone(validate_legacy(*self.args())['requires_human_review'])
 def fails(self,a):
  with self.assertRaises(ValueError):validate_legacy(*a)
 def test_missing_accept(self):
  a=self.args();a[2]=a[2].replace('Decision: ACCEPT','Decision: REVISE');self.fails(a)
 def test_archive_mismatch(self):
  a=self.args();a[3]='0'*64;self.fails(a)
 def test_missing_archive(self):
  a=self.args();a[3]=None;self.fails(a)
 def test_nonancestor(self):
  a=self.args();a[4]=False;self.fails(a)
 def test_missing_contract_ids(self):
  a=self.args();a[2]=a[2].replace('P02','other');self.fails(a)
 def test_build_only(self):
  a=self.args();a[2]='# external acceptance\nDecision: ACCEPT\nP01 P02 P03\nbuild passed';self.fails(a)
 def test_qualification_missing(self):
  a=self.args('M03A');a[2]=a[2].replace('zeroRightMarginal','placeholder');self.fails(a)
 def test_semantic_mismatch(self):
  a=self.args();a[5]=False;self.fails(a)
 def test_unlisted_gate(self):
  a=self.args();a[0]='M03B1';self.fails(a)
 def test_wrong_ids(self):
  a=self.args();a[1]['contracts']=['P01'];self.fails(a)
class Modern(unittest.TestCase):
 def verdict(self):return {'verdict':'PASS','confidence':'HIGH','requires_human_review':False,'snapshot_sha256':'final','blocking_findings':[],'contract_assessments':[{'adequate':True}]}
 def test_valid(self):self.assertTrue(validate_modern(self.verdict(),'final'))
 def fails(self,v):
  with self.assertRaises(ValueError):validate_modern(v,'final')
 def test_missing_high(self):
  v=self.verdict();v.pop('confidence');self.fails(v)
 def test_human_required(self):
  v=self.verdict();v['requires_human_review']=True;self.fails(v)
 def test_revise_block(self):
  for status in ['REVISE','BLOCK']:
   v=self.verdict();v['verdict']=status;self.fails(v)
 def test_e03_revision0_cannot_supersede_final(self):
  rec=json.loads((ROOT/'reviews/m10b3_acceptance.json').read_text());final=rec['reviewer_history'][rec['reviewer_history']['operative']]['verdict'];self.assertTrue(validate_modern(final,rec['snapshot_sha256']))
  old=copy.deepcopy(final);old.update(verdict='REVISE',snapshot_sha256='89eeb9f2863f0b87550f5414f0d04c6c3e99676693daf38cb31fa4103eff4d9d')
  with self.assertRaises(ValueError):validate_modern(old,rec['snapshot_sha256'])
if __name__=='__main__':unittest.main()
