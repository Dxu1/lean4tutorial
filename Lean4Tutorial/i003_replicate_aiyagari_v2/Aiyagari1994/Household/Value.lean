import Aiyagari1994.Household.Bellman

/-! One canonical bounded continuous Bellman fixed point. -/
open MeasureTheory Set Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

def valueFunction (m : HouseholdPrimitives) : ValueSpace :=
  (bellman_selfmap_contracting m).fixedPoint (bellmanOperator m)

theorem valueFunction_fixedPoint (m : HouseholdPrimitives) :
    bellmanOperator m (valueFunction m) = valueFunction m :=
  (bellman_selfmap_contracting m).fixedPoint_isFixedPt

theorem valueFunction_unique (m : HouseholdPrimitives) (v : ValueSpace)
    (hv : bellmanOperator m v = v) : v = valueFunction m :=
  (bellman_selfmap_contracting m).fixedPoint_unique hv

theorem valueIteration_tendsto (m : HouseholdPrimitives) (v : ValueSpace) :
    Tendsto (fun n => (bellmanOperator m)^[n] v) atTop (𝓝 (valueFunction m)) :=
  (bellman_selfmap_contracting m).tendsto_iterate_fixedPoint v

theorem valueIteration_uniform (m : HouseholdPrimitives) (v : ValueSpace) :
    TendstoUniformly (fun n z => ((bellmanOperator m)^[n] v) z) (valueFunction m) atTop :=
  BoundedContinuousFunction.tendsto_iff_tendstoUniformly.mp (valueIteration_tendsto m v)

def utilityRange (m : HouseholdPrimitives) : Set ℝ :=
  Set.range (fun c : Resources => m.utility.utility (c : ℝ))
def utilityInf (m : HouseholdPrimitives) : ℝ := sInf (utilityRange m)
def utilitySup (m : HouseholdPrimitives) : ℝ := sSup (utilityRange m)

theorem utilityRange_nonempty (m : HouseholdPrimitives) : (utilityRange m).Nonempty :=
  ⟨m.utility.utility 0, (0 : Resources), rfl⟩

theorem utilityRange_bounded (m : HouseholdPrimitives) :
    BddBelow (utilityRange m) ∧ BddAbove (utilityRange m) := by
  obtain ⟨C, hC⟩ := m.utility_base.bounded
  constructor
  · refine ⟨-C, ?_⟩; rintro _ ⟨c, rfl⟩; exact (abs_le.mp (hC _ c.property)).1
  · refine ⟨C, ?_⟩; rintro _ ⟨c, rfl⟩; exact (abs_le.mp (hC _ c.property)).2

theorem utility_bounds (m : HouseholdPrimitives) (c : Resources) :
    utilityInf m ≤ m.utility.utility (c : ℝ) ∧ m.utility.utility (c : ℝ) ≤ utilitySup m :=
  ⟨csInf_le (utilityRange_bounded m).1 ⟨c, rfl⟩,
   le_csSup (utilityRange_bounded m).2 ⟨c, rfl⟩⟩

theorem valueRange_bounded (v : ValueSpace) :
    BddBelow (Set.range v) ∧ BddAbove (Set.range v) := by
  constructor
  · refine ⟨-‖v‖, ?_⟩; rintro _ ⟨z, rfl⟩; exact v.neg_norm_le_apply z
  · refine ⟨‖v‖, ?_⟩; rintro _ ⟨z, rfl⟩; exact v.apply_le_norm z

theorem continuation_range_bounds (m : HouseholdPrimitives) (v : ValueSpace) (a : Resources) :
    sInf (Set.range v) ≤ continuation m v a ∧ continuation m v a ≤ sSup (Set.range v) := by
  have hi := continuation_integrable m v a
  constructor
  · have h := integral_mono (integrable_const (sInf (Set.range v))) hi
      (fun l => csInf_le (valueRange_bounded v).1 ⟨m.prices.nextResources a l, rfl⟩)
    simpa [continuation] using h
  · have h := integral_mono hi (integrable_const (sSup (Set.range v)))
      (fun l => le_csSup (valueRange_bounded v).2 ⟨m.prices.nextResources a l, rfl⟩)
    simpa [continuation] using h

