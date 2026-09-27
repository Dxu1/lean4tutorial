# M07A2 analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Is this theorem generic rather than tied to the household primitives? | Yes. The signature quantifies over an arbitrary measurable state type, Markov kernel, invariant probability measure, positive measurable real function `q`, and scalar `gamma`. It has no economic assumption profile or project-theorem dependency. |
| Does the signature require finite stationary `E_pi[q]`? | No. It requires `Integrable q (P z)` separately for every current state and never requires or constructs `Integrable q pi`. Only the bounded transform `psi o q` is integrated against `pi`. |
| Is positivity strong enough for the strict steps? | Yes. `q z > 0` holds pointwise. Because each `P z` is a probability measure and `q` is conditionally integrable, every conditional mean `m(z)` is strictly positive. This makes the `gamma>1` middle inequality strict and all tangent-gap denominators positive. |
| Is stationarity used only on a bounded quantity? | Yes. The endpoint identity is `Integral e pi = Integral (psi o q) pi`, where `0 <= psi(q) <= 1`. Fubini is applied to the integrable bounded transform under `pi compProd P`; no stationary first moment of `q` is used. |
| Is the exact approved tangent-gap identity proved? | Yes. The Lean proof establishes `psi(m)+(x-m)/(1+m)^2-psi(x)=(x-m)^2/((1+m)^2*(1+x))` by field algebra after proving both denominators nonzero. The identity supplies Jensen's inequality and its equality case. |
| How is `gamma>1` ruled out? | The bounded chain `e <= psi(m) <= psi(gamma*m) <= psi(q)` has equal endpoint integrals by stationarity. Hence its middle terms agree almost everywhere. At any such state, `m>0` and injectivity of `psi` on the positive half-line force `gamma*m=m`, so `gamma=1`. |
| How is the critical equality lifted to the stationary pair law? | Zero integral of the nonnegative tangent gap yields `q(z')=m(z)` for `P z`-almost every next state. Equality of the last bounded-chain step gives `m(z)=q(z)` for `pi`-almost every current state. `Measure.ae_compProd_of_ae_ae` combines them into `q(z')=q(z)` under `pi compProd P`. |
| Are H09, H10, H11, H12, or S05 used? | No. N02 imports only installed Mathlib kernel/integration infrastructure. It neither supplies a candidate invariant law nor invokes any strict-impatience or consumption-positivity result. |
| Are zero-boundary marginal objects involved? | No. This generic theorem takes a positive finite real-valued `q`; it does not mention `rightMarginalValue`, `zeroRightMarginal`, or economic boundary conversion. The inherited distinction remains untouched for later wrappers. |
| Are stronger stationary claims introduced? | No. The result proves only `gamma=1` and adjacent-pair equality of `q` under the supplied stationary joint law. It proves no invariant-law existence, uniqueness, convergence, moment, pathwise divergence, consumption constancy, aggregation, or equilibrium statement. |
| Are prohibited assumptions or bypasses introduced? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, numerical model, or changed economic premise. |

## Assumptions and predecessor qualifications

The public signature states every generic mathematical premise explicitly: measurability and
pointwise positivity of `q`, pointwise conditional integrability, `gamma>=1`, the pointwise
superharmonic inequality, the Markov property, probability of `pi`, and invariance. It does not
silently strengthen these to stationary `q`-integrability or weaken them to totalized integral
semantics.

All 611 entries in the supplied `predecessor_qualifications.json` remain operative and
unsuperseded. In particular, candidate invariant laws at arbitrary returns remain hypotheses;
H09's real form still requires finite initial marginal; `zeroRightMarginal : ENNReal` remains the
only economic zero-state object; conditional integrability remains distinct from stationary
`E[q]`; H11 remains local to positive consumption; and H10/H12 strict-impatience conclusions are
not used at critical corners. Historical source-inspection, documentation, controller-evidence,
and nonblocking qualifications retain their original gate attribution.

## Source and scope

The proof implements architecture section 9.2 and the supplied generic bounded-Jensen extract.
A94 printed p. 669 / PDF p. 12, notes 20--21, supplies surrounding stationary/pathwise context;
CW00 supplies background. The bounded-transform and tangent-gap theorem is a new reconstruction,
not a literal source theorem. No fresh source-PDF inspection is claimed.

The sole new public declaration has `#check`, `assert_no_sorry`, and `#print axioms` coverage in
both audit files. N02 is submitted as **REVIEW_READY** only; this audit certifies no other Stage
07a contract and does not advance N03, N04, Stage 07b, or Stage 08.
