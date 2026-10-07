# M09B2 analytical audit

This audit covers G03 only and does not claim independent adequacy review.

| Required bridge | Derived evidence |
|---|---|
| Positive natural domain | `NaturalRate m` is exactly `0<r<lambda`; `firmRateOf` embeds it into F01's unrestricted firm domain using positive depreciation. The natural debt limit is never evaluated at zero. |
| Strict impatience | `natural_betaR` derives `beta*(1+r)<1` from `0<beta` and `r<lambda` before any canonical stationary law is selected. |
| Natural prices | `naturalPrices` is P02's `naturalCapPrices` at F01's actual wage. `naturalPrices_normalized` proves its normalized prices equal `(1+r,w(r),-w(r)l_min)`. |
| Continuity | F01 wage continuity, P02 natural-limit continuity on positive rates, and A03 joint price/shift continuity yield continuous actual canonical net asset supply. Subtracting F01 capital demand gives continuous `X_N=S_N-K`. |
| Lower firm limits | An explicit positive sequence tends to zero. F01 continuity proves `w(r_n)->w(0)>0` and finite `K(r_n)->K(0)`. |
| Lower sign | B03 applies along that actual wage sequence and sends natural stationary net asset supply to negative infinity. Comparison with convergent capital demand selects finite `r_L>0` with `X_N(r_L)<0`. |
| Upper price and firm limits | An explicit sequence tends to `lambda` from below. F01 gives `w(r_n)->w(lambda)>0` and finite `K(r_n)->K(lambda)`. Normalized prices converge to the critical admissible triple, and `phi_n` converges to finite `w(lambda)l_min/lambda`. |
| Upper sign | B02 sends actual canonical stationary supply to positive infinity. Eventual comparison with capital demand and the rate limit selects `r_L<r_U<lambda` with `X_N(r_U)>0`. |
| IVT | The compact bracket is parameterized by the unit interval. Continuous excess supply and strict endpoint signs produce a root in the positive subcritical domain. |
| Full G01 witness | At the root the construction supplies P02 original/normalized prices, H05 lifetime optimality, the S01 kernel, invariant canonical resource law, resource and net-asset integrability, mean-one labor, finite-history IID, P01 normalization, F01 optimization, and capital clearing. |

The existential predicate explicitly retains the supplied beta, utility, complete income data, and
the exact natural debt limit at the endogenous firm wage and rate. The theorem proves existence of
one equilibrium only. It does not prove uniqueness, asset-supply monotonicity, comparisons,
every-equilibrium positivity or subcriticality, or G04. It does not use F02 or G02 as a dependency.

Every economic integral in the equilibrium witness has an explicit integrability proof. No moment
limit is inferred from weak convergence, and weak drift is not promoted to finite-time entry.
Predetermined net assets remain paired with fresh labor under G01's accepted timing. No marginal
object is used, so the distinction between `zeroRightMarginal` and `rightMarginalValue m 0` is
untouched.

A94 printed p. 673 / PDF p. 16, note 30, with adjacent PDF p. 15, motivates the natural-limit
endpoint and existence conclusion. A93 is used only through its approved structured priority
context and hash. The firm-path limit arguments, complete IVT construction, and Lean bridges are
project proofs. Both new public declarations have `#check`, `assert_no_sorry`, and `#print axioms`
coverage. No `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model is
used.
