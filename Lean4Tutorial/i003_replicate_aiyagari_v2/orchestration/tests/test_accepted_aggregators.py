import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import root_aggregators as a
import accepted_aggregators as post
from orchestrate import Stop,digest,canonical
ROOT=Path(__file__).resolve().parents[2]
class AcceptedAggregatorTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.r=Path(self.tmp.name)
  self.c=Mock();self.c.root=self.r;self.c.gates=[{'id':gid,'contracts':[a.CONTRACTS[gid]],'module':a.REGISTRY['All.lean'][gid][0].replace('.','/')+'.lean'} for gid in ('M10A1','M10B1','M10B3')]
  self.g=self.c.gates[-1];self.records={};self.blobs={};self.certs={};self.missing=set();self.ancestry_bad=False;self.extra_history=False
  old=b'import Aiyagari1994.Base\n';self.sources={'Aiyagari1994/Base.lean':b''}
  for i,g in enumerate(self.c.gates):
   gid=g['id'];new=old+('import '+a.REGISTRY['All.lean'][gid][0]+'\n').encode();base='baseline'+str(i);commit='accepted'+str(i)
   self.blobs[base+':All.lean']=old.decode();self.blobs[commit+':All.lean']=new.decode()
   d=self.r/'evidence'/gid;d.mkdir(parents=True);names=['old'+str(j) for j in range(a.ACCEPTED_COUNTS[gid])]
   fp=[{'name':n,'unsafe':False,'partial':False,'axioms':[],'type':'type','value':'proof'} for n in names]
   for n in ('baseline_fingerprints.json','candidate_fingerprints.json'):(d/n).write_text(json.dumps(fp))
   cert={'classification':a.CLASS,'result':'PASS','gate':gid,'contract':g['contracts'][0],'aggregator':'All.lean','baseline_commit':base,'baseline_sha256':digest(old),'candidate_sha256':digest(new),'accepted_declarations':names,'accepted_declaration_count':len(names),'baseline_fingerprints_sha256':digest(canonical(fp)),'candidate_fingerprints_sha256':digest(canonical(fp)),'evidence_directory':str(d),'artifacts':{n:digest((d/n).read_bytes()) for n in ('baseline_fingerprints.json','candidate_fingerprints.json')},**a.import_delta(old,new,a.REGISTRY['All.lean'][gid])}
   self.certs[gid]=cert;self.records[gid]={'accepted_commit_sha':commit,'evidence_directory':str(d)};self.publish(gid)
   self.sources[g['module']]=b'import Aiyagari1994.Base\n';old=new
  self.sources['All.lean']=old
  for n,b in self.sources.items():p=self.r/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
  self.c.tracked.side_effect=lambda n:n not in self.missing
  self.c.acceptance_record.side_effect=lambda g:self.records[g['id']]
  self.c.project_files.side_effect=lambda:{n:digest((self.r/n).read_bytes()) for n in self.sources}
  self.c.git.side_effect=self.git
 def publish(self,gid):
  d=Path(self.records[gid]['evidence_directory']);raw=canonical({'root_aggregator':self.certs[gid]});(d/'deterministic_summary.json').write_bytes(raw)
  manifest={'files':{'verification/deterministic_summary.json':digest(raw)}};(d/'snapshot_manifest.json').write_text(json.dumps(manifest));self.records[gid]['snapshot_sha256']=digest(canonical(manifest))
 def git(self,*args):
  if args==('rev-parse','--show-prefix'):return ''
  if args[0]=='merge-base':
   if self.ancestry_bad:raise Stop('ANCESTRY_MISMATCH')
   return ''
  if args[0]=='show':
   if args[1].startswith('HEAD:'):return self.sources[args[1][5:]].decode()
   return self.blobs[args[1]]
  if args[0]=='log':return '\n'.join([self.records[g['id']]['accepted_commit_sha'] for g in self.c.gates]+(['rogue'] if self.extra_history else []))
  raise AssertionError(args)
 def cert(self,g=None):return a.certify(self.c,g or self.g,force=True)
 def test_e03_already_contains_import(self):self.assertEqual(self.cert()['phase'],'POST_ACCEPTANCE')
 def test_accepted_certificate_consumed(self):self.assertEqual(len(self.cert()['accepted_chain']['chain']),3)
 def test_no_current_delta_detector(self):
  with patch.object(a,'inputs',side_effect=AssertionError('C to C')):self.cert()
 def test_historical_delta(self):x=self.certs['M10B3'];self.assertEqual(x['added_imports'],['Aiyagari1994.Extensions.GovernmentDebt'])
 def test_missing_e03(self):self.missing.add('reviews/m10b3_acceptance.json');self.assertRaises(Stop,post.certify,self.c,self.g)
 def test_wrong_baseline(self):self.certs['M10B3']['baseline_sha256']='bad';self.publish('M10B3');self.assertRaises(Stop,self.cert)
 def test_wrong_candidate(self):self.certs['M10B3']['candidate_sha256']='bad';self.publish('M10B3');self.assertRaises(Stop,self.cert)
 def test_ancestry(self):self.ancestry_bad=True;self.assertRaises(Stop,self.cert)
 def test_unauthorized_import(self):p=self.r/'All.lean';p.write_bytes(p.read_bytes()+b'import Evil\n');self.assertRaises(Stop,self.cert)
 def test_removed_import(self):p=self.r/'All.lean';p.write_bytes(p.read_bytes().replace(b'import Aiyagari1994.Base\n',b''));self.assertRaises(Stop,self.cert)
 def test_missing_link(self):self.missing.add('reviews/m10b1_acceptance.json');self.assertRaises(Stop,self.cert)
 def test_sequential_chain(self):self.assertEqual([x['certificate']['gate'] for x in self.cert()['accepted_chain']['chain']],['M10A1','M10B1','M10B3'])
 def test_old_gate_with_later_extension(self):self.assertEqual(self.cert(self.c.gates[0])['current_sha256'],self.certs['M10B3']['candidate_sha256'])
 def test_terminal_changed(self):p=self.r/'All.lean';p.write_bytes(p.read_bytes()+b'\n');self.assertRaises(Stop,self.cert)
 def test_active_candidate_strict(self):
  self.c.tracked.return_value=False;self.c.tracked.side_effect=None
  with patch.object(a,'inputs',side_effect=Stop('STRICT')) as x:self.assertRaisesRegex(Stop,'STRICT',self.cert);x.assert_called_once()
 def test_preexecutor_unchanged(self):
  self.c.tracked.return_value=False;self.c.tracked.side_effect=None
  with patch.object(a,'inputs',side_effect=Stop('NO_ACTIVE_DELTA')):self.assertRaisesRegex(Stop,'NO_ACTIVE_DELTA',self.cert)
 def test_no_model_calls(self):self.cert();self.c.model_run.assert_not_called();self.c.review_submission.assert_not_called()
 def test_record_unchanged(self):before=copy.deepcopy(self.records);self.cert();self.assertEqual(before,self.records)
 def test_sources_unchanged(self):before={n:(self.r/n).read_bytes() for n in self.sources};self.cert();self.assertEqual(before,{n:(self.r/n).read_bytes() for n in self.sources})
 def test_snapshot_hash(self):self.records['M10B3']['snapshot_sha256']='bad';self.assertRaises(Stop,self.cert)
 def test_unauthorized_history(self):self.extra_history=True;self.assertRaises(Stop,self.cert)
 def test_ordering(self):self.c.gates[0],self.c.gates[1]=self.c.gates[1],self.c.gates[0];self.assertRaises(Stop,self.cert)
 def test_artifact_hash(self):p=Path(self.certs['M10B3']['evidence_directory'])/'candidate_fingerprints.json';p.write_text('[]');self.assertRaises(Stop,self.cert)
 def test_future_semantic_reverse_import(self):
  n=self.g['module'];self.sources[n]=b'import All\n';(self.r/n).write_bytes(self.sources[n]);self.assertRaisesRegex(Stop,'REVERSE',self.cert)
 def test_cycle(self):
  n='Aiyagari1994/Base.lean';self.sources[n]=b'import Aiyagari1994.Base\n';(self.r/n).write_bytes(self.sources[n]);self.assertRaisesRegex(Stop,'CYCLE',self.cert)
 def test_wrong_gate(self):g=dict(self.g,contracts=['E02']);self.assertRaises(Stop,self.cert,g)
 def test_current_source_changed(self):p=self.r/self.g['module'];p.write_bytes(p.read_bytes()+b'\n');self.assertRaises(Stop,self.cert)
 def test_exact_live_incident_frozen(self):
  receipt=ROOT/'tmp_orchestration/stage10b/accepted_aggregator_repair/receipt.json'
  if not receipt.exists():self.skipTest('local incident evidence unavailable')
  d=json.loads(receipt.read_text());ts=json.loads((ROOT/'contracts/theorems.json').read_text())['theorems'];self.assertEqual(len(ts),57);self.assertTrue(all(t['status']=='GREEN' for t in ts))
  for n,h in d['files'].items():
   if n.endswith('.lean') or n.startswith(('reviews/','docs/proof_ledger','contracts/')):self.assertEqual(digest((ROOT/n).read_bytes()),h,n)
