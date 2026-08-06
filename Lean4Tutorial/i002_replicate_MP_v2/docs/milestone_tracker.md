# MP1994V2 milestone tracker

> **Active analytical proof roadmap:** **COMPLETE THROUGH M10.3**
>
> **Last completed milestone:** M10.3 - Endogenous creation, staged destruction,
> and equations (36)-(38) - **COMPLETE - GREEN**
>
> **Numerical replication:** **DEFERRED / OUTSIDE CORE LEAN**
>
> **Deferred analytical refinements:** Optional M5b existence foundation and
> equation (31)

The Markdown file is the source of truth. Status vocabulary:

- NOT STARTED
- IN PROGRESS
- BLOCKED
- BLOCKED - CUTOFF ORDERING
- READY FOR REVIEW
- PARTIAL - READY FOR REVIEW
- COMPLETE - GREEN
- COMPLETE - AMBER
- DEFERRED / OUTSIDE CORE LEAN

M0 through M4 are complete and green. M5 is complete and amber: uniqueness is
green, while existence remains conditional on an additional bracket. M5b is
an unstarted foundational refinement. M6 is complete and amber overall: stock
completion, equation (14), and full-state uniqueness are green, while
existence inherits M5's amber qualification. M7 is complete and green after
human mathematical/economic review. M8 is **COMPLETE - AMBER** after review on
2026-08-01: its analytic infrastructure is GREEN, while supplied differentiable
local paths cause the AMBER qualification. This is not inherited from M5.
That historical grade applies to the original supplied-path layer. M8b.1 and
M8b.2 now derive all four paths from a supplied regular reduced equilibrium;
the full Appendix package is **COMPLETE - GREEN** under Appendix matching and
IFT regularity and the explicitly stated sign conditions. Selecting the base
equilibrium from primitives remains separately qualified by M5's AMBER
existence result.

Section 5 equations (32)-(38) are **COMPLETE - GREEN**, conditional on a
supplied finite Markov equilibrium, current finite employment distribution,
next aggregate state, explicit one-period redraw and matching probabilities,
and `PaperMatchingIdentification` only for paper-facing equation (36). No
density premise or externally supplied creation/mass-bound premise enters the
full M10.3 capstone. The next state remains supplied rather than sampled;
general equilibrium existence and numerical simulation are not claimed.

## Milestones

| ID | Paper section and equations | Economic target | Expected key Lean declarations | Status | Adequacy grade | Dependencies | Blocker | Branch/commit or tag | Last review date | Next action |
|---|---|---|---|---|---|---|---|---|---|---|
| M0 | Sections 2-3; (1)-(7) | Primitives, layered assumptions, probability/matching definitions, and primitive value equilibrium | `Primitives`; four assumption bundles; `cdf`; meeting rates; `surplus`; `continuationTerm`; `ValueEquilibrium` | COMPLETE - GREEN | GREEN | None | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve the reviewed M0 interface while beginning M1 separately |
| M1 | Section 3, journal p. 401; (8) | Derive the surplus Bellman equation from (3)-(7) | continuation decomposition; `firm_share`; `surplus_flow_equation`; `surplus_bellman_of_probability`; `surplus_bellman` | COMPLETE - GREEN | GREEN | M0 complete | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve the reviewed conditional representation theorem |
| M2 | Section 3; reservation discussion and (12) | Surplus difference theorem, strict monotonicity, unique endogenous reservation threshold, and (12) | surplus difference; affinity; strict monotonicity; zero uniqueness; reservation theorem | COMPLETE - GREEN | GREEN | M1 | None | `issue2`; completion commit | 2026-07-29 (human mathematical/economic review) | Preserve M2 interfaces and design the measure-form continuation identity for M3 |
| M3 | Section 3; (9), (10), (13) | Measure-form continuation identity and derivation of job destruction and job creation | `expectedExcess`; `tailOptionValue`; `equation9`; `equation10`; `equation13`; JD/JC residual predicates; M3 capstone | COMPLETE - GREEN | GREEN | M2 | None | `issue2`; completion commit | 2026-07-30 (human mathematical/economic review) | Preserve the reviewed independent JD/JC theorem interfaces and neutral capstone module |
| M4 | Section 3; (10), (13), journal p. 402 | Reduced-equilibrium reconstruction and equivalence | `ReducedEquilibrium`; generic tail identity; `toReducedEquilibrium`; `toValueEquilibrium`; economic round trips; nonempty equivalence | COMPLETE - GREEN | GREEN | M3 | None | `issue2`; completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the representation interfaces and formulate the corrected continuity, endpoint, and crossing assumptions for M5 |
| M5 | Section 3; (10), (13), Figure 1, journal p. 402 | Existence and uniqueness of the static reduced equilibrium | expected-excess regularity; JD/JC slopes; `StaticExistenceAssumptions`; `ReducedEquilibrium.unique`; conditional unique existence; value-side economic uniqueness | COMPLETE - AMBER | Uniqueness: GREEN; existence: AMBER; overall: AMBER | M4 | Existence uses an added lower positive crossing condition not derived from primitive assumptions | `issue2`; completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the conditional theorem; see `docs/static_existence_foundation.md` for the M5b primitive upgrade path |
| M5b | Foundational refinement to Section 3 static existence | Replace the assumed lower crossing with a derived result | proposed matching-boundary bundle; upper-job profitability; `lower_crossing_of_matching_inada`; optional Cobb-Douglas certification | NOT STARTED | Target: upgrade existence from AMBER to GREEN under a strengthened general theorem or certified Cobb-Douglas specialization | M5 | `q` Inada alone is insufficient; JD-implied tightness must become positive through a separate profitability condition | - | - | Add right-hand Inada and upper-job profitability, derive `StaticExistenceAssumptions`, and optionally certify Cobb-Douglas; see `docs/static_existence_foundation.md` |
| M6 | Section 3; (14), Figure 2, journal pp. 403-404 | Derive steady-state unemployment, employment and vacancies; define the full static steady state | strict destruction mass/CDF bridge; hazards and flows; `steadyStateUnemployment`; `SteadyStateEquilibrium`; equation (14); exact reduced/full equivalence; conditional unique existence; split capstones | COMPLETE - AMBER | Stock completion and equation (14): GREEN; uniqueness: GREEN; existence: AMBER - INHERITED FROM M5; overall: AMBER | M4-M5 | No new M6 blocker. Full-state nonemptiness inherits M5's unproved lower-crossing foundation. | `issue2`; M6 completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the split capstones and adequacy contract; M7 remains NOT STARTED |
| M7 | Section 3, journal pp. 401-404; (10), (13), (14); Figures 1-2 | Static order comparative statics for supplied equilibria; hazards, initial flows, and stocks for aggregate net productivity | parameter updates and transports; four general fixed-theta orders plus two strict positive-option-value refinements; four robust equilibrium orders; hazard/flow/stock lemmas; two M7 capstones | COMPLETE - GREEN | GREEN | M5-M6 | None for the proved pairwise results | `issue2`; M7 completion commit | 2026-07-31 (human mathematical/economic review) | Preserve the M7 order interface and design M8's Appendix-specific derivative layer |
| M8 | Appendix; (A1)-(A12), plus (11) | Derivative identities and signs along supplied differentiable equilibrium paths | `AppendixMatchingAssumptions`; CDF/expected-excess analytic lemmas; exact path structures; (11), (A1)-(A12); component and overall capstones | COMPLETE - AMBER | Historical supplied-path layer: AMBER; analytic statements remain valid | M3-M4, M7 analytic interfaces | Paths were supplied in M8; M8b now discharges that premise locally | `issue2`; M8 completion commit | 2026-08-01 human mathematical/economic review | Preserve the historical record; use the COMPLETE - GREEN M8b full Appendix package for supplied regular reduced equilibria |
| M8b.1 | Appendix foundation | Local IFT foundation; derive fixed-tightness sigma and lambda equilibrium paths through a supplied reduced equilibrium | `AppendixIFTAssumptions`; parameterized residuals; `exists_localImplicitCutoffPath`; fixed-sigma and lambda path constructors; M8b.1 capstones | COMPLETE - GREEN | GREEN relative to a supplied equilibrium under explicit primitive C1 regularity of `q` | M8 | None | `issue2`; M8b.1 completion commit | 2026-08-01 human review | Preserve the reviewed interfaces as the foundation for completed M8b.2 |
| M8b.2 | Appendix foundation | Construct discount and dispersion IFT paths | Locally C1 residuals; derived negative cutoff partials; discount and dispersion path constructors and capstones; full implicit Appendix capstone | COMPLETE - GREEN | Full Appendix package GREEN relative to a supplied regular reduced equilibrium | M8b.1 | None | `issue2`; M8b.2 completion commit | 2026-08-02 human mathematical/economic review | Begin M9 separately; add aggregate-state transition terms rather than reusing static equations unchanged |
| M9.1 | Section 4; coupled surplus system and conditional (16)-(18) | Anticipated two-state primitives, primitive value equilibrium, and general max-based surplus equations | `AggregateState`; `TwoStatePrimitives`; `TwoStateValueEquilibrium`; coupled and state surplus Bellman equations; conditional (16)-(18); M9.1 capstone | COMPLETE - GREEN | GREEN | M0-M3 | None | `issue2`; M9.1 completion commit | 2026-08-02 human mathematical/economic review | Preserve the conditional max-form representation; begin cutoff theory without assuming an ordering |
| M9.2 | Section 4; cutoff ordering and regional formulas | Statewise cutoffs, boom/recession cutoff ordering, and certified interval-specific equations | simultaneous surplus differences; strict monotonicity and bounds; statewise cutoff definitions and signs; interval-integral representation; cutoff-order theorem; regional slopes; hinge/option values; equations (16)-(24); capstones | COMPLETE - GREEN | GREEN, conditional on a supplied `TwoStateValueEquilibrium` | M9.1 | None | `issue2`; M9.2A commit `af3dbb6`; M9.2B commit `7d65582`; M9.2C completion commit | 2026-08-04 human mathematical/economic review | Preserve the reviewed M9.2 interface; begin M9.3 separately. |
| M9.3 | Section 4; (15), (25)-(30) | Statewise job creation, unemployment dynamics, and aggregate-shock impact asymmetry | equations (25)-(30); statewise hazards and flows; equation (15); stationary unemployment; measure-valued impact operator; exact interval destruction; capstones | COMPLETE - GREEN | GREEN, conditional on a supplied `TwoStateValueEquilibrium` and admissible employment distributions | Reviewed M9.2, M6; Appendix matching only for strict worker-hazard monotonicity | None | `issue2`; completion commit | 2026-08-04 human mathematical/economic review | Preserve the reviewed Section 4 package; equation (31) remains unimplemented. |
| M10.1 | Section 5 setup; (32)-(34) | Finite-state continuous-time Markov equilibrium representation | finite process and row-stochastic weights; next-state expectation; `FiniteMarkovEquilibrium`; equations (32)-(34); two-state embedding | COMPLETE - GREEN | GREEN; conditional on a supplied `FiniteMarkovEquilibrium` | M9.3 | None | `issue2`; completion commit | 2026-08-04 human mathematical/economic review | Preserve the reviewed continuous-time representation; begin M10.2 separately. |
| M10.2 | Section 5; (35) | Discrete-time employment transition | separate one-period redraw probability; measure-valued transition; full density-plus-upper-atom theorem | COMPLETE - GREEN | GREEN | M10.1 | None | `issue2`; completion commit plus repair `eccf928` | 2026-08-04 human mathematical/economic review | Preserve the reviewed transition as the foundation of completed M10.3. |
| M10.3 | Section 5; (36)-(38) | Endogenous creation, staged destruction, and employment accounting | `DiscreteMatchingParameters`; `PaperMatchingIdentification`; endogenous creation; aggregate/redraw/total destruction; no-double-counting; packaged next distribution; equations (36)-(38); four capstones | COMPLETE - GREEN | GREEN under the stated supplied-equilibrium and discrete-probability conditions | M10.2 | None | `issue2`; completion commit | 2026-08-05 human mathematical/economic review | Preserve the completed equations-(32)-(38) analytical package; numerical replication remains deferred. |
| NUM | Section 5; (39)-(42), Tables I-II | Numerical simulation and calibration | External Python or Julia replication; optional exact accounting or certified residual checks in Lean | DEFERRED / OUTSIDE CORE LEAN | - | Analytical interfaces as needed | Numerical/empirical work is outside core Lean | - | - | Define reproducible solver, calibration, and residual protocol externally |

