import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoffOrdering

/-!
# MP1994 v2: cross-state comparison under the contrary cutoff order

This module develops the maximum-principle comparison used by M9.2B.  Every
cross-state conclusion is conditional on the contrary weak order
`d_R ≤ d_B`; no ordering premise is added to an equilibrium structure.
-/

open MeasureTheory

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Below the recession cutoff, the boom-minus-recession surplus gap is
constant under the contrary weak cutoff order. -/
theorem surplus_gap_eq_at_recession_cutoff_of_le_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom)
    {eps : ℝ} (hEps : eps ≤ E.reservationCutoff A D TA M .recession) :
    E.toTwoStateValueCandidate.surplus .boom eps -
        E.toTwoStateValueCandidate.surplus .recession eps =
      E.toTwoStateValueCandidate.surplus .boom
          (E.reservationCutoff A D TA M .recession) -
        E.toTwoStateValueCandidate.surplus .recession
          (E.reservationCutoff A D TA M .recession) := by
  let dR := E.reservationCutoff A D TA M .recession
  let dB := E.reservationCutoff A D TA M .boom
  have hSRdR : E.toTwoStateValueCandidate.surplus .recession dR = 0 :=
    E.surplus_reservationCutoff_eq_zero A D TA M .recession
  have hSBdB : E.toTwoStateValueCandidate.surplus .boom dB = 0 :=
    E.surplus_reservationCutoff_eq_zero A D TA M .boom
  have hSReps : E.toTwoStateValueCandidate.surplus .recession eps ≤ 0 := by
    have h := (E.surplus_strictMono A D TA .recession).monotone hEps
    simpa [dR, hSRdR] using h
  have hSBeps : E.toTwoStateValueCandidate.surplus .boom eps ≤ 0 := by
    have h := (E.surplus_strictMono A D TA .boom).monotone
      (le_trans hEps hReverse)
    simpa [dB, hSBdB] using h
  have hSBdR : E.toTwoStateValueCandidate.surplus .boom dR ≤ 0 := by
    have h := (E.surplus_strictMono A D TA .boom).monotone hReverse
    simpa [dB, hSBdB] using h
  have hR := E.recession_surplus_difference D eps dR
  have hB := E.boom_surplus_difference D eps dR
  simp only [TwoStateValueCandidate.activeSurplus] at hR hB
  rw [show positivePart (E.toTwoStateValueCandidate.surplus .boom dR) = 0 by
        simp [positivePart, hSBdR],
      show positivePart (E.toTwoStateValueCandidate.surplus .boom eps) = 0 by
        simp [positivePart, hSBeps]] at hR
  rw [show positivePart (E.toTwoStateValueCandidate.surplus .recession dR) = 0 by
        simp [positivePart, hSRdR],
      show positivePart (E.toTwoStateValueCandidate.surplus .recession eps) = 0 by
        simp [positivePart, hSReps]] at hB
  have hCoeff : 0 < P.r + P.lambda + T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  dsimp [dR] at hR hB ⊢
  nlinarith

/-- Under the contrary weak cutoff order, boom surplus is weakly below
recession surplus below the recession cutoff. -/
theorem boom_surplus_le_recession_surplus_below_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom)
    {eps : ℝ} (hEps : eps ≤ E.reservationCutoff A D TA M .recession) :
    E.toTwoStateValueCandidate.surplus .boom eps ≤
      E.toTwoStateValueCandidate.surplus .recession eps := by
  have hGap := E.surplus_gap_eq_at_recession_cutoff_of_le_recession_cutoff
    A D TA M hReverse hEps
  have hBoomAtR := (E.surplus_strictMono A D TA .boom).monotone hReverse
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .boom] at hBoomAtR
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hGap
  linarith

/-- Between reverse-ordered cutoffs, the reservation signs directly imply the
cross-state surplus order. -/
theorem boom_surplus_le_recession_surplus_between_reverse_cutoffs
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    {eps : ℝ}
    (hR : E.reservationCutoff A D TA M .recession ≤ eps)
    (hB : eps ≤ E.reservationCutoff A D TA M .boom) :
    E.toTwoStateValueCandidate.surplus .boom eps ≤
      E.toTwoStateValueCandidate.surplus .recession eps := by
  obtain ⟨hSR, hSB⟩ :=
    E.surplus_signs_between_cutoffs_of_recession_le_boom A D TA M hR hB
  linarith

