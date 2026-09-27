# M07A1 analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Is the stationary law constructed under strict impatience? | No. `pi` is an arbitrary probability law with the explicit invariant-kernel hypothesis. S05 is not imported or invoked, so the theorem applies at every primitive-admissible positive gross return. |
| Is the economic zero marginal represented correctly? | Yes. Every boundary statement uses `zeroRightMarginal m : ENNReal`. `rightMarginalValue m 0` never appears. Positive states use `extendedRightMarginalValue_of_pos`. |
| Are both zero-income cases proved? | Yes. If zero-income probability is zero, every zero-transition probability is zero. If it is positive and the boundary marginal is infinite, H09 conditional finiteness rules out zero saving from every positive state. |
| Why is zero-income probability below one? | NONDEGENERATE gives positive probability to every upper-endpoint neighborhood. A strictly positive wage and nonnegative effective income at the lower endpoint make a suitable upper neighborhood strictly positive-income, so it lies outside the zero-income event. |
| How does invariance imply zero stationary mass? | In the positive-atom branch, the kernel sends zero to zero with probability `p0` and positive states to zero with probability zero, giving `pi{0}=p0*pi{0}`. Since `p0<1`, cancellation forces `pi{0}=0`. The no-atom branch gives zero incoming mass directly. |
| Is marginal finiteness proved before conversion to reals? | Yes. The proof first establishes `extendedRightMarginalValue m z < top` for `pi`-almost every state. Only then is H09's real-valued conditional integral used. |
| Is positivity covered at the boundary? | Yes. `M07A1.extendedRightMarginalValue_pos` splits zero from positive resources and uses `zeroRightMarginal_pos` at zero and `rightMarginalValue_pos` elsewhere. |
| Is conditional integrability confused with a stationary moment? | No. The target proves integrability over next labor conditional on almost every current state and next-marginal finiteness under that conditional law. It never integrates the marginal against `pi` and asserts no finite stationary `E[q]`. |
| Does the proof use H10/H12 at critical or supercritical returns? | No. It uses H04/H08/H09/S01 only. No consumption-positivity, Euler-equality, borrowing-threshold, curvature, or strict-impatience theorem enters. |
| Is the general income scope preserved? | Yes. Labor retains its arbitrary compact probability law. Endpoint-neighborhood mass is used without assuming atoms, a density, or finite support. |
| Are stronger stationary claims introduced? | No. There is no invariant-law existence or uniqueness, convergence, moment convergence, stationary marginal integrability, asset-supply, divergence, or equilibrium conclusion. |
| Are prohibited assumptions or bypasses introduced? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, numerical model, or changed mathematical premise. |

## Assumptions and predecessor qualifications

BASIC is inherited through `HouseholdPrimitives`; SMOOTH is explicit in the contracted target;
NONDEGENERATE supplies distinct endpoints and upper-neighborhood mass. Smoothness is retained as
required by the contract even though the zero-state argument itself uses the already accepted H08
and H09 interfaces. The candidate invariant law is a hypothesis and is not supplied by S05.

All 585 entries in the supplied `predecessor_qualifications.json` remain operative and
unsuperseded. In particular, H09's unconditional extended inequality remains valid at arbitrary
returns, while its real form is invoked only after finite initial marginal is proved. H11 remains
local to positive consumption, and H10/H12 are not used at critical corners. All historical
source-inspection, documentation, and controller-evidence qualifications retain their original
gate attribution.

## Source and scope

The proof implements architecture section 9.1 and the two supplied authoritative extracts. A94
printed p. 669 / PDF p. 12, notes 20--21, distinguishes pathwise claims from the stationary
implication; CW00 supplies background. The atom/no-atom kernel calculation and conditional-
finiteness bridge are a new reconstruction, not a literal source theorem. No fresh source-PDF
inspection is claimed.

All four new public declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage in
both audit files. N01 is submitted as **REVIEW_READY** only; this audit certifies no other Stage 07a
contract and does not advance Stage 07b or Stage 08.
