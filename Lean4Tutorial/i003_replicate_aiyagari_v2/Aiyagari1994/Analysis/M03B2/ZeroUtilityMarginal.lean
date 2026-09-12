import Aiyagari1994.Household.RightMarginal
import Mathlib.Topology.Instances.ENNReal.Lemmas

/-! The utility marginal at zero, retaining a possible infinite value. -/
open Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- The economic right marginal of utility at zero, defined by nonnegative secants. -/
def utilityZeroRightMarginal (m : HouseholdPrimitives) : ENNReal :=
  sSup ((fun y => ENNReal.ofReal (slope m.utility.utility 0 y)) '' Ioi 0)

theorem utilityZeroSecant_antitone (m : HouseholdPrimitives) :
    AntitoneOn (fun y => ENNReal.ofReal (slope m.utility.utility 0 y)) (Ioi 0) := by
  intro x hx y hy hxy
  apply ENNReal.ofReal_le_ofReal
  exact m.utility_base.concave.concaveOn.antitoneOn_slope_gt (by simp)
    ⟨(show 0 ≤ x from (show 0 < x from hx).le), hx⟩
    ⟨(show 0 ≤ y from (show 0 < y from hy).le), hy⟩ hxy

theorem utilityZeroRightMarginal_secant_limit (m : HouseholdPrimitives) :
    Tendsto (fun y => ENNReal.ofReal (slope m.utility.utility 0 y)) (𝓝[>] 0)
      (𝓝 (utilityZeroRightMarginal m)) :=
  (utilityZeroSecant_antitone m).tendsto_nhdsGT (OrderTop.bddAbove _)

theorem utilityZeroRightMarginal_pos (m : HouseholdPrimitives) :
    0 < utilityZeroRightMarginal m := by
  have hu := m.utility_base.increasing (show (0 : ℝ) ∈ Ici 0 by simp)
    (show (1 : ℝ) ∈ Ici 0 by simp) (by norm_num)
  have hs : 0 < ENNReal.ofReal (slope m.utility.utility 0 1) := by
    rw [ENNReal.ofReal_pos, slope_def_field]
    simpa using hu
  exact hs.trans_le (le_csSup (OrderTop.bddAbove _)
    ⟨(1 : ℝ), by norm_num, rfl⟩)

theorem utility_secant_le_zeroRightMarginal (m : HouseholdPrimitives) {x y : ℝ}
    (hx : 0 ≤ x) (hxy : x < y) :
    ENNReal.ofReal (slope m.utility.utility x y) ≤ utilityZeroRightMarginal m := by
  have hxy0 : 0 < y := hx.trans_lt hxy
  have hs : slope m.utility.utility x y ≤ slope m.utility.utility 0 y := by
    rw [slope_comm m.utility.utility x y, slope_comm m.utility.utility 0 y]
    exact m.utility_base.concave.concaveOn.slope_anti hxy0.le
      (show 0 ∈ Ici 0 \ {y} by exact ⟨by simp, by simpa using hxy0.ne⟩)
      (show x ∈ Ici 0 \ {y} by exact ⟨hx, by simpa using hxy.ne⟩) hx
  exact (ENNReal.ofReal_le_ofReal hs).trans
    (le_csSup (OrderTop.bddAbove _)
      ⟨y, hxy0, rfl⟩)

/-- A finite zero utility marginal bounds every utility increment on the economic domain. -/
theorem utility_increment_le_zeroMarginal (m : HouseholdPrimitives)
    (hfinite : utilityZeroRightMarginal m < ⊤) {x y : ℝ}
    (hx : 0 ≤ x) (hxy : x ≤ y) :
    m.utility.utility y - m.utility.utility x ≤
      (utilityZeroRightMarginal m).toReal * (y - x) := by
  rcases hxy.eq_or_lt with rfl | hxy
  · simp
  have hsnonneg : 0 ≤ slope m.utility.utility x y := by
    rw [slope_def_field]
    exact div_nonneg (sub_nonneg.mpr (m.utility_base.increasing hx
      (hx.trans hxy.le) hxy).le) (sub_nonneg.mpr hxy.le)
  have hs : slope m.utility.utility x y ≤ (utilityZeroRightMarginal m).toReal := by
    have h := utility_secant_le_zeroRightMarginal m hx hxy
    have hr := (ENNReal.toReal_le_toReal ENNReal.ofReal_ne_top hfinite.ne).2 h
    simpa [ENNReal.toReal_ofReal hsnonneg] using hr
  rw [slope_def_field] at hs
  exact (div_le_iff₀ (sub_pos.mpr hxy)).mp hs

end
end Aiyagari1994
