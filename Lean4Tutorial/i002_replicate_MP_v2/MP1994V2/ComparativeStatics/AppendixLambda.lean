import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixFixedTightness
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixAlgebra

/-! # Appendix comparative statics for the shock-arrival rate (A1)--(A4) -/

open Filter
open scoped Topology

namespace MP1994V2
namespace LambdaEquilibriumPath

variable {P : Primitives}

private theorem q_hasDerivAt
    (AM : AppendixMatchingAssumptions P) (L : LambdaEquilibriumPath P) :
    HasDerivAt P.q (deriv P.q (L.theta P.lambda)) (L.theta P.lambda) := by
  exact ((AM.q_differentiableOn_pos (L.theta P.lambda) L.theta_pos).differentiableAt
    (Ioi_mem_nhds L.theta_pos)).hasDerivAt

private theorem jd_derivative
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : LambdaEquilibriumPath P) :
    P.sigma * L.cutoffSlope
      - P.searchOpportunityCostCoefficient * L.thetaSlope
      + (P.sigma * P.r / (P.r + P.lambda)^2) *
          P.expectedExcess (L.cutoff P.lambda)
      - (P.lambda * P.sigma / (P.r + P.lambda)) *
          (1 - P.cdf (L.cutoff P.lambda)) * L.cutoffSlope = 0 := by
  let H := fun t => P.expectedExcess (L.cutoff t)
  have hH := (P.hasDerivAt_expectedExcess D L.cutoff_lt_epsUpper).comp
    P.lambda L.cutoff_hasDerivAt
  have hfrac : HasDerivAt (fun t : ℝ => t * P.sigma / (P.r + t))
      (P.sigma * P.r / (P.r + P.lambda)^2) P.lambda := by
    convert (((hasDerivAt_id P.lambda).mul_const P.sigma).div
      ((hasDerivAt_const P.lambda P.r).add (hasDerivAt_id P.lambda))
      A.r_add_lambda_ne) using 1
    all_goals first | rfl |
      (simp [id] <;> field_simp [A.r_add_lambda_ne] <;> ring)
  have hJD : HasDerivAt
      (fun t => P.p + P.sigma * L.cutoff t - P.b
        - P.searchOpportunityCostCoefficient * L.theta t
        + (t * P.sigma / (P.r + t)) * H t)
      (P.sigma * L.cutoffSlope
        - P.searchOpportunityCostCoefficient * L.thetaSlope
        + (P.sigma * P.r / (P.r + P.lambda)^2) * H P.lambda
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            (1 - P.cdf (L.cutoff P.lambda)) * L.cutoffSlope) P.lambda := by
    convert (((((hasDerivAt_const P.lambda P.p).add
      ((hasDerivAt_const P.lambda P.sigma).mul L.cutoff_hasDerivAt)).sub
      (hasDerivAt_const P.lambda P.b)).sub
      ((hasDerivAt_const P.lambda P.searchOpportunityCostCoefficient).mul
        L.theta_hasDerivAt)).add (hfrac.mul hH)) using 1
    all_goals first | rfl | (simp [H, Function.comp_apply, id] <;> ring)
  have hEq : (fun t => P.p + P.sigma * L.cutoff t - P.b
        - P.searchOpportunityCostCoefficient * L.theta t
        + (t * P.sigma / (P.r + t)) * H t) =ᶠ[𝓝 P.lambda] fun _ => 0 := by
    filter_upwards [L.jd_eventually] with t ht
    simpa [Primitives.SatisfiesJobDestructionMeasure,
      Primitives.jobDestructionResidualMeasure,
      Primitives.searchOpportunityCostCoefficient, H,
      Primitives.withShockArrivalRate, Primitives.expectedExcess] using ht
  exact hJD.unique ((hasDerivAt_const P.lambda (0 : ℝ)).congr_of_eventuallyEq hEq)

