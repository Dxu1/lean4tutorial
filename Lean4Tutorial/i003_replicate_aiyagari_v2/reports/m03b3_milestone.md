# Milestone M03B3 - local value envelope theorem

Date: 2026-09-12. Accepted baseline:
`3b96d6654a2cc0771818ba0f6a381b497a5dae36`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned scope: H11 only.

## Results against the contract

H11, `Aiyagari1994.value_envelope_at_positive_consumption` in
`Aiyagari1994/Household/Envelope.lean`: REVIEW_READY. For BASIC household primitives,
SMOOTH utility, a positive resource state, and positive canonical consumption, it proves that the
real value extension has derivative `deriv U c(z)` at `z` and that the accepted positive-state
`rightMarginalValue` equals this derivative. There is no `beta * R < 1` premise.

The new generic declaration `Aiyagari1994.concave_hasDerivAt_of_lowerTouching` is in
`Aiyagari1994/Analysis/M03B3/LowerTouching.lean`. H03 supplies concavity, H04 supplies the
constructed optimizer and Bellman equality, and H08 supplies the positive-state right-marginal
secant limit used for the final identification. H10 is not imported or used. All predecessor
contract statuses and theorem bodies are preserved. H06 and H12 onward remain UNFORMALIZED.

## Proof route and changes

The one-dimensional helper constructs the right derivative of a finite concave function at an
interior point. Concavity places its right derivative below every left secant. A differentiable
local lower touch bounds right secants from below and left secants from above. The resulting two
squeezes identify both one-sided limits with the touching derivative, proving a full derivative.

For H11, the touching function keeps the actual shifted asset choice `A(z)` fixed. Since
`c(z)>0`, the action remains feasible on the two-sided state neighborhood `x>A(z)`, where current
consumption is also positive. Bellman optimality makes this function no larger than value and the
canonical Bellman identity makes it equal at `z`. SMOOTH differentiates only the current utility
term; the continuation is constant in the state perturbation. The lower-touching lemma gives the
full envelope derivative and uniqueness of the right limit identifies it with H08's marginal.

The generic helper is confined to the assigned gate's Analysis subdirectory. Returning both the
`HasDerivAt` certificate and the equality to `rightMarginalValue` makes the contract's derivative
and marginal identity explicit. This is an interface elaboration, not a change to assumptions,
quantifiers, state coverage, dependencies, or conclusion strength.

## Verification evidence

The following commands were run with output to stdout, as required by the mechanical evidence
policy; the controller owns persisted check logs:

- `lake build Aiyagari1994.Analysis.M03B3.LowerTouching Aiyagari1994.Household.Envelope Probes.M03B3Signatures`
- `lake env lean Probes/M03B3Signatures.lean`
- `lake build`
- `lake env lean Audit.lean`
- `python3 tools/check_contracts.py`
- targeted prohibited-pattern and baseline-scope scans with `rg` and `git diff`
- `bash tools/build_docs.sh proof_ledger`
- `pdftoppm` rendering and visual inspection of the H11 ledger pages

Every listed required check exited 0. Exact signatures are in `reports/m03b3_signatures.md`.
Direct audit reports exactly `[propext, Classical.choice, Quot.sound]` for both new exports. The
synchronized ledger PDF is `docs/proof_ledger.pdf`; title/status page 1 and affected H11 pages
24-25 were visually inspected with no clipping, overlap, broken glyphs, or unreadable text.

The optional `pdftotext` utility and Python `pypdf` module were unavailable; neither was needed
for the required visual QA, which used successful Poppler rendering. No required check was skipped.

## Adequacy audit

The state remains all `NNReal`, and the labor law remains the general compactly supported
probability measure. H11 adds only `UtilitySmooth`, `z>0`, and `c(z)>0` to BASIC. It adds no
impatience, curvature, endpoint, atom, density, nondegeneracy, stationary-law, or asset-bound
condition. The primitive consistency witness P03 is inherited unchanged.

The theorem never evaluates `rightMarginalValue m 0`. The economic zero-state object remains the
distinct `zeroRightMarginal : ENNReal`, which may be infinite. No marginal expectation is formed
and no differentiation under an integral occurs. The continuation term is fixed, and its bounded
real integral is the already-proved H01 object.

The approved source files were hash-verified and their exact pages rendered and inspected. A93
Appendix Proposition 2(c), printed pp. 37-38 / PDF pp. 38-39, states the envelope equality and
attributes it to Benveniste-Scheinkman. BS79 Lemma 1, printed p. 728 / PDF p. 3, supplies the
lower-touching criterion. The mathematical lemma is proved in Lean rather than treated as an
external theorem axiom. A successful build does not establish economic adequacy.

## Blockers and review request

No implementation blocker remains. H11 is submitted at REVIEW_READY for independent adequacy
review. No GREEN status is claimed. Stop at M03B3; H12 and later gates are not authorized. Per the
orchestrated-run override, no manual review ZIP was created.
