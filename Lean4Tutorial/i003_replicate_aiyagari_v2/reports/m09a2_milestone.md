# Milestone report: M09A2 / G01 stationary-equilibrium definition

Date: 2026-10-04. Assigned gate: M09A2. Assigned contract: G01 only. Accepted baseline:
`543ea531971cfb93731443fcbe9c0025de6563a7`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, evidence, inventories, logs, and review archives were not
edited.

## Result

G01, `Aiyagari1994.equilibrium_resource_asset_iff` in
`Aiyagari1994/Equilibrium/Definition.lean`: **REVIEW_READY**.

The equilibrium core is noncircular and valid on the full domain `r>-delta`. Its witness supplies
the invariant candidate probability law, finite resource and net-asset first moments, and capital
clearing. It includes accepted F01 optimization, H05 lifetime optimality, S01's actual household
kernel, P01's exact price/budget normalization, finite-history IID and labor mean one. No strict
impatience or upper-rate restriction appears.

The theorem proves exact equivalence of resource-law stationarity and the induced net-asset/current-
labor product-law formulation by A01. Predetermined assets are paired with a fresh labor draw; no
independence of contemporaneous saving and contemporaneous labor is asserted.

Only G01's contract status changed. F02, G02--G08, A04--A05, Stage 10, and all other unassigned
contracts remain unchanged. No GREEN status or stage advancement is awarded.

## Verification and review boundary

The dedicated signature probe, full `lake build`, global `Audit.lean` run, structural contract
check, prohibited-pattern scan and diff-whitespace check completed successfully. Every new public
declaration is audited with `#check`, `assert_no_sorry`, and `#print axioms`; the printed
transitive axiom set is exactly `propext`, `Classical.choice`, and `Quot.sound`.

The Markdown ledger regenerated deterministically to TeX and a 67-page PDF. Pages 61--65,
including the complete G01 entry and both transitions to untouched neighboring contracts, were
rendered and visually inspected with no clipping, overlap, broken glyph, or header/footer defect.
The PDF SHA-256 is `5c878831d084d598891b2363af9afee783a8482456c7740cdc422659de4cd54e`.
The controller owns verification logs, evidence, export inventories, and review archives; no
manual archive is created. Independent adequacy review is requested for G01 only. Stop at
REVIEW_READY.
