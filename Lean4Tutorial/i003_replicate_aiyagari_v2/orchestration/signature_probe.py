"""Registered, declaration-free signature evidence grammar, version 2.

Options are an exact display-only whitelist, not a pp.* or set_option wildcard.
The registry fixes command identity; whitespace normalization preserves comments.
"""
import json,re
from pathlib import Path
from shared_imports import sha,canonical

GRAMMAR='signature_probe_v2'
CLASSIFICATION='GENERATED_SIGNATURE_PROBE_FORMAT_RECONCILIATION'
DISPLAY_OPTIONS={'format.width':{'72','100'},'pp.funBinderTypes':{'true'}}
NAME=r'[A-Za-z_][A-Za-z0-9_.]*'

def need(ok,reason):
    if not ok:raise ValueError('NON_MECHANICAL_PROBE_CHANGE: '+reason)

def commands(raw):
    need(b'\r' not in raw,'CRLF not authorized')
    # No strings or quoted syntax occur in this grammar. Replace comments with
    # spaces while preserving line boundaries, so token concatenation is impossible.
    text=raw.decode();out=[];i=0;depth=0
    while i<len(text):
        if text[i:i+2]=='/-':depth+=1;out.extend('  ');i+=2
        elif depth and text[i:i+2]=='-/':depth-=1;out.extend('  ');i+=2
        elif depth:out.append('\n' if text[i]=='\n' else ' ');i+=1
        elif text[i:i+2]=='--':
            j=text.find('\n',i);j=len(text) if j<0 else j;out.extend(' '*(j-i));i=j
        else:out.append(text[i]);i+=1
    need(depth==0,'unterminated comment');seq=[]
    for line in ''.join(out).splitlines():
        line=line.strip()
        if not line:continue
        option=re.fullmatch(r'set_option[ \t]+('+NAME+r')[ \t]+(\w+)',line)
        if option:
            name,value=option.groups();need(value in DISPLAY_OPTIONS.get(name,set()),'NON_MECHANICAL_PROBE_OPTION: '+line)
            seq.append(['set_option',name,value]);continue
        m=re.fullmatch(r'(import|#check|assert_no_sorry|#print axioms|#print)[ \t]+('+NAME+r')',line)
        need(m is not None,'ambiguous probe syntax: '+line)
        seq.append(list(m.groups()))
    return seq

def template(entry):
    need(entry.get('grammar')==GRAMMAR and entry.get('artifact_kind')=='signature_probe','grammar/producer registration')
    need(entry.get('producer')=='completed_executor_file_change','unregistered producer')
    need(entry.get('gate') and entry['path']==f"Probes/{entry['gate']}Signatures.lean",'gate/path')
    imports=entry['imports'];names=entry['declarations']
    need(imports and len(imports)==len(set(imports)) and names and len(names)==len(set(names)),'inventory')
    opts=entry.get('printing_options',[])
    text='\n'.join('import '+n for n in imports)+'\n\n'
    if opts:text+='\n'.join('set_option '+n+' '+v for n,v in opts)+'\n\n'
    text+='\n\n'.join('\n'.join(cmd+' '+n for cmd in ['#check','assert_no_sorry','#print axioms']) for n in names)+'\n'
    commands(text.encode());return text.encode()

def normalize(raw):
    commands(raw)
    return ('\n'.join(x.rstrip(' \t') for x in raw.decode().split('\n')).rstrip('\n')+'\n').encode()

def compare(raw,entry):
    need(commands(raw)==commands(template(entry)),'probe command sequence differs')
    out=normalize(raw);need(commands(out)==commands(raw),'normalization changed commands');return out

def certificate(c,gate):
    from probe_whitespace import producer
    entry=json.loads((c.o/'artifacts.json').read_text())['generated_probes'][gate['id']]
    if entry.get('candidate_manifests'):
        from revision_probe import certificate as revision_certificate
        return revision_certificate(c,gate,entry)
    raw=(c.root/entry['path']).read_bytes();need(raw==compare(raw,entry),'probe is not canonical')
    state=c.status();identity=producer(c,gate,state,entry)
    names=entry['declarations'];audit=(c.root/'Audit.lean').read_text()
    for cmd in ('#check','assert_no_sorry','#print axioms'):
        actual=re.findall(r'^'+re.escape(cmd)+r' (\S+)\s*$',audit,re.M)
        need(all(actual.count(n)==1 for n in names),'audit target coverage')
    need(all(n.startswith('Aiyagari1994.M10B3.') or n=='Aiyagari1994.naturalBound_governmentDebt_correspondence' for n in names),'gate ownership')
    d=c.attempt_directory(gate,1)/'probe_whitespace';journals=[]
    for p in d.glob('*.json'):
        j=json.loads(p.read_text())
        if j.get('classification')==CLASSIFICATION:
            original=Path(j['original']).read_bytes()
            need(sha(original)==j['before_sha256'] and sha(raw)==j['after_sha256'],'probe journal hashes')
            need(compare(original,entry)==raw and commands(original)==commands(raw),'probe journal sequence')
            journals.append({'path':str(p),'sha256':sha(p.read_bytes()),'before_sha256':j['before_sha256'],'after_sha256':j['after_sha256']})
    need(len(journals)==1,'missing or ambiguous normalization provenance')
    return {'result':'PASS','classification':CLASSIFICATION,'gate':gate['id'],'contract':gate['contracts'],
            'path':entry['path'],'sha256':sha(raw),'command_sequence':commands(raw),
            'command_sequence_sha256':sha(canonical(commands(raw))),'printing_options':entry['printing_options'],
            'registry_sha256':sha(canonical(entry)),'producer':identity,'journals':journals,
            'semantic_declarations':0,'model_calls':0,'substantive_revisions':0}


def integration_certificates(c):
    """Read-only checks of every registered accepted probe; never normalize history."""
    from probe_whitespace import compare as registered_compare
    entries=json.loads((c.o/'artifacts.json').read_text())['generated_probes'];out={}
    prefix=c.git('rev-parse','--show-prefix').strip()
    for gid,entry in entries.items():
        raw=(c.root/entry['path']).read_bytes()
        need(c.tracked(entry['path']) and c.git('show','HEAD:'+prefix+entry['path']).encode()==raw,'accepted probe changed')
        if entry.get('candidate_manifests'):
            from revision_probe import resolve
            gate=next(g for g in c.gates if g['id']==gid)
            rec=c.acceptance_record(gate)
            # The accepted record pins the reviewed attempt and its revision.
            state=dict(c.status())
            reviewed=json.loads((c.root/rec['evidence_directory']/'deterministic_summary.json').read_text())
            state['revisions']=reviewed['generated_probe']['substantive_revision']
            selected,manifest,item,outbytes=resolve(c,gate,entry,state)
            need(outbytes==raw,'accepted probe not canonical')
        else:
            need(registered_compare(raw,entry)==raw,'accepted probe not canonical')
        out[gid]={'result':'PASS','path':entry['path'],'sha256':sha(raw),'registry_sha256':sha(canonical(entry))}
    return {'result':'PASS','probes':out}
