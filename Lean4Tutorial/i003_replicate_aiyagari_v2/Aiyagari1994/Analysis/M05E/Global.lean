import Aiyagari1994.Analysis.M05E.Bounds
import Aiyagari1994.Analysis.M05E.CrossingBridge
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import Mathlib.Probability.Kernel.MeasurableIntegral

/-! Full-space law dynamics and compact-restriction bridges for S05. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- One step of the household law on the full resource space. -/
def householdLawStep (m : HouseholdPrimitives)
    (mu : ProbabilityMeasure Resources) : ProbabilityMeasure Resources :=
  ⟨householdKernel m ∘ₘ (mu : Measure Resources), by infer_instance⟩

/-- Embed a law on a compact resource interval into the full resource space. -/
def M05E.embedLaw (a b : Resources)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ))) : ProbabilityMeasure Resources :=
  mu.map (M05E.intervalResource_continuous a b).measurable.aemeasurable

theorem M05E.embedLaw_injective (a b : Resources) :
    Function.Injective (M05E.embedLaw a b) := by
  intro mu nu h
  apply ProbabilityMeasure.toMeasure_injective
  have hmap : (mu : Measure _).map (M05E.intervalResource a b) =
      (nu : Measure _).map (M05E.intervalResource a b) := by
    exact congrArg ProbabilityMeasure.toMeasure h
  exact (M05E.intervalResource_measurableEmbedding a b).map_injective hmap

private theorem M05E.comp_map_measure
    {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    (mu : Measure α) (f : α → β) (hf : Measurable f)
    (k : Kernel β β) [IsSFiniteKernel k] :
    k ∘ₘ (mu.map f) = (k.comap f hf) ∘ₘ mu := by
  ext s hs
  rw [Measure.bind_apply hs k.aemeasurable,
    Measure.bind_apply hs (Kernel.aemeasurable _)]
  rw [lintegral_map (k.measurable_coe hs) hf]
  rfl

theorem M05E.embedLaw_lawStep
    (m : HouseholdPrimitives) (a b : Resources) (hab : a ≤ b)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ))) :
    M05E.embedLaw a b (lawStep (M05E.restrictedKernel m a b hab) mu) =
      householdLawStep m (M05E.embedLaw a b mu) := by
  apply ProbabilityMeasure.toMeasure_injective
  change ((M05E.restrictedKernel m a b hab ∘ₘ (mu : Measure _)).map
      (M05E.intervalResource a b)) =
    householdKernel m ∘ₘ ((mu : Measure _).map (M05E.intervalResource a b))
  rw [Measure.map_comp _ _ (M05E.intervalResource_continuous a b).measurable]
  rw [← M05E.exactRestrictedKernel_eq_restrictedKernel m a b hab hInvariant]
  rw [M05E.map_exactRestrictedKernel m a b hInvariant]
  exact (M05E.comp_map_measure (mu : Measure _) (M05E.intervalResource a b)
    (M05E.intervalResource_continuous a b).measurable (householdKernel m)).symm

theorem M05E.embedLaw_lawStep_iterate
    (m : HouseholdPrimitives) (a b : Resources) (hab : a ≤ b)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ))) :
    ∀ n, M05E.embedLaw a b
        ((lawStep (M05E.restrictedKernel m a b hab))^[n] mu) =
      (householdLawStep m)^[n] (M05E.embedLaw a b mu) := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [Function.iterate_succ_apply', Function.iterate_succ_apply', ← ih]
      exact M05E.embedLaw_lawStep m a b hab hInvariant _

theorem M05E.embedLaw_support (a b : Resources)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ))) :
    (M05E.embedLaw a b mu : Measure Resources) (Icc a b) = 1 := by
  rw [M05E.embedLaw, ProbabilityMeasure.toMeasure_map,
    Measure.map_apply (M05E.intervalResource_continuous a b).measurable measurableSet_Icc]
  have hpre : (M05E.intervalResource a b) ⁻¹' Icc a b = Set.univ := by
    ext x
    simp only [Set.mem_preimage, Set.mem_Icc, Set.mem_univ, iff_true]
    exact ⟨by exact_mod_cast x.property.1, by exact_mod_cast x.property.2⟩
  rw [hpre, measure_univ]

