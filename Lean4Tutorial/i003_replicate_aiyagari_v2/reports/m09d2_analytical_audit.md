# M09D2 analytical audit

This audit covers G07 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Universal equilibrium quantifier | The core theorem and public wrapper take arbitrary `e : StationaryEquilibrium p hp`; no G02/G03 construction or restricted equilibrium witness is used. |
| Gross share definition | `grossReplacementShare p K` is exactly `p.depreciation*K/p.output K`, the gross replacement-investment share rather than stationary net saving. |
| Positive capital and output | F01 gives positive capital demand. At any `K>0`, its surjectivity onto positive capital transports F01's positive firm wage to `f(K)-K*f'(K)>0`; positive marginal product then gives `f(K)>0`. |
| Exact derivative | `grossReplacementShare_hasDerivAt` applies the quotient rule and proves `g'(K)=delta*(f(K)-K*f'(K))/f(K)^2` for every `K>0`. |
| Derivative positivity | The numerator uses `delta>0` and the transported positive wage gap; the denominator square is positive because output is positive. |
| Rigorous strict monotonicity | `strictMonoOn_of_deriv_pos` is applied to the convex domain `Ioi 0`, after proving continuity there and positivity of the derivative throughout its interior. |
| Correct comparison direction | G06 provides `K_FI<K`; strict monotonicity yields `g(K_FI)<g(K)`. The actual `K` is the equilibrium net-asset integral and is positive after rewriting by `e.capital_clearing`. |
| Exact dependencies | The implementation imports the G06 public module and uses only the accepted F01 firm interface plus G06 for the contract proof. |
| Excluded conclusions | No interest-rate monotonicity, equilibrium uniqueness, positive stationary net saving, net asset accumulation, capital growth, or G08 goods-market clearing is proved. |

The maintained household scope and all predecessor qualifications remain unchanged. Shifted
assets and net assets remain distinct; the theorem's risky capital is explicitly the integral
of `M06B.netAsset`. There is no new marginal-at-zero, integrability, weak-convergence, or
numerical claim.

A94 printed pp. 670--671 / original PDF pp. 13--14 motivates the capital and gross investment
share comparison. The exact quotient-rule and strict-monotonicity implementation is a project
reconstruction.
