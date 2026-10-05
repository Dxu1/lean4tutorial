import Aiyagari1994.Firms.Neoclassical
import Aiyagari1994.Aggregate.AssetSupply
import Aiyagari1994.Budget.EffectiveLimit

/-! Gate-local proof body for the finite-cap lower bracket. -/

open Filter MeasureTheory Set Topology
open scoped NNReal Topology

namespace Aiyagari1994
noncomputable section

/-- Vanishing marginal product and concavity imply vanishing average product.  The proof uses
the tangent bound at a positive reference capital; average-product decay is not assumed. -/
theorem production_average_tendsto_zero (p : ProductionData) (hp : ProductionRegularity p) :
    Tendsto (fun K : ℝ => p.output K / K) atTop (nhds 0) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  have hhalf : 0 < ε / 2 := half_pos hε
  have hmarg : ∀ᶠ K in atTop, deriv p.output K < ε / 2 :=
    hp.marginal_at_infinity (Iio_mem_nhds hhalf)
  obtain ⟨x, hxMarg, hxPos⟩ := (hmarg.and (eventually_gt_atTop 0)).exists
  let d := deriv p.output x
  let C := p.output x - d * x
  refine ⟨max x (2 * |C| / ε) + 1, ?_⟩
  intro K hK
  have hxK : x < K := lt_of_le_of_lt (le_max_left _ _) (by linarith)
  have hKpos : 0 < K := hxPos.trans hxK
  have hdiff : p.output K - p.output x < d * (K - x) := by
    have hs := (production_strictConcaveOn hp).slope_lt_deriv
      (x := x) (y := K) hxPos.le hKpos.le hxK
      ((hp.smooth_positive.differentiableOn (by norm_num) x hxPos).differentiableAt
        (Ioi_mem_nhds hxPos))
    simp only [slope, vsub_eq_sub, smul_eq_mul, inv_mul_eq_div] at hs
    exact (div_lt_iff₀ (sub_pos.mpr hxK)).mp hs
  have hC : |C| / K < ε / 2 := by
    have hbound : 2 * |C| / ε < K := by
      have hmax : max x (2 * |C| / ε) < K := by linarith
      exact (le_max_right x (2 * |C| / ε)).trans_lt hmax
    have hmul' : 2 * |C| < K * ε := (div_lt_iff₀ hε).mp hbound
    have hmul : 2 * |C| < ε * K := by nlinarith
    exact (div_lt_iff₀ hKpos).2 (by linarith)
  have hd : d < ε / 2 := hxMarg
  have hu : p.output K / K < ε := by
    have houtput : p.output K < d * K + C := by
      dsimp [C]
      linarith
    have hdiv : p.output K / K < d + C / K := by
      apply (div_lt_iff₀ hKpos).2
      calc
        p.output K < d * K + C := houtput
        _ = (d + C / K) * K := by field_simp
    have hCle : C / K ≤ |C| / K :=
      div_le_div_of_nonneg_right (le_abs_self C) hKpos.le
    linarith
  have hl : -ε < p.output K / K := by
    have hs := (production_strictConcaveOn hp).deriv_lt_slope
      (x := 0) (y := K) (by simp) hKpos.le hKpos
      ((hp.smooth_positive.differentiableOn (by norm_num) K hKpos).differentiableAt
        (Ioi_mem_nhds hKpos))
    simp only [slope, hp.output_zero, sub_zero, vsub_eq_sub, smul_eq_mul,
      inv_mul_eq_div] at hs
    have := hp.marginal_positive K hKpos
    linarith
  rw [Real.dist_eq]
  simpa only [sub_zero] using (abs_lt.2 ⟨hl, hu⟩)

def M09A3.lowerOriginalPrices (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) (r : FirmRate p) :
    OriginalPrices m.income :=
  finiteCapPrices m.income m.income_support b (firmWage p hp r) r hb
    (firmWage_positive p hp r) (by
      have hr := r.property
      have hδ := hp.depreciation_lt_one
      change -p.depreciation < (r : ℝ) at hr
      linarith)

def M09A3.lowerHousehold (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) (r : FirmRate p) :
    HouseholdPrimitives where
  beta := m.beta
  beta_pos := m.beta_pos
  beta_lt_one := m.beta_lt_one
  utility := m.utility
  utility_base := m.utility_base
  income := m.income
  income_support := m.income_support
  prices := (M09A3.lowerOriginalPrices m p hp b hb r).normalized

theorem M09A3.lower_betaR (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : FirmRate p) (hrneg : (r : ℝ) < 0) :
    m.beta * (1 + (r : ℝ)) < 1 := by
  have hRpos : 0 < 1 + (r : ℝ) := by
    have hr := r.property
    change -p.depreciation < (r : ℝ) at hr
    linarith [hp.depreciation_lt_one]
  nlinarith [m.beta_pos, m.beta_lt_one]

