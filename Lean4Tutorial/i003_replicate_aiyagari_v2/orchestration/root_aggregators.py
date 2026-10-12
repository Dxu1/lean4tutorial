"""Fail-closed certificates for explicitly registered terminal import aggregators."""
import copy,json,re,subprocess,tempfile,os
from pathlib import Path
from orchestrate import Stop,atomic_json,digest,canonical,strip_lean_comments,clean_environment
REGISTRY={'All.lean': {'M10A1':['Aiyagari1994.Budget.NoPonzi'],'M10B1':['Aiyagari1994.Extensions.BorrowingCap'],'M10B3':['Aiyagari1994.Extensions.GovernmentDebt']}}
CONTRACTS={'M10A1':'NP01','M10B1':'E01','M10B3':'E03'}
ACCEPTED_COUNTS={'M10A1':51,'M10B1':54,'M10B3':56}
CLASS='ROOT_AGGREGATOR_IMPORT_CERTIFICATE'
INCIDENT='ROOT_AGGREGATOR_IMPORT_RECONCILIATION'
BASE='2e6bd77b55fa23252eac601ada028c0ed39fb12e'
INFRA={'orchestration/root_aggregators.py','orchestration/aggregator_fingerprint.txt',
       'orchestration/orchestrate.py','orchestration/gate_context.py','orchestration/stage10a.py',
       'orchestration/artifacts.json','orchestration/tests/test_root_aggregators.py','orchestration/tests/test_compact_context.py',
       'reports/np01_aggregator_reconciliation.md'}
OBS={'reports/stage10a_early_stop.md','reports/stage10a_usage_metrics.json','reports/stage10a_usage_report.md'}
MODULE_RE=r'[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*'
def need(ok,why):
    if not ok:raise Stop(why)
def mask_comments(text):
    # Preserve token boundaries and line positions; nested comments are whitespace.
    out=[];i=0;depth=0;quoted=False
    while i<len(text):
        if quoted:
            out.append(text[i])
            if text[i]=='\\' and i+1<len(text):out.append(text[i+1]);i+=2;continue
            if text[i]=='"':quoted=False
            i+=1;continue
        if not depth and text[i]=='"':quoted=True;out.append(text[i]);i+=1;continue
        if text[i:i+2]=='/-':depth+=1;out.append('  ');i+=2
        elif depth and text[i:i+2]=='-/':depth-=1;out.append('  ');i+=2
        elif depth:out.append('\n' if text[i]=='\n' else ' ');i+=1
        elif text[i:i+2]=='--':
            end=text.find('\n',i);end=len(text) if end<0 else end;out.append(' '*(end-i));i=end
        else:out.append(text[i]);i+=1
    need(not depth,'UNTERMINATED_AGGREGATOR_COMMENT')
    return ''.join(out)

def pure_imports(raw):
    text=mask_comments(raw.decode());imports=[]
    for line in text.splitlines():
        if not line.strip():continue
        m=re.fullmatch(r'\s*import\s+('+MODULE_RE+r'(?:\s+'+MODULE_RE+r')*)\s*',line)
        need(m is not None,'ALL_LEAN_NOT_PURE_AGGREGATOR')
        imports+=m[1].split()
    need(bool(imports) and len(imports)==len(set(imports)),'AGGREGATOR_DUPLICATE_OR_EMPTY_IMPORTS')
    return imports

def import_delta(old,new,allowed):
    before=pure_imports(old);after=pure_imports(new)
    added=[m for m in after if m not in before];removed=[m for m in before if m not in after]
    need(not removed,'AGGREGATOR_REMOVED_IMPORT')
    need([m for m in after if m in before]==before,'AGGREGATOR_REORDERED_IMPORT')
    need(added==allowed,'AGGREGATOR_UNAUTHORIZED_IMPORT')
    return {'baseline_imports':before,'candidate_imports':after,'added_imports':added,'removed_imports':removed,'relative_order_preserved':True,'non_import_content_sha256':digest(b'')}

