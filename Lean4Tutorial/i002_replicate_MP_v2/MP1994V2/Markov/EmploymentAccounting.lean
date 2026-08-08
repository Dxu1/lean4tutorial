import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentDestruction

/-!
# MP1994 v2: endogenous employment accounting

The endogenous creation mass is inserted into the reviewed equation-(35)
measure transition.  The additive accounting identity and unit-mass bound are
then proved rather than stored as premises.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Equation-(35) transition with creation determined by discrete matching. -/
noncomputable def endogenousRawNextMeasure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) : Measure ℝ :=
  N.rawNextMeasure D DP j (N.endogenousCreationMass DM j)

/-- Total mass of the endogenous raw next measure. -/
noncomputable def endogenousRawNextMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) : ENNReal :=
  N.endogenousRawNextMeasure D DP DM j univ

@[simp] theorem endogenousRawNextMass_eq
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousRawNextMass D DP DM j =
      N.incumbentNextMass D DP j + N.endogenousCreationMass DM j := by
  change N.rawNextMass D DP j (N.endogenousCreationMass DM j) =
    N.incumbentNextMass D DP j + N.endogenousCreationMass DM j
  exact N.rawNextMass_eq D DP j (N.endogenousCreationMass DM j)

/-- Fundamental additive accounting: equation (35)'s next mass plus staged
destruction equals current employment plus endogenous creation. -/
theorem endogenousRawNextMass_add_totalDestructionMass_eq
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousRawNextMass D DP DM j + N.totalDestructionMass D DP j =
      N.currentMass + N.endogenousCreationMass DM j := by
  rw [N.endogenousRawNextMass_eq D DP DM j]
  calc
    (N.incumbentNextMass D DP j + N.endogenousCreationMass DM j) +
        N.totalDestructionMass D DP j =
      (N.incumbentNextMass D DP j + N.totalDestructionMass D DP j) +
        N.endogenousCreationMass DM j := by ac_rfl
    _ = N.currentMass + N.endogenousCreationMass DM j := by
      rw [N.incumbentNextMass_add_totalDestructionMass_eq_currentMass D DP j]

theorem incumbentNextMass_le_currentMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.incumbentNextMass D DP j ≤ N.currentMass := by
  rw [← N.incumbentNextMass_add_totalDestructionMass_eq_currentMass D DP j]
  exact le_add_right (le_refl (N.incumbentNextMass D DP j))

/-- Endogenous matching automatically preserves the unit labor-force bound. -/
theorem endogenousRawNextMass_le_one
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousRawNextMass D DP DM j ≤ 1 := by
  rw [N.endogenousRawNextMass_eq D DP DM j]
  calc
    N.incumbentNextMass D DP j + N.endogenousCreationMass DM j ≤
        N.currentMass + N.endogenousCreationMass DM j :=
      add_le_add_left (N.incumbentNextMass_le_currentMass D DP j) _
    _ ≤ 1 := N.currentMass_add_endogenousCreationMass_le_one DM j

theorem endogenousRawNextMass_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    N.endogenousRawNextMass D DP DM j ≠ ⊤ :=
  ne_of_lt ((N.endogenousRawNextMass_le_one D DP DM j).trans_lt ENNReal.one_lt_top)

/-- Package the endogenous transition without caller-supplied finiteness or
mass-bound premises. -/
noncomputable def toEndogenousNextDistribution
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    FiniteMarkovEmploymentDistribution P E j :=
  N.toNextDistribution D DP j (N.endogenousCreationMass DM j)
    (N.endogenousCreationMass_ne_top DM j)
    (by
      change N.endogenousRawNextMass D DP DM j ≤ 1
      exact N.endogenousRawNextMass_le_one D DP DM j)

@[simp] theorem toEndogenousNextDistribution_measure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    (N.toEndogenousNextDistribution D DP DM j).measure =
      N.endogenousRawNextMeasure D DP DM j := rfl

@[simp] theorem toEndogenousNextDistribution_currentMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    (N.toEndogenousNextDistribution D DP DM j).currentMass =
      N.endogenousRawNextMass D DP DM j := rfl

@[simp] theorem toEndogenousNextDistribution_employmentMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    (N.toEndogenousNextDistribution D DP DM j).employmentMass =
      (N.endogenousRawNextMass D DP DM j).toReal := rfl

/-- Robust additive ENNReal form of paper equation (38). -/
theorem equation38_ennreal
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    (N.toEndogenousNextDistribution D DP DM j).currentMass +
        N.totalDestructionMass D DP j =
      N.currentMass + N.endogenousCreationMass DM j := by
  simpa using N.endogenousRawNextMass_add_totalDestructionMass_eq D DP DM j

/-- Real subtraction form of paper equation (38), derived from equation (35)
and the staged destruction identity. -/
theorem equation38
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    (N.toEndogenousNextDistribution D DP DM j).employmentMass =
      N.employmentMass + (N.endogenousCreationMass DM j).toReal -
        (N.totalDestructionMass D DP j).toReal := by
  have h := congrArg ENNReal.toReal (N.equation38_ennreal D DP DM j)
  rw [ENNReal.toReal_add
      (N.toEndogenousNextDistribution D DP DM j).currentMass_ne_top
      (N.totalDestructionMass_ne_top D DP j),
    ENNReal.toReal_add N.currentMass_ne_top
      (N.endogenousCreationMass_ne_top DM j)] at h
  change
    (N.toEndogenousNextDistribution D DP DM j).employmentMass +
        (N.totalDestructionMass D DP j).toReal =
      N.employmentMass + (N.endogenousCreationMass DM j).toReal at h
  linarith

theorem creationFlow_nonneg
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DM : DiscreteMatchingParameters ι) (j : ι) :
    0 ≤ (N.endogenousCreationMass DM j).toReal := ENNReal.toReal_nonneg

theorem destructionFlow_nonneg
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    0 ≤ (N.totalDestructionMass D DP j).toReal := ENNReal.toReal_nonneg

end FiniteMarkovEmploymentDistribution
end MP1994V2
