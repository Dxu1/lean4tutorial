# M08B analytical audit

This audit covers B02 only and does not claim that independent adequacy review has occurred.

| Required bridge | Derived evidence |
|---|---|
| Failure of divergence gives a bounded-above subsequence | The sequential proof negates the `atTop` conclusion, obtains frequently `S n < b`, combines this with eventual finite bounds from price/shift convergence, and uses `extraction_of_frequently_atTop` to obtain a strict subsequence. |
| `E[A]=S+phi` with integrability | `stationary_budget_identity` (A02) supplies shifted-saving integrability and the stationary asset-supply identity for original prices reconstructed from each normalized price and shift. |
| Uniform resource first moment | A02 supplies `E[z]=R E[A]+E[e]`. Nonnegativity and subsequence bounds for `R`, `E[A]`, and maximum effective income produce one explicit finite upper bound. |
| Markov tightness | `M08B.tight_of_uniform_first_moment` proves the bound directly on `NNReal`, choosing a compact interval and applying Markov's inequality. Tightness is not assumed. |
| Weak subsequence | Prokhorov compactness of the tight family yields a convergent further subsequence of probability measures. |
| Compact-local kernel convergence | `M08B.householdKernel_tendstoLocallyUniformly` uses H06 through the accepted parameterized canonical test operator and its continuous restriction to compact resource intervals. It identifies that operator with the actual household-kernel integral. |
| Feller probability kernels | `householdKernel_feller_monotone` supplies the Markov and Feller interfaces for every approximating kernel and the critical limiting kernel. |
| Critical invariant contradiction | B01 passes invariance to the weak limit using bounded tests only. Exact criticality gives `1 <= beta*Rstar`, and N07 excludes the resulting invariant law. |
| One-sided/filter form | `M08B.UpperBoundaryPrices` contracts nonnegative shift, normalization, and strict subcriticality. `assetSupply_tendsto_at_impatience` follows from the sequential theorem using the countably generated filter sequence criterion. |

The proof never extends S06 to the critical boundary, assumes a common compact support, passes an
unbounded moment through weak convergence, or substitutes support explosion or pathwise
divergence. The raw shift remains finite in B02 and is used only through the exact normalization
identity. All supplied predecessor qualifications remain mandatory and unsuperseded.

All eight new public declarations are covered by `#check`, `assert_no_sorry`, and `#print axioms`
in the gate probe and global audit. The permitted transitive axioms are only `propext`,
`Classical.choice`, and `Quot.sound`. No `sorry`, `admit`, project axiom, `native_decide`, unsafe
bypass, or numerical model is used.
