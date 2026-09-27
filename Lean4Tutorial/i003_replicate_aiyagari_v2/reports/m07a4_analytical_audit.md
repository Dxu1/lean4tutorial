# M07A4 analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Is the invariant law constructed at the critical return? | No. `pi` and its invariance identity are explicit hypotheses. S05 is neither imported nor invoked. |
| Is the return branch exactly critical? | Yes. The public premise is `m.beta * m.prices.grossReturn = 1`; no strict-impatience premise occurs. |
| Is a stationary marginal moment assumed? | No. N01 supplies conditional integrability almost everywhere. Only the bounded transform from the N02 route is integrated under `pi`; `Integral q pi` is never formed. |
| Why is an almost-everywhere Jensen helper needed? | N02's accepted reusable theorem has pointwise conditional premises, while N01 supplies the economic premises almost everywhere. `stationary_bounded_jensen_ae_equality` repeats the approved exact tangent-gap proof with the correct null-set interface. |
| How is zero consumption separated from positive consumption? | A retained-saving Bellman comparison proves `utilityZeroRightMarginal <= extendedRightMarginalValue` at any zero-consumption state. At positive consumption H11 gives the derivative identity, and strict concavity puts that derivative strictly below the utility endpoint marginal. Equal finite value marginals therefore cannot join a zero-consumption state to a positive-consumption state. |
| Is the economic zero-state object correct? | Yes. The proof uses `extendedRightMarginalValue`, whose zero branch is `zeroRightMarginal : ENNReal`. It never uses `rightMarginalValue m 0`. `utilityZeroRightMarginal` is kept as the distinct utility endpoint object. |
| Is H11 used within scope? | Yes. It is invoked only for states with proved positive consumption, which also proves positive resources. No zero-corner envelope identity is asserted. |
| What does “every finite stationary history” mean formally? | For every `n : Nat`, consumption agrees almost everywhere between the endpoints under `pi.compProd (householdKernel m ^ n)`. A generic kernel-power induction derives this from one-step equality and invariance. |
| Does finite-history propagation add a moment premise? | No. It is purely an almost-everywhere Markov-kernel argument using stationarity and measurability of consumption. |
| Is the income law still general? | Yes. It remains the compact iid law in `HouseholdPrimitives`, with `IncomeNondegenerate`; no atom, density, finite-state, or two-point restriction is added. |
| Are stronger conclusions introduced? | No. N04 proves consumption constancy under a putative critical invariant law. It does not prove critical nonexistence, the two-string contradiction, pathwise divergence, moment divergence, or equilibrium. |
| Are prohibited devices present? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. |

## Assumptions and predecessor qualifications

All entries in the supplied `predecessor_qualifications.json` remain operative and unsuperseded.
In particular, candidate invariant laws at arbitrary returns remain hypotheses; H09's real form is
used only after N01 establishes initial marginal finiteness almost everywhere; conditional
integrability is not a stationary marginal moment; H11 remains local to positive consumption;
and H10/H12 are not used at critical corners. Historical source, evidence, documentation, and
metadata qualifications retain their original gate attribution.

## Source, dependency, and scope audit

The formal route uses H09 through N01's accepted conditional inequality, H11 for the local
positive-consumption envelope identity, N01 for boundary resolution and conditional finiteness,
and N02's approved bounded-Jensen construction through the gate-local almost-everywhere
interface. A94 printed p. 669 / PDF p. 12 supplies the stationary-versus-pathwise context and
CW00 supplies background. This proof is a new reconstruction, not a cited source theorem. No
fresh source-PDF inspection is claimed.

All four new public declarations have `#check`, `assert_no_sorry`, and `#print axioms` in the
global audit and assigned signature probe. M07A4 changes only N04 to **REVIEW_READY**. It does not
advance N05--N07, Stage 07b, Stage 08, or any later contract.
