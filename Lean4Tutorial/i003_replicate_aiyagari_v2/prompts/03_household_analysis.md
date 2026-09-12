# Milestone 03: household analysis

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 02 accepted; H01–H05 green.

**Contract IDs:** H07, H08, H09, H10, H11, H12, H13, H14, D01

## Work and source passages

Implement the policy-order, right-marginal, marginal-inequality, positive-consumption, envelope/Euler and threshold modules, plus the Inada diagnostic. Read architecture §§4–5; A93 Appendix Propositions 2–3; Benveniste–Scheinkman Lemma 1. Generic concave-analysis helpers belong under `Analysis/`.

## Mandatory proof sequence

1. Prove H07 by comparing the two optimality inequalities. Separate savings monotonicity from consumption monotonicity; use concavity of continuation value and strict concavity of U to exclude a reversal. Conclude both 1-Lipschitz inequalities. Do not claim differentiable policies.
2. Construct the right derivative of the finite concave V on positive states. For real-domain calculus use the extension `x ↦ V(x.toNNReal)`, claiming concavity only on nonnegative inputs. Define the right marginal by one-sided secant limits, not by an ordinary `deriv` that defaults to zero at an unproved differentiability point. Prove its positivity, monotonicity, right continuity and bound `q(z)<=osc(U)/((1-beta)*z)`. Define the zero-state derivative as an extended nonnegative limit, not as a real derivative that defaults to zero.
3. Prove H09 by keeping the original consumption and saving an extra initial h. Divide the Bellman comparison by h and apply monotone convergence to nonnegative concave difference quotients as h decreases to zero. Initially use the nonnegative extended integral. A finite left marginal proves the conditional expectation finite; only then convert to a real integral. The resulting inequality is valid at all R>0, including zero-consumption states.
4. Under beta*R<1, prove positive consumption by splitting finite versus infinite U_right_prime(0). For a finite marginal L, first prove the L-Lipschitz bound for all finite-horizon values when beta*R<=1, then pass to V. At a zero-consumption corner, shifting savings to consumption yields marginal gain L and continuation loss at most beta*R*L<L. For infinite marginal, consuming extra initial resources would force q(z)=infinity if c(z)=0.
5. Prove the one-dimensional lower-touching concavity lemma using left/right secant slopes. At c(z)>0, keep A(z) fixed in a two-sided state neighborhood to obtain H11. This theorem is local and must not carry beta*R<1: N04 later needs it at the critical return.
6. For interior savings, a neighborhood of actions puts next resources away from zero. Establish a dominating marginal bound, differentiate under the integral and use the first-order condition. At A=0 use right derivatives and the marginal inequality. Explicitly represent infinite endpoint slopes before proving conditional finiteness.
7. Prove the binding interval from `q(z)>beta*R*q(e_min)` near e_min and the opposite inequality required by interior Euler equality. Cover separately positive e_min and finite zero marginal.
8. Prove H14's corrected sufficient condition. Inada implies an infinite value slope at zero by consuming extra initial wealth. With a zero-income atom, an infinitesimal positive saving deviation at A=0 then gives an infinite continuation marginal and a finite current cost.

## Exact diagnostic D01

Keep the asset state continuous. Use beta=1/2, R=w=3/2, r=1/2, phi=2, uniform labor on [2/3,4/3], and U(c)=sqrt(c)/(1+sqrt(c)). Verify all primitive requirements and the effective-income pushforward to uniform [0,1]. Show `0<=V<=2`.

Using continuity of V and the sliding interval integral, prove the right derivative at a=0 of `Integral_0^1 V(R*a+e) de` is `R*(V(1)-V(0))`. The whole objective's derivative is at most `-U_prime(z)+3/2`, which is strictly negative for `0<z<=1/100`. Concavity yields A(z)=0 on that interval. Verify the exact derivative/RRA algebra; do not use a plotted curve or a grid. Until this theorem is checked, describe it as a proposed counterexample, not a certified correction.

This milestone can retain completed core lemmas if the diagnostic is blocked, but the report must distinguish the unresolved source correction. Never replace the core family by Inada-plus-atom merely to avoid the finite-marginal case.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
