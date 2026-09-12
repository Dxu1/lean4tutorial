# Milestone M03B2 - positive consumption under impatience

Date: 2026-09-12. Accepted baseline:
`390e5e9a3491a705f5b8bc3aee42b02bf693c2d4`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned scope: H10 only.

## Results against the contract

H10, `Aiyagari1994.consumption_positive_subcritical` in
`Aiyagari1994/Household/ConsumptionPositive.lean`: REVIEW_READY. Given BASIC primitives,
`UtilitySmooth m.utility`, strict `beta * R < 1`, and any positive `z : Resources`, it proves
strictly positive canonical consumption. It allows either a finite or infinite right marginal
of utility at zero.

H04 supplies the constructed canonical optimizer and H08 supplies the finite positive-state
right value marginal. H09 remains accepted but is not a proof dependency. All predecessor
statuses and theorem bodies are preserved. H06 and H11 onward remain UNFORMALIZED.

## Proof route and changes

`utilityZeroRightMarginal : ENNReal` represents the zero utility marginal without imposing
finiteness. Concavity proves its secant limit and positivity. In the finite branch, its real
value bounds utility increments. A finite-horizon Bellman induction proves the same global
bound for value when `beta*R<=1`; H02's uniform convergence passes it to the canonical fixed
point. A small transfer from saving to consumption then contradicts `beta*R<1` at a zero-
consumption corner. In the infinite branch, consuming an extra resource increment while
preserving saving forces the finite positive-state value marginal to dominate infinity, a
contradiction.

The generic endpoint and finite-horizon helpers are confined to
`Aiyagari1994/Analysis/M03B2/`. This is a local API organization choice. No theorem assumption,
quantifier, state coverage, dependency, or conclusion changed.

## Verification evidence

The signature probe and assigned-module build are recorded in
`reports/logs/m03b2/targeted_build.log`. Final evidence under `reports/logs/m03b2/` includes the
full substantive build, direct `Audit.lean`, contract checker, no-sorry and prohibited-pattern
scans, transitive axioms, documentation build, source hashes, and PDF QA. Exact signatures are
in `reports/m03b2_signatures.md`; the mathematical and source audit is in
`reports/m03b2_analytical_audit.md`.

## Adequacy audit

The state remains all `NNReal`, and the labor law remains the general compactly supported
probability measure. No positivity of effective income, atom, density, curvature, stationary
law, or asset bound is added. The economic value marginal at zero remains the distinct
`zeroRightMarginal : ENNReal`; no occurrence of `rightMarginalValue m 0` is used. The H10 proof
forms no marginal expectation and makes no real-integral interpretation beyond H01's already
proved bounded continuation integrals. P03 remains the inherited BASIC consistency witness.

The exact cited A93 and A94 pages were hash-verified, rendered, and inspected. A93 supplies
Appendix Proposition 2(a); A94 supplies equations (5)-(7). The explicit finite/infinite endpoint
argument is the architecture section 4.2 reconstruction. A successful build does not establish
economic adequacy.

## Blockers and review request

No implementation blocker remains. H10 is submitted at REVIEW_READY for external adequacy
review. No GREEN status is claimed. Stop at M03B2; H11 and later gates are not authorized. Per
the orchestrated-run override, no manual review ZIP was created.
