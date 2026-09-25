import Aiyagari1994.Stationary.Crossing
import Aiyagari1994.Analysis.MonotoneFeller
import Aiyagari1994.Household.UpperDrift
import Mathlib.Topology.ContinuousMap.Interval

/-! Restricted-kernel bridge for the economic stability theorem. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- Interpret a point of a nonnegative real interval as resources. -/
def M05E.intervalResource (a b : Resources) (x : CI (a : ℝ) (b : ℝ)) : Resources :=
  ⟨x, le_trans a.property x.property.1⟩

theorem M05E.intervalResource_continuous (a b : Resources) :
    Continuous (M05E.intervalResource a b) := by
  apply Continuous.subtype_mk
  exact continuous_subtype_val

theorem M05E.intervalResource_monotone (a b : Resources) :
    Monotone (M05E.intervalResource a b) := by
  intro x y hxy
  exact hxy

theorem M05E.intervalResource_injective (a b : Resources) :
    Function.Injective (M05E.intervalResource a b) := by
  intro x y hxy
  apply Subtype.ext
  exact_mod_cast congrArg Subtype.val hxy

theorem M05E.intervalResource_measurableEmbedding (a b : Resources) :
    MeasurableEmbedding (M05E.intervalResource a b) :=
  (M05E.intervalResource_continuous a b).measurableEmbedding
    (M05E.intervalResource_injective a b)

theorem M05E.range_intervalResource (a b : Resources) :
    Set.range (M05E.intervalResource a b) = Icc a b := by
  ext z
  constructor
  · rintro ⟨x, rfl⟩
    exact ⟨by exact_mod_cast x.property.1, by exact_mod_cast x.property.2⟩
  · intro hz
    refine ⟨⟨(z : ℝ), by exact_mod_cast hz⟩, ?_⟩
    apply Subtype.ext
    rfl

/-- Project resources to a fixed nonempty real interval. -/
def M05E.projectResource (a b : Resources) (hab : a ≤ b) (z : Resources) :
    CI (a : ℝ) (b : ℝ) :=
  Set.projIcc (a : ℝ) (b : ℝ) (by exact_mod_cast hab) (z : ℝ)

theorem M05E.projectResource_continuous (a b : Resources) (hab : a ≤ b) :
    Continuous (M05E.projectResource a b hab) := by
  exact continuous_projIcc.comp NNReal.continuous_coe

theorem M05E.projectResource_monotone (a b : Resources) (hab : a ≤ b) :
    Monotone (M05E.projectResource a b hab) := by
  intro x y hxy
  exact monotone_projIcc (by exact_mod_cast hab) (by exact_mod_cast hxy)

@[simp] theorem M05E.project_intervalResource (a b : Resources) (hab : a ≤ b)
    (x : CI (a : ℝ) (b : ℝ)) :
    M05E.projectResource a b hab (M05E.intervalResource a b x) = x := by
  apply Subtype.ext
  change (Set.projIcc (a : ℝ) (b : ℝ) (by exact_mod_cast hab) (x : ℝ) : ℝ) = x
  exact congrArg Subtype.val (Set.projIcc_of_mem (by exact_mod_cast hab) x.property)

/-- The household kernel observed on a compact invariant interval. The projection is harmless
on an invariant interval and makes the construction a Markov kernel definitionally. -/
def M05E.restrictedKernel (m : HouseholdPrimitives) (a b : Resources) (hab : a ≤ b) :
    Kernel (CI (a : ℝ) (b : ℝ)) (CI (a : ℝ) (b : ℝ)) :=
  ((householdKernel m).comap (M05E.intervalResource a b)
      (M05E.intervalResource_continuous a b).measurable).map
    (M05E.projectResource a b hab)

instance M05E.restrictedKernel_isMarkov (m : HouseholdPrimitives) (a b : Resources)
    (hab : a ≤ b) : IsMarkovKernel (M05E.restrictedKernel m a b hab) := by
  unfold M05E.restrictedKernel
  exact Kernel.IsMarkovKernel.map _
    (M05E.projectResource_continuous a b hab).measurable

