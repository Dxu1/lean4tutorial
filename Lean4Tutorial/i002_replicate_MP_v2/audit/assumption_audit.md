# MP1994 Assumption Classification Audit

Repository root: `/Users/davidxu/Documents/lean4tutorial`  
Current assumptions record:
`Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`

## 1. Classification rule

- **Primitive**: an economic or stochastic input fixed before equilibrium is solved.
- **Analytic closure**: a temporary regularity fact needed to make a definition, integral,
  derivative, or existence argument rigorous. It should ultimately be proved from a
  cleaner representation or isolated in a theorem's hypotheses.
- **Desired conclusion**: a comparative static, equilibrium ordering, existence fact, or
  qualitative result that the development is supposed to prove. It must not be retained
  in a primitive assumptions record or equilibrium structure merely to make downstream
  theorems compile.
- **Redundant / derivable**: follows from another representation or stronger field and
  should be proved rather than independently supplied.
- **Finite-witness-specific**: calibration data or a property needed only for a concrete
  `Fin n` construction, not for the general theory.

## 2. Audit of every existing `Assumptions` field

| Existing field | Location | Classification | Keep/change | Reason |
|---|---|---|---|---|
| `r_pos : 0 < P.r` | `Definitions.lean:253-254` | **Primitive** | Keep, preferably in structural primitives or as a subtype. | Positive discounting is an economic input and makes `r`, `r+λ`, and value equations nondegenerate. |
| `λ_nonneg : 0 ≤ P.λ` | `Definitions.lean:255-256` | **Primitive** | Keep; consider `NNReal`. | A Poisson arrival rate is nonnegative. |
| `σ_pos : 0 < P.σ` | `Definitions.lean:257-258` | **Primitive** | Keep for the positive-dispersion theory; permit a separate `σ=0` boundary model if needed. | Positivity supports surplus slope and comparative statics. |
| `β_pos : 0 < P.β` | `Definitions.lean:259-260` | **Primitive** | Keep, ideally combined with `β_lt_one` as membership in `Set.Ioo 0 1`. | Bargaining share restriction. |
| `β_lt_one : P.β < 1` | `Definitions.lean:261-262` | **Primitive** | Keep with `β_pos`. | Ensures a positive firm share and nonzero denominator. |
| `c_pos : 0 < P.c` | `Definitions.lean:263-264` | **Primitive** | Keep. | Positive vacancy cost is part of the model and avoids the paper's degenerate free-entry case. |
| `dF_probability : P.dF univ = 1` | `Definitions.lean:265-266` | **Primitive representation, but structurally redundant** | Replace the equality field with `[IsProbabilityMeasure P.dF]` or a bundled probability measure. | Mathlib already has the probability-measure typeclass, used throughout `.lake/packages/mathlib/Mathlib/MeasureTheory` and `Probability`; maintaining a parallel equality loses infrastructure. |
| `dF_support_upper : P.dF (Iic P.εu) = 1` | `Definitions.lean:267-268` | **Primitive** plus analytic support closure | Keep in a more semantic form. | The paper assumes finite upper support. Prefer `P.dF (Iic shockUpper)=1` plus a support-boundary condition if entry at the “best” technology requires it. |
| `F_nonneg : ∀x, 0≤P.F x` | `Definitions.lean:269-270` | **Redundant / derivable** | Remove after proving it from the measure/CDF definition. | Measures are nonnegative and `ENNReal.toReal` is nonnegative for finite values. |
| `F_le_one : ∀x, P.F x≤1` | `Definitions.lean:271-272` | **Redundant / derivable** | Remove after deriving it from probability mass. | `dF(Iic x)≤dF(univ)=1`; Mathlib measure monotonicity supplies the main step. |
| `F_monotone : Monotone P.F` | `Definitions.lean:273-274` | **Redundant / derivable** | Remove after proving a CDF monotonicity lemma. | `Iic x⊆Iic y` for `x≤y`, so measure monotonicity gives the result. |
| `q_pos : ∀θ,0<θ→0<P.q θ` | `Definitions.lean:275-276` | **Primitive** | Keep, but restrict the function's economic domain. | Positive vacancy meeting rate is a matching-technology input. |
| `q_antitone : Antitone P.q` | `Definitions.lean:277-278` | **Primitive, weaker than paper** | Replace or supplement with strict antitonicity/differentiability when needed. | The paper assumes `q'<0`; weak antitonicity is enough for the current JC proof but not all derivative claims. |
| `mWorker_monotone : Monotone P.mWorker` | `Definitions.lean:279-280` | **Redundant / derivable under the paper's elasticity primitive** | Temporarily keep only if elasticity has not yet been formalized. | With differentiable positive `q` and elasticity in `(0,1)`, `θq(θ)` is strictly increasing. It should become a theorem, not a coequal primitive assumption. |

