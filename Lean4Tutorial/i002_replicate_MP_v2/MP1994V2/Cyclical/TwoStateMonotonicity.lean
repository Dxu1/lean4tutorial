import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateSurplus

/-!
# MP1994 v2: simultaneous two-state surplus monotonicity

The two surplus functions are treated as a coupled system.  Neither state's
monotonicity is assumed in order to prove the other's.
-/

namespace MP1994V2

/-- Positive part is monotone. -/
theorem positivePart_mono {x₁ x₂ : ℝ} (h : x₁ ≤ x₂) :
    positivePart x₁ ≤ positivePart x₂ := by
  unfold positivePart
  exact max_le_max_right 0 h

/-- Along an increasing pair, the positive-part increment is nonnegative. -/
theorem positivePart_sub_nonneg {x₁ x₂ : ℝ} (h : x₁ ≤ x₂) :
    0 ≤ positivePart x₂ - positivePart x₁ :=
  sub_nonneg.mpr (positivePart_mono h)

/-- Positive part is one-Lipschitz in difference form along an increasing pair. -/
theorem positivePart_sub_le {x₁ x₂ : ℝ} (h : x₁ ≤ x₂) :
    positivePart x₂ - positivePart x₁ ≤ x₂ - x₁ := by
  unfold positivePart
  rcases le_total x₂ 0 with hx₂ | hx₂
  · rw [max_eq_right hx₂, max_eq_right (le_trans h hx₂)]
    linarith
  · rcases le_total x₁ 0 with hx₁ | hx₁
    · rw [max_eq_left hx₂, max_eq_right hx₁]
      linarith
    · rw [max_eq_left hx₂, max_eq_left hx₁]

