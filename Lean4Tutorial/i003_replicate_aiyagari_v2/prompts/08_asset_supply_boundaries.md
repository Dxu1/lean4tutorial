# Milestone 08: asset supply boundaries

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestones 04–07b accepted; joint policy continuity includes the critical return and N07 excludes all invariant probability laws there.

**Contract IDs:** B01, B02, B03

## Work

Implement architecture §10 in `Analysis/TightKernelLimit.lean` and `Aggregate/{UpperBoundary,LowerBoundary}.lean`. Source locator: Clarida 1990 Proposition 2.4, printed p. 548/PDF p. 7, and A94 note 19. Clarida states the result without proof; our proof is the construction below.

## Upper boundary

Prove a sequence theorem first. Let r_n<lambda tend to lambda, w_n→wStar>0, and phi_n→finite phiStar through admissible prices. If S_n does not tend to +infinity, extract a subsequence bounded above by M. Since E A_n=S_n+phi_n and phi_n is bounded, shifted asset means are uniformly bounded. Use the stationary budget `E z=R_n E A_n+E e_n` to bound resource means; all these integrals are finite for the individual subcritical laws by earlier compact support.

The generic B01 lemma must explicitly assume Feller probability Markov kernels; the economic application supplies this from S01. Continuity of the limiting test function PStar f is necessary for the weak-limit step.

Markov's inequality gives uniform tightness on NNReal. Use the verified Prokhorov API to extract a weakly convergent subsequence. For each bounded continuous test f, joint policy/transition continuity gives local uniform convergence P_n f→PStar f. On a compact state interval, this convergence controls the integral difference; outside it, bounded f and tightness make the tails small. Weak convergence handles the fixed bounded continuous function PStar f. Pass the invariance identity to show that the limit law is invariant for the critical kernel.

N07 gives the contradiction. No convergence of unbounded asset means is required, and there is no common compact asset bound at the boundary. Then translate the sequence result to the one-sided filter statement, including along the firm wage schedule later used by equilibrium.

## Natural-limit lower boundary

For r_n→0 from above and w_n→w0>0, set normalized effective income e_n=w_n*(l-l_min). Here R_n→1 and beta<1 leave a uniform impatience margin; normalized `(R_n,w_n,k_n=-w_n*l_min)` stays locally bounded. D03 supplies a common cap on shifted saving, hence a bound on E A_n. Since phi_n=w_n*l_min/r_n→infinity, S_n=E A_n-phi_n→-infinity.

Do not apply the raw-parameter continuity theorem to phi_n→infinity, assume the conclusion as an endpoint condition, or replace divergent means by expanding support. Return the complete limit passage and probability-measure topology assumptions for review.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
