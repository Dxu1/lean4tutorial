# MP1994 Normalized Notation Table

Repository root: `/Users/davidxu/Documents/lean4tutorial`  
Lean source base: `Lean4Tutorial/i002_replicate_MP`

Naming policy:

- preserve paper symbols in documentation but use descriptive ASCII aliases where a
  symbol is overloaded;
- reserve `theta`/`θ` for market tightness, never for the paper's matching elasticity;
- distinguish a probability measure (`shockMeasure`) from its CDF (`shockCDF`) and any
  density (`shockDensity`);
- distinguish state-invariant structural primitives from state-contingent aggregate
  productivity;
- distinguish continuous-time rates from discrete-period probabilities;
- use finite measures for employment distributions, with densities only as derived
  representations.

## 1. Primitive and state-invariant objects

| Paper symbol | Economic meaning | Mathematical type/domain | Current Lean identifier | Proposed normalized Lean identifier | Current representation issues | Required restrictions |
|---|---|---|---|---|---|---|
| `r` | Continuous-time discount rate | `ℝ`, economically positive | `Primitives.r` (`Definitions.lean:23-24`) | `discountRate` | Unconstrained in `Primitives`; positivity is detached in `Assumptions` (`Definitions.lean:253-254`). | `0 < discountRate`. |
| `λ` | Idiosyncratic shock arrival rate | `ℝ≥0` or `NNReal` | `Primitives.«λ»` (`Definitions.lean:25-26`) | `idiosyncraticArrivalRate` | Stored as `ℝ`; no Poisson process is constructed. | Nonnegative; distinguish rate from period probability. |
| `σ` | Idiosyncratic productivity dispersion | `ℝ>0` | `Primitives.σ` (`Definitions.lean:27-28`) | `shockScale` or `dispersion` | Called a standard deviation without mean/variance assumptions. | Positive; standardized shock has mean zero and variance one. |
| `β` | Worker's Nash share | open unit interval | `Primitives.β` (`Definitions.lean:29-30`) | `workerShare` | Stored as unconstrained `ℝ`; bounds detached. | `0 < workerShare ∧ workerShare < 1`. |
| `c` | Vacancy flow cost | `ℝ>0` | `Primitives.c` (`Definitions.lean:31-32`) | `vacancyCost` | Positivity detached. | Positive and finite. |
| `b` | Leisure value / unemployment income | `ℝ` | `Primitives.b` (`Definitions.lean:33-34`) | `unemploymentIncome` | No issue as scalar, but cross-state invariance is not enforced in `TwoStateEquilibrium`. | Usually state-invariant in the aggregate-`p` experiment. |
| `εu` | Upper support point of idiosyncratic shocks | `ℝ` | `Primitives.εu` (`Definitions.lean:37-38`) | `shockUpper` | Only all mass below the point is assumed; support-boundary membership is not. | Finite upper support; preferably `shockUpper ∈ support shockMeasure`. |
| `F` as law | Idiosyncratic shock probability law | `Measure ℝ` with probability instance | `Primitives.dF` (`Definitions.lean:39-40`) | `shockMeasure` | Named `dF`, which suggests a differential/density; probability is a detached equality. | `IsProbabilityMeasure`; atomless; finite moments; support bound. |
| `F(x)` | Cumulative distribution function | monotone `ℝ → [0,1]` | `Primitives.F` (`Definitions.lean:48-50`) | `shockCDF` | Returns `ℝ` via `ENNReal.toReal`; bounds/monotonicity are duplicated assumptions. | Derive from a probability measure; choose `Iio`/`Iic` convention explicitly. |
| `F'(x)` | Density used in paper (35) | `ℝ → ℝ≥0`, if it exists | none | `shockDensity` | Current model has a measure/CDF but no density or absolute continuity. | `shockMeasure ≪ volume`; Radon-Nikodym derivative; integrability. |
| `ε` | Realized standardized idiosyncratic component | `ℝ` in support | function argument `ε` | `shock` | Functions accept all reals. | Membership in support only where economically needed. |
| `q(θ)` | Vacancy meeting rate | positive function on `ℝ>0` | `Primitives.q` (`Definitions.lean:41-42`) | `vacancyMeetingRate` | Arbitrary real function; weak antitonicity only. | Continuity; strict decrease; positive; elasticity in `(-1,0)`. |
| `m(v,u)` | Aggregate matching flow | nonnegative homogeneous function | `Primitives.m` (`Definitions.lean:60-62`) | `matches` | Defined from `q`; accepts negative stocks and division by zero. | `v,u≥0`; CRS; boundary conventions. |
| `m(θ,1)=θq(θ)` | Worker meeting rate | positive function on `ℝ>0` | `Primitives.mWorker` (`Definitions.lean:56-58`) | `workerMeetingRate` | Only weak monotonicity is assumed. | Continuous and strictly increasing under elasticity restriction. |
| `η` in Appendix | Absolute elasticity `-θq'(θ)/q(θ)` | `(0,1)` | none | `matchingElasticity` | Paper also uses a symbol visually resembling `θ` in Section 5; collision risk with tightness. | Differentiable `q`, `q>0`, `0<η<1`. |
| `k` | Matching scale in calibration | `ℝ>0` | none | `matchingScale` | Absent. | Positive; finite-state-witness-specific. |

