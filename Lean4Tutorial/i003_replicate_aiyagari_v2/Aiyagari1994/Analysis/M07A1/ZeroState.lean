import Aiyagari1994.Household.MarginalInequality
import Aiyagari1994.Stationary.Kernel
import Mathlib.Probability.Kernel.Composition.MeasureComp

/-! Analytic helpers for gate M07A1. -/
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal NNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

namespace M07A1

/-- Labor realizations producing zero effective income. -/
private def zeroIncomeSet (m : HouseholdPrimitives) : Set m.income.Labor :=
  {l | m.prices.effectiveIncome l = 0}

private theorem zeroIncomeSet_measurable (m : HouseholdPrimitives) :
    MeasurableSet (zeroIncomeSet m) := by
  unfold zeroIncomeSet NormalizedPrices.effectiveIncome
  exact measurableSet_eq_fun
    ((measurable_const.mul measurable_subtype_coe).add measurable_const) measurable_const

/-- Endpoint nondegeneracy and a strictly positive wage leave positive probability away from
zero effective income. -/
private theorem zeroIncome_probability_lt_one (m : HouseholdPrimitives)
    (hnd : IncomeNondegenerate m.income) :
    (m.income.law : Measure m.income.Labor) (zeroIncomeSet m) < 1 := by
  let eps : ℝ := (m.income.upper - m.income.lower) / 2
  have heps : 0 < eps := div_pos (sub_pos.mpr hnd.endpoints_distinct) (by norm_num)
  let U : Set m.income.Labor := {l | m.income.upper - eps < (l : ℝ)}
  have hUpos : 0 < (m.income.law : Measure m.income.Labor) U := hnd.upper_mass eps heps
  have hUsub : U ⊆ (zeroIncomeSet m)ᶜ := by
    intro l hl
    have hlower : m.income.lower < (l : ℝ) := by
      have : m.income.lower < m.income.upper - eps := by
        dsimp [eps]
        linarith [hnd.endpoints_distinct]
      exact this.trans hl
    have helower : 0 ≤ m.prices.effectiveIncome
        (⟨m.income.lower, le_rfl, hnd.endpoints_distinct.le⟩ : m.income.Labor) :=
      m.prices.income_nonneg _
    have hepos : 0 < m.prices.effectiveIncome l := by
      unfold NormalizedPrices.effectiveIncome at helower ⊢
      nlinarith [m.prices.wage_pos]
    exact by simpa [zeroIncomeSet] using hepos.ne'
  have hcompl : 0 < (m.income.law : Measure m.income.Labor) (zeroIncomeSet m)ᶜ :=
    hUpos.trans_le (measure_mono hUsub)
  have hne : (m.income.law : Measure m.income.Labor) (zeroIncomeSet m) ≠ 1 := by
    intro hEq
    have : (m.income.law : Measure m.income.Labor) (zeroIncomeSet m)ᶜ = 0 :=
      (prob_compl_eq_zero_iff (zeroIncomeSet_measurable m)).2 hEq
    exact (ne_of_gt hcompl) this
  exact lt_of_le_of_ne prob_le_one hne

/-- With an infinite boundary marginal and a positive zero-income atom, a positive state cannot
optimally choose zero shifted saving.  H09 supplies the conditional finiteness contradiction. -/
private theorem assetPolicy_pos_of_zeroIncome_probability_pos (m : HouseholdPrimitives)
    (hq0 : zeroRightMarginal m = ⊤)
    (hp0 : 0 < (m.income.law : Measure m.income.Labor) (zeroIncomeSet m))
    {z : Resources} (hz : 0 < z) :
    0 < assetPolicy m z := by
  by_contra hnot
  have ha0 : assetPolicy m z = 0 := nonpos_iff_eq_zero.mp (le_of_not_gt hnot)
  have hzfinite : extendedRightMarginalValue m z < ⊤ := by
    rw [extendedRightMarginalValue_of_pos m hz]
    exact ENNReal.ofReal_lt_top
  have hae := (rightMarginalValue_superharmonic m z hzfinite).1
  have hcomp : ∀ᵐ l ∂(m.income.law : Measure m.income.Labor), l ∈ (zeroIncomeSet m)ᶜ := by
    filter_upwards [hae] with l hl
    intro hlzero
    have hnext : m.prices.nextResources (assetPolicy m z) l = 0 := by
      apply Subtype.ext
      change m.prices.grossReturn * (assetPolicy m z : ℝ) +
        m.prices.effectiveIncome l = 0
      simp [ha0, zeroIncomeSet] at hlzero ⊢
      exact hlzero
    rw [hnext, extendedRightMarginalValue_zero, hq0] at hl
    exact (not_lt_of_ge le_rfl) hl
  have hp0zero : (m.income.law : Measure m.income.Labor) (zeroIncomeSet m) = 0 := by
    rw [← compl_compl (zeroIncomeSet m), ← mem_ae_iff]
    exact hcomp
  exact (ne_of_gt hp0) hp0zero

