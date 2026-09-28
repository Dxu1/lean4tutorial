# Milestone report: M07B2 / N06 critical nonstationarity

Date: 2026-09-28. Assigned gate: M07B2. Assigned contract: N06 only. Accepted baseline:
`07dd2605ff6fb211d166192cc64c087f885234ca`. This gate was executed at Sol Medium from the
controller-supplied capsule. Controller-owned orchestration state, evidence, inventories, logs,
and review archives were not edited.

## Result

N06, `Aiyagari1994.no_invariant_critical` in
`Aiyagari1994/Stationary/Critical.lean`: **REVIEW_READY**. At `beta*R=1`, the canonical household
kernel has no invariant probability law when effective income is nondegenerate, including a law
with infinite first moment.

Only N06's contract status changed. N07 and all later contracts remain UNFORMALIZED. No GREEN
status or gate advancement is awarded.

## Proof route and exact dependencies

The theorem introduces `pi` only after assuming the negation of the conclusion. From
`beta*R=1`, `0<beta`, and `beta<1`, it derives `R>1`. The compact labor carrier gives a pointwise
bound on affine effective income. Essential endpoint mass and the positive wage prove effective
income is not almost everywhere constant.

N06 instantiates the accepted N05 theorem with the actual canonical objects:
`c=consumptionPolicy` and `step(z,l)=nextResources(assetPolicy(z),l)`. The accepted budget
identity gives `c+A=z`; unfolding the canonical transition gives `R*A+e`; together they derive
the exact N05 recursion `R*(z-c(z))+e`. The generic resource kernel is proved equal to
`householdKernel`. The accepted N04 theorem supplies only stationary one-step a.e. consumption
equality under the contradictory `pi`; N05 performs the legitimate finite-product transfer,
endpoint-law induction, finite full-measure intersection, telescope, tightness/union-bound
argument, and exact positive-variance contradiction.

No state moment, bounded stationary support, stationary marginal-utility moment, strict
impatience, assumed positive critical consumption, infinite path space, or S05 invariant-law
existence enters the proof. The reconstruction is new and is not attributed as a theorem copied
from A94 or CW00. All supplied predecessor qualifications remain operative and unsuperseded.

## Verification and review request

`lake build Aiyagari1994.Stationary.Critical` completed successfully with 2,982 jobs, and
`lake build Probes.M07B2Signatures` completed successfully with 2,983 jobs. The signature probe covers the target
and all four new public bridge declarations with `#check`, `assert_no_sorry`, and `#print axioms`;
each printed transitive axiom set is exactly `propext`, `Classical.choice`, and `Quot.sound`.

The final `lake build` completed successfully with 3,114 jobs, including `All` and `Audit`; the
global audit contains 574 `assert_no_sorry` commands. Reported linter warnings are inherited from
earlier modules; the assigned M07B2 sources are warning-free. `python3 tools/check_contracts.py`
passed for 57 contracts and an acyclic dependency graph, with status counts 34 GREEN, 1
REVIEW_READY, and 22 UNFORMALIZED. The contract diff changes only N06's `status` field.
`git diff --check` and the source-only prohibited-pattern scan passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 63-page Markdown/TeX/PDF ledger.
Rendered pages 54--55 were visually inspected with Poppler; the complete N06 entry, exact
signature, N07 boundary, headers, footers, and page numbers are legible with no clipping, overlap,
broken glyph, or bad section transition. N07 remains UNFORMALIZED. The PDF SHA-256 is
`998685a0f4a58f19e8843e01fde2647e68ea9083e94dd2ab4bd0f3b45acc9f55`.

Independent adequacy review is requested for N06 only. Stop at REVIEW_READY; do not execute N07,
Stage 08, or any later gate.
