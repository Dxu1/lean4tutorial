# Aiyagari (1994) in Lean 4

This directory translates only `aiyagari1994_theory_summary.tex` into Lean 4.

## Files

- `Definitions.lean`: notation, debt limits, household-policy predicates,
  stationary-law interfaces, production primitives, and assumptions.
- `Equilibrium.lean`: household, stationary recursive competitive,
  full-insurance, government-debt, and monetary equilibrium structures.
- `PropertiesHousehold.lean`: Properties 1--5.
- `PropertiesStationary.lean`: Properties 6--10.
- `PropertiesEquilibrium.lean`: Properties 11--17.
- `PropertiesExtensions.lean`: Properties 18--20.
- `Verification.lean`: one `assert_no_sorry` check for each numbered property,
  plus checks for the supporting lemmas.
- `../i003_replicate_aiyagari.lean`: build entry point.

## What “proved” means here

Every numbered declaration is accepted by Lean and is checked not to depend on
`sorryAx`. The algebraic, order, counterexample, and intermediate-value
arguments are derived in Lean. In particular, the development proves:

- the policy-to-consumption comparative static;
- the one-for-one consumption response in the binding region;
- a concrete nonmonotone asset-supply counterexample with two equilibria;
- positive- and negative-return equilibrium existence from continuity and
  endpoint signs;
- the capital and saving-rate comparisons from the paper's order conditions;
- debt-budget and borrowing-floor invariance after netting out government
  debt; and
- slackness of the monetary constraint above the sharp return.

The supplied `.tex` explicitly omits the analytic proofs from Aiyagari (1993a).
Consequently, results that require dynamic programming, ergodic theory, or
distributional comparative statics expose the cited source theorem as a named
hypothesis. This applies to the analytic core of Properties 1--3, 5--7, 9--10,
and 18. No conclusion is introduced as a Lean axiom; callers must provide the
corresponding source hypothesis. This is the strongest faithful formalization
available from the summary alone without adding material not contained in it.

## Property map

| Source property | Lean theorem | Proof status |
|---|---|---|
| 1 | `property01_naturalDebt_iff_noPonzi` | Conditional on the two omitted source implications |
| 2 | `property02_value_and_policy_regularity` | Conditional on the omitted Bellman regularity results |
| 3 | `property03_binding_region_at_low_resources` | Source cutoff conditional; binding-region identities derived |
| 4 | `property04_monotonicity_and_one_for_one_response` | One-for-one response derived from the cutoff policy |
| 5 | `property05_mean_preserving_spread` | Policy shift conditional; consumption ordering derived; aggregate sign explicitly unsigned |
| 6 | `property06_bounded_resource_dynamics` | Conditional on Aiyagari (1993a), Proposition 4 |
| 7 | `property07_unique_stable_invariant_distribution` | Conditional on Aiyagari (1993a), Proposition 5 |
| 8 | `property08_continuity_and_possible_nonmonotonicity` | Continuous nonmonotone witness constructed in Lean |
| 9 | `property09_explosion_at_time_preference_rate` | Divergence conditional; equilibrium return bound derived |
| 10 | `property10_uncertainty_raises_assets_near_benchmark` | Conditional on the source dominance result |
| 11 | `property11_factor_price_and_capital_signs` | Capital ordering derived from return ordering and decreasing demand |
| 12 | `property12_saving_rate_sign` | Derived from capital ordering and increasing saving rate |
| 13 | `property13_equilibrium_need_not_be_unique` | Explicit two-equilibrium counterexample constructed in Lean |
| 14 | `property14_existence_under_alternative_debt_limits` | Intermediate Value Theorem proof from source endpoint signs |
| 15 | `property15_general_equilibrium_disciplines_saving` | Derived directly from market clearing |
| 16 | `property16_more_borrowing_reduces_capital` | Derived under the stated left shift and single-crossing condition |
| 17 | `property17_no_effect_when_fixed_limit_slack` | Derived by reducing both fixed limits to the natural limit |
| 18 | `property18_balanced_growth_extension` | Conditional on the source return and stationarity results |
| 19 | `property19_debt_neutrality_depends_on_constraint` | Budget/floor invariance and fixed-limit counterexample derived |
| 20 | `property20_monetary_return_upper_bound` | Constraint slackness and upper bound derived under the source asset-supply condition |

## Build

From the repository root:

```sh
lake build Lean4Tutorial.i003_replicate_aiyagari
lake build
```
