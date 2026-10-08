# Milestone report: M09C4 / G05 certainty benchmark verified

Date: 2026-10-07. Assigned gate: M09C4. Assigned contract: G05 only. Accepted baseline:
`47a156ee77f8d9e283a8a5247c29c1ef3b6f224c`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G05, `Aiyagari1994.certainty_benchmark_verified` in
`Aiyagari1994/Equilibrium/CertaintyBenchmark.lean`: **REVIEW_READY**.

The theorem constructs the deterministic mean-one benchmark at
`lambda=1/beta-1`, uses F01 to obtain positive `K(lambda)` and wages, proves positive stationary
consumption, and verifies the constant allocation globally against every admitted measurable
full-history feasible plan. Only G05's status changed. No GREEN status, G06--G08 result, Stage-10
result, or stage advancement is awarded.

## Proof route and exact dependencies

Beta positivity and strict discounting imply `lambda>0`, hence `lambda>-delta`. F01 constructs
`K>0`, `w>0`, and `f'(K)=lambda+delta`. The wage definition gives
`cFI=f(K)-delta*K=w+lambda*K>0`.

The benchmark uses a genuinely degenerate labor-one law. For every nonnegative certainty debt
shift satisfying `lambda*phi<=w`, it constructs the corresponding certainty prices and proves
that shifted saving `K+phi` represents positive original assets `K`, is borrowing-feasible, and
has the correct initial resource identity. This interface contains both the finite certainty cap
`min(b,w/lambda)` and the natural certainty limit `w/lambda`; no risky minimum labor enters.

For every admitted feasible plan, the proof derives the exact finite discounted budget
`sum_{t=0}^N beta^t(c_t-cFI)=beta^N(astar-a_N)`. Nonnegative shifted actions bound the right side
by `beta^N astar`. The global utility supporting line at positive `cFI`, followed by the justified
finite-utility limit, proves lifetime dominance of the constant plan. H05 then identifies this
plan's lifetime utility with the value function by comparison with the canonical plan. P01 is
used for the original/shifted initial-budget statement; it is not treated as No-Ponzi.

Thus the exact contract dependencies are P01, H05, and F01. No A04/A05/G04 theorem, critical
stationary law, risky equilibrium existence, or Stage-10 no-Ponzi result is used.

## Verification and review boundary

The helper and wrapper build successfully. The gate signature probe and global audit cover every
new public declaration with `#check`, `assert_no_sorry`, and `#print axioms`; the reported axioms
are only `propext`, `Classical.choice`, and `Quot.sound`. The synchronized ledger is rebuilt from
Markdown into TeX and PDF.

A94 printed pp. 670--671 / PDF pp. 13--14 supplies the approved certainty and factor-pricing
motivation. The global present-value/supporting-line verification is explicitly a project
reconstruction. The controller owns review archives, so no manual ZIP is created. Independent
adequacy review is requested for G05 only. Stop at REVIEW_READY.
