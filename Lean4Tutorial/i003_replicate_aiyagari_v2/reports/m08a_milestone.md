# Milestone report: M08A / B01 tight kernel invariant limit

Date: 2026-10-02. Assigned gate: M08A. Assigned contract: B01 only. Accepted baseline:
`47ed1ab9c2972432c6eaeeeacb18cd70089cfb73`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, evidence, inventories, logs, and review archives were not
edited.

## Result

B01, `Aiyagari1994.tight_kernel_invariant_limit` in
`Aiyagari1994/Analysis/TightKernelLimit.lean`: **REVIEW_READY**. For Feller probability Markov
kernels on noncompact `NNReal`, a weak limit of tight invariant laws is invariant for the limiting
kernel when every bounded-continuous kernel test converges locally uniformly.

Only B01's contract status changed. B02, B03, Stage 09, and all later contracts remain
UNFORMALIZED. No GREEN status or gate advancement is awarded.

## Proof route and scope

For each bounded continuous test, the proof splits the varying-test integral over a compact set
provided by tightness and its complement. Local uniform convergence controls the compact part.
The Markov property bounds each kernel expectation by the test sup norm, so the uniformly small
tail mass controls the complement. The limiting Feller hypothesis packages the limiting kernel
expectation as a bounded continuous test for weak convergence. The approximating invariance
identities, convergence of the two bounded tests, and bounded-continuous measure separation then
prove invariance of the limit.

There are no household assumptions, globally uniform convergence, compact-state or bounded-
support assumptions, moments, unbounded-test limit passages, or later-gate conclusions. The two
directly necessary exported helpers are confined to `Aiyagari1994/Analysis/M08A/`.

All supplied predecessor qualifications remain operative and unsuperseded. In particular, no
weak-convergence moment conclusion is inferred, and S06's local common-support result is not used
or extended to the boundary. This is the authorized project reconstruction, not a claim that
SLP89 states the noncompact theorem verbatim.

## Verification and review boundary

The targeted theorem and signature probe build successfully. The final full `lake build`
completed successfully with 3,117 jobs, including `All` and `Audit`. The gate probe audits all
three new public declarations with `#check`, `assert_no_sorry`, and `#print axioms`; each printed
axiom set is exactly `propext`, `Classical.choice`, and `Quot.sound`. The synchronized global
audit contains 578 matching `#check`, `assert_no_sorry`, and `#print axioms` entries.

`python3 tools/check_contracts.py` passes for 57 contracts and an acyclic dependency graph, with
status counts 36 GREEN, 1 REVIEW_READY, and 20 UNFORMALIZED. The contract diff changes only
B01's `status` field. `git diff --check` and the assigned-source prohibited-pattern scan pass.

The proof ledger records the exact elaborated signature, hypotheses, compact/tail argument,
axioms, and REVIEW_READY boundary. The Markdown/TeX/PDF ledger is synchronized; the rendered
title/status page and B01 pages 56--57 were visually inspected with no clipping, overlap, broken
glyph, or section-transition defect. The PDF SHA-256 is
`6c737b4b371c60e9501c96cfad2bdb53a0a5024c0004dd4462ef925ed2fa3ad9`.

Independent adequacy review is requested for B01 only. Stop at REVIEW_READY; do not execute B02,
B03, Stage 09, or any later gate.
