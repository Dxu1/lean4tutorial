import Aiyagari1994.Primitives.Examples
import Mathlib.Analysis.Calculus.ContDiff.Deriv
import Mathlib.Analysis.Convex.Deriv
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Topology.Order.MonotoneContinuity

/-!
# Neoclassical firms

The capital demand and wage below are constructed from a production function.  They are not
primitive demand schedules.  Capital is represented on the real line, with every economic
claim restricted to nonnegative (or positive) capital.
-/

open Filter Set Topology
open scoped Topology

namespace Aiyagari1994
noncomputable section

/-- Production and depreciation data.  All regularity is kept in `ProductionRegularity`. -/
structure ProductionData where
  output : ℝ → ℝ
  depreciation : ℝ

/-- The exact PRODUCTION profile: continuity at nonnegative capital, `C²` smoothness at
positive capital, positive and strictly decreasing marginal product, both Inada limits, and
depreciation strictly between zero and one. -/
structure ProductionRegularity (p : ProductionData) : Prop where
  output_zero : p.output 0 = 0
  continuous_nonnegative : ContinuousOn p.output (Ici 0)
  smooth_positive : ContDiffOn ℝ 2 p.output (Ioi 0)
  marginal_positive : ∀ K > (0 : ℝ), 0 < deriv p.output K
  curvature_negative : ∀ K > (0 : ℝ), deriv (deriv p.output) K < 0
  inada_zero : Tendsto (deriv p.output) (nhdsWithin 0 (Ioi 0)) atTop
  marginal_at_infinity : Tendsto (deriv p.output) atTop (nhds 0)
  depreciation_positive : 0 < p.depreciation
  depreciation_lt_one : p.depreciation < 1

/-- The untruncated domain `r > -δ`. -/
abbrev FirmRate (p : ProductionData) := Ioi (-p.depreciation)

theorem firmRate_add_depreciation_pos (p : ProductionData) (r : FirmRate p) :
    0 < (r : ℝ) + p.depreciation := by
  have hr := r.property
  change -p.depreciation < (r : ℝ) at hr
  linarith

theorem production_marginal_strictAntiOn {p : ProductionData}
    (hp : ProductionRegularity p) :
    StrictAntiOn (deriv p.output) (Ioi 0) := by
  apply strictAntiOn_of_deriv_neg (convex_Ioi 0)
  · exact hp.smooth_positive.continuousOn_deriv_of_isOpen isOpen_Ioi (by norm_num)
  · intro K hK
    exact hp.curvature_negative K (by simpa only [interior_Ioi, mem_Ioi] using hK)

theorem production_strictConcaveOn {p : ProductionData}
    (hp : ProductionRegularity p) :
    StrictConcaveOn ℝ (Ici 0) p.output := by
  apply strictConcaveOn_of_deriv2_neg (convex_Ici 0) hp.continuous_nonnegative
  intro K hK
  change deriv (deriv p.output) K < 0
  exact hp.curvature_negative K (by simpa only [interior_Ici, mem_Ioi] using hK)

