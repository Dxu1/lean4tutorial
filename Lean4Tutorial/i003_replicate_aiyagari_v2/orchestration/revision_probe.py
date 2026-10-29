"""Immutable, candidate-bound generated probe registrations; no mathematical edits."""
import copy,json,re
from pathlib import Path
from shared_imports import sha,canonical
from signature_probe import commands,compare,need
CLASSIFICATION='SUBSTANTIVE_REVISION_PROBE_TEMPLATE_STALE'

def contract_semantics(t):return {k:v for k,v in t.items() if k!='status'}

def candidate(c,gate):
    files={gate['module']}|{str(p.relative_to(c.root)) for p in (c.root/'Aiyagari1994/Analysis'/gate['id']).rglob('*.lean')}
    hashes={n:sha((c.root/n).read_bytes()) for n in sorted(files)}
    return hashes,sha(canonical(hashes))

def audit_targets(raw,namespace,public):
    # Other gates have their own audits; only this gate's exact owned names enter.
    seq=[]
    for line in raw.decode().splitlines():
        m=re.fullmatch(r'(#[a-z]+(?: axioms)?|assert_no_sorry)\s+(\S+)\s*',line)
        if m and (m[2].startswith(namespace) or m[2]==public):seq.append(list(m.groups()))
    names=[n for cmd,n in seq if cmd=='#check']
    need(names and len(names)==len(set(names)),'duplicate/missing audit targets')
    for cmd in ('#check','assert_no_sorry','#print axioms'):
        actual=[n for k,n in seq if k==cmd]
        need(len(actual)==len(names) and set(actual)==set(names),'incomplete audit commands')
    need(len(seq)==3*len(names) and public in names,'public/command coverage')
    return names

def validate_inventory(records,names,gate,contracts):
    by={x['name']:x for x in records};need(len(by)==len(records) and set(by)==set(names),'kernel inventory differs')
    ts={t['id']:t for t in contracts['theorems']};allowed=set()
    def visit(cid):
        if cid in allowed:return
        allowed.add(cid)
        for dep in ts[cid]['dependencies']:visit(dep)
    for cid in gate['contracts']:visit(cid)
    public={ts[cid]['declaration'] for cid in gate['contracts']}
    owners={gate['module'][:-5].replace('/','.')}
    used_contracts=set()
    for n,x in by.items():
        own=x['owner'];helper=own.startswith('Aiyagari1994.Analysis.'+gate['id']+'.')
        need((n in public and own in owners) or (helper and n.startswith('Aiyagari1994.'+gate['id']+'.')),'foreign/future target: '+n)
        need(not x['unsafe'] and not x['partial'] and set(x['axioms'])<={'propext','Classical.choice','Quot.sound'},'unsafe target')
        deps=set(x['project_dependencies'])
        used={t['id'] for t in ts.values() if t['declaration'] in deps}
        need(used<=allowed,'unauthorized formal dependency: '+str(used-allowed));used_contracts|=used
    return sorted(used_contracts)

def validate(c,gate,entry,m,revision):
    files,key=candidate(c,gate)
    need(m['version']==1 and m['gate']==gate['id'] and m['contracts']==gate['contracts'],'manifest identity')
    need(m['substantive_revision']==revision,'stale substantive revision')
    need(m['candidate_sha256']==key and m['candidate_files']==files,'candidate hash mismatch')
    ts=json.loads((c.root/'contracts/theorems.json').read_text())
    actual=[contract_semantics(t) for t in ts['theorems'] if t['id'] in gate['contracts']]
    need(actual==m['contract_semantics'],'contract mutation')
    need(sha((c.root/'contracts/assumptions.json').read_bytes())==m['assumptions_sha256'],'assumption mutation')
    namespace='Aiyagari1994.'+gate['id']+'.';public=actual[0]['declaration']
    names=audit_targets((c.root/'Audit.lean').read_bytes(),namespace,public)
    need(set(names)==set(m['template']['declarations']),'audit inventory changed')
    # Template bytes and command identity are distinct from the mathematical candidate hash.
    t=m['template'];need({k:t[k] for k in ('path','gate','producer','artifact_kind','grammar','imports','printing_options')}=={k:entry[k] for k in ('path','gate','producer','artifact_kind','grammar','imports','printing_options')},'producer/options changed')
    need(set(entry['declarations'])<=set(t['declarations']),'mandatory historical target missing')
    validate_inventory(m['kernel_inventory'],t['declarations'],gate,ts)
    raw=(c.root/t['path']).read_bytes();out=compare(raw,t)
    need(commands(raw)==m['command_sequence'],'manifest command sequence mismatch')
    for n,h in m['dependency_sources'].items():need(sha((c.root/n).read_bytes())==h,'dependency source changed: '+n)
    return t,out

def resolve(c,gate,entry,state=None):
    state=state if state is not None else c.status()
    revision=state.get('revisions',0);_,key=candidate(c,gate)
    matches=[]
    for item in entry.get('candidate_manifests',[]):
        if item['substantive_revision']==revision and item['candidate_sha256']==key:
            p=c.root/item['path'];raw=p.read_bytes();need(sha(raw)==item['sha256'],'manifest digest')
            m=json.loads(raw);t,out=validate(c,gate,entry,m,revision)
            matches.append((t,m,item,out))
    need(len(matches)==1,'missing/ambiguous candidate-bound registration')
    return matches[0]

def certificate(c,gate,entry):
    from probe_whitespace import producer
    t,m,item,out=resolve(c,gate,entry);raw=(c.root/t['path']).read_bytes()
    need(raw==out,'probe is not canonical')
    identity=producer(c,gate,c.status(),t)
    need(identity==m['producer_identity'],'candidate producer mismatch')
    return {'result':'PASS','classification':CLASSIFICATION,'gate':gate['id'],'contract':gate['contracts'],
            'candidate_sha256':m['candidate_sha256'],'substantive_revision':m['substantive_revision'],
            'path':t['path'],'sha256':sha(raw),'command_sequence_sha256':sha(canonical(commands(raw))),
            'printing_options':t['printing_options'],'manifest':item,'producer':identity,
            'targets':len(t['declarations']),'formal_dependencies':m['contract_semantics'][0]['dependencies'],
            'target_classification_counts':{k:sum(x['classification']==k for x in m['target_classifications']) for k in ('retained','A','B','C')},'removed_targets':[],'changed_modes':[],'semantic_declarations':0,'model_calls':0}