def source_imports(raw):
    text=mask_comments(raw.decode());out=[]
    # Project Lean headers use one or multiple unquoted module names per import.
    for line in text.splitlines():
        if re.match(r'^\s*(?:(?:public|private|meta)\s+)*import\b',line):
            m=re.fullmatch(r'\s*(?:(?:public|private|meta)\s+)*import\s+('+MODULE_RE+r'(?:\s+'+MODULE_RE+r')*)\s*',line)
            need(m is not None,'UNSUPPORTED_PROJECT_IMPORT_SYNTAX')
            out+=m[1].split()
    return out

def graph_check(sources,base_sources,active,added):
    graph={n[:-5].replace('/','.'):source_imports(raw) for n,raw in sources.items()}
    semantic={n[:-5].replace('/','.') for n in sources if n.startswith('Aiyagari1994/') or n=='Aiyagari1994.lean'}
    reverse=[m for m,ds in graph.items() if 'All' in ds]
    need(not set(reverse)&semantic,'AGGREGATOR_SEMANTIC_REVERSE_IMPORT')
    for start in semantic:
        todo=[start];seen_reverse=set()
        while todo:
            m=todo.pop()
            if m in seen_reverse:continue
            seen_reverse.add(m)
            need(m!='All','AGGREGATOR_SEMANTIC_REVERSE_IMPORT')
            todo += [x for x in graph.get(m,[]) if x in graph]

    seen=set();visiting=set()
    def visit(m):
        need(m not in visiting,'AGGREGATOR_IMPORT_CYCLE')
        if m in seen:return
        visiting.add(m)
        for dep in graph.get(m,[]):
            if dep in graph:visit(dep)
            else:need(not dep.startswith(('Aiyagari1994','Probes')) and dep not in ('All','Audit'),'MISSING_PROJECT_IMPORT')
        visiting.remove(m);seen.add(m)
    for m in graph:visit(m)
    new_allowed={active['module']}
    new_allowed.update(n for n in sources if n.startswith('Aiyagari1994/Analysis/'+active['id']+'/'))
    for m in added:
        n=m.replace('.','/')+'.lean';need(n in sources and n==active['module'],'AGGREGATOR_IMPORT_NOT_GATE_OWNED')
        todo=[m];closure=set()
        while todo:
            x=todo.pop()
            if x in closure:continue
            closure.add(x);path=x.replace('.','/')+'.lean'
            need(x not in ('All','Audit'),'AGGREGATOR_NONTERMINAL_IMPORT')
            if x in graph:
                need(path in base_sources or path in new_allowed,'AGGREGATOR_FUTURE_STAGE_IMPORT')
                if path in base_sources:need(sources[path]==base_sources[path],'AGGREGATOR_ACCEPTED_SOURCE_CHANGED')
                todo+=graph[x]
    return {'reverse_imports':sorted(reverse),'semantic_reverse_imports':[],'terminal_semantic_root':True,'import_cycles':False,'graph_sha256':digest(canonical(graph))}

