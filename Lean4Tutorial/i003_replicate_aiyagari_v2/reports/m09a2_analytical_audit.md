# M09A2 analytical audit

This audit covers G01 only and does not claim independent adequacy review.

| Required bridge | Derived evidence |
|---|---|
| Untruncated rates | `EquilibriumCore.rate : FirmRate p` means exactly `r>-delta`; there is no upper-rate or impatience field. |
| Ordinary admissibility | Compatible `OriginalPrices` proves `r>-1`, positive wage, nonnegative debt limit and nonnegative effective income; normalization is an equality to the household prices. |
| Firm side | `firm_optimization` has the complete accepted F01 certificate, including global unique profit maximization and positive wage. |
| Household side | `lifetime_optimality` is H05 for every initial resource and every measurable full-history feasible plan. |
| Actual transition | `household_kernel` is S01's policy-induced Markov kernel, not an abstract or strictly impatient stationary constructor. |
| Exact budgets | `budget_normalization` is P01's conjunction of original budget equality and borrowing feasibility iff shifted equality and nonnegative shifted saving. |
| IID and labor aggregation | The witness records the constructed finite-history IID property and `LaborMeanOne`; compact labor also has the accepted integrability theorem. |
| Supplied law and moments | The witness supplies a probability law, resource integrability, induced-net-asset integrability and capital clearing. |
| Resource formulation | `resourceLawForm e` is the fixed-point identity `householdLawStep m pi = pi`. |
| Asset/labor formulation | `assetLaborLawForm e` uses the induced net-asset marginal and its product with a fresh labor draw, then maps that product to resources. |
| Exact equivalence | `equilibrium_resource_asset_iff` is a direct two-way application of A01. |

The product law concerns predetermined net assets and the fresh draw. It does not state that the
canonical contemporaneous saving choice is independent of contemporaneous income. Resource law
and asset law remain distinct. No economic integral is interpreted without an explicit
integrability certificate.

The definition has no `r<lambda`, `beta*(1+r)<1`, positive-rate premise, B02/N07 premise,
asset-supply monotonicity, equilibrium existence or uniqueness, uncontracted debt specialization,
or reliance on S05/S06/M06C to manufacture its invariant law. All predecessor qualifications
remain mandatory and unsuperseded.

The contracted wrapper is in `Aiyagari1994/Equilibrium/Definition.lean`; every supporting helper
is in `Aiyagari1994/Analysis/M09A2/`. All new public declarations have `#check`,
`assert_no_sorry`, and `#print axioms` coverage in the gate probe and global audit. No `sorry`,
`admit`, project axiom, `native_decide`, unsafe bypass, numerical model, or later contract is used.
