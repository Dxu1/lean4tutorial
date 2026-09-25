# Milestone M04C - uniform upper drift

Date: 2026-09-25. Accepted baseline: `e996bd1a2e732d834f9eea0cd94ca040d35b5f61`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: D03 only.

## Result against the contract

D03, `Aiyagari1994.uniform_upper_drift` in `Aiyagari1994/Household/UpperDrift.lean`: **REVIEW_READY**. For any specified set of admissible normalized prices satisfying the explicit LOCAL_IMPATIENT bounds, it constructs one common finite `B>0`. Every price has `e_max<=B`; its maximal next resource satisfies `R*A_q(z)+e_max<=z` for `z>=B`; and `[e_min,B]` is forward invariant. No other contract field or status changed.

## Proof route and changes

The authorized helper module `Aiyagari1994/Analysis/M04C/DriftBounds.lean` provides endpoint-income order, the large-`C` limit choice, the uniform large-state consumption lemma, and the single-price crossing argument. D02 controls marginal-utility ratios; H07 controls policy order and consumption differences; H08, H10, and the positive-state envelope identity yield the common consumption threshold; H12 supplies the integrable interior Euler equality. The family-level wrapper chooses explicit common `L`, `K`, and `B` from the neighborhood bounds and derives invariance by monotonicity.

The proof never selects pointwise caps continuously and never infers finite-time entry from weak drift. All marginal-value arguments are restricted to positive resource states.

## Verification evidence

The focused helper and target files kernel-check. `All.lean`, `Audit.lean`, and `Probes/M04CSignatures.lean` include the new module and required declaration audits. All nine public declarations are covered by `#check`, `assert_no_sorry`, and `#print axioms`; their only transitive axioms are `propext`, `Classical.choice`, and `Quot.sound`.

The synchronized Markdown and TeX ledgers record D03 as REVIEW_READY and preserve the exact no-finite-time-entry qualification. The PDF rebuilt successfully at 48 pages with no overfull boxes, undefined references, or LaTeX errors. Ledger pages 33-36 were rendered at 130 DPI; the complete D03 entry on page 34 and its transitions from D02 and to S01 were visually inspected with no clipping, overlap, broken glyphs, or footer collision. The controller owns verification logs, evidence inventories, and review archives; no orchestration state or manual ZIP was created.

## Adequacy and review boundary

All 168 supplied predecessor entries remain mandatory and unsuperseded. The maintained bounded-utility, continuous-resource, general compact iid-income model is unchanged. D03 proves no stationary law, stationary marginal integrability, tightness, convergence, asset supply, or equilibrium conclusion. Historical source and PDF-review limitations retain their original gate attribution.

No implementation blocker remains. D03 stops at REVIEW_READY for independent adequacy review. No GREEN status or advancement beyond M04C is claimed.
