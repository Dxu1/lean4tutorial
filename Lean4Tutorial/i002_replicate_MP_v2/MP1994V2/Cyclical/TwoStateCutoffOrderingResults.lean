import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCrossStateComparison

/-!
# MP1994 v2: boom and recession cutoff ordering

This module closes the maximum-principle contradiction and proves the M9.2B
cutoff order.  It introduces no cutoff-order, surplus-order, tightness-order,
or search-gain assumption.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- The contrary weak cutoff order is inconsistent with the coupled surplus
system, free entry, and the maintained primitive assumptions. -/
theorem not_recession_cutoff_le_boom_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    ¬ E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom := by
  intro hReverse
  let Du := E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
    E.toTwoStateValueCandidate.surplus .recession P.epsUpper
  let IB := ∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock
  let IR := ∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock
  let K := P.beta * P.c / (1 - P.beta)
  have hDu : Du ≤ 0 := by
    exact E.upper_surplus_gap_nonpos_of_reverse_order A D TA M hReverse
  have hTheta : E.theta .boom ≤ E.theta .recession :=
    E.boom_tightness_le_recession_tightness_of_reverse_order
      A D TA M hReverse
  have hIntegral : Du ≤ IB - IR := by
    exact E.upper_surplus_gap_le_integral_activeSurplus_gap_of_reverse_order
      A D TA M hReverse
  have hEquation := E.upper_surplus_gap_equation A D M
  change (P.r + P.lambda + 2 * T.aggregateArrival) * Du =
    (T.pHigh - P.p) + P.lambda * (IB - IR) +
      K * (E.theta .recession - E.theta .boom) at hEquation
  have hK : 0 < K := by
    dsimp [K]
    exact div_pos (mul_pos A.beta_pos A.c_pos) (sub_pos.mpr A.beta_lt_one)
  have hTightnessTerm :
      0 ≤ K * (E.theta .recession - E.theta .boom) :=
    mul_nonneg hK.le (sub_nonneg.mpr hTheta)
  have hContinuationTerm : P.lambda * Du ≤ P.lambda * (IB - IR) :=
    mul_le_mul_of_nonneg_left hIntegral A.lambda_nonneg
  have hMaximumPrinciple :
      (T.pHigh - P.p) + P.lambda * Du ≤
        (P.r + P.lambda + 2 * T.aggregateArrival) * Du := by
    nlinarith [hEquation, hTightnessTerm, hContinuationTerm]
  have hReduced :
      T.pHigh - P.p ≤ (P.r + 2 * T.aggregateArrival) * Du := by
    nlinarith [hMaximumPrinciple]
  have hCoefficient : 0 < P.r + 2 * T.aggregateArrival := by
    linarith [A.r_pos, TA.aggregateArrival_pos]
  have hLeftNonpos : (P.r + 2 * T.aggregateArrival) * Du ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos hCoefficient.le hDu
  have hProductivityGap : 0 < T.pHigh - P.p := sub_pos.mpr TA.p_lt_pHigh
  linarith

/-- M9.2B main theorem: the boom reservation cutoff is strictly below the
recession reservation cutoff. -/
theorem boom_cutoff_lt_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    E.reservationCutoff A D TA M .boom <
      E.reservationCutoff A D TA M .recession := by
  exact lt_of_not_ge (E.not_recession_cutoff_le_boom_cutoff A D TA M)

