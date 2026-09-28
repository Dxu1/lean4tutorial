# Milestone report: M07B1 / N05 finite-product two-string contradiction, substantive revision 1

Date: 2026-09-28. Assigned gate: M07B1. Assigned contract: N05 only. Preserved local baseline:
`31b36f34f25d0ef7c21f7ce1c24d9d138b6199e6`. This is user-authorized substantive revision 1,
executed at Sol High after the controller-owned signature-record parser reconciliation. The
original Medium submission and its evidence remain preserved under
`tmp_orchestration/stage07b/n05_repair/`; this revision does not edit that runtime state.

## Result

N05, `Aiyagari1994.two_independent_histories_contradiction` in
`Aiyagari1994/Analysis/TwoShockStrings.lean`: **REVIEW_READY**. It proves that an actual
state-dependent resource recursion with `R>1`, bounded nonconstant IID shocks, an invariant
probability law, and N04-shaped stationary a.e. consumption constancy is impossible.

Only N05's contract status changed. No GREEN status or later-contract advancement is awarded.

## Proof route and interface

The public target now takes primitive `c`, `step`, the exact equation
`step(z,e)=R*(z-c(z))+shock(e)`, invariance of the induced resource kernel, and a stationary
one-step a.e. consumption equality of exactly the form supplied by N04. It no longer accepts
arbitrary terminal maps, endpoint-law premises, or a conclusion-like discounted identity.

For each horizon, `coupledHistoryLaw` builds a separate recursive finite product with a common
initial state and two independent IID innovation strings. The proof converts kernel invariance to
the one-step resource pushforward, derives both terminal `pi` laws by induction, transfers the
N04-shaped equality to innovation products, intersects the finitely many full-measure events, and
derives the discounted telescope from the recursion. Tightness and a union bound make the scaled
terminal difference small without a state moment. Uniform shock boundedness converts this to a
small second moment. Independent paired shocks give the exact identity
`E[D_n²]=2*Var(e)*∑_{j=1}^n R^(-2j)`, while non-a.e.-constancy proves `Var(e)>0`.

New reusable helpers are confined to `Aiyagari1994/Analysis/M07B1/`. The analytical audit maps
the required coverage explicitly: telescoping identity derived; endpoint `pi` laws derived; N04
bridge a.e.-compatible; state moments absent.

## Verification and review request

`lake build Aiyagari1994.Analysis.M07B1.FiniteHistoryBridge
Aiyagari1994.Analysis.TwoShockStrings` completed successfully with 2,922 jobs, and
`lake build Probes.M07B1Signatures` completed successfully with 2,924 jobs. The probe has 39
`assert_no_sorry` commands and reports transitive axioms exactly `propext`, `Classical.choice`,
and `Quot.sound` for the target and all thirty-eight public helpers. `lake build` completed
successfully with 3,112 jobs, including `All` and `Audit`; the global audit now contains 569
`assert_no_sorry` commands. Reported full-build linter warnings were inherited from earlier
modules; the assigned sources are warning-free.

`python3 tools/check_contracts.py` passed for 57 contracts and an acyclic dependency graph, with
status counts 33 GREEN, 1 REVIEW_READY, and 23 UNFORMALIZED. The contract diff changes only N05's
`status` field. `git diff --check` and the source-only prohibited-pattern scan passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 62-page Markdown/TeX/PDF ledger.
Rendered pages 52--58 were visually inspected with Poppler; the complete N05 entry on pages 53--54
and the N06/N07 boundary are legible with no clipping, overlap, broken glyph, or bad section
transition. N06 and N07 remain UNFORMALIZED. The PDF SHA-256 is
`cf79dca425f526142a24de41b4ea8f750fa938090132c5ee2546ef7bf946037d`.

The controller owns verification logs, export inventories, evidence, and review archives; none
are created or edited here. Independent adequacy review is requested for N05 only. Stop at
REVIEW_READY; do not execute N06, N07, Stage 08, or any later gate.