theorem M05E.restrictedKernel_integral (m : HouseholdPrimitives) (a b : Resources)
    (hab : a ≤ b) (x : CI (a : ℝ) (b : ℝ))
    (f : CI (a : ℝ) (b : ℝ) → ℝ) (hf : Measurable f) :
    (∫ y, f y ∂M05E.restrictedKernel m a b hab x) =
      ∫ y, f (M05E.projectResource a b hab y) ∂householdKernel m (M05E.intervalResource a b x) := by
  unfold M05E.restrictedKernel
  rw [Kernel.map_apply _ (M05E.projectResource_continuous a b hab).measurable]
  rw [MeasureTheory.integral_map
    (M05E.projectResource_continuous a b hab).measurable.aemeasurable
    hf.aestronglyMeasurable]
  rfl

theorem M05E.restrictedKernel_feller (m : HouseholdPrimitives) (a b : Resources)
    (hab : a ≤ b) :
    ∀ f : BoundedContinuousFunction (CI (a : ℝ) (b : ℝ)) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂M05E.restrictedKernel m a b hab x) := by
  intro f
  rw [show (fun x ↦ ∫ y, f y ∂M05E.restrictedKernel m a b hab x) =
      fun x ↦ ∫ y, f (M05E.projectResource a b hab y)
        ∂householdKernel m (M05E.intervalResource a b x) by
    funext x
    exact M05E.restrictedKernel_integral m a b hab x f f.continuous.measurable]
  let g : BoundedContinuousFunction Resources ℝ :=
    f.compContinuous ⟨M05E.projectResource a b hab,
      M05E.projectResource_continuous a b hab⟩
  have hg := ((householdKernel_feller_monotone m).2.1 g).comp
    (M05E.intervalResource_continuous a b)
  change Continuous (fun x ↦ ∫ y, g y ∂householdKernel m (M05E.intervalResource a b x))
  simpa only [Function.comp_def] using hg

theorem M05E.restrictedKernel_monotone (m : HouseholdPrimitives) (a b : Resources)
    (hab : a ≤ b) :
    ∀ f : BoundedContinuousFunction (CI (a : ℝ) (b : ℝ)) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂M05E.restrictedKernel m a b hab x) := by
  intro f hf x y hxy
  change (∫ z, f z ∂M05E.restrictedKernel m a b hab x) ≤
    ∫ z, f z ∂M05E.restrictedKernel m a b hab y
  rw [M05E.restrictedKernel_integral m a b hab x f f.continuous.measurable,
    M05E.restrictedKernel_integral m a b hab y f f.continuous.measurable]
  let g : BoundedContinuousFunction Resources ℝ :=
    f.compContinuous ⟨M05E.projectResource a b hab,
      M05E.projectResource_continuous a b hab⟩
  have hg : Monotone g := hf.comp (M05E.projectResource_monotone a b hab)
  simpa [g] using (householdKernel_feller_monotone m).2.2.1 g hg
    (M05E.intervalResource_monotone a b hxy)

theorem M05E.householdKernel_apply (m : HouseholdPrimitives) (z : Resources)
    (s : Set Resources) (hs : MeasurableSet s) :
    householdKernel m z s =
      (m.income.law : Measure m.income.Labor)
        ((fun l ↦ m.prices.nextResources (assetPolicy m z) l) ⁻¹' s) := by
  rw [show householdKernel m z =
      (m.income.law : Measure m.income.Labor).map
        (fun l ↦ m.prices.nextResources (assetPolicy m z) l) by
    ext t ht
    rw [householdKernel, Kernel.map_apply' _ (householdTransition_continuous m).measurable _ ht,
      Kernel.id_prod_apply' _ _ ((householdTransition_continuous m).measurable ht)]
    rw [Kernel.const_apply]
    have hmeas : Measurable
        (fun l ↦ m.prices.nextResources (assetPolicy m z) l) :=
      ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id)).measurable
    rw [Measure.map_apply hmeas ht]
    rfl]
  exact Measure.map_apply
    (((householdTransition_continuous m).comp
      (continuous_const.prodMk continuous_id)).measurable) hs

