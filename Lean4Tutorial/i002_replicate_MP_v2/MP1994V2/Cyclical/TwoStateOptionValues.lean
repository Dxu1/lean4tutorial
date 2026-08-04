import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateRegionalAffine
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.ReducedAnalytic

/-!
# MP1994 v2: two-state option-value formulas

Regional affine results are assembled into global hinge identities and then
integrated against the primitive shock law.  The CDF-tail statements use the
generic M3 layer-cake theorem; no probability representation is postulated.
-/

open MeasureTheory Set
open scoped Interval

namespace MP1994V2

namespace Primitives

/-- The strict-tail probability induced by the shock law is antitone. -/
theorem tailProbability_antitone (P : Primitives) (D : ShockAssumptions P) :
    Antitone P.tailProbability := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  intro x y hxy
  have hMeasure : P.shock (Iic x) ≤ P.shock (Iic y) :=
    measure_mono (Iic_subset_Iic.mpr hxy)
  have hCDF : P.cdf x ≤ P.cdf y := by
    exact ENNReal.toReal_mono (measure_ne_top P.shock (Iic y)) hMeasure
  unfold tailProbability
  linarith

/-- A difference of upper-tail option values is exactly the CDF-tail integral
over the intervening interval. -/
theorem tailOptionValue_sub_eq_interval
    (P : Primitives) (D : ShockAssumptions P) (d1 d2 : ℝ) :
    P.tailOptionValue d1 - P.tailOptionValue d2 =
      ∫ x in d1..d2, P.tailProbability x := by
  have hInt (a b : ℝ) :
      IntervalIntegrable P.tailProbability volume a b :=
    (P.tailProbability_antitone D).intervalIntegrable
  have hAdd := intervalIntegral.integral_add_adjacent_intervals
    (hInt d1 d2) (hInt d2 P.epsUpper)
  unfold tailOptionValue
  linarith

end Primitives

namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- The between-cutoff boom slope is positive. -/
theorem regionalBoomSlope_pos
    (A : CoreEconomicAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) :
    0 < P.sigma / (P.r + P.lambda + T.aggregateArrival) := by
  exact div_pos A.sigma_pos (by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos])

/-- The common upper-region slope is positive. -/
theorem upperRegionalSlope_pos (A : CoreEconomicAssumptions P) :
    0 < P.sigma / (P.r + P.lambda) := by
  exact div_pos A.sigma_pos (by linarith [A.r_pos, A.lambda_nonneg])

/-- Aggregate switching makes the between-cutoff boom slope strictly smaller
than the common upper-region slope. -/
theorem regionalBoomSlope_lt_upperRegionalSlope
    (A : CoreEconomicAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) :
    P.sigma / (P.r + P.lambda + T.aggregateArrival) <
      P.sigma / (P.r + P.lambda) := by
  have hBig : 0 < P.r + P.lambda + T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  have hSmall : 0 < P.r + P.lambda := by
    linarith [A.r_pos, A.lambda_nonneg]
  apply (div_lt_div_iff₀ hBig hSmall).2
  nlinarith [A.sigma_pos, TA.aggregateArrival_pos]

/-- Global hinge representation of recession active surplus. -/
theorem recession_activeSurplus_hinge
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (x : ℝ) :
    E.activeSurplus .recession x =
      P.sigma / (P.r + P.lambda) *
        positivePart (x - E.reservationCutoff A D TA M .recession) := by
  rcases le_total x (E.reservationCutoff A D TA M .recession) with hx | hx
  · have hS : E.surplus .recession x ≤ 0 := by
      have hMono := (E.surplus_strictMono A D TA .recession).monotone hx
      rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hMono
      exact hMono
    simp [TwoStateValueCandidate.activeSurplus, positivePart, hS,
      sub_nonpos.mpr hx]
  · have hS := E.recession_surplus_above_recession_cutoff A D TA M hx
    have hNonneg :=
      (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .recession x).2 hx
    simp only [TwoStateValueCandidate.activeSurplus, positivePart]
    rw [max_eq_left hNonneg, max_eq_left (sub_nonneg.mpr hx)]
    exact hS

/-- Global two-hinge representation of boom active surplus. -/
theorem boom_activeSurplus_hinge
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (x : ℝ) :
    E.activeSurplus .boom x =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
          positivePart (x - E.reservationCutoff A D TA M .boom) +
        (P.sigma / (P.r + P.lambda) -
          P.sigma / (P.r + P.lambda + T.aggregateArrival)) *
          positivePart (x - E.reservationCutoff A D TA M .recession) := by
  have hCutoffs := E.boom_cutoff_lt_recession_cutoff A D TA M
  rcases le_total x (E.reservationCutoff A D TA M .boom) with hxB | hxB
  · have hS : E.surplus .boom x ≤ 0 := by
      have hMono := (E.surplus_strictMono A D TA .boom).monotone hxB
      rw [E.surplus_reservationCutoff_eq_zero A D TA M .boom] at hMono
      exact hMono
    have hxR : x ≤ E.reservationCutoff A D TA M .recession :=
      le_trans hxB hCutoffs.le
    simp [TwoStateValueCandidate.activeSurplus, positivePart, hS,
      sub_nonpos.mpr hxB, sub_nonpos.mpr hxR]
  · rcases le_total x (E.reservationCutoff A D TA M .recession) with hxR | hxR
    · have hS := E.boom_surplus_between_cutoffs A D TA M hxB hxR
      have hNonneg :=
        (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .boom x).2 hxB
      simp only [TwoStateValueCandidate.activeSurplus, positivePart]
      rw [max_eq_left hNonneg, max_eq_left (sub_nonneg.mpr hxB),
        max_eq_right (sub_nonpos.mpr hxR)]
      simpa using hS
    · have hS := E.boom_surplus_above_recession_cutoff A D TA M hxR
      have hAt := E.equation23 A D TA M
      have hNonneg :=
        (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .boom x).2
          (le_trans hCutoffs.le hxR)
      simp only [TwoStateValueCandidate.activeSurplus, positivePart]
      rw [max_eq_left hNonneg,
        max_eq_left (sub_nonneg.mpr (le_trans hCutoffs.le hxR)),
        max_eq_left (sub_nonneg.mpr hxR)]
      rw [hS, hAt]
      ring

