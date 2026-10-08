import Aiyagari1994.Equilibrium.Definition
import Aiyagari1994.Firms.Neoclassical
import Mathlib.Probability.Kernel.Composition.IntegralCompProd
import Mathlib.MeasureTheory.Integral.Prod

/-!
# Goods-market clearing

For an unrestricted stationary equilibrium, finite resource and net-asset moments imply the
missing shifted-asset and consumption moments.  Invariance of the actual household transition
then gives the aggregate household budget.  Mean-one labor, net asset clearing, and F01's
competitive factor-price identities turn that budget into goods-market clearing.
-/

open MeasureTheory ProbabilityTheory
open scoped NNReal ProbabilityTheory

namespace Aiyagari1994
noncomputable section

namespace M09D3

private theorem resourceImage_eq_lawStep (m : HouseholdPrimitives)
    (pi : ProbabilityMeasure Resources) :
    (pi.prod m.income.law).map
        (householdTransition_continuous m).measurable.aemeasurable = householdLawStep m pi := by
  apply ProbabilityMeasure.toMeasure_injective
  simp only [ProbabilityMeasure.toMeasure_map, ProbabilityMeasure.toMeasure_prod]
  change Measure.map (householdTransition m)
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) =
    householdKernel m ∘ₘ (pi : Measure Resources)
  rw [← Measure.compProd_const]
  rw [Measure.compProd_eq_comp_prod]
  rw [Measure.map_comp _ _ (householdTransition_continuous m).measurable]
  rfl

private theorem stationary_resource_identity
    (m : HouseholdPrimitives) (pi : ProbabilityMeasure Resources)
    (hinv : householdLawStep m pi = pi)
    (_hz : Integrable (fun z : Resources => (z : ℝ)) (pi : Measure Resources))
    (hA : Integrable (fun z : Resources => (assetPolicy m z : ℝ))
      (pi : Measure Resources)) :
    (∫ z, (z : ℝ) ∂(pi : Measure Resources)) =
      m.prices.grossReturn *
          ∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources) +
        ∫ l, m.prices.effectiveIncome l ∂(m.income.law : Measure m.income.Labor) := by
  have he : Integrable m.prices.effectiveIncome
      (m.income.law : Measure m.income.Labor) := by
    exact ((labor_integrable m.income).const_mul m.prices.wage).add
      (integrable_const m.prices.intercept)
  have hRA : Integrable
      (fun zl : Resources × m.income.Labor =>
        m.prices.grossReturn * (assetPolicy m zl.1 : ℝ))
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) :=
    (hA.const_mul m.prices.grossReturn).comp_fst _
  have heProd : Integrable
      (fun zl : Resources × m.income.Labor => m.prices.effectiveIncome zl.2)
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) :=
    he.comp_snd _
  calc
    (∫ y, (y : ℝ) ∂(pi : Measure Resources)) =
        ∫ y, (y : ℝ) ∂(householdLawStep m pi : Measure Resources) := by rw [hinv]
    _ = ∫ y, (y : ℝ) ∂((pi.prod m.income.law).map
        (householdTransition_continuous m).measurable.aemeasurable : Measure Resources) := by
          rw [resourceImage_eq_lawStep]
    _ = _ := by
      change (∫ y, (y : ℝ) ∂Measure.map (householdTransition m)
          ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor))) = _
      rw [integral_map (householdTransition_continuous m).measurable.aemeasurable
        measurable_coe_nnreal_real.aestronglyMeasurable]
      change (∫ zl, m.prices.grossReturn * (assetPolicy m zl.1 : ℝ) +
          m.prices.effectiveIncome zl.2
          ∂((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor))) = _
      rw [integral_add hRA heProd]
      rw [integral_fun_fst (fun z : Resources =>
        m.prices.grossReturn * (assetPolicy m z : ℝ))]
      rw [integral_fun_snd m.prices.effectiveIncome]
      simp [integral_const_mul]

