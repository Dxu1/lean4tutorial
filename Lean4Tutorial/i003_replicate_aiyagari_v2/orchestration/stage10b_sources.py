"""Frozen exact extension locators; scanned A93 falls back to its approved original."""
CAP='A94 borrowing-limit discussion, printed pp. 672-673 / PDF pp. 15-16, and equation (2) on printed p. 666 / PDF p. 9.'
DEBT='A94 government-debt reinterpretation, printed pp. 673-674 / PDF pp. 16-17.'
def resolve(root,catalog,assigned,sid):
    if len(assigned)!=1 or assigned[0]['id'] not in {'E01','E02','E03'} or assigned[0]['stage']!='10' or sid not in {'A93','A94'}:raise ValueError('Unauthorized Stage10b source')
    t=assigned[0]
    if t['source_locator']!=(DEBT if t['id']=='E03' else CAP):raise ValueError('Stage10b source locator changed')
    if sid=='A93':return set(range(1,catalog[sid]['pdf_pages']+1)),['A93 is an explicit source ID without an extension-specific page locator. Approved hash-verified scanned original supplied because text extraction is empty; no invented page attribution. Exact extension statements use A94.'],True
    return ({16,17} if t['id']=='E03' else {9,15,16}),[t['source_locator']+' Exact Lean equality transport, feasible-plan bijection and measure-pushforward machinery are project reconstruction.'],False

def resolve_stage10(root,catalog,assigned,sid):
    if assigned and all(t['id'] in {'E01','E02','E03'} for t in assigned):return resolve(root,catalog,assigned,sid)
    from stage10a_sources import resolve as previous
    return previous(root,catalog,assigned,sid)
