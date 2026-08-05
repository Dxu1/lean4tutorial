import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.FiniteStateEquilibriumConsequences
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoffResults

/-!
# MP1994 v2: embedding the reviewed two-state economy

The deterministic-other-state kernel specializes the finite expectation to
the aggregate continuation already derived in M9. Every supplied two-state
value equilibrium therefore induces equations (32)--(34). No converse or
existence theorem is claimed.
-/

open MeasureTheory Set

namespace MP1994V2
namespace TwoStatePrimitives

variable {P : Primitives}

/-- The two-state process as a finite marked-Poisson process. -/
noncomputable def toFiniteAggregateProcess (T : TwoStatePrimitives P) :
    FiniteAggregateProcess P AggregateState where
  commonProductivity
    | .recession => P.p
    | .boom => T.pHigh
  aggregateArrival := T.aggregateArrival
  transitionWeight i j := if j = i.other then 1 else 0

@[simp] theorem toFiniteAggregateProcess_productivity_recession
    (T : TwoStatePrimitives P) :
    T.toFiniteAggregateProcess.commonProductivity .recession = P.p := rfl

@[simp] theorem toFiniteAggregateProcess_productivity_boom
    (T : TwoStatePrimitives P) :
    T.toFiniteAggregateProcess.commonProductivity .boom = T.pHigh := rfl

@[simp] theorem toFiniteAggregateProcess_arrival (T : TwoStatePrimitives P) :
    T.toFiniteAggregateProcess.aggregateArrival = T.aggregateArrival := rfl

theorem toFiniteAggregateProcess_transitionWeight_nonneg
    (T : TwoStatePrimitives P) (i j : AggregateState) :
    0 ≤ T.toFiniteAggregateProcess.transitionWeight i j := by
  by_cases h : j = i.other <;> simp [toFiniteAggregateProcess, h]

theorem toFiniteAggregateProcess_transitionWeight_sum_one
    (T : TwoStatePrimitives P) (i : AggregateState) :
    ∑ j, T.toFiniteAggregateProcess.transitionWeight i j = 1 := by
  simp only [toFiniteAggregateProcess]
  simp [Finset.sum_ite_eq']

theorem toFiniteAggregateProcess_assumptions
    {T : TwoStatePrimitives P} (TA : TwoStateEconomicAssumptions P T) :
    FiniteAggregateProcessAssumptions P T.toFiniteAggregateProcess := by
  refine ⟨TA.aggregateArrival_pos.le,
    T.toFiniteAggregateProcess_transitionWeight_nonneg,
    T.toFiniteAggregateProcess_transitionWeight_sum_one⟩

/-- The deterministic finite expectation is exactly the other-state value. -/
theorem nextExpectation_toFiniteAggregateProcess
    (T : TwoStatePrimitives P) (i : AggregateState) (f : AggregateState → ℝ) :
    T.toFiniteAggregateProcess.nextExpectation i f = f i.other := by
  cases i <;> simp [FiniteAggregateProcess.nextExpectation,
    toFiniteAggregateProcess, AggregateState.other]

end TwoStatePrimitives

namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- The finite candidate obtained from the reviewed M9 statewise objects. -/
noncomputable def toFiniteMarkovCandidate
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    FiniteMarkovCandidate P T.toFiniteAggregateProcess where
  theta := E.theta
  cutoff := E.reservationCutoff A D TA M
  surplus := E.surplus

@[simp] theorem toFiniteMarkovCandidate_theta
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (E.toFiniteMarkovCandidate A D TA M).theta = E.theta := rfl

@[simp] theorem toFiniteMarkovCandidate_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (E.toFiniteMarkovCandidate A D TA M).cutoff =
      E.reservationCutoff A D TA M := rfl

@[simp] theorem toFiniteMarkovCandidate_surplus
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (E.toFiniteMarkovCandidate A D TA M).surplus = E.surplus := rfl

private theorem survivingSurplus_integrable
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    Integrable (fun x => E.surplus s x)
      (P.shock.restrict
        (Icc (E.reservationCutoff A D TA M s) P.epsUpper)) := by
  have hActive : Integrable (fun x => E.activeSurplus s x)
      (P.shock.restrict
        (Icc (E.reservationCutoff A D TA M s) P.epsUpper)) :=
    (E.active_surplus_integrable s).mono_measure Measure.restrict_le_self
  apply hActive.congr
  filter_upwards [ae_restrict_mem measurableSet_Icc] with x hx
  unfold TwoStateValueCandidate.activeSurplus positivePart
  rw [max_eq_left]
  exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M s x).2 hx.1

