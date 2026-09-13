"""Strict parsing of complete Lean #print axioms records, not physical lines."""
import re

ALLOWED = frozenset({'propext', 'Classical.choice', 'Quot.sound'})

class AxiomEvidenceError(ValueError):
    pass

HEADER = re.compile(r"[ \t]*'([^\s]+)'\s+(depends\s+on\s+axioms\s*:|does\s+not\s+depend\s+on\s+any\s+axioms)")
NAME = re.compile(r'[^\s,\[\]\'";:]+')

def parse_axiom_records(text, expected=None):
    """SEARCH header -> EXPECT bracket -> ACCUMULATE list -> VALIDATE.

Lean's explicit 'does not depend on any axioms' is an empty record. Duplicate
permitted list items are harmless, but duplicate declarations are rejected.
Unrelated output is ignored only while searching, never inside a record.
"""
    records=[]; seen=set(); pos=0
    def malformed(detail):
        raise AxiomEvidenceError('AXIOM_EVIDENCE_MALFORMED: '+detail)
    while pos < len(text):
        end=text.find('\n',pos)
        if end<0: end=len(text)
        line=text[pos:end]
        match=HEADER.match(text,pos)
        if not match:
            if re.search(r'depend\w*\s+(?:on\s+)?(?:any\s+)?axiom',line,re.I) or re.match(r"\s*'.*'\s+(?:depends|does\s+not\s+depend)",line) or re.match(r"\s*'.*'.*axioms",line):
                malformed('unrecognized record header')
            pos=end+1; continue
        start=pos; name=match[1]
        if not name or any(c.isspace() for c in name): malformed('invalid declaration name')
        if name in seen: malformed('duplicate declaration '+name)
        pos=match.end(); axioms=[]
        if match[2].startswith('depends'):
            while pos<len(text) and text[pos].isspace(): pos+=1
            if pos==len(text) or text[pos]!='[': malformed('missing opening bracket for '+name)
            pos+=1; body_start=pos
            while pos<len(text) and text[pos]!=']':
                if text[pos]=='[': malformed('nested list for '+name)
                pos+=1
            if pos==len(text): malformed('truncated list for '+name)
            body=text[body_start:pos].strip();pos+=1
            if body:
                axioms=[x.strip() for x in body.split(',')]
                if any(not NAME.fullmatch(x) for x in axioms): malformed('invalid axiom list syntax for '+name)
        # Reject junk after a complete record; a new adjacent header is allowed.
        tail=pos
        while tail<len(text) and text[tail] in ' \t\r': tail+=1
        if tail<len(text) and text[tail]!='\n' and not HEADER.match(text,tail): malformed('trailing record syntax for '+name)
        unknown=set(axioms)-ALLOWED
        if unknown: raise AxiomEvidenceError('GENUINE_NONSTANDARD_AXIOM: '+name+': '+', '.join(sorted(unknown)))
        records.append({'declaration':name,'axioms':axioms,'raw':text[start:pos].strip()})
        seen.add(name);pos=tail
        if pos<len(text) and text[pos]=='\n':pos+=1
    if expected is not None:
        expected=list(expected)
        if len(expected)!=len(set(expected)) or len(records)!=len(expected) or seen!=set(expected):
            malformed('audited declaration/record coverage mismatch')
    return records
