"""Approved Stage-09a A94 page mapping; no later-stage implementation authority."""
def resolve(root,catalog,assigned,sid):
    if not assigned or any(t['stage']!='09' or t['id'] not in {'F01','G01','F02'} for t in assigned):
        raise ValueError('Unauthorized Stage09a contract')
    if sid!='A94':raise ValueError('Unresolved Stage09a source: '+sid)
    for t in assigned:
        if t['id'] in {'F01','G01'}:
            assert 'printed pp. 670-671 / PDF pp. 13-14' in t['source_locator']
        else:
            assert 'New derived lower-bracket lemma' in t['source_locator']
    return {13,14},['A94 printed 670-671 / original PDF 13-14; firm and equilibrium discussion including notes 24-27. Explicit production primitives, sqrt witness, resource/asset-law formal equivalence and derived lower bracket are project constructions, not literal source proofs.'],False
