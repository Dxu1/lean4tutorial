# MP1994V2 milestone tracker

> **Current milestone:** M8 - Appendix derivative comparative statics
>
> **Current status:** **NOT STARTED**
>
> **Last completed milestone:** M7 - Static order comparative statics -
> **COMPLETE - GREEN**

The Markdown file is the source of truth. Status vocabulary:

- NOT STARTED
- IN PROGRESS
- BLOCKED
- READY FOR REVIEW
- COMPLETE - GREEN
- COMPLETE - AMBER
- DEFERRED / OUTSIDE CORE LEAN

M0 through M4 are complete and green. M5 is complete and amber: uniqueness is
green, while existence remains conditional on an additional bracket. M5b is
an unstarted foundational refinement. M6 is complete and amber overall: stock
completion, equation (14), and full-state uniqueness are green, while
existence inherits M5's amber qualification. M7 is complete and green after
human mathematical/economic review. M8 has not started.

## Milestones

| ID | Paper section and equations | Economic target | Expected key Lean declarations | Status | Adequacy grade | Dependencies | Blocker | Branch/commit or tag | Last review date | Next action |
|---|---|---|---|---|---|---|---|---|---|---|
| M0 | Sections 2-3; (1)-(7) | Primitives, layered assumptions, probability/matching definitions, and primitive value equilibrium | `Primitives`; four assumption bundles; `cdf`; meeting rates; `surplus`; `continuationTerm`; `ValueEquilibrium` | COMPLETE - GREEN | GREEN | None | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve the reviewed M0 interface while beginning M1 separately |
| M1 | Section 3, journal p. 401; (8) | Derive the surplus Bellman equation from (3)-(7) | continuation decomposition; `firm_share`; `surplus_flow_equation`; `surplus_bellman_of_probability`; `surplus_bellman` | COMPLETE - GREEN | GREEN | M0 complete | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve the reviewed conditional representation theorem |
| M2 | Section 3; reservation discussion and (12) | Surplus difference theorem, strict monotonicity, unique endogenous reservation threshold, and (12) | surplus difference; affinity; strict monotonicity; zero uniqueness; reservation theorem | COMPLETE - GREEN | GREEN | M1 | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve M2 interfaces and design the measure-form continuation identity for M3 |
| M3 | Section 3; (9), (10), (13) | Measure-form continuation identity and derivation of job destruction and job creation | `expectedExcess`; `tailOptionValue`; `equation9`; `equation10`; `equation13`; JD/JC residual predicates; M3 capstone | COMPLETE - GREEN | GREEN | M2 | None | `issue2`; completion commit | 2026-07-30 (human mathematical/economic review) | Preserve the reviewed independent JD/JC theorem interfaces and neutral capstone module |
| M4 | Section 3; (10), (13), journal p. 402 | Reduced-equilibrium reconstruction and equivalence | `ReducedEquilibrium`; generic tail identity; `toReducedEquilibrium`; `toValueEquilibrium`; economic round trips; nonempty equivalence | COMPLETE - GREEN | GREEN | M3 | None | `issue2`; completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the representation interfaces and formulate the corrected continuity, endpoint, and crossing assumptions for M5 |
| M5 | Section 3; (10), (13), Figure 1, journal p. 402 | Existence and uniqueness of the static reduced equilibrium | expected-excess regularity; JD/JC slopes; `StaticExistenceAssumptions`; `ReducedEquilibrium.unique`; conditional unique existence; value-side economic uniqueness | COMPLETE - AMBER | Uniqueness: GREEN; existence: AMBER; overall: AMBER | M4 | Existence uses an added lower positive crossing condition not derived from primitive assumptions | `issue2`; completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the conditional theorem; see `docs/static_existence_foundation.md` for the M5b primitive upgrade path |
| M5b | Foundational refinement to Section 3 static existence | Replace the assumed lower crossing with a derived result | proposed matching-boundary bundle; upper-job profitability; `lower_crossing_of_matching_inada`; optional Cobb-Douglas certification | NOT STARTED | Target: upgrade existence from AMBER to GREEN under a strengthened general theorem or certified Cobb-Douglas specialization | M5 | `q` Inada alone is insufficient; JD-implied tightness must become positive through a separate profitability condition | - | - | Add right-hand Inada and upper-job profitability, derive `StaticExistenceAssumptions`, and optionally certify Cobb-Douglas; see `docs/static_existence_foundation.md` |
| M6 | Section 3; (14), Figure 2, journal pp. 403-404 | Derive steady-state unemployment, employment and vacancies; define the full static steady state | strict destruction mass/CDF bridge; hazards and flows; `steadyStateUnemployment`; `SteadyStateEquilibrium`; equation (14); exact reduced/full equivalence; conditional unique existence; split capstones | COMPLETE - AMBER | Stock completion and equation (14): GREEN; uniqueness: GREEN; existence: AMBER - INHERITED FROM M5; overall: AMBER | M4-M5 | No new M6 blocker. Full-state nonemptiness inherits M5's unproved lower-crossing foundation. | `issue2`; M6 completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the split capstones and adequacy contract; M7 remains NOT STARTED |
| M7 | Section 3, journal pp. 401-404; (10), (13), (14); Figures 1-2 | Static order comparative statics for supplied equilibria; hazards, initial flows, and stocks for aggregate net productivity | parameter updates and transports; four general fixed-theta orders plus two strict positive-option-value refinements; four robust equilibrium orders; hazard/flow/stock lemmas; two M7 capstones | COMPLETE - GREEN | GREEN | M5-M6 | None for the proved pairwise results | `issue2`; M7 completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the M7 order interface and design M8's Appendix-specific derivative layer |
| M8 | Appendix; (A1)-(A12) | Differentiable equilibrium paths and derivative sign results | analytic assumption layer; Jacobian/implicit-path theorems | NOT STARTED | - | M5, M7 | Differentiability and nondegenerate Jacobian | - | - | Design Appendix-specific assumptions without strengthening core |
| M9 | Section 4; (15)-(31) | Two-state surplus systems, threshold ordering under explicit hypotheses, and impact asymmetry | two-state value system; ordering theorems; employment-measure impact results | NOT STARTED | - | M3-M6 | Piecewise continuation and employment measure | - | - | Start with an explicit two-state process |
| M10 | Prelude to Section 5; (32)-(38) | Finite-state equilibrium representation, employment transition operator, creation/destruction accounting, and (38) | finite kernel; transition operator; mass preservation; accounting identity | NOT STARTED | - | M6, M9 | Finite-state interface and connection to numerical solver | - | - | Prefer finite state before general measurable states |
| NUM | Section 5; (39)-(42), Tables I-II | Numerical simulation and calibration | External Python or Julia replication; optional exact accounting or certified residual checks in Lean | DEFERRED / OUTSIDE CORE LEAN | - | Analytical interfaces as needed | Numerical/empirical work is outside core Lean | - | - | Define reproducible solver, calibration, and residual protocol externally |

