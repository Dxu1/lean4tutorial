# Milestone report: M09D3 / G08 equilibrium goods-market clearing

Date: 2026-10-08. Assigned gate: M09D3. Assigned contract: G08 only. Accepted baseline:
`f8be0a64ec66ac185841d48743af943d487778f6`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G08, `Aiyagari1994.equilibrium_goods_market_clears` in
`Aiyagari1994/Equilibrium/Saving.lean`: **REVIEW_READY**.

For every unrestricted stationary equilibrium, the theorem proves that expected canonical
consumption plus replacement investment equals output at the equilibrium net capital stock. Only
G08's status changed. No GREEN status, Stage-10 result, or stage advancement is awarded.

## Proof route and exact dependencies

The equilibrium witness supplies finite resource and net-asset moments. The proof derives
shifted-saving and consumption integrability, uses compact support for labor integrability, and
integrates the actual canonical transition under the product of current resources and fresh iid
labor. Invariance yields the aggregate stationary resource budget. Exact original-price
normalization, mean-one labor, and the distinction `S=E(A-phi)` then give `E c=r*S+w`.
Accepted net-asset clearing identifies `S=K`. F01 supplies `f'(K)=r+delta`, and its competitive
wage definition is `w=f(K)-K*f'(K)`, yielding `E c+delta*K=f(K)`.

The exact dependencies are G01 and F01. The implementation uses no G02/G03 witness, G04
subcriticality, G06/G07 comparison, A02 stationary-law constructor, impatience restriction,
equilibrium uniqueness, or Stage-10 argument.

## Verification and review boundary

The following fresh checks completed with exit status zero:

- `lake build Aiyagari1994.Analysis.M09D3.GoodsClearing Aiyagari1994.Equilibrium.Saving`
- `lake env lean Probes/M09D3Signatures.lean`
- `lake build` (3141 jobs, including `All` and `Audit`)
- `lake env lean Audit.lean`
- `python3 tools/check_contracts.py` (57 contracts, acyclic dependency graph)
- `bash tools/build_docs.sh proof_ledger` (76-page PDF)
- `git diff --check` and the targeted prohibited-pattern scan

The M09D3 signature probe and global audit cover both new declarations with `#check`,
`assert_no_sorry`, and `#print axioms`; both axiom prints contain only `propext`,
`Classical.choice`, and `Quot.sound`. A baseline comparison confirms that the sole contract-field
change is G08 `status: UNFORMALIZED -> REVIEW_READY`. G01's accepted definition and semantic
fields are unchanged. The shared `Saving.lean` diff consists only of the authorized M09D3 header
import and the appended thin G08 wrapper; all accepted G07 bytes are preserved.

The synchronized ledger hashes are Markdown
`c6b9a4fb8c168651bf1e877ca77426fff5c6bca20f420d93864dca6113cc8e1c`, TeX
`7ac214c8026ff956a535fc52b6e00d52d8e880ac3d97c4b3ba58c9424189c1aa`, and PDF
`49317e45bc62f84dc610ba20eccab175266a69bef20b5b41168390b1035c084d`. Rendered ledger pages 1 and
72--76 were visually inspected; the global overview, G08 entry, and unchanged Stage-10 boundary
are legible with no clipping or overlap.

A94 printed pp. 670--671 / original PDF pp. 13--14 supplies the approved factor-pricing and
aggregate-accounting motivation. Both repository copies match the manifest's original SHA-256
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f` and byte count 1,394,274;
original PDF pages 13--14 were freshly rendered and visually inspected, including notes 24--27.
The exact moment and product-transition proof is a project reconstruction. The controller owns
verification logs and review archives, so no manual log or ZIP is created. Independent adequacy
review is requested for G08 only. Stop at REVIEW_READY.

REVIEW_CONTEXT_COMPLETE: G08 implementation, analytical audit, exact signature probe, global
audit coverage, frozen contract metadata with status-only transition, and synchronized ledger
Markdown/TeX/PDF are present for controller verification and independent review.
