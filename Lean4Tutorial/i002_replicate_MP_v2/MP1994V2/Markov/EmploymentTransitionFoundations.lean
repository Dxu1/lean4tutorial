import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.Equation35

/-!
# MP1994 v2: M10.2 employment-transition capstones

These capstones close only equation (35). Creation mass and the next aggregate
state remain supplied; later accounting equations are not included.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Compact interface for the mandatory measure-valued transition layer. -/
def SatisfiesMeasureTransition
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) : Prop :=
  (DP.redrawProb : ℝ) ∈ Icc 0 1 ∧
  (∀ j, N.currentMass = N.measure (Iio (E.cutoff j)) + N.survivingMass j) ∧
  (∀ j, N.incumbentNextMass D DP j =
      ((1 - DP.redrawProb : NNReal) : ENNReal) * N.survivingMass j +
        (DP.redrawProb : ENNReal) * N.survivingMass j *
          P.shock (Icc (E.cutoff j) P.epsUpper)) ∧
  (∀ j creationMass, N.rawNextMass D DP j creationMass =
      N.incumbentNextMass D DP j + creationMass) ∧
  (∀ j creationMass,
      ∀ᵐ x ∂N.rawNextMeasure D DP j creationMass,
        x ∈ Icc (E.cutoff j) P.epsUpper) ∧
  (∀ j creationMass, creationMass ≠ ⊤ →
      IsFiniteMeasure (N.rawNextMeasure D DP j creationMass)) ∧
  (∀ j creationMass hFinite hMass,
      (N.toNextDistribution D DP j creationMass hFinite hMass).measure =
        N.rawNextMeasure D DP j creationMass)

theorem m10_2_measureTransition_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) :
    SatisfiesMeasureTransition N D DP := by
  refine ⟨DP.redrawProb_coe_mem_unitInterval,
    fun j => N.currentMass_eq_belowCutoff_add_survivingMass j,
    fun j => N.incumbentNextMass_eq D DP j,
    fun j creationMass => N.rawNextMass_eq D DP j creationMass,
    fun j creationMass => N.rawNextMeasure_supported D DP j creationMass,
    fun j creationMass hFinite => N.rawNextMeasure_finite D DP j hFinite,
    fun j creationMass hFinite hMass =>
      N.toNextDistribution_measure D DP j creationMass hFinite hMass⟩

/-- Density-form equation (35), conditional on explicit density witnesses. -/
theorem m10_2_equation35_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (SD : ShockDensityRepresentation P)
    (ND : EmploymentDensityRepresentation N) :
    (N.rawNextMeasure D DP j creationMass).restrict (Iio P.epsUpper) =
        volume.withDensity
          (nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper) ∧
      N.rawNextMeasure D DP j creationMass =
        volume.withDensity
          (nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper) +
          nextUpperMass DP ND.upperMass creationMass •
            Measure.dirac P.epsUpper ∧
      (∀ᵐ eps ∂volume,
        nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper eps =
          if eps ∈ Ico (E.cutoff j) P.epsUpper then
            (((1 - DP.redrawProb : NNReal) : ENNReal) * ND.interiorDensity eps) +
              (DP.redrawProb : ENNReal) * N.survivingMass j * SD.density eps
          else 0) ∧
      N.rawNextMeasure D DP j creationMass {P.epsUpper} =
        nextUpperMass DP ND.upperMass creationMass := by
  exact ⟨N.rawNextMeasure_restrict_Iio_eq_density D DP j creationMass SD ND,
    N.rawNextMeasure_eq_density_plus_upperAtom D DP j creationMass SD ND,
    N.equation35_density_ae DP j SD ND,
    N.equation35_upperMass D DP j creationMass ND⟩

/-- Overall M10.2 capstone: mandatory measure transition plus the optional
density representation for supplied density witnesses. -/
theorem m10_2_employmentTransition_foundations_capstone
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (SD : ShockDensityRepresentation P)
    (ND : EmploymentDensityRepresentation N) :
    SatisfiesMeasureTransition N D DP ∧
      N.rawNextMeasure D DP j creationMass =
        volume.withDensity
          (nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper) +
          nextUpperMass DP ND.upperMass creationMass •
            Measure.dirac P.epsUpper ∧
      N.rawNextMeasure D DP j creationMass {P.epsUpper} =
        nextUpperMass DP ND.upperMass creationMass := by
  exact ⟨N.m10_2_measureTransition_capstone D DP,
    N.rawNextMeasure_eq_density_plus_upperAtom D DP j creationMass SD ND,
    N.equation35_upperMass D DP j creationMass ND⟩

end FiniteMarkovEmploymentDistribution
end MP1994V2
