# Milestone report: M09B1 / G02 finite-cap equilibrium existence

Date: 2026-10-06. Assigned gate: M09B1. Assigned contract: G02 only. Accepted baseline:
`445a4d5cac4a32a90b49161f623790e63fc3943d`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G02, `Aiyagari1994.finiteCap_equilibrium_exists` in
`Aiyagari1994/Equilibrium/Existence.lean`: **REVIEW_READY**.

For every finite `b>=0`, the theorem constructs an actual unchanged G01
`StationaryEquilibrium p hp` with rate in `(-delta,1/beta-1)`. Both the gate-local core theorem and
the public wrapper return explicit equalities retaining `m.beta`, `m.utility`, the complete
`m.income`, and the exact finite debt limit
`effectiveLimit b m.income.lower (firmWage p hp e.rate) e.rate`. The construction changes only the
household's endogenous normalized prices and does not identify them with the supplied `m.prices`.
It derives strict impatience before
using canonical stationary laws, proves continuity of actual net asset supply along F01's firm
schedule from P02 and A03, takes the lower sign from F02, derives the upper sign from B02 after
proving all critical price and firm limits, applies IVT, and fills every equilibrium field including
invariance, finite first moments, lifetime optimality, the actual kernel, budget normalization,
firm optimization, and capital clearing.

Only G02's contract status changed. G03, A04, A05, G04--G08, Stage 10, and all other unassigned
contracts remain unchanged. No positive-rate, uniqueness, monotonicity, comparison, or
every-equilibrium conclusion is claimed. No GREEN status or stage advancement is awarded.

## Verification and review boundary

The focused gate-local module build, `lake env lean Probes/M09B1Signatures.lean`, the full
`lake build`, and the direct `lake env lean Audit.lean` run all exited successfully; the full build
completed 3,129 jobs. Both new public declarations are registered for `#check`,
`assert_no_sorry`, and `#print axioms` in `Probes/M09B1Signatures.lean` and `Audit.lean`; the
focused probe and global audit report the strengthened signatures and only `propext`,
`Classical.choice`, and `Quot.sound`. The controller-owned export inventory will therefore record
the same two declaration names with their revised exact types; no orchestration inventory was
edited manually.

`python3 tools/check_contracts.py` passed all 57 contracts and reported exactly 42 GREEN, one
REVIEW_READY, and 14 UNFORMALIZED. The deterministic global-status reconciliation passed with G02
as the sole REVIEW_READY contract and G03 unchanged. The assigned-source prohibited-pattern scan,
accepted G01 byte-preservation check, and `git diff --check` all passed.

A94's manifest hash was confirmed, and printed pages 670--671 / PDF pages 13--14 were rendered and
visually inspected. They support the documented general-equilibrium interpretation and the notes
declining monotonicity and uniqueness; the formal continuity and IVT construction is identified as
a project proof.

`bash tools/build_docs.sh proof_ledger` rebuilt synchronized Markdown, TeX, and a 70-page PDF.
Ledger page 1 and pages 64--67 were rendered with Poppler and visually inspected. The opening
existence overview, both strengthened G02 signatures, the full proof entry, untouched G03
transition, headers, footers, and page numbering have no clipping, overlap, broken glyph, or
spacing defect. The PDF SHA-256 is
`06540577552301cb95edcb0a548b662f4f2687083835e2b16f86b5e23c2f2367`.

The controller owns review archives, so no manual ZIP is created. Independent adequacy review is
requested for G02 only. Stop at REVIEW_READY.
