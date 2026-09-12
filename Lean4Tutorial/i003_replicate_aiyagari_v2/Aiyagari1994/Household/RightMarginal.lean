import Aiyagari1994.Analysis.ConcaveReal
import Mathlib.Topology.Instances.ENNReal.Lemmas

open Set Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

def valueExtension (m : HouseholdPrimitives) : ℝ → ℝ := nonnegativeExtension (valueFunction m)

theorem valueExtension_concave (m : HouseholdPrimitives) : ConcaveOn ℝ (Ici 0) (valueExtension m) :=
  (valueFunction_concave m).extension

theorem valueExtension_continuous (m : HouseholdPrimitives) : Continuous (valueExtension m) :=
  (valueFunction m).continuous.comp continuous_real_toNNReal

theorem valueExtension_strictMono (m : HouseholdPrimitives) : StrictMonoOn (valueExtension m) (Ici 0) := by
  intro x hx y hy hxy
  apply valueFunction_strictMono m
  change x.toNNReal < y.toNNReal
  exact (Real.toNNReal_lt_toNNReal_iff_of_nonneg hx).mpr hxy

/-- Right marginal constructed as the negative infimum of the convex negative-value secants.
Its economic properties are asserted only at strictly positive real states. -/
def rightMarginalValue (m : HouseholdPrimitives) (z : ℝ) : ℝ :=
  -sInf (slope (fun x => -valueExtension m x) z '' {y | y ∈ Ici 0 ∧ z < y})