M6 adequacy: [`docs/static_steady_state_adequacy.md`](static_steady_state_adequacy.md).
Inherited M5 existence foundation:
[`docs/static_existence_foundation.md`](static_existence_foundation.md).

## M0 acceptance checklist

- [x] New module root is isolated from the legacy architecture.
- [x] Primitive parameter structure exists.
- [x] Economic assumptions are layered.
- [x] Shock law is represented by a measure.
- [x] CDF is derived from the measure.
- [x] Matching rates are defined.
- [x] Surplus is defined from `J`, `W`, and `U` rather than stored independently.
- [x] Equations (1)-(7) are represented faithfully.
- [x] Equations (5) and (6) use one shared continuation term.
- [x] No cutoff or reduced-equilibrium conclusion is assumed.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, or custom axioms exist in the new module.
- [x] Tracker TeX compiles and PDF has been visually inspected.
- [x] Human mathematical/economic review is complete.

## M1 acceptance checklist

- [x] Generic continuation decomposition is proved under a probability measure.
- [x] Firm surplus share is derived from equations (3) and (4).
- [x] The surplus flow equation is derived from equations (5)-(7).
- [x] Equation (8) is proved for the actual equilibrium surplus.
- [x] The main theorem uses only probability normalization and existing integrability.
- [x] The `ShockAssumptions` wrapper installs the probability instance locally.
- [x] No M0 structure was strengthened or modified.
- [x] No cutoff, affine surplus, or reduced equilibrium was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, or custom axioms exist.
- [x] Proof ledger TeX/PDF compiles and passes visual inspection.
- [x] Milestone tracker TeX/PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M2 acceptance checklist