## 2. Aggregate-state primitives and transition objects

| Paper symbol | Economic meaning | Mathematical type/domain | Current Lean identifier | Proposed normalized Lean identifier | Current representation issues | Required restrictions |
|---|---|---|---|---|---|---|
| `p` | Aggregate productivity/common price | `ℝ`; scalar or state function | `Primitives.p` (`Definitions.lean:35-36`); also explicit `p` (`Equilibrium.lean:104-107`) | state-invariant record omits `p`; use `aggregateProductivity : State → ℝ` | Duplicated: `P.p` coexists with explicit `p,pStar` in anticipated structure. | Decide one source of truth; other structural primitives fixed across pure `p` states. |
| `p*` | Boom productivity | `ℝ` | `AnticipatedTwoStateEquilibrium.pStar` (`Equilibrium.lean:106-107`) | `aggregateProductivity boom` | Explicit scalar not tied to `P.p`. | `pLow < pHigh`. |
| `μ` | Aggregate-state Poisson arrival rate | `State → ℝ≥0` | fields in `AnticipatedTwoStateEquilibrium` and `GeneralMarkovValueEquilibrium` (`Equilibrium.lean:108-109`, `Equilibrium.lean:152-158`) | `aggregateArrivalRate` | Stored as `ℝ`; relationship to transition kernel semantics unstated. | Nonnegative; clarify whether self-transitions are permitted. |
| `G(y|p)` | Conditional distribution of next aggregate state | Markov kernel; finite case row-stochastic matrix | `G : State → State → ℝ` (`Equilibrium.lean:139-142`, `Equilibrium.lean:154-160`) | `transitionProb` | Two structures use `tsum` versus finite `sum`; entries are reals. | Nonnegative rows sum to one; finite case can use `Matrix`. |
| `πij` | Three-state transition matrix (39) | `Matrix (Fin 3) (Fin 3) ℚ/ℝ` | none | `calibrationTransition` | Missing. | Exact nonnegativity and row-sum proofs. |
| `zi` | Productivity deviations in three states | `Fin 3 → ℝ` | none | `productivityDeviation` | Missing. | Values `(-0.053,0,0.053)`; finite witness. |
| `State` | Aggregate state space | general type / finite type | parameters to Markov structures (`Equilibrium.lean:136`, `Equilibrium.lean:147`) | `AggregateState`; concrete `Fin 2`, `Fin 3` aliases | `MarkovEquilibrium` is general; value equilibrium requires `Fintype`; no concrete state. | `Fintype` for finite sums and numerical witnesses; decidable equality as needed. |

## 3. Endogenous stationary and value objects