/-- Above the boom cutoff, the boom-minus-recession surplus gap is constant
under the contrary weak cutoff order. -/
theorem surplus_gap_eq_at_boom_cutoff_of_boom_cutoff_le
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom)
    {eps : ℝ} (hEps : E.reservationCutoff A D TA M .boom ≤ eps) :
    E.toTwoStateValueCandidate.surplus .boom eps -
        E.toTwoStateValueCandidate.surplus .recession eps =
      E.toTwoStateValueCandidate.surplus .boom
          (E.reservationCutoff A D TA M .boom) -
        E.toTwoStateValueCandidate.surplus .recession
          (E.reservationCutoff A D TA M .boom) := by
  let dB := E.reservationCutoff A D TA M .boom
  have hAt := E.both_surplus_nonneg_above_boom_cutoff_of_reverse_order
    A D TA M hReverse (eps := dB) (le_refl dB)
  have hE := E.both_surplus_nonneg_above_boom_cutoff_of_reverse_order
    A D TA M hReverse hEps
  have hR := E.recession_surplus_difference D dB eps
  have hB := E.boom_surplus_difference D dB eps
  simp only [TwoStateValueCandidate.activeSurplus] at hR hB
  rw [show positivePart (E.toTwoStateValueCandidate.surplus .boom eps) =
        E.toTwoStateValueCandidate.surplus .boom eps by
        simp [positivePart, hE.2],
      show positivePart (E.toTwoStateValueCandidate.surplus .boom dB) =
        E.toTwoStateValueCandidate.surplus .boom dB by
        simp [positivePart, hAt.2]] at hR
  rw [show positivePart (E.toTwoStateValueCandidate.surplus .recession eps) =
        E.toTwoStateValueCandidate.surplus .recession eps by
        simp [positivePart, hE.1],
      show positivePart (E.toTwoStateValueCandidate.surplus .recession dB) =
        E.toTwoStateValueCandidate.surplus .recession dB by
        simp [positivePart, hAt.1]] at hB
  have hCoeff : 0 < P.r + P.lambda + 2 * T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  dsimp [dB] at hR hB ⊢
  nlinarith

/-- Under the contrary weak cutoff order, boom surplus is weakly below
recession surplus above the boom cutoff. -/
theorem boom_surplus_le_recession_surplus_above_boom_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom)
    {eps : ℝ} (hEps : E.reservationCutoff A D TA M .boom ≤ eps) :
    E.toTwoStateValueCandidate.surplus .boom eps ≤
      E.toTwoStateValueCandidate.surplus .recession eps := by
  have hGap := E.surplus_gap_eq_at_boom_cutoff_of_boom_cutoff_le
    A D TA M hReverse hEps
  have hRecAtB := (E.surplus_strictMono A D TA .recession).monotone hReverse
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hRecAtB
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .boom] at hGap
  linarith

/-- The contrary cutoff order forces boom surplus below recession surplus at
every idiosyncratic productivity. -/
theorem boom_surplus_le_recession_surplus_of_reverse_cutoff_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) (eps : ℝ) :
    E.toTwoStateValueCandidate.surplus .boom eps ≤
      E.toTwoStateValueCandidate.surplus .recession eps := by
  rcases le_total eps (E.reservationCutoff A D TA M .recession) with hLow | hR
  · exact E.boom_surplus_le_recession_surplus_below_recession_cutoff
      A D TA M hReverse hLow
  rcases le_total eps (E.reservationCutoff A D TA M .boom) with hMid | hHigh
  · exact E.boom_surplus_le_recession_surplus_between_reverse_cutoffs
      A D TA M hR hMid
  · exact E.boom_surplus_le_recession_surplus_above_boom_cutoff
      A D TA M hReverse hHigh

/-- The global reverse-order comparison specialized to the upper support. -/
theorem boom_upper_surplus_le_recession_upper_surplus_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) :
    E.toTwoStateValueCandidate.surplus .boom P.epsUpper ≤
      E.toTwoStateValueCandidate.surplus .recession P.epsUpper :=
  E.boom_surplus_le_recession_surplus_of_reverse_cutoff_order
    A D TA M hReverse P.epsUpper

/-- Statewise free entry expressed in surplus units. -/
theorem statewise_q_mul_surplus_upper_eq
    (A : CoreEconomicAssumptions P) (E : TwoStateValueEquilibrium P T)
    (s : AggregateState) :
    P.q (E.theta s) * E.toTwoStateValueCandidate.surplus s P.epsUpper =
      P.c / (1 - P.beta) := by
  have hVac := E.statewise_vacancy_equation A s
  rw [E.firm_share s P.epsUpper] at hVac
  have hβ : 1 - P.beta ≠ 0 := (sub_pos.mpr A.beta_lt_one).ne'
  apply (eq_div_iff hβ).2
  rw [← hVac]
  ring