- [x] Equation (8) is subtracted at two states.
- [x] The scaled two-point surplus identity is proved.
- [x] The divided affine-surplus identity is proved.
- [x] Surplus is proved strictly increasing.
- [x] The cutoff is defined from the actual equilibrium surplus.
- [x] The cutoff is proved to be a zero of surplus.
- [x] The zero is proved unique.
- [x] `V = 0` is derived from free entry and `r > 0`.
- [x] `q(theta) J(epsUpper) = c` is derived from equations (1)-(2).
- [x] `J(epsUpper) > 0` is proved.
- [x] `S(epsUpper) > 0` is proved.
- [x] `epsD < epsUpper` is proved.
- [x] Equation (12) is proved.
- [x] Surplus signs are characterized relative to `epsD`.
- [x] Firm-value signs are characterized relative to `epsD`.
- [x] Active surplus is rewritten as a scaled positive part.
- [x] No M0 or M1 mathematical declaration was changed.
- [x] No M3 or later theorem was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, or custom axioms exist.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M3 acceptance checklist

- [x] Expected excess is defined as an integral of the positive part.
- [x] Tail option value is defined from the induced CDF.
- [x] Expected-excess integrability is proved.
- [x] The strict upper-tail probability equals one minus the CDF.
- [x] The layer-cake tail identity is proved.
- [x] Active-surplus expectation is rewritten using expected excess.
- [x] Measure-form equation (9) is derived.
- [x] Paper-facing equation (9) is derived.
- [x] The free-entry search-gain identity is derived.
- [x] Measure-form equation (10) is derived.
- [x] Paper-facing equation (10) is derived.
- [x] Job-destruction residual and predicate are defined.
- [x] The equilibrium pair satisfies the job-destruction predicate.
- [x] The product-form job-creation identity is derived.
- [x] Paper equation (13) is derived.
- [x] Job-creation residual and predicate are defined.
- [x] The equilibrium pair satisfies the job-creation predicate.
- [x] No `ReducedEquilibrium` structure is introduced.
- [x] No M0-M2 mathematical declaration is changed.
- [x] No M4 or later theorem is introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M4 acceptance checklist

- [x] Robust product-form job-creation predicate is defined.
- [x] `ReducedEquilibrium` contains theta positivity and cutoff admissibility.
- [x] `ReducedEquilibrium` stores measure-form JD only.
- [x] `ReducedEquilibrium` stores product-form JC only.
- [x] Generic positive-part integrability is proved from the first moment.
- [x] Generic expected-excess/tail identity is proved.
- [x] Reduced-equilibrium paper equations (10) and (13) are derived.
- [x] Every `ValueEquilibrium` maps to a `ReducedEquilibrium`.
- [x] Candidate surplus, J, U, W, V, and wage are defined.
- [x] Reconstructed surplus equals the intended affine surplus.
- [x] Reconstructed active surplus is integrable.
- [x] Reduced search-gain identity is proved.
- [x] Candidate surplus satisfies equation (8).
- [x] Reconstructed vacancy Bellman equation is proved.
- [x] Reconstructed free-entry condition is proved.
- [x] Reconstructed Nash-sharing equation is proved.
- [x] Reconstructed filled-job Bellman equation is proved.
- [x] Reconstructed worker Bellman equation is proved.
- [x] Reconstructed unemployment Bellman equation is proved.
- [x] `ReducedEquilibrium` reconstructs a `ValueEquilibrium`.
- [x] Reconstructed cutoff equals the original reduced cutoff.
- [x] Reconstruct-then-reduce round trip is exact.
- [x] Reduce-then-reconstruct economic components are equal.
- [x] Nonempty `ValueEquilibrium` iff Nonempty `ReducedEquilibrium` is proved.
- [x] No unconditional existence or uniqueness theorem is introduced.
- [x] No M0-M3 mathematical declaration changed.
- [x] No M5 or later theorem is introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M5 acceptance checklist

