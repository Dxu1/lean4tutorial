import Aiyagari1994.Primitives.Basic
import Aiyagari1994.Analysis.ParametricMax
import Mathlib.MeasureTheory.Integral.Bochner.Set

/-! Bellman construction on all nonnegative resources, using BASIC alone. -/
open MeasureTheory Set Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section
abbrev ValueSpace := BoundedContinuousFunction Resources ℝ
abbrev UnitShare := Set.Icc (0 : ℝ≥0) 1

instance unitShare_nonempty : Nonempty UnitShare := ⟨⟨0, by simp⟩⟩

def continuation (m : HouseholdPrimitives) (v : ValueSpace) (a : Resources) : ℝ :=
  ∫ l : m.income.Labor, v (m.prices.nextResources a l) ∂(m.income.law : Measure m.income.Labor)

theorem nextResources_continuous (m : HouseholdPrimitives) :
    Continuous (fun p : Resources × m.income.Labor => m.prices.nextResources p.1 p.2) := by
  apply Continuous.subtype_mk
  change Continuous (fun p : Resources × m.income.Labor =>
    m.prices.grossReturn * (p.1 : ℝ) + (m.prices.wage * (p.2 : ℝ) + m.prices.intercept))
  fun_prop

theorem continuation_integrand_continuous (m : HouseholdPrimitives) (v : ValueSpace) :
    Continuous (fun p : Resources × m.income.Labor => v (m.prices.nextResources p.1 p.2)) :=
  v.continuous.comp (nextResources_continuous m)

theorem continuation_integrand_bound (m : HouseholdPrimitives) (v : ValueSpace)
    (a : Resources) (l : m.income.Labor) : |v (m.prices.nextResources a l)| ≤ ‖v‖ :=
  v.norm_coe_le_norm _

theorem continuation_integrable (m : HouseholdPrimitives) (v : ValueSpace) (a : Resources) :
    Integrable (fun l : m.income.Labor => v (m.prices.nextResources a l))
      (m.income.law : Measure m.income.Labor) := by
  apply Continuous.integrable_of_hasCompactSupport
  · exact v.continuous.comp ((nextResources_continuous m).comp
      (continuous_const.prodMk continuous_id))
  · exact HasCompactSupport.of_compactSpace _

theorem continuation_continuous (m : HouseholdPrimitives) (v : ValueSpace) :
    Continuous (continuation m v) := by
  have h := continuous_parametric_integral_of_continuous
    (μ := (m.income.law : Measure m.income.Labor))
    (f := fun a l => v (m.prices.nextResources a l))
    (v.continuous.comp (nextResources_continuous m)) isCompact_univ
  unfold continuation
  simpa only [Measure.restrict_univ] using h

theorem continuation_bound (m : HouseholdPrimitives) (v : ValueSpace) (a : Resources) :
    |continuation m v a| ≤ ‖v‖ := by
  have hi := continuation_integrable m v a
  simpa [continuation, Real.norm_eq_abs] using
    norm_integral_le_of_norm_le_const (μ := (m.income.law : Measure m.income.Labor))
      (Eventually.of_forall (fun l => v.norm_coe_le_norm (m.prices.nextResources a l)))

/-- Outside the feasible set truncated consumption is only a continuous extension. -/
def bellmanObjective (m : HouseholdPrimitives) (v : ValueSpace) (z a : Resources) : ℝ :=
  m.utility.utility (↑(z - a) : ℝ) + m.beta * continuation m v a

theorem bellmanObjective_feasible (m : HouseholdPrimitives) (v : ValueSpace)
    (z a : Resources) (ha : a ≤ z) :
    bellmanObjective m v z a = m.utility.utility ((z : ℝ) - (a : ℝ)) +
      m.beta * continuation m v a := by
  simp [bellmanObjective, NNReal.coe_sub ha]

theorem bellmanObjective_continuous (m : HouseholdPrimitives) (v : ValueSpace) :
    Continuous (fun p : Resources × Resources => bellmanObjective m v p.1 p.2) := by
  have hu : Continuous (fun c : Resources => m.utility.utility (c : ℝ)) :=
    m.utility_base.continuous.comp_continuous NNReal.continuous_coe (fun c => c.property)
  exact (hu.comp (continuous_fst.sub continuous_snd)).add
    (continuous_const.mul ((continuation_continuous m v).comp continuous_snd))

def shareObjective (m : HouseholdPrimitives) (v : ValueSpace) (z : Resources) (t : UnitShare) : ℝ :=
  bellmanObjective m v z (t.val * z)

theorem shareObjective_continuous (m : HouseholdPrimitives) (v : ValueSpace) :
    Continuous (shareObjective m v).uncurry := by
  exact (bellmanObjective_continuous m v).comp
    (continuous_fst.prodMk ((continuous_subtype_val.comp continuous_snd).mul continuous_fst))

theorem share_feasible (z : Resources) (t : UnitShare) : t.val * z ≤ z := by
  simpa using mul_le_mul_of_nonneg_right t.property.2 z.property

theorem feasible_share (z a : Resources) (ha : a ≤ z) :
    ∃ t : UnitShare, t.val * z = a := by
  by_cases hz : z = 0
  · subst z; have : a = 0 := le_antisymm ha (show 0 ≤ a from bot_le); subst a
    exact ⟨⟨0, by simp⟩, by simp⟩
  · refine ⟨⟨a / z, bot_le, (div_le_one (pos_iff_ne_zero.mpr hz)).mpr ha⟩, ?_⟩
    exact div_mul_cancel₀ a hz

def bellmanValue (m : HouseholdPrimitives) (v : ValueSpace) : Resources → ℝ :=
  compactMax (shareObjective m v)

