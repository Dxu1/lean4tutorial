import Aiyagari1994.Household.Policy
import Mathlib.Topology.UniformSpace.UniformConvergence

/-!
Analytic infrastructure for H06.  The parameter space contains exactly the admissible
normalized triples `(R,w,k)` for a fixed income law.  Utility, the income law, and the discount
factor are inherited from a fixed `HouseholdPrimitives` object.
-/
open MeasureTheory Set Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- Admissible normalized `(R,w,k)` coordinates for a fixed income law. -/
def AdmissibleNormalizedPrices (i : IncomeData) :=
  {q : (ℝ × ℝ) × ℝ //
    (0 < q.1.1 ∧ 0 < q.1.2) ∧ ∀ l : i.Labor, 0 ≤ q.1.2 * (l : ℝ) + q.2}

instance (i : IncomeData) : TopologicalSpace (AdmissibleNormalizedPrices i) :=
  inferInstanceAs (TopologicalSpace {q : (ℝ × ℝ) × ℝ //
    (0 < q.1.1 ∧ 0 < q.1.2) ∧ ∀ l : i.Labor, 0 ≤ q.1.2 * (l : ℝ) + q.2})

instance (i : IncomeData) : FirstCountableTopology (AdmissibleNormalizedPrices i) :=
  inferInstanceAs (FirstCountableTopology {q : (ℝ × ℝ) × ℝ //
    (0 < q.1.1 ∧ 0 < q.1.2) ∧ ∀ l : i.Labor, 0 ≤ q.1.2 * (l : ℝ) + q.2})

instance (i : IncomeData) : LocallyCompactSpace (AdmissibleNormalizedPrices i) := by
  let s : Set ((ℝ × ℝ) × ℝ) := {q | 0 < q.1.1 ∧ 0 < q.1.2}
  let t : Set ((ℝ × ℝ) × ℝ) := {q | ∀ l : i.Labor, 0 ≤ q.1.2 * (l : ℝ) + q.2}
  have hs : IsOpen s := by
    apply (isOpen_lt continuous_const continuous_fst.fst).inter
    exact isOpen_lt continuous_const continuous_fst.snd
  have ht : IsClosed t := by
    change IsClosed {q : ((ℝ × ℝ) × ℝ) |
      ∀ l : i.Labor, 0 ≤ q.1.2 * (l : ℝ) + q.2}
    rw [show {q : ((ℝ × ℝ) × ℝ) | ∀ l : i.Labor,
        0 ≤ q.1.2 * (l : ℝ) + q.2} =
        ⋂ l : i.Labor, {q | 0 ≤ q.1.2 * (l : ℝ) + q.2} by ext q; simp]
    exact isClosed_iInter fun l => isClosed_le continuous_const
      ((continuous_fst.snd.mul (continuous_const :
        Continuous (fun _ : ((ℝ × ℝ) × ℝ) => (l : ℝ)))).add continuous_snd)
  change LocallyCompactSpace {q // q ∈ s ∩ t}
  exact (show IsLocallyClosed (s ∩ t) from ⟨s, t, hs, ht, rfl⟩).locallyCompactSpace

namespace AdmissibleNormalizedPrices

variable {i : IncomeData}

def grossReturn (q : AdmissibleNormalizedPrices i) : ℝ := q.1.1.1
def wage (q : AdmissibleNormalizedPrices i) : ℝ := q.1.1.2
def intercept (q : AdmissibleNormalizedPrices i) : ℝ := q.1.2

def toPrices (q : AdmissibleNormalizedPrices i) : NormalizedPrices i where
  grossReturn := q.grossReturn
  wage := q.wage
  intercept := q.intercept
  grossReturn_pos := q.property.1.1
  wage_pos := q.property.1.2
  income_nonneg := q.property.2

@[simp] private theorem toPrices_grossReturn (q : AdmissibleNormalizedPrices i) :
    q.toPrices.grossReturn = q.grossReturn := rfl

@[simp] private theorem toPrices_wage (q : AdmissibleNormalizedPrices i) :
    q.toPrices.wage = q.wage := rfl

@[simp] private theorem toPrices_intercept (q : AdmissibleNormalizedPrices i) :
    q.toPrices.intercept = q.intercept := rfl

private theorem continuous_grossReturn : Continuous (grossReturn : AdmissibleNormalizedPrices i → ℝ) :=
  (continuous_fst.comp continuous_subtype_val).fst

private theorem continuous_wage : Continuous (wage : AdmissibleNormalizedPrices i → ℝ) :=
  (continuous_fst.comp continuous_subtype_val).snd

private theorem continuous_intercept : Continuous (intercept : AdmissibleNormalizedPrices i → ℝ) :=
  continuous_snd.comp continuous_subtype_val

end AdmissibleNormalizedPrices

/-- Replace only normalized prices; all utility, law, and discount data remain definitionally fixed. -/
def HouseholdPrimitives.withPrices (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) : HouseholdPrimitives where
  beta := m.beta
  beta_pos := m.beta_pos
  beta_lt_one := m.beta_lt_one
  utility := m.utility
  utility_base := m.utility_base
  income := m.income
  income_support := m.income_support
  prices := q.toPrices

@[simp] private theorem HouseholdPrimitives.withPrices_beta (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) : (m.withPrices q).beta = m.beta := rfl

@[simp] private theorem HouseholdPrimitives.withPrices_utility (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) : (m.withPrices q).utility = m.utility := rfl

@[simp] private theorem HouseholdPrimitives.withPrices_income (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) : (m.withPrices q).income = m.income := rfl

private def parameterizedNextResources (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (a : Resources) (l : m.income.Labor) : Resources :=
  q.toPrices.nextResources a l

private theorem parameterizedNextResources_continuous (m : HouseholdPrimitives) :
    Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) × m.income.Labor =>
      parameterizedNextResources m x.1.1 x.1.2 x.2) := by
  apply Continuous.subtype_mk
  change Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) × m.income.Labor =>
    x.1.1.grossReturn * (x.1.2 : ℝ) +
      (x.1.1.wage * (x.2 : ℝ) + x.1.1.intercept))
  exact (((AdmissibleNormalizedPrices.continuous_grossReturn.comp continuous_fst.fst).mul
      (NNReal.continuous_coe.comp continuous_fst.snd)).add
    (((AdmissibleNormalizedPrices.continuous_wage.comp continuous_fst.fst).mul
      (continuous_subtype_val.comp continuous_snd)).add
      (AdmissibleNormalizedPrices.continuous_intercept.comp continuous_fst.fst)))