def inputs(c,gate,name):
    need(name in REGISTRY and gate['id'] in REGISTRY[name],'UNREGISTERED_AGGREGATOR_GATE')
    cid=CONTRACTS[gate['id']]
    need(gate['contracts']==[cid] and gate['module']==REGISTRY[name][gate['id']][0].replace('.','/')+'.lean','AGGREGATOR_WRONG_GATE')
    prefix=c.git('rev-parse','--show-prefix').strip()
    baseline=c.status()['baseline']
    blob=lambda n:subprocess.check_output(['git','show',baseline+':'+prefix+n],cwd=c.root)
    old=blob(name);new=(c.root/name).read_bytes()
    delta=import_delta(old,new,REGISTRY[name][gate['id']])
    paths=[n for n in c.project_files() if n.endswith('.lean') and (n in ('All.lean','Audit.lean','Aiyagari1994.lean') or n.startswith(('Aiyagari1994/','Probes/')))]
    sources={n:(c.root/n).read_bytes() for n in paths}
    base_paths=c.git('ls-tree','-r','--name-only',baseline,'--','Aiyagari1994','Probes','Aiyagari1994.lean','All.lean','Audit.lean').splitlines()
    base_sources={n:blob(n) for n in base_paths if n.endswith('.lean')}
    for n,b in base_sources.items():
        if n.startswith('Aiyagari1994/') or n=='Aiyagari1994.lean':need(sources.get(n)==b,'AGGREGATOR_ACCEPTED_SOURCE_CHANGED: '+n)
    graph=graph_check(sources,base_sources,gate,delta['added_imports'])
    before=json.loads(blob('contracts/theorems.json'));after=json.loads((c.root/'contracts/theorems.json').read_text())
    expected=copy.deepcopy(before)
    for t in expected['theorems']:
        if t['id']==cid:t['status']=next(x['status'] for x in after['theorems'] if x['id']==cid)
    need(expected==after and next(t['status'] for t in after['theorems'] if t['id']==cid) in ('REVIEW_READY','GREEN'),'AGGREGATOR_CONTRACT_MUTATION')
    names=[t['declaration'] for t in before['theorems'] if t['status']=='GREEN']
    need(len(names)==ACCEPTED_COUNTS[gate['id']],'AGGREGATOR_ACCEPTED_INVENTORY')
    need(not any(t['declaration'].split('.')[-1] in strip_lean_comments(sources[gate['module']].decode()) for t in after['theorems'] if t['status']=='UNFORMALIZED' and t['id']!=cid),'AGGREGATOR_LATER_DECLARATION')
    key=digest(canonical({'baseline':baseline,'gate':gate,'files':{n:digest(b) for n,b in sources.items()},'contracts':digest(canonical(after)),'tool':digest(Path(__file__).read_bytes()),'serializer':digest((c.root/'orchestration/aggregator_fingerprint.txt').read_bytes())}))
    cert={'classification':CLASS,'result':'PASS','gate':gate['id'],'contract':cid,'aggregator':name,'baseline_commit':baseline,'baseline_sha256':digest(old),'candidate_sha256':digest(new),'input_sha256':key,'authorized_module':gate['module'],**delta,**graph}
    return cert,old,names

def compare_fingerprints(before,after,names):
    need({x['name'] for x in before}==set(names) and len(before)==len(names),'AGGREGATOR_FINGERPRINT_COVERAGE')
    need(before==after,'AGGREGATOR_ACCEPTED_SEMANTICS_CHANGED')
    need(all(not x['unsafe'] and not x['partial'] and set(x['axioms'])<={'propext','Classical.choice','Quot.sound'} for x in after),'AGGREGATOR_NONSTANDARD_AXIOM')

def fingerprint(c,d,old,names):
    env=clean_environment()
    def run(args,label,custom=None):
        r=subprocess.run(args,cwd=c.root,env=custom or env,capture_output=True,text=True)
        (d/(label+'.log')).write_text(json.dumps(args)+'\n'+r.stdout+r.stderr+'\nExit: '+str(r.returncode)+'\n')
        need(r.returncode==0,'AGGREGATOR_FINGERPRINT_FAILED: '+label)
        return r.stdout
    run(['lake','build','All'],'candidate_build')
    with tempfile.TemporaryDirectory(prefix='aggregator-audit-') as temp:
        tmp=Path(temp);p=tmp/'All.lean';p.write_bytes(old)
        run(['lake','env','lean','--root='+str(tmp),'-o',str(tmp/'All.olean'),str(p)],'baseline_build')
        source=(c.root/'orchestration/aggregator_fingerprint.txt').read_text().replace('NAMES_PLACEHOLDER',','.join('`'+n for n in names))
        probe=tmp/'Fingerprint.lean';probe.write_text('import All\nimport Lean\n'+source)
        after=json.loads(run(['lake','env','lean',str(probe)],'candidate_fingerprint'))
        baseenv=dict(env);baseenv['LEAN_PATH']=str(tmp)+os.pathsep+run(['lake','env','printenv','LEAN_PATH'],'lean_path').strip()
        lean=run(['lake','env','which','lean'],'lean_binary').strip()
        before=json.loads(run([lean,str(probe)],'baseline_fingerprint',baseenv))
    compare_fingerprints(before,after,names)
    atomic_json(d/'baseline_fingerprints.json',before);atomic_json(d/'candidate_fingerprints.json',after)
    return {'accepted_declaration_count':len(names),'accepted_declarations':names,'baseline_fingerprints_sha256':digest(canonical(before)),'candidate_fingerprints_sha256':digest(canonical(after))}

