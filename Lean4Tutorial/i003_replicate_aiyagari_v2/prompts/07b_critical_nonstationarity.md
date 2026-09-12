# Milestone 07b: critical nonstationarity

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 07a accepted, especially its zero-state and equal-consumption treatment. No finite stationary wealth moment may be added.

**Contract IDs:** N05, N06, N07

## Implement the finite-history contradiction in architecture §9.4

Assume for contradiction that the canonical kernel has an invariant probability law pi at beta*R=1. Then R=1/beta>1. For each integer n>=1 independently construct a probability space carrying:
- a common initial resource Z0 with law pi;
- a length-n iid effective-income string e_1,...,e_n;
- an independent length-n iid copy eTilde_1,...,eTilde_n;
with the two strings independent of Z0. These are finite products; there is no need for all n to be realized on one infinite probability space.

Evolve both paths with the same canonical policy. Prove marginal stationarity at every date. N04 gives constant consumption along each path; their initial consumption is identical because they share Z0. Subtract the two resource recursions and telescope exactly to obtain

`R^(-n)*(Z_n-ZTilde_n)=D_n`,
`D_n=sum(j=1..n) R^(-j)*(e_j-eTilde_j)`.

## Two incompatible bounds

1. The marginal laws of Z_n and ZTilde_n are pi. For any eta>0, the union bound gives a tail bound using `pi{z > eta*R^n/2}` (adjust constants consistently). Since every probability measure on NNReal has vanishing upper tails, `R^(-n)*(Z_n-ZTilde_n)` tends to zero in probability. This requires no first or second moment of pi.
2. Independently, `abs(D_n)<=incomeSpan/(R-1)` uniformly. For every a>0, split its second moment at `abs(D_n)<=a` to obtain `E D_n^2 <= a^2+C^2 Pr(abs(D_n)>a)`. First take n large, then a small: the second moments tend to zero. This argument works on changing finite-product spaces; do not introduce a common space just to use an inappropriate dominated-convergence theorem.
3. Expand the square under the product law. Different date/copy centered shock terms have zero cross moments. Both copies have the same mean. Prove
`E D_n^2=2*Var(e)*sum(j=1..n) R^(-2*j)`.
The effective income is bounded and nondegenerate, so its variance is finite and strictly positive. Essential endpoint probabilities supply two separated positive-mass regions, or use a proved variance-zero iff almost-surely-constant lemma. Thus for n>=1 the second moment is at least `2*Var(e)*R^(-2)>0`, contradiction.

Conclude N06, and combine with N03 to export N07 for beta*R>=1. The core result is nonexistence of an invariant probability law, not a statement of pathwise almost-sure divergence. Keep those conclusions distinct in the manifest and prose.

## Reject these shortcuts

No asset boundedness, stationary wealth moment, stationary marginal expectation, explicit consumption lower bound, assumed ergodicity, or claimed a.s. pathwise divergence. No appeal to Clarida's proposition as a proof. Any real gap in this finite-history construction must be returned for mathematical review, not repaired by narrowing the theorem without approval.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
