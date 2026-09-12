# M9.1 two-state foundations: scope and adequacy boundary

**Status:** COMPLETE - GREEN

**Human review:** complete, 2026-08-02

M9.1 begins Section 4 by extending the primitive value architecture to an
anticipated recession/boom process. It is deliberately a conditional
representation layer: every theorem starts from a supplied
`TwoStateValueEquilibrium P T`; existence is not claimed.

## Section 4 setup and notation

`AggregateState.recession` represents the paper's low common-productivity
state `p`; `AggregateState.boom` represents the high state `p*`, encoded as
`T.pHigh`. `AggregateState.other` is the symmetric switch, and aggregate
shocks arrive at `T.aggregateArrival`. Statewise tightness and values are
functions of `AggregateState`; the idiosyncratic law `P.shock` and all other
static primitives are shared.

## Primitive values before surplus

`TwoStateValueEquilibrium` records the state-contingent vacancy, filled-job,
worker, and unemployment Bellman equations. The vacancy equation contains
`aggregateArrival * (V s.other - V s)` and the unemployment equation contains
`aggregateArrival * (U s.other - U s)`: anticipated state changes create
capital gains even before free entry is used. The filled-job and worker
equations likewise contain their separately derived aggregate continuation
terms. Only after those primitive equations are recorded does Lean add firm
and worker values and subtract unemployment to derive the coupled surplus
equation. The surplus equation is never an equilibrium field.

## Included

1. `AggregateState` and its involution `AggregateState.other`.
2. `TwoStatePrimitives`, with recession productivity `P.p`, boom productivity
   `T.pHigh`, and aggregate switching rate `T.aggregateArrival`.
3. `TwoStateEconomicAssumptions`, containing only `P.p < T.pHigh` and positive
   aggregate arrival.
4. Statewise primitive projection and transport of core, shock, and matching
   assumptions; static existence assumptions are not transported.
5. `TwoStateValueCandidate` and `TwoStateValueEquilibrium`, with state-specific
   tightness and values and explicit aggregate-transition terms.
6. Derived `TwoStateValueCandidate.surplus` and `activeSurplus`; surplus is not
   an equilibrium field.
7. One shared `idiosyncraticContinuation`, one
   `aggregateSurplusTransition`, and one `workerAggregateContinuation`.
8. Statewise zero vacancy value and the vacancy-cost equation.
9. `surplus_flow_equation` and the probability-normalized general
   `coupled_surplus_bellman` for actual equilibrium surplus.
10. `recession_surplus_bellman` and `boom_surplus_bellman`, which retain the
    other state's positive-part surplus.
11. Conditional regional forms `equation16_of_boom_surplus_nonneg`,
    `equation17_of_recession_surplus_nonneg`, and
    `equation18_of_recession_surplus_nonpos`.
12. The representation capstone `m9_1_two_state_foundations`.

## Explicitly excluded

M9.1 proves no statewise cutoff, cutoff ordering, equilibrium existence or
uniqueness, equation (15), equations (19)-(30), job-creation system,
unemployment dynamics, employment-measure transition, or impact-asymmetry
claim. It does not reuse static equilibrium equations without the aggregate
transition terms.

The paper writes equations (16)–(18) after using the expected ordering of boom
and recession cutoffs. M9.1 instead formalizes one general max-based system.
M9.2 must prove the ordering before interval-specific formulas are certified.

Probability normalization is explicit: paper-facing coupled-surplus theorems
take `ShockAssumptions P` and locally install `D.isProbability`. It is not
stored in `TwoStateValueEquilibrium`.

## Assumptions and fields accessed

- `TwoStateEconomicAssumptions P T` supplies only `p_lt_pHigh` and
  `aggregateArrival_pos`; it is used for the primitive productivity ordering,
  not for the surplus representation.
- `CoreEconomicAssumptions P` contributes only `r_pos` to the zero-vacancy
  theorem and is transported statewise for interface completeness.
- `ShockAssumptions P` contributes `isProbability` to the coupled Bellman
  wrapper. Active-surplus integrability comes from the explicit
  `TwoStateValueEquilibrium.active_surplus_integrable` admissibility field.
- `MatchingAssumptions P` is transported to both state primitive records but
  is not needed by the M9.1 surplus derivations.
- No `StaticExistenceAssumptions`, normalization bundle, cutoff sign, surplus
  ordering, root, or equilibrium witness is accessed.

The principal public declarations are
`AggregateState.other`, `TwoStatePrimitives.statePrimitives`,
`TwoStatePrimitives.productivity`, `TwoStateValueCandidate.surplus`,
`TwoStateValueEquilibrium`, `TwoStateValueEquilibrium.firm_share`,
`aggregate_transition_surplus_identity`, `vacancy_value_eq_zero`,
`statewise_vacancy_equation`, `surplus_flow_equation`,
`coupled_surplus_bellman_of_probability`, `coupled_surplus_bellman`,
`recession_surplus_bellman`, `boom_surplus_bellman`, the three conditional
regional theorems, and `m9_1_two_state_foundations`.

## Dependency boundary

```text
Definitions + ComparativeStatics.ParameterChanges
  → Cyclical.TwoStatePrimitives
  → Cyclical.TwoStateValue
  → Cyclical.TwoStateContinuation
  → Cyclical.TwoStateSurplus
  → Cyclical.TwoStateRegionalEquations
  → Cyclical.TwoStateFoundations
  → All → Audit
```

M9.2 may build statewise cutoffs and prove their ordering from this max-based
system. M9.3 may then add job creation, unemployment dynamics, and impact
asymmetry. Neither later layer is implemented here.

## Human-review conclusion

Review found M9.1 mathematically and economically faithful. It is a conditional
representation theorem for every supplied `TwoStateValueEquilibrium`; it does
not assert existence, and absence of existence is not an AMBER defect. The
vacancy, unemployment, firm, and worker equations all include the appropriate
aggregate-state capital gains. The coupled surplus equation is derived rather
than assumed. The current equation-(16)-(18) theorems are max-form pointwise
sign reductions, not the final cutoff-indexed interval-integral equations. No
cutoff or cutoff ordering is assumed. M9.1 is **COMPLETE - GREEN**.
