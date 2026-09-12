import Aiyagari1994.Household.Value
import Mathlib.Analysis.Convex.Deriv

open Set
open scoped NNReal
namespace Aiyagari1994
noncomputable section

/-- Extend only for real-domain analysis; concavity is asserted on Ici 0. -/
def nonnegativeExtension (f : Resources → ℝ) (x : ℝ) : ℝ := f x.toNNReal

theorem NNRealConcave.extension {f : Resources → ℝ} (hf : NNRealConcave f) :
    ConcaveOn ℝ (Ici 0) (nonnegativeExtension f) := by
  refine ⟨convex_Ici _, ?_⟩
  intro x hx y hy a b ha hb hab
  have habn : a.toNNReal+b.toNNReal=1 := by
    apply NNReal.eq
    simpa only [NNReal.coe_add,NNReal.coe_one,Real.coe_toNNReal _ ha,Real.coe_toNNReal _ hb] using hab
  have h := hf x.toNNReal y.toNNReal a.toNNReal b.toNNReal habn
  have he : (a*x+b*y).toNNReal = a.toNNReal*x.toNNReal+b.toNNReal*y.toNNReal := by
    apply NNReal.eq
    simp only [NNReal.coe_add,NNReal.coe_mul,Real.coe_toNNReal _ ha,Real.coe_toNNReal _ hb,
      Real.coe_toNNReal _ hx,Real.coe_toNNReal _ hy,
      Real.coe_toNNReal _ (add_nonneg (mul_nonneg ha hx) (mul_nonneg hb hy))]
  change a*f x.toNNReal+b*f y.toNNReal ≤ f (a*x+b*y).toNNReal
  rw [he]
  simpa only [Real.coe_toNNReal _ ha,Real.coe_toNNReal _ hb] using h

/-- Moving two points inward while preserving their sum increases a concave sum. -/
theorem concave_four_point {f : ℝ → ℝ} (hf : ConcaveOn ℝ (Ici 0) f)
    {x y u v : ℝ} (hx : 0 ≤ x) (hxy : x < y)
    (hxu : x ≤ u) (huy : u ≤ y) (hxv : x ≤ v) (hvy : v ≤ y)
    (hs : u+v=x+y) : f x+f y ≤ f u+f v := by
  have hd : 0 < y-x := sub_pos.mpr hxy
  have comb (w : ℝ) (hxw : x ≤ w) (hwy : w ≤ y) :
      ((y-w)/(y-x))*f x+((w-x)/(y-x))*f y ≤ f w := by
    have h := hf.2 hx (le_trans hx hxy.le)
      (div_nonneg (sub_nonneg.mpr hwy) hd.le)
      (div_nonneg (sub_nonneg.mpr hxw) hd.le)
      (show (y-w)/(y-x)+(w-x)/(y-x)=1 by field_simp; ring)
    have he : ((y-w)/(y-x)) • x+((w-x)/(y-x)) • y = w := by
      simp only [smul_eq_mul]; field_simp [ne_of_gt hd]; ring
    simp only [smul_eq_mul] at he h
    rw [he] at h
    exact h
  have hu := comb u hxu huy
  have hv := comb v hxv hvy
  have h1 : (y-u)/(y-x)+(y-v)/(y-x)=1 := by
    rw [← add_div]; apply (div_eq_one_iff_eq (ne_of_gt hd)).mpr; linarith
  have h2 : (u-x)/(y-x)+(v-x)/(y-x)=1 := by
    rw [← add_div]; apply (div_eq_one_iff_eq (ne_of_gt hd)).mpr; linarith
  have he : (y-u)/(y-x)*f x+(u-x)/(y-x)*f y +
      ((y-v)/(y-x)*f x+(v-x)/(y-x)*f y) = f x+f y := by
    calc
      _ = ((y-u)/(y-x)+(y-v)/(y-x))*f x+((u-x)/(y-x)+(v-x)/(y-x))*f y := by ring
      _ = _ := by rw [h1,h2]; ring
  linarith [hu,hv]

end
end Aiyagari1994
