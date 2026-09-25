# Milestone M05A - household transition kernel

Date: 2026-09-25. Accepted baseline: `02e0c9f7f35c17c0ec34f81012a829cf611e3af0`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: S01 only.

## Result against the contract

S01, `Aiyagari1994.householdKernel_feller_monotone` in `Aiyagari1994/Stationary/Kernel.lean`: **REVIEW_READY**. The constructed `householdKernel` is the pushforward of the general labor probability law under `l ↦ R*A(z)+e(l)`. It is a Markov kernel; bounded-continuous transition expectations vary continuously in current resources; increasing bounded-continuous tests have increasing transition expectations; and the exact change-of-variables formula is proved for every measurable real test. Only S01's status changed.

## Proof route and changes

The authorized helper `Aiyagari1994/Analysis/M05A/KernelTransition.lean` proves joint continuity of the household transition from H04's policy continuity and the affine transition formula. The core kernel is obtained by taking the product of the identity Dirac kernel and the constant labor-law kernel, then mapping through this joint transition. Standard Markov instances prove probability mass one. The product-kernel and measure-map identities give the test-function formula. Dominated continuity proves the Feller property, using the norm bound of a bounded continuous test. H07 orders optimal shifted assets; positivity of the gross return orders next resources under a common labor draw, and integral monotonicity proves the stochastic-order conclusion.

The integral formula is stated for all measurable real tests, which is an API-level strengthening of the contracted bounded-measurable formula and changes no economic assumption. Stochastic monotonicity is deliberately stated for bounded continuous increasing tests, the weak-order class used by the approved architecture.

## Verification evidence

`lake build Aiyagari1994.Stationary.Kernel`, `lake build`, `lake env lean Audit.lean`, `lake env lean Probes/M05ASignatures.lean`, `python3 tools/check_contracts.py`, and `git diff --check -- .` all exited 0. The assigned Lean-file prohibited-pattern scan returned no hit. `All.lean` imports the new core module. `Audit.lean` and the signature probe cover all six new public declarations with `#check`, `assert_no_sorry`, and `#print axioms`; the transitive axiom union is `propext`, `Classical.choice`, and `Quot.sound`.

The synchronized Markdown and generated TeX ledgers record only S01 as REVIEW_READY. `bash tools/build_docs.sh proof_ledger` exited 0 and produced a 49-page PDF with no overfull boxes, undefined references, or LaTeX errors. Pages 35–36 were rendered and visually inspected: the full S01 entry, audit continuation, headers, footers, equations, and transition to S02 are legible without clipping or overlap. The controller owns verification logs, export inventories, evidence, and review archives; no orchestration state or manual ZIP was created.

## Adequacy and review boundary

All 201 supplied predecessor entries remain mandatory and unsuperseded. The proof keeps continuous resources and the general compactly supported iid labor law; the finite P03 witness is not used. H07 is used only for weak policy monotonicity, without policy differentiability or strict order. No marginal-value object is used, so `zeroRightMarginal` is not conflated with `rightMarginalValue m 0`. S01 proves no crossing, invariant distribution, convergence, moment, asset-supply, or equilibrium result.

No implementation blocker remains. S01 stops at REVIEW_READY for independent adequacy review. S02 and every later contract remain unformalized; no GREEN status or advancement beyond M05A is claimed.
