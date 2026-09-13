# M03E analytical audit

Baseline: `066c27b9b5f3ce01cd6114c1957c83719914b110`. Assigned contract: H14 only.

| Required question | Answer and proof evidence |
|---|---|
| Is ATOM_INADA represented exactly? | Yes. The signature exposes `minimumEffectiveIncome m = 0`, `utilityZeroRightMarginal m = ⊤`, and positive probability of `{l | effectiveIncome l = 0}`. BASIC is in `HouseholdPrimitives`; SMOOTH remains an explicit contract argument. |
| Is impatience absent? | Yes. No hypothesis or proof step uses `beta*R<1`, `beta*R≤1`, or consumption positivity. Only the primitive facts `beta>0` and `R>0` are used. |
| Is the zero-state value marginal preserved? | Yes. Inada is lifted to `zeroRightMarginal m = ⊤`. The proof never evaluates `rightMarginalValue m 0`; positive-state `rightMarginalValue` is not used at all. |
| Why does Inada imply an infinite value slope? | At state `h>0`, the feasible zero-saving action consumes `h` and has the same continuation as the forced zero action at state zero. Thus every utility secant is bounded by the corresponding value secant. Passing through the two proved ENNReal secant limits sends utility infinity to value infinity. |
| How does the atom enter? | The event `E={e=0}` is measurable by continuity of affine effective income. For saving `a=x/R`, the continuation-value difference is nonnegative everywhere and exactly `V(x)-V(0)` on `E`, so its integral is at least `Pr(E)[V(x)-V(0)]`. |
| Are real integrals interpreted only after integrability? | Yes. Both value integrands are bounded continuous functions under a probability law; `continuation_integrable` proves their integrability, subtraction proves difference integrability, and only then does `integral_mono` compare them. No real marginal integral is formed. |
| Why is current utility cost finite? | For fixed `z>0` and `0<a<z/2`, concavity bounds `[U(z)-U(z-a)]/a` by the fixed real secant `slope(U,z/2,z)`. Strict increase makes this bound positive. No derivative at zero or consumption-positivity theorem is used. |
| What contradiction rules out binding? | Infinite zero value slope supplies small `x` with `slope(V,0,x)>C/(beta*p*R)+1`. Optimality of `A(z)=0` and the atom bound imply `beta*p*R*slope(V,0,x)≤C`, contradicting positivity of `beta`, `p`, and `R`. |
| Are quantifiers and policy interpretation preserved? | Yes. The conclusion holds for every `z : Resources` with `z>0`, and `assetPolicy` remains shifted next assets. There is no numerical grid or finite-income-support specialization. |
| Are later claims inferred? | No. H14 does not prove the unqualified Inada note without an atom, D01, H06, stationarity, or any equilibrium conclusion. |

## Source audit

The approved A93 file has SHA-256
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.
Rendered inspection covered PDF p. 39, printed p. 38. Proposition 3 gives the qualified binding
interval, and the following note states the unqualified Inada/zero-minimum-income nonbinding
claim. The formal theorem adds the architecture-required positive zero-income atom and proves
that corrected sufficient condition.

The approved A94 file has SHA-256
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.
Rendered inspection covered PDF p. 10, printed p. 667. It displays the shifted asset policy and
resource transition and discusses the borrowing threshold. It does not supply the corrected atom
argument.

## Assumption and axiom conclusion

H14 exposes BASIC, SMOOTH, and every ATOM_INADA component, while using no impatience premise.
The M03E export reports exactly `propext`, `Classical.choice`, and `Quot.sound`. No project axiom,
`sorryAx`, unsafe bypass, assumed policy conclusion, or marginal-integrability shortcut occurs.
H14 is REVIEW_READY, not GREEN. All mandatory predecessor qualifications remain in force.
