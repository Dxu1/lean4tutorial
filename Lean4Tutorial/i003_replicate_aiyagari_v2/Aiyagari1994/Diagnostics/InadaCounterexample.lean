import Aiyagari1994.Household.Policy
import Aiyagari1994.Primitives.UtilityExample
import Aiyagari1994.Analysis.M03F.SlidingIntegral
import Aiyagari1994.Analysis.ConcaveReal
import Mathlib.MeasureTheory.Constructions.UnitInterval
import Mathlib.Analysis.Convex.SpecificFunctions.Pow
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic

/-! The exact continuous-state diagnostic from architecture §5.3. -/
open MeasureTheory ProbabilityTheory Set Filter
open scoped NNReal Topology unitInterval Interval

namespace Aiyagari1994
noncomputable section

abbrev ExactDiagnosticLabor := Labor (2 / 3 : ℝ) (4 / 3 : ℝ)

def exactDiagnosticLaborMap (e : unitInterval) : ExactDiagnosticLabor :=
  ⟨2 / 3 + (2 / 3) * (e : ℝ), by
    constructor
    · have he := e.property.1
      norm_num at he ⊢
      linarith
    · have he := e.property.2
      norm_num at he ⊢
      linarith⟩

theorem exactDiagnosticLaborMap_continuous : Continuous exactDiagnosticLaborMap := by
  apply Continuous.subtype_mk
  fun_prop

def unitIntervalProbability : ProbabilityMeasure unitInterval :=
  ⟨volume, inferInstance⟩

def exactDiagnosticIncome : IncomeData where
  lower := 2 / 3
  upper := 4 / 3
  law := unitIntervalProbability.map (f := exactDiagnosticLaborMap)
    exactDiagnosticLaborMap_continuous.aemeasurable

def exactDiagnosticUtility : UtilityData :=
  ⟨fun c => witnessUtility.utility (Real.sqrt c)⟩

theorem exactDiagnosticUtility_continuous :
    ContinuousOn exactDiagnosticUtility.utility (Ici 0) := by
  simpa [exactDiagnosticUtility, Function.comp_def] using
    (witness_utility_continuous.comp_continuous Real.continuous_sqrt
      (fun c => Real.sqrt_nonneg c)).continuousOn

theorem exactDiagnosticUtility_bounds (c : ℝ) (hc : 0 ≤ c) :
    0 ≤ exactDiagnosticUtility.utility c ∧ exactDiagnosticUtility.utility c < 1 := by
  exact witness_utility_bounds (Real.sqrt c) (Real.sqrt_nonneg c)

theorem exactDiagnosticUtility_strictMono :
    StrictMonoOn exactDiagnosticUtility.utility (Ici 0) := by
  intro x hx y hy hxy
  exact witness_utility_strictMono (Real.sqrt_nonneg x) (Real.sqrt_nonneg y)
    (Real.sqrt_lt_sqrt hx hxy)

theorem exactDiagnosticUtility_strictConcave :
    StrictConcaveOn ℝ (Ici 0) exactDiagnosticUtility.utility := by
  have himage : Real.sqrt '' Ici (0 : ℝ) = Ici 0 := by
    apply Set.Subset.antisymm
    · rintro _ ⟨x, _, rfl⟩
      exact Real.sqrt_nonneg x
    · intro y hy
      refine ⟨y ^ 2, sq_nonneg y, ?_⟩
      rw [Real.sqrt_sq hy]
  have hg : StrictConcaveOn ℝ (Real.sqrt '' Ici (0 : ℝ)) witnessUtility.utility := by
    rw [himage]
    exact witness_utility_strictConcave
  simpa [exactDiagnosticUtility, Function.comp_def] using
    hg.comp Real.strictConcaveOn_sqrt
      (by rw [himage]; exact witness_utility_strictMono)
      (fun x hx y hy h => by
        calc
          x = Real.sqrt x ^ 2 := (Real.sq_sqrt hx).symm
          _ = Real.sqrt y ^ 2 := congrArg (fun t : ℝ => t ^ 2) h
          _ = y := Real.sq_sqrt hy)

theorem exactDiagnosticUtility_base : UtilityBase exactDiagnosticUtility where
  continuous := exactDiagnosticUtility_continuous
  bounded := ⟨1, fun c hc => by
    rw [abs_of_nonneg (exactDiagnosticUtility_bounds c hc).1]
    exact (exactDiagnosticUtility_bounds c hc).2.le⟩
  increasing := exactDiagnosticUtility_strictMono
  concave := exactDiagnosticUtility_strictConcave

