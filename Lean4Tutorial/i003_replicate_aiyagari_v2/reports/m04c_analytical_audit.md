# M04C analytical audit

Accepted baseline: `e996bd1a2e732d834f9eea0cd94ca040d35b5f61`. Assigned contract: D03 only.

| Required question | Answer and proof evidence |
|---|---|
| Does the declaration match D03? | Yes. `uniform_upper_drift` constructs one real `B>0` for every specified price set satisfying the LOCAL_IMPATIENT bounds. It proves `e_max<=B`, maximal-next-resource drift for every `z>=B`, and forward invariance of each `[e_min,B]`. |
| Is the bound genuinely uniform? | Yes. `C`, `L`, `K`, and `B` depend only on the fixed household utility/beta and the supplied common constants `Rmin`, `Rmax`, `gammaStar`, `EStar`, and `DeltaStar`, never on an individual price `q`. No continuity of pointwise caps is assumed. |
| Is the curvature step valid? | Yes. D02 supplies `n>0`, `C0>0`, and the marginal ratio. A filter limit proves existence of `C>=C0` with `gammaStar*(1+DeltaStar/C)^n<1`; this inequality is derived, not added as a neighborhood premise. |
| How is uniform large-state consumption proved? | H08 bounds the positive-state value marginal by `osc(U)/((1-beta)z)`. H10 proves positive consumption under the locally uniform subcritical bound, and H11 identifies the positive-state value marginal with ordinary marginal utility. Concavity makes `U'` antitone, so resources above the common `L` imply consumption above `C`. |
| Is Euler equality used only when authorized? | Yes. The nontrivial branch has `A_q(z)>K>0`, so H12's interior equality applies. Every next resource is positive, and H12 supplies integrability of the ordinary marginal-utility integrand before integral monotonicity is used. |
| Are H07 and H08 kept at their accepted strength? | Yes. H07 supplies only weak policy monotonicity and the one-Lipschitz consumption difference bound. H08 supplies positive-state marginal bounds and antitonicity. No policy derivative, strict policy order, or zero-state real marginal is introduced. |
| Is the zero boundary handled correctly? | Yes. `rightMarginalValue` occurs only at states proved positive. `rightMarginalValue m 0` is never interpreted economically; `zeroRightMarginal : ENNReal` remains the boundary object and may be infinite. |
| Does forward invariance follow from the proved drift? | Yes. At the common state `B`, drift bounds the maximal next resource. Asset-policy monotonicity bounds transitions from every `z<=B` by that transition, while the lower endpoint follows from nonnegative saving and affine-income endpoint order. |
| Is finite-time entry claimed? | No. The public conclusion contains only weak upper drift and forward invariance. No iteration or hitting-time conclusion appears in the implementation, ledger, or report. |
| Were predecessor qualifications preserved? | Yes. All 168 supplied entries remain mandatory and unsuperseded. The bounded-utility, continuous-resource, general compact iid-income scope is unchanged; no finite-state model, stationary integrability, tightness, convergence, asset supply, or equilibrium result is inferred. |

## Assumption and axiom conclusion

The contracted declaration has BASIC, SMOOTH, CURVATURE, and LOCAL_IMPATIENT exactly. The latter is expressed through explicit bounds on the specified set `Q`; no extra economic premise is hidden in a structure or helper. The helper assumptions used by `M04C_upper_drift_at_price` are derived in the public wrapper.

All nine new public declarations pass `#check`, `assert_no_sorry`, and `#print axioms`. Their transitive axiom output contains only `propext`, `Classical.choice`, and `Quot.sound`. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. D03 is REVIEW_READY, not GREEN.

## Source and design correspondence

The authorized locator is A93 Appendix Proposition 4, printed pp. 38–39 / PDF pp. 39–40, and SE77 Theorems 3.8–3.9, printed pp. 161–162 / PDF pp. 11–12. The proof follows the supplied Architecture §6.2 reconstruction: a direct uniform construction replaces any unsupported continuously varying selection of pointwise absorbing caps. Source correspondence relies on the supplied capsule and accepted D02 source qualification; no broader source theorem is certified here.
