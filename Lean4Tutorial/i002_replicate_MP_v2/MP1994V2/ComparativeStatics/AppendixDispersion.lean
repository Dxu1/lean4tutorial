import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixFixedTightness
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixAlgebra

/-! # Appendix comparative statics for dispersion (A9)--(A12) -/

open MeasureTheory Set Filter
open scoped Topology

namespace MP1994V2

namespace Primitives

/-- Mean zero, unit second moment, and the almost-sure upper bound imply a
strictly positive upper support bound. -/
theorem epsUpper_pos_of_normalization {P : Primitives}
    (D : ShockAssumptions P) (N : ShockNormalizationAssumptions P) :
    0 < P.epsUpper := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  by_contra hn
  have hu : P.epsUpper ≤ 0 := le_of_not_gt hn
  have hUpper : ∀ᵐ x ∂P.shock, x ≤ P.epsUpper := by
    rw [ae_iff]
    rw [show {a : ℝ | ¬a ≤ P.epsUpper} = Ioi P.epsUpper by
      ext x
      simp]
    exact D.upperSupport
  have hnonneg : 0 ≤ᵐ[P.shock] fun x : ℝ => -x :=
    hUpper.mono fun _ hx => neg_nonneg.mpr (hx.trans hu)
  have hnegInt : Integrable (fun x : ℝ => -x) P.shock :=
    N.firstMomentIntegrable.neg
  have hzero : ∫ x, -x ∂P.shock = 0 := by
    rw [integral_neg, N.mean_zero]
    simp
  have haeNeg := (integral_eq_zero_iff_of_nonneg_ae hnonneg hnegInt).1 hzero
  have hae : (fun x : ℝ => x) =ᵐ[P.shock] 0 :=
    haeNeg.mono fun x hx => by simpa using congrArg Neg.neg hx
  have hsquare : (fun x : ℝ => x^2) =ᵐ[P.shock] 0 := by
    filter_upwards [hae] with x hx
    rw [hx]
    norm_num
  have : (∫ x, x^2 ∂P.shock) = 0 := by
    simpa using integral_congr_ae hsquare
  linarith [N.secondMoment_one]

/-- The tail first moment equals `d(1-F(d))+H(d)`. -/
theorem tailMoment_eq_cutoff_mul_tail_add_expectedExcess {P : Primitives}
    (D : ShockAssumptions P) (d : ℝ) :
    ∫ x in Ioi d, x ∂P.shock =
      d * (1 - P.cdf d) + P.expectedExcess d := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hi : IntegrableOn (fun x : ℝ => x) (Ioi d) P.shock :=
    D.firstMomentIntegrable.integrableOn
  have hc : Integrable (fun _ : ℝ => d) P.shock := integrable_const d
  have hp := P.positivePart_sub_integrable D d
  rw [← P.measureReal_Ioi_eq_one_sub_cdf d]
  rw [← integral_indicator measurableSet_Ioi]
  rw [mul_comm d, ← smul_eq_mul, ← setIntegral_const]
  rw [← integral_indicator measurableSet_Ioi]
  unfold Primitives.expectedExcess
  rw [← integral_add (hc.indicator measurableSet_Ioi) hp]
  apply integral_congr_ae
  filter_upwards with x
  simp only [indicator_apply, mem_Ioi]
  split_ifs with hx
  · unfold positivePart
    simp [max_eq_left (sub_nonneg.mpr hx.le)]
  · unfold positivePart
    have : x - d ≤ 0 := sub_nonpos.mpr (le_of_not_gt hx)
    simp [max_eq_right this]

end Primitives

namespace DispersionEquilibriumPath

variable {P : Primitives}

