# Milestone report: M07A2 / N02 stationary bounded Jensen equality

Date: 2026-09-27. Assigned gate: M07A2. Assigned contract: N02 only. Accepted baseline from the
capsule: `a3c2afc8018b0182b671436a8c6c44793f36711c`.

## Results against the contract

N02, `Aiyagari1994.stationary_bounded_jensen_equality` in
`Aiyagari1994/Analysis/BoundedJensen.lean`: **REVIEW_READY**. For a positive measurable real
function with pointwise finite conditional means, `gamma>=1`, a pointwise superharmonic
inequality, and a supplied stationary law, the theorem proves `gamma=1` and equality of `q`
across the stationary one-step joint law. It assumes no finite stationary `E_pi[q]`.

Only N02's contract status changed. No GREEN status or later-contract advancement is awarded.

## Proof route and changes

The proof uses `psi(x)=x/(1+x)`, conditional mean `m=Pq`, and conditional bounded mean
`e=P(psi o q)`. It proves the exact tangent-gap identity required by architecture section 9.2,
uses it for Jensen's inequality, and closes the bounded chain
`e <= psi(m) <= psi(gamma*m) <= psi(q)`. Stationarity equates the integrals of its endpoints.
The middle equality and strict positivity of `m` force `gamma=1`. At the critical value, zero
conditional tangent gap forces `q(next)=m(current)` almost surely, while the last chain equality
forces `m(current)=q(current)` almost everywhere. Composition-product almost-everywhere calculus
then yields the contracted adjacent-pair equality.

The only new public declaration is the contracted target. No helper export was introduced. The
implementation is generic primitive mathematics and imports no economic theorem module.

## Verification evidence

`lake build Aiyagari1994.Analysis.BoundedJensen Probes.M07A2Signatures` completed successfully
with 2,589 jobs. The final `lake build` completed successfully with 2,881 jobs, including `All`
and `Audit`. Reported linters are inherited from M03F, M04A, and the diagnostic module; the N02
file introduces no build warning.

The sole new public declaration has `#check`, `assert_no_sorry`, and `#print axioms` coverage in
both `Audit.lean` and `Probes/M07A2Signatures.lean`. The full audit has 524
`assert_no_sorry` commands. The target's transitive axiom set is exactly `propext`,
`Classical.choice`, and `Quot.sound`.

`python3 tools/check_contracts.py` passed for 57 contracts and an acyclic dependency graph, with
status counts 30 GREEN, 1 REVIEW_READY, and 26 UNFORMALIZED. The manifest diff changes only
N02's `status` field. The source-only prohibited-pattern scan over the implementation and
signature probe found no match. `git diff --check` passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 59-page Markdown/TeX/PDF
ledger. Rendered PDF pages 49--52 were visually inspected after the final rebuild; pages 49--50
contain the complete N02 entry and its N03 boundary. There is no clipping, overlap, broken glyph,
or illegible text. The PDF SHA-256 is
`080b9ed9ebc1a354108946dd44e84eb5ed36ea322fa179cd6b5a5e51902a0df8`.

The verified environment is Lean 4.32.0 commit
`8c9756b28d64dab099da31a4c09229a9e6a2ef35` and Mathlib commit
`81a5d257c8e410db227a6665ed08f64fea08e997`. No fresh source-PDF inspection was performed; the
gate used only the capsule's approved extracts and inherited source qualifications. The
controller owns verification logs, export inventories, evidence, and review archives, so none
are created or edited here.

## Adequacy audit

The theorem distinguishes conditional integrability from stationary integrability exactly as
required. It never forms `Integral q pi`. Stationarity is applied only to the bounded transform.
All positivity, finite-conditional-mean, invariance, Markov, and probability premises are explicit.
The theorem makes no economic boundary claim and therefore does not misuse
`rightMarginalValue m 0`. See `reports/m07a2_analytical_audit.md` for the detailed audit.

## Blockers and review request

No N02 implementation blocker remains. Independent adequacy review is requested for N02 only.
Stop at REVIEW_READY; do not execute N03, N04, N05--N07, Stage 07b, Stage 08, or any later gate.
