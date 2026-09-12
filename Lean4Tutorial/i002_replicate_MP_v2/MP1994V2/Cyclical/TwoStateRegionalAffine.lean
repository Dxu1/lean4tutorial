import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateOrderedRegionalEquations

/-!
# MP1994 v2: regional affine consequences

The main results are difference identities derived from the coupled Bellman
system.  Pointwise affine and derivative statements are consequences, never
assumptions or equilibrium fields.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Above the recession cutoff, recession and boom surplus increments coincide
and have the paper's common slope. -/
private theorem surplus_differences_above_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps1 eps2 : ℝ}
    (hCutoff : E.reservationCutoff A D TA M .recession ≤ eps1)
    (hOrder : eps1 ≤ eps2) :
    (E.surplus .recession eps2 - E.surplus .recession eps1 =
        P.sigma / (P.r + P.lambda) * (eps2 - eps1)) ∧
      (E.surplus .boom eps2 - E.surplus .boom eps1 =
        P.sigma / (P.r + P.lambda) * (eps2 - eps1)) := by
  have hPaperOrder := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hSigns1 := E.both_surplus_nonneg_above_recession_cutoff
    A D TA M hPaperOrder hCutoff
  have hSigns2 := E.both_surplus_nonneg_above_recession_cutoff
    A D TA M hPaperOrder (le_trans hCutoff hOrder)
  have hR := E.recession_surplus_difference D eps1 eps2
  have hB := E.boom_surplus_difference D eps1 eps2
  simp only [TwoStateValueCandidate.activeSurplus] at hR hB
  rw [show positivePart (E.surplus .boom eps2) = E.surplus .boom eps2 by
        simp [positivePart, hSigns2.1],
      show positivePart (E.surplus .boom eps1) = E.surplus .boom eps1 by
        simp [positivePart, hSigns1.1]] at hR
  rw [show positivePart (E.surplus .recession eps2) =
        E.surplus .recession eps2 by simp [positivePart, hSigns2.2],
      show positivePart (E.surplus .recession eps1) =
        E.surplus .recession eps1 by simp [positivePart, hSigns1.2]] at hB
  let dR := E.surplus .recession eps2 - E.surplus .recession eps1
  let dB := E.surplus .boom eps2 - E.surplus .boom eps1
  have hCommonCoeff : 0 < P.r + P.lambda + 2 * T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  have hRate : 0 < P.r + P.lambda := by
    linarith [A.r_pos, A.lambda_nonneg]
  change (P.r + P.lambda + T.aggregateArrival) * dR =
    P.sigma * (eps2 - eps1) + T.aggregateArrival * dB at hR
  change (P.r + P.lambda + T.aggregateArrival) * dB =
    P.sigma * (eps2 - eps1) + T.aggregateArrival * dR at hB
  have hEqual : dR = dB := by nlinarith
  have hScaledR : (P.r + P.lambda) * dR = P.sigma * (eps2 - eps1) := by
    nlinarith [hR]
  have hScaledB : (P.r + P.lambda) * dB = P.sigma * (eps2 - eps1) := by
    rw [← hEqual]
    exact hScaledR
  constructor
  · change dR = _
    calc
      dR = (P.sigma * (eps2 - eps1)) / (P.r + P.lambda) :=
        (eq_div_iff hRate.ne').2 (by nlinarith [hScaledR])
      _ = P.sigma / (P.r + P.lambda) * (eps2 - eps1) := by ring
  · change dB = _
    calc
      dB = (P.sigma * (eps2 - eps1)) / (P.r + P.lambda) :=
        (eq_div_iff hRate.ne').2 (by nlinarith [hScaledB])
      _ = P.sigma / (P.r + P.lambda) * (eps2 - eps1) := by ring

/-- Recession surplus has slope `sigma / (r + lambda)` above the recession
cutoff. -/
theorem recession_surplus_difference_above_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps1 eps2 : ℝ}
    (hCutoff : E.reservationCutoff A D TA M .recession ≤ eps1)
    (hOrder : eps1 ≤ eps2) :
    E.surplus .recession eps2 - E.surplus .recession eps1 =
      P.sigma / (P.r + P.lambda) * (eps2 - eps1) :=
  (E.surplus_differences_above_recession_cutoff
    A D TA M hCutoff hOrder).1

/-- Boom surplus has the same slope above the recession cutoff. -/
theorem boom_surplus_difference_above_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps1 eps2 : ℝ}
    (hCutoff : E.reservationCutoff A D TA M .recession ≤ eps1)
    (hOrder : eps1 ≤ eps2) :
    E.surplus .boom eps2 - E.surplus .boom eps1 =
      P.sigma / (P.r + P.lambda) * (eps2 - eps1) :=
  (E.surplus_differences_above_recession_cutoff
    A D TA M hCutoff hOrder).2

