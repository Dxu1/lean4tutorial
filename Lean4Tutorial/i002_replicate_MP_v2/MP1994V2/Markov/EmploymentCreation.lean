import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.DiscreteMatchingPrimitives

/-!
# MP1994 v2: endogenous employment creation

Equation (36) multiplies unit-labor-force unemployment by an explicit
one-period matching probability.
-/

open MeasureTheory

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- ENNReal unemployment under a unit labor force. -/
noncomputable def unemploymentMassENNReal
    (N : FiniteMarkovEmploymentDistribution P E i) : ENNReal :=
  1 - N.currentMass

theorem currentMass_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.currentMass ≠ ⊤ :=
  ne_of_lt (N.mass_le_one.trans_lt ENNReal.one_lt_top)

theorem currentMass_add_unemploymentMassENNReal
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.currentMass + N.unemploymentMassENNReal = 1 := by
  exact add_tsub_cancel_of_le N.mass_le_one

theorem unemploymentMassENNReal_le_one
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.unemploymentMassENNReal ≤ 1 := by
  exact tsub_le_self

theorem unemploymentMassENNReal_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.unemploymentMassENNReal ≠ ⊤ :=
  ne_of_lt (N.unemploymentMassENNReal_le_one.trans_lt ENNReal.one_lt_top)

/-- Endogenous one-period creation mass in next aggregate state `j`. -/
noncomputable def endogenousCreationMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) : ENNReal :=
  (DM.matchProb j : ENNReal) * N.unemploymentMassENNReal

theorem endogenousCreationMass_nonneg
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    0 ≤ N.endogenousCreationMass DM j := bot_le

theorem endogenousCreationMass_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousCreationMass DM j ≠ ⊤ := by
  unfold endogenousCreationMass
  exact ENNReal.mul_ne_top (by simp) N.unemploymentMassENNReal_ne_top

theorem endogenousCreationMass_le_unemploymentMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousCreationMass DM j ≤ N.unemploymentMassENNReal := by
  unfold endogenousCreationMass
  calc
    (DM.matchProb j : ENNReal) * N.unemploymentMassENNReal ≤
        1 * N.unemploymentMassENNReal := by
      apply mul_le_mul_left
      exact_mod_cast DM.matchProb_le_one j
    _ = N.unemploymentMassENNReal := one_mul _

theorem currentMass_add_endogenousCreationMass_le_one
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.currentMass + N.endogenousCreationMass DM j ≤ 1 := by
  calc
    N.currentMass + N.endogenousCreationMass DM j ≤
        N.currentMass + N.unemploymentMassENNReal :=
      add_le_add_right (N.endogenousCreationMass_le_unemploymentMass DM j) _
    _ = 1 := N.currentMass_add_unemploymentMassENNReal

/-- Discrete-probability form of paper equation (36). -/
theorem equation36_discrete
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousCreationMass DM j =
      (DM.matchProb j : ENNReal) * (1 - N.currentMass) := rfl

theorem unemploymentMassENNReal_toReal
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.unemploymentMassENNReal.toReal = 1 - N.employmentMass := by
  unfold unemploymentMassENNReal currentMass
  rw [ENNReal.toReal_sub_of_le N.mass_le_one (by simp)]
  simp [currentMass, employmentMass]

/-- Paper-facing equation (36), conditional on the explicit identification of
the discrete matching probability with the continuous-time worker hazard. -/
theorem equation36
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (PI : PaperMatchingIdentification E DM)
    (j : ι) :
    (N.endogenousCreationMass DM j).toReal =
      E.workerMeetingHazard j * (1 - N.employmentMass) := by
  rw [endogenousCreationMass, ENNReal.toReal_mul,
    N.unemploymentMassENNReal_toReal]
  simpa [PI.matchProb_eq_workerMeetingHazard j]

theorem endogenousCreationMass_eq_zero_of_matchProb_eq_zero
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι)
    (hZero : DM.matchProb j = 0) :
    N.endogenousCreationMass DM j = 0 := by
  simp [endogenousCreationMass, hZero]

end FiniteMarkovEmploymentDistribution
end MP1994V2