## 3. Missing primitive assumptions

| Required assumption | Classification | Why required | Where it enters | Recommended form |
|---|---|---|---|---|
| `dF` has no atoms | **Primitive** distributional restriction | Resolves `Iic` versus `Iio` at the cutoff and matches the paper. | Hazard/cutoff convention: `Definitions.lean:48-50`, `Definitions.lean:80-82`, `Equilibrium.lean:48-49`; tail integrations. | `[NoAtoms P.dF]` / Mathlib's alias of `NullSingletonClass`, available at `.lake/packages/mathlib/Mathlib/MeasureTheory/Measure/Typeclasses/NullSingletonClass.lean:16-34`. |
| Standardized shock mean is zero | **Primitive** normalization | Gives `σ` its scale interpretation and is essential in Appendix (A11). | Dispersion comparative statics. | `Integrable id P.dF` and `∫x,x∂P.dF=0`. |
| Standardized shock variance is one | **Primitive** normalization | Makes `σ` the standard deviation rather than an arbitrary scale. | Economic interpretation and calibration. | Square integrability and `∫x,x^2∂P.dF=1`, using mean zero. |
| Independent iid redraws | **Primitive** stochastic restriction | Justifies using one fixed `dF` after every idiosyncratic shock. | Bellman equations (5)-(8), distribution dynamics (35). | State as model semantics unless a full stochastic process is constructed. |
| State-invariance of non-`p` primitives | **Primitive** for aggregate-productivity experiments | Prevents a “productivity shock” theorem from changing `r,λ,σ,β,c,b,F,q` simultaneously. | `TwoStateEquilibrium`, currently `Equilibrium.lean:90-98`. | Use one structural-primitives record plus `aggregateProductivity : State→ℝ`. |
| Economic domains for stocks/rates | **Primitive/domain specification** | Prevents negative flows and undefined ratio interpretations. | `Definitions.lean:52-62`, `Equilibrium.lean:181-199`. | `0≤u≤1`, `0≤v`, positive `u` when using `v/u`; nonnegative rates. |
| Matching differentiability and elasticity in `(-1,0)` | **Primitive** technology restriction | Required for Appendix derivatives and strict worker-rate monotonicity. | A1-A12, uniqueness/comparative statics. | `DifferentiableOn ℝ q (Ioi 0)` plus `0 < -θ*q'/q < 1`. |

## 4. Analytic closure assumptions

These assumptions are not economic conclusions. They may be introduced locally to unblock
proofs, but each must name the theorem it temporarily substitutes for.

