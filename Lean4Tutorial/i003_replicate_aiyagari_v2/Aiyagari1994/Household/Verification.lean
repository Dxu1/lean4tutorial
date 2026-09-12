import Aiyagari1994.Household.Policy
import Aiyagari1994.Household.History
import Aiyagari1994.Budget.Normalization
import Mathlib.Analysis.SpecificLimits.Basic

/-! Lifetime verification over arbitrary measurable finite-history plans. -/
open MeasureTheory Set Filter Finset
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- Resources are derived from the preceding action and the newly arriving shock. -/
def actionResources (m : HouseholdPrimitives) (z0 : Resources)
    (action : (t : ℕ) → History m t → Resources) : (t : ℕ) → History m t → Resources
  | 0, _ => z0
  | t+1, h => m.prices.nextResources (action t (previousHistory m t h)) (newestShock m t h)

/-- Full-history measurable actions; pointwise feasibility as authorized by the M02B interface. -/
structure FeasiblePlan (m : HouseholdPrimitives) (z0 : Resources) where
  action : (t : ℕ) → History m t → Resources
  measurable_action : ∀ t, Measurable (action t)
  feasible : ∀ t h, action t h ≤ actionResources m z0 action t h

def planResources {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0) :=
  actionResources m z0 p.action

def planConsumption {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0)
    (t : ℕ) (h : History m t) : Resources := planResources p t h - p.action t h

theorem planResources_measurable {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0)
    (t : ℕ) : Measurable (planResources p t) := by
  cases t with
  | zero => exact measurable_const
  | succ t =>
    exact (nextResources_continuous m).measurable.comp
      (((p.measurable_action t).comp (previousHistory_measurable m t)).prodMk
        (newestShock_measurable m t))

theorem planConsumption_measurable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) : Measurable (planConsumption p t) :=
  (planResources_measurable p t).sub (p.measurable_action t)

theorem planConsumption_coe {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) (h : History m t) :
    (planConsumption p t h : ℝ) = (planResources p t h : ℝ) - (p.action t h : ℝ) :=
  NNReal.coe_sub (p.feasible t h)

theorem planConsumption_budget {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) (h : History m t) :
    planConsumption p t h + p.action t h = planResources p t h :=
  tsub_add_cancel_of_le (p.feasible t h)

def flowUtility {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0)
    (t : ℕ) (h : History m t) : ℝ := m.utility.utility (planConsumption p t h : ℝ)

def utilityBound (m : HouseholdPrimitives) : ℝ := Classical.choose m.utility_base.bounded

theorem utilityBound_spec (m : HouseholdPrimitives) (c : Resources) :
    |m.utility.utility (c : ℝ)| ≤ utilityBound m :=
  Classical.choose_spec m.utility_base.bounded _ c.property

theorem utilityBound_nonneg (m : HouseholdPrimitives) : 0 ≤ utilityBound m :=
  (abs_nonneg _).trans (utilityBound_spec m 0)

theorem flowUtility_measurable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) : Measurable (flowUtility p t) := by
  have hu : Continuous (fun c : Resources => m.utility.utility (c : ℝ)) :=
    m.utility_base.continuous.comp_continuous NNReal.continuous_coe (fun c => c.property)
  exact hu.measurable.comp (planConsumption_measurable p t)

theorem flowUtility_bound {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) (h : History m t) :
    |flowUtility p t h| ≤ utilityBound m := utilityBound_spec m _

theorem flowUtility_integrable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) : Integrable (flowUtility p t) (historyLaw m.income t) :=
  Integrable.of_bound (flowUtility_measurable p t).aestronglyMeasurable (utilityBound m)
    (Eventually.of_forall (flowUtility_bound p t))

def expectedFlow {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0) (t : ℕ) : ℝ :=
  ∫ h, flowUtility p t h ∂historyLaw m.income t

theorem expectedFlow_bound {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) : |expectedFlow p t| ≤ utilityBound m := by
  have hi := flowUtility_integrable p t
  simpa [expectedFlow, Real.norm_eq_abs] using
    norm_integral_le_of_norm_le_const (μ := historyLaw m.income t)
      (f := flowUtility p t) (C := utilityBound m)
      (Eventually.of_forall (flowUtility_bound p t))

