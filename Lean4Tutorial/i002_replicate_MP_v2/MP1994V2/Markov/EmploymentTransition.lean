import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentDistribution

/-!
# MP1994 v2: measure-valued one-period employment transition

The next aggregate state and creation mass are supplied. The order is cutoff
re-evaluation, incumbent redraw, and then entry at the upper support point.
-/

open MeasureTheory Set

namespace MP1994V2

namespace Primitives

/-- Shock draws that survive a supplied cutoff. -/
noncomputable def shockSurvivingMeasure (P : Primitives) (cutoff : ℝ) : Measure ℝ :=
  P.shock.restrict (Icc cutoff P.epsUpper)

end Primitives

/-- A supplied mass of new jobs entering at the highest idiosyncratic state. -/
noncomputable def upperCreationMeasure
    (P : Primitives) (creationMass : ENNReal) : Measure ℝ :=
  creationMass • Measure.dirac P.epsUpper

namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Incumbents surviving immediate re-evaluation at the next-state cutoff. -/
noncomputable def survivingMeasure
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) : Measure ℝ :=
  N.measure.restrict (Icc (E.cutoff j) P.epsUpper)

/-- Mass reaching the redraw stage after aggregate cutoff re-evaluation. -/
noncomputable def survivingMass
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) : ENNReal :=
  N.survivingMeasure j univ

@[simp] theorem survivingMeasure_apply_univ
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.survivingMeasure j univ =
      N.measure (Icc (E.cutoff j) P.epsUpper) := by
  simp [survivingMeasure]

theorem survivingMeasure_le
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.survivingMeasure j ≤ N.measure := Measure.restrict_le_self

theorem survivingMass_le_currentMass
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.survivingMass j ≤ N.measure univ :=
  N.survivingMeasure_le j univ

theorem survivingMeasure_supported
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    ∀ᵐ x ∂N.survivingMeasure j, x ∈ Icc (E.cutoff j) P.epsUpper := by
  exact ae_restrict_mem measurableSet_Icc

theorem survivingMeasure_finite
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    IsFiniteMeasure (N.survivingMeasure j) := by
  refine ⟨?_⟩
  rw [survivingMeasure_apply_univ]
  letI : IsFiniteMeasure N.measure := N.finite_measure
  exact measure_lt_top N.measure _

/-- Surviving incumbents that retain their current idiosyncratic state. -/
noncomputable def noRedrawMeasure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DP : DiscreteEmploymentParameters) (j : ι) : Measure ℝ :=
  ((1 - DP.redrawProb : NNReal) : ENNReal) • N.survivingMeasure j

@[simp] theorem noRedrawMeasure_apply_univ
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DP : DiscreteEmploymentParameters) (j : ι) :
    N.noRedrawMeasure DP j univ =
      ((1 - DP.redrawProb : NNReal) : ENNReal) * N.survivingMass j := by
  simp [noRedrawMeasure, survivingMass, Measure.smul_apply]

theorem noRedrawMeasure_supported
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DP : DiscreteEmploymentParameters) (j : ι) :
    ∀ᵐ x ∂N.noRedrawMeasure DP j, x ∈ Icc (E.cutoff j) P.epsUpper := by
  exact Measure.ae_smul_measure (N.survivingMeasure_supported j) _

theorem noRedrawMeasure_finite
    (N : FiniteMarkovEmploymentDistribution P E i)
    (DP : DiscreteEmploymentParameters) (j : ι) :
    IsFiniteMeasure (N.noRedrawMeasure DP j) := by
  letI : IsFiniteMeasure (N.survivingMeasure j) := N.survivingMeasure_finite j
  exact Measure.smul_finite _ (by simp)

/-- Surviving incumbents that redraw and remain above the new cutoff. -/
noncomputable def redrawMeasure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (_D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) : Measure ℝ :=
  (((DP.redrawProb : ENNReal) * N.survivingMass j)) •
    P.shockSurvivingMeasure (E.cutoff j)

@[simp] theorem redrawMeasure_apply_univ
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.redrawMeasure D DP j univ =
      (DP.redrawProb : ENNReal) * N.survivingMass j *
        P.shock (Icc (E.cutoff j) P.epsUpper) := by
  simp [redrawMeasure, Primitives.shockSurvivingMeasure,
    Measure.smul_apply, mul_assoc]

theorem redrawMeasure_supported
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    ∀ᵐ x ∂N.redrawMeasure D DP j, x ∈ Icc (E.cutoff j) P.epsUpper := by
  exact Measure.ae_smul_measure (ae_restrict_mem measurableSet_Icc) _

theorem redrawMeasure_finite
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    IsFiniteMeasure (N.redrawMeasure D DP j) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  letI : IsFiniteMeasure (P.shockSurvivingMeasure (E.cutoff j)) := by
    refine ⟨?_⟩
    simp [Primitives.shockSurvivingMeasure]
  apply Measure.smul_finite
  have hSurviving : N.survivingMass j ≠ ⊤ := by
    exact ne_of_lt (N.survivingMeasure_finite j).measure_univ_lt_top
  exact ENNReal.mul_ne_top (by simp) hSurviving

