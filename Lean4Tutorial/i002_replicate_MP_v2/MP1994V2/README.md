# MP1994V2: value equilibrium and reduced static conditions

`MP1994V2` is the clean, staged replication architecture for Mortensen and
Pissarides (1994), implemented through the M9.3 cyclical-dynamics layer. The legacy `MP1994` files
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
  employment, and vacancy stocks; M7 proves global order comparative statics
  for supplied equilibria; M8 proves the Appendix derivative algebra and sign
  results for supplied differentiable equilibrium paths; M8b now derives all
  four Appendix paths locally from a supplied reduced equilibrium; M9.1 adds
  the anticipated two-state primitive value system and derives its general
  coupled max-based surplus equations; M9.2A derives simultaneous statewise
  monotonicity, unique cutoffs, reservation signs, and interval integrals;
  M9.2B proves that the boom cutoff is strictly below the recession cutoff by
  a maximum-principle comparison; M9.2C derives the ordered regional formulas
  and paper equations (16)-(24); M9.3 derives equations (25)-(30), encodes
  equation (15) as a fixed-state labor-flow law, and proves the exact
  measure-valued impact asymmetry of aggregate shocks.

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
ParameterChanges ───────────────┐
StaticCurves → FixedTightness   │
      └→ EquilibriumOrders      │
[Unemployment,                  │
 EquilibriumOrders]            │
      → FlowImplications        │
      → StaticComparativeStatics
                         ↓
[Assumptions.Appendix, ExpectedExcessDerivative,
 AppendixParameterChanges, AppendixPaths]
      → AppendixFixedTightness → AppendixAlgebra
      → [AppendixLambda, AppendixDiscount, AppendixDispersion]
      → AppendixComparativeStatics
                         ↓
[Assumptions.AppendixIFT, ExpectedExcessDerivative, StaticCurves]
      → ImplicitResiduals → ImplicitFunctionFoundation
      → [ImplicitFixedTightness, ImplicitLambda,
          ImplicitDiscount, ImplicitDispersion]
      → [ImplicitComparativeStatics,
          ImplicitAppendixComparativeStatics]
                         ↓
Cyclical.TwoStatePrimitives → TwoStateValue
      → TwoStateContinuation → TwoStateSurplus
      → TwoStateRegionalEquations → TwoStateFoundations
      → TwoStateMonotonicity → TwoStateCutoff
      → [TwoStateIntervalIntegrals, TwoStateCutoffOrdering]
      → TwoStateCrossStateComparison
      → TwoStateCutoffOrderingResults
      → TwoStateOrderedRegionalEquations
      → TwoStateRegionalAffine → TwoStateOptionValues
      → TwoStateCutoffEquations → TwoStateCutoffResults
      → TwoStateJobCreation → TwoStateFlowRates
      → TwoStateUnemploymentDynamics ──────────────┐
                                                   │
      TwoStateCutoffResults → TwoStateEmploymentImpact
                                                   │
      [TwoStateJobCreation, TwoStateUnemploymentDynamics,
       TwoStateEmploymentImpact] → TwoStateCyclicalDynamics
                         ↓
                        All → Audit