theorem equationA2_crossMultiplied
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : LambdaEquilibriumPath P) :
    deriv P.q (L.theta P.lambda) * L.thetaSlope *
        (P.epsUpper - L.cutoff P.lambda) -
      P.q (L.theta P.lambda) * L.cutoffSlope =
        P.c / ((1 - P.beta) * P.sigma) := by
  have hq := (q_hasDerivAt AM L).comp P.lambda L.theta_hasDerivAt
  have hgap := (hasDerivAt_const P.lambda P.epsUpper).sub L.cutoff_hasDerivAt
  have hleft := hq.mul hgap
  have hright : HasDerivAt
      (fun t : ℝ => P.c * (P.r + t) / ((1-P.beta)*P.sigma))
      (P.c / ((1-P.beta)*P.sigma)) P.lambda := by
    convert ((hasDerivAt_const P.lambda P.c).mul
      ((hasDerivAt_const P.lambda P.r).add (hasDerivAt_id P.lambda))).div_const
        ((1-P.beta)*P.sigma) using 1
    all_goals first | rfl | ring
  have hRpos : ∀ᶠ t in 𝓝 P.lambda, 0 < P.r + t := by
    exact (continuousAt_const.add continuousAt_id).tendsto
      (Ioi_mem_nhds A.r_add_lambda_pos)
  have hEq : (fun t => P.q (L.theta t) * (P.epsUpper-L.cutoff t)) =ᶠ[𝓝 P.lambda]
      (fun t => P.c*(P.r+t)/((1-P.beta)*P.sigma)) := by
    filter_upwards [L.jc_eventually, hRpos] with t ht hrt
    simp [Primitives.SatisfiesJobCreationProduct,
      Primitives.withShockArrivalRate] at ht
    have hβ := A.one_sub_beta_pos.ne'; have hs := A.sigma_ne
    calc
      P.q (L.theta t) * (P.epsUpper - L.cutoff t) =
          (P.q (L.theta t) * (1 - P.beta) *
              (P.sigma / (P.r + t)) * (P.epsUpper - L.cutoff t)) *
            (P.r + t) / ((1 - P.beta) * P.sigma) := by
        field_simp [hβ, hs, hrt.ne']
      _ = P.c * (P.r + t) / ((1 - P.beta) * P.sigma) := by
        rw [ht]
  have hu := hleft.unique (hright.congr_of_eventuallyEq hEq)
  simpa [Function.comp_apply, sub_eq_add_neg] using hu

/-- Appendix equation (A1). -/
theorem equationA1
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : LambdaEquilibriumPath P) :
    ((P.r + P.lambda * P.cdf (L.cutoff P.lambda)) /
        (P.r + P.lambda)) * P.sigma * L.cutoffSlope =
      P.searchOpportunityCostCoefficient * L.thetaSlope
        - P.sigma * P.r / (P.r + P.lambda)^2 *
            P.expectedExcess (L.cutoff P.lambda) := by
  have h := jd_derivative A D L
  have hn := A.r_add_lambda_ne
  field_simp [hn] at h ⊢
  linear_combination h