theorem jd_derivative_raw (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) (L : DispersionEquilibriumPath P) :
    L.cutoff P.sigma + P.sigma*L.cutoffSlope
      - P.searchOpportunityCostCoefficient*L.thetaSlope
      + P.lambda/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.sigma)
      - P.lambda*P.sigma/(P.r+P.lambda)*
        (1-P.cdf (L.cutoff P.sigma))*L.cutoffSlope = 0 := by
  let H := fun s => P.expectedExcess (L.cutoff s)
  have hH := (P.hasDerivAt_expectedExcess D L.cutoff_lt_epsUpper).comp
    P.sigma L.cutoff_hasDerivAt
  have hc : HasDerivAt (fun s : ℝ => P.lambda*s/(P.r+P.lambda))
      (P.lambda/(P.r+P.lambda)) P.sigma := by
    convert (((hasDerivAt_const P.sigma P.lambda).mul (hasDerivAt_id P.sigma)).div_const
      (P.r+P.lambda)) using 1
    all_goals first | rfl | (simp [id] <;> ring)
  have h : HasDerivAt
      (fun s => P.p+s*L.cutoff s-P.b-
        P.searchOpportunityCostCoefficient*L.theta s +
        (P.lambda*s/(P.r+P.lambda))*H s)
      (L.cutoff P.sigma+P.sigma*L.cutoffSlope-
        P.searchOpportunityCostCoefficient*L.thetaSlope+
        P.lambda/(P.r+P.lambda)*H P.sigma-
        P.lambda*P.sigma/(P.r+P.lambda)*
          (1-P.cdf (L.cutoff P.sigma))*L.cutoffSlope) P.sigma := by
    convert (((((hasDerivAt_const P.sigma P.p).add
      ((hasDerivAt_id P.sigma).mul L.cutoff_hasDerivAt)).sub
      (hasDerivAt_const P.sigma P.b)).sub
      ((hasDerivAt_const P.sigma P.searchOpportunityCostCoefficient).mul
        L.theta_hasDerivAt)).add (hc.mul hH)) using 1
    all_goals first | rfl | (simp [H, Function.comp_apply] <;> ring)
  have heq : (fun s => P.p+s*L.cutoff s-P.b-
        P.searchOpportunityCostCoefficient*L.theta s+
        (P.lambda*s/(P.r+P.lambda))*H s) =ᶠ[𝓝 P.sigma] fun _ => 0 := by
    filter_upwards [L.jd_eventually] with s hs
    simpa [Primitives.SatisfiesJobDestructionMeasure,
      Primitives.jobDestructionResidualMeasure,
      Primitives.searchOpportunityCostCoefficient, Primitives.withDispersion,
      Primitives.expectedExcess, H] using hs
  exact h.unique ((hasDerivAt_const P.sigma (0:ℝ)).congr_of_eventuallyEq heq)

theorem equationA10_crossMultiplied (A : CoreEconomicAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DispersionEquilibriumPath P) :
    deriv P.q (L.theta P.sigma)*L.thetaSlope*P.sigma*
        (P.epsUpper-L.cutoff P.sigma) +
      P.q (L.theta P.sigma)*(P.epsUpper-L.cutoff P.sigma) -
      P.q (L.theta P.sigma)*P.sigma*L.cutoffSlope = 0 := by
  have hqd : HasDerivAt P.q (deriv P.q (L.theta P.sigma)) (L.theta P.sigma) :=
    ((AM.q_differentiableOn_pos (L.theta P.sigma) L.theta_pos).differentiableAt
      (Ioi_mem_nhds L.theta_pos)).hasDerivAt
  have hq:=hqd.comp P.sigma L.theta_hasDerivAt
  have hg := (hasDerivAt_const P.sigma P.epsUpper).sub L.cutoff_hasDerivAt
  have h := (hq.mul (hasDerivAt_id P.sigma)).mul hg
  have heq : (fun s => P.q (L.theta s)*s*(P.epsUpper-L.cutoff s)) =ᶠ[𝓝 P.sigma]
      fun _ => P.c*(P.r+P.lambda)/(1-P.beta) := by
    filter_upwards [L.jc_eventually] with s hs
    simp [Primitives.SatisfiesJobCreationProduct,
      Primitives.withDispersion] at hs
    have hβ := A.one_sub_beta_pos.ne'
    calc
      P.q (L.theta s) * s * (P.epsUpper - L.cutoff s) =
          (P.q (L.theta s) * (1 - P.beta) *
              (s / (P.r + P.lambda)) * (P.epsUpper - L.cutoff s)) *
            (P.r + P.lambda) / (1 - P.beta) := by
        field_simp [hβ, A.r_add_lambda_ne]
      _ = P.c * (P.r + P.lambda) / (1 - P.beta) := by
        rw [hs]
  have hu := h.unique ((hasDerivAt_const P.sigma
    (P.c*(P.r+P.lambda)/(1-P.beta))).congr_of_eventuallyEq heq)
  convert hu using 1 <;> simp [Function.comp_apply, sub_eq_add_neg] <;> ring

