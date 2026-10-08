# M09C3 analytical audit

This audit covers G04 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Universal quantifier | The theorem takes an arbitrary `e : StationaryEquilibrium p hp`; it does not select or construct an equilibrium. |
| Unrestricted G01 type | The complete accepted record was rechecked. `EquilibriumCore` has the full firm-rate domain and no impatience or rate-upper-bound field; `StationaryEquilibrium` adds only `resource_stationary`. |
| Actual invariant law | The proof applies `ProbabilityMeasure.toMeasure` to `e.resource_stationary`, yielding invariance of `e.resourceLaw` under the actual `householdKernel e.household`. |
| N07 contradiction | Under the negation of strict impatience, `1 <= beta*R`; N07 rules out the exhibited probability law `e.resourceLaw`. No moment premise is needed for this contradiction. |
| Correct price identity | `e.normalized_prices`, definitional normalization, and `e.original_rate` give `R=1+netRate=1+e.rate`. |
| Strict net-rate bound | `beta>0` permits division of `beta*(1+e.rate)<1`, proving `e.rate<1/beta-1`. |
| Exact dependencies | The gate imports only the accepted G01 equilibrium definition and N07. G02 and G03 are neither imported nor invoked. |
| Excluded conclusions | The theorem asserts no equilibrium positivity or existence, uniqueness, capital comparison, asset comparison, or saving comparison. |

The accepted G01 semantic fingerprint supplied by the controller is source SHA-256
`11fc757624ffbc386ac2f0d11d80f86af316e43e41a2c26a18744c8730238969`. Its exact elaborated
bridge signature is
`Aiyagari1994.equilibrium_resource_asset_iff {p} {hp} (e : EquilibriumCore p hp) :
resourceLawForm e ↔ assetLaborLawForm e`. The G01 dependency evidence explicitly states that the
definition allows all `r>-delta` and contains no `r<lambda` or `beta*(1+r)<1` premise.

The result preserves the bounded-utility, compact iid-income, positive-lower-support,
nondegeneracy, mean-one aggregation, normalization, and finite-history lifetime qualifications
carried by the accepted equilibrium. No boundary marginal, ENNReal conversion, moment-limit,
No-Ponzi, or infinite-product-path claim is introduced. A94 supplies motivation at the approved
pages; the Lean contradiction is a project reconstruction.