/-- If the raw increment is nonpositive, the positive-part increment is no
smaller than the raw increment. -/
theorem le_positivePart_sub_of_sub_nonpos {x₁ x₂ : ℝ}
    (h : x₂ - x₁ ≤ 0) :
    x₂ - x₁ ≤ positivePart x₂ - positivePart x₁ := by
  have h₂₁ : x₂ ≤ x₁ := sub_nonpos.mp h
  by_cases hx₁ : x₁ ≤ 0
  · have hx₂ : x₂ ≤ 0 := le_trans h₂₁ hx₁
    simp [positivePart, max_eq_right hx₁, max_eq_right hx₂, h]
  by_cases hx₂ : 0 ≤ x₂
  · have hx₁' : 0 ≤ x₁ := le_trans hx₂ h₂₁
    simp [positivePart, max_eq_left hx₁', max_eq_left hx₂]
  · have hx₂' : x₂ ≤ 0 := le_of_not_ge hx₂
    have hx₁' : 0 ≤ x₁ := le_of_not_ge hx₁
    unfold positivePart
    rw [max_eq_right hx₂', max_eq_left hx₁']
    linarith

/-- Absolute positive-part increments are bounded by absolute raw increments. -/
theorem abs_positivePart_sub_le (x₁ x₂ : ℝ) :
    |positivePart x₂ - positivePart x₁| ≤ |x₂ - x₁| := by
  have h := MeasureTheory.Lp.lipschitzWith_pos_part.dist_le_mul x₂ x₁
  simpa [positivePart, Real.dist_eq] using h

namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Recession surplus increments satisfy the first coupled difference equation. -/
theorem recession_surplus_difference (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps₁ eps₂ : ℝ) :
    (P.r + P.lambda + T.aggregateArrival) *
        (E.toTwoStateValueCandidate.surplus .recession eps₂ -
          E.toTwoStateValueCandidate.surplus .recession eps₁) =
      P.sigma * (eps₂ - eps₁) + T.aggregateArrival *
        (E.toTwoStateValueCandidate.activeSurplus .boom eps₂ -
          E.toTwoStateValueCandidate.activeSurplus .boom eps₁) := by
  have h₂ := E.recession_surplus_bellman D eps₂
  have h₁ := E.recession_surplus_bellman D eps₁
  linear_combination h₂ - h₁

/-- Boom surplus increments satisfy the second coupled difference equation. -/
theorem boom_surplus_difference (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps₁ eps₂ : ℝ) :
    (P.r + P.lambda + T.aggregateArrival) *
        (E.toTwoStateValueCandidate.surplus .boom eps₂ -
          E.toTwoStateValueCandidate.surplus .boom eps₁) =
      P.sigma * (eps₂ - eps₁) + T.aggregateArrival *
        (E.toTwoStateValueCandidate.activeSurplus .recession eps₂ -
          E.toTwoStateValueCandidate.activeSurplus .recession eps₁) := by
  have h₂ := E.boom_surplus_bellman D eps₂
  have h₁ := E.boom_surplus_bellman D eps₁
  linear_combination h₂ - h₁

/-- Both statewise surplus increments are strictly positive simultaneously. -/
theorem surplus_increment_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (E : TwoStateValueEquilibrium P T) {eps₁ eps₂ : ℝ} (h : eps₁ < eps₂) :
    0 < E.toTwoStateValueCandidate.surplus .recession eps₂ -
          E.toTwoStateValueCandidate.surplus .recession eps₁ ∧
      0 < E.toTwoStateValueCandidate.surplus .boom eps₂ -
          E.toTwoStateValueCandidate.surplus .boom eps₁ := by
  let dR := E.toTwoStateValueCandidate.surplus .recession eps₂ -
    E.toTwoStateValueCandidate.surplus .recession eps₁
  let dB := E.toTwoStateValueCandidate.surplus .boom eps₂ -
    E.toTwoStateValueCandidate.surplus .boom eps₁
  have ha : 0 < P.r + P.lambda + T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  have hrl : 0 < P.r + P.lambda := by linarith [A.r_pos, A.lambda_nonneg]
  have hs : 0 < P.sigma * (eps₂ - eps₁) :=
    mul_pos A.sigma_pos (sub_pos.mpr h)
  have hR := E.recession_surplus_difference D eps₁ eps₂
  have hB := E.boom_surplus_difference D eps₁ eps₂
  change (P.r + P.lambda + T.aggregateArrival) * dR = _ at hR
  change (P.r + P.lambda + T.aggregateArrival) * dB = _ at hB
  have proveR : 0 < dR := by
    by_contra hn
    have hdR : dR ≤ 0 := le_of_not_gt hn
    by_cases hdB : 0 ≤ dB
    · have hpB : 0 ≤
          E.toTwoStateValueCandidate.activeSurplus .boom eps₂ -
            E.toTwoStateValueCandidate.activeSurplus .boom eps₁ := by
        apply positivePart_sub_nonneg
        exact sub_nonneg.mp hdB
      nlinarith [TA.aggregateArrival_pos]
    · have hdB' : dB ≤ 0 := le_of_not_ge hdB
      by_cases hRB : dR ≤ dB
      · have hpB : dB ≤
            E.toTwoStateValueCandidate.activeSurplus .boom eps₂ -
              E.toTwoStateValueCandidate.activeSurplus .boom eps₁ := by
          apply le_positivePart_sub_of_sub_nonpos
          exact hdB'
        nlinarith [TA.aggregateArrival_pos]
      · have hBR : dB ≤ dR := le_of_not_ge hRB
        have hpR : dR ≤
            E.toTwoStateValueCandidate.activeSurplus .recession eps₂ -
              E.toTwoStateValueCandidate.activeSurplus .recession eps₁ := by
          apply le_positivePart_sub_of_sub_nonpos
          exact hdR
        nlinarith [TA.aggregateArrival_pos]
  have proveB : 0 < dB := by
    by_contra hn
    have hdB : dB ≤ 0 := le_of_not_gt hn
    have hpR : 0 ≤
        E.toTwoStateValueCandidate.activeSurplus .recession eps₂ -
          E.toTwoStateValueCandidate.activeSurplus .recession eps₁ := by
      apply positivePart_sub_nonneg
      exact (sub_pos.mp proveR).le
    nlinarith [TA.aggregateArrival_pos]
  exact ⟨proveR, proveB⟩

/-- Surplus is strictly increasing in every aggregate state. -/
theorem surplus_strictMono
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    StrictMono (E.toTwoStateValueCandidate.surplus s) := by
  intro eps₁ eps₂ h
  have hBoth := E.surplus_increment_pos A D TA h
  cases s
  · exact sub_pos.mp hBoth.1
  · exact sub_pos.mp hBoth.2

/-- Lower quantitative increment bound for either aggregate state. -/
theorem surplus_difference_lowerBound
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState)
    {eps₁ eps₂ : ℝ} (h : eps₁ ≤ eps₂) :
    P.sigma / (P.r + P.lambda + T.aggregateArrival) * (eps₂ - eps₁) ≤
      E.toTwoStateValueCandidate.surplus s eps₂ -
        E.toTwoStateValueCandidate.surplus s eps₁ := by
  rcases h.eq_or_lt with rfl | hlt
  · simp
  have hBoth := E.surplus_increment_pos A D TA hlt
  have ha : 0 < P.r + P.lambda + T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  cases s
  · have hEq := E.recession_surplus_difference D eps₁ eps₂
    have hp : 0 ≤ E.toTwoStateValueCandidate.activeSurplus .boom eps₂ -
        E.toTwoStateValueCandidate.activeSurplus .boom eps₁ :=
      positivePart_sub_nonneg (sub_pos.mp hBoth.2).le
    calc
      P.sigma / (P.r + P.lambda + T.aggregateArrival) * (eps₂ - eps₁) =
          (P.sigma * (eps₂ - eps₁)) /
            (P.r + P.lambda + T.aggregateArrival) := by ring
      _ ≤ _ := (div_le_iff₀ ha).2 (by nlinarith [hEq, TA.aggregateArrival_pos])
  · have hEq := E.boom_surplus_difference D eps₁ eps₂
    have hp : 0 ≤ E.toTwoStateValueCandidate.activeSurplus .recession eps₂ -
        E.toTwoStateValueCandidate.activeSurplus .recession eps₁ :=
      positivePart_sub_nonneg (sub_pos.mp hBoth.1).le
    calc
      P.sigma / (P.r + P.lambda + T.aggregateArrival) * (eps₂ - eps₁) =
          (P.sigma * (eps₂ - eps₁)) /
            (P.r + P.lambda + T.aggregateArrival) := by ring
      _ ≤ _ := (div_le_iff₀ ha).2 (by nlinarith [hEq, TA.aggregateArrival_pos])

