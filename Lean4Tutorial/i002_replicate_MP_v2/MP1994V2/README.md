# MP1994V2: value equilibrium and reduced static conditions

`MP1994V2` is the clean, staged replication architecture for Mortensen and
Pissarides (1994), implemented through Milestone 6. The legacy `MP1994` files
remain unchanged and can be consulted for generic Lean techniques, but their
economic architecture is not inherited.

The v2 design separates:

- **primitives**: exogenous parameters, the shock measure, and the meeting-rate
  function;
- **assumptions**: layered economic signs, shock regularity, optional moment
  normalization, and matching restrictions;
- **equilibrium definitions**: candidate values and paper equations (1)-(7);
- **theorem modules**: results proved in dependency order; M1 derives the
  surplus Bellman equation (8), and M2 derives affine surplus, the reservation
  rule, and equation (12); M3 derives the continuation identity and equations
  (9), (10), and (13); M4 proves the two-way reduced/value representation;
  M5 proves uniqueness and conditional existence of the reduced static
  equilibrium; M6 derives equation (14) and completes it with unemployment,
  employment, and vacancy stocks.

## Import graph

```text
Definitions
  ├── Assumptions
  │     ├── Probability
  │     └── Matching
  └──────────────┘
          ↓
  Equilibrium.Value
          ↓
  SteadyState.Surplus
          ↓
  SteadyState.AffineSurplus
          ↓
  SteadyState.Cutoff
      ┌───┴──────────────┐
      ↓                  ↓
  Continuation       JobCreation
      ↓                  │
  JobDestruction         │

[JobDestruction, JobCreation]
      ├──→ StaticConditions ──┐
      └──→ Equilibrium.Reduced├──→ ForwardBridge
                              │
[Continuation, Equilibrium.Reduced]
      └──→ ReducedAnalytic ──→ Reconstruction

[ForwardBridge, Reconstruction]
      └──→ Equivalence ───────────────────────────┐

ReducedAnalytic → ExpectedExcessProperties
      → StaticCurves → Assumptions.StaticExistence
      → ExistenceUniqueness ← Equivalence

[Probability, Matching]
      → Flows → Equilibrium.SteadyState
      → Unemployment → FullEquilibrium
                         ↑              ↑
             ExistenceUniqueness   Equivalence
                         ↓
                        All → Audit
```

In particular, `JobDestruction` and `JobCreation` feed both
`StaticConditions` and `Equilibrium.Reduced`. `ForwardBridge` imports those
two combining modules. `ReducedAnalytic` imports `Continuation` and
`Equilibrium.Reduced`; `Reconstruction` follows `ReducedAnalytic`; and
`Equivalence` imports `ForwardBridge` and `Reconstruction`.

`All.lean` imports all twenty-five substantive modules directly, including the
four M6 modules. `Audit.lean` imports
`All.lean` and adds compile-time checks. No substantive Milestone 0 module or
`All.lean` imports `Audit.lean`, and no Milestone 0 module imports a future
theorem directory.

## Milestone 0 scope

Milestone 0 provides:

- `Primitives`;
- `CoreEconomicAssumptions`;
- `ShockAssumptions`;
- `ShockNormalizationAssumptions`;
- `MatchingAssumptions`;
- the CDF derived from `Primitives.shock`;
- vacancy and worker meeting rates;
- surplus and active surplus derived from `J`, `W`, and `U`;
- one shared measure-theoretic continuation term;
- `ValueCandidate` and `ValueEquilibrium`;
- compile-time interface and no-`sorry` audits.

The optional shock normalization is not required by `ValueEquilibrium`.
Integrability of active surplus is labeled as value-function admissibility.

## Probability contract for later theorems

`ValueEquilibrium P` records equations (1)-(7) for raw primitives. It does not
silently install probability normalization or bundle the distributional
assumptions into the equilibrium structure.

Probability-based theorems explicitly take `D : ShockAssumptions P`. The
paper-level equation (8) wrapper installs `D.isProbability` locally as an
`IsProbabilityMeasure P.shock` instance before invoking the theorem stated
under the minimal probability typeclass.

