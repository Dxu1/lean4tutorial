# M09C1 analytical audit

This audit covers A04 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Actual mean labor | `M09C1.meanLabor` is the integral under the full supplied risky labor law; positivity follows from the positive support floor. |
| Genuine degeneracy | `certaintyIncome` has equal endpoints and a Dirac law at that mean. No `IncomeNondegenerate` premise is present. |
| Correct debt shift | The certainty household uses its own `OriginalPrices`; normalization sets the intercept to `-netRate * debtLimit`, and the final net-asset identity subtracts exactly that debt limit. |
| Canonical deterministic kernel | Singleton elimination proves every labor draw equals mean labor, so `householdKernel m z = dirac (R*A(z)+ebar)`. |
| Fixed point and descent | S02 gives `h(ebar)=ebar` and strict descent at every state above `ebar`, using the accepted H04/H10/H12 household results. |
| Every finite state | S02 handles states weakly above `ebar`; the primitive lower-transition inequality sends any lower state weakly above `ebar` in one step. |
| Arbitrary initial laws | For every bounded continuous test, pointwise iterate convergence plus domination by the test norm yields convergence of integrals by dominated convergence. No support or moment premise is imposed on the initial law. |
| Unique invariant law | The point mass is fixed. An invariant law has a constant law orbit, while global weak convergence sends the same orbit to the point mass; uniqueness of limits gives equality. |
| Shifted and net assets | The fixed-point equation and positive gross return force `A(ebar)=0`; the net-asset map is explicitly integrable under the point mass, and its integral is `-phi`. |

The proof assumes only BASIC data inherited from `base`, utility SMOOTH, and strict impatience.
There is no curvature, mixing, risky S05 crossing, income nondegeneracy, or initial-law compact
support/moment assumption. Weak convergence is not promoted to unbounded-moment convergence. No
zero-state marginal, No-Ponzi statement, risky comparison, equilibrium construction, or later
contract is used. The deterministic household uses actual risky mean labor, not minimum labor.

A94 supplies the motivating certainty discussion at the approved pages. The full Lean convergence
argument is a project reconstruction. The wrapper and gate-owned public constructions have exact
signature, no-sorry, and transitive-axiom coverage in both audit locations.
