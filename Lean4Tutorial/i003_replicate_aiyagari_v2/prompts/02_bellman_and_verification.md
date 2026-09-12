# Milestone 02: bellman and verification

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 01 accepted; P01–P03 green.

**Contract IDs:** H01, H02, H03, H04, H05

## Files and mathematical target

Implement `Analysis/ParametricMax.lean` and `Household/{Bellman,Value,Policy,Verification}.lean`. Follow architecture §3. The fixed-point and lifetime-optimality results must hold for **every R>0**, not merely `beta*R<1`.

## Proof construction

1. Define the objective and prove that integrating a bounded continuous candidate value against the fixed compact labor law is continuous on locally compact ranges of `(z,a)`. The maximization set is `[0,z]`. Use `a=t*z`, `t in [0,1]`, only to prove maximum continuity over a fixed compact control interval; do not claim unique t at z=0.
2. Prove existence of the maximum, boundedness of the Bellman result, and the two sup-norm inequalities yielding the beta-contraction. Use the installed Banach theorem, then name the canonical fixed point. Establish value bounds and uniform finite-horizon convergence.
3. Show the Bellman operator preserves concavity and weak increase. Pass these properties through uniform convergence from a zero terminal value. Derive strict increase of the fixed point by retaining the old saving choice and consuming the added resources.
4. Prove strict concavity of the objective in the actual action a, yielding a unique maximizer. Define `assetPolicy` from this proved uniqueness. Prove policy continuity with compact maximization/uniqueness, including z=0 through feasibility. Consumption is the nonnegative difference z-A(z).
5. Implement measurable finite-history plans and recursively generated resource paths under iid labor. Prove the one-step Bellman inequality for arbitrary feasible actions. Integrate and induct to obtain
   `V(z0) >= E[sum(t<n) beta^t U(c_t) + beta^n V(z_n)]`.
   For the canonical policy prove equality. Verify all measurability and iterated-integral steps. The last state is after n future transitions, with the initial resource already observed.
6. Use bounded V to remove the terminal term and bounded U to justify absolute convergence of expected discounted sums. Conclude optimality against all nonanticipative feasible plans, not just stationary plans. Apply P01 to state the original-budget counterpart.

## Explicit prohibitions

No supplied behavior/value function in primitive records, no unproved measurable selection, no `beta*R<1` restriction, and no statement that a Bellman solution is automatically an infinite-horizon optimum. Do not assume all policies are continuous; continuity is proved only for the canonical one, whereas competitors need measurability and feasibility.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
