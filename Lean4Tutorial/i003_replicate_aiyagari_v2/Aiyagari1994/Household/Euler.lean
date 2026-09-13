import Aiyagari1994.Analysis.M03C.ContinuationDerivative
import Mathlib.Analysis.Calculus.LocalExtr.Basic

/-! H12: Euler inequality and interior equality in the subcritical household problem. -/
open MeasureTheory Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- The marginal entering H12's conditional expectation.  At positive next resources it is
current marginal utility.  At zero it is the separate extended value marginal, which may be
infinite; `rightMarginalValue m 0` and a default-valued real derivative are never substituted. -/
def eulerNextMarginal (m : HouseholdPrimitives) (z : Resources) : ENNReal :=
  if z = 0 then zeroRightMarginal m
  else ENNReal.ofReal (deriv m.utility.utility (consumptionPolicy m z : ℝ))

@[simp] theorem eulerNextMarginal_zero (m : HouseholdPrimitives) :
    eulerNextMarginal m 0 = zeroRightMarginal m := by
  simp [eulerNextMarginal]

theorem eulerNextMarginal_of_pos (m : HouseholdPrimitives) {z : Resources} (hz : 0 < z) :
    eulerNextMarginal m z =
      ENNReal.ofReal (deriv m.utility.utility (consumptionPolicy m z : ℝ)) := by
  simp [eulerNextMarginal, ne_of_gt hz]

/-- Under subcritical positive-consumption and the envelope theorem, the explicit H12 marginal
agrees everywhere with H09's extended value marginal, including their common explicit value at
zero. -/
theorem eulerNextMarginal_eq_extendedRightMarginalValue
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1) (z : Resources) :
    eulerNextMarginal m z = extendedRightMarginalValue m z := by
  by_cases hz : z = 0
  · subst z
    simp
  · have hzPos : 0 < z := pos_iff_ne_zero.mpr hz
    have hc := consumption_positive_subcritical m hsmooth hbetaR z hzPos
    have henv := (value_envelope_at_positive_consumption m hsmooth z hzPos hc).2
    rw [eulerNextMarginal_of_pos m hzPos, extendedRightMarginalValue_of_pos m hzPos, henv]

private def realBellmanObjective
    (m : HouseholdPrimitives) (z : Resources) (a : ℝ) : ℝ :=
  m.utility.utility ((z : ℝ) - a) +
    m.beta * ∫ l : m.income.Labor,
      valueExtension m (m.prices.grossReturn * a + m.prices.effectiveIncome l)
      ∂(m.income.law : Measure m.income.Labor)

