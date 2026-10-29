"""Structural release acceptance compatibility. Does not authenticate reviewers or prove adequacy."""
import hashlib,json,re,subprocess,zipfile
from pathlib import Path

CLASSIFICATION='LEGACY_EXTERNAL_ACCEPTANCE_SCHEMA_COMPATIBILITY'
ALLOWED={'M01': ['P01','P02','P03'],'M02A':['H01','H02','H03','H04'],'M02B':['H05'],'M03A':['H07','H08']}
QUALIFICATIONS={'M01':['H01-H04 may use BASIC','No-Ponzi','consistency'], 'M02A':['no CoreRegularity','impatience','finite-state'], 'M02B':['No literal infinite-product','full-history','absolutely convergent'], 'M03A':['rightMarginalValue m 0','zeroRightMarginal','Every later argument']}
def sha(b):return hashlib.sha256(b).hexdigest()
def canonical(x):return json.dumps(x,sort_keys=True,separators=(',',':')).encode()
def need(ok,msg):
 if not ok:raise ValueError('RELEASE_ACCEPTANCE: '+msg)
def git(root,*args):return subprocess.check_output(['git',*args],cwd=root,stderr=subprocess.PIPE)
def ancestor(root,commit):return subprocess.run(['git','merge-base','--is-ancestor',commit,'HEAD'],cwd=root,capture_output=True).returncode==0

def validate_legacy(gate,policy,text,archive_hash,in_ancestry,semantic_ok):
 need(gate in ALLOWED,'unlisted legacy gate')
 need(policy['contracts']==ALLOWED[gate],'wrong legacy contract IDs')
 need('Decision: ACCEPT' in text,'missing explicit ACCEPT')
 need('external acceptance' in text.lower() or 'external mathematical' in text.lower(),'missing external provenance')
 need(all(re.search(r'\b'+i+r'\b',text) for i in ALLOWED[gate]),'missing contract IDs')
 need(all(q in text for q in QUALIFICATIONS[gate]),'missing substantive conclusions or qualification')
 need(re.search(r'substantive (?:review(?:er)? )?conclusions',text,re.I),'missing substantive adequacy conclusions')
 need(sha(text.encode())==policy['record_sha256'],'historical record changed')
 need(archive_hash is not None,'missing reviewed archive')
 need(archive_hash==policy['archive_sha256'] and archive_hash in text,'archive hash mismatch')
 need(in_ancestry,'acceptance commit not in ancestry')
 need(semantic_ok,'current theorem semantic mismatch')
 return {'class':'legacy_external','verdict':'ACCEPT','confidence':None,'requires_human_review':None,'release_eligible':True}

def validate_modern(verdict,snapshot):
 need(verdict.get('verdict')=='PASS','modern verdict not PASS')
 need(verdict.get('confidence')=='HIGH','modern confidence not HIGH')
 need(verdict.get('requires_human_review') is False,'modern human review unresolved')
 need(verdict.get('snapshot_sha256')==snapshot,'modern snapshot mismatch')
 need(not verdict.get('blocking_findings'),'modern blockers')
 need(verdict.get('contract_assessments') and all(x.get('adequate') is True for x in verdict['contract_assessments']),'modern inadequacy')
 return True

def closure(root,modules):
 seen={};todo=list(modules)
 while todo:
  n=todo.pop()
  if n in seen:continue
  b=(root/n).read_bytes();seen[n]=sha(b)
  for m in re.findall(r'^import\s+([\w.]+)',b.decode(),re.M):
   p=m.replace('.','/')+'.lean'
   if p.startswith('Aiyagari1994/'):
    need((root/p).is_file(),'missing project import');todo.append(p)
 return seen

