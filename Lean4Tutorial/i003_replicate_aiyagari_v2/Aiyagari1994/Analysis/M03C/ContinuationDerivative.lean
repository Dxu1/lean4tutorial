import Aiyagari1994.Household.ConsumptionPositive
import Aiyagari1994.Household.Envelope
import Aiyagari1994.Household.MarginalInequality
import Mathlib.Analysis.Calculus.ParametricIntegral

/-! Differentiation of the expected continuation value away from the zero-resource boundary. -/
open MeasureTheory Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- At a strictly positive shifted-asset choice, all next resources have a common positive lower
bound.  The continuation derivative may therefore be passed through the integral.  The theorem
also proves integrability of the resulting conditional marginal utility before exposing the real
integral. -/
theorem continuationValue_hasDerivAt_of_asset_pos
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (a : Resources) (ha : 0 < a) :
    Integrable (fun l : m.income.Labor =>
      deriv m.utility.utility
        (consumptionPolicy m (m.prices.nextResources a l) : ℝ))
      (m.income.law : Measure m.income.Labor) ∧
    HasDerivAt
      (fun x : ℝ => ∫ l : m.income.Labor,
        valueExtension m
          (m.prices.grossReturn * x + m.prices.effectiveIncome l)
        ∂(m.income.law : Measure m.income.Labor))
      (m.prices.grossReturn * ∫ l : m.income.Labor,
        deriv m.utility.utility
          (consumptionPolicy m (m.prices.nextResources a l) : ℝ)
        ∂(m.income.law : Measure m.income.Labor)) (a : ℝ) := by
  let F : ℝ → m.income.Labor → ℝ := fun x l =>
    valueExtension m (m.prices.grossReturn * x + m.prices.effectiveIncome l)
  let F' : ℝ → m.income.Labor → ℝ := fun x l =>
    (extendedRightMarginalValue m
      (m.prices.grossReturn * x + m.prices.effectiveIncome l).toNNReal).toReal *
        m.prices.grossReturn
  let lower : ℝ := m.prices.grossReturn * ((a : ℝ) / 2)
  let bound : m.income.Labor → ℝ := fun _ =>
    m.prices.grossReturn * rightMarginalValue m lower
  have haReal : 0 < (a : ℝ) := by exact_mod_cast ha
  have hlower : 0 < lower := mul_pos m.prices.grossReturn_pos (half_pos haReal)
  have hs : Ioi ((a : ℝ) / 2) ∈ 𝓝 (a : ℝ) := Ioi_mem_nhds (half_lt_self haReal)
  have hFmeas : ∀ᶠ x in 𝓝 (a : ℝ),
      AEStronglyMeasurable (F x) (m.income.law : Measure m.income.Labor) := by
    filter_upwards [] with x
    have he : Continuous (fun l : m.income.Labor => m.prices.effectiveIncome l) := by
      unfold NormalizedPrices.effectiveIncome
      fun_prop
    exact ((valueExtension_continuous m).comp (continuous_const.add he)).aestronglyMeasurable
  have hFint : Integrable (F (a : ℝ))
      (m.income.law : Measure m.income.Labor) := by
    apply Continuous.integrable_of_hasCompactSupport
    · have he : Continuous (fun l : m.income.Labor => m.prices.effectiveIncome l) := by
        unfold NormalizedPrices.effectiveIncome
        fun_prop
      exact (valueExtension_continuous m).comp (continuous_const.add he)
    · exact HasCompactSupport.of_compactSpace _
  have hF'meas : AEStronglyMeasurable (F' (a : ℝ))
      (m.income.law : Measure m.income.Labor) := by
    have hn : Continuous (fun l : m.income.Labor =>
        m.prices.nextResources a l) :=
      (nextResources_continuous m).comp (continuous_const.prodMk continuous_id)
    have heq : F' (a : ℝ) = fun l : m.income.Labor =>
        (extendedRightMarginalValue m (m.prices.nextResources a l)).toReal *
          m.prices.grossReturn := by
      funext l
      dsimp [F']
      congr 2
      apply congrArg (extendedRightMarginalValue m)
      apply NNReal.eq
      change max (m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l) 0 =
        m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l
      exact max_eq_left (add_nonneg
        (mul_nonneg m.prices.grossReturn_pos.le a.property) (m.prices.income_nonneg l))
    rw [heq]
    exact (((extendedRightMarginalValue_measurable m).comp hn.measurable).ennreal_toReal.mul
      measurable_const).aestronglyMeasurable
  have hbound : ∀ᵐ l ∂(m.income.law : Measure m.income.Labor),
      ∀ x ∈ Ioi ((a : ℝ) / 2), ‖F' x l‖ ≤ bound l := by
    filter_upwards [] with l x hx
    have hy : 0 < m.prices.grossReturn * x + m.prices.effectiveIncome l :=
      add_pos_of_pos_of_nonneg
        (mul_pos m.prices.grossReturn_pos (half_pos haReal |>.trans hx))
        (m.prices.income_nonneg l)
    have hto : ((m.prices.grossReturn * x + m.prices.effectiveIncome l).toNNReal : ℝ) =
        m.prices.grossReturn * x + m.prices.effectiveIncome l := by
      simp [Real.toNNReal_of_nonneg hy.le]
    have hext : (extendedRightMarginalValue m
        (m.prices.grossReturn * x + m.prices.effectiveIncome l).toNNReal).toReal =
        rightMarginalValue m (m.prices.grossReturn * x + m.prices.effectiveIncome l) := by
      rw [extendedRightMarginalValue_of_pos m (Real.toNNReal_pos.mpr hy)]
      rw [ENNReal.toReal_ofReal (rightMarginalValue_pos m (by simpa [hto] using hy)).le, hto]
    have hlow : lower ≤ m.prices.grossReturn * x + m.prices.effectiveIncome l := by
      dsimp [lower]
      exact (mul_le_mul_of_nonneg_left hx.le m.prices.grossReturn_pos.le).trans
        (le_add_of_nonneg_right (m.prices.income_nonneg l))
    have hq := rightMarginalValue_antitone m hlower hy hlow
    dsimp [F', bound]
    rw [hext,
      abs_of_pos (mul_pos (rightMarginalValue_pos m hy) m.prices.grossReturn_pos)]
    simpa [mul_comm] using mul_le_mul_of_nonneg_right hq m.prices.grossReturn_pos.le
  have hboundInt : Integrable bound (m.income.law : Measure m.income.Labor) :=
    integrable_const _
  have hdiff : ∀ᵐ l ∂(m.income.law : Measure m.income.Labor),
      ∀ x ∈ Ioi ((a : ℝ) / 2), HasDerivAt (F · l) (F' x l) x := by
    filter_upwards [] with l x hx
    have hy : 0 < m.prices.grossReturn * x + m.prices.effectiveIncome l :=
      add_pos_of_pos_of_nonneg
        (mul_pos m.prices.grossReturn_pos (half_pos haReal |>.trans hx))
        (m.prices.income_nonneg l)
    let y : Resources :=
      ⟨m.prices.grossReturn * x + m.prices.effectiveIncome l, hy.le⟩
    have hyPos : 0 < y := by exact_mod_cast hy
    have hc := consumption_positive_subcritical m hsmooth hbetaR y hyPos
    have hv := (value_envelope_at_positive_consumption m hsmooth y hyPos hc).1
    have harg : HasDerivAt
        (fun t : ℝ => m.prices.grossReturn * t + m.prices.effectiveIncome l)
        m.prices.grossReturn x :=
      by simpa [mul_comm] using (((hasDerivAt_id x).mul_const m.prices.grossReturn).add_const
        (m.prices.effectiveIncome l))
    have hcoe : (y : ℝ) = m.prices.grossReturn * x + m.prices.effectiveIncome l := rfl
    have hq : rightMarginalValue m (y : ℝ) =
        deriv m.utility.utility (consumptionPolicy m y : ℝ) :=
      (value_envelope_at_positive_consumption m hsmooth y hyPos hc).2
    have hext : (extendedRightMarginalValue m
        (m.prices.grossReturn * x + m.prices.effectiveIncome l).toNNReal).toReal =
        rightMarginalValue m (y : ℝ) := by
      have hto : (m.prices.grossReturn * x + m.prices.effectiveIncome l).toNNReal = y := by
        apply NNReal.eq
        simpa [Real.toNNReal_of_nonneg hy.le]
      rw [hto, extendedRightMarginalValue_of_pos m hyPos,
        ENNReal.toReal_ofReal (rightMarginalValue_pos m (by simpa [hcoe] using hy)).le]
    have hgLeft : Tendsto
        (fun t : ℝ => m.prices.grossReturn * t + m.prices.effectiveIncome l)
        (𝓝[<] x) (𝓝[<] (y : ℝ)) := by
      rw [tendsto_nhdsWithin_iff]
      constructor
      · exact harg.continuousAt.tendsto.mono_left nhdsWithin_le_nhds
      · filter_upwards [self_mem_nhdsWithin] with t ht
        change m.prices.grossReturn * t + m.prices.effectiveIncome l < (y : ℝ)
        rw [hcoe]
        simpa [add_comm] using add_lt_add_right
          (mul_lt_mul_of_pos_left (show t < x from ht) m.prices.grossReturn_pos)
          (m.prices.effectiveIncome l)
    have hgRight : Tendsto
        (fun t : ℝ => m.prices.grossReturn * t + m.prices.effectiveIncome l)
        (𝓝[>] x) (𝓝[>] (y : ℝ)) := by
      rw [tendsto_nhdsWithin_iff]
      constructor
      · exact harg.continuousAt.tendsto.mono_left nhdsWithin_le_nhds
      · filter_upwards [self_mem_nhdsWithin] with t ht
        change (y : ℝ) < m.prices.grossReturn * t + m.prices.effectiveIncome l
        rw [hcoe]
        simpa [add_comm] using add_lt_add_right
          (mul_lt_mul_of_pos_left (show x < t from ht) m.prices.grossReturn_pos)
          (m.prices.effectiveIncome l)
    have hvSlope := hasDerivAt_iff_tendsto_slope_left_right.mp hv
    dsimp [F']
    rw [hext, hq, hasDerivAt_iff_tendsto_slope_left_right]
    constructor
    · have ht := (hvSlope.1.comp hgLeft).mul_const m.prices.grossReturn
      apply ht.congr'
      filter_upwards [self_mem_nhdsWithin] with t htne
      change slope (valueExtension m) (y : ℝ)
          (m.prices.grossReturn * t + m.prices.effectiveIncome l) *
            m.prices.grossReturn = slope (fun x => F x l) x t
      dsimp [F, y]
      rw [slope_def_field, slope_def_field]
      rw [hcoe]
      have htx : t - x ≠ 0 := sub_ne_zero.mpr (ne_of_lt (show t < x from htne))
      have hR : m.prices.grossReturn ≠ 0 := ne_of_gt m.prices.grossReturn_pos
      have hden : (m.prices.grossReturn * t + m.prices.effectiveIncome l) -
          (m.prices.grossReturn * x + m.prices.effectiveIncome l) =
          m.prices.grossReturn * (t - x) := by ring
      rw [hden]
      field_simp [htx, hR]
    · have ht := (hvSlope.2.comp hgRight).mul_const m.prices.grossReturn
      apply ht.congr'
      filter_upwards [self_mem_nhdsWithin] with t htne
      change slope (valueExtension m) (y : ℝ)
          (m.prices.grossReturn * t + m.prices.effectiveIncome l) *
            m.prices.grossReturn = slope (fun x => F x l) x t
      dsimp [F, y]
      rw [slope_def_field, slope_def_field]
      rw [hcoe]
      have htx : t - x ≠ 0 := sub_ne_zero.mpr (ne_of_gt (show x < t from htne))
      have hR : m.prices.grossReturn ≠ 0 := ne_of_gt m.prices.grossReturn_pos
      have hden : (m.prices.grossReturn * t + m.prices.effectiveIncome l) -
          (m.prices.grossReturn * x + m.prices.effectiveIncome l) =
          m.prices.grossReturn * (t - x) := by ring
      rw [hden]
      field_simp [htx, hR]
  obtain ⟨hF'int, hderiv⟩ := hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (𝕜 := ℝ) hs hFmeas hFint hF'meas hbound hboundInt hdiff
  have hpoint : ∀ l : m.income.Labor, F' (a : ℝ) l =
      deriv m.utility.utility
        (consumptionPolicy m (m.prices.nextResources a l) : ℝ) *
          m.prices.grossReturn := by
    intro l
    have hnpos : 0 < m.prices.nextResources a l := by
      change 0 < m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l
      exact add_pos_of_pos_of_nonneg (mul_pos m.prices.grossReturn_pos haReal)
        (m.prices.income_nonneg l)
    have hc := consumption_positive_subcritical m hsmooth hbetaR _ hnpos
    have henv := (value_envelope_at_positive_consumption m hsmooth _ hnpos hc).2
    dsimp [F']
    have hto : (m.prices.grossReturn * (a : ℝ) +
        m.prices.effectiveIncome l).toNNReal = m.prices.nextResources a l := by
      apply NNReal.eq
      change max (m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l) 0 =
        m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l
      exact max_eq_left (add_nonneg
        (mul_nonneg m.prices.grossReturn_pos.le a.property) (m.prices.income_nonneg l))
    rw [hto, extendedRightMarginalValue_of_pos m hnpos,
      ENNReal.toReal_ofReal (rightMarginalValue_pos m (by exact_mod_cast hnpos)).le,
      henv]
  have hmargInt : Integrable (fun l : m.income.Labor =>
      deriv m.utility.utility
        (consumptionPolicy m (m.prices.nextResources a l) : ℝ))
      (m.income.law : Measure m.income.Labor) := by
    have hRne : m.prices.grossReturn ≠ 0 := ne_of_gt m.prices.grossReturn_pos
    have hscaled : Integrable (fun l : m.income.Labor =>
        deriv m.utility.utility
          (consumptionPolicy m (m.prices.nextResources a l) : ℝ) *
            m.prices.grossReturn)
        (m.income.law : Measure m.income.Labor) := by
      exact hF'int.congr (Eventually.of_forall hpoint)
    have hinv := hscaled.const_mul m.prices.grossReturn⁻¹
    convert hinv using 1
    funext l
    field_simp
  refine ⟨hmargInt, ?_⟩
  have hint : ∫ l : m.income.Labor, F' (a : ℝ) l
        ∂(m.income.law : Measure m.income.Labor) =
      m.prices.grossReturn * ∫ l : m.income.Labor,
        deriv m.utility.utility
          (consumptionPolicy m (m.prices.nextResources a l) : ℝ)
        ∂(m.income.law : Measure m.income.Labor) := by
    rw [integral_congr_ae (Eventually.of_forall hpoint), integral_mul_const]
    ring
  simpa [F, hint] using hderiv

end
end Aiyagari1994
