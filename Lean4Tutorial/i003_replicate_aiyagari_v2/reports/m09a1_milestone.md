# Milestone report: M09A1 / F01 neoclassical firms

Date: 2026-10-04. Assigned gate: M09A1. Assigned contract: F01 only. Accepted baseline:
`82871353edc06308220d12665b236517f55edcd1`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, evidence, inventories, logs, and review archives were not
edited.

## Result

F01, `Aiyagari1994.capitalDemand_wage_constructed` in
`Aiyagari1994/Firms/Neoclassical.lean`: **REVIEW_READY**.

The contract module contains the F01 wrapper; all supporting declarations and witnesses are in
the capsule helper directory `Aiyagari1994/Analysis/M09A1/`.

The implementation constructs demand for every `r>-delta`, proves the unique marginal-product
solution, global unique profit maximization over all nonnegative capital ratios, wage positivity,
continuity of demand and wage, and strict decrease of demand. The general theorem assumes no
demand/wage schedules and is not restricted to the square-root case.

Separately, `sqrtProduction_regular` verifies `f(K)=sqrt(K)`, `delta=1/2` as a full production
witness. `fullEquilibriumPrimitives_nonempty` combines it with accepted P03 to prove nonemptiness
of the household-plus-production primitive package. P03 is not a dependency of the general firm
theorem.

Only F01's contract status changed. F02, G01--G08, A04--A05, Stage 10, and all other unassigned
contracts remain unchanged. No GREEN status or stage advancement is awarded.

## Proof route and scope

The proof derives strict decline of marginal product from C2 smoothness and negative second
derivative. The Inada and infinity limits bracket each positive target, IVT supplies a root, and
strict decline proves uniqueness. Demand continuity is proved through its surjective antitone
inverse on positive capital. Strict concavity then yields both global strict profit comparison and
the positive wage inequality against the secant from zero.

No household admissibility, stationarity constructor, asset-supply result, equilibrium existence,
average-product decay premise, later-economic prerequisite, or numerical model enters F01. All
predecessor qualifications remain operative.

## Verification and review boundary

The dedicated signature probe, full `lake build`, and global `Audit.lean` run completed
successfully. Every new public declaration has `#check`, `assert_no_sorry`, and `#print axioms`
coverage, with only `propext`, `Classical.choice`, and `Quot.sound` printed. Contract checking
passes for 57 contracts with 39 GREEN, 1 REVIEW_READY, and 17 UNFORMALIZED. The prohibited-pattern
and diff-whitespace checks pass.

The Markdown ledger regenerated deterministically to TeX and a 67-page PDF. Pages 1 and 60--62,
covering the global status, complete F01 entry, and transition to untouched later contracts, were
rendered and visually inspected with no clipping, overlap, broken glyph, or header/footer defect.
The PDF SHA-256 is `5f30271b6c787b7070202565a59842de6e78370c08c103b1ef9ba4e2b0986f29`.

The controller owns verification logs, evidence, export inventories, and review archives; no
manual archive was created. Independent adequacy review is requested for F01 only. Stop at
REVIEW_READY.