private theorem realBellmanObjective_isLocalMax_at_policy
    (m : HouseholdPrimitives) (z : Resources)
    (ha : 0 < assetPolicy m z) (hc : 0 < consumptionPolicy m z) :
    IsLocalMax (realBellmanObjective m z) (assetPolicy m z : ℝ) := by
  have haReal : 0 < (assetPolicy m z : ℝ) := by exact_mod_cast ha
  have haz : (assetPolicy m z : ℝ) < (z : ℝ) := by
    apply sub_pos.mp
    rw [← consumptionPolicy_coe m z]
    exact_mod_cast hc
  filter_upwards [Ioo_mem_nhds haReal haz] with x hx
  let ax : Resources := ⟨x, hx.1.le⟩
  have hax : ax ≤ z := by exact_mod_cast hx.2.le
  have hmax := assetPolicy_maximizes m z ax hax
  rw [bellmanObjective_feasible m _ z ax hax,
    bellmanObjective_feasible m _ z (assetPolicy m z) (assetPolicy_le_state m z)] at hmax
  have hcontx : continuation m (valueFunction m) ax =
      ∫ l : m.income.Labor,
        valueExtension m (m.prices.grossReturn * x + m.prices.effectiveIncome l)
        ∂(m.income.law : Measure m.income.Labor) := by
    unfold continuation
    apply integral_congr_ae
    filter_upwards [] with l
    change valueFunction m (m.prices.nextResources ax l) =
      valueFunction m
        (m.prices.grossReturn * x + m.prices.effectiveIncome l).toNNReal
    congr 1
    apply NNReal.eq
    change m.prices.grossReturn * x + m.prices.effectiveIncome l =
      max (m.prices.grossReturn * x + m.prices.effectiveIncome l) 0
    symm
    exact max_eq_left (add_nonneg (mul_nonneg m.prices.grossReturn_pos.le hx.1.le)
      (m.prices.income_nonneg l))
  have hconta : continuation m (valueFunction m) (assetPolicy m z) =
      ∫ l : m.income.Labor,
        valueExtension m
          (m.prices.grossReturn * (assetPolicy m z : ℝ) + m.prices.effectiveIncome l)
        ∂(m.income.law : Measure m.income.Labor) := by
    unfold continuation
    apply integral_congr_ae
    filter_upwards [] with l
    change valueFunction m (m.prices.nextResources (assetPolicy m z) l) =
      valueFunction m
        (m.prices.grossReturn * (assetPolicy m z : ℝ) +
          m.prices.effectiveIncome l).toNNReal
    congr 1
    apply NNReal.eq
    change m.prices.grossReturn * (assetPolicy m z : ℝ) + m.prices.effectiveIncome l =
      max (m.prices.grossReturn * (assetPolicy m z : ℝ) +
        m.prices.effectiveIncome l) 0
    symm
    exact max_eq_left (add_nonneg
      (mul_nonneg m.prices.grossReturn_pos.le (assetPolicy m z).property)
      (m.prices.income_nonneg l))
  dsimp [realBellmanObjective]
  rw [← hcontx, ← hconta]
  change m.utility.utility ((z : ℝ) - x) + m.beta * continuation m (valueFunction m) ax ≤
    m.utility.utility ((z : ℝ) - (assetPolicy m z : ℝ)) +
      m.beta * continuation m (valueFunction m) (assetPolicy m z)
  have haxcoe : (ax : ℝ) = x := rfl
  rw [haxcoe] at hmax
  linarith only [hmax]

private theorem interior_euler_equality
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (z : Resources) (hz : 0 < z) (ha : 0 < assetPolicy m z) :
    Integrable (fun l : m.income.Labor =>
      deriv m.utility.utility
        (consumptionPolicy m (m.prices.nextResources (assetPolicy m z) l) : ℝ))
      (m.income.law : Measure m.income.Labor) ∧
    m.beta * m.prices.grossReturn * ∫ l : m.income.Labor,
        deriv m.utility.utility
          (consumptionPolicy m
            (m.prices.nextResources (assetPolicy m z) l) : ℝ)
        ∂(m.income.law : Measure m.income.Labor) =
      deriv m.utility.utility (consumptionPolicy m z : ℝ) := by
  have hc := consumption_positive_subcritical m hsmooth hbetaR z hz
  obtain ⟨hint, hcont⟩ := continuationValue_hasDerivAt_of_asset_pos
    m hsmooth hbetaR (assetPolicy m z) ha
  have hcReal : 0 < (consumptionPolicy m z : ℝ) := by exact_mod_cast hc
  have hu : HasDerivAt m.utility.utility
      (deriv m.utility.utility (consumptionPolicy m z : ℝ))
      (consumptionPolicy m z : ℝ) :=
    ((hsmooth.smooth.differentiableOn_one _ hcReal).differentiableAt
      (isOpen_Ioi.mem_nhds hcReal)).hasDerivAt
  have hcur : (z : ℝ) - (assetPolicy m z : ℝ) =
      (consumptionPolicy m z : ℝ) := (consumptionPolicy_coe m z).symm
  rw [← hcur] at hu
  have harg := ((hasDerivAt_id (assetPolicy m z : ℝ)).sub_const (z : ℝ)).neg
  have harg' : HasDerivAt (fun x : ℝ => (z : ℝ) - x) (-1)
      (assetPolicy m z : ℝ) := harg.congr_of_eventuallyEq
    (Eventually.of_forall fun x : ℝ => by simp)
  have hutility := hu.comp (assetPolicy m z : ℝ) harg'
  have hobj := hutility.add (hcont.const_mul m.beta)
  have hlocal : IsLocalMax
      (m.utility.utility ∘ (fun x : ℝ => (z : ℝ) - x) +
        fun x : ℝ => m.beta * ∫ l : m.income.Labor,
          valueExtension m (m.prices.grossReturn * x + m.prices.effectiveIncome l)
          ∂(m.income.law : Measure m.income.Labor))
      (assetPolicy m z : ℝ) := by
    convert (realBellmanObjective_isLocalMax_at_policy m z ha hc) using 1
    funext x
    rfl
  have hzero := hlocal.hasDerivAt_eq_zero hobj
  rw [hcur] at hzero
  refine ⟨hint, ?_⟩
  nlinarith