/-- Appendix equation (A9). -/
theorem equationA9 (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : DispersionEquilibriumPath P) :
    P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.sigma))/(P.r+P.lambda)*
      L.cutoffSlope =
    P.searchOpportunityCostCoefficient*L.thetaSlope - L.cutoff P.sigma -
      P.lambda/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.sigma) := by
  convert appendixA9_normalize A.r_add_lambda_ne rfl rfl
    (L.jd_derivative_raw A D) using 1 <;> ring

/-- Appendix equation (A10). -/
theorem equationA10 (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DispersionEquilibriumPath P) :
    P.sigma*(P.epsUpper-L.cutoff P.sigma)*
      (P.matchingElasticity (L.theta P.sigma)/L.theta P.sigma)*L.thetaSlope =
    P.epsUpper-L.cutoff P.sigma-P.sigma*L.cutoffSlope := by
  exact appendixA10_of_crossMultiplied
    (M.vacancyMeetingRate_pos L.theta_pos).ne' L.theta_pos.ne'
    (P.deriv_q_eq_neg_elasticity_mul M L.theta_pos)
    (L.equationA10_crossMultiplied A AM)

/-- Positive numerator behind the paper's equation (A11). -/
theorem equationA11_signCarrier_pos (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) (N : ShockNormalizationAssumptions P)
    (L : DispersionEquilibriumPath P) :
    0 < (P.r+P.lambda*P.cdf (L.cutoff P.sigma))*P.epsUpper +
      P.lambda*(L.cutoff P.sigma*(1-P.cdf (L.cutoff P.sigma))+
        P.expectedExcess (L.cutoff P.sigma)) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  let d:=L.cutoff P.sigma
  have hu:=P.epsUpper_pos_of_normalization D N
  have htail := P.tailMoment_eq_cutoff_mul_tail_add_expectedExcess D d
  have hsplit : (∫ x in Iic d, x ∂P.shock) + (∫ x in Ioi d, x ∂P.shock) = 0 := by
    have hIic : IntegrableOn (fun x : ℝ => x) (Iic d) P.shock :=
      N.firstMomentIntegrable.integrableOn
    have hIoi : IntegrableOn (fun x : ℝ => x) (Ioi d) P.shock :=
      N.firstMomentIntegrable.integrableOn
    rw [← setIntegral_union (Iic_disjoint_Ioi le_rfl) measurableSet_Ioi
      hIic hIoi]
    simpa [Iic_union_Ioi] using N.mean_zero
  have hlower : ∫ x in Iic d, x ∂P.shock ≤
      P.epsUpper * P.shock.real (Iic d) := by
    have hi : IntegrableOn (fun x : ℝ => x) (Iic d) P.shock :=
      N.firstMomentIntegrable.integrableOn
    have hc : IntegrableOn (fun _ : ℝ => P.epsUpper) (Iic d) P.shock :=
      (integrable_const P.epsUpper).integrableOn
    calc
      (∫ x in Iic d, x ∂P.shock) ≤
          ∫ _ in Iic d, P.epsUpper ∂P.shock :=
        setIntegral_mono_on hi hc measurableSet_Iic fun x hx =>
          hx.trans L.cutoff_lt_epsUpper.le
      _ = P.epsUpper * P.shock.real (Iic d) := by
        rw [setIntegral_const, smul_eq_mul, mul_comm]
  have hbracket : 0 ≤ P.cdf d*P.epsUpper + ∫ x in Ioi d, x ∂P.shock := by
    have htailNeg : ∫ x in Ioi d, x ∂P.shock =
        -(∫ x in Iic d, x ∂P.shock) := by linarith [hsplit]
    unfold Primitives.cdf at hlower
    rw [measureReal_def] at hlower
    change 0 ≤ (P.shock (Iic d)).toReal * P.epsUpper +
      ∫ x in Ioi d, x ∂P.shock
    rw [htailNeg]
    nlinarith [hlower]
  rw [← htail]
  have : 0 < P.r*P.epsUpper := mul_pos A.r_pos hu
  nlinarith [mul_nonneg A.lambda_nonneg hbracket]

/-- A11 slope equation obtained by eliminating the cutoff slope. -/
theorem equationA11_slopeEquation
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DispersionEquilibriumPath P) :
    (P.searchOpportunityCostCoefficient*(P.r+P.lambda) +
      (P.r+P.lambda*P.cdf (L.cutoff P.sigma))*P.sigma*
        (P.epsUpper-L.cutoff P.sigma)*
        P.matchingElasticity (L.theta P.sigma)/(L.theta P.sigma))*L.thetaSlope =
    (P.r+P.lambda*P.cdf (L.cutoff P.sigma))*P.epsUpper +
      P.lambda*(L.cutoff P.sigma*(1-P.cdf (L.cutoff P.sigma))+
        P.expectedExcess (L.cutoff P.sigma)) := by
  exact appendixA11_slopeEquation_of_A9_A10 A.r_add_lambda_ne
    L.theta_pos.ne' rfl (by ring)
    (by convert L.equationA9 A D using 1 <;> ring)
    (L.equationA10 A M AM)

