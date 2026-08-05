import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentDensity

/-!
# MP1994 v2: paper equation (35)

The primary theorem is measure-valued. The density statement is an optional
corollary under explicit shock and employment density representations.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Paper equation (35), primary measure form on interior shock states. The
creation atom at `epsUpper` is excluded by restriction to `Iio epsUpper`. -/
theorem equation35_measure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal) :
    (N.rawNextMeasure D DP j creationMass).restrict (Iio P.epsUpper) =
      (((1 - DP.redrawProb : NNReal) : ENNReal) •
          N.measure.restrict (Ico (E.cutoff j) P.epsUpper)) +
        (((DP.redrawProb : ENNReal) * N.survivingMass j) •
          P.shock.restrict (Ico (E.cutoff j) P.epsUpper)) := by
  rw [rawNextMeasure, Measure.restrict_add,
    upperCreationMeasure_restrict_Iio_epsUpper_eq_zero, add_zero,
    incumbentNextMeasure, Measure.restrict_add]
  unfold noRedrawMeasure redrawMeasure survivingMeasure
    Primitives.shockSurvivingMeasure
  simp only [Measure.restrict_smul, Measure.restrict_restrict measurableSet_Iio]
  rw [show Iio P.epsUpper ∩ Icc (E.cutoff j) P.epsUpper =
      Ico (E.cutoff j) P.epsUpper by
    ext x
    simp only [mem_inter_iff, mem_Iio, mem_Icc, mem_Ico]
    constructor
    · rintro ⟨hu, hl, _⟩
      exact ⟨hl, hu⟩
    · rintro ⟨hl, hu⟩
      exact ⟨hu, hl, hu.le⟩]

/-- Under explicit density representations, restricting the raw next measure
below `epsUpper` gives Lebesgue measure with the paper's interior density. -/
theorem rawNextMeasure_restrict_Iio_eq_density
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (SD : ShockDensityRepresentation P)
    (ND : EmploymentDensityRepresentation N) :
    (N.rawNextMeasure D DP j creationMass).restrict (Iio P.epsUpper) =
      volume.withDensity
        (nextInteriorDensity DP SD.density ND.interiorDensity
          (N.survivingMass j) (E.cutoff j) P.epsUpper) := by
  rw [N.equation35_measure D DP j creationMass, SD.shock_eq, ND.measure_eq]
  rw [Measure.restrict_add, Measure.restrict_smul]
  have hDirac : (Measure.dirac P.epsUpper).restrict
      (Ico (E.cutoff j) P.epsUpper) = 0 := by
    rw [Measure.restrict_eq_zero]
    simp [Measure.dirac_apply']
  rw [hDirac, smul_zero, add_zero]
  rw [restrict_withDensity measurableSet_Ico,
    restrict_withDensity measurableSet_Ico]
  rw [← withDensity_smul _ SD.measurable_density,
    ← withDensity_smul _ ND.measurable_interiorDensity]
  rw [← withDensity_add_left]
  · rw [← withDensity_indicator measurableSet_Ico]
    apply withDensity_congr_ae
    filter_upwards with x
    simp [nextInteriorDensity, Set.indicator, mul_assoc, add_comm]
  · exact ND.measurable_interiorDensity.const_smul _

/-- The actual raw-next employment measure assigns the claimed retained-plus-
created mass to the upper support point. The redraw component contributes no
atom because the primitive shock law is atomless. -/
theorem equation35_upperMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (ND : EmploymentDensityRepresentation N) :
    N.rawNextMeasure D DP j creationMass {P.epsUpper} =
      nextUpperMass DP ND.upperMass creationMass := by
  have hCutoff : P.epsUpper ∈ Icc (E.cutoff j) P.epsUpper :=
    ⟨(E.cutoff_lt_epsUpper j).le, le_rfl⟩
  simp [rawNextMeasure, incumbentNextMeasure, noRedrawMeasure, redrawMeasure,
    survivingMeasure, Primitives.shockSurvivingMeasure, upperCreationMeasure,
    Measure.smul_apply, hCutoff, ND.measure_singleton_epsUpper_eq,
    D.shock_singleton_eq_zero, nextUpperMass]

/-- Full equation-(35) density decomposition. The interior density and the
upper-support atom together describe the entire raw next measure. -/
theorem rawNextMeasure_eq_density_plus_upperAtom
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (SD : ShockDensityRepresentation P)
    (ND : EmploymentDensityRepresentation N) :
    N.rawNextMeasure D DP j creationMass =
      volume.withDensity
          (nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper) +
        nextUpperMass DP ND.upperMass creationMass •
          Measure.dirac P.epsUpper := by
  let mu := N.rawNextMeasure D DP j creationMass
  have hInterior :
      mu.restrict (Iio P.epsUpper) =
        volume.withDensity
          (nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper) :=
    N.rawNextMeasure_restrict_Iio_eq_density D DP j creationMass SD ND
  have hUpper :
      mu {P.epsUpper} = nextUpperMass DP ND.upperMass creationMass :=
    N.equation35_upperMass D DP j creationMass ND
  have hSupported : ∀ᵐ x ∂mu, x ∈ Iic P.epsUpper := by
    filter_upwards [N.rawNextMeasure_supported D DP j creationMass] with x hx
    exact hx.2
  have hIic : Iic P.epsUpper = Iio P.epsUpper ∪ {P.epsUpper} := by
    ext x
    simp [le_iff_lt_or_eq]
  calc
    mu = mu.restrict (Iic P.epsUpper) :=
      (Measure.restrict_eq_self_of_ae_mem hSupported).symm
    _ = mu.restrict (Iio P.epsUpper ∪ {P.epsUpper}) := by rw [← hIic]
    _ = mu.restrict (Iio P.epsUpper) + mu.restrict {P.epsUpper} := by
      rw [Measure.restrict_union]
      · exact Set.disjoint_singleton_right.mpr (lt_irrefl P.epsUpper)
      · exact measurableSet_singleton P.epsUpper
    _ = volume.withDensity
          (nextInteriorDensity DP SD.density ND.interiorDensity
            (N.survivingMass j) (E.cutoff j) P.epsUpper) +
        nextUpperMass DP ND.upperMass creationMass •
          Measure.dirac P.epsUpper := by
      rw [hInterior, Measure.restrict_singleton, hUpper]

/-- Almost-everywhere paper density formula for equation (35). -/
theorem equation35_density_ae
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DP : DiscreteEmploymentParameters) (j : ι)
    (SD : ShockDensityRepresentation P)
    (ND : EmploymentDensityRepresentation N) :
    ∀ᵐ eps ∂volume,
      nextInteriorDensity DP SD.density ND.interiorDensity
          (N.survivingMass j) (E.cutoff j) P.epsUpper eps =
        if eps ∈ Ico (E.cutoff j) P.epsUpper then
          (((1 - DP.redrawProb : NNReal) : ENNReal) * ND.interiorDensity eps) +
            (DP.redrawProb : ENNReal) * N.survivingMass j * SD.density eps
        else 0 := by
  filter_upwards with eps
  rfl

/-- Definitional simplification for the separately named next upper mass. -/
@[simp] theorem nextUpperMass_eq
    (DP : DiscreteEmploymentParameters) (upperMass creationMass : ENNReal) :
    nextUpperMass DP upperMass creationMass =
      ((1 - DP.redrawProb : NNReal) : ENNReal) * upperMass + creationMass := rfl

end FiniteMarkovEmploymentDistribution
end MP1994V2
