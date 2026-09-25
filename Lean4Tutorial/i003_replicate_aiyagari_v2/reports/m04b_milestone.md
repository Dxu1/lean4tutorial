# Milestone M04B - marginal-utility ratio bound

Date: 2026-09-25. Accepted baseline: `101729ceb06b1df41800ed7e0b9382072f99ab8c`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: D02 only.

## Results against the contract

D02, `Aiyagari1994.marginalUtility_ratio_bound` in `Aiyagari1994/Analysis/Curvature.lean`: **REVIEW_READY**. For any BASIC household whose utility satisfies SMOOTH and CURVATURE, it constructs a positive integer `n` and positive threshold `C` such that

`U'(c₁) / U'(c₂) ≤ (c₂ / c₁)^n`

whenever `C ≤ c₁ ≤ c₂`. The result depends only on primitive mathematics and installed Mathlib. No other contract status or field changed. D03 and all later contracts remain UNFORMALIZED.

## Proof route and changes

The helper `power_mul_deriv_monotoneOn`, confined to the authorized directory `Aiyagari1994/Analysis/M04B/`, chooses `n > max M 0` from the eventual RRA bound. Since SMOOTH gives `U'(c)>0`, the curvature inequality implies `n U'(c)+c U''(c)≥0`. CURVATURE's positive-tail `C²` regularity justifies differentiating `c^n U'(c)`, whose derivative is

`c^(n-1) * (n*U'(c) + c*U''(c)) ≥ 0`.

Thus `c^n U'(c)` is nondecreasing on the closed positive tail. Applying this at `c₁≤c₂` and dividing by positive quantities yields the contracted ratio. This exactly follows the supplied Architecture §6.2 plan; there is no semantic design change. The only local API adaptation is an explicit passage from `ContDiffOn` on the open positive set to pointwise differentiability using the neighborhood `Ioi 0`.

## Verification evidence

The focused build and signature audit completed successfully:

- `lake build Aiyagari1994.Analysis.Curvature Probes.M04BSignatures` exited 0 after 2,648 jobs.
- Both new public declarations passed `#check`, `assert_no_sorry`, and `#print axioms`; their transitive axioms are exactly `propext`, `Classical.choice`, and `Quot.sound`.

- `lake build All` exited 0 after 2,810 jobs, and `lake env lean Audit.lean` exited 0 with both declarations covered by the required three audit commands.
- `lake build` exited 0 after 2,813 jobs. Existing linter suggestions in predecessor files are non-errors; the new D02 files emit none.
- `python3 tools/check_contracts.py` exited 0: 57 contracts, 18 GREEN, D02 as the sole REVIEW_READY contract, and 38 UNFORMALIZED.
- `git diff --check` and the prohibited-pattern scan over the new Lean and probe files exited 0.
- `bash tools/build_docs.sh proof_ledger` exited 0 and rebuilt the synchronized 48-page `docs/proof_ledger.pdf`. There are no overfull boxes, undefined references, or LaTeX errors; historical underfull-box warnings remain.
- Ledger PDF pages 32-34 were rendered at 130 DPI and visually inspected. The D02 status, exact statement, signature, assumptions, equations, proof, audit, and transition to unchanged D03 are readable with no clipping, overlap, broken glyph, or footer collision.

The controller owns verification logs and review archives; no orchestration state or manual ZIP was created by the executor.

## Adequacy audit

All 138 supplied predecessor entries remain mandatory and unsuperseded. The theorem is restricted to strictly positive consumption and does not use or identify `rightMarginalValue m 0`; the economic zero-boundary object remains `zeroRightMarginal : ENNReal`. It forms no integral or expectation and does not narrow the general compact iid labor law. It proves no drift, invariant interval, finite-time entry, stationary law, tightness, asset supply, or equilibrium conclusion. Full details are in `reports/m04b_analytical_audit.md` and the synchronized proof ledger.

The authorized source locator is A93 Appendix Proposition 4, printed pp. 38–39 / PDF pp. 39–40, and SE77 Theorems 3.8–3.9, printed pp. 161–162 / PDF pp. 11–12. The pages were not re-inspected for this gate; correspondence uses the supplied capsule and authoritative Architecture §6.2 extract.

## Blockers and review request

No implementation blocker remains. D02 is submitted at REVIEW_READY for independent adequacy review. No GREEN status is claimed, and this capsule authorizes no advancement beyond M04B.
