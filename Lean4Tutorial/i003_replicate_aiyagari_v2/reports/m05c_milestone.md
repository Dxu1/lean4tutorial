# Milestone M05C - economic crossing condition

Date: 2026-09-25. Accepted baseline: `a8fc8731f435b95e4ceff705426ff6e994159d90`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: S03 only.

## Result against the contract

S03, `Aiyagari1994.economic_crossing_condition` in `Aiyagari1994/Stationary/Crossing.lean`: **REVIEW_READY**. On a supplied forward-invariant interval `[e_min,B]`, the theorem constructs an interior effective-income midpoint `d`, a common horizon `N≥1`, and `ε>0` giving both contracted endpoint-crossing inequalities for the actual policy kernel. Only S03's contract status changed.

## Proof route and changes

`Aiyagari1994/Analysis/M05C/Crossing.lean` contains the authorized helper proof. S02 convergence selects a horizon where the minimum-shock path from `B` is below `d`. Finite-path continuity enlarges the minimum shock to a neighborhood; state and shock monotonicity then make `N` low-neighborhood shocks sufficient. Kernel composition gives probability at least `pLow^N`. For the opposite direction, invariant support holds through the first `N-1` steps and a final upper-neighborhood shock crosses `d` with probability at least `pHigh`. The common bound is `min (pLow^N) pHigh`.

The implementation states D03's needed price-specific consequences explicitly: `upperEffectiveIncome m ≤ B` and pointwise forward invariance. This is an API adaptation, not a semantic change. It uses no endpoint atom, density, upper fixed-point uniqueness, or source drawing.

## Verification evidence

`lake build Aiyagari1994.Stationary.Crossing`, `lake build`, `lake env lean Audit.lean`, `lake env lean Probes/M05CSignatures.lean`, and `python3 tools/check_contracts.py` exited 0. The assigned Lean-file prohibited-pattern scan returned clean, and `git diff --check -- .` exited 0. Comparison with accepted baseline `a8fc8731f435b95e4ceff705426ff6e994159d90` confirms that S03's `status` is the only changed contract field.

All three public declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage in both audit files. Each reports exactly `propext`, `Classical.choice`, and `Quot.sound`. `bash tools/build_docs.sh proof_ledger` exited 0 and produced the synchronized 51-page `docs/proof_ledger.pdf` with no overfull boxes, undefined references, or LaTeX errors. Ledger pages 37-39 were rendered with Poppler and visually inspected; the S03 heading, exact signature, complete proof, audit, adequacy note, and transition to S04 are legible without clipping or overlap.

The controller owns verification logs, export inventories, evidence, and review archives; no orchestration state or manual ZIP was created.

## Adequacy audit

NONDEGENERATE is used only for distinct endpoints and positive mass of relative endpoint neighborhoods. IID is represented by finite kernel powers. S03 introduces no marginal-value expression or real-valued expected quantity, so the inherited zero-boundary and integrability qualifications are unchanged. The theorem retains continuous resources and the general compact iid labor law. It proves crossing only, not mixing, invariant-law existence or uniqueness, distributional or moment convergence, asset supply, or equilibrium. Every supplied predecessor qualification remains mandatory and unsuperseded.

## Blockers and review request

No implementation blocker remains. S03 stops at REVIEW_READY for independent adequacy review. S04 and every later contract remain unformalized; no GREEN status or advancement beyond M05C is claimed.