/-- H12: at every positive state under `beta * R < 1`, current marginal utility dominates
the conditionally integrable expected next marginal.  The next marginal is explicitly
`zeroRightMarginal` at zero resources.  If shifted savings are positive, all next resources are
positive, the ordinary marginal-utility integrand is integrable, and the Euler condition is an
equality. -/
theorem euler_subcritical
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (z : Resources) (hz : 0 < z) :
    (∀ᵐ l ∂(m.income.law : Measure m.income.Labor),
      eulerNextMarginal m
        (m.prices.nextResources (assetPolicy m z) l) < ⊤) ∧
    Integrable (fun l : m.income.Labor =>
      (eulerNextMarginal m
        (m.prices.nextResources (assetPolicy m z) l)).toReal)
      (m.income.law : Measure m.income.Labor) ∧
    m.beta * m.prices.grossReturn * ∫ l : m.income.Labor,
        (eulerNextMarginal m
          (m.prices.nextResources (assetPolicy m z) l)).toReal
        ∂(m.income.law : Measure m.income.Labor) ≤
      deriv m.utility.utility (consumptionPolicy m z : ℝ) ∧
    (0 < assetPolicy m z →
      Integrable (fun l : m.income.Labor =>
        deriv m.utility.utility
          (consumptionPolicy m
            (m.prices.nextResources (assetPolicy m z) l) : ℝ))
        (m.income.law : Measure m.income.Labor) ∧
      (∀ l : m.income.Labor,
        eulerNextMarginal m
            (m.prices.nextResources (assetPolicy m z) l) =
          ENNReal.ofReal (deriv m.utility.utility
            (consumptionPolicy m
              (m.prices.nextResources (assetPolicy m z) l) : ℝ))) ∧
      m.beta * m.prices.grossReturn * ∫ l : m.income.Labor,
          deriv m.utility.utility
            (consumptionPolicy m
              (m.prices.nextResources (assetPolicy m z) l) : ℝ)
          ∂(m.income.law : Measure m.income.Labor) =
        deriv m.utility.utility (consumptionPolicy m z : ℝ)) := by
  have hc := consumption_positive_subcritical m hsmooth hbetaR z hz
  have hzext : extendedRightMarginalValue m z < ⊤ := by
    rw [extendedRightMarginalValue_of_pos m hz]
    exact ENNReal.ofReal_lt_top
  obtain ⟨hae, hint, hineq⟩ := rightMarginalValue_superharmonic m z hzext
  have heq (x : Resources) : eulerNextMarginal m x = extendedRightMarginalValue m x :=
    eulerNextMarginal_eq_extendedRightMarginalValue m hsmooth hbetaR x
  have henv := (value_envelope_at_positive_consumption m hsmooth z hz hc).2
  have hcurrent : (extendedRightMarginalValue m z).toReal =
      deriv m.utility.utility (consumptionPolicy m z : ℝ) := by
    rw [extendedRightMarginalValue_of_pos m hz,
      ENNReal.toReal_ofReal (rightMarginalValue_pos m (by exact_mod_cast hz)).le, henv]
  refine ⟨?_, ?_, ?_, ?_⟩
  · simpa only [heq] using hae
  · exact hint.congr (Eventually.of_forall fun l =>
      congrArg ENNReal.toReal (heq _).symm)
  · rw [← hcurrent]
    simpa only [heq] using hineq
  · intro ha
    obtain ⟨hmarg, heuler⟩ := interior_euler_equality m hsmooth hbetaR z hz ha
    refine ⟨hmarg, ?_, heuler⟩
    intro l
    have hn : 0 < m.prices.nextResources (assetPolicy m z) l := by
      change 0 < m.prices.grossReturn * (assetPolicy m z : ℝ) +
        m.prices.effectiveIncome l
      exact add_pos_of_pos_of_nonneg
        (mul_pos m.prices.grossReturn_pos (by exact_mod_cast ha))
        (m.prices.income_nonneg l)
    exact eulerNextMarginal_of_pos m hn

end
end Aiyagari1994
