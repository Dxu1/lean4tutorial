# M04B analytical audit

Accepted baseline: `101729ceb06b1df41800ed7e0b9382072f99ab8c`. Assigned contract: D02 only.

| Required question | Answer and proof evidence |
|---|---|
| Does the result match the ratio contract? | Yes. `marginalUtility_ratio_bound` produces a positive natural exponent `n` and positive threshold `C`, then proves `U'(c₁)/U'(c₂) ≤ (c₂/c₁)^n` for every `C ≤ c₁ ≤ c₂`. |
| How does eventual RRA imply the result? | Choose `n > max M 0`. Positivity of `U'` turns `-c U''/U' ≤ M < n` into `0 ≤ n U' + c U''`. The derivative of `c^n U'(c)` is therefore nonnegative on the open tail, so that function is nondecreasing on the closed tail. |
| Is the integer genuinely positive and sufficiently large? | Yes. `exists_nat_gt (max M 0)` supplies `n`; its strict domination of zero proves `0<n`, and its domination of `M` is used in the derivative-sign argument. |
| Is division legitimate? | Yes. The positive threshold gives `0<c₁≤c₂`; SMOOTH gives strictly positive marginal utilities at both points. All denominators in the final rearrangement are therefore nonzero and positive. |
| Is differentiability assumed only where authorized? | Yes. CURVATURE supplies `ContDiffOn ℝ 2` only on `Ioi 0`. Every derivative and monotonicity argument is restricted to a tail with positive threshold. No differentiability at zero is used or claimed. |
| What does BASIC contribute? | The contracted wrapper quantifies over `HouseholdPrimitives`, preserving BASIC exactly. The ratio proof itself is utility-analytic, so the reusable helper requires only SMOOTH and CURVATURE. No BASIC field is strengthened. |
| Are boundary marginal qualifications preserved? | Yes. Neither `rightMarginalValue` nor `zeroRightMarginal` occurs. D02 concerns ordinary utility derivatives at strictly positive consumption only. |
| Are integrability and income-law qualifications preserved? | Yes. No integral, expectation, labor realization, or transition law occurs. The general compact iid income law remains untouched, and the finite-support witness is not substituted for it. |
| Are later economic conclusions inferred? | No. D02 proves only the marginal-utility ratio. It proves no policy monotonicity, absorbing bound, finite-time entry, invariant law, tightness, asset-supply property, stationarity, or equilibrium claim. D03 and all later contracts remain unchanged. |
| Is the theorem nonvacuous? | Yes. Accepted primitive examples provide `HouseholdPrimitives` with `CoreRegularity`, whose fields include both `UtilitySmooth` and `UtilityCurvature`. D02 adds no impossible premise. |
| Were predecessor qualifications preserved? | Yes. All 138 supplied entries (119 qualifications and 19 nonblocking findings) remain mandatory and unsuperseded. D02 changes none of their accepted proofs, assumptions, source limitations, declaration meanings, or review boundaries. |

## Assumption and axiom conclusion

The contracted declaration has exactly BASIC, SMOOTH, and CURVATURE in its public interface. CURVATURE is used only for its positive-tail `C²` regularity and finite eventual RRA upper bound; SMOOTH supplies positivity of `U'`. No mathematical assumption was changed.

Both public declarations pass `#check`, `assert_no_sorry`, and `#print axioms`; the transitive axiom set is exactly `propext`, `Classical.choice`, and `Quot.sound`. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. D02 is REVIEW_READY, not GREEN.

## Source and design correspondence

The authorized locator is A93 Appendix Proposition 4, printed pp. 38–39 / PDF pp. 39–40, and SE77 Theorems 3.8–3.9, printed pp. 161–162 / PDF pp. 11–12. The supplied Architecture §6.2 extract explicitly authorizes choosing an integer above the eventual RRA bound and differentiating `c^n U'(c)`. This gate implements that analytic component only. The source pages were not re-inspected; no claim is made that the Lean organization is verbatim source text.
