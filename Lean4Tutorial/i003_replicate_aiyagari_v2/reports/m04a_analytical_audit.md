# M04A analytical audit

Accepted baseline: `d513a22d437ce6e9b8393fccf2e81083b84a4123`. Assigned contract: H06 only.

| Required question | Answer and proof evidence |
|---|---|
| Are utility, income law and beta fixed? | Yes. `HouseholdPrimitives.withPrices m q` copies every field of `m` except normalized prices. Its parameter is an admissible `(R,w,k)` triple for the already fixed labor space and law. |
| Is continuity genuinely joint? | Yes. The public theorem is continuity on `AdmissibleNormalizedPrices m.income × Resources`, not fixed-state parameter continuity or separate continuity. |
| Is the normalized domain exact? | Yes. It requires `R>0`, `w>0`, and `w*l+k>=0` for every labor realization. `toPrices` constructs the existing authoritative `NormalizedPrices`; no raw debt limit is inserted into the Bellman parameter. |
| Are critical and supercritical returns included? | Yes. Neither the domain nor any proof lemma assumes `beta*R<1`. Every admissible `R>0` is covered, including `beta*R=1` and `beta*R>1`. |
| How is value continuity proved on the unbounded state space? | Finite Bellman iterates from zero are jointly continuous by transition continuity, compact parametric integration, and fixed-share compact maximization. The uniform bound `|T_q^n 0(z)-V_q(z)| <= beta^n C/(1-beta)` holds over all prices and states, so the uniform limit is continuous. No global sup-norm continuity of the transition operator in prices is assumed. |
| Why is the tail bound uniform in prices? | The one-period utility bound `|U|<=C` and contraction modulus beta are fixed. The canonical value norm is at most `C/(1-beta)` for every price triple; returns do not enter this bound because utility is bounded. |
| How is policy continuity proved? | At positive resources, the canonical policy divided by resources is the unique maximizer on the fixed compact share interval. Joint objective continuity and the compact unique-argmax theorem give continuous shares. Multiplication by resources gives the shifted-asset policy. |
| Is the zero-resource boundary handled correctly? | Yes. Share uniqueness is not asserted at zero. The accepted H04 inequalities `0<=A_q(z)<=z` yield joint continuity at `(q,0)` by squeezing, uniformly across prices. |
| Are real integrals justified? | Yes. Every continuation integral has a jointly continuous integrand on the fixed compact labor subtype and a finite probability measure. The compact parametric-integral theorem supplies continuity and integrability; no marginal expectation is formed. |
| Is the state/law scope preserved? | Yes. Resources remain all `NNReal`; labor remains the general compact iid probability law. The P03 two-point witness is not used to narrow H06. |
| Are marginal and endpoint qualifications preserved? | Yes. The proof never uses `rightMarginalValue`, `zeroRightMarginal`, utility marginal values, consumption positivity, an envelope identity, or an Euler equation. In particular it makes no claim about `rightMarginalValue m 0`. |
| Are budget/lifetime qualifications affected? | No. H06 works wholly in normalized shifted-resource coordinates. It asserts neither No-Ponzi nor a raw natural-limit continuity result and does not alter H05's finite-history lifetime interpretation. |
| Are stationary or later claims inferred? | No. There is no drift, tightness, invariant-law, asset-supply, boundary-divergence, or equilibrium conclusion. D02 and every later contract remain unformalized. |
| Were predecessor qualifications preserved? | Yes. All 110 supplied entries (94 qualifications and 16 nonblocking findings) were treated as mandatory. None is superseded. Their accepted proofs, assumptions, source limitations, declaration meanings, and review boundaries remain unchanged. |

## Assumption and axiom conclusion

H06 uses BASIC through the existing `HouseholdPrimitives` only: `0<beta<1`, bounded continuous strictly increasing and strictly concave utility, compact positive labor support with its probability law, and admissible normalized prices. Strict increase and concavity are inherited because H04's unique canonical policy depends on them; no stronger profile is added.

The public domain, price conversion, repricing map, joint value theorem, joint policy theorem, and contracted theorem all pass `#check`, `assert_no_sorry`, and `#print axioms`. Their transitive axioms are exactly `propext`, `Classical.choice`, and `Quot.sound`. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. H06 is REVIEW_READY, not GREEN.

## Source and design correspondence

The authorized locator is A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39, with A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10, providing the Bellman and shifted-resource context. The supplied architecture section 6.1 authorizes the explicit normalized-parameter reconstruction: continuous finite horizons, a price-uniform discounted tail, unique compact maximization, and separate zero-boundary treatment. No claim is made that these proof details are verbatim source text.
