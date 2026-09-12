import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Matching
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Probability

/-!
# MP1994 v2 Appendix: matching differentiability

This separate layer records only the differentiability and elasticity
restrictions used on journal pages 413--414. It does not strengthen the core
matching assumptions.
-/

open Set

namespace MP1994V2

namespace Primitives

/-- Paper matching elasticity `eta(theta) = -theta q'(theta) / q(theta)`. -/
noncomputable def matchingElasticity (P : Primitives) (theta : ℝ) : ℝ :=
  -(theta * deriv P.q theta / P.q theta)

end Primitives

/-- Appendix-specific smoothness and elasticity restrictions. -/
structure AppendixMatchingAssumptions (P : Primitives) : Prop where
  q_differentiableOn_pos : DifferentiableOn ℝ P.q (Ioi 0)
  elasticity_pos : ∀ {theta : ℝ}, 0 < theta → 0 < P.matchingElasticity theta
  elasticity_lt_one : ∀ {theta : ℝ}, 0 < theta → P.matchingElasticity theta < 1

namespace Primitives

variable {P : Primitives}

theorem q_ne_of_pos (M : MatchingAssumptions P) {theta : ℝ}
    (htheta : 0 < theta) : P.q theta ≠ 0 :=
  (M.vacancyMeetingRate_pos htheta).ne'

theorem matchingElasticity_ne
    (AM : AppendixMatchingAssumptions P) {theta : ℝ}
    (htheta : 0 < theta) : P.matchingElasticity theta ≠ 0 :=
  (AM.elasticity_pos htheta).ne'

theorem deriv_q_eq_neg_elasticity_mul
    (M : MatchingAssumptions P) {theta : ℝ}
    (htheta : 0 < theta) :
    deriv P.q theta =
      -(P.matchingElasticity theta * P.q theta / theta) := by
  have hq := P.q_ne_of_pos M htheta
  have ht : theta ≠ 0 := htheta.ne'
  unfold matchingElasticity
  field_simp [hq, ht]

theorem deriv_q_neg
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    {theta : ℝ} (htheta : 0 < theta) : deriv P.q theta < 0 := by
  rw [P.deriv_q_eq_neg_elasticity_mul M htheta]
  exact neg_lt_zero.mpr
    (div_pos (mul_pos (AM.elasticity_pos htheta)
      (M.vacancyMeetingRate_pos htheta)) htheta)

theorem one_sub_matchingElasticity_pos
    (AM : AppendixMatchingAssumptions P) {theta : ℝ}
    (htheta : 0 < theta) : 0 < 1 - P.matchingElasticity theta := by
  linarith [AM.elasticity_lt_one htheta]

theorem r_add_lambda_cdf_pos
    (A : CoreEconomicAssumptions P) (d : ℝ) :
    0 < P.r + P.lambda * P.cdf d := by
  have hcdf : 0 ≤ P.cdf d := ENNReal.toReal_nonneg
  exact add_pos_of_pos_of_nonneg A.r_pos
    (mul_nonneg A.lambda_nonneg hcdf)

end Primitives

end MP1994V2
