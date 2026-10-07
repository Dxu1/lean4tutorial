"""Explicitly authorized import-header extensions; all other prefix edits fail closed.

Fingerprints use Lean's structural Expr Repr (not pretty-printed terms), including
binder names, levels and metadata, without erasure or normalization. Only theorem
wrappers are supported. A missing value or another declaration kind fails closed.
"""
import copy,hashlib,json,os,re,subprocess,tempfile
from pathlib import Path

BASE='b756f3d21530728a30a99534ea4aadcf60d796f3'
MODULE='Aiyagari1994/Equilibrium/Existence.lean'
IMPORT='Aiyagari1994.Analysis.M09B2.NaturalCapExistence'
CLASSIFICATION='SHARED_MODULE_IMPORT_ONLY_RECONCILIATION'
POLICIES={'M09B2':{'module':MODULE,'imports':[IMPORT],
    'new_declarations':['Aiyagari1994.naturalCap_equilibrium_exists']}}
INFRA={'orchestration/shared_imports.py','orchestration/semantic_fingerprint.txt',
       'orchestration/orchestrate.py','orchestration/stage09b.py',
       'orchestration/gate_context.py','orchestration/artifacts.json',
       'orchestration/tests/test_shared_imports.py','orchestration/tests/test_compact_context.py','reports/g03_shared_import_reconciliation.md'}

def sha(b):return hashlib.sha256(b).hexdigest()
def canonical(x):return json.dumps(x,sort_keys=True,separators=(',',':')).encode()
def fail(msg):raise ValueError(msg)

def structure(original,candidate,policy):
    """Remove only authorized new header import lines; retain every old byte."""
    allowed={('import '+x+'\n').encode():x for x in policy['imports']}
    lines=candidate.splitlines(keepends=True);added=[];retained=[];header=True
    for line in lines:
        if header and line in allowed and line not in original.splitlines(keepends=True):
            added.append(allowed[line]);continue
        if header and not line.startswith(b'import ') and line.strip():header=False
        retained.append(line)
    if not added or len(added)!=len(set(added)):fail('UNAUTHORIZED_OR_DUPLICATE_IMPORT')
    stripped=b''.join(retained)
    if not stripped.startswith(original):fail('GENUINE_ACCEPTED_DECLARATION_SOURCE_CHANGE')
    suffix=stripped[len(original):].decode()
    from orchestrate import strip_lean_comments
    text=strip_lean_comments(suffix)
    decls=re.findall(r'^theorem\s+(\w+)\b',text,re.M)
    if ['Aiyagari1994.'+n for n in decls]!=policy['new_declarations']:fail('UNAUTHORIZED_APPENDED_DECLARATION')
    # Narrow wrapper syntax: no attributes, instances, namespaces or elaborator commands
    # beyond one ordinary namespace and the assigned theorem. Reject unsupported forms.
    if re.search(r'(?m)^\s*(?:import|open|export|attribute|instance|def|abbrev|lemma|axiom|macro|syntax|elab|set_option|section|noncomputable|private|protected|mutual|#|@)',text):fail('UNAUTHORIZED_SUFFIX_COMMAND')
    if re.findall(r'(?m)^namespace (\S+)',text)!=['Aiyagari1994'] or re.findall(r'(?m)^end (\S+)',text)!=['Aiyagari1994']:fail('UNAUTHORIZED_SUFFIX_NAMESPACE')
    return added

def import_graph(root,imports):
    seen={};active=set()
    def visit(m):
        if m in active:fail('IMPORT_CYCLE: '+m)
        if m in seen:return
        active.add(m);p=Path(root)/(m.replace('.','/')+'.lean')
        if not p.is_file():fail('MISSING_PROJECT_IMPORT: '+m)
        from orchestrate import strip_lean_comments
        deps=re.findall(r'^import\s+(\S+)\s*$',strip_lean_comments(p.read_text()),re.M)
        if m in ('Aiyagari1994.Equilibrium.Existence','Aiyagari1994.Equilibrium.LowerBracket') or m.startswith(('Aiyagari1994.Analysis.M09B1.','Aiyagari1994.Analysis.M09A3.')):fail('UNAUTHORIZED_DEPENDENCY: '+m)
        for dep in deps:
            if dep.startswith('Aiyagari1994.'):visit(dep)
        active.remove(m);seen[m]=deps
    for m in imports:visit(m)
    return seen

