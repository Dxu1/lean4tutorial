# Milestone 05: kernel mixing and stationarity

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 04 accepted; the subcritical household analysis and uniform drift are green.

**Contract IDs:** S01, S02, S03, S04, S05

## Work and source

Implement the kernel, lower-transition, crossing, generic monotone-Feller, and global-stability modules. Read architecture §7 and SLP Assumption 12.1, Lemma 12.11, Theorem 12.12, printed pp. 381–383 / PDF pp. 391–393. Do not import SLP as an axiom.

## Economic kernel and crossing

Construct the actual pushforward probability kernel and prove measurability/Feller continuity via bounded continuous tests. Use the same shock for two states to prove stochastic monotonicity.

For `h_min(z)=R*A(z)+e_min`, prove h_min(e_min)=e_min and h_min(z)<z for z>e_min. The contradiction if h_min(z)>=z is interior Euler equality plus
`q(z)<=beta*R*q(h_min(z))<=beta*R*q(z)<q(z)`.
At e_min=0 use A(0)=0; at a positive endpoint the same contradiction rules out positive savings.

Iterates of h_min from B decrease to e_min. Pick d strictly between e_min and e_max; choose N>=1 with h_min^N(B)<d. Continuity of the finite N-fold transition makes a sufficiently small common neighborhood of the minimum shocks keep the endpoint below d. Essential support gives this event probability pMinus^N>0. A final shock above d, with probability pPlus>0, sends any path above d. Derive both endpoint-crossing inequalities for the **same N** with epsilon=min(pMinus^N,pPlus,1/2)>0. No point mass at the minimum, density assumption, upper fixed-point uniqueness, or source figure is available as a premise.

## Generic SLP theorem

Prove the increasing lower-endpoint law sequence and decreasing upper-endpoint sequence are ordered. Compactness of probability measures supplies limit laws. Establish that continuous increasing functions determine measures/order on an interval (piecewise-linear approximation or a proved distribution-function characterization is acceptable). Feller continuity makes each endpoint limit invariant.

Crossing bounds, for nondecreasing f:
`epsilon*f(d)+(1-epsilon)*f(low) <= P^N f(z)`
and
`P^N f(z) <= epsilon*f(d)+(1-epsilon)*f(high)`.
Apply them to P^(k*N)f, deriving oscillation contraction by `(1-epsilon)^k`. Endpoint invariant limits agree; stochastic sandwich gives a unique invariant law and weak convergence for all initial laws. Prove the weak-convergence conclusion using a determining class rather than silently claiming convergence for every bounded measurable f or in total variation.

## Full unbounded state space

Use the compact theorem first on [e_min,B]. For an initial state z>B, apply it to [e_min,max(B,z)]; the existing invariant law also lives there, so uniqueness identifies the limit. States below e_min enter the economically reachable range after one step. Integrate pointwise convergence against an arbitrary initial probability law using bounded test functions and dominated convergence. Deduce uniqueness among **all** invariant probability laws on NNReal, not only those already assumed compactly supported or integrable.

Do not make finite-time absorption or full-space invariant uniqueness an assumption. Keep the generic theorem's legitimate hypotheses distinct from the economic wrapper that discharges them.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
