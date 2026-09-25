# Milestone M05D - compact monotone--Feller stability

Date: 2026-09-25. Accepted baseline: `e88a8734d0a4d28640797ab4d40061ef139fad64`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: S04 only.

## Result against the contract

S04, `Aiyagari1994.compact_monotone_feller_stability` in `Aiyagari1994/Analysis/MonotoneFeller.lean`: **REVIEW_READY**. For a monotone Feller Markov kernel on a nonempty compact real interval and a positive common-horizon crossing bound, it constructs the unique invariant probability law, proves weak convergence from every initial probability law, and exports the geometric endpoint oscillation bound. Only S04's contract status changed.

## Proof route and changes

`Aiyagari1994/Analysis/M05D/Determining.lean` proves that continuous increasing tests determine probability laws on a real interval and that convergence on this class implies weak convergence. The proof uses the Weierstrass polynomial approximation theorem; each polynomial is written as a difference of two increasing continuous functions by adding a sufficiently steep linear function.

`Aiyagari1994/Analysis/M05D/Stability.lean` defines the exact law and test operators. Compactness gives cluster laws for lower- and upper-endpoint orbits. Endpoint test integrals are monotone and bounded, so their full sequences converge; the determining result upgrades this to weak convergence. Feller continuity makes both limits invariant. Repeated crossing contracts endpoint oscillation by `(1-eps)^m`; this identifies the endpoint laws. A stochastic sandwich then gives weak convergence from every initial law, and a constant invariant orbit proves uniqueness.

The crossing premise is stated in the architecture's displayed test-function form. This is an API adaptation, not a semantic strengthening of the conclusion. S05 must still derive it from S03's event crossing and S01's monotonicity. No economic assumption, global `NNReal` stability, moment convergence, or equilibrium assertion enters S04.

## Verification evidence

`lake build Aiyagari1994.Analysis.MonotoneFeller`, `lake build`, `lake env lean Audit.lean`, `lake env lean Probes/M05DSignatures.lean`, `python3 tools/check_contracts.py`, and `bash tools/build_docs.sh proof_ledger` exited 0. The assigned Lean-file prohibited-pattern scan returned clean, and `git diff --check -- .` exited 0. The contract checker reports 23 GREEN, one REVIEW_READY, and 33 UNFORMALIZED contracts, with the dependency graph acyclic.

All eight public declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage in both audit files. Each reports exactly `propext`, `Classical.choice`, and `Quot.sound`. The documentation build produced the synchronized 52-page `docs/proof_ledger.pdf` with no overfull boxes, undefined references, or LaTeX errors. Ledger pages 39-40 were rendered with Ghostscript and visually inspected; the S04 status, signature, proof, public-declaration inventory, audit, adequacy note, and transition to S05 are legible without clipping or overlap.

The controller owns verification logs, export inventories, evidence, and review archives; no orchestration state or manual ZIP was created.

## Adequacy audit

The theorem's hypotheses are nonvacuous generic inputs: `a≤b`, a Markov kernel, Feller continuity, monotonicity on increasing bounded-continuous tests, `N≥1`, and `0<eps≤1` with common-horizon crossing. No invariant-law existence or convergence assumption is hidden in a structure. S04 uses no marginal-value expression or economic real-valued expectation, so inherited zero-boundary and integrability qualifications remain unchanged. All integrals are of bounded-continuous tests under probability laws. Convergence is weak only; total variation and moment convergence are not claimed. S05, S06, and all stationary asset-supply/equilibrium contracts remain unformalized.

## Blockers and review request

No implementation blocker remains. S04 stops at REVIEW_READY for independent adequacy review. S05 and every later contract remain unformalized; no GREEN status or advancement beyond M05D is claimed.
