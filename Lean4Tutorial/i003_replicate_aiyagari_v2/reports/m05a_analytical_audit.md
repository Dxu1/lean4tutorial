# M05A analytical audit

Accepted baseline: `02e0c9f7f35c17c0ec34f81012a829cf611e3af0`. Assigned contract: S01 only.

| Required question | Answer and proof evidence |
|---|---|
| Is this the economic pushforward kernel? | Yes. `householdKernel m z` is proved equal to `m.income.law.map (fun l ↦ m.prices.nextResources (assetPolicy m z) l)`, whose real value is `R*A(z)+e(l)`. |
| Is it genuinely a probability Markov kernel? | Yes. The identity kernel and constant probability-law kernel are Markov; their product is Markov; mapping by the measurable joint transition preserves the Markov property. |
| Is the test-function formula exact? | Yes. `householdKernel_integral` proves the change-of-variables identity for every measurable real test. Thus it covers, and is slightly stronger than, the requested bounded-measurable class. |
| Is Feller continuity proved from primitives? | Yes. H04 makes `assetPolicy` continuous, so the transition is jointly continuous. Composition with a bounded continuous test is jointly continuous and uniformly dominated by the test's norm; dominated continuity makes its labor-law integral continuous in current resources. |
| Is stochastic monotonicity coupled with the same shock? | Yes. For `z₁≤z₂`, H07 gives `A(z₁)≤A(z₂)`. Since `R>0`, adding the same `e(l)` orders the two next states pointwise. Integral monotonicity then orders expectations of every bounded continuous increasing test. |
| Is H07 kept at accepted strength? | Yes. Only weak monotonicity of the asset policy is used. No strict policy order, derivative, or Lipschitz strengthening is inferred. |
| Is the general income law preserved? | Yes. The construction uses the `ProbabilityMeasure` stored in arbitrary `IncomeData`. It does not use the finite two-point consistency witness, density, atoms, nondegeneracy, or endpoint mass. |
| Are zero-boundary qualifications preserved? | Yes. The kernel is defined on all `NNReal`, including zero, using H04's continuous policy. No right-marginal or Euler object appears, so `rightMarginalValue m 0` is never used as the economic boundary marginal. |
| Does S01 claim later stability results? | No. There is no crossing, compact invariance, invariant-law existence or uniqueness, weak convergence, total-variation convergence, moment convergence, asset supply, or equilibrium conclusion. |
| Were predecessor qualifications preserved? | Yes. All 201 supplied entries remain mandatory and unsuperseded. No mathematical assumption or accepted declaration meaning changed. |

## Assumption and axiom conclusion

The target takes only `m : HouseholdPrimitives`, exactly the BASIC profile. Probability normalization, positive gross return, affine nonnegative income, and the canonical policy are inherited from the accepted primitive and H04 interfaces. H07 supplies the only order result.

All six new public declarations pass `#check`, `assert_no_sorry`, and `#print axioms`. Their transitive axioms are only `propext`, `Classical.choice`, and `Quot.sound`. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. S01 is REVIEW_READY, not GREEN.

## Source and design correspondence

The authorized locator is A93 Appendix Proposition 5 and proof, printed pp. 39–40 / PDF pp. 40–41, together with SLP89 §12.4. The implementation follows the supplied Architecture §7 construction: push forward the iid labor law, use joint continuity for Feller continuity, and couple ordered current states with the same shock. It formalizes only the S01 kernel layer; the explicit primitive-to-crossing reconstruction is deferred to S02–S03 and is not claimed here.
