"""Resolve Stage-06 source abbreviations using frozen approved authority."""
import re,json

def resolve(root,catalog,assigned,sid):
    assert all(t['stage']=='06' for t in assigned)
    pages=set();notes=[];full=False
    for t in assigned:
        if sid not in t['sources'] and not re.search(r'\b'+sid+r'\b',t['source_locator']):continue
        clauses=[x.strip() for x in t['source_locator'].split(';') if re.search(r'\b'+sid+r'\b',x)]
        if sid=='C90' and t['id']=='A03' and not clauses:
            pages.update(range(1,catalog[sid]['pdf_pages']+1));full=True
            notes.append('A03 structured source C90 has no page locator; exact approved full original included, no page attribution invented.');continue
        assert clauses, 'missing source clause '+sid
        for clause in clauses:
            hit=re.search(r'PDF\s+pp?\.\s*(\d+)(?:\s*[-–]\s*(\d+))?',clause)
            if hit:
                pages.update(range(int(hit[1]),int(hit[2] or hit[1])+1));notes.append(clause);continue
            if sid=='A93' and 'Proposition 5' in clause:
                contracts=json.loads((root/'contracts/theorems.json').read_text())['theorems'];authority=next(x for x in contracts if x['id']=='S05')
                assert 'A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41' in authority['source_locator']
                pages.update([40,41]);notes.append(clause+'; resolved via accepted S05 source locator: printed 39-40 / PDF 40-41');continue
            raise ValueError('unresolved Stage06 source locator: '+clause)
    assert pages and all(1<=p<=catalog[sid]['pdf_pages'] for p in pages)
    return pages,notes,full
