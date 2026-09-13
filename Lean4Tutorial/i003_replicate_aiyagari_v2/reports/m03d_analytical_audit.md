# M03D analytical audit

Baseline: `49f74f9cf3bd62d5b85331eebd88f152d8901cba`. Assigned contract: H13 only.

| Required question | Answer and proof evidence |
|---|---|
| Is the lower endpoint derived from primitives? | Yes. `minimumEffectiveIncome m` is the affine effective income at the lower labor endpoint, packaged as `Resources` using BASIC's proved nonnegativity. Positive wage and the labor subtype lower bound prove it is no larger than every realized effective income and hence every next resource. |
| Is THRESHOLD represented exactly? | Yes. The public disjunction is `0 < minimumEffectiveIncome m ∨ utilityZeroRightMarginal m < ⊤`: either positive minimum effective income or finite utility right marginal at zero. No alternative threshold, density, or atom premise is introduced. |
| Is the economic zero-state marginal preserved? | Yes. The value endpoint is always `zeroRightMarginal m : ENNReal`. The proof never evaluates `rightMarginalValue m 0`. `utilityZeroRightMarginal` is used only for THRESHOLD's finite-utility branch and is not identified with the value marginal. |
| Why is the endpoint value marginal finite? | If `e_min>0`, H08 gives a finite positive-state marginal. If `e_min=0` and the utility endpoint marginal is finite, H10's global value Lipschitz bound bounds every value secant from zero by that finite utility marginal; taking the supremum proves `zeroRightMarginal<⊤`. |
| Is its positivity proved? | Yes. H08 proves `zeroRightMarginal>0` and every positive-state right marginal is strictly positive. Thus the finite endpoint value marginal has positive `.toReal`. |
| Does the interior upper bound use the actual Euler theorem? | Yes. For `A(z)>0`, H12 returns the ordinary marginal-utility integrability certificate and interior Euler equality. H10 gives positive current and next consumption; H11 identifies marginal utility with the positive-state value marginal. |
| Is the conditional expectation bounded legitimately? | Yes. Every next resource is at least `e_min`. H08's marginal antitonicity bounds each next marginal by the finite endpoint marginal. `integral_mono` uses H12's integrability proof and the integrable constant under the probability law before the real expectation is bounded. |
| How is the neighborhood obtained? | Since `0<beta*R<1`, `beta*R*Q<Q`. At positive `e_min`, H08's right continuity keeps `q(z)>beta*R*Q` on a right neighborhood. At zero, H08's `ENNReal` convergence of positive-state marginals to `zeroRightMarginal` gives the punctured neighborhood without inventing a real derivative at zero. |
| Does the closed interval include the endpoint? | Yes. At zero, H04's `assetPolicy_zero` applies. At positive `e_min`, an interior endpoint choice would imply `Q≤beta*R*Q`, contradicting positivity and impatience. |
| Are theorem quantifiers and strength preserved? | Yes. The result constructs `zHat : Resources` with `e_min<zHat` and proves `A(z)=0` for every `z` satisfying `e_min≤z≤zHat`. `A` remains shifted next assets. |
| Are assumptions stronger than BASIC, SMOOTH, IMPATIENT, THRESHOLD introduced? | No. There is no curvature, nondegeneracy, atom, density, stationarity, invariant law, asset bound, or assumed policy monotonicity beyond accepted dependencies. SMOOTH remains explicit because H12/H11 use it. |
| Is the general continuous-state model preserved? | Yes. Resources and actions remain `NNReal`; labor remains a general compactly supported probability law. No finite-support restriction or numerical model is used. |
| Are later claims inferred? | No. H14, D01, H06, and all stationary/equilibrium contracts remain unformalized. In particular this theorem does not validate the unqualified Inada/nonbinding note. |

## Source audit

The approved A93 file has SHA-256
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.
Rendered inspection covered PDF p. 39, whose printed page is 38. Proposition 3 states the
disjunction `U'(0)<infinity` or positive minimum effective income, concludes a threshold strictly
above minimum resources with consumption equal to resources and shifted next assets zero, and
uses the inequality `beta*(1+r)*V'(z_min)<V'(z_min)` in its contradiction. The following note is
the separately qualified, not-yet-certified Inada claim.

The approved A94 file has SHA-256
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.
Rendered inspection covered PDF p. 10, whose printed page is 667. It displays the shifted policy
and resource transition and describes a positive threshold above `z_min` below which all total
resources are consumed and shifted assets are zero. The formal result implements the qualified
A93 proposition, not the figure's later strict-policy description.

## Assumption and axiom conclusion

H13 exposes BASIC through `HouseholdPrimitives`, SMOOTH through `UtilitySmooth`, IMPATIENT through
`beta*R<1`, and THRESHOLD through the exact endpoint disjunction. Both M03D exports report exactly
`propext`, `Classical.choice`, and `Quot.sound`. No project axiom, `sorryAx`, unsafe bypass,
closure record, or assumed threshold occurs. H13 is REVIEW_READY, not GREEN.

All mandatory predecessor qualifications remain in force: positive-state
`rightMarginalValue` is never repurposed at zero; H09's real inequality remains conditional on a
finite initial extended marginal; H10's endpoint split and H11's local scope are unchanged; H12's
boundary-safe conditional marginal and integrability ordering are preserved; the state remains
continuous with a general compact iid-income law; and no predecessor budget, lifetime,
stationarity, or API-probe conclusion is strengthened.
