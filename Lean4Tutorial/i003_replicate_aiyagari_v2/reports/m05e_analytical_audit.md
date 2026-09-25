# M05E analytical audit

| Question | Finding |
|---|---|
| Does S05 construct its upper interval from primitives? | Yes. `M05E.exists_invariant_upper` specializes D03 to the singleton actual price vector and constructs `B`, upper-shock drift, and forward invariance. No absorbing bound is assumed. |
| Is the compact kernel genuinely the economic kernel? | Yes. `exactRestrictedKernel` is the measurable-embedding restriction of `householdKernel`. On an invariant interval it is proved equal to the projected Markov kernel used for Feller and monotonicity. Kernel powers are intertwined explicitly. |
| Is S03's ENNReal probability converted safely? | Yes. The crossing mass is bounded by a probability-kernel value, hence finite; only then is `ENNReal.toReal` used. Positivity and the upper bound by one are separately proved. |
| Is S04's test crossing discharged? | Yes. Event probability bounds on `Ici d` and `Iic d` imply the two increasing-test integral inequalities. The S04 theorem is then applied with the restricted Feller and monotone kernel. |
| Is full-space convergence proved rather than assumed? | Yes. High initial states use invariant intervals `[e_min,max B z]`; low states enter `[e_min,B]` after one step. Pointwise weak convergence is extended to arbitrary initial laws by dominated convergence for bounded-continuous tests. |
| Is full-space invariant uniqueness unrestricted by moments or support? | Yes. Global convergence applies to every `ProbabilityMeasure Resources`. An invariant law has a constant orbit and therefore equals the constructed compactly supported law. |
| Are stronger conclusions excluded? | Yes. There is no total-variation convergence, moment convergence, finite-time absorption above `B`, stationary marginal integrability, asset supply, or equilibrium claim. |

## Assumption and predecessor audit

The public theorem lists exactly `HouseholdPrimitives`, `UtilitySmooth`, `UtilityCurvature`, `IncomeNondegenerate`, and `beta*R<1`. IID draws are implemented by the fixed labor probability law in `householdKernel`. The proof does not use `rightMarginalValue m 0`, `zeroRightMarginal`, or any unproved boundary finiteness. It preserves continuous resources and the general compact iid income law; no atom, density, finite support, or positive minimum effective income is introduced.

D03 is used only for the constructed upper bound, weak upper drift, and invariant intervals. S01 is used only for the full economic kernel's Feller and increasing-test monotonicity properties. S03 is used only for common-horizon event crossing. S04 supplies compact invariant existence, uniqueness, and weak convergence. The proof does not reinterpret weak drift as finite-time entry.

## Source and scope

The source correspondence remains A93 Appendix Proposition 5 and SLP89 Section 12.4. This gate uses the capsule's accepted source and predecessor qualifications; it does not claim a new inspection of source PDFs. The primitive-to-restricted-kernel bridge, ENNReal conversion, interval enlargement, and dominated-convergence implementation are formal reconstructions.

All new public declarations have `#check`, `assert_no_sorry`, and `#print axioms` commands in both audit files. S05 is submitted as **REVIEW_READY** only.
