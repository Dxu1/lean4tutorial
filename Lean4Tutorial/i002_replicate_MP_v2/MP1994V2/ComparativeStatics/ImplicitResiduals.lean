import Mathlib.Analysis.Calculus.ImplicitContDiff
import Mathlib.Analysis.Calculus.ContDiff.Deriv
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions.AppendixIFT
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ExpectedExcessDerivative
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixParameterChanges
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.StaticCurves
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Equilibrium.Reduced

/-! # M8b parameterized residual calculus -/

open Filter Set ContinuousLinearMap
open scoped Topology ContDiff

namespace MP1994V2
namespace Primitives

variable {P : Primitives}

/-- Expected excess is locally `C¹` at every economically admissible cutoff.
The derivative is derived from the continuous CDF, not assumed. -/
theorem contDiffAt_expectedExcess (D : ShockAssumptions P) {d : ℝ}
    (hd : d < P.epsUpper) : ContDiffAt ℝ 1 P.expectedExcess d := by
  rw [contDiffAt_one_iff]
  let f' : ℝ → ℝ →L[ℝ] ℝ := fun x =>
    toSpanSingleton ℝ (-(1 - P.cdf x))
  refine ⟨f', Iio P.epsUpper, Iio_mem_nhds hd, ?_, ?_⟩
  · dsimp [f']
    exact (ContinuousLinearMap.toSpanSingletonLIE ℝ ℝ).continuous.comp
      ((continuous_const.sub (P.cdf_continuous D)).neg) |>.continuousOn
  · intro x hx
    simpa [f'] using (P.hasDerivAt_expectedExcess D hx).hasFDerivAt

/-- Derivative of the net value defining the job-destruction curve. -/
theorem hasDerivAt_jobDestructionNet
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    {d : ℝ} (hd : d < P.epsUpper) :
    HasDerivAt P.jobDestructionNet
      (P.sigma * (P.r + P.lambda * P.cdf d) / (P.r + P.lambda)) d := by
  have hH := P.hasDerivAt_expectedExcess D hd
  have hcalc := (((hasDerivAt_const d P.p).add
      ((hasDerivAt_const d P.sigma).mul (hasDerivAt_id d))).sub
      (hasDerivAt_const d P.b)).add
      ((hasDerivAt_const d (P.lambda * P.sigma / (P.r + P.lambda))).mul hH)
  have hcalc' : HasDerivAt P.jobDestructionNet
      (P.sigma +
        (P.lambda * P.sigma / (P.r + P.lambda)) * (-(1 - P.cdf d))) d := by
    apply (hcalc.congr_of_eventuallyEq ?_).congr_deriv
    · simp [id]
    · filter_upwards [] with x
      simp [jobDestructionNet, id]
  convert hcalc' using 1
  field_simp [A.r_add_lambda_ne]
  ring

theorem jobDestructionNet_deriv_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    {d : ℝ} (hd : d < P.epsUpper) :
    0 < deriv P.jobDestructionNet d := by
  rw [(P.hasDerivAt_jobDestructionNet A D hd).deriv]
  exact div_pos (mul_pos A.sigma_pos (P.r_add_lambda_cdf_pos A d))
    A.r_add_lambda_pos

/-- Derivative of JD-implied tightness. -/
theorem hasDerivAt_jobDestructionTheta
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    {d : ℝ} (hd : d < P.epsUpper) :
    HasDerivAt P.jobDestructionTheta
      ((P.sigma * (P.r + P.lambda * P.cdf d) / (P.r + P.lambda)) /
        P.searchOpportunityCostCoefficient) d := by
  unfold jobDestructionTheta
  exact (P.hasDerivAt_jobDestructionNet A D hd).div_const
    P.searchOpportunityCostCoefficient

theorem jobDestructionTheta_deriv_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    {d : ℝ} (hd : d < P.epsUpper) :
    0 < deriv P.jobDestructionTheta d := by
  rw [(P.hasDerivAt_jobDestructionTheta A D hd).deriv]
  exact div_pos
    (div_pos (mul_pos A.sigma_pos (P.r_add_lambda_cdf_pos A d))
      A.r_add_lambda_pos)
    (P.searchOpportunityCostCoefficient_pos A)

theorem contDiffAt_jobDestructionTheta
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    {d : ℝ} (hd : d < P.epsUpper) :
    ContDiffAt ℝ 1 P.jobDestructionTheta d := by
  have hH := P.contDiffAt_expectedExcess D hd
  unfold jobDestructionTheta jobDestructionNet
  fun_prop

/-- Derivative of the scalar JC residual after solving JD for tightness. -/
theorem hasDerivAt_staticCrossingResidual
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (AM : AppendixMatchingAssumptions P) {d : ℝ}
    (htheta : 0 < P.jobDestructionTheta d) (hd : d < P.epsUpper) :
    HasDerivAt P.staticCrossingResidual
      (P.jobCreationScale *
        (deriv P.q (P.jobDestructionTheta d) *
            deriv P.jobDestructionTheta d * (P.epsUpper - d) -
          P.q (P.jobDestructionTheta d))) d := by
  have hTheta := P.hasDerivAt_jobDestructionTheta A D hd
  have hq0 : HasDerivAt P.q (deriv P.q (P.jobDestructionTheta d))
      (P.jobDestructionTheta d) :=
    ((AM.q_differentiableOn_pos (P.jobDestructionTheta d) htheta).differentiableAt
      (Ioi_mem_nhds htheta)).hasDerivAt
  have hq := hq0.comp d hTheta
  have hgap := (hasDerivAt_const d P.epsUpper).sub (hasDerivAt_id d)
  have hcalc := (((hq.mul_const P.jobCreationScale).mul hgap).sub
    (hasDerivAt_const d P.c))
  have hcalc' : HasDerivAt P.staticCrossingResidual
      (deriv P.q (P.jobDestructionTheta d) *
          (P.sigma * (P.r + P.lambda * P.cdf d) / (P.r + P.lambda) /
            P.searchOpportunityCostCoefficient) * P.jobCreationScale *
          (P.epsUpper - d) -
        P.q (P.jobDestructionTheta d) * P.jobCreationScale) d := by
    apply (hcalc.congr_of_eventuallyEq ?_).congr_deriv
    · simp [Function.comp_apply, id]
      ring
    · filter_upwards [] with x
      simp [staticCrossingResidual, Function.comp_apply, id]
  rw [hTheta.deriv]
  convert hcalc' using 1 <;> ring

theorem deriv_staticCrossingResidual_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    {d : ℝ} (htheta : 0 < P.jobDestructionTheta d)
    (hd : d < P.epsUpper) :
    deriv P.staticCrossingResidual d < 0 := by
  rw [(P.hasDerivAt_staticCrossingResidual A D AM htheta hd).deriv]
  have hscale := P.jobCreationScale_pos A
  have hq' := P.deriv_q_neg M AM htheta
  have htheta' := P.jobDestructionTheta_deriv_pos A D hd
  have hgap : 0 < P.epsUpper - d := sub_pos.mpr hd
  have hq := M.vacancyMeetingRate_pos htheta
  have hfirst : deriv P.q (P.jobDestructionTheta d) *
      deriv P.jobDestructionTheta d * (P.epsUpper - d) < 0 :=
    mul_neg_of_neg_of_pos (mul_neg_of_neg_of_pos hq' htheta') hgap
  have hbracket : deriv P.q (P.jobDestructionTheta d) *
      deriv P.jobDestructionTheta d * (P.epsUpper - d) -
        P.q (P.jobDestructionTheta d) < 0 :=
    sub_neg.mpr (lt_trans hfirst hq)
  exact mul_neg_of_pos_of_neg hscale hbracket

theorem contDiffAt_staticCrossingResidual
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (IFT : AppendixIFTAssumptions P) {d : ℝ}
    (htheta : 0 < P.jobDestructionTheta d) (hd : d < P.epsUpper) :
    ContDiffAt ℝ 1 P.staticCrossingResidual d := by
  have hTheta := P.contDiffAt_jobDestructionTheta A D hd
  have hq := (IFT.q_contDiffAt htheta).comp d hTheta
  unfold staticCrossingResidual
  fun_prop

/-- Fixed-tightness sigma JD residual used by the scalar IFT. -/
noncomputable def fixedTightnessSigmaResidual
    (P : Primitives) (theta sigma d : ℝ) : ℝ :=
  (P.withDispersion sigma).jobDestructionResidualMeasure theta d

noncomputable def fixedTightnessSigmaResidualUncurried
    (P : Primitives) (theta : ℝ) (z : ℝ × ℝ) : ℝ :=
  P.fixedTightnessSigmaResidual theta z.1 z.2

/-- Lambda-varying scalar crossing residual used by the scalar IFT. -/
noncomputable def lambdaStaticResidual
    (P : Primitives) (lambda d : ℝ) : ℝ :=
  (P.withShockArrivalRate lambda).staticCrossingResidual d

noncomputable def lambdaStaticResidualUncurried
    (P : Primitives) (z : ℝ × ℝ) : ℝ :=
  P.lambdaStaticResidual z.1 z.2

/-- JD-implied tightness when the shock-arrival rate and cutoff vary jointly. -/
noncomputable def lambdaJobDestructionTheta
    (P : Primitives) (lambda d : ℝ) : ℝ :=
  (P.withShockArrivalRate lambda).jobDestructionTheta d

noncomputable def lambdaJobDestructionThetaUncurried
    (P : Primitives) (z : ℝ × ℝ) : ℝ :=
  P.lambdaJobDestructionTheta z.1 z.2

/-- Discount-rate-varying scalar crossing residual used by the scalar IFT. -/
noncomputable def discountStaticResidual
    (P : Primitives) (r d : ℝ) : ℝ :=
  (P.withDiscountRate r).staticCrossingResidual d

noncomputable def discountStaticResidualUncurried
    (P : Primitives) (z : ℝ × ℝ) : ℝ :=
  P.discountStaticResidual z.1 z.2

/-- JD-implied tightness when the discount rate and cutoff vary jointly. -/
noncomputable def discountJobDestructionTheta
    (P : Primitives) (r d : ℝ) : ℝ :=
  (P.withDiscountRate r).jobDestructionTheta d

noncomputable def discountJobDestructionThetaUncurried
    (P : Primitives) (z : ℝ × ℝ) : ℝ :=
  P.discountJobDestructionTheta z.1 z.2

/-- Dispersion-varying scalar crossing residual used by the scalar IFT. -/
noncomputable def dispersionStaticResidual
    (P : Primitives) (sigma d : ℝ) : ℝ :=
  (P.withDispersion sigma).staticCrossingResidual d

noncomputable def dispersionStaticResidualUncurried
    (P : Primitives) (z : ℝ × ℝ) : ℝ :=
  P.dispersionStaticResidual z.1 z.2

/-- JD-implied tightness when dispersion and cutoff vary jointly. -/
noncomputable def dispersionJobDestructionTheta
    (P : Primitives) (sigma d : ℝ) : ℝ :=
  (P.withDispersion sigma).jobDestructionTheta d

noncomputable def dispersionJobDestructionThetaUncurried
    (P : Primitives) (z : ℝ × ℝ) : ℝ :=
  P.dispersionJobDestructionTheta z.1 z.2

end Primitives

namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

theorem fixedTightnessSigmaResidual_base_eq_zero :
    P.fixedTightnessSigmaResidual R.theta P.sigma R.cutoff = 0 := by
  have h := R.jobDestructionMeasure
  unfold Primitives.SatisfiesJobDestructionMeasure at h
  simpa [Primitives.fixedTightnessSigmaResidual,
    Primitives.withDispersion, Primitives.jobDestructionResidualMeasure,
    Primitives.expectedExcess] using h

theorem lambdaStaticResidual_base_eq_zero
    (A : CoreEconomicAssumptions P) :
    P.lambdaStaticResidual P.lambda R.cutoff = 0 := by
  have htheta : P.jobDestructionTheta R.cutoff = R.theta :=
    ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
      R.jobDestructionMeasure).symm
  unfold Primitives.lambdaStaticResidual Primitives.staticCrossingResidual
    Primitives.jobCreationScale
  simp only [Primitives.withShockArrivalRate]
  rw [htheta]
  have hjc := R.jobCreationProduct
  unfold Primitives.SatisfiesJobCreationProduct at hjc
  rw [show P.q R.theta * ((1 - P.beta) * (P.sigma / (P.r + P.lambda))) *
      (P.epsUpper - R.cutoff) = P.c by
    simpa [mul_assoc] using hjc]
  ring

theorem fixedTightnessSigma_cutoffDerivative_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    0 < deriv (fun d =>
      P.fixedTightnessSigmaResidual R.theta P.sigma d) R.cutoff := by
  have h := P.jobDestructionNet_deriv_pos A D R.cutoff_lt_epsUpper
  rw [show (fun d => P.fixedTightnessSigmaResidual R.theta P.sigma d) =
      fun d => P.jobDestructionNet d -
        P.searchOpportunityCostCoefficient * R.theta by
    funext d
    simp only [Primitives.fixedTightnessSigmaResidual,
      Primitives.withDispersion, Primitives.jobDestructionResidualMeasure,
      Primitives.jobDestructionNet, Primitives.expectedExcess,
      Primitives.searchOpportunityCostCoefficient]
    ring]
  rw [deriv_sub_const]
  exact h

theorem fixedTightnessSigma_cutoffDerivative_ne
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    deriv (fun d => P.fixedTightnessSigmaResidual R.theta P.sigma d)
      R.cutoff ≠ 0 :=
  (R.fixedTightnessSigma_cutoffDerivative_pos A D).ne'

theorem lambdaStaticResidual_cutoffDerivative_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    deriv (fun d => P.lambdaStaticResidual P.lambda d) R.cutoff < 0 := by
  have htheta : P.jobDestructionTheta R.cutoff = R.theta :=
    ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
      R.jobDestructionMeasure).symm
  have h := P.deriv_staticCrossingResidual_neg A D M AM
    (by simpa [htheta] using R.theta_pos) R.cutoff_lt_epsUpper
  simpa [Primitives.lambdaStaticResidual,
    Primitives.withShockArrivalRate] using h

