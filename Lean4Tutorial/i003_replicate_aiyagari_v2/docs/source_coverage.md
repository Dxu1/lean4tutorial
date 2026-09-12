# Source coverage and release scope

Every contracted target begins UNFORMALIZED. Deferred and excluded claims are not covered by a core build.

## A93-P1: Natural debt floor and no-Ponzi
**Scope:** core. **Contract IDs:** NP01, NP02, NP03.
Literal target with adaptedness and nonnegative, not zero, terminal limit made explicit.

## A93-P2: Bellman, optimal policy, concavity and continuity
**Scope:** core. **Contract IDs:** H01, H02, H03, H04, H05, H07, H11.
General continuous assets, iid bounded labor, bounded utility. Lifetime verification is added explicitly.

## A93-P2-STRICT: Strict policy increase above a binding threshold
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
Core contracts prove weak monotonicity and Lipschitz bounds only. Do not mark strict source prose covered.

## A93-P3: Binding interval under its stated alternatives
**Scope:** core. **Contract IDs:** H13.
Finite marginal at zero or positive minimum effective income.

## A93-P3-NOTE: Inada and zero minimum imply never binding
**Scope:** diagnostic. **Contract IDs:** H14, D01.
Unqualified note is challenged by an exact continuous-state counterexample. Atom-at-zero sufficient condition is separately proved.

## A93-P4: Finite upper resource bound under impatience and eventual RRA bound
**Scope:** core. **Contract IDs:** D02, D03.
Locally uniform strengthened bound; C2 analytic regularity explicitly declared. Does not imply finite-time absorption.

## A93-P5: Unique stable invariant law and parameter continuity
**Scope:** core. **Contract IDs:** S01, S02, S03, S04, S05, S06.
Mixing is derived from primitives. Stability means weak convergence.

## A94-AGGREGATE: Continuous stationary mean asset supply
**Scope:** core. **Contract IDs:** A01, A02, A03.
Resource law and asset/labor cross-section are linked; local common compact support supplies moment control.

## A94-CRITICAL: No stationary distribution at or above the impatience return
**Scope:** core. **Contract IDs:** N01, N02, N03, N04, N05, N06, N07.
Reconstructed proof using value marginals, bounded Jensen and two independent finite shock histories.

## A94-CERTAINTY-ASSETS: Certain-income stationary assets and qualified precautionary excess assets
**Scope:** core. **Contract IDs:** A04, A05.
At subcritical returns the deterministic stationary law is the borrowing-limit point mass. Compare the correct mean-income and risky borrowing limits; prove weak excess assets and strict excess sufficiently near the impatience boundary, without a global risk-order theorem.

## A94-PATHWISE: Almost-sure asset divergence along individual paths at/above the threshold
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
Not equivalent to absence of a stationary law. Supercritical and critical pathwise claims remain separately named targets.

## A94-UPPER-BOUNDARY: Mean asset supply diverges as r approaches lambda below
**Scope:** core. **Contract IDs:** B01, B02.
Clarida 1990 Proposition 2.4 supplies the target, not a proof. Proposed tightness argument closes it without an imported conclusion.

## A93-NATURAL-LOWER: Natural-limit mean supply tends to minus infinity as r tends to zero above
**Scope:** core. **Contract IDs:** B03.
Use normalized effective income; do not assume raw effective debt remains bounded.

## A94-EXISTENCE: Stationary equilibrium for finite and natural borrowing limits
**Scope:** core. **Contract IDs:** F01, F02, G01, G02, G03.
Fixed-cap lower bracket derived, not assumed. No uniqueness conclusion.

## A94-MAIN: Interest below time preference; capital and gross saving above certainty
**Scope:** core. **Contract IDs:** G04, G05, G06, G07, G08.
All equilibrium rates are allowed in the definition. Benchmark verification and gross-versus-net distinction explicit.

## A94-NONMONOTONE: Asset supply can be nonmonotone; multiple equilibria can occur
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
Permission for multiplicity is not a constructed witness. No arbitrary curves or calibrated-looking examples accepted.

## A94-BORROWING: Comparative statics of borrowing limits
**Scope:** extension. **Contract IDs:** E01, E02.
Only the two exact invariance/translation identities are contracted. Global monotonicity is not asserted.

## A94-RISK: Precautionary/risk-order comparative statics and Sibley/Miller links
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
No aggregate risk ordering follows from a household-policy order alone. Needs exact risk/utility/cross-sectional contracts.

## A94-DEBT: Government-debt neutrality under natural borrowing
**Scope:** extension. **Contract IDs:** E03.
Exact pure-exchange/tax-adjusted natural-limit correspondence, not fixed-cap neutrality.

## A94-MONEY: Monetary reinterpretation/existence of monetary equilibria
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
Different return and clearing conditions need their own contract. Not covered by the capital-economy existence theorem.

## A94-GROWTH: Growth normalization and endogenous-growth extensions
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
An Euler normalization identity does not extend bounded-utility stationarity to log/CRRA or endogenous growth.

## A94-CRRA: Log/CRRA continuous-state model
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
Not bounded above and below as required by this release. A separate weighted/unbounded-reward Bellman and stationarity track is needed.

## A94-PERSISTENCE: Persistent Markov labor shocks used in quantitative analysis
**Scope:** deferred. **Contract IDs:** No implementation contract in v1.
iid scalar-resource proof is not a proof for serially correlated income. No finite Markov numerical track.

## A94-NUMERICS: Calibrations, tables, figures, grids and numerical algorithms
**Scope:** excluded_by_user. **Contract IDs:** No implementation contract in v1.
Entirely outside scope; no numerical certification or solver development.

