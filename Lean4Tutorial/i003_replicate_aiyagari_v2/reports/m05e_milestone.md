# Milestone M05E report: S05 global stationary law

Date: 2026-09-25. Assigned gate: M05E. Assigned contract: S05 only.

## Results against the contract

S05, `Aiyagari1994.stationaryLaw_exists_unique_global` in `Aiyagari1994/Stationary/GlobalStability.lean`: **REVIEW_READY**. Under BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, and strict IMPATIENT assumptions, it constructs a finite resource bound `B` and a probability law `pi` on all `NNReal`. The law gives mass one to `[e_min,B]`, is invariant under `householdLawStep`, is the only invariant full-space probability law without any moment or support premise, and attracts every initial probability law weakly.

Only S05's contract status changed. S06 and later stationary aggregation and equilibrium contracts remain unformalized.

## Proof route and changes

D03 is specialized to the actual singleton price vector. New helpers under `Aiyagari1994/Analysis/M05E/` build and verify the compact economic kernel, prove its equality with the exact restriction, convert S03's finite ENNReal crossing events to S04's real increasing-test interface, and embed compact laws into the full state space.

For `z>B`, the proof applies compact stability on `[e_min,max B z]`; maximal-shock weak drift proves that enlarged interval is invariant. The base invariant law, lifted into the enlarged interval, identifies its compact limit. For `z<e_min`, direct policy monotonicity proves one-step entry into `[e_min,B]`. Bounded-continuous pointwise convergence is integrated against an arbitrary initial probability law by dominated convergence. Full-space uniqueness follows because an invariant law's orbit is constant.

This is the Architecture section 7.2 route with an explicit projected-kernel API adapter. No mathematical assumption or source interpretation changed.

## Verification evidence

The substantive module build was run repeatedly during implementation, culminating in successful builds of `Aiyagari1994.Analysis.M05E.Global` and `Aiyagari1994.Stationary.GlobalStability`. The final verification command `lake build Probes.M05ESignatures All Audit && lake build` completed successfully (2,869 jobs in the whole-project build). The M05E signature probe and repository audit elaborated every requested check; all new declarations print only `propext`, `Classical.choice`, and `Quot.sound` as transitive axioms.

The prohibited-pattern scan over the M05E proof modules and signature probe found no occurrence of `sorry`, `admit`, project `axiom`, `native_decide`, `Lean.ofReduceBool`, or `unsafe`. `bash tools/build_docs.sh proof_ledger` rebuilt `docs/proof_ledger.pdf` successfully as a 53-page PDF. The S05 entry and its transition to unchanged S06 were visually inspected on rendered pages 40--42; no clipping, overlap, or illegible content was found.

Every new public declaration has `#check`, `assert_no_sorry`, and `#print axioms` coverage in `Audit.lean` and `Probes/M05ESignatures.lean`. No `sorry`, `admit`, project axiom, `native_decide`, `Lean.ofReduceBool`, unsafe bypass, or numerical model is used.

## Adequacy audit

The proof keeps the general compact iid labor law and continuous resource state. It introduces no atom, density, finite support, positive minimum income, finite moment, invariant-law, or convergence premise. All real integrals used for convergence are of bounded-continuous tests under probability laws. The result is weak convergence only and yields no unbounded moment convergence or total-variation convergence. Weak drift above `B` is used to make each initial-state-dependent enlarged interval invariant; it is not called finite-time absorption.

The predecessor qualifications on boundary marginals, lifetime interpretation, budgets, source scope, and prior verification remain unchanged. The M05E proof does not use marginal values at zero or assert stationary marginal integrability.

## Blockers and review request

No implementation blocker remains. Independent adequacy review is requested for S05 only. Stop at REVIEW_READY; do not advance to S06 or award GREEN.