def exactDiagnosticMarginal (c : ℝ) : ℝ :=
  1 / (2 * Real.sqrt c * (1 + Real.sqrt c) ^ 2)

theorem exactDiagnosticUtility_hasDerivAt (c : ℝ) (hc : 0 < c) :
    HasDerivAt exactDiagnosticUtility.utility (exactDiagnosticMarginal c) c := by
  have hs : Real.sqrt c ≠ 0 := (Real.sqrt_pos.2 hc).ne'
  have h := (witness_utility_hasDerivAt (Real.sqrt c) (Real.sqrt_nonneg c)).comp c
    (Real.hasDerivAt_sqrt hc.ne')
  change HasDerivAt (witnessUtility.utility ∘ Real.sqrt) (exactDiagnosticMarginal c) c
  apply h.congr_deriv
  unfold exactDiagnosticMarginal
  field_simp

theorem exactDiagnosticUtility_deriv (c : ℝ) (hc : 0 < c) :
    deriv exactDiagnosticUtility.utility c = exactDiagnosticMarginal c :=
  (exactDiagnosticUtility_hasDerivAt c hc).deriv

theorem exactDiagnosticUtility_contDiff (n : ℕ) :
    ContDiffOn ℝ n exactDiagnosticUtility.utility (Ioi 0) := by
  have hs : ContDiffOn ℝ n Real.sqrt (Ioi 0) := fun c hc =>
    (Real.contDiffAt_sqrt (n := (n : WithTop ℕ∞)) hc.ne').contDiffWithinAt
  have hcomp := (witness_utility_contDiff n).comp hs
    (fun c hc => Real.sqrt_pos.2 hc)
  simpa [exactDiagnosticUtility, Function.comp_def] using hcomp

theorem exactDiagnosticMarginal_hasDerivAt (c : ℝ) (hc : 0 < c) :
    HasDerivAt exactDiagnosticMarginal
      (-(1 + 3 * Real.sqrt c) /
        (4 * (Real.sqrt c) ^ 3 * (1 + Real.sqrt c) ^ 3)) c := by
  have hs0 : Real.sqrt c ≠ 0 := (Real.sqrt_pos.2 hc).ne'
  have hs := Real.hasDerivAt_sqrt hc.ne'
  have hden : 2 * Real.sqrt c * (1 + Real.sqrt c) ^ 2 ≠ 0 := by
    positivity
  unfold exactDiagnosticMarginal
  have hd := ((hs.const_mul (2 : ℝ)).mul ((hs.const_add (1 : ℝ)).fun_pow 2))
  have h := (hasDerivAt_const c (1 : ℝ)).div hd hden
  apply h.congr_deriv
  simp only [Pi.mul_apply, Pi.div_apply, Nat.cast_ofNat, Nat.reduceSub,
    zero_mul, one_mul, add_zero]
  field_simp [hs0]
  ring

theorem exactDiagnosticUtility_second_deriv (c : ℝ) (hc : 0 < c) :
    deriv (deriv exactDiagnosticUtility.utility) c =
      -(1 + 3 * Real.sqrt c) /
        (4 * (Real.sqrt c) ^ 3 * (1 + Real.sqrt c) ^ 3) := by
  apply ((exactDiagnosticMarginal_hasDerivAt c hc).congr_of_eventuallyEq ?_).deriv
  filter_upwards [Ioi_mem_nhds hc] with x hx
  exact exactDiagnosticUtility_deriv x hx

theorem exactDiagnostic_relative_risk_aversion (c : ℝ) (hc : 0 < c) :
    -c * deriv (deriv exactDiagnosticUtility.utility) c /
        deriv exactDiagnosticUtility.utility c =
      1 / 2 + Real.sqrt c / (1 + Real.sqrt c) ∧
    1 / 2 + Real.sqrt c / (1 + Real.sqrt c) < 3 / 2 := by
  rw [exactDiagnosticUtility_second_deriv c hc,
    exactDiagnosticUtility_deriv c hc]
  unfold exactDiagnosticMarginal
  have hs0 : Real.sqrt c ≠ 0 := (Real.sqrt_pos.2 hc).ne'
  have hs2 : Real.sqrt c ^ 2 = c := Real.sq_sqrt hc.le
  have hp : 0 < 1 + Real.sqrt c := by positivity
  constructor
  · field_simp
    nlinarith
  · have hfrac : Real.sqrt c / (1 + Real.sqrt c) < 1 :=
      (div_lt_one hp).mpr (by linarith)
    linarith

theorem exactDiagnosticUtility_smooth : UtilitySmooth exactDiagnosticUtility where
  smooth := exactDiagnosticUtility_contDiff 1
  marginal_pos := by
    intro c hc
    rw [exactDiagnosticUtility_deriv c hc]
    unfold exactDiagnosticMarginal
    have := Real.sqrt_pos.2 hc
    positivity

theorem exactDiagnosticUtility_curvature : UtilityCurvature exactDiagnosticUtility where
  smooth := exactDiagnosticUtility_contDiff 2
  risk_bound := ⟨1, by norm_num, 3 / 2, fun c hc => by
    rw [(exactDiagnostic_relative_risk_aversion c (by linarith)).1]
    exact (exactDiagnostic_relative_risk_aversion c (by linarith)).2.le⟩

theorem exactDiagnostic_inada :
    Tendsto exactDiagnosticMarginal (nhdsWithin 0 (Ioi 0)) atTop := by
  let d : ℝ → ℝ := fun c => 2 * Real.sqrt c * (1 + Real.sqrt c) ^ 2
  have hd0 : Tendsto d (nhdsWithin 0 (Ioi 0)) (nhdsWithin 0 (Ioi 0)) := by
    apply tendsto_nhdsWithin_iff.2
    constructor
    · have hc : Continuous d := by
        dsimp [d]
        fun_prop
      have ht : Tendsto d (nhdsWithin 0 (Ioi 0)) (𝓝 (d 0)) :=
        hc.continuousAt.tendsto.mono_left inf_le_left
      simpa [d] using ht
    · filter_upwards [self_mem_nhdsWithin] with c hc
      change 0 < d c
      dsimp [d]
      have := Real.sqrt_pos.2 hc
      positivity
  have hinv := tendsto_inv_nhdsGT_zero.comp hd0
  apply hinv.congr'
  filter_upwards with c
  simp [exactDiagnosticMarginal, d, one_div]

theorem exactDiagnostic_income_support : IncomeSupport exactDiagnosticIncome := by
  constructor <;> norm_num [exactDiagnosticIncome]

def exactDiagnosticOriginalPrices : OriginalPrices exactDiagnosticIncome where
  netRate := 1 / 2
  wage := 3 / 2
  debtLimit := 2
  netRate_gt := by norm_num
  wage_pos := by norm_num
  debtLimit_nonneg := by norm_num
  income_nonneg := by
    intro l
    have hl := l.property.1
    norm_num [exactDiagnosticIncome] at hl ⊢
    linarith

def exactDiagnosticModel : HouseholdPrimitives where
  beta := 1 / 2
  beta_pos := by norm_num
  beta_lt_one := by norm_num
  utility := exactDiagnosticUtility
  utility_base := exactDiagnosticUtility_base
  income := exactDiagnosticIncome
  income_support := exactDiagnostic_income_support
  prices := exactDiagnosticOriginalPrices.normalized

@[simp] theorem exactDiagnostic_beta : exactDiagnosticModel.beta = 1 / 2 := rfl

@[simp] theorem exactDiagnostic_grossReturn :
    exactDiagnosticModel.prices.grossReturn = 3 / 2 := by
  change 1 + (1 / 2 : ℝ) = 3 / 2
  norm_num

@[simp] theorem exactDiagnostic_wage :
    exactDiagnosticModel.prices.wage = 3 / 2 := rfl

@[simp] theorem exactDiagnostic_intercept :
    exactDiagnosticModel.prices.intercept = -1 := by
  change -(1 / 2 : ℝ) * 2 = -1
  norm_num

@[simp] theorem exactDiagnostic_effectiveIncome_map (e : unitInterval) :
    exactDiagnosticModel.prices.effectiveIncome (exactDiagnosticLaborMap e) = (e : ℝ) := by
  simp only [NormalizedPrices.effectiveIncome, exactDiagnostic_wage,
    exactDiagnostic_intercept]
  change (3 / 2 : ℝ) * (2 / 3 + (2 / 3) * (e : ℝ)) + -1 = (e : ℝ)
  ring

@[simp] theorem exactDiagnostic_nextResources_map (a : Resources) (e : unitInterval) :
    exactDiagnosticModel.prices.nextResources a (exactDiagnosticLaborMap e) =
      ⟨3 / 2 * (a : ℝ) + (e : ℝ),
        add_nonneg (mul_nonneg (by norm_num) a.property) e.property.1⟩ := by
  apply Subtype.ext
  simp only [NormalizedPrices.nextResources, exactDiagnostic_grossReturn,
    exactDiagnostic_effectiveIncome_map]

theorem exactDiagnostic_integral_map (f : exactDiagnosticIncome.Labor → ℝ)
    (hf : Continuous f) :
    ∫ l, f l ∂(exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) =
      ∫ e : unitInterval, f (exactDiagnosticLaborMap e) ∂volume := by
  change ∫ l, f l ∂((unitIntervalProbability.map (f := exactDiagnosticLaborMap)
      exactDiagnosticLaborMap_continuous.aemeasurable : ProbabilityMeasure _).toMeasure) = _
  rw [ProbabilityMeasure.toMeasure_map]
  exact MeasureTheory.integral_map exactDiagnosticLaborMap_continuous.aemeasurable
    hf.aestronglyMeasurable

theorem exactDiagnostic_continuation_unit (a : Resources) :
    continuation exactDiagnosticModel (valueFunction exactDiagnosticModel) a =
      ∫ e : unitInterval,
        valueFunction exactDiagnosticModel
          ⟨3 / 2 * (a : ℝ) + (e : ℝ),
            add_nonneg (mul_nonneg (by norm_num) a.property) e.property.1⟩ ∂volume := by
  unfold continuation
  change ∫ l : exactDiagnosticIncome.Labor,
      valueFunction exactDiagnosticModel
        (exactDiagnosticModel.prices.nextResources a l)
      ∂(exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) = _
  rw [exactDiagnostic_integral_map]
  simp only [exactDiagnostic_nextResources_map]
  exact (valueFunction exactDiagnosticModel).continuous.comp
    ((nextResources_continuous exactDiagnosticModel).comp
      (continuous_const.prodMk continuous_id))

theorem unitInterval_integral_eq_interval (F : ℝ → ℝ) :
    ∫ e : unitInterval, F (e : ℝ) ∂volume = ∫ x in (0 : ℝ)..1, F x := by
  have h := unitInterval.measurePreserving_coe.integral_comp
    unitInterval.measurableEmbedding_coe F
  rw [MeasureTheory.integral_Icc_eq_integral_Ioc,
    ← intervalIntegral.integral_of_le (by norm_num)] at h
  exact h

theorem exactDiagnostic_continuation_interval (a : Resources) :
    continuation exactDiagnosticModel (valueFunction exactDiagnosticModel) a =
      ∫ x in (0 : ℝ)..1,
        nonnegativeExtension (valueFunction exactDiagnosticModel)
          (x + 3 / 2 * (a : ℝ)) := by
  rw [exactDiagnostic_continuation_unit]
  rw [← unitInterval_integral_eq_interval]
  apply integral_congr_ae
  filter_upwards with e
  unfold nonnegativeExtension
  congr 1
  apply Subtype.ext
  have hn : 0 ≤ (e : ℝ) + 3 / 2 * (a : ℝ) :=
    add_nonneg e.property.1 (mul_nonneg (by norm_num) a.property)
  calc
    3 / 2 * (a : ℝ) + (e : ℝ) =
        (e : ℝ) + 3 / 2 * (a : ℝ) := by ring
    _ = ((e : ℝ) + 3 / 2 * (a : ℝ)).toNNReal :=
      (Real.coe_toNNReal _ hn).symm

/-- The exact right derivative requested by the continuous-income diagnostic;
the statement is an ordinary derivative because continuity of `V` supplies the
fundamental-theorem-of-calculus hypotheses. -/
theorem exactDiagnostic_sliding_continuation_hasDerivAt :
    HasDerivAt
      (fun a : ℝ => ∫ x in (0 : ℝ)..1,
        nonnegativeExtension (valueFunction exactDiagnosticModel) (3 / 2 * a + x))
      (3 / 2 * (valueFunction exactDiagnosticModel (1 : Resources) -
        valueFunction exactDiagnosticModel (0 : Resources))) 0 := by
  simpa [nonnegativeExtension] using
    sliding_unit_integral_hasDerivAt
      (nonnegativeExtension (valueFunction exactDiagnosticModel))
      ((valueFunction exactDiagnosticModel).continuous.comp continuous_real_toNNReal)
      (3 / 2 : ℝ)

theorem exactDiagnostic_utilityInf : utilityInf exactDiagnosticModel = 0 := by
  apply le_antisymm
  · apply csInf_le (utilityRange_bounded exactDiagnosticModel).1
    refine ⟨(0 : Resources), ?_⟩
    simp [exactDiagnosticModel, exactDiagnosticUtility, witnessUtility]
  · apply le_csInf (utilityRange_nonempty exactDiagnosticModel)
    rintro _ ⟨c, rfl⟩
    exact (exactDiagnosticUtility_bounds c c.property).1

theorem exactDiagnostic_utilitySup_le_one : utilitySup exactDiagnosticModel ≤ 1 := by
  apply csSup_le (utilityRange_nonempty exactDiagnosticModel)
  rintro _ ⟨c, rfl⟩
  exact (exactDiagnosticUtility_bounds c c.property).2.le

theorem exactDiagnostic_value_bounds (z : Resources) :
    0 ≤ valueFunction exactDiagnosticModel z ∧
      valueFunction exactDiagnosticModel z ≤ 2 := by
  have h := valueFunction_bounds exactDiagnosticModel z
  rw [exactDiagnostic_utilityInf] at h
  constructor
  · norm_num at h ⊢
    exact h.1
  · calc
      valueFunction exactDiagnosticModel z ≤
          utilitySup exactDiagnosticModel / (1 - exactDiagnosticModel.beta) := h.2
      _ ≤ 2 := by
        rw [exactDiagnostic_beta]
        have hs := exactDiagnostic_utilitySup_le_one
        norm_num at hs ⊢
        linarith

theorem exactDiagnostic_continuation_sub_le (a : Resources) :
    continuation exactDiagnosticModel (valueFunction exactDiagnosticModel) a -
        continuation exactDiagnosticModel (valueFunction exactDiagnosticModel) 0 ≤
      3 * (a : ℝ) := by
  rw [exactDiagnostic_continuation_interval,
    exactDiagnostic_continuation_interval]
  have h := sliding_unit_integral_sub_le
    (f := nonnegativeExtension (valueFunction exactDiagnosticModel))
    (C := 2) (h := 3 / 2 * (a : ℝ))
    ((valueFunction exactDiagnosticModel).continuous.comp continuous_real_toNNReal)
    (fun x => exactDiagnostic_value_bounds x.toNNReal)
    (mul_nonneg (by norm_num) a.property)
  norm_num at h ⊢
  convert h using 1 <;> ring

theorem exactDiagnostic_marginal_gt_three_halves (z : ℝ)
    (hz : 0 < z) (hzmax : z ≤ 1 / 100) :
    3 / 2 < exactDiagnosticMarginal z := by
  have hspos : 0 < Real.sqrt z := Real.sqrt_pos.2 hz
  have hsle : Real.sqrt z ≤ 1 / 10 := by
    rw [Real.sqrt_le_iff]
    constructor
    · norm_num
    · norm_num
      exact hzmax
  have hsq : (1 + Real.sqrt z) ^ 2 ≤ (11 / 10 : ℝ) ^ 2 := by
    nlinarith [sq_nonneg (1 + Real.sqrt z), sq_nonneg ((11 / 10 : ℝ) -
      (1 + Real.sqrt z))]
  have hden : 2 * Real.sqrt z * (1 + Real.sqrt z) ^ 2 ≤ 121 / 500 := by
    have hfirst : 2 * Real.sqrt z ≤ 1 / 5 := by linarith
    have hmul := mul_le_mul hfirst hsq (sq_nonneg (1 + Real.sqrt z)) (by norm_num)
    norm_num at hmul ⊢
    exact hmul
  have hdenpos : 0 < 2 * Real.sqrt z * (1 + Real.sqrt z) ^ 2 := by positivity
  unfold exactDiagnosticMarginal
  apply (lt_div_iff₀ hdenpos).2
  nlinarith

theorem exactDiagnostic_utility_loss (z a : Resources) (ha : a ≤ z)
    (hz : 0 < z) (hzmax : z ≤ (1 / 100 : Resources)) :
    exactDiagnosticUtility.utility ((z : ℝ) - (a : ℝ)) +
        3 / 2 * (a : ℝ) ≤ exactDiagnosticUtility.utility (z : ℝ) := by
  by_cases ha0 : a = 0
  · subst a
    simp
  have hapos : 0 < (a : ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr ha0)
  have hx : 0 ≤ (z : ℝ) - (a : ℝ) := sub_nonneg.mpr (by exact_mod_cast ha)
  have hxy : (z : ℝ) - (a : ℝ) < (z : ℝ) := by linarith
  have hsec := exactDiagnosticUtility_strictConcave.concaveOn.le_slope_of_hasDerivAt
    hx z.property hxy
    (exactDiagnosticUtility_hasDerivAt (z : ℝ) (by exact_mod_cast hz))
  have hm := exactDiagnostic_marginal_gt_three_halves (z : ℝ)
    (by exact_mod_cast hz) (by exact_mod_cast hzmax)
  rw [slope_def_field] at hsec
  have hsec' : exactDiagnosticMarginal (z : ℝ) ≤
      (exactDiagnosticUtility.utility (z : ℝ) -
        exactDiagnosticUtility.utility ((z : ℝ) - (a : ℝ))) / (a : ℝ) := by
    calc
      _ ≤ (exactDiagnosticUtility.utility (z : ℝ) -
          exactDiagnosticUtility.utility ((z : ℝ) - (a : ℝ))) /
          ((z : ℝ) - ((z : ℝ) - (a : ℝ))) := hsec
      _ = _ := by congr 1 <;> ring
  have hmul := (le_div_iff₀ hapos).mp hsec'
  nlinarith

theorem exactDiagnostic_zero_maximizes (z : Resources)
    (hz : 0 < z) (hzmax : z ≤ (1 / 100 : Resources)) :
    ∀ a : Resources, a ≤ z →
      bellmanObjective exactDiagnosticModel (valueFunction exactDiagnosticModel) z a ≤
        bellmanObjective exactDiagnosticModel (valueFunction exactDiagnosticModel) z 0 := by
  intro a ha
  rw [bellmanObjective_feasible exactDiagnosticModel
    (valueFunction exactDiagnosticModel) z a ha]
  simp only [bellmanObjective, tsub_zero]
  change exactDiagnosticUtility.utility ((z : ℝ) - (a : ℝ)) +
      (1 / 2 : ℝ) * continuation exactDiagnosticModel
        (valueFunction exactDiagnosticModel) a ≤
    exactDiagnosticUtility.utility (z : ℝ) +
      (1 / 2 : ℝ) * continuation exactDiagnosticModel
        (valueFunction exactDiagnosticModel) 0
  have hu := exactDiagnostic_utility_loss z a ha hz hzmax
  have hc := exactDiagnostic_continuation_sub_le a
  linarith

theorem exactDiagnostic_assetPolicy_eq_zero (z : Resources)
    (hz : 0 < z) (hzmax : z ≤ (1 / 100 : Resources)) :
    assetPolicy exactDiagnosticModel z = 0 := by
  have hopt : AssetOptimal exactDiagnosticModel z 0 :=
    (assetOptimal_iff_maximizes exactDiagnosticModel z 0).2
      ⟨bot_le, exactDiagnostic_zero_maximizes z hz hzmax⟩
  exact assetOptimal_unique exactDiagnosticModel z _ _
    (assetPolicy_optimal exactDiagnosticModel z) hopt

theorem exactDiagnostic_labor_mean :
  ∫ l : exactDiagnosticIncome.Labor, (l : ℝ)
      ∂(exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) = 1 := by
  rw [exactDiagnostic_integral_map _ continuous_subtype_val]
  change ∫ e : unitInterval, (2 / 3 + (2 / 3) * (e : ℝ)) ∂volume = 1
  calc
    _ = ∫ x in (0 : ℝ)..1, 2 / 3 + (2 / 3) * x :=
      unitInterval_integral_eq_interval _
    _ = 1 := by
      rw [intervalIntegral.integral_add intervalIntegrable_const
        (intervalIntegral.intervalIntegrable_id.const_mul (2 / 3 : ℝ))]
      rw [intervalIntegral.integral_const_mul]
      norm_num [integral_id]

theorem exactDiagnostic_mean_one : LaborMeanOne exactDiagnosticIncome :=
  ⟨exactDiagnostic_labor_mean⟩

theorem exactDiagnostic_affine_income_law :
    Measure.map (fun l : exactDiagnosticIncome.Labor => 3 / 2 * (l : ℝ) - 1)
      (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) =
      volume.restrict (Icc (0 : ℝ) 1) := by
  change Measure.map (fun l : ExactDiagnosticLabor => 3 / 2 * (l : ℝ) - 1)
      (Measure.map exactDiagnosticLaborMap (volume : Measure unitInterval)) = _
  rw [Measure.map_map (by fun_prop) exactDiagnosticLaborMap_continuous.measurable]
  calc
    Measure.map ((fun l : ExactDiagnosticLabor => 3 / 2 * (l : ℝ) - 1) ∘
        exactDiagnosticLaborMap)
        (volume : Measure unitInterval) =
        Measure.map (fun e : unitInterval => (e : ℝ)) volume := by
          congr 1
          funext e
          dsimp [exactDiagnosticLaborMap]
          ring
    _ = volume.restrict (Icc (0 : ℝ) 1) :=
      unitInterval.measurePreserving_coe.map_eq

theorem exactDiagnostic_affine_lt_measure (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor)
        {l | 3 / 2 * (l : ℝ) - 1 < t} = ENNReal.ofReal t := by
  have h := congrArg (fun μ : Measure ℝ => μ (Iio t))
    exactDiagnostic_affine_income_law
  rw [Measure.map_apply
    (μ := (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor))
    (f := fun l : exactDiagnosticIncome.Labor => 3 / 2 * (l : ℝ) - 1)
    ((continuous_const.mul continuous_subtype_val).sub continuous_const).measurable
    measurableSet_Iio] at h
  rw [Measure.restrict_apply measurableSet_Iio] at h
  have hi : Icc (0 : ℝ) 1 ∩ Iio t = Ico 0 t := by
    ext x
    simp only [mem_inter_iff, mem_Icc, mem_Iio, mem_Ico]
    constructor
    · rintro ⟨⟨hx0, _⟩, hxt⟩
      exact ⟨hx0, hxt⟩
    · rintro ⟨hx0, hxt⟩
      exact ⟨⟨hx0, hxt.le.trans ht1⟩, hxt⟩
  rw [inter_comm, hi, Real.volume_Ico] at h
  convert h using 1
  · congr 1
  · simp

theorem exactDiagnostic_affine_gt_measure (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor)
        {l | t < 3 / 2 * (l : ℝ) - 1} = ENNReal.ofReal (1 - t) := by
  have h := congrArg (fun μ : Measure ℝ => μ (Ioi t))
    exactDiagnostic_affine_income_law
  rw [Measure.map_apply
    (μ := (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor))
    (f := fun l : exactDiagnosticIncome.Labor => 3 / 2 * (l : ℝ) - 1)
    ((continuous_const.mul continuous_subtype_val).sub continuous_const).measurable
    measurableSet_Ioi] at h
  rw [Measure.restrict_apply measurableSet_Ioi] at h
  have hi : Icc (0 : ℝ) 1 ∩ Ioi t = Ioc t 1 := by
    ext x
    simp only [mem_inter_iff, mem_Icc, mem_Ioi, mem_Ioc]
    constructor
    · rintro ⟨⟨_, hx1⟩, htx⟩
      exact ⟨htx, hx1⟩
    · rintro ⟨htx, hx1⟩
      exact ⟨⟨ht0.trans htx.le, hx1⟩, htx⟩
  rw [inter_comm, hi, Real.volume_Ioc] at h
  convert h using 1
  congr 1

theorem exactDiagnostic_income_nondegenerate :
    IncomeNondegenerate exactDiagnosticIncome where
  endpoints_distinct := by norm_num [exactDiagnosticIncome]
  lower_mass := by
    intro ε hε
    let d : ℝ := min (1 / 2) (3 / 2 * ε)
    have hd0 : 0 < d := lt_min (by norm_num) (mul_pos (by norm_num) hε)
    have hd1 : d ≤ 1 := (min_le_left _ _).trans (by norm_num)
    have hm := exactDiagnostic_affine_lt_measure d hd0.le hd1
    have hsub : {l : exactDiagnosticIncome.Labor | 3 / 2 * (l : ℝ) - 1 < d} ⊆
        {l | (l : ℝ) < exactDiagnosticIncome.lower + ε} := by
      intro l hl
      change (l : ℝ) < 2 / 3 + ε
      have hdε : d ≤ 3 / 2 * ε := min_le_right _ _
      norm_num at hl hdε ⊢
      linarith
    exact lt_of_lt_of_le (by rw [hm]; exact ENNReal.ofReal_pos.mpr hd0)
      (measure_mono hsub)
  upper_mass := by
    intro ε hε
    let d : ℝ := min (1 / 2) (3 / 2 * ε)
    let t : ℝ := 1 - d
    have hd0 : 0 < d := lt_min (by norm_num) (mul_pos (by norm_num) hε)
    have hd1 : d ≤ 1 := (min_le_left _ _).trans (by norm_num)
    have ht0 : 0 ≤ t := sub_nonneg.mpr hd1
    have ht1 : t ≤ 1 := by dsimp [t]; linarith
    have hm := exactDiagnostic_affine_gt_measure t ht0 ht1
    have hsub : {l : exactDiagnosticIncome.Labor | t < 3 / 2 * (l : ℝ) - 1} ⊆
        {l | exactDiagnosticIncome.upper - ε < (l : ℝ)} := by
      intro l hl
      change 4 / 3 - ε < (l : ℝ)
      have hdε : d ≤ 3 / 2 * ε := min_le_right _ _
      dsimp [t] at hl
      norm_num at hl hdε ⊢
      linarith
    have htd : 1 - t = d := by dsimp [t]; ring
    rw [htd] at hm
    exact lt_of_lt_of_le (by rw [hm]; exact ENNReal.ofReal_pos.mpr hd0)
      (measure_mono hsub)

theorem exactDiagnostic_core_regular : CoreRegularity exactDiagnosticModel := by
  refine ⟨exactDiagnosticUtility_smooth, exactDiagnosticUtility_curvature, ?_, ?_⟩
  · simpa [exactDiagnosticModel] using exactDiagnostic_income_nondegenerate
  · simpa [exactDiagnosticModel] using exactDiagnostic_mean_one

theorem exactDiagnostic_effectiveIncome (l : exactDiagnosticIncome.Labor) :
    exactDiagnosticModel.prices.effectiveIncome l = 3 / 2 * (l : ℝ) - 1 := by
  change (3 / 2 : ℝ) * (l : ℝ) + (-(1 / 2 : ℝ) * 2) =
    3 / 2 * (l : ℝ) - 1
  ring

def exactDiagnosticLowerLabor : exactDiagnosticIncome.Labor :=
  ⟨2 / 3, by norm_num [exactDiagnosticIncome]⟩

theorem exactDiagnostic_minimum_income_zero :
    exactDiagnosticModel.prices.effectiveIncome exactDiagnosticLowerLabor = 0 := by
  rw [exactDiagnostic_effectiveIncome]
  norm_num [exactDiagnosticLowerLabor]

theorem exactDiagnostic_zero_income_no_atom :
    Measure.map (fun l : exactDiagnosticIncome.Labor =>
        exactDiagnosticModel.prices.effectiveIncome l)
      (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) {0} = 0 := by
  have heq : (fun l : exactDiagnosticIncome.Labor =>
      exactDiagnosticModel.prices.effectiveIncome l) =
      (fun l : exactDiagnosticIncome.Labor => 3 / 2 * (l : ℝ) - 1) := by
    funext l
    exact exactDiagnostic_effectiveIncome l
  rw [heq, exactDiagnostic_affine_income_law]
  simp

/-- D01: exact atom-free uniform-income diagnostic. -/
theorem inada_without_atom_binding_example :
    CoreRegularity exactDiagnosticModel ∧
    exactDiagnosticOriginalPrices.netRate = 1 / 2 ∧
    exactDiagnosticOriginalPrices.wage = 3 / 2 ∧
    exactDiagnosticOriginalPrices.debtLimit = 2 ∧
    exactDiagnosticModel.beta = 1 / 2 ∧
    exactDiagnosticModel.prices.grossReturn = 3 / 2 ∧
    (∀ l : exactDiagnosticIncome.Labor,
      exactDiagnosticModel.prices.effectiveIncome l = 3 / 2 * (l : ℝ) - 1) ∧
    Measure.map (fun l : exactDiagnosticIncome.Labor =>
        exactDiagnosticModel.prices.effectiveIncome l)
      (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) =
        volume.restrict (Icc (0 : ℝ) 1) ∧
    exactDiagnosticModel.prices.effectiveIncome exactDiagnosticLowerLabor = 0 ∧
    Measure.map (fun l : exactDiagnosticIncome.Labor =>
        exactDiagnosticModel.prices.effectiveIncome l)
      (exactDiagnosticIncome.law : Measure exactDiagnosticIncome.Labor) {0} = 0 ∧
    exactDiagnosticUtility.utility 0 = 0 ∧
    (∀ c : ℝ, 0 < c →
      deriv exactDiagnosticUtility.utility c = exactDiagnosticMarginal c) ∧
    Tendsto exactDiagnosticMarginal (nhdsWithin 0 (Ioi 0)) atTop ∧
    (∀ z : Resources, 0 ≤ valueFunction exactDiagnosticModel z ∧
      valueFunction exactDiagnosticModel z ≤ 2) ∧
    (∀ z : Resources, 0 < z → z ≤ (1 / 100 : Resources) →
      assetPolicy exactDiagnosticModel z = 0) := by
  refine ⟨exactDiagnostic_core_regular, rfl, rfl, rfl, rfl,
    exactDiagnostic_grossReturn, exactDiagnostic_effectiveIncome, ?_,
    exactDiagnostic_minimum_income_zero, exactDiagnostic_zero_income_no_atom,
    ?_, exactDiagnosticUtility_deriv, exactDiagnostic_inada, exactDiagnostic_value_bounds,
    exactDiagnostic_assetPolicy_eq_zero⟩
  · have heq : (fun l : exactDiagnosticIncome.Labor =>
        exactDiagnosticModel.prices.effectiveIncome l) =
        (fun l : exactDiagnosticIncome.Labor => 3 / 2 * (l : ℝ) - 1) := by
      funext l
      exact exactDiagnostic_effectiveIncome l
    rw [heq]
    exact exactDiagnostic_affine_income_law
  · norm_num [exactDiagnosticUtility, witnessUtility]

end
end Aiyagari1994