| Paper symbol | Economic meaning | Mathematical type/domain | Current Lean identifier | Proposed normalized Lean identifier | Current representation issues | Required restrictions |
|---|---|---|---|---|---|---|
| `v` | Vacancy stock/rate | `[0,1]` or `ℝ≥0` | `SteadyStateEquilibrium.v` (`Equilibrium.lean:72-73`) | `vacancyStock` | Defined as `θu`; no upper bound. | Nonnegative; normalization-specific bound if a rate. |
| `u` | Unemployment stock/rate | `[0,1]` | `SteadyStateEquilibrium.u` (`Equilibrium.lean:58-63`) | `unemploymentRate` | Bounds are fields, which is appropriate for a solution record. | `0≤u≤1`; positive when `θ=v/u` is used literally. |
| `n=1-u` | Employment stock/rate | `[0,1]` | `SteadyStateEquilibrium.n` (`Equilibrium.lean:75-76`) | `employmentRate` | Definitional only. | Follows from `u` bounds. |
| `θ=v/u` | Market tightness | `ℝ>0` | `Primitives.θ`; equilibrium field `θ` (`Definitions.lean:52-54`, `Equilibrium.lean:20`, `Equilibrium.lean:55`) | `marketTightness` | Same glyph can be confused with paper matching elasticity; ratio undefined at `u=0`. | Positive; either primitive ratio proof or treat as endogenous scalar with `v=θu`. |
| `εd` | Destruction/reservation cutoff | `ℝ`, below `εu` | equilibrium fields `εd` (`Equilibrium.lean:21-22`, `Equilibrium.lean:56-61`) | `destructionCutoff` | Existence, uniqueness, lower support, and cutoff convention not proved. | `< shockUpper`; zero crossing; atomless law or strict/weak convention. |
| `εd*` | Boom destruction cutoff | `ℝ` | `AnticipatedTwoStateEquilibrium.εdStar` (`Equilibrium.lean:114-123`) | `destructionCutoff boom` | Ordering is a record field. | Derive ordering from state equations. |
| `V` | Vacancy asset value | `ℝ` | `ValueEquilibrium.V` (`Equilibrium.lean:23-24`) | `vacancyValue` | No finiteness/transversality semantics beyond scalar. | Stationary finite value; `r>0`. |
| `U` | Unemployment asset value | `ℝ` | `ValueEquilibrium.U` (`Equilibrium.lean:25-26`) | `unemploymentValue` | Scalar representation is adequate. | Finite value. |
| `J(ε)` | Firm value of filled job | `ℝ → ℝ` | `ValueEquilibrium.J` (`Equilibrium.lean:27-28`) | `firmValue` | No regularity; not connected to `J_cutoff`. | Measurable/continuous; zero at cutoff; nonnegative above. |
| `W(ε)` | Worker value of employment | `ℝ → ℝ` | `ValueEquilibrium.W` (`Equilibrium.lean:29-30`) | `workerValue` | No regularity. | Measurable/finite. |
| `w(ε)` | Wage | `ℝ → ℝ` | `ValueEquilibrium.w` (`Equilibrium.lean:31-32`) | `wage` | No regularity or derived wage formula. | Measurable/finite. |
| `S(ε)` | Total match surplus | `ℝ → ℝ` | `ValueEquilibrium.S` (`Equilibrium.lean:33-34`) | `matchSurplus` | Reservation sign is a field; no equality with closed form. | Measurable/continuous/strictly increasing; integrable positive part. |
| `S_d(ε;εd)` | Closed-form stationary surplus | `ℝ → ℝ` | `Primitives.S_cutoff` (`Definitions.lean:84-86`) | `stationarySurplusFormula` | Parallel to, not identified with, `ValueEquilibrium.S`. | `r+λ>0`; bridge theorem. |
| `J_d` | Firm share of closed-form surplus | `ℝ → ℝ` | `Primitives.J_cutoff` (`Definitions.lean:88-90`) | `stationaryFirmValueFormula` | Parallel to actual `J`. | Bridge via sharing and surplus identity. |
| `W-U` | Worker surplus gain | `ℝ → ℝ` | `Primitives.WminusU_cutoff` (`Definitions.lean:92-94`) | `stationaryWorkerGainFormula` | Parallel to actual `W-U`. | Bridge theorem. |
| `S*(ε)` | Boom/high-state surplus | `ℝ → ℝ` | formula `Primitives.boomSurplus` (`Definitions.lean:195-201`); general `S ε s` (`Equilibrium.lean:150-151`) | `matchSurplus ε high` | Formula not connected to state surplus field. | State Bellman equations and derivation of (29). |
| `C` | Gross job-creation flow | `ℝ≥0` | `creationFlow`; `SteadyStateEquilibrium.C` (`Definitions.lean:220-222`, `Equilibrium.lean:78-79`) | `creationFlow` | General function accepts invalid `u`; strict shock result not derived. | `u≥0`, worker rate nonnegative. |
| `D` | Gross job-destruction flow | `ℝ≥0` | `destructionFlow`; `SteadyStateEquilibrium.D` (`Definitions.lean:224-226`, `Equilibrium.lean:81-83`) | `destructionFlow` | Uses `F(Iic εd)` despite weak cutoff acceptance; accepts invalid `u`. | Atomless or `Iio`; `u≤1`; nonnegative rate. |
| `s(εd)=λF(εd)` | Separation hazard | `ℝ≥0` | `destructionHazard` (`Definitions.lean:80-82`) | `separationRate` | Cutoff-atom issue. | Atomless law or strict-CDF convention. |
| `u̇` | Continuous-time unemployment drift | vector field / derivative | `unemploymentDrift` (`Definitions.lean:228-230`) | `unemploymentDrift`; path derivative separately | Only RHS is defined, not an ODE solution. | Local Lipschitz/continuity for existence; state invariance. |

