"""Human-readable reference grammar; structured manifest statuses stay authoritative."""
import re
ID=r'[A-Z]+[0-9]+'

def parse_ids(text,known):
    """ID (',' ID)* [ [','] ('and'|'&') ID ]; conjunction is final only."""
    tokens=[];pos=0
    while pos<len(text):
        if text[pos].isspace():pos+=1;continue
        m=re.match(ID+r'\b|and\b|[,&]',text[pos:])
        if not m:raise ValueError('invalid contract reference list')
        tokens.append(m[0]);pos+=m.end()
    result=[];i=0
    def take_id():
        nonlocal i
        if i>=len(tokens) or not re.fullmatch(ID,tokens[i]):raise ValueError('missing contract ID')
        value=tokens[i];i+=1
        if value not in known:raise ValueError('unknown contract ID '+value)
        if value in result:raise ValueError('duplicate contract ID '+value)
        result.append(value)
    take_id()
    while i<len(tokens):
        separator=tokens[i];i+=1
        if separator==',':
            if i<len(tokens) and tokens[i] in ('and','&'):
                i+=1;take_id()
                if i!=len(tokens):raise ValueError('conjunction must end list')
            else:take_id()
        elif separator in ('and','&'):
            take_id()
            if i!=len(tokens):raise ValueError('conjunction must end list')
        else:raise ValueError('missing list separator')
    return result

def parse_overview(line,known,statuses):
    """Only the established semicolon-separated overview status slots, before its prose."""
    result={}
    for clause in line.split('.',1)[0].split(';'):
        m=re.fullmatch(r'\s*(.*?)\s+(?:is|are)\s+\*\*('+statuses+r')\*\*\s*',clause)
        if not m:raise ValueError('invalid overview status clause')
        for cid in parse_ids(m[1],known):
            if cid in result:raise ValueError('duplicate overview '+cid)
            result[cid]=m[2]
    return result

def prose_claims(sentence,known,statuses):
    """Only reference-list slots immediately preceding an existing status predicate.

    Ordinary prose conjunctions (e.g. E02 proves X and preserves Y) are not slots.
    Historical and fenced-code exemptions are handled by the caller unchanged.
    """
    slot=r'('+ID+r'(?:(?:\s+and\b)|[\s,&]|(?:'+ID+r'))*)'
    predicate=r'(?:is|are|remain|remains|onward remain)\s+(?:now\s+)?(?:separately\s+)?'
    for m in re.finditer(r'\b'+slot+r'\s+'+predicate+'('+statuses+r')\b',sentence):
        yield parse_ids(m[1],known),m[2]
