# M9.3 cyclical dynamics: scope and theorem map

Status: **COMPLETE - GREEN**, reviewed 2026-08-04.

M9.3 is conditional on a supplied `TwoStateValueEquilibrium P T`. It uses
the statewise cutoffs and strict order proved in M9.2; it does not select an
equilibrium from primitives.

## Equations (25)-(30)

`TwoStateJobCreation.lean` exposes:

- `equation25` and `equation26`: the coupled upper-region difference
  equations above the recession cutoff;
- `equation27`: recession surplus
  `sigma*(eps-dR)/(r+lambda)`, reusing the stronger M9.2C affine theorem;
- `equation28`: the recession vacancy-contact condition;
- `equation29`: the anticipated boom surplus formula above `dR`;
- `boomJobCreationDenominator`, `boomJobCreationDenominator_eq`, and
  `boomJobCreationDenominator_pos`;
- `equation30`: the boom vacancy-contact condition;
- `boomJobCreationDenominator_lt_staticGap` and
  `staticJobCreationTarget_lt_boomVacancyMeetingRate`: the anticipation
  wedge; and
- `m9_3_jobCreation_capstone`.

Every denominator is proved positive or nonzero before division. No regional
formula or numbered equation is stored in the equilibrium.

## Contact rates, hazards, and flows

The model distinguishes:

- vacancy contact rate: `q(theta)`;
- unemployed-worker meeting hazard: `theta*q(theta)`;
- aggregate continuous creation flow: `u*theta*q(theta)`.

The exact declarations are `workerMeetingHazard` and `jobCreationFlow`.
The idiosyncratic destruction hazard and flow are
`idiosyncraticDestructionHazard = lambda*F(d_s)` and
`idiosyncraticDestructionFlow = (1-u)*lambda*F(d_s)`.

Core matching assumptions give positivity of the worker meeting hazard.
Strict monotonicity on positive tightness follows from
`AppendixMatchingAssumptions`, through differentiability of `q` and
`0 < matchingElasticity < 1` imply derivative
`q(theta)*(1-matchingElasticity(theta)) > 0`. No
`AppendixIFTAssumptions` are used.

M9.2's orders imply:

- `boom_destructionHazard_le_recession`;
- `recession_workerMeetingHazard_lt_boom`;
- `recession_jobCreationFlow_lt_boom`; and
- `boom_idiosyncraticDestructionFlow_le_recession`.

Destruction ordering is weak in general. The strict variants explicitly take
`0 < lambda` and a strict CDF increase between the two cutoffs.

## Equation (15) and fixed-state unemployment

`unemploymentDrift` is the vector field

`(1-u)*lambda*F(d_s) - u*theta_s*q(theta_s)`.

`equation15` records this flow accounting. `SatisfiesEquation15` describes
a supplied differentiable path whose derivative equals the vector field; no
ODE existence theorem is claimed.

`stationaryUnemployment` is
`delta_s/(delta_s+a_s)`. Theorems prove its denominator positive, its value
in `[0,1)`, zero drift at the stationary value, positive drift below it, and
negative drift above it. At a common `0 < u <= 1`,
`boom_unemploymentDrift_lt_recession` states that the boom vector field
points more strongly toward lower unemployment. It does not order global
paths.

## Aggregate-shock impact timing

`StateEmploymentDistribution` contains a finite measure of incumbent jobs,
total mass at most one, and support above the current cutoff. It assumes no
density and no positive mass between cutoffs.

`afterAggregateShock` restricts the incumbent measure to
`[d_new,infinity)`. This is a transparent timing convention:

1. incumbents are immediately re-evaluated;
2. jobs below the new cutoff are destroyed;
3. no match forms at the mathematical instant of the shock;
4. later creation occurs through the continuous matching flow.

`impactCreationMass` is therefore definitionally zero; that fact is a model
timing convention, not a consequence of cutoff ordering.

For a recession-to-boom transition:

- `recession_to_boom_employmentMeasure_eq`;
- `recession_to_boom_impactDestruction_zero`;
- `recession_to_boom_no_impact_employment_change`; and
- `recession_to_boom_unemploymentMass_eq`

show that the incumbent measure and unemployment are unchanged on impact.

For a boom-to-recession transition:

- `boom_to_recession_measure_decomposition`;
- `boom_to_recession_impactDestruction_eq`;
- `boom_to_recession_totalMass_accounting`; and
- `boom_to_recession_unemploymentMass_eq`

show that the destroyed mass is exactly the pre-shock employment measure of
`[dB,dR)`, with the same amount added to real-valued unemployment.
`boom_to_recession_employmentMass_lt` requires strictly positive mass in
that interval. No unconditional strict-impact claim is made.

The capstones are `m9_3_impact_asymmetry_capstone` and
`m9_3_full_cyclical_dynamics_capstone`.

## Assumptions and deliberate exclusions

Equations (25)-(30), hazard levels, and impact results use
`CoreEconomicAssumptions`, `ShockAssumptions`,
`TwoStateEconomicAssumptions`, `MatchingAssumptions`, and the supplied
value equilibrium. Strict worker-hazard, creation-flow, and cross-state drift
comparisons additionally use `AppendixMatchingAssumptions`.

M9.3 does not use `StaticExistenceAssumptions`,
`AppendixIFTAssumptions`, a density, a primitive-selected two-state
equilibrium, an assumed cutoff order, affinity, or impact asymmetry. It does
not formalize statistical volatility, lead-lag behavior, simulation findings,
or dispersion-cycle equation (31).

Human mathematical/economic review confirmed that equations (25)-(30) agree
with Section 4 and that equation (27) appropriately reuses the stronger M9.2C
affine theorem. Equation (15) is a transparent labor-flow vector field; no ODE
existence or global unemployment-path theorem is claimed. The impact operator
is an explicit timing convention that re-evaluates incumbents before
continuous matching: a downturn destroys exactly `[dB,dR)`, strictly only
when that interval carries positive pre-shock employment mass, while an
upturn creates no employment instantaneously. No statistical volatility,
lead-lag, or simulation result is claimed.

The complete Section 4 productivity-shock package M9.1-M9.3 is **COMPLETE -
GREEN**, conditional on a supplied `TwoStateValueEquilibrium`. Equation (31)
remains unimplemented. M10.1, finite-state Markov equations (32)-(34), is the
next milestone; M10.2 and M10.3 remain not started.

Related scope documents:

- [Two-state foundations](two_state_foundations_scope.md)
- [Statewise cutoffs](two_state_cutoff_scope.md)
- [Ordered equations](two_state_ordered_equations_scope.md)