## 4. Probability, integral, and expectation notation

| Paper symbol | Economic meaning | Mathematical type/domain | Current Lean identifier | Proposed normalized Lean identifier | Current representation issues | Required restrictions |
|---|---|---|---|---|---|---|
| `∫ max(S(x),0)dF(x)` | Expected positive continuation surplus | `ℝ`, Bochner/Lebesgue integral | `positiveContinuation` (`Definitions.lean:76-78`) | `expectedPositiveSurplus` | No measurability/integrability contract. | AEStronglyMeasurable/integrable positive part; probability measure. |
| `∫_{εd}^{εu}(1-F(x))dx` | Option-value tail integral | `ℝ`, interval integral w.r.t. Lebesgue | `optionValueIntegral` (`Definitions.lean:68-70`) | `shockTailIntegralFromCutoff` | No theorem connects it to expected surplus. | Measurable CDF; ordered bounds; integrability. |
| `∫_l^h(1-F(x))dx` | Bounded tail integral | `ℝ` | `tailIntegral` (`Definitions.lean:72-74`) | `shockTailIntegral` | Oriented integral permits reversed bounds; conditions live elsewhere. | Explicit `l≤h` where interpreted as positive option value. |
| `E(ε)` | Mean standardized shock | `ℝ` | none | `shockMean` theorem | Mean-zero normalization missing. | Integrable identity function; equals zero. |
| `Var(ε)` | Unit standardized variance | `ℝ≥0` | none | `shockVariance` theorem | Missing. | Square integrable; equals one. |
| `E(ε | ε≥εd)` | Conditional tail mean in (A11) | `ℝ` | none | `conditionalShockMeanAbove` | Conditional expectation infrastructure absent. | Positive tail probability; integrability. |

## 5. Dynamic, Markov, and simulation objects

