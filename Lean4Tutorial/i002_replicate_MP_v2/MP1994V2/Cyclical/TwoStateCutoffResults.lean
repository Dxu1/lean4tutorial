import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoffEquations

/-!
# MP1994 v2: M9.2C ordered-equation capstones

The proposition below is a theorem-result bundle, not an equilibrium input.
Every component is derived from a supplied `TwoStateValueEquilibrium`.
-/

open MeasureTheory
open scoped Interval

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Compact statement of the ordered regional equations proved in M9.2C. -/
def SatisfiesM92COrderedEquations
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) : Prop :=
  E.reservationCutoff A D TA M .boom <
      E.reservationCutoff A D TA M .recession ∧
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
      P.p + P.sigma * eps - P.b +
        P.lambda *
          (∫ x in Set.Icc (E.reservationCutoff A D TA M .recession) P.epsUpper,
            E.surplus .recession x ∂P.shock) -
        P.beta * P.workerMeetingRate (E.theta .recession) *
          E.surplus .recession P.epsUpper +
        T.aggregateArrival * E.surplus .boom eps) ∧
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b +
        P.lambda *
          (∫ x in Set.Icc (E.reservationCutoff A D TA M .boom) P.epsUpper,
            E.surplus .boom x ∂P.shock) -
        P.beta * P.workerMeetingRate (E.theta .boom) *
          E.surplus .boom P.epsUpper +
        T.aggregateArrival * E.surplus .recession eps) ∧
  (∀ eps, E.reservationCutoff A D TA M .boom ≤ eps →
    eps ≤ E.reservationCutoff A D TA M .recession →
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b +
        P.lambda *
          (∫ x in Set.Icc (E.reservationCutoff A D TA M .boom) P.epsUpper,
            E.surplus .boom x ∂P.shock) -
        P.beta * P.workerMeetingRate (E.theta .boom) *
          E.surplus .boom P.epsUpper) ∧
  (∀ eps1 eps2,
    E.reservationCutoff A D TA M .recession ≤ eps1 → eps1 ≤ eps2 →
    (E.surplus .recession eps2 - E.surplus .recession eps1 =
      P.sigma / (P.r + P.lambda) * (eps2 - eps1)) ∧
    (E.surplus .boom eps2 - E.surplus .boom eps1 =
      P.sigma / (P.r + P.lambda) * (eps2 - eps1))) ∧
  E.surplus .boom (E.reservationCutoff A D TA M .recession) =
    P.sigma / (P.r + P.lambda + T.aggregateArrival) *
      (E.reservationCutoff A D TA M .recession -
        E.reservationCutoff A D TA M .boom) ∧
  (∫ x, E.activeSurplus .recession x ∂P.shock) =
    P.sigma / (P.r + P.lambda) *
      P.tailOptionValue (E.reservationCutoff A D TA M .recession) ∧
  (∫ x, E.activeSurplus .boom x ∂P.shock) =
    P.sigma / (P.r + P.lambda + T.aggregateArrival) *
        (∫ x in (E.reservationCutoff A D TA M .boom)..
            (E.reservationCutoff A D TA M .recession),
          P.tailProbability x) +
      P.sigma / (P.r + P.lambda) *
        P.tailOptionValue (E.reservationCutoff A D TA M .recession) ∧
  (∀ eps, E.reservationCutoff A D TA M .boom ≤ eps →
    eps ≤ E.reservationCutoff A D TA M .recession →
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .boom eps =
      T.pHigh + P.sigma * eps - P.b -
        P.beta * P.workerMeetingRate (E.theta .boom) *
          E.surplus .boom P.epsUpper +
        (P.lambda * P.sigma / (P.r + P.lambda + T.aggregateArrival)) *
          (∫ x in (E.reservationCutoff A D TA M .boom)..
              (E.reservationCutoff A D TA M .recession),
            P.tailProbability x) +
        (P.lambda * P.sigma / (P.r + P.lambda)) *
          P.tailOptionValue (E.reservationCutoff A D TA M .recession)) ∧
  T.pHigh + P.sigma * E.reservationCutoff A D TA M .boom =
    P.b + (P.beta * P.c / (1 - P.beta)) * E.theta .boom -
      (P.lambda * P.sigma / (P.r + P.lambda + T.aggregateArrival)) *
        (∫ x in (E.reservationCutoff A D TA M .boom)..
            (E.reservationCutoff A D TA M .recession),
          P.tailProbability x) -
      (P.lambda * P.sigma / (P.r + P.lambda)) *
        P.tailOptionValue (E.reservationCutoff A D TA M .recession) ∧
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
      P.p + P.sigma * eps - P.b +
        (P.lambda * P.sigma / (P.r + P.lambda)) *
          P.tailOptionValue (E.reservationCutoff A D TA M .recession) -
        P.beta * P.workerMeetingRate (E.theta .recession) *
          E.surplus .recession P.epsUpper +
        T.aggregateArrival * E.surplus .boom eps) ∧
  P.p + P.sigma * E.reservationCutoff A D TA M .recession =
    P.b + (P.beta * P.c / (1 - P.beta)) * E.theta .recession -
      (P.lambda * P.sigma / (P.r + P.lambda)) *
        P.tailOptionValue (E.reservationCutoff A D TA M .recession) -
      (T.aggregateArrival * P.sigma /
        (P.r + P.lambda + T.aggregateArrival)) *
        (E.reservationCutoff A D TA M .recession -
          E.reservationCutoff A D TA M .boom)

/-- M9.2C capstone: all ordered regional and cutoff equations follow from a
supplied two-state value equilibrium. -/
theorem m9_2C_ordered_equations_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    SatisfiesM92COrderedEquations A D TA M E := by
  unfold SatisfiesM92COrderedEquations
  refine ⟨E.boom_cutoff_lt_recession_cutoff A D TA M, ?_, ?_, ?_, ?_,
    E.equation23 A D TA M,
    E.recession_activeSurplus_integral_eq_tailOptionValue A D TA M,
    E.boom_activeSurplus_integral_eq_tailIntervals A D TA M,
    ?_, E.equation20 A D TA M, ?_, E.equation24 A D TA M⟩
  · intro eps h
    exact E.equation16_ordered A D TA M h
  · intro eps h
    exact E.equation17_ordered A D TA M h
  · intro eps hB hR
    exact E.equation18_ordered A D TA M hB hR
  · intro eps1 eps2 hR h12
    exact E.equation21_difference A D TA M hR h12
  · intro eps hB hR
    exact E.equation19 A D TA M hB hR
  · intro eps hR
    exact E.equation22 A D TA M hR

/-- Full M9.2 capstone: statewise cutoff foundations, strict state ordering,
and all M9.2C ordered equations, still conditional on a supplied equilibrium. -/
theorem m9_2_full_cutoff_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    ((∀ s, StrictMono (E.surplus s)) ∧
      (∀ s, ∃! eps, E.surplus s eps = 0) ∧
      E.reservationCutoff A D TA M .boom <
        E.reservationCutoff A D TA M .recession ∧
      E.surplus .recession P.epsUpper < E.surplus .boom P.epsUpper ∧
      E.theta .recession < E.theta .boom) ∧
      SatisfiesM92COrderedEquations A D TA M E := by
  exact ⟨E.m9_2B_cutoff_ordering_capstone A D TA M,
    E.m9_2C_ordered_equations_capstone A D TA M⟩

end TwoStateValueEquilibrium
end MP1994V2