theorem lambdaStaticResidual_cutoffDerivative_ne
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    deriv (fun d => P.lambdaStaticResidual P.lambda d) R.cutoff ≠ 0 :=
  (R.lambdaStaticResidual_cutoffDerivative_neg A D M AM).ne

theorem lambdaJobDestructionTheta_base_eq
    (A : CoreEconomicAssumptions P) :
    P.lambdaJobDestructionTheta P.lambda R.cutoff = R.theta := by
  exact ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
    R.jobDestructionMeasure).symm

theorem discountStaticResidual_base_eq_zero
    (A : CoreEconomicAssumptions P) :
    P.discountStaticResidual P.r R.cutoff = 0 := by
  simpa [Primitives.discountStaticResidual,
    Primitives.lambdaStaticResidual, Primitives.withDiscountRate,
    Primitives.withShockArrivalRate] using
      R.lambdaStaticResidual_base_eq_zero A

theorem discountJobDestructionTheta_base_eq
    (A : CoreEconomicAssumptions P) :
    P.discountJobDestructionTheta P.r R.cutoff = R.theta := by
  simpa [Primitives.discountJobDestructionTheta,
    Primitives.withDiscountRate] using
      ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
        R.jobDestructionMeasure).symm

theorem discountStaticResidual_cutoffDerivative_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    deriv (fun d => P.discountStaticResidual P.r d) R.cutoff < 0 := by
  have htheta : P.jobDestructionTheta R.cutoff = R.theta :=
    ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
      R.jobDestructionMeasure).symm
  have h := P.deriv_staticCrossingResidual_neg A D M AM
    (by simpa [htheta] using R.theta_pos) R.cutoff_lt_epsUpper
  simpa [Primitives.discountStaticResidual,
    Primitives.withDiscountRate] using h

