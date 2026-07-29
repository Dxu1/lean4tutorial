# MP1994 Proposed Proof Milestones

Repository root: `/Users/davidxu/Documents/lean4tutorial`

This is a staged extension plan, not a rewrite. It preserves the existing source files and
declarations as a compatibility layer, adds missing mathematical bridges in small theorem
families, and postpones structural replacement until dependent proofs exist.

## 1. Guiding rules

1. Do not place comparative-static orderings, existence, uniqueness, or flow directions
   in a primitive assumptions structure.
2. Distinguish an equation predicate from a theorem deriving that equation.
3. Add analytic hypotheses locally until they can be derived from a better probability or
   matching representation.
4. Prefer elementary order/monotone comparisons to implicit differentiation when the
   paper's qualitative conclusion does not require a derivative.
5. Treat the Section 5 calibration as a finite witness layer, separate from the general
   theory.
6. Preserve current names until replacement theorems compile; use aliases and deprecation
   notices rather than breaking all imports.

## 2. Declaration disposition

### Retain unchanged initially

| Existing declaration | Location | Reason |
|---|---|---|
| `Primitives.price`, `mWorker`, `m` | `Definitions.lean:52-66` | Correct core formulas; domain lemmas can be added around them. |
| `VacancyBellman` through `SurplusBellman` | `Definitions.lean:96-141` | Useful equation predicates and already used by `ValueEquilibrium`. |
| `JobDestructionCondition`, `JobCreationCondition`, `BeveridgeCondition` | `Definitions.lean:143-165`, `Definitions.lean:214-218` | Keep as target predicates even after proving bridge theorems. |
| `ValueEquilibrium`, `SteadyStateEquilibrium` | `Equilibrium.lean:18-66` | Useful records for equation-bearing candidates/solutions. Add constructors and theorems rather than replacing immediately. |
| Elementary algebra/order theorems | `Results.lean:70-145`, `Results.lean:284-305`, `Results.lean:337-365`, `Results.lean:398-436` | Sound reusable lemmas. Some need neutral names or stronger upstream theorems, not deletion. |

### Generalize or supplement

| Existing declaration | Action |
|---|---|
| `Assumptions` (`Definitions.lean:251-280`) | Introduce a stronger paper-faithful layer or companion records for probability moments and matching regularity. Derive CDF bounds/monotonicity rather than adding more parallel fields. |
| `positiveContinuation` (`Definitions.lean:76-78`) | Keep; add integrability-aware lemmas and a theorem equating it to a tail integral for affine threshold surplus. |
| `S_cutoff`, `J_cutoff`, `WminusU_cutoff` (`Definitions.lean:84-94`) | Keep as closed-form formulas; add bridge theorems identifying them with actual equilibrium values. |
| `GeneralMarkovValueEquilibrium` (`Equilibrium.lean:146-176`) | Add statewise assumptions/reservation rules through a companion structure or theorem hypotheses before changing the existing record. |
| `SimulationPath` (`Equilibrium.lean:181-199`) | Keep as an accounting interface; add a stronger `ModelSimulationPath` constructed from state and employment-measure dynamics. |

### Rename or deprecate after replacements exist

| Existing declaration | Proposed treatment |
|---|---|
| `dispersionCutoffResponse` (`Definitions.lean:151-157`) | Rename/alias to `dispersionCutoffResponseRHS` until a derivative-equality theorem exists. The current name overstates what is defined. |
| `aggregateShock_negative_comovement` (`Results.lean:378-386`) | Retain theorem body under a neutral name such as `movesOpposite_of_lt_of_gt`; deprecate the economic name after a genuine aggregate-shock theorem is added. |
| `dispersionShock_positive_comovement` (`Results.lean:388-396`) | Retain under `movesTogether_of_lt_of_lt`; reserve the economic name for a model theorem. |
| `TwoStateEquilibrium` (`Equilibrium.lean:90-98`) | Do not delete. Consider aliasing/documenting it as `OrderedTwoStateCandidate` because its main orderings are fields and its primitives may all differ. |
| raw `dF` naming (`Definitions.lean:39-40`) | Keep field for compatibility; expose `shockMeasure` as an accessor/alias. |

### Replace only in the long term