| Paper symbol | Economic meaning | Mathematical type/domain | Current Lean identifier | Proposed normalized Lean identifier | Current representation issues | Required restrictions |
|---|---|---|---|---|---|---|
| `a(p)` | Worker job-finding rate in aggregate state | `State → ℝ≥0` | no standalone field; represented by `mWorker (θ s)` (`Equilibrium.lean:161-164`) | `jobFindingRate` | `SimulationPath.a` is arbitrary and not linked to equilibrium (`Equilibrium.lean:184-195`). | Equal to worker meeting rate; nonnegative; period conversion specified. |
| `εd(p)` | State-contingent destruction cutoff | `State → ℝ` | `GeneralMarkovValueEquilibrium.εd` (`Equilibrium.lean:148-149`) | `destructionCutoff` | Only cutoff-zero, no reservation rule/uniqueness. | Statewise upper bound, sign rule, uniqueness. |
| `S(ε,p)` | State-contingent surplus | `ℝ → State → ℝ` | `GeneralMarkovValueEquilibrium.S` (`Equilibrium.lean:150-151`) | `matchSurplus` | Argument order is acceptable; no regularity. | Statewise measurability/integrability/continuity. |
| `n_t(ε)` | Employment distribution/density at time `t` | preferably `Measure ℝ`; density if AC | only argument to `immediateScrapping` (`Definitions.lean:236-239`) | `employmentMeasure : ℕ → Measure ℝ` | Current `n : ℝ→ℝ` is not required nonnegative/integrable and has no path law. | Finite nonnegative measure; mass equals employment; support restrictions. |
| `N_t` | Total employment at start of period | `[0,1]` | `SimulationPath.N : ℕ → ℝ` (`Equilibrium.lean:182-183`) | `employment : ℕ → ℝ` | No bounds or relationship to employment distribution. | `0≤N_t≤1`; equals total mass. |
| `C_t` | Period creation flow | `ℝ≥0` | `SimulationPath.C` (`Equilibrium.lean:190-195`) | `periodCreationFlow` | Law uses arbitrary `a_t`. | Link to aggregate state and equilibrium job-finding rate. |
| `D_t^immediate` | One-off scrapping after cutoff rise | `ℝ≥0` | `SimulationPath.D_immediate` (`Equilibrium.lean:186-187`) | `immediateDestruction` | Arbitrary sequence; integral definition not required by record. | Derived from restricted employment measure and ordered cutoffs. |
| `D_t^ongoing` | Redraw-induced destruction | `ℝ≥0` | `SimulationPath.D_ongoing` (`Equilibrium.lean:188-189`) | `ongoingDestruction` | Completely unconstrained. | Exact second term of paper (37), tied to hazard and surviving employment. |
| `D_t` | Total period destruction | `ℝ≥0` | `SimulationPath.D` (`Equilibrium.lean:192-197`) | `periodDestructionFlow` | Only additive accounting is required. | Derived from transition operator; feasibility. |
| path aggregate state | Markov state at period `t` | `ℕ → State` | none | `aggregateStatePath` | Missing, so paths cannot select `p_t,θ_t,εd_t`. | Markov transition law or fixed realized path. |
| simulation seed/sample | Monte Carlo realization | finite random stream | none | `simulationConfig`, `simulationSeed` | Missing. | Reproducible RNG semantics; sample length/count. |
| sample moments | mean, SD, correlation | real statistics on finite vectors | none | `mean`, `sampleStdDev`, `sampleCorrelation` | Missing. | Nonzero variance for correlation; normalization convention. |

## 6. Structural separation recommended for future Lean

The current `Primitives` record mixes state-invariant structural primitives with the
aggregate productivity scalar (`Definitions.lean:21-43`). A non-wholesale normalization
can retain it while introducing views:

```text
StructuralPrimitives
  discountRate, idiosyncraticArrivalRate, shockScale,
  workerShare, vacancyCost, unemploymentIncome,
  shockUpper, shockMeasure, vacancyMeetingRate

AggregateEnvironment State
  aggregateProductivity : State -> Real
  aggregateArrivalRate  : State -> NNReal
  transitionProb        : State -> State -> NNReal

EquilibriumObjects State
  marketTightness, destructionCutoff,
  matchSurplus, unemploymentRate
```

For compatibility, existing declarations can initially receive conversion functions from
`Primitives`; a future deprecation can occur only after the bridge theorems exist. The
most urgent naming fix is to reserve `θ` for market tightness and call the Appendix/Section
5 matching elasticity `matchingElasticity`.