def legacy_bridge(root,raw_fingerprints):
 root=Path(root); policy=json.loads((root/'orchestration/legacy_acceptance_policy.json').read_text())
 need(set(policy['gates'])==set(ALLOWED),'legacy eligibility expanded')
 ts={x['id']:x for x in json.loads((root/'contracts/theorems.json').read_text())['theorems']}
 fps={x['name']:x for x in raw_fingerprints};prefix=git(root,'rev-parse','--show-prefix').decode().strip();entries=[]
 for gate,p in policy['gates'].items():
  text=(root/p['record']).read_text();archive=root/p['archive'];ah=sha(archive.read_bytes()) if archive.is_file() else None
  mods=[ts[i]['module'] for i in p['contracts']];sources=closure(root,mods)
  for n,h in sources.items():need(sha(git(root,'show',p['commit']+':'+prefix+n))==h,'historical import closure changed: '+n)
  for n in ['lean-toolchain','lake-manifest.json']:
   need(git(root,'show',p['commit']+':'+prefix+n)==(root/n).read_bytes(),'historical toolchain changed')
  need(archive.is_file(),'missing reviewed archive')
  with zipfile.ZipFile(archive) as z:
   for n in mods:need(z.read(n)==git(root,'show',p['commit']+':'+prefix+n),'reviewed implementation differs from accepted commit')
  declarations={}
  for i in p['contracts']:
   n=ts[i]['declaration'];f=fps.get(n);need(f is not None and not f['unsafe'] and not f['partial'],'missing or unsafe fingerprint')
   need(set(f['axioms'])<={'propext','Classical.choice','Quot.sound'},'unapproved axiom')
   declarations[n]={'fingerprint_sha256':sha(canonical(f)),'type_sha256':sha(canonical(f['type'])),'value_sha256':sha(canonical(f['value'])),'levels':f['levels'],'metadata':f['metadata'],'project_dependencies':f['project_dependencies'],'axioms':f['axioms']}
  v=validate_legacy(gate,p,text,ah,ancestor(root,p['commit']),True)
  entries.append(dict(v,gate=gate,contracts=p['contracts'],original_record=p['record'],original_record_sha256=sha(text.encode()),reviewer_provenance_text=text,archive=p['archive'],expected_archive_sha256=p['archive_sha256'],current_archive_sha256=ah,archive_hash_match=True,acceptance_commit=p['commit'],ancestry=True,qualification_references={'record':p['record'],'mandatory_text':QUALIFICATIONS[gate],'ledger_sections':p['contracts']},source_import_closure=sources,current_declaration_fingerprints=declarations,semantic_preservation={'result':'PASS','method':'Reviewed module bytes equal acceptance commit; entire project import closure and toolchain/lock byte-identical since acceptance. Fresh final-environment lossless type/value DAG fingerprints recorded. Historical fingerprint logs unavailable; no historical hashes fabricated.'}))
 return {'classification':CLASSIFICATION,'policy_sha256':sha((root/'orchestration/legacy_acceptance_policy.json').read_bytes()),'mathematical_candidate':policy['mathematical_candidate'],'entries':entries,'contract_count':10,'structural_only':True}

def modern_index(root):
 from stage10b import Stage10bController
 from orchestrate import decision,canonical as oc,digest
 c=Stage10bController(Path(root));rows=[]
 for gate in c.gates:
  if gate['id']=='M03A':continue
  rec=c.acceptance_record(gate);directory=c.root/rec['evidence_directory'];v=json.loads((directory/'reviewer_final.json').read_text());m=json.loads((directory/'snapshot_manifest.json').read_text())
  need(ancestor(root,rec['accepted_commit_sha']),'modern acceptance ancestry')
  need(digest(oc(m))==rec['snapshot_sha256'],'modern immutable manifest hash')
  validate_modern(v,rec['snapshot_sha256'])
  need(decision(v,gate,v['attempt'],rec['snapshot_sha256'],True)=='ACCEPTANCE_RECORDING','modern controller decision')
  h=rec.get('reviewer_history')
  if h:need(h[h['operative']]['verdict']==v,'operative reviewer history mismatch')
  rows.append({'gate':gate['id'],'contracts':gate['contracts'],'commit':rec['accepted_commit_sha'],'snapshot_sha256':rec['snapshot_sha256'],'verdict':'PASS','confidence':'HIGH','requires_human_review':False,'evidence_directory':rec['evidence_directory'],'qualifications':rec.get('qualifications',[]),'nonblocking_findings':rec.get('nonblocking_findings',[])})
 return rows

def release_approvals(root):
 root=Path(root);d=root/'reports/stage11_evidence';b=json.loads((d/'legacy_acceptance_bridge.json').read_text());fp=json.loads((d/'legacy_fingerprint_evidence.json').read_text())
 need(legacy_bridge(root,fp)==b,'stale legacy bridge')
 rows=modern_index(root);ids=[i for x in b['entries']+rows for i in x['contracts']]
 need(len(ids)==57 and len(set(ids))==57,'acceptance contract coverage')
 return set(ids)

if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser();p.add_argument('--fingerprints',type=Path,required=True);a=p.parse_args();root=Path(__file__).resolve().parents[1]
 raw=json.loads(a.fingerprints.read_text());bridge=legacy_bridge(root,raw);d=root/'reports/stage11_evidence';d.mkdir(exist_ok=True)
 (d/'legacy_acceptance_bridge.json').write_text(json.dumps(bridge,indent=2)+'\n')
 (d/'legacy_fingerprint_evidence.json').write_text(json.dumps(raw,separators=(',',':'))+'\n')
 (d/'modern_acceptance_index.json').write_text(json.dumps(modern_index(root),indent=2)+'\n')
 print('Legacy bridge: 10 contracts; modern index: 47 contracts. Structural validation only.')
