import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentTransitionFoundations

/-!
# MP1994 v2: discrete matching primitives

The one-period matching probability is deliberately separate from the
continuous-time worker meeting hazard.  The paper-facing identification is an
explicit proposition, not a field of the finite-state equilibrium.
-/

namespace MP1994V2

/-- State-contingent one-period matching probabilities. -/
structure DiscreteMatchingParameters (ι : Type*) [Fintype ι] where
  matchProb : ι → NNReal
  matchProb_le_one : ∀ j, matchProb j ≤ 1

namespace DiscreteMatchingParameters

theorem matchProb_nonneg {ι : Type*} [Fintype ι]
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    0 ≤ DM.matchProb j := by positivity

theorem one_sub_matchProb_nonneg {ι : Type*} [Fintype ι]
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    0 ≤ 1 - DM.matchProb j := by positivity

theorem matchProb_coe_mem_unitInterval {ι : Type*} [Fintype ι]
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    (DM.matchProb j : ℝ) ∈ Set.Icc 0 1 := by
  constructor
  · exact_mod_cast DM.matchProb_nonneg j
  · exact_mod_cast DM.matchProb_le_one j

end DiscreteMatchingParameters

/-- Explicit identification of a discrete matching probability with the
paper's worker meeting hazard.  It is an assumption only for paper-facing
equation (36), never a silent hazard-to-probability conversion. -/
structure PaperMatchingIdentification
    {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι}
    (E : FiniteMarkovEquilibrium P K)
    (DM : DiscreteMatchingParameters ι) : Prop where
  matchProb_eq_workerMeetingHazard :
    ∀ j, (DM.matchProb j : ℝ) = E.workerMeetingHazard j

namespace PaperMatchingIdentification

theorem workerMeetingHazard_le_one
    {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι}
    {E : FiniteMarkovEquilibrium P K}
    {DM : DiscreteMatchingParameters ι}
    (PI : PaperMatchingIdentification E DM) (j : ι) :
    E.workerMeetingHazard j ≤ 1 := by
  rw [← PI.matchProb_eq_workerMeetingHazard j]
  exact_mod_cast DM.matchProb_le_one j

end PaperMatchingIdentification
end MP1994V2
