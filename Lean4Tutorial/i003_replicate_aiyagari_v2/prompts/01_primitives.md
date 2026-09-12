# Milestone 01: primitives

Recommended reasoning: **High**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 00 accepted, source hashes verified, toolchain pinned and API probes building.

**Contract IDs:** P01, P02, P03

## Allowed work

Implement `Primitives/*`, `Budget/Normalization.lean`, `Budget/EffectiveLimit.lean` and exact primitive examples, plus minimal supporting lemmas. Read architecture §2 and the interface design. Do not implement Bellman optimization or stationarity yet.

## Mathematical instructions

- Use nonnegative real resources and continuous asset choices. Represent primitive utility as `Real → Real` with its properties restricted to nonnegative consumption; this allows ordinary derivatives on strictly positive real inputs. `NNReal` is not a real normed vector space. Production will use the same real-domain/restricted-property convention. Separate base bounded/continuous/strictly-concave utility from positive-consumption differentiability and eventual curvature bounds. Do not build finite marginal utility or Inada at zero into the base type; both are allowed.
- Separate the general income probability law from endpoint-neighborhood nondegeneracy and mean-one normalization. A density is not required.
- Parameterize the analytic household by normalized prices `(R,w,k)` with effective income `e(l)=w*l+k>=0`. The original-price map has `R=1+r`, `k=-r*phi`. Retain an explicit debt shift only for the original budget and net aggregation. Prove all coercions and positivity facts.
- Prove P01 in both directions with exact timing. Do not identify `A(z)` with net assets: the future optimal action will be shifted holdings.
- For finite b, prove nonnegativity/admissibility of the piecewise effective limit. At positive r use each branch of the minimum. At r=0, show that a neighborhood has `b<=w*l_min/r` whenever r>0 is sufficiently small, so the minimum equals b; the negative-rate branch is already b. Treat b=0 without division by b. Prove continuity on `w>0,r>-1`.
- Define and prove the natural-limit map separately on r>0. Its normalized intercept is exactly `-w*l_min`. Do not combine mutually exclusive branch assumptions into one impossible premise.
- Construct P03 with exact rational parameters and a two-point labor measure, while retaining continuous assets. Prove the utility's continuity, boundedness, strict increase/concavity, derivative conditions and the bound `2c/(1+c)<=2`. Show endpoint masses and labor mean one. This is a nonvacuity test for the full assumption profile, not a restricted core theorem.

## Acceptance checks

Print the primitive structures. No field may contain a value function, policy, Feller property, mixing condition, stationary law, upper bound or equilibrium conclusion. Compile the consistency witness against the same primitive types intended for the core theorem. Return the exact elaborated P01/P02/P03 signatures for review.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
