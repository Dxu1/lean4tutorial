# Milestone 04: continuity and uniform drift

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 03 accepted for H07–H13; milestone 02 complete. Diagnostic status remains explicit.

**Contract IDs:** H06, D02, D03

## Work

Implement `Household/ParameterContinuity.lean`, `Analysis/Curvature.lean` and `Household/UpperDrift.lean`, following architecture §6. Source: SE77 Theorems 3.8–3.9 and A93 Proposition 4.

## Joint continuity

For fixed U, nu and beta, show each finite-horizon value jointly continuous in normalized parameters and state. The bounded discounted tail estimate is uniform in normalized prices, so the limit V is jointly continuous. Unique compact maximization gives joint continuity of A. Include critical/supercritical R in this theorem. Do not prove only fixed-state parameter continuity or assume a global sup-norm continuity of the transition operator on an unbounded state space.

## Uniform drift construction to implement

Work with explicit neighborhood bounds `0<Rmin<=R<=Rmax`, `beta*R<=gammaStar<1`, `0<=e_min<=e_max<=EStar`, and span `<=DeltaStar`.

- Choose a positive integer m dominating the eventual RRA bound. Differentiate `c^m*U_prime(c)` to prove it is nondecreasing above C0, hence `U_prime(c1)/U_prime(c2)<=(c2/c1)^m`.
- Choose C>=C0 with `gammaStar*(1+DeltaStar/C)^m<1`. Prove this choice by the relevant limit rather than assuming it.
- Let D=osc(U)/(1-beta). Choose L>D/U_prime(C); H08 and the envelope give `c_theta(x)>C` for x>L, uniformly over the neighborhood.
- Choose K with Rmin*K>L and B>=Rmax*K+EStar, B>0.
- For z>=B, if A(z)<=K then maximal next resources are <=B<=z. Otherwise both extreme next states consume more than C. The consumption 1-Lipschitz bound and the ratio inequality give `E q(next)/q(next_max)<1/(beta*R)`. Euler equality gives `q(z)<q(next_max)`, and nonincreasing q forces `next_max<z`.
- Since A is nondecreasing, next resources from any z<=B are at most the maximal next resources from B, hence <=B. The lower bound is e_min. Record the common invariant interval.

The bound is uniform on the specified neighborhood, not a presumed continuous selection of pointwise caps. For the natural-limit boundary, this result will be applied to bounded `(R,w,k=-w*l_min)`, despite divergent phi. Do not infer finite-time entry from a non-strict drift inequality.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
