# M03C analytical audit

Baseline: `de0af9ba9adb00d736e466a031e9677807bfe9b9`. Assigned contract: H12 only.

| Required question | Answer and proof evidence |
|---|---|
| Is the theorem genuinely about positive current states? | Yes. `euler_subcritical` quantifies over `z : Resources` with `0 < z`. H10 proves `c(z)>0`; H11 then identifies the current finite value marginal with `deriv U (c(z))`. |
| Is impatience explicit and local to H12? | Yes. The signature takes exactly `m.beta * m.prices.grossReturn < 1`. It is not added to primitives or predecessor H09/H11. |
| Is the Euler inequality conditional expectation proved integrable? | Yes. H09 first proves an `ENNReal` inequality. The finite positive current marginal proves the conditional `lintegral < ⊤`, then H09 supplies a.e. finiteness and real `Integrable`; H12 returns both before its real inequality. |
| Is the zero-resource marginal preserved? | Yes. `eulerNextMarginal m 0 = zeroRightMarginal m : ENNReal`, which may be infinite. Neither `rightMarginalValue m 0` nor `deriv U 0` is used as the economic boundary marginal. |
| Does the inequality use marginal utility where justified? | Yes. At each positive next resource, H10 gives positive next consumption and H11 proves the envelope identity. At a zero next resource the extended boundary value marginal remains explicit. |
| Is equality restricted to interior shifted savings? | Yes. Equality requires `0 < assetPolicy m z`; this is shifted next assets, not net assets. No later threshold or never-binding theorem is assumed. |
| Are next states bounded away from zero in the equality proof? | Yes. For `A(z)>0`, `R*A(z)+e(l) >= R*A(z)>0` pointwise because `R>0` and effective income is nonnegative. The differentiability helper uses the uniform neighborhood `a>A(z)/2`. |
| Is differentiation under the integral justified? | Yes. H10/H11 give the pointwise derivative. Concavity and antitonicity bound it by the constant `R * q(R*A(z)/2)`. The labor law is a probability measure, so this constant is integrable. Mathlib's dominated parametric-integral theorem then returns both derivative-integrand integrability and the derivative formula. |
| Is the first-order condition applied to the actual optimizer? | Yes. Positive saving and positive consumption give the open feasible neighborhood `0<a<z`. H04 optimality proves the real Bellman objective has a local maximum at `A(z)`, and Fermat's theorem sets its proved derivative to zero. |
| Are assumptions stronger than BASIC, SMOOTH, IMPATIENT introduced? | No. There is no curvature, nondegeneracy, atom, density, positive minimum income, stationary distribution, absorbing bound, or consumption-positivity premise. Positivity is derived from H10. |
| Is the general continuous-state compact-law model preserved? | Yes. States and choices remain `NNReal`; the labor law remains an arbitrary probability measure on the compact labor interval. No finite-support replacement or numerical model occurs. |
| Are later claims inferred? | No. H13, H14, D01, H06, and all stationary/equilibrium contracts remain unformalized. |

## Source audit

The approved A93 file has SHA-256
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.
Rendered inspection covered printed pp. 37-38 / PDF pp. 38-39. Proposition 2(c) states
`V'(z_t)=U'(c_t) >= beta*(1+r)*E[V'(z_{t+1})]`, with equality for positive shifted next assets;
printed p. 38 identifies the inequality/equality as the first-order condition for the Bellman
maximization.

The approved A94 file has SHA-256
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.
Rendered inspection covered equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. These pages
define the normalized Bellman maximization, shifted policy `A`, and transition
`z' = effective income + R*A(z)` used by the formal theorem. The paper does not discharge the
formal conditional-integrability or zero-state issues; H09 and H12 do so explicitly.

The structured H12 `sources` array contains A93, while its approved `source_locator` also names
A94. Both approved files and both exact locator ranges were inspected; this pre-existing manifest
metadata shape was preserved rather than silently changing the assigned contract.

## Assumption and axiom conclusion

H12 exposes exactly BASIC through `HouseholdPrimitives`, SMOOTH through `UtilitySmooth`,
IMPATIENT through `beta*R<1`, and a positive current state. Its equality implication adds positive
shifted savings only. All six M03C exports report exactly `propext`, `Classical.choice`, and
`Quot.sound`; no project axiom, `sorryAx`, unsafe bypass, or assumed closure record occurs. H12 is
REVIEW_READY, not GREEN.