M6 adequacy: [`docs/static_steady_state_adequacy.md`](static_steady_state_adequacy.md).
Inherited M5 existence foundation:
[`docs/static_existence_foundation.md`](static_existence_foundation.md).

## M0 acceptance checklist

- [x] New module root is isolated from the legacy architecture.
- [x] Primitive parameter structure exists.
- [x] Economic assumptions are layered.
- [x] Shock law is represented by a measure.
- [x] CDF is derived from the measure.
- [x] Matching rates are defined.
- [x] Surplus is defined from `J`, `W`, and `U` rather than stored independently.
- [x] Equations (1)-(7) are represented faithfully.
- [x] Equations (5) and (6) use one shared continuation term.
- [x] No cutoff or reduced-equilibrium conclusion is assumed.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, or custom axioms exist in the new module.
- [x] Tracker TeX compiles and PDF has been visually inspected.
- [x] Human mathematical/economic review is complete.

## M1 acceptance checklist

- [x] Generic continuation decomposition is proved under a probability measure.
- [x] Firm surplus share is derived from equations (3) and (4).
- [x] The surplus flow equation is derived from equations (5)-(7).
- [x] Equation (8) is proved for the actual equilibrium surplus.
- [x] The main theorem uses only probability normalization and existing integrability.
- [x] The `ShockAssumptions` wrapper installs the probability instance locally.
- [x] No M0 structure was strengthened or modified.
- [x] No cutoff, affine surplus, or reduced equilibrium was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, or custom axioms exist.
- [x] Proof ledger TeX/PDF compiles and passes visual inspection.
- [x] Milestone tracker TeX/PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M2 acceptance checklist

- [x] Equation (8) is subtracted at two states.
- [x] The scaled two-point surplus identity is proved.
- [x] The divided affine-surplus identity is proved.
- [x] Surplus is proved strictly increasing.
- [x] The cutoff is defined from the actual equilibrium surplus.
- [x] The cutoff is proved to be a zero of surplus.
- [x] The zero is proved unique.
- [x] `V = 0` is derived from free entry and `r > 0`.
- [x] `q(theta) J(epsUpper) = c` is derived from equations (1)-(2).
- [x] `J(epsUpper) > 0` is proved.
- [x] `S(epsUpper) > 0` is proved.
- [x] `epsD < epsUpper` is proved.
- [x] Equation (12) is proved.
- [x] Surplus signs are characterized relative to `epsD`.
- [x] Firm-value signs are characterized relative to `epsD`.
- [x] Active surplus is rewritten as a scaled positive part.
- [x] No M0 or M1 mathematical declaration was changed.
- [x] No M3 or later theorem was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, or custom axioms exist.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M3 acceptance checklist

