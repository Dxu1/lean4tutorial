import Aiyagari1994.Analysis.M10B3.GovernmentDebt

/-! E03 public wrapper: pure-exchange government debt under the tax-adjusted natural bound. -/
open MeasureTheory
namespace Aiyagari1994
noncomputable section

/-- E03.  Subtracting constant government debt converts the taxed pure-exchange household into
the debt-free natural-bound household.  The result includes exact budget/floor algebra, inverse
full-history feasible-plan views, H05 lifetime optimality, canonical policy and transition
translation, invariant-law pushforward correspondence without existence, and integrable bond
clearing.  It contains no capital-demand, fixed-cap, money, or growth conclusion. -/
theorem naturalBound_governmentDebt_correspondence
    (base : HouseholdPrimitives) (e : M10B3.PureExchangeDebt base) (z0 : Resources)
    (mu : Measure ℝ) [IsProbabilityMeasure mu]
    (hint : Integrable (fun x : ℝ ↦ x) mu) :
    (∀ (c a aNext : ℝ) (l : base.income.Labor),
      c + aNext = (1 + e.netRate) * a + e.wage * (l : ℝ) - e.netRate * e.debt ↔
        c + (aNext - e.debt) =
          (1 + e.netRate) * (a - e.debt) + e.wage * (l : ℝ)) ∧
    (∀ a : ℝ,
      a ≥ e.debt - e.wage * base.income.lower / e.netRate ↔
        a - e.debt ≥ -e.wage * base.income.lower / e.netRate) ∧
    (∀ (c x xNext : ℝ) (l : base.income.Labor),
      (c + xNext = (1 + e.netRate) * x + e.wage * (l : ℝ) ∧
          -M10B3.naturalShift e ≤ xNext) ↔
        (c + (xNext + M10B3.naturalShift e) =
            (1 + e.netRate) * (x + M10B3.naturalShift e) + e.wage * (l : ℝ) -
              e.netRate * M10B3.naturalShift e ∧
          0 ≤ xNext + M10B3.naturalShift e)) ∧
    (∀ (x : ℝ) (l : base.income.Labor) (hx : -M10B3.naturalShift e ≤ x),
      0 ≤ (1 + e.netRate) * x + e.wage * (l : ℝ) + M10B3.naturalShift e ∧
      Real.toNNReal ((1 + e.netRate) * x + e.wage * (l : ℝ) +
          M10B3.naturalShift e) =
        (M10B3.debtFreePrices e).nextResources
          ⟨x + M10B3.naturalShift e, by linarith⟩ l) ∧
    (∀ (a : ℝ) (l : base.income.Labor)
        (ha : e.debt - M10B3.naturalShift e ≤ a),
      0 ≤ (1 + e.netRate) * a + e.wage * (l : ℝ) - e.netRate * e.debt -
          e.debt + M10B3.naturalShift e ∧
      Real.toNNReal ((1 + e.netRate) * a + e.wage * (l : ℝ) -
          e.netRate * e.debt - e.debt + M10B3.naturalShift e) =
        (M10B3.debtFreePrices e).nextResources
          ⟨a - e.debt + M10B3.naturalShift e, by linarith⟩ l) ∧
    (∀ p : M10B3.TaxedPlan e z0,
      M10B3.toTaxedPlan (M10B3.toDebtFreePlan p) = p ∧
      (∀ t h, p.asset t h = (M10B3.toDebtFreePlan p).asset t h + e.debt) ∧
      (∀ t h, p.consumption t h = (M10B3.toDebtFreePlan p).consumption t h) ∧
      (∀ t h, e.debt - M10B3.naturalShift e ≤ p.asset t h) ∧
      (∀ t h, -M10B3.naturalShift e ≤ (M10B3.toDebtFreePlan p).asset t h) ∧
      (∀ t h, (p.consumption t h : ℝ) + p.asset t h =
        (planResources p.plan t h : ℝ) - M10B3.naturalShift e + e.debt) ∧
      (∀ t h, ((M10B3.toDebtFreePlan p).consumption t h : ℝ) +
        (M10B3.toDebtFreePlan p).asset t h =
          (planResources (M10B3.toDebtFreePlan p).plan t h : ℝ) -
            M10B3.naturalShift e) ∧
      (∀ t, Measurable (p.asset t)) ∧
      (∀ t, Measurable ((M10B3.toDebtFreePlan p).asset t)) ∧
      (∀ t, Measurable (p.consumption t)) ∧
      (∀ t, Measurable ((M10B3.toDebtFreePlan p).consumption t)) ∧
      p.lifetimeUtility = (M10B3.toDebtFreePlan p).lifetimeUtility) ∧
    (∀ p : M10B3.DebtFreePlan e z0,
      M10B3.toDebtFreePlan (M10B3.toTaxedPlan p) = p) ∧
    (∀ p : M10B3.TaxedPlan e z0,
      (∀ q : M10B3.TaxedPlan e z0, q.lifetimeUtility ≤ p.lifetimeUtility) ↔
        ∀ q : M10B3.DebtFreePlan e z0,
          q.lifetimeUtility ≤ (M10B3.toDebtFreePlan p).lifetimeUtility) ∧
    (∀ p : M10B3.TaxedPlan e z0,
      p.lifetimeUtility ≤ (M10B3.canonicalTaxedPlan e z0).lifetimeUtility) ∧
    (∀ p : M10B3.DebtFreePlan e z0,
      p.lifetimeUtility ≤ (M10B3.canonicalDebtFreePlan e z0).lifetimeUtility) ∧
    ((∀ p : M10B3.TaxedPlan e z0,
        Summable (fun t ↦ |base.beta ^ t * expectedFlow p.plan t|)) ∧
      (∀ p : M10B3.DebtFreePlan e z0,
        Summable (fun t ↦ |base.beta ^ t * expectedFlow p.plan t|))) ∧
    ((∀ z, M10B3.taxedAssetPolicy e z =
        M10B3.debtFreeAssetPolicy e z + e.debt) ∧
      M10B3.taxedConsumptionPolicy e = M10B3.debtFreeConsumptionPolicy e) ∧
    (∀ (t : ℕ) (h : History (M10B3.debtFreeHousehold e) (t + 1)),
      ((M10B3.canonicalDebtFreePlan e z0).consumption (t + 1) h : ℝ) +
          (M10B3.canonicalDebtFreePlan e z0).asset (t + 1) h =
        (1 + e.netRate) * (M10B3.canonicalDebtFreePlan e z0).asset t
            (previousHistory (M10B3.debtFreeHousehold e) t h) +
          e.wage * (newestShock (M10B3.debtFreeHousehold e) t h : ℝ)) ∧
    (∀ (t : ℕ) (h : History (M10B3.debtFreeHousehold e) (t + 1)),
      ((M10B3.canonicalTaxedPlan e z0).consumption (t + 1) h : ℝ) +
          (M10B3.canonicalTaxedPlan e z0).asset (t + 1) h =
        (1 + e.netRate) * (M10B3.canonicalTaxedPlan e z0).asset t
            (previousHistory (M10B3.debtFreeHousehold e) t h) +
          e.wage * (newestShock (M10B3.debtFreeHousehold e) t h : ℝ) -
            e.netRate * e.debt) ∧
    (∀ (t : ℕ) (h : History (M10B3.debtFreeHousehold e) (t + 1)),
      (M10B3.canonicalDebtFreePlan e z0).asset (t + 1) h =
        M10B3.debtFreeTransition e
          ((M10B3.canonicalDebtFreePlan e z0).asset t
            (previousHistory (M10B3.debtFreeHousehold e) t h),
          newestShock (M10B3.debtFreeHousehold e) t h)) ∧
    (∀ (t : ℕ) (h : History (M10B3.debtFreeHousehold e) (t + 1)),
      (M10B3.canonicalTaxedPlan e z0).asset (t + 1) h =
        M10B3.taxedTransition e
          ((M10B3.canonicalTaxedPlan e z0).asset t
            (previousHistory (M10B3.debtFreeHousehold e) t h),
          newestShock (M10B3.debtFreeHousehold e) t h)) ∧
    (∀ (x0 : ℝ) (l0 : base.income.Labor) (hx : -M10B3.naturalShift e ≤ x0)
        (hz : (z0 : ℝ) = (1 + e.netRate) * x0 + e.wage * (l0 : ℝ) +
          M10B3.naturalShift e) (h : History (M10B3.debtFreeHousehold e) 0),
      (M10B3.canonicalDebtFreePlan e z0).asset 0 h =
          M10B3.debtFreeTransition e (x0, l0) ∧
        ((M10B3.canonicalDebtFreePlan e z0).consumption 0 h : ℝ) +
            (M10B3.canonicalDebtFreePlan e z0).asset 0 h =
          (1 + e.netRate) * x0 + e.wage * (l0 : ℝ)) ∧
    (∀ (a0 : ℝ) (l0 : base.income.Labor)
        (ha : e.debt - M10B3.naturalShift e ≤ a0)
        (hz : (z0 : ℝ) = (1 + e.netRate) * a0 + e.wage * (l0 : ℝ) -
          e.netRate * e.debt - e.debt + M10B3.naturalShift e)
        (h : History (M10B3.debtFreeHousehold e) 0),
      (M10B3.canonicalTaxedPlan e z0).asset 0 h =
          M10B3.taxedTransition e (a0, l0) ∧
        ((M10B3.canonicalTaxedPlan e z0).consumption 0 h : ℝ) +
            (M10B3.canonicalTaxedPlan e z0).asset 0 h =
          (1 + e.netRate) * a0 + e.wage * (l0 : ℝ) - e.netRate * e.debt) ∧
    (∀ (x : ℝ) (l : base.income.Labor),
      M10B3.taxedTransition e (x + e.debt, l) =
        M10B3.debtFreeTransition e (x, l) + e.debt) ∧
    M10B3.subtractDebtLaw e.debt (M10B3.addDebtLaw e.debt mu) = mu ∧
    M10B3.addDebtLaw e.debt (M10B3.subtractDebtLaw e.debt mu) = mu ∧
    (M10B3.debtFreeLawStep e mu = mu ↔
      M10B3.taxedLawStep e (M10B3.addDebtLaw e.debt mu) =
        M10B3.addDebtLaw e.debt mu) ∧
    (M10B3.taxedLawStep e (M10B3.addDebtLaw e.debt mu) =
        M10B3.addDebtLaw e.debt mu ↔
      M10B3.debtFreeLawStep e
          (M10B3.subtractDebtLaw e.debt (M10B3.addDebtLaw e.debt mu)) =
        M10B3.subtractDebtLaw e.debt (M10B3.addDebtLaw e.debt mu)) ∧
    (M10B3.debtFreeLawStep e mu = mu →
      ∀ᵐ x ∂mu, -M10B3.naturalShift e ≤ x) ∧
    (M10B3.taxedLawStep e (M10B3.addDebtLaw e.debt mu) =
        M10B3.addDebtLaw e.debt mu →
      ∀ᵐ a ∂M10B3.addDebtLaw e.debt mu,
        e.debt - M10B3.naturalShift e ≤ a) ∧
    Integrable (fun a : ℝ ↦ a) (M10B3.addDebtLaw e.debt mu) ∧
    ((∫ a, a ∂M10B3.addDebtLaw e.debt mu) = e.debt ↔
      (∫ x, x ∂mu) = 0) := by
  letI : SFinite (M10B3.addDebtLaw e.debt mu) := by
    unfold M10B3.addDebtLaw
    infer_instance
  refine ⟨fun c a aNext l ↦ M10B3.taxed_budget_iff_debtFree
      e.netRate e.wage e.debt a aNext c l,
    fun a ↦ M10B3.taxed_floor_iff_debtFree
      e.netRate e.wage e.debt base.income.lower a,
    fun c x xNext l ↦ M10B3.debtFree_shifted_budget_iff e x xNext c l,
    fun x l hx ↦ ⟨M10B3.debtFreeTransition_input_nonneg e x l hx,
      M10B3.debtFreeTransition_input_eq_nextResources e x l hx⟩,
    fun a l ha ↦ ⟨M10B3.taxedTransition_input_nonneg e a l ha,
      M10B3.taxedTransition_input_eq_nextResources e a l ha⟩, ?_⟩
  refine ⟨fun p ↦ ⟨M10B3.toTaxedPlan_toDebtFreePlan p,
      M10B3.plan_asset_translation p, M10B3.plan_consumption_preserved p,
      M10B3.taxedPlan_admissible p, M10B3.debtFreePlan_admissible (M10B3.toDebtFreePlan p),
      M10B3.taxedPlan_budget p, M10B3.debtFreePlan_budget (M10B3.toDebtFreePlan p),
      (M10B3.plan_full_history_nonanticipative p).1,
      (M10B3.plan_full_history_nonanticipative p).2,
      (M10B3.plan_consumption_measurable p).1,
      (M10B3.plan_consumption_measurable p).2,
      M10B3.plan_lifetimeUtility_preserved p⟩,
    M10B3.toDebtFreePlan_toTaxedPlan,
    M10B3.lifetimeOptimality_transport,
    M10B3.taxed_lifetime_optimal e z0,
    M10B3.debtFree_lifetime_optimal e z0, ?_⟩
  refine ⟨⟨(M10B3.lifetimeUtility_absolutely_summable e z0).2,
      (M10B3.lifetimeUtility_absolutely_summable e z0).1⟩,
    M10B3.canonical_policy_translation e,
    fun t h ↦ (M10B3.debtFreePlan_original_budget_step
      (M10B3.canonicalDebtFreePlan e z0) t h).1,
    fun t h ↦ (M10B3.taxedPlan_original_budget_step
      (M10B3.canonicalTaxedPlan e z0) t h).1,
    M10B3.canonicalDebtFreePlan_asset_transition_step e z0,
    M10B3.canonicalTaxedPlan_asset_transition_step e z0,
    fun x0 l0 hx hz h ↦ ⟨M10B3.canonicalDebtFreePlan_asset_transition_initial
      e z0 x0 l0 hx hz h,
      (M10B3.debtFreePlan_original_budget_initial
        (M10B3.canonicalDebtFreePlan e z0) x0 l0 (by nlinarith [hz]) h).1⟩,
    fun a0 l0 ha hz h ↦ ⟨M10B3.canonicalTaxedPlan_asset_transition_initial
      e z0 a0 l0 ha hz h,
      (M10B3.taxedPlan_original_budget_initial
        (M10B3.canonicalTaxedPlan e z0) a0 l0 (by nlinarith [hz]) h).1⟩,
    M10B3.canonical_transition_conjugate e,
    M10B3.subtractDebtLaw_addDebtLaw e.debt mu,
    M10B3.addDebtLaw_subtractDebtLaw e.debt mu,
    M10B3.invariantLaw_correspondence e mu,
    M10B3.invariantLaw_correspondence_inverse e (M10B3.addDebtLaw e.debt mu),
    M10B3.debtFreeInvariant_supported e mu,
    M10B3.taxedInvariant_supported e (M10B3.addDebtLaw e.debt mu), ?_⟩
  exact M10B3.bondClearing_iff_zeroNetAssets e.debt mu hint

end
end Aiyagari1994