theorem discountStaticResidual_cutoffDerivative_ne
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    deriv (fun d => P.discountStaticResidual P.r d) R.cutoff ≠ 0 :=
  (R.discountStaticResidual_cutoffDerivative_neg A D M AM).ne

theorem dispersionStaticResidual_base_eq_zero
    (A : CoreEconomicAssumptions P) :
    P.dispersionStaticResidual P.sigma R.cutoff = 0 := by
  simpa [Primitives.dispersionStaticResidual,
    Primitives.lambdaStaticResidual, Primitives.withDispersion,
    Primitives.withShockArrivalRate] using
      R.lambdaStaticResidual_base_eq_zero A

theorem dispersionJobDestructionTheta_base_eq
    (A : CoreEconomicAssumptions P) :
    P.dispersionJobDestructionTheta P.sigma R.cutoff = R.theta := by
  simpa [Primitives.dispersionJobDestructionTheta,
    Primitives.withDispersion] using
      ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
        R.jobDestructionMeasure).symm

theorem dispersionStaticResidual_cutoffDerivative_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    deriv (fun d => P.dispersionStaticResidual P.sigma d) R.cutoff < 0 := by
  have htheta : P.jobDestructionTheta R.cutoff = R.theta :=
    ((P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
      R.jobDestructionMeasure).symm
  have h := P.deriv_staticCrossingResidual_neg A D M AM
    (by simpa [htheta] using R.theta_pos) R.cutoff_lt_epsUpper
  simpa [Primitives.dispersionStaticResidual,
    Primitives.withDispersion] using h

theorem dispersionStaticResidual_cutoffDerivative_ne
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    deriv (fun d => P.dispersionStaticResidual P.sigma d) R.cutoff ≠ 0 :=
  (R.dispersionStaticResidual_cutoffDerivative_neg A D M AM).ne

/-- Joint local `C¹` regularity of the lambda-varying JD curve. -/
theorem lambdaJobDestructionTheta_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    ContDiffAt ℝ 1 P.lambdaJobDestructionThetaUncurried
      (P.lambda, R.cutoff) := by
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hden : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  have hHcomp := hH.comp (P.lambda, R.cutoff)
    (contDiffAt_snd : ContDiffAt ℝ 1 (Prod.snd : ℝ × ℝ → ℝ)
      (P.lambda, R.cutoff))
  unfold Primitives.lambdaJobDestructionThetaUncurried
    Primitives.lambdaJobDestructionTheta Primitives.withShockArrivalRate
    Primitives.jobDestructionTheta Primitives.jobDestructionNet
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ =>
      (P.p + P.sigma * z.2 - P.b +
        (z.1 * P.sigma / (P.r + z.1)) *
          (P.expectedExcess ∘ Prod.snd) z) /
        P.searchOpportunityCostCoefficient) (P.lambda, R.cutoff)
  have hfrac : ContDiffAt ℝ 1
      (fun z : ℝ × ℝ => z.1 * P.sigma / (P.r + z.1))
      (P.lambda, R.cutoff) := by
    fun_prop
  exact ((((contDiffAt_const.add
      (contDiffAt_const.mul contDiffAt_snd)).sub contDiffAt_const).add
      (hfrac.mul hHcomp)).div_const P.searchOpportunityCostCoefficient)