/-- Finite-horizon value iteration from zero, indexed by normalized prices and resources. -/
private def parameterizedFiniteValue (m : HouseholdPrimitives) :
    ℕ → AdmissibleNormalizedPrices m.income → Resources → ℝ
  | 0, _, _ => 0
  | n + 1, q, z => ((bellmanOperator (m.withPrices q))^[n + 1] (0 : ValueSpace)) z

@[simp] private theorem parameterizedFiniteValue_zero (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (z : Resources) :
    parameterizedFiniteValue m 0 q z = 0 := rfl

private theorem parameterizedFiniteValue_apply (m : HouseholdPrimitives) (n : ℕ)
    (q : AdmissibleNormalizedPrices m.income) (z : Resources) :
    parameterizedFiniteValue m n q z =
      ((bellmanOperator (m.withPrices q))^[n] (0 : ValueSpace)) z := by
  cases n <;> rfl

private theorem parameterizedContinuation_continuous (m : HouseholdPrimitives)
    {v : AdmissibleNormalizedPrices m.income → Resources → ℝ}
    (hv : Continuous v.uncurry) :
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      ∫ l : m.income.Labor, v x.1 (parameterizedNextResources m x.1 x.2 l)
        ∂(m.income.law : Measure m.income.Labor)) := by
  have hi : Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) ×
      m.income.Labor => v x.1.1 (parameterizedNextResources m x.1.1 x.1.2 x.2)) := by
    exact hv.comp (continuous_fst.fst.prodMk (parameterizedNextResources_continuous m))
  have h := continuous_parametric_integral_of_continuous
    (μ := (m.income.law : Measure m.income.Labor))
    (f := fun (x : AdmissibleNormalizedPrices m.income × Resources) l =>
      v x.1 (parameterizedNextResources m x.1 x.2 l)) hi isCompact_univ
  simpa only [Measure.restrict_univ] using h

