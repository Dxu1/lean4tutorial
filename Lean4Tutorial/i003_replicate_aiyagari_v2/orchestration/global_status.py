"""Compact deterministic global contract/ledger evidence for every review snapshot."""
import hashlib,json,re
from review_evidence import ledger_errors

def overview(root,gate):
    paths={'contracts_theorems':'contracts/theorems.json','proof_ledger_md':'docs/proof_ledger.md','proof_ledger_tex':'docs/proof_ledger.tex'}
    raw={k:(root/p).read_bytes() for k,p in paths.items()}
    contracts=json.loads(raw['contracts_theorems'])['theorems'];text=raw['proof_ledger_md'].decode()
    states={t['id']:t['status'] for t in contracts}
    errors=ledger_errors(text,contracts)
    if len(states)!=len(contracts):errors.append('duplicate contract ID')
    assigned=[t for t in contracts if t['id'] in gate['contracts']]
    if len(assigned)!=len(gate['contracts']):errors.append('assigned contract missing')
    stage=max(((int(re.fullmatch(r'(\d+)([a-z]?)',t['stage'])[1]),re.fullmatch(r'(\d+)([a-z]?)',t['stage'])[2]) for t in assigned),default=(-1,''))
    future={t['id']:t['status'] for t in contracts if (int(re.fullmatch(r'(\d+)([a-z]?)',t['stage'])[1]),re.fullmatch(r'(\d+)([a-z]?)',t['stage'])[2])>stage}
    if any(v!='UNFORMALIZED' for v in future.values()):errors.append('future-stage status leakage')
    if errors:raise ValueError('REVIEW_CONTEXT_INCOMPLETE: global status: '+ '; '.join(errors))
    return {'current_gate':gate['id'],'assigned_contracts':gate['contracts'],'contracts':states,
        'canonical_ledger_overview':re.findall(r'^\*\*Economic status:\*\*[^\n]*',text,re.M)[0],
        'accepted_predecessor_statuses':{k:v for k,v in states.items() if v=='GREEN' and k not in gate['contracts']},
        'future_contracts':future,'unformalized_contracts':[k for k,v in states.items() if v=='UNFORMALIZED'],
        'hashes':{k:hashlib.sha256(b).hexdigest() for k,b in raw.items()},
        'global_consistency':{'result':'PASS','errors':[],'producer':'orchestration.global_status.overview / review_evidence.ledger_errors'},
        'tex_note':'TeX hash binds the generated artifact; deterministic documentation verification separately checks regeneration against Markdown.'}
