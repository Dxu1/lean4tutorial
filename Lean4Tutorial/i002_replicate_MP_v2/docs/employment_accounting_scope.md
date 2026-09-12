# M10.3 employment-accounting scope

**Status:** COMPLETE - GREEN
**Human mathematical/economic review:** 2026-08-05

M10.3 derives paper equations (36)-(38) for a supplied finite-state equilibrium,
current employment distribution, and next aggregate state. It extends the
reviewed equation-(35) transition; it does not alter that transition.

## Equations

For current employment mass `N_t`, unemployment `U_t = 1 - N_t`, discrete
matching probability `a_j`, and discrete redraw probability `rho`:

- Equation (36): `C_t = a_j (1 - N_t)`.
- Equation (37): `D_t = D_t^agg + D_t^redraw`, where aggregate-cutoff
  destruction is current mass strictly below the next cutoff and redraw
  destruction is `rho * survivingMass * F(cutoff)`.
- Equation (38): `N_(t+1) = N_t + C_t - D_t`. The primary ENNReal theorem is
  the subtraction-free identity `N_(t+1) + D_t = N_t + C_t`.

Both ENNReal and real interfaces are exposed. Finiteness is proved before
conversion to real-valued formulas.

## Rates and probabilities

`P.lambda`, the worker meeting rate `theta*q(theta)`, and aggregate-state
arrival are continuous-time hazards. M10.3 uses two separate one-period
probabilities:

- `DiscreteEmploymentParameters.redrawProb`;
- `DiscreteMatchingParameters.matchProb`.

`PaperMatchingIdentification E DM` explicitly identifies the latter with the
paper's worker meeting hazard for the paper-facing equation (36). The core
discrete accounting does not assume this identification, and no time-step
conversion is silently embedded in the equilibrium.

## Endogenous creation and automatic admissibility

`unemploymentMassENNReal` is `1 - currentMass` and
`endogenousCreationMass` is matching probability times that unemployment.
Creation is bounded by unemployment, so current mass plus creation is at most
one. Combined with incumbent mass being at most current mass, this proves
`endogenousRawNextMass_le_one` and finiteness automatically.

`toEndogenousNextDistribution` therefore needs no externally supplied
creation mass or mass bound. Its measure is exactly the reviewed raw transition
with endogenous creation inserted at the upper-support atom.

## Staged destruction and no double counting

The destruction stages are sequential:

1. aggregate re-evaluation removes `N.measure (Iio cutoff)`;
2. only aggregate survivors reach redraw, and failed redraws contribute
   `redrawProb * survivingMass * P.shock (Iio cutoff)`.

Probability normalization and the almost-sure upper bound partition shock
draws between the strict lower event and the closed survival interval.
Atomlessness equates the strict-event probability, after `toReal`, with the
CDF derived from `P.shock`. The theorem
`incumbentNextMass_add_totalDestructionMass_eq_currentMass` proves exhaustiveness
and non-overlap.

## Relation to earlier milestones

Equation (38) uses `rawNextMass_eq` from M10.2 and the staged destruction
partition; it is not definitional. The aggregate-cutoff component uses the same
strict-cutoff convention as the M9.3 impact operator.
`m10_3_twoState_aggregateDestruction_embedding` proves that the two masses are
equal under the reviewed finite-state embedding and its explicit upper-support
condition.

The theorem layer accesses a supplied `FiniteMarkovEquilibrium`,
`FiniteMarkovEmploymentDistribution`, `ShockAssumptions`, the two explicit
discrete probability structures, and—only for paper equation (36)—
`PaperMatchingIdentification`. It uses no density witness and no
`StaticExistenceAssumptions`.

The full public capstone explicitly collects equations (36), (37), and (38),
together with the staged no-double-counting and subtraction-free additive
identities. Thus Section 5 equations (32)-(38) are **COMPLETE - GREEN**
conditional on a supplied finite Markov equilibrium, current finite employment
distribution, next aggregate state, explicit redraw and matching
probabilities, and—only for paper-facing equation (36)—the transparent
`PaperMatchingIdentification`. No continuous-time rate is silently used as a
one-period probability, no density premise enters equations (36)-(38), and no
external creation mass or mass-bound premise enters the full capstone. The next
aggregate state remains supplied rather than sampled; general equilibrium
existence and numerical simulation are not claimed.

## Deferred numerical layer

Aggregate-state sampling, numerical equilibrium solution, calibration,
simulation, equations (39), (40), and (42), and Tables I-II are outside core
Lean and remain **DEFERRED / OUTSIDE CORE LEAN**. Equation (31) and optional
M5b existence refinements also remain deferred; M5 and M6 retain their
documented AMBER existence qualification. Active analytical proof work is
**COMPLETE THROUGH M10.3**.