/-- Every supplied M9 two-state equilibrium induces the finite-state
continuous-time representation (32)--(34). -/
noncomputable def toFiniteMarkovEquilibrium
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    FiniteMarkovEquilibrium P T.toFiniteAggregateProcess where
  toFiniteMarkovCandidate := E.toFiniteMarkovCandidate A D TA M
  theta_pos := E.theta_pos
  cutoff_lt_epsUpper := E.reservationCutoff_lt_epsUpper A D TA M
  surviving_surplus_integrable := E.survivingSurplus_integrable A D TA M
  equation32_freeEntry := by
    intro s
    have hFree := E.statewise_q_mul_surplus_upper_eq A s
    have hBeta : 1 - P.beta ≠ 0 := (sub_pos.mpr A.beta_lt_one).ne'
    change P.q (E.theta s) * (1 - P.beta) * E.surplus s P.epsUpper = P.c
    calc
      P.q (E.theta s) * (1 - P.beta) * E.surplus s P.epsUpper =
          (P.q (E.theta s) * E.surplus s P.epsUpper) * (1 - P.beta) := by ring
      _ = (P.c / (1 - P.beta)) * (1 - P.beta) := by rw [hFree]
      _ = P.c := by field_simp [hBeta]
  equation33_cutoff := E.surplus_reservationCutoff_eq_zero A D TA M
  equation34_surplus := by
    intro s eps
    have hBellman := E.coupled_surplus_bellman D s eps
    rw [E.statewise_continuation_integral_eq A D TA M s] at hBellman
    change
      (P.r + P.lambda + T.aggregateArrival) * E.surplus s eps =
        T.toFiniteAggregateProcess.commonProductivity s + P.sigma * eps - P.b
          - P.workerMeetingRate (E.theta s) * P.beta * E.surplus s P.epsUpper
          + P.lambda *
              (E.toFiniteMarkovCandidate A D TA M).survivingSurplusIntegral s
          + T.aggregateArrival *
              T.toFiniteAggregateProcess.nextExpectation s
                (fun j => (E.toFiniteMarkovCandidate A D TA M).activeSurplus j eps)
    rw [T.nextExpectation_toFiniteAggregateProcess]
    change
      (P.r + P.lambda + T.aggregateArrival) * E.surplus s eps =
        T.toFiniteAggregateProcess.commonProductivity s + P.sigma * eps - P.b
          - P.workerMeetingRate (E.theta s) * P.beta * E.surplus s P.epsUpper
          + P.lambda *
              (∫ x in Icc (E.reservationCutoff A D TA M s) P.epsUpper,
                E.surplus s x ∂P.shock)
          + T.aggregateArrival * E.activeSurplus s.other eps
    cases s
    · rw [TwoStatePrimitives.productivity_recession] at hBellman
      linear_combination hBellman
    · rw [TwoStatePrimitives.productivity_boom] at hBellman
      linear_combination hBellman

@[simp] theorem toFiniteMarkovEquilibrium_theta
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (E.toFiniteMarkovEquilibrium A D TA M).theta = E.theta := rfl

@[simp] theorem toFiniteMarkovEquilibrium_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (E.toFiniteMarkovEquilibrium A D TA M).cutoff =
      E.reservationCutoff A D TA M := rfl

@[simp] theorem toFiniteMarkovEquilibrium_surplus
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (E.toFiniteMarkovEquilibrium A D TA M).surplus = E.surplus := rfl

theorem m10_1_twoState_embedding_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    FiniteMarkovEquilibrium.SatisfiesFiniteMarkovEquations32To34 A
        (T.toFiniteAggregateProcess_assumptions TA) M
        (E.toFiniteMarkovEquilibrium A D TA M) ∧
      (E.toFiniteMarkovEquilibrium A D TA M).theta = E.theta ∧
      (E.toFiniteMarkovEquilibrium A D TA M).cutoff =
        E.reservationCutoff A D TA M ∧
      (E.toFiniteMarkovEquilibrium A D TA M).surplus = E.surplus := by
  refine ⟨FiniteMarkovEquilibrium.m10_1_finiteMarkov_capstone A
      (T.toFiniteAggregateProcess_assumptions TA) M
      (E.toFiniteMarkovEquilibrium A D TA M), rfl, rfl, rfl⟩

end TwoStateValueEquilibrium
end MP1994V2
