import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.Equation36To38

/-!
# MP1994 v2: M10.3 employment-accounting capstones

These capstones require no externally supplied creation mass, mass bound,
destruction identity, density witness, or static-existence assumption.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

theorem m10_3_creation_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (PI : PaperMatchingIdentification E DM)
    (j : ι) :
    N.endogenousCreationMass DM j =
        (DM.matchProb j : ENNReal) * (1 - N.currentMass) ∧
      (N.endogenousCreationMass DM j).toReal =
        E.workerMeetingHazard j * (1 - N.employmentMass) ∧
      N.endogenousCreationMass DM j ≤ N.unemploymentMassENNReal ∧
      N.currentMass + N.endogenousCreationMass DM j ≤ 1 := by
  exact ⟨N.equation36_discrete DM j, N.equation36 DM PI j,
    N.endogenousCreationMass_le_unemploymentMass DM j,
    N.currentMass_add_endogenousCreationMass_le_one DM j⟩

theorem m10_3_destruction_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.incumbentNextMass D DP j + N.totalDestructionMass D DP j =
        N.currentMass ∧
      N.totalDestructionMass D DP j =
        N.measure (Iio (E.cutoff j)) +
          (DP.redrawProb : ENNReal) * N.survivingMass j *
            P.shock (Iio (E.cutoff j)) ∧
      (N.totalDestructionMass D DP j).toReal =
        (N.measure (Iio (E.cutoff j))).toReal +
          (DP.redrawProb : ℝ) * P.cdf (E.cutoff j) *
            (N.employmentMass -
              (N.measure (Iio (E.cutoff j))).toReal) := by
  exact ⟨N.incumbentNextMass_add_totalDestructionMass_eq_currentMass D DP j,
    N.equation37_ennreal D DP j, N.equation37 D DP j⟩

theorem m10_3_accounting_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousRawNextMass D DP DM j + N.totalDestructionMass D DP j =
        N.currentMass + N.endogenousCreationMass DM j ∧
      N.endogenousRawNextMass D DP DM j ≤ 1 ∧
      (N.toEndogenousNextDistribution D DP DM j).measure =
        N.endogenousRawNextMeasure D DP DM j ∧
      (N.toEndogenousNextDistribution D DP DM j).employmentMass =
        N.employmentMass + (N.endogenousCreationMass DM j).toReal -
          (N.totalDestructionMass D DP j).toReal := by
  exact ⟨N.endogenousRawNextMass_add_totalDestructionMass_eq D DP DM j,
    N.endogenousRawNextMass_le_one D DP DM j,
    N.toEndogenousNextDistribution_measure D DP DM j,
    N.equation38 D DP DM j⟩

/-- Full M10.3 foundation, parameterized only by the supplied finite Markov
equilibrium, current distribution, next state, and explicit discrete
probabilities (plus the paper identification used by equation (36)). -/
theorem m10_3_employmentAccounting_foundations_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (PI : PaperMatchingIdentification E DM)
    (j : ι) :
    (N.endogenousCreationMass DM j).toReal =
        E.workerMeetingHazard j * (1 - N.employmentMass) ∧
      (N.totalDestructionMass D DP j).toReal =
        (N.measure (Iio (E.cutoff j))).toReal +
          (DP.redrawProb : ℝ) * P.cdf (E.cutoff j) *
            (N.employmentMass -
              (N.measure (Iio (E.cutoff j))).toReal) ∧
      N.incumbentNextMass D DP j + N.totalDestructionMass D DP j =
        N.currentMass ∧
      (N.toEndogenousNextDistribution D DP DM j).currentMass +
          N.totalDestructionMass D DP j =
        N.currentMass + N.endogenousCreationMass DM j ∧
      (N.toEndogenousNextDistribution D DP DM j).employmentMass =
        N.employmentMass + (N.endogenousCreationMass DM j).toReal -
          (N.totalDestructionMass D DP j).toReal := by
  exact ⟨N.equation36 DM PI j,
    N.equation37 D DP j,
    N.incumbentNextMass_add_totalDestructionMass_eq_currentMass D DP j,
    N.equation38_ennreal D DP DM j,
    N.equation38 D DP DM j⟩

end FiniteMarkovEmploymentDistribution
end MP1994V2
