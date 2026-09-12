import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateValue
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Surplus

/-! # MP1994 v2: two-state continuation identities -/

open MeasureTheory

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Nash sharing gives the firm's complementary share in each aggregate state. -/
theorem firm_share (E : TwoStateValueEquilibrium P T)
    (s : AggregateState) (eps : ℝ) :
    E.J s eps = (1 - P.beta) * E.toTwoStateValueCandidate.surplus s eps := by
  change E.J s eps = (1 - P.beta) * (E.J s eps + E.W s eps - E.U s)
  have h := E.nash_sharing s eps
  change E.W s eps - E.U s =
    P.beta * (E.J s eps + E.W s eps - E.U s) at h
  linear_combination -h

/-- Under a probability law, the idiosyncratic continuation term decomposes
into expected active surplus minus current surplus. -/
theorem idiosyncraticContinuation_eq_integral_activeSurplus_sub
    [IsProbabilityMeasure P.shock]
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    E.toTwoStateValueCandidate.idiosyncraticContinuation P s eps =
      (∫ x, E.toTwoStateValueCandidate.activeSurplus s x ∂P.shock) -
        E.toTwoStateValueCandidate.surplus s eps := by
  exact continuationTerm_eq_integral_activeSurplus_sub
    (eps := eps) (E.active_surplus_integrable s)

/-- Firm and worker aggregate continuation terms, net of the unemployment
aggregate transition, add to the aggregate surplus transition. -/
theorem aggregate_transition_surplus_identity
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    T.aggregateArrival * (1 - P.beta) *
          E.toTwoStateValueCandidate.aggregateSurplusTransition s eps
      + T.aggregateArrival *
          E.toTwoStateValueCandidate.workerAggregateContinuation P s eps
      - T.aggregateArrival * (E.U s.other - E.U s) =
        T.aggregateArrival *
          E.toTwoStateValueCandidate.aggregateSurplusTransition s eps := by
  unfold TwoStateValueCandidate.workerAggregateContinuation
  ring

/-- Free entry and `r > 0` imply zero vacancy value state by state. -/
theorem vacancy_value_eq_zero (E : TwoStateValueEquilibrium P T)
    (A : CoreEconomicAssumptions P) (s : AggregateState) : E.V s = 0 := by
  exact (mul_eq_zero.mp (E.free_entry s)).resolve_left A.r_pos.ne'

/-- With zero vacancy values, the statewise vacancy equation is
`q(θ_s) J_s(εᵤ) = c`. -/
theorem statewise_vacancy_equation (E : TwoStateValueEquilibrium P T)
    (A : CoreEconomicAssumptions P) (s : AggregateState) :
    P.q (E.theta s) * E.J s P.epsUpper = P.c := by
  have h := E.vacancy_bellman s
  rw [E.vacancy_value_eq_zero A s, E.vacancy_value_eq_zero A s.other] at h
  linarith

end TwoStateValueEquilibrium
end MP1994V2
