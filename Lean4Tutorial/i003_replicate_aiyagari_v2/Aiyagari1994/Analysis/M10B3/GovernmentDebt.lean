import Aiyagari1994.Budget.Normalization
import Aiyagari1994.Household.Verification
import Mathlib.MeasureTheory.Measure.Map

/-!
Gate-local support for E03.  The taxed asset coordinate is genuinely real-valued; only after
subtracting government debt do we apply the usual natural-limit shift into `Resources`.
-/
open MeasureTheory Set
open scoped NNReal
namespace Aiyagari1994
noncomputable section
namespace M10B3

structure PureExchangeDebt (base : HouseholdPrimitives) where
  netRate : ℝ
  wage : ℝ
  debt : ℝ
  netRate_pos : 0 < netRate
  wage_pos : 0 < wage

def naturalShift {base : HouseholdPrimitives} (e : PureExchangeDebt base) : ℝ :=
  e.wage * base.income.lower / e.netRate

theorem naturalShift_nonneg {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    0 ≤ naturalShift e := by
  exact div_nonneg (mul_nonneg e.wage_pos.le base.income_support.lower_pos.le)
    e.netRate_pos.le

def debtFreePrices {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    NormalizedPrices base.income where
  grossReturn := 1 + e.netRate
  wage := e.wage
  intercept := -e.netRate * naturalShift e
  grossReturn_pos := by linarith [e.netRate_pos]
  wage_pos := e.wage_pos
  income_nonneg := by
    intro l
    have hl : base.income.lower ≤ (l : ℝ) := l.property.1
    have hr : e.netRate ≠ 0 := ne_of_gt e.netRate_pos
    dsimp [naturalShift]
    have hcancel : e.netRate * (e.wage * base.income.lower / e.netRate) =
        e.wage * base.income.lower := by field_simp
    rw [neg_mul, hcancel]
    nlinarith [mul_nonneg e.wage_pos.le (sub_nonneg.mpr hl)]

def debtFreeHousehold {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    HouseholdPrimitives where
  beta := base.beta
  beta_pos := base.beta_pos
  beta_lt_one := base.beta_lt_one
  utility := base.utility
  utility_base := base.utility_base
  income := base.income
  income_support := base.income_support
  prices := debtFreePrices e

/-- The genuine debt-free original-price system obtained after `x=a-d`. -/
def debtFreeOriginalPrices {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    OriginalPrices base.income where
  netRate := e.netRate
  wage := e.wage
  debtLimit := naturalShift e
  netRate_gt := by linarith [e.netRate_pos]
  wage_pos := e.wage_pos
  debtLimit_nonneg := naturalShift_nonneg e
  income_nonneg := by
    intro l
    simpa [debtFreePrices, sub_eq_add_neg] using (debtFreePrices e).income_nonneg l

@[simp] theorem debtFreeOriginalPrices_normalized {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) :
    (debtFreeOriginalPrices e).normalized = debtFreePrices e := by
  rfl

/-- Exact cancellation: `(1+r)d-rd=d`.  Both directions are retained as an `iff`. -/
theorem taxed_budget_iff_debtFree (r w d a aNext c l : ℝ) :
    c + aNext = (1 + r) * a + w * l - r * d ↔
      c + (aNext - d) = (1 + r) * (a - d) + w * l := by
  constructor <;> intro h <;> nlinarith [h]

theorem taxed_floor_iff_debtFree (r w d laborMin a : ℝ) :
    a ≥ d - w * laborMin / r ↔ a - d ≥ -w * laborMin / r := by
  constructor
  · intro h
    have hs := sub_le_sub_right h d
    convert hs using 1 <;> ring
  · intro h
    have ha := add_le_add_right h d
    convert ha using 1 <;> ring

theorem shiftedAsset_eq_debtFreeAsset_add_naturalShift
    {base : HouseholdPrimitives} (e : PureExchangeDebt base) (a : ℝ) :
    a - e.debt + naturalShift e = (a - e.debt) + naturalShift e := rfl

/-- P01 is applied only after `x=a-d`: its shifted action is `aHat=x+phi`, not `x`. -/
theorem debtFree_shifted_budget_iff {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (x xNext c : ℝ) (l : base.income.Labor) :
    (c + xNext = (1 + e.netRate) * x + e.wage * (l : ℝ) ∧
        -naturalShift e ≤ xNext) ↔
      (c + (xNext + naturalShift e) =
          (1 + e.netRate) * (x + naturalShift e) + e.wage * (l : ℝ) -
            e.netRate * naturalShift e ∧
        0 ≤ xNext + naturalShift e) := by
  exact shifted_budget_iff e.netRate e.wage l (naturalShift e) x xNext c

structure DebtFreePlan {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z0 : Resources) where
  plan : FeasiblePlan (debtFreeHousehold e) z0

structure TaxedPlan {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z0 : Resources) where
  plan : FeasiblePlan (debtFreeHousehold e) z0

def toDebtFreePlan {base : HouseholdPrimitives} {e : PureExchangeDebt base} {z0 : Resources}
    (p : TaxedPlan e z0) : DebtFreePlan e z0 := ⟨p.plan⟩

def toTaxedPlan {base : HouseholdPrimitives} {e : PureExchangeDebt base} {z0 : Resources}
    (p : DebtFreePlan e z0) : TaxedPlan e z0 := ⟨p.plan⟩

@[simp] theorem toTaxedPlan_toDebtFreePlan {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0) :
    toTaxedPlan (toDebtFreePlan p) = p := by cases p; rfl

@[simp] theorem toDebtFreePlan_toTaxedPlan {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : DebtFreePlan e z0) :
    toDebtFreePlan (toTaxedPlan p) = p := by cases p; rfl

def DebtFreePlan.asset {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : DebtFreePlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) : ℝ :=
  (p.plan.action t h : ℝ) - naturalShift e

def TaxedPlan.asset {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) : ℝ :=
  (p.plan.action t h : ℝ) - naturalShift e + e.debt

def DebtFreePlan.consumption {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : DebtFreePlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) : Resources := planConsumption p.plan t h

def TaxedPlan.consumption {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) : Resources := planConsumption p.plan t h

theorem plan_asset_translation {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    p.asset t h = (toDebtFreePlan p).asset t h + e.debt := by rfl

theorem plan_consumption_preserved {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    p.consumption t h = (toDebtFreePlan p).consumption t h := rfl

theorem debtFreePlan_admissible {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : DebtFreePlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) : -naturalShift e ≤ p.asset t h := by
  have hnonneg : (0 : ℝ) ≤ (p.plan.action t h : ℝ) := NNReal.coe_nonneg _
  dsimp [DebtFreePlan.asset]
  linarith only [hnonneg]

theorem taxedPlan_admissible {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    e.debt - naturalShift e ≤ p.asset t h := by
  have hnonneg : (0 : ℝ) ≤ (p.plan.action t h : ℝ) := NNReal.coe_nonneg _
  have hs := sub_le_sub_right hnonneg (naturalShift e)
  have ha := add_le_add_right hs e.debt
  change e.debt - naturalShift e ≤
    (p.plan.action t h : ℝ) - naturalShift e + e.debt
  calc
    e.debt - naturalShift e = e.debt + (0 - naturalShift e) := by ring
    _ ≤ e.debt + ((p.plan.action t h : ℝ) - naturalShift e) := ha
    _ = (p.plan.action t h : ℝ) - naturalShift e + e.debt := by ring

theorem debtFreePlan_budget {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : DebtFreePlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    (p.consumption t h : ℝ) + p.asset t h =
      (planResources p.plan t h : ℝ) - naturalShift e := by
  rw [DebtFreePlan.consumption, planConsumption_coe]
  dsimp [DebtFreePlan.asset]
  ring

theorem taxedPlan_budget {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    (p.consumption t h : ℝ) + p.asset t h =
      (planResources p.plan t h : ℝ) - naturalShift e + e.debt := by
  rw [TaxedPlan.consumption, planConsumption_coe]
  dsimp [TaxedPlan.asset]
  ring

/-- At positive dates, a debt-free plan satisfies the original-coordinate budget with the
current asset inherited from the preceding normalized action. -/
theorem debtFreePlan_original_budget_step {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : DebtFreePlan e z0)
    (t : ℕ) (h : History (debtFreeHousehold e) (t + 1)) :
    (p.consumption (t + 1) h : ℝ) + p.asset (t + 1) h =
        (1 + e.netRate) * p.asset t (previousHistory (debtFreeHousehold e) t h) +
          e.wage * (newestShock (debtFreeHousehold e) t h : ℝ) ∧
      -naturalShift e ≤ p.asset (t + 1) h := by
  exact plan_original_budget_step p.plan (debtFreeOriginalPrices (base := base) e) rfl t h

/-- The same positive-date H05 plan, read in taxed assets, satisfies the actual taxed budget. -/
theorem taxedPlan_original_budget_step {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0)
    (t : ℕ) (h : History (debtFreeHousehold e) (t + 1)) :
    (p.consumption (t + 1) h : ℝ) + p.asset (t + 1) h =
        (1 + e.netRate) * p.asset t (previousHistory (debtFreeHousehold e) t h) +
          e.wage * (newestShock (debtFreeHousehold e) t h : ℝ) -
            e.netRate * e.debt ∧
      e.debt - naturalShift e ≤ p.asset (t + 1) h := by
  have hfree := debtFreePlan_original_budget_step (toDebtFreePlan p) t h
  constructor
  · apply (taxed_budget_iff_debtFree e.netRate e.wage e.debt
      (p.asset t (previousHistory (debtFreeHousehold e) t h))
      (p.asset (t + 1) h) (p.consumption (t + 1) h)
      (newestShock (debtFreeHousehold e) t h : ℝ)).2
    rw [plan_consumption_preserved p, plan_asset_translation p,
      plan_asset_translation p]
    simpa only [add_sub_cancel_right] using hfree.1
  · exact taxedPlan_admissible p (t + 1) h

/-- The initial normalized resource is the shifted form of the debt-free current asset and
current labor.  Under this relation the date-zero H05 budget is an original-coordinate budget. -/
theorem debtFreePlan_original_budget_initial {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : DebtFreePlan e z0)
    (x0 : ℝ) (l0 : base.income.Labor)
    (hz : (z0 : ℝ) = (1 + e.netRate) * (x0 + naturalShift e) +
      e.wage * (l0 : ℝ) - e.netRate * naturalShift e)
    (h : History (debtFreeHousehold e) 0) :
    (p.consumption 0 h : ℝ) + p.asset 0 h =
        (1 + e.netRate) * x0 + e.wage * (l0 : ℝ) ∧
      -naturalShift e ≤ p.asset 0 h := by
  exact plan_original_budget_initial p.plan (debtFreeOriginalPrices (base := base) e) x0 l0 hz h

/-- The corresponding initial relation for taxed assets uses `a0-d+phi`; it yields the actual
taxed date-zero budget, including the lump-sum tax `r*d`. -/
theorem taxedPlan_original_budget_initial {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0)
    (a0 : ℝ) (l0 : base.income.Labor)
    (hz : (z0 : ℝ) = (1 + e.netRate) * (a0 - e.debt + naturalShift e) +
      e.wage * (l0 : ℝ) - e.netRate * naturalShift e)
    (h : History (debtFreeHousehold e) 0) :
    (p.consumption 0 h : ℝ) + p.asset 0 h =
        (1 + e.netRate) * a0 + e.wage * (l0 : ℝ) - e.netRate * e.debt ∧
      e.debt - naturalShift e ≤ p.asset 0 h := by
  have hfree := debtFreePlan_original_budget_initial (toDebtFreePlan p)
    (a0 - e.debt) l0 hz h
  constructor
  · apply (taxed_budget_iff_debtFree e.netRate e.wage e.debt a0
      (p.asset 0 h) (p.consumption 0 h) (l0 : ℝ)).2
    rw [plan_consumption_preserved p, plan_asset_translation p]
    simpa only [add_sub_cancel_right] using hfree.1
  · exact taxedPlan_admissible p 0 h

theorem debtFreePlan_asset_measurable {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : DebtFreePlan e z0) (t : ℕ) : Measurable (p.asset t) := by
  exact (measurable_coe_nnreal_real.comp (p.plan.measurable_action t)).sub measurable_const

theorem taxedPlan_asset_measurable {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) (t : ℕ) : Measurable (p.asset t) := by
  exact ((measurable_coe_nnreal_real.comp (p.plan.measurable_action t)).sub
    measurable_const).add measurable_const

theorem plan_full_history_nonanticipative {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0) :
    (∀ t, Measurable (p.asset t)) ∧
      ∀ t, Measurable ((toDebtFreePlan p).asset t) := by
  exact ⟨taxedPlan_asset_measurable p, debtFreePlan_asset_measurable (toDebtFreePlan p)⟩

theorem plan_consumption_measurable {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0) :
    (∀ t, Measurable (p.consumption t)) ∧
      ∀ t, Measurable ((toDebtFreePlan p).consumption t) := by
  exact ⟨fun t ↦ planConsumption_measurable p.plan t,
    fun t ↦ planConsumption_measurable (toDebtFreePlan p).plan t⟩

def DebtFreePlan.lifetimeUtility {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : DebtFreePlan e z0) : ℝ := Aiyagari1994.lifetimeUtility p.plan

def TaxedPlan.lifetimeUtility {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) : ℝ := Aiyagari1994.lifetimeUtility p.plan

theorem plan_lifetimeUtility_preserved {base : HouseholdPrimitives} {e : PureExchangeDebt base}
    {z0 : Resources} (p : TaxedPlan e z0) :
    p.lifetimeUtility = (toDebtFreePlan p).lifetimeUtility := rfl

/-- Because the full-history plan maps are inverse and preserve consumption exactly, domination
of every feasible plan is equivalent in the taxed and debt-free coordinates. -/
theorem lifetimeOptimality_transport {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0) :
    (∀ q : TaxedPlan e z0, q.lifetimeUtility ≤ p.lifetimeUtility) ↔
      (∀ q : DebtFreePlan e z0,
        q.lifetimeUtility ≤ (toDebtFreePlan p).lifetimeUtility) := by
  constructor
  · intro h q
    change Aiyagari1994.lifetimeUtility q.plan ≤ Aiyagari1994.lifetimeUtility p.plan
    exact h (toTaxedPlan q)
  · intro h q
    change Aiyagari1994.lifetimeUtility q.plan ≤ Aiyagari1994.lifetimeUtility p.plan
    exact h (toDebtFreePlan q)

def canonicalDebtFreePlan {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z0 : Resources) : DebtFreePlan e z0 := ⟨canonicalPlan (debtFreeHousehold e) z0⟩

def canonicalTaxedPlan {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z0 : Resources) : TaxedPlan e z0 := toTaxedPlan (canonicalDebtFreePlan e z0)

theorem debtFree_lifetime_optimal {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z0 : Resources) (p : DebtFreePlan e z0) :
    p.lifetimeUtility ≤ (canonicalDebtFreePlan e z0).lifetimeUtility := by
  exact (canonicalPolicy_lifetime_optimal (debtFreeHousehold e) z0).2.2.2 p.plan

theorem taxed_lifetime_optimal {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z0 : Resources) (p : TaxedPlan e z0) :
    p.lifetimeUtility ≤ (canonicalTaxedPlan e z0).lifetimeUtility := by
  exact (lifetimeOptimality_transport (canonicalTaxedPlan e z0)).2
    (debtFree_lifetime_optimal e z0) p

theorem lifetimeUtility_absolutely_summable {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) :
    (∀ p : DebtFreePlan e z0,
      Summable (fun t ↦ |base.beta ^ t * expectedFlow p.plan t|)) ∧
    (∀ p : TaxedPlan e z0,
      Summable (fun t ↦ |base.beta ^ t * expectedFlow p.plan t|)) := by
  constructor <;> intro p
  · simpa [debtFreeHousehold] using
      (canonicalPolicy_lifetime_optimal (debtFreeHousehold e) z0).1 p.plan
  · simpa [debtFreeHousehold] using
      (canonicalPolicy_lifetime_optimal (debtFreeHousehold e) z0).1 p.plan

def debtFreeAssetPolicy {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z : Resources) : ℝ := (assetPolicy (debtFreeHousehold e) z : ℝ) - naturalShift e

def taxedAssetPolicy {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z : Resources) : ℝ := debtFreeAssetPolicy e z + e.debt

def debtFreeConsumptionPolicy {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z : Resources) : Resources := consumptionPolicy (debtFreeHousehold e) z

def taxedConsumptionPolicy {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (z : Resources) : Resources := consumptionPolicy (debtFreeHousehold e) z

theorem canonical_policy_translation {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    (∀ z, taxedAssetPolicy e z = debtFreeAssetPolicy e z + e.debt) ∧
      taxedConsumptionPolicy e = debtFreeConsumptionPolicy e := by
  exact ⟨fun _ ↦ rfl, rfl⟩

/-- On the debt-free natural-floor domain, current original resources plus `phi` are
nonnegative and therefore define the normalized policy state without truncation. -/
theorem debtFreeTransition_input_nonneg {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (x : ℝ) (l : base.income.Labor)
    (hx : -naturalShift e ≤ x) :
    0 ≤ (1 + e.netRate) * x + e.wage * (l : ℝ) + naturalShift e := by
  let aHat : Resources := ⟨x + naturalShift e, by linarith⟩
  have hn := ((debtFreePrices e).nextResources aHat l).property
  change 0 ≤ (1 + e.netRate) * (x + naturalShift e) +
    (e.wage * (l : ℝ) + -e.netRate * naturalShift e) at hn
  nlinarith [hn]

/-- The corrected debt-free transition input is exactly normalized next resources generated by
the shifted current asset `x+phi`. -/
theorem debtFreeTransition_input_eq_nextResources {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (x : ℝ) (l : base.income.Labor)
    (hx : -naturalShift e ≤ x) :
    Real.toNNReal ((1 + e.netRate) * x + e.wage * (l : ℝ) + naturalShift e) =
      (debtFreePrices e).nextResources
        ⟨x + naturalShift e, by linarith⟩ l := by
  apply NNReal.eq
  rw [Real.coe_toNNReal _ (debtFreeTransition_input_nonneg e x l hx)]
  change (1 + e.netRate) * x + e.wage * (l : ℝ) + naturalShift e =
    (1 + e.netRate) * (x + naturalShift e) +
      (e.wage * (l : ℝ) + -e.netRate * naturalShift e)
  ring

/-- On the taxed floor domain the corrected taxed transition input is nonnegative. -/
theorem taxedTransition_input_nonneg {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (a : ℝ) (l : base.income.Labor)
    (ha : e.debt - naturalShift e ≤ a) :
    0 ≤ (1 + e.netRate) * a + e.wage * (l : ℝ) - e.netRate * e.debt -
      e.debt + naturalShift e := by
  have hx : -naturalShift e ≤ a - e.debt := by linarith
  have hn := debtFreeTransition_input_nonneg e (a - e.debt) l hx
  nlinarith [hn]

/-- The corrected taxed input is the same normalized next resource generated by the shifted
asset `a-d+phi`. -/
theorem taxedTransition_input_eq_nextResources {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (a : ℝ) (l : base.income.Labor)
    (ha : e.debt - naturalShift e ≤ a) :
    Real.toNNReal ((1 + e.netRate) * a + e.wage * (l : ℝ) -
        e.netRate * e.debt - e.debt + naturalShift e) =
      (debtFreePrices e).nextResources
        ⟨a - e.debt + naturalShift e, by linarith⟩ l := by
  have hx : -naturalShift e ≤ a - e.debt := by linarith
  convert debtFreeTransition_input_eq_nextResources e (a - e.debt) l hx using 1 <;> ring

def debtFreeTransition {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (xl : ℝ × base.income.Labor) : ℝ :=
  debtFreeAssetPolicy e (Real.toNNReal
    ((1 + e.netRate) * xl.1 + e.wage * (xl.2 : ℝ) + naturalShift e))

def taxedTransition {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (al : ℝ × base.income.Labor) : ℝ :=
  taxedAssetPolicy e (Real.toNNReal
    ((1 + e.netRate) * al.1 + e.wage * (al.2 : ℝ) - e.netRate * e.debt -
      e.debt + naturalShift e))

theorem canonical_transition_conjugate {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (x : ℝ) (l : base.income.Labor) :
    taxedTransition e (x + e.debt, l) = debtFreeTransition e (x, l) + e.debt := by
  unfold taxedTransition debtFreeTransition taxedAssetPolicy
  congr 2
  congr 1
  ring

theorem debtFreeTransition_admissible {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (xl : ℝ × base.income.Labor) :
    -naturalShift e ≤ debtFreeTransition e xl := by
  unfold debtFreeTransition debtFreeAssetPolicy
  have hnonneg : (0 : ℝ) ≤
      (assetPolicy (debtFreeHousehold e)
        (Real.toNNReal ((1 + e.netRate) * xl.1 + e.wage * (xl.2 : ℝ) +
          naturalShift e)) : ℝ) := NNReal.coe_nonneg _
  linarith

theorem taxedTransition_admissible {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (al : ℝ × base.income.Labor) :
    e.debt - naturalShift e ≤ taxedTransition e al := by
  unfold taxedTransition taxedAssetPolicy debtFreeAssetPolicy
  have hnonneg : (0 : ℝ) ≤
      (assetPolicy (debtFreeHousehold e)
        (Real.toNNReal ((1 + e.netRate) * al.1 + e.wage * (al.2 : ℝ) -
          e.netRate * e.debt - e.debt + naturalShift e)) : ℝ) := NNReal.coe_nonneg _
  linarith

theorem debtFreePlan_nextResources {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : DebtFreePlan e z0)
    (t : ℕ) (h : History (debtFreeHousehold e) (t + 1)) :
    planResources p.plan (t + 1) h =
      (debtFreePrices e).nextResources
        ⟨p.asset t (previousHistory (debtFreeHousehold e) t h) + naturalShift e,
          by
            have hf := debtFreePlan_admissible p t
              (previousHistory (debtFreeHousehold e) t h)
            linarith⟩
        (newestShock (debtFreeHousehold e) t h) := by
  unfold planResources actionResources
  change (debtFreePrices e).nextResources
    (p.plan.action t (previousHistory (debtFreeHousehold e) t h))
      (newestShock (debtFreeHousehold e) t h) = _
  apply congrArg (fun a : Resources ↦
    (debtFreePrices e).nextResources a (newestShock (debtFreeHousehold e) t h))
  apply Subtype.ext
  simp [DebtFreePlan.asset]

theorem taxedPlan_nextResources {base : HouseholdPrimitives}
    {e : PureExchangeDebt base} {z0 : Resources} (p : TaxedPlan e z0)
    (t : ℕ) (h : History (debtFreeHousehold e) (t + 1)) :
    planResources p.plan (t + 1) h =
      (debtFreePrices e).nextResources
        ⟨p.asset t (previousHistory (debtFreeHousehold e) t h) - e.debt + naturalShift e,
          by
            have hf := taxedPlan_admissible p t
              (previousHistory (debtFreeHousehold e) t h)
            linarith⟩
        (newestShock (debtFreeHousehold e) t h) := by
  unfold planResources actionResources
  change (debtFreePrices e).nextResources
    (p.plan.action t (previousHistory (debtFreeHousehold e) t h))
      (newestShock (debtFreeHousehold e) t h) = _
  apply congrArg (fun a : Resources ↦
    (debtFreePrices e).nextResources a (newestShock (debtFreeHousehold e) t h))
  apply Subtype.ext
  simp [TaxedPlan.asset]

/-- Every date of the canonical debt-free H05 plan uses the normalized policy at its actual
current resources; the returned real number is its actual next-date original asset. -/
theorem canonicalDebtFreePlan_asset_policy {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    (canonicalDebtFreePlan e z0).asset t h =
      debtFreeAssetPolicy e
        (planResources (canonicalDebtFreePlan e z0).plan t h) := by
  change ((canonicalPlan (debtFreeHousehold e) z0).action t h : ℝ) - naturalShift e =
    (assetPolicy (debtFreeHousehold e)
      (planResources (canonicalPlan (debtFreeHousehold e) z0) t h) : ℝ) - naturalShift e
  rw [canonicalPlan_action]

/-- The taxed canonical plan selects the same normalized action and translates the actual
next-date asset by `d`. -/
theorem canonicalTaxedPlan_asset_policy {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) (t : ℕ)
    (h : History (debtFreeHousehold e) t) :
    (canonicalTaxedPlan e z0).asset t h =
      taxedAssetPolicy e
        (planResources (canonicalTaxedPlan e z0).plan t h) := by
  change ((canonicalPlan (debtFreeHousehold e) z0).action t h : ℝ) - naturalShift e + e.debt =
    (assetPolicy (debtFreeHousehold e)
      (planResources (canonicalPlan (debtFreeHousehold e) z0) t h) : ℝ) -
        naturalShift e + e.debt
  rw [canonicalPlan_action]

/-- Along the canonical H05 plan, the corrected debt-free transition generates the actual
next-date asset from the current original asset and newly arriving labor shock. -/
theorem canonicalDebtFreePlan_asset_transition_step {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) (t : ℕ)
    (h : History (debtFreeHousehold e) (t + 1)) :
    (canonicalDebtFreePlan e z0).asset (t + 1) h =
      debtFreeTransition e
        ((canonicalDebtFreePlan e z0).asset t
          (previousHistory (debtFreeHousehold e) t h),
        newestShock (debtFreeHousehold e) t h) := by
  rw [canonicalDebtFreePlan_asset_policy]
  unfold debtFreeTransition
  congr 1
  rw [debtFreeTransition_input_eq_nextResources e _ _
    (debtFreePlan_admissible (canonicalDebtFreePlan e z0) t _)]
  exact debtFreePlan_nextResources (canonicalDebtFreePlan e z0) t h

/-- The analogous taxed recursion contains the tax and debt repayment in its resource input and
returns the actual taxed next-date asset. -/
theorem canonicalTaxedPlan_asset_transition_step {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) (t : ℕ)
    (h : History (debtFreeHousehold e) (t + 1)) :
    (canonicalTaxedPlan e z0).asset (t + 1) h =
      taxedTransition e
        ((canonicalTaxedPlan e z0).asset t
          (previousHistory (debtFreeHousehold e) t h),
        newestShock (debtFreeHousehold e) t h) := by
  rw [canonicalTaxedPlan_asset_policy]
  unfold taxedTransition
  congr 1
  rw [taxedTransition_input_eq_nextResources e _ _
    (taxedPlan_admissible (canonicalTaxedPlan e z0) t _)]
  exact taxedPlan_nextResources (canonicalTaxedPlan e z0) t h

/-- At date zero, the explicit debt-free initial-resource relation identifies the transition
with the first actual next-date asset of the canonical H05 plan. -/
theorem canonicalDebtFreePlan_asset_transition_initial {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) (x0 : ℝ)
    (l0 : base.income.Labor) (hx : -naturalShift e ≤ x0)
    (hz : (z0 : ℝ) = (1 + e.netRate) * x0 + e.wage * (l0 : ℝ) + naturalShift e)
    (h : History (debtFreeHousehold e) 0) :
    (canonicalDebtFreePlan e z0).asset 0 h = debtFreeTransition e (x0, l0) := by
  rw [canonicalDebtFreePlan_asset_policy]
  unfold planResources actionResources debtFreeTransition
  congr 1
  apply NNReal.eq
  rw [Real.coe_toNNReal _ (debtFreeTransition_input_nonneg e x0 l0 hx)]
  exact hz

/-- The taxed initial-resource relation uses `a0-d+phi` and identifies the first actual taxed
next-date asset of the canonical H05 plan. -/
theorem canonicalTaxedPlan_asset_transition_initial {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (z0 : Resources) (a0 : ℝ)
    (l0 : base.income.Labor) (ha : e.debt - naturalShift e ≤ a0)
    (hz : (z0 : ℝ) = (1 + e.netRate) * a0 + e.wage * (l0 : ℝ) -
      e.netRate * e.debt - e.debt + naturalShift e)
    (h : History (debtFreeHousehold e) 0) :
    (canonicalTaxedPlan e z0).asset 0 h = taxedTransition e (a0, l0) := by
  rw [canonicalTaxedPlan_asset_policy]
  unfold planResources actionResources taxedTransition
  congr 1
  apply NNReal.eq
  rw [Real.coe_toNNReal _ (taxedTransition_input_nonneg e a0 l0 ha)]
  exact hz

def addDebtEquiv (d : ℝ) : ℝ ≃ᵐ ℝ where
  toFun x := x + d
  invFun a := a - d
  left_inv x := by ring
  right_inv a := by ring
  measurable_toFun := measurable_id.add measurable_const
  measurable_invFun := measurable_id.sub measurable_const

def addDebtLaw (d : ℝ) (mu : Measure ℝ) : Measure ℝ := Measure.map (addDebtEquiv d) mu
def subtractDebtLaw (d : ℝ) (mu : Measure ℝ) : Measure ℝ :=
  Measure.map (addDebtEquiv d).symm mu

@[simp] theorem subtractDebtLaw_addDebtLaw (d : ℝ) (mu : Measure ℝ) :
    subtractDebtLaw d (addDebtLaw d mu) = mu := by
  rw [subtractDebtLaw, addDebtLaw,
    Measure.map_map (addDebtEquiv d).symm.measurable (addDebtEquiv d).measurable]
  simp

@[simp] theorem addDebtLaw_subtractDebtLaw (d : ℝ) (mu : Measure ℝ) :
    addDebtLaw d (subtractDebtLaw d mu) = mu := by
  rw [subtractDebtLaw, addDebtLaw,
    Measure.map_map (addDebtEquiv d).measurable (addDebtEquiv d).symm.measurable]
  simp

def debtFreeLawStep {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (mu : Measure ℝ) : Measure ℝ :=
  Measure.map (debtFreeTransition e) (mu.prod (base.income.law : Measure base.income.Labor))

def taxedLawStep {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (mu : Measure ℝ) : Measure ℝ :=
  Measure.map (taxedTransition e) (mu.prod (base.income.law : Measure base.income.Labor))

theorem debtFreeTransition_measurable {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    Measurable (debtFreeTransition e) := by
  unfold debtFreeTransition debtFreeAssetPolicy
  exact (measurable_coe_nnreal_real.comp
    ((assetPolicy_continuous (debtFreeHousehold e)).measurable.comp
      ((measurable_id.fst.const_mul (1 + e.netRate) |>.add
        (continuous_subtype_val.measurable.comp measurable_id.snd |>.const_mul
          e.wage)).add measurable_const).real_toNNReal)).sub
    measurable_const

theorem taxedTransition_measurable {base : HouseholdPrimitives} (e : PureExchangeDebt base) :
    Measurable (taxedTransition e) := by
  unfold taxedTransition taxedAssetPolicy debtFreeAssetPolicy
  exact ((measurable_coe_nnreal_real.comp
    ((assetPolicy_continuous (debtFreeHousehold e)).measurable.comp
      (((measurable_id.fst.const_mul (1 + e.netRate) |>.add
        (continuous_subtype_val.measurable.comp measurable_id.snd |>.const_mul
          e.wage)).sub measurable_const).sub
          measurable_const |>.add measurable_const).real_toNNReal)).sub
            measurable_const).add measurable_const

/-- Every one-step debt-free law is supported on the economically admissible natural-floor
domain, even though its input law is represented on all of `ℝ`. -/
theorem debtFreeLawStep_supported {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (mu : Measure ℝ) :
    ∀ᵐ x ∂debtFreeLawStep e mu, -naturalShift e ≤ x := by
  rw [debtFreeLawStep, ae_map_iff (debtFreeTransition_measurable e).aemeasurable
    measurableSet_Ici]
  filter_upwards [] with xl
  exact debtFreeTransition_admissible e xl

/-- Every one-step taxed law is supported on its translated, possibly positive, floor domain. -/
theorem taxedLawStep_supported {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (mu : Measure ℝ) :
    ∀ᵐ a ∂taxedLawStep e mu, e.debt - naturalShift e ≤ a := by
  rw [taxedLawStep, ae_map_iff (taxedTransition_measurable e).aemeasurable
    measurableSet_Ici]
  filter_upwards [] with al
  exact taxedTransition_admissible e al

/-- Invariance on the ambient real line forces the debt-free law onto the admissible domain. -/
theorem debtFreeInvariant_supported {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (mu : Measure ℝ)
    (hinv : debtFreeLawStep e mu = mu) :
    ∀ᵐ x ∂mu, -naturalShift e ≤ x := by
  rw [← hinv]
  exact debtFreeLawStep_supported e mu

/-- Invariance on the ambient real line forces the taxed law onto its translated floor domain. -/
theorem taxedInvariant_supported {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (mu : Measure ℝ)
    (hinv : taxedLawStep e mu = mu) :
    ∀ᵐ a ∂mu, e.debt - naturalShift e ≤ a := by
  rw [← hinv]
  exact taxedLawStep_supported e mu

theorem lawStep_conjugate {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (mu : Measure ℝ) [SFinite mu] :
    taxedLawStep e (addDebtLaw e.debt mu) = addDebtLaw e.debt (debtFreeLawStep e mu) := by
  unfold taxedLawStep debtFreeLawStep addDebtLaw
  rw [show (base.income.law : Measure base.income.Labor) =
      Measure.map id (base.income.law : Measure base.income.Labor) by simp]
  rw [Measure.map_prod_map _ _ (addDebtEquiv e.debt).measurable measurable_id]
  simp only [Measure.map_id]
  rw [Measure.map_map (addDebtEquiv e.debt).measurable (debtFreeTransition_measurable e)]
  rw [Measure.map_map (taxedTransition_measurable e)
    ((addDebtEquiv e.debt).measurable.prodMap measurable_id)]
  apply Measure.map_congr
  filter_upwards [] with xl
  exact canonical_transition_conjugate e xl.1 xl.2

theorem invariantLaw_correspondence {base : HouseholdPrimitives} (e : PureExchangeDebt base)
    (mu : Measure ℝ) [SFinite mu] :
    debtFreeLawStep e mu = mu ↔
      taxedLawStep e (addDebtLaw e.debt mu) = addDebtLaw e.debt mu := by
  rw [lawStep_conjugate]
  constructor
  · exact fun h ↦ congrArg (addDebtLaw e.debt) h
  · exact fun h ↦ (addDebtEquiv e.debt).measurableEmbedding.map_injective h

/-- The inverse half of the invariant-law bijection starts from an arbitrary taxed law and
pushes it back by subtraction of government debt. -/
theorem invariantLaw_correspondence_inverse {base : HouseholdPrimitives}
    (e : PureExchangeDebt base) (nu : Measure ℝ) [SFinite nu] :
    taxedLawStep e nu = nu ↔
      debtFreeLawStep e (subtractDebtLaw e.debt nu) = subtractDebtLaw e.debt nu := by
  letI : SFinite (subtractDebtLaw e.debt nu) := by
    unfold subtractDebtLaw
    infer_instance
  have h := invariantLaw_correspondence e (subtractDebtLaw e.debt nu)
  rw [addDebtLaw_subtractDebtLaw] at h
  exact h.symm

theorem id_integrable_addDebtLaw_iff (d : ℝ) (mu : Measure ℝ) [IsFiniteMeasure mu] :
    Integrable (fun a : ℝ ↦ a) (addDebtLaw d mu) ↔ Integrable (fun x : ℝ ↦ x) mu := by
  rw [addDebtLaw, (addDebtEquiv d).measurableEmbedding.integrable_map_iff]
  constructor <;> intro h
  · change Integrable (fun x : ℝ ↦ x + d) mu at h
    rw [show (fun x : ℝ ↦ x) = (fun x ↦ x + d) - (fun _ ↦ d) by
      funext x; simp]
    exact h.sub (integrable_const d)
  · change Integrable (fun x : ℝ ↦ x + d) mu
    rw [show (fun x : ℝ ↦ x + d) = (fun x ↦ x) + (fun _ ↦ d) by rfl]
    exact h.add (integrable_const d)

theorem bondClearing_iff_zeroNetAssets (d : ℝ) (mu : Measure ℝ)
    [IsProbabilityMeasure mu] (hint : Integrable (fun x : ℝ ↦ x) mu) :
    Integrable (fun a : ℝ ↦ a) (addDebtLaw d mu) ∧
      ((∫ a, a ∂addDebtLaw d mu) = d ↔ (∫ x, x ∂mu) = 0) := by
  have ha : Integrable (fun a : ℝ ↦ a) (addDebtLaw d mu) :=
    (id_integrable_addDebtLaw_iff d mu).2 hint
  refine ⟨ha, ?_⟩
  rw [addDebtLaw, integral_map_equiv]
  change ((∫ x, x + d ∂mu) = d ↔ (∫ x, x ∂mu) = 0)
  rw [integral_add hint (integrable_const d), integral_const, probReal_univ,
    one_smul]
  constructor <;> intro h <;> linarith

end M10B3
end
end Aiyagari1994