/-- Recession active-surplus expectation in expected-excess form. -/
theorem recession_activeSurplus_integral_eq_expectedExcess
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∫ x, E.activeSurplus .recession x ∂P.shock) =
      P.sigma / (P.r + P.lambda) *
        P.expectedExcess (E.reservationCutoff A D TA M .recession) := by
  rw [Primitives.expectedExcess, ← integral_const_mul]
  exact integral_congr_ae (Filter.Eventually.of_forall fun x =>
    E.recession_activeSurplus_hinge A D TA M x)

/-- Recession active-surplus expectation in the paper's CDF-tail form. -/
theorem recession_activeSurplus_integral_eq_tailOptionValue
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∫ x, E.activeSurplus .recession x ∂P.shock) =
      P.sigma / (P.r + P.lambda) *
        P.tailOptionValue (E.reservationCutoff A D TA M .recession) := by
  rw [E.recession_activeSurplus_integral_eq_expectedExcess A D TA M,
    P.expectedExcess_eq_tailOptionValue D
      (E.reservationCutoff_lt_epsUpper A D TA M .recession).le]

/-- Boom active-surplus expectation in the two-hinge expected-excess form. -/
theorem boom_activeSurplus_integral_eq_expectedExcess
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∫ x, E.activeSurplus .boom x ∂P.shock) =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
          P.expectedExcess (E.reservationCutoff A D TA M .boom) +
        (P.sigma / (P.r + P.lambda) -
          P.sigma / (P.r + P.lambda + T.aggregateArrival)) *
          P.expectedExcess (E.reservationCutoff A D TA M .recession) := by
  let a := P.sigma / (P.r + P.lambda + T.aggregateArrival)
  let b := P.sigma / (P.r + P.lambda)
  let dB := E.reservationCutoff A D TA M .boom
  let dR := E.reservationCutoff A D TA M .recession
  have hIntB := (P.positivePart_sub_integrable D dB).const_mul a
  have hIntR := (P.positivePart_sub_integrable D dR).const_mul (b - a)
  calc
    (∫ x, E.activeSurplus .boom x ∂P.shock) =
        ∫ x, a * positivePart (x - dB) +
          (b - a) * positivePart (x - dR) ∂P.shock :=
      integral_congr_ae (Filter.Eventually.of_forall fun x => by
        simpa [a, b, dB, dR] using E.boom_activeSurplus_hinge A D TA M x)
    _ = (∫ x, a * positivePart (x - dB) ∂P.shock) +
        ∫ x, (b - a) * positivePart (x - dR) ∂P.shock :=
      integral_add hIntB hIntR
    _ = a * P.expectedExcess dB + (b - a) * P.expectedExcess dR := by
      simp [Primitives.expectedExcess, integral_const_mul]
    _ = _ := by rfl

/-- Equivalent boom option-value decomposition separating the interval between
cutoffs from the common upper tail. -/
theorem boom_activeSurplus_integral_eq_expectedExcess_difference
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∫ x, E.activeSurplus .boom x ∂P.shock) =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
          (P.expectedExcess (E.reservationCutoff A D TA M .boom) -
            P.expectedExcess (E.reservationCutoff A D TA M .recession)) +
        P.sigma / (P.r + P.lambda) *
          P.expectedExcess (E.reservationCutoff A D TA M .recession) := by
  rw [E.boom_activeSurplus_integral_eq_expectedExcess A D TA M]
  ring

/-- Boom active-surplus expectation in the exact paper-facing split CDF-tail
form. -/
theorem boom_activeSurplus_integral_eq_tailIntervals
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∫ x, E.activeSurplus .boom x ∂P.shock) =
      P.sigma / (P.r + P.lambda + T.aggregateArrival) *
          (∫ x in (E.reservationCutoff A D TA M .boom)..
              (E.reservationCutoff A D TA M .recession),
            P.tailProbability x) +
        P.sigma / (P.r + P.lambda) *
          P.tailOptionValue (E.reservationCutoff A D TA M .recession) := by
  rw [E.boom_activeSurplus_integral_eq_expectedExcess_difference A D TA M,
    P.expectedExcess_eq_tailOptionValue D
      (E.reservationCutoff_lt_epsUpper A D TA M .boom).le,
    P.expectedExcess_eq_tailOptionValue D
      (E.reservationCutoff_lt_epsUpper A D TA M .recession).le,
    P.tailOptionValue_sub_eq_interval D]

end TwoStateValueEquilibrium
end MP1994V2
