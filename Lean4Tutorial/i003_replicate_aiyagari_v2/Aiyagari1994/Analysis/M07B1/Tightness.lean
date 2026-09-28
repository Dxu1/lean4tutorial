import Mathlib.MeasureTheory.Measure.Tight
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.Probability.Moments.Variance

/-! Tightness and union-bound estimates requiring no moments of the state law. -/
open MeasureTheory ProbabilityTheory Filter Set
open scoped ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994.M07B1
noncomputable section

/-- Every probability law on nonnegative reals has arbitrarily small upper tails. -/
theorem probability_nnreal_tail_le (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (eps : ℝ≥0∞) (heps : 0 < eps) :
    ∃ K : ℝ≥0, pi (Ioi K) ≤ eps := by
  have ht : IsTightMeasureSet ({pi} : Set (Measure ℝ≥0)) :=
    isTightMeasureSet_singleton
  rw [isTightMeasureSet_iff_exists_isCompact_measure_compl_le] at ht
  obtain ⟨S, hScompact, hStail⟩ := ht eps heps
  obtain ⟨K, hK⟩ := hScompact.bddAbove
  refine ⟨K, (measure_mono ?_).trans (hStail pi (by simp))⟩
  intro z hz hzS
  exact (not_lt_of_ge (hK hzS)) hz

/-- If a scaled difference is large, one of two nonnegative states with a common marginal
law must lie in the corresponding upper tail.  This is the union-bound step. -/
theorem scaled_difference_event_le_two_tails
    {Ω : Type*} [MeasurableSpace Ω] (mu : Measure Ω) [IsProbabilityMeasure mu]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (Z Z' : Ω → ℝ≥0) (hZ : Measurable Z) (hZ' : Measurable Z')
    (hlawZ : Measure.map Z mu = pi) (hlawZ' : Measure.map Z' mu = pi)
    (D : Ω → ℝ) (q : ℝ) (hq : 0 ≤ q) (n : ℕ)
    (hidentity : ∀ᵐ ω ∂mu, D ω = q ^ n * ((Z ω : ℝ) - (Z' ω : ℝ)))
    (a : ℝ) (K : ℝ≥0) (hscale : q ^ n * (2 * (K : ℝ)) ≤ a) :
    mu {ω | a < |D ω|} ≤ 2 * pi (Ioi K) := by
  have hsubset : ∀ᵐ ω ∂mu,
      ω ∈ {ω | a < |D ω|} → ω ∈ {ω | K < Z ω} ∪ {ω | K < Z' ω} := by
    filter_upwards [hidentity] with ω hid hlarge
    by_contra hout
    simp only [mem_union, mem_setOf_eq, not_or] at hout
    have hzK : (Z ω : ℝ) ≤ (K : ℝ) := by exact_mod_cast le_of_not_gt hout.1
    have hzK' : (Z' ω : ℝ) ≤ (K : ℝ) := by exact_mod_cast le_of_not_gt hout.2
    have hz0 : 0 ≤ (Z ω : ℝ) := NNReal.zero_le_coe
    have hz0' : 0 ≤ (Z' ω : ℝ) := NNReal.zero_le_coe
    have habs : |(Z ω : ℝ) - (Z' ω : ℝ)| ≤ 2 * (K : ℝ) := by
      rw [abs_le]
      constructor <;> nlinarith
    have hqn : 0 ≤ q ^ n := pow_nonneg hq n
    have : |D ω| ≤ a := by
      rw [hid, abs_mul, abs_of_nonneg hqn]
      exact (mul_le_mul_of_nonneg_left habs hqn).trans hscale
    exact (not_lt_of_ge this) hlarge
  calc
    mu {ω | a < |D ω|} ≤ mu ({ω | K < Z ω} ∪ {ω | K < Z' ω}) :=
      measure_mono_ae hsubset
    _ ≤ mu {ω | K < Z ω} + mu {ω | K < Z' ω} := measure_union_le _ _
    _ = pi (Ioi K) + pi (Ioi K) := by
      have hfirst : mu {ω | K < Z ω} = pi (Ioi K) := by
        rw [← hlawZ, Measure.map_apply hZ measurableSet_Ioi]
        rfl
      have hsecond : mu {ω | K < Z' ω} = pi (Ioi K) := by
        rw [← hlawZ', Measure.map_apply hZ' measurableSet_Ioi]
        rfl
      rw [hfirst, hsecond]
    _ = 2 * pi (Ioi K) := by ring

/-- Uniform boundedness plus a small large-deviation event bounds the second moment. -/
theorem secondMoment_le_of_uniform_bound
    {Ω : Type*} [MeasurableSpace Ω] (mu : Measure Ω) [IsProbabilityMeasure mu]
    (D : Ω → ℝ) (hD : Measurable D) (C a : ℝ)
    (hC : 0 ≤ C) (ha : 0 ≤ a) (hbound : ∀ ω, |D ω| ≤ C) :
    ∫ ω, (D ω) ^ 2 ∂mu ≤
      a ^ 2 + C ^ 2 * (mu {ω | a < |D ω|}).toReal := by
  let s : Set Ω := {ω | a < |D ω|}
  have hs : MeasurableSet s := by
    exact measurableSet_lt measurable_const (by simpa only [Real.norm_eq_abs] using hD.norm)
  have hpoint : ∀ ω, (D ω) ^ 2 ≤ a ^ 2 + C ^ 2 * s.indicator (fun _ ↦ (1 : ℝ)) ω := by
    intro ω
    by_cases hω : ω ∈ s
    · have hsq : (D ω) ^ 2 ≤ C ^ 2 :=
        (sq_le_sq).2 (by simpa [abs_of_nonneg hC] using hbound ω)
      simp [Set.indicator_of_mem hω]
      nlinarith [sq_nonneg a]
    · have hsmall : |D ω| ≤ a := le_of_not_gt hω
      have hsq : (D ω) ^ 2 ≤ a ^ 2 :=
        (sq_le_sq).2 (by simpa [abs_of_nonneg ha] using hsmall)
      simp [Set.indicator_of_notMem hω]
      exact hsq
  have hDsq : Integrable (fun ω ↦ (D ω) ^ 2) mu := by
    have hmem : MemLp D 2 mu := MemLp.of_bound hD.aestronglyMeasurable C
      (Filter.Eventually.of_forall hbound)
    exact hmem.integrable_sq
  have hrhs : Integrable (fun ω ↦
      a ^ 2 + C ^ 2 * s.indicator (fun _ ↦ (1 : ℝ)) ω) mu := by
    fun_prop
  calc
    ∫ ω, (D ω) ^ 2 ∂mu ≤
        ∫ ω, (a ^ 2 + C ^ 2 * s.indicator (fun _ ↦ (1 : ℝ)) ω) ∂mu :=
      integral_mono hDsq hrhs hpoint
    _ = a ^ 2 + C ^ 2 * (mu s).toReal := by
      rw [integral_add, integral_const, integral_const_mul]
      · simp [Measure.real, hs, s]
      · fun_prop
      · fun_prop

end
end Aiyagari1994.M07B1
