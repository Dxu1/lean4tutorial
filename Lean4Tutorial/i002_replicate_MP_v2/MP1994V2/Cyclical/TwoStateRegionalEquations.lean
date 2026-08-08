import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateSurplus

/-!
# MP1994 v2: conditional regional forms of equations (16)--(18)

These lemmas simplify the general max-based system under pointwise surplus-sign
hypotheses.  They do not assert a cutoff or an ordering of statewise cutoffs.
-/

open MeasureTheory

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Paper equation (16), conditional on nonnegative boom surplus at `eps`. -/
theorem equation16_of_boom_surplus_nonneg (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps : ℝ)
    (h : 0 ≤ E.toTwoStateValueCandidate.surplus .boom eps) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus .recession eps =
      P.p + P.sigma * eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .recession) *
            E.toTwoStateValueCandidate.surplus .recession P.epsUpper
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.surplus .boom eps := by
  have hEq : E.toTwoStateValueCandidate.activeSurplus .boom eps =
      E.toTwoStateValueCandidate.surplus .boom eps := by
    simp [TwoStateValueCandidate.activeSurplus, positivePart, max_eq_left h]
  rw [← hEq]
  exact E.recession_surplus_bellman D eps

/-- Paper equation (17), conditional on nonnegative recession surplus at `eps`. -/
theorem equation17_of_recession_surplus_nonneg (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps : ℝ)
    (h : 0 ≤ E.toTwoStateValueCandidate.surplus .recession eps) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .boom) *
            E.toTwoStateValueCandidate.surplus .boom P.epsUpper
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.surplus .recession eps := by
  have hEq : E.toTwoStateValueCandidate.activeSurplus .recession eps =
      E.toTwoStateValueCandidate.surplus .recession eps := by
    simp [TwoStateValueCandidate.activeSurplus, positivePart, max_eq_left h]
  rw [← hEq]
  exact E.boom_surplus_bellman D eps

/-- Paper equation (18), conditional on nonpositive recession surplus at `eps`. -/
theorem equation18_of_recession_surplus_nonpos (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps : ℝ)
    (h : E.toTwoStateValueCandidate.surplus .recession eps ≤ 0) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .boom) *
            E.toTwoStateValueCandidate.surplus .boom P.epsUpper := by
  have hEq : E.toTwoStateValueCandidate.activeSurplus .recession eps = 0 := by
    simp [TwoStateValueCandidate.activeSurplus, positivePart, max_eq_right h]
  have hBoom := E.boom_surplus_bellman D eps
  rw [hEq] at hBoom
  simpa using hBoom

end TwoStateValueEquilibrium
end MP1994V2
