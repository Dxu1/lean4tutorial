# M09C4 analytical audit

This audit covers G05 only and does not claim independent adequacy review.

| Required clause | Derived evidence |
|---|---|
| Mean-income deterministic labor one | `M09C4.certaintyIncomeOne` is the Dirac law on the singleton interval `[1,1]`; the theorem also retains and records the supplied `LaborMeanOne` identity. |
| Impatience rate and firm domain | From `0<beta<1`, the proof derives `lambda=1/beta-1>0`, hence `lambda>-delta`, and constructs `rFI : FirmRate prod` with value `lambda`. |
| F01 firm construction | `capitalDemand_wage_constructed` supplies positive wage and the marginal-product equation at `K(lambda)`; the accepted positive-capital constructor supplies `K>0`. |
| Positive benchmark consumption | Expanding `firmWage` and the marginal equation proves `cFI=f(K)-delta*K=w+lambda*K>0`. |
| Correct certainty debt limit | The result quantifies over every `phi>=0` with `lambda*phi<=w`, exactly the labor-one effective-income condition. It therefore covers `min(b,w/lambda)` and `w/lambda`, without using risky minimum labor. |
| Borrowing feasibility and initial resources | Shifted saving is `K+phi`, original assets are exactly `K`, and `-phi<=K`. The constructed resources are `cFI+K+phi`; P01's trajectory bridge proves the date-zero original budget and borrowing inequality. |
| Critical Euler product | The construction proves `beta*(1+lambda)=1` algebraically. It invokes no strictly-impatient stationary-law theorem. |
| Finite present-value budget | For arbitrary admitted history-dependent feasible plans, singleton histories reduce the budget path and the proof telescopes it exactly to `beta^N(astar-a_N)`. Nonnegative shifted saving gives the vanishing upper bound. |
| Global supporting line | Concavity plus differentiability at positive `cFI` proves `u(c)-u(cFI)<=u'(cFI)(c-cFI)` for every nonnegative consumption, including zero. |
| Lifetime optimality | Finite-horizon utility differences are bounded by the marginal utility times the present-value bound. Accepted finite-history lifetime convergence and `beta^N->0` yield dominance against every `FeasiblePlan`. |
| H05 use | H05 compares the canonical plan to the constructed constant plan; combined with the direct reverse dominance, this identifies benchmark lifetime utility with the value function. H05 is not used as an Euler-sufficiency shortcut. |
| Excluded conclusions | No risky equilibrium, invariant critical law, G06 capital comparison, G07 saving comparison, G08 clearing claim, risky uniqueness, No-Ponzi theorem, or primitive transversality conclusion is proved. |

The implementation preserves bounded utility and the accepted finite-history expected-flow
lifetime semantics. It introduces no curvature, nondegeneracy, marginal-at-zero, ENNReal
conversion, moment-convergence, or infinite-product-path claim. All four new public declarations
are audited; their transitive axioms are only `propext`, `Classical.choice`, and `Quot.sound`.

A94 at the approved printed pp. 670--671 / PDF pp. 13--14 motivates the certainty benchmark and
competitive factor prices. The complete Lean finite-budget and supporting-line argument is a
project reconstruction, not attributed verbatim to the paper.