- Raw real transition matrices plus separate row proofs should eventually be replaced by a
  bundled stochastic matrix/kernel. Mathlib defines row-stochastic matrices in
  `.lake/packages/mathlib/Mathlib/LinearAlgebra/Matrix/Stochastic.lean:59`.
- A future structural-primitives record should separate state-invariant primitives from
  `aggregateProductivity : State → ℝ`; do this only after conversion functions allow old
  declarations to remain usable.

## 3. Milestone group A: immediate algebra and order theory

These results require no new measure theory if they work from existing equation fields.

### A1. Actual-surplus difference theorem - **recommended first**

**Goal**

For `A : Assumptions P` and `E : ValueEquilibrium P`, prove:

```text
E.S ε₂ - E.S ε₁ = P.σ * (ε₂ - ε₁) / (P.r + P.λ).
```

**Method**

- use the already proved `E.surplus_bellman`
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:24-38`);
- specialize it at `ε₁` and `ε₂`;
- subtract the equations so continuation and search terms cancel;
- divide by `r+λ`, positive from `A.r_pos` and `A.λ_nonneg`.

**Acceptance tests**

- theorem elaborates without `sorry`;
- proof uses only `ValueEquilibrium.surplus_bellman`, `price`, and sign assumptions;
- no integrability hypotheses are added, because the integral cancels;
- add `assert_no_sorry` for the new theorem.

**Why first**

It is small, proves a fact about the actual equilibrium surplus rather than the parallel
formula, and is the first missing edge to paper equation (12).

### A2. Actual surplus equals `S_cutoff`

From A1 and `E.cutoff_zero` (`Equilibrium.lean:48`), prove:

```text
E.S ε = P.S_cutoff E.εd ε.
```

Then derive:

- actual surplus strict monotonicity;
- `E.S ε ≥ 0 ↔ E.εd ≤ ε` as a theorem, showing the existing reservation field is
  redundant for constructed equilibria;
- actual firm/worker shares equal the closed-form shares by surplus identity and Nash
  sharing.

No measure theory is required.

### A3. Complete the free-entry bridge to equation (13)

Combine:

- `vacancy_free_entry_value` (`Results.lean:49-62`);
- actual `J(εu)=(1-β)S(εu)`;
- A2 at `εu`;
- existing algebra in `jobCreation_iff_freeEntryValue`
  (`Results.lean:121-145`).

Prove every suitable `ValueEquilibrium` satisfies
`P.JobCreationCondition E.θ E.εd`. This upgrades equation (13) from a record field to a
derived result.

### A4. Beveridge equivalence

The current direction (14) -> balanced flows is proved
(`Results.lean:337-351`). Add the converse:

```text
unemploymentDrift θ εd u = 0
  ↔ BeveridgeCondition θ εd u
```

under positive denominator. This is field algebra using
`beveridge_denominator_pos` (`Results.lean:284-289`).

### A5. Elementary tail bound (Appendix A4)

Prove:

```text
0 ≤ optionValueIntegral εd
optionValueIntegral εd ≤ εu - εd
```

under `εd≤εu`, CDF bounds, and interval integrability. The order part uses Mathlib's
interval-integral monotonicity
(`.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/IntervalIntegral/Basic.lean:1427-1432`).

### A6. Neutralize circular economic theorem names

Add generic aliases:

- `movesOpposite_of_first_increases_second_decreases`;
- `movesTogether_of_both_increase`;
- `periodDestruction_gt_ongoing_of_immediate_pos`.

Keep existing theorems for compatibility, but make future economic results compose these
generic lemmas rather than cite their current economic names.

## 4. Milestone group B: probability and measure theory

### B1. Probability-law adapter

Without replacing `Primitives`, define a companion predicate/structure:

```text
PaperShockLaw P
  [IsProbabilityMeasure P.dF]
  NoAtoms P.dF
  P.dF (Iic P.εu) = 1
  Integrable id P.dF
  integral id = 0
  Integrable (fun x => x^2) P.dF
  integral (fun x => x^2) = 1
