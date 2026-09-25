# Milestone M05B - lower transition iterates

Date: 2026-09-25. Accepted baseline: `e7114e926dea1d4717ad095e664c3c18d54630ca`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: S02 only.

## Result against the contract

S02, `Aiyagari1994.lower_transition_iterates_tendsto` in `Aiyagari1994/Stationary/LowerTransition.lean`: **REVIEW_READY**. Under BASIC, SMOOTH, and `beta*R<1`, the primitive-derived least-shock transition fixes least effective income, lies strictly below every larger resource state, and has antitone iterates converging to least effective income from every finite upper state. Only S02's status changed.

## Proof route and changes

`Aiyagari1994/Analysis/M05B/LowerTransition.lean` contains the authorized helper infrastructure: least effective income, the least-shock transition, continuity, and its primitive lower bound. The core proof uses H12's positive-saving Euler equality and its integrability certificate. H10 gives positive consumption; H11 and H08 identify and order positive-state marginals. Failure of strict downward drift would bound every next marginal by the current positive marginal, contradicting the Euler equality under `beta*R<1`. Zero saving makes the transition equal the endpoint. Endpoint fixation follows by splitting the zero and positive endpoint cases. The iterates are decreasing and bounded below; continuity makes their limit a fixed point, and strict drift uniquely identifies it.

The implementation does not use policy monotonicity, an invariant interval, an assumed absorbing bound, a density, endpoint mass, finite labor support, or nondegeneracy. This is a local API simplification relative to the prose architecture and changes no semantics.

## Verification evidence

`lake build Aiyagari1994.Stationary.LowerTransition`, `lake build`, `lake env lean Audit.lean`, `lake env lean Probes/M05BSignatures.lean`, and `python3 tools/check_contracts.py` exited 0. The assigned Lean-file prohibited-pattern scan returned no prohibited declaration or bypass, and `git diff --check -- .` exited 0. A baseline comparison confirmed that S02's `status` is the only changed contract field. All six new public declarations pass `#check`, `assert_no_sorry`, and `#print axioms`; their transitive axiom union is `propext`, `Classical.choice`, and `Quot.sound`.

`bash tools/build_docs.sh proof_ledger` exited 0 and produced the synchronized 50-page `docs/proof_ledger.pdf` with no overfull boxes, undefined references, or LaTeX errors. Ledger pages 36-37 were rendered and visually inspected: the complete S02 entry, exact signature, readable proof, audit, and transition to S03 are legible without clipping or overlap. The controller owns verification logs, export inventories, evidence, and review archives; no orchestration state or manual ZIP was created.

## Adequacy audit

The zero boundary is handled by `assetPolicy_zero`; `rightMarginalValue m 0` is never used. Ordinary real marginal integrals occur only in H12's positive-saving branch with its proved integrability. The theorem retains continuous resources and the general compact iid labor law. Its convergence is deterministic iteration of `h_min`; it proves no kernel mixing, invariant law, moment convergence, asset-supply result, or equilibrium claim. All supplied predecessor qualifications remain mandatory and unsuperseded.

## Blockers and review request

No implementation blocker remains. S02 stops at REVIEW_READY for independent adequacy review. S03 and every later contract remain unformalized; no GREEN status or advancement beyond M05B is claimed.