theorem production_marginal_exists_unique {p : ProductionData}
    (hp : ProductionRegularity p) {y : ℝ} (hy : 0 < y) :
    ∃! K : ℝ, 0 < K ∧ deriv p.output K = y := by
  have hsmall : ∀ᶠ K in nhdsWithin (0 : ℝ) (Ioi 0), y ≤ deriv p.output K :=
    hp.inada_zero (eventually_ge_atTop y)
  have hlarge : ∀ᶠ K in atTop, deriv p.output K < y :=
    hp.marginal_at_infinity (Iio_mem_nhds hy)
  obtain ⟨a, ha0, ha⟩ : ∃ a : ℝ, 0 < a ∧ y ≤ deriv p.output a := by
    obtain ⟨a, ha, ha0⟩ := (hsmall.and self_mem_nhdsWithin).exists
    exact ⟨a, ha0, ha⟩
  obtain ⟨b, hb0, hb⟩ : ∃ b : ℝ, 0 < b ∧ deriv p.output b < y := by
    obtain ⟨b, hb, hb0⟩ := (hlarge.and (eventually_gt_atTop 0)).exists
    exact ⟨b, hb0, hb⟩
  have hab : a < b := by
    by_contra h
    have hba : b ≤ a := le_of_not_gt h
    rcases hba.eq_or_lt with rfl | hba
    · linarith
    · have := production_marginal_strictAntiOn hp hb0 ha0 hba
      linarith
  have hcont : ContinuousOn (deriv p.output) (Icc a b) :=
    (hp.smooth_positive.continuousOn_deriv_of_isOpen isOpen_Ioi (by norm_num)).mono
      (fun _ hx => ha0.trans_le hx.1)
  obtain ⟨K, hKab, hK⟩ := intermediate_value_Icc' hab.le hcont ⟨hb.le, ha⟩
  refine ⟨K, ⟨ha0.trans_le hKab.1, hK⟩, ?_⟩
  intro K' hK'
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have := production_marginal_strictAntiOn hp hK'.1 (ha0.trans_le hKab.1) hlt
    linarith [hK'.2, hK]
  · have := production_marginal_strictAntiOn hp (ha0.trans_le hKab.1) hK'.1 hgt
    linarith [hK'.2, hK]

/-- Positive capital ratio selected by the proved marginal-product existence theorem. -/
def capitalDemandPositive (p : ProductionData) (hp : ProductionRegularity p)
    (r : FirmRate p) : Ioi (0 : ℝ) :=
  ⟨Classical.choose (production_marginal_exists_unique hp
      (y := (r : ℝ) + p.depreciation) (firmRate_add_depreciation_pos p r)),
    (Classical.choose_spec
      (production_marginal_exists_unique hp (y := (r : ℝ) + p.depreciation)
        (firmRate_add_depreciation_pos p r))).1.1⟩

/-- Capital demand as a real-valued function on all `r > -δ`. -/
def capitalDemand (p : ProductionData) (hp : ProductionRegularity p)
    (r : FirmRate p) : ℝ := capitalDemandPositive p hp r

theorem capitalDemand_positive (p : ProductionData) (hp : ProductionRegularity p)
    (r : FirmRate p) : 0 < capitalDemand p hp r :=
  (capitalDemandPositive p hp r).property

theorem capitalDemand_marginal (p : ProductionData) (hp : ProductionRegularity p)
    (r : FirmRate p) :
    deriv p.output (capitalDemand p hp r) = (r : ℝ) + p.depreciation :=
  (Classical.choose_spec
    (production_marginal_exists_unique hp (y := (r : ℝ) + p.depreciation)
      (firmRate_add_depreciation_pos p r))).1.2

theorem capitalDemand_strictAnti (p : ProductionData) (hp : ProductionRegularity p) :
    StrictAnti (capitalDemand p hp) := by
  intro r₁ r₂ hr
  have hm := production_marginal_strictAntiOn hp
  have hy : (r₁ : ℝ) + p.depreciation < (r₂ : ℝ) + p.depreciation := by
    change (r₁ : ℝ) < (r₂ : ℝ) at hr
    linarith
  by_contra hnot
  have hle : capitalDemand p hp r₁ ≤ capitalDemand p hp r₂ := le_of_not_gt hnot
  rcases hle.eq_or_lt with heq | hlt
  · have h₁ := capitalDemand_marginal p hp r₁
    have h₂ := capitalDemand_marginal p hp r₂
    rw [heq] at h₁
    linarith
  · have hanti := hm (capitalDemand_positive p hp r₁)
        (capitalDemand_positive p hp r₂) hlt
    rw [capitalDemand_marginal, capitalDemand_marginal] at hanti
    linarith

theorem capitalDemandPositive_surjective (p : ProductionData)
    (hp : ProductionRegularity p) : Function.Surjective (capitalDemandPositive p hp) := by
  intro K
  let r : FirmRate p := ⟨deriv p.output K - p.depreciation, by
    change -p.depreciation < deriv p.output K - p.depreciation
    linarith [hp.marginal_positive K K.property]⟩
  refine ⟨r, Subtype.ext ?_⟩
  apply (production_marginal_exists_unique hp (hp.marginal_positive K K.property)).unique
  · refine ⟨capitalDemand_positive p hp r, ?_⟩
    change deriv p.output (capitalDemand p hp r) = deriv p.output K
    rw [capitalDemand_marginal]
    simp [r]
  · exact ⟨K.property, rfl⟩

theorem capitalDemand_continuous (p : ProductionData) (hp : ProductionRegularity p) :
    Continuous (capitalDemand p hp) := by
  have hmono : Monotone (fun r => OrderDual.toDual (capitalDemandPositive p hp r)) :=
    fun a b hab => by
      exact (capitalDemand_strictAnti p hp).antitone hab
  have hsurj : Function.Surjective
      (fun r => OrderDual.toDual (capitalDemandPositive p hp r)) :=
    capitalDemandPositive_surjective p hp
  have hc : Continuous (fun r => OrderDual.toDual (capitalDemandPositive p hp r)) :=
    hmono.continuous_of_surjective hsurj
  exact continuous_subtype_val.comp hc

/-- Wage implied by the marginal-product condition. -/
def firmWage (p : ProductionData) (hp : ProductionRegularity p) (r : FirmRate p) : ℝ :=
  p.output (capitalDemand p hp r) -
    capitalDemand p hp r * deriv p.output (capitalDemand p hp r)

/-- Unit-labor profit at a candidate capital-labor ratio. -/
def firmProfit (p : ProductionData) (r : FirmRate p) (K : ℝ) : ℝ :=
  p.output K - ((r : ℝ) + p.depreciation) * K

theorem firmWage_positive (p : ProductionData) (hp : ProductionRegularity p)
    (r : FirmRate p) : 0 < firmWage p hp r := by
  let K := capitalDemand p hp r
  have hconc := production_strictConcaveOn hp
  have hslope := hconc.deriv_lt_slope (x := 0) (y := K) (by simp)
      (by exact (capitalDemand_positive p hp r).le) (capitalDemand_positive p hp r)
      ((hp.smooth_positive.differentiableOn (by norm_num) K
        (capitalDemand_positive p hp r)).differentiableAt
          (Ioi_mem_nhds (capitalDemand_positive p hp r)))
  simp only [slope, hp.output_zero, sub_zero, vsub_eq_sub, smul_eq_mul] at hslope
  dsimp [firmWage, K]
  have hK := capitalDemand_positive p hp r
  dsimp [K] at hslope
  rw [← div_eq_inv_mul] at hslope
  have hslope' := (lt_div_iff₀ hK).mp hslope
  nlinarith

theorem capitalDemand_unique_profit_maximizer (p : ProductionData)
    (hp : ProductionRegularity p) (r : FirmRate p) :
    ∀ K ∈ Ici (0 : ℝ), K ≠ capitalDemand p hp r →
      firmProfit p r K < firmProfit p r (capitalDemand p hp r) := by
  intro K hK hne
  let Kstar := capitalDemand p hp r
  have hKstar : 0 < Kstar := capitalDemand_positive p hp r
  have hconc := production_strictConcaveOn hp
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have hs := hconc.deriv_lt_slope (x := K) (y := Kstar) hK hKstar.le hlt
      ((hp.smooth_positive.differentiableOn (by norm_num) Kstar hKstar).differentiableAt
        (Ioi_mem_nhds hKstar))
    change deriv p.output (capitalDemand p hp r) < slope p.output K (capitalDemand p hp r) at hs
    rw [capitalDemand_marginal] at hs
    simp only [slope, vsub_eq_sub, smul_eq_mul] at hs
    rw [inv_mul_eq_div] at hs
    have hs' := (lt_div_iff₀ (sub_pos.mpr hlt)).mp hs
    dsimp [firmProfit, Kstar]
    linarith
  · have hs := hconc.slope_lt_deriv (x := Kstar) (y := K) hKstar.le hK hgt
      ((hp.smooth_positive.differentiableOn (by norm_num) Kstar hKstar).differentiableAt
        (Ioi_mem_nhds hKstar))
    change slope p.output (capitalDemand p hp r) K <
      deriv p.output (capitalDemand p hp r) at hs
    rw [capitalDemand_marginal] at hs
    simp only [slope, vsub_eq_sub, smul_eq_mul] at hs
    rw [inv_mul_eq_div] at hs
    have hs' := (div_lt_iff₀ (sub_pos.mpr hgt)).mp hs
    dsimp [firmProfit, Kstar]
    linarith

theorem firmWage_continuous (p : ProductionData) (hp : ProductionRegularity p) :
    Continuous (firmWage p hp) := by
  have hfo : Continuous fun r : FirmRate p => p.output (capitalDemand p hp r) := by
    rw [continuous_iff_continuousAt]
    intro r
    exact ((hp.smooth_positive.differentiableOn (by norm_num)
      (capitalDemand p hp r) (capitalDemand_positive p hp r)).differentiableAt
        (Ioi_mem_nhds (capitalDemand_positive p hp r))).continuousAt.comp
          (capitalDemand_continuous p hp).continuousAt
  have hm : Continuous fun r : FirmRate p =>
      capitalDemand p hp r * ((r : ℝ) + p.depreciation) :=
    (capitalDemand_continuous p hp).mul
      (continuous_subtype_val.add continuous_const)
  apply Continuous.congr (hfo.sub hm)
  intro r
  simp only [Pi.sub_apply, firmWage]
  rw [capitalDemand_marginal]

/-- F01: the constructed capital demand solves the marginal equation, is continuous and strictly
decreasing, yields a continuous positive wage, and is the global unique profit-maximizing ratio. -/
theorem capitalDemand_wage_constructed_core (p : ProductionData) (hp : ProductionRegularity p) :
    (∀ r : FirmRate p,
      deriv p.output (capitalDemand p hp r) = (r : ℝ) + p.depreciation ∧
      0 < firmWage p hp r ∧
      ∀ K ∈ Ici (0 : ℝ), K ≠ capitalDemand p hp r →
        firmProfit p r K < firmProfit p r (capitalDemand p hp r)) ∧
    Continuous (capitalDemand p hp) ∧ StrictAnti (capitalDemand p hp) ∧
    Continuous (firmWage p hp) := by
  refine ⟨fun r => ⟨capitalDemand_marginal p hp r, firmWage_positive p hp r,
    capitalDemand_unique_profit_maximizer p hp r⟩,
    capitalDemand_continuous p hp, capitalDemand_strictAnti p hp,
    firmWage_continuous p hp⟩

/-! ## Exact nonvacuity witness -/

/-- The approved production witness `f(K) = √K`, `δ = 1/2`. -/
def sqrtProduction : ProductionData where
  output := Real.sqrt
  depreciation := 1 / 2

theorem sqrtProduction_deriv (K : ℝ) (hK : 0 < K) :
    deriv sqrtProduction.output K = 1 / (2 * Real.sqrt K) := by
  exact (Real.hasDerivAt_sqrt hK.ne').deriv

theorem sqrtProduction_second_deriv (K : ℝ) (hK : 0 < K) :
    deriv (deriv sqrtProduction.output) K =
      -(1 : ℝ) / (4 * (Real.sqrt K) ^ 3) := by
  have hs : HasDerivAt Real.sqrt (1 / (2 * Real.sqrt K)) K :=
    Real.hasDerivAt_sqrt hK.ne'
  have hden : 2 * Real.sqrt K ≠ 0 := by positivity
  have hd := (hasDerivAt_const K (1 : ℝ)).div (hs.const_mul 2) hden
  apply (hd.congr_deriv ?_).congr_of_eventuallyEq ?_ |>.deriv
  · field_simp [Real.sqrt_ne_zero'.mpr hK]
    ring
  · filter_upwards [Ioi_mem_nhds hK] with x hx
    exact sqrtProduction_deriv x hx

theorem sqrtProduction_inada_zero :
    Tendsto (deriv sqrtProduction.output) (nhdsWithin 0 (Ioi 0)) atTop := by
  have hsqrt : Tendsto Real.sqrt (nhdsWithin (0 : ℝ) (Ioi 0))
      (nhdsWithin (0 : ℝ) (Ioi 0)) := by
    refine tendsto_nhdsWithin_iff.mpr ⟨?_, ?_⟩
    · have hc : Tendsto Real.sqrt (nhds (0 : ℝ)) (nhds (Real.sqrt 0)) :=
        Real.continuous_sqrt.continuousAt
      convert hc.mono_left
        (show nhdsWithin (0 : ℝ) (Ioi 0) ≤ nhds 0 from inf_le_left) using 1 <;> simp
    · filter_upwards [self_mem_nhdsWithin] with x hx
      exact Real.sqrt_pos.2 hx
  have hden : Tendsto (fun x : ℝ => 2 * Real.sqrt x)
      (nhdsWithin 0 (Ioi 0)) (nhdsWithin 0 (Ioi 0)) := by
    refine tendsto_nhdsWithin_iff.mpr ⟨?_, ?_⟩
    · simpa using (tendsto_const_nhds.mul (hsqrt.mono_right inf_le_left))
    · filter_upwards [self_mem_nhdsWithin] with x hx
      change 0 < 2 * Real.sqrt x
      have hx' : 0 < x := by simpa only [mem_Ioi] using hx
      exact mul_pos (by norm_num) (Real.sqrt_pos.2 hx')
  apply (tendsto_inv_nhdsGT_zero.comp hden).congr'
  filter_upwards [self_mem_nhdsWithin] with x hx
  rw [sqrtProduction_deriv x hx]
  simp only [Function.comp_apply, one_div]

theorem sqrtProduction_marginal_at_infinity :
    Tendsto (deriv sqrtProduction.output) atTop (nhds 0) := by
  have hden : Tendsto (fun x : ℝ => 2 * Real.sqrt x) atTop atTop :=
    Real.tendsto_sqrt_atTop.const_mul_atTop (by norm_num)
  apply (tendsto_inv_atTop_zero.comp hden).congr'
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
  rw [sqrtProduction_deriv x hx]
  simp only [Function.comp_apply, one_div]

theorem sqrtProduction_regular : ProductionRegularity sqrtProduction where
  output_zero := by simp [sqrtProduction]
  continuous_nonnegative := Real.continuous_sqrt.continuousOn
  smooth_positive := by
    intro K hK
    exact (Real.contDiffAt_sqrt hK.ne').contDiffWithinAt
  marginal_positive := by
    intro K hK
    rw [sqrtProduction_deriv K hK]
    positivity
  curvature_negative := by
    intro K hK
    rw [sqrtProduction_second_deriv K hK]
    apply div_neg_of_neg_of_pos
    · norm_num
    · positivity
  inada_zero := sqrtProduction_inada_zero
  marginal_at_infinity := sqrtProduction_marginal_at_infinity
  depreciation_positive := by norm_num [sqrtProduction]
  depreciation_lt_one := by norm_num [sqrtProduction]

/-- Household and production primitives required before adding an equilibrium witness. -/
structure FullEquilibriumPrimitives where
  household : HouseholdPrimitives
  household_regular : CoreRegularity household
  production : ProductionData
  production_regular : ProductionRegularity production

/-- The square-root firm witness combined with P03 proves the full primitive package nonempty.
P03 is used only here as a consistency witness, not by the general firm theorem. -/
theorem fullEquilibriumPrimitives_nonempty :
    ∃ e : FullEquilibriumPrimitives,
      e.production = sqrtProduction ∧ e.household.beta = 1 / 2 ∧
      e.household.utility = witnessUtility ∧ e.household.income = witnessIncome := by
  obtain ⟨m, hm, hbeta, -, -, -, hu, hi, -⟩ := corePrimitives_nonempty
  exact ⟨⟨m, hm, sqrtProduction, sqrtProduction_regular⟩, rfl, hbeta, hu, hi⟩

end
end Aiyagari1994
