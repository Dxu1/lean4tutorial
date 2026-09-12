# M10.2 employment-transition scope

**Status:** COMPLETE - GREEN. **Human review:** 2026-08-04.

> `redrawProb` is a discrete one-period probability. It is not definitionally
> equal to the continuous-time rate `P.lambda`.

## Economic contract

Paper equation (35) advances an employment distribution after a supplied next
aggregate state is known. Lean resolves the paper's overloaded lambda notation
by using `DiscreteEmploymentParameters.redrawProb`, with `0 ≤ redrawProb ≤ 1`.
The order is: apply the next-state cutoff; discard incumbents below it; let each
survivor retain its shock or redraw; discard redraws below the cutoff; then add
a supplied creation mass at `P.epsUpper`.

For current measure `nu`, next cutoff `d`, upper support `u`, redraw probability
`rho`, and supplied creation mass `C`, the incumbent measure is

```text
(1-rho) * nu|[d,u] + rho * nu([d,u]) * P.shock|[d,u].
```

The raw next measure adds `C * dirac u`. Creation is an upper-support atom
because new jobs begin at the paper's highest idiosyncratic productivity. The
primary theorem is measure-valued, so no density is assumed in the core layer.

## Measures and identities

`currentMass` is the current total mass, `survivingMass` is the mass after
next-cutoff re-evaluation, `incumbentNextMass` follows redraw, and `rawNextMass`
also includes creation. Lean proves the robust decomposition

```text
currentMass = current measure (-infinity,d) + survivingMass,
```

the exact incumbent formula, and `rawNextMass = incumbentNextMass + C`.
`toNextDistribution` requires explicit finiteness of `C` and an explicit raw
mass-at-most-one premise; arbitrary supplied creation is not claimed to
preserve mass.

When redraw probability and creation mass are both zero, the operator is just
cutoff restriction. `m10_2_twoState_impact_embedding` identifies this case with
the reviewed M9.3 aggregate-shock impact measure, under the matching upper-bound
premise.

## Equation (35) and optional densities

`equation35_measure` restricts the raw next measure to `(-infinity,u)` and gives
the unconditional interior measure equation. Optional, separate
`ShockDensityRepresentation` and `EmploymentDensityRepresentation` witnesses
yield, for almost every shock `eps`,

```text
nextDensity eps =
  if d ≤ eps and eps < u then
    (1-rho) * currentDensity eps
      + rho * survivingMass * shockDensity eps
  else 0.
```

`rawNextMeasure_restrict_Iio_eq_density` proves the interior with-density
representation. `rawNextMeasure_eq_density_plus_upperAtom` proves the entire
raw-next measure is that interior density plus the upper-support atom.
`EmploymentDensityRepresentation.measure_singleton_epsUpper_eq` identifies the
current upper atom, while `ShockAssumptions.shock_singleton_eq_zero` excludes a
redraw atom. Consequently, `equation35_upperMass` proves the actual raw-next
mass at `epsUpper` is `(1-rho) * currentUpperMass + C`; this is not merely a
definitional identity. The most productive jobs excluded from the paper's
interior density are therefore tracked exactly.
The installed Mathlib `withDensity` and restriction API was sufficient; there
is no remaining density obstruction.

## Assumptions and dependency boundary

The transition is conditional on a supplied `FiniteMarkovEquilibrium`, current
`FiniteMarkovEmploymentDistribution`, next state, `ShockAssumptions`, discrete
redraw parameters, and creation mass. It accesses the equilibrium cutoff and
primitive shock law/upper support. Aggregate-state sampling is outside equation
(35). There is no relation between `redrawProb` and `P.lambda`.

M10.3 must still define endogenous creation mass, distinguish cutoff and redraw
losses, prove no double counting, and derive equations (36)-(38). None of those
objects or results is part of M10.2.

## Principal Lean declarations

- `DiscreteEmploymentParameters`, `one_sub_redrawProb_nonneg`
- `FiniteMarkovEmploymentDistribution`, `employmentMass`, `unemploymentMass`
- `Primitives.shockSurvivingMeasure`, `survivingMeasure`, `survivingMass`
- `noRedrawMeasure`, `redrawMeasure`, `incumbentNextMeasure`
- `upperCreationMeasure`, `rawNextMeasure`, `toNextDistribution`
- `currentMass_eq_belowCutoff_add_survivingMass`
- `incumbentNextMass_eq`, `rawNextMass_eq`
- `incumbentNextMeasure_of_redrawProb_zero`
- `rawNextMeasure_of_redrawProb_zero_creation_zero`
- `m10_2_twoState_impact_embedding`
- `ShockDensityRepresentation`, `EmploymentDensityRepresentation`
- `nextInteriorDensity`, `nextUpperMass`
- `EmploymentDensityRepresentation.measure_singleton_epsUpper_eq`
- `ShockAssumptions.shock_singleton_eq_zero`
- `equation35_measure`, `rawNextMeasure_restrict_Iio_eq_density`
- `rawNextMeasure_eq_density_plus_upperAtom`
- `equation35_density_ae`, `equation35_upperMass`
- `m10_2_measureTransition_capstone`, `m10_2_equation35_capstone`
- `m10_2_employmentTransition_foundations_capstone`
