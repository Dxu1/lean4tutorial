# Milestone 10: no ponzi and exact extensions

Recommended reasoning: **Extra-high for No-Ponzi; High for algebra**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Core equilibrium milestone accepted; original-budget timing from P01 is fixed. Separate extension IDs from core completion.

**Contract IDs:** NP01, NP02, NP03, E01, E02, E03

## No-Ponzi proof (core)

Read A93 Proposition 1, printed p. 37/PDF p. 38, and architecture §12.1. The forward implication is pathwise; the reverse uses iid income and nonanticipative asset timing. For this genuinely infinite-horizon tail statement, use a properly instantiated iid path space or filtration; the finite-product arguments used by earlier milestones do not by themselves define the tail event.

Prove the exact finite telescoping identity NP01. With r>0 and the natural lower asset bound, discounted consumption partial sums are monotone and bounded above by initial resources plus maximum discounted income and a vanishing lower-bound remainder. They converge, so discounted terminal assets have a finite limit. The lower bound forces that limit nonnegative, not zero.

For the reverse, suppose at some date t the natural floor is violated with positive probability. Extract eta>0 and an event measurable before labor_t on which `a_t<=-w*l_min/r-eta`. Choose a labor-neighborhood width h>0 with `w*h/r<eta/4`. Choose N sufficiently large that `w*(l_max-l_min)*R^(-N)/r<eta/4`.

Conditional on the event, N successive incomes in [l_min,l_min+h] have strictly positive probability by independence and essential lower support. Even assigning all later incomes their maximum, their date-t present value plus R*a_t is bounded above by a strictly negative amount: divide the geometric sum consistently to obtain a bound no greater than `-R*eta/2`. Nonnegative consumption cannot repair this deficit. The telescoping identity forces a negative discounted terminal wealth limit on that event, contradicting no-Ponzi almost surely. Retain the wage factor w and the timing of the income stream. Turn the datewise statements into an almost-sure all-dates statement by a countable intersection.

Do not replace adapted plans by arbitrary foresighted arrays. Do not claim the natural floor is equivalent to a zero wealth limit. Include a simple feasible plan with a positive discounted terminal wealth limit as a diagnostic helper if useful.

## Exact extension identities

E01: At r=0, normalized effective income is w*l and does not depend on b. Prove equality of the entire shifted Bellman problem, canonical policy and stationary law; subtracting b then gives the exact net-supply translation. E02: At positive r, caps above the natural limit induce identical effective primitives and hence identical derived objects. Do not infer a global ordering for other borrowing-limit changes.

E03: For government debt d and tax r*d in pure exchange, substitute x=a-d into `c+a_next=R*a+w*l-r*d`. The budget becomes `c+x_next=R*x+w*l`; the tax-adjusted natural bound becomes x>=-w*l_min/r and bond clearing E a=d becomes E x=0. Prove the bijection of feasible plans, utilities, canonical optimization and stationary laws, then the equilibrium correspondence. Represent the taxed model with a general real asset floor, which can be positive; apply the core nonnegative debt-shift representation only after the x=a-d transformation. The price/clearing problem is pure exchange, not the capital economy. Do not claim neutrality under a fixed institutional cap.

No money, growth, aggregate-risk or full pathwise theorem is authorized by this prompt; they remain visible deferred claims with separate future design requirements.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
