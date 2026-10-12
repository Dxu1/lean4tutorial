# M10A2 analytical audit

This executor audit covers NP02 only and does not claim independent adequacy review.

| Dimension | Executor evidence |
|---|---|
| D01 | `Aiyagari1994.naturalBound_implies_noPonzi` concludes almost surely that there is a finite real limit `L >= 0` for exactly `(1+r)^(-T) * a_(T+1)`. It does not conclude `L=0`. |
| D02 | `NaturalNoPonzi.lean` proves discounted-income summability, an upper bound on every nonnegative discounted-consumption partial sum, convergence of both series, the NP01 rearrangement, and nonnegativity by a vanishing lower squeeze. |
| D03 | The budget is `c_t+a_(t+1)=(1+r)*a_t+w*l_t` in original/net assets. The floor is exactly `-naturalLimit laborMin w r = -w*laborMin/r`; shifted assets and resources never replace `a`. |
| D04 | A93 Appendix Proposition 1, printed 37/PDF 38, states and sketches the forward implication. A94 printed 666/PDF 9 note 16 records the present-value and natural borrowing-limit relation. Detailed Lean convergence and a.s. lifting are labeled project reconstruction. |
| D05 | Actual premises are positive `r`, positive `w`, positive lower labor endpoint, datewise a.s. bounded labor, nonnegative consumption, original budgets, and the natural floor. No helper adds IID, optimality, Euler, stationarity, equilibrium, or transversality. |
| D06 | No hypothesis asserts consumption-series convergence, terminal-wealth convergence, limit nonnegativity, or a surrogate final contradiction. Each is derived from the finite budget identity and primitive path bounds. |
| D07 | The sole formal theorem dependency is accepted NP01 through `M10A1.discounted_budget_telescope_core`; `EffectiveLimit` supplies the already accepted exact `naturalLimit` definition. No later No-Ponzi theorem is imported. |
| D08 | The forward proof is distribution-free and therefore preserves the accepted general compact iid-income scope, including atoms and non-finite support. It does not narrow the income law to a numerical or finite-support model. |
| D09 | No value marginal, zero-state marginal, envelope, or Euler object occurs. All inherited boundary-marginal qualifications remain untouched. |
| D10 | No expectation or real-valued integral is used. The only infinite objects are real series whose summability is proved before their `tsum` values enter limit arithmetic. |
| D11 | Income convergence follows from a proved geometric comparison; consumption convergence follows from nonnegative bounded partial sums. No weak-convergence-to-moment inference occurs. |
| D12 | `r>0` yields `R=1+r>1` and `0<R^-1<1`. No `beta*R<1`, strictly positive consumption, or zero-consumption exclusion is assumed. |
| D13 | Targeted scans and both audit surfaces cover all new sources; no `sorry`, `admit`, project axiom, `native_decide`, `Lean.ofReduceBool`, unsafe bypass, or numerical model is present. |
| D14 | `#print axioms` for the pathwise helper, a.s. helper, and public wrapper reports only `propext`, `Classical.choice`, and `Quot.sound`. |
| D15 | `Probes/M10A2Signatures.lean` and `Audit.lean` each contain `#check`, `assert_no_sorry`, and `#print axioms` for all three new public declarations. |
| D16 | Only NP02's contract status changes from UNFORMALIZED to REVIEW_READY. The ledger records its exact target, actual premises, proof, source locators, dependency, axiom inventory, and review boundary. |
| D17 | The proof establishes the economic forward implication: bounded discounted income plus nonnegative consumption and the natural debt floor force finite nonnegative discounted terminal wealth. It does not prove a shifted-coordinate surrogate. |
| D18 | Datewise almost-sure hypotheses are converted by `MeasureTheory.ae_all_iff` into a common full-measure all-dates event before the pathwise theorem is applied. No a.s. premise is treated globally as pointwise. |
| D19 | NP03's converse, IID tail construction, adaptedness argument, finite low-income block, and natural-floor derivation are absent. E01-E03 and stage advancement remain unauthorized. |
| D20 | The implementation and evidence support REVIEW_READY only. Independent immutable-snapshot review and controller promotion remain required for GREEN. |

All predecessor qualifications q1-q934 remain operative by reference with no supersession. In
particular, P01 remains coordinate/budget equivalence rather than No-Ponzi; NP01 remains a finite
pathwise telescope rather than an infinite-horizon conclusion; original/net assets remain distinct
from shifted assets; the natural floor uses the positive-rate branch of `naturalLimit`; and all
historical evidence limitations retain their originating-gate attribution.