- [x] Expected excess is defined as an integral of the positive part.
- [x] Tail option value is defined from the induced CDF.
- [x] Expected-excess integrability is proved.
- [x] The strict upper-tail probability equals one minus the CDF.
- [x] The layer-cake tail identity is proved.
- [x] Active-surplus expectation is rewritten using expected excess.
- [x] Measure-form equation (9) is derived.
- [x] Paper-facing equation (9) is derived.
- [x] The free-entry search-gain identity is derived.
- [x] Measure-form equation (10) is derived.
- [x] Paper-facing equation (10) is derived.
- [x] Job-destruction residual and predicate are defined.
- [x] The equilibrium pair satisfies the job-destruction predicate.
- [x] The product-form job-creation identity is derived.
- [x] Paper equation (13) is derived.
- [x] Job-creation residual and predicate are defined.
- [x] The equilibrium pair satisfies the job-creation predicate.
- [x] No `ReducedEquilibrium` structure is introduced.
- [x] No M0-M2 mathematical declaration is changed.
- [x] No M4 or later theorem is introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M4 acceptance checklist

- [x] Robust product-form job-creation predicate is defined.
- [x] `ReducedEquilibrium` contains theta positivity and cutoff admissibility.
- [x] `ReducedEquilibrium` stores measure-form JD only.
- [x] `ReducedEquilibrium` stores product-form JC only.
- [x] Generic positive-part integrability is proved from the first moment.
- [x] Generic expected-excess/tail identity is proved.
- [x] Reduced-equilibrium paper equations (10) and (13) are derived.
- [x] Every `ValueEquilibrium` maps to a `ReducedEquilibrium`.
- [x] Candidate surplus, J, U, W, V, and wage are defined.
- [x] Reconstructed surplus equals the intended affine surplus.
- [x] Reconstructed active surplus is integrable.
- [x] Reduced search-gain identity is proved.
- [x] Candidate surplus satisfies equation (8).
- [x] Reconstructed vacancy Bellman equation is proved.
- [x] Reconstructed free-entry condition is proved.
- [x] Reconstructed Nash-sharing equation is proved.
- [x] Reconstructed filled-job Bellman equation is proved.
- [x] Reconstructed worker Bellman equation is proved.
- [x] Reconstructed unemployment Bellman equation is proved.
- [x] `ReducedEquilibrium` reconstructs a `ValueEquilibrium`.
- [x] Reconstructed cutoff equals the original reduced cutoff.
- [x] Reconstruct-then-reduce round trip is exact.
- [x] Reduce-then-reconstruct economic components are equal.
- [x] Nonempty `ValueEquilibrium` iff Nonempty `ReducedEquilibrium` is proved.
- [x] No unconditional existence or uniqueness theorem is introduced.
- [x] No M0-M3 mathematical declaration changed.
- [x] No M5 or later theorem is introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M5 acceptance checklist

- [x] Expected excess is proved antitone.
- [x] Expected excess satisfies a one-Lipschitz bound.
- [x] Expected excess is proved continuous.
- [x] The job-destruction net-value curve is defined.
- [x] The job-destruction-implied tightness curve is defined.
- [x] JD satisfaction is equivalent to theta = theta_JD(d).
- [x] The JD curve is proved strictly increasing.
- [x] The scalar job-creation residual is defined.
- [x] The scalar residual is proved strictly decreasing on the admissible domain.
- [x] The Figure 1 JD upward-slope theorem is proved.
- [x] The Figure 1 JC downward-slope theorem is proved.
- [x] At most one `ReducedEquilibrium` is proved.
- [x] `StaticExistenceAssumptions` is explicitly defined.
- [x] The existence bundle contains no equilibrium witness or root.
- [x] Continuity on the crossing bracket is proved.
- [x] The upper endpoint residual is proved equal to `-c`.
- [x] An interior scalar root is proved by the IVT.
- [x] A `ReducedEquilibrium` witness is constructed.
- [x] Unique existence of `ReducedEquilibrium` is proved.
- [x] `ValueEquilibrium` nonemptiness is derived through M4.
- [x] Equilibrium theta uniqueness is proved.
- [x] Reservation-cutoff uniqueness is proved.
- [x] Economic uniqueness of value equilibria is proved.
- [x] Existence is labeled as conditional on the additional bracket assumptions.
- [x] No M0-M4 mathematical theorem statement changed.
- [x] No M6 or later theorem was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M6 acceptance checklist

- [x] Strict destruction mass is connected to the M2 destruction rule.
- [x] Strict lower tail equals the CDF under no atoms.
- [x] Job-separation hazard is defined.
- [x] Worker job-finding hazard is defined or reused.
- [x] Creation and destruction flows are defined.
- [x] Total transition hazard is proved positive.
- [x] Closed-form unemployment is defined.
- [x] Closed-form unemployment lies in `[0,1)`.
- [x] Closed-form unemployment satisfies flow balance.
- [x] Flow balance uniquely determines unemployment.
- [x] Paper equation (14) is proved.
- [x] `SteadyStateEquilibrium` is defined.
- [x] Employment is derived from unemployment.
- [x] Vacancies are derived as `theta * unemployment`.
- [x] Creation flow is rewritten as `q(theta) * vacancies`.
- [x] Destruction flow is rewritten as `lambda F(cutoff) * employment`.
- [x] Creation equals destruction.
- [x] Positive separation implies positive unemployment.
- [x] `vacancies / unemployment = theta` is proved only under positivity.
- [x] Every reduced equilibrium completes to a full steady state.
- [x] Reduced/full exact round trips are proved.
- [x] At most one full steady state is proved without existence assumptions.
- [x] Conditional full-state nonemptiness is transported from M5.
- [x] Full-state unique existence is proved conditionally.
- [x] Beveridge-curve slope is not assumed or proved.
- [x] No M0-M5 mathematical theorem statement changed.
- [x] No M7 or later theorem was introduced.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF compiles and passes visual inspection.
- [x] Tracker PDF compiles and passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M7 acceptance checklist

- [x] Parameter-update functions are defined.
- [x] Assumption transport is proved.
- [x] Fixed-theta p cutoff result is proved.
- [x] Fixed-theta b cutoff result is proved.
- [x] Fixed-theta lambda cutoff result is proved.
- [x] Fixed-theta r cutoff result is proved.
- [x] Full-equilibrium p orders are proved.
- [x] Full-equilibrium b orders are proved.
- [x] Full-equilibrium lambda cutoff order is proved.
- [x] Full-equilibrium r tightness order is proved.
- [x] Separation-hazard order is proved.
- [x] Job-finding-rate order is proved.
- [x] Initial-impact creation/destruction results are proved.
- [x] Steady unemployment and employment orders are proved.
- [x] Vacancy response is explicitly left ambiguous.
- [x] No core theorem uses `StaticExistenceAssumptions`.
- [x] M8 derivative results remain unimplemented.
- [x] No M0-M6 mathematical theorem changed.
- [x] Targeted builds pass.
- [x] Full build passes.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Proof-ledger PDF passes visual inspection.
- [x] Tracker PDF passes visual inspection.
- [x] Human mathematical/economic review is complete.

## M8 acceptance checklist

