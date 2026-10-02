"""Stage-08 approved source resolver; reconstructions are explicitly distinguished."""
import json

def resolve(root,catalog,assigned,sid):
    assert all(t['stage']=='08' for t in assigned)
    ids={t['id'] for t in assigned}
    if sid=='SLP89' and ids=={'B01'}:
        ts=json.loads((root/'contracts/theorems.json').read_text())['theorems']
        locator=next(t for t in ts if t['id']=='S06')['source_locator']
        assert 'SLP89 Theorem 12.13, printed pp. 384-385 / PDF pp. 394-395' in locator
        return {394,395},['B01 related Theorem 12.13 resolved by accepted S06 locator: SLP89 printed 384-385 / PDF 394-395. The noncompact tight-tail passage is a project proof, not attributed to this source.'],False
    if sid=='C90' and ids<={'B02','B03'}:
        assert 'Proposition 2.4, printed 548; PDF 7' in catalog[sid]['priority_locator']
        return {6,7},['C90 Proposition 2.4 printed 548 / PDF 7; preceding PDF 6 (printed 547) supplies immediate assumptions. Boundary result stated without proof.'],False
    if sid=='A94' and ids=={'B02'}:
        return {11,12},['A94 note 19 and upper-boundary discussion: printed 668 / PDF 11, with immediate continuation printed 669 / PDF 12. The tightness/B01/N07 proof is a reconstruction, not a pathwise-divergence claim.'],False
    if sid=='A94' and ids=={'B03'}:
        return {15,16},['A94 natural-limit discussion printed 673 / PDF 16; immediate preceding context printed 672 / PDF 15. Normalized-coordinate proof is a project reconstruction.'],False
    if sid=='A93' and ids=={'B03'}:
        assert 'PDF 12–23, 38–41' in catalog[sid]['priority_locator']
        return set(range(12,24))|set(range(38,42)),['B03 structured source A93 has no narrower contract locator; approved priority context printed 11–22, 37–40 / PDF 12–23, 38–41. No new literal source theorem attribution.'],False
    raise ValueError('Unresolved Stage08 source: '+sid)