theorem equationA11_leftCoefficient_pos
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DispersionEquilibriumPath P) :
    0 < P.searchOpportunityCostCoefficient*(P.r+P.lambda) +
      (P.r+P.lambda*P.cdf (L.cutoff P.sigma))*P.sigma*
        (P.epsUpper-L.cutoff P.sigma)*
        P.matchingElasticity (L.theta P.sigma)/(L.theta P.sigma) := by
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have hfirst : 0 < P.searchOpportunityCostCoefficient*(P.r+P.lambda) :=
    mul_pos hk A.r_add_lambda_pos
  have hsecond : 0 < (P.r+P.lambda*P.cdf (L.cutoff P.sigma))*P.sigma*
      (P.epsUpper-L.cutoff P.sigma)*P.matchingElasticity (L.theta P.sigma)/
        (L.theta P.sigma) := by
    exact div_pos
      (mul_pos
        (mul_pos (mul_pos (P.r_add_lambda_cdf_pos A _) A.sigma_pos)
          (sub_pos.mpr L.cutoff_lt_epsUpper))
        (AM.elasticity_pos L.theta_pos))
      L.theta_pos
  linarith

theorem thetaSlope_pos (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (N : ShockNormalizationAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DispersionEquilibriumPath P) :
    0 < L.thetaSlope := by
  have heq:=L.equationA11_slopeEquation A D M AM
  have hc:=L.equationA11_leftCoefficient_pos A AM
  have hr:=L.equationA11_signCarrier_pos A D N
  nlinarith

/-- Appendix equation (A12), obtained from the base JD condition. -/
theorem equationA12 (A : CoreEconomicAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DispersionEquilibriumPath P) :
    P.searchOpportunityCostCoefficient*L.theta P.sigma /
        P.matchingElasticity (L.theta P.sigma)
      - P.sigma*L.cutoff P.sigma
      - P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.sigma) =
    P.p-P.b + P.searchOpportunityCostCoefficient*L.theta P.sigma*
      (1/P.matchingElasticity (L.theta P.sigma)-1) := by
  have hb:=L.jd_eventually.self_of_nhds
  unfold Primitives.SatisfiesJobDestructionMeasure
    Primitives.jobDestructionResidualMeasure at hb
  simp only [Primitives.withDispersion_p, Primitives.withDispersion_sigma,
    Primitives.withDispersion_b, Primitives.withDispersion_beta,
    Primitives.withDispersion_c, Primitives.withDispersion_r,
    Primitives.withDispersion_lambda] at hb
  change P.p + P.sigma * L.cutoff P.sigma - P.b -
      (P.beta * P.c / (1 - P.beta)) * L.theta P.sigma +
      (P.lambda * P.sigma / (P.r + P.lambda)) *
        P.expectedExcess (L.cutoff P.sigma) = 0 at hb
  have hJD : P.p + P.sigma * L.cutoff P.sigma - P.b -
      P.searchOpportunityCostCoefficient * L.theta P.sigma +
      P.lambda * P.sigma / (P.r + P.lambda) *
        P.expectedExcess (L.cutoff P.sigma) = 0 := by
    simpa [Primitives.searchOpportunityCostCoefficient] using hb
  ring_nf at hJD ⊢
  linear_combination -hJD

theorem equationA12_slopeEquation
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DispersionEquilibriumPath P) :
    (P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.sigma))/(P.r+P.lambda) +
      P.searchOpportunityCostCoefficient*L.theta P.sigma /
        (P.matchingElasticity (L.theta P.sigma)*
          (P.epsUpper-L.cutoff P.sigma)))*L.cutoffSlope =
    (1/P.sigma)*(P.searchOpportunityCostCoefficient*L.theta P.sigma /
      P.matchingElasticity (L.theta P.sigma) - P.sigma*L.cutoff P.sigma -
      P.lambda*P.sigma/(P.r+P.lambda)*
        P.expectedExcess (L.cutoff P.sigma)) := by
  exact appendixA12_slopeEquation_of_A9_A10 A.sigma_ne A.r_add_lambda_ne
    (AM.elasticity_pos L.theta_pos).ne' L.theta_pos.ne'
    (sub_pos.mpr L.cutoff_lt_epsUpper).ne'
    (by convert L.equationA9 A D using 1 <;> ring) (L.equationA10 A M AM)

