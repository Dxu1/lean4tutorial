import Aiyagari1994.Analysis.M05B.LowerTransition

/-! S02: strict lower-shock drift and convergence of its iterates. -/
open MeasureTheory Set Filter Function
open scoped NNReal Topology ENNReal
namespace Aiyagari1994
noncomputable section

private theorem lowerTransition_lt_of_assetPolicy_pos
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (z : Resources) (hzpos : 0 < z) (ha : 0 < assetPolicy m z) :
    lowerTransition m z < z := by
  by_contra hnot
  have hzle : z ≤ lowerTransition m z := le_of_not_gt hnot
  obtain ⟨hint, _, heuler⟩ :=
    (euler_subcritical m hsmooth hbetaR z hzpos).2.2.2 ha
  have hc : 0 < consumptionPolicy m z :=
    consumption_positive_subcritical m hsmooth hbetaR z hzpos
  have henv := (value_envelope_at_positive_consumption m hsmooth z hzpos hc).2
  have hpoint : ∀ l : m.income.Labor,
      deriv m.utility.utility
          (consumptionPolicy m
            (m.prices.nextResources (assetPolicy m z) l) : ℝ) ≤
        deriv m.utility.utility (consumptionPolicy m z : ℝ) := by
    intro l
    have hmin : lowerTransition m z ≤
        m.prices.nextResources (assetPolicy m z) l := by
      apply Subtype.coe_le_coe.mp
      change m.prices.grossReturn * (assetPolicy m z : ℝ) +
          m.prices.effectiveIncome
            ⟨m.income.lower, le_rfl, m.income_support.ordered⟩ ≤
        m.prices.grossReturn * (assetPolicy m z : ℝ) +
          m.prices.effectiveIncome l
      have hinc : m.prices.effectiveIncome
          ⟨m.income.lower, le_rfl, m.income_support.ordered⟩ ≤
          m.prices.effectiveIncome l := by
        unfold NormalizedPrices.effectiveIncome
        simpa [add_comm] using add_le_add_right
          (mul_le_mul_of_nonneg_left l.property.1 m.prices.wage_pos.le)
          m.prices.intercept
      simpa [add_comm] using add_le_add_left hinc
        (m.prices.grossReturn * (assetPolicy m z : ℝ))
    have hznext : z ≤ m.prices.nextResources (assetPolicy m z) l := hzle.trans hmin
    have hnpos : 0 < m.prices.nextResources (assetPolicy m z) l := hzpos.trans_le hznext
    have hcn : 0 < consumptionPolicy m
        (m.prices.nextResources (assetPolicy m z) l) :=
      consumption_positive_subcritical m hsmooth hbetaR _ hnpos
    have henvn := (value_envelope_at_positive_consumption m hsmooth _ hnpos hcn).2
    rw [← henv, ← henvn]
    exact rightMarginalValue_antitone m
      (by exact_mod_cast hzpos) (by exact_mod_cast hnpos) (by exact_mod_cast hznext)
  have hint_le : (∫ l : m.income.Labor,
      deriv m.utility.utility
        (consumptionPolicy m
          (m.prices.nextResources (assetPolicy m z) l) : ℝ)
      ∂(m.income.law : Measure m.income.Labor)) ≤
      deriv m.utility.utility (consumptionPolicy m z : ℝ) := by
    calc
      _ ≤ ∫ _l : m.income.Labor,
          deriv m.utility.utility (consumptionPolicy m z : ℝ)
          ∂(m.income.law : Measure m.income.Labor) :=
        integral_mono hint (integrable_const _) hpoint
      _ = _ := by simp
  have hqpos : 0 < deriv m.utility.utility (consumptionPolicy m z : ℝ) :=
    hsmooth.marginal_pos _ (by exact_mod_cast hc)
  have hbetaRpos : 0 < m.beta * m.prices.grossReturn :=
    mul_pos m.beta_pos m.prices.grossReturn_pos
  have hmul : m.beta * m.prices.grossReturn *
      (∫ l : m.income.Labor,
        deriv m.utility.utility
          (consumptionPolicy m
            (m.prices.nextResources (assetPolicy m z) l) : ℝ)
        ∂(m.income.law : Measure m.income.Labor)) ≤
      m.beta * m.prices.grossReturn *
        deriv m.utility.utility (consumptionPolicy m z : ℝ) :=
    mul_le_mul_of_nonneg_left hint_le hbetaRpos.le
  rw [heuler] at hmul
  have hstrict : m.beta * m.prices.grossReturn *
      deriv m.utility.utility (consumptionPolicy m z : ℝ) <
      deriv m.utility.utility (consumptionPolicy m z : ℝ) := by
    nlinarith
  exact (not_lt_of_ge hmul) hstrict

private theorem lowerTransition_lt_of_lt
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (z : Resources) (hz : lowerEffectiveIncome m < z) :
    lowerTransition m z < z := by
  have hzpos : 0 < z := lt_of_le_of_lt (lowerEffectiveIncome m).property hz
  by_cases ha0 : assetPolicy m z = 0
  · have heq : lowerTransition m z = lowerEffectiveIncome m := by
      apply NNReal.eq
      simp [lowerTransition, lowerEffectiveIncome, ha0,
        NormalizedPrices.nextResources]
    rw [heq]
    exact hz
  · have ha : 0 < assetPolicy m z := pos_iff_ne_zero.mpr ha0
    exact lowerTransition_lt_of_assetPolicy_pos m hsmooth hbetaR z hzpos ha