| Closure assumption | Why currently needed | Exact theorem it substitutes for | Mathlib infrastructure likely available | Intended future derivation |
|---|---|---|---|---|
| `Measurable P.F` / interval integrability of `1-P.F` | Makes the tail integrals behave as mathematical integrals rather than merely well-typed terms. | “A monotone real CDF is measurable and bounded on a finite interval, hence integrable.” | Monotone measurability and interval-integral infrastructure are in Mathlib; `intervalIntegral.integral_mono_on` is at `.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/IntervalIntegral/Basic.lean:1427-1432`. | Derive measurability from CDF monotonicity and integrability from boundedness/support. |
| `Integrable (max ∘ S) P.dF` | Needed for Bellman expectations and algebra moving constants through integrals. | “Positive continuation surplus has finite expectation.” | Bochner integral and probability-measure bounds are available; probability instances are used throughout Mathlib. | Derive from affine surplus plus bounded-above support, or keep as a theorem hypothesis for general `S`. |
| Continuity/strict monotonicity of `S` | Needed for cutoff existence/uniqueness and reservation equivalence. | “There exists a unique `εd` with `S εd=0`, and `S ε≥0 ↔ εd≤ε`.” | Intermediate value and strict monotone inverse/crossing results are standard Mathlib order/topology tools. | Derive the affine formula (12), then continuity and strict monotonicity follow algebraically from `σ>0`, `r+λ>0`. |
| Endpoint signs for surplus | Needed to prove a cutoff exists inside support. | `S(lower)≤0≤S(εu)` or an equivalent crossing condition. | Intermediate value infrastructure likely suffices once a lower domain is chosen. | Derive from primitive/equilibrium inequalities; if not derivable, state an economically interpretable entry/nondegeneracy condition. |
| Tail-expectation identity | Needed to pass from (8) to (9)/(10). | `∫ max(S x,0)dF = slope * ∫_{εd}^{εu}(1-F x)dx` for affine threshold surplus. | Mathlib has `MeasureTheory.Integral.Layercake` and interval integration-by-parts modules; local paths include `.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/Layercake.lean` and `.../IntervalIntegral/IntegrationByParts.lean`. | Prove a specialized bounded-support lemma first; generalize only if reuse warrants it. |
| FTC for moving lower endpoint | Needed for (11) and Appendix derivatives. | `d/dz ∫_z^u f(x)dx = -f(z)` under continuity at `z`. | `intervalIntegral.integral_hasStrictDerivAt_right` is documented at `.lake/packages/mathlib/Mathlib/MeasureTheory/Integral/IntervalIntegral/FundThmCalculus.lean:567`; parametric integral derivatives are in `.lake/packages/mathlib/Mathlib/Analysis/Calculus/ParametricIntervalIntegral.lean:56-97`. | Prove continuity of `1-F` where needed; atomlessness gives CDF continuity. Use one-sided derivatives if global continuity is too strong. |
| Differentiability of `q` | Needed for elasticity, IFT, and A1-A12. | `HasDerivAt q q' θ` and nonzero slope. | Ordinary calculus infrastructure is present. | Make it a matching-technology primitive rather than deriving it. |
| Local differentiable equilibrium branch | Needed to interpret `∂εd/∂σ` and all Appendix derivatives. | An implicit-function theorem for the JD/JC residual system. | Mathlib has bivariate/product-domain implicit function theorems at `.lake/packages/mathlib/Mathlib/Analysis/Calculus/ImplicitFunction/Bivariate.lean:14-20` and `ProdDomain.lean:13-21`. | Define a two-dimensional residual map, prove a nonsingular Jacobian, then obtain a local branch and derivative formula. |
| Continuity and boundary crossing of JD/JC residuals | Needed for steady-state existence. | Existence of a root/intersection. | Intermediate value, compactness, and monotone functions are mature Mathlib areas. | Choose explicit economic domains and prove opposite residual signs at boundaries. |
| Strict monotonicity/nonsingular crossing | Needed for uniqueness. | At most one joint equilibrium. | Order lemmas may avoid IFT for global uniqueness. | Use JD increasing and JC decreasing after representing both as graphs over a common domain. |
| Statewise reservation-sign rule | Needed to equate `max` expectation in Lean's (34) with the paper's truncated integral. | `0≤S(ε,s) ↔ εd(s)≤ε`. | Order reasoning is elementary once statewise surplus monotonicity is known. | Derive from the finite-state value equations or temporarily require it locally in the Markov structure. |
| Measure-valued employment transition well-defined | Needed for (35)-(38). | The update operator maps finite nonnegative employment measures to finite nonnegative measures and conserves accounting mass. | `Measure.map`, `Measure.restrict`, and Radon-Nikodym infrastructure are present throughout `.lake/packages/mathlib/Mathlib/MeasureTheory`; density support is in `Measure/WithDensity.lean`. | Define the update using restriction, scalar multiplication, and redraw measure; prove mass identity before deriving a density formula. |
| ODE/path existence and invariance | Needed for claims about eventual unemployment and between-shock convergence. | Existence/uniqueness of an integral curve and preservation of `[0,1]`. | Mathlib's ODE entry point describes integral curves at `.lake/packages/mathlib/Mathlib/Analysis/ODE/Basic.lean:14`. | The drift is affine in `u` for fixed state, so solve it explicitly before using general ODE machinery. |

## 5. Desired conclusions currently embedded as assumptions or hypotheses

These items must move out of records/hypothesis lists if the theorem is advertised as
deriving them.

| Current field/hypothesis | Location | Classification | Why it is a desired conclusion | Required replacement |
|---|---|---|---|---|
| `TwoStateEquilibrium.θ_order` | `Equilibrium.lean:97` | **Desired conclusion** | Higher aggregate productivity is supposed to cause higher tightness. | A theorem comparing two equilibria that share all non-`p` primitives. |
| `TwoStateEquilibrium.εd_order` | `Equilibrium.lean:98` | **Desired conclusion** | Lower boom cutoff is a main comparative-static result. | Derive from JD/JC monotone crossing. |
| `AnticipatedTwoStateEquilibrium.εdStar_lt_εd` | `Equilibrium.lean:122` | **Desired conclusion** unless the structure is explicitly called an “ordered candidate equilibrium” | It is a substantive two-state result. | Prove after existence/selection; temporarily rename the structure to disclose the supplied ordering. |
| `aggregateShock_flow_orders` hypotheses `hθ,hε` | `Results.lean:310-314` | **Desired conclusions** | They are precisely the equilibrium responses to an aggregate shock. | Split into a generic flow-monotonicity lemma and a model theorem supplying the orderings. |
| `dispersionShock_flow_orders` hypotheses `hθ,hε` | `Results.lean:322-326` | **Desired conclusions** | They are the Appendix conclusions for a dispersion change. | Prove A9-A12, then instantiate the generic flow lemma. |
| `aggregateShock_negative_comovement` hypotheses `hC,hD` | `Results.lean:380-384` | **Desired conclusions / circular** | The theorem assumes strict creation rise and destruction fall, then renames the sign product. | Retain as a generic arithmetic lemma under a neutral name; prove a separate economic theorem. |
| `dispersionShock_positive_comovement` hypotheses `hC,hD` | `Results.lean:390-394` | **Desired conclusions / circular** | Same issue for joint rises. | Retain/rename generic sign lemma; derive strict flows elsewhere. |
| `downturn_destruction_exceeds_ongoing` hypothesis `0<D_immediate` | `Results.lean:417-419` | **Desired conclusion upstream** | Positivity should follow from positive job mass between ordered cutoffs. | Prove immediate-scrapping positivity, then use the existing algebra lemma. |
| `SimulationPath.creation_law`, `destruction_law`, `employment_law` | `Equilibrium.lean:194-199` | **Equilibrium/path defining conditions**, not primitive assumptions | They appropriately define a valid path, but do not prove one exists. | Keep as record laws; add a constructor from the employment transition operator. |
| `SteadyStateEquilibrium.job_destruction`, `.job_creation`, `.beveridge` | `Equilibrium.lean:64-66` | **Equilibrium defining conditions** | It is legitimate to define a solution by equations, but these are not derivations. | Keep the record, while adding bridge and existence/uniqueness theorems. |