theorem M05E.householdKernel_interval_probability_one
    (m : HouseholdPrimitives) (a b : Resources)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b)
    (x : CI (a : ℝ) (b : ℝ)) :
    householdKernel m (M05E.intervalResource a b x) (Icc a b) = 1 := by
  rw [M05E.householdKernel_apply m _ _ measurableSet_Icc]
  have hall : (fun l ↦ m.prices.nextResources
      (assetPolicy m (M05E.intervalResource a b x)) l) ⁻¹' Icc a b = Set.univ := by
    ext l
    simp only [Set.mem_preimage, Set.mem_Icc, Set.mem_univ, iff_true]
    exact hInvariant _ (by exact_mod_cast x.property.1) (by exact_mod_cast x.property.2) l
  rw [hall, measure_univ]

/-- Exact restriction of the household kernel to an invariant compact interval. -/
def M05E.exactRestrictedKernel (m : HouseholdPrimitives) (a b : Resources) :
    Kernel (CI (a : ℝ) (b : ℝ)) (CI (a : ℝ) (b : ℝ)) :=
  Kernel.comapRight
    ((householdKernel m).comap (M05E.intervalResource a b)
      (M05E.intervalResource_continuous a b).measurable)
    (M05E.intervalResource_measurableEmbedding a b)