- [x] Expected excess is proved antitone.
- [x] Expected excess satisfies a one-Lipschitz bound.
- [x] Expected excess is proved continuous.
- [x] The job-destruction net-value curve is defined.
- [x] The job-destruction-implied tightness curve is defined.
- [x] JD satisfaction is equivalent to theta = theta_JD(d).
- [x] The JD curve is proved strictly increasing.
- [x] The scalar job-creation residual is defined.
- [x] The scalar residual is proved strictly decreasing on the admissible domain.
- [x] The Figure 1 JD upward-slope theorem is proved.
- [x] The Figure 1 JC downward-slope theorem is proved.
- [x] At most one `ReducedEquilibrium` is proved.
- [x] `StaticExistenceAssumptions` is explicitly defined.
- [x] The existence bundle contains no equilibrium witness or root.
- [x] Continuity on the crossing bracket is proved.
- [x] The upper endpoint residual is proved equal to `-c`.
- [x] An interior scalar root is proved by the IVT.
- [x] A `ReducedEquilibrium` witness is constructed.
- [x] Unique existence of `ReducedEquilibrium` is proved.
- [x] `ValueEquilibrium` nonemptiness is derived through M4.
- [x] Equilibrium theta uniqueness is proved.
- [x] Reservation-cutoff uniqueness is proved.
- [x] Economic uniqueness of value equilibria is proved.
- [x] Existence is labeled as conditional on the additional bracket assumptions.
- [x] No M0-M4 mathematical theorem statement changed.
- [x] No M6 or later theorem was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M6 acceptance checklist

- [x] Strict destruction mass is connected to the M2 destruction rule.
- [x] Strict lower tail equals the CDF under no atoms.
- [x] Job-separation hazard is defined.
- [x] Worker job-finding hazard is defined or reused.
- [x] Creation and destruction flows are defined.
- [x] Total transition hazard is proved positive.
- [x] Closed-form unemployment is defined.
- [x] Closed-form unemployment lies in `[0,1)`.
- [x] Closed-form unemployment satisfies flow balance.
- [x] Flow balance uniquely determines unemployment.
- [x] Paper equation (14) is proved.
- [x] `SteadyStateEquilibrium` is defined.
- [x] Employment is derived from unemployment.
- [x] Vacancies are derived as `theta * unemployment`.
- [x] Creation flow is rewritten as `q(theta) * vacancies`.
- [x] Destruction flow is rewritten as `lambda F(cutoff) * employment`.
- [x] Creation equals destruction.
- [x] Positive separation implies positive unemployment.
- [x] `vacancies / unemployment = theta` is proved only under positivity.
- [x] Every reduced equilibrium completes to a full steady state.
- [x] Reduced/full exact round trips are proved.
- [x] At most one full steady state is proved without existence assumptions.
- [x] Conditional full-state nonemptiness is transported from M5.
- [x] Full-state unique existence is proved conditionally.
- [x] Beveridge-curve slope is not assumed or proved.
- [x] No M0-M5 mathematical theorem statement changed.
- [x] No M7 or later theorem was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M7 acceptance checklist

- [x] Parameter-update functions are defined.
- [x] Assumption transport is proved.
- [x] Fixed-theta p cutoff result is proved.
- [x] Fixed-theta b cutoff result is proved.
- [x] Fixed-theta lambda cutoff result is proved.
- [x] Fixed-theta r cutoff result is proved.
- [x] Full-equilibrium p orders are proved.
- [x] Full-equilibrium b orders are proved.
- [x] Full-equilibrium lambda cutoff order is proved.
- [x] Full-equilibrium r tightness order is proved.
- [x] Separation-hazard order is proved.
- [x] Job-finding-rate order is proved.
- [x] Initial-impact creation/destruction results are proved.
- [x] Steady unemployment and employment orders are proved.
- [x] Vacancy response is explicitly left ambiguous.
- [x] No core theorem uses `StaticExistenceAssumptions`.
- [x] M8 derivative results remain unimplemented.
- [x] No M0-M6 mathematical theorem changed.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF passes visual inspection.
- [x] Tracker PDF passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M5b - Primitive foundation for static existence

