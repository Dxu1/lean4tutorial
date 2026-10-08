# Milestone report: M09C2 / A05 risky assets above certainty near impatience

Date: 2026-10-07. Assigned gate: M09C2. Assigned contract: A05 only. Accepted baseline:
`8a7f4e7370fa21c4db9644aa54c654ad579e9d01`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

A05, `Aiyagari1994.risky_assets_above_certainty_near_impatience` in
`Aiyagari1994/Aggregate/CertaintyComparison.lean`: **REVIEW_READY**.

At fixed positive wage, the theorem covers every strictly impatient finite-cap rate, including the
nonpositive branch, and every strictly impatient positive natural-limit rate. It compares risky
stationary net assets with the actual A04 certainty stationary integral at risky mean labor and
proves strict comparison throughout a one-sided neighborhood of the impatience boundary for both
families.

Only A05's contract status changed. All predecessor statuses and every other contract field are
unchanged. No GREEN status, later gate, checkpoint, or stage advancement is awarded.

## Proof route

The risky labor floor is at most its integral mean. P02's two debt rules then give
`phiRisk<=phiCertainty`, with a separate nonpositive finite-cap branch. A02 supplies integrability
and `S_risky=E[A]-phiRisk`; nonnegative shifted saving yields the weak comparison. A04 identifies
the separately constructed certainty stationary integral with `-phiCertainty`.

For strictness, the proof works in pulled-back rate-neighborhood filters at
`lambda=1/beta-1`. Every sequence converging in either filter generates the actual fixed-wage
normalized price family and convergent finite shifts. B02 sends risky supply to `+infinity`.
Thus risky assets are positive for all sufficiently close rates, whereas certainty assets remain
nonpositive.

## Verification and review boundary

Focused builds of the helper, wrapper, signature probe, and global audit succeeded. Every one of
the thirteen new public declarations has `#check`, `assert_no_sorry`, and `#print axioms` coverage
in `Probes/M09C2Signatures.lean` and `Audit.lean`; only `propext`, `Classical.choice`, and
`Quot.sound` were reported. The synchronized ledger is rebuilt from Markdown into TeX and PDF.

A94 printed pp. 669-671 / PDF pp. 12-14 is the approved motivating locator. The full formal proof
is described as project reconstruction. The controller owns review archives, so no manual ZIP is
created. Independent adequacy review is requested for A05 only. Stop at REVIEW_READY.