theorem M05E.invariant_interval_enlarge
    (m : HouseholdPrimitives) (B C : Resources) (hBC : B ≤ C)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
          m.prices.nextResources (assetPolicy m z) l ≤ B)
    (hDrift : ∀ z : Resources, B ≤ z →
      m.prices.nextResources (assetPolicy m z)
        ⟨m.income.upper, m.income_support.ordered, le_rfl⟩ ≤ z) :
    ∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ C →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
          m.prices.nextResources (assetPolicy m z) l ≤ C := by
  intro z hzLower hzC l
  have hnextLower : lowerEffectiveIncome m ≤
      m.prices.nextResources (assetPolicy m z) l := by
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
  refine ⟨hnextLower, ?_⟩
  rcases le_total z B with hzB | hBz
  · exact (hInvariant z hzLower hzB l).2.trans hBC
  · have hlUpper : m.prices.nextResources (assetPolicy m z) l ≤
        m.prices.nextResources (assetPolicy m z)
          ⟨m.income.upper, m.income_support.ordered, le_rfl⟩ := by
      apply Subtype.coe_le_coe.mp
      change m.prices.grossReturn * (assetPolicy m z : ℝ) +
          m.prices.effectiveIncome l ≤
        m.prices.grossReturn * (assetPolicy m z : ℝ) +
          m.prices.effectiveIncome
            ⟨m.income.upper, m.income_support.ordered, le_rfl⟩
      unfold NormalizedPrices.effectiveIncome
      exact add_le_add le_rfl (add_le_add
        (mul_le_mul_of_nonneg_left l.property.2 m.prices.wage_pos.le) le_rfl)
    exact hlUpper.trans ((hDrift z hBz).trans hzC)

def M05E.intervalInclusion (a b c : Resources) (hbc : b ≤ c)
    (x : CI (a : ℝ) (b : ℝ)) : CI (a : ℝ) (c : ℝ) :=
  ⟨x, x.property.1, x.property.2.trans (by exact_mod_cast hbc)⟩

theorem M05E.intervalInclusion_continuous (a b c : Resources) (hbc : b ≤ c) :
    Continuous (M05E.intervalInclusion a b c hbc) := by
  apply Continuous.subtype_mk
  exact continuous_subtype_val

def M05E.liftLaw (a b c : Resources) (hbc : b ≤ c)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ))) :
    ProbabilityMeasure (CI (a : ℝ) (c : ℝ)) :=
  mu.map (M05E.intervalInclusion_continuous a b c hbc).measurable.aemeasurable

theorem M05E.embedLaw_liftLaw (a b c : Resources) (hbc : b ≤ c)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ))) :
    M05E.embedLaw a c (M05E.liftLaw a b c hbc mu) = M05E.embedLaw a b mu := by
  apply ProbabilityMeasure.toMeasure_injective
  change (((mu : Measure _).map (M05E.intervalInclusion a b c hbc)).map
      (M05E.intervalResource a c)) =
    (mu : Measure _).map (M05E.intervalResource a b)
  rw [Measure.map_map (M05E.intervalResource_continuous a c).measurable
    (M05E.intervalInclusion_continuous a b c hbc).measurable]
  congr 1

theorem M05E.liftLaw_invariant
    (m : HouseholdPrimitives) (a b c : Resources) (hab : a ≤ b) (hbc : b ≤ c)
    (hInvB : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b)
    (hInvC : ∀ z : Resources, a ≤ z → z ≤ c → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ c)
    (mu : ProbabilityMeasure (CI (a : ℝ) (b : ℝ)))
    (hmu : lawStep (M05E.restrictedKernel m a b hab) mu = mu) :
    lawStep (M05E.restrictedKernel m a c (hab.trans hbc))
      (M05E.liftLaw a b c hbc mu) = M05E.liftLaw a b c hbc mu := by
  apply M05E.embedLaw_injective a c
  rw [M05E.embedLaw_lawStep m a c (hab.trans hbc) hInvC]
  rw [M05E.embedLaw_liftLaw]
  rw [← M05E.embedLaw_lawStep m a b hab hInvB, hmu]