private theorem parameterizedFiniteValue_continuous (m : HouseholdPrimitives) (n : ℕ) :
    Continuous (parameterizedFiniteValue m n).uncurry := by
  induction n with
  | zero => exact continuous_const
  | succ n ih =>
      let f : (AdmissibleNormalizedPrices m.income × Resources) → UnitShare → ℝ :=
        fun x t => m.utility.utility (↑(x.2 - t.val * x.2) : ℝ) + m.beta *
          ∫ l : m.income.Labor,
            parameterizedFiniteValue m n x.1
              (parameterizedNextResources m x.1 (t.val * x.2) l)
            ∂(m.income.law : Measure m.income.Labor)
      have hc : Continuous f.uncurry := by
        have hu : Continuous (fun x : ((AdmissibleNormalizedPrices m.income × Resources) ×
            UnitShare) => m.utility.utility (↑(x.1.2 - x.2.val * x.1.2) : ℝ)) := by
          have hbase : Continuous (fun c : Resources => m.utility.utility (c : ℝ)) :=
            m.utility_base.continuous.comp_continuous NNReal.continuous_coe
              (fun c => c.property)
          exact hbase.comp (continuous_fst.snd.sub
            ((continuous_subtype_val.comp continuous_snd).mul continuous_fst.snd))
        have hcont := parameterizedContinuation_continuous m ih
        have hcomp : Continuous (fun x : ((AdmissibleNormalizedPrices m.income × Resources) ×
            UnitShare) =>
            ∫ l : m.income.Labor,
              parameterizedFiniteValue m n x.1.1
                (parameterizedNextResources m x.1.1 (x.2.val * x.1.2) l)
              ∂(m.income.law : Measure m.income.Labor)) :=
          hcont.comp (continuous_fst.fst.prodMk
            ((continuous_subtype_val.comp continuous_snd).mul continuous_fst.snd))
        exact hu.add (continuous_const.mul hcomp)
      have hmax := compactMax_continuous hc
      rw [show (parameterizedFiniteValue m (n + 1)).uncurry = compactMax f by
        funext x
        change parameterizedFiniteValue m (n + 1) x.1 x.2 = compactMax f x
        rw [parameterizedFiniteValue_apply, Function.iterate_succ_apply']
        simp only [bellmanOperator_apply, bellmanValue, compactMax, f,
          parameterizedFiniteValue_apply, parameterizedNextResources]
        rfl]
      exact hmax

private theorem parameterized_value_tendstoUniformly (m : HouseholdPrimitives) :
    TendstoUniformly (fun (n : ℕ) (x : AdmissibleNormalizedPrices m.income × Resources) =>
      parameterizedFiniteValue m n x.1 x.2)
      (fun x => valueFunction (m.withPrices x.1) x.2) atTop := by
  obtain ⟨C, hC⟩ := m.utility_base.bounded
  have hC0 : 0 ≤ C := le_trans (abs_nonneg _) (hC 0 (mem_Ici.mpr le_rfl))
  apply Metric.tendstoUniformly_iff.mpr
  intro ε hε
  have ht : Tendsto (fun n : ℕ => m.beta ^ n * (C / (1 - m.beta))) atTop (𝓝 0) := by
    convert (tendsto_pow_atTop_nhds_zero_of_lt_one m.beta_pos.le m.beta_lt_one).mul_const
      (C / (1 - m.beta)) using 1 <;> simp
  obtain ⟨N, hN⟩ := Metric.tendsto_atTop.1 ht ε hε
  refine Filter.eventually_atTop.2 ⟨N, fun n hn x => ?_⟩
  rw [parameterizedFiniteValue_apply, Real.dist_eq]
  have hnorm : ‖valueFunction (m.withPrices x.1)‖ ≤ C / (1 - m.beta) := by
    have hb : ‖valueFunction (m.withPrices x.1)‖ ≤
        C + m.beta * ‖valueFunction (m.withPrices x.1)‖ := by
      apply (BoundedContinuousFunction.norm_le
        (add_nonneg hC0 (mul_nonneg m.beta_pos.le (norm_nonneg _)))).mpr
      intro z
      change |valueFunction (m.withPrices x.1) z| ≤
        C + m.beta * ‖valueFunction (m.withPrices x.1)‖
      conv_lhs => rw [← congrArg (fun v : ValueSpace => v z)
        (valueFunction_fixedPoint (m.withPrices x.1))]
      exact bellmanValue_bound (m.withPrices x.1) _ C hC z
    apply (le_div_iff₀ (sub_pos.mpr m.beta_lt_one)).mpr
    nlinarith
  have hlip := ((bellman_selfmap_contracting (m.withPrices x.1)).toLipschitzWith.iterate n).dist_le_mul
      (0 : ValueSpace) (valueFunction (m.withPrices x.1))
  have hfix : Function.IsFixedPt (bellmanOperator (m.withPrices x.1))
      (valueFunction (m.withPrices x.1)) := valueFunction_fixedPoint (m.withPrices x.1)
  rw [hfix.iterate n] at hlip
  rw [NNReal.coe_pow] at hlip
  change dist ((bellmanOperator (m.withPrices x.1))^[n] (0 : ValueSpace))
      (valueFunction (m.withPrices x.1)) ≤
      m.beta ^ n * dist (0 : ValueSpace) (valueFunction (m.withPrices x.1)) at hlip
  have hp : dist (((bellmanOperator (m.withPrices x.1))^[n] (0 : ValueSpace)) x.2)
      (valueFunction (m.withPrices x.1) x.2) ≤
      m.beta ^ n * ‖valueFunction (m.withPrices x.1)‖ := by
    exact (BoundedContinuousFunction.dist_coe_le_dist x.2).trans
      (by simpa only [dist_eq_norm, norm_zero, zero_sub,
          norm_neg] using hlip)
  rw [abs_sub_comm]
  have htail : m.beta ^ n * (C / (1 - m.beta)) < ε := by
    have hnonneg : 0 ≤ m.beta ^ n * (C / (1 - m.beta)) :=
      mul_nonneg (pow_nonneg m.beta_pos.le n)
        (div_nonneg hC0 (sub_nonneg.mpr m.beta_lt_one.le))
    simpa only [Real.dist_eq, sub_zero, abs_of_nonneg hnonneg] using hN n hn
  exact lt_of_le_of_lt (hp.trans (mul_le_mul_of_nonneg_left hnorm (pow_nonneg m.beta_pos.le n)))
    htail

theorem parameterized_value_continuous (m : HouseholdPrimitives) :
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      valueFunction (m.withPrices x.1) x.2) := by
  exact (parameterized_value_tendstoUniformly m).continuous
    (Frequently.of_forall (parameterizedFiniteValue_continuous m))

