import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixFixedTightness
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixAlgebra

/-! # Appendix comparative statics for the discount rate (A5)--(A8) -/

open Filter
open scoped Topology

namespace MP1994V2
namespace DiscountEquilibriumPath

variable {P : Primitives}

theorem jd_derivative_raw
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : DiscountEquilibriumPath P) :
    P.sigma * L.cutoffSlope - P.searchOpportunityCostCoefficient * L.thetaSlope
      - P.lambda * P.sigma / (P.r + P.lambda)^2 *
          P.expectedExcess (L.cutoff P.r)
      - P.lambda * P.sigma / (P.r + P.lambda) *
          (1 - P.cdf (L.cutoff P.r)) * L.cutoffSlope = 0 := by
  let H := fun t => P.expectedExcess (L.cutoff t)
  have hH := (P.hasDerivAt_expectedExcess D L.cutoff_lt_epsUpper).comp
    P.r L.cutoff_hasDerivAt
  have hc : HasDerivAt (fun t : ℝ => P.lambda * P.sigma / (t + P.lambda))
      (-P.lambda * P.sigma / (P.r + P.lambda)^2) P.r := by
    convert (hasDerivAt_const P.r (P.lambda * P.sigma)).div
      ((hasDerivAt_id P.r).add (hasDerivAt_const P.r P.lambda))
      A.r_add_lambda_ne using 1
    all_goals first | rfl |
      (simp [id] <;> field_simp [A.r_add_lambda_ne] <;> ring)
  have hJD : HasDerivAt
      (fun t => P.p + P.sigma * L.cutoff t - P.b
        - P.searchOpportunityCostCoefficient * L.theta t +
          (P.lambda * P.sigma / (t + P.lambda)) * H t)
      (P.sigma * L.cutoffSlope - P.searchOpportunityCostCoefficient * L.thetaSlope
        - P.lambda * P.sigma / (P.r + P.lambda)^2 * H P.r
        - P.lambda * P.sigma / (P.r + P.lambda) *
          (1 - P.cdf (L.cutoff P.r)) * L.cutoffSlope) P.r := by
    convert (((((hasDerivAt_const P.r P.p).add
      ((hasDerivAt_const P.r P.sigma).mul L.cutoff_hasDerivAt)).sub
      (hasDerivAt_const P.r P.b)).sub
      ((hasDerivAt_const P.r P.searchOpportunityCostCoefficient).mul
        L.theta_hasDerivAt)).add (hc.mul hH)) using 1
    all_goals first | rfl |
      (simp [H, Function.comp_apply] <;> ring)
  have hEq : (fun t => P.p + P.sigma * L.cutoff t - P.b
        - P.searchOpportunityCostCoefficient * L.theta t +
          (P.lambda * P.sigma / (t + P.lambda)) * H t) =ᶠ[𝓝 P.r] fun _ => 0 := by
    filter_upwards [L.jd_eventually] with t ht
    simpa [Primitives.SatisfiesJobDestructionMeasure,
      Primitives.jobDestructionResidualMeasure,
      Primitives.searchOpportunityCostCoefficient, Primitives.withDiscountRate,
      Primitives.expectedExcess, H] using ht
  exact hJD.unique ((hasDerivAt_const P.r (0 : ℝ)).congr_of_eventuallyEq hEq)

