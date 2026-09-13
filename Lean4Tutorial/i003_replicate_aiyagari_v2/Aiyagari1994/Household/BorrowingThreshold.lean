import Aiyagari1994.Household.Euler

/-! H13: a nontrivial interval on which the borrowing constraint binds. -/
open MeasureTheory Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- The minimum effective income, represented in the nonnegative resource state space. -/
def minimumEffectiveIncome (m : HouseholdPrimitives) : Resources :=
  ⟨m.prices.effectiveIncome
      ⟨m.income.lower, le_rfl, m.income_support.ordered⟩,
    m.prices.income_nonneg ⟨m.income.lower, le_rfl, m.income_support.ordered⟩⟩

private theorem minimumEffectiveIncome_coe (m : HouseholdPrimitives) :
    (minimumEffectiveIncome m : ℝ) =
      m.prices.wage * m.income.lower + m.prices.intercept := rfl

private theorem minimumEffectiveIncome_le_effectiveIncome
    (m : HouseholdPrimitives) (l : m.income.Labor) :
    (minimumEffectiveIncome m : ℝ) ≤ m.prices.effectiveIncome l := by
  rw [minimumEffectiveIncome_coe]
  unfold NormalizedPrices.effectiveIncome
  simpa only [add_comm] using add_le_add_right
    (mul_le_mul_of_nonneg_left l.property.1 m.prices.wage_pos.le)
      m.prices.intercept

private theorem minimumEffectiveIncome_le_nextResources
    (m : HouseholdPrimitives) (a : Resources) (l : m.income.Labor) :
    minimumEffectiveIncome m ≤ m.prices.nextResources a l := by
  change (minimumEffectiveIncome m : ℝ) ≤
    m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l
  exact (minimumEffectiveIncome_le_effectiveIncome m l).trans
    (le_add_of_nonneg_left (mul_nonneg m.prices.grossReturn_pos.le a.property))

private theorem zeroRightMarginal_lt_top_of_utility
    (m : HouseholdPrimitives)
    (hfinite : utilityZeroRightMarginal m < ⊤)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
    zeroRightMarginal m < ⊤ := by
  let L := (utilityZeroRightMarginal m).toReal
  have hweak : m.beta * m.prices.grossReturn ≤ 1 := hbetaR.le
  have hbound : zeroRightMarginal m ≤ ENNReal.ofReal L := by
    unfold zeroRightMarginal
    apply sSup_le
    rintro _ ⟨y, hy, rfl⟩
    apply ENNReal.ofReal_le_ofReal
    let yr : Resources := ⟨y, (show 0 ≤ y from (show 0 < y from hy).le)⟩
    have hinc := valueFunction_increment_le_zeroMarginal m hfinite hweak
      (show (0 : Resources) ≤ yr from bot_le)
    have he0 : valueExtension m 0 = valueFunction m 0 := by
      simp [valueExtension, nonnegativeExtension]
    have hey : valueExtension m y = valueFunction m yr := by
      change valueFunction m y.toNNReal = valueFunction m yr
      congr 1
      apply NNReal.eq
      rw [Real.coe_toNNReal _]
      · rfl
      · exact (show 0 ≤ y from (show 0 < y from hy).le)
    rw [slope_def_field, sub_zero, he0, hey]
    apply (div_le_iff₀ (show 0 < y from hy)).2
    change valueFunction m yr - valueFunction m 0 ≤ L * y
    change valueFunction m yr - valueFunction m 0 ≤ L * (y - 0) at hinc
    simpa only [sub_zero] using hinc
  exact hbound.trans_lt ENNReal.ofReal_lt_top

private theorem thresholdMarginal_finite
    (m : HouseholdPrimitives)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (hthreshold : 0 < minimumEffectiveIncome m ∨
      utilityZeroRightMarginal m < ⊤) :
    extendedRightMarginalValue m (minimumEffectiveIncome m) < ⊤ := by
  rcases hthreshold with hePos | huFinite
  · rw [extendedRightMarginalValue_of_pos m hePos]
    exact ENNReal.ofReal_lt_top
  · by_cases he : minimumEffectiveIncome m = 0
    · rw [he, extendedRightMarginalValue_zero]
      exact zeroRightMarginal_lt_top_of_utility m huFinite hbetaR
    · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr he)]
      exact ENNReal.ofReal_lt_top

private theorem thresholdMarginal_pos (m : HouseholdPrimitives) :
    0 < extendedRightMarginalValue m (minimumEffectiveIncome m) := by
  by_cases he : minimumEffectiveIncome m = 0
  · rw [he, extendedRightMarginalValue_zero]
    exact zeroRightMarginal_pos m
  · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr he)]
    exact ENNReal.ofReal_pos.mpr
      (rightMarginalValue_pos m (by exact_mod_cast (pos_iff_ne_zero.mpr he)))