theorem M05E.exactRestrictedKernel_isMarkov
    (m : HouseholdPrimitives) (a b : Resources)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b) :
    IsMarkovKernel (M05E.exactRestrictedKernel m a b) := by
  unfold M05E.exactRestrictedKernel
  apply Kernel.IsMarkovKernel.comapRight
  intro x
  rw [Kernel.comap_apply']
  rw [M05E.range_intervalResource]
  exact M05E.householdKernel_interval_probability_one m a b hInvariant x

theorem M05E.exactRestrictedKernel_apply
    (m : HouseholdPrimitives) (a b : Resources)
    (x : CI (a : ℝ) (b : ℝ)) (s : Set (CI (a : ℝ) (b : ℝ)))
    (hs : MeasurableSet s) :
    M05E.exactRestrictedKernel m a b x s =
      householdKernel m (M05E.intervalResource a b x)
        (M05E.intervalResource a b '' s) := by
  unfold M05E.exactRestrictedKernel
  rw [Kernel.comapRight_apply' _ _ _ hs, Kernel.comap_apply']

theorem M05E.exactRestrictedKernel_eq_restrictedKernel
    (m : HouseholdPrimitives) (a b : Resources) (hab : a ≤ b)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b) :
    M05E.exactRestrictedKernel m a b = M05E.restrictedKernel m a b hab := by
  ext x s hs
  rw [M05E.exactRestrictedKernel_apply m a b x s hs]
  unfold M05E.restrictedKernel
  rw [Kernel.map_apply' _ (M05E.projectResource_continuous a b hab).measurable _ hs,
    Kernel.comap_apply']
  rw [M05E.householdKernel_apply m _ _
      ((M05E.intervalResource_measurableEmbedding a b).measurableSet_image.mpr hs),
    M05E.householdKernel_apply m _ _
      (hs.preimage (M05E.projectResource_continuous a b hab).measurable)]
  congr 1
  ext l
  let z := m.prices.nextResources
    (assetPolicy m (M05E.intervalResource a b x)) l
  have hz : a ≤ z ∧ z ≤ b :=
    hInvariant _ (by exact_mod_cast x.property.1) (by exact_mod_cast x.property.2) l
  have hproj : M05E.projectResource a b hab z =
      ⟨(z : ℝ), by exact_mod_cast hz⟩ := by
    apply Subtype.ext
    exact congrArg Subtype.val
      (Set.projIcc_of_mem (by exact_mod_cast hab) (by exact_mod_cast hz))
  constructor
  · rintro ⟨y, hy, hzy⟩
    have hyz : y = ⟨(z : ℝ), by exact_mod_cast hz⟩ := by
      apply M05E.intervalResource_injective a b
      calc
        M05E.intervalResource a b y = z := hzy
        _ = M05E.intervalResource a b ⟨(z : ℝ), by exact_mod_cast hz⟩ := by
          apply Subtype.ext
          rfl
    simpa [Set.mem_preimage, z, hproj, hyz] using hy
  · intro hzmem
    refine ⟨⟨(z : ℝ), by exact_mod_cast hz⟩, ?_, ?_⟩
    · simpa [Set.mem_preimage, z, hproj] using hzmem
    · apply Subtype.ext
      rfl

theorem M05E.map_exactRestrictedKernel
    (m : HouseholdPrimitives) (a b : Resources)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b) :
    (M05E.exactRestrictedKernel m a b).map (M05E.intervalResource a b) =
      (householdKernel m).comap (M05E.intervalResource a b)
        (M05E.intervalResource_continuous a b).measurable := by
  ext x s hs
  rw [Kernel.map_apply' _ (M05E.intervalResource_continuous a b).measurable _ hs]
  unfold M05E.exactRestrictedKernel
  rw [Kernel.comapRight_apply]
  change (Measure.comap (M05E.intervalResource a b)
    (householdKernel m (M05E.intervalResource a b x)))
      ((M05E.intervalResource a b) ⁻¹' s) =
        householdKernel m (M05E.intervalResource a b x) s
  have hae : ∀ᵐ y ∂householdKernel m (M05E.intervalResource a b x),
      y ∈ Set.range (M05E.intervalResource a b) := by
    apply (ae_mem_iff_measure_eq
      (M05E.intervalResource_measurableEmbedding a b).measurableSet_range.nullMeasurableSet).2
    rw [M05E.range_intervalResource,
      M05E.householdKernel_interval_probability_one m a b hInvariant x, measure_univ]
  rw [(M05E.intervalResource_measurableEmbedding a b).comap_apply,
    Set.image_preimage_eq_inter_range]
  rw [Set.inter_comm, MeasureTheory.Measure.measure_inter_eq_of_ae hae]

theorem M05E.map_exactRestrictedKernel_pow
    (m : HouseholdPrimitives) (a b : Resources)
    (hInvariant : ∀ z : Resources, a ≤ z → z ≤ b → ∀ l : m.income.Labor,
      a ≤ m.prices.nextResources (assetPolicy m z) l ∧
        m.prices.nextResources (assetPolicy m z) l ≤ b) :
    ∀ n : ℕ,
      ((M05E.exactRestrictedKernel m a b) ^ n).map (M05E.intervalResource a b) =
        ((householdKernel m) ^ n).comap (M05E.intervalResource a b)
          (M05E.intervalResource_continuous a b).measurable := by
  intro n
  induction n with
  | zero =>
      rw [pow_zero, pow_zero]
      exact Kernel.id_map (M05E.intervalResource_continuous a b).measurable
  | succ n ih =>
      rw [pow_succ, pow_succ]
      change
        (((M05E.exactRestrictedKernel m a b) ^ n) ∘ₖ
          (M05E.exactRestrictedKernel m a b)).map
            (M05E.intervalResource a b) =
          (((householdKernel m) ^ n) ∘ₖ (householdKernel m)).comap
            (M05E.intervalResource a b)
            (M05E.intervalResource_continuous a b).measurable
      rw [Kernel.map_comp]
      rw [ih]
      rw [← Kernel.comp_map _ _
        (M05E.intervalResource_continuous a b).measurable]
      rw [M05E.map_exactRestrictedKernel m a b hInvariant]
      ext x s hs
      rw [Kernel.comp_apply' _ _ _ hs, Kernel.comap_apply',
        Kernel.comp_apply' _ _ _ hs]
      rfl

end
end Aiyagari1994