/-- Foundational normalized form of Appendix equation (A2). -/
theorem equationA2_normalized
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : LambdaEquilibriumPath P) :
    deriv P.q (L.theta P.lambda) * L.thetaSlope =
      P.q (L.theta P.lambda) / (P.r + P.lambda)
      + P.q (L.theta P.lambda) /
          (P.epsUpper - L.cutoff P.lambda) * L.cutoffSlope := by
  have hraw := L.equationA2_crossMultiplied A AM
  have hjc := L.jc_eventually.self_of_nhds
  simp [Primitives.SatisfiesJobCreationProduct,
    Primitives.withShockArrivalRate] at hjc
  exact appendixA2_normalize (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
    A.one_sub_beta_pos.ne' A.sigma_ne A.r_add_lambda_ne hraw hjc

/-- Paper-facing cost form of Appendix equation (A2). -/
theorem equationA2
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : LambdaEquilibriumPath P) :
    deriv P.q (L.theta P.lambda) * L.thetaSlope =
      P.c / ((1-P.beta)*P.sigma*(P.epsUpper-L.cutoff P.lambda)) +
      P.c*(P.r+P.lambda) /
        ((1-P.beta)*P.sigma*(P.epsUpper-L.cutoff P.lambda)^2) * L.cutoffSlope := by
  have hn := L.equationA2_normalized A AM
  have hjc := L.jc_eventually.self_of_nhds
  simp [Primitives.SatisfiesJobCreationProduct,
    Primitives.withShockArrivalRate] at hjc
  exact appendixA2_paper (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
    A.one_sub_beta_pos.ne' A.sigma_ne A.r_add_lambda_ne hn hjc

/-- The reservation cutoff falls with the shock-arrival rate. -/
theorem cutoffSlope_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : LambdaEquilibriumPath P) : L.cutoffSlope < 0 := by
  by_contra h
  have hdnon : 0 ≤ L.cutoffSlope := le_of_not_gt h
  have hA2 := L.equationA2_normalized A AM
  have hq' := P.deriv_q_neg M AM L.theta_pos
  have hgap : 0 < P.epsUpper - L.cutoff P.lambda := sub_pos.mpr L.cutoff_lt_epsUpper
  have hfirst : 0 < P.q (L.theta P.lambda)/(P.r+P.lambda) :=
    div_pos (M.vacancyMeetingRate_pos L.theta_pos) A.r_add_lambda_pos
  have hsecond : 0 ≤ P.q (L.theta P.lambda)/
      (P.epsUpper-L.cutoff P.lambda)*L.cutoffSlope :=
    mul_nonneg (div_nonneg (M.vacancyMeetingRate_pos L.theta_pos).le hgap.le) hdnon
  have htheta : L.thetaSlope < 0 := by
    have : 0 < deriv P.q (L.theta P.lambda) * L.thetaSlope := by
      rw [hA2]; positivity
    have := (mul_pos_iff.mp this)
    rcases this with hp | hp
    · linarith
    · linarith
  have hA1 := L.equationA1 A D
  have hleft : 0 ≤ ((P.r + P.lambda * P.cdf (L.cutoff P.lambda)) /
      (P.r + P.lambda)) * P.sigma * L.cutoffSlope := by
    exact mul_nonneg (mul_nonneg
      (div_nonneg (P.r_add_lambda_cdf_pos A _).le A.r_add_lambda_pos.le)
      A.sigma_pos.le) hdnon
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have hH := P.expectedExcess_nonneg (L.cutoff P.lambda)
  have hright : P.searchOpportunityCostCoefficient * L.thetaSlope
      - P.sigma * P.r / (P.r + P.lambda)^2 *
          P.expectedExcess (L.cutoff P.lambda) < 0 := by
    have : P.searchOpportunityCostCoefficient * L.thetaSlope < 0 := mul_neg_of_pos_of_neg hk htheta
    have hcoef : 0 ≤ P.sigma * P.r / (P.r + P.lambda)^2 := by
      exact div_nonneg (mul_nonneg A.sigma_pos.le A.r_pos.le) (sq_nonneg _)
    have : 0 ≤ P.sigma * P.r / (P.r + P.lambda)^2 *
        P.expectedExcess (L.cutoff P.lambda) := mul_nonneg hcoef hH
    linarith
  linarith

