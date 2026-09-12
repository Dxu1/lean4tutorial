import Aiyagari1994.Household.Value

/-! Canonical shifted-asset policy constructed from unique compact maximization. -/
open Set MeasureTheory Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

def AssetOptimal (m : HouseholdPrimitives) (z a : Resources) : Prop :=
  a ≤ z ∧ bellmanObjective m (valueFunction m) z a = valueFunction m z

theorem assetOptimal_exists (m : HouseholdPrimitives) (z : Resources) :
    ∃ a, AssetOptimal m z a := by
  obtain ⟨a, ha, he⟩ := bellmanValue_attained m (valueFunction m) z
  have hf := congrArg (fun f : ValueSpace => f z) (valueFunction_fixedPoint m)
  exact ⟨a,ha,he.symm.trans hf⟩

/-- Strict concavity in actual saving actions, for all positive real convex weights. -/
theorem objective_strictConcave_assets (m : HouseholdPrimitives) (z x y a b : Resources)
    (hx : x ≤ z) (hy : y ≤ z) (hxy : x ≠ y) (ha : 0 < a) (hb : 0 < b) (hab : a+b=1) :
    (a:ℝ)*bellmanObjective m (valueFunction m) z x +
      (b:ℝ)*bellmanObjective m (valueFunction m) z y <
    bellmanObjective m (valueFunction m) z (a*x+b*y) := by
  have hr : (a:ℝ)+(b:ℝ)=1 := by exact_mod_cast hab
  have hf : a*x+b*y ≤ z := by
    calc
      _ ≤ a*z+b*z := add_le_add (mul_le_mul_right hx a) (mul_le_mul_right hy b)
      _ = z := by rw [← add_mul,hab,one_mul]
  have hn : (z:ℝ)-(x:ℝ) ≠ (z:ℝ)-(y:ℝ) := by
    intro h; apply hxy; apply Subtype.ext; change (x:ℝ)=(y:ℝ); linarith
  have hu := m.utility_base.concave.2
    (show (z:ℝ)-(x:ℝ) ∈ Ici 0 from sub_nonneg.mpr (show (x:ℝ) ≤ (z:ℝ) from hx))
    (show (z:ℝ)-(y:ℝ) ∈ Ici 0 from sub_nonneg.mpr (show (y:ℝ) ≤ (z:ℝ) from hy))
    hn (show 0 < (a:ℝ) from ha) (show 0 < (b:ℝ) from hb) hr
  change (a:ℝ)*m.utility.utility ((z:ℝ)-(x:ℝ)) +
    (b:ℝ)*m.utility.utility ((z:ℝ)-(y:ℝ)) <
    m.utility.utility ((a:ℝ)*((z:ℝ)-(x:ℝ))+(b:ℝ)*((z:ℝ)-(y:ℝ))) at hu
  have he : (a:ℝ)*((z:ℝ)-(x:ℝ))+(b:ℝ)*((z:ℝ)-(y:ℝ)) =
      (z:ℝ)-((a*x+b*y : Resources):ℝ) := by
    push_cast
    calc
      _ = ((a:ℝ)+(b:ℝ))*(z:ℝ)-((a:ℝ)*(x:ℝ)+(b:ℝ)*(y:ℝ)) := by ring
      _ = _ := by rw [hr, one_mul]
  erw [he] at hu
  have hc := mul_le_mul_of_nonneg_left
    (continuation_concave m (valueFunction m) (valueFunction_concave m) x y a b hab) m.beta_pos.le
  rw [bellmanObjective_feasible m _ z x hx, bellmanObjective_feasible m _ z y hy,
    bellmanObjective_feasible m _ z _ hf]
  simp only [NNReal.toReal] at hu hc ⊢
  convert add_lt_add_of_lt_of_le hu hc using 1 <;> first | rfl | ring

theorem assetOptimal_unique (m : HouseholdPrimitives) (z x y : Resources)
    (hx : AssetOptimal m z x) (hy : AssetOptimal m z y) : x = y := by
  by_cases hz : z = 0
  · subst z
    exact (le_antisymm hx.1 bot_le).trans (le_antisymm hy.1 bot_le).symm
  · by_contra hxy
    have h := objective_strictConcave_assets m z x y (1/2) (1/2) hx.1 hy.1 hxy
      (by norm_num) (by norm_num) (by norm_num)
    have hf : (1/2)*x+(1/2)*y ≤ z := by
      calc
        _ ≤ (1/2)*z+(1/2)*z :=
          add_le_add (mul_le_mul_right hx.1 _) (mul_le_mul_right hy.1 _)
        _ = z := by ring
    have hm := objective_le_bellmanValue m (valueFunction m) z _ hf
    have hv := congrArg (fun f : ValueSpace => f z) (valueFunction_fixedPoint m)
    change bellmanValue m (valueFunction m) z = valueFunction m z at hv
    rw [hv] at hm
    rw [hx.2,hy.2] at h
    norm_num at h
    linarith