/-- Upper quantitative increment bound for either aggregate state. -/
theorem surplus_difference_upperBound
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState)
    {eps₁ eps₂ : ℝ} (h : eps₁ ≤ eps₂) :
    E.toTwoStateValueCandidate.surplus s eps₂ -
        E.toTwoStateValueCandidate.surplus s eps₁ ≤
      P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by
  rcases h.eq_or_lt with rfl | hlt
  · simp
  let dR := E.toTwoStateValueCandidate.surplus .recession eps₂ -
    E.toTwoStateValueCandidate.surplus .recession eps₁
  let dB := E.toTwoStateValueCandidate.surplus .boom eps₂ -
    E.toTwoStateValueCandidate.surplus .boom eps₁
  have hBoth := E.surplus_increment_pos A D TA hlt
  have hrl : 0 < P.r + P.lambda := by linarith [A.r_pos, A.lambda_nonneg]
  have hR := E.recession_surplus_difference D eps₁ eps₂
  have hB := E.boom_surplus_difference D eps₁ eps₂
  change (P.r + P.lambda + T.aggregateArrival) * dR = _ at hR
  change (P.r + P.lambda + T.aggregateArrival) * dB = _ at hB
  have hpR : E.toTwoStateValueCandidate.activeSurplus .recession eps₂ -
      E.toTwoStateValueCandidate.activeSurplus .recession eps₁ ≤ dR :=
    positivePart_sub_le (sub_pos.mp hBoth.1).le
  have hpB : E.toTwoStateValueCandidate.activeSurplus .boom eps₂ -
      E.toTwoStateValueCandidate.activeSurplus .boom eps₁ ≤ dB :=
    positivePart_sub_le (sub_pos.mp hBoth.2).le
  have boundR : dR ≤ P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by
    by_cases hmax : dB ≤ dR
    · calc
        dR ≤ (P.sigma * (eps₂ - eps₁)) / (P.r + P.lambda) :=
          (le_div_iff₀ hrl).2 (by nlinarith [TA.aggregateArrival_pos])
        _ = P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by ring
    · have hmax' : dR ≤ dB := le_of_not_ge hmax
      have boundB : dB ≤ P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by
        calc
          dB ≤ (P.sigma * (eps₂ - eps₁)) / (P.r + P.lambda) :=
            (le_div_iff₀ hrl).2 (by nlinarith [TA.aggregateArrival_pos])
          _ = P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by ring
      exact le_trans hmax' boundB
  have boundB : dB ≤ P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by
    by_cases hmax : dR ≤ dB
    · calc
        dB ≤ (P.sigma * (eps₂ - eps₁)) / (P.r + P.lambda) :=
          (le_div_iff₀ hrl).2 (by nlinarith [TA.aggregateArrival_pos])
        _ = P.sigma / (P.r + P.lambda) * (eps₂ - eps₁) := by ring
    · exact le_trans (le_of_not_ge hmax) boundR
  cases s
  · exact boundR
  · exact boundB

