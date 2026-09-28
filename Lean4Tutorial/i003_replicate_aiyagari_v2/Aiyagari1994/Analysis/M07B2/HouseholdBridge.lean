import Aiyagari1994.Analysis.TwoShockStrings
import Aiyagari1994.Stationary.CriticalConsumption

/-! Household-to-generic bridges for gate M07B2. -/
open MeasureTheory ProbabilityTheory Filter Set
open scoped ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994.M07B2
noncomputable section

/-- Essential endpoint mass rules out an almost-everywhere constant labor realization. -/
theorem labor_not_ae_const (i : IncomeData) (hnd : IncomeNondegenerate i) :
    ¬ ∃ a : ℝ, (fun l : i.Labor ↦ (l : ℝ)) =ᵐ[(i.law : Measure i.Labor)] fun _ ↦ a := by
  rintro ⟨a, ha⟩
  let eps : ℝ := (i.upper - i.lower) / 3
  have heps : 0 < eps := div_pos (sub_pos.mpr hnd.endpoints_distinct) (by norm_num)
  have halow : a < i.lower + eps := by
    by_contra hnot
    have hae : ∀ᵐ l ∂(i.law : Measure i.Labor),
        l ∈ ({l : i.Labor | (l : ℝ) < i.lower + eps} : Set i.Labor)ᶜ := by
      filter_upwards [ha] with l hl
      simp only [mem_compl_iff, mem_setOf_eq]
      rw [hl]
      exact hnot
    have hzero : (i.law : Measure i.Labor)
        {l : i.Labor | (l : ℝ) < i.lower + eps} = 0 := by
      rw [← compl_compl ({l : i.Labor | (l : ℝ) < i.lower + eps} : Set i.Labor),
        ← mem_ae_iff]
      exact hae
    exact (ne_of_gt (hnd.lower_mass eps heps)) hzero
  have hahigh : i.upper - eps < a := by
    by_contra hnot
    have hae : ∀ᵐ l ∂(i.law : Measure i.Labor),
        l ∈ ({l : i.Labor | i.upper - eps < (l : ℝ)} : Set i.Labor)ᶜ := by
      filter_upwards [ha] with l hl
      simp only [mem_compl_iff, mem_setOf_eq]
      rw [hl]
      exact hnot
    have hzero : (i.law : Measure i.Labor)
        {l : i.Labor | i.upper - eps < (l : ℝ)} = 0 := by
      rw [← compl_compl ({l : i.Labor | i.upper - eps < (l : ℝ)} : Set i.Labor),
        ← mem_ae_iff]
      exact hae
    exact (ne_of_gt (hnd.upper_mass eps heps)) hzero
  dsimp [eps] at halow hahigh
  linarith [hnd.endpoints_distinct]

/-- A positive affine wage maps endpoint-nondegenerate labor into a nonconstant effective-income
shock. -/
theorem effectiveIncome_not_ae_const (m : HouseholdPrimitives)
    (hnd : IncomeNondegenerate m.income) :
    ¬ ∃ a : ℝ, m.prices.effectiveIncome =ᵐ[(m.income.law : Measure m.income.Labor)]
      fun _ ↦ a := by
  rintro ⟨a, ha⟩
  apply labor_not_ae_const m.income hnd
  refine ⟨(a - m.prices.intercept) / m.prices.wage, ?_⟩
  filter_upwards [ha] with l hl
  unfold NormalizedPrices.effectiveIncome at hl
  field_simp [ne_of_gt m.prices.wage_pos]
  linarith

/-- Effective income is pointwise bounded on the compact labor interval. -/
theorem effectiveIncome_abs_bounded (m : HouseholdPrimitives) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ l, |m.prices.effectiveIncome l| ≤ B := by
  let elo : ℝ := m.prices.wage * m.income.lower + m.prices.intercept
  let ehi : ℝ := m.prices.wage * m.income.upper + m.prices.intercept
  refine ⟨|elo| + |ehi|, add_nonneg (abs_nonneg _) (abs_nonneg _), ?_⟩
  intro l
  have hlo : elo ≤ m.prices.effectiveIncome l := by
    dsimp [elo, NormalizedPrices.effectiveIncome]
    nlinarith [m.prices.wage_pos, l.property.1]
  have hhi : m.prices.effectiveIncome l ≤ ehi := by
    dsimp [ehi, NormalizedPrices.effectiveIncome]
    nlinarith [m.prices.wage_pos, l.property.2]
  apply abs_le.2
  constructor
  · nlinarith [neg_le_abs elo, abs_nonneg ehi]
  · nlinarith [le_abs_self ehi, abs_nonneg elo]

/-- The generic N05 resource kernel instantiated with the canonical transition is exactly the
household kernel. -/
theorem resourceKernel_canonical_eq (m : HouseholdPrimitives) :
    M07B1.resourceKernel (m.income.law : Measure m.income.Labor)
      (fun z l ↦ m.prices.nextResources (assetPolicy m z) l)
      (householdTransition_continuous m).measurable = householdKernel m := by
  rfl

end
end Aiyagari1994.M07B2
