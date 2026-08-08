import Mathlib.MeasureTheory.Integral.Layercake
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Continuation
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Equilibrium.Reduced

/-!
# MP1994 v2: analytic infrastructure for reduced equilibria

This module derives excess-payoff integrability from the primitive first
moment and proves the strict-tail identity for any admissible cutoff.  It then
derives the paper-facing versions of equations (10) and (13) from the robust
reduced fields.
-/

open MeasureTheory Set
open scoped Interval

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- The positive excess over any fixed cutoff is integrable whenever the shock
has an integrable first moment. -/
theorem positivePart_sub_integrable
    (D : ShockAssumptions P) (d : ℝ) :
    Integrable (fun x : ℝ => positivePart (x - d)) P.shock := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hSub : Integrable (fun x : ℝ => x - d) P.shock :=
    D.firstMomentIntegrable.sub (integrable_const d)
  refine hSub.norm.mono'
    (measurable_positivePart_sub d).aestronglyMeasurable ?_
  filter_upwards with x
  unfold positivePart
  calc
    ‖max (x - d) 0‖ = |max (x - d) 0| :=
      Real.norm_eq_abs _
    _ = max (x - d) 0 :=
      abs_of_nonneg (le_max_right (x - d) 0)
    _ ≤ |x - d| :=
      max_le (le_abs_self (x - d)) (abs_nonneg (x - d))
    _ = ‖x - d‖ := (Real.norm_eq_abs (x - d)).symm

/-- Generic strict-tail representation of expected excess for every cutoff
below the almost-sure upper bound.  Atomlessness is not used. -/
theorem expectedExcess_eq_tailOptionValue
    (D : ShockAssumptions P)
    {d : ℝ}
    (hd : d ≤ P.epsUpper) :
    P.expectedExcess d = P.tailOptionValue d := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  let u := P.epsUpper - d
  have hu : 0 ≤ u := sub_nonneg.mpr hd
  have hInt :
      Integrable (fun x => positivePart (x - d)) P.shock :=
    P.positivePart_sub_integrable D d
  have hLayer :=
    hInt.integral_eq_integral_meas_lt
      (Filter.Eventually.of_forall fun x =>
        positivePart_nonneg (x - d))
  have hLevelSet :
      ∀ t : ℝ, 0 < t →
        {x : ℝ | t < positivePart (x - d)} = Ioi (d + t) := by
    intro t ht
    ext x
    simp only [mem_setOf_eq, mem_Ioi]
    unfold positivePart
    rw [lt_max_iff]
    constructor
    · intro h
      rcases h with h | h
      · linarith
      · linarith
    · intro h
      left
      linarith
  have hTailOnPositive :
      (∫ t in Ioi 0,
          P.shock.real {x : ℝ | t < positivePart (x - d)}) =
        (∫ t in Ioi 0, P.tailProbability (d + t)) := by
    refine setIntegral_congr_fun measurableSet_Ioi ?_
    intro t ht
    change
      P.shock.real {x : ℝ | t < positivePart (x - d)} =
        P.tailProbability (d + t)
    rw [hLevelSet t ht]
    exact P.measureReal_Ioi_eq_one_sub_cdf (d + t)
  have hTruncate :
      (∫ t in Ioi 0, P.tailProbability (d + t)) =
        ∫ t in Ioc 0 u, P.tailProbability (d + t) := by
    apply setIntegral_eq_of_subset_of_ae_sdiff_eq_zero
      nullMeasurableSet_Ioi Ioc_subset_Ioi_self
    apply Filter.Eventually.of_forall
    intro t ht
    have htu : u < t := by
      have hnotle : ¬ t ≤ u := fun hle => ht.2 ⟨ht.1, hle⟩
      exact lt_of_not_ge hnotle
    have hUpper : P.epsUpper < d + t := by
      dsimp [u] at htu
      linarith
    have hTailZero : P.shock (Ioi (d + t)) = 0 :=
      measure_mono_null (Ioi_subset_Ioi hUpper.le) D.upperSupport
    rw [Primitives.tailProbability,
      ← P.measureReal_Ioi_eq_one_sub_cdf (d + t),
      measureReal_def, hTailZero]
    simp
  calc
    P.expectedExcess d =
        ∫ x, positivePart (x - d) ∂P.shock := by
      rfl
    _ = ∫ t in Ioi 0,
          P.shock.real {x : ℝ | t < positivePart (x - d)} := hLayer
    _ = ∫ t in Ioi 0, P.tailProbability (d + t) := hTailOnPositive
    _ = ∫ t in Ioc 0 u, P.tailProbability (d + t) := hTruncate
    _ = ∫ t in 0..u, P.tailProbability (d + t) := by
      rw [intervalIntegral.integral_of_le hu]
    _ = ∫ x in d..P.epsUpper, P.tailProbability x := by
      have hTranslate :=
        intervalIntegral.integral_comp_add_left
          (P.tailProbability) d
          (a := 0) (b := u)
      dsimp [u] at hTranslate ⊢
      rw [show d + (P.epsUpper - d) = P.epsUpper by ring] at hTranslate
      simpa only [add_zero] using hTranslate
    _ = P.tailOptionValue d := rfl

