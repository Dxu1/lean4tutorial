import Aiyagari1994.Household.PolicyOrder

/-! Joint transition regularity used to construct the household kernel. -/
open MeasureTheory ProbabilityTheory Set
open scoped NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- Resources tomorrow as a jointly continuous function of resources today and the labor shock. -/
def householdTransition (m : HouseholdPrimitives) (zl : Resources × m.income.Labor) : Resources :=
  m.prices.nextResources (assetPolicy m zl.1) zl.2

theorem householdTransition_continuous (m : HouseholdPrimitives) :
    Continuous (householdTransition m) := by
  apply Continuous.subtype_mk
  exact (continuous_const.mul
      (continuous_subtype_val.comp ((assetPolicy_continuous m).comp continuous_fst))).add
    ((continuous_const.mul (continuous_subtype_val.comp continuous_snd)).add continuous_const)

end
end Aiyagari1994
