import Aiyagari1994.Analysis.M03B3.LowerTouching
import Aiyagari1994.Household.Policy
import Aiyagari1994.Household.RightMarginal

/-! H11: the local envelope identity at a positive-consumption state. -/
open Set Filter
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

private def envelopeTouchingFunction
    (m : HouseholdPrimitives) (z : Resources) (x : ℝ) : ℝ :=
  m.utility.utility (x - (assetPolicy m z : ℝ)) +
    m.beta * continuation m (valueFunction m) (assetPolicy m z)

private theorem envelopeTouchingFunction_hasDerivAt
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (z : Resources) (hc : 0 < consumptionPolicy m z) :
    HasDerivAt (envelopeTouchingFunction m z)
      (deriv m.utility.utility (consumptionPolicy m z : ℝ)) (z : ℝ) := by
  have hcReal : 0 < (consumptionPolicy m z : ℝ) := by exact_mod_cast hc
  have huWithin := hsmooth.smooth.differentiableOn_one
    (consumptionPolicy m z : ℝ) hcReal
  have hu : HasDerivAt m.utility.utility
      (deriv m.utility.utility (consumptionPolicy m z : ℝ))
      (consumptionPolicy m z : ℝ) :=
    (huWithin.differentiableAt (isOpen_Ioi.mem_nhds hcReal)).hasDerivAt
  have harg : HasDerivAt (fun x : ℝ ↦ x - (assetPolicy m z : ℝ)) 1 (z : ℝ) :=
    (hasDerivAt_id (z : ℝ)).sub_const _
  have hcEq : (z : ℝ) - (assetPolicy m z : ℝ) =
      (consumptionPolicy m z : ℝ) := (consumptionPolicy_coe m z).symm
  have huAt : HasDerivAt m.utility.utility
      (deriv m.utility.utility (consumptionPolicy m z : ℝ))
      ((z : ℝ) - (assetPolicy m z : ℝ)) := by
    rw [hcEq]
    exact hu
  unfold envelopeTouchingFunction
  simpa only [Function.comp_apply, mul_one] using (huAt.comp (z : ℝ) harg).add_const
    (m.beta * continuation m (valueFunction m) (assetPolicy m z))

private theorem envelopeTouchingFunction_eq_value
    (m : HouseholdPrimitives) (z : Resources) :
    envelopeTouchingFunction m z (z : ℝ) = valueExtension m (z : ℝ) := by
  rw [envelopeTouchingFunction]
  have h := (assetPolicy_optimal m z).2
  rw [bellmanObjective_feasible m _ z (assetPolicy m z) (assetPolicy_le_state m z)] at h
  simpa [valueExtension, nonnegativeExtension] using h

private theorem envelopeTouchingFunction_eventually_le_value
    (m : HouseholdPrimitives) (z : Resources) (hc : 0 < consumptionPolicy m z) :
    ∀ᶠ x : ℝ in nhds (z : ℝ), envelopeTouchingFunction m z x ≤ valueExtension m x := by
  have ha : (assetPolicy m z : ℝ) < (z : ℝ) := by
    apply sub_pos.mp
    rw [← consumptionPolicy_coe m z]
    exact_mod_cast hc
  filter_upwards [Ioi_mem_nhds ha] with x hx
  let xr : Resources := ⟨x, (show 0 ≤ x from
    (show 0 ≤ (assetPolicy m z : ℝ) from (assetPolicy m z).property).trans hx.le)⟩
  have hfeas : assetPolicy m z ≤ xr := by exact_mod_cast hx.le
  have hmax := assetPolicy_maximizes m xr (assetPolicy m z) hfeas
  rw [(assetPolicy_optimal m xr).2] at hmax
  rw [bellmanObjective_feasible m _ xr (assetPolicy m z) hfeas] at hmax
  change envelopeTouchingFunction m z x ≤ valueFunction m xr at hmax
  have hxTo : x.toNNReal = xr := by
    apply NNReal.eq
    change max x 0 = x
    exact max_eq_left xr.property
  rw [valueExtension, nonnegativeExtension, hxTo]
  exact hmax

/-- H11: at every positive state with positive optimal consumption, the value extension is
differentiable and its derivative equals current marginal utility.  No impatience condition is
used. -/
theorem value_envelope_at_positive_consumption
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (z : Resources) (hz : 0 < z) (hc : 0 < consumptionPolicy m z) :
    HasDerivAt (valueExtension m)
      (deriv m.utility.utility (consumptionPolicy m z : ℝ)) (z : ℝ) ∧
    rightMarginalValue m (z : ℝ) =
      deriv m.utility.utility (consumptionPolicy m z : ℝ) := by
  have hderiv := concave_hasDerivAt_of_lowerTouching
    (valueExtension_concave m)
    (show (z : ℝ) ∈ interior (Ici (0 : ℝ)) by simpa using hz)
    (envelopeTouchingFunction_hasDerivAt m hsmooth z hc)
    (envelopeTouchingFunction_eq_value m z)
    (envelopeTouchingFunction_eventually_le_value m z hc)
  refine ⟨hderiv, ?_⟩
  exact tendsto_nhds_unique (rightMarginalValue_secant_limit m
      (show 0 < (z : ℝ) by exact_mod_cast hz))
    (hasDerivAt_iff_tendsto_slope_left_right.mp hderiv).2

end
end Aiyagari1994
