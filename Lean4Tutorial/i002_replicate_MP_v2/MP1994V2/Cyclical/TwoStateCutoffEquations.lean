import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateOptionValues

/-!
# MP1994 v2: ordered cutoff equations (19), (20), (22), and (24)

The paper-facing CDF-tail formulas are derived from the ordered Bellman system,
the regional affine results, and statewise free entry.  Equation (23) is
provided by `TwoStateRegionalAffine` and used in equation (24).
-/

open MeasureTheory
open scoped Interval

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Paper equation (19), valid between the boom and recession cutoffs. -/
theorem equation19
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hBoom : E.reservationCutoff A D TA M .boom ≤ eps)
    (hRecession : eps ≤ E.reservationCutoff A D TA M .recession) :
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b
        - P.beta * P.workerMeetingRate (E.theta .boom) *
            E.surplus .boom P.epsUpper
        + (P.lambda * P.sigma /
            (P.r + P.lambda + T.aggregateArrival)) *
            (∫ x in (E.reservationCutoff A D TA M .boom)..
                (E.reservationCutoff A D TA M .recession),
              P.tailProbability x)
        + (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue (E.reservationCutoff A D TA M .recession) := by
  have h := E.equation18_ordered A D TA M hBoom hRecession
  rw [← E.statewise_continuation_integral_eq A D TA M .boom,
    E.boom_activeSurplus_integral_eq_tailIntervals A D TA M] at h
  calc
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
        T.pHigh + P.sigma * eps - P.b +
          P.lambda *
            (P.sigma / (P.r + P.lambda + T.aggregateArrival) *
                (∫ x in (E.reservationCutoff A D TA M .boom)..
                    (E.reservationCutoff A D TA M .recession),
                  P.tailProbability x) +
              P.sigma / (P.r + P.lambda) *
                P.tailOptionValue
                  (E.reservationCutoff A D TA M .recession)) -
          P.beta * P.workerMeetingRate (E.theta .boom) *
            E.surplus .boom P.epsUpper := h
    _ = _ := by ring

/-- Paper equation (20), the boom cutoff equation obtained from equation (19)
and statewise free entry. -/
theorem equation20
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    T.pHigh + P.sigma * E.reservationCutoff A D TA M .boom =
      P.b + (P.beta * P.c / (1 - P.beta)) * E.theta .boom
        - (P.lambda * P.sigma /
            (P.r + P.lambda + T.aggregateArrival)) *
            (∫ x in (E.reservationCutoff A D TA M .boom)..
                (E.reservationCutoff A D TA M .recession),
              P.tailProbability x)
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue (E.reservationCutoff A D TA M .recession) := by
  have h19 := E.equation19 A D TA M (le_refl _)
    (E.boom_cutoff_lt_recession_cutoff A D TA M).le
  have hZero := E.surplus_reservationCutoff_eq_zero A D TA M .boom
  have hSearch := E.statewise_search_gain_eq A .boom
  rw [hZero] at h19
  nlinarith [h19, hSearch]

/-- Paper equation (22), valid at and above the recession cutoff. -/
theorem equation22
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
      P.p + P.sigma * eps - P.b
        + (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue (E.reservationCutoff A D TA M .recession)
        - P.beta * P.workerMeetingRate (E.theta .recession) *
            E.surplus .recession P.epsUpper
        + T.aggregateArrival * E.surplus .boom eps := by
  have h := E.equation16_ordered A D TA M hEps
  rw [← E.statewise_continuation_integral_eq A D TA M .recession,
    E.recession_activeSurplus_integral_eq_tailOptionValue A D TA M] at h
  calc
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
        P.p + P.sigma * eps - P.b +
          P.lambda * (P.sigma / (P.r + P.lambda) *
            P.tailOptionValue
              (E.reservationCutoff A D TA M .recession)) -
          P.beta * P.workerMeetingRate (E.theta .recession) *
            E.surplus .recession P.epsUpper +
          T.aggregateArrival * E.surplus .boom eps := h
    _ = _ := by ring

/-- Paper equation (24), the recession cutoff equation.  The final switching
term is the negative bridge-gap contribution from equation (23). -/
theorem equation24
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    P.p + P.sigma * E.reservationCutoff A D TA M .recession =
      P.b + (P.beta * P.c / (1 - P.beta)) * E.theta .recession
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue (E.reservationCutoff A D TA M .recession)
        - (T.aggregateArrival * P.sigma /
            (P.r + P.lambda + T.aggregateArrival)) *
            (E.reservationCutoff A D TA M .recession -
              E.reservationCutoff A D TA M .boom) := by
  have h22 := E.equation22 A D TA M (le_refl _)
  have hZero := E.surplus_reservationCutoff_eq_zero A D TA M .recession
  have hSearch := E.statewise_search_gain_eq A .recession
  have h23 := E.equation23 A D TA M
  rw [hZero, h23] at h22
  calc
    P.p + P.sigma * E.reservationCutoff A D TA M .recession =
        P.b + (P.beta * P.c / (1 - P.beta)) * E.theta .recession -
          (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue (E.reservationCutoff A D TA M .recession) -
          T.aggregateArrival *
            (P.sigma / (P.r + P.lambda + T.aggregateArrival) *
              (E.reservationCutoff A D TA M .recession -
                E.reservationCutoff A D TA M .boom)) := by
      nlinarith [h22, hSearch]
    _ = _ := by ring

end TwoStateValueEquilibrium
end MP1994V2