```

Prove from it:

- `F_nonneg`, `F_le_one`, and `F_monotone`;
- `dF {εd}=0`;
- equality of `dF(Iic εd)` and `dF(Iio εd)`;
- CDF continuity at every point if convenient.

Mathlib already exposes `NoAtoms`/`NullSingletonClass`
(`.lake/packages/mathlib/Mathlib/MeasureTheory/Measure/Typeclasses/NullSingletonClass.lean:16-34`)
and probability-measure infrastructure.

### B2. Positive-continuation integrability

For affine `S_cutoff` and upper-bounded support, prove integrability of
`max (S_cutoff εd x) 0`. Avoid a global assumption on every arbitrary `S`.

### B3. Tail-expectation identity

Prove the specialized result:

```text
∫ x, max (S_cutoff εd x) 0 ∂dF
  = (σ/(r+λ)) * ∫ x in εd..εu, (1-F x).
```

Use a bounded-support layer-cake or Stieltjes integration argument. Relevant Mathlib
areas include:

- `.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/Layercake.lean`;
- `.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/IntervalIntegral/IntegrationByParts.lean`;
- interval FTC at
  `.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/IntervalIntegral/FundThmCalculus.lean`.

Do not generalize beyond the exact affine threshold form until the specialized proof is
complete.

### B4. Derive equations (9) and (10)

Substitute A2 and B3 into the actual surplus Bellman equation, evaluate at the cutoff,
and combine with free entry. Target the existing predicate
`JobDestructionCondition` (`Definitions.lean:143-149`).

The result should be a theorem:

```text
valueEquilibrium_jobDestructionCondition
  (A) (shockLaw) (E) :
  P.JobDestructionCondition E.θ E.εd
```

At this point both (10) and (13) are derived from the same `ValueEquilibrium`.

### B5. Cutoff-atom correction

Until B1 is available, do not prove hazard/cutoff equivalences that silently identify
`Iic` and `Iio`. Once atomlessness is established, prove the endpoint equality and
document why `destructionHazard` remains compatible with the weak reservation rule.

If the project ultimately wants atoms, introduce a strict-CDF hazard and explicitly
choose whether zero-surplus jobs separate; this would correct/extend rather than merely
formalize the paper.

## 5. Milestone group C: existence, monotonicity, and implicit functions

### C1. Residual functions and economic domain

Define residuals without changing existing predicates:

```text
jobDestructionResidual P theta cutoff
jobCreationResidual P theta cutoff
```

Prove each existing condition is equivalent to its residual being zero. Choose explicit
domains:

- `theta ∈ Ioi 0`;
- `cutoff ∈ Iio P.εu`, with a lower compact bound or a coercivity condition.

### C2. Curve monotonicity

- retain `jobCreationCurve_slopes_down` (`Results.lean:147-188`);
- prove the JD locus rises under explicit tail-integral monotonicity;
- strengthen weak results only when strict CDF/matching assumptions justify strictness.

This step should prefer order comparisons over derivatives.

### C3. Steady-state existence

Prove a root/intersection using continuity and boundary signs. The theorem should return
an actual witness, not add `Nonempty` as an assumption:

```text
exists_steadyStateEquilibrium
  (paperPrimitives) (boundaryConditions) :
  Nonempty (SteadyStateEquilibrium P)
```

If the paper's claim “at all nonnegative dispersion” requires stronger matching boundary
conditions than stated, record and expose them rather than overclaiming.

### C4. Steady-state uniqueness

Use strict JD/JC crossing to prove uniqueness of `(θ,εd)`. `u` then follows uniquely from
the Beveridge equation and denominator positivity. If global uniqueness cannot be proved
under paper assumptions, weaken the published statement to local uniqueness or add a
clearly named sufficient condition.

### C5. Aggregate productivity comparative statics

Define paired equilibria that share all structural primitives and differ only in `p`.
Prove:

```text
pLow < pHigh
  -> thetaLow < thetaHigh
  -> cutoffHigh < cutoffLow.