theorem equationA12_leftCoefficient_pos
    (A : CoreEconomicAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DispersionEquilibriumPath P) :
    0 < P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.sigma))/(P.r+P.lambda) +
      P.searchOpportunityCostCoefficient*L.theta P.sigma /
        (P.matchingElasticity (L.theta P.sigma)*
          (P.epsUpper-L.cutoff P.sigma)) := by
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have h1 : 0 < P.sigma*(P.r+P.lambda*P.cdf (L.cutoff P.sigma))/
      (P.r+P.lambda) := by
    exact div_pos (mul_pos A.sigma_pos (P.r_add_lambda_cdf_pos A _))
      A.r_add_lambda_pos
  have h2 : 0 < P.searchOpportunityCostCoefficient*L.theta P.sigma /
      (P.matchingElasticity (L.theta P.sigma)*
        (P.epsUpper-L.cutoff P.sigma)) := by
    exact div_pos (mul_pos hk L.theta_pos)
      (mul_pos (AM.elasticity_pos L.theta_pos)
        (sub_pos.mpr L.cutoff_lt_epsUpper))
  linarith

theorem cutoffSlope_pos_iff_A12_expression_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DispersionEquilibriumPath P) :
    0 < L.cutoffSlope ↔
      0 < P.searchOpportunityCostCoefficient*L.theta P.sigma /
        P.matchingElasticity (L.theta P.sigma) - P.sigma*L.cutoff P.sigma -
        P.lambda*P.sigma/(P.r+P.lambda)*
          P.expectedExcess (L.cutoff P.sigma) := by
  have heq:=L.equationA12_slopeEquation A D M AM
  have hc:=L.equationA12_leftCoefficient_pos A AM
  have hsInv : 0 < 1/P.sigma := one_div_pos.mpr A.sigma_pos
  constructor
  · intro hd
    have hp : 0 < (1/P.sigma)*(P.searchOpportunityCostCoefficient*L.theta P.sigma /
        P.matchingElasticity (L.theta P.sigma) - P.sigma*L.cutoff P.sigma -
        P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.sigma)) := by
      rw [← heq]
      exact mul_pos hc hd
    rcases mul_pos_iff.mp hp with hp' | hn
    · exact hp'.2
    · exact (not_lt_of_ge hsInv.le hn.1).elim
  · intro hr
    have hp : 0 < (1/P.sigma)*(P.searchOpportunityCostCoefficient*L.theta P.sigma /
        P.matchingElasticity (L.theta P.sigma) - P.sigma*L.cutoff P.sigma -
        P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.sigma)) :=
      mul_pos hsInv hr
    rw [← heq] at hp
    rcases mul_pos_iff.mp hp with hp' | hn
    · exact hp'.2
    · exact (not_lt_of_ge hc.le hn.1).elim

theorem cutoffSlope_pos_of_b_le_p (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (L : DispersionEquilibriumPath P) (hbp : P.b ≤ P.p) :
    0 < L.cutoffSlope := by
  have h12:=L.equationA12 A AM
  have hk : 0 < P.searchOpportunityCostCoefficient := by
    unfold Primitives.searchOpportunityCostCoefficient
    exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos
  have heta:=AM.elasticity_pos L.theta_pos
  have heta1:=AM.elasticity_lt_one L.theta_pos
  have hpositive : 0 < P.searchOpportunityCostCoefficient*L.theta P.sigma /
      P.matchingElasticity (L.theta P.sigma) - P.sigma*L.cutoff P.sigma -
      P.lambda*P.sigma/(P.r+P.lambda)*P.expectedExcess (L.cutoff P.sigma) := by
    rw [h12]
    have : 0 < 1/P.matchingElasticity (L.theta P.sigma)-1 := by
      rw [sub_pos]
      exact (lt_div_iff₀ heta).2 (by simpa using heta1)
    exact add_pos_of_nonneg_of_pos (sub_nonneg.mpr hbp)
      (mul_pos (mul_pos hk L.theta_pos) this)
  exact (L.cutoffSlope_pos_iff_A12_expression_pos A D M AM).2 hpositive

end DispersionEquilibriumPath
end MP1994V2