private theorem parameterized_valueContinuation_continuous (m : HouseholdPrimitives) :
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      ∫ l : m.income.Labor,
        valueFunction (m.withPrices x.1) (parameterizedNextResources m x.1 x.2 l)
        ∂(m.income.law : Measure m.income.Labor)) :=
  parameterizedContinuation_continuous m
    (v := fun q z => valueFunction (m.withPrices q) z) (by
      change Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
        valueFunction (m.withPrices x.1) x.2)
      exact parameterized_value_continuous m)

/-- The Bellman objective evaluated at the canonical parameterized value function. -/
private def parameterizedBellmanObjective (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (z a : Resources) : ℝ :=
  bellmanObjective (m.withPrices q) (valueFunction (m.withPrices q)) z a

private theorem parameterizedBellmanObjective_continuous (m : HouseholdPrimitives) :
    Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) × Resources =>
      parameterizedBellmanObjective m x.1.1 x.1.2 x.2) := by
  have hu : Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) × Resources =>
      m.utility.utility (↑(x.1.2 - x.2) : ℝ)) := by
    have hbase : Continuous (fun c : Resources => m.utility.utility (c : ℝ)) :=
      m.utility_base.continuous.comp_continuous NNReal.continuous_coe (fun c => c.property)
    exact hbase.comp (continuous_fst.snd.sub continuous_snd)
  have hc := parameterized_valueContinuation_continuous m
  have hcomp : Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) ×
      Resources =>
      ∫ l : m.income.Labor,
        valueFunction (m.withPrices x.1.1) (parameterizedNextResources m x.1.1 x.2 l)
        ∂(m.income.law : Measure m.income.Labor)) :=
    hc.comp (continuous_fst.fst.prodMk continuous_snd)
  change Continuous (fun x : (AdmissibleNormalizedPrices m.income × Resources) × Resources =>
    m.utility.utility (↑(x.1.2 - x.2) : ℝ) + m.beta *
      ∫ l : m.income.Labor,
        valueFunction (m.withPrices x.1.1) (parameterizedNextResources m x.1.1 x.2 l)
        ∂(m.income.law : Measure m.income.Labor))
  exact hu.add (continuous_const.mul hcomp)