/-- Under the contrary cutoff order, free entry and strict decrease of `q`
force boom tightness weakly below recession tightness. -/
theorem boom_tightness_le_recession_tightness_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) :
    E.theta .boom ≤ E.theta .recession := by
  have hS := E.boom_upper_surplus_le_recession_upper_surplus_of_reverse_order
    A D TA M hReverse
  have hSB := E.upper_surplus_pos A M .boom
  have hqR := M.vacancyMeetingRate_pos (E.theta_pos .recession)
  have hProdR := E.statewise_q_mul_surplus_upper_eq A .recession
  have hProdB := E.statewise_q_mul_surplus_upper_eq A .boom
  have hProducts :
      P.q (E.theta .recession) *
          E.toTwoStateValueCandidate.surplus .recession P.epsUpper =
        P.q (E.theta .boom) *
          E.toTwoStateValueCandidate.surplus .boom P.epsUpper := by
    rw [hProdR, hProdB]
  have hMul :
      P.q (E.theta .recession) *
          E.toTwoStateValueCandidate.surplus .boom P.epsUpper ≤
        P.q (E.theta .boom) *
          E.toTwoStateValueCandidate.surplus .boom P.epsUpper := by
    calc
      _ ≤ P.q (E.theta .recession) *
          E.toTwoStateValueCandidate.surplus .recession P.epsUpper :=
        mul_le_mul_of_nonneg_left hS hqR.le
      _ = _ := hProducts
  have hq : P.q (E.theta .recession) ≤ P.q (E.theta .boom) :=
    le_of_mul_le_mul_right hMul hSB
  by_contra hNot
  have hTheta : E.theta .recession < E.theta .boom := lt_of_not_ge hNot
  have hStrict := M.vacancyMeetingRate_strictAntiOn
    (E.theta_pos .recession) (E.theta_pos .boom) hTheta
  exact (not_lt_of_ge hq hStrict)

/-- The upper-support boom-minus-recession surplus gap is nonpositive under
the contrary cutoff order. -/
theorem upper_surplus_gap_nonpos_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) :
    E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper ≤ 0 :=
  sub_nonpos.mpr
    (E.boom_upper_surplus_le_recession_upper_surplus_of_reverse_order
      A D TA M hReverse)

/-- The upper-support gap equals the gap at the boom cutoff, hence minus the
recession surplus there. -/
theorem upper_surplus_gap_eq_boom_cutoff_gap
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) :
    E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper =
      E.toTwoStateValueCandidate.surplus .boom
          (E.reservationCutoff A D TA M .boom) -
        E.toTwoStateValueCandidate.surplus .recession
          (E.reservationCutoff A D TA M .boom) ∧
    E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper =
      -E.toTwoStateValueCandidate.surplus .recession
          (E.reservationCutoff A D TA M .boom) := by
  have hCut := E.reservationCutoff_lt_epsUpper A D TA M .boom
  have hGap := E.surplus_gap_eq_at_boom_cutoff_of_boom_cutoff_le
    A D TA M hReverse hCut.le
  refine ⟨hGap, ?_⟩
  rw [hGap, E.surplus_reservationCutoff_eq_zero A D TA M .boom]
  ring

/-- Pointwise maximum-principle bound: the upper-support raw surplus gap is no
larger than the active-surplus gap at any shock. -/
theorem upper_surplus_gap_le_activeSurplus_gap_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) (x : ℝ) :
    E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper ≤
      E.toTwoStateValueCandidate.activeSurplus .boom x -
        E.toTwoStateValueCandidate.activeSurplus .recession x := by
  have hDu := E.upper_surplus_gap_nonpos_of_reverse_order A D TA M hReverse
  rcases le_total x (E.reservationCutoff A D TA M .recession) with hLow | hR
  · have hSR := (E.surplus_strictMono A D TA .recession).monotone hLow
    rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hSR
    have hSB := (E.surplus_strictMono A D TA .boom).monotone
      (le_trans hLow hReverse)
    rw [E.surplus_reservationCutoff_eq_zero A D TA M .boom] at hSB
    simp [TwoStateValueCandidate.activeSurplus, positivePart, hSR, hSB, hDu]
  rcases le_total x (E.reservationCutoff A D TA M .boom) with hB | hHigh
  · obtain ⟨hSR, hSB⟩ :=
      E.surplus_signs_between_cutoffs_of_recession_le_boom A D TA M hR hB
    have hGap := (E.upper_surplus_gap_eq_boom_cutoff_gap A D TA M hReverse).2
    have hMono := (E.surplus_strictMono A D TA .recession).monotone hB
    rw [hGap]
    simp only [TwoStateValueCandidate.activeSurplus]
    rw [show positivePart (E.toTwoStateValueCandidate.surplus .boom x) = 0 by
          simp [positivePart, hSB],
      show positivePart (E.toTwoStateValueCandidate.surplus .recession x) =
          E.toTwoStateValueCandidate.surplus .recession x by
          simp [positivePart, hSR]]
    linarith
  · have hAt := E.both_surplus_nonneg_above_boom_cutoff_of_reverse_order
      A D TA M hReverse hHigh
    have hGapX := E.surplus_gap_eq_at_boom_cutoff_of_boom_cutoff_le
      A D TA M hReverse hHigh
    have hGapU := (E.upper_surplus_gap_eq_boom_cutoff_gap A D TA M hReverse).1
    simp only [TwoStateValueCandidate.activeSurplus]
    rw [show positivePart (E.toTwoStateValueCandidate.surplus .boom x) =
          E.toTwoStateValueCandidate.surplus .boom x by
          simp [positivePart, hAt.2],
      show positivePart (E.toTwoStateValueCandidate.surplus .recession x) =
          E.toTwoStateValueCandidate.surplus .recession x by
          simp [positivePart, hAt.1]]
    linarith