theorem assetOptimal_existsUnique (m : HouseholdPrimitives) (z : Resources) :
    ∃! a, AssetOptimal m z a := by
  obtain ⟨a,ha⟩ := assetOptimal_exists m z
  exact ⟨a,ha, fun b hb => assetOptimal_unique m z b a hb ha⟩

def assetPolicy (m : HouseholdPrimitives) (z : Resources) : Resources :=
  Classical.choose (assetOptimal_existsUnique m z)

theorem assetPolicy_optimal (m : HouseholdPrimitives) (z : Resources) :
    AssetOptimal m z (assetPolicy m z) :=
  (Classical.choose_spec (assetOptimal_existsUnique m z)).1

theorem assetPolicy_le_state (m : HouseholdPrimitives) (z : Resources) : assetPolicy m z ≤ z :=
  (assetPolicy_optimal m z).1

theorem assetPolicy_maximizes (m : HouseholdPrimitives) (z a : Resources) (ha : a ≤ z) :
    bellmanObjective m (valueFunction m) z a ≤
      bellmanObjective m (valueFunction m) z (assetPolicy m z) := by
  rw [(assetPolicy_optimal m z).2]
  have h := objective_le_bellmanValue m (valueFunction m) z a ha
  have he := congrArg (fun f : ValueSpace => f z) (valueFunction_fixedPoint m)
  exact h.trans_eq he

/-- The value-equality specification is equivalent to maximization over all feasible assets. -/
theorem assetOptimal_iff_maximizes (m : HouseholdPrimitives) (z a : Resources) :
    AssetOptimal m z a ↔ a ≤ z ∧ ∀ b : Resources, b ≤ z →
      bellmanObjective m (valueFunction m) z b ≤ bellmanObjective m (valueFunction m) z a := by
  constructor
  · intro ha
    have he := assetOptimal_unique m z a _ ha (assetPolicy_optimal m z)
    subst a
    exact ⟨assetPolicy_le_state m z, fun b hb => assetPolicy_maximizes m z b hb⟩
  · rintro ⟨ha,hm⟩
    refine ⟨ha, le_antisymm ?_ ?_⟩
    · have h := assetPolicy_maximizes m z a ha
      rwa [(assetPolicy_optimal m z).2] at h
    · have h := hm (assetPolicy m z) (assetPolicy_le_state m z)
      rwa [(assetPolicy_optimal m z).2] at h

theorem assetPolicy_existsUnique_maximizer (m : HouseholdPrimitives) (z : Resources) :
    ∃! a : Resources, a ≤ z ∧ ∀ b : Resources, b ≤ z →
      bellmanObjective m (valueFunction m) z b ≤ bellmanObjective m (valueFunction m) z a := by
  exact ⟨assetPolicy m z, (assetOptimal_iff_maximizes m z _).mp (assetPolicy_optimal m z),
    fun a ha => assetOptimal_unique m z a _ ((assetOptimal_iff_maximizes m z a).mpr ha)
      (assetPolicy_optimal m z)⟩

@[simp] theorem assetPolicy_zero (m : HouseholdPrimitives) : assetPolicy m 0 = 0 :=
  le_antisymm (assetPolicy_le_state m 0) bot_le

abbrev PositiveResources := Set.Ioi (0 : Resources)

def positiveAssetShare (m : HouseholdPrimitives) (z : PositiveResources) : UnitShare :=
  ⟨assetPolicy m z.val / z.val, bot_le,
    (div_le_one z.property).mpr (assetPolicy_le_state m z.val)⟩

theorem positiveAssetShare_mul (m : HouseholdPrimitives) (z : PositiveResources) :
    (positiveAssetShare m z).val * z.val = assetPolicy m z.val :=
  div_mul_cancel₀ _ (ne_of_gt z.property)

