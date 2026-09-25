import Aiyagari1994.Household.Euler
import Aiyagari1994.Household.PolicyOrder
import Aiyagari1994.Household.ParameterContinuity
import Aiyagari1994.Analysis.Curvature

/-! Analytic infrastructure for D03's locally uniform upper-drift bound. -/
open MeasureTheory Set Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

def M04CLowerLabor (m : HouseholdPrimitives) : m.income.Labor :=
  ⟨m.income.lower, le_rfl, m.income_support.ordered⟩

def M04CUpperLabor (m : HouseholdPrimitives) : m.income.Labor :=
  ⟨m.income.upper, m.income_support.ordered, le_rfl⟩

def M04CIncomeLower (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) : ℝ :=
  q.wage * m.income.lower + q.intercept

def M04CIncomeUpper (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) : ℝ :=
  q.wage * m.income.upper + q.intercept

theorem M04CIncome_between (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (l : m.income.Labor) :
    M04CIncomeLower m q ≤ q.toPrices.effectiveIncome l ∧
      q.toPrices.effectiveIncome l ≤ M04CIncomeUpper m q := by
  constructor <;>
    simp only [M04CIncomeLower, M04CIncomeUpper,
      NormalizedPrices.effectiveIncome, AdmissibleNormalizedPrices.toPrices,
      AdmissibleNormalizedPrices.wage, AdmissibleNormalizedPrices.intercept] <;>
    nlinarith [q.property.1.2, l.property.1, l.property.2]

theorem M04C_exists_consumption_buffer (gamma Delta C₀ : ℝ) (n : ℕ)
    (hgamma : gamma < 1) (_hDelta : 0 ≤ Delta) :
    ∃ C : ℝ, C₀ ≤ C ∧ 0 < C ∧ gamma * (1 + Delta / C) ^ n < 1 := by
  have ht0 : Tendsto (fun C : ℝ => Delta / C) atTop (nhds 0) := by
    simpa only [div_eq_mul_inv, mul_zero] using
      ((tendsto_const_nhds : Tendsto (fun _ : ℝ => Delta) atTop (nhds Delta)).mul
        tendsto_inv_atTop_zero)
  have ht : Tendsto (fun C : ℝ => gamma * (1 + Delta / C) ^ n)
      atTop (nhds gamma) := by
    have hg : Tendsto (fun _ : ℝ => gamma) atTop (nhds gamma) := tendsto_const_nhds
    have h1 : Tendsto (fun _ : ℝ => (1 : ℝ)) atTop (nhds 1) := tendsto_const_nhds
    simpa using (hg.mul ((h1.add ht0).pow n))
  have hev : ∀ᶠ C : ℝ in atTop, gamma * (1 + Delta / C) ^ n < 1 :=
    ht.eventually (Iio_mem_nhds hgamma)
  have hall : ∀ᶠ C : ℝ in atTop,
      gamma * (1 + Delta / C) ^ n < 1 ∧ C₀ ≤ C ∧ 0 < C := by
    filter_upwards [hev, eventually_ge_atTop C₀,
      eventually_gt_atTop (0 : ℝ)] with C hC hC₀ hCpos
    exact ⟨hC, hC₀, hCpos⟩
  obtain ⟨C, hC, hC₀, hCpos⟩ := hall.exists
  exact ⟨C, hC₀, hCpos, hC⟩

theorem M04C_consumption_gt_of_state_gt (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (hs : UtilitySmooth m.utility)
    (hbetaR : m.beta * q.grossReturn < 1) {C L : ℝ}
    (hC : 0 < C)
    (hL : utilityOscillation m / (1 - m.beta) /
      deriv m.utility.utility C < L)
    (x : Resources) (hx : L < (x : ℝ)) :
    C < (consumptionPolicy (m.withPrices q) x : ℝ) := by
  let mq := m.withPrices q
  have hxpos : 0 < x := by
    have hosc : 0 ≤ utilityOscillation m := by
      have hb := utility_bounds m (0 : Resources)
      unfold utilityOscillation
      linarith
    have huC : 0 < deriv m.utility.utility C := hs.marginal_pos C hC
    have hD : 0 ≤ utilityOscillation m / (1 - m.beta) :=
      div_nonneg hosc (sub_nonneg.mpr m.beta_lt_one.le)
    have hLnonneg : 0 ≤ L := le_trans (div_nonneg hD huC.le) hL.le
    exact_mod_cast hLnonneg.trans_lt hx
  have hbetaRq : mq.beta * mq.prices.grossReturn < 1 := hbetaR
  have hcpos := consumption_positive_subcritical mq hs hbetaRq x hxpos
  have henv := (value_envelope_at_positive_consumption mq hs x hxpos hcpos).2
  have huC : 0 < deriv m.utility.utility C := hs.marginal_pos C hC
  have hD : 0 ≤ utilityOscillation m / (1 - m.beta) := by
    have hb := utility_bounds m (0 : Resources)
    have hosc : 0 ≤ utilityOscillation m := by
      unfold utilityOscillation
      linarith
    exact div_nonneg hosc (sub_nonneg.mpr m.beta_lt_one.le)
  have hxreal : 0 < (x : ℝ) := by exact_mod_cast hxpos
  have hsmall : utilityOscillation m / (1 - m.beta) / (x : ℝ) <
      deriv m.utility.utility C := by
    apply (div_lt_iff₀ hxreal).2
    have hratio := hL.trans hx
    apply (div_lt_iff₀ huC).1 at hratio
    nlinarith
  have hqbound : rightMarginalValue mq (x : ℝ) ≤
      utilityOscillation m / (1 - m.beta) / (x : ℝ) := by
    have hb := (rightMarginalValue_bounds mq hxreal).1.trans
      (rightMarginalValue_bounds mq hxreal).2
    change rightMarginalValue mq (x : ℝ) ≤
      utilityOscillation m / ((1 - m.beta) * (x : ℝ)) at hb
    simpa only [div_div] using hb
  by_contra hnot
  have hcC : (consumptionPolicy mq x : ℝ) ≤ C := le_of_not_gt hnot
  have hanti : AntitoneOn (deriv m.utility.utility) (Ioi 0) := by
    intro x hx' y hy' hxy
    rcases eq_or_lt_of_le hxy with rfl | hxy'
    · rfl
    · have hdx := (hs.smooth.differentiableOn_one x hx').differentiableAt
          (isOpen_Ioi.mem_nhds hx')
      have hdy := (hs.smooth.differentiableOn_one y hy').differentiableAt
          (isOpen_Ioi.mem_nhds hy')
      exact (m.utility_base.concave.concaveOn.deriv_le_slope
        (x := x) (y := y) (show (0 : ℝ) ≤ x from le_of_lt hx')
        (show (0 : ℝ) ≤ y from le_of_lt hy') hxy' hdy).trans
        (m.utility_base.concave.concaveOn.slope_le_deriv
          (x := x) (y := y) (show (0 : ℝ) ≤ x from le_of_lt hx')
          (show (0 : ℝ) ≤ y from le_of_lt hy') hxy' hdx)
  have hderiv : deriv m.utility.utility C ≤
      deriv m.utility.utility (consumptionPolicy mq x : ℝ) :=
    hanti hcpos hC hcC
  change ¬ C < (consumptionPolicy mq x : ℝ) at hnot
  change rightMarginalValue mq (x : ℝ) =
    deriv m.utility.utility (consumptionPolicy mq x : ℝ) at henv
  rw [← henv] at hderiv
  exact (not_lt_of_ge hqbound) (hsmall.trans_le hderiv)

theorem M04C_upper_drift_at_price (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income)
    (hs : UtilitySmooth m.utility) (n : ℕ) (C₀ C L K B gamma Delta : ℝ)
    (hratio : ∀ ⦃c₁ c₂ : ℝ⦄, C₀ ≤ c₁ → c₁ ≤ c₂ →
      deriv m.utility.utility c₁ / deriv m.utility.utility c₂ ≤ (c₂ / c₁) ^ n)
    (hC₀C : C₀ ≤ C) (hC : 0 < C)
    (hgamma : gamma < 1) (hDelta : 0 ≤ Delta)
    (hfactor : gamma * (1 + Delta / C) ^ n < 1)
    (hL : utilityOscillation m / (1 - m.beta) /
      deriv m.utility.utility C < L)
    (hRmin : 0 < q.grossReturn)
    (hbetaR : m.beta * q.grossReturn ≤ gamma)
    (hKpos : 0 < K) (hRK : L < q.grossReturn * K)
    (hKB : q.grossReturn * K + M04CIncomeUpper m q ≤ B)
    (hBpos : 0 < B)
    (hspan : M04CIncomeUpper m q - M04CIncomeLower m q ≤ Delta) :
    ∀ z : Resources, B ≤ (z : ℝ) →
      q.grossReturn * (assetPolicy (m.withPrices q) z : ℝ) +
        M04CIncomeUpper m q ≤ (z : ℝ) := by
  let mq := m.withPrices q
  have hsub : m.beta * q.grossReturn < 1 := hbetaR.trans_lt hgamma
  intro z hzB
  by_cases haK : (assetPolicy mq z : ℝ) ≤ K
  · have hmul := mul_le_mul_of_nonneg_left haK q.property.1.1.le
    change q.grossReturn * (assetPolicy mq z : ℝ) ≤ q.grossReturn * K at hmul
    linarith
  · have haK' : K < (assetPolicy mq z : ℝ) := lt_of_not_ge haK
    have ha : 0 < assetPolicy mq z := by
      exact_mod_cast hKpos.trans haK'
    have hzpos : 0 < z := by exact_mod_cast hBpos.trans_le hzB
    let lmax : m.income.Labor := M04CUpperLabor m
    let ymax : Resources := q.toPrices.nextResources (assetPolicy mq z) lmax
    have hymaxL : L < (ymax : ℝ) := by
      change L < q.grossReturn * (assetPolicy mq z : ℝ) + M04CIncomeUpper m q
      have he : 0 ≤ M04CIncomeUpper m q := by
        have he' := q.property.2 lmax
        change 0 ≤ M04CIncomeUpper m q at he'
        exact he'
      have hmul := mul_lt_mul_of_pos_left haK' hRmin
      linarith
    have hcymax : C < (consumptionPolicy mq ymax : ℝ) :=
      M04C_consumption_gt_of_state_gt m q hs hsub hC hL ymax hymaxL
    have heuler := (euler_subcritical mq hs hsub z hzpos).2.2.2 ha
    obtain ⟨hint, _hmarg, heq⟩ := heuler
    change Integrable (fun l : m.income.Labor =>
      deriv m.utility.utility
        (consumptionPolicy mq (q.toPrices.nextResources (assetPolicy mq z) l) : ℝ))
      (m.income.law : Measure m.income.Labor) at hint
    change m.beta * q.grossReturn * ∫ l : m.income.Labor,
        deriv m.utility.utility
          (consumptionPolicy mq (q.toPrices.nextResources (assetPolicy mq z) l) : ℝ)
        ∂(m.income.law : Measure m.income.Labor) =
      deriv m.utility.utility (consumptionPolicy mq z : ℝ) at heq
    have hpoint (l : m.income.Labor) :
        deriv m.utility.utility
            (consumptionPolicy mq (q.toPrices.nextResources (assetPolicy mq z) l) : ℝ) ≤
          (1 + Delta / C) ^ n *
            deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) := by
      let yl : Resources := q.toPrices.nextResources (assetPolicy mq z) l
      have hylL : L < (yl : ℝ) := by
        change L < q.grossReturn * (assetPolicy mq z : ℝ) + q.toPrices.effectiveIncome l
        have hmul := mul_lt_mul_of_pos_left haK' hRmin
        change q.grossReturn * K < q.grossReturn * (assetPolicy mq z : ℝ) at hmul
        exact (hRK.trans hmul).trans_le (le_add_of_nonneg_right (q.property.2 l))
      have hcyl : C < (consumptionPolicy mq yl : ℝ) :=
        M04C_consumption_gt_of_state_gt m q hs hsub hC hL yl hylL
      have hyy : yl ≤ ymax := by
        change q.grossReturn * (assetPolicy mq z : ℝ) + q.toPrices.effectiveIncome l ≤
          q.grossReturn * (assetPolicy mq z : ℝ) + M04CIncomeUpper m q
        simpa [add_comm] using
          add_le_add_left (M04CIncome_between m q l).2
            (q.grossReturn * (assetPolicy mq z : ℝ))
      have hcc := ((policies_order_lipschitz mq).2.2 yl ymax hyy).2
      have hcdiff : (consumptionPolicy mq ymax : ℝ) -
          (consumptionPolicy mq yl : ℝ) ≤ Delta := by
        have hyDiff : (ymax : ℝ) - (yl : ℝ) =
            M04CIncomeUpper m q - q.toPrices.effectiveIncome l := by
          change (q.grossReturn * (assetPolicy mq z : ℝ) + M04CIncomeUpper m q) -
              (q.grossReturn * (assetPolicy mq z : ℝ) + q.toPrices.effectiveIncome l) = _
          ring
        rw [hyDiff] at hcc
        exact hcc.2.trans (by
          nlinarith [(M04CIncome_between m q l).1, hspan])
      have hratioC : (consumptionPolicy mq ymax : ℝ) /
          (consumptionPolicy mq yl : ℝ) ≤ 1 + Delta / C := by
        apply (div_le_iff₀ (by linarith [hcyl])).2
        have hcRatio : 1 ≤ (consumptionPolicy mq yl : ℝ) / C :=
          (le_div_iff₀ hC).2 (by simpa using hcyl.le)
        have hDeltaC : Delta ≤ Delta / C * (consumptionPolicy mq yl : ℝ) := by
          calc
            Delta = Delta * 1 := by ring
            _ ≤ Delta * ((consumptionPolicy mq yl : ℝ) / C) :=
              mul_le_mul_of_nonneg_left hcRatio hDelta
            _ = Delta / C * (consumptionPolicy mq yl : ℝ) := by ring
        nlinarith
      have hcmono : (consumptionPolicy mq yl : ℝ) ≤
          (consumptionPolicy mq ymax : ℝ) := by linarith [hcc.1]
      have hraw := hratio (hC₀C.trans hcyl.le) hcmono
      have hp := pow_le_pow_left₀ (div_nonneg (by positivity) (by positivity)) hratioC n
      have huMax : 0 < deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) :=
        hs.marginal_pos _ (hC.trans hcymax)
      apply (div_le_iff₀ huMax).1 at hraw
      exact hraw.trans (mul_le_mul_of_nonneg_right hp huMax.le)
    have hintBound : ∫ l : m.income.Labor,
          deriv m.utility.utility
            (consumptionPolicy mq (q.toPrices.nextResources (assetPolicy mq z) l) : ℝ)
          ∂(m.income.law : Measure m.income.Labor) ≤
        (1 + Delta / C) ^ n *
          deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) := by
      have hcint : Integrable (fun _ : m.income.Labor =>
          (1 + Delta / C) ^ n *
            deriv m.utility.utility (consumptionPolicy mq ymax : ℝ))
          (m.income.law : Measure m.income.Labor) := integrable_const _
      have hi := integral_mono hint hcint hpoint
      simpa using hi
    have huMax : 0 < deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) :=
      hs.marginal_pos _ (hC.trans hcymax)
    have hcurrent : deriv m.utility.utility (consumptionPolicy mq z : ℝ) <
        deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) := by
      rw [← heq]
      have hmul := mul_le_mul_of_nonneg_left hintBound
        (mul_nonneg m.beta_pos.le q.property.1.1.le)
      calc
        m.beta * q.grossReturn * ∫ l : m.income.Labor,
              deriv m.utility.utility
                (consumptionPolicy mq
                  (q.toPrices.nextResources (assetPolicy mq z) l) : ℝ)
              ∂(m.income.law : Measure m.income.Labor)
            ≤ m.beta * q.grossReturn *
                ((1 + Delta / C) ^ n *
                  deriv m.utility.utility (consumptionPolicy mq ymax : ℝ)) := hmul
        _ = (m.beta * q.grossReturn * (1 + Delta / C) ^ n) *
              deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) := by ring
        _ ≤ (gamma * (1 + Delta / C) ^ n) *
              deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) := by
            gcongr
        _ < 1 * deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) :=
            mul_lt_mul_of_pos_right hfactor huMax
        _ = deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) := one_mul _
    have henvz := (value_envelope_at_positive_consumption mq hs z hzpos
      (consumption_positive_subcritical mq hs hsub z hzpos)).2
    have hymaxpos : 0 < ymax :=
      (lt_of_lt_of_le (by exact_mod_cast hC.trans hcymax)
        (show consumptionPolicy mq ymax ≤ ymax by
          exact tsub_le_self))
    have henvy := (value_envelope_at_positive_consumption mq hs ymax hymaxpos
      (consumption_positive_subcritical mq hs hsub ymax hymaxpos)).2
    have hstate : (ymax : ℝ) < (z : ℝ) := by
      by_contra hnot
      have hmono := rightMarginalValue_antitone mq hzpos hymaxpos (le_of_not_gt hnot)
      change rightMarginalValue mq (ymax : ℝ) ≤ rightMarginalValue mq (z : ℝ) at hmono
      change rightMarginalValue mq (z : ℝ) =
        deriv m.utility.utility (consumptionPolicy mq z : ℝ) at henvz
      change rightMarginalValue mq (ymax : ℝ) =
        deriv m.utility.utility (consumptionPolicy mq ymax : ℝ) at henvy
      rw [henvy, henvz] at hmono
      exact (not_lt_of_ge hmono) hcurrent
    exact hstate.le

end
end Aiyagari1994