private theorem interior_marginal_upper_bound
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (hminFinite : extendedRightMarginalValue m (minimumEffectiveIncome m) < ⊤)
    {z : Resources} (hz : 0 < z) (ha : 0 < assetPolicy m z) :
    rightMarginalValue m (z : ℝ) ≤
      m.beta * m.prices.grossReturn *
        (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal := by
  obtain ⟨_, _, _, hinterior⟩ := euler_subcritical m hsmooth hbetaR z hz
  obtain ⟨hint, _, heq⟩ := hinterior ha
  have hc := consumption_positive_subcritical m hsmooth hbetaR z hz
  have henv := (value_envelope_at_positive_consumption m hsmooth z hz hc).2
  have hle : ∀ l : m.income.Labor,
      deriv m.utility.utility
          (consumptionPolicy m
            (m.prices.nextResources (assetPolicy m z) l) : ℝ) ≤
        (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal := by
    intro l
    have hn : 0 < m.prices.nextResources (assetPolicy m z) l := by
      change 0 < m.prices.grossReturn * (assetPolicy m z : ℝ) +
        m.prices.effectiveIncome l
      exact add_pos_of_pos_of_nonneg
        (mul_pos m.prices.grossReturn_pos (by exact_mod_cast ha))
        (m.prices.income_nonneg l)
    have hmono : ENNReal.ofReal
        (rightMarginalValue m
          (m.prices.nextResources (assetPolicy m z) l : ℝ)) ≤
        extendedRightMarginalValue m (minimumEffectiveIncome m) := by
      by_cases he : minimumEffectiveIncome m = 0
      · rw [he, extendedRightMarginalValue_zero]
        exact rightMarginalValue_le_zeroRightMarginal m (by exact_mod_cast hn)
      · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr he)]
        exact ENNReal.ofReal_le_ofReal (rightMarginalValue_antitone m
          (by exact_mod_cast (pos_iff_ne_zero.mpr he)) (by exact_mod_cast hn)
          (by exact_mod_cast
            (minimumEffectiveIncome_le_nextResources m (assetPolicy m z) l)))
    have hreal := (ENNReal.toReal_le_toReal ENNReal.ofReal_ne_top hminFinite.ne).2 hmono
    rw [ENNReal.toReal_ofReal
      (rightMarginalValue_pos m (by exact_mod_cast hn)).le] at hreal
    have hcnext := consumption_positive_subcritical m hsmooth hbetaR _ hn
    have henvnext := (value_envelope_at_positive_consumption m hsmooth _ hn hcnext).2
    rwa [← henvnext]
  have hconst : Integrable (fun _ : m.income.Labor =>
      (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal)
      (m.income.law : Measure m.income.Labor) := integrable_const _
  have hintLe : ∫ l : m.income.Labor,
        deriv m.utility.utility
          (consumptionPolicy m
            (m.prices.nextResources (assetPolicy m z) l) : ℝ)
        ∂(m.income.law : Measure m.income.Labor) ≤
      (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal := by
    calc
      _ ≤ ∫ _ : m.income.Labor,
          (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal
          ∂(m.income.law : Measure m.income.Labor) :=
        integral_mono hint hconst hle
      _ = _ := by simp
  rw [henv, ← heq]
  exact mul_le_mul_of_nonneg_left hintLe
    (mul_nonneg m.beta_pos.le m.prices.grossReturn_pos.le)

private theorem marginal_gap_near_minimum
    (m : HouseholdPrimitives)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (hminFinite : extendedRightMarginalValue m (minimumEffectiveIncome m) < ⊤) :
    ∃ zHat : Resources, minimumEffectiveIncome m < zHat ∧
      ∀ z : Resources, minimumEffectiveIncome m < z → z ≤ zHat →
        m.beta * m.prices.grossReturn *
            (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal <
          rightMarginalValue m (z : ℝ) := by
  let e := minimumEffectiveIncome m
  let Q := (extendedRightMarginalValue m e).toReal
  have hQ : 0 < Q := ENNReal.toReal_pos
    (ne_of_gt (thresholdMarginal_pos m)) hminFinite.ne
  have hgamma : 0 < m.beta * m.prices.grossReturn :=
    mul_pos m.beta_pos m.prices.grossReturn_pos
  have hgap : m.beta * m.prices.grossReturn * Q < Q := by
    nlinarith
  by_cases he : e = 0
  · have hminZero : minimumEffectiveIncome m = 0 := by simpa [e] using he
    have ht : Tendsto
        (fun z : ℝ => ENNReal.ofReal (rightMarginalValue m z))
        (nhdsWithin 0 (Ioi 0)) (nhds (zeroRightMarginal m)) :=
      positiveMarginal_tendsto_zero m
    have heq : zeroRightMarginal m = extendedRightMarginalValue m e := by
      rw [he, extendedRightMarginalValue_zero]
    have htarget : ENNReal.ofReal (m.beta * m.prices.grossReturn * Q) <
        zeroRightMarginal m := by
      rw [heq]
      apply (ENNReal.ofReal_lt_iff_lt_toReal
        (mul_nonneg hgamma.le hQ.le) hminFinite.ne).2
      exact hgap
    have hev : ∀ᶠ x : ℝ in nhdsWithin 0 (Ioi 0),
        ENNReal.ofReal (m.beta * m.prices.grossReturn * Q) <
          ENNReal.ofReal (rightMarginalValue m x) :=
      (tendsto_order.1 ht).1 _ htarget
    rw [eventually_nhdsWithin_iff, Metric.eventually_nhds_iff] at hev
    obtain ⟨ε, hε, hεs⟩ := hev
    let zHat : Resources := ⟨ε / 2, by positivity⟩
    refine ⟨zHat, ?_, ?_⟩
    · rw [hminZero]
      exact_mod_cast (half_pos hε)
    · intro z hz hzHat
      have hzReal : 0 < (z : ℝ) := by rw [hminZero] at hz; exact_mod_cast hz
      have hdist : dist (z : ℝ) 0 < ε := by
        have : (z : ℝ) ≤ ε / 2 := by exact_mod_cast hzHat
        calc
          dist (z : ℝ) 0 = (z : ℝ) := by
            simp
          _ ≤ ε / 2 := this
          _ < ε := by linarith
      have hof := hεs hdist hzReal
      rw [ENNReal.ofReal_lt_ofReal_iff (rightMarginalValue_pos m hzReal)] at hof
      exact hof
  · have hePos : 0 < (e : ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr he)
    have hcont := rightMarginalValue_rightContinuous m hePos
    have hQeq : Q = rightMarginalValue m (e : ℝ) := by
      dsimp [Q]
      rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr he),
        ENNReal.toReal_ofReal (rightMarginalValue_pos m hePos).le]
    have hev : ∀ᶠ x : ℝ in nhdsWithin (e : ℝ) (Set.Ici (e : ℝ)),
        m.beta * m.prices.grossReturn * Q < rightMarginalValue m x :=
      hcont.eventually (Ioi_mem_nhds (by simpa only [hQeq] using hgap))
    rw [eventually_nhdsWithin_iff, Metric.eventually_nhds_iff] at hev
    obtain ⟨ε, hε, hεs⟩ := hev
    let zHat : Resources := ⟨(e : ℝ) + ε / 2, by positivity⟩
    refine ⟨zHat, ?_, ?_⟩
    · exact_mod_cast lt_add_of_pos_right (e : ℝ) (half_pos hε)
    · intro z hz hzHat
      have hdist : dist (z : ℝ) (e : ℝ) < ε := by
        rw [Real.dist_eq, abs_of_nonneg (sub_nonneg.mpr (by exact_mod_cast hz.le))]
        have : (z : ℝ) ≤ (e : ℝ) + ε / 2 := by exact_mod_cast hzHat
        linarith
      exact hεs hdist (by exact_mod_cast hz.le)

/-- H13: under impatience and the qualified endpoint condition, shifted saving is zero on
a nondegenerate interval beginning at minimum effective income. -/
theorem binding_interval_exists
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (hthreshold : 0 < minimumEffectiveIncome m ∨
      utilityZeroRightMarginal m < ⊤) :
    ∃ zHat : Resources, minimumEffectiveIncome m < zHat ∧
      ∀ z : Resources, minimumEffectiveIncome m ≤ z → z ≤ zHat →
        assetPolicy m z = 0 := by
  have hminFinite := thresholdMarginal_finite m hbetaR hthreshold
  obtain ⟨zHat, hzHat, hgap⟩ :=
    marginal_gap_near_minimum m hbetaR hminFinite
  refine ⟨zHat, hzHat, ?_⟩
  intro z hminz hzzHat
  by_cases hzmin : z = minimumEffectiveIncome m
  · subst z
    by_cases he : minimumEffectiveIncome m = 0
    · rw [he]
      exact assetPolicy_zero m
    · by_contra ha0
      have ha : 0 < assetPolicy m (minimumEffectiveIncome m) :=
        pos_iff_ne_zero.mpr ha0
      have hu := interior_marginal_upper_bound m hsmooth hbetaR hminFinite
        (pos_iff_ne_zero.mpr he) ha
      have hq : rightMarginalValue m (minimumEffectiveIncome m : ℝ) =
          (extendedRightMarginalValue m (minimumEffectiveIncome m)).toReal := by
        rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr he),
          ENNReal.toReal_ofReal
            (rightMarginalValue_pos m (by exact_mod_cast (pos_iff_ne_zero.mpr he))).le]
      rw [hq] at hu
      have hpos := ENNReal.toReal_pos
        (ne_of_gt (thresholdMarginal_pos m)) hminFinite.ne
      nlinarith
  · have hzlt : minimumEffectiveIncome m < z := lt_of_le_of_ne hminz (Ne.symm hzmin)
    by_contra ha0
    have hz : 0 < z := lt_of_le_of_lt (minimumEffectiveIncome m).property hzlt
    have ha : 0 < assetPolicy m z := pos_iff_ne_zero.mpr ha0
    exact (not_lt_of_ge
      (interior_marginal_upper_bound m hsmooth hbetaR hminFinite hz ha))
      (hgap z hzlt hzzHat)

end
end Aiyagari1994