/-- Gate-local implementation of G08.  Goods clearing is derived for every unrestricted
stationary equilibrium from its invariant household law and finite first moments. -/
theorem equilibrium_goods_market_clears_core
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    (∫ z, (consumptionPolicy e.household z : ℝ) ∂e.resourceLaw) +
        p.depreciation *
          (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z
            ∂e.resourceLaw) =
      p.output
        (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z
          ∂e.resourceLaw) := by
  have hA : Integrable (fun z : Resources => (assetPolicy e.household z : ℝ))
      (e.resourceLaw : Measure Resources) := by
    have h := e.net_assets_integrable.add
      (integrable_const e.originalPrices.debtLimit)
    apply h.congr
    exact Filter.Eventually.of_forall fun z => by simp [M06B.netAsset]
  have hc : Integrable (fun z : Resources => (consumptionPolicy e.household z : ℝ))
      (e.resourceLaw : Measure Resources) := by
    have h := e.resource_integrable.sub hA
    apply h.congr
    exact Filter.Eventually.of_forall fun z => (consumptionPolicy_coe e.household z).symm
  have hresource := stationary_resource_identity e.household e.resourceLaw
    e.resource_stationary e.resource_integrable hA
  have hnet :
      (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z
          ∂e.resourceLaw) =
        (∫ z, (assetPolicy e.household z : ℝ) ∂e.resourceLaw) -
          e.originalPrices.debtLimit := by
    simp_rw [M06B.netAsset]
    rw [integral_sub hA (integrable_const _), integral_const]
    simp
  have heffective :
      (∫ l, e.household.prices.effectiveIncome l
          ∂(e.household.income.law : Measure e.household.income.Labor)) =
        e.originalPrices.wage *
            ∫ l, (l : ℝ)
              ∂(e.household.income.law : Measure e.household.income.Labor) -
          e.originalPrices.netRate * e.originalPrices.debtLimit := by
    rw [← e.normalized_prices]
    change (∫ l, e.originalPrices.wage * (l : ℝ) +
        (-e.originalPrices.netRate * e.originalPrices.debtLimit)
        ∂(e.household.income.law : Measure e.household.income.Labor)) = _
    rw [integral_add ((labor_integrable e.household.income).const_mul
      e.originalPrices.wage) (integrable_const _), integral_const_mul, integral_const]
    simp
    ring
  have hconsumption :
      (∫ z, (consumptionPolicy e.household z : ℝ) ∂e.resourceLaw) =
        e.originalPrices.netRate *
            (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z
              ∂e.resourceLaw) +
          e.originalPrices.wage *
            ∫ l, (l : ℝ)
              ∂(e.household.income.law : Measure e.household.income.Labor) := by
    have hc_sub :
        (∫ z, (consumptionPolicy e.household z : ℝ) ∂e.resourceLaw) =
          (∫ z, (z : ℝ) ∂(e.resourceLaw : Measure Resources)) -
            ∫ z, (assetPolicy e.household z : ℝ)
              ∂(e.resourceLaw : Measure Resources) := by
      calc
        (∫ z, (consumptionPolicy e.household z : ℝ) ∂e.resourceLaw) =
            ∫ z, (z : ℝ) - (assetPolicy e.household z : ℝ)
              ∂(e.resourceLaw : Measure Resources) := by
                apply integral_congr_ae
                exact Filter.Eventually.of_forall (consumptionPolicy_coe e.household)
        _ = _ := integral_sub e.resource_integrable hA
    rw [hc_sub, hresource, heffective, hnet]
    have hR : e.household.prices.grossReturn = 1 + e.originalPrices.netRate := by
      rw [← e.normalized_prices]
      rfl
    rw [hR]
    ring
  rw [hconsumption, e.labor_mean_one.mean_eq_one, mul_one, e.original_rate,
    e.original_wage, e.capital_clearing]
  have hmarginal := (capitalDemand_wage_constructed p hp).1 e.rate |>.1
  simp only [firmWage]
  rw [hmarginal]
  ring

end M09D3

end
end Aiyagari1994
