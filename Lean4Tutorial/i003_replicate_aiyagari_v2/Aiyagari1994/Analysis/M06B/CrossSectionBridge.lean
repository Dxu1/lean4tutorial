import Aiyagari1994.Budget.Normalization
import Aiyagari1994.Stationary.GlobalStability
import Mathlib.MeasureTheory.Measure.FiniteMeasureProd

/-! Measure-theoretic implementation of the stationary resource/asset-labor bridge. -/
open MeasureTheory ProbabilityTheory
open scoped NNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- Net assets obtained by undoing the debt-limit shift from the optimal shifted saving rule. -/
def M06B.netAsset (m : HouseholdPrimitives) (phi : ℝ) (z : Resources) : ℝ :=
  (assetPolicy m z : ℝ) - phi

theorem M06B.netAsset_continuous (m : HouseholdPrimitives) (phi : ℝ) :
    Continuous (M06B.netAsset m phi) :=
  (continuous_subtype_val.comp (assetPolicy_continuous m)).sub continuous_const

/-- The net-asset marginal induced by a resource law and the canonical saving policy. -/
def M06B.netAssetLaw (m : HouseholdPrimitives) (phi : ℝ)
    (pi : ProbabilityMeasure Resources) : ProbabilityMeasure ℝ :=
  pi.map (M06B.netAsset_continuous m phi).measurable.aemeasurable

/-- Predetermined net assets and the current iid labor draw have their independent product law. -/
def M06B.assetLaborLaw (m : HouseholdPrimitives) (rho : ProbabilityMeasure ℝ) :
    ProbabilityMeasure (ℝ × m.income.Labor) :=
  rho.prod m.income.law

/-- Recover shifted saving from net assets and apply the normalized one-period resource map. -/
def M06B.resourceFromAssetLabor (m : HouseholdPrimitives) (phi : ℝ)
    (al : ℝ × m.income.Labor) : Resources :=
  m.prices.nextResources (Real.toNNReal (al.1 + phi)) al.2

theorem M06B.resourceFromAssetLabor_continuous (m : HouseholdPrimitives) (phi : ℝ) :
    Continuous (M06B.resourceFromAssetLabor m phi) := by
  apply Continuous.subtype_mk
  change Continuous (fun al : ℝ × m.income.Labor =>
    m.prices.grossReturn * (Real.toNNReal (al.1 + phi) : ℝ) +
      (m.prices.wage * (al.2 : ℝ) + m.prices.intercept))
  fun_prop

/-- Before imposing stationarity, the resource image of the policy-induced asset/labor
cross-section is exactly one application of the household law operator. -/
theorem M06B.resourceImage_eq_lawStep (m : HouseholdPrimitives) (phi : ℝ)
    (pi : ProbabilityMeasure Resources) :
    (M06B.assetLaborLaw m (M06B.netAssetLaw m phi pi)).map
        (M06B.resourceFromAssetLabor_continuous m phi).measurable.aemeasurable =
      householdLawStep m pi := by
  apply ProbabilityMeasure.toMeasure_injective
  simp only [M06B.assetLaborLaw, M06B.netAssetLaw, ProbabilityMeasure.toMeasure_map,
    ProbabilityMeasure.toMeasure_prod]
  rw [show (m.income.law : Measure m.income.Labor) =
    Measure.map id (m.income.law : Measure m.income.Labor) by rw [Measure.map_id]]
  rw [Measure.map_prod_map _ _ (M06B.netAsset_continuous m phi).measurable measurable_id]
  rw [Measure.map_map (M06B.resourceFromAssetLabor_continuous m phi).measurable
    ((M06B.netAsset_continuous m phi).measurable.prodMap measurable_id)]
  have hcomp : M06B.resourceFromAssetLabor m phi ∘
        Prod.map (M06B.netAsset m phi) id = householdTransition m := by
    funext zl
    apply Subtype.ext
    simp [M06B.resourceFromAssetLabor, M06B.netAsset, householdTransition,
      Real.toNNReal_of_nonneg]
  have htransition : Measurable (householdTransition m) :=
    (householdTransition_continuous m).measurable
  rw [hcomp]
  change Measure.map (householdTransition m)
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) =
    householdKernel m ∘ₘ (pi : Measure Resources)
  rw [← Measure.compProd_const]
  rw [Measure.compProd_eq_comp_prod]
  rw [Measure.map_comp _ _ htransition]
  rfl

end
end Aiyagari1994
