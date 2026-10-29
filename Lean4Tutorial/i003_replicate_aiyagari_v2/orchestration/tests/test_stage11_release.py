import sys,unittest,copy,tempfile,json
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from stage11_release import clean,AREAS,check_snapshot,sha,canonical
class ReleaseReview(unittest.TestCase):
 def value(self):return dict(snapshot_sha256='x',verdict='PASS',confidence='HIGH',requires_human_review=False,blocking_findings=[],release_assessments=[dict(area=a,status='PASS') for a in AREAS])
 def test_clean(self):self.assertTrue(clean(self.value(),'x'))
 def test_hash(self):self.assertFalse(clean(self.value(),'other'))
 def test_confidence(self):
  v=self.value();v['confidence']='MEDIUM';self.assertFalse(clean(v,'x'))
 def test_human(self):
  v=self.value();v['requires_human_review']=True;self.assertFalse(clean(v,'x'))
 def test_blocker(self):
  v=self.value();v['blocking_findings']=['defect'];self.assertFalse(clean(v,'x'))
 def test_missing_area(self):
  v=self.value();v['release_assessments'].pop();self.assertFalse(clean(v,'x'))
 def test_area_failure(self):
  v=self.value();v['release_assessments'][0]['status']='FAIL';self.assertFalse(clean(v,'x'))
 def test_snapshot_tamper(self):
  with tempfile.TemporaryDirectory() as tmp:
   p=Path(tmp);(p/'evidence').write_text('one');m={'files':{'evidence':sha(b'one')}};(p/'snapshot_manifest.json').write_text(json.dumps(m));self.assertEqual(check_snapshot(p),sha(canonical(m)));(p/'evidence').write_text('two')
   with self.assertRaises(ValueError):check_snapshot(p)
 def test_nested_manifests_are_included(self):
  with tempfile.TemporaryDirectory() as tmp:
   p=Path(tmp);(p/'history').mkdir();(p/'history/snapshot_manifest.json').write_text('old');m={'files':{'history/snapshot_manifest.json':sha(b'old')}};(p/'snapshot_manifest.json').write_text(json.dumps(m));self.assertEqual(check_snapshot(p),sha(canonical(m)))
   (p/'history/snapshot_manifest.json').write_text('tampered')
   with self.assertRaises(ValueError):check_snapshot(p)
if __name__=='__main__':unittest.main()
