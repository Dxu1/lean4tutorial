# Milestone report: M07A3 / N03 supercritical invariant-law exclusion

Date: 2026-09-27. Assigned gate: M07A3. Assigned contract: N03 only. Accepted baseline from the
capsule: `cf51164fc890ca6030f804b0f8aab5e48f6e95cf`.

## Results against the contract

N03, `Aiyagari1994.no_invariant_supercritical` in
`Aiyagari1994/Stationary/Supercritical.lean`: **REVIEW_READY**. Under BASIC, SMOOTH,
NONDEGENERATE, and `1 < beta*R`, it proves that no probability law on `NNReal` is invariant for
the canonical household kernel. It assumes neither a stationary marginal moment nor bounded
support of the candidate law.

Only N03's contract status changed. No GREEN status or later-contract advancement is awarded.

## Proof route and changes

Assuming an invariant candidate law, the proof replaces an infinite extended marginal by the
finite value one only on the null branch identified by N01. The resulting measurable real
function is pointwise positive. N01 supplies almost-everywhere current finiteness, conditional
next-marginal integrability, and H09's real superharmonic inequality. The household-kernel
pushforward and S01 integral identity transport those facts from labor shocks to the kernel.

The new gate-local helper
`Aiyagari1994.M07A3.stationary_bounded_jensen_ae_gamma_eq_one` adapts N02's approved bounded
strict-Jensen route to almost-everywhere conditional premises. It integrates only the bounded
transform `psi(x)=x/(1+x)` under the stationary law. Equality of bounded endpoint integrals and
strict positivity of the conditional mean force `beta*R=1`, contradicting supercriticality.

This helper is the sole local API adaptation. It neither changes N02 nor adds an economic
assumption. Both new public declarations are audited.

## Verification evidence

`lake build Aiyagari1994.Analysis.M07A3.BoundedJensenAE
Aiyagari1994.Stationary.Supercritical` completed successfully with 2,702 jobs after one local
elaboration correction. `lake build Probes.M07A3Signatures` then completed successfully with
2,703 jobs. The probe reports both declarations with transitive axiom set exactly `propext`,
`Classical.choice`, and `Quot.sound`.

The final `lake build` completed successfully with 2,883 jobs, including `All` and `Audit`.
Reported linter warnings are inherited from M03F, M04A, and the diagnostic module; neither M07A3
source file introduces a build warning. The global audit now contains 526 `assert_no_sorry`
commands. Both new declarations have matching `#check`, `assert_no_sorry`, and `#print axioms`
coverage in `Audit.lean` and the assigned probe.

`python3 tools/check_contracts.py` passed for 57 contracts and an acyclic dependency graph, with
status counts 31 GREEN, 1 REVIEW_READY, and 25 UNFORMALIZED. The manifest diff changes only N03's
`status` field. The source-only prohibited-pattern scan over the implementation and signature
probe found no match, and `git diff --check` passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 60-page Markdown/TeX/PDF ledger.
Rendered pages 50--51, containing the full N03 entry and its N04 boundary, were visually inspected
with Poppler output. There is no clipping, overlap, broken glyph, or illegible text. The PDF
SHA-256 is `69b3fddb334af68d09c3c1bfd2b4b5e0ad7842fd41226927b6a1704cf96b2353`.

The verified environment is Lean 4.32.0 commit
`8c9756b28d64dab099da31a4c09229a9e6a2ef35` and Mathlib commit
`81a5d257c8e410db227a6665ed08f64fea08e997`. No fresh source-PDF inspection was performed; the
gate used the capsule's approved extracts and inherited source qualifications.

The controller owns verification logs, export inventories, evidence, and review archives; none
are created or edited here.

## Adequacy audit

The proof uses `zeroRightMarginal : ENNReal` through `extendedRightMarginalValue` and never calls
`rightMarginalValue m 0`. It distinguishes N01's conditional integrability from stationary
`E[q]`, uses no S05 invariant-law construction outside strict impatience, and imports neither H10
nor H12. See `reports/m07a3_analytical_audit.md` for the full audit.

## Blockers and review request

No N03 implementation blocker remains. Independent adequacy review is requested for N03 only.
Stop at REVIEW_READY; do not execute N04, N05--N07, Stage 07b, Stage 08, or any later gate.
