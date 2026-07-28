import Lean4Tutorial.i003_replicate_aiyagari.Assumptions

/-!
# Aiyagari (1994): equilibrium definitions

Equilibrium records contain feasibility, optimality, and market clearing.  They
do not assume uniqueness or stability results that should be proved.
-/

open MeasureTheory Set
open scoped BigOperators ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994

noncomputable section

def aggregateLabor (μ : Measure ℝ) : ℝ := ∫ l, l ∂μ

def aggregateAssets (φ : ℝ) (A : ℝ → ℝ) (μ : Measure ℝ) : ℝ :=
  stationaryMeanAssets φ A μ

def aggregateConsumption (A : ℝ → ℝ) (μ : Measure ℝ) : ℝ :=
  ∫ z, consumptionFromPolicy A z ∂μ

/-- A solution of the concrete household Bellman problem. -/
structure HouseholdEquilibriumData (M : HouseholdPrimitives) (φ : ℝ) where
  V : ℝ → ℝ
  A : ℝ → ℝ
  value_solves : IsBellmanFixedPoint M φ V
  policy_optimal : IsOptimalPolicy M φ V A
  transition_measurable : Measurable (fun p : ℝ × ℝ =>
    resourceTransition M φ (A p.1) p.2)

namespace HouseholdEquilibriumData

variable {M : HouseholdPrimitives} {φ : ℝ}

def kernel (H : HouseholdEquilibriumData M φ) :
    ProbabilityTheory.Kernel ℝ ℝ :=
  resourceKernel M φ H.A H.transition_measurable

theorem consumption_nonneg (H : HouseholdEquilibriumData M φ) (z : ℝ) :
    0 ≤ consumptionFromPolicy H.A z := by
  have hz := (H.policy_optimal z).1
  exact sub_nonneg.mpr hz.2

end HouseholdEquilibriumData

/-! ## Debt-neutral stationary household equilibria

The following objects make the change of variables behind Aiyagari's debt
neutrality claim explicit.  If `ahat = aNet + φ` is shifted net wealth and the
government supplies constant per-capita debt `d`, gross household wealth is
`aGross = ahat - φ + d`.  The government levies the constant interest tax
`r*d`.  Consequently the gross budget, consumption, and next-resource map are
not postulated to agree with their debt-free counterparts: that agreement is
proved in `PropertiesExtensions.lean`.
-/

/-- Convert one shifted net-asset choice into gross government-debt wealth. -/
def grossAssetOfShifted (φ d ahat : ℝ) : ℝ := ahat - φ + d

/-- Convert a shifted net-asset policy into a gross-asset policy. -/
def debtAdjustedAssetPolicy (φ d : ℝ) (A : ℝ → ℝ) (z : ℝ) : ℝ :=
  grossAssetOfShifted φ d (A z)

/-- The gross-asset interval corresponding to shifted choices in `[0,z]`. -/
def debtAdjustedFeasibleChoices (φ d z : ℝ) : Set ℝ :=
  Icc (d - φ) (z + d - φ)

/-- Consumption expressed in resource and gross-asset coordinates. -/
def debtAdjustedConsumption (φ d z aGross : ℝ) : ℝ :=
  z + d - φ - aGross

/-- Next resources when debt interest is financed by the constant tax `r*d`. -/
def debtAdjustedResourceTransition
    (M : HouseholdPrimitives) (φ d aGross lnext : ℝ) : ℝ :=
  debtBudgetResources M.w lnext M.r d aGross - d + φ

/-- The Bellman objective written in gross government-debt coordinates. -/
def debtAdjustedBellmanObjective
    (M : HouseholdPrimitives) (φ d : ℝ) (V : ℝ → ℝ)
    (z aGross : ℝ) : ℝ :=
  M.utility (debtAdjustedConsumption φ d z aGross) + M.β *
    ∫ l, V (debtAdjustedResourceTransition M φ d aGross l) ∂M.laborLaw

/-- The gross-debt Bellman operator, taking the supremum over actual gross
asset choices rather than silently reusing the debt-free operator. -/
def debtAdjustedBellmanOperator
    (M : HouseholdPrimitives) (φ d : ℝ) (V : ℝ → ℝ) (z : ℝ) : ℝ :=
  sSup (debtAdjustedBellmanObjective M φ d V z ''
    debtAdjustedFeasibleChoices φ d z)

def IsDebtAdjustedBellmanFixedPoint
    (M : HouseholdPrimitives) (φ d : ℝ) (V : ℝ → ℝ) : Prop :=
  debtAdjustedBellmanOperator M φ d V = V

/-- Optimality for the actual gross-asset problem with debt-financing taxes. -/
def IsDebtAdjustedOptimalPolicy
    (M : HouseholdPrimitives) (φ d : ℝ) (V G : ℝ → ℝ) : Prop :=
  ∀ z, G z ∈ debtAdjustedFeasibleChoices φ d z ∧
    ∀ g ∈ debtAdjustedFeasibleChoices φ d z,
      debtAdjustedBellmanObjective M φ d V z g ≤
        debtAdjustedBellmanObjective M φ d V z (G z)