- [x] Appendix assumptions are isolated from the core assumptions.
- [x] Appendix matching elasticity and its `0 < eta < 1` restrictions are explicit.
- [x] CDF continuity and the expected-excess derivative are derived from the primitive shock law.
- [x] Weak and strict tail-gap bounds and the moment identity use explicit shock assumptions.
- [x] The two path structures store exact differentiability and closure, with no sign or Appendix conclusion.
- [x] Equation (11), its exact sign characterization, and equations (A1)-(A12) are proved.
- [x] Lambda cutoff and tightness derivatives are negative.
- [x] Discount tightness is negative and its cutoff sign has the exact ambiguous (A8) condition.
- [x] Dispersion tightness and cutoff derivatives are positive under `b ≤ p`.
- [x] The lambda capstone states `0 < lambda` explicitly.
- [x] Component and overall capstones compose the supplied-path results.
- [x] No result takes `StaticExistenceAssumptions` or selects an M5 witness.
- [x] M8's AMBER source is documented as supplied local path regularity, not M5 inheritance.
- [x] The M8b route from a regular base equilibrium to constructed paths is documented.
- [x] No M0-M7 mathematical theorem statement changed.
- [x] The M8 review surface was isolated from later M8b and Section 4 work.
- [x] All ten M8 sources pass direct fresh-source elaboration.
- [x] Aggregate and full builds pass.
- [x] No `sorry`, `admit`, custom axiom, or opaque placeholder exists.
- [x] Transitive axiom checks contain no custom project axiom.
- [x] Proof-ledger and tracker PDFs pass visual inspection.
- [x] The review archive contains the exact review surface without build artifacts.
- [x] Human mathematical/economic review is complete (2026-08-01).

## M8b.2 acceptance checklist

- [x] Discount and dispersion base residual roots are derived from `ReducedEquilibrium`.
- [x] Both cutoff partials are proved strictly negative and nonzero.
- [x] Joint local C1 regularity is proved for both JD graphs and residuals.
- [x] Discount and dispersion equilibrium paths are constructed by the scalar IFT.
- [x] Local parameter positivity, JD, product-form JC, and base recovery are proved.
- [x] Discount tightness falls and the exact A8 cutoff-sign iff is preserved.
- [x] Dispersion tightness and cutoff rise under normalization and `b ≤ p`.
- [x] Normalization and `b ≤ p` are used only by the dispersion sign capstone.
- [x] The full Appendix capstone takes no path, M5 selection, sign, or nondegeneracy assumption.
- [x] No Section 4 declaration is implemented.
- [x] Direct, aggregate, audit, and full builds pass.
- [x] No `sorry`, `admit`, custom `axiom`, or `opaque` declaration exists.
- [x] Documentation PDFs compile and pass visual inspection.
- [x] Human mathematical/economic review is complete (2026-08-02).

## M8b.1 acceptance checklist

- [x] `AppendixIFTAssumptions` contains only local C1 regularity of `q`.
- [x] The installed Mathlib IFT API and exact theorem are recorded.
- [x] Expected-excess local C1 regularity is derived from the continuous CDF.
- [x] Fixed-sigma and lambda residual base roots are proved from `ReducedEquilibrium`.
- [x] Both cutoff nondegeneracy results are proved rather than assumed.
- [x] The generic scalar IFT wrapper exposes local residual closure and uniqueness.
- [x] A fixed-tightness sigma path is constructed and equation (11) is recovered.
- [x] A lambda equilibrium path is constructed and both derivative signs are recovered.
- [x] No `StaticExistenceAssumptions` or M5-selected equilibrium is used.
- [x] The reviewed M8b.1 layer contains no M8b.2 or Section 4 theorem.
- [x] Direct, aggregate, audit, and full builds pass.
- [x] No `sorry`, `admit`, custom `axiom`, or `opaque` declaration exists.
- [x] Documentation PDFs compile and have been visually inspected.
- [x] Human mathematical/economic review is complete (2026-08-01).

## M9.1 acceptance checklist

- [x] `AggregateState` is defined.
- [x] State switching is involutive.
- [x] Two-state productivity primitives are defined.
- [x] `pHigh > pLow` and positive transition rate are primitive assumptions.
- [x] No cutoff ordering is assumed.
- [x] Two-state value candidates are defined.
- [x] Statewise surplus is derived from `J`, `W`, and `U`.
- [x] Statewise active-surplus integrability is required.
- [x] Vacancy Bellman equations include aggregate-state capital gains.
- [x] Unemployment Bellman equations include aggregate-state capital gains.
- [x] Firm and worker equations contain economically correct aggregate continuation terms.
- [x] Firm share is derived.
- [x] Vacancy values equal zero is derived.
- [x] Raw surplus flow equation is derived.
- [x] General coupled max-form surplus equation is derived.
- [x] Recession and boom max-form equations are derived.
- [x] Equation-(16) sign-region theorem is derived.
- [x] Equation-(17) sign-region theorem is derived.
- [x] Equation-(18) sign-region theorem is derived.
- [x] No cutoff or cutoff ordering is introduced.
- [x] No equation (15) or (19)-(30) is introduced.
- [x] No M0-M8b.2 theorem changes.
- [x] Targeted and full builds pass.
- [x] No placeholder or custom axiom exists.
- [x] PDFs pass visual inspection.
- [x] Human mathematical/economic review is complete (2026-08-02).

## M9.2 acceptance checklist

- [x] Coupled two-point recession and boom surplus identities are derived.
- [x] Both statewise surplus functions are proved strictly increasing simultaneously.
- [x] Lower and upper increment bounds are proved.
- [x] Global Lipschitz continuity is derived rather than assumed.
- [x] Upper-support firm value and surplus are proved positive.
- [x] A negative-surplus witness below `epsUpper` is constructed in each state.
- [x] A unique admissible reservation cutoff is derived in each state.
- [x] Complete surplus and firm-value sign characterizations are proved.
- [x] Active-surplus expectations are rewritten over statewise survival intervals.
- [x] No cross-state cutoff order is assumed.
- [x] Conditional interval geometry is checked under either possible order.
- [x] The initial cutoff-ordering obstruction is preserved as historical context.
- [x] Human review identified and documented the stronger maximum-principle route.
- [x] `d_B < d_R` is derived from reviewed assumptions.
- [x] Exact ordered equation (16) is proved.
- [x] Exact ordered equation (17) is proved.
- [x] Exact ordered equation (18) is proved.
- [x] Regional difference formulas and equation (21) are proved.
- [x] Recession option-value formula is proved.
- [x] Boom piecewise option-value formula is proved.
- [x] Equation (19) is proved.
- [x] Equation (20) is proved.
- [x] Equation (22) is proved.
- [x] Equation (23) is proved.
- [x] Equation (24) is proved.
- [x] No M9.3 theorem is implemented.
- [x] Targeted, aggregate, audit, and full builds pass.
- [x] No `sorry`, `admit`, custom `axiom`, or prohibited declaration exists.
- [x] Documentation PDFs compile and pass visual inspection.
- [x] Human mathematical/economic review of M9.2C/full M9.2 is complete
  (2026-08-04).
- [x] M9.2A human mathematical/economic review is complete (2026-08-02).
- [x] M9.2B human mathematical/economic review is complete (2026-08-04).

## M9.3 acceptance checklist

- [x] Equation (25).
- [x] Equation (26).
- [x] Equation (27).
- [x] Equation (28).
- [x] Equation (29).
- [x] Boom denominator positivity.
- [x] Equation (30).
- [x] Anticipation wedge.
- [x] Vacancy and worker meeting rates distinguished.
- [x] Statewise destruction hazards defined.
- [x] Worker-meeting hazard is increasing in positive tightness.
- [x] Boom worker-meeting hazard exceeds recession.
- [x] Boom idiosyncratic destruction hazard is weakly lower.
- [x] Equation (15) vector field.
- [x] Stationary unemployment and drift signs.
- [x] Cross-state drift order.
- [x] Measure-valued employment distribution.
- [x] Upturn impact employment unchanged.
- [x] Downturn destroys exactly `[dB,dR)`.
- [x] Strict downturn impact requires positive interval mass.
- [x] The no-impact-creation timing convention is explicit.
- [x] No density assumption.
- [x] No M10 theorem.
- [x] Direct and aggregate builds.
- [x] No placeholders or custom axioms.
- [x] PDFs visually inspected.
- [x] Human mathematical/economic review is complete (2026-08-04).

