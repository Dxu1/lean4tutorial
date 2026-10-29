"""Explicitly registered, token-safe verification probe formatting only."""
import json,re,subprocess
from pathlib import Path
from shared_imports import sha,canonical
CLASSIFICATION='GENERATED_PROBE_EOF_WHITESPACE_ONLY'
INFRA={'orchestration/probe_whitespace.py','orchestration/mechanical.py','orchestration/artifacts.json',
       'orchestration/shared_lifecycle.py','orchestration/tests/test_probe_whitespace.py',
       'reports/np03_probe_whitespace_reconciliation.md'}

def need(ok,reason):
    if not ok:raise ValueError('NON_MECHANICAL_PROBE_CHANGE: '+reason)

def normalize(raw):
    """No CRLF or expression/string rewriting. Only verified command lines."""
    need(b'\r' not in raw,'CRLF not authorized')
    lines=raw.decode('utf-8').split('\n')
    pattern=r'(?:import|#check|assert_no_sorry|#print axioms) [A-Za-z_][A-Za-z0-9_.]*[ \t]*'
    need(all(not x.strip(' \t') or re.fullmatch(pattern,x) for x in lines),'ambiguous probe syntax')
    return ('\n'.join(x.rstrip(' \t') for x in lines).rstrip('\n')+'\n').encode()

def expected(entry):
    if entry.get('grammar')=='signature_probe_v2':
        from signature_probe import template
        return template(entry)
    need(entry['producer']=='completed_executor_file_change','unregistered producer')
    names=entry['declarations'];imports=entry['imports']
    need(names and len(names)==len(set(names)) and imports and len(imports)==len(set(imports)), 'inventory')
    text='\n'.join('import '+n for n in imports)+'\n\n'
    text+='\n\n'.join('\n'.join(cmd+' '+n for cmd in ['#check','assert_no_sorry','#print axioms']) for n in names)+'\n'
    need(normalize(text.encode())==text.encode(),'invalid registry template')
    return text.encode()

def compare(raw,entry):
    if entry.get('grammar')=='signature_probe_v2':
        from signature_probe import compare as compare_commands
        return compare_commands(raw,entry)
    canonical_bytes=expected(entry)
    need(normalize(raw)==canonical_bytes,'imports or audit command inventory differs')
    return canonical_bytes

def producer(c,gate,state,entry):
    h=state['executor_history'][-1]
    need(h['gate_id']==gate['id'] and h['outcome']=='COMPLETED','executor identity')
    d=c.attempt_directory(gate,h['attempt'])
    need(json.loads((d/'executor_invocation.json').read_text())==h,'invocation metadata')
    events=d/'executor_events.jsonl';found=[]
    for line in events.read_text().splitlines():
        e=json.loads(line);i=e.get('item',{})
        if e.get('type')=='item.completed' and i.get('type')=='file_change' and i.get('status')=='completed':
            if any(x['path']==str(c.root/entry['path']) and x['kind'] in ('add','update') for x in i['changes']):found.append(i['id'])
    need(bool(found),'missing matching producer event')
    return {'invocation':h,'event':found[-1],'events_sha256':sha(events.read_bytes())}

def registered(c,gate):
    entries=json.loads((c.o/'artifacts.json').read_text()).get('generated_probes',{})
    entry=entries.get(gate['id'])
    if entry is None:return None
    need(entry['path']==gate['signature_probe'] and entry['path']==f"Probes/{gate['id']}Signatures.lean",'artifact identity')
    need(not c.tracked(f"reviews/{gate['id'].lower()}_acceptance.json"),'accepted probe is immutable')
    if entry.get('candidate_manifests'):
        from revision_probe import resolve
        return resolve(c,gate,entry)[0]
    return entry

def reconcile(c,gate,state):
    entry=registered(c,gate)
    if entry is None:return None
    p=c.root/entry['path'];raw=p.read_bytes();out=compare(raw,entry);identity=producer(c,gate,state,entry)
    if raw==out:return {'result':'PASS','changed':False,'sha256':sha(raw)}
    from orchestrate import atomic_json
    d=c.attempt_directory(gate,state['attempt'])/'probe_whitespace'
    d.mkdir(exist_ok=True);key=sha(raw);backup=d/(key+'.lean');journal=d/(key+'.json')
    need(not backup.exists() and not journal.exists(),'repeated normalization')
    backup.write_bytes(raw)
    result={'result':'PASS','classification':CLASSIFICATION,'path':entry['path'],
            'before_sha256':sha(raw),'after_sha256':sha(out),'producer':identity,'original':str(backup),'model_calls':0,'substantive_revisions':0}
    if entry.get('grammar')=='signature_probe_v2':
        from signature_probe import CLASSIFICATION as signature_class,commands
        result.update(classification=signature_class,command_sequence_unchanged=commands(raw)==commands(out),printing_options=entry['printing_options'])
    atomic_json(journal,result);p.write_bytes(out)
    return result

