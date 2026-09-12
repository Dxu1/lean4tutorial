import Aiyagari1994.Primitives.UtilityExample
import Aiyagari1994.Primitives.IncomeExample
import Aiyagari1994.Budget.EffectiveLimit
namespace Aiyagari1994

noncomputable def witnessOriginalPrices : OriginalPrices witnessIncome :=
  finiteCapPrices witnessIncome witness_income_support 0 1 0 (by norm_num) (by norm_num) (by norm_num)

noncomputable def witnessModel : HouseholdPrimitives where
  beta := 1/2
  beta_pos := by norm_num
  beta_lt_one := by norm_num
  utility := witnessUtility
  utility_base := witness_utility_base
  income := witnessIncome
  income_support := witness_income_support
  prices := witnessOriginalPrices.normalized

theorem witness_core_regular : CoreRegularity witnessModel :=
  ⟨witness_utility_smooth, witness_utility_curvature,
    witness_income_nondegenerate, witness_mean_one⟩

/-- P03: a genuine inhabitant of the general continuous-asset primitive class, with exact data.
IID finite-history compatibility is supplied for this very income type by history_* above. -/
theorem corePrimitives_nonempty :
    ∃ m : HouseholdPrimitives, CoreRegularity m ∧ m.beta = 1/2 ∧
      m.prices.grossReturn = 1 ∧ m.prices.wage = 1 ∧ m.prices.intercept = 0 ∧
      m.utility = witnessUtility ∧ m.income = witnessIncome ∧
      ∃ p : OriginalPrices m.income, p.normalized = m.prices ∧
        p.netRate = 0 ∧ p.wage = 1 ∧ p.debtLimit = 0 ∧
        p.debtLimit = effectiveLimit 0 m.income.lower 1 0 := by
  refine ⟨witnessModel, witness_core_regular, rfl, ?_, rfl, ?_, rfl, rfl,
    witnessOriginalPrices, rfl, rfl, rfl, ?_, rfl⟩
  · change (1 + (0 : ℝ)) = 1
    norm_num
  · change -(0 : ℝ) * _ = 0
    ring
  · change effectiveLimit 0 _ 1 0 = 0
    simp [effectiveLimit]

end Aiyagari1994