/-- Joint local `C¹` regularity of the fixed-tightness sigma residual. -/
theorem fixedTightnessSigmaResidual_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    ContDiffAt ℝ 1
      (P.fixedTightnessSigmaResidualUncurried R.theta)
      (P.sigma, R.cutoff) := by
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hHcomp := hH.comp (P.sigma, R.cutoff)
    (contDiffAt_snd : ContDiffAt ℝ 1 (Prod.snd : ℝ × ℝ → ℝ)
      (P.sigma, R.cutoff))
  unfold Primitives.fixedTightnessSigmaResidualUncurried
    Primitives.fixedTightnessSigmaResidual
    Primitives.jobDestructionResidualMeasure
    Primitives.withDispersion
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ =>
      P.p + z.1 * z.2 - P.b -
        (P.beta * P.c / (1 - P.beta)) * R.theta +
        (P.lambda * z.1 / (P.r + P.lambda)) *
          (P.expectedExcess ∘ Prod.snd) z) (P.sigma, R.cutoff)
  exact ((((contDiffAt_const.add
      (contDiffAt_fst.mul contDiffAt_snd)).sub contDiffAt_const).sub
      contDiffAt_const).add
      ((contDiffAt_const.mul contDiffAt_fst).div_const
        (P.r + P.lambda) |>.mul
          hHcomp))