## 6. Redundant or derivable structure fields

| Field | Location | Classification | Future treatment |
|---|---|---|---|
| `ValueEquilibrium.cutoff_zero` plus full `reservation_rule` | `Equilibrium.lean:48-49` | `cutoff_zero` is derivable from a sufficiently strong reservation rule only if the rule includes an actual zero statement; the current biconditional alone gives nonnegativity, not equality. | Retain both until strict monotonicity and zero existence are proved; then construct the record rather than assume them. |
| `SteadyStateEquilibrium.u_nonneg`, `u_le_one` | `Equilibrium.lean:62-63` | Potentially **derivable** from (14) and denominator positivity. | Prove from the Beveridge formula, then consider a constructor that does not require them as inputs. |
| `GeneralMarkovValueEquilibrium.G_nonneg`, `G_rows_sum_one` | `Equilibrium.lean:159-160` | Primitive kernel validity, but redundant if `G` is bundled as a stochastic matrix/kernel. | Replace raw real matrix plus proofs with a bundled stochastic object. Mathlib defines row-stochastic matrices at `.lake/packages/mathlib/Mathlib/LinearAlgebra/Matrix/Stochastic.lean:59`. |
| Separate `F_nonneg`, `F_le_one`, `F_monotone` | `Definitions.lean:269-274` | **Redundant / derivable** | Prove once from bundled probability measure and remove from user-facing assumptions. |

## 7. Finite-witness-specific assumptions

These belong in a calibration namespace or witness record, never in the general theory.

| Assumption/data | Paper locus | Classification | Future Lean form |
|---|---|---|---|
| Three aggregate states and deviations `(-0.053,0,0.053)` | p. 411 | **Finite-witness-specific** | `Fin 3 → ℚ` or exact decimals as rationals. |
| Transition matrix (39) | p. 411 | **Finite-witness-specific** | `Matrix (Fin 3) (Fin 3) ℚ` plus `Matrix.IsStochastic`. |
| Uniform shock law on `[-1,1]` | p. 411 | **Finite-witness-specific** | A uniform probability measure with atomless/moment theorems. |
| Matching elasticity `0.5`, scale `k=4` | Table I, p. 411 | **Finite-witness-specific** | Calibrated matching record. |
| `p-b=.075`, `r=.01`, `λ=.081`, `β=.5`, `σ=.0375` | Table I, p. 411 | **Finite-witness-specific** | Exact rational parameters plus proofs of general assumptions. |
| Reported equilibrium vectors (42) | p. 411 | **Finite-witness-specific desired witness** | Interval-enclosed vectors with certified residuals for (32)-(34). |
| 100 samples of 66 quarters | p. 412 | **Finite-witness-specific** | Reproducible simulation configuration and seed policy. |

## 8. Recommended assumption architecture

Do not enlarge the existing `Assumptions` record indiscriminately. Use three layers:

```text
PaperPrimitives
  economic signs, probability law, atomlessness, moments,
  matching technology, state-invariance policy

AnalyticHypotheses (local to theorem families)
  integrability, continuity, differentiability,
  endpoint signs, Jacobian nonsingularity

CalibrationWitness
  Fin 3 states, matrix, numerical parameters,
  candidate solution and certified error bounds
```

Desired conclusions such as equilibrium existence, `θ`/`εd` orderings, curve slopes, and
flow co-movement must be theorem outputs. This separation allows the existing
`Primitives`, equation predicates, and elementary lemmas to be retained while preventing
future proofs from succeeding only because their advertised conclusions were placed in a
record field.