def finiteUtility {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0) (N : ℕ) : ℝ :=
  ∑ t ∈ Finset.range N, m.beta^t * expectedFlow p t

def expectedTerminalValue {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (N : ℕ) : ℝ :=
  ∫ h, valueFunction m (planResources p N h) ∂historyLaw m.income N

theorem terminalValue_integrable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (N : ℕ) :
    Integrable (fun h => valueFunction m (planResources p N h)) (historyLaw m.income N) :=
  Integrable.of_bound ((valueFunction m).continuous.measurable.comp
    (planResources_measurable p N)).aestronglyMeasurable ‖valueFunction m‖
    (Eventually.of_forall (fun h => (valueFunction m).norm_coe_le_norm (planResources p N h)))

theorem expectedTerminalValue_bound {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (N : ℕ) : |expectedTerminalValue p N| ≤ ‖valueFunction m‖ := by
  have hi := terminalValue_integrable p N
  simpa [expectedTerminalValue,Real.norm_eq_abs] using
    norm_integral_le_of_norm_le_const (μ := historyLaw m.income N)
      (Eventually.of_forall (fun h => (valueFunction m).norm_coe_le_norm (planResources p N h)))

def lifetimeUtility {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0) : ℝ :=
  ∑' t, m.beta^t * expectedFlow p t

theorem discountedFlow_abs_summable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : Summable (fun t => |m.beta^t * expectedFlow p t|) := by
  apply ((summable_geometric_of_lt_one m.beta_pos.le m.beta_lt_one).mul_right
    (utilityBound m)).of_norm_bounded
  intro t
  simp only [Real.norm_eq_abs,abs_abs,abs_mul,abs_of_nonneg (pow_nonneg m.beta_pos.le t)]
  exact mul_le_mul_of_nonneg_left (expectedFlow_bound p t) (pow_nonneg m.beta_pos.le t)

theorem discountedFlow_summable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : Summable (fun t => m.beta^t * expectedFlow p t) :=
  Summable.of_norm (f := fun t => m.beta^t * expectedFlow p t) (discountedFlow_abs_summable p)

theorem finiteUtility_tendsto {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : Tendsto (finiteUtility p) atTop (𝓝 (lifetimeUtility p)) :=
  (discountedFlow_summable p).hasSum.tendsto_sum_nat


def planContinuation {m : HouseholdPrimitives} {z0 : Resources} (p : FeasiblePlan m z0)
    (t : ℕ) (h : History m t) : ℝ := continuation m (valueFunction m) (p.action t h)

theorem planContinuation_integrable {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) : Integrable (planContinuation p t) (historyLaw m.income t) :=
  Integrable.of_bound (((continuation_continuous m (valueFunction m)).measurable.comp
    (p.measurable_action t)).aestronglyMeasurable) ‖valueFunction m‖
    (Eventually.of_forall (fun h => continuation_bound m (valueFunction m) (p.action t h)))

theorem expectedTerminalValue_step {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) :
    expectedTerminalValue p (t+1) = ∫ h, planContinuation p t h ∂historyLaw m.income t := by
  have he := history_integral_step m t
    (fun h => valueFunction m (planResources p (t+1) h)) (terminalValue_integrable p (t+1))
  simpa only [expectedTerminalValue,planContinuation,continuation,planResources,actionResources,
    newestShock_extend,previousHistory_extend] using he

theorem plan_bellman_inequality {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) (h : History m t) :
    flowUtility p t h + m.beta * planContinuation p t h ≤ valueFunction m (planResources p t h) := by
  have hmax := assetPolicy_maximizes m (planResources p t h) (p.action t h) (p.feasible t h)
  rw [(assetPolicy_optimal m (planResources p t h)).2] at hmax
  exact hmax

theorem expected_bellman_inequality {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (t : ℕ) :
    expectedFlow p t + m.beta * expectedTerminalValue p (t+1) ≤ expectedTerminalValue p t := by
  have hi := integral_mono ((flowUtility_integrable p t).add
    ((planContinuation_integrable p t).const_mul m.beta)) (terminalValue_integrable p t)
    (plan_bellman_inequality p t)
  rw [expectedTerminalValue_step]
  simp only [Pi.add_apply] at hi
  simpa only [integral_add (flowUtility_integrable p t)
    ((planContinuation_integrable p t).const_mul m.beta), integral_const_mul,
    expectedFlow,expectedTerminalValue] using hi

@[simp] theorem expectedTerminalValue_zero {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : expectedTerminalValue p 0 = valueFunction m z0 := by
  simp [expectedTerminalValue,planResources,actionResources]

@[simp] theorem finiteUtility_zero {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : finiteUtility p 0 = 0 := by simp [finiteUtility]

theorem finiteUtility_succ {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (N : ℕ) :
    finiteUtility p (N+1) = finiteUtility p N + m.beta^N * expectedFlow p N := by
  simp [finiteUtility,Finset.sum_range_succ]

/-- Bellman telescoping for every history-dependent feasible plan. -/
theorem finiteHorizon_verification {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (N : ℕ) :
    finiteUtility p N + m.beta^N * expectedTerminalValue p N ≤ valueFunction m z0 := by
  induction N with
  | zero => simp
  | succ N ih =>
    calc
      _ = finiteUtility p N + m.beta^N *
          (expectedFlow p N + m.beta * expectedTerminalValue p (N+1)) := by
        rw [finiteUtility_succ,pow_succ]; ring
      _ ≤ finiteUtility p N + m.beta^N * expectedTerminalValue p N :=
        add_le_add le_rfl (mul_le_mul_of_nonneg_left (expected_bellman_inequality p N)
          (pow_nonneg m.beta_pos.le N))
      _ ≤ _ := ih

def canonicalResources (m : HouseholdPrimitives) (z0 : Resources) : (t : ℕ) → History m t → Resources
  | 0, _ => z0
  | t+1, h => m.prices.nextResources
      (assetPolicy m (canonicalResources m z0 t (previousHistory m t h))) (newestShock m t h)

theorem canonicalResources_measurable (m : HouseholdPrimitives) (z0 : Resources) (t : ℕ) :
    Measurable (canonicalResources m z0 t) := by
  induction t with
  | zero => exact measurable_const
  | succ t ih =>
    exact (nextResources_continuous m).measurable.comp
      (((assetPolicy_continuous m).measurable.comp
        (ih.comp (previousHistory_measurable m t))).prodMk (newestShock_measurable m t))

def canonicalAction (m : HouseholdPrimitives) (z0 : Resources) (t : ℕ) (h : History m t) : Resources :=
  assetPolicy m (canonicalResources m z0 t h)

theorem canonicalAction_resources (m : HouseholdPrimitives) (z0 : Resources) (t : ℕ) :
    actionResources m z0 (canonicalAction m z0) t = canonicalResources m z0 t := by
  cases t <;> rfl

def canonicalPlan (m : HouseholdPrimitives) (z0 : Resources) : FeasiblePlan m z0 where
  action := canonicalAction m z0
  measurable_action := fun t => (assetPolicy_continuous m).measurable.comp (canonicalResources_measurable m z0 t)
  feasible := by
    intro t h
    rw [canonicalAction_resources]
    exact assetPolicy_le_state m _

theorem canonicalPlan_action (m : HouseholdPrimitives) (z0 : Resources) (t : ℕ) (h : History m t) :
    (canonicalPlan m z0).action t h = assetPolicy m (planResources (canonicalPlan m z0) t h) := by
  change canonicalAction m z0 t h = assetPolicy m (actionResources m z0 (canonicalAction m z0) t h)
  rw [canonicalAction_resources]; rfl

theorem canonical_bellman_equality (m : HouseholdPrimitives) (z0 : Resources) (t : ℕ) (h : History m t) :
    flowUtility (canonicalPlan m z0) t h + m.beta * planContinuation (canonicalPlan m z0) t h =
      valueFunction m (planResources (canonicalPlan m z0) t h) := by
  change bellmanObjective m (valueFunction m) (planResources (canonicalPlan m z0) t h)
    ((canonicalPlan m z0).action t h) = _
  rw [canonicalPlan_action]
  exact (assetPolicy_optimal m _).2

theorem canonical_expected_bellman_equality (m : HouseholdPrimitives) (z0 : Resources) (t : ℕ) :
    expectedFlow (canonicalPlan m z0) t + m.beta * expectedTerminalValue (canonicalPlan m z0) (t+1) =
      expectedTerminalValue (canonicalPlan m z0) t := by
  have h := integral_congr_ae (μ := historyLaw m.income t)
    (Eventually.of_forall (canonical_bellman_equality m z0 t))
  rw [expectedTerminalValue_step]
  simpa only [integral_add (flowUtility_integrable (canonicalPlan m z0) t)
    ((planContinuation_integrable (canonicalPlan m z0) t).const_mul m.beta),
    integral_const_mul,expectedFlow,expectedTerminalValue] using h

theorem canonical_finiteHorizon_verification (m : HouseholdPrimitives) (z0 : Resources) (N : ℕ) :
    finiteUtility (canonicalPlan m z0) N + m.beta^N * expectedTerminalValue (canonicalPlan m z0) N =
      valueFunction m z0 := by
  induction N with
  | zero => simp
  | succ N ih =>
    calc
      _ = finiteUtility (canonicalPlan m z0) N + m.beta^N *
          (expectedFlow (canonicalPlan m z0) N + m.beta * expectedTerminalValue (canonicalPlan m z0) (N+1)) := by
        rw [finiteUtility_succ,pow_succ]; ring
      _ = _ := by rw [canonical_expected_bellman_equality,ih]

theorem discountedTerminalValue_bound {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (N : ℕ) :
    |m.beta^N * expectedTerminalValue p N| ≤ m.beta^N * ‖valueFunction m‖ := by
  rw [abs_mul,abs_of_nonneg (pow_nonneg m.beta_pos.le N)]
  exact mul_le_mul_of_nonneg_left (expectedTerminalValue_bound p N) (pow_nonneg m.beta_pos.le N)

theorem discountedTerminalValue_tendsto {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : Tendsto (fun N => m.beta^N * expectedTerminalValue p N) atTop (𝓝 0) := by
  have hg : Tendsto (fun N : ℕ => m.beta^N * ‖valueFunction m‖) atTop (𝓝 0) := by
    simpa only [zero_mul] using
      (tendsto_pow_atTop_nhds_zero_of_lt_one m.beta_pos.le m.beta_lt_one).mul_const ‖valueFunction m‖
  apply squeeze_zero_norm (fun N => by simpa only [Real.norm_eq_abs] using discountedTerminalValue_bound p N) hg

theorem lifetimeUtility_le_value {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) : lifetimeUtility p ≤ valueFunction m z0 := by
  have ht := (finiteUtility_tendsto p).add (discountedTerminalValue_tendsto p)
  simp only [add_zero] at ht
  exact le_of_tendsto ht (Eventually.of_forall (finiteHorizon_verification p))

theorem canonical_lifetimeUtility_eq_value (m : HouseholdPrimitives) (z0 : Resources) :
    lifetimeUtility (canonicalPlan m z0) = valueFunction m z0 := by
  have ht := (finiteUtility_tendsto (canonicalPlan m z0)).add
    (discountedTerminalValue_tendsto (canonicalPlan m z0))
  simp only [add_zero] at ht
  exact tendsto_nhds_unique ht (tendsto_const_nhds.congr
    (fun N => (canonical_finiteHorizon_verification m z0 N).symm))

/-- H05: the canonical policy dominates every measurable full-history feasible plan. -/
theorem canonicalPolicy_lifetime_optimal (m : HouseholdPrimitives) (z0 : Resources) :
    (∀ p : FeasiblePlan m z0, Summable (fun t => |m.beta^t * expectedFlow p t|)) ∧
    (∀ p : FeasiblePlan m z0, lifetimeUtility p ≤ valueFunction m z0) ∧
    lifetimeUtility (canonicalPlan m z0) = valueFunction m z0 ∧
    (∀ p : FeasiblePlan m z0, lifetimeUtility p ≤ lifetimeUtility (canonicalPlan m z0)) := by
  refine ⟨fun p => discountedFlow_abs_summable p, fun p => lifetimeUtility_le_value p,
    canonical_lifetimeUtility_eq_value m z0, ?_⟩
  intro p
  rw [canonical_lifetimeUtility_eq_value]
  exact lifetimeUtility_le_value p


/-- P01 applied at every date of an arbitrary original-price trajectory. -/
theorem original_shifted_trajectory_budget_iff {i : IncomeData} (p : OriginalPrices i)
    (assets consumption : ℕ → ℝ) (labor : ℕ → i.Labor) :
    (∀ t, consumption t + assets (t+1) = (1+p.netRate)*assets t+p.wage*(labor t : ℝ) ∧
      -p.debtLimit ≤ assets (t+1)) ↔
    (∀ t, consumption t + (assets (t+1)+p.debtLimit) =
      p.normalized.grossReturn*(assets t+p.debtLimit)+p.wage*(labor t : ℝ)-p.netRate*p.debtLimit ∧
      0 ≤ assets (t+1)+p.debtLimit) := by
  apply forall_congr'
  intro t
  exact shifted_budget_iff p.netRate p.wage (labor t : ℝ) p.debtLimit
    (assets t) (assets (t+1)) (consumption t)

/-- A feasible history plan satisfies the paper's original budget at each subsequent date. -/
theorem plan_original_budget_step {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (prices : OriginalPrices m.income) (hp : prices.normalized = m.prices)
    (t : ℕ) (h : History m (t+1)) :
    (planConsumption p (t+1) h : ℝ) + ((p.action (t+1) h : ℝ)-prices.debtLimit) =
      (1+prices.netRate)*((p.action t (previousHistory m t h) : ℝ)-prices.debtLimit)+
        prices.wage*(newestShock m t h : ℝ) ∧
      -prices.debtLimit ≤ (p.action (t+1) h : ℝ)-prices.debtLimit := by
  apply (shifted_budget_iff prices.netRate prices.wage (newestShock m t h : ℝ) prices.debtLimit
    ((p.action t (previousHistory m t h) : ℝ)-prices.debtLimit)
    ((p.action (t+1) h : ℝ)-prices.debtLimit) (planConsumption p (t+1) h : ℝ)).mpr
  simp only [sub_add_cancel]
  have hb : (planConsumption p (t+1) h : ℝ)+(p.action (t+1) h : ℝ) =
      (planResources p (t+1) h : ℝ) := by exact_mod_cast planConsumption_budget p (t+1) h
  refine ⟨hb.trans ?_, (p.action (t+1) h).property⟩
  change (m.prices.nextResources (p.action t (previousHistory m t h)) (newestShock m t h) : ℝ) = _
  rw [← hp]
  simp [NormalizedPrices.nextResources,NormalizedPrices.effectiveIncome,OriginalPrices.normalized,
    sub_eq_add_neg,add_assoc]
  rfl

/-- At date zero the coordinate relation determines the original initial assets/current labor. -/
theorem plan_original_budget_initial {m : HouseholdPrimitives} {z0 : Resources}
    (p : FeasiblePlan m z0) (prices : OriginalPrices m.income) (initialAssets : ℝ)
    (initialLabor : m.income.Labor)
    (hz : (z0 : ℝ) = (1+prices.netRate)*(initialAssets+prices.debtLimit)+
      prices.wage*(initialLabor : ℝ)-prices.netRate*prices.debtLimit) (h : History m 0) :
    (planConsumption p 0 h : ℝ)+((p.action 0 h : ℝ)-prices.debtLimit) =
      (1+prices.netRate)*initialAssets+prices.wage*(initialLabor : ℝ) ∧
      -prices.debtLimit ≤ (p.action 0 h : ℝ)-prices.debtLimit := by
  apply (shifted_budget_iff prices.netRate prices.wage (initialLabor : ℝ) prices.debtLimit
    initialAssets ((p.action 0 h : ℝ)-prices.debtLimit) (planConsumption p 0 h : ℝ)).mpr
  simp only [sub_add_cancel]
  have hb : (planConsumption p 0 h : ℝ)+(p.action 0 h : ℝ) = (z0 : ℝ) := by
    exact_mod_cast planConsumption_budget p 0 h
  exact ⟨hb.trans hz,(p.action 0 h).property⟩

end
end Aiyagari1994
