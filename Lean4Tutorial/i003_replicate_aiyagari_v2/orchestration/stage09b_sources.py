"""Exact approved existence-source mapping; keep Stage09a resolution unchanged."""
def resolve(root,catalog,assigned,sid):
    ids={t['id'] for t in assigned}
    if not ids or not ids<={'G02','G03'} or any(t['stage']!='09' for t in assigned):raise ValueError('Unauthorized Stage09b contract')
    if sid=='A94' and ids=={'G02'}:
        assert 'printed pp. 670-671 / PDF pp. 13-14' in assigned[0]['source_locator']
        return {13,14},['A94 printed670-671 / original PDF13-14, especially notes24-27. IVT, boundary specialization and full equilibrium construction are project proofs; no uniqueness or positive-rate claim.'],False
    if sid=='A94' and ids=={'G03'}:
        assert 'printed p. 673 / PDF p. 16' in assigned[0]['source_locator']
        return {15,16},['A94 printed673 / original PDF16, note30; adjacent printed672/PDF15 supplies immediate natural-limit context. Full IVT equilibrium construction is a project proof.'],False
    if sid=='A93' and ids=={'G03'}:
        assert 'A93' in assigned[0]['sources'] and 'PDF 12–23, 38–41' in catalog[sid]['priority_locator']
        return set(range(12,24))|set(range(38,42)),['G03 structured source A93 has no narrower locator; approved priority context printed11-22,37-40 / PDF12-23,38-41. No new literal source theorem attribution; equilibrium proof is reconstructed.'],False
    raise ValueError('Unresolved Stage09b source: '+sid)

def resolve_stage09(root,catalog,assigned,sid):
    if assigned and all(t['id'] in {'F01','G01','F02'} for t in assigned):
        from stage09a_sources import resolve as old
        return old(root,catalog,assigned,sid)
    return resolve(root,catalog,assigned,sid)