/-- Joint local `C¹` regularity of the lambda scalar residual. -/
theorem lambdaStaticResidual_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    ContDiffAt ℝ 1 P.lambdaStaticResidualUncurried
      (P.lambda, R.cutoff) := by
  let thetaFun : ℝ × ℝ → ℝ := fun z =>
    (P.p + P.sigma * z.2 - P.b +
      (z.1 * P.sigma / (P.r + z.1)) * P.expectedExcess z.2) /
        P.searchOpportunityCostCoefficient
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hTheta : ContDiffAt ℝ 1 thetaFun (P.lambda, R.cutoff) := by
    dsimp [thetaFun]
    have hden : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
    fun_prop
  have hThetaBase : thetaFun (P.lambda, R.cutoff) = R.theta := by
    have hgraph := (P.satisfiesJobDestructionMeasure_iff A R.theta R.cutoff).mp
      R.jobDestructionMeasure
    simpa [thetaFun, Primitives.jobDestructionTheta,
      Primitives.jobDestructionNet] using hgraph.symm
  have hq : ContDiffAt ℝ 1 (fun z => P.q (thetaFun z))
      (P.lambda, R.cutoff) := by
    have hq0 := IFT.q_contDiffAt R.theta_pos
    rw [← hThetaBase] at hq0
    exact hq0.comp (P.lambda, R.cutoff) hTheta
  unfold Primitives.lambdaStaticResidualUncurried
    Primitives.lambdaStaticResidual Primitives.staticCrossingResidual
    Primitives.jobCreationScale Primitives.withShockArrivalRate
    Primitives.jobDestructionTheta Primitives.jobDestructionNet
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ => P.q (thetaFun z) *
      ((1 - P.beta) * (P.sigma / (P.r + z.1))) *
        (P.epsUpper - z.2) - P.c) (P.lambda, R.cutoff)
  have hden : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  fun_prop