/-- Concavity proves existence and finiteness of this secant limit; no derivative is assumed. -/
theorem rightMarginalValue_hasDerivWithinAt (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    HasDerivWithinAt (valueExtension m) (rightMarginalValue m z) (Ioi z) z := by
  have h := (valueExtension_concave m).neg.hasDerivWithinAt_sInf_slope_of_mem_interior
    (show z ∈ interior (Ici (0:ℝ)) by simpa using hz)
  convert! h.neg using 1
  simp [Pi.neg_def]

theorem rightMarginalValue_secant_limit (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    Tendsto (slope (valueExtension m) z) (𝓝[>] z) (𝓝 (rightMarginalValue m z)) :=
  (hasDerivWithinAt_iff_tendsto_slope' (by simp)).mp (rightMarginalValue_hasDerivWithinAt m hz)

theorem rightSecant_antitone (m : HouseholdPrimitives) {z : ℝ} (hz : 0 ≤ z) :
    AntitoneOn (slope (valueExtension m) z) (Ioi z) := by
  intro x hx y hy hxy
  exact (valueExtension_concave m).antitoneOn_slope_gt hz ⟨hz.trans hx.le,hx⟩ ⟨hz.trans hy.le,hy⟩ hxy

theorem secant_le_rightMarginalValue (m : HouseholdPrimitives) {z y : ℝ} (hz : 0 < z) (hzy : z < y) :
    slope (valueExtension m) z y ≤ rightMarginalValue m z :=
  (valueExtension_concave m).slope_le_of_hasDerivWithinAt_Ioi hz.le (hz.trans hzy).le hzy
    (rightMarginalValue_hasDerivWithinAt m hz)

theorem rightMarginalValue_pos (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    0 < rightMarginalValue m z := by
  have h := (valueExtension_strictMono m) hz.le (show 0 ≤ z+1 by linarith) (show z<z+1 by linarith)
  have hs : 0 < slope (valueExtension m) z (z+1) := by
    rw [slope_def_field]; exact div_pos (sub_pos.mpr h) (by linarith)
  exact hs.trans_le (secant_le_rightMarginalValue m hz (by linarith))

theorem rightMarginalValue_le_leftSecant (m : HouseholdPrimitives) {x z : ℝ}
    (hx : 0 ≤ x) (hxz : x < z) : rightMarginalValue m z ≤ slope (valueExtension m) x z := by
  apply le_of_tendsto (rightMarginalValue_secant_limit m (hx.trans_lt hxz))
  filter_upwards [self_mem_nhdsWithin] with y hy
  have h := (valueExtension_concave m).slope_anti (hx.trans hxz.le)
    (show x ∈ Ici 0 \ {z} by exact ⟨hx,by simpa using hxz.ne⟩)
    (show y ∈ Ici 0 \ {z} by exact ⟨hx.trans (hxz.trans hy).le,by simpa using hy.ne'⟩)
    (hxz.trans hy).le
  simpa only [slope_comm (valueExtension m) z x] using h

theorem rightMarginalValue_antitone (m : HouseholdPrimitives) : AntitoneOn (rightMarginalValue m) (Ioi 0) := by
  intro x hx y hy hxy
  rcases hxy.eq_or_lt with rfl | hxy
  · rfl
  exact (rightMarginalValue_le_leftSecant m hx.le hxy).trans (secant_le_rightMarginalValue m hx hxy)

def utilityOscillation (m : HouseholdPrimitives) : ℝ := utilitySup m-utilityInf m

theorem valueExtension_oscillation_bound (m : HouseholdPrimitives) {z : ℝ} (_hz : 0 ≤ z) :
    valueExtension m z-valueExtension m 0 ≤ utilityOscillation m/(1-m.beta) := by
  have h1 := (valueFunction_bounds m z.toNNReal).2
  have h0 := (valueFunction_bounds m 0).1
  simp only [valueExtension,nonnegativeExtension,Real.toNNReal_zero]
  rw [utilityOscillation,sub_div]
  linarith

theorem rightMarginalValue_bounds (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    rightMarginalValue m z ≤ (valueExtension m z-valueExtension m 0)/z ∧
    (valueExtension m z-valueExtension m 0)/z ≤ utilityOscillation m/((1-m.beta)*z) := by
  constructor
  · simpa only [slope_def_field,sub_zero] using rightMarginalValue_le_leftSecant m (le_refl 0) hz
  · simpa only [div_div] using div_le_div_of_nonneg_right (valueExtension_oscillation_bound m hz.le) hz.le

/-- Continuity of a secant with a fixed, distinct right endpoint. -/
theorem valueSlope_tendsto_left (m : HouseholdPrimitives) {z y : ℝ} (hzy : z < y) :
    Tendsto (fun x => slope (valueExtension m) x y) (𝓝[>] z)
      (𝓝 (slope (valueExtension m) z y)) := by
  simp only [slope_def_field]
  exact ((tendsto_const_nhds.sub (valueExtension_continuous m).continuousAt.tendsto).div
    (tendsto_const_nhds.sub tendsto_id) (sub_ne_zero.mpr hzy.ne')).mono_left nhdsWithin_le_nhds

/-- The right marginal is continuous from the right at every positive state. -/
theorem rightMarginalValue_rightContinuous (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    ContinuousWithinAt (rightMarginalValue m) (Ici z) z := by
  let Q := rightMarginalValue m
  have hb : BddAbove (Q '' Ioi z) := ⟨Q z, by
    rintro _ ⟨x,hx,rfl⟩; exact rightMarginalValue_antitone m hz (hz.trans hx) hx.le⟩
  have hn : (Q '' Ioi z).Nonempty := ⟨Q (z+1),z+1,by simp,rfl⟩
  let L := sSup (Q '' Ioi z)
  have ht : Tendsto Q (𝓝[>] z) (𝓝 L) :=
    (rightMarginalValue_antitone m |>.mono (fun x hx => hz.trans hx)).tendsto_nhdsGT hb
  have hle : L ≤ Q z := csSup_le hn (by
    rintro _ ⟨x,hx,rfl⟩; exact rightMarginalValue_antitone m hz (hz.trans hx) hx.le)
  have hs (y : ℝ) (hy : z < y) : slope (valueExtension m) z y ≤ L := by
    apply le_of_tendsto (valueSlope_tendsto_left m hy)
    filter_upwards [self_mem_nhdsWithin, (eventually_lt_nhds hy).filter_mono nhdsWithin_le_nhds] with x hx hxy
    exact (secant_le_rightMarginalValue m (hz.trans hx) hxy).trans
      (le_csSup hb ⟨x,hx,rfl⟩)
  have hge : Q z ≤ L := le_of_tendsto (rightMarginalValue_secant_limit m hz)
    (by filter_upwards [self_mem_nhdsWithin] with y hy; exact hs y hy)
  have he : L = Q z := le_antisymm hle hge
  rw [he] at ht
  exact continuousWithinAt_Ioi_iff_Ici.mp ht

/-- Boundary marginal retains infinity: supremum of nonnegative right secants at zero. -/
def zeroRightMarginal (m : HouseholdPrimitives) : ENNReal :=
  sSup ((fun y => ENNReal.ofReal (slope (valueExtension m) 0 y)) '' Ioi 0)

theorem zeroSecant_antitone (m : HouseholdPrimitives) :
    AntitoneOn (fun y => ENNReal.ofReal (slope (valueExtension m) 0 y)) (Ioi 0) :=
  fun _ hx _ hy hxy => ENNReal.ofReal_le_ofReal (rightSecant_antitone m (le_refl 0) hx hy hxy)

theorem zeroRightMarginal_secant_limit (m : HouseholdPrimitives) :
    Tendsto (fun y => ENNReal.ofReal (slope (valueExtension m) 0 y)) (𝓝[>] 0)
      (𝓝 (zeroRightMarginal m)) :=
  (zeroSecant_antitone m).tendsto_nhdsGT (OrderTop.bddAbove _)

theorem rightMarginalValue_le_zeroRightMarginal (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    ENNReal.ofReal (rightMarginalValue m z) ≤ zeroRightMarginal m :=
  (ENNReal.ofReal_le_ofReal (rightMarginalValue_le_leftSecant m (le_refl 0) hz)).trans
    (le_sSup ⟨z,hz,rfl⟩)

/-- The boundary secant supremum equals the supremum of positive-state marginals. -/
theorem zeroRightMarginal_eq_sup_positive (m : HouseholdPrimitives) :
    zeroRightMarginal m = sSup ((fun z => ENNReal.ofReal (rightMarginalValue m z)) '' Ioi 0) := by
  apply le_antisymm
  · apply sSup_le
    rintro _ ⟨y,hy,rfl⟩
    have ht := ENNReal.continuous_ofReal.continuousAt.tendsto.comp (valueSlope_tendsto_left m hy)
    apply le_of_tendsto ht
    filter_upwards [self_mem_nhdsWithin, (eventually_lt_nhds hy).filter_mono nhdsWithin_le_nhds] with x hx hxy
    exact (ENNReal.ofReal_le_ofReal (secant_le_rightMarginalValue m hx hxy)).trans (le_sSup ⟨x,hx,rfl⟩)
  · apply sSup_le
    rintro _ ⟨z,hz,rfl⟩; exact rightMarginalValue_le_zeroRightMarginal m hz

theorem positiveMarginal_antitone (m : HouseholdPrimitives) :
    AntitoneOn (fun z => ENNReal.ofReal (rightMarginalValue m z)) (Ioi 0) :=
  fun _ hx _ hy hxy => ENNReal.ofReal_le_ofReal (rightMarginalValue_antitone m hx hy hxy)

/-- Positive-state marginal values increase to the extended boundary marginal as the state decreases. -/
theorem positiveMarginal_tendsto_zero (m : HouseholdPrimitives) :
    Tendsto (fun z => ENNReal.ofReal (rightMarginalValue m z)) (𝓝[>] 0)
      (𝓝 (zeroRightMarginal m)) := by
  rw [zeroRightMarginal_eq_sup_positive]
  exact (positiveMarginal_antitone m).tendsto_nhdsGT (OrderTop.bddAbove _)

/-- Exact criterion for an infinite boundary marginal, with no finiteness imposed. -/
theorem zeroRightMarginal_eq_top_iff (m : HouseholdPrimitives) :
    zeroRightMarginal m = ⊤ ↔ ∀ B : ENNReal, B < ⊤ →
      ∃ z : ℝ, 0 < z ∧ B < ENNReal.ofReal (rightMarginalValue m z) := by
  rw [zeroRightMarginal_eq_sup_positive,sSup_eq_top]
  simp only [mem_image,mem_Ioi,exists_exists_and_eq_and]

/-- Economic increment notation agrees exactly with the endpoint secant API. -/
theorem rightSecant_increment (m : HouseholdPrimitives) (z h : ℝ) :
    slope (valueExtension m) z (z+h) = (valueExtension m (z+h)-valueExtension m z)/h := by
  simp only [slope_def_field,add_sub_cancel_left]

theorem rightSecant_pos (m : HouseholdPrimitives) {z y : ℝ} (hz : 0 ≤ z) (hzy : z < y) :
    0 < slope (valueExtension m) z y := by
  rw [slope_def_field]
  exact div_pos (sub_pos.mpr (valueExtension_strictMono m hz (hz.trans hzy.le) hzy)) (sub_pos.mpr hzy)

/-- The real marginal is the finite supremum of the value's right secants. -/
theorem rightMarginalValue_eq_sSup_secants (m : HouseholdPrimitives) {z : ℝ} (hz : 0 < z) :
    rightMarginalValue m z = sSup (slope (valueExtension m) z '' Ioi z) := by
  have hb : BddAbove (slope (valueExtension m) z '' Ioi z) := ⟨rightMarginalValue m z,by
    rintro _ ⟨y,hy,rfl⟩; exact secant_le_rightMarginalValue m hz hy⟩
  exact tendsto_nhds_unique (rightMarginalValue_secant_limit m hz)
    ((rightSecant_antitone m hz.le).tendsto_nhdsGT hb)

theorem rightMarginalValue_finite (m : HouseholdPrimitives) (z : ℝ) :
    ENNReal.ofReal (rightMarginalValue m z) < ⊤ := ENNReal.ofReal_lt_top

theorem zeroRightMarginal_pos (m : HouseholdPrimitives) : 0 < zeroRightMarginal m := by
  have h : 0 < ENNReal.ofReal (rightMarginalValue m 1) :=
    ENNReal.ofReal_pos.mpr (rightMarginalValue_pos m (by norm_num))
  exact h.trans_le (rightMarginalValue_le_zeroRightMarginal m (by norm_num))

/-- H08: constructed secant limits, positivity, right continuity, bounds and extended boundary. -/
theorem rightMarginalValue_properties (m : HouseholdPrimitives) :
    (∀ z : ℝ, 0 < z →
      Tendsto (slope (valueExtension m) z) (𝓝[>] z) (𝓝 (rightMarginalValue m z)) ∧
      0 < rightMarginalValue m z ∧
      ContinuousWithinAt (rightMarginalValue m) (Ici z) z ∧
      rightMarginalValue m z ≤ (valueExtension m z-valueExtension m 0)/z ∧
      (valueExtension m z-valueExtension m 0)/z ≤ utilityOscillation m/((1-m.beta)*z)) ∧
    AntitoneOn (rightMarginalValue m) (Ioi 0) ∧
    Tendsto (fun y => ENNReal.ofReal (slope (valueExtension m) 0 y)) (𝓝[>] 0)
      (𝓝 (zeroRightMarginal m)) ∧
    Tendsto (fun z => ENNReal.ofReal (rightMarginalValue m z)) (𝓝[>] 0)
      (𝓝 (zeroRightMarginal m)) := by
  exact ⟨fun z hz => ⟨rightMarginalValue_secant_limit m hz,rightMarginalValue_pos m hz,
    rightMarginalValue_rightContinuous m hz,(rightMarginalValue_bounds m hz).1,
    (rightMarginalValue_bounds m hz).2⟩,rightMarginalValue_antitone m,
    zeroRightMarginal_secant_limit m,positiveMarginal_tendsto_zero m⟩

end
end Aiyagari1994