theorem equationA6_crossMultiplied
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DiscountEquilibriumPath P) :
    deriv P.q (L.theta P.r) * L.thetaSlope *
        (P.epsUpper-L.cutoff P.r) -
      P.q (L.theta P.r) * L.cutoffSlope =
        P.c / ((1-P.beta)*P.sigma) := by
  have hqd : HasDerivAt P.q (deriv P.q (L.theta P.r)) (L.theta P.r) :=
    ((AM.q_differentiableOn_pos (L.theta P.r) L.theta_pos).differentiableAt
      (Ioi_mem_nhds L.theta_pos)).hasDerivAt
  have hq := hqd.comp P.r L.theta_hasDerivAt
  have hg := (hasDerivAt_const P.r P.epsUpper).sub L.cutoff_hasDerivAt
  have hleft := hq.mul hg
  have hright : HasDerivAt
      (fun t : ℝ => P.c*(t+P.lambda)/((1-P.beta)*P.sigma))
      (P.c/((1-P.beta)*P.sigma)) P.r := by
    convert ((hasDerivAt_const P.r P.c).mul
      ((hasDerivAt_id P.r).add (hasDerivAt_const P.r P.lambda))).div_const
        ((1-P.beta)*P.sigma) using 1
    all_goals first | rfl | ring
  have hRpos : ∀ᶠ t in 𝓝 P.r, 0 < t+P.lambda := by
    exact (continuousAt_id.add continuousAt_const).tendsto
      (Ioi_mem_nhds A.r_add_lambda_pos)
  have heq : (fun t => P.q (L.theta t)*(P.epsUpper-L.cutoff t)) =ᶠ[𝓝 P.r]
      (fun t => P.c*(t+P.lambda)/((1-P.beta)*P.sigma)) := by
    filter_upwards [L.jc_eventually, hRpos] with t ht hrt
    simp [Primitives.SatisfiesJobCreationProduct,
      Primitives.withDiscountRate] at ht
    have hβ:=A.one_sub_beta_pos.ne'; have hs:=A.sigma_ne
    calc
      P.q (L.theta t) * (P.epsUpper - L.cutoff t) =
          (P.q (L.theta t) * (1 - P.beta) *
              (P.sigma / (t + P.lambda)) * (P.epsUpper - L.cutoff t)) *
            (t + P.lambda) / ((1 - P.beta) * P.sigma) := by
        field_simp [hβ, hs, hrt.ne']
      _ = P.c * (t + P.lambda) / ((1 - P.beta) * P.sigma) := by
        rw [ht]
  have hu := hleft.unique (hright.congr_of_eventuallyEq heq)
  simpa [Function.comp_apply, sub_eq_add_neg] using hu

/-- Normalized derivative form of Appendix equation (A5). -/
theorem equationA5_normalized
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : DiscountEquilibriumPath P) :
    P.sigma * ((P.r+P.lambda*P.cdf (L.cutoff P.r))/(P.r+P.lambda)) *
        L.cutoffSlope =
      P.searchOpportunityCostCoefficient*L.thetaSlope +
        P.lambda*P.sigma/(P.r+P.lambda)^2 *
          P.expectedExcess (L.cutoff P.r) := by
  have h := L.jd_derivative_raw A D
  field_simp [A.r_add_lambda_ne] at h ⊢
  linear_combination h

/-- Appendix equation (A5), solved for the cutoff slope. -/
theorem equationA5 (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : DiscountEquilibriumPath P) :
    L.cutoffSlope =
      P.searchOpportunityCostCoefficient * (P.r+P.lambda) /
          (P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r))) * L.thetaSlope
      + P.lambda / ((P.r+P.lambda)*(P.r+P.lambda*P.cdf (L.cutoff P.r))) *
          P.expectedExcess (L.cutoff P.r) := by
  have h := L.equationA5_normalized A D
  exact appendixA5_solve A.sigma_ne
    (P.r_add_lambda_cdf_pos A _).ne' A.r_add_lambda_ne
    (by simpa [mul_assoc, mul_left_comm, mul_comm] using h)