```

In particular, `JobDestruction` and `JobCreation` feed both
`StaticConditions` and `Equilibrium.Reduced`. `ForwardBridge` imports those
two combining modules. `ReducedAnalytic` imports `Continuation` and
`Equilibrium.Reduced`; `Reconstruction` follows `ReducedAnalytic`; and
`Equivalence` imports `ForwardBridge` and `Reconstruction`.

`All.lean` imports all substantive modules directly, including the five M7,
ten M8, six M8b.1, three M8b.2, six M9.1 modules, the three M9.2A aggregate
modules, the two M9.2B modules, and the five M9.2C modules. `Audit.lean` imports
`All.lean` and adds compile-time checks; the five M9.3 modules are also
imported directly by `All.lean`. No substantive Milestone 0 module or
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

## Milestone 7: static order comparative statics

M7 is **COMPLETE - GREEN**. `ComparativeStatics/ParameterChanges.lean` provides immutable one-field
updates for `p`, `b`, `lambda`, and `r`, together with transparent assumption
transport. `FixedTightness.lean` proves the JD-only cutoff effects: higher `p`
strictly lowers the cutoff, higher `b` strictly raises it, higher `lambda`
weakly lowers it, and higher `r` weakly raises it.

The last two general results are robustly weak because the option value may be
zero. Separate GREEN refinements prove strict cutoff movement when
`P.expectedExcess dLow > 0`; the strict discount-rate refinement additionally
requires `P.lambda > 0`. The current almost-sure upper-bound assumption does
not by itself supply this positivity.

For arbitrary supplied reduced equilibria, `EquilibriumOrders.lean` proves
that higher `p` lowers the cutoff and raises tightness, higher `b` raises the
cutoff and lowers tightness, higher `lambda` lowers the cutoff, and higher `r`
lowers tightness. `FlowImplications.lean` converts the `p` and `b` orders into
weak separation, finding, initial creation/destruction, steady unemployment,
and employment implications. Vacancy stocks are deliberately unsigned.

These are universal conditional order theorems: no M7 core theorem uses
M5's `StaticExistenceAssumptions.lower_crossing`. The equilibrium tightness
effect of `lambda`, equilibrium cutoff effect of `r`, all `sigma` effects, and
Appendix derivatives are reserved for M8. See
[`docs/static_comparative_statics_scope.md`](../docs/static_comparative_statics_scope.md)
for the precise scope and strict-versus-weak distinctions.

The M7 dependency path is deliberately independent of conditional existence:
`StaticCurves -> FixedTightness -> EquilibriumOrders`, while
`Unemployment` and `EquilibriumOrders` feed `FlowImplications`. Selected-
equilibrium wrappers using M5's existence assumption would be separately
AMBER; they are not part of M7.

## Milestone 8: Appendix derivative comparative statics

M8 is **COMPLETE - AMBER** after human review. Its
analytic infrastructure is GREEN: atomlessness gives CDF continuity,
`expectedExcess` has the required derivative, and the measure-theoretic
identities used in (A4) and (A11) are proved. The supplied-path layer derives
equation (11), equations (A1)-(A12), a negative cutoff and tightness response
to `lambda`, a negative tightness response to `r` with the cutoff sign governed
by the exact (A8) condition, and positive tightness and cutoff responses to
`sigma` when `b ≤ p`.

The AMBER qualification is narrow: `LocalReducedEquilibriumPath` and
`FixedTightnessSigmaPath` require exact differentiable paths satisfying the
local JD/JC equations, but M8 does not construct those paths with an implicit-
function theorem. These are closure premises, not sign or comparative-static
conclusions, and no M8 theorem imports or uses `StaticExistenceAssumptions` or
an M5-selected witness. At the low-level theorem layer `lambda ≥ 0` comes from
the core assumptions; the capstone states the paper's interior convention
`0 < lambda` explicitly.

The optional derivative of the worker meeting rate is not part of the current
core. Appendix matching assumptions instead impose differentiability of `q`
on positive tightness and the elasticity restriction `0 < eta < 1`. The exact
adequacy boundary and the future M8b implicit-path route are documented in
[`docs/appendix_differentiability_scope.md`](../docs/appendix_differentiability_scope.md).

## M8b.1: local implicit-function foundation

M8b.1 is **COMPLETE - GREEN**, reviewed 2026-08-01, relative to a supplied
reduced equilibrium and the explicit technical regularity bundle
`AppendixIFTAssumptions`. It uses Mathlib's
`ContDiffAt.implicitFunction` through the generic scalar wrapper
`exists_localImplicitCutoffPath`. The parameterized JD and scalar-crossing
residuals are proved locally `C¹`; their cutoff derivatives are proved
strictly positive and strictly negative, respectively. Thus nondegeneracy is
derived rather than assumed.

From any supplied `R : ReducedEquilibrium P`, M8b.1 constructs a
`FixedTightnessSigmaPath P R.theta` and, under `0 < P.lambda`, a
`LambdaEquilibriumPath P`. It then applies the existing M8 capstones. The
construction does not import `StaticExistenceAssumptions` and does not select
an M5 equilibrium. The selected functions are noncomputable and locally
unique as residual roots; no global path uniqueness is claimed.

At M8b.1 completion, M8 remained AMBER because discount and dispersion paths
were still supplied. M8b.2 now constructs them and has passed human review.
The GREEN grade does not claim that the paper explicitly assumes `q` is
continuously differentiable. Base roots are derived, cutoff nondegeneracy is
proved, and no derivative sign is assumed. Neither global path uniqueness nor
global equilibrium uniqueness is claimed. The full IFT-derived Appendix
package is now GREEN relative to a supplied regular reduced equilibrium.
See [`docs/m8b_implicit_function_scope.md`](../docs/m8b_implicit_function_scope.md)
and [`docs/m8b_ift_api_notes.md`](../docs/m8b_ift_api_notes.md).

## M8b.2: discount and dispersion implicit paths

M8b.2 is **COMPLETE - GREEN**, reviewed 2026-08-02. From any supplied regular
`R : ReducedEquilibrium P`, it constructs local `DiscountEquilibriumPath P`
and `DispersionEquilibriumPath P` objects using the scalar IFT route. The base
roots come from `R`; both cutoff partials are proved strictly negative; local
`C¹` regularity is proved; and local JD and product-form JC are established
before packaging the paths.

The selected paths feed `ReducedEquilibrium.m8b_discount_capstone` and
`ReducedEquilibrium.m8b_dispersion_capstone`. Normalization and `b ≤ p` enter
only the dispersion sign capstone, not path construction. The discount result
retains the exact A8 iff characterization and imposes no unconditional cutoff
sign. `ReducedEquilibrium.m8b_full_appendix_capstone` combines all four
constructed paths without M5 selection, supplied path objects, derivative
sign assumptions, or assumed nondegeneracy. Together M8b.1 and M8b.2 derive
all four Appendix paths, so the full Appendix comparative-static package is
**COMPLETE - GREEN** relative to a supplied regular reduced equilibrium,
`AppendixMatchingAssumptions`, `AppendixIFTAssumptions`, and explicit sign
conditions such as `0 < P.lambda` and `P.b ≤ P.p`.

No `StaticExistenceAssumptions` or M5-selected equilibrium is used. Residual
roots are derived, cutoff nondegeneracy is proved, and the full GREEN capstone
assumes neither a path nor a derivative sign. The primitive condition
`AppendixIFTAssumptions.q_contDiffOn_pos` is an explicit technical regularity
strengthening. Selecting the supplied base equilibrium from primitives would
be a separate wrapper and would inherit M5's AMBER existence qualification.

## M9.1: anticipated two-state foundations

M9.1 is **COMPLETE - GREEN**, reviewed 2026-08-02. It introduces
`AggregateState`, `TwoStatePrimitives`, `TwoStateValueCandidate`, and
`TwoStateValueEquilibrium`. The latter records the anticipated recession/boom
value equations with explicit aggregate-state transition terms. Surplus and
all continuation terms are derived once from the value functions.

The theorem layer derives statewise zero vacancy values, firm sharing, the raw
surplus-flow equation, and one coupled max-based Bellman system. The recession
and boom specializations retain the positive part of the other state's
surplus. Equations (16)-(18) are exposed only under the exact pointwise sign
hypotheses that simplify those positive parts.

M9.1 proves no cutoff, cutoff ordering, equilibrium existence, job-creation
system, unemployment dynamics, or impact asymmetry. The precise boundary and
declaration inventory are in
[`docs/two_state_foundations_scope.md`](../docs/two_state_foundations_scope.md).

Human review confirmed that M9.1 is a conditional representation theorem for
every supplied `TwoStateValueEquilibrium`; it does not assert existence, and
that does not make the representation AMBER. Aggregate capital gains appear
in the primitive vacancy, unemployment, firm, and worker equations, and the
coupled surplus equation is derived from them. The equation-(16)-(18) results
are pointwise max-form sign reductions, not yet the paper's final
cutoff-indexed interval-integral formulas. No cutoff or cutoff order is assumed.

## M9.2: statewise cutoffs and cutoff ordering

M9.2A is **COMPLETE - GREEN**, reviewed 2026-08-02. Starting from the coupled
max-based system, it proves the two surplus-increment identities
simultaneously, strict monotonicity in both states, global quantitative
increment bounds, Lipschitz continuity, and positive upper-support surplus.
The lower increment bound supplies a negative-surplus witness, so continuity
and strict monotonicity yield one unique admissible cutoff in each state.

`TwoStateValueEquilibrium.reservationCutoff` is derived from the actual surplus
zero; it is not stored in the equilibrium. The reservation-property theorems
characterize all surplus and firm-value signs, and
`statewise_continuation_integral_eq` rewrites each max-based continuation
integral over its own cutoff-to-`epsUpper` interval. None of these results uses
a cross-state cutoff order.

The initial M9.2B route stalled at an apparently uncontrolled cross-state
search-gain difference. The implemented maximum-principle route assumes the
contrary weak cutoff order only inside a contradiction proof, proves boom
surplus lies below recession surplus globally, uses free entry to order
tightness, integrates the active-surplus gap, and contradicts the upper-support
difference equation using `pHigh > p`. It proves
`boom_cutoff_lt_recession_cutoff`, then derives strictly larger boom
upper-support surplus and tightness. Human mathematical/economic review on
2026-08-04 graded M9.2B **COMPLETE - GREEN**.

M9.2C now derives the exact cutoff-indexed forms of equations (16)-(18), the
common difference slope `sigma / (r + lambda)` above the recession cutoff,
and the lower boom slope `sigma / (r + lambda + aggregateArrival)` between
cutoffs. The resulting recession and boom hinge formulas yield exact
expected-excess and CDF-tail option values. Equations (19), (20), (22), (23),
and (24) then follow by substitution and statewise free entry.

Human mathematical/economic review on 2026-08-04 graded M9.2C and full M9.2
**COMPLETE - GREEN**, conditional on a supplied `TwoStateValueEquilibrium`.
Equation (21) is formalized in the stronger difference form. No cutoff order,
regional affinity, derivative result, interval equation, or option-value
formula is assumed or stored in the equilibrium, and no
`StaticExistenceAssumptions` or primitive-selected two-state equilibrium is
used. See
[`docs/two_state_cutoff_scope.md`](../docs/two_state_cutoff_scope.md) and
[`docs/two_state_cutoff_ordering_analysis.md`](../docs/two_state_cutoff_ordering_analysis.md),
and the detailed M9.2C boundary in
[`docs/two_state_ordered_equations_scope.md`](../docs/two_state_ordered_equations_scope.md).

## M9.3: job creation, unemployment dynamics, and impact asymmetry

M9.3 derives paper equations (25)-(30) from the reviewed M9.2 regional
surplus formulas and statewise free entry. The boom denominator is proved
positive and strictly below its same-cutoff static gap, yielding the
anticipation wedge in the vacancy-contact target.

The flow layer keeps three objects distinct:

- `q(theta)` is the vacancy contact rate;
- `theta*q(theta)` is the unemployed-worker meeting hazard;
- `u*theta*q(theta)` is aggregate continuous job creation.

The idiosyncratic destruction hazard is `lambda*F(d_s)`. Equation (15) is
encoded as the statewise vector field
`(1-u)*lambda*F(d_s) - u*theta_s*q(theta_s)`. The implementation proves its
affine form, stationary unemployment, local drift signs, and the strict
boom-below-recession drift comparison at a common interior unemployment
stock. It does not assert existence or ordering of ODE paths.

`StateEmploymentDistribution` stores a finite employment measure supported
above the current cutoff, without a density assumption. The aggregate-impact
operator restricts that measure to the new survival region. A
recession-to-boom transition leaves employment unchanged on impact. A
boom-to-recession transition destroys exactly the mass in `[dB,dR)` and
raises real-valued unemployment by that mass. Strict employment loss requires
strictly positive pre-shock mass in that interval. Impact creation is zero by
the explicit continuous-matching timing convention, not by cutoff ordering.

M9.3 is **COMPLETE - GREEN**, reviewed 2026-08-04, conditional on a
supplied `TwoStateValueEquilibrium` and admissible employment measures. The
strict worker-hazard and creation-flow orders use the existing
`AppendixMatchingAssumptions`; no `AppendixIFTAssumptions` are needed. Human
review confirmed equations (25)-(30), the flow-law boundary, and the exact
impact timing/asymmetry result. The full M9.1-M9.3 Section 4 productivity-shock
package is **COMPLETE - GREEN**, conditional on a supplied
`TwoStateValueEquilibrium`. M10.1 equations (32)-(34) are next; equation (31),
M10.2, M10.3, and simulation remain unimplemented. See
[`docs/two_state_cyclical_dynamics_scope.md`](../docs/two_state_cyclical_dynamics_scope.md).

## Prohibited shortcuts

M2 derived affine surplus, strict monotonicity, the unique surplus zero, an
endogenous reservation cutoff, the reservation rules, and equation (12). M3
has now derived the tail-integral representation and equations (9), (10), and
(13), together with forward residual conditions.

The development contains no unconditional equilibrium-existence theorem,
Beveridge-curve direction theorem, unconditional statistical volatility or
lead-lag theorem, or finite-state witness. M5/M6
existence statements visibly take `StaticExistenceAssumptions`; M7 pairwise
comparative statics do not.

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
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/ComparativeStatics/ParameterChanges.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/ComparativeStatics/FixedTightness.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/ComparativeStatics/EquilibriumOrders.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/ComparativeStatics/FlowImplications.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/ComparativeStatics/StaticComparativeStatics.lean
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
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateOrderedRegionalEquations.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateRegionalAffine.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateOptionValues.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateCutoffEquations.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateCutoffResults.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateJobCreation.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateFlowRates.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateUnemploymentDynamics.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateEmploymentImpact.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Cyclical/TwoStateCyclicalDynamics.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/All.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Audit.lean
lake build
```

`All.lean` is the substantive aggregate import. `Audit.lean` depends on it,
checks the public interfaces, runs `assert_no_sorry` through M9.3, and prints
transitive axioms for the main equation (8), M2 cutoff results, the layer-cake
identity, equations (9), (10), and (13), reconstruction, both round-trip
interfaces, nonemptiness equivalence, and the M4 capstone.

The cumulative human-readable theorem account is in
`docs/proof_ledger.{md,tex,pdf}`.

## Review archives

Beginning with Milestone 3, review bundles use the project-local names
`review_m3.zip`, `review_m4.zip`, and so on. Review archives remain untracked
and must never be committed.