`epsUpper` is the designated productivity state of a newly formed job in
equations (1) and (7). The field `ShockAssumptions.upperSupport` states
`P.shock (Set.Ioi P.epsUpper) = 0`, so it is also an almost-sure upper bound
under that assumption bundle. The development does not prove that `epsUpper`
is the maximal or exact endpoint of the topological support.

## Paper equations (1)-(7)

| Paper equation | `ValueEquilibrium` interface | Content |
|---|---|---|
| (1) | `vacancy_bellman` | `r V = -c + q(theta) [J(epsUpper) - V]` |
| (2) | `free_entry` | `r V = 0` |
| (3) | definition `surplus`; theorem `surplus_eq` | `S(eps) = J(eps) + W(eps) - U` |
| (4) | `nash_sharing` | `W(eps) - U = beta S(eps)` |
| (5) | `filled_job_bellman` | filled-job value equation using `continuationTerm` |
| (6) | `worker_bellman` | employed-worker value equation using the same `continuationTerm` |
| (7) | `unemployed_bellman` | `r U = b + theta q(theta) [W(epsUpper) - U]` |

Equation (3) is not stored as an independent consistency condition: it is true
by the definition of surplus.

## Milestone 1: equation (8)

`SteadyState/Surplus.lean` proves:

- the probability-measure decomposition of `continuationTerm`;
- the firm's Nash share from equations (3) and (4);
- the pre-normalization surplus flow equation from equations (5)-(7);
- paper equation (8) under `[IsProbabilityMeasure P.shock]`;
- a paper-facing wrapper taking `ShockAssumptions P`.

The actual `ValueEquilibrium` surplus is used throughout. Equation (8) is a
theorem, not a structure field or assumption.

## Milestone 2: affine surplus and reservation cutoff

`SteadyState/AffineSurplus.lean` subtracts equation (8) at two states, derives
the affine surplus-difference identity, and proves that actual equilibrium
surplus is strictly increasing.

`SteadyState/Cutoff.lean` defines `ValueEquilibrium.reservationCutoff` from the
actual equilibrium values and proves that it is the unique surplus zero.
Separately, equations (1)-(2), positive vacancy cost and meeting, and
`beta < 1` imply that the cutoff lies strictly below `epsUpper`. The cutoff is
derived rather than assumed and is not a field of `ValueEquilibrium`.

M2 remains conditional on an existing `ValueEquilibrium`; it does not prove
joint existence or uniqueness of `(theta, epsD)`.

## Milestone 3: continuation, job destruction, and job creation

`SteadyState/Continuation.lean` defines the measure-form expected excess

```text
H(d) = ∫ max (x - d) 0 dP.shock
```

and the paper-facing CDF-tail option value

```text
∫_d^epsUpper [1 - F(x)] dx.
```

The strict-tail layer-cake theorem proves these coincide at the equilibrium
cutoff. It then derives equation (9) in both measure and CDF-tail forms.
`SteadyState/JobDestruction.lean` evaluates equation (9) at the zero-surplus
cutoff and uses free entry to derive equation (10).
`SteadyState/JobCreation.lean` independently combines free entry, firm surplus
sharing, and M2 affine surplus to derive equation (13); it does not use
equation (10).
These are independent theorem modules. `SteadyState/StaticConditions.lean`
imports both and combines their forward conclusions in the M3 capstone.

All M3 results remain conditional on an existing `ValueEquilibrium`.

## Milestone 4: reduced reconstruction and equivalence

`ReducedEquilibrium` stores only positive market tightness, a cutoff strictly
below `epsUpper`, the measure-form job-destruction condition, and the robust
product-form job-creation condition. It contains no value functions and is not
the paper's full steady state: unemployment `u` is deferred to equation (14)
in M6.

M4 proves both directions. Every existing `ValueEquilibrium` yields a
`ReducedEquilibrium`. Conversely, equations (10) and (13), stored in their
robust measure and product forms, reconstruct

```text
V = 0
S(eps) = [sigma/(r + lambda)] (eps - cutoff)
J(eps) = (1 - beta) S(eps)
U = [b + beta theta q(theta) S(epsUpper)] / r
W(eps) = U + beta S(eps)
w(eps) = beta [p + sigma eps] + (1 - beta)b + beta c theta.
```

