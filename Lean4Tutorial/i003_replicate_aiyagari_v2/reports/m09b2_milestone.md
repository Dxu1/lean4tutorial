# Milestone report: M09B2 / G03 natural-cap equilibrium existence

Date: 2026-10-06. Assigned gate: M09B2. Assigned contract: G03 only. Accepted baseline:
`b756f3d21530728a30a99534ea4aadcf60d796f3`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G03, `Aiyagari1994.naturalCap_equilibrium_exists` in
`Aiyagari1994/Equilibrium/Existence.lean`: **REVIEW_READY**.

The theorem constructs an actual unchanged G01 `StationaryEquilibrium p hp` with
`0<r<1/beta-1`. It retains the supplied beta, utility, and complete income law and identifies the
original debt limit exactly as `naturalLimit l_min w(r) r`. On the strictly positive natural-limit
domain it proves impatience before stationarity, derives continuity of actual net asset supply from
F01/P02/A03, derives the lower sign from B03 along the actual firm wage schedule, derives the upper
sign from B02 after proving all firm, normalized-price, and finite-shift limits, applies IVT, and
fills every G01 field including invariance, finite first moments, lifetime optimality, the actual
kernel, budget normalization, firm optimization, and capital clearing.

Only G03's contract status changed. G02 and all accepted predecessors remain unchanged; A04, A05,
G04--G08, Stage 10, and every other unassigned contract remain unchanged. No uniqueness,
monotonicity, comparison, every-equilibrium, or later-stage conclusion is claimed. No GREEN status
or stage advancement is awarded.

## Verification and review boundary

The focused gate-local module build, `lake env lean Probes/M09B2Signatures.lean`, the full
`lake build`, and the direct `lake env lean Audit.lean` run all exited successfully; the full build
completed 3,130 jobs. Both new public declarations are registered for `#check`,
`assert_no_sorry`, and `#print axioms` in `Probes/M09B2Signatures.lean` and `Audit.lean`; both
audits report the exact strengthened signatures and only `propext`, `Classical.choice`, and
`Quot.sound`.

`python3 tools/check_contracts.py` passed all 57 contracts and reported exactly 43 GREEN, one
REVIEW_READY, and 13 UNFORMALIZED. The G03 manifest diff changes its status only. The assigned-file
prohibited-pattern scan and `git diff --check` passed. The pre-existing G02 declaration and proof
remain byte-for-byte present in the shared existence module; only the new helper import and G03
wrapper were added.

`bash tools/build_docs.sh proof_ledger` rebuilt synchronized Markdown, TeX, and a 71-page PDF.
Rendered page 1 and pages 66--71 were visually inspected. The opening status overview, G03 exact
signatures and proof, the transition to untouched later contracts, headers, footers, and page
numbering have no clipping, overlap, broken glyph, or spacing defect. The PDF SHA-256 is
`f6486ad78be2373fd3d5368600a112f0f2f6fb5a8ae09fa561961d1dabe2cca5`.

A94 printed p. 673 / PDF p. 16, note 30, with adjacent PDF p. 15, is the approved motivating
locator. G03's A93 evidence remains the approved structured priority context and hash, not a web
substitute. The formal firm-path limits, continuity and IVT argument are identified as project
proofs.

The controller owns review archives, so no manual ZIP is created. Independent adequacy review is
requested for G03 only. Stop at REVIEW_READY.
