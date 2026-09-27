import Aiyagari1994.Analysis.M03B2.ZeroUtilityMarginal
import Aiyagari1994.Household.Envelope
import Aiyagari1994.Household.MarginalInequality

/-! Gate-local bridge from equal finite value marginals to equal consumption. -/
open Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994.M07A4
noncomputable section

private theorem assetPolicy_eq_state_of_consumption_zero
    (m : HouseholdPrimitives) (z : Resources) (hc : consumptionPolicy m z = 0) :
    assetPolicy m z = z := by
  have hb := (consumptionPolicy_budget m z).2
  rw [hc, zero_add] at hb
  exact hb

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

private theorem extendedMarginal_secant_limit (m : HouseholdPrimitives) (z : Resources) :
    Tendsto (fun h : ℝ ↦ ENNReal.ofReal
      (slope (valueExtension m) (z : ℝ) ((z : ℝ) + h)))
      (nhdsWithin 0 (Ioi 0)) (nhds (extendedRightMarginalValue m z)) := by
  by_cases hz : z = 0
  · subst z
    simpa using zeroRightMarginal_secant_limit m
  · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr hz)]
    exact (ENNReal.continuous_ofReal.continuousAt.tendsto.comp
      (rightMarginalValue_secant_limit m
        (show 0 < (z : ℝ) by exact_mod_cast pos_iff_ne_zero.mpr hz))).comp
      (by
        rw [tendsto_nhdsWithin_iff]
        constructor
        · simpa using (tendsto_const_nhds.add
            (tendsto_id.mono_left nhdsWithin_le_nhds) :
            Tendsto (fun h : ℝ ↦ (z : ℝ) + h) (nhdsWithin 0 (Ioi 0))
              (nhds ((z : ℝ) + 0)))
        · filter_upwards [self_mem_nhdsWithin] with h hh
          exact lt_add_of_pos_right (z : ℝ) hh)

private theorem utilityZeroRightMarginal_le_extended_of_consumption_zero
    (m : HouseholdPrimitives) (z : Resources) (hc : consumptionPolicy m z = 0) :
    utilityZeroRightMarginal m ≤ extendedRightMarginalValue m z := by
  have hineq : ∀ᶠ h : ℝ in nhdsWithin 0 (Ioi 0),
      ENNReal.ofReal (slope m.utility.utility 0 h) ≤
        ENNReal.ofReal (slope (valueExtension m) (z : ℝ) ((z : ℝ) + h)) := by
    filter_upwards [self_mem_nhdsWithin] with h hh
    apply ENNReal.ofReal_le_ofReal
    rw [slope_def_field, slope_def_field, sub_zero, add_sub_cancel_left]
    exact (div_le_div_iff_of_pos_right hh).2
      (utility_increment_le_value_increment_of_consumption_zero m z hc hh)
  exact le_of_tendsto_of_tendsto (utilityZeroRightMarginal_secant_limit m)
    (extendedMarginal_secant_limit m z) hineq

private theorem positive_consumption_marginal_lt_utilityZero
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (z : Resources) (hc : 0 < consumptionPolicy m z) :
    extendedRightMarginalValue m z < utilityZeroRightMarginal m := by
  have hz : 0 < z := lt_of_lt_of_le hc (tsub_le_self : z - assetPolicy m z ≤ z)
  have hcReal : 0 < (consumptionPolicy m z : ℝ) := by exact_mod_cast hc
  have hdiff : DifferentiableAt ℝ m.utility.utility (consumptionPolicy m z : ℝ) :=
    (hsmooth.smooth.differentiableOn_one _ hcReal).differentiableAt
      (isOpen_Ioi.mem_nhds hcReal)
  have hderivSlope : deriv m.utility.utility (consumptionPolicy m z : ℝ) <
      slope m.utility.utility 0 (consumptionPolicy m z : ℝ) :=
    m.utility_base.concave.deriv_lt_slope (by simp) hcReal.le hcReal hdiff
  have hderivPos := hsmooth.marginal_pos (consumptionPolicy m z : ℝ) hcReal
  rw [extendedRightMarginalValue_of_pos m hz,
    (value_envelope_at_positive_consumption m hsmooth z hz hc).2]
  exact (ENNReal.ofReal_lt_ofReal_iff (hderivPos.trans hderivSlope)).2 hderivSlope |>.trans_le
    (utility_secant_le_zeroRightMarginal m (by norm_num) hcReal)

