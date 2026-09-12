# Milestone 06: stationary continuity and aggregation

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 05 accepted; H06 and D03 green.

**Contract IDs:** S06, A01, A02, A03

## Work

Implement invariant-law parameter continuity, the cross-sectional bridge, the stationary budget and mean-asset continuity. Read architecture §8 and SLP Theorem 12.13, printed pp. 384–385 / PDF pp. 394–395.

For a convergent sequence of strictly impatient normalized parameters, use D03 to place all nearby stationary laws on one [0,B]. Compactness gives subsequences. For bounded continuous f, joint transition/policy continuity makes P_n f converge uniformly on this compact state interval. Pass the invariance identity to the limit and identify it by S05 uniqueness. Conclude weak continuity of the full sequence. Address the varying economic lower endpoint by using [0,B], not by silently identifying different subtype spaces.

Prove the current-asset/current-labor law is rho×nu with rho=(A-phi)#pi, and its resource image is pi. Also prove the converse correspondence for an admissible invariant asset/labor law. No continuum law of large numbers or common aggregate shock process is required.

Establish compact-support integrability before writing every real aggregate. Derive
`E z=R*E A+E e`, `S=E A-phi`, and `E c=r*S+w*E l`.
For parameter continuity of S, split the integral change into uniform convergence of A on [0,B] and weak convergence against the fixed A-limit integrand. Subtract the continuous finite debt shift. Do not pass an unbounded integrand through weak convergence alone. Do not assert this common B remains valid as beta*R approaches one.

Give an additional stationary-budget lemma for any invariant law with explicit finite first moments; this will support goods clearing for arbitrary equilibria, not only the constructed canonical law. Explain how that moment hypothesis is legitimate in an equilibrium definition while its existence is derived in the construction.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
