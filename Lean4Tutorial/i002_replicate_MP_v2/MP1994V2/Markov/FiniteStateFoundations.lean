import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.TwoStateEmbedding

/-!
# MP1994 v2: M10.1 finite-state foundations capstone

This module closes only the continuous-time representation layer for equations
(32)--(34). Equation (35), employment transitions, and equations (36)--(38)
remain outside M10.1.
-/

namespace MP1994V2

/-- Generic finite-state kernel laws together with equations (32)--(34) for a
supplied finite Markov equilibrium. -/
theorem m10_1_finiteState_foundations_capstone
    {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι}
    (A : CoreEconomicAssumptions P)
    (KA : FiniteAggregateProcessAssumptions P K)
    (M : MatchingAssumptions P)
    (E : FiniteMarkovEquilibrium P K) :
    FiniteMarkovEquilibrium.SatisfiesFiniteMarkovEquations32To34 A KA M E ∧
      (∀ i c, K.nextExpectation i (fun _ => c) = c) ∧
      (∀ i (f : ι → ℝ), (∀ j, 0 ≤ f j) → 0 ≤ K.nextExpectation i f) ∧
      (∀ i (f g : ι → ℝ), (∀ j, f j ≤ g j) →
        K.nextExpectation i f ≤ K.nextExpectation i g) := by
  refine ⟨FiniteMarkovEquilibrium.m10_1_finiteMarkov_capstone A KA M E,
    fun i c => K.nextExpectation_const KA i c,
    fun i f hf => K.nextExpectation_nonneg KA i hf,
    fun i f g hfg => K.nextExpectation_mono KA i hfg⟩

/-- The reviewed M9 two-state model is a deterministic-other-state instance
of the generic finite-state representation. This is a forward embedding only. -/
theorem m10_1_twoState_foundations_capstone
    {P : Primitives} {T : TwoStatePrimitives P}
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    FiniteMarkovEquilibrium.SatisfiesFiniteMarkovEquations32To34 A
        (T.toFiniteAggregateProcess_assumptions TA) M
        (E.toFiniteMarkovEquilibrium A D TA M) ∧
      (E.toFiniteMarkovEquilibrium A D TA M).theta = E.theta ∧
      (E.toFiniteMarkovEquilibrium A D TA M).cutoff =
        E.reservationCutoff A D TA M ∧
      (E.toFiniteMarkovEquilibrium A D TA M).surplus = E.surplus :=
  E.m10_1_twoState_embedding_capstone A D TA M

end MP1994V2