/-- Equal finite economic value marginals force equal optimal consumption.  This includes a
zero-consumption endpoint and never substitutes the positive-state real marginal at zero. -/
theorem consumption_eq_of_extendedMarginal_eq
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (z₁ z₂ : Resources)
    (_hfinite₁ : extendedRightMarginalValue m z₁ < ⊤)
    (_hfinite₂ : extendedRightMarginalValue m z₂ < ⊤)
    (heq : extendedRightMarginalValue m z₂ = extendedRightMarginalValue m z₁) :
    consumptionPolicy m z₂ = consumptionPolicy m z₁ := by
  by_cases hc₁ : consumptionPolicy m z₁ = 0
  · by_cases hc₂ : consumptionPolicy m z₂ = 0
    · rw [hc₁, hc₂]
    · have hc₂pos : 0 < consumptionPolicy m z₂ := pos_iff_ne_zero.mpr hc₂
      have hlt := positive_consumption_marginal_lt_utilityZero m hsmooth z₂ hc₂pos
      have hle := utilityZeroRightMarginal_le_extended_of_consumption_zero m z₁ hc₁
      rw [heq] at hlt
      exact False.elim ((not_lt_of_ge hle) hlt)
  · have hc₁pos : 0 < consumptionPolicy m z₁ := pos_iff_ne_zero.mpr hc₁
    by_cases hc₂ : consumptionPolicy m z₂ = 0
    · have hlt := positive_consumption_marginal_lt_utilityZero m hsmooth z₁ hc₁pos
      have hle := utilityZeroRightMarginal_le_extended_of_consumption_zero m z₂ hc₂
      rw [heq] at hle
      exact False.elim ((not_lt_of_ge hle) hlt)
    · have hc₂pos : 0 < consumptionPolicy m z₂ := pos_iff_ne_zero.mpr hc₂
      have hz₁ : 0 < z₁ := lt_of_lt_of_le hc₁pos
        (tsub_le_self : z₁ - assetPolicy m z₁ ≤ z₁)
      have hz₂ : 0 < z₂ := lt_of_lt_of_le hc₂pos
        (tsub_le_self : z₂ - assetPolicy m z₂ ≤ z₂)
      have hm₁ := (value_envelope_at_positive_consumption m hsmooth z₁ hz₁ hc₁pos).2
      have hm₂ := (value_envelope_at_positive_consumption m hsmooth z₂ hz₂ hc₂pos).2
      rw [extendedRightMarginalValue_of_pos m hz₂,
        extendedRightMarginalValue_of_pos m hz₁, hm₂, hm₁] at heq
      have hd₁ := hsmooth.marginal_pos _ (show (consumptionPolicy m z₁ : ℝ) ∈ Ioi 0 by
        exact_mod_cast hc₁pos)
      have hd₂ := hsmooth.marginal_pos _ (show (consumptionPolicy m z₂ : ℝ) ∈ Ioi 0 by
        exact_mod_cast hc₂pos)
      have hderiv : deriv m.utility.utility (consumptionPolicy m z₂ : ℝ) =
          deriv m.utility.utility (consumptionPolicy m z₁ : ℝ) := by
        exact (ENNReal.ofReal_eq_ofReal_iff hd₂.le hd₁.le).mp heq
      have hdiff : ∀ x ∈ Ioi (0 : ℝ), DifferentiableAt ℝ m.utility.utility x := by
        intro x hx
        exact (hsmooth.smooth.differentiableOn_one x hx).differentiableAt
          (isOpen_Ioi.mem_nhds hx)
      have hinj := ((m.utility_base.concave.subset Ioi_subset_Ici_self
        (convex_Ioi 0)).strictAntiOn_deriv hdiff).injOn
      exact_mod_cast hinj (show (consumptionPolicy m z₂ : ℝ) ∈ Ioi 0 by
          exact_mod_cast hc₂pos)
        (show (consumptionPolicy m z₁ : ℝ) ∈ Ioi 0 by exact_mod_cast hc₁pos) hderiv

end
end Aiyagari1994.M07A4