**Status:** NOT STARTED

**Adequacy target:** Upgrade static existence from AMBER to GREEN under either
a strengthened general matching-boundary theorem or a fully certified
Cobb-Douglas specialization.

This is a foundational refinement, not M6, and it is not part of the current
M5 Lean proof. Its proposed tasks are:

- add a right-hand Inada condition for `q`;
- separately require upper-job profitability,
  `b < p + sigma * epsUpper`;
- prove that the JD curve reaches zero and then positive tightness;
- derive `StaticExistenceAssumptions.lower_crossing` rather than assuming it;
- construct `StaticExistenceAssumptions`; and
- optionally certify all conditions for Cobb-Douglas matching.

The Inada condition on `q` alone is insufficient: without positive
JD-implied tightness somewhere below `epsUpper`, its behavior on positive
tightness cannot yield a crossing. The complete design is recorded in
`docs/static_existence_foundation.md`. M6 does not implement this refinement.

## Changelog

### 2026-07-31 - M7 human review completed

- Found the order proofs mathematically and economically sound and graded M7
  **COMPLETE - GREEN**.
- Confirmed that no M5 existence assumption is used; the theorems are
  universal conditional comparisons of supplied equilibria.
- Removed unnecessary imports of the M5 existence and M6 transported-existence
  layers from the M7 core.
- Added strict fixed-tightness refinements under explicit positive option value;
  the strict discount-rate result also assumes positive `lambda`.
- Corrected the proof-ledger symbol and rendering defects.
- Left the `lambda`-tightness, `r`-cutoff, `sigma`, and derivative results for
  M8, which remains **NOT STARTED**.

### 2026-07-31 - M7 static order comparative statics implemented

- Added immutable parameter updates and assumption transports for `p`, `b`,
  `lambda`, and `r`.
- Proved the four fixed-tightness cutoff orders and the robust supplied-
  equilibrium orders: full `p` and `b` responses, the `lambda` cutoff, and the
  `r` tightness response.
- Derived weak separation, finding, initial-flow, unemployment, and employment
  implications for aggregate net productivity; left vacancies ambiguous.
- Confirmed that M7 core uses no `StaticExistenceAssumptions` and proves no
  existence theorem. Deferred `lambda`-tightness, `r`-cutoff, `sigma`, and all
  Appendix derivative results to M8.
- Added `docs/static_comparative_statics_scope.md`; submitted M7 as
  **READY FOR REVIEW**, with target grade **COMPLETE - GREEN**.

### 2026-07-31 - M6 human review completed

- Judged stock completion, equation (14), flow accounting, exact reduced/full
  representation, and full-state uniqueness mathematically and economically
  faithful; these components are GREEN.
- Confirmed that zero separation gives `u = v = 0`, while the literal
  `v / u = theta` result correctly requires positive separation.
- Confirmed that M6 introduces no new existence closure assumption. Its AMBER
  existence grade is inherited entirely from M5 through `lower_crossing`.
- Split the capstone interface into green stock/uniqueness and amber
  conditional-existence theorems, removed irrelevant shock assumptions from
  the pure stock representation, and recorded the detailed assessment in
  `docs/static_steady_state_adequacy.md`.
- Marked M6 **COMPLETE - AMBER**. M7 remains **NOT STARTED**.

### 2026-07-31 - M6 unemployment flow balance implemented

- Added the strict destruction mass and used atomlessness to identify it with
  the paper CDF.
- Defined separation and job-finding hazards, creation/destruction flows, and
  the unique balanced unemployment formula; derived paper equation (14).