theorem bellmanValue_attained (m : HouseholdPrimitives) (v : ValueSpace) (z : Resources) :
    ∃ a : Resources, a ≤ z ∧ bellmanValue m v z = bellmanObjective m v z a := by
  obtain ⟨t, he, _⟩ := compactMax_attained (shareObjective_continuous m v) z
  exact ⟨t.val * z, share_feasible z t, he⟩

theorem objective_le_bellmanValue (m : HouseholdPrimitives) (v : ValueSpace)
    (z a : Resources) (ha : a ≤ z) : bellmanObjective m v z a ≤ bellmanValue m v z := by
  obtain ⟨t, ht⟩ := feasible_share z a ha
  simpa [shareObjective, ht, bellmanValue] using le_compactMax (shareObjective_continuous m v) z t

theorem bellmanValue_bound (m : HouseholdPrimitives) (v : ValueSpace)
    (C : ℝ) (hC : ∀ c ∈ Ici (0 : ℝ), |m.utility.utility c| ≤ C) (z : Resources) :
    |bellmanValue m v z| ≤ C + m.beta * ‖v‖ := by
  obtain ⟨a, _, he⟩ := bellmanValue_attained m v z
  rw [he, bellmanObjective]
  calc
    _ ≤ |m.utility.utility (↑(z-a) : ℝ)| + |m.beta * continuation m v a| := abs_add_le _ _
    _ ≤ C + m.beta * ‖v‖ := by
      rw [abs_mul, abs_of_pos m.beta_pos]
      exact add_le_add (hC _ (z-a).property)
        (mul_le_mul_of_nonneg_left (continuation_bound m v a) m.beta_pos.le)

def bellmanOperator (m : HouseholdPrimitives) (v : ValueSpace) : ValueSpace where
  toFun := bellmanValue m v
  continuous_toFun := compactMax_continuous (shareObjective_continuous m v)
  map_bounded' := by
    obtain ⟨C, hC⟩ := m.utility_base.bounded
    refine ⟨2 * (C + m.beta * ‖v‖), fun x y => ?_⟩
    rw [Real.dist_eq]
    calc
      _ ≤ |bellmanValue m v x| + |bellmanValue m v y| := abs_sub _ _
      _ ≤ _ := by linarith [bellmanValue_bound m v C hC x, bellmanValue_bound m v C hC y]

@[simp] theorem bellmanOperator_apply (m : HouseholdPrimitives) (v : ValueSpace) (z : Resources) :
    bellmanOperator m v z = bellmanValue m v z := rfl


theorem continuation_sub_bound (m : HouseholdPrimitives) (v w : ValueSpace) (a : Resources) :
    |continuation m v a - continuation m w a| ≤ ‖v - w‖ := by
  rw [continuation, continuation, ← integral_sub
    (continuation_integrable m v a) (continuation_integrable m w a)]
  simpa [Real.norm_eq_abs] using
    norm_integral_le_of_norm_le_const (μ := (m.income.law : Measure m.income.Labor))
      (Eventually.of_forall (fun l => (v-w).norm_coe_le_norm (m.prices.nextResources a l)))

theorem objective_sub_bound (m : HouseholdPrimitives) (v w : ValueSpace) (z a : Resources) :
    |bellmanObjective m v z a - bellmanObjective m w z a| ≤ m.beta * ‖v-w‖ := by
  have he : bellmanObjective m v z a - bellmanObjective m w z a =
      m.beta * (continuation m v a - continuation m w a) := by unfold bellmanObjective; ring
  rw [he, abs_mul, abs_of_pos m.beta_pos]
  exact mul_le_mul_of_nonneg_left (continuation_sub_bound m v w a) m.beta_pos.le

theorem bellmanValue_sub_le (m : HouseholdPrimitives) (v w : ValueSpace) (z : Resources) :
    bellmanValue m v z - bellmanValue m w z ≤ m.beta * ‖v-w‖ := by
  obtain ⟨a, ha, he⟩ := bellmanValue_attained m v z
  have h1 := objective_le_bellmanValue m w z a ha
  have h2 := (abs_le.mp (objective_sub_bound m v w z a)).2
  rw [he]; linarith

theorem bellman_pointwise_contraction (m : HouseholdPrimitives) (v w : ValueSpace) (z : Resources) :
    |bellmanOperator m v z - bellmanOperator m w z| ≤ m.beta * ‖v-w‖ := by
  apply abs_le.mpr
  have h1 := bellmanValue_sub_le m v w z
  have h2 := bellmanValue_sub_le m w v z
  rw [norm_sub_rev w v] at h2
  constructor <;> dsimp only [bellmanOperator_apply] <;> linarith

theorem bellman_norm_contraction (m : HouseholdPrimitives) (v w : ValueSpace) :
    ‖bellmanOperator m v - bellmanOperator m w‖ ≤ m.beta * ‖v-w‖ := by
  apply (BoundedContinuousFunction.norm_le (mul_nonneg m.beta_pos.le (norm_nonneg _))).mpr
  intro z
  exact bellman_pointwise_contraction m v w z

/-- H01: an actual self-map, with beta contraction for every HouseholdPrimitives object. -/
theorem bellman_selfmap_contracting (m : HouseholdPrimitives) :
    ContractingWith ⟨m.beta, m.beta_pos.le⟩ (bellmanOperator m) := by
  refine ⟨m.beta_lt_one, LipschitzWith.of_dist_le_mul (fun v w => ?_)⟩
  change dist (bellmanOperator m v) (bellmanOperator m w) ≤ m.beta * dist v w
  rw [dist_eq_norm, dist_eq_norm]
  exact bellman_norm_contraction m v w

end
end Aiyagari1994