```

Then compose existing generic flow monotonicity to derive strict creation/destruction
co-movement results. Do not use `TwoStateEquilibrium.θ_order` or `.εd_order` as inputs.

### C6. Dispersion comparative statics and equation (11)

Two tracks:

1. **Monotone/global where possible:** prove paired-equilibrium orderings without
   derivatives under a sufficient condition such as `p≥b`.
2. **Local derivative contract:** define JD/JC residuals as a bivariate system, use
   Mathlib's implicit-function theorem
   (`.lake/packages/mathlib/Mathlib/Analysis/Calculus/ImplicitFunction/Bivariate.lean:14-20`),
   derive Appendix (A9)-(A12), and finally prove that the existing
   `dispersionCutoffResponseRHS` equals the fixed-`θ` derivative in (11).

If CDF continuity is unavailable at a cutoff, use a one-sided derivative or weaken the
statement; do not assert classical differentiability across atoms.

### C7. Remaining Appendix comparative statics

- A1-A4: higher `λ` lowers cutoff and tightness;
- A5-A8: higher `r` lowers tightness, with cutoff sign not determined;
- formalize “ambiguous” either as absence of a theorem under assumptions plus two valid
  parameter witnesses, or as explicit conditional sign criteria.

## 6. Milestone group D: anticipated and Markov equilibria

### D1. Two-state value specialization

Add a concrete two-state type and specialize `GeneralMarkovValueEquilibrium` to it. Prove
the specialized Bellman equation yields regional equations (16)-(18), using statewise
reservation rules.

Do not replace `AnticipatedTwoStateEquilibrium`; construct it from the value specialization
after deriving (20), (24), (28), and (30).

### D2. Derive equations (19)-(30)

Ordered proof sequence:

1. regional surplus derivative identities (21);
2. integrated formulas (19), (22);
3. cross-state value (23);
4. destruction equations (20), (24);
5. linear relations (25), (26);
6. recession surplus (27) and creation (28);
7. boom surplus (29) and creation (30).

Reuse B3's tail-integral machinery. Existing definitions at
`Definitions.lean:166-212` remain the target predicates/formulas.

### D3. Anticipation results

Retain:

- `boomJobCreation_zero_transition_iff` (`Results.lean:209-220`);
- `anticipation_reduces_boom_tightness` as an explicitly fixed-cutoff theorem
  (`Results.lean:222-282`).

Add separately:

- endogenous cutoff-gap response to `μ`;
- high/low tightness ordering;
- exact conditions under which anticipation dampens creation cyclicality.

The paper uses “likely” for part of the full endogenous-cutoff claim; formalization may
need to keep that statement conditional rather than forcing a universal theorem.

### D4. General Markov closure

Supplement `GeneralMarkovValueEquilibrium` with:

- `∀s, PaperShockLaw (P s)` or a state-invariant shock law;
- statewise reservation sign and cutoff uniqueness;
- bundled stochastic kernel;
- proof that the `max` continuation integral equals the paper's truncated current-state
  integral.

General existence may be postponed. The first green Markov target should be a finite
witness, not an abstract fixed-point theorem.

## 7. Milestone group E: finite-state dynamics and numerical witnesses

### E1. Employment-measure state and equation (35)

Use:

```text
employmentMeasure : Nat -> Measure Real
employment : Nat -> Real
employment t = employmentMeasure t univ
```

Define the update by:

- restricting old employment to the surviving cutoff region;
- applying the no-shock survival weight;
- adding redraw mass distributed by `shockMeasure`;
- adding newly created jobs at the upper-support entry point if required by timing.

Prove nonnegativity, finiteness, support preservation, and total-mass accounting. Derive
the paper's density form only under absolute continuity.

### E2. Full equations (36)-(38)

Construct a stronger path record from:

- an aggregate-state path;
- a Markov equilibrium;
- the employment-measure update.

Derive:

- creation (36);
- both terms of destruction (37);
- employment identity (38);
- current `SimulationPath` as a projection.

This retains the existing accounting record (`Equilibrium.lean:181-199`) without treating
its arbitrary `D_ongoing` as a model solution.

### E3. Concrete `Fin 3` calibration

Define exact finite data:

- productivity deviations;
- matrix (39), with a proof of row-stochasticity;
- uniform shock law on `[-1,1]`;
- Table I parameters;
- matching form (40).

This layer is **finite-witness-specific** and must not enter general assumptions.

### E4. Certified equilibrium vector (42)

Choose one of:

- interval arithmetic proving a solution lies in small boxes around the reported values;
- rational candidate vectors with certified residual bounds and a local uniqueness
  theorem;
- a verified nonlinear solver if infrastructure justifies it.

Do not claim exact equality to rounded decimal values.

### E5. Simulation reproduction

Specify:

- timing convention;
- RNG/seed;
- 100 samples of 66 quarters;
- creation/destruction rate normalization;
- mean, sample standard deviation, and correlation definitions.

Separate:

- deterministic correctness of the transition/update code;
- reproduced numerical output;
- probabilistic claims about standard errors.

## 8. Statements that may need correction or weakening

| Paper/current wording | Risk | Formal recommendation |
|---|---|---|
| Unique joint equilibrium from (10),(13) | Paper does not list all global boundary/regularity conditions. | Prove under explicit sufficient conditions; otherwise state local uniqueness. |
| Equation (11) as a derivative | Requires CDF continuity and an equilibrium branch. | Prove a one-sided/local derivative under atomlessness; keep RHS-only definition clearly named until then. |
| `p≥b` sufficient for cutoff response | Uses Appendix elasticity and mean normalization omitted in Lean. | State the complete assumptions; do not reuse the current stronger fixed-`θ` net-price theorem as if equivalent. |
| Anticipation reduces creation cyclicality | Paper qualifies endogenous-cutoff effect as “likely.” | Keep a universal fixed-cutoff theorem and a conditional full-equilibrium theorem. |
| Interest-rate effect on cutoff is “ambiguous” | Non-sign is not itself a theorem without counterexamples or a conditional formula. | Prove formula (A8) and exhibit both-sign finite witnesses, or state only the conditional sign expression. |
| Density law (35) for general `F` | Paper previously assumes no mass points but not necessarily a density. | Use a measure-valued law as primary; derive density form under absolute continuity. |
| Rounded vector (42) is a solution | Rounded decimals will not satisfy nonlinear equations exactly. | Certify enclosures/residuals, not exact equality. |

## 9. Ordered implementation sequence

| Order | Milestone | Mathematical class | Existing declarations affected |
|---:|---|---|---|
| 1 | A1-A2: actual surplus difference and equality with `S_cutoff` | Elementary algebra/order | Retain; add theorems beside `ValueEquilibrium` results. |
| 2 | A3-A4: derive (13), Beveridge equivalence | Elementary algebra/field manipulation | Retain existing predicates and lemmas. |
| 3 | B1: paper shock-law adapter and derived CDF facts | Measure/probability | Supplement `Assumptions`; later deprecate redundant fields. |
| 4 | B2-B4: tail identity and derive (9),(10) | Measure/integration | Retain `positiveContinuation`, tail integrals, and JD predicate. |
| 5 | C1-C4: residuals, existence, uniqueness | Continuity/monotonicity | Add constructors/theorems for `SteadyStateEquilibrium`. |
| 6 | C5: aggregate-`p` comparative statics | Order/monotone comparative statics | Generalize away from supplied order fields. |
| 7 | C6-C7: dispersion, equation (11), Appendix | FTC/implicit functions | Rename RHS definition; add derivative theorems. |
| 8 | D1-D3: two-state value bridge and anticipation | Measure + finite-state algebra | Retain existing anticipated predicates/record as targets. |
| 9 | D4: Markov closure | Finite sums/probability | Supplement general Markov record. |
| 10 | E1-E2: employment measure and full dynamics | Measure transitions | Construct stronger path; project to current `SimulationPath`. |
| 11 | E3-E5: calibration and simulation | Finite numerical witnesses | New calibration namespace only. |

## 10. Single best first Lean milestone

**Prove paper equation (12) for the actual `ValueEquilibrium.S`.**

Concretely, add:

1. `ValueEquilibrium.surplus_sub_surplus`;
2. `ValueEquilibrium.surplus_eq_S_cutoff`.

This is the best first milestone because it:

- requires only algebra and existing sign assumptions;
- does not require new measure theory, dependencies, or a structural rewrite;
- converts `S_cutoff` from a parallel formula into a theorem about the actual value
  equilibrium;
- unlocks the genuine equation (13) free-entry bridge;
- provides strict surplus monotonicity and the foundation for cutoff uniqueness;
- is the first necessary step toward deriving equation (10).