The explicit Nash wage is derived and all equations (1)-(7) are verified.
Reconstructing then reducing is exact; reducing then reconstructing recovers
all public economic components and surplus; this complete value-side economic
round trip is explicitly included in the M4 capstone.

Under the core, shock, and matching assumption bundles, nonemptiness of
`ValueEquilibrium P` and `ReducedEquilibrium P` is logically equivalent. The
result is not an unconditional existence theorem because no witness to either
side is constructed from the assumptions alone.

## Milestone 5: static existence and uniqueness

`ExpectedExcessProperties.lean` proves that expected excess is antitone,
one-Lipschitz, and continuous. `StaticCurves.lean` scalarizes equation (10) as
the strictly increasing JD-implied curve `jobDestructionTheta` and evaluates
the robust equation (13) along it as `staticCrossingResidual`. The JD locus is
proved upward-sloping, the positive-tightness JC locus downward-sloping, and
therefore `ReducedEquilibrium` is unique under the existing core, shock, and
matching bundles.

The Figure 1 uniqueness result is graded **COMPLETE - GREEN**. It is
independent of `StaticExistenceAssumptions`.

Slopes alone do not establish an intersection. The separate
`StaticExistenceAssumptions` bundle supplies continuity of `q` on positive
tightness and one lower point with positive tightness and positive residual.
The upper residual is derived as `-c < 0`; the intermediate value theorem then
constructs an interior crossing. Thus M5 existence is conditional on this
additional sufficient bracket condition, not a theorem from the original
primitive assumptions alone.

The existence-only theorems `exists_staticCrossing`,
`reducedEquilibrium_nonempty`, `staticReducedEquilibrium`, and
`valueEquilibrium_nonempty` take `CoreEconomicAssumptions`,
`ShockAssumptions`, and `StaticExistenceAssumptions`; they do not take
`MatchingAssumptions`. Their shock proof terms use only `isProbability` and
`firstMomentIntegrable`. Uniqueness additionally uses
`MatchingAssumptions.vacancyMeetingRate_pos` and
`vacancyMeetingRate_strictAntiOn`, so combined unique-existence and economic-
uniqueness capstones retain the matching bundle.

The field `lower_crossing` is not circular: it assumes a strictly positive
residual, not a root. It nevertheless supplies the missing lower endpoint
condition needed for an intersection, which the paper's slope argument alone
does not provide. Conditional existence is therefore graded
**COMPLETE - AMBER**, and overall M5 is **COMPLETE - AMBER**.

M4 reconstruction transports reduced existence and uniqueness to
`ValueEquilibrium`: all public values, wages, surplus, tightness, and the
reservation cutoff are economically unique. Equation (14), unemployment and
vacancy stocks, and the full steady state remain M6.

## Milestone 6: unemployment flow balance and the full static steady state

`SteadyState/Flows.lean` starts from the actual strict destruction event
`eps < cutoff`. It defines `strictShockBelow`, the separation hazard
`jobSeparationRate`, the existing worker-meeting rate under the economic alias
`jobFindingRate`, and the creation/destruction flows. Under
`ShockAssumptions.noAtoms`, `strictShockBelow_eq_cdf` replaces the strict tail
by the induced CDF `F(cutoff)`.

`SteadyState/Unemployment.lean` derives the unique balanced stock

```text
u = lambda F(cutoff) /
      (lambda F(cutoff) + theta q(theta)),
```

which is paper equation (14). `SteadyStateEquilibrium` extends a
`ReducedEquilibrium` only with unemployment and its flow-balance condition.
Employment is derived as `1 - unemployment`, and vacancies are derived as
`theta * unemployment`; neither is stored redundantly.

The three equilibrium interfaces now have distinct roles:

- `ReducedEquilibrium` is the static `(theta, cutoff)` pair satisfying robust
  job-destruction and job-creation conditions;
- `SteadyStateEquilibrium` is that pair plus the uniquely balanced
  unemployment stock;
- `ValueEquilibrium` stores the primitive value functions and equations
  (1)-(7), recoverable from the full state through M4 reconstruction.

