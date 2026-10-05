# M09A3 analytical audit

This audit covers F02 only and does not claim independent adequacy review.

| Required bridge | Derived evidence |
|---|---|
| Average-product decay | `production_average_tendsto_zero` derives `f(K)/K -> 0` from PRODUCTION using a strict-concavity tangent bound and `f'(K)->0`; it assumes no average-product limit. |
| Large capital | The two at-infinity limits jointly select `K_L>0` with `f'(K_L)<delta` and `f(K_L)<delta*K_L`. |
| Firm rate and demand | `r_L=f'(K_L)-delta`; positive marginal product gives `r_L>-delta`, while the selected marginal inequality gives `r_L<0`. F01 uniqueness proves `K(r_L)=K_L`; F01 also proves positive wage. |
| Gross return and impatience | `delta<1` and `r_L>-delta` give `1+r_L>0`. Then `0<beta<1` and `r_L<0` give `beta*(1+r_L)<1`, before the stationary constructor is invoked. |
| Finite-cap prices | P02's `finiteCapPrices` supplies admissible original prices. Its negative-rate branch reduces exactly to `effectiveLimit=b`; the normalized prices retain positive gross return and nonnegative effective income. |
| Canonical stationary accounting | A02 supplies the canonical S05 stationary law only after strict impatience is derived, plus integrability of resources, saving, net assets, consumption and effective income. |
| Mean-one aggregation | `LaborMeanOne` changes A02's identity to `E[c]=w_L+r_L*S`. No economic integral is interpreted without A02's integrability result. |
| Weak supply bound | Pointwise nonnegative consumption gives `E[c]>=0`, hence `S<=w_L/(-r_L)` because `-r_L>0`. |
| Strict firm comparison | Substituting wage and rate definitions, `w_L/(-r_L)<K_L` is algebraically equivalent to the already-derived strict inequality `f(K_L)<delta*K_L`. |

The theorem is valid for every real finite cap `b>=0`; no positive-rate natural-limit branch is
used. It assumes neither an excess-supply sign nor asset-supply monotonicity, continuity, or
divergence. It proves a lower bracket only, not equilibrium existence, uniqueness, or a positive
equilibrium rate. B02, B03, G02, G03, and later contracts are absent.

The accepted limitations remain unchanged: weak drift is not treated as finite-time entry;
almost-everywhere facts are not promoted to pointwise claims; and every stationary economic
integral used here comes with A02 integrability. The construction is a project derivation motivated
by A94 printed pages 670--671 / PDF pages 13--14, not a literal source theorem.

The wrapper is in `Aiyagari1994/Equilibrium/LowerBracket.lean`; all helpers are in the assigned
`Aiyagari1994/Analysis/M09A3/` directory. Every new public declaration is covered by `#check`,
`assert_no_sorry`, and `#print axioms` in both the gate probe and global audit. No `sorry`, `admit`,
project axiom, `native_decide`, unsafe bypass, numerical model, or later-contract implementation is
used.