def certify(c,gate,name='All.lean',force=False):
    expected,old,names=inputs(c,gate,name);d=c.runtime/'aggregator_certificates'/expected['input_sha256'];p=d/'certificate.json'
    if p.exists() and not force:
        cert=json.loads(p.read_text());validate(c,gate,cert);return cert
    d.mkdir(parents=True,exist_ok=True);sem=fingerprint(c,d,old,names)
    cert={**expected,**sem,'evidence_directory':str(d),'artifacts':{n:digest((d/n).read_bytes()) for n in ('baseline_fingerprints.json','candidate_fingerprints.json')},'executor_rerun':False}
    atomic_json(p,cert);return cert

def validate(c,gate,cert):
    expected,_,names=inputs(c,gate,cert.get('aggregator'))
    need(all(cert.get(k)==v for k,v in expected.items()),'STALE_OR_WRONG_AGGREGATOR_CERTIFICATE')
    d=c.runtime/'aggregator_certificates'/expected['input_sha256']
    need(cert.get('evidence_directory')==str(d) and set(cert.get('artifacts',{}))=={'baseline_fingerprints.json','candidate_fingerprints.json'},'AGGREGATOR_ARTIFACT_INVENTORY')
    for n,h in cert['artifacts'].items():need(digest((d/n).read_bytes())==h,'AGGREGATOR_ARTIFACT_CHANGED')
    before=json.loads((d/'baseline_fingerprints.json').read_text());after=json.loads((d/'candidate_fingerprints.json').read_text());compare_fingerprints(before,after,names)
    need(cert.get('accepted_declaration_count')==len(names) and cert.get('accepted_declarations')==names and cert.get('baseline_fingerprints_sha256')==digest(canonical(before)) and cert.get('candidate_fingerprints_sha256')==digest(canonical(after)),'AGGREGATOR_FINGERPRINT_BINDING')
    return cert

