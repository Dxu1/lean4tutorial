# Milestone 07a: marginal stationarity argument

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestones 02–03 and kernel construction accepted. Full stationary-existence results are not premises of this argument.

**Contract IDs:** N01, N02, N03, N04

## Goal and why the proof uses value marginals

Implement architecture §§9.1–9.3, including N01–N04. The return is arbitrary; the relevant branches have beta*R>=1. Do not assume positive consumption, a compact asset bound, or finite stationary expected marginal utility. The subcritical positivity theorem is unavailable here.

## Zero-state and conditional finiteness

Use the extended right value derivative from H08/H09. If q(0) is finite, it is positive. If it is infinite and Pr(e=0)>0, an optimal zero-saving action at a positive state would have an infinite continuation marginal and a finite current cost, so A(z)>0. Therefore a putative invariant law obeys `pi{0}=Pr(e=0)*pi{0}`. Nondegenerate income implies Pr(e=0)<1; conclude pi{0}=0. If Pr(e=0)=0, zero has no incoming probability anyway.

Only after this null-state result may q(0) be assigned a finite placeholder for real-valued integration. Prove q finite and positive pi-almost everywhere and prove its conditional integral is finite from H09. Invariance makes the next-state marginal finite almost surely under the stationary joint law as well.

## Generic bounded-Jensen lemma

Set gamma=beta*R and psi(x)=x/(1+x) for nonnegative x. With m(z)=Pq(z), prove almost everywhere:
`psi(q(z)) >= psi(gamma*m(z)) >= psi(m(z)) >= P(psi∘q)(z)`.
The end terms have equal integrals by stationarity and boundedness of psi. Thus all nonnegative gaps have zero integral.

For gamma>1, m(z)>0 gives a strictly positive middle gap almost everywhere, a contradiction. This proves N03 without any stationary first moment.

At gamma=1, prove strict Jensen equality using the exact algebraic identity
`psi(m)+psi'(m)*(x-m)-psi(x)=(x-m)^2/((1+m)^2*(1+x))`.
The conditional integral of the left side is zero precisely when x=m almost surely. Combine with the first equality and strict monotonicity of psi to obtain q(next)=q(current) under the stationary one-step joint law. Only conditional integrability of q is used; do not write `Integral q dpi` unless separately known finite.

## Equal consumption including corners

At c(z)>0 use H11: q(z)=U_prime(c(z)). At c(z)=0, the extra-initial-consumption comparison gives q(z)>=U_right_prime(0). Strict concavity makes U_prime strictly decreasing, and for positive c, U_prime(c)<U_right_prime(0). Hence equal finite q values imply equal consumption, even when U has a finite marginal and zero consumption occurs.

Lift one-step equality to each finite stationary history by induction/integration. This does not yet prove critical nonstationarity: return a lemma that any putative critical stationary process has c_t=c_0 almost surely on each finite history. That is the input to 07b.

This is a high-risk mathematical gate. Return the full readable argument, zero-state branches, integrability derivations and exact elaborated hypotheses for review before using it to prove boundary behavior.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
