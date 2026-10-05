import Aiyagari1994.Aggregate.CrossSection
import Aiyagari1994.Firms.Neoclassical
import Aiyagari1994.Household.Verification
import Aiyagari1994.Stationary.Kernel

/-!
# Stationary equilibrium data and its two cross-sectional formulations

The equilibrium core below is deliberately noncircular. Its resource law and finite first
moments are supplied by the witness; no stationary-law constructor and no impatience inequality
enters the definition. Predetermined net assets are paired with a fresh labor draw only in
`assetLaborLawForm`.
-/

open MeasureTheory ProbabilityTheory Set
open scoped NNReal ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- The complete accepted F01 certificate. -/
def FirmOptimizationCertificate (p : ProductionData) (hp : ProductionRegularity p) : Prop :=
  (∀ r : FirmRate p,
      deriv p.output (capitalDemand p hp r) = (r : ℝ) + p.depreciation ∧
        0 < firmWage p hp r ∧
          ∀ K ∈ Ici (0 : ℝ), K ≠ capitalDemand p hp r →
            firmProfit p r K < firmProfit p r (capitalDemand p hp r)) ∧
    Continuous (capitalDemand p hp) ∧ StrictAnti (capitalDemand p hp) ∧
      Continuous (firmWage p hp)

/-- H05 lifetime optimality against every measurable full-history feasible plan. -/
def LifetimeOptimalityCertificate (m : HouseholdPrimitives) : Prop :=
  ∀ z0 : Resources,
    (∀ q : FeasiblePlan m z0, Summable fun t => |m.beta ^ t * expectedFlow q t|) ∧
      (∀ q : FeasiblePlan m z0, lifetimeUtility q ≤ valueFunction m z0) ∧
        lifetimeUtility (canonicalPlan m z0) = valueFunction m z0 ∧
          ∀ q : FeasiblePlan m z0,
            lifetimeUtility q ≤ lifetimeUtility (canonicalPlan m z0)

/-- The actual S01 policy-induced Markov kernel and its accepted regularity properties. -/
def HouseholdKernelCertificate (m : HouseholdPrimitives) : Prop :=
  IsMarkovKernel (householdKernel m) ∧
    (∀ f : BoundedContinuousFunction Resources ℝ,
      Continuous fun z => ∫ y, f y ∂householdKernel m z) ∧
      (∀ f : BoundedContinuousFunction Resources ℝ, Monotone f →
        Monotone fun z => ∫ y, f y ∂householdKernel m z) ∧
        ∀ (z : Resources) (f : Resources → ℝ), Measurable f →
          (∫ y, f y ∂householdKernel m z) =
            ∫ l, f (m.prices.nextResources (assetPolicy m z) l)
              ∂(m.income.law : Measure m.income.Labor)

/-- P01's exact original/shifted budget and borrowing-feasibility equivalence. -/
def BudgetNormalizationCertificate : Prop :=
  ∀ r w l phi a aNext c : ℝ,
    (c + aNext = (1 + r) * a + w * l ∧ -phi ≤ aNext) ↔
      (c + (aNext + phi) = (1 + r) * (a + phi) + w * l - r * phi ∧
        0 ≤ aNext + phi)

/-- Data common to the resource-law and net-asset/current-labor equilibrium formulations.

The rate has the full firm domain `r > -δ`. The original-price witness adds no restriction:
`δ < 1` implies every such rate exceeds `-1`. In particular there is no `r < lambda` or
`beta * (1+r) < 1` field. -/
structure EquilibriumCore (p : ProductionData) (hp : ProductionRegularity p) where
  rate : FirmRate p
  household : HouseholdPrimitives
  utility_smooth : UtilitySmooth household.utility
  income_nondegenerate : IncomeNondegenerate household.income
  labor_mean_one : LaborMeanOne household.income
  iid_histories : ∀ n, iIndepFun
    (fun j : Fin n => fun h : Fin n → household.income.Labor => h j)
    (historyLaw household.income n)
  originalPrices : OriginalPrices household.income
  original_rate : originalPrices.netRate = (rate : ℝ)
  original_wage : originalPrices.wage = firmWage p hp rate
  normalized_prices : originalPrices.normalized = household.prices
  resourceLaw : ProbabilityMeasure Resources
  resource_integrable : Integrable (fun z : Resources => (z : ℝ)) resourceLaw
  net_assets_integrable :
    Integrable (M06B.netAsset household originalPrices.debtLimit) resourceLaw
  capital_clearing :
    (∫ z, M06B.netAsset household originalPrices.debtLimit z ∂resourceLaw) =
      capitalDemand p hp rate
  firm_optimization : FirmOptimizationCertificate p hp
  lifetime_optimality : LifetimeOptimalityCertificate household
  household_kernel : HouseholdKernelCertificate household
  budget_normalization : BudgetNormalizationCertificate

/-- Stationarity stated as invariance of the resource law under the actual household kernel. -/
def resourceLawForm {p : ProductionData} {hp : ProductionRegularity p}
    (e : EquilibriumCore p hp) : Prop :=
  householdLawStep e.household e.resourceLaw = e.resourceLaw

/-- Stationarity stated using the induced net-asset marginal and the independent product of
predetermined assets with a fresh current labor draw. -/
def assetLaborLawForm {p : ProductionData} {hp : ProductionRegularity p}
    (e : EquilibriumCore p hp) : Prop :=
  ∃ rho : ProbabilityMeasure ℝ,
    rho = M06B.netAssetLaw e.household e.originalPrices.debtLimit e.resourceLaw ∧
      (M06B.assetLaborLaw e.household rho).map
          (M06B.resourceFromAssetLabor_continuous e.household
            e.originalPrices.debtLimit).measurable.aemeasurable = e.resourceLaw

/-- A stationary equilibrium in the resource-law formulation. -/
structure StationaryEquilibrium (p : ProductionData) (hp : ProductionRegularity p)
    extends EquilibriumCore p hp where
  resource_stationary : resourceLawForm toEquilibriumCore

/-- A01 converts exactly between the two cross-sectional formulations, without asserting that
the contemporaneous saving choice is independent of contemporaneous labor. -/
theorem resource_asset_labor_form_iff {p : ProductionData} {hp : ProductionRegularity p}
    (e : EquilibriumCore p hp) :
    resourceLawForm e ↔ assetLaborLawForm e := by
  let rho := M06B.netAssetLaw e.household e.originalPrices.debtLimit e.resourceLaw
  have hbridge := resource_asset_labor_law_bridge e.household e.originalPrices.debtLimit
    e.resourceLaw rho rfl
  constructor
  · intro hstationary
    refine ⟨rho, rfl, ?_⟩
    exact hbridge.mpr hstationary
  · rintro ⟨rho', hrho', himage⟩
    exact (resource_asset_labor_law_bridge e.household e.originalPrices.debtLimit
      e.resourceLaw rho' hrho').mp himage

end
end Aiyagari1994