def eligible(s):
    need(s['status']=='HUMAN_STOP' and s['gate']=='M10A1' and s['diagnostic']=='ACCEPTED_LEAN_CHANGED: All.lean','AGGREGATOR_WRONG_INCIDENT')
    need(s['attempt']==1 and s['revisions']==0 and s['executor_effort_index']==0 and s['executor_history']==[{'attempt':1,'gate_id':'M10A1','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}],'AGGREGATOR_EXECUTION_IDENTITY')
    need(not s.get('snapshot_sha256') and not s.get('reviewer_verdict') and not s.get('acceptance_committed'),'AGGREGATOR_REVIEW_ALREADY_STARTED')

def resume(c,receipt,sha,head):
    with c.lock():
        p=Path(receipt);raw=p.read_bytes();r=json.loads(raw);s=c.status();eligible(s)
        need(digest(raw)==sha and digest(c.state_path.read_bytes())==r['state_sha256'],'AGGREGATOR_RECEIPT_CHANGED')
        need(c.git('rev-parse','HEAD').strip()==head and c.git('rev-list','--parents','-n','1','HEAD').split()==[head,r['head']],'AGGREGATOR_REPAIR_HISTORY')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',r['head'],head).splitlines())=={prefix+n for n in INFRA},'AGGREGATOR_REPAIR_SCOPE')
        need(not c.git('diff','--cached','--name-only').strip(),'AGGREGATOR_DIRTY_INDEX')
        files=c.project_files();select=lambda x:{n:h for n,h in x.items() if n not in INFRA}
        need(select(files)==select(r['files']),'AGGREGATOR_SUBMISSION_CHANGED')
        for n,h in r['runtime_hashes'].items():need(digest(Path(n).read_bytes())==h,'AGGREGATOR_RUNTIME_CHANGED')
        need(not list((c.runtime/'runs/M10A1').rglob('reviewer_invocation.json')),'AGGREGATOR_REVIEW_EXISTS')
        c.preserve();candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:
            need(digest(subprocess.check_output(['git','show',head+':'+prefix+n],cwd=c.root))==files[n],'AGGREGATOR_DIRTY_INFRASTRUCTURE')
            candidate['initial_files'][n]=files[n]
        for n in OBS:candidate['initial_files'][n]=files[n]
        gate=next(g for g in c.gates if g['id']=='M10A1')
        # Current baseline has byte-identical accepted mathematics and All.lean.
        cert=certify(c,gate,force=True)
        candidate['owned_files']=files;candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        c._semantic_scope(gate,candidate,candidate['initial_files'])
        atomic_json(p.parent/'reconciliation.json',{'classification':INCIDENT,'history':['ACCEPTED_LEAN_CHANGED: All.lean','APPEND_ONLY_GUARD_INCOMPATIBLE_WITH_ROOT_AGGREGATOR',INCIDENT],'infrastructure_commit':head,'receipt_sha256':sha,'certificate':cert,'model_calls':0,'executor_rerun':False,'substantive_revisions':0})
        c.save(candidate,'POST_EXECUTOR_RECONCILED');return {'status':candidate['status'],'executor_rerun':False}

if __name__=='__main__':
    import argparse
    from stage10a import Stage10aController
    p=argparse.ArgumentParser();p.add_argument('receipt');p.add_argument('sha');p.add_argument('head');a=p.parse_args()
    print(json.dumps(resume(Stage10aController(),a.receipt,a.sha,a.head)))

def accepted_provenance(c):
    """Hash-bound contiguous reviewed import chain, including every accepted root change."""
    nodes=[];prefix=c.git('rev-parse','--show-prefix').strip();previous=None
    for gate in c.gates:
        if gate['id'] not in REGISTRY['All.lean'] or not c.tracked(f"reviews/{gate['id'].lower()}_acceptance.json"):continue
        rec=c.acceptance_record(gate);d=c.root/rec['evidence_directory']
        manifest=json.loads((d/'snapshot_manifest.json').read_text())
        need(digest(canonical(manifest))==rec['snapshot_sha256'],'AGGREGATOR_ACCEPTANCE_SNAPSHOT')
        raw=(d/'deterministic_summary.json').read_bytes()
        need(digest(raw)==manifest['files']['verification/deterministic_summary.json'],'AGGREGATOR_REVIEWED_SUMMARY_CHANGED')
        cert=json.loads(raw)['root_aggregator']
        need(cert['classification']==CLASS and cert['gate']==gate['id'] and cert['contract']==CONTRACTS[gate['id']] and cert['result']=='PASS','AGGREGATOR_ACCEPTANCE_IDENTITY')
        c.git('merge-base','--is-ancestor',cert['baseline_commit'],rec['accepted_commit_sha'])
        c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD')
        old=c.git('show',cert['baseline_commit']+':'+prefix+'All.lean').encode()
        new=c.git('show',rec['accepted_commit_sha']+':'+prefix+'All.lean').encode()
        need(digest(old)==cert['baseline_sha256'] and digest(new)==cert['candidate_sha256'],'AGGREGATOR_ACCEPTANCE_BLOB')
        delta=import_delta(old,new,REGISTRY['All.lean'][gate['id']])
        need(all(cert[k]==v for k,v in delta.items()),'AGGREGATOR_ACCEPTANCE_DELTA')
        if previous:
            need(previous['certificate']['candidate_sha256']==cert['baseline_sha256'],'AGGREGATOR_PROVENANCE_GAP')
            c.git('merge-base','--is-ancestor',previous['acceptance_commit'],cert['baseline_commit'])
        previous={'result':'PASS','acceptance_commit':rec['accepted_commit_sha'],'review_snapshot_sha256':rec['snapshot_sha256'],'certificate':cert}
        nodes.append(previous)
    need(bool(nodes),'AGGREGATOR_ACCEPTANCE_MISSING')
    need(nodes[-1]['certificate']['candidate_sha256']==digest((c.root/'All.lean').read_bytes()),'AGGREGATOR_CHANGED_AFTER_ACCEPTANCE')
    changes=c.git('log','--format=%H',nodes[0]['certificate']['baseline_commit']+'..HEAD','--','All.lean').splitlines()
    need(set(changes)=={n['acceptance_commit'] for n in nodes},'AGGREGATOR_UNCERTIFIED_HISTORY')
    return {**nodes[-1],'chain':nodes}