theorem valueFunction_bounds (m : HouseholdPrimitives) (z : Resources) :
    utilityInf m / (1-m.beta) ≤ valueFunction m z ∧
    valueFunction m z ≤ utilitySup m / (1-m.beta) := by
  let V := valueFunction m
  have hn : (Set.range V).Nonempty := ⟨V 0, 0, rfl⟩
  have hb := valueRange_bounded V
  have hf (x : Resources) : bellmanValue m V x = V x :=
    congrArg (fun f : ValueSpace => f x) (valueFunction_fixedPoint m)
  have hlo (x : Resources) : utilityInf m + m.beta * sInf (Set.range V) ≤ V x := by
    have h := objective_le_bellmanValue m V x 0 bot_le
    rw [hf] at h
    have hu := (utility_bounds m (x-0)).1
    have hc := mul_le_mul_of_nonneg_left (continuation_range_bounds m V 0).1 m.beta_pos.le
    dsimp [bellmanObjective] at h
    linarith
  have hhi (x : Resources) : V x ≤ utilitySup m + m.beta * sSup (Set.range V) := by
    obtain ⟨a, _, he⟩ := bellmanValue_attained m V x
    rw [hf] at he
    have hu := (utility_bounds m (x-a)).2
    have hc := mul_le_mul_of_nonneg_left (continuation_range_bounds m V a).2 m.beta_pos.le
    dsimp [bellmanObjective] at he
    linarith
  have hl : utilityInf m + m.beta * sInf (Set.range V) ≤ sInf (Set.range V) := by
    apply le_csInf hn
    rintro _ ⟨x,rfl⟩; exact hlo x
  have hh : sSup (Set.range V) ≤ utilitySup m + m.beta * sSup (Set.range V) := by
    apply csSup_le hn
    rintro _ ⟨x,rfl⟩; exact hhi x
  have hd : 0 < 1-m.beta := sub_pos.mpr m.beta_lt_one
  constructor
  · apply le_trans _ (csInf_le hb.1 (mem_range_self z))
    apply (div_le_iff₀ hd).mpr; nlinarith
  · apply le_trans (le_csSup hb.2 (mem_range_self z))
    apply (le_div_iff₀ hd).mpr; nlinarith

/-- H02 includes the canonical object, uniqueness, uniform iteration, and exact utility bounds. -/
theorem valueFunction_unique_fixedPoint (m : HouseholdPrimitives) :
    bellmanOperator m (valueFunction m) = valueFunction m ∧
    (∀ v : ValueSpace, bellmanOperator m v = v → v = valueFunction m) ∧
    (∀ v : ValueSpace, TendstoUniformly (fun n z => ((bellmanOperator m)^[n] v) z)
      (valueFunction m) atTop) ∧
    (∀ z, utilityInf m / (1-m.beta) ≤ valueFunction m z ∧
      valueFunction m z ≤ utilitySup m / (1-m.beta)) :=
  ⟨valueFunction_fixedPoint m, valueFunction_unique m, valueIteration_uniform m,
    valueFunction_bounds m⟩


/-- Ordinary convex-combination concavity, with nonnegative real weights represented by NNReal. -/
def NNRealConcave (f : Resources → ℝ) : Prop :=
  ∀ (x y a b : Resources), a+b=1 →
    (a : ℝ)*f x + (b : ℝ)*f y ≤ f (a*x+b*y)

theorem NNRealConcave.real_combination {f : Resources → ℝ} (hf : NNRealConcave f)
    (x y : Resources) (theta : ℝ) (h0 : 0 ≤ theta) (h1 : theta ≤ 1) :
    theta*f x + (1-theta)*f y ≤
      f ⟨theta*(x : ℝ)+(1-theta)*(y : ℝ),
        add_nonneg (mul_nonneg h0 x.property) (mul_nonneg (sub_nonneg.mpr h1) y.property)⟩ := by
  exact hf x y ⟨theta,h0⟩ ⟨1-theta,sub_nonneg.mpr h1⟩ (by ext; change theta+(1-theta)=1; ring)

theorem nnrealConcave_zero : NNRealConcave (fun _ => 0) := by
  intro x y a b hab; simp