## M10.1 acceptance checklist

- [x] Finite aggregate-state process is defined.
- [x] Aggregate arrival is a nonnegative continuous-time rate.
- [x] Transition weights are nonnegative.
- [x] Every transition row sums to one.
- [x] Finite next-state expectation is defined.
- [x] Constant, additive, nonnegative, and monotone expectation laws are proved.
- [x] Finite Markov candidate is defined.
- [x] Worker meeting rate is derived, not stored.
- [x] Active surplus is derived, not stored.
- [x] Surviving-surplus integral is defined.
- [x] Finite Markov equilibrium is defined.
- [x] Equation (32) is represented.
- [x] Equation (33) is represented.
- [x] Equation (34) is represented.
- [x] Upper surplus is positive.
- [x] Worker meeting rate is positive.
- [x] Aggregate continuation is nonnegative.
- [x] Deterministic two-state transition kernel is defined.
- [x] Two-state expectation reduces to the other state.
- [x] Every supplied M9 two-state equilibrium embeds.
- [x] No M10.2/M10.3 declaration.
- [x] No discrete-time use of `1 - lambda`.
- [x] No density assumption.
- [x] Direct and full builds pass.
- [x] No placeholders or custom axioms.
- [x] PDFs visually inspected.
- [x] Human mathematical/economic review is complete (2026-08-04).

## M10.2 acceptance checklist

- [x] Separate one-period redraw probability.
- [x] Probability lies in `[0,1]`.
- [x] No use of `1 - P.lambda`.
- [x] Finite-state employment distribution.
- [x] Current mass at most one.
- [x] Support above current cutoff.
- [x] Support below upper shock bound.
- [x] Re-evaluation at next-state cutoff.
- [x] No-redraw incumbent measure.
- [x] Redraw incumbent measure.
- [x] Incumbent transition measure.
- [x] Supplied upper-support creation atom.
- [x] Raw next measure.
- [x] Exact incumbent mass formula.
- [x] Exact raw-next mass formula.
- [x] Packaged distribution requires explicit mass bound.
- [x] Zero-redraw/zero-creation specialization.
- [x] Shock density representation is separate.
- [x] Employment density representation is separate.
- [x] Equation-(35) measure form.
- [x] Full raw-next density-plus-upper-atom equality.
- [x] Equation-(35) almost-everywhere density form.
- [x] Actual raw-next upper-support singleton mass theorem.
- [x] The M10.2 modules themselves contain no equation (36), (37), or (38).
- [x] No density in core transition.
- [x] Direct and full builds.
- [x] No placeholders or custom axioms.
- [x] PDFs visually inspected.
- [x] Human mathematical/economic review is complete (2026-08-04).

## M10.3 acceptance checklist

- [x] Separate one-period matching probability lies in `[0,1]`.
- [x] `PaperMatchingIdentification` is explicit and not stored in equilibrium.
- [x] No continuous-time rate is silently treated as a probability.
- [x] ENNReal unemployment and endogenous creation are defined.
- [x] Equation (36) is proved in discrete and paper-facing real forms.
- [x] Aggregate-cutoff and redraw destruction are separate stages.
- [x] Shock partition and strict-event/CDF bridge are proved.
- [x] Staged destruction is exhaustive and does not double count.
- [x] Equation (37) is proved in ENNReal and real forms.
- [x] Endogenous creation is inserted into the reviewed equation-(35) operator.
- [x] The additive accounting identity is proved.
- [x] The unit-mass bound and finiteness are automatic.
- [x] The endogenous next distribution is packaged without caller mass premises.
- [x] Equation (38) is proved in ENNReal and real forms.
- [x] Bounds and zero-probability special cases are proved.
- [x] Aggregate-cutoff destruction is bridged to M9.3 impact destruction.
- [x] All four M10.3 capstones are present; the full capstone explicitly
  collects equations (36), (37), and (38).
- [x] No density or static-existence premise enters the full capstone.
- [x] No equation (31), numerical solution, calibration, or simulation theorem.
- [x] Direct/full builds and no-placeholder/axiom audits pass.
- [x] Tracker and proof-ledger PDFs compile and are visually inspected.
- [x] Human mathematical/economic review is complete (2026-08-05).

## M5b - Primitive foundation for static existence

**Status:** NOT STARTED

**Adequacy target:** Upgrade static existence from AMBER to GREEN under either
a strengthened general matching-boundary theorem or a fully certified
Cobb-Douglas specialization.

This is a foundational refinement, not M6, and it is not part of the current
M5 Lean proof. Its proposed tasks are:

- add a right-hand Inada condition for `q`;
- separately require upper-job profitability,
  `b < p + sigma * epsUpper`;
- prove that the JD curve reaches zero and then positive tightness;
- derive `StaticExistenceAssumptions.lower_crossing` rather than assuming it;
- construct `StaticExistenceAssumptions`; and
- optionally certify all conditions for Cobb-Douglas matching.

The Inada condition on `q` alone is insufficient: without positive
JD-implied tightness somewhere below `epsUpper`, its behavior on positive
tightness cannot yield a crossing. The complete design is recorded in
`docs/static_existence_foundation.md`. M6 does not implement this refinement.

## Changelog

### 2026-08-05 - M10.3 employment accounting completed and human reviewed

- Added explicit discrete matching probabilities and the optional paper
  identification; no continuous-time hazard is silently used as a probability.
- Derived endogenous creation, staged aggregate/redraw destruction, the
  no-double-counting identity, automatic mass admissibility, a packaged next
  distribution, and equations (36)-(38).
- Corrected the final public capstone so it explicitly collects equations
  (36), (37), and (38), alongside the staged no-double-counting and additive
  ENNReal identities.
- Human review found the construction mathematically and economically
  adequate. M10.3 and the conditional Section 5 equations-(32)-(38) analytical
  package are **COMPLETE - GREEN**.
- The next aggregate state remains supplied. M5/M6 retain their AMBER
  existence qualification; optional M5b and equation (31) remain deferred.
  Numerical equilibrium solution, calibration, simulation, and equations
  (39), (40), and (42) are **DEFERRED / OUTSIDE CORE LEAN**.

### 2026-08-04 - M10.2 upper-atom correction and human review completed

- Renamed the interior restriction result
  `rawNextMeasure_restrict_Iio_eq_density` and proved the full-measure
  `rawNextMeasure_eq_density_plus_upperAtom` theorem.
- Proved the current employment upper atom, shock singleton zero, and the
  actual `equation35_upperMass` singleton identity.
- Graded every M10.2 component and overall M10.2 **COMPLETE - GREEN**. The
  next state and creation mass remain supplied, and no arbitrary supplied
  creation mass is claimed to preserve total mass. M10.3 remains **NOT
  STARTED**.

### 2026-08-04 - M10.2 employment transition implemented

- Introduced the separate unit-interval `redrawProb`; no continuous-time rate
  is treated as a one-period probability.
- Defined the cutoff, no-redraw, redraw, incumbent-next, supplied creation,
  and raw-next measures with exact support, finiteness, and mass identities.
- Proved the measure-valued equation (35), its optional almost-everywhere
  density form, upper-support atom update, and the M9.3 zero-redraw embedding.
- Submitted M10.2 as **READY FOR REVIEW**, target **COMPLETE - GREEN**.
  Creation remains supplied; M10.3 equations (36)-(38) are **NOT STARTED**.

### 2026-08-04 - M10.1 human review completed

