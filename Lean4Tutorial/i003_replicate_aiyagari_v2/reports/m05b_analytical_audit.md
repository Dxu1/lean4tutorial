# M05B analytical audit

Accepted baseline: `e7114e926dea1d4717ad095e664c3c18d54630ca`. Assigned contract: S02 only.

| Required question | Answer and proof evidence |
|---|---|
| Is `e_min` primitive-derived? | Yes. `lowerEffectiveIncome` evaluates the affine effective-income formula at the lower endpoint of the maintained compact labor support. Wage positivity proves it is no larger than income at any labor realization. |
| Is the transition the intended lower-shock map? | Yes. `lowerTransition m z` is definitionally `R*A(z)+e_min`, using the canonical shifted-asset policy from H04. |
| Is strict drift proved from optimality? | Yes. Positive saving invokes H12's Euler equality. H10 and H11 identify positive-consumption marginal utility with H08's positive-state right value marginal. If `h_min(z)>=z`, all next states are at least `z`, so antitonicity bounds all next marginals by the current positive marginal. Probability normalization and `beta*R<1` contradict Euler equality. |
| Is the endpoint valid when `e_min=0`? | Yes. `assetPolicy_zero` gives zero saving directly. The proof never uses `rightMarginalValue m 0`; `zeroRightMarginal` remains the economic boundary object. |
| Is integrability justified? | Yes. It is taken exactly from the positive-saving branch of H12 before the real integral is ordered. No unconditional stationary marginal integrability is asserted. |
| Are iterates genuinely decreasing and convergent? | Yes. Endpoint fixation plus strict drift makes iterates antitone, while the primitive lower-income bound keeps them above `e_min`. Real monotone convergence supplies a finite limit; continuity makes it a fixed point; strict drift makes `e_min` the only possible fixed point in the reachable order interval. |
| Is the general income law preserved? | Yes. Only its probability normalization and compact lower endpoint are used. There is no finite-state, density, atom, or nondegeneracy premise. |
| Are later claims excluded? | Yes. S02 proves no common-horizon crossing probability, mixing, invariant-law existence or uniqueness, weak kernel convergence, moment convergence, asset supply, or equilibrium result. |
| Were predecessor qualifications preserved? | Yes. All supplied qualifications remain operative and unsuperseded; in particular the boundary-marginal, lifetime-plan, budget, general-income-law, and historical source/evidence qualifications are unchanged. |

## Assumption and axiom conclusion

The exported theorem has exactly BASIC through `HouseholdPrimitives`, SMOOTH through `UtilitySmooth`, and IMPATIENT through `beta*R<1`. No premise is vacuous and no mathematical assumption was added or changed. All six new public declarations are covered by `#check`, `assert_no_sorry`, and `#print axioms`; the permitted transitive axiom union is `propext`, `Classical.choice`, and `Quot.sound`. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. S02 is REVIEW_READY, not GREEN.

## Source and design correspondence

The proof implements Architecture §7.1's primitive-to-drift reconstruction associated with A93 Appendix Proposition 5, printed pp. 39-40 / PDF pp. 40-41. The deterministic iterate conclusion is the S02 layer only. Endpoint-neighborhood probability and common-horizon crossing arguments remain deferred to S03.