- Added `SteadyStateEquilibrium`, derived employment and vacancies, proved
  flow equality, and guarded the literal `v/u = theta` identity by positive
  separation because zero separation gives `u = v = 0`.
- Proved exact reduced/full round trips, an explicit `Equiv`, at-most-one full
  state, and conditional nonemptiness/unique existence inherited from M5.
- Stock completion and equation (14) were submitted as GREEN; existence and
  overall M6 were submitted as AMBER pending the completed review above.

### 2026-07-31 - M5 static-existence foundation documented

- Recorded the exact current continuity and lower-crossing assumptions.
- Added the unimplemented M5b path combining a right-hand Inada condition for
  `q` with the separate upper-job profitability condition.
- Recorded that `q` Inada alone is insufficient and that M5 remains
  **COMPLETE - AMBER** while M6 remains **NOT STARTED**.
- Added `docs/static_existence_foundation.md` as the durable design note.

### 2026-07-31 - M5 review completed

- The substantive uniqueness and IVT proofs passed mathematical review.
- Figure 1 establishes uniqueness but does not by itself establish existence.
- `lower_crossing` is non-circular because it assumes a strictly positive
  residual, not a root, but it supplies the missing endpoint condition.
- Existence-only declarations were weakened to omit `MatchingAssumptions`;
  the combined uniqueness capstones retain it.
- Uniqueness is **COMPLETE - GREEN**; existence and overall M5 are
  **COMPLETE - AMBER**.
- Future task: derive `lower_crossing` from primitive conditions on `q`, or
  certify it for a standard Cobb-Douglas matching function. This does not
  block M6.

### 2026-07-31 - M5 static existence and uniqueness implemented

Added expected-excess regularity, the upward-sloping JD curve, the
downward-sloping JC curve, and at-most-one reduced equilibrium under the
maintained assumptions. Added the separate `StaticExistenceAssumptions`
continuity/bracket bundle; the derived upper residual `-c < 0` and Mathlib's
intermediate value theorem construct an interior reduced equilibrium. M4
reconstruction transports conditional existence and economic uniqueness to
primitive value equilibria. The implementation was submitted for review;
equation (14) and the full steady state remain M6.

### 2026-07-31 - M4 review completed

- The generic excess and CDF-tail analysis is valid.
- Equations (10) and (13) are sufficient for reconstruction under the stated
  admissibility assumptions.
- The explicit Nash wage is economically correct, and equations (1)-(7) are
  reconstructed rather than assumed.
- Exact reduced and complete value-side economic round trips are certified.
- The import diagram and assumption-field documentation were corrected.
- M4 establishes neither equilibrium existence nor uniqueness.
- M4 was graded **COMPLETE - GREEN**.

### 2026-07-30 - M4 reconstruction and equivalence implemented

Created the robust two-variable `ReducedEquilibrium`, generic excess
integrability and tail-identity layer, forward bridge, explicit reverse
reconstruction, and equivalence module. The reverse construction verifies
equations (1)-(7) with the economic Nash wage, reconstructs the original
cutoff, and gives exact reduced and componentwise value round trips.
Nonemptiness is equivalent only after receiving a witness on one side; no
existence or uniqueness result is introduced. M4 is **READY FOR REVIEW**.

### 2026-07-30 - M3 review completed

- The layer-cake/CDF proof was reviewed and found valid; atomlessness is not
  used.
- Equations (9), (10), and (13) have the correct signs and dependencies.
- Job creation is derived independently of the job-destruction equation.
- The capstone was moved to the neutral combining module
  `SteadyState/StaticConditions.lean`.
- The residual predicates require separate admissibility fields in M4.
- M4 must prove a generic expected-excess/tail theorem for reverse
  reconstruction.
- M3 was graded **COMPLETE - GREEN**.

### 2026-07-30 - M3 continuation and static conditions implemented

