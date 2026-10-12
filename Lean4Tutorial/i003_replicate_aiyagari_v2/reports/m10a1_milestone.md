# Milestone report: M10A1 / NP01 discounted budget telescope

Date: 2026-10-12. Assigned gate: M10A1. Assigned contract: NP01 only. Accepted baseline:
`2e6bd77b55fa23252eac601ada028c0ed39fb12e`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, export inventories, evidence, and review
archives were not edited.

## Result

NP01, `Aiyagari1994.discounted_budget_telescope` in
`Aiyagari1994/Budget/NoPonzi.lean`: **REVIEW_READY**.

For every finite horizon, positive gross return, and path satisfying the original one-period
budget, it proves the exact discounted identity through date `T`. The terminal asset is
`R⁻¹ ^ T * a (T+1)`, with exponent `T`, not `T+1`. NP02 and NP03 remain unformalized. No GREEN
status or stage advancement is awarded.

## Proof route and scope

The gate-local proof in `Aiyagari1994/Analysis/M10A1/BudgetTelescope.lean` inducts on the finite
horizon. The successor calculation discounts the date-`T+1` budget and uses
`R⁻¹^(T+1) * R = R⁻¹^T`, canceling the previous terminal asset. The public module is a
thin theorem wrapper importing exactly the authorized helper.

The formal dependency is exactly P01 through `Aiyagari1994.Budget.Normalization`, which fixes the
original/shifted coordinate interpretation. The theorem starts from original assets directly. It
uses no IID law, natural floor, No-Ponzi premise, optimality, infinite convergence, integrability,
consumption positivity, or conclusion-like hypothesis.

## Source and verification boundary

The repository A93 PDF matches manifest SHA-256
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80` and 4,333,203 bytes; A94
matches `75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f` and 1,394,274 bytes.
Only the authorized pages were rendered and visually inspected: A93 printed 37/original PDF 38
contains Appendix Proposition 1 and its displayed finite identity; A94 printed 666/original PDF 9
note 16 states the present-value/borrowing-limit relationship. The explicit finite-sum induction
is a project reconstruction, not a proof attributed verbatim to either source.

The following fresh checks completed with exit status zero:

- `lake build Aiyagari1994.Analysis.M10A1.BudgetTelescope Aiyagari1994.Budget.NoPonzi`
- `lake env lean Probes/M10A1Signatures.lean`
- `lake build` (3143 jobs, including `All` and `Audit`)
- `lake env lean Audit.lean`
- `python3 tools/check_contracts.py` (57 contracts; 51 GREEN, 1 REVIEW_READY, 5 UNFORMALIZED)
- `bash tools/build_docs.sh proof_ledger` (76-page PDF)
- `git diff --check`, the targeted prohibited-pattern scan, and the baseline contract-field check

Both new declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage in the gate
probe and global audit. Both axiom prints contain only `propext`, `Classical.choice`, and
`Quot.sound`. Baseline comparison confirms that the sole contract-field change is NP01
`status: UNFORMALIZED -> REVIEW_READY`; assumptions, dependency, scope, source fields, notes, and
every other contract remain unchanged.

The synchronized ledger hashes are Markdown
`8d5d2589db7948bc8078a151ab8b75a29122f545920a45e52e6fe82a8a3d2385`, TeX
`31ab85ad1c888edb7c957b2b726f5beddd06a80d46166a7762a06bdd466d21dc`, and PDF
`81aeddf03c15e93ba22f9216959b03da2523f3d9a8bb8f9d86534b4f4e0dc21f`. Rendered ledger pages 1
and 73--76 were visually inspected; the global status, historical G08 wording, NP01 entry, and
unchanged later-contract boundaries are legible without clipping or overlap.

The controller owns review archives, so no manual ZIP is created. Independent adequacy review is
requested for NP01 only.

REVIEW_CONTEXT_COMPLETE: NP01 implementation, D01–D20 analytical audit, exact signature probe,
global audit coverage, frozen contract metadata with status-only transition, source verification,
and synchronized ledger Markdown/TeX/PDF are present for controller verification and independent
review.
