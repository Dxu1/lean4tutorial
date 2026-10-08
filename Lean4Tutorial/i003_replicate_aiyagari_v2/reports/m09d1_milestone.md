# Milestone report: M09D1 / G06 equilibrium capital above certainty

Date: 2026-10-08. Assigned gate: M09D1. Assigned contract: G06 only. Accepted baseline:
`a0467e651f14717f4b5d3b6caa93cc97e566ad13`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G06, `Aiyagari1994.equilibrium_capital_above_certainty` in
`Aiyagari1994/Equilibrium/MainTheorem.lean`: **REVIEW_READY**.

For every unrestricted stationary equilibrium, the theorem returns the certified certainty
firm rate `rFI=lambda`, identifies certainty capital as `capitalDemand(rFI)`, and proves it is
strictly below the equilibrium's actual cleared net-capital integral. Only G06's status changed.
No GREEN status, G07/G08 result, Stage-10 result, or stage advancement is awarded.

## Proof route and exact dependencies

G05 supplies `rFI : FirmRate p` with real value `lambda=1/beta-1`. G04 supplies
`e.rate<lambda` for the arbitrary equilibrium. F01's strict antitonicity of capital demand then
gives `K(lambda)<K(e.rate)` in the correct orientation. The accepted G01 capital-clearing field
rewrites `K(e.rate)` as the equilibrium's actual integral of net assets.

Thus the exact dependencies are F01, G04, and G05. The proof uses no G02/G03 witness restriction,
A05 comparison, N07 reproof, positive-rate or uniqueness claim, asset-supply monotonicity, or
G07/G08 argument.

## Verification and review boundary

The gate-owned helper and extended public wrapper build successfully. The M09D1 signature probe
and global audit cover both new declarations with `#check`, `assert_no_sorry`, and
`#print axioms`; the reported axioms are only `propext`, `Classical.choice`, and `Quot.sound`.
The synchronized ledger is rebuilt from Markdown into TeX and PDF.

A94 printed pp. 670--671 / original PDF pp. 13--14 supplies the approved comparison motivation.
The exact proof is a project reconstruction. The controller owns review archives, so no manual
ZIP is created. Independent adequacy review is requested for G06 only. Stop at REVIEW_READY.

REVIEW_CONTEXT_COMPLETE: G06 implementation, analytical audit, exact signature probe, global
audit coverage, frozen contract metadata with status-only transition, and synchronized ledger
Markdown/TeX/PDF are present for controller verification and independent review.