/-- Normalized `q`-ratio form of Appendix equation (A6). -/
theorem equationA6_normalized (A : CoreEconomicAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DiscountEquilibriumPath P) :
    deriv P.q (L.theta P.r)*L.thetaSlope =
      P.q (L.theta P.r)/(P.r+P.lambda) +
        P.q (L.theta P.r)/(P.epsUpper-L.cutoff P.r)*L.cutoffSlope := by
  have hraw:=L.equationA6_crossMultiplied A AM
  have hjc:=L.jc_eventually.self_of_nhds
  simp [Primitives.SatisfiesJobCreationProduct,
    Primitives.withDiscountRate] at hjc
  exact appendixA2_normalize (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
    A.one_sub_beta_pos.ne' A.sigma_ne A.r_add_lambda_ne hraw hjc

/-- Paper equation (A6). -/
theorem equationA6 (A : CoreEconomicAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DiscountEquilibriumPath P) :
    P.sigma*(P.epsUpper-L.cutoff P.r)*deriv P.q (L.theta P.r)*L.thetaSlope =
      P.c/(1-P.beta) + P.sigma*P.q (L.theta P.r)*L.cutoffSlope := by
  have h:=L.equationA6_crossMultiplied A AM
  have hβ:=A.one_sub_beta_pos.ne'
  have hsolve :
      deriv P.q (L.theta P.r) * L.thetaSlope *
          (P.epsUpper - L.cutoff P.r) =
        P.q (L.theta P.r) * L.cutoffSlope +
          P.c / ((1 - P.beta) * P.sigma) := by
    linarith [h]
  calc
    P.sigma * (P.epsUpper - L.cutoff P.r) *
        deriv P.q (L.theta P.r) * L.thetaSlope =
        P.sigma * (deriv P.q (L.theta P.r) * L.thetaSlope *
          (P.epsUpper - L.cutoff P.r)) := by ring
    _ = P.sigma * (P.q (L.theta P.r) * L.cutoffSlope +
          P.c / ((1 - P.beta) * P.sigma)) := by rw [hsolve]
    _ = P.c / (1 - P.beta) +
        P.sigma * P.q (L.theta P.r) * L.cutoffSlope := by
      field_simp [hβ, A.sigma_ne]
      ring

theorem thetaSlope_neg (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DiscountEquilibriumPath P) : L.thetaSlope < 0 := by
  by_contra hn
  have ht : 0 ≤ L.thetaSlope := le_of_not_gt hn
  have h5:=L.equationA5 A D
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have hcut : 0 ≤ L.cutoffSlope := by
    rw [h5]
    exact add_nonneg
      (mul_nonneg
        (div_nonneg (mul_nonneg hk.le A.r_add_lambda_pos.le)
          (mul_nonneg A.sigma_pos.le (P.r_add_lambda_cdf_pos A _).le)) ht)
      (mul_nonneg
        (div_nonneg A.lambda_nonneg
          (mul_nonneg A.r_add_lambda_pos.le
            (P.r_add_lambda_cdf_pos A _).le))
        (P.expectedExcess_nonneg _))
  have h6:=L.equationA6 A AM
  have hq':=P.deriv_q_neg M AM L.theta_pos
  have hgap:=sub_pos.mpr L.cutoff_lt_epsUpper
  have hl : P.sigma*(P.epsUpper-L.cutoff P.r)*deriv P.q (L.theta P.r)*L.thetaSlope ≤ 0 := by
    have : deriv P.q (L.theta P.r)*L.thetaSlope ≤ 0 := mul_nonpos_of_nonpos_of_nonneg hq'.le ht
    calc
      P.sigma * (P.epsUpper - L.cutoff P.r) *
          deriv P.q (L.theta P.r) * L.thetaSlope =
          (P.sigma * (P.epsUpper - L.cutoff P.r)) *
            (deriv P.q (L.theta P.r) * L.thetaSlope) := by ring
      _ ≤ 0 := mul_nonpos_of_nonneg_of_nonpos
        (mul_nonneg A.sigma_pos.le hgap.le) this
  have hr : 0 < P.c/(1-P.beta)+P.sigma*P.q (L.theta P.r)*L.cutoffSlope := by
    have : 0 < P.c/(1-P.beta) := div_pos A.c_pos A.one_sub_beta_pos
    have : 0 ≤ P.sigma*P.q (L.theta P.r)*L.cutoffSlope :=
      mul_nonneg (mul_nonneg A.sigma_pos.le
        (M.vacancyMeetingRate_pos L.theta_pos).le) hcut
    linarith
  linarith

/-- Appendix elasticity form (A7). -/
theorem equationA7 (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DiscountEquilibriumPath P) :
    L.thetaSlope = -L.theta P.r /
        (P.matchingElasticity (L.theta P.r)*(P.r+P.lambda))
      - L.theta P.r /
        (P.matchingElasticity (L.theta P.r)*(P.epsUpper-L.cutoff P.r)) *
          L.cutoffSlope := by
  exact appendixA7_of_normalized_A6
    (M.vacancyMeetingRate_pos L.theta_pos).ne'
    (AM.elasticity_pos L.theta_pos).ne' L.theta_pos.ne'
    A.r_add_lambda_ne (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
    (P.deriv_q_eq_neg_elasticity_mul M L.theta_pos)
    (L.equationA6_normalized A AM)

/-- Appendix equation (A8); its right side has no maintained sign. -/
theorem equationA8 (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DiscountEquilibriumPath P) :
    (1 + P.searchOpportunityCostCoefficient*(P.r+P.lambda)*L.theta P.r /
      (P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r))*
        P.matchingElasticity (L.theta P.r)*(P.epsUpper-L.cutoff P.r))) * L.cutoffSlope =
    1/(P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r))) *
      (-P.searchOpportunityCostCoefficient*L.theta P.r /
          P.matchingElasticity (L.theta P.r)
       + P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.r)) := by
  exact appendixA8_of_A5_A7 A.sigma_ne
    (P.r_add_lambda_cdf_pos A _).ne' A.r_add_lambda_ne
    (AM.elasticity_pos L.theta_pos).ne'
    (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
    (L.equationA5 A D) (L.equationA7 A M AM)

/-- The coefficient multiplying `cutoffSlope` in (A8) is positive. -/
theorem equationA8_leftCoefficient_pos
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DiscountEquilibriumPath P) :
    0 < 1 + P.searchOpportunityCostCoefficient*(P.r+P.lambda)*L.theta P.r /
      (P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r))*
        P.matchingElasticity (L.theta P.r)*(P.epsUpper-L.cutoff P.r)) := by
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have : 0 < P.searchOpportunityCostCoefficient*(P.r+P.lambda)*L.theta P.r /
      (P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r))*
        P.matchingElasticity (L.theta P.r)*(P.epsUpper-L.cutoff P.r)) := by
    exact div_pos (mul_pos (mul_pos hk A.r_add_lambda_pos) L.theta_pos)
      (mul_pos
        (mul_pos (mul_pos A.sigma_pos (P.r_add_lambda_cdf_pos A _))
          (AM.elasticity_pos L.theta_pos))
        (sub_pos.mpr L.cutoff_lt_epsUpper))
  linarith

