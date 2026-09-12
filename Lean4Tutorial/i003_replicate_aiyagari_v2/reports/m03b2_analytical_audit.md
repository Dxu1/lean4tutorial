# M03B2 analytical audit

Baseline: `390e5e9a3491a705f5b8bc3aee42b02bf693c2d4`. Assigned contract: H10 only.

| Required question | Answer and proof evidence |
|---|---|
| Is consumption positive at every positive state? | Yes. `consumption_positive_subcritical` quantifies over all `z : Resources` and proves `0 < consumptionPolicy m z` from `0 < z`. |
| Is impatience explicit and local to H10? | Yes. The public premise is exactly `m.beta * m.prices.grossReturn < 1`; the primitive type remains valid for every positive return. |
| Is SMOOTH preserved? | Yes. The public theorem takes `UtilitySmooth m.utility`. The secant proof itself needs no derivative and therefore proves the conclusion from weaker analytic facts while retaining the contracted interface. No differentiability at zero is introduced. |
| Can the utility marginal at zero be infinite? | Yes. `utilityZeroRightMarginal : ENNReal` is defined by zero secants. The proof splits `utilityZeroRightMarginal < top` from equality to `top`; neither case is assumed away. |
| Is the accepted zero-value marginal qualification preserved? | Yes. `rightMarginalValue` appears only at the strictly positive state `z` in the infinite branch. `rightMarginalValue m 0` is never used. The distinct `zeroRightMarginal : ENNReal` remains unchanged. |
| Is the finite branch non-circular? | Yes. `valueFunction_increment_le_zeroMarginal` proves the value Lipschitz bound by induction on finite Bellman iterates from zero and passes it through H02's uniform convergence. It does not assume H10 or an envelope theorem. |
| Is Bellman propagation complete in both optimizer cases? | Yes. If the larger-state optimizer is feasible at the smaller state, the continuation cancels. Otherwise, the smaller comparison action saves all resources; the increment splits into current consumption and saving, with the continuation contribution bounded by `beta * R * L <= L`. |
| Does the finite corner contradiction use actual optimality? | Yes. From `c(z)=0`, H04's budget identity yields `A(z)=z`. The feasible action `z-h` consumes `h`; H04 maximization and the proved continuation bound imply the zero utility secant is at most `beta*R*L`. Its extended limit contradicts strict impatience and `L>0`. |
| Does the infinite branch avoid converting infinity to a real number? | Yes. It compares `ENNReal.ofReal` secants. Keeping saving `z` at `z+h` gives utility secant <= value secant. H08 makes the latter converge to the finite positive-state real marginal converted with `ofReal`, contradicting an infinite utility endpoint marginal. |
| Is a marginal expectation or real integral used? | No marginal expectation occurs in H10. The only integrals are the already-defined bounded continuation values, whose integrability was proved in H01. The finite continuation Lipschitz proof integrates a pointwise bounded difference using those explicit integrability facts. |
| Are the contracted dependencies preserved? | Yes. H04 supplies optimality and the policy budget identity; H08 supplies the positive-state finite right value marginal. H09 is accepted but not imported or invoked. |
| Is the labor law still general? | Yes. The proof uses the original arbitrary probability measure on the compact labor subtype. It assumes no density, atom, nondegeneracy, or positive effective-income minimum. |
| Is any later result claimed? | No. No envelope identity, Euler equation, borrowing threshold, stationary law, or diagnostic is implemented or inferred. |

## Source audit

The approved A93 hash is
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.
Rendered inspection covered A93 printed pp. 37-38 / PDF pp. 38-39. Proposition 2(a) states
positive consumption above the lower resource boundary, and its proof uses concavity and the
subcritical coefficient. The formal proof reconstructs the endpoint-marginal cases explicitly,
as required by architecture section 4.2.

The approved A94 hash is
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.
Rendered inspection covered A94 printed pp. 666-667 / PDF pp. 9-10. Equations (5)-(7) give the
Bellman equation, shifted asset policy, and total-resource transition used by the formal model.
The nearby prose is motivation; it is not treated as a Lean proof.

## Assumption and axiom conclusion

H10's exposed economic profiles are exactly BASIC, SMOOTH, and IMPATIENT. The proof introduces
no new primitive record or field. The full exported-declaration audit reports only `propext`,
`Classical.choice`, and `Quot.sound`. There is no project axiom, `sorryAx`, unsafe bypass, or
assumed closure result. H10 is REVIEW_READY, not GREEN.
