# Theorem index

Navigation for all 57 GREEN contracts at the mathematical release `fa1c6188837f9f460481868679d3847a12dbb7e9`. Short descriptions are navigation labels; exact assumptions, conclusions and dependencies remain in the [manifest](../contracts/theorems.json) and [proof ledger](proof_ledger.md). Declaration names below omit the common `Aiyagari1994.` namespace.

| ID | Declaration | Economic or mathematical content | Module | Status |
| --- | --- | --- | --- | --- |
| P01 | `shifted_budget_iff` | Shifted and original budget equivalence | [Budget/Normalization.lean](../Aiyagari1994/Budget/Normalization.lean) | GREEN |
| P02 | `effectiveLimit_admissible_continuous` | Effective borrowing-limit admissibility and continuity | [Budget/EffectiveLimit.lean](../Aiyagari1994/Budget/EffectiveLimit.lean) | GREEN |
| P03 | `corePrimitives_nonempty` | Nonempty core primitive model | [Primitives/Examples.lean](../Aiyagari1994/Primitives/Examples.lean) | GREEN |
| H01 | `bellman_selfmap_contracting` | Bellman self-map and contraction | [Household/Bellman.lean](../Aiyagari1994/Household/Bellman.lean) | GREEN |
| H02 | `valueFunction_unique_fixedPoint` | Unique canonical Bellman fixed point | [Household/Value.lean](../Aiyagari1994/Household/Value.lean) | GREEN |
| H03 | `valueFunction_concave_strictMono` | Value concavity and strict increase | [Household/Value.lean](../Aiyagari1994/Household/Value.lean) | GREEN |
| H04 | `assetPolicy_unique_continuous` | Unique continuous asset policy | [Household/Policy.lean](../Aiyagari1994/Household/Policy.lean) | GREEN |
| H05 | `canonicalPolicy_lifetime_optimal` | Canonical policy lifetime optimality | [Household/Verification.lean](../Aiyagari1994/Household/Verification.lean) | GREEN |
| H06 | `policy_jointly_continuous` | Joint state and price continuity | [Household/ParameterContinuity.lean](../Aiyagari1994/Household/ParameterContinuity.lean) | GREEN |
| H07 | `policies_order_lipschitz` | Weak policy order and Lipschitz bounds | [Household/PolicyOrder.lean](../Aiyagari1994/Household/PolicyOrder.lean) | GREEN |
| H08 | `rightMarginalValue_properties` | Right value marginals and zero-state limit | [Household/RightMarginal.lean](../Aiyagari1994/Household/RightMarginal.lean) | GREEN |
| H09 | `rightMarginalValue_superharmonic` | Conditional marginal superharmonic inequality | [Household/MarginalInequality.lean](../Aiyagari1994/Household/MarginalInequality.lean) | GREEN |
| H10 | `consumption_positive_subcritical` | Positive consumption under strict impatience | [Household/ConsumptionPositive.lean](../Aiyagari1994/Household/ConsumptionPositive.lean) | GREEN |
| H11 | `value_envelope_at_positive_consumption` | Envelope identity at positive consumption | [Household/Envelope.lean](../Aiyagari1994/Household/Envelope.lean) | GREEN |
| H12 | `euler_subcritical` | Subcritical Euler inequality and interior equality | [Household/Euler.lean](../Aiyagari1994/Household/Euler.lean) | GREEN |
| H13 | `binding_interval_exists` | Binding interval under the stated alternatives | [Household/BorrowingThreshold.lean](../Aiyagari1994/Household/BorrowingThreshold.lean) | GREEN |
| H14 | `zero_income_atom_implies_nonbinding` | Zero-income atom and Inada imply nonbinding | [Household/BorrowingThreshold.lean](../Aiyagari1994/Household/BorrowingThreshold.lean) | GREEN |
| D01 | `inada_without_atom_binding_example` | Continuous-income Inada binding diagnostic | [Diagnostics/InadaCounterexample.lean](../Aiyagari1994/Diagnostics/InadaCounterexample.lean) | GREEN |
| D02 | `marginalUtility_ratio_bound` | Marginal-utility ratio bound | [Analysis/Curvature.lean](../Aiyagari1994/Analysis/Curvature.lean) | GREEN |
| D03 | `uniform_upper_drift` | Common upper drift and invariant interval | [Household/UpperDrift.lean](../Aiyagari1994/Household/UpperDrift.lean) | GREEN |
| S01 | `householdKernel_feller_monotone` | Feller and monotone household kernel | [Stationary/Kernel.lean](../Aiyagari1994/Stationary/Kernel.lean) | GREEN |
| S02 | `lower_transition_iterates_tendsto` | Convergence of the lowest-income transition | [Stationary/LowerTransition.lean](../Aiyagari1994/Stationary/LowerTransition.lean) | GREEN |
| S03 | `economic_crossing_condition` | Derived economic endpoint crossing | [Stationary/Crossing.lean](../Aiyagari1994/Stationary/Crossing.lean) | GREEN |
| S04 | `compact_monotone_feller_stability` | Generic compact monotone-Feller stability | [Analysis/MonotoneFeller.lean](../Aiyagari1994/Analysis/MonotoneFeller.lean) | GREEN |
| S05 | `stationaryLaw_exists_unique_global` | Full-state unique invariant law and global stability | [Stationary/GlobalStability.lean](../Aiyagari1994/Stationary/GlobalStability.lean) | GREEN |
| S06 | `stationaryLaw_weakly_continuous` | Weak continuity of the stationary law | [Stationary/ParameterContinuity.lean](../Aiyagari1994/Stationary/ParameterContinuity.lean) | GREEN |
| A01 | `resource_asset_labor_law_bridge` | Resource and asset/labor law correspondence | [Aggregate/CrossSection.lean](../Aiyagari1994/Aggregate/CrossSection.lean) | GREEN |
| A02 | `stationary_budget_identity` | Stationary household budget identity | [Aggregate/AssetSupply.lean](../Aiyagari1994/Aggregate/AssetSupply.lean) | GREEN |
| A03 | `stationaryAssetSupply_continuous` | Continuity of stationary asset supply | [Aggregate/ParameterContinuity.lean](../Aiyagari1994/Aggregate/ParameterContinuity.lean) | GREEN |
| A04 | `certainty_stationary_assets_at_limit` | Certainty assets at the effective borrowing limit | [Equilibrium/CertaintyBenchmark.lean](../Aiyagari1994/Equilibrium/CertaintyBenchmark.lean) | GREEN |
| A05 | `risky_assets_above_certainty_near_impatience` | Weak certainty comparison and near-boundary strictness | [Aggregate/CertaintyComparison.lean](../Aiyagari1994/Aggregate/CertaintyComparison.lean) | GREEN |
| N01 | `stationary_zero_state_marginal_resolved` | Resolution of the stationary zero-state marginal | [Stationary/ZeroState.lean](../Aiyagari1994/Stationary/ZeroState.lean) | GREEN |
| N02 | `stationary_bounded_jensen_equality` | Bounded Jensen equality under stationarity | [Analysis/BoundedJensen.lean](../Aiyagari1994/Analysis/BoundedJensen.lean) | GREEN |
| N03 | `no_invariant_supercritical` | No supercritical invariant law | [Stationary/Supercritical.lean](../Aiyagari1994/Stationary/Supercritical.lean) | GREEN |
| N04 | `critical_stationary_consumption_constant` | Critical stationary consumption would be constant | [Stationary/CriticalConsumption.lean](../Aiyagari1994/Stationary/CriticalConsumption.lean) | GREEN |
| N05 | `two_independent_histories_contradiction` | Two independent histories contradict constant consumption | [Analysis/TwoShockStrings.lean](../Aiyagari1994/Analysis/TwoShockStrings.lean) | GREEN |
| N06 | `no_invariant_critical` | No critical invariant law | [Stationary/Critical.lean](../Aiyagari1994/Stationary/Critical.lean) | GREEN |
| N07 | `no_invariant_at_or_above_impatience` | No invariant law at or above impatience | [Stationary/NoInvariant.lean](../Aiyagari1994/Stationary/NoInvariant.lean) | GREEN |
| B01 | `tight_kernel_invariant_limit` | Invariant limit under tightness and kernel convergence | [Analysis/TightKernelLimit.lean](../Aiyagari1994/Analysis/TightKernelLimit.lean) | GREEN |
| B02 | `assetSupply_tendsTo_infinity_at_impatience` | Upper asset-supply divergence at impatience | [Aggregate/UpperBoundary.lean](../Aiyagari1994/Aggregate/UpperBoundary.lean) | GREEN |
| B03 | `naturalAssetSupply_tendsTo_neg_infinity` | Natural-limit lower asset-supply divergence | [Aggregate/LowerBoundary.lean](../Aiyagari1994/Aggregate/LowerBoundary.lean) | GREEN |
| F01 | `capitalDemand_wage_constructed` | Competitive capital demand and wage construction | [Firms/Neoclassical.lean](../Aiyagari1994/Firms/Neoclassical.lean) | GREEN |
| F02 | `finiteCap_lower_bracket` | Finite-cap lower excess-demand bracket | [Equilibrium/LowerBracket.lean](../Aiyagari1994/Equilibrium/LowerBracket.lean) | GREEN |
| G01 | `equilibrium_resource_asset_iff` | Equivalent stationary-equilibrium formulations | [Equilibrium/Definition.lean](../Aiyagari1994/Equilibrium/Definition.lean) | GREEN |
| G02 | `finiteCap_equilibrium_exists` | Finite-cap stationary equilibrium existence | [Equilibrium/Existence.lean](../Aiyagari1994/Equilibrium/Existence.lean) | GREEN |
| G03 | `naturalCap_equilibrium_exists` | Natural-limit stationary equilibrium existence | [Equilibrium/Existence.lean](../Aiyagari1994/Equilibrium/Existence.lean) | GREEN |
| G04 | `every_equilibrium_rate_below_impatience` | Every equilibrium is subcritical | [Equilibrium/MainTheorem.lean](../Aiyagari1994/Equilibrium/MainTheorem.lean) | GREEN |
| G05 | `certainty_benchmark_verified` | Verified mean-income certainty benchmark | [Equilibrium/CertaintyBenchmark.lean](../Aiyagari1994/Equilibrium/CertaintyBenchmark.lean) | GREEN |
| G06 | `equilibrium_capital_above_certainty` | Risky equilibrium capital exceeds the benchmark | [Equilibrium/MainTheorem.lean](../Aiyagari1994/Equilibrium/MainTheorem.lean) | GREEN |
| G07 | `equilibrium_gross_saving_share_above_certainty` | Higher gross replacement-investment/output share | [Equilibrium/Saving.lean](../Aiyagari1994/Equilibrium/Saving.lean) | GREEN |
| G08 | `equilibrium_goods_market_clears` | Aggregate goods-market clearing | [Equilibrium/Saving.lean](../Aiyagari1994/Equilibrium/Saving.lean) | GREEN |
| NP01 | `discounted_budget_telescope` | Finite-horizon discounted budget identity | [Budget/NoPonzi.lean](../Aiyagari1994/Budget/NoPonzi.lean) | GREEN |
| NP02 | `naturalBound_implies_noPonzi` | Natural bound implies nonnegative terminal wealth limit | [Budget/NoPonzi.lean](../Aiyagari1994/Budget/NoPonzi.lean) | GREEN |
| NP03 | `noPonzi_implies_naturalBound` | Qualified No-Ponzi converse to the natural bound | [Budget/NoPonzi.lean](../Aiyagari1994/Budget/NoPonzi.lean) | GREEN |
| E01 | `zeroRate_cap_change_exact` | Zero-rate borrowing-cap translation | [Extensions/BorrowingCap.lean](../Aiyagari1994/Extensions/BorrowingCap.lean) | GREEN |
| E02 | `caps_above_naturalLimit_equivalent` | Identical household problems beyond the natural cap | [Extensions/BorrowingCap.lean](../Aiyagari1994/Extensions/BorrowingCap.lean) | GREEN |
| E03 | `naturalBound_governmentDebt_correspondence` | Pure-exchange government-debt correspondence | [Extensions/GovernmentDebt.lean](../Aiyagari1994/Extensions/GovernmentDebt.lean) | GREEN |
