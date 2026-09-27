# Milestone report: M07A1 / N01 stationary zero-state marginal

Date: 2026-09-27. Assigned gate: M07A1. Assigned contract: N01 only. Accepted baseline from the
capsule: `a38e76f7557fca91bf08c4230f39f88d27b4cf61`.

## Results against the contract

N01, `Aiyagari1994.stationary_zero_state_marginal_resolved` in
`Aiyagari1994/Stationary/ZeroState.lean`: **REVIEW_READY**. For an arbitrary candidate invariant
probability law at any primitive-admissible positive gross return, an infinite
`zeroRightMarginal` forces zero stationary mass at zero. The extended marginal is then finite and
positive almost everywhere, and H09 supplies conditional next-marginal finiteness, integrability,
and its real superharmonic inequality.

Only N01's contract status changed. No GREEN status or later-contract advancement is awarded.

## Proof route and changes

The helper implementation in `Aiyagari1994/Analysis/M07A1/ZeroState.lean` first proves that
endpoint nondegeneracy makes zero-income probability strictly below one. When this probability is
positive and the boundary marginal is infinite, H09 conditional finiteness excludes zero optimal
saving from every positive state. The household kernel therefore reaches zero only from zero,
with probability equal to the zero-income probability. The invariant singleton equation forces
zero stationary mass. If zero-income probability is zero, zero has no incoming mass directly.

Finite boundary marginal gives extended marginal finiteness everywhere. Infinite boundary
marginal leaves zero as the only possible infinite point, and that point is stationary-null. H08
provides positivity. H09 is applied only on the resulting almost-everywhere finite set, after
which its real conditional integral is legitimate. The public helpers are
`M07A1.invariant_zero_measure_of_boundary_infinite`,
`M07A1.extendedRightMarginalValue_pos`, and
`M07A1.invariant_extendedMarginal_finite_ae`.

The only local API adaptation is to express candidate invariance directly as
`householdKernel m ∘ₘ pi = pi`, avoiding any use of S05's strict-impatience law constructor. There
is no change to assumptions, quantifiers, declaration meaning, continuous state space, or general
compact iid income law.

## Verification evidence

`lake build Aiyagari1994.Analysis.M07A1.ZeroState Aiyagari1994.Stationary.ZeroState` completed
successfully with 2,696 jobs. `lake build Probes.M07A1Signatures All Audit` completed successfully
with 2,880 jobs, and the final `lake build` completed successfully with 2,880 jobs. Reported
linters are inherited from M03F, M04A, and the diagnostic module; the M07A1 files introduce no
build warning.

All four new public declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage in
both `Audit.lean` and `Probes/M07A1Signatures.lean`. The full audit has 523
`assert_no_sorry` commands. Each new declaration's transitive axiom set is exactly `propext`,
`Classical.choice`, and `Quot.sound`.

`python3 tools/check_contracts.py` passed for 57 contracts and an acyclic dependency graph, with
status counts 29 GREEN, 1 REVIEW_READY, and 27 UNFORMALIZED. The manifest diff changes only N01's
`status` field. The source-only prohibited-pattern scan over both implementation files and the
signature probe found no match. `git diff --check` passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 58-page Markdown/TeX/PDF ledger.
Rendered PDF pages 47--49, covering the A05/N01 boundary, all of N01, and the N01/N02 boundary,
were visually inspected after the final rebuild. There is no clipping, overlap, broken glyph, or
illegible text. The PDF SHA-256 is
`f03be3ef8b99a936e5097d7223f949925272b6d6096ebdd565a35600991c51dd`.

The verified environment is Lean 4.32.0 commit
`8c9756b28d64dab099da31a4c09229a9e6a2ef35` and Mathlib commit
`81a5d257c8e410db227a6665ed08f64fea08e997`. No fresh source-PDF inspection was performed; the
gate used only the capsule's approved extracts and inherited source qualifications. The
controller owns verification logs, export inventories, evidence, and review archives, so none
were created or edited here.

## Adequacy audit

The theorem retains explicit SMOOTH and NONDEGENERATE premises, with BASIC inherited from
`HouseholdPrimitives`. It assumes rather than constructs an invariant law, so it is valid at
arbitrary admissible returns and does not borrow strict impatience from S05. At zero it uses only
`zeroRightMarginal : ENNReal`. Conditional integrability is proved state by state after extended
finiteness; no stationary marginal moment is assumed or concluded. H10, H11, and H12 are not used.
See `reports/m07a1_analytical_audit.md` for the detailed audit.

## Blockers and review request

No N01 implementation blocker remains. Independent adequacy review is requested for N01 only.
Stop at REVIEW_READY; do not execute N02, N03, N04, N05--N07, Stage 07b, Stage 08, or any later
gate.