- Graded the finite process, expectation API, equations (32)-(34), two-state
  embedding, and overall M10.1 **COMPLETE - GREEN**.
- Confirmed the marked-Poisson rate and conditional-next-mark interpretation,
  row stochasticity, vacancy/worker contact distinction, finite active-surplus
  expectation, and the absence of existence, cutoff-sign, or rate-as-probability
  shortcuts.
- Set M10.2 equation (35) as next. It must introduce a separate one-period
  `redrawProb`; M10.3 remains **NOT STARTED**.

### 2026-08-04 - M10.1 finite-state representation implemented

- Added the finite marked-Poisson aggregate process, row-stochastic finite
  expectation API, and statewise assumption transports.
- Defined supplied finite Markov candidates and equilibria and exposed paper
  equations (32)-(34), including their immediate positivity consequences.
- Embedded every supplied M9 two-state equilibrium through the deterministic
  other-state kernel, preserving tightness, cutoff, and actual surplus.
- Submitted M10.1 as **READY FOR REVIEW**, target **COMPLETE - GREEN**. It
  proves no existence or uniqueness; M10.2, M10.3, equation (31), discrete-time
  employment transitions, and numerical work remain unimplemented.

### 2026-08-04 - M9.3 human review completed

- Graded equations (25)-(30), statewise hazards and equation (15), stationary
  unemployment algebra, cross-state flows, the impact operator, and the full
  impact-asymmetry theorem **COMPLETE - GREEN**.
- Confirmed equation (27)'s reuse of M9.2C, the labor-flow/ODE boundary, all
  three matching-rate concepts, exact `[dB,dR)` downturn destruction, its
  strict-mass qualification, and zero instantaneous upturn creation.
- Graded full M9.1-M9.3 **COMPLETE - GREEN**, conditional on a supplied
  `TwoStateValueEquilibrium`. Equation (31) remains unimplemented; M10.1 is
  next, while M10.2 and M10.3 remain not started.

### 2026-08-04 - M9.3 cyclical dynamics implemented

- Derived equations (25)-(30), boom-denominator positivity, and the
  anticipation wedge from the reviewed M9.2 cutoff and regional interfaces.
- Defined statewise hazards, flows, equation (15)'s affine vector field,
  stationary unemployment, and the cross-state drift comparison without
  claiming ODE existence.
- Added a density-free measure impact operator: upturn employment is unchanged,
  downturn destruction is exactly `[dB,dR)`, and strict loss requires positive
  interval mass; impact creation is zero by the explicit timing convention.
- Submitted M9.3 as **READY FOR REVIEW**, target **COMPLETE - GREEN**. M10
  remains **NOT STARTED**.

### 2026-08-04 - M9.2C and full M9.2 human review completed

- Graded the ordered equations (16)-(18), regional difference results and
  equation (21), both hinge and option-value layers, equations (19), (20),
  (22), (23), and (24), and the M9.2C capstone **COMPLETE - GREEN**.
- Graded full M9.2 **COMPLETE - GREEN**, conditional on a supplied
  `TwoStateValueEquilibrium`; no `StaticExistenceAssumptions` or
  primitive-selected two-state equilibrium is used.
- Confirmed that no cutoff order, regional affinity, derivative, interval
  equation, or option-value formula is stored in the equilibrium structure.
- Set M9.3 job creation, unemployment dynamics, and impact asymmetry as the
  next milestone, with status **NOT STARTED**.

### 2026-08-04 - M9.2C ordered regional equations implemented

- Derived exact ordered equations (16)-(18) from the proved cutoff order.
- Proved the common upper-region and lower between-cutoff boom difference
  formulas, equation (21), and equation (23).
- Proved recession and boom hinge identities, expected-excess/CDF-tail option
  values, and equations (19), (20), (22), and (24).
- Added the M9.2C and full M9.2 capstones, aggregate/audit coverage, and the
  ordered-equations scope note.
- Marked M9.2C **READY FOR REVIEW**, target **COMPLETE - GREEN**; M9.3 remains
  **NOT STARTED**.

### 2026-08-04 - M9.2B human review completed

- Graded the contrary-order cross-state comparison, reverse-order
  contradiction, strict cutoff order, and strict upper-surplus/tightness
  implications **COMPLETE - GREEN**.
- Confirmed `d_B < d_R` is derived from a supplied
  `TwoStateValueEquilibrium` without a cutoff-order, surplus-order,
  tightness-order, search-gain, affinity, derivative, or closure assumption.
- Confirmed the maximum-principle chain `S_B ≤ S_R`, `theta_B ≤ theta_R`,
  `D_u ≤ I_B-I_R`, and the contradiction
  `(r+2*mu)D_u ≥ pHigh-p > 0` while `D_u ≤ 0`.
- Set M9.2C ordered equations (16)-(24) as the next milestone.

### 2026-08-02 - M9.2B maximum-principle cutoff ordering implemented

- Proved regional cross-state gap constancy under the contrary weak cutoff
  order, the global reverse-order surplus comparison, and the induced weak
  tightness order from statewise free entry.
- Proved the pointwise and integrated active-surplus gap bounds and exposed the
  upper-support gap equation as a named theorem.
- Derived `boom_cutoff_lt_recession_cutoff` without adding an order,
  cross-state surplus, tightness, search-gain, or closure assumption; also
  derived strict boom upper-surplus and tightness orders.
- Marked M9.2B **READY FOR REVIEW**, target GREEN. M9.2C and M9.3 remain
  **NOT STARTED**.

### 2026-08-02 - M9.2A human review completed

- Graded simultaneous monotonicity, global increment bounds and continuity,
  unique statewise cutoffs, reservation signs, and statewise interval
  integrals **COMPLETE - GREEN**.
- Confirmed that neither state's monotonicity is assumed for the other, no
  lower shock support or cross-state cutoff order is used, and conditionality
  on a supplied `TwoStateValueEquilibrium` does not create an AMBER grade.
- Recorded the review-discovered maximum-principle route for M9.2B. The initial
  failed search-gain comparison remains in the historical record, but M9.2B is
  now **NOT STARTED - REVIEWED PROOF ROUTE AVAILABLE**.

### 2026-08-02 - M9.2A implemented; initial cutoff-ordering route stalled

- Derived simultaneous statewise surplus monotonicity, quantitative increment
  bounds, continuity, positive upper surplus, negative witnesses, and unique
  admissible statewise cutoffs.
- Added the full reservation-property sign interface and exact statewise
  active-surplus interval integrals without using a cross-state cutoff order.
- Checked the conditional interval geometry under either possible order.
- The ordering attempt left the endogenous tightness-weighted search-gain
  difference unsigned relative to the productivity and continuation terms.
  No ordering assumption was added. This initial classification was superseded
  by the review-discovered maximum-principle route recorded above.

### 2026-08-02 - M9.1 human review completed

- Confirmed that M9.1 is a conditional representation theorem for every
  supplied `TwoStateValueEquilibrium`; existence is not asserted and its
  absence does not make the milestone AMBER.
- Confirmed aggregate-state capital gains in the vacancy, unemployment, firm,
  and worker equations and that the coupled surplus equation is derived.
- Classified equations (16)-(18) as max-form sign reductions rather than the
  final cutoff-indexed interval-integral formulas.
- Confirmed that no cutoff or cutoff ordering is assumed. M9.1 is
  **COMPLETE - GREEN**; M9.2 is next and **NOT STARTED**.

### 2026-08-02 - M9.1 anticipated two-state foundations implemented

- Added six `Cyclical` modules defining the recession/boom process, statewise
  primitive value system, shared continuation terms, coupled max-based surplus
  Bellman equation, conditional forms of equations (16)-(18), and the M9.1
  representation capstone.
