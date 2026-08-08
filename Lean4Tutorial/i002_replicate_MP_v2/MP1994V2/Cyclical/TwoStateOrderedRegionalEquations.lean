import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoffOrderingResults
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateIntervalIntegrals

/-!
# MP1994 v2: ordered regional forms of equations (16)--(18)

These results insert the proved boom-below-recession cutoff order into the
max-form Bellman system.  They are conditional on a supplied two-state value
equilibrium and add no regional equation to that structure.
-/

open MeasureTheory Set

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Paper equation (16), valid at and above the recession cutoff. -/
theorem equation16_ordered
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
      P.p + P.sigma * eps - P.b
        + P.lambda *
            (∫ x in Icc (E.reservationCutoff A D TA M .recession) P.epsUpper,
              E.surplus .recession x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .recession) *
            E.surplus .recession P.epsUpper
        + T.aggregateArrival * E.surplus .boom eps := by
  have hOrder := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hSigns := E.both_surplus_nonneg_above_recession_cutoff
    A D TA M hOrder hEps
  have hBellman := E.recession_surplus_bellman D eps
  rw [E.statewise_continuation_integral_eq A D TA M .recession] at hBellman
  simpa [TwoStateValueCandidate.activeSurplus, positivePart,
    max_eq_left hSigns.1] using hBellman

/-- Paper equation (17), valid at and above the recession cutoff. -/
theorem equation17_ordered
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b
        + P.lambda *
            (∫ x in Icc (E.reservationCutoff A D TA M .boom) P.epsUpper,
              E.surplus .boom x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .boom) *
            E.surplus .boom P.epsUpper
        + T.aggregateArrival * E.surplus .recession eps := by
  have hOrder := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hSigns := E.both_surplus_nonneg_above_recession_cutoff
    A D TA M hOrder hEps
  have hBellman := E.boom_surplus_bellman D eps
  rw [E.statewise_continuation_integral_eq A D TA M .boom] at hBellman
  simpa [TwoStateValueCandidate.activeSurplus, positivePart,
    max_eq_left hSigns.2] using hBellman

/-- Paper equation (18), valid from the boom cutoff through the recession
cutoff.  The recession active surplus is zero on this region. -/
theorem equation18_ordered
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hBoom : E.reservationCutoff A D TA M .boom ≤ eps)
    (hRecession : eps ≤ E.reservationCutoff A D TA M .recession) :
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b
        + P.lambda *
            (∫ x in Icc (E.reservationCutoff A D TA M .boom) P.epsUpper,
              E.surplus .boom x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .boom) *
            E.surplus .boom P.epsUpper := by
  have hSigns := E.surplus_signs_between_cutoffs_of_boom_lt_recession
    A D TA M hBoom hRecession
  have hBellman := E.boom_surplus_bellman D eps
  rw [E.statewise_continuation_integral_eq A D TA M .boom] at hBellman
  simpa [TwoStateValueCandidate.activeSurplus, positivePart,
    max_eq_right hSigns.2] using hBellman

end TwoStateValueEquilibrium
end MP1994V2
