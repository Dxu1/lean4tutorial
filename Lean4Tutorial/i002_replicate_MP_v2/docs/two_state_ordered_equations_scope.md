# M9.2C ordered regional equations: scope and theorem map

Status: **COMPLETE - GREEN**, reviewed 2026-08-04, conditional on a supplied
`TwoStateValueEquilibrium P T`.

M9.2C is conditional on a supplied `TwoStateValueEquilibrium P T`. It derives
the paper's interval formulas only after M9.2B has proved the strict orders

```text
dB < dR,   theta_recession < theta_boom.
```

No regional equation, cutoff order, or affine formula is stored in the
equilibrium structure.

Human review confirmed that M9.2C derives the exact ordered equations only
after M9.2B proves the ordering, that equation (21) is stated in stronger
difference form, and that the hinge, expected-excess, tail-integral, cutoff
equation, and capstone layers are mathematically and economically faithful.

## Exact regions for equations (16)-(18)

- `equation16_ordered`: recession equation (16), for `dR ≤ eps`.
- `equation17_ordered`: boom equation (17), for `dR ≤ eps`.
- `equation18_ordered`: boom equation (18), for `dB ≤ eps ≤ dR`.

The first two regions have nonnegative surplus in both states. Between the
cutoffs, boom surplus is nonnegative and recession surplus is nonpositive, so
the recession aggregate-transition option is zero. Each idiosyncratic
continuation integral is the existing state-specific integral over
`[d_s, epsUpper]`; it is not a new equilibrium field.

## Difference and affine results

The primary results are two-point identities:

- `recession_surplus_difference_above_recession_cutoff`;
- `boom_surplus_difference_above_recession_cutoff`;
- `equation21_difference`;
- `boom_surplus_difference_between_cutoffs`.

Above `dR`, both state surpluses have slope
`sigma / (r + lambda)`. Between `dB` and `dR`, boom surplus has the smaller
slope `sigma / (r + lambda + aggregateArrival)`. Positivity of the primitive
rates proves the latter coefficient is strictly between zero and the common
upper slope. Pointwise consequences are
`recession_surplus_above_recession_cutoff`,
`boom_surplus_between_cutoffs`, `equation23`, and
`boom_surplus_above_recession_cutoff`.

Difference form is foundational: M9.2C does not assume differentiability or a
derivative field. Equation (21) is certified in difference form, which is
stronger for the exact affine regions needed here.

## Hinge and option-value identities

Let

```text
a = sigma / (r + lambda + aggregateArrival)
b = sigma / (r + lambda).
```

Lean proves `0 < a < b`, then derives

```text
recession active surplus = b * positivePart (x - dR)
boom active surplus      = a * positivePart (x - dB)
                         + (b - a) * positivePart (x - dR).
```

The exact declarations are `recession_activeSurplus_hinge` and
`boom_activeSurplus_hinge`. Integration against `P.shock` gives
`recession_activeSurplus_integral_eq_expectedExcess` and
`boom_activeSurplus_integral_eq_expectedExcess`. The generic M3 layer-cake
theorem then gives the paper-facing forms
`recession_activeSurplus_integral_eq_tailOptionValue` and
`boom_activeSurplus_integral_eq_tailIntervals`. Here `P.shock` is the
probability law, its induced CDF is `F`, and integration with respect to `dF`
is represented in Lean by integration against `P.shock`.

## Equations (19)-(24)

- `equation19`: equation (18) with the split boom option value substituted.
- `equation20`: equation (19) at `dB`, using zero boom surplus and boom free
  entry.
- `equation21_difference`: common upper-region affine slope.
- `equation22`: equation (16) with the recession tail option value substituted.
- `equation23`: boom bridge value at `dR`.
- `equation24`: equation (22) at `dR`, using recession free entry and equation
  (23); the aggregate-transition gap enters with a negative sign.

`m9_2C_ordered_equations_capstone` packages these results through the derived
proposition `SatisfiesM92COrderedEquations`.
`m9_2_full_cutoff_capstone` combines M9.2A monotonicity and unique cutoffs,
M9.2B cutoff/tightness ordering, and the M9.2C equation package.

## Assumptions and boundary

The theorem layer takes `CoreEconomicAssumptions P`, `ShockAssumptions P`,
`TwoStateEconomicAssumptions P T`, `MatchingAssumptions P`, and a supplied
`TwoStateValueEquilibrium P T`. It uses primitive positivity, probability and
integrability of the shock law, the almost-sure upper bound, matching-rate
positivity/strict decrease, and the equilibrium equations/free-entry fields.
It does not take cutoffs, cutoff ordering, affinity, derivatives,
`StaticExistenceAssumptions`, or a selected equilibrium constructed from
primitives.

M9.3 remains **NOT STARTED**. In particular, M9.2C contains no equation (15),
equations (25)-(30), statewise job-creation system, unemployment-stock or
employment-measure dynamics, impact-asymmetry result, Markov generalization,
or simulation.