- Kept probability normalization explicit through `ShockAssumptions P` and
  kept every theorem conditional on a supplied `TwoStateValueEquilibrium`.
- Added `docs/two_state_foundations_scope.md`; no cutoff, cutoff ordering,
  two-state existence, job-creation, unemployment-dynamics, or impact-asymmetry
  result was introduced.
- Marked M9.1 **READY FOR REVIEW**, target **COMPLETE - GREEN**. M9.2 and M9.3
  remain **NOT STARTED**.

### 2026-08-02 - M8b.2 human review completed

- Graded the discount residual/path, dispersion residual/path, and full
  IFT-derived Appendix capstone **COMPLETE - GREEN**.
- Confirmed that roots are derived, both cutoff partials are proved strictly
  negative, and all four local paths are constructed through Mathlib's IFT.
- Confirmed that the GREEN capstone assumes no path, derivative sign,
  `StaticExistenceAssumptions`, or M5-selected equilibrium.
- Recorded the full Appendix package as GREEN relative to a supplied regular
  reduced equilibrium, explicit Appendix matching/IFT regularity, and stated
  sign conditions. A future primitive-selected wrapper would separately
  inherit M5's AMBER existence qualification.
- Set M9, the two-state anticipated aggregate-productivity extension, as the
  next milestone and left it NOT STARTED.

### 2026-08-01 - M8b.2 discount and dispersion paths implemented

- Derived both base roots and strictly negative cutoff partials from a supplied
  reduced equilibrium; no nondegeneracy assumption is taken.
- Proved joint local C1 regularity and constructed local discount and
  dispersion equilibrium paths by the scalar IFT.
- Connected the paths to the reviewed M8 sign results and added the full
  implicit Appendix capstone with no M5, supplied-path, sign, or
  nondegeneracy premise.
- Marked M8b.2 **READY FOR REVIEW**, target GREEN. Overall M8 remains
  **COMPLETE - AMBER** pending human review.

### 2026-08-01 - M8b.1 human review completed

- Graded the generic IFT wrapper, fixed-tightness sigma path, lambda path, and
  combined result **COMPLETE - GREEN** relative to a supplied reduced
  equilibrium under explicit `AppendixIFTAssumptions`.
- Confirmed that base roots are derived, cutoff nondegeneracy is proved, no
  derivative sign is assumed, and neither M5 selection nor
  `StaticExistenceAssumptions` is used.
- Recorded that `q_contDiffOn_pos` is a technical regularity strengthening,
  not a paper conclusion, and that no global path or equilibrium uniqueness is
  claimed. Overall M8 remains **COMPLETE - AMBER** pending M8b.2 review.

### 2026-08-01 - M8b.1 local IFT foundation implemented

- Added `AppendixIFTAssumptions`, parameterized residual calculus, the generic
  scalar Mathlib IFT wrapper, and derived fixed-tightness sigma and lambda
  equilibrium paths through a supplied reduced equilibrium.
- Proved the fixed-sigma cutoff partial positive and the lambda scalar-crossing
  cutoff partial negative; no root, Jacobian, or derivative sign is assumed.
- Applied the reviewed M8 capstones to the constructed paths. No M5 existence
  assumption or selected equilibrium is used.
- Marked M8b.1 **READY FOR REVIEW**, target GREEN. M8 remains **COMPLETE -
  AMBER** until M8b.2 constructs discount and dispersion paths.

### 2026-08-01 - M8 human review completed

- Confirmed the Appendix equations and comparative-static signs are faithful
  and non-circular.
- Graded analytic infrastructure **COMPLETE - GREEN**, supplied-path results
  **COMPLETE - AMBER**, and overall M8 **COMPLETE - AMBER**.
- Confirmed the AMBER source is supplied differentiable local paths, not M5's
  existence grade; the paper-facing lambda capstone uses `0 < P.lambda`.
- Marked human mathematical/economic review complete. M8b remains the route to
  GREEN for the path layer.

### 2026-08-01 - M8 Appendix derivative comparative statics integrated

- Added the isolated Appendix assumptions, shock-law analytic lemmas, exact
  supplied-path structures, scalar algebra, equations (11) and (A1)-(A12),
  sign theorems, and component/overall capstones.
- Proved negative lambda cutoff/tightness responses, negative discount
  tightness with the cutoff sign characterized by (A8), and positive dispersion
  responses under `b ≤ p`.
- Confirmed that M8 uses neither `StaticExistenceAssumptions` nor an M5 witness.
  The missing IFT construction of supplied local paths is the sole AMBER gap
  and is deferred to M8b.
- Submitted M8 as **READY FOR REVIEW**, overall **COMPLETE - AMBER**; human
  mathematical/economic review remains unchecked.

### 2026-07-31 - M7 human review completed

- Found the order proofs mathematically and economically sound and graded M7
  **COMPLETE - GREEN**.
- Confirmed that no M5 existence assumption is used; the theorems are
  universal conditional comparisons of supplied equilibria.
- Removed unnecessary imports of the M5 existence and M6 transported-existence
  layers from the M7 core.
- Added strict fixed-tightness refinements under explicit positive option value;
  the strict discount-rate result also assumes positive `lambda`.
- Corrected the proof-ledger symbol and rendering defects.
- Left the `lambda`-tightness, `r`-cutoff, `sigma`, and derivative results for
  M8, which remains **NOT STARTED**.

### 2026-07-31 - M7 static order comparative statics implemented

- Added immutable parameter updates and assumption transports for `p`, `b`,
  `lambda`, and `r`.
- Proved the four fixed-tightness cutoff orders and the robust supplied-
  equilibrium orders: full `p` and `b` responses, the `lambda` cutoff, and the
  `r` tightness response.
- Derived weak separation, finding, initial-flow, unemployment, and employment
  implications for aggregate net productivity; left vacancies ambiguous.
- Confirmed that M7 core uses no `StaticExistenceAssumptions` and proves no
  existence theorem. Deferred `lambda`-tightness, `r`-cutoff, `sigma`, and all
  Appendix derivative results to M8.
- Added `docs/static_comparative_statics_scope.md`; submitted M7 as
  **READY FOR REVIEW**, with target grade **COMPLETE - GREEN**.

### 2026-07-31 - M6 human review completed

- Judged stock completion, equation (14), flow accounting, exact reduced/full
  representation, and full-state uniqueness mathematically and economically
  faithful; these components are GREEN.
- Confirmed that zero separation gives `u = v = 0`, while the literal
  `v / u = theta` result correctly requires positive separation.
- Confirmed that M6 introduces no new existence closure assumption. Its AMBER
  existence grade is inherited entirely from M5 through `lower_crossing`.
- Split the capstone interface into green stock/uniqueness and amber
  conditional-existence theorems, removed irrelevant shock assumptions from
  the pure stock representation, and recorded the detailed assessment in
  `docs/static_steady_state_adequacy.md`.
- Marked M6 **COMPLETE - AMBER**. M7 remains **NOT STARTED**.

### 2026-07-31 - M6 unemployment flow balance implemented

- Added the strict destruction mass and used atomlessness to identify it with
  the paper CDF.
- Defined separation and job-finding hazards, creation/destruction flows, and
  the unique balanced unemployment formula; derived paper equation (14).
- Added `SteadyStateEquilibrium`, derived employment and vacancies, proved
  flow equality, and guarded the literal `v/u = theta` identity by positive
  separation because zero separation gives `u = v = 0`.
- Proved exact reduced/full round trips, an explicit `Equiv`, at-most-one full
  state, and conditional nonemptiness/unique existence inherited from M5.
- Stock completion and equation (14) were submitted as GREEN; existence and
  overall M6 were submitted as AMBER pending the completed review above.

