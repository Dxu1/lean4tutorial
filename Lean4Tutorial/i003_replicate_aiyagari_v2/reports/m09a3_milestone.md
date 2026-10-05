# Milestone report: M09A3 / F02 finite-cap lower bracket

Date: 2026-10-04. Assigned gate: M09A3. Assigned contract: F02 only. Accepted baseline:
`22ff42167fb9726234ede80aafd385a91eba0b11`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

F02, `Aiyagari1994.finiteCap_lower_bracket` in
`Aiyagari1994/Equilibrium/LowerBracket.lean`: **REVIEW_READY**.

For every finite `b>=0`, the theorem derives positive `K_L` and a rate
`r_L=f'(K_L)-delta` in `(-delta,0)`, identifies `K(r_L)=K_L`, constructs admissible finite-cap
original and normalized prices with debt limit exactly `b`, derives positive gross return and
strict impatience, and proves that canonical stationary net asset supply is strictly below capital
demand. The strict lower sign is a conclusion, not a premise.

The proof first derives `f(K)/K->0` from the tangent bound and vanishing marginal product. A02 is
used only after `beta*(1+r_L)<1` is proved. Its integrable stationary consumption identity and
mean-one labor imply `0<=E[c]=w_L+r_L*S`, hence `S<=w_L/(-r_L)<K_L`.

Only F02's contract status changed. G02, G03, A04, A05, G04--G08, Stage 10, and all other
unassigned contracts remain unchanged. No equilibrium-existence theorem is implemented. No GREEN
status or stage advancement is awarded.

## Verification and review boundary

The focused module build, `lake env lean Probes/M09A3Signatures.lean`, the full `lake build`, and
the direct `lake env lean Audit.lean` run all exited successfully; the full build completed 3,127
jobs.
`python3 tools/check_contracts.py` passed all 57 contracts and reported exactly 41 GREEN, one
REVIEW_READY, and 15 UNFORMALIZED. The deterministic global-status reconciliation passed with F02
as the sole REVIEW_READY contract. The changed-file prohibited-pattern scan and `git diff --check`
also passed.

All six new public declarations are registered for `#check`, `assert_no_sorry`, and
`#print axioms` in `Probes/M09A3Signatures.lean` and `Audit.lean`. The dedicated probe reports only
`propext`, `Classical.choice`, and `Quot.sound`.

`bash tools/build_docs.sh proof_ledger` rebuilt synchronized Markdown, TeX, and a 68-page PDF.
Ledger page 1 and pages 61--64 were rendered with Poppler and visually inspected. The global status,
complete F02 entry, accepted G01 boundary, and untouched G02/G03 transitions have no clipping,
overlap, broken glyph, or header/footer defect. The PDF SHA-256 is
`9fc700ba1e235e953aba4d37b428868c86cfe25e08117409d747d736b110659f`.

The controller owns review archives, so no manual ZIP is created. Independent adequacy review is
requested for F02 only. Stop at REVIEW_READY.