/-- Integrating the pointwise maximum-principle bound gives the continuation
integral comparison. -/
theorem upper_surplus_gap_le_integral_activeSurplus_gap_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hReverse : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom) :
    E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper ≤
      (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock) -
        (∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hInt := (E.active_surplus_integrable .boom).sub
    (E.active_surplus_integrable .recession)
  have hMono := integral_mono_ae
    (integrable_const
      (E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper))
    hInt (Filter.Eventually.of_forall
      (E.upper_surplus_gap_le_activeSurplus_gap_of_reverse_order
        A D TA M hReverse))
  have hConst :
      (∫ _ : ℝ, E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper ∂P.shock) =
      E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper := by simp
  rw [hConst] at hMono
  rw [← integral_sub (E.active_surplus_integrable .boom)
      (E.active_surplus_integrable .recession)]
  simpa only [Pi.sub_apply] using hMono

/-- Statewise free entry rewrites the employed worker's search gain in terms
of vacancy cost and tightness. -/
theorem statewise_search_gain_eq
    (A : CoreEconomicAssumptions P) (E : TwoStateValueEquilibrium P T)
    (s : AggregateState) :
    P.beta * P.workerMeetingRate (E.theta s) *
        E.toTwoStateValueCandidate.surplus s P.epsUpper =
      (P.beta * P.c / (1 - P.beta)) * E.theta s := by
  have h := E.statewise_q_mul_surplus_upper_eq A s
  unfold Primitives.workerMeetingRate
  calc
    P.beta * (E.theta s * P.q (E.theta s)) *
        E.toTwoStateValueCandidate.surplus s P.epsUpper =
      P.beta * E.theta s *
        (P.q (E.theta s) *
          E.toTwoStateValueCandidate.surplus s P.epsUpper) := by ring
    _ = P.beta * E.theta s * (P.c / (1 - P.beta)) := by rw [h]
    _ = (P.beta * P.c / (1 - P.beta)) * E.theta s := by ring

/-- Difference of the two upper-support coupled surplus equations after
statewise free entry. -/
theorem upper_surplus_gap_equation
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (E : TwoStateValueEquilibrium P T) :
    (P.r + P.lambda + 2 * T.aggregateArrival) *
        (E.toTwoStateValueCandidate.surplus .boom P.epsUpper -
          E.toTwoStateValueCandidate.surplus .recession P.epsUpper) =
      (T.pHigh - P.p)
        + P.lambda *
            ((∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock) -
              (∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock))
        + (P.beta * P.c / (1 - P.beta)) *
            (E.theta .recession - E.theta .boom) := by
  have hR := E.recession_surplus_bellman D P.epsUpper
  have hB := E.boom_surplus_bellman D P.epsUpper
  have hSR := E.upper_surplus_pos A M .recession
  have hSB := E.upper_surplus_pos A M .boom
  have hSearchR := E.statewise_search_gain_eq A .recession
  have hSearchB := E.statewise_search_gain_eq A .boom
  rw [show E.toTwoStateValueCandidate.activeSurplus .boom P.epsUpper =
        E.toTwoStateValueCandidate.surplus .boom P.epsUpper by
        simp [TwoStateValueCandidate.activeSurplus, positivePart, hSB.le]] at hR
  rw [show E.toTwoStateValueCandidate.activeSurplus .recession P.epsUpper =
        E.toTwoStateValueCandidate.surplus .recession P.epsUpper by
        simp [TwoStateValueCandidate.activeSurplus, positivePart, hSR.le]] at hB
  rw [hSearchR] at hR
  rw [hSearchB] at hB
  linear_combination hB - hR

end TwoStateValueEquilibrium
end MP1994V2
