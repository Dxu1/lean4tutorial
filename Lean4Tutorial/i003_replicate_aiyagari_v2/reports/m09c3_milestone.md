# Milestone report: M09C3 / G04 every equilibrium rate below impatience

Date: 2026-10-07. Assigned gate: M09C3. Assigned contract: G04 only. Accepted baseline:
`cc18fdf59aebfa811d64941ab0c6b58340b46259`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G04, `Aiyagari1994.every_equilibrium_rate_below_impatience` in
`Aiyagari1994/Equilibrium/MainTheorem.lean`: **REVIEW_READY**.

The theorem quantifies over every witness of the accepted unrestricted G01
`StationaryEquilibrium p hp` type. It derives `e.rate < 1 / e.household.beta - 1` from that
witness's actual invariant resource probability law. It does not use the G02 or G03 existence
witnesses and does not assume a rate upper bound through an equilibrium field.

Only G04's contract status changed. All predecessor statuses and every other contract field are
unchanged. No GREEN status, G05--G08 result, checkpoint, or stage advancement is awarded.

## Proof route

`StationaryEquilibrium` extends `EquilibriumCore` only by `resource_stationary`. Applying
`ProbabilityMeasure.toMeasure` to this equality identifies the actual equilibrium resource law as
an invariant probability measure for `householdKernel e.household`. If
`1 <= e.household.beta * e.household.prices.grossReturn`, N07 excludes precisely that law, a
contradiction. Hence the product is strictly below one.

The G01 normalization fields give
`e.household.prices.grossReturn = e.originalPrices.normalized.grossReturn =
1 + e.originalPrices.netRate = 1 + e.rate`. Positivity of beta then converts the product inequality
to `e.rate < 1 / e.household.beta - 1`.

The controller-supplied accepted G01 evidence records source SHA-256
`11fc757624ffbc386ac2f0d11d80f86af316e43e41a2c26a18744c8730238969` and the exact accepted
signature
`equilibrium_resource_asset_iff (e : EquilibriumCore p hp) : resourceLawForm e ↔
assetLaborLawForm e`. The proof uses that unchanged equilibrium-definition source and its
`StationaryEquilibrium` record, not either direction of the bridge theorem.

## Verification and review boundary

Focused builds of the helper and wrapper, the M09C3 signature probe, the full project, and the
global audit succeeded. Both new public declarations have `#check`, `assert_no_sorry`, and
`#print axioms` coverage in `Probes/M09C3Signatures.lean` and `Audit.lean`; only `propext`,
`Classical.choice`, and `Quot.sound` were reported. The synchronized ledger was rebuilt from
Markdown into TeX and PDF.

A94 printed pp. 670--671 / PDF pp. 13--14 supplies the approved general-equilibrium motivation;
the direct contradiction using the exact Lean equilibrium record and N07 is a project
reconstruction. The controller owns review archives, so no manual ZIP is created. Independent
adequacy review is requested for G04 only. Stop at REVIEW_READY.