private def M05E.pullLaw (a b : Resources) (mu : ProbabilityMeasure Resources)
    (hsupp : (mu : Measure Resources) (Icc a b) = 1) :
    ProbabilityMeasure (CI (a : ℝ) (b : ℝ)) :=
  ⟨Measure.comap (M05E.intervalResource a b) (mu : Measure Resources), by
    refine ⟨?_⟩
    rw [(M05E.intervalResource_measurableEmbedding a b).comap_apply,
      Set.image_univ, M05E.range_intervalResource, hsupp]⟩

private theorem M05E.embedLaw_pullLaw (a b : Resources) (mu : ProbabilityMeasure Resources)
    (hsupp : (mu : Measure Resources) (Icc a b) = 1) :
    M05E.embedLaw a b (M05E.pullLaw a b mu hsupp) = mu := by
  apply ProbabilityMeasure.toMeasure_injective
  change (Measure.comap (M05E.intervalResource a b) (mu : Measure Resources)).map
      (M05E.intervalResource a b) = (mu : Measure Resources)
  rw [(M05E.intervalResource_measurableEmbedding a b).map_comap,
    Measure.restrict_eq_self_of_ae_mem]
  apply (ae_mem_iff_measure_eq
    (M05E.intervalResource_measurableEmbedding a b).measurableSet_range.nullMeasurableSet).2
  rw [M05E.range_intervalResource, hsupp, measure_univ]

private def M05E.pointLawFull (x : Resources) : ProbabilityMeasure Resources :=
  ⟨Measure.dirac x, by infer_instance⟩

