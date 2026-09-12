import Mathlib.Analysis.Convex.Deriv

/-! A one-dimensional differentiable lower-touching lemma for concave functions. -/
open Set Filter
open scoped Topology
namespace Aiyagari1994

/-- A finite concave real function is differentiable at an interior point when a differentiable
function touches it from below on a neighborhood of that point.  This is the one-dimensional
lower-touching argument: concavity orders the left and right secants, while the touching function
squeezes both one-sided limits to its derivative. -/
theorem concave_hasDerivAt_of_lowerTouching
    {S : Set ℝ} {f g : ℝ → ℝ} {x d : ℝ}
    (hf : ConcaveOn ℝ S f) (hx : x ∈ interior S)
    (hg : HasDerivAt g d x) (heq : g x = f x)
    (htouch : ∀ᶠ y in nhds x, g y ≤ f y) :
    HasDerivAt f d x := by
  let q : ℝ := -sInf (slope (fun y ↦ -f y) x '' {y | y ∈ S ∧ x < y})
  have hright : HasDerivWithinAt f q (Ioi x) x := by
    have h := hf.neg.hasDerivWithinAt_sInf_slope_of_mem_interior hx
    convert! h.neg using 1
    simp [Pi.neg_def]
  have hS : S ∈ nhds x := mem_interior_iff_mem_nhds.mp hx
  have hxS : x ∈ S := interior_subset hx
  have hSRight : ∀ᶠ y in nhdsWithin x (Ioi x), y ∈ S :=
    (show ∀ᶠ y in nhds x, y ∈ S from hS).filter_mono nhdsWithin_le_nhds
  have hSLeft : ∀ᶠ y in nhdsWithin x (Iio x), y ∈ S :=
    (show ∀ᶠ y in nhds x, y ∈ S from hS).filter_mono nhdsWithin_le_nhds
  have hrightSlope : Tendsto (slope f x) (nhdsWithin x (Ioi x)) (nhds q) :=
    (hasDerivWithinAt_iff_tendsto_slope' self_notMem_Ioi).mp hright
  have hgRight : Tendsto (slope g x) (nhdsWithin x (Ioi x)) (nhds d) :=
    (hasDerivAt_iff_tendsto_slope_left_right.mp hg).2
  have hgfRight : ∀ᶠ y in nhdsWithin x (Ioi x), slope g x y ≤ slope f x y := by
    filter_upwards [self_mem_nhdsWithin, htouch.filter_mono nhdsWithin_le_nhds] with y hxy hy
    rw [slope_def_field, slope_def_field, heq]
    exact div_le_div_of_nonneg_right (sub_le_sub_right hy _) (sub_nonneg.mpr hxy.le)
  have hdq : d ≤ q := le_of_tendsto_of_tendsto hgRight hrightSlope hgfRight
  have hqLeft : ∀ᶠ y in nhdsWithin x (Iio x), q ≤ slope f x y := by
    filter_upwards [self_mem_nhdsWithin, hSLeft] with y hyx hyS
    apply le_of_tendsto hrightSlope
    filter_upwards [self_mem_nhdsWithin, hSRight] with u hxu huS
    have hs := hf.slope_anti hxS (show y ∈ S \ {x} from ⟨hyS, by simpa using hyx.ne⟩)
      (show u ∈ S \ {x} from ⟨huS, by simpa using hxu.ne'⟩) (hyx.le.trans hxu.le)
    simpa only [slope_comm f x y] using hs
  have hfgLeft : ∀ᶠ y in nhdsWithin x (Iio x), slope f x y ≤ slope g x y := by
    filter_upwards [self_mem_nhdsWithin, htouch.filter_mono nhdsWithin_le_nhds] with y hyx hy
    rw [slope_def_field, slope_def_field, heq]
    exact (div_le_div_right_of_neg (sub_neg.mpr hyx)).2 (sub_le_sub_right hy _)
  have hgLeft : Tendsto (slope g x) (nhdsWithin x (Iio x)) (nhds d) :=
    (hasDerivAt_iff_tendsto_slope_left_right.mp hg).1
  have hqd : q ≤ d := le_of_tendsto_of_tendsto tendsto_const_nhds hgLeft
    (hqLeft.and hfgLeft |>.mono fun _ h ↦ h.1.trans h.2)
  have hqd_eq : q = d := le_antisymm hqd hdq
  rw [hqd_eq] at hrightSlope hqLeft
  apply hasDerivAt_iff_tendsto_slope_left_right.mpr
  exact ⟨tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hgLeft hqLeft hfgLeft,
    hrightSlope⟩

end Aiyagari1994