/-- Difference-form paper equation (21), the foundation for any derivative
corollary. -/
theorem equation21_difference
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps1 eps2 : ℝ}
    (hCutoff : E.reservationCutoff A D TA M .recession ≤ eps1)
    (hOrder : eps1 ≤ eps2) :
    (E.surplus .recession eps2 - E.surplus .recession eps1 =
        P.sigma / (P.r + P.lambda) * (eps2 - eps1)) ∧
      (E.surplus .boom eps2 - E.surplus .boom eps1 =
        P.sigma / (P.r + P.lambda) * (eps2 - eps1)) :=
  E.surplus_differences_above_recession_cutoff
    A D TA M hCutoff hOrder

/-- Between the two cutoffs, boom surplus has slope
`sigma / (r + lambda + mu)`. -/
theorem boom_surplus_difference_between_cutoffs
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps1 eps2 : ℝ}
    (hBoom : E.reservationCutoff A D TA M .boom ≤ eps1)
    (hOrder : eps1 ≤ eps2)
    (hRecession : eps2 ≤ E.reservationCutoff A D TA M .recession) :
    E.surplus .boom eps2 - E.surplus .boom eps1 =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) * (eps2 - eps1) := by
  have hSigns1 := E.surplus_signs_between_cutoffs_of_boom_lt_recession
    A D TA M hBoom (le_trans hOrder hRecession)
  have hSigns2 := E.surplus_signs_between_cutoffs_of_boom_lt_recession
    A D TA M (le_trans hBoom hOrder) hRecession
  have hEq := E.boom_surplus_difference D eps1 eps2
  simp only [TwoStateValueCandidate.activeSurplus] at hEq
  rw [show positivePart (E.surplus .recession eps2) = 0 by
        simp [positivePart, hSigns2.2],
      show positivePart (E.surplus .recession eps1) = 0 by
        simp [positivePart, hSigns1.2]] at hEq
  have hRate : 0 < P.r + P.lambda + T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  calc
    E.surplus .boom eps2 - E.surplus .boom eps1 =
        (P.sigma * (eps2 - eps1)) /
          (P.r + P.lambda + T.aggregateArrival) :=
      (eq_div_iff hRate.ne').2 (by nlinarith [hEq])
    _ = P.sigma / (P.r + P.lambda + T.aggregateArrival) *
        (eps2 - eps1) := by ring

/-- Recession surplus above its cutoff, in pointwise affine form. -/
theorem recession_surplus_above_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    E.surplus .recession eps =
      P.sigma / (P.r + P.lambda) *
        (eps - E.reservationCutoff A D TA M .recession) := by
  have hDiff := E.recession_surplus_difference_above_recession_cutoff
    A D TA M (le_refl _) hEps
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hDiff
  simpa using hDiff

/-- Boom surplus between the cutoffs, in pointwise affine form. -/
theorem boom_surplus_between_cutoffs
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hBoom : E.reservationCutoff A D TA M .boom ≤ eps)
    (hRecession : eps ≤ E.reservationCutoff A D TA M .recession) :
    E.surplus .boom eps =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
        (eps - E.reservationCutoff A D TA M .boom) := by
  have hDiff := E.boom_surplus_difference_between_cutoffs
    A D TA M (le_refl _) hBoom hRecession
  rw [E.surplus_reservationCutoff_eq_zero A D TA M .boom] at hDiff
  simpa using hDiff

/-- Paper equation (23): the boom surplus carried into the recession cutoff. -/
theorem equation23
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    E.surplus .boom (E.reservationCutoff A D TA M .recession) =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
        (E.reservationCutoff A D TA M .recession -
          E.reservationCutoff A D TA M .boom) := by
  exact E.boom_surplus_between_cutoffs A D TA M
    (E.boom_cutoff_lt_recession_cutoff A D TA M).le (le_refl _)

/-- Above the recession cutoff, boom surplus continues from equation (23)
with the common upper-region slope. -/
theorem boom_surplus_above_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    E.surplus .boom eps =
      E.surplus .boom (E.reservationCutoff A D TA M .recession) +
        P.sigma / (P.r + P.lambda) *
          (eps - E.reservationCutoff A D TA M .recession) := by
  have hDiff := E.boom_surplus_difference_above_recession_cutoff
    A D TA M (le_refl _) hEps
  linarith

end TwoStateValueEquilibrium
end MP1994V2