private theorem householdKernel_zero_apply (m : HouseholdPrimitives) (z : Resources) :
    householdKernel m z {0} =
      (m.income.law : Measure m.income.Labor)
        {l | m.prices.nextResources (assetPolicy m z) l = 0} := by
  rw [householdKernel, Kernel.map_apply' _ (householdTransition_continuous m).measurable _
    (measurableSet_singleton 0),
    Kernel.id_prod_apply' _ _
      ((householdTransition_continuous m).measurable (measurableSet_singleton 0))]
  rw [Kernel.const_apply]
  congr 1

/-- At zero current resources the probability of returning to zero is exactly the zero-income
probability. -/
private theorem householdKernel_zero_at_zero (m : HouseholdPrimitives) :
    householdKernel m 0 {0} =
      (m.income.law : Measure m.income.Labor) (zeroIncomeSet m) := by
  rw [householdKernel_zero_apply]
  congr 1
  ext l
  simp only [mem_setOf_eq, assetPolicy_zero]
  constructor
  · intro h
    have hz : (m.prices.nextResources 0 l : ℝ) = 0 := congrArg Subtype.val h
    change m.prices.grossReturn * (0 : ℝ) + m.prices.effectiveIncome l = 0 at hz
    change m.prices.effectiveIncome l = 0
    simpa using hz
  · intro h
    apply Subtype.ext
    change m.prices.grossReturn * (0 : ℝ) + m.prices.effectiveIncome l = 0
    change m.prices.effectiveIncome l = 0 at h
    simpa using h

/-- Positive shifted saving makes zero next resources impossible because gross returns are
strictly positive and effective income is nonnegative. -/
private theorem householdKernel_zero_of_assetPolicy_pos (m : HouseholdPrimitives) {z : Resources}
    (ha : 0 < assetPolicy m z) : householdKernel m z {0} = 0 := by
  rw [householdKernel_zero_apply]
  have hempty : {l | m.prices.nextResources (assetPolicy m z) l = 0} = ∅ := by
    ext l
    simp only [mem_setOf_eq, mem_empty_iff_false, iff_false]
    intro h
    have hz := congrArg Subtype.val h
    change m.prices.grossReturn * (assetPolicy m z : ℝ) +
      m.prices.effectiveIncome l = 0 at hz
    have : 0 < m.prices.grossReturn * (assetPolicy m z : ℝ) +
        m.prices.effectiveIncome l :=
      add_pos_of_pos_of_nonneg
        (mul_pos m.prices.grossReturn_pos (by exact_mod_cast ha))
        (m.prices.income_nonneg l)
    linarith
  rw [hempty, measure_empty]

/-- Reaching zero always requires zero effective income. -/
private theorem householdKernel_zero_le_zeroIncome (m : HouseholdPrimitives) (z : Resources) :
    householdKernel m z {0} ≤
      (m.income.law : Measure m.income.Labor) (zeroIncomeSet m) := by
  rw [householdKernel_zero_apply]
  apply measure_mono
  intro l hl
  change m.prices.nextResources (assetPolicy m z) l = 0 at hl
  have hval := congrArg Subtype.val hl
  change m.prices.grossReturn * (assetPolicy m z : ℝ) +
    m.prices.effectiveIncome l = 0 at hval
  have ha : 0 ≤ m.prices.grossReturn * (assetPolicy m z : ℝ) :=
    mul_nonneg m.prices.grossReturn_pos.le (assetPolicy m z).property
  have he : 0 ≤ m.prices.effectiveIncome l := m.prices.income_nonneg l
  change m.prices.effectiveIncome l = 0
  linarith

