import Aiyagari1994.Primitives.Basic
import Mathlib.MeasureTheory.Measure.Support
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal NNReal Topology
namespace Aiyagari1994

abbrev WitnessLabor := Labor (1/2 : ℝ) (3/2 : ℝ)
noncomputable def witnessLow : WitnessLabor := ⟨1/2, by norm_num⟩
noncomputable def witnessHigh : WitnessLabor := ⟨3/2, by norm_num⟩
noncomputable def witnessMeasure : Measure WitnessLabor :=
  (1/2 : ℝ≥0∞) • Measure.dirac witnessLow + (1/2 : ℝ≥0∞) • Measure.dirac witnessHigh

instance witness_measure_probability : IsProbabilityMeasure witnessMeasure := by
  constructor
  simp only [witnessMeasure, Measure.add_apply, Measure.smul_apply, Measure.dirac_apply_of_mem (Set.mem_univ _), smul_eq_mul, mul_one]
  exact ENNReal.add_halves 1

noncomputable def witnessIncome : IncomeData where
  lower := 1/2
  upper := 3/2
  law := ⟨witnessMeasure, inferInstance⟩

theorem witness_low_mass : witnessMeasure {witnessLow} = 1/2 := by
  norm_num [witnessMeasure, Measure.add_apply, Measure.smul_apply, witnessLow, witnessHigh]

theorem witness_high_mass : witnessMeasure {witnessHigh} = 1/2 := by
  norm_num [witnessMeasure, Measure.add_apply, Measure.smul_apply, witnessLow, witnessHigh]

theorem witness_only_endpoints : witnessMeasure ({witnessLow, witnessHigh} : Set WitnessLabor)ᶜ = 0 := by
  simp [witnessMeasure, Measure.add_apply, Measure.smul_apply]

/-- Exact topological support, in addition to the explicit two-atom measure formula. -/
theorem witness_support_exact : witnessMeasure.support = {witnessLow, witnessHigh} := by
  apply Set.Subset.antisymm
  · apply Measure.support_subset_of_isClosed (isClosed_singleton.union isClosed_singleton)
    exact witness_only_endpoints
  · intro x hx
    rw [Measure.mem_support_iff_forall]
    intro U hU
    have hxU : x ∈ U := mem_of_mem_nhds hU
    have hsub : {x} ⊆ U := singleton_subset_iff.mpr hxU
    have hpos : 0 < witnessMeasure {x} := by
      rcases hx with rfl | hx
      · rw [witness_low_mass]; norm_num
      · have hx' : x = witnessHigh := hx
        subst x
        rw [witness_high_mass]; norm_num
    exact lt_of_lt_of_le hpos (measure_mono hsub)

theorem witness_income_support : IncomeSupport witnessIncome := ⟨by norm_num [witnessIncome], by norm_num [witnessIncome]⟩

theorem witness_income_nondegenerate : IncomeNondegenerate witnessIncome where
  endpoints_distinct := by norm_num [witnessIncome]
  lower_mass := by
    intro ε hε
    change 0 < witnessMeasure {l : WitnessLabor | (l : ℝ) < 1/2+ε}
    have hsub : {witnessLow} ⊆ {l : WitnessLabor | (l : ℝ) < 1/2+ε} := by
      intro l hl
      simp only [mem_singleton_iff] at hl
      subst l
      change (1/2 : ℝ) < 1/2+ε
      linarith
    exact lt_of_lt_of_le (by rw [witness_low_mass]; norm_num) (measure_mono hsub)
  upper_mass := by
    intro ε hε
    change 0 < witnessMeasure {l : WitnessLabor | 3/2-ε < (l : ℝ)}
    have hsub : {witnessHigh} ⊆ {l : WitnessLabor | 3/2-ε < (l : ℝ)} := by
      intro l hl
      simp only [mem_singleton_iff] at hl
      subst l
      change (3/2 : ℝ)-ε < 3/2
      linarith
    exact lt_of_lt_of_le (by rw [witness_high_mass]; norm_num) (measure_mono hsub)

theorem witness_labor_mean :
    ∫ l : WitnessLabor, (l : ℝ) ∂witnessMeasure = 1 := by
  have hlo : Integrable (fun l : WitnessLabor => (l : ℝ)) (Measure.dirac witnessLow) :=
    integrable_dirac (by simp)
  have hhi : Integrable (fun l : WitnessLabor => (l : ℝ)) (Measure.dirac witnessHigh) :=
    integrable_dirac (by simp)
  unfold witnessMeasure
  rw [integral_add_measure (hlo.smul_measure (by norm_num)) (hhi.smul_measure (by norm_num))]
  norm_num [integral_smul_measure, witnessLow, witnessHigh]

theorem witness_mean_one : LaborMeanOne witnessIncome := ⟨witness_labor_mean⟩

end Aiyagari1994