private theorem M05E.householdLawStep_iterate_measure (m : HouseholdPrimitives)
    (mu : ProbabilityMeasure Resources) :
    ∀ n, (((householdLawStep m)^[n] mu : ProbabilityMeasure Resources) : Measure Resources) =
      (householdKernel m ^ n) ∘ₘ (mu : Measure Resources) := by
  intro n
  induction n with
  | zero =>
      rw [pow_zero]
      exact Measure.id_comp.symm
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      change householdKernel m ∘ₘ
          ((((householdLawStep m)^[n] mu : ProbabilityMeasure Resources) : Measure Resources)) = _
      rw [ih, Measure.comp_assoc]
      have hk : householdKernel m ∘ₖ (householdKernel m ^ n) =
          householdKernel m ^ (n + 1) := (pow_succ' (householdKernel m) n).symm
      rw [hk]

private theorem M05E.householdLawStep_point_measure (m : HouseholdPrimitives) (x : Resources) :
    ∀ n, (((householdLawStep m)^[n] (M05E.pointLawFull x) :
        ProbabilityMeasure Resources) : Measure Resources) = (householdKernel m ^ n) x := by
  intro n
  rw [M05E.householdLawStep_iterate_measure]
  change (householdKernel m ^ n) ∘ₘ Measure.dirac x = _
  exact Measure.dirac_bind (Kernel.measurable _) x

private theorem M05E.iterate_fixed {α : Type*} (F : α → α) (x : α) (hx : F x = x) :
    ∀ n, F^[n] x = x := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih => rw [Function.iterate_succ_apply', ih, hx]

/-- Every deterministic initial resource has weak convergence to the compact stationary law. -/
theorem M05E.pointwise_global_stability
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hnd : IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (B : Resources) (hUpperB : upperEffectiveIncome m ≤ B)
    (hab0 : lowerEffectiveIncome m ≤ B)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
          m.prices.nextResources (assetPolicy m z) l ≤ B)
    (hDrift : ∀ z : Resources, B ≤ z →
      m.prices.nextResources (assetPolicy m z)
        ⟨m.income.upper, m.income_support.ordered, le_rfl⟩ ≤ z)
    (pi : ProbabilityMeasure
      (CI (lowerEffectiveIncome m : ℝ) (B : ℝ)))
    (hpi : lawStep (M05E.restrictedKernel m (lowerEffectiveIncome m) B
      hab0) pi = pi)
    (hallpi : ∀ mu : ProbabilityMeasure
      (CI (lowerEffectiveIncome m : ℝ) (B : ℝ)),
      Tendsto (fun n ↦ (lawStep (M05E.restrictedKernel m
        (lowerEffectiveIncome m) B hab0))^[n] mu) atTop (nhds pi)) :
    ∀ x : Resources, Tendsto
      (fun n ↦ (householdLawStep m)^[n] (M05E.pointLawFull x)) atTop
      (nhds (M05E.embedLaw (lowerEffectiveIncome m) B pi)) := by
  let a := lowerEffectiveIncome m
  have haUpper : a < upperEffectiveIncome m := by
    apply Subtype.coe_lt_coe.mp
    change m.prices.wage * m.income.lower + m.prices.intercept <
      m.prices.wage * m.income.upper + m.prices.intercept
    nlinarith [m.prices.wage_pos, hnd.endpoints_distinct]
  have hab : a ≤ B := hab0
  intro x
  by_cases hax : a ≤ x
  · let C : Resources := max B x
    have hBC : B ≤ C := le_max_left _ _
    have hxC : x ≤ C := le_max_right _ _
    have hInvC := M05E.invariant_interval_enlarge m B C hBC hInvariant hDrift
    obtain ⟨piC, hpiC, hallC⟩ := M05E.economic_compact_stability m hsmooth hnd
      hbetaR C (hUpperB.trans hBC) hInvC
    let xI : CI (a : ℝ) (C : ℝ) := ⟨(x : ℝ), by
      constructor
      · exact_mod_cast hax
      · exact_mod_cast hxC⟩
    let deltaI : ProbabilityMeasure (CI (a : ℝ) (C : ℝ)) :=
      ⟨Measure.dirac xI, by infer_instance⟩
    have hcompact := hallC deltaI
    have hmapped := ProbabilityMeasure.tendsto_map_of_tendsto_of_continuous _ _ hcompact
      (M05E.intervalResource_continuous a C)
    have hdelta : M05E.embedLaw a C deltaI = M05E.pointLawFull x := by
      apply ProbabilityMeasure.toMeasure_injective
      change (Measure.dirac xI).map (M05E.intervalResource a C) = Measure.dirac x
      rw [Measure.map_dirac xI]
      congr 1
    have horbit : (fun n ↦ M05E.embedLaw a C
        ((lawStep (M05E.restrictedKernel m a C (hab.trans hBC)))^[n] deltaI)) =
        fun n ↦ (householdLawStep m)^[n] (M05E.pointLawFull x) := by
      funext n
      rw [M05E.embedLaw_lawStep_iterate m a C (hab.trans hBC) hInvC, hdelta]
    change Tendsto (fun n ↦ M05E.embedLaw a C
      ((lawStep (M05E.restrictedKernel m a C (hab.trans hBC)))^[n] deltaI)) atTop
      (nhds (M05E.embedLaw a C piC)) at hmapped
    rw [horbit] at hmapped
    have hliftInv := M05E.liftLaw_invariant m a B C hab hBC hInvariant hInvC pi hpi
    have hliftConst : Tendsto (fun _ : ℕ ↦ M05E.liftLaw a B C hBC pi) atTop
        (nhds (M05E.liftLaw a B C hBC pi)) := tendsto_const_nhds
    have hliftConv := hallC (M05E.liftLaw a B C hBC pi)
    have hliftOrbit : ∀ n,
        (lawStep (M05E.restrictedKernel m a C (hab.trans hBC)))^[n]
          (M05E.liftLaw a B C hBC pi) = M05E.liftLaw a B C hBC pi :=
      M05E.iterate_fixed _ _ hliftInv
    have hpiCeq : piC = M05E.liftLaw a B C hBC pi := by
      have horbfun : (fun n ↦
          (lawStep (M05E.restrictedKernel m a C (hab.trans hBC)))^[n]
            (M05E.liftLaw a B C hBC pi)) =
          fun _ : ℕ ↦ M05E.liftLaw a B C hBC pi := by
        funext n
        exact hliftOrbit n
      rw [horbfun] at hliftConv
      have hc : Tendsto (fun _ : ℕ ↦ M05E.liftLaw a B C hBC pi) atTop
          (nhds piC) := hliftConv
      exact tendsto_nhds_unique hc hliftConst
    rw [hpiCeq, M05E.embedLaw_liftLaw] at hmapped
    exact hmapped
  · have hxa : x ≤ a := le_of_not_ge hax
    have hxB : x ≤ B := hxa.trans hab
    have hnext : ∀ l : m.income.Labor,
        a ≤ m.prices.nextResources (assetPolicy m x) l ∧
          m.prices.nextResources (assetPolicy m x) l ≤ B := by
      intro l
      have hlow : a ≤ m.prices.nextResources (assetPolicy m x) l := by
        apply Subtype.coe_le_coe.mp
        change m.prices.effectiveIncome
            ⟨m.income.lower, le_rfl, m.income_support.ordered⟩ ≤
          m.prices.grossReturn * (assetPolicy m x : ℝ) + m.prices.effectiveIncome l
        have hi : m.prices.effectiveIncome
            ⟨m.income.lower, le_rfl, m.income_support.ordered⟩ ≤
            m.prices.effectiveIncome l := by
          unfold NormalizedPrices.effectiveIncome
          exact add_le_add
            (mul_le_mul_of_nonneg_left l.property.1 m.prices.wage_pos.le) le_rfl
        exact hi.trans (le_add_of_nonneg_left
          (mul_nonneg m.prices.grossReturn_pos.le (assetPolicy m x).property))
      have haPol : assetPolicy m x ≤ assetPolicy m a := assetPolicy_monotone m hxa
      have hupp : m.prices.nextResources (assetPolicy m x) l ≤
          m.prices.nextResources (assetPolicy m a) l := by
        apply Subtype.coe_le_coe.mp
        change m.prices.grossReturn * (assetPolicy m x : ℝ) + m.prices.effectiveIncome l ≤
          m.prices.grossReturn * (assetPolicy m a : ℝ) + m.prices.effectiveIncome l
        exact add_le_add (mul_le_mul_of_nonneg_left (by exact_mod_cast haPol)
          m.prices.grossReturn_pos.le) le_rfl
      exact ⟨hlow, hupp.trans (hInvariant a le_rfl hab l).2⟩
    let mu1 : ProbabilityMeasure Resources := ⟨householdKernel m x, by infer_instance⟩
    have hsupp1 : (mu1 : Measure Resources) (Icc a B) = 1 := by
      change householdKernel m x (Icc a B) = 1
      rw [M05E.householdKernel_apply m x _ measurableSet_Icc]
      have hpre : (fun l ↦ m.prices.nextResources (assetPolicy m x) l) ⁻¹' Icc a B =
          Set.univ := by
        ext l
        simp only [Set.mem_preimage, Set.mem_Icc, Set.mem_univ, iff_true]
        exact hnext l
      rw [hpre, measure_univ]
    let muI := M05E.pullLaw a B mu1 hsupp1
    have hcompact := hallpi muI
    have hmapped := ProbabilityMeasure.tendsto_map_of_tendsto_of_continuous _ _ hcompact
      (M05E.intervalResource_continuous a B)
    change Tendsto (fun n ↦ M05E.embedLaw a B
      ((lawStep (M05E.restrictedKernel m a B hab))^[n] muI)) atTop
      (nhds (M05E.embedLaw a B pi)) at hmapped
    have hmu1 : M05E.embedLaw a B muI = mu1 := M05E.embedLaw_pullLaw a B mu1 hsupp1
    have horbit : (fun n ↦ M05E.embedLaw a B
        ((lawStep (M05E.restrictedKernel m a B hab))^[n] muI)) =
      fun n ↦ (householdLawStep m)^[n] mu1 := by
      funext n
      rw [M05E.embedLaw_lawStep_iterate m a B hab hInvariant, hmu1]
    rw [horbit] at hmapped
    have hstep : householdLawStep m (M05E.pointLawFull x) = mu1 := by
      apply ProbabilityMeasure.toMeasure_injective
      change householdKernel m ∘ₘ Measure.dirac x = householdKernel m x
      exact Measure.dirac_bind (Kernel.measurable _) x
    have hshift : (fun n ↦ (householdLawStep m)^[n + 1] (M05E.pointLawFull x)) =
        fun n ↦ (householdLawStep m)^[n] mu1 := by
      funext n
      rw [Function.iterate_add_apply]
      simp only [Function.iterate_one, hstep]
    rw [← hshift] at hmapped
    exact (tendsto_add_atTop_iff_nat 1).1 hmapped

private theorem M05E.kernel_pow_markov
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

private theorem M05E.integral_householdLawStep_iterate
    (m : HouseholdPrimitives) (mu : ProbabilityMeasure Resources)
    (f : BoundedContinuousFunction Resources ℝ) :
    ∀ n, (∫ y, f y ∂(((householdLawStep m)^[n] mu :
        ProbabilityMeasure Resources) : Measure Resources)) =
      ∫ x, (∫ y, f y ∂(householdKernel m ^ n) x) ∂(mu : Measure Resources) := by
  intro n
  letI : IsMarkovKernel (householdKernel m ^ n) :=
    M05E.kernel_pow_markov (householdKernel m) n
  rw [M05E.householdLawStep_iterate_measure]
  change (∫ y, f y ∂((householdKernel m ^ n) ∘ₘ (mu : Measure Resources))) = _
  rw [Measure.comp_eq_comp_const_apply]
  exact Kernel.integral_comp (f.integrable _)

/-- Pointwise convergence for every deterministic initial state extends, by bounded dominated
convergence, to weak convergence from every initial probability law. -/
theorem M05E.global_stability_from_points
    (m : HouseholdPrimitives) (pi : ProbabilityMeasure Resources)
    (hpoint : ∀ x : Resources, Tendsto
      (fun n ↦ (householdLawStep m)^[n] (M05E.pointLawFull x)) atTop (nhds pi)) :
    ∀ mu : ProbabilityMeasure Resources,
      Tendsto (fun n ↦ (householdLawStep m)^[n] mu) atTop (nhds pi) := by
  intro mu
  apply ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mpr
  intro f
  have hpointInt : ∀ x : Resources, Tendsto
      (fun n ↦ ∫ y, f y ∂(householdKernel m ^ n) x) atTop
      (nhds (∫ y, f y ∂(pi : Measure Resources))) := by
    intro x
    have hx := ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp (hpoint x) f
    simpa only [M05E.householdLawStep_point_measure] using hx
  have hdom := tendsto_integral_of_dominated_convergence
    (μ := (mu : Measure Resources)) (fun _ ↦ ‖f‖)
    (F := fun n x ↦ ∫ y, f y ∂(householdKernel m ^ n) x)
    (f := fun _ ↦ ∫ y, f y ∂(pi : Measure Resources))
    (fun n ↦ by
      letI : IsMarkovKernel (householdKernel m ^ n) :=
        M05E.kernel_pow_markov (householdKernel m) n
      exact f.continuous.stronglyMeasurable.integral_kernel.aestronglyMeasurable)
    (integrable_const ‖f‖)
    (fun n ↦ Filter.Eventually.of_forall fun x ↦ by
      letI : IsMarkovKernel (householdKernel m ^ n) :=
        M05E.kernel_pow_markov (householdKernel m) n
      have hb := norm_integral_le_of_norm_le_const
        (μ := (householdKernel m ^ n) x)
        (Filter.Eventually.of_forall fun y ↦ f.norm_coe_le_norm y)
      simpa using hb)
    (Filter.Eventually.of_forall hpointInt)
  simp only [integral_const, smul_eq_mul, measureReal_def, measure_univ,
    ENNReal.toReal_one, one_mul] at hdom
  simpa only [M05E.integral_householdLawStep_iterate] using hdom

end
end Aiyagari1994
