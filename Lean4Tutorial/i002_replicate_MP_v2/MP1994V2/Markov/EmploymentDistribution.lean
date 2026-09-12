import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.DiscreteEmploymentPrimitives

/-!
# MP1994 v2: finite-state employment distributions

This measure-valued object has no density field. It records only finite mass,
a unit-labor-force bound, and support between the current cutoff and the upper
shock bound.
-/

open MeasureTheory Set

namespace MP1994V2

/-- Employment in aggregate state `i`, conditional on a supplied finite-state
equilibrium. Jobs exactly at the zero-surplus cutoff may be retained. -/
structure FiniteMarkovEmploymentDistribution
    (P : Primitives) {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι}
    (E : FiniteMarkovEquilibrium P K) (i : ι) where
  measure : Measure ℝ
  finite_measure : IsFiniteMeasure measure
  mass_le_one : measure univ ≤ 1
  supported_above_cutoff : measure (Iio (E.cutoff i)) = 0
  supported_below_upper : measure (Ioi P.epsUpper) = 0

namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Real-valued employment mass. -/
noncomputable def employmentMass
    (N : FiniteMarkovEmploymentDistribution P E i) : ℝ :=
  (N.measure univ).toReal

/-- Real-valued unemployment mass under a unit labor force. -/
noncomputable def unemploymentMass
    (N : FiniteMarkovEmploymentDistribution P E i) : ℝ :=
  1 - N.employmentMass

theorem employmentMass_nonneg
    (N : FiniteMarkovEmploymentDistribution P E i) :
    0 ≤ N.employmentMass := ENNReal.toReal_nonneg

theorem employmentMass_le_one
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.employmentMass ≤ 1 := by
  unfold employmentMass
  simpa using ENNReal.toReal_mono (by simp : (1 : ENNReal) ≠ ⊤) N.mass_le_one

theorem unemploymentMass_nonneg
    (N : FiniteMarkovEmploymentDistribution P E i) :
    0 ≤ N.unemploymentMass := by
  unfold unemploymentMass
  linarith [N.employmentMass_le_one]

theorem employmentMass_add_unemploymentMass
    (N : FiniteMarkovEmploymentDistribution P E i) :
    N.employmentMass + N.unemploymentMass = 1 := by
  unfold unemploymentMass
  ring

/-- Almost every employed match lies in the current closed survival interval. -/
theorem ae_mem_cutoff_upperInterval
    (N : FiniteMarkovEmploymentDistribution P E i) :
    ∀ᵐ x ∂N.measure, x ∈ Icc (E.cutoff i) P.epsUpper := by
  have hLower : ∀ᵐ x ∂N.measure, x ∈ Ici (E.cutoff i) := by
    rw [ae_iff]
    rw [show {x | x ∉ Ici (E.cutoff i)} = Iio (E.cutoff i) by
      ext x
      simp]
    exact N.supported_above_cutoff
  have hUpper : ∀ᵐ x ∂N.measure, x ∈ Iic P.epsUpper := by
    rw [ae_iff]
    rw [show {x | x ∉ Iic P.epsUpper} = Ioi P.epsUpper by
      ext x
      simp]
    exact N.supported_below_upper
  filter_upwards [hLower, hUpper] with x hxLower hxUpper
  exact ⟨hxLower, hxUpper⟩

end FiniteMarkovEmploymentDistribution
end MP1994V2
