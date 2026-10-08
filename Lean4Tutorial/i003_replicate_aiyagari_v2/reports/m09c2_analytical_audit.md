# M09C2 analytical audit

This audit covers A05 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Actual risky mean | `M09C1.meanLabor` integrates the full risky labor law; the proof derives `income.lower <= meanLabor` from compact-support integrability. |
| Finite-cap debt rules | Risk uses `effectiveLimit b lower w r`; certainty uses `effectiveLimit b meanLabor w r`. Unfolding retains `b` for `r<=0` and compares the two `min` formulas only for `r>0`. |
| Natural debt rules | Risk uses `w*lower/r`; certainty uses `w*meanLabor/r`, on the separate domain `r>0`. |
| Effective-limit order | `lower<=meanLabor`, `w>0`, and positive-rate division prove `phiRisk<=phiCertainty`; the finite nonpositive branch is equality. |
| Integrability and weak comparison | A02 proves shifted-asset and net-asset integrability and `S=E[A]-phiRisk`. NNReal saving has nonnegative mean, so `S>=-phiRisk>=-phiCertainty`. |
| Actual certainty benchmark | A04 is applied at each constructed certainty price and identifies the actual stationary integral of `A-phiCertainty` with `-phiCertainty`. |
| Every impatient rate | The weak finite clause quantifies over all `-1<r` with `beta*(1+r)<1`; the weak natural clause quantifies over all `0<r` with the same strict-impatience inequality. |
| Fixed wage near boundary | Both boundary filters hold `w` fixed and pull neighborhoods of `lambda=1/beta-1` back to the appropriate rate subtype. |
| Convergent finite shifts | P02 continuity gives finite-cap shift convergence; the natural quotient converges because `lambda>0`. |
| Qualified strictness | B02 yields risky supply tending to `+infinity`; hence it is positive throughout a boundary neighborhood, while A04 gives certainty supply `-phiCertainty<=0`. |

The result is partial equilibrium only. It adds no convex marginal utility, Jensen argument,
global strict comparison, risky-versus-risky distribution order, equilibrium existence, capital
comparison, or saving comparison. Boundary marginal and finite-history lifetime qualifications are
unchanged. A94 supplies motivation at the approved pages; the complete formal comparison is a
project reconstruction.