/-- Joint local `C¹` regularity of the discount-varying JD curve. -/
theorem discountJobDestructionTheta_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    ContDiffAt ℝ 1 P.discountJobDestructionThetaUncurried
      (P.r, R.cutoff) := by
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hHcomp := hH.comp (P.r, R.cutoff)
    (contDiffAt_snd : ContDiffAt ℝ 1 (Prod.snd : ℝ × ℝ → ℝ)
      (P.r, R.cutoff))
  unfold Primitives.discountJobDestructionThetaUncurried
    Primitives.discountJobDestructionTheta Primitives.withDiscountRate
    Primitives.jobDestructionTheta Primitives.jobDestructionNet
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ =>
      (P.p + P.sigma * z.2 - P.b +
        (P.lambda * P.sigma / (z.1 + P.lambda)) *
          (P.expectedExcess ∘ Prod.snd) z) /
        P.searchOpportunityCostCoefficient) (P.r, R.cutoff)
  have hden : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  fun_prop

/-- Joint local `C¹` regularity of the discount scalar residual. -/
theorem discountStaticResidual_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    ContDiffAt ℝ 1 P.discountStaticResidualUncurried
      (P.r, R.cutoff) := by
  let thetaFun : ℝ × ℝ → ℝ := fun z =>
    (P.p + P.sigma * z.2 - P.b +
      (P.lambda * P.sigma / (z.1 + P.lambda)) *
        P.expectedExcess z.2) /
      P.searchOpportunityCostCoefficient
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hTheta : ContDiffAt ℝ 1 thetaFun (P.r, R.cutoff) := by
    dsimp [thetaFun]
    have hden : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
    fun_prop
  have hThetaBase : thetaFun (P.r, R.cutoff) = R.theta := by
    simpa [thetaFun, Primitives.discountJobDestructionTheta,
      Primitives.withDiscountRate, Primitives.jobDestructionTheta,
      Primitives.jobDestructionNet] using
        R.discountJobDestructionTheta_base_eq A
  have hq : ContDiffAt ℝ 1 (fun z => P.q (thetaFun z))
      (P.r, R.cutoff) := by
    have hq0 := IFT.q_contDiffAt R.theta_pos
    rw [← hThetaBase] at hq0
    exact hq0.comp (P.r, R.cutoff) hTheta
  unfold Primitives.discountStaticResidualUncurried
    Primitives.discountStaticResidual Primitives.staticCrossingResidual
    Primitives.jobCreationScale Primitives.withDiscountRate
    Primitives.jobDestructionTheta Primitives.jobDestructionNet
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ => P.q (thetaFun z) *
      ((1 - P.beta) * (P.sigma / (z.1 + P.lambda))) *
        (P.epsUpper - z.2) - P.c) (P.r, R.cutoff)
  have hden : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  fun_prop