/-- A complete stationary pure-exchange equilibrium without government debt.
Household optimality is concrete Bellman optimality, `μ` is invariant for the
induced resource kernel, and the market-clearing object is actual net assets
`A(z)-φ`, not shifted assets. -/
structure DebtFreeStationaryEquilibrium
    (M : HouseholdPrimitives) (φ : ℝ) where
  household : HouseholdEquilibriumData M φ
  μ : Measure ℝ
  μ_probability : IsProbabilityMeasure μ
  invariant_distribution : IsInvariant household.kernel μ
  net_assets_integrable : Integrable (fun z => household.A z - φ) μ
  asset_market_clears : ∫ z, household.A z - φ ∂μ = 0

/-- A complete stationary pure-exchange equilibrium with constant government
debt `d` and the tax-adjusted natural constraint.  The household solves the
gross-asset problem, the resource law is invariant, and gross assets clear the
government debt market. -/
structure TaxAdjustedDebtStationaryEquilibrium
    (M : HouseholdPrimitives) (φ d : ℝ) where
  household : HouseholdEquilibriumData M φ
  debt_value_solves :
    IsDebtAdjustedBellmanFixedPoint M φ d household.V
  debt_policy_optimal :
    IsDebtAdjustedOptimalPolicy M φ d household.V
      (debtAdjustedAssetPolicy φ d household.A)
  μ : Measure ℝ
  μ_probability : IsProbabilityMeasure μ
  invariant_distribution : IsInvariant household.kernel μ
  gross_assets_integrable :
    Integrable (debtAdjustedAssetPolicy φ d household.A) μ
  asset_market_clears :
    ∫ z, debtAdjustedAssetPolicy φ d household.A z ∂μ = d

/-- A stationary recursive competitive equilibrium with an actual invariant
probability law for the policy-induced resource kernel. -/
structure StationaryRecursiveEquilibrium (P : Primitives) where
  r : ℝ
  w : ℝ
  k : ℝ
  C : ℝ
  b : ℝ
  φ : ℝ
  householdModel : HouseholdPrimitives
  β_matches : householdModel.β = P.β
  r_matches : householdModel.r = r
  w_matches : householdModel.w = w
  b_matches : householdModel.b = b
  lmin_matches : householdModel.lmin = P.lmin
  household : HouseholdEquilibriumData householdModel φ
  μ : Measure ℝ
  μ_probability : IsProbabilityMeasure μ
  effective_limit : φ = effectiveBorrowingLimit b w P.lmin r
  invariant_distribution : IsInvariant household.kernel μ
  firm_return : r = P.marginalProductCapital k - P.δ
  firm_wage : w = P.wageFromCapital k
  labor_clears : aggregateLabor householdModel.laborLaw = 1
  assets_clear : aggregateAssets φ household.A μ = k
  capital_demand_clears : P.capitalDemand r = k
  consumption_aggregates : aggregateConsumption household.A μ = C
  goods_clear : C + P.δ * k = P.production k

namespace StationaryRecursiveEquilibrium

variable {P : Primitives} (E : StationaryRecursiveEquilibrium P)

theorem market_clears :
    MarketClears P.capitalDemand
      (fun _ => aggregateAssets E.φ E.household.A E.μ) E.r := by
  unfold MarketClears
  rw [E.capital_demand_clears, E.assets_clear]

def savingRate : ℝ := P.savingRate E.k

def netSaving : ℝ := P.production E.k - E.C - P.δ * E.k

end StationaryRecursiveEquilibrium

structure FullInsuranceEquilibrium (P : Primitives) where
  r : ℝ
  k : ℝ
  C : ℝ
  return_eq_timePreference : r = P.«λ»
  firm_return : r = P.marginalProductCapital k - P.δ
  capital_demand_clears : P.capitalDemand r = k
  goods_clear : C + P.δ * k = P.production k

/-- Pure-exchange debt equilibrium with genuine distributional clearing. -/
structure GovernmentDebtEquilibrium where
  r : ℝ
  w : ℝ
  d : ℝ
  consumption : ℕ → ℝ
  assets : ℕ → ℝ
  labor : ℕ → ℝ
  budget : ∀ t,
    consumption t + assets (t + 1) =
      debtBudgetResources w (labor t) r d (assets t)
  μ : Measure ℝ
  μ_probability : IsProbabilityMeasure μ
  assets_integrable : Integrable id μ
  assetMarketClears : ∫ a, a ∂μ = d

/-- Monetary equilibrium with a probability law and zero mean net assets. -/
structure MonetaryStationaryEquilibrium where
  r : ℝ
  p : ℝ
  μ : Measure ℝ
  μ_probability : IsProbabilityMeasure μ
  assets_integrable : Integrable id μ
  p_pos : 0 < p
  clears : ∫ a, a ∂μ = 0

end

end Aiyagari1994
