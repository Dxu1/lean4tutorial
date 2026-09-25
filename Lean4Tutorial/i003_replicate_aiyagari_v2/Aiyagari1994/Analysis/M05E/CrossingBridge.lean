import Aiyagari1994.Analysis.M05E.RestrictedKernel

/-! Conversion of S03 event probabilities into S04 test-function crossing bounds. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

private theorem M05E.integral_lower_of_upper_event
    {a b : ℝ} (hab : a ≤ b) (mu : ProbabilityMeasure (CI a b))
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f)
    (d : CI a b) (eps : ℝ) (heps : 0 ≤ eps)
    (hprob : ENNReal.ofReal eps ≤ (mu : Measure _) (Ici d)) :
    eps * f d + (1 - eps) * f ⟨a, le_rfl, hab⟩ ≤
      ∫ y, f y ∂(mu : Measure _) := by
  let lo : CI a b := ⟨a, le_rfl, hab⟩
  have hfd : f lo ≤ f d := hf d.property.1
  have hnonneg : 0 ≤ f d - f lo := sub_nonneg.mpr hfd
  have hmonoInt :
      ∫ y, (Ici d).indicator (fun _ ↦ f d - f lo) y ∂(mu : Measure _) ≤
        ∫ y, (f y - f lo) ∂(mu : Measure _) := by
    apply integral_mono_ae
    · exact (integrable_const (f d - f lo)).indicator measurableSet_Ici
    · exact (f.integrable _).sub (integrable_const _)
    · filter_upwards [] with y
      by_cases hy : y ∈ Ici d
      · rw [Set.indicator_of_mem hy]
        exact sub_le_sub_right (hf hy) _
      · simp only [Set.indicator, hy, ↓reduceIte]
        exact sub_nonneg.mpr (hf y.property.1)
  have hmass : eps ≤ ((mu : Measure _) (Ici d)).toReal := by
    rw [← ENNReal.toReal_ofReal heps]
    exact ENNReal.toReal_mono (measure_ne_top _ _) hprob
  have hscale : eps * (f d - f lo) ≤
      ((mu : Measure _) (Ici d)).toReal * (f d - f lo) :=
    mul_le_mul_of_nonneg_right hmass hnonneg
  rw [integral_indicator measurableSet_Ici, setIntegral_const,
    smul_eq_mul, measureReal_def] at hmonoInt
  have htotal : (∫ y, (f y - f lo) ∂(mu : Measure _)) =
      (∫ y, f y ∂(mu : Measure _)) - f lo := by
    rw [integral_sub (f.integrable _) (integrable_const _), integral_const, smul_eq_mul]
    simp
  rw [htotal] at hmonoInt
  dsimp [lo] at *
  nlinarith

private theorem M05E.integral_upper_of_lower_event
    {a b : ℝ} (hab : a ≤ b) (mu : ProbabilityMeasure (CI a b))
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f)
    (d : CI a b) (eps : ℝ) (heps : 0 ≤ eps)
    (hprob : ENNReal.ofReal eps ≤ (mu : Measure _) (Iic d)) :
    (∫ y, f y ∂(mu : Measure _)) ≤
      eps * f d + (1 - eps) * f ⟨b, hab, le_rfl⟩ := by
  let hi : CI a b := ⟨b, hab, le_rfl⟩
  have hfd : f d ≤ f hi := hf d.property.2
  have hnonneg : 0 ≤ f hi - f d := sub_nonneg.mpr hfd
  have hmonoInt :
      ∫ y, (Iic d).indicator (fun _ ↦ f hi - f d) y ∂(mu : Measure _) ≤
        ∫ y, (f hi - f y) ∂(mu : Measure _) := by
    apply integral_mono_ae
    · exact (integrable_const (f hi - f d)).indicator measurableSet_Iic
    · exact (integrable_const _).sub (f.integrable _)
    · filter_upwards [] with y
      by_cases hy : y ∈ Iic d
      · rw [Set.indicator_of_mem hy]
        exact sub_le_sub_left (hf hy) _
      · simp only [Set.indicator, hy, ↓reduceIte]
        exact sub_nonneg.mpr (hf y.property.2)
  have hmass : eps ≤ ((mu : Measure _) (Iic d)).toReal := by
    rw [← ENNReal.toReal_ofReal heps]
    exact ENNReal.toReal_mono (measure_ne_top _ _) hprob
  have hscale : eps * (f hi - f d) ≤
      ((mu : Measure _) (Iic d)).toReal * (f hi - f d) :=
    mul_le_mul_of_nonneg_right hmass hnonneg
  rw [integral_indicator measurableSet_Iic, setIntegral_const,
    smul_eq_mul, measureReal_def] at hmonoInt
  have htotal : (∫ y, (f hi - f y) ∂(mu : Measure _)) =
      f hi - ∫ y, f y ∂(mu : Measure _) := by
    rw [integral_sub (integrable_const _) (f.integrable _), integral_const, smul_eq_mul]
    simp
  rw [htotal] at hmonoInt
  dsimp [hi] at *
  nlinarith

