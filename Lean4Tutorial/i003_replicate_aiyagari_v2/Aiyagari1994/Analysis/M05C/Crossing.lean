import Aiyagari1994.Stationary.Kernel
import Aiyagari1994.Stationary.LowerTransition
import Mathlib.Probability.Kernel.Composition.Comp

/-! Analytic construction of the common-horizon economic crossing condition. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- The greatest effective income, evaluated at the upper endpoint of labor support. -/
def upperEffectiveIncome (m : HouseholdPrimitives) : Resources :=
  ⟨m.prices.effectiveIncome
      ⟨m.income.upper, m.income_support.ordered, le_rfl⟩,
    m.prices.income_nonneg ⟨m.income.upper, m.income_support.ordered, le_rfl⟩⟩

private def transitionAt (m : HouseholdPrimitives) (l : m.income.Labor)
    (z : Resources) : Resources :=
  m.prices.nextResources (assetPolicy m z) l

private theorem transitionAt_continuous (m : HouseholdPrimitives) (l : m.income.Labor) :
    Continuous (transitionAt m l) := by
  apply Continuous.subtype_mk
  exact (continuous_const.mul
      (continuous_subtype_val.comp (assetPolicy_continuous m))).add continuous_const

private theorem transitionAt_mono_state (m : HouseholdPrimitives) (l : m.income.Labor) :
    Monotone (transitionAt m l) := by
  intro x y hxy
  apply Subtype.coe_le_coe.mp
  change m.prices.grossReturn * (assetPolicy m x : ℝ) + m.prices.effectiveIncome l ≤
    m.prices.grossReturn * (assetPolicy m y : ℝ) + m.prices.effectiveIncome l
  exact add_le_add
    (mul_le_mul_of_nonneg_left (by exact_mod_cast assetPolicy_monotone m hxy)
      m.prices.grossReturn_pos.le) le_rfl

private theorem transitionAt_mono_labor (m : HouseholdPrimitives) (z : Resources) :
    Monotone (fun l : m.income.Labor ↦ transitionAt m l z) := by
  intro l₁ l₂ hl
  apply Subtype.coe_le_coe.mp
  change m.prices.grossReturn * (assetPolicy m z : ℝ) +
      (m.prices.wage * (l₁ : ℝ) + m.prices.intercept) ≤
    m.prices.grossReturn * (assetPolicy m z : ℝ) +
      (m.prices.wage * (l₂ : ℝ) + m.prices.intercept)
  gcongr
  exact m.prices.wage_pos.le

private theorem transitionAt_lower (m : HouseholdPrimitives) (l : m.income.Labor)
    (z : Resources) : lowerEffectiveIncome m ≤ transitionAt m l z := by
  apply Subtype.coe_le_coe.mp
  change m.prices.effectiveIncome
      ⟨m.income.lower, le_rfl, m.income_support.ordered⟩ ≤
    m.prices.grossReturn * (assetPolicy m z : ℝ) + m.prices.effectiveIncome l
  have hinc : m.prices.effectiveIncome
      ⟨m.income.lower, le_rfl, m.income_support.ordered⟩ ≤
      m.prices.effectiveIncome l := by
    unfold NormalizedPrices.effectiveIncome
    exact add_le_add
      (mul_le_mul_of_nonneg_left l.property.1 m.prices.wage_pos.le) le_rfl
  exact hinc.trans (le_add_of_nonneg_left
    (mul_nonneg m.prices.grossReturn_pos.le (assetPolicy m z).property))

