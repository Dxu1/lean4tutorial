# M09D1 analytical audit

This audit covers G06 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Universal equilibrium quantifier | Both helper and wrapper take an arbitrary `e : StationaryEquilibrium p hp`; no G02/G03 construction or witness restriction appears. |
| G04 subcriticality | `M09C3.every_equilibrium_rate_below_impatience_core p hp e` gives `e.rate < 1/e.household.beta-1` for that arbitrary witness. |
| G05 benchmark identity | `certainty_benchmark_verified` is unpacked to obtain `rFI : FirmRate p` and `(rFI : ℝ)=1/e.household.beta-1`; its capital demand is therefore the certified `K_FI=K(lambda)`. |
| Correct F01 orientation | Since `e.rate<rFI`, F01's `StrictAnti (capitalDemand p hp)` yields `capitalDemand p hp rFI < capitalDemand p hp e.rate`. |
| Actual equilibrium capital | G01's `e.capital_clearing` rewrites `capitalDemand p hp e.rate` to the integral of actual equilibrium net assets. |
| Exact dependencies | The proof uses F01, the accepted G04 gate-local interface needed to avoid a shared-wrapper import cycle, and the public G05 certificate. |
| Excluded routes | It uses no A05 comparison, N07 reproof, rate positivity, equilibrium uniqueness, asset-supply monotonicity, G07 derivative argument, or G08 accounting argument. |

The maintained household scope remains bounded utility, continuous nonnegative resources, a
general compactly supported iid labor law with essential distinct endpoints, and the accepted
finite-history lifetime semantics. Shifted assets and net assets remain distinct; the clearing
integral is explicitly the net-asset object. No marginal-at-zero, new integrability, weak-moment,
or numerical claim is introduced.

A94 printed pp. 670--671 / original PDF pp. 13--14 motivates the comparison. The exact
composition of the accepted G04, G05, F01, and G01 interfaces is a project reconstruction.
