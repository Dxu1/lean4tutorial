# M10A1 analytical audit

This executor audit covers NP01 only and does not claim independent adequacy review.

| Dimension | Executor evidence |
|---|---|
| D01 | `Aiyagari1994.discounted_budget_telescope` quantifies over every finite `T` and concludes the exact sum through `T`, with terminal term `R⁻¹ ^ T * a (T+1)`. |
| D02 | `BudgetTelescope.lean` proves the base budget and a genuine induction; the successor step uses `R⁻¹^(T+1) * R = R⁻¹^T` and the next one-period budget. |
| D03 | `a` denotes original/net assets in `c t + a(t+1) = R*a t + w*labor t`; no shifted asset or resource state is substituted. |
| D04 | A93 Appendix Proposition 1, printed 37/PDF 38, displays the finite identity; A94 printed 666/PDF 9 note 16 gives its borrowing-limit context. The Lean induction is identified as reconstruction. |
| D05 | Actual premises are `0<R` and the pointwise original budget equality. No helper adds an economic premise; omitted path properties are algebraically irrelevant. |
| D06 | The sole substantive hypothesis is the one-period budget being telescoped. No finite-identity conclusion, terminal condition, or impossible premise is assumed. |
| D07 | The helper imports only P01's `Budget.Normalization`; the public module imports only the authorized M10A1 helper. Accepted declarations were not edited. |
| D08 | NP01 is pathwise and distribution-free, so it applies in particular to continuous assets and the accepted general compact iid income law without restricting either. |
| D09 | No value marginal or zero-state marginal object occurs because NP01 is pure budget algebra. |
| D10 | No expectation, integral, ENNReal conversion, or infinite sum occurs; all sums are finite real Finset sums. |
| D11 | No convergence claim occurs. NP01 proves only the finite-horizon identity and cannot be read as moment or limit convergence. |
| D12 | No `beta*R<1`, consumption positivity, or positive-consumption premise occurs. Only the assigned positive gross return is used. |
| D13 | Targeted scans and both audit surfaces cover the new sources; no `sorry`, `admit`, project axiom, `native_decide`, or unsafe bypass is present. |
| D14 | `#print axioms` for both the gate-local theorem and public wrapper reports only `propext`, `Classical.choice`, and `Quot.sound`. |
| D15 | `Probes/M10A1Signatures.lean` and `Audit.lean` each contain `#check`, `assert_no_sorry`, and `#print axioms` for both new public declarations. |
| D16 | The contract has only NP01 status changed to REVIEW_READY; this ledger records the exact signature, actual premises, proof, source, axioms, and review boundary. |
| D17 | The formal hypothesis is the original paper budget at every date, and the formal conclusion is its discounted finite telescope, rather than a surrogate shifted-budget identity. |
| D18 | The theorem is stronger only by omitting unused wage-positivity and path-regularity premises; it does not weaken the conclusion, timing, discount exponent, or pathwise interpretation. |
| D19 | No limit, natural debt floor, No-Ponzi implication, IID/adapted path space, NP02, NP03, or extension theorem is implemented, even as a helper. |
| D20 | The evidence supports REVIEW_READY only. Independent immutable-snapshot review and controller promotion remain required for GREEN. |

All predecessor qualifications q1–q925 remain operative by reference with no supersession. In
particular, P01 remains coordinate/budget equivalence rather than a No-Ponzi theorem, original and
shifted assets remain distinct, and historical evidence limitations retain their originating-gate
attribution.
