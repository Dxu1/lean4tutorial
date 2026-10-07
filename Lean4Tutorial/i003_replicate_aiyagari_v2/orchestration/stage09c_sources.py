"""Approved certainty/headline page mapping; historical resolvers remain unchanged."""
def resolve(root,catalog,assigned,sid):
    ids={t['id'] for t in assigned}
    if len(ids)!=1 or not ids<={'A04','A05','G04','G05'} or any(t['stage']!='09' for t in assigned):raise ValueError('Unauthorized Stage09c contract')
    cid=assigned[0]['id'];locator=assigned[0]['source_locator']
    if sid=='A94':
        if cid in ('A04','A05'):
            assert 'PDF pp. 12-13' in locator and 'PDF p. 14' in locator
            return {12,13,14},['A94 printed669-671 / original PDF12-14, notes22-23 and deterministic benchmark. Global deterministic convergence and complete comparison proofs are project reconstructions.'],False
        assert 'PDF pp. 13-14' in locator
        return {13,14},['A94 printed670-671 / original PDF13-14, notes24-27. Universal G01+N07 argument and global concavity/present-value certainty verification are project reconstructions. No later capital/saving result certified.'],False
    if sid=='A93' and cid in ('A04','G04'):
        assert 'A93' in assigned[0]['sources'] and 'PDF 12–23, 38–41' in catalog[sid]['priority_locator']
        return set(range(12,24))|set(range(38,42)),['Structured A93 source has no narrower contract locator; approved priority context PDF12-23,38-41. Do not overattribute the reconstructed deterministic and universal-equilibrium proofs.'],False
    raise ValueError('Unresolved Stage09c source: '+sid)

def resolve_stage09(root,catalog,assigned,sid):
    if assigned and all(t['id'] in {'A04','A05','G04','G05'} for t in assigned):return resolve(root,catalog,assigned,sid)
    from stage09b_sources import resolve_stage09 as previous
    return previous(root,catalog,assigned,sid)