def compare(baseline,candidate,policy,contracts):
    b={x['name']:x for x in baseline};a={x['name']:x for x in candidate}
    if len(b)!=len(baseline) or len(a)!=len(candidate) or not b:fail('INVALID_DECLARATION_INVENTORY')
    if set(a)!=set(b)|set(policy['new_declarations']):fail('UNAUTHORIZED_DECLARATION_INVENTORY')
    for n,v in b.items():
        required={'name','kind','unsafe','partial','reducibility','mutual_block','levels','type','value','project_dependencies','axioms'}
        if set(v)!=required or not v['value'] or not v['type']:fail('INCOMPLETE_SEMANTIC_FINGERPRINT')
        if a[n]!=v:fail('IMPORT_CHANGED_ACCEPTED_DECLARATION_SEMANTICS: '+n)
    ts={t['id']:t for t in contracts['theorems']};allowed=set()
    def visit(i):
        if i in allowed:return
        allowed.add(i)
        for j in ts[i]['dependencies']:visit(j)
    visit('G03')
    for n in policy['new_declarations']:
        deps=a[n]['project_dependencies']
        bad=[t['id'] for t in ts.values() if t['declaration'] in deps and t['id'] not in allowed]
        if bad:fail('UNAUTHORIZED_DEPENDENCY: '+','.join(bad))
        if not set(a[n]['axioms'])<={'propext','Quot.sound','Classical.choice'}:fail('NONSTANDARD_AXIOM')
    return [b[n] for n in sorted(b)]

def certify(c,gate,force=False):
    from orchestrate import atomic_json,Stop,clean_environment
    policy=POLICIES.get(gate['id'])
    if not policy or gate['module']!=policy['module']:raise Stop('ACCEPTED_LEAN_CHANGED: '+gate['module'])
    try:
        prefix=c.git('rev-parse','--show-prefix').strip()
        original=subprocess.check_output(['git','show',BASE+':'+prefix+MODULE],cwd=c.root)
        # Baseline sibling artifacts are usable only for byte-identical accepted sources.
        for name in c.git('ls-tree','-r','--name-only',BASE,'--','Aiyagari1994').splitlines():
            if name.endswith('.lean') and name!=MODULE:
                old=subprocess.check_output(['git','show',BASE+':'+prefix+name],cwd=c.root)
                if (c.root/name).read_bytes()!=old:fail('ACCEPTED_DEPENDENCY_SOURCE_CHANGED: '+name)
        candidate=(c.root/MODULE).read_bytes();added=structure(original,candidate,policy)
        graph=import_graph(c.root,added);c.preserve()
        # Exact source and tool keys prevent reusing evidence after any Lean edit.
        inputs={n:h for n,h in c.project_files().items() if n.endswith('.lean') or n in ('lean-toolchain','lake-manifest.json','contracts/theorems.json')}
        inputs['tool']=sha(Path(__file__).read_bytes());inputs['serializer']=sha((c.root/'orchestration/semantic_fingerprint.txt').read_bytes())
        key=sha(canonical(inputs));directory=c.runtime/'shared_import_reconciliation'/'certificates'/key
        result=directory/'certificate.json'
        if result.exists() and not force:
            cert=json.loads(result.read_text())
            if cert['input_sha256']!=key:fail('SEMANTIC_CERTIFICATE_INPUT_MISMATCH')
            for n,h in cert['artifacts'].items():
                if sha((directory/n).read_bytes())!=h:fail('SEMANTIC_CERTIFICATE_ARTIFACT_CHANGED')
            compare(json.loads((directory/'baseline_raw.json').read_text()),json.loads((directory/'candidate_raw.json').read_text()),policy,json.loads((c.root/'contracts/theorems.json').read_text()))
            return cert
        directory.mkdir(parents=True,exist_ok=True)
        env=clean_environment()
        def run(args,name,custom_env=None):
            r=subprocess.run(args,cwd=c.root,env=custom_env or env,capture_output=True,text=True)
            (directory/(name+'.log')).write_text(json.dumps(args)+'\n'+r.stdout+r.stderr+'\nExit: '+str(r.returncode))
            if r.returncode:fail('SEMANTIC_FINGERPRINT_COMMAND_FAILED: '+name)
            return r.stdout
        run(['lake','build',MODULE[:-5].replace('/','.')],'candidate_build')
        with tempfile.TemporaryDirectory(prefix='aiyagari-semantic-') as tmp:
            tmp=Path(tmp)
            # Lean resolves a package prefix to one root. Supply unchanged siblings
            # there too, while the shared module is freshly compiled from Git.
            lib=c.root/'.lake/build/lib/lean'
            for f in (lib/'Aiyagari1994').rglob('*'):
                if f.is_file() and not str(f.relative_to(lib)).startswith(MODULE[:-5]+'.'):
                    target=tmp/f.relative_to(lib);target.parent.mkdir(parents=True,exist_ok=True);target.symlink_to(f.resolve())
            src=tmp/MODULE;src.parent.mkdir(parents=True,exist_ok=True);src.write_bytes(original)
            run(['lake','env','lean','--root='+str(tmp),'-o',str(src.with_suffix('.olean')),str(src)],'baseline_build')
            probe=tmp/'Fingerprint.lean';probe.write_text('import Aiyagari1994.Equilibrium.Existence\nimport Lean\n'+(c.root/'orchestration/semantic_fingerprint.txt').read_text())
            candidate_raw=json.loads(run(['lake','env','lean',str(probe)],'candidate_fingerprint'))
            base_env=dict(env);base_env['LEAN_PATH']=str(tmp)+os.pathsep+run(['lake','env','printenv','LEAN_PATH'],'lean_path').strip()
            lean=run(['lake','env','which','lean'],'lean_binary').strip()
            baseline_raw=json.loads(run([lean,str(probe)],'baseline_fingerprint',base_env))
        accepted=compare(baseline_raw,candidate_raw,policy,json.loads((c.root/'contracts/theorems.json').read_text()))
        artifacts={'baseline_raw.json':baseline_raw,'candidate_raw.json':candidate_raw,
            'accepted_shared_declarations_baseline.json':accepted,
            'accepted_shared_declarations_candidate.json':[x for x in sorted(candidate_raw,key=lambda x:x['name']) if x['name'] in {v['name'] for v in accepted}],
            'import_graph.json':graph}
        for n,v in artifacts.items():atomic_json(directory/n,v)
        cert={'classification':CLASSIFICATION,'result':'PASS','baseline_commit':BASE,'module':MODULE,
              'authorized_imports':added,'source_prefix_unchanged':True,'source_sha256':sha(candidate),
              'input_sha256':key,'accepted_declarations':[x['name'] for x in accepted],
              'fingerprint_method':'Lean structural Expr Repr: exact type/value/levels/metadata and project/axiom closures; no fallback',
              'artifacts':{n:sha((directory/n).read_bytes()) for n in artifacts},
              'evidence_directory':str(directory),'executor_rerun':False}
        def compact(values):
            return [{k:(sha(canonical(v)) if k in ('type','value','project_dependencies') else v) for k,v in x.items()} for x in values]
        cert['baseline_fingerprints']=compact(artifacts['accepted_shared_declarations_baseline.json'])
        cert['candidate_fingerprints']=compact(artifacts['accepted_shared_declarations_candidate.json'])
        atomic_json(result,cert);return cert
    except (ValueError,KeyError) as e:raise Stop(str(e)) from e

