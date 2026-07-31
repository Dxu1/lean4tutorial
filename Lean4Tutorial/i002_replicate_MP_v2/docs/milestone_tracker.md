# MP1994V2 milestone tracker

> **Last completed milestone:** M3 - Continuation value, job destruction, and
> job creation - **COMPLETE - GREEN**
>
> **Next milestone:** M4 - Reduced-equilibrium reconstruction and equivalence
> - **NOT STARTED**

The Markdown file is the source of truth. Status vocabulary:

- NOT STARTED
- IN PROGRESS
- BLOCKED
- READY FOR REVIEW
- COMPLETE - GREEN
- COMPLETE - AMBER
- DEFERRED / OUTSIDE CORE LEAN

M0 through M3 are complete and green. M4 has not started.

## Milestones

| ID | Paper section and equations | Economic target | Expected key Lean declarations | Status | Adequacy grade | Dependencies | Blocker | Branch/commit or tag | Last review date | Next action |
|---|---|---|---|---|---|---|---|---|---|---|
| M0 | Sections 2-3; (1)-(7) | Primitives, layered assumptions, probability/matching definitions, and primitive value equilibrium | `Primitives`; four assumption bundles; `cdf`; meeting rates; `surplus`; `continuationTerm`; `ValueEquilibrium` | COMPLETE - GREEN | GREEN | None | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve the reviewed M0 interface while beginning M1 separately |
| M1 | Section 3, journal p. 401; (8) | Derive the surplus Bellman equation from (3)-(7) | continuation decomposition; `firm_share`; `surplus_flow_equation`; `surplus_bellman_of_probability`; `surplus_bellman` | COMPLETE - GREEN | GREEN | M0 complete | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve the reviewed conditional representation theorem |
| M2 | Section 3; reservation discussion and (12) | Surplus difference theorem, strict monotonicity, unique endogenous reservation threshold, and (12) | surplus difference; affinity; strict monotonicity; zero uniqueness; reservation theorem | COMPLETE - GREEN | GREEN | M1 | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve M2 interfaces and design the measure-form continuation identity for M3 |
| M3 | Section 3; (9), (10), (13) | Measure-form continuation identity and derivation of job destruction and job creation | `expectedExcess`; `tailOptionValue`; `equation9`; `equation10`; `equation13`; JD/JC residual predicates; M3 capstone | COMPLETE - GREEN | GREEN | M2 | None | `issue2`; completion commit | 2026-07-30 (human mathematical/economic review) | Preserve the reviewed independent JD/JC theorem interfaces and neutral capstone module |
| M4 | Section 3 | Reduced-equilibrium reconstruction and equivalence | `ReducedEquilibrium`; forward map; converse constructor; equivalence theorem | NOT STARTED | - | M3 | Generic excess integrability and tail identity; admissible reduced-interface and value reconstruction design | - | - | Prove generic excess integrability from the shock first moment and the generic tail identity for an arbitrary admissible cutoff; use product-form job creation as the robust reduced representation; construct value functions from a reduced pair |
| M5 | Section 3; Figure 1 and statement after (13) | Clarified existence theorem and uniqueness of `(theta, epsD)` | existence; at-most-one; unique-equilibrium theorem with endpoint assumptions | NOT STARTED | - | M4 | Paper omits endpoint conditions | - | - | State corrected continuity, range, and crossing hypotheses |
| M6 | Section 3; (14) | Derive steady-state unemployment and define the full steady state | flow balance; unemployment identity; full steady-state structure | NOT STARTED | - | M4-M5 | Static equilibrium foundation | - | - | Introduce unemployment stocks only at this stage |
| M7 | Section 3 | Order-theoretic comparative statics for `p`, `b`, `lambda`, `r`, and `sigma` where possible without differentiability | parameter-order theorems; equilibrium order lemmas | NOT STARTED | - | M5 | Global solution selection and parameter monotonicity | - | - | Separate global monotone results from derivatives |
| M8 | Appendix; (A1)-(A12) | Differentiable equilibrium paths and derivative sign results | analytic assumption layer; Jacobian/implicit-path theorems | NOT STARTED | - | M5, M7 | Differentiability and nondegenerate Jacobian | - | - | Design Appendix-specific assumptions without strengthening core |
| M9 | Section 4; (15)-(31) | Two-state surplus systems, threshold ordering under explicit hypotheses, and impact asymmetry | two-state value system; ordering theorems; employment-measure impact results | NOT STARTED | - | M3-M6 | Piecewise continuation and employment measure | - | - | Start with an explicit two-state process |
| M10 | Prelude to Section 5; (32)-(38) | Finite-state equilibrium representation, employment transition operator, creation/destruction accounting, and (38) | finite kernel; transition operator; mass preservation; accounting identity | NOT STARTED | - | M6, M9 | Finite-state interface and connection to numerical solver | - | - | Prefer finite state before general measurable states |
| NUM | Section 5; (39)-(42), Tables I-II | Numerical simulation and calibration | External Python or Julia replication; optional exact accounting or certified residual checks in Lean | DEFERRED / OUTSIDE CORE LEAN | - | Analytical interfaces as needed | Numerical/empirical work is outside core Lean | - | - | Define reproducible solver, calibration, and residual protocol externally |

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

## Changelog

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
