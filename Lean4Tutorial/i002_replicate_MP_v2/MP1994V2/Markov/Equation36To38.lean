import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentAccounting

/-!
# MP1994 v2: public interfaces for equations (36)--(38)

* Equation (36) uses an explicit `PaperMatchingIdentification`.
* Equation (37) uses the discrete `redrawProb`, never `P.lambda`.
* Equation (38) is derived from the reviewed equation-(35) transition and
  staged destruction; it is not an accounting axiom.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Convenient joint paper-facing interface for equations (36)--(38). -/
theorem equations36_to_38
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
      (N.toEndogenousNextDistribution D DP DM j).employmentMass =
        N.employmentMass + (N.endogenousCreationMass DM j).toReal -
          (N.totalDestructionMass D DP j).toReal := by
  exact ⟨N.equation36 DM PI j, N.equation37 D DP j, N.equation38 D DP DM j⟩

end FiniteMarkovEmploymentDistribution
end MP1994V2