### 2026-07-31 - M5 static-existence foundation documented

- Recorded the exact current continuity and lower-crossing assumptions.
- Added the unimplemented M5b path combining a right-hand Inada condition for
  `q` with the separate upper-job profitability condition.
- Recorded that `q` Inada alone is insufficient and that M5 remains
  **COMPLETE - AMBER** while M6 remains **NOT STARTED**.
- Added `docs/static_existence_foundation.md` as the durable design note.

### 2026-07-31 - M5 review completed

- The substantive uniqueness and IVT proofs passed mathematical review.
- Figure 1 establishes uniqueness but does not by itself establish existence.
- `lower_crossing` is non-circular because it assumes a strictly positive
  residual, not a root, but it supplies the missing endpoint condition.
- Existence-only declarations were weakened to omit `MatchingAssumptions`;
  the combined uniqueness capstones retain it.
- Uniqueness is **COMPLETE - GREEN**; existence and overall M5 are
  **COMPLETE - AMBER**.
- Future task: derive `lower_crossing` from primitive conditions on `q`, or
  certify it for a standard Cobb-Douglas matching function. This does not
  block M6.

### 2026-07-31 - M5 static existence and uniqueness implemented

Added expected-excess regularity, the upward-sloping JD curve, the
downward-sloping JC curve, and at-most-one reduced equilibrium under the
maintained assumptions. Added the separate `StaticExistenceAssumptions`
continuity/bracket bundle; the derived upper residual `-c < 0` and Mathlib's
intermediate value theorem construct an interior reduced equilibrium. M4
reconstruction transports conditional existence and economic uniqueness to
primitive value equilibria. The implementation was submitted for review;
equation (14) and the full steady state remain M6.

### 2026-07-31 - M4 review completed

- The generic excess and CDF-tail analysis is valid.
- Equations (10) and (13) are sufficient for reconstruction under the stated
  admissibility assumptions.
- The explicit Nash wage is economically correct, and equations (1)-(7) are
  reconstructed rather than assumed.
- Exact reduced and complete value-side economic round trips are certified.
- The import diagram and assumption-field documentation were corrected.
- M4 establishes neither equilibrium existence nor uniqueness.
- M4 was graded **COMPLETE - GREEN**.

### 2026-07-30 - M4 reconstruction and equivalence implemented

Created the robust two-variable `ReducedEquilibrium`, generic excess
integrability and tail-identity layer, forward bridge, explicit reverse
reconstruction, and equivalence module. The reverse construction verifies
equations (1)-(7) with the economic Nash wage, reconstructs the original
cutoff, and gives exact reduced and componentwise value round trips.
Nonemptiness is equivalent only after receiving a witness on one side; no
existence or uniqueness result is introduced. M4 is **READY FOR REVIEW**.

### 2026-07-30 - M3 review completed

- The layer-cake/CDF proof was reviewed and found valid; atomlessness is not
  used.
- Equations (9), (10), and (13) have the correct signs and dependencies.
- Job creation is derived independently of the job-destruction equation.
- The capstone was moved to the neutral combining module
  `SteadyState/StaticConditions.lean`.
- The residual predicates require separate admissibility fields in M4.
- M4 must prove a generic expected-excess/tail theorem for reverse
  reconstruction.
- M3 was graded **COMPLETE - GREEN**.

### 2026-07-30 - M3 continuation and static conditions implemented

Created `SteadyState/Continuation.lean`,
`SteadyState/JobDestruction.lean`, `SteadyState/JobCreation.lean`, and the
neutral combining module `SteadyState/StaticConditions.lean`.
Expected excess is derived from the M2 active-surplus formula; Mathlib's
strict-tail layer-cake theorem gives the induced-CDF representation without
using atomlessness. Equations (9), (10), and (13), the job-destruction and
job-creation residual predicates, and the forward M3 capstone are proved for an
existing `ValueEquilibrium`. No reduced-equilibrium structure or M4 theorem
was introduced.

### 2026-07-29 - M2 review completed

- Equation (8) was correctly subtracted at two states.
- The actual equilibrium surplus was proved affine and strictly increasing.
- `reservationCutoff` was proved to be the uniquely identified surplus zero.
- Equations (1)-(2) establish `reservationCutoff < epsUpper`.
- Equation (12) and the reservation rule were proved.
- M2 remains conditional on an existing `ValueEquilibrium`.
- M2 was graded **COMPLETE - GREEN**.

### 2026-07-29 - M2 affine surplus and cutoff implemented

Created `SteadyState/AffineSurplus.lean` and `SteadyState/Cutoff.lean`.
Equation (8) was subtracted at two states to derive the affine surplus
difference and strict monotonicity. The derived `reservationCutoff` was proved
to be the unique surplus zero; equations (1)-(2), positive vacancy cost and
meeting, and `beta < 1` separately imply that it lies below `epsUpper`.
Equation (12), surplus and firm-value reservation rules, the active-surplus
positive-part bridge, and an M2 capstone were added. M2 is **READY FOR REVIEW**.

### Review-archive convention

Beginning with M3, review archives use project-local names such as
`review_m3.zip`, `review_m4.zip`, and so on. They remain untracked and are
never committed.

### 2026-07-29 - M1 review completed

Human mathematical and economic review found equation (8) mathematically
faithful to the paper and its proof non-circular. It is derived from equations
(3)-(7), uses the actual equilibrium surplus, and assumes no cutoff, affinity
result, or reduced equilibrium. The result is a conditional representation
theorem for an existing `ValueEquilibrium`; M1 does not prove equilibrium
existence. M1 was graded **COMPLETE - GREEN**.

### 2026-07-29 - M1 equation (8) implemented

Created `MP1994V2/SteadyState/Surplus.lean` with the continuation
decomposition, derived firm share, surplus flow equation,
`surplus_bellman_of_probability`, and the `ShockAssumptions` wrapper
`surplus_bellman`. Updated `All.lean`, `Audit.lean`, the README, trackers, and
added the cumulative proof ledger. M1 is **READY FOR REVIEW**.

### 2026-07-29 - M0 review completed

- Equations (1)-(7) were judged economically faithful.
- No conclusion belonging to a future theorem is embedded in the architecture.
- The aggregate import direction was corrected to substantive modules -> `All`
  -> `Audit`.
- Milestone 1 must take `ShockAssumptions P` explicitly and install
  `D.isProbability` locally when probability-measure integral identities are
  needed.
- M0 was graded **COMPLETE - GREEN**.

### 2026-07-29 - v2 foundation created

Created the isolated `MP1994V2` Milestone 0 foundation:

- `Definitions.lean`: `Primitives`, productivity and meeting rates,
  `positivePart`, `surplus`, `activeSurplus`, and `continuationTerm`;
- `Assumptions.lean`: `CoreEconomicAssumptions`, `ShockAssumptions`,
  `ShockNormalizationAssumptions`, and `MatchingAssumptions`;
- `Probability.lean`: derived `cdf`, `shockBelow`, and
  `IsShockUpperBound`;
- `Matching.lean`: `MarketTightness` and `workerMeetingRate_pos`;
- `Equilibrium/Value.lean`: `ValueCandidate`, candidate surplus/continuation
  accessors, `ValueEquilibrium`, and definitional equation (3);
- `Audit.lean` and `All.lean`: aggregate import and compile-time audit;
- `README.md`: architecture, scope, equation map, and build instructions;
- this synchronized Markdown/TeX/PDF tracker.

No legacy v1 Lean file, replication-architecture document, or Lake
configuration was modified. The library root `Lean4Tutorial.lean` received one
aggregate import so `lake build` certifies `MP1994V2.All`.
