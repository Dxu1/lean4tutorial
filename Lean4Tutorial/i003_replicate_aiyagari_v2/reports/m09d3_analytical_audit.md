# M09D3 analytical audit

This audit covers G08 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Universal equilibrium quantifier | The core theorem and wrapper take arbitrary `e : StationaryEquilibrium p hp`; no G02/G03 construction or restricted witness is used. |
| Resource, asset, consumption moments | `e.resource_integrable` and `e.net_assets_integrable` are accepted G01 witness fields. Adding the constant debt shift proves shifted-saving integrability; `c=z-A` then proves consumption integrability. |
| Labor moment | `labor_integrable` follows from compact labor support; `e.labor_mean_one.mean_eq_one` supplies the mean used in aggregation. |
| Actual invariant law | The resource coordinate is integrated after mapping the product of `e.resourceLaw` and the fresh labor law through `householdTransition`; `e.resource_stationary` identifies the image law with the current law. |
| Canonical household budget | The resulting identity is `E z = R E A + E[wl-r phi]`. Combining it with `c=z-A`, `R=1+r`, and `S=E(A-phi)` gives `E c=r*S+w*E labor`. |
| Net versus shifted accounting | Net assets are explicitly `A-phi`; only their integral is identified with capital by `e.capital_clearing`. Shifted saving `A` and resources `z` are never called capital. |
| Firm factor payments | F01 supplies `f'(K)=r+delta`; `firmWage` is `f(K)-K*f'(K)`. Mean-one labor and net asset clearing therefore give `E c+delta*K=f(K)`. |
| Exact dependencies | The helper imports the G01 and F01 public modules. It does not import A02's stationary-budget module, G04, G06, or G07. |
| Excluded conclusions | No impatience restriction, equilibrium existence or uniqueness, asset-supply monotonicity, capital comparison, gross-share comparison, No-Ponzi result, or Stage-10 theorem is proved. |

All predecessor qualifications remain operative. In particular, the proof uses the accepted
finite-history iid timing and fresh labor product law, not contemporaneous saving/labor
independence or a continuum law of large numbers. It forms real economic integrals only after
establishing the required integrability. A94 printed pp. 670--671 / original PDF pp. 13--14
motivates the accounting identity; the complete Lean derivation is a project reconstruction.
