# M9.2 scope: statewise cutoffs and the ordering gate

## Status

- **M9.2A — COMPLETE — GREEN**, reviewed 2026-08-02.
- **M9.2B — COMPLETE — GREEN**, reviewed 2026-08-04.
- **M9.2C — NOT STARTED**.
- **M9.2 overall — PARTIAL**.

M9.2A is conditional on a supplied `TwoStateValueEquilibrium P T`; it does not
assert existence, which does not make it AMBER. It derives both monotonicity
results simultaneously, global increment bounds and continuity, and every
statewise cutoff result without a lower shock support or cross-state order.

## Simultaneous monotonicity

`TwoStateMonotonicity.lean` subtracts the coupled max-based surplus equation at
two shocks. The public identities are:

- `TwoStateValueEquilibrium.recession_surplus_difference`;
- `TwoStateValueEquilibrium.boom_surplus_difference`.

Generic positive-part increment bounds then support a simultaneous proof:

- `TwoStateValueEquilibrium.surplus_increment_pos`;
- `TwoStateValueEquilibrium.surplus_strictMono`.

Neither state’s monotonicity is assumed to prove the other’s. The quantitative
bounds are:

- `surplus_difference_lowerBound`, with slope
  `sigma / (r + lambda + aggregateArrival)`;
- `surplus_difference_upperBound`, with slope
  `sigma / (r + lambda)`;
- `surplus_lipschitz` and `surplus_continuous`.

These are increment bounds, not a claim of globally affine two-state surplus.

## Cutoff construction and reservation property

Statewise free entry and matching positivity give `upper_firm_value_pos` and
`upper_surplus_pos`. The lower increment bound gives `exists_surplus_neg`
without assuming a lower shock support. Continuity and the intermediate value
theorem then construct:

- `TwoStateValueEquilibrium.reservationCutoff`;
- `surplus_reservationCutoff_eq_zero`;
- `surplus_eq_zero_iff`;
- `existsUnique_surplus_zero`;
- `reservationCutoff_lt_epsUpper`.

The cutoff is a derived noncomputable definition, not an equilibrium field.
The complete sign interface is:

- `surplus_neg_iff_lt_reservationCutoff`;
- `surplus_pos_iff_reservationCutoff_lt`;
- `surplus_nonneg_iff_reservationCutoff_le`;
- `firm_value_neg_iff_lt_reservationCutoff`;
- `firm_value_eq_zero_iff`;
- `firm_value_nonneg_iff_reservationCutoff_le`.

## Statewise continuation intervals

`TwoStateIntervalIntegrals.lean` defines
`TwoStateValueEquilibrium.survivingSurplusIntegral` using the restriction of
`P.shock` to the closed interval from the statewise cutoff to `epsUpper`.
The theorems
`integral_activeSurplus_eq_survivingSurplusIntegral` and
`statewise_continuation_integral_eq` prove

\[
\int S_s^+(x)\,dF(x)
=
\int_{[d_s,\varepsilon_u]} S_s(x)\,dF(x).
\]

The proof uses the statewise sign characterization and
`ShockAssumptions.upperSupport`. Endpoint values agree exactly because surplus
is zero at the cutoff; no cross-state order is used.

## Assumptions used

- `CoreEconomicAssumptions P`: positivity of `r`, `sigma`, `c`, the bound
  `beta < 1`, and nonnegativity of `lambda`;
- `ShockAssumptions P`: probability normalization for the coupled surplus
  theorem and the almost-sure upper bound for the interval representation;
- `MatchingAssumptions P`: vacancy-meeting positivity for upper-support firm
  value;
- `TwoStateEconomicAssumptions P T`: `pHigh > p` and positive aggregate
  arrival, though the productivity ordering is not needed for all M9.2A
  lemmas;
- a supplied `TwoStateValueEquilibrium P T`.

No shock normalization, cutoff ordering, tightness ordering, surplus affinity,
or two-state existence premise is added.

## M9.2B maximum-principle cutoff ordering

Conditional interval-sign lemmas for either possible cutoff order remain in
`TwoStateCutoffOrdering.lean`; that module asserts no order.
`TwoStateCrossStateComparison.lean` implements the reviewed contradiction
route. Under the temporary contrary premise `d_R ≤ d_B`, it proves regional
gap constancy, the global comparison `S_B ≤ S_R`, the induced order
`theta_B ≤ theta_R`, and the pointwise and integrated maximum-principle bound

\[
D_u \le S_B^+(x)-S_R^+(x), \qquad D_u \le I_B-I_R.
\]

It also exposes the upper-support difference equation

\[
(r+\lambda+2\mu)D_u=(p^*-p)+\lambda(I_B-I_R)
  +\frac{\beta c}{1-\beta}(\theta_R-\theta_B).
\]

`TwoStateCutoffOrderingResults.lean` combines these named facts to contradict
`D_u ≤ 0` and proves `boom_cutoff_lt_recession_cutoff`. It then derives
strictly larger boom upper-support surplus and boom tightness. No cutoff,
surplus, tightness, search-gain, or closure assumption was added. The detailed
proof map is in
[`two_state_cutoff_ordering_analysis.md`](two_state_cutoff_ordering_analysis.md).

Human review on 2026-08-04 found this maximum-principle proof mathematically
and economically faithful. It begins from a supplied
`TwoStateValueEquilibrium`, proves `d_B < d_R`, and embeds no order or closure
conclusion as an assumption. M9.2C is the next milestone and must derive the
ordered regional equations only after using this proved cutoff order.

M9.2C was not begun. No exact ordered versions of equations
(16)–(18), no equations (19)–(24), and no regional slope theorem were added.
The earlier M9.1 pointwise max-form sign reductions remain unchanged.

## Deferred to M9.3

M9.3 remains wholly unimplemented: equation (15), job-creation equations
(25)–(30), unemployment/employment dynamics, impact creation or destruction,
and asymmetry results are all deferred. M9.3 may begin only after a reviewed
resolution of the M9.2 ordering gate and completion of M9.2C.

Foundation details are in
[`two_state_foundations_scope.md`](two_state_foundations_scope.md).