theorem transition_convex_combination (m : HouseholdPrimitives) (x y a b : Resources)
    (hab : a+b=1) (l : m.income.Labor) :
    m.prices.nextResources (a*x+b*y) l =
      a*m.prices.nextResources x l + b*m.prices.nextResources y l := by
  have hr : (a : ℝ)+(b : ℝ)=1 := by exact_mod_cast hab
  apply Subtype.ext
  change m.prices.grossReturn*((a:ℝ)*(x:ℝ)+(b:ℝ)*(y:ℝ))+m.prices.effectiveIncome l =
    (a:ℝ)*(m.prices.grossReturn*(x:ℝ)+m.prices.effectiveIncome l)+
    (b:ℝ)*(m.prices.grossReturn*(y:ℝ)+m.prices.effectiveIncome l)
  calc
    _ = m.prices.grossReturn*((a:ℝ)*(x:ℝ)+(b:ℝ)*(y:ℝ))+
        ((a:ℝ)+(b:ℝ))*m.prices.effectiveIncome l := by rw [hr, one_mul]
    _ = _ := by ring

theorem continuation_concave (m : HouseholdPrimitives) (v : ValueSpace)
    (hv : NNRealConcave v) : NNRealConcave (continuation m v) := by
  intro x y a b hab
  have hx := continuation_integrable m v x
  have hy := continuation_integrable m v y
  have hz := continuation_integrable m v (a*x+b*y)
  have h := integral_mono ((hx.const_mul (a:ℝ)).add (hy.const_mul (b:ℝ))) hz
    (fun l => by rw [transition_convex_combination m x y a b hab]; exact hv _ _ a b hab)
  simp only [Pi.add_apply] at h
  simpa only [integral_add (hx.const_mul (a:ℝ)) (hy.const_mul (b:ℝ)),
    integral_const_mul, continuation] using h

theorem objective_convex_combination (m : HouseholdPrimitives) (v : ValueSpace)
    (hv : NNRealConcave v) (x y s t a b : Resources) (hs : s ≤ x) (ht : t ≤ y)
    (hab : a+b=1) :
    (a:ℝ)*bellmanObjective m v x s + (b:ℝ)*bellmanObjective m v y t ≤
      bellmanObjective m v (a*x+b*y) (a*s+b*t) := by
  have hf : a*s+b*t ≤ a*x+b*y :=
    add_le_add (mul_le_mul_right hs a) (mul_le_mul_right ht b)
  rw [bellmanObjective_feasible m v x s hs, bellmanObjective_feasible m v y t ht,
    bellmanObjective_feasible m v _ _ hf]
  have hr : (a:ℝ)+(b:ℝ)=1 := by exact_mod_cast hab
  have hu := m.utility_base.concave.concaveOn.2
    (show (x:ℝ)-(s:ℝ) ∈ Ici 0 from sub_nonneg.mpr (show (s:ℝ) ≤ (x:ℝ) from hs))
    (show (y:ℝ)-(t:ℝ) ∈ Ici 0 from sub_nonneg.mpr (show (t:ℝ) ≤ (y:ℝ) from ht))
    a.property b.property hr
  change (a:ℝ)*m.utility.utility ((x:ℝ)-(s:ℝ)) +
    (b:ℝ)*m.utility.utility ((y:ℝ)-(t:ℝ)) ≤
    m.utility.utility ((a:ℝ)*((x:ℝ)-(s:ℝ))+(b:ℝ)*((y:ℝ)-(t:ℝ))) at hu
  have he : (a:ℝ)*((x:ℝ)-(s:ℝ))+(b:ℝ)*((y:ℝ)-(t:ℝ)) =
      ((a*x+b*y : Resources):ℝ)-((a*s+b*t : Resources):ℝ) := by push_cast; ring
  erw [he] at hu
  have hc := mul_le_mul_of_nonneg_left (continuation_concave m v hv s t a b hab) m.beta_pos.le
  simp only [NNReal.toReal] at hu hc ⊢
  convert add_le_add hu hc using 1 <;> first | rfl | ring