Created `SteadyState/Continuation.lean`,
`SteadyState/JobDestruction.lean`, `SteadyState/JobCreation.lean`, and the
neutral combining module `SteadyState/StaticConditions.lean`.
Expected excess is derived from the M2 active-surplus formula; Mathlib's
strict-tail layer-cake theorem gives the induced-CDF representation without
using atomlessness. Equations (9), (10), and (13), the job-destruction and
job-creation residual predicates, and the forward M3 capstone are proved for an
existing `ValueEquilibrium`. No reduced-equilibrium structure or M4 theorem
was introduced.

### 2026-07-29 - M2 review completed

- Equation (8) was correctly subtracted at two states.
- The actual equilibrium surplus was proved affine and strictly increasing.
- `reservationCutoff` was proved to be the uniquely identified surplus zero.
- Equations (1)-(2) establish `reservationCutoff < epsUpper`.
- Equation (12) and the reservation rule were proved.
- M2 remains conditional on an existing `ValueEquilibrium`.
- M2 was graded **COMPLETE - GREEN**.

### 2026-07-29 - M2 affine surplus and cutoff implemented

Created `SteadyState/AffineSurplus.lean` and `SteadyState/Cutoff.lean`.
Equation (8) was subtracted at two states to derive the affine surplus
difference and strict monotonicity. The derived `reservationCutoff` was proved
to be the unique surplus zero; equations (1)-(2), positive vacancy cost and
meeting, and `beta < 1` separately imply that it lies below `epsUpper`.
Equation (12), surplus and firm-value reservation rules, the active-surplus
positive-part bridge, and an M2 capstone were added. M2 is **READY FOR REVIEW**.

### Review-archive convention

Beginning with M3, review archives use project-local names such as
`review_m3.zip`, `review_m4.zip`, and so on. They remain untracked and are
never committed.

### 2026-07-29 - M1 review completed

Human mathematical and economic review found equation (8) mathematically
faithful to the paper and its proof non-circular. It is derived from equations
(3)-(7), uses the actual equilibrium surplus, and assumes no cutoff, affinity
result, or reduced equilibrium. The result is a conditional representation
theorem for an existing `ValueEquilibrium`; M1 does not prove equilibrium
existence. M1 was graded **COMPLETE - GREEN**.

### 2026-07-29 - M1 equation (8) implemented

Created `MP1994V2/SteadyState/Surplus.lean` with the continuation
decomposition, derived firm share, surplus flow equation,
`surplus_bellman_of_probability`, and the `ShockAssumptions` wrapper
`surplus_bellman`. Updated `All.lean`, `Audit.lean`, the README, trackers, and
added the cumulative proof ledger. M1 is **READY FOR REVIEW**.

### 2026-07-29 - M0 review completed

- Equations (1)-(7) were judged economically faithful.
- No conclusion belonging to a future theorem is embedded in the architecture.
- The aggregate import direction was corrected to substantive modules -> `All`
  -> `Audit`.
- Milestone 1 must take `ShockAssumptions P` explicitly and install
  `D.isProbability` locally when probability-measure integral identities are
  needed.
- M0 was graded **COMPLETE - GREEN**.

### 2026-07-29 - v2 foundation created

Created the isolated `MP1994V2` Milestone 0 foundation:

- `Definitions.lean`: `Primitives`, productivity and meeting rates,
  `positivePart`, `surplus`, `activeSurplus`, and `continuationTerm`;
- `Assumptions.lean`: `CoreEconomicAssumptions`, `ShockAssumptions`,
  `ShockNormalizationAssumptions`, and `MatchingAssumptions`;
- `Probability.lean`: derived `cdf`, `shockBelow`, and
  `IsShockUpperBound`;
- `Matching.lean`: `MarketTightness` and `workerMeetingRate_pos`;
- `Equilibrium/Value.lean`: `ValueCandidate`, candidate surplus/continuation
  accessors, `ValueEquilibrium`, and definitional equation (3);
- `Audit.lean` and `All.lean`: aggregate import and compile-time audit;
- `README.md`: architecture, scope, equation map, and build instructions;
- this synchronized Markdown/TeX/PDF tracker.

No legacy v1 Lean file, replication-architecture document, or Lake
configuration was modified. The library root `Lean4Tutorial.lean` received one
aggregate import so `lake build` certifies `MP1994V2.All`.
