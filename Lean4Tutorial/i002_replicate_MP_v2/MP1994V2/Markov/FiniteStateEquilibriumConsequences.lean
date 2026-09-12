import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.FiniteStateEquilibrium
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Matching

/-!
# MP1994 v2: equations (32)--(34) and immediate consequences

This module only exposes the stored representation and elementary positivity
consequences. It proves neither equilibrium existence nor surplus geometry.
-/

namespace MP1994V2
namespace FiniteMarkovEquilibrium

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι}

/-- The first component of equation (32): worker contact is derived from
tightness rather than stored independently. -/
theorem workerMeetingHazard_eq (E : FiniteMarkovEquilibrium P K) (i : ι) :
    E.toFiniteMarkovCandidate.workerMeetingHazard i =
      P.workerMeetingRate (E.theta i) := rfl

/-- Paper equation (32), free entry. -/
theorem equation32 (E : FiniteMarkovEquilibrium P K) (i : ι) :
    P.q (E.theta i) * (1 - P.beta) * E.surplus i P.epsUpper = P.c :=
  E.equation32_freeEntry i

/-- Paper equation (33), zero surplus at the supplied cutoff. -/
theorem equation33 (E : FiniteMarkovEquilibrium P K) (i : ι) :
    E.surplus i (E.cutoff i) = 0 :=
  E.equation33_cutoff i

/-- Paper equation (34), with the conditional aggregate integral represented
as a finite expectation of active surplus. -/
theorem equation34 (E : FiniteMarkovEquilibrium P K) (i : ι) (eps : ℝ) :
    (P.r + P.lambda + K.aggregateArrival) * E.surplus i eps =
      K.commonProductivity i + P.sigma * eps - P.b
        - E.toFiniteMarkovCandidate.workerMeetingHazard i * P.beta *
            E.surplus i P.epsUpper
        + P.lambda * E.toFiniteMarkovCandidate.survivingSurplusIntegral i
        + K.aggregateArrival *
            K.nextExpectation i
              (fun j => E.toFiniteMarkovCandidate.activeSurplus j eps) := by
  exact E.equation34_surplus i eps

/-- Free entry after division by the positive Nash firm share. -/
theorem q_mul_upperSurplus_eq
    (A : CoreEconomicAssumptions P) (E : FiniteMarkovEquilibrium P K) (i : ι) :
    P.q (E.theta i) * E.surplus i P.epsUpper = P.c / (1 - P.beta) := by
  have hBeta : 1 - P.beta ≠ 0 := (sub_pos.mpr A.beta_lt_one).ne'
  apply (eq_div_iff hBeta).2
  rw [← E.equation32 i]
  ring

theorem upperSurplus_pos
    (A : CoreEconomicAssumptions P) (M : MatchingAssumptions P)
    (E : FiniteMarkovEquilibrium P K) (i : ι) :
    0 < E.surplus i P.epsUpper := by
  have hq : 0 < P.q (E.theta i) := M.vacancyMeetingRate_pos (E.theta_pos i)
  have hRight : 0 < P.c / (1 - P.beta) :=
    div_pos A.c_pos (sub_pos.mpr A.beta_lt_one)
  have hProduct : 0 < P.q (E.theta i) * E.surplus i P.epsUpper := by
    rw [E.q_mul_upperSurplus_eq A i]
    exact hRight
  exact pos_of_mul_pos_left (by simpa [mul_comm] using hProduct) hq.le

theorem workerMeetingHazard_pos
    (M : MatchingAssumptions P) (E : FiniteMarkovEquilibrium P K) (i : ι) :
    0 < E.toFiniteMarkovCandidate.workerMeetingHazard i :=
  P.workerMeetingRate_pos M (E.theta_pos i)

/-- The aggregate continuation term in equation (34) is nonnegative. -/
theorem aggregateContinuation_nonneg
    (KA : FiniteAggregateProcessAssumptions P K)
    (E : FiniteMarkovEquilibrium P K) (i : ι) (eps : ℝ) :
    0 ≤ K.aggregateArrival *
      K.nextExpectation i
        (fun j => E.toFiniteMarkovCandidate.activeSurplus j eps) := by
  apply mul_nonneg KA.aggregateArrival_nonneg
  apply K.nextExpectation_nonneg KA i
  intro j
  exact le_max_right _ _

/-- Compact interface for the finite-state equations and their immediate
positivity consequences. -/
def SatisfiesFiniteMarkovEquations32To34
    (_A : CoreEconomicAssumptions P)
    (_KA : FiniteAggregateProcessAssumptions P K)
    (_M : MatchingAssumptions P)
    (E : FiniteMarkovEquilibrium P K) : Prop :=
  (∀ i, E.toFiniteMarkovCandidate.workerMeetingHazard i =
      P.workerMeetingRate (E.theta i)) ∧
  (∀ i, P.q (E.theta i) * (1 - P.beta) * E.surplus i P.epsUpper = P.c) ∧
  (∀ i, E.surplus i (E.cutoff i) = 0) ∧
  (∀ i eps, (P.r + P.lambda + K.aggregateArrival) * E.surplus i eps =
      K.commonProductivity i + P.sigma * eps - P.b
        - E.toFiniteMarkovCandidate.workerMeetingHazard i * P.beta *
            E.surplus i P.epsUpper
        + P.lambda * E.toFiniteMarkovCandidate.survivingSurplusIntegral i
        + K.aggregateArrival * K.nextExpectation i
            (fun j => E.toFiniteMarkovCandidate.activeSurplus j eps)) ∧
  (∀ i, 0 < E.surplus i P.epsUpper) ∧
  (∀ i, 0 < E.toFiniteMarkovCandidate.workerMeetingHazard i) ∧
  (∀ i eps, 0 ≤ K.aggregateArrival * K.nextExpectation i
      (fun j => E.toFiniteMarkovCandidate.activeSurplus j eps))

theorem m10_1_finiteMarkov_capstone
    (A : CoreEconomicAssumptions P)
    (KA : FiniteAggregateProcessAssumptions P K)
    (M : MatchingAssumptions P)
    (E : FiniteMarkovEquilibrium P K) :
    SatisfiesFiniteMarkovEquations32To34 A KA M E := by
  refine ⟨fun i => E.workerMeetingHazard_eq i, fun i => E.equation32 i,
    fun i => E.equation33 i, fun i eps => E.equation34 i eps,
    fun i => E.upperSurplus_pos A M i, fun i => E.workerMeetingHazard_pos M i, ?_⟩
  exact fun i eps => E.aggregateContinuation_nonneg KA i eps

end FiniteMarkovEquilibrium
end MP1994V2
