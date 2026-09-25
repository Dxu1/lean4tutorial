import Aiyagari1994.Household.UpperDrift
import Aiyagari1994.Stationary.Crossing

/-! Specialization of D03 to one strictly impatient household. -/
open Set
open scoped NNReal
namespace Aiyagari1994
noncomputable section

private def M05E.currentPrices (m : HouseholdPrimitives) :
    AdmissibleNormalizedPrices m.income :=
  ⟨((m.prices.grossReturn, m.prices.wage), m.prices.intercept),
    ⟨⟨m.prices.grossReturn_pos, m.prices.wage_pos⟩, m.prices.income_nonneg⟩⟩

private theorem M05E.withPrices_current (m : HouseholdPrimitives) :
    m.withPrices (M05E.currentPrices m) = m := by
  cases m
  rfl

private theorem M05E.current_income_lower (m : HouseholdPrimitives) :
    M04CIncomeLower m (M05E.currentPrices m) = (lowerEffectiveIncome m : ℝ) := rfl

private theorem M05E.current_income_upper (m : HouseholdPrimitives) :
    M04CIncomeUpper m (M05E.currentPrices m) = (upperEffectiveIncome m : ℝ) := rfl

/-- D03 specialized to the singleton containing the household's actual price vector. -/
theorem M05E.exists_invariant_upper (m : HouseholdPrimitives)
    (hs : UtilitySmooth m.utility) (hc : UtilityCurvature m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ∃ B : Resources, upperEffectiveIncome m ≤ B ∧
      (∀ z : Resources, B ≤ z →
        m.prices.nextResources (assetPolicy m z)
          ⟨m.income.upper, m.income_support.ordered, le_rfl⟩ ≤ z) ∧
      (∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ B →
        ∀ l : m.income.Labor,
          lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
            m.prices.nextResources (assetPolicy m z) l ≤ B) := by
  let q := M05E.currentPrices m
  let gamma : ℝ := (m.beta * m.prices.grossReturn + 1) / 2
  let eMax : ℝ := M04CIncomeUpper m q
  let span : ℝ := M04CIncomeUpper m q - M04CIncomeLower m q
  have hgamma : gamma < 1 := by dsimp [gamma]; linarith
  have heMax : 0 ≤ eMax := by
    dsimp [eMax, q, M05E.currentPrices, M04CIncomeUpper]
    exact m.prices.income_nonneg
      ⟨m.income.upper, m.income_support.ordered, le_rfl⟩
  have hspan : 0 ≤ span := by
    change 0 ≤ m.prices.wage * m.income.upper + m.prices.intercept -
      (m.prices.wage * m.income.lower + m.prices.intercept)
    nlinarith [mul_nonneg m.prices.wage_pos.le
      (sub_nonneg.mpr m.income_support.ordered)]
  have hq : ∀ q' ∈ ({q} : Set (AdmissibleNormalizedPrices m.income)),
      m.prices.grossReturn ≤ q'.grossReturn ∧
      q'.grossReturn ≤ m.prices.grossReturn ∧
      m.beta * q'.grossReturn ≤ gamma ∧
      M04CIncomeUpper m q' ≤ eMax ∧
      M04CIncomeUpper m q' - M04CIncomeLower m q' ≤ span := by
    intro q' hq'
    simp only [Set.mem_singleton_iff] at hq'
    subst q'
    refine ⟨le_rfl, le_rfl, ?_, le_rfl, le_rfl⟩
    change m.beta * m.prices.grossReturn ≤
      (m.beta * m.prices.grossReturn + 1) / 2
    linarith
  obtain ⟨B, hBpos, hB⟩ := uniform_upper_drift m hs hc ({q} : Set _)
    m.prices.grossReturn m.prices.grossReturn gamma eMax span
    m.prices.grossReturn_pos m.prices.grossReturn_pos hgamma heMax hspan hq
  have hqmem : q ∈ ({q} : Set (AdmissibleNormalizedPrices m.income)) := Set.mem_singleton q
  rcases hB q hqmem with ⟨hIncome, hDrift, hInv⟩
  let b : Resources := ⟨B, hBpos.le⟩
  refine ⟨b, ?_, ?_, ?_⟩
  · exact_mod_cast (M05E.current_income_upper m).symm ▸ hIncome
  · intro z hz
    have hz' : B ≤ (z : ℝ) := by exact_mod_cast hz
    have hd := hDrift z hz'
    rw [M05E.current_income_upper] at hd
    rw [M05E.withPrices_current] at hd
    exact_mod_cast hd
  · intro z hzLower hzUpper l
    have hzLower' : M04CIncomeLower m q ≤ (z : ℝ) := by
      rw [M05E.current_income_lower]
      exact_mod_cast hzLower
    have hzUpper' : (z : ℝ) ≤ B := by exact_mod_cast hzUpper
    have hi := hInv z hzLower' hzUpper' l
    rw [M05E.current_income_lower] at hi
    rw [M05E.withPrices_current] at hi
    exact_mod_cast hi

end
end Aiyagari1994