/-- If the boundary marginal is infinite, invariance and endpoint nondegeneracy force the zero
resource state to be null.  The proof covers zero-income atom and no-atom cases separately. -/
theorem invariant_zero_measure_of_boundary_infinite (m : HouseholdPrimitives)
    (hnd : IncomeNondegenerate m.income) (pi : ProbabilityMeasure Resources)
    (hinv : householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources))
    (hq0 : zeroRightMarginal m = ⊤) :
    (pi : Measure Resources) {0} = 0 := by
  let p0 := (m.income.law : Measure m.income.Labor) (zeroIncomeSet m)
  have hp0lt : p0 < 1 := zeroIncome_probability_lt_one m hnd
  have hinv0 := congrArg (fun mu : Measure Resources => mu {0}) hinv
  rw [Measure.bind_apply (measurableSet_singleton 0) (Kernel.aemeasurable _)] at hinv0
  by_cases hp0zero : p0 = 0
  · have hkernel : ∀ z : Resources, householdKernel m z {0} = 0 := by
      intro z
      exact nonpos_iff_eq_zero.mp
        ((householdKernel_zero_le_zeroIncome m z).trans_eq hp0zero)
    simp_rw [hkernel, lintegral_zero] at hinv0
    exact hinv0.symm
  · have hp0pos : 0 < p0 := bot_lt_iff_ne_bot.mpr hp0zero
    have hkernel : ∀ z : Resources,
        householdKernel m z {0} = Set.indicator ({0} : Set Resources) (fun _ => p0) z := by
      intro z
      by_cases hz : z = 0
      · subst z
        simp [householdKernel_zero_at_zero, p0]
      · have hzpos : 0 < z := pos_iff_ne_zero.mpr hz
        have ha := assetPolicy_pos_of_zeroIncome_probability_pos m hq0 hp0pos hzpos
        rw [householdKernel_zero_of_assetPolicy_pos m ha]
        simp [hz]
    simp_rw [hkernel] at hinv0
    rw [lintegral_indicator (measurableSet_singleton 0)] at hinv0
    simp only [lintegral_const] at hinv0
    have hpi0le : (pi : Measure Resources) {0} ≤ 1 := prob_le_one
    have hp0finite : p0 ≠ ⊤ := ne_of_lt (hp0lt.trans ENNReal.one_lt_top)
    have hpi0finite : (pi : Measure Resources) {0} ≠ ⊤ :=
      ne_of_lt (hpi0le.trans_lt ENNReal.one_lt_top)
    have hfactor : p0 * (pi : Measure Resources) {0} = (pi : Measure Resources) {0} := by
      simpa [mul_comm] using hinv0
    by_contra hpi0ne
    have hcancel := ENNReal.mul_lt_mul_left hpi0ne hpi0finite hp0lt
    rw [hfactor, one_mul] at hcancel
    exact (lt_irrefl _) hcancel

/-- The economic extended marginal is strictly positive at every resource state. -/
theorem extendedRightMarginalValue_pos (m : HouseholdPrimitives) (z : Resources) :
    0 < extendedRightMarginalValue m z := by
  by_cases hz : z = 0
  · subst z
    simpa using zeroRightMarginal_pos m
  · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr hz)]
    exact ENNReal.ofReal_pos.mpr
      (rightMarginalValue_pos m (by exact_mod_cast pos_iff_ne_zero.mpr hz))

/-- Under an invariant candidate law the extended marginal is finite almost everywhere.  No
stationary marginal moment is asserted. -/
theorem invariant_extendedMarginal_finite_ae (m : HouseholdPrimitives)
    (hnd : IncomeNondegenerate m.income) (pi : ProbabilityMeasure Resources)
    (hinv : householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources)) :
    ∀ᵐ z ∂(pi : Measure Resources), extendedRightMarginalValue m z < ⊤ := by
  by_cases hq0 : zeroRightMarginal m = ⊤
  · have hpi0 := invariant_zero_measure_of_boundary_infinite m hnd pi hinv hq0
    have hne : ∀ᵐ z ∂(pi : Measure Resources), z ∈ ({0} : Set Resources)ᶜ := by
      apply ae_iff.mpr
      simpa using hpi0
    filter_upwards [hne] with z hz
    rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr (by simpa using hz))]
    exact ENNReal.ofReal_lt_top
  · filter_upwards [] with z
    by_cases hz : z = 0
    · subst z
      simpa [extendedRightMarginalValue_zero] using (lt_top_iff_ne_top.mpr hq0)
    · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr hz)]
      exact ENNReal.ofReal_lt_top

end M07A1

end
end Aiyagari1994