/-- Complete incumbent transition before new job creation. -/
noncomputable def incumbentNextMeasure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) : Measure ℝ :=
  N.noRedrawMeasure DP j + N.redrawMeasure D DP j

theorem incumbentNextMeasure_finite
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    IsFiniteMeasure (N.incumbentNextMeasure D DP j) := by
  refine ⟨?_⟩
  rw [incumbentNextMeasure]
  simp only [Measure.add_apply]
  exact ENNReal.add_lt_top.2 ⟨
    (N.noRedrawMeasure_finite DP j).measure_univ_lt_top,
    (N.redrawMeasure_finite D DP j).measure_univ_lt_top⟩

theorem incumbentNextMeasure_supported
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    ∀ᵐ x ∂N.incumbentNextMeasure D DP j,
      x ∈ Icc (E.cutoff j) P.epsUpper := by
  rw [incumbentNextMeasure, ae_add_measure_iff]
  exact ⟨N.noRedrawMeasure_supported DP j, N.redrawMeasure_supported D DP j⟩

/-- Full next-period measure including a supplied upper-support creation atom. -/
noncomputable def rawNextMeasure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal) : Measure ℝ :=
  N.incumbentNextMeasure D DP j + upperCreationMeasure P creationMass

@[simp] theorem upperCreationMeasure_apply_univ
    (creationMass : ENNReal) :
    upperCreationMeasure P creationMass univ = creationMass := by
  simp [upperCreationMeasure, Measure.smul_apply]

theorem upperCreationMeasure_supported (creationMass : ENNReal) :
    ∀ᵐ x ∂upperCreationMeasure P creationMass, x = P.epsUpper := by
  exact Measure.ae_smul_measure (by simp) _

theorem upperCreationMeasure_restrict_Iio_epsUpper_eq_zero
    (creationMass : ENNReal) :
    (upperCreationMeasure P creationMass).restrict (Iio P.epsUpper) = 0 := by
  rw [Measure.restrict_eq_zero]
  simp [upperCreationMeasure, Measure.smul_apply, Measure.dirac_apply']

theorem rawNextMeasure_supported
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal) :
    ∀ᵐ x ∂N.rawNextMeasure D DP j creationMass,
      x ∈ Icc (E.cutoff j) P.epsUpper := by
  rw [rawNextMeasure, ae_add_measure_iff]
  refine ⟨N.incumbentNextMeasure_supported D DP j, ?_⟩
  filter_upwards [upperCreationMeasure_supported (P := P) creationMass] with x hx
  simpa [hx] using (E.cutoff_lt_epsUpper j).le

theorem rawNextMeasure_finite
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) {creationMass : ENNReal} (hCreationFinite : creationMass ≠ ⊤) :
    IsFiniteMeasure (N.rawNextMeasure D DP j creationMass) := by
  refine ⟨?_⟩
  rw [rawNextMeasure]
  simp only [Measure.add_apply,
    upperCreationMeasure_apply_univ]
  exact ENNReal.add_lt_top.2 ⟨
    (N.incumbentNextMeasure_finite D DP j).measure_univ_lt_top,
    lt_top_iff_ne_top.mpr hCreationFinite⟩

/-- Package the raw transition as a next-state distribution only under the
explicit supplied total-mass bound. -/
noncomputable def toNextDistribution
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (hCreationFinite : creationMass ≠ ⊤)
    (hMassLeOne : N.rawNextMeasure D DP j creationMass univ ≤ 1) :
    FiniteMarkovEmploymentDistribution P E j where
  measure := N.rawNextMeasure D DP j creationMass
  finite_measure := N.rawNextMeasure_finite D DP j hCreationFinite
  mass_le_one := hMassLeOne
  supported_above_cutoff := by
    have hSupport := N.rawNextMeasure_supported D DP j creationMass
    rw [ae_iff] at hSupport
    apply measure_mono_null
      (t := {x | x ∉ Icc (E.cutoff j) P.epsUpper})
    · intro x hx hmem
      exact (not_lt_of_ge hmem.1) hx
    · exact hSupport
  supported_below_upper := by
    have hSupport := N.rawNextMeasure_supported D DP j creationMass
    rw [ae_iff] at hSupport
    apply measure_mono_null
      (t := {x | x ∉ Icc (E.cutoff j) P.epsUpper})
    · intro x hx hmem
      exact (not_lt_of_ge hmem.2) hx
    · exact hSupport

@[simp] theorem toNextDistribution_measure
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal)
    (hCreationFinite : creationMass ≠ ⊤)
    (hMassLeOne : N.rawNextMeasure D DP j creationMass univ ≤ 1) :
    (N.toNextDistribution D DP j creationMass hCreationFinite hMassLeOne).measure =
      N.rawNextMeasure D DP j creationMass := rfl

end FiniteMarkovEmploymentDistribution
end MP1994V2
