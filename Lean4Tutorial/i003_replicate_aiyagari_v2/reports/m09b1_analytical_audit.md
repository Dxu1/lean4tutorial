# M09B1 analytical audit

This audit covers G02 only and does not claim independent adequacy review.

| Required bridge | Derived evidence |
|---|---|
| Firm path | `finitePrices` uses F01's constructed `capitalDemand` and `firmWage` and P02's actual finite-cap prices for every firm rate. Wage positivity and `r>-1` are derived from F01 and PRODUCTION. |
| Strict impatience | On `r<lambda=1/beta-1`, `subcritical_betaR` derives `beta*(1+r)<1` from `0<beta`; stationarity is invoked only afterward. |
| Finite-cap continuity | P02 proves continuity of `effectiveLimit b l_min w r` on positive wages and `r>-1`, including through zero. A03's repaired joint theorem is composed with both normalized prices and the independently varying debt shift. |
| Actual excess supply | `excessPath` is canonical stationary net asset supply minus F01 capital demand. Its continuity is derived by composition, not assumed as a field. |
| Lower sign | F02 supplies an actual negative `r_L`, identical finite-cap prices, and canonical supply below `K(r_L)`. Equality of the accepted M06A and M06C canonical selectors is justified through invariant-law uniqueness. |
| Critical price limit | An explicit sequence approaches `lambda` from below. F01 continuity gives `w(r_n)->w(lambda)>0` and finite `K(r_n)->K(lambda)`. P02 continuity gives a finite debt-shift limit, and the normalized gross return, wage, and intercept converge jointly. |
| Upper sign | B02 applies to those actual critical normalized prices and finite shifts, so supply tends to positive infinity. Eventual comparison with convergent capital demand selects `r_U<lambda` with `r_L<r_U` and positive excess supply. |
| IVT | The bracket is parameterized by the connected unit interval. Strict endpoint signs and continuous excess supply produce a root strictly inside `(-delta,lambda)`. |
| Supplied economy and cap | Since the witness household is `m.withPrices` at the endogenous finite-cap prices, its beta, utility, and complete `IncomeData` are definitionally those of `m`, while its prices are intentionally endogenous. Its original debt limit is definitionally `effectiveLimit b m.income.lower (firmWage p hp e.rate) e.rate`. Both exported existential signatures return these identities explicitly. |
| Full G01 witness | The root fills original and normalized prices, H05 lifetime optimality, the S01 actual kernel, invariant canonical resource law, resource and net-asset integrability, mean-one labor, finite-history IID, P01 normalization, F01 optimization, and exact capital clearing. G01 itself also supplies the original rate, firm wage, and normalization identities. |

The theorem establishes one equilibrium for every finite real `b>=0`, for the supplied beta,
utility, complete income law, and cap. It does not equate endogenous household prices with the
input `m.prices`. It does not impose or prove a
positive equilibrium rate, uniqueness, supply monotonicity, comparative statics, every-equilibrium
subcriticality, or any G03/G04 claim. The finite-cap branch is valid at negative, zero, and positive
rates; it never substitutes the positive-rate natural limit.

All economic integrals used in the constructed equilibrium carry explicit integrability proofs.
No moment convergence is inferred from weak convergence, and no weak-drift statement is promoted
to finite-time entry. Predetermined net assets remain paired with fresh labor exactly as in G01;
no contemporaneous saving/labor independence is asserted. The accepted distinction between
`zeroRightMarginal` and `rightMarginalValue m 0` is untouched and no marginal object is used.

A94 printed pages 670--671 / PDF pages 13--14 were checked against the manifest hash. They motivate
the capital-demand and asset-supply intersection and explicitly decline monotonicity and uniqueness
in notes 24--25. The continuity composition, endpoint construction, IVT, and complete Lean
equilibrium witness are project proofs. Both new public declarations are covered by `#check`,
`assert_no_sorry`, and `#print axioms`; no `sorry`, `admit`, project axiom, `native_decide`, unsafe
bypass, or numerical model is used.