theorem positiveAssetShare_continuous (m : HouseholdPrimitives) : Continuous (positiveAssetShare m) := by
  let f : PositiveResources → UnitShare → ℝ := fun z t => shareObjective m (valueFunction m) z.val t
  have hc : Continuous f.uncurry :=
    (shareObjective_continuous m (valueFunction m)).comp
      ((continuous_subtype_val.comp continuous_fst).prodMk continuous_snd)
  have hmax (z : PositiveResources) : compactMax f z = valueFunction m z.val :=
    congrArg (fun v : ValueSpace => v z.val) (valueFunction_fixedPoint m)
  apply compact_unique_argmax_continuous hc (positiveAssetShare m)
  · intro z
    change bellmanObjective m (valueFunction m) z.val ((positiveAssetShare m z).val*z.val) = _
    rw [positiveAssetShare_mul, (assetPolicy_optimal m z.val).2, hmax]
  · intro z t ht
    have ho : AssetOptimal m z.val (t.val*z.val) :=
      ⟨share_feasible z.val t, ht.trans (hmax z)⟩
    have he := assetOptimal_unique m z.val _ _ ho (assetPolicy_optimal m z.val)
    apply Subtype.ext
    apply mul_right_cancel₀ (ne_of_gt z.property)
    exact he.trans (positiveAssetShare_mul m z).symm

theorem assetPolicy_continuous_positive (m : HouseholdPrimitives) :
    ContinuousOn (assetPolicy m) (Ioi 0) := by
  rw [continuousOn_iff_continuous_restrict]
  have h := (continuous_subtype_val.comp (positiveAssetShare_continuous m)).mul continuous_subtype_val
  change Continuous (fun z : PositiveResources => (positiveAssetShare m z).val * z.val) at h
  change Continuous (fun z : PositiveResources => assetPolicy m z.val)
  simpa only [positiveAssetShare_mul] using h

theorem assetPolicy_continuous (m : HouseholdPrimitives) : Continuous (assetPolicy m) := by
  rw [continuous_iff_continuousAt]
  intro z
  by_cases hz : z = 0
  · subst z
    rw [ContinuousAt, assetPolicy_zero]
    exact tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds tendsto_id
      (fun x => bot_le) (assetPolicy_le_state m)
  · exact (assetPolicy_continuous_positive m).continuousAt
      (isOpen_Ioi.mem_nhds (pos_iff_ne_zero.mpr hz))

def consumptionPolicy (m : HouseholdPrimitives) (z : Resources) : Resources := z - assetPolicy m z

theorem consumptionPolicy_coe (m : HouseholdPrimitives) (z : Resources) :
    (consumptionPolicy m z : ℝ) = (z:ℝ) - (assetPolicy m z : ℝ) :=
  NNReal.coe_sub (assetPolicy_le_state m z)

theorem consumptionPolicy_budget (m : HouseholdPrimitives) (z : Resources) :
    0 ≤ consumptionPolicy m z ∧ consumptionPolicy m z + assetPolicy m z = z :=
  ⟨bot_le, tsub_add_cancel_of_le (assetPolicy_le_state m z)⟩

theorem consumptionPolicy_continuous (m : HouseholdPrimitives) : Continuous (consumptionPolicy m) :=
  continuous_id.sub (assetPolicy_continuous m)

/-- H04: canonical unique optimizer in actual shifted assets, continuous also at zero. -/
theorem assetPolicy_unique_continuous (m : HouseholdPrimitives) :
    (∀ z, AssetOptimal m z (assetPolicy m z) ∧
      ∀ a, AssetOptimal m z a → a = assetPolicy m z) ∧
    Continuous (assetPolicy m) ∧
    (∀ z a, a ≤ z → bellmanObjective m (valueFunction m) z a ≤
      bellmanObjective m (valueFunction m) z (assetPolicy m z)) ∧
    (∀ z, 0 ≤ assetPolicy m z ∧ assetPolicy m z ≤ z) ∧
    (∀ z, (consumptionPolicy m z : ℝ) = (z:ℝ)-(assetPolicy m z : ℝ) ∧
      consumptionPolicy m z + assetPolicy m z = z) ∧ Continuous (consumptionPolicy m) := by
  exact ⟨fun z => ⟨assetPolicy_optimal m z,
      fun a ha => assetOptimal_unique m z a _ ha (assetPolicy_optimal m z)⟩,
    assetPolicy_continuous m, assetPolicy_maximizes m,
    fun z => ⟨bot_le,assetPolicy_le_state m z⟩,
    fun z => ⟨consumptionPolicy_coe m z,(consumptionPolicy_budget m z).2⟩,
    consumptionPolicy_continuous m⟩

end
end Aiyagari1994
