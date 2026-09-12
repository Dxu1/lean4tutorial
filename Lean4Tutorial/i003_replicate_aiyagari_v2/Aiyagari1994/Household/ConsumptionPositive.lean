import Aiyagari1994.Analysis.M03B2.BellmanLipschitz
import Aiyagari1994.Household.Policy

/-! H10: strictly positive optimal consumption under `beta * R < 1`. -/
open MeasureTheory Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994
noncomputable section

private theorem assetPolicy_eq_state_of_consumption_zero
    (m : HouseholdPrimitives) (z : Resources) (hc : consumptionPolicy m z = 0) :
    assetPolicy m z = z := by
  have hb := (consumptionPolicy_budget m z).2
  rw [hc, zero_add] at hb
  exact hb

/-- At a zero-consumption corner, extra current resources can be consumed while preserving
the original shifted saving choice. -/
private theorem utility_increment_le_value_increment_of_consumption_zero
    (m : HouseholdPrimitives) (z : Resources) (hc : consumptionPolicy m z = 0)
    {h : ℝ} (hh : 0 < h) :
    m.utility.utility h - m.utility.utility 0 ≤
      valueExtension m ((z : ℝ) + h) - valueExtension m (z : ℝ) := by
  let zh : Resources := ⟨(z : ℝ) + h, add_nonneg z.property hh.le⟩
  have hfeas : assetPolicy m z ≤ zh := by
    exact (assetPolicy_le_state m z).trans (show z ≤ zh by
      change (z : ℝ) ≤ (z : ℝ) + h
      linarith)
  have hmax := assetPolicy_maximizes m zh (assetPolicy m z) hfeas
  rw [(assetPolicy_optimal m zh).2] at hmax
  have hvz := (assetPolicy_optimal m z).2
  rw [bellmanObjective_feasible m _ zh (assetPolicy m z) hfeas] at hmax
  rw [bellmanObjective_feasible m _ z (assetPolicy m z)
    (assetPolicy_le_state m z)] at hvz
  have ha := assetPolicy_eq_state_of_consumption_zero m z hc
  have hcur : (zh : ℝ) - (assetPolicy m z : ℝ) = h := by
    change (z : ℝ) + h - (assetPolicy m z : ℝ) = h
    rw [ha]
    ring
  have hzero : (z : ℝ) - (assetPolicy m z : ℝ) = 0 := by rw [ha]; ring
  have hez : valueExtension m (z : ℝ) = valueFunction m z := by
    simp [valueExtension, nonnegativeExtension]
  have hezh : valueExtension m ((z : ℝ) + h) = valueFunction m zh := by
    change valueExtension m (zh : ℝ) = valueFunction m zh
    simp [valueExtension, nonnegativeExtension]
  rw [hcur] at hmax
  rw [hzero] at hvz
  rw [hez, hezh]
  linarith

private theorem finite_zeroMarginal_excludes_zero_consumption
    (m : HouseholdPrimitives)
    (hfinite : utilityZeroRightMarginal m < ⊤)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (z : Resources) (hz : 0 < z) : consumptionPolicy m z ≠ 0 := by
  intro hc
  let L := (utilityZeroRightMarginal m).toReal
  have hL : 0 < L := ENNReal.toReal_pos (ne_of_gt (utilityZeroRightMarginal_pos m)) hfinite.ne
  have hweak : m.beta * m.prices.grossReturn ≤ 1 := hbetaR.le
  have ha : assetPolicy m z = z := assetPolicy_eq_state_of_consumption_zero m z hc
  have hsmall : ∀ᶠ h : ℝ in 𝓝[>] 0, h ≤ (z : ℝ) := by
    filter_upwards [self_mem_nhdsWithin,
      (eventually_lt_nhds (show (0 : ℝ) < (z : ℝ) by exact_mod_cast hz)).filter_mono
        nhdsWithin_le_nhds] with h hh hhz
    exact hhz.le
  have hslope : ∀ᶠ h : ℝ in 𝓝[>] 0,
      ENNReal.ofReal (slope m.utility.utility 0 h) ≤
        ENNReal.ofReal (m.beta * m.prices.grossReturn * L) := by
    filter_upwards [self_mem_nhdsWithin, hsmall] with h hh hhz
    let ah : Resources := ⟨(z : ℝ) - h, sub_nonneg.mpr hhz⟩
    have hah : ah ≤ z := by
      change (z : ℝ) - h ≤ (z : ℝ)
      exact sub_le_self _ (show 0 ≤ h from (show 0 < h from hh).le)
    have hopt := assetPolicy_maximizes m z ah hah
    rw [ha] at hopt
    rw [bellmanObjective_feasible m _ z ah hah,
      bellmanObjective_feasible m _ z z le_rfl] at hopt
    have hcur : (z : ℝ) - (ah : ℝ) = h := by
      change (z : ℝ) - ((z : ℝ) - h) = h
      ring
    have hzero : (z : ℝ) - (z : ℝ) = 0 := sub_self _
    rw [hcur, hzero] at hopt
    have hcont := continuation_increment_le_zeroMarginal m hfinite hweak
      (show ah ≤ z from hah)
    have hreal : slope m.utility.utility 0 h ≤
        m.beta * m.prices.grossReturn * L := by
      rw [slope_def_field, sub_zero]
      apply (div_le_iff₀ (show 0 < h from hh)).2
      have hcont' := mul_le_mul_of_nonneg_left hcont m.beta_pos.le
      have he : ((z : ℝ) - (ah : ℝ)) = h := hcur
      dsimp [L] at hcont' ⊢
      rw [he] at hcont'
      linarith
    exact ENNReal.ofReal_le_ofReal hreal
  have hlim : utilityZeroRightMarginal m ≤
      ENNReal.ofReal (m.beta * m.prices.grossReturn * L) :=
    le_of_tendsto (utilityZeroRightMarginal_secant_limit m) hslope
  have hreal := (ENNReal.toReal_le_toReal hfinite.ne ENNReal.ofReal_ne_top).2 hlim
  have hcoef_nonneg : 0 ≤ m.beta * m.prices.grossReturn * L :=
    mul_nonneg (mul_nonneg m.beta_pos.le m.prices.grossReturn_pos.le) hL.le
  rw [ENNReal.toReal_ofReal hcoef_nonneg] at hreal
  dsimp [L] at hreal hL
  nlinarith

