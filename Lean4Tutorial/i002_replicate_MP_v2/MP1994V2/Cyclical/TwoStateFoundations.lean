import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateRegionalEquations

/-! # MP1994 v2: M9.1 two-state foundations capstone -/

open MeasureTheory

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- M9.1 capstone: a supplied two-state value equilibrium has zero vacancy
values, firm surplus shares, the coupled max-form system, both state equations,
and the three conditional regional forms.  This is a representation theorem,
not an equilibrium-existence or cutoff-ordering theorem. -/
theorem m9_1_two_state_foundations
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∀ s, E.V s = 0) ∧
    (∀ s eps, E.J s eps =
      (1 - P.beta) * E.toTwoStateValueCandidate.surplus s eps) ∧
    (∀ s eps,
      (P.r + P.lambda + T.aggregateArrival) *
          E.toTwoStateValueCandidate.surplus s eps =
        T.productivity s eps - P.b
          + P.lambda *
              (∫ x, E.toTwoStateValueCandidate.activeSurplus s x ∂P.shock)
          - P.beta * P.workerMeetingRate (E.theta s) *
              E.toTwoStateValueCandidate.surplus s P.epsUpper
          + T.aggregateArrival *
              E.toTwoStateValueCandidate.activeSurplus s.other eps) ∧
    (∀ eps,
      (P.r + P.lambda + T.aggregateArrival) *
          E.toTwoStateValueCandidate.surplus .recession eps =
        P.p + P.sigma * eps - P.b
          + P.lambda *
              (∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock)
          - P.beta * P.workerMeetingRate (E.theta .recession) *
              E.toTwoStateValueCandidate.surplus .recession P.epsUpper
          + T.aggregateArrival *
              E.toTwoStateValueCandidate.activeSurplus .boom eps) ∧
    (∀ eps,
      (P.r + P.lambda + T.aggregateArrival) *
          E.toTwoStateValueCandidate.surplus .boom eps =
        T.pHigh + P.sigma * eps - P.b
          + P.lambda *
              (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock)
          - P.beta * P.workerMeetingRate (E.theta .boom) *
              E.toTwoStateValueCandidate.surplus .boom P.epsUpper
          + T.aggregateArrival *
              E.toTwoStateValueCandidate.activeSurplus .recession eps) ∧
    (∀ eps, 0 ≤ E.toTwoStateValueCandidate.surplus .boom eps →
      (P.r + P.lambda + T.aggregateArrival) *
          E.toTwoStateValueCandidate.surplus .recession eps =
        P.p + P.sigma * eps - P.b
          + P.lambda *
              (∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock)
          - P.beta * P.workerMeetingRate (E.theta .recession) *
              E.toTwoStateValueCandidate.surplus .recession P.epsUpper
          + T.aggregateArrival *
              E.toTwoStateValueCandidate.surplus .boom eps) ∧
    (∀ eps, 0 ≤ E.toTwoStateValueCandidate.surplus .recession eps →
      (P.r + P.lambda + T.aggregateArrival) *
          E.toTwoStateValueCandidate.surplus .boom eps =
        T.pHigh + P.sigma * eps - P.b
          + P.lambda *
              (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock)
          - P.beta * P.workerMeetingRate (E.theta .boom) *
              E.toTwoStateValueCandidate.surplus .boom P.epsUpper
          + T.aggregateArrival *
              E.toTwoStateValueCandidate.surplus .recession eps) ∧
    (∀ eps, E.toTwoStateValueCandidate.surplus .recession eps ≤ 0 →
      (P.r + P.lambda + T.aggregateArrival) *
          E.toTwoStateValueCandidate.surplus .boom eps =
        T.pHigh + P.sigma * eps - P.b
          + P.lambda *
              (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock)
          - P.beta * P.workerMeetingRate (E.theta .boom) *
              E.toTwoStateValueCandidate.surplus .boom P.epsUpper) := by
  refine ⟨fun s => E.vacancy_value_eq_zero A s,
    fun s eps => E.firm_share s eps,
    fun s eps => E.coupled_surplus_bellman D s eps,
    fun eps => E.recession_surplus_bellman D eps,
    fun eps => E.boom_surplus_bellman D eps, ?_, ?_, ?_⟩
  · exact fun eps h => E.equation16_of_boom_surplus_nonneg D eps h
  · exact fun eps h => E.equation17_of_recession_surplus_nonneg D eps h
  · exact fun eps h => E.equation18_of_recession_surplus_nonpos D eps h

end TwoStateValueEquilibrium
end MP1994V2
