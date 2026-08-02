import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateContinuation

/-!
# MP1994 v2: coupled two-state surplus Bellman equations

The central result is one general max-based system.  It is conditional on a
supplied `TwoStateValueEquilibrium` and introduces no cutoff or cutoff ordering.
-/

open MeasureTheory

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- The surplus flow equation before using probability normalization. -/
theorem surplus_flow_equation (E : TwoStateValueEquilibrium P T)
    (s : AggregateState) (eps : ℝ) :
    P.r * E.toTwoStateValueCandidate.surplus s eps =
      T.productivity s eps - P.b
        + P.lambda * E.toTwoStateValueCandidate.idiosyncraticContinuation P s eps
        - P.workerMeetingRate (E.theta s) * (E.W s P.epsUpper - E.U s)
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.aggregateSurplusTransition s eps := by
  have hFirm := E.filled_job_bellman s eps
  have hWorker := E.worker_bellman s eps
  have hUnemployed := E.unemployed_bellman s
  have hAggregate := E.aggregate_transition_surplus_identity s eps
  change P.r * (E.J s eps + E.W s eps - E.U s) = _
  calc
    P.r * (E.J s eps + E.W s eps - E.U s) =
        (P.r * E.J s eps + P.r * E.W s eps) - P.r * E.U s := by ring
    _ = T.productivity s eps - P.b
        + P.lambda * E.toTwoStateValueCandidate.idiosyncraticContinuation P s eps
        - P.workerMeetingRate (E.theta s) * (E.W s P.epsUpper - E.U s)
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.aggregateSurplusTransition s eps := by
      rw [hFirm, hWorker, hUnemployed]
      linear_combination hAggregate

/-- The coupled max-form surplus Bellman equation under the weakest probability
interface needed for the continuation integral. -/
theorem coupled_surplus_bellman_of_probability
    [IsProbabilityMeasure P.shock]
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus s eps =
      T.productivity s eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus s x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta s) *
            E.toTwoStateValueCandidate.surplus s P.epsUpper
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.activeSurplus s.other eps := by
  have hFlow := E.surplus_flow_equation s eps
  have hContinuation :=
    E.idiosyncraticContinuation_eq_integral_activeSurplus_sub s eps
  have hSharing := E.nash_sharing s P.epsUpper
  change E.W s P.epsUpper - E.U s =
    P.beta * E.toTwoStateValueCandidate.surplus s P.epsUpper at hSharing
  rw [hContinuation, hSharing] at hFlow
  unfold TwoStateValueCandidate.aggregateSurplusTransition at hFlow
  linear_combination hFlow

/-- Paper-level coupled system.  Probability normalization remains explicit
through `ShockAssumptions`, rather than being embedded in the equilibrium. -/
theorem coupled_surplus_bellman (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus s eps =
      T.productivity s eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus s x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta s) *
            E.toTwoStateValueCandidate.surplus s P.epsUpper
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.activeSurplus s.other eps := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.coupled_surplus_bellman_of_probability s eps

/-- The recession component of the coupled max-based system. -/
theorem recession_surplus_bellman (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps : ℝ) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus .recession eps =
      P.p + P.sigma * eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus .recession x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .recession) *
            E.toTwoStateValueCandidate.surplus .recession P.epsUpper
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.activeSurplus .boom eps := by
  simpa using E.coupled_surplus_bellman D .recession eps

/-- The boom component of the coupled max-based system. -/
theorem boom_surplus_bellman (D : ShockAssumptions P)
    (E : TwoStateValueEquilibrium P T) (eps : ℝ) :
    (P.r + P.lambda + T.aggregateArrival) *
        E.toTwoStateValueCandidate.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b
        + P.lambda *
            (∫ x, E.toTwoStateValueCandidate.activeSurplus .boom x ∂P.shock)
        - P.beta * P.workerMeetingRate (E.theta .boom) *
            E.toTwoStateValueCandidate.surplus .boom P.epsUpper
        + T.aggregateArrival *
            E.toTwoStateValueCandidate.activeSurplus .recession eps := by
  simpa using E.coupled_surplus_bellman D .boom eps

end TwoStateValueEquilibrium
end MP1994V2