/-- Joint local `C¹` regularity of the dispersion-varying JD curve. -/
theorem dispersionJobDestructionTheta_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    ContDiffAt ℝ 1 P.dispersionJobDestructionThetaUncurried
      (P.sigma, R.cutoff) := by
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hHcomp := hH.comp (P.sigma, R.cutoff)
    (contDiffAt_snd : ContDiffAt ℝ 1 (Prod.snd : ℝ × ℝ → ℝ)
      (P.sigma, R.cutoff))
  unfold Primitives.dispersionJobDestructionThetaUncurried
    Primitives.dispersionJobDestructionTheta Primitives.withDispersion
    Primitives.jobDestructionTheta Primitives.jobDestructionNet
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ =>
      (P.p + z.1 * z.2 - P.b +
        (P.lambda * z.1 / (P.r + P.lambda)) *
          (P.expectedExcess ∘ Prod.snd) z) /
        P.searchOpportunityCostCoefficient) (P.sigma, R.cutoff)
  exact ((((contDiffAt_const.add
      (contDiffAt_fst.mul contDiffAt_snd)).sub contDiffAt_const).add
      (((contDiffAt_const.mul contDiffAt_fst).div_const
        (P.r + P.lambda)).mul hHcomp)).div_const
          P.searchOpportunityCostCoefficient)

/-- Joint local `C¹` regularity of the dispersion scalar residual. -/
theorem dispersionStaticResidual_contDiffAt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    ContDiffAt ℝ 1 P.dispersionStaticResidualUncurried
      (P.sigma, R.cutoff) := by
  let thetaFun : ℝ × ℝ → ℝ := fun z =>
    (P.p + z.1 * z.2 - P.b +
      (P.lambda * z.1 / (P.r + P.lambda)) *
        P.expectedExcess z.2) /
      P.searchOpportunityCostCoefficient
  have hH := P.contDiffAt_expectedExcess D R.cutoff_lt_epsUpper
  have hTheta : ContDiffAt ℝ 1 thetaFun (P.sigma, R.cutoff) := by
    dsimp [thetaFun]
    fun_prop
  have hThetaBase : thetaFun (P.sigma, R.cutoff) = R.theta := by
    simpa [thetaFun, Primitives.dispersionJobDestructionTheta,
      Primitives.withDispersion, Primitives.jobDestructionTheta,
      Primitives.jobDestructionNet] using
        R.dispersionJobDestructionTheta_base_eq A
  have hq : ContDiffAt ℝ 1 (fun z => P.q (thetaFun z))
      (P.sigma, R.cutoff) := by
    have hq0 := IFT.q_contDiffAt R.theta_pos
    rw [← hThetaBase] at hq0
    exact hq0.comp (P.sigma, R.cutoff) hTheta
  unfold Primitives.dispersionStaticResidualUncurried
    Primitives.dispersionStaticResidual Primitives.staticCrossingResidual
    Primitives.jobCreationScale Primitives.withDispersion
    Primitives.jobDestructionTheta Primitives.jobDestructionNet
  change ContDiffAt ℝ 1
    (fun z : ℝ × ℝ => P.q (thetaFun z) *
      ((1 - P.beta) * (z.1 / (P.r + P.lambda))) *
        (P.epsUpper - z.2) - P.c) (P.sigma, R.cutoff)
  fun_prop

end ReducedEquilibrium
end MP1994V2