private theorem householdKernel_apply (m : HouseholdPrimitives) (z : Resources)
    (s : Set Resources) (hs : MeasurableSet s) :
    householdKernel m z s =
      (m.income.law : Measure m.income.Labor)
        ((fun l ↦ transitionAt m l z) ⁻¹' s) := by
  rw [show householdKernel m z =
      (m.income.law : Measure m.income.Labor).map
        (fun l ↦ transitionAt m l z) by
    ext t ht
    rw [householdKernel, Kernel.map_apply' _ (householdTransition_continuous m).measurable _ ht,
      Kernel.id_prod_apply' _ _ ((householdTransition_continuous m).measurable ht)]
    rw [Kernel.const_apply]
    unfold transitionAt
    have hmeas : Measurable
        (fun l ↦ m.prices.nextResources (assetPolicy m z) l) :=
      ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id)).measurable
    rw [Measure.map_apply hmeas ht]
    rfl]
  unfold transitionAt
  exact Measure.map_apply
    (((householdTransition_continuous m).comp
      (continuous_const.prodMk continuous_id)).measurable) hs

private theorem kernel_pow_lower_bound
    {α : Type*} [MeasurableSpace α] (k : Kernel α α) [IsMarkovKernel k]
    (S : ℕ → Set α) (hS : ∀ n, MeasurableSet (S n))
    (p : ℝ≥0∞) (z : α) (hz : z ∈ S 0)
    (hstep : ∀ n x, x ∈ S n → p ≤ k x (S (n + 1))) :
    ∀ n, p ^ n ≤ (k ^ n) z (S n) := by
  intro n
  induction n with
  | zero =>
      simp only [pow_zero]
      change 1 ≤ Kernel.id z (S 0)
      rw [Kernel.id_apply, Measure.dirac_apply' _ (hS 0)]
      simp [hz]
  | succ n ih =>
      rw [Kernel.pow_succ_apply_eq_lintegral k n z (hS (n + 1))]
      calc
        p ^ (n + 1) = p * p ^ n := by rw [pow_succ']
        _ ≤ p * (k ^ n) z (S n) := by gcongr
        _ = ∫⁻ _x in S n, p ∂((k ^ n) z) := by
          rw [setLIntegral_const]
        _ ≤ ∫⁻ x in S n, k x (S (n + 1)) ∂((k ^ n) z) := by
          exact setLIntegral_mono (Kernel.measurable_coe k (hS (n + 1)))
            (fun x hx ↦ hstep n x hx)
        _ ≤ ∫⁻ x, k x (S (n + 1)) ∂((k ^ n) z) :=
          setLIntegral_le_lintegral _ _

private theorem kernel_pow_isMarkov
    {α : Type*} [MeasurableSpace α] (k : Kernel α α) [IsMarkovKernel k] :
    ∀ n : ℕ, IsMarkovKernel (k ^ n) := by
  intro n
  induction n with
  | zero =>
      change IsMarkovKernel (Kernel.id : Kernel α α)
      infer_instance
  | succ n ih =>
      letI : IsMarkovKernel (k ^ n) := ih
      rw [pow_succ]
      change IsMarkovKernel ((k ^ n) ∘ₖ k)
      infer_instance

private theorem constantShockPath_continuous
    (m : HouseholdPrimitives) (n : ℕ) (B : Resources) :
    Continuous (fun l : m.income.Labor ↦ (transitionAt m l)^[n] B) := by
  induction n with
  | zero => simpa using (continuous_const : Continuous (fun _ : m.income.Labor ↦ B))
  | succ n ih =>
      rw [show (fun l : m.income.Labor ↦ (transitionAt m l)^[n + 1] B) =
          fun l ↦ transitionAt m l ((transitionAt m l)^[n] B) by
        funext l
        rw [Function.iterate_succ_apply']]
      apply Continuous.subtype_mk
      exact (continuous_const.mul
          (continuous_subtype_val.comp ((assetPolicy_continuous m).comp ih))).add
        ((continuous_const.mul continuous_subtype_val).add continuous_const)

private theorem one_step_low_bound
    (m : HouseholdPrimitives) (l₀ : m.income.Labor) (p : ℝ≥0∞)
    (hp : p = (m.income.law : Measure m.income.Labor) {l | (l : ℝ) < (l₀ : ℝ)})
    (b x : Resources) (hxb : x ≤ b) :
    p ≤ householdKernel m x (Icc (lowerEffectiveIncome m) (transitionAt m l₀ b)) := by
  rw [householdKernel_apply m x _ measurableSet_Icc, hp]
  apply measure_mono
  intro l hl
  constructor
  · exact transitionAt_lower m l x
  · exact (transitionAt_mono_labor m x (le_of_lt hl)).trans
      (transitionAt_mono_state m l₀ hxb)

private theorem midpoint_income_bounds
    (m : HouseholdPrimitives) (hnd : IncomeNondegenerate m.income) :
    let d : Resources :=
      ⟨((lowerEffectiveIncome m : ℝ) + (upperEffectiveIncome m : ℝ)) / 2,
        by
          have := (lowerEffectiveIncome m).property
          have := (upperEffectiveIncome m).property
          positivity⟩
    lowerEffectiveIncome m < d ∧ d < upperEffectiveIncome m := by
  dsimp
  have hinc : (lowerEffectiveIncome m : ℝ) < (upperEffectiveIncome m : ℝ) := by
    change m.prices.wage * m.income.lower + m.prices.intercept <
      m.prices.wage * m.income.upper + m.prices.intercept
    nlinarith [m.prices.wage_pos, hnd.endpoints_distinct]
  constructor
  · exact_mod_cast (by linarith : (lowerEffectiveIncome m : ℝ) <
      ((lowerEffectiveIncome m : ℝ) + (upperEffectiveIncome m : ℝ)) / 2)
  · exact_mod_cast (by linarith :
      ((lowerEffectiveIncome m : ℝ) + (upperEffectiveIncome m : ℝ)) / 2 <
        (upperEffectiveIncome m : ℝ))

private theorem kernel_pow_final_lower_bound
    {α : Type*} [MeasurableSpace α] (k : Kernel α α) [IsMarkovKernel k]
    (I T : Set α) (hT : MeasurableSet T)
    (p : ℝ≥0∞) (z : α) (n : ℕ)
    (hfull : (k ^ n) z I = 1) (hstep : ∀ x ∈ I, p ≤ k x T) :
    p ≤ (k ^ (n + 1)) z T := by
  rw [Kernel.pow_succ_apply_eq_lintegral k n z hT]
  calc
    p = p * (k ^ n) z I := by rw [hfull, mul_one]
    _ = ∫⁻ _x in I, p ∂((k ^ n) z) := by rw [setLIntegral_const]
    _ ≤ ∫⁻ x in I, k x T ∂((k ^ n) z) := by
      exact setLIntegral_mono (Kernel.measurable_coe k hT) hstep
    _ ≤ ∫⁻ x, k x T ∂((k ^ n) z) := setLIntegral_le_lintegral _ _

/-- M05C analytic core: endpoint-neighborhood mass and an invariant interval imply a
common-horizon crossing for the actual policy-induced kernel. -/
theorem M05C_economic_crossing_condition
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hnd : IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (B : Resources) (hUpperB : upperEffectiveIncome m ≤ B)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
          m.prices.nextResources (assetPolicy m z) l ≤ B) :
    ∃ (d : Resources) (N : ℕ) (ε : ℝ≥0∞),
      lowerEffectiveIncome m < d ∧ d < upperEffectiveIncome m ∧ 1 ≤ N ∧ 0 < ε ∧
      ε ≤ (householdKernel m ^ N) (lowerEffectiveIncome m) (Icc d B) ∧
      ε ≤ (householdKernel m ^ N) B (Icc (lowerEffectiveIncome m) d) := by
  let d : Resources :=
    ⟨((lowerEffectiveIncome m : ℝ) + (upperEffectiveIncome m : ℝ)) / 2,
      by
        exact div_nonneg (add_nonneg (lowerEffectiveIncome m).property
          (upperEffectiveIncome m).property) (by norm_num)⟩
  have hd := midpoint_income_bounds m hnd
  change lowerEffectiveIncome m < d ∧ d < upperEffectiveIncome m at hd
  have hLowerB : lowerEffectiveIncome m ≤ B := hd.1.le.trans (hd.2.le.trans hUpperB)
  have hconv := (lower_transition_iterates_tendsto m hsmooth hbetaR).2.2 B hLowerB
  have hev : ∀ᶠ n : ℕ in atTop, (lowerTransition m)^[n] B ∈ Iio d :=
    hconv.2 (isOpen_Iio.mem_nhds hd.1)
  rcases (eventually_atTop.1 hev) with ⟨n₀, hn₀⟩
  let N : ℕ := max n₀ 1
  have hNpos : 1 ≤ N := le_max_right _ _
  have hNlow : (lowerTransition m)^[N] B < d := hn₀ N (le_max_left _ _)
  let lmin : m.income.Labor :=
    ⟨m.income.lower, le_rfl, m.income_support.ordered⟩
  have hpathMin : (transitionAt m lmin)^[N] B < d := by
    have heq : transitionAt m lmin = lowerTransition m := by
      funext z
      rfl
    simpa [heq] using hNlow
  let O : Set m.income.Labor :=
    {l | (transitionAt m l)^[N] B < d}
  have hOopen : IsOpen O := by
    exact isOpen_Iio.preimage (constantShockPath_continuous m N B)
  have hlminO : lmin ∈ O := hpathMin
  rcases Metric.isOpen_iff.1 hOopen lmin hlminO with ⟨r, hr, hrO⟩
  let span : ℝ := m.income.upper - m.income.lower
  have hspan : 0 < span := sub_pos.mpr hnd.endpoints_distinct
  let δ : ℝ := min (r / 2) (span / 2)
  have hδ : 0 < δ := lt_min (half_pos hr) (half_pos hspan)
  have hδr : δ < r := (min_le_left _ _).trans_lt (half_lt_self hr)
  have hδspan : δ ≤ span := (min_le_right _ _).trans (half_le_self hspan.le)
  let l₀ : m.income.Labor := ⟨m.income.lower + δ, by
    constructor
    · linarith
    · dsimp [span] at hδspan
      linarith⟩
  have hl₀O : l₀ ∈ O := by
    apply hrO
    rw [Metric.mem_ball]
    change dist (m.income.lower + δ) m.income.lower < r
    simpa [Real.dist_eq, abs_of_pos hδ] using hδr
  have hpath₀ : (transitionAt m l₀)^[N] B < d := hl₀O
  let lowSet : Set m.income.Labor := {l | (l : ℝ) < (l₀ : ℝ)}
  let pLow : ℝ≥0∞ := (m.income.law : Measure m.income.Labor) lowSet
  have hpLow : 0 < pLow := by
    exact hnd.lower_mass δ hδ
  let S : ℕ → Set Resources := fun n ↦
    Icc (lowerEffectiveIncome m) ((transitionAt m l₀)^[n] B)
  have hSmeas : ∀ n, MeasurableSet (S n) := fun _ ↦ measurableSet_Icc
  have hBS : B ∈ S 0 := by
    exact ⟨hLowerB, by simp⟩
  have hlowStep : ∀ n x, x ∈ S n →
      pLow ≤ householdKernel m x (S (n + 1)) := by
    intro n x hx
    have h := one_step_low_bound m l₀ pLow rfl
      ((transitionAt m l₀)^[n] B) x hx.2
    simpa only [S, Function.iterate_succ_apply'] using h
  have hLowPow : pLow ^ N ≤ (householdKernel m ^ N) B (S N) :=
    kernel_pow_lower_bound (householdKernel m) S hSmeas pLow B hBS hlowStep N
  have hSlow : S N ⊆ Icc (lowerEffectiveIncome m) d := by
    intro x hx
    exact ⟨hx.1, hx.2.trans hpath₀.le⟩
  have hLowerCross : pLow ^ N ≤
      (householdKernel m ^ N) B (Icc (lowerEffectiveIncome m) d) :=
    hLowPow.trans (measure_mono hSlow)
  let I : Set Resources := Icc (lowerEffectiveIncome m) B
  have hInvStep : ∀ x ∈ I, (1 : ℝ≥0∞) ≤ householdKernel m x I := by
    intro x hx
    rw [householdKernel_apply m x I measurableSet_Icc]
    have hall : (fun l ↦ transitionAt m l x) ⁻¹' I = Set.univ := by
      ext l
      simp only [mem_preimage, mem_univ, iff_true]
      change lowerEffectiveIncome m ≤ transitionAt m l x ∧ transitionAt m l x ≤ B
      simpa [transitionAt] using hInvariant x hx.1 hx.2 l
    rw [hall, measure_univ]
  have hStartI : lowerEffectiveIncome m ∈ I := ⟨le_rfl, hLowerB⟩
  have hFullLower : (householdKernel m ^ (N - 1)) (lowerEffectiveIncome m) I = 1 := by
    letI : IsMarkovKernel (householdKernel m ^ (N - 1)) :=
      kernel_pow_isMarkov (householdKernel m) (N - 1)
    apply le_antisymm
    · calc
        _ ≤ (householdKernel m ^ (N - 1)) (lowerEffectiveIncome m) Set.univ :=
          measure_mono (subset_univ _)
        _ = 1 := measure_univ
    · have h := kernel_pow_lower_bound (householdKernel m) (fun _ ↦ I)
          (fun _ ↦ measurableSet_Icc) 1 (lowerEffectiveIncome m) hStartI
          (fun _ x hx ↦ hInvStep x hx) (N - 1)
      simpa using h
  let midLabor : ℝ := (m.income.lower + m.income.upper) / 2
  let highSet : Set m.income.Labor := {l | midLabor < (l : ℝ)}
  let pHigh : ℝ≥0∞ := (m.income.law : Measure m.income.Labor) highSet
  have hpHigh : 0 < pHigh := by
    have heq : m.income.upper - span / 2 = midLabor := by
      dsimp [span, midLabor]
      ring
    simpa [pHigh, highSet, heq] using hnd.upper_mass (span / 2) (half_pos hspan)
  have hHighStep : ∀ x ∈ I,
      pHigh ≤ householdKernel m x (Icc d B) := by
    intro x hx
    rw [householdKernel_apply m x _ measurableSet_Icc]
    apply measure_mono
    intro l hl
    constructor
    · apply Subtype.coe_le_coe.mp
      change ((lowerEffectiveIncome m : ℝ) + (upperEffectiveIncome m : ℝ)) / 2 ≤
        m.prices.grossReturn * (assetPolicy m x : ℝ) + m.prices.effectiveIncome l
      have hIncome : ((lowerEffectiveIncome m : ℝ) + (upperEffectiveIncome m : ℝ)) / 2 <
          m.prices.effectiveIncome l := by
        change (m.prices.wage * m.income.lower + m.prices.intercept +
            (m.prices.wage * m.income.upper + m.prices.intercept)) / 2 <
          m.prices.wage * (l : ℝ) + m.prices.intercept
        dsimp [highSet, midLabor] at hl
        have hmul := mul_lt_mul_of_pos_left hl m.prices.wage_pos
        nlinarith
      exact hIncome.le.trans (le_add_of_nonneg_left
        (mul_nonneg m.prices.grossReturn_pos.le (assetPolicy m x).property))
    · simpa [transitionAt] using (hInvariant x hx.1 hx.2 l).2
  have hUpperCross : pHigh ≤
      (householdKernel m ^ N) (lowerEffectiveIncome m) (Icc d B) := by
    have hfinal := kernel_pow_final_lower_bound (householdKernel m) I (Icc d B)
      measurableSet_Icc pHigh (lowerEffectiveIncome m) (N - 1)
      hFullLower hHighStep
    rwa [Nat.sub_add_cancel hNpos] at hfinal
  let ε : ℝ≥0∞ := min (pLow ^ N) pHigh
  have hε : 0 < ε := lt_min (ENNReal.pow_pos hpLow N) hpHigh
  refine ⟨d, N, ε, hd.1, hd.2, hNpos, hε, ?_, ?_⟩
  · exact (min_le_right _ _).trans hUpperCross
  · exact (min_le_left _ _).trans hLowerCross

end
end Aiyagari1994