/-- S02: the least-shock transition fixes least effective income, lies strictly below every
larger state, and its iterates from every finite upper state converge monotonically to the
least effective income. -/
theorem M05B_lower_transition_iterates_tendsto
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
    lowerTransition m (lowerEffectiveIncome m) = lowerEffectiveIncome m ∧
    (∀ z : Resources, lowerEffectiveIncome m < z → lowerTransition m z < z) ∧
    ∀ B : Resources, lowerEffectiveIncome m ≤ B →
      Antitone (fun n : ℕ ↦ (lowerTransition m)^[n] B) ∧
      Tendsto (fun n : ℕ ↦ (lowerTransition m)^[n] B) atTop
        (nhds (lowerEffectiveIncome m)) := by
  have hlt := lowerTransition_lt_of_lt m hsmooth hbetaR
  have hfix : lowerTransition m (lowerEffectiveIncome m) = lowerEffectiveIncome m := by
    apply le_antisymm
    · by_contra hnot
      have hgt : lowerEffectiveIncome m < lowerTransition m (lowerEffectiveIncome m) :=
        lt_of_not_ge hnot
      have ha : 0 < assetPolicy m (lowerEffectiveIncome m) := by
        by_contra hanz
        have ha0 : assetPolicy m (lowerEffectiveIncome m) = 0 :=
          nonpos_iff_eq_zero.mp (le_of_not_gt hanz)
        have : lowerTransition m (lowerEffectiveIncome m) = lowerEffectiveIncome m := by
          apply NNReal.eq
          change m.prices.grossReturn *
              (assetPolicy m (lowerEffectiveIncome m) : ℝ) +
              m.prices.effectiveIncome _ = m.prices.effectiveIncome _
          rw [ha0]
          simp
        exact hgt.ne this.symm
      have hepos : 0 < lowerEffectiveIncome m := by
        by_contra he0
        have heq : lowerEffectiveIncome m = 0 :=
          nonpos_iff_eq_zero.mp (le_of_not_gt he0)
        rw [heq, assetPolicy_zero] at ha
        exact (lt_irrefl 0) ha
      have hbelow := lowerTransition_lt_of_assetPolicy_pos m hsmooth hbetaR
        (lowerEffectiveIncome m) hepos ha
      exact (not_lt_of_ge (lowerEffectiveIncome_le_lowerTransition m _)) hbelow
    · exact lowerEffectiveIncome_le_lowerTransition m _
  refine ⟨hfix, hlt, ?_⟩
  intro B hB
  have hmap : lowerTransition m B ≤ B := by
    rcases hB.eq_or_lt with rfl | hBlt
    · exact hfix.le
    · exact (hlt B hBlt).le
  have hLower : ∀ n : ℕ, lowerEffectiveIncome m ≤ (lowerTransition m)^[n] B := by
    intro n
    induction n with
    | zero => simpa using hB
    | succ n ih =>
        rw [Function.iterate_succ_apply']
        exact lowerEffectiveIncome_le_lowerTransition m _
  have hstep : ∀ n : ℕ,
      (lowerTransition m)^[n + 1] B ≤ (lowerTransition m)^[n] B := by
    intro n
    rw [Function.iterate_succ_apply']
    rcases (hLower n).eq_or_lt with heq | hgt
    · rw [← heq, hfix]
    · exact (hlt _ hgt).le
  have hanti : Antitone (fun n : ℕ ↦ (lowerTransition m)^[n] B) :=
    antitone_nat_of_succ_le hstep
  let xr : ℕ → ℝ := fun n ↦ ((lowerTransition m)^[n] B : Resources)
  have hxanti : Antitone xr := fun i j hij ↦ by exact_mod_cast hanti hij
  have hxbdd : BddBelow (Set.range xr) := ⟨(lowerEffectiveIncome m : ℝ), by
    rintro _ ⟨n, rfl⟩
    exact_mod_cast hLower n⟩
  let L : ℝ := sInf (Set.range xr)
  have hxlim : Tendsto xr atTop (nhds L) := tendsto_atTop_ciInf hxanti hxbdd
  have hLnonneg : 0 ≤ L := by
    exact ge_of_tendsto hxlim (Eventually.of_forall fun n ↦ NNReal.coe_nonneg _)
  let Lr : Resources := ⟨L, hLnonneg⟩
  have hLrlim : Tendsto (fun n : ℕ ↦ (lowerTransition m)^[n] B) atTop (nhds Lr) := by
    exact tendsto_subtype_rng.2 hxlim
  have hLfix : lowerTransition m Lr = Lr :=
    isFixedPt_of_tendsto_iterate hLrlim (lowerTransition_continuous m).continuousAt
  have heL : lowerEffectiveIncome m ≤ Lr := by
    apply ge_of_tendsto hLrlim
    exact Eventually.of_forall hLower
  have hLeq : Lr = lowerEffectiveIncome m := by
    apply le_antisymm
    · by_contra hnle
      have helt : lowerEffectiveIncome m < Lr := lt_of_not_ge hnle
      have := hlt Lr helt
      rw [hLfix] at this
      exact (lt_irrefl Lr) this
    · exact heL
  rw [hLeq] at hLrlim
  exact ⟨hanti, hLrlim⟩

end
end Aiyagari1994