private theorem infinite_zeroMarginal_excludes_zero_consumption
    (m : HouseholdPrimitives)
    (hinfinite : utilityZeroRightMarginal m = ⊤)
    (z : Resources) (hz : 0 < z) : consumptionPolicy m z ≠ 0 := by
  intro hc
  have hineq : ∀ᶠ h : ℝ in 𝓝[>] 0,
      ENNReal.ofReal (slope m.utility.utility 0 h) ≤
        ENNReal.ofReal (slope (valueExtension m) (z : ℝ) ((z : ℝ) + h)) := by
    filter_upwards [self_mem_nhdsWithin] with h hh
    apply ENNReal.ofReal_le_ofReal
    rw [slope_def_field, slope_def_field, sub_zero, add_sub_cancel_left]
    exact (div_le_div_iff_of_pos_right (show 0 < h from hh)).2
      (utility_increment_le_value_increment_of_consumption_zero m z hc hh)
  have hvalue : Tendsto
      (fun h : ℝ => ENNReal.ofReal
        (slope (valueExtension m) (z : ℝ) ((z : ℝ) + h)))
      (𝓝[>] 0) (𝓝 (ENNReal.ofReal (rightMarginalValue m (z : ℝ)))) :=
    (ENNReal.continuous_ofReal.continuousAt.tendsto.comp
      (rightMarginalValue_secant_limit m
        (show 0 < (z : ℝ) by exact_mod_cast hz))).comp
      (by
        rw [tendsto_nhdsWithin_iff]
        constructor
        · simpa using (tendsto_const_nhds.add
            (tendsto_id.mono_left nhdsWithin_le_nhds) :
            Tendsto (fun h : ℝ => (z : ℝ) + h) (𝓝[>] 0) (𝓝 ((z : ℝ) + 0)))
        · filter_upwards [self_mem_nhdsWithin] with h hh
          exact lt_add_of_pos_right (z : ℝ) hh)
  have htop : utilityZeroRightMarginal m ≤
      ENNReal.ofReal (rightMarginalValue m (z : ℝ)) :=
    le_of_tendsto_of_tendsto (utilityZeroRightMarginal_secant_limit m) hvalue hineq
  rw [hinfinite] at htop
  exact ENNReal.ofReal_ne_top (top_unique htop)

/-- H10: under impatience, optimal consumption is strictly positive at every positive
resource state. The proof covers both a finite and an infinite utility marginal at zero. -/
theorem consumption_positive_subcritical
    (m : HouseholdPrimitives) (_hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ∀ z : Resources, 0 < z → 0 < consumptionPolicy m z := by
  intro z hz
  apply pos_iff_ne_zero.mpr
  by_cases hfinite : utilityZeroRightMarginal m < ⊤
  · exact finite_zeroMarginal_excludes_zero_consumption m hfinite hbetaR z hz
  · exact infinite_zeroMarginal_excludes_zero_consumption m
      (top_unique (not_lt.mp hfinite)) z hz

end
end Aiyagari1994