/-- Appendix equation (A3). -/
theorem equationA3
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : LambdaEquilibriumPath P) :
    (deriv P.q (L.theta P.lambda) -
      P.searchOpportunityCostCoefficient * (P.r + P.lambda) /
        (P.sigma * (P.r + P.lambda * P.cdf (L.cutoff P.lambda))) *
        (P.q (L.theta P.lambda) /
          (P.epsUpper - L.cutoff P.lambda))) * L.thetaSlope =
    P.q (L.theta P.lambda) / (P.r + P.lambda) *
      (1 - P.r / (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) *
        (P.expectedExcess (L.cutoff P.lambda) /
          (P.epsUpper - L.cutoff P.lambda))) := by
  have h1 := L.equationA1 A D
  have h2 := L.equationA2_normalized A AM
  have hs := A.sigma_ne
  have hden := (P.r_add_lambda_cdf_pos A (L.cutoff P.lambda)).ne'
  have hgap := (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
  have h := appendixA3_of_A1_A2
    (sigma := P.sigma)
    (B := P.r + P.lambda * P.cdf (L.cutoff P.lambda))
    (R := P.r + P.lambda)
    (K := P.searchOpportunityCostCoefficient)
    (thetaSlope := L.thetaSlope) (cutoffSlope := L.cutoffSlope)
    (r := P.r) (H := P.expectedExcess (L.cutoff P.lambda))
    (q := P.q (L.theta P.lambda))
    (qp := deriv P.q (L.theta P.lambda))
    (gap := P.epsUpper - L.cutoff P.lambda)
    hs hden A.r_add_lambda_ne hgap
    (by convert h1 using 1 <;> ring) h2
  field_simp [hs, hden, A.r_add_lambda_ne, hgap] at h ⊢
  linear_combination h

/-- Normalized equation (A3); identical to the paper-facing theorem. -/
theorem equationA3_normalized
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : LambdaEquilibriumPath P) :
    (deriv P.q (L.theta P.lambda) -
      P.searchOpportunityCostCoefficient * (P.r + P.lambda) /
        (P.sigma * (P.r + P.lambda * P.cdf (L.cutoff P.lambda))) *
        (P.q (L.theta P.lambda) /
          (P.epsUpper - L.cutoff P.lambda))) * L.thetaSlope =
    P.q (L.theta P.lambda) / (P.r + P.lambda) *
      (1 - P.r / (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) *
        (P.expectedExcess (L.cutoff P.lambda) /
          (P.epsUpper - L.cutoff P.lambda))) :=
  L.equationA3 A D AM

/-- Equation (A4), the strict expected-excess tail-gap bound. -/
theorem equationA4 (D : ShockAssumptions P) (L : LambdaEquilibriumPath P) :
    P.expectedExcess (L.cutoff P.lambda) <
      P.epsUpper - L.cutoff P.lambda :=
  P.expectedExcess_lt_epsUpper_sub D L.cutoff_lt_epsUpper

theorem equationA3_coefficient_neg
    (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : LambdaEquilibriumPath P) :
    deriv P.q (L.theta P.lambda) -
      P.searchOpportunityCostCoefficient * (P.r + P.lambda) /
        (P.sigma * (P.r + P.lambda * P.cdf (L.cutoff P.lambda))) *
        (P.q (L.theta P.lambda) /
          (P.epsUpper - L.cutoff P.lambda)) < 0 := by
  have hq' := P.deriv_q_neg M AM L.theta_pos
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have : 0 < P.searchOpportunityCostCoefficient * (P.r + P.lambda) /
        (P.sigma * (P.r + P.lambda * P.cdf (L.cutoff P.lambda))) *
        (P.q (L.theta P.lambda) /
          (P.epsUpper - L.cutoff P.lambda)) := by
    exact mul_pos (div_pos (mul_pos hk A.r_add_lambda_pos)
      (mul_pos A.sigma_pos (P.r_add_lambda_cdf_pos A _)))
      (div_pos (M.vacancyMeetingRate_pos L.theta_pos)
        (sub_pos.mpr L.cutoff_lt_epsUpper))
  linarith

theorem equationA3_leftCoefficient_neg
    (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : LambdaEquilibriumPath P) :
    deriv P.q (L.theta P.lambda) -
      P.searchOpportunityCostCoefficient * (P.r + P.lambda) /
        (P.sigma * (P.r + P.lambda * P.cdf (L.cutoff P.lambda))) *
        (P.q (L.theta P.lambda) /
          (P.epsUpper - L.cutoff P.lambda)) < 0 :=
  L.equationA3_coefficient_neg A M AM