/-- Core F02 proof.  Every finite nonnegative cap admits a negative firm rate at which the
canonical stationary household asset supply is strictly below capital demand. -/
theorem finiteCap_lower_bracket_core (p : ProductionData) (hp : ProductionRegularity p)
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (hmean : LaborMeanOne m.income) (b : ℝ) (hb : 0 ≤ b) :
    ∃ K_L : ℝ, 0 < K_L ∧
      ∃ r_L : FirmRate p,
        capitalDemand p hp r_L = K_L ∧
        ∃ hrneg : (r_L : ℝ) < 0,
        deriv p.output K_L < p.depreciation ∧
        p.output K_L < p.depreciation * K_L ∧
        let prices := M09A3.lowerOriginalPrices m p hp b hb r_L
        let household := M09A3.lowerHousehold m p hp b hb r_L
        let hbetaR : household.beta * household.prices.grossReturn < 1 := by
          change m.beta * (1 + (r_L : ℝ)) < 1
          exact M09A3.lower_betaR m p hp r_L hrneg
        prices.debtLimit = b ∧
        0 < 1 + (r_L : ℝ) ∧
        household.beta * household.prices.grossReturn < 1 ∧
        stationaryAssetSupply household prices.debtLimit
            (M06C.stationaryLaw household hsmooth hcurvature hnd hbetaR) < K_L := by
  have havg := production_average_tendsto_zero p hp
  have havgEventually : ∀ᶠ K in atTop, p.output K / K < p.depreciation :=
    havg (Iio_mem_nhds hp.depreciation_positive)
  have hmargEventually : ∀ᶠ K in atTop, deriv p.output K < p.depreciation :=
    hp.marginal_at_infinity (Iio_mem_nhds hp.depreciation_positive)
  obtain ⟨K_L, havgK, hmargK, hKpos⟩ :=
    (havgEventually.and (hmargEventually.and (eventually_gt_atTop 0))).exists
  have houtputK : p.output K_L < p.depreciation * K_L :=
    (div_lt_iff₀ hKpos).mp havgK
  let rReal := deriv p.output K_L - p.depreciation
  have hrFirm : -p.depreciation < rReal := by
    dsimp [rReal]
    linarith [hp.marginal_positive K_L hKpos]
  let r_L : FirmRate p := ⟨rReal, hrFirm⟩
  have hrneg : (r_L : ℝ) < 0 := by dsimp [r_L, rReal]; linarith
  have hKdemand : capitalDemand p hp r_L = K_L := by
    apply (production_marginal_exists_unique hp (hp.marginal_positive K_L hKpos)).unique
    · refine ⟨capitalDemand_positive p hp r_L, ?_⟩
      rw [capitalDemand_marginal]
      dsimp [r_L, rReal]
      ring
    · exact ⟨hKpos, rfl⟩
  refine ⟨K_L, hKpos, r_L, hKdemand, hrneg, hmargK, houtputK, ?_⟩
  dsimp only
  let prices := M09A3.lowerOriginalPrices m p hp b hb r_L
  let household := M09A3.lowerHousehold m p hp b hb r_L
  have hRpos : 0 < 1 + (r_L : ℝ) := by
    have hr := r_L.property
    linarith [hp.depreciation_lt_one]
  have hbetaR : household.beta * household.prices.grossReturn < 1 := by
    change m.beta * (1 + (r_L : ℝ)) < 1
    exact M09A3.lower_betaR m p hp r_L hrneg
  let pi := M06C.stationaryLaw household hsmooth hcurvature hnd hbetaR
  have hbudget := stationary_budget_identity household hsmooth hcurvature hnd hbetaR
    prices (by rfl)
  dsimp only at hbudget
  have hconsNonneg : 0 ≤ ∫ z, (consumptionPolicy household z : ℝ)
      ∂(pi : Measure Resources) := by
    exact integral_nonneg fun z => (consumptionPolicy household z).property
  have hsupplyUpper : stationaryAssetSupply household prices.debtLimit pi ≤
      (firmWage p hp r_L) / (-(r_L : ℝ)) := by
    have hmean' : ∫ l, (l : ℝ) ∂(household.income.law : Measure household.income.Labor) = 1 :=
      hmean.mean_eq_one
    have hidentity := hbudget.2.2.2.2.2.2.2
    rw [hmean'] at hidentity
    have hrden : 0 < -(r_L : ℝ) := neg_pos.mpr hrneg
    apply (le_div_iff₀ hrden).2
    dsimp [pi] at hconsNonneg
    rw [show prices.netRate = (r_L : ℝ) by rfl,
      show prices.wage = firmWage p hp r_L by rfl, mul_one] at hidentity
    dsimp [pi]
    nlinarith [hidentity, hconsNonneg]
  have hwOver : (firmWage p hp r_L) / (-(r_L : ℝ)) < K_L := by
    have hrden : 0 < -(r_L : ℝ) := neg_pos.mpr hrneg
    apply (div_lt_iff₀ hrden).2
    rw [firmWage]
    rw [hKdemand]
    dsimp [r_L, rReal]
    linarith
  have hcap : prices.debtLimit = b := by
    dsimp [prices, M09A3.lowerOriginalPrices, finiteCapPrices, effectiveLimit]
    rw [if_neg (not_lt.mpr hrneg.le)]
  refine ⟨hcap, hRpos, hbetaR, ?_⟩
  exact lt_of_le_of_lt hsupplyUpper hwOver

end
end Aiyagari1994
