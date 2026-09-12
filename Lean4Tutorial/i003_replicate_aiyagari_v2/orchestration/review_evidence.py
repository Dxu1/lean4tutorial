"""Deterministic source selection and narrowly scoped ledger status checks.

The source array's broader semantics are left intact. Exact manifest IDs in the
locator additionally require primary review evidence; prose never names files.
"""
import re

STATUSES = 'UNFORMALIZED|IN_PROGRESS|KERNEL_CHECKED|REVIEW_READY|GREEN|BLOCKED'

def locator_ids(contract, catalog):
    return {sid for sid in catalog if re.search(r'(?<![A-Za-z0-9_])'+re.escape(sid)+r'(?![A-Za-z0-9_])', contract.get('source_locator',''))}

def required_sources(contract, catalog):
    return set(contract['sources']) | locator_ids(contract,catalog)

def source_consistency(contracts, catalog):
    return [{'contract_id':t['id'], 'missing_from_sources':sorted(locator_ids(t,catalog)-set(t.get('sources',[]))),
             'source_locator':t.get('source_locator','')} for t in sorted(contracts,key=lambda t:t['id'])
            if locator_ids(t,catalog)-set(t.get('sources',[]))]

def ledger_errors(text, contracts):
    """Check explicit current assertions, never infer theorem adequacy from prose.

Historical exemptions are sentence-local, not paragraph-wide. Code fences are
excluded; metadata lines and explicit contract/status prose remain checked.
"""
    errors=[]; states={t['id']:t['status'] for t in contracts}
    overview=re.findall(r'^\*\*Economic status:\*\* (.*)$',text,re.M)
    observed={}
    if len(overview)==1:
        for ids,status in re.findall(r'([A-Z0-9, ]+) (?:is|are) \*\*('+STATUSES+r')\*\*',overview[0]):
            for sid in re.findall(r'\b[A-Z]+\d+\b',ids):
                if sid in observed: errors.append('duplicate overview '+sid)
                observed[sid]=status
    if observed!=states: errors.append('global overview differs from contracts')
    for sid,status in states.items():
        sections=re.findall(r'^## '+re.escape(sid)+r'\b[^\n]*\n(.*?)(?=^## |\Z)',text,re.M|re.S)
        if len(sections)!=1:
            errors.append('missing/duplicate section '+sid); continue
        body=sections[0]
        labels=re.findall(r'\*\*Status:\*\*\s*('+STATUSES+r')\b',body)
        if labels!=[status]: errors.append('section status '+sid)
        body=re.sub(r'```.*?```','',body,flags=re.S)
        for sentence in re.split(r'(?<=[.;])\s+|\n\n',body):
            sentence=' '.join(sentence.split())
            if re.match(r'(?:Historically,|At (?:the )?M\d+[A-Z0-9]* (?:acceptance|submission boundary)\b)',sentence): continue
            if status=='GREEN' and re.search(r'(?:still awaits? (?:economic |external )?review|economic adequacy remains for external review|(?:awaiting|pending) (?:external|independent|Astra) review|no GREEN status is claimed)',sentence,re.I):
                errors.append('accepted section awaits review '+sid)
            if status!='GREEN' and re.search(r'\b(?:'+re.escape(sid)+r'|[Tt]his contract|[Tt]he contract) (?:is GREEN|passed independent Astra review|is completed|has been accepted)\b',sentence):
                errors.append('unaccepted section claims completion '+sid)
            # Explicit cross-contract current statements, including "onward".
            for target,claimed in re.findall(r'\b([A-Z]+\d+) (?:is |are |remain |remains |onward remain )(?:now )?(?:separately )?('+STATUSES+r')\b',sentence):
                if target in states and states[target]!=claimed: errors.append('current prose '+target+' claims '+claimed)
    return errors

def evidence_repair_eligible(state, authorized_review_sha, actual_review_sha):
    """Exact human-authorized incident only, never a generic BLOCK recovery rule."""
    v=state.get('reviewer_verdict') or {}
    dims={d['dimension_id']:d['status'] for d in v.get('dimension_assessments',[])}
    expected={f'D{i:02d}' for i in range(1,21)}
    return (authorized_review_sha==actual_review_sha and state.get('gate')=='M03B2'
        and state.get('status')=='HUMAN_STOP' and state.get('attempt')==1
        and state.get('revisions')==0 and state.get('executor_effort_index')==0
        and state.get('executor_invocation_reason')=='INITIAL'
        and len(state.get('executor_history',[]))==1
        and state['executor_history'][0]=={'gate_id':'M03B2','attempt':1,'invocation_number':1,
            'model':'gpt-5.6-sol','reasoning_effort':'medium','reason':'INITIAL','substantive_round':1,'outcome':'COMPLETED'}
        and v.get('verdict')=='BLOCK' and v.get('confidence')=='HIGH'
        and set(dims)==expected and all(dims[d]=='PASS' for d in expected-{'D04','D16','D20'})
        and len(v.get('blocking_findings',[]))==2
        and {s.split(':',1)[0] for s in v['blocking_findings']}=={'D04','D16'})

if __name__ == '__main__':
    import json
    import sys
    from pathlib import Path
    root=Path(__file__).resolve().parents[1]
    contracts=json.loads((root/'contracts/theorems.json').read_text())['theorems']
    catalog={t['id']:t for t in json.loads((root/'contracts/source_manifest.json').read_text())['sources']}
    errors=ledger_errors((root/'docs/proof_ledger.md').read_text(),contracts)
    print(json.dumps({'policy':'structured sources UNION exact approved locator IDs; arrays preserved',
        'metadata_discrepancies':source_consistency(contracts,catalog),'ledger_errors':errors},indent=2))
    sys.exit(bool(errors))