end Primitives

namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

theorem expectedExcess_eq_tailOptionValue
    (D : ShockAssumptions P) :
    P.expectedExcess R.cutoff =
      P.tailOptionValue R.cutoff :=
  P.expectedExcess_eq_tailOptionValue D R.cutoff_le_epsUpper

/-- Measure-form equation (10), directly unpacked from the robust reduced
job-destruction condition. -/
theorem equation10_measure :
    P.p + P.sigma * R.cutoff =
      P.b
        + (P.beta * P.c / (1 - P.beta)) * R.theta
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.expectedExcess R.cutoff := by
  have hJD := R.jobDestructionMeasure
  unfold Primitives.SatisfiesJobDestructionMeasure
    Primitives.jobDestructionResidualMeasure at hJD
  linarith

/-- Paper equation (10), using the induced-CDF tail option value. -/
theorem equation10
    (D : ShockAssumptions P) :
    P.p + P.sigma * R.cutoff =
      P.b
        + (P.beta * P.c / (1 - P.beta)) * R.theta
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue R.cutoff := by
  rw [← R.expectedExcess_eq_tailOptionValue D]
  exact R.equation10_measure

/-- Paper equation (13), derived from the foundational product form. -/
theorem equation13
    (A : CoreEconomicAssumptions P) :
    P.q R.theta =
      (P.c / (1 - P.beta)) *
        ((P.r + P.lambda) /
          (P.sigma * (P.epsUpper - R.cutoff))) := by
  have hProduct := R.jobCreationProduct
  unfold Primitives.SatisfiesJobCreationProduct at hProduct
  have hBeta : 1 - P.beta ≠ 0 := A.one_sub_beta_pos.ne'
  have hRate : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  have hSigma : P.sigma ≠ 0 := A.sigma_ne
  have hGap : P.epsUpper - R.cutoff ≠ 0 :=
    R.epsUpper_sub_cutoff_ne
  field_simp [hBeta, hRate, hSigma, hGap] at hProduct ⊢
  simpa [mul_assoc, mul_left_comm, mul_comm] using hProduct

theorem satisfiesJobDestruction
    (D : ShockAssumptions P) :
    P.SatisfiesJobDestruction R.theta R.cutoff := by
  unfold Primitives.SatisfiesJobDestruction
    Primitives.jobDestructionResidual
  linarith [R.equation10 D]

theorem satisfiesJobCreation
    (A : CoreEconomicAssumptions P) :
    P.SatisfiesJobCreation R.theta R.cutoff := by
  unfold Primitives.SatisfiesJobCreation
    Primitives.jobCreationResidual
  rw [R.equation13 A]
  ring

end ReducedEquilibrium

end MP1994V2