def guard(c,gate,name):
    if gate['id'] not in POLICIES or name!=POLICIES[gate['id']]['module']:
        raise c.error('ACCEPTED_LEAN_CHANGED: '+name)
    return certify(c,gate)

def eligible(s):
    h=s.get('executor_history',[])
    if not (s.get('status')=='HUMAN_STOP' and s.get('gate')=='M09B2' and s.get('diagnostic')=='ACCEPTED_LEAN_CHANGED: '+MODULE and s.get('attempt')==1 and s.get('revisions')==0 and s.get('executor_effort_index')==0 and len(h)==1 and h[0]=={'attempt':1,'gate_id':'M09B2','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1} and not s.get('snapshot_sha256') and not s.get('reviewer_verdict') and not s.get('acceptance_committed')):fail('SHARED_IMPORT_REPAIR_INELIGIBLE')

def resume(c,receipt_path,receipt_sha,expected_head):
    from orchestrate import atomic_json,Stop
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status()
        if sha(raw)!=receipt_sha or sha(c.state_path.read_bytes())!=r['state_sha256']:raise Stop('SHARED_IMPORT_RECEIPT_CHANGED')
        eligible(s)
        for n,h in r['executor_evidence'].items():
            if sha((c.root/n).read_bytes())!=h:raise Stop('SHARED_IMPORT_EXECUTOR_EVIDENCE_CHANGED')
        head=c.git('rev-parse','HEAD').strip();prefix=c.git('rev-parse','--show-prefix').strip()
        if head!=expected_head or c.git('rev-list','--parents','-n','1','HEAD').split()!=[head,BASE]:raise Stop('SHARED_IMPORT_BASELINE_CHANGED')
        if set(c.git('diff','--name-only',BASE,head).splitlines())!={prefix+n for n in INFRA}:raise Stop('SHARED_IMPORT_COMMIT_SCOPE')
        if c.git('diff','--cached','--name-only').strip():raise Stop('SHARED_IMPORT_INDEX_DIRTY')
        current=c.project_files();select=lambda d:{n:h for n,h in d.items() if n not in INFRA}
        if select(current)!=select(r['files']):raise Stop('SHARED_IMPORT_SUBMISSION_CHANGED')
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:
            if sha(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=c.root))!=current[n]:raise Stop('SHARED_IMPORT_INFRA_DIRTY')
            candidate['initial_files'][n]=current[n]
        outer=sorted(x for x in c.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
        if outer!=s['outer_status']:raise Stop('SHARED_IMPORT_OUTER_CHANGED')
        gate=next(g for g in c.gates if g['id']=='M09B2')
        c._semantic_scope(gate,candidate,candidate['initial_files']);c.preserve()
        cert=certify(c,gate)
        candidate['owned_files']=c.project_files();candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        atomic_json(c.runtime/'shared_import_reconciliation/reconciliation.json',{'classification':CLASSIFICATION,'receipt_sha256':receipt_sha,'infrastructure_commit':head,'executor_history':s['executor_history'],'substantive_revisions':0,'executor_rerun':False,'certificate':cert})
        c.save(candidate,'POST_EXECUTOR_RECONCILED');return {'status':candidate['status'],'executor_rerun':False}