The identity `v = theta * u` is unconditional. If the separation hazard is
zero, equation (14) gives `u = 0` and hence `v = 0`, so the literal ratio is
undefined. Accordingly, `vacancies_div_unemployment_eq_theta` requires
positive separation (and proves positive unemployment first).

M6 proves no Beveridge-curve slope, convexity, comparative static, or dynamic
law. Stock completion, equation (14), flow equality, representation
equivalence, and uniqueness introduce no new analytic closure assumption and
are graded GREEN. The pure reduced/full stock-completion equivalence does not
take `ShockAssumptions`: the shock bundle enters the paper-facing CDF rewrite,
not the algebraic completion itself. Full-state nonemptiness inherits M5's
`StaticExistenceAssumptions.lower_crossing` and therefore remains AMBER;
overall M6 is **COMPLETE - AMBER**.

The review split is exposed by two capstones. `m6_stock_completion_capstone`
contains equation (14), flow accounting, exact reduced/full round trips, and
uniqueness, and takes no static-existence bundle. The separate
`m6_conditional_existence_capstone` transports M5 nonemptiness and unique
existence and visibly takes `StaticExistenceAssumptions`. M6 introduces no new
existence closure assumption.

Static steady-state adequacy and the exact inheritance chain:
[`docs/static_steady_state_adequacy.md`](../docs/static_steady_state_adequacy.md).

### Future foundational task

Derive `StaticExistenceAssumptions.lower_crossing` from more primitive
boundary or range conditions on `q`, or certify it for a standard matching
function such as a Cobb-Douglas specification. Until then, existence remains
conditional. This gap is inherited by M6 existence but does not affect the
green stock-completion and uniqueness results.

Static existence gap and proposed primitive proof:
[`docs/static_existence_foundation.md`](../docs/static_existence_foundation.md).
The documented, unformalized route combines a right-hand Inada condition for
`q` with the separate upper-job profitability condition
`b < p + sigma * epsUpper`. The Inada property alone is insufficient because
the JD-implied tightness must first become positive.

## Prohibited shortcuts

M2 derived affine surplus, strict monotonicity, the unique surplus zero, an
endogenous reservation cutoff, the reservation rules, and equation (12). M3
has now derived the tail-integral representation and equations (9), (10), and
(13), together with forward residual conditions.

The development contains no unconditional equilibrium-existence theorem,
equation (11), Beveridge-curve direction theorem, comparative statics,
cyclical or Markov extension, or finite-state witness. M5/M6 existence
statements visibly take `StaticExistenceAssumptions`.

M5 does not use `ShockAssumptions.upperSupport`, atomlessness, shock mean or
variance normalization, worker-meeting-rate monotonicity, matching elasticity,
or differentiability.

The new modules contain no `sorry`, `admit`, or project `axiom`.

## Builds

Run from the repository root:

```sh
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Definitions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Assumptions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Probability.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Matching.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Equilibrium/Value.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Surplus.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/AffineSurplus.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Cutoff.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Continuation.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/JobCreation.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/JobDestruction.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/StaticConditions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Equilibrium/Reduced.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/ReducedAnalytic.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/ForwardBridge.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Reconstruction.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Equivalence.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/ExpectedExcessProperties.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/StaticCurves.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Assumptions/StaticExistence.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/ExistenceUniqueness.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Flows.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Equilibrium/SteadyState.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Unemployment.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/FullEquilibrium.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/All.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Audit.lean
lake build
```

`All.lean` is the substantive aggregate import. `Audit.lean` depends on it,
checks the public interfaces, runs `assert_no_sorry` through M6, and prints
transitive axioms for the main equation (8), M2 cutoff results, the layer-cake
identity, equations (9), (10), and (13), reconstruction, both round-trip
interfaces, nonemptiness equivalence, and the M4 capstone.

The cumulative human-readable theorem account is in
`docs/proof_ledger.{md,tex,pdf}`.

## Review archives

Beginning with Milestone 3, review bundles use the project-local names
`review_m3.zip`, `review_m4.zip`, and so on. Review archives remain untracked
and must never be committed.
