"""Approved Stage-07a source pages; new reconstructions are not source theorems."""
def resolve(root,catalog,assigned,sid):
    assert all(t['stage']=='07a' for t in assigned)
    if sid=='CW00':
        authority=(root/'docs/architecture.md').read_text();assert 'Sections 2–4' in authority
        return set(range(4,19)),['Architecture source table: CW00 Sections 2–4, printed 368–382 / PDF 4–18; section headings verified against the hash-approved original. Background only; bounded-Jensen proof is a new reconstruction.'],False
    if sid=='A94':return {12},['Exact contract locator: A94 printed 669 / PDF 12, notes 20–21.'],False
    if sid=='A93':
        assert any(t['id']=='N03' and sid in t['sources'] for t in assigned)
        assert 'PDF 12–23, 38–41' in catalog[sid]['priority_locator']
        return set(range(12,24))|set(range(38,42)),['N03 structured A93 source has no narrower locator; approved source-manifest priority pages: printed 11–22, 37–40 / PDF 12–23, 38–41.'],False
    raise ValueError('Unresolved Stage07a source: '+sid)