/-- Price-resource pairs away from the zero-resource boundary. -/
private abbrev PositivePriceResources (m : HouseholdPrimitives) :=
  {x : AdmissibleNormalizedPrices m.income × Resources // 0 < x.2}

private def parameterizedPositiveAssetShare (m : HouseholdPrimitives)
    (x : PositivePriceResources m) : UnitShare :=
  ⟨assetPolicy (m.withPrices x.val.1) x.val.2 / x.val.2, bot_le,
    (div_le_one x.property).mpr (assetPolicy_le_state (m.withPrices x.val.1) x.val.2)⟩

private theorem parameterizedPositiveAssetShare_mul (m : HouseholdPrimitives)
    (x : PositivePriceResources m) :
    (parameterizedPositiveAssetShare m x).val * x.val.2 =
      assetPolicy (m.withPrices x.val.1) x.val.2 :=
  div_mul_cancel₀ _ (ne_of_gt x.property)

private theorem parameterizedPositiveAssetShare_continuous (m : HouseholdPrimitives) :
    Continuous (parameterizedPositiveAssetShare m) := by
  let f : PositivePriceResources m → UnitShare → ℝ := fun x t =>
    parameterizedBellmanObjective m x.val.1 x.val.2 (t.val * x.val.2)
  have hc : Continuous f.uncurry := by
    exact (parameterizedBellmanObjective_continuous m).comp
      ((continuous_subtype_val.comp continuous_fst).prodMk
        ((continuous_subtype_val.comp continuous_snd).mul
          ((continuous_subtype_val.comp continuous_fst).snd)))
  have hmax (x : PositivePriceResources m) : compactMax f x =
      valueFunction (m.withPrices x.val.1) x.val.2 := by
    exact congrArg (fun v : ValueSpace => v x.val.2)
      (valueFunction_fixedPoint (m.withPrices x.val.1))
  apply compact_unique_argmax_continuous hc (parameterizedPositiveAssetShare m)
  · intro x
    change parameterizedBellmanObjective m x.val.1 x.val.2
      ((parameterizedPositiveAssetShare m x).val * x.val.2) = _
    rw [parameterizedPositiveAssetShare_mul, parameterizedBellmanObjective,
      (assetPolicy_optimal (m.withPrices x.val.1) x.val.2).2, hmax]
  · intro x t ht
    have ho : AssetOptimal (m.withPrices x.val.1) x.val.2 (t.val * x.val.2) := by
      refine ⟨share_feasible x.val.2 t, ?_⟩
      exact ht.trans (hmax x)
    have he := assetOptimal_unique (m.withPrices x.val.1) x.val.2 _ _ ho
      (assetPolicy_optimal (m.withPrices x.val.1) x.val.2)
    apply Subtype.ext
    apply mul_right_cancel₀ (ne_of_gt x.property)
    exact he.trans (parameterizedPositiveAssetShare_mul m x).symm

private theorem parameterized_assetPolicy_continuous_positive (m : HouseholdPrimitives) :
    ContinuousOn (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      assetPolicy (m.withPrices x.1) x.2) {x | 0 < x.2} := by
  rw [continuousOn_iff_continuous_restrict]
  have h := (continuous_subtype_val.comp (parameterizedPositiveAssetShare_continuous m)).mul
    (continuous_subtype_val.snd)
  change Continuous (fun x : PositivePriceResources m =>
    (parameterizedPositiveAssetShare m x).val * x.val.2) at h
  change Continuous (fun x : PositivePriceResources m =>
    assetPolicy (m.withPrices x.val.1) x.val.2)
  simpa only [parameterizedPositiveAssetShare_mul] using h

theorem parameterized_assetPolicy_continuous (m : HouseholdPrimitives) :
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      assetPolicy (m.withPrices x.1) x.2) := by
  rw [continuous_iff_continuousAt]
  intro x
  by_cases hx : x.2 = 0
  · have hvalue : assetPolicy (m.withPrices x.1) x.2 = 0 := by
      rw [hx, assetPolicy_zero]
    rw [ContinuousAt, hvalue]
    have hs : Tendsto (fun y : AdmissibleNormalizedPrices m.income × Resources => y.2)
        (𝓝 x) (𝓝 0) := by
      rw [← hx]
      exact (continuousAt_snd :
        ContinuousAt (fun y : AdmissibleNormalizedPrices m.income × Resources => y.2) x)
    exact tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds hs
      (fun y => bot_le) (fun y => assetPolicy_le_state (m.withPrices y.1) y.2)
  · exact (parameterized_assetPolicy_continuous_positive m).continuousAt
      ((isOpen_lt continuous_const continuous_snd).mem_nhds (pos_iff_ne_zero.mpr hx))

end
end Aiyagari1994