/-- Each statewise surplus function is globally Lipschitz. -/
theorem surplus_lipschitz
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    LipschitzWith ⟨P.sigma / (P.r + P.lambda),
      div_nonneg A.sigma_pos.le (by linarith [A.r_pos, A.lambda_nonneg])⟩
      (E.toTwoStateValueCandidate.surplus s) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  change |E.toTwoStateValueCandidate.surplus s x -
      E.toTwoStateValueCandidate.surplus s y| ≤
    (P.sigma / (P.r + P.lambda)) * |x - y|
  rcases le_total x y with hxy | hyx
  · rw [abs_of_nonpos (sub_nonpos.mpr
      ((E.surplus_strictMono A D TA s).monotone hxy)),
      abs_of_nonpos (sub_nonpos.mpr hxy)]
    simpa [sub_eq_add_neg] using E.surplus_difference_upperBound A D TA s hxy
  · rw [abs_of_nonneg (sub_nonneg.mpr
      ((E.surplus_strictMono A D TA s).monotone hyx)),
      abs_of_nonneg (sub_nonneg.mpr hyx)]
    simpa [sub_eq_add_neg] using E.surplus_difference_upperBound A D TA s hyx

/-- Statewise surplus continuity is derived rather than assumed. -/
theorem surplus_continuous
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    Continuous (E.toTwoStateValueCandidate.surplus s) :=
  (E.surplus_lipschitz A D TA s).continuous

/-- Statewise free entry and matching positivity make the upper-support firm
value strictly positive. -/
theorem upper_firm_value_pos
    (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    0 < E.J s P.epsUpper := by
  have hq := M.vacancyMeetingRate_pos (E.theta_pos s)
  have hc := E.statewise_vacancy_equation A s
  by_contra hJ
  have hJle : E.J s P.epsUpper ≤ 0 := le_of_not_gt hJ
  have hprodle : P.q (E.theta s) * E.J s P.epsUpper ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos hq.le hJle
  rw [hc] at hprodle
  exact (not_le_of_gt A.c_pos) hprodle

/-- The upper-support surplus is strictly positive in both aggregate states. -/
theorem upper_surplus_pos
    (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    0 < E.toTwoStateValueCandidate.surplus s P.epsUpper := by
  have hJ := E.upper_firm_value_pos A M s
  have hShare := E.firm_share s P.epsUpper
  have hβ : 0 < 1 - P.beta := sub_pos.mpr A.beta_lt_one
  nlinarith

/-- Each state has an explicit point below `epsUpper` with negative surplus. -/
theorem exists_surplus_neg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    ∃ eps < P.epsUpper,
      E.toTwoStateValueCandidate.surplus s eps < 0 := by
  let a := P.r + P.lambda + T.aggregateArrival
  have ha : 0 < a := by
    dsimp [a]
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  let eps := P.epsUpper -
    a * (E.toTwoStateValueCandidate.surplus s P.epsUpper + 1) / P.sigma
  have hUpper := E.upper_surplus_pos A M s
  have hstep : 0 <
      a * (E.toTwoStateValueCandidate.surplus s P.epsUpper + 1) / P.sigma :=
    div_pos (mul_pos ha (by linarith)) A.sigma_pos
  have hLower := E.surplus_difference_lowerBound A D TA s (show eps ≤ P.epsUpper by
    dsimp [eps]
    linarith)
  refine ⟨eps, by dsimp [eps]; linarith, ?_⟩
  have hcalc :
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
          (P.epsUpper - eps) =
        E.toTwoStateValueCandidate.surplus s P.epsUpper + 1 := by
    change P.sigma / a * (P.epsUpper - eps) = _
    dsimp [eps]
    field_simp [A.sigma_pos.ne', ha.ne']
    ring
  rw [hcalc] at hLower
  nlinarith

end TwoStateValueEquilibrium
end MP1994V2