def rebind_valid(c,record,state):
    """Preserve original execution baseline while binding a separate infrastructure child."""
    from shared_lifecycle import blob
    p=Path(state['probe_whitespace_reconciliation']);raw=p.read_bytes();r=json.loads(raw)
    need(sha(raw)==state['probe_whitespace_reconciliation_sha256'],'reconciliation hash')
    need(r['classification']==CLASSIFICATION and r['old_baseline']==record['baseline'] and r['head']==state['baseline'],'baseline rebind')
    candidate=c.attempt_directory({'id':state['gate']},state['executor_history'][-1]['attempt'])/'shared_candidate.json'
    need(r['candidate_receipt_sha256']==sha(candidate.read_bytes()),'original candidate receipt')
    prefix=c.git('rev-parse','--show-prefix').strip()
    need(c.git('rev-list','--parents','-n','1',state['baseline']).split()==[state['baseline'],record['baseline']],'repair history')
    need(set(c.git('diff','--name-only',record['baseline'],state['baseline']).splitlines())=={prefix+n for n in INFRA},'non-infrastructure rebind')
    return True

def resume(c,receipt_path,receipt_sha,head):
    import copy
    from orchestrate import atomic_json
    from shared_lifecycle import phase
    with c.lock():
        raw=Path(receipt_path).read_bytes();r=json.loads(raw);s=c.status()
        need(sha(raw)==receipt_sha and sha(c.state_path.read_bytes())==r['state_sha256'],'receipt/state')
        gate=next(g for g in c.gates if g['id']==s['gate']);entry=registered(c,gate)
        need(entry is not None and s['status']=='HUMAN_STOP' and s['diagnostic']=='NEW_FILE_DIFF_CHECK: '+entry['path'],'incident')
        need(s['attempt']==1 and s['revisions']==0 and s['executor_effort_index']==0 and s['executor_history']==r['executor_history'] and len(s['executor_history'])==1,'execution identity')
        need(not s.get('snapshot_sha256') and not s.get('reviewer_verdict') and not s.get('acceptance_committed'),'review reached')
        a=c.attempt_directory(gate,s['attempt']);need(not list(a.rglob('reviewer_invocation.json')),'reviewer already invoked')
        need(c.git('rev-parse','HEAD').strip()==head and c.git('rev-list','--parents','-n','1',head).split()==[head,r['head']],'repair history')
        prefix=c.git('rev-parse','--show-prefix').strip()
        need(set(c.git('diff','--name-only',r['head'],head).splitlines())=={prefix+n for n in INFRA},'repair scope')
        need(not c.git('diff','--cached','--name-only').strip(),'dirty index')
        files=c.project_files();exclude=INFRA|{entry['path']};select=lambda f:{n:h for n,h in f.items() if n not in exclude}
        need(select(files)==select(r['files']),'mathematical submission changed')
        for n,h in r['runtime_hashes'].items():need(sha(Path(n).read_bytes())==h,'original evidence changed')
        from shared_lifecycle import blob
        for n in INFRA:need(files[n]==sha(blob(c,head,n)),'dirty infrastructure')
        original=(Path(receipt_path).parent/'original_probe.lean').read_bytes()
        need(sha(original)==r['files'][entry['path']] and (c.root/entry['path']).read_bytes()==compare(original,entry),'probe differs beyond whitespace')
        producer(c,gate,s,entry);c.preserve()
        candidate=copy.deepcopy(s);candidate['baseline']=head
        for n in INFRA:candidate['initial_files'][n]=files[n]
        path=Path(receipt_path).parent/'reconciliation.json'
        need(not path.exists(),'already reconciled')
        atomic_json(path,{'classification':CLASSIFICATION,'old_baseline':r['head'],'head':head,'receipt_sha256':receipt_sha,'candidate_receipt_sha256':sha((a/'shared_candidate.json').read_bytes()),'mathematical_hashes':select(files),'model_calls':0,'executor_rerun':False,'substantive_revisions':0})
        candidate['probe_whitespace_reconciliation']=str(path);candidate['probe_whitespace_reconciliation_sha256']=sha(path.read_bytes())
        need(phase(c,gate,candidate)=='POST_EXECUTOR','candidate lifecycle')
        c._semantic_scope(gate,candidate,candidate['initial_files'])
        candidate['owned_files']=files;candidate.pop('diagnostic',None);candidate.pop('stop_class',None)
        c.save(candidate,'POST_EXECUTOR_RECONCILED')
        return {'status':candidate['status'],'executor_rerun':False,'revisions':0}