private theorem M05E.kernel_pow_isMarkov
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
      exact Kernel.IsMarkovKernel.comp (k ^ n) k

private theorem M05E.testStep_iterate_eq_integral_pow
    {a b : ℝ} (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (f : BoundedContinuousFunction (CI a b) ℝ) :
    ∀ (n : ℕ) (x : CI a b),
      (testStep k hFeller)^[n] f x = ∫ y, f y ∂(k ^ n) x := by
  intro n
  induction n with
  | zero =>
      intro x
      simp only [Function.iterate_zero_apply, pow_zero]
      change f x = ∫ y, f y ∂Measure.dirac x
      exact (integral_dirac f x).symm
  | succ n ih =>
      intro x
      letI : IsMarkovKernel (k ^ n) := M05E.kernel_pow_isMarkov k n
      letI : IsMarkovKernel (k ^ (n + 1)) := M05E.kernel_pow_isMarkov k (n + 1)
      rw [Function.iterate_succ_apply']
      change (∫ y, (testStep k hFeller)^[n] f y ∂k x) = _
      simp_rw [ih]
      rw [pow_succ]
      symm
      exact Kernel.integral_comp (f.integrable _)

/-- S03's event crossing implies exactly the test-function crossing interface required by S04
for the compact economic restriction. -/
theorem M05E.economic_compact_stability
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hnd : IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (B : Resources) (hUpperB : upperEffectiveIncome m ≤ B)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
          m.prices.nextResources (assetPolicy m z) l ≤ B) :
    ∃ pi : ProbabilityMeasure (CI (lowerEffectiveIncome m : ℝ) (B : ℝ)),
      lawStep (M05E.restrictedKernel m (lowerEffectiveIncome m) B
        (le_trans (le_of_lt (by
          apply Subtype.coe_lt_coe.mp
          change m.prices.wage * m.income.lower + m.prices.intercept <
            m.prices.wage * m.income.upper + m.prices.intercept
          nlinarith [m.prices.wage_pos, hnd.endpoints_distinct])) hUpperB)) pi = pi ∧
      ∀ mu : ProbabilityMeasure (CI (lowerEffectiveIncome m : ℝ) (B : ℝ)),
        Tendsto (fun n ↦
          (lawStep (M05E.restrictedKernel m (lowerEffectiveIncome m) B
            (le_trans (le_of_lt (by
              apply Subtype.coe_lt_coe.mp
              change m.prices.wage * m.income.lower + m.prices.intercept <
                m.prices.wage * m.income.upper + m.prices.intercept
              nlinarith [m.prices.wage_pos, hnd.endpoints_distinct])) hUpperB)))^[n] mu)
          atTop (nhds pi) := by
  let a := lowerEffectiveIncome m
  have hab : a ≤ B := (le_trans (le_of_lt (show a < upperEffectiveIncome m from by
    have h := hnd.endpoints_distinct
    apply Subtype.coe_lt_coe.mp
    change m.prices.wage * m.income.lower + m.prices.intercept <
      m.prices.wage * m.income.upper + m.prices.intercept
    nlinarith [m.prices.wage_pos])) hUpperB)
  let k := M05E.restrictedKernel m a B hab
  letI : IsMarkovKernel k := M05E.restrictedKernel_isMarkov m a B hab
  have hFeller : ∀ f : BoundedContinuousFunction (CI (a : ℝ) (B : ℝ)) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x) := by
    exact M05E.restrictedKernel_feller m a B hab
  have hMono : ∀ f : BoundedContinuousFunction (CI (a : ℝ) (B : ℝ)) ℝ,
      Monotone f → Monotone (fun x ↦ ∫ y, f y ∂k x) := by
    exact M05E.restrictedKernel_monotone m a B hab
  obtain ⟨d, N, epsE, had, hdUpper, hN, hepsE,
      hcrossLower, hcrossUpper⟩ :=
    economic_crossing_condition m hsmooth hnd hbetaR B hUpperB hInvariant
  have hdB : d ≤ B := hdUpper.le.trans hUpperB
  let dI : CI (a : ℝ) (B : ℝ) := ⟨(d : ℝ), by
    constructor
    · exact_mod_cast had.le
    · exact_mod_cast hdB⟩
  let lo : CI (a : ℝ) (B : ℝ) := ⟨(a : ℝ), le_rfl, by exact_mod_cast hab⟩
  let hi : CI (a : ℝ) (B : ℝ) := ⟨(B : ℝ), by exact_mod_cast hab, le_rfl⟩
  have hpow := M05E.map_exactRestrictedKernel_pow m a B hInvariant N
  rw [M05E.exactRestrictedKernel_eq_restrictedKernel m a B hab hInvariant] at hpow
  have hLowSet : (M05E.intervalResource a B) ⁻¹' Icc d B = Ici dI := by
    ext x
    simp only [Set.mem_preimage, Set.mem_Icc, Set.mem_Ici]
    constructor
    · exact fun hx ↦ by exact_mod_cast hx.1
    · intro hx
      exact ⟨by exact_mod_cast hx, by exact_mod_cast x.property.2⟩
  have hHighSet : (M05E.intervalResource a B) ⁻¹' Icc a d = Iic dI := by
    ext x
    simp only [Set.mem_preimage, Set.mem_Icc, Set.mem_Iic]
    constructor
    · exact fun hx ↦ by exact_mod_cast hx.2
    · intro hx
      exact ⟨by exact_mod_cast x.property.1, by exact_mod_cast hx⟩
  have hprobLow : epsE ≤ (k ^ N) lo (Ici dI) := by
    have hlo : M05E.intervalResource a B lo = a := by
      apply Subtype.ext
      rfl
    change epsE ≤ (householdKernel m ^ N) a (Icc d B) at hcrossLower
    rw [← hlo] at hcrossLower
    apply hcrossLower.trans_eq
    have heq := congrArg (fun K : Kernel (CI (a : ℝ) (B : ℝ)) Resources ↦
      K lo (Icc d B)) hpow
    rw [Kernel.map_apply' _ (M05E.intervalResource_continuous a B).measurable _ measurableSet_Icc,
      hLowSet, Kernel.comap_apply'] at heq
    simpa [k] using heq.symm
  have hprobHigh : epsE ≤ (k ^ N) hi (Iic dI) := by
    have hhi : M05E.intervalResource a B hi = B := by
      apply Subtype.ext
      rfl
    rw [← hhi] at hcrossUpper
    apply hcrossUpper.trans_eq
    have heq := congrArg (fun K : Kernel (CI (a : ℝ) (B : ℝ)) Resources ↦
      K hi (Icc a d)) hpow
    rw [Kernel.map_apply' _ (M05E.intervalResource_continuous a B).measurable _ measurableSet_Icc,
      hHighSet, Kernel.comap_apply'] at heq
    simpa [k] using heq.symm
  letI : IsMarkovKernel (k ^ N) := M05E.kernel_pow_isMarkov k N
  have hepsTop : epsE ≠ ∞ := by
    exact ne_top_of_le_ne_top (measure_ne_top _ _) hprobLow
  let eps := epsE.toReal
  have heps0 : 0 < eps := ENNReal.toReal_pos hepsE.ne' hepsTop
  have heps1 : eps ≤ 1 := by
    have hmeasure : (k ^ N) lo (Ici dI) ≤ 1 := by
      calc
        (k ^ N) lo (Ici dI) ≤ (k ^ N) lo Set.univ := measure_mono (subset_univ _)
        _ = 1 := measure_univ
    have hle : epsE ≤ 1 := hprobLow.trans hmeasure
    simpa [eps] using ENNReal.toReal_mono (by norm_num : (1 : ℝ≥0∞) ≠ ∞) hle
  have hCross : ∀ f : BoundedContinuousFunction (CI (a : ℝ) (B : ℝ)) ℝ,
      Monotone f →
      eps * f dI + (1 - eps) * f lo ≤ (testStep k hFeller)^[N] f lo ∧
      (testStep k hFeller)^[N] f hi ≤ eps * f dI + (1 - eps) * f hi := by
    intro f hf
    have htestLo := M05E.testStep_iterate_eq_integral_pow k hFeller f N lo
    have htestHi := M05E.testStep_iterate_eq_integral_pow k hFeller f N hi
    rw [htestLo, htestHi]
    have hof : ENNReal.ofReal eps = epsE := ENNReal.ofReal_toReal hepsTop
    constructor
    · apply M05E.integral_lower_of_upper_event (by exact_mod_cast hab)
        ⟨(k ^ N) lo, by infer_instance⟩ f hf dI eps heps0.le
      simpa [hof] using hprobLow
    · apply M05E.integral_upper_of_lower_event (by exact_mod_cast hab)
        ⟨(k ^ N) hi, by infer_instance⟩ f hf dI eps heps0.le
      simpa [hof] using hprobHigh
  have hs := compact_monotone_feller_stability (by exact_mod_cast hab) k hFeller hMono
    dI N hN eps heps0 heps1 hCross
  exact ⟨hs.1.choose, hs.1.choose_spec.1.1, hs.1.choose_spec.1.2⟩

end
end Aiyagari1994
