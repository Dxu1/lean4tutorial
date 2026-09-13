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

namespace Aiyagari1994
noncomputable section

/-- H14: if minimum effective income is zero, utility has an Inada marginal at zero, and
zero effective income has positive probability, the canonical shifted saving choice is positive
at every positive resource state.  No impatience restriction is used. -/
theorem zero_income_atom_implies_nonbinding
    (m : HouseholdPrimitives) (_hsmooth : UtilitySmooth m.utility)
    (_hmin : minimumEffectiveIncome m = 0)
    (hinada : utilityZeroRightMarginal m = ⊤)
    (hatom : 0 < (m.income.law : Measure m.income.Labor)
      {l | m.prices.effectiveIncome l = 0}) :
    ∀ z : Resources, 0 < z → 0 < assetPolicy m z := by
  intro z hz
  let E : Set m.income.Labor := {l | m.prices.effectiveIncome l = 0}
  have hE : MeasurableSet E := by
    exact (isClosed_singleton.preimage
      ((continuous_const.mul continuous_subtype_val).add continuous_const)).measurableSet
  have hmassTop : (m.income.law : Measure m.income.Labor) E ≠ ⊤ := measure_ne_top _ _
  let p : ℝ := (m.income.law : Measure m.income.Labor).real E
  have hp : 0 < p := by
    have hatomE : 0 < (m.income.law : Measure m.income.Labor) E := by
      simpa [E] using hatom
    exact ENNReal.toReal_pos hatomE.ne' hmassTop
  have hq0 : zeroRightMarginal m = ⊤ := by
    have hinc : ∀ h : ℝ, 0 < h →
        m.utility.utility h - m.utility.utility 0 ≤
          valueExtension m h - valueExtension m 0 := by
      intro h hh
      let hr : Resources := ⟨h, hh.le⟩
      have hmax := assetPolicy_maximizes m hr 0 bot_le
      rw [(assetPolicy_optimal m hr).2,
        bellmanObjective_feasible m _ hr 0 bot_le] at hmax
      have hv0 := (assetPolicy_optimal m (0 : Resources)).2
      rw [assetPolicy_zero, bellmanObjective_feasible m _ 0 0 le_rfl] at hv0
      have heh : valueExtension m h = valueFunction m hr := by
        change valueFunction m h.toNNReal = valueFunction m hr
        congr 1
        apply NNReal.eq
        rw [Real.coe_toNNReal _ hh.le]
        rfl
      have he0 : valueExtension m 0 = valueFunction m 0 := by
        simp [valueExtension, nonnegativeExtension]
      change m.utility.utility ((hr : ℝ) - 0) +
        m.beta * continuation m (valueFunction m) 0 ≤ valueFunction m hr at hmax
      change m.utility.utility ((0 : ℝ) - 0) +
        m.beta * continuation m (valueFunction m) 0 = valueFunction m 0 at hv0
      rw [heh, he0]
      have hhr : (hr : ℝ) = h := rfl
      rw [sub_zero, hhr] at hmax
      norm_num at hv0
      linarith
    have hslope : ∀ᶠ h : ℝ in 𝓝[>] 0,
        ENNReal.ofReal (slope m.utility.utility 0 h) ≤
          ENNReal.ofReal (slope (valueExtension m) 0 h) := by
      filter_upwards [self_mem_nhdsWithin] with h hh
      apply ENNReal.ofReal_le_ofReal
      rw [slope_def_field, slope_def_field]
      exact (div_le_div_iff_of_pos_right (by simpa using hh)).2 (hinc h hh)
    have hle : utilityZeroRightMarginal m ≤ zeroRightMarginal m :=
      le_of_tendsto_of_tendsto (utilityZeroRightMarginal_secant_limit m)
        (zeroRightMarginal_secant_limit m) hslope
    rw [hinada] at hle
    exact top_unique hle
  by_contra hapos
  have ha0 : assetPolicy m z = 0 := by
    exact le_antisymm (not_lt.mp hapos) bot_le
  let C := slope m.utility.utility ((z : ℝ) / 2) (z : ℝ)
  have hzReal : 0 < (z : ℝ) := by exact_mod_cast hz
  have hCpos : 0 < C := by
    dsimp [C]
    rw [slope_def_field]
    apply div_pos
    · exact sub_pos.mpr (m.utility_base.increasing
        (show (z : ℝ) / 2 ∈ Ici 0 by change 0 ≤ (z : ℝ) / 2; positivity)
        (show (z : ℝ) ∈ Ici 0 by exact hzReal.le) (by linarith))
    · linarith
  let K := C / (m.beta * p * m.prices.grossReturn) + 1
  have hden : 0 < m.beta * p * m.prices.grossReturn :=
    mul_pos (mul_pos m.beta_pos hp) m.prices.grossReturn_pos
  have hK : 0 < K := by
    dsimp [K]
    positivity
  have ht : Tendsto
      (fun x : ℝ => ENNReal.ofReal (slope (valueExtension m) 0 x))
      (𝓝[>] 0) (𝓝 (⊤ : ENNReal)) := by
    simpa [hq0] using zeroRightMarginal_secant_limit m
  have hev : ∀ᶠ x : ℝ in 𝓝[>] 0,
      ENNReal.ofReal K < ENNReal.ofReal (slope (valueExtension m) 0 x) :=
    (tendsto_order.1 ht).1 _ ENNReal.ofReal_lt_top
  have hsmall : ∀ᶠ x : ℝ in 𝓝[>] 0,
      x < m.prices.grossReturn * (z : ℝ) / 2 := by
    have hupper : (0 : ℝ) < m.prices.grossReturn * (z : ℝ) / 2 := by
      exact div_pos (mul_pos m.prices.grossReturn_pos hzReal) (by norm_num)
    exact (eventually_lt_nhds hupper).filter_mono
        nhdsWithin_le_nhds
  have hex : ∃ x : ℝ, 0 < x ∧
      x < m.prices.grossReturn * (z : ℝ) / 2 ∧
      ENNReal.ofReal K < ENNReal.ofReal (slope (valueExtension m) 0 x) := by
    have hboth : ∀ᶠ x : ℝ in 𝓝[>] 0, 0 < x ∧
        x < m.prices.grossReturn * (z : ℝ) / 2 ∧
        ENNReal.ofReal K < ENNReal.ofReal (slope (valueExtension m) 0 x) := by
      filter_upwards [self_mem_nhdsWithin, hsmall, hev] with x hx hxsmall hxlarge
      exact ⟨hx, hxsmall, hxlarge⟩
    exact hboth.exists
  obtain ⟨x, hx, hxsmall, hxlarge⟩ := hex
  let a : Resources := ⟨x / m.prices.grossReturn,
    (div_nonneg hx.le m.prices.grossReturn_pos.le)⟩
  have ha : 0 < a := by
    exact_mod_cast div_pos hx m.prices.grossReturn_pos
  have hazhalf : (a : ℝ) < (z : ℝ) / 2 := by
    dsimp [a]
    exact (div_lt_iff₀ m.prices.grossReturn_pos).2 (by linarith)
  have haz : a ≤ z := by
    exact_mod_cast (hazhalf.trans_le (by linarith : (z : ℝ) / 2 ≤ (z : ℝ))).le
  let xr : Resources := ⟨x, hx.le⟩
  have hxa : x = m.prices.grossReturn * (a : ℝ) := by
    change x = m.prices.grossReturn * (x / m.prices.grossReturn)
    calc
      x = (x / m.prices.grossReturn) * m.prices.grossReturn :=
        (div_mul_cancel₀ x m.prices.grossReturn_pos.ne').symm
      _ = _ := by ring
  let d : ℝ := valueFunction m xr - valueFunction m 0
  have hdpos : 0 ≤ d := by
    dsimp [d]
    exact sub_nonneg.mpr (valueFunction_monotone m
      (show (0 : Resources) ≤ xr from bot_le))
  have hcontLower : p * d ≤
      continuation m (valueFunction m) a - continuation m (valueFunction m) 0 := by
    let f : m.income.Labor → ℝ := fun l =>
      valueFunction m (m.prices.nextResources a l) -
        valueFunction m (m.prices.nextResources 0 l)
    let g : m.income.Labor → ℝ := E.indicator (fun _ => d)
    have hf : Integrable f (m.income.law : Measure m.income.Labor) :=
      (continuation_integrable m (valueFunction m) a).sub
        (continuation_integrable m (valueFunction m) 0)
    have hg : Integrable g (m.income.law : Measure m.income.Labor) :=
      (integrable_const d).indicator hE
    have hgf : ∀ l, g l ≤ f l := by
      intro l
      by_cases hl : l ∈ E
      · have heff : m.prices.effectiveIncome l = 0 := hl
        simp only [g, f, indicator_of_mem hl]
        change valueFunction m xr - valueFunction m 0 ≤
          valueFunction m (m.prices.nextResources a l) -
            valueFunction m (m.prices.nextResources 0 l)
        rw [show m.prices.nextResources a l =
              xr by
              apply NNReal.eq
              change m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l = x
              rw [heff, add_zero, ← hxa],
            show m.prices.nextResources 0 l = 0 by
              apply NNReal.eq
              change m.prices.grossReturn * (0 : ℝ) + m.prices.effectiveIncome l = 0
              rw [heff]
              ring]
      · simp only [g, f, Set.indicator_of_notMem hl]
        exact sub_nonneg.mpr (valueFunction_monotone m
          (show m.prices.nextResources 0 l ≤ m.prices.nextResources a l by
            change (m.prices.nextResources 0 l : ℝ) ≤
              (m.prices.nextResources a l : ℝ)
            simp only [NormalizedPrices.nextResources, NNReal.coe_zero,
              mul_zero, zero_add]
            exact le_add_of_nonneg_left
              (mul_nonneg m.prices.grossReturn_pos.le a.property)))
    have hi := integral_mono hg hf hgf
    have hfi : ∫ l, f l ∂(m.income.law : Measure m.income.Labor) =
        continuation m (valueFunction m) a - continuation m (valueFunction m) 0 := by
      exact integral_sub
        (continuation_integrable m (valueFunction m) a)
        (continuation_integrable m (valueFunction m) 0)
    have hgi : ∫ l, g l ∂(m.income.law : Measure m.income.Labor) = p * d := by
      rw [integral_indicator_const d hE]
      simp [p]
    rwa [hgi, hfi] at hi
  have hopt := assetPolicy_maximizes m z a haz
  rw [ha0, bellmanObjective_feasible m _ z a haz,
    bellmanObjective_feasible m _ z 0 bot_le] at hopt
  norm_num at hopt
  have hcost : m.beta * p * d ≤
      m.utility.utility (z : ℝ) - m.utility.utility ((z : ℝ) - (a : ℝ)) := by
    have := mul_le_mul_of_nonneg_left hcontLower m.beta_pos.le
    calc
      _ ≤ m.beta * (continuation m (valueFunction m) a -
          continuation m (valueFunction m) 0) := by simpa [mul_assoc] using this
      _ ≤ _ := by linarith
  have hcostBound :
      m.utility.utility (z : ℝ) - m.utility.utility ((z : ℝ) - (a : ℝ)) ≤
        C * (a : ℝ) := by
    have hleft : (z : ℝ) / 2 ≤ (z : ℝ) - (a : ℝ) := by linarith
    have hza : (z : ℝ) - (a : ℝ) < (z : ℝ) := by linarith [show (0 : ℝ) < (a : ℝ) by exact_mod_cast ha]
    have hs := m.utility_base.concave.concaveOn.slope_anti
      (show (z : ℝ) ∈ Ici 0 from hzReal.le)
      (show (z : ℝ) / 2 ∈ Ici 0 \ {(z : ℝ)} by
        exact ⟨by change 0 ≤ (z : ℝ) / 2; positivity, by
          intro h
          simp only [mem_singleton_iff] at h
          linarith⟩)
      (show (z : ℝ) - (a : ℝ) ∈ Ici 0 \ {(z : ℝ)} by
        exact ⟨by change 0 ≤ (z : ℝ) - (a : ℝ); linarith, hza.ne⟩)
      hleft
    have hs' : slope m.utility.utility ((z : ℝ) - (a : ℝ)) (z : ℝ) ≤ C := by
      dsimp [C]
      rw [slope_comm m.utility.utility ((z : ℝ) - (a : ℝ)) (z : ℝ),
        slope_comm m.utility.utility ((z : ℝ) / 2) (z : ℝ)]
      exact hs
    rw [slope_def_field, sub_sub_cancel] at hs'
    have haReal : 0 < (a : ℝ) := by exact_mod_cast ha
    exact (div_le_iff₀ haReal).mp hs'
  have hdSlope : d = x * slope (valueExtension m) 0 x := by
    have hev0 : valueExtension m 0 = valueFunction m 0 := by
      simp [valueExtension, nonnegativeExtension]
    have hevx : valueExtension m x = valueFunction m xr := by
      change valueFunction m x.toNNReal = valueFunction m xr
      congr 1
      apply NNReal.eq
      rw [Real.coe_toNNReal _ hx.le]
      rfl
    rw [slope_def_field, sub_zero, hev0, hevx]
    dsimp [d]
    field_simp
  have hbound : m.beta * p * m.prices.grossReturn *
      slope (valueExtension m) 0 x ≤ C := by
    have hineq := hcost.trans hcostBound
    rw [hdSlope] at hineq
    have hacoe : (a : ℝ) = x / m.prices.grossReturn := rfl
    rw [hacoe] at hineq
    have hmul := mul_le_mul_of_nonneg_left hineq m.prices.grossReturn_pos.le
    have hcanc : x * (m.beta * p * m.prices.grossReturn *
        slope (valueExtension m) 0 x) ≤ x * C := by
      calc
        _ = m.prices.grossReturn * (m.beta * p * (x *
            slope (valueExtension m) 0 x)) := by ring
        _ ≤ m.prices.grossReturn * (C * (x / m.prices.grossReturn)) := hmul
        _ = _ := by
          field_simp [m.prices.grossReturn_pos.ne']
    exact le_of_mul_le_mul_left hcanc hx
  have hxlargeReal : K < slope (valueExtension m) 0 x := by
    exact (ENNReal.ofReal_lt_ofReal_iff (rightSecant_pos m (le_refl 0) hx)).mp hxlarge
  have hCK : C < (m.beta * p * m.prices.grossReturn) * K := by
    calc
      C < C + m.beta * p * m.prices.grossReturn := by linarith
      _ = (m.beta * p * m.prices.grossReturn) * K := by
        dsimp [K]
        rw [mul_add, mul_one]
        have hcancel : (m.beta * p * m.prices.grossReturn) *
            (C / (m.beta * p * m.prices.grossReturn)) = C := by
          rw [mul_comm, div_mul_cancel₀ C hden.ne']
        rw [hcancel]
  have := mul_lt_mul_of_pos_left hxlargeReal hden
  exact (not_lt_of_ge hbound) (hCK.trans this)

end
end Aiyagari1994
