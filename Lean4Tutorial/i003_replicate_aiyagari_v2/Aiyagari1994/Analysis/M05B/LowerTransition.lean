import Aiyagari1994.Household.Euler
import Mathlib.Dynamics.FixedPoints.Topology
import Mathlib.Topology.Instances.Real.Lemmas

/-! Analytic support for the lower-shock transition in S02. -/
open MeasureTheory Set Filter Function
open scoped NNReal Topology ENNReal
namespace Aiyagari1994
noncomputable section

/-- The least effective income, evaluated at the lower endpoint of labor support. -/
def lowerEffectiveIncome (m : HouseholdPrimitives) : Resources :=
  ⟨m.prices.effectiveIncome
      ⟨m.income.lower, le_rfl, m.income_support.ordered⟩,
    m.prices.income_nonneg ⟨m.income.lower, le_rfl, m.income_support.ordered⟩⟩

/-- Tomorrow's resources under the optimal policy and the least labor realization. -/
def lowerTransition (m : HouseholdPrimitives) (z : Resources) : Resources :=
  m.prices.nextResources (assetPolicy m z)
    ⟨m.income.lower, le_rfl, m.income_support.ordered⟩

theorem lowerTransition_continuous (m : HouseholdPrimitives) :
    Continuous (lowerTransition m) := by
  apply Continuous.subtype_mk
  exact (continuous_const.mul
      (continuous_subtype_val.comp (assetPolicy_continuous m))).add continuous_const

theorem lowerEffectiveIncome_le_lowerTransition (m : HouseholdPrimitives) (z : Resources) :
    lowerEffectiveIncome m ≤ lowerTransition m z := by
  apply Subtype.coe_le_coe.mp
  change m.prices.effectiveIncome _ ≤
    m.prices.grossReturn * (assetPolicy m z : ℝ) + m.prices.effectiveIncome _
  exact le_add_of_nonneg_left
    (mul_nonneg m.prices.grossReturn_pos.le (assetPolicy m z).property)

end
end Aiyagari1994
