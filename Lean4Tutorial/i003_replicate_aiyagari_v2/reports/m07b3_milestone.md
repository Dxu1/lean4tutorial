# Milestone report: M07B3 / N07 combined nonstationarity

Date: 2026-10-02. Assigned gate: M07B3. Assigned contract: N07 only. Accepted baseline:
`7abd34d6e86d7ae7ebd8bbbdd63f1e1890d522ca`. This gate was executed at Sol Medium from the
controller-supplied capsule. Controller-owned orchestration state, evidence, inventories, logs,
and review archives were not edited.

## Result

N07, `Aiyagari1994.no_invariant_at_or_above_impatience` in
`Aiyagari1994/Stationary/NoInvariant.lean`: **REVIEW_READY**. If `1 ≤ beta*R`, the canonical
household kernel has no invariant probability law under the unchanged smoothness and income
nondegeneracy premises.

Only N07's contract status changed. Stage 08 and all later contracts remain UNFORMALIZED. No
GREEN status or gate advancement is awarded.

## Proof route and exact dependencies

The proof splits `1 ≤ beta*R` into the equality and strict-inequality cases. The equality case
uses accepted N06 after orienting the equality as `beta*R=1`; the strict case uses accepted N03.
No helper declaration is needed. This preserves the exact canonical kernel, candidate-law
quantification, and assumptions of the accepted dependencies.

N07 adds no state moment, bounded stationary support, stationary marginal expectation, strict
impatience, assumed positive critical consumption, infinite path space, S05 existence result, or
pathwise conclusion. All supplied predecessor qualifications remain operative and unsuperseded.
The critical two-string proof remains the accepted new reconstruction in N05/N06, not a theorem
attributed to A94 or CW00.

## Verification evidence

`lake build Aiyagari1994.Stationary.NoInvariant Probes.M07B3Signatures` completed successfully
with 2,986 jobs. The signature probe covers the sole new export with `#check`,
`assert_no_sorry`, and `#print axioms`; its printed transitive axiom set is exactly `propext`,
`Classical.choice`, and `Quot.sound`.

The final `lake build` completed successfully with 3,115 jobs, including `All` and `Audit`; the
global audit contains 575 `assert_no_sorry` commands. Reported linter warnings are inherited from
earlier modules; the assigned M07B3 sources are warning-free. `python3 tools/check_contracts.py`
passed for 57 contracts and an acyclic dependency graph, with status counts 35 GREEN, 1
REVIEW_READY, and 21 UNFORMALIZED. The contract diff changes only N07's `status` field.
`git diff --check` and the source-only prohibited-pattern scan passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 63-page Markdown/TeX/PDF
ledger. Rendered title page 1 and pages 55--56 were visually inspected; the global status, full
N07 entry, exact signature, N03/N06 assembly proof, B01 boundary, headers, footers, and page
numbers are legible with no clipping, overlap, broken glyph, or bad section transition. The PDF
SHA-256 is `cc703f954f1513719ec2bd55d5b4c6be092ea5ea6b9381a21f0efc6039ccc3e8`.

## Review request

Independent adequacy review is requested for N07 only. Stop at REVIEW_READY; do not execute
Stage 08 or any later gate.