/-- With the proved cutoff order, the boom-minus-recession surplus gap is
constant above the recession cutoff. -/
theorem surplus_gap_eq_at_recession_cutoff_of_recession_cutoff_le
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    {eps : ℝ} (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    E.toTwoStateValueCandidate.surplus .boom eps -
        E.toTwoStateValueCandidate.surplus .recession eps =
      E.toTwoStateValueCandidate.surplus .boom
          (E.reservationCutoff A D TA M .recession) -
        E.toTwoStateValueCandidate.surplus .recession
          (E.reservationCutoff A D TA M .recession) := by
  let dR := E.reservationCutoff A D TA M .recession
  have hOrder := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hAt := E.both_surplus_nonneg_above_recession_cutoff
    A D TA M hOrder (eps := dR) (le_refl dR)
  have hE := E.both_surplus_nonneg_above_recession_cutoff
    A D TA M hOrder hEps
  have hR := E.recession_surplus_difference D dR eps
  have hB := E.boom_surplus_difference D dR eps
  simp only [TwoStateValueCandidate.activeSurplus] at hR hB
  rw [show positivePart (E.toTwoStateValueCandidate.surplus .boom eps) =
        E.toTwoStateValueCandidate.surplus .boom eps by
        simp [positivePart, hE.1],
      show positivePart (E.toTwoStateValueCandidate.surplus .boom dR) =
        E.toTwoStateValueCandidate.surplus .boom dR by
        simp [positivePart, hAt.1]] at hR
  rw [show positivePart (E.toTwoStateValueCandidate.surplus .recession eps) =
        E.toTwoStateValueCandidate.surplus .recession eps by
        simp [positivePart, hE.2],
      show positivePart (E.toTwoStateValueCandidate.surplus .recession dR) =
        E.toTwoStateValueCandidate.surplus .recession dR by
        simp [positivePart, hAt.2]] at hB
  have hCoefficient : 0 < P.r + P.lambda + 2 * T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  dsimp [dR] at hR hB ⊢
  nlinarith

/-- The boom upper-support surplus is strictly larger once the cutoff order is
proved. -/
theorem recession_upper_surplus_lt_boom_upper_surplus
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    E.toTwoStateValueCandidate.surplus .recession P.epsUpper <
      E.toTwoStateValueCandidate.surplus .boom P.epsUpper := by
  have hOrder := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hGap := E.surplus_gap_eq_at_recession_cutoff_of_recession_cutoff_le
    A D TA M (E.reservationCutoff_lt_epsUpper A D TA M .recession).le
  have hBoomAtR :=
    (E.surplus_pos_iff_reservationCutoff_lt A D TA M .boom
      (E.reservationCutoff A D TA M .recession)).2 hOrder
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hGap
  linarith

/-- Free entry turns the strict upper-surplus order into strictly greater boom
market tightness. -/
theorem recession_tightness_lt_boom_tightness
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    E.theta .recession < E.theta .boom := by
  have hS := E.recession_upper_surplus_lt_boom_upper_surplus A D TA M
  have hSR := E.upper_surplus_pos A M .recession
  have hqB := M.vacancyMeetingRate_pos (E.theta_pos .boom)
  have hProdR := E.statewise_q_mul_surplus_upper_eq A .recession
  have hProdB := E.statewise_q_mul_surplus_upper_eq A .boom
  have hProducts :
      P.q (E.theta .boom) *
          E.toTwoStateValueCandidate.surplus .boom P.epsUpper =
        P.q (E.theta .recession) *
          E.toTwoStateValueCandidate.surplus .recession P.epsUpper := by
    rw [hProdB, hProdR]
  have hq : P.q (E.theta .boom) < P.q (E.theta .recession) := by
    by_contra hNot
    have hqWeak : P.q (E.theta .recession) ≤ P.q (E.theta .boom) :=
      le_of_not_gt hNot
    have hWeak :
        P.q (E.theta .recession) *
            E.toTwoStateValueCandidate.surplus .recession P.epsUpper ≤
          P.q (E.theta .boom) *
            E.toTwoStateValueCandidate.surplus .recession P.epsUpper :=
      mul_le_mul_of_nonneg_right hqWeak hSR.le
    have hStrict :
        P.q (E.theta .boom) *
            E.toTwoStateValueCandidate.surplus .recession P.epsUpper <
          P.q (E.theta .boom) *
            E.toTwoStateValueCandidate.surplus .boom P.epsUpper :=
      mul_lt_mul_of_pos_left hS hqB
    exact not_lt_of_ge hProducts.le (lt_of_le_of_lt hWeak hStrict)
  apply lt_of_not_ge
  intro hTheta
  rcases hTheta.eq_or_lt with hEq | hStrictTheta
  · rw [hEq] at hq
    exact (lt_irrefl _ hq)
  · have hStrictQ := M.vacancyMeetingRate_strictAntiOn
      (E.theta_pos .boom) (E.theta_pos .recession) hStrictTheta
    exact not_lt_of_ge hq.le hStrictQ

/-- M9.2B capstone: simultaneous statewise monotonicity and unique cutoffs,
the strict paper cutoff order, and its strict upper-surplus and tightness
consequences. -/
theorem m9_2B_cutoff_ordering_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∀ s, StrictMono (E.toTwoStateValueCandidate.surplus s)) ∧
      (∀ s, ∃! eps, E.toTwoStateValueCandidate.surplus s eps = 0) ∧
      E.reservationCutoff A D TA M .boom <
        E.reservationCutoff A D TA M .recession ∧
      E.toTwoStateValueCandidate.surplus .recession P.epsUpper <
        E.toTwoStateValueCandidate.surplus .boom P.epsUpper ∧
      E.theta .recession < E.theta .boom := by
  exact ⟨fun s => E.surplus_strictMono A D TA s,
    fun s => E.existsUnique_surplus_zero A D TA M s,
    E.boom_cutoff_lt_recession_cutoff A D TA M,
    E.recession_upper_surplus_lt_boom_upper_surplus A D TA M,
    E.recession_tightness_lt_boom_tightness A D TA M⟩

end TwoStateValueEquilibrium
end MP1994V2