theorem equationA3_rightBracket_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : LambdaEquilibriumPath P) :
    0 < 1 - P.r * P.expectedExcess (L.cutoff P.lambda) /
      ((P.r + P.lambda * P.cdf (L.cutoff P.lambda)) *
        (P.epsUpper - L.cutoff P.lambda)) := by
  have hg := sub_pos.mpr L.cutoff_lt_epsUpper
  have hB := P.r_add_lambda_cdf_pos A (L.cutoff P.lambda)
  have hH := P.expectedExcess_lt_epsUpper_sub D L.cutoff_lt_epsUpper
  have hrle : P.r ≤ P.r + P.lambda * P.cdf (L.cutoff P.lambda) := by
    have : 0 ≤ P.lambda * P.cdf (L.cutoff P.lambda) :=
      mul_nonneg A.lambda_nonneg ENNReal.toReal_nonneg
    linarith
  have hstrict : P.r * P.expectedExcess (L.cutoff P.lambda) <
      (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) *
        (P.epsUpper - L.cutoff P.lambda) :=
    calc
      _ < P.r * (P.epsUpper - L.cutoff P.lambda) :=
        mul_lt_mul_of_pos_left hH A.r_pos
      _ ≤ _ := mul_le_mul_of_nonneg_right hrle hg.le
  rw [sub_pos]
  exact (div_lt_one (mul_pos hB hg)).2 hstrict

theorem equationA3_rhs_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (L : LambdaEquilibriumPath P) :
    0 < P.q (L.theta P.lambda) / (P.r + P.lambda) *
      (1 - P.r / (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) *
        (P.expectedExcess (L.cutoff P.lambda) /
          (P.epsUpper - L.cutoff P.lambda))) := by
  have hgap := sub_pos.mpr L.cutoff_lt_epsUpper
  have hH := P.expectedExcess_lt_epsUpper_sub D L.cutoff_lt_epsUpper
  have hden := P.r_add_lambda_cdf_pos A (L.cutoff P.lambda)
  have hratio : P.r / (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) ≤ 1 := by
    rw [div_le_one hden]
    have : 0 ≤ P.lambda * P.cdf (L.cutoff P.lambda) :=
      mul_nonneg A.lambda_nonneg ENNReal.toReal_nonneg
    linarith
  have hhratio : P.expectedExcess (L.cutoff P.lambda) /
      (P.epsUpper - L.cutoff P.lambda) < 1 := (div_lt_one hgap).2 hH
  have hprod : P.r / (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) *
      (P.expectedExcess (L.cutoff P.lambda) /
        (P.epsUpper - L.cutoff P.lambda)) < 1 := by
    have hnon : 0 ≤ P.r / (P.r + P.lambda * P.cdf (L.cutoff P.lambda)) :=
      div_nonneg A.r_pos.le hden.le
    calc
      _ ≤ 1 * (P.expectedExcess (L.cutoff P.lambda) /
          (P.epsUpper - L.cutoff P.lambda)) :=
        mul_le_mul_of_nonneg_right hratio
          (div_nonneg (P.expectedExcess_nonneg _) hgap.le)
      _ < 1 := by simpa using hhratio
  exact mul_pos (div_pos (M.vacancyMeetingRate_pos L.theta_pos)
    A.r_add_lambda_pos) (sub_pos.mpr hprod)

theorem thetaSlope_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : LambdaEquilibriumPath P) : L.thetaSlope < 0 := by
  have h := L.equationA3 A D AM
  have hc := L.equationA3_coefficient_neg A M AM
  have hr := L.equationA3_rhs_pos A D M
  nlinarith

end LambdaEquilibriumPath
end MP1994V2