/-- Machine-readable statement of the paper's ambiguous cutoff response. -/
theorem cutoffSlope_pos_iff_A8_rhs_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DiscountEquilibriumPath P) :
    0 < L.cutoffSlope ↔
      P.searchOpportunityCostCoefficient*L.theta P.r /
          P.matchingElasticity (L.theta P.r) <
        P.lambda*P.sigma/(P.r+P.lambda)*
          P.expectedExcess (L.cutoff P.r) := by
  have h8:=L.equationA8 A D M AM
  have hc:=L.equationA8_leftCoefficient_pos A AM
  have hden : 0 < P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r)) :=
    mul_pos A.sigma_pos (P.r_add_lambda_cdf_pos A _)
  constructor
  · intro hd
    have : 0 < (1/(P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r)))) *
      (-P.searchOpportunityCostCoefficient*L.theta P.r /
        P.matchingElasticity (L.theta P.r) +
        P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.r)) := by
      rw [← h8]; positivity
    have : 0 < -P.searchOpportunityCostCoefficient*L.theta P.r /
        P.matchingElasticity (L.theta P.r) +
        P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.r) := by
      rcases mul_pos_iff.mp this with hp | hn
      · exact hp.2
      · exact (not_lt_of_ge (one_div_pos.mpr hden).le hn.1).elim
    have : 0 < P.lambda * P.sigma / (P.r + P.lambda) *
        P.expectedExcess (L.cutoff P.r) -
          P.searchOpportunityCostCoefficient * L.theta P.r /
            P.matchingElasticity (L.theta P.r) := by
      convert this using 1 <;> ring
    exact sub_pos.mp this
  · intro hrhs
    have hr : 0 < -P.searchOpportunityCostCoefficient*L.theta P.r /
        P.matchingElasticity (L.theta P.r) +
        P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.r) := by
      have := sub_pos.mpr hrhs
      convert this using 1 <;> ring
    have : 0 < (1/(P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.r)))) *
      (-P.searchOpportunityCostCoefficient*L.theta P.r /
        P.matchingElasticity (L.theta P.r) +
        P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.r)) :=
      mul_pos (one_div_pos.mpr hden) hr
    rw [← h8] at this
    rcases mul_pos_iff.mp this with hp | hn
    · exact hp.2
    · exact (not_lt_of_ge hc.le hn.1).elim

end DiscountEquilibriumPath
end MP1994V2