theorem bellman_preserves_concavity (m : HouseholdPrimitives) (v : ValueSpace)
    (hv : NNRealConcave v) : NNRealConcave (bellmanOperator m v) := by
  intro x y a b hab
  obtain ⟨s, hs, he1⟩ := bellmanValue_attained m v x
  obtain ⟨t, ht, he2⟩ := bellmanValue_attained m v y
  have hf : a*s+b*t ≤ a*x+b*y :=
    add_le_add (mul_le_mul_right hs a) (mul_le_mul_right ht b)
  change (a:ℝ)*bellmanValue m v x+(b:ℝ)*bellmanValue m v y ≤ bellmanValue m v (a*x+b*y)
  rw [he1,he2]
  exact (objective_convex_combination m v hv x y s t a b hs ht hab).trans
    (objective_le_bellmanValue m v _ _ hf)

/-- Keeping savings fixed proves strict increase of T v for any candidate v. -/
theorem bellman_strictMono (m : HouseholdPrimitives) (v : ValueSpace) :
    StrictMono (bellmanOperator m v) := by
  intro x y hxy
  obtain ⟨a, ha, he⟩ := bellmanValue_attained m v x
  have hay := ha.trans hxy.le
  have h := objective_le_bellmanValue m v y a hay
  have hu := m.utility_base.increasing
    (show (x:ℝ)-(a:ℝ) ∈ Ici 0 from sub_nonneg.mpr (show (a:ℝ) ≤ (x:ℝ) from ha))
    (show (y:ℝ)-(a:ℝ) ∈ Ici 0 from sub_nonneg.mpr (show (a:ℝ) ≤ (y:ℝ) from hay))
    (sub_lt_sub_right (show (x:ℝ)<(y:ℝ) by exact_mod_cast hxy) _)
  rw [bellmanObjective_feasible m v y a hay] at h
  rw [bellmanObjective_feasible m v x a ha] at he
  change bellmanValue m v x < bellmanValue m v y
  linarith

theorem bellman_preserves_monotonicity (m : HouseholdPrimitives) (v : ValueSpace)
    (_hv : Monotone v) : Monotone (bellmanOperator m v) :=
  (bellman_strictMono m v).monotone

theorem valueIteration_concave (m : HouseholdPrimitives) (n : ℕ) :
    NNRealConcave ((bellmanOperator m)^[n] (0 : ValueSpace)) := by
  induction n with
  | zero => exact nnrealConcave_zero
  | succ n ih => simpa only [Function.iterate_succ_apply'] using bellman_preserves_concavity m _ ih

theorem valueIteration_monotone (m : HouseholdPrimitives) (n : ℕ) :
    Monotone ((bellmanOperator m)^[n] (0 : ValueSpace)) := by
  induction n with
  | zero => exact monotone_const
  | succ n ih => simpa only [Function.iterate_succ_apply'] using bellman_preserves_monotonicity m _ ih

theorem valueFunction_concave (m : HouseholdPrimitives) : NNRealConcave (valueFunction m) := by
  have hp := (valueIteration_uniform m 0).tendsto_at
  intro x y a b hab
  exact le_of_tendsto_of_tendsto ((hp x).const_mul (a:ℝ) |>.add ((hp y).const_mul (b:ℝ)))
    (hp (a*x+b*y)) (Eventually.of_forall (fun n => valueIteration_concave m n x y a b hab))

theorem valueFunction_monotone (m : HouseholdPrimitives) : Monotone (valueFunction m) := by
  have hp := (valueIteration_uniform m 0).tendsto_at
  intro x y hxy
  exact le_of_tendsto_of_tendsto (hp x) (hp y)
    (Eventually.of_forall (fun n => valueIteration_monotone m n hxy))

theorem valueFunction_strictMono (m : HouseholdPrimitives) : StrictMono (valueFunction m) := by
  have h := bellman_strictMono m (valueFunction m)
  rw [valueFunction_fixedPoint m] at h
  exact h

/-- H03: ordinary real convex-combination concavity and strict increase. -/
theorem valueFunction_concave_strictMono (m : HouseholdPrimitives) :
    NNRealConcave (valueFunction m) ∧ StrictMono (valueFunction m) :=
  ⟨valueFunction_concave m, valueFunction_strictMono m⟩

end
end Aiyagari1994
