"""Exact authorized No-Ponzi source locator union; no web substitution."""
LOCATOR='A93 Appendix Proposition 1, printed p. 37 / PDF p. 38; A94 p. 666 / PDF p. 9, note 16.'
def resolve(root,catalog,assigned,sid):
    if len(assigned)!=1 or assigned[0]['id'] not in {'NP01','NP02','NP03'} or assigned[0]['stage']!='10' or assigned[0]['source_locator']!=LOCATOR or sid not in {'A93','A94'}:raise ValueError('Unauthorized Stage10a source')
    return ({38} if sid=='A93' else {9}),[('A93 Appendix Proposition1 printed37/PDF38' if sid=='A93' else 'A94 printed666/PDF9 note16')+'; detailed Lean finite-sum, convergence and finite-low-history measure arguments are project reconstructions.'],False
