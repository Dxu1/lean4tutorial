import Aiyagari1994.Analysis.M03B1.MonotoneSecants
import Aiyagari1994.Household.Policy
import Mathlib.MeasureTheory.Integral.Lebesgue.Markov

/-! H09: the right marginal of value is superharmonic under the optimal transition. -/
open MeasureTheory Set Filter
open scoped NNReal Topology ENNReal
namespace Aiyagari1994
noncomputable section

@[simp] private theorem valueExtension_coe (m : HouseholdPrimitives) (z : Resources) :
    valueExtension m (z : ℝ) = valueFunction m z := by
  simp [valueExtension, nonnegativeExtension]

/-- Economic right marginal on the whole nonnegative state space.  At zero this uses the
separate extended boundary marginal and can therefore equal infinity. -/
def extendedRightMarginalValue (m : HouseholdPrimitives) (z : Resources) : ENNReal :=
  if z = 0 then zeroRightMarginal m else ENNReal.ofReal (rightMarginalValue m (z : ℝ))

@[simp] theorem extendedRightMarginalValue_zero (m : HouseholdPrimitives) :
    extendedRightMarginalValue m 0 = zeroRightMarginal m := by
  simp [extendedRightMarginalValue]

theorem extendedRightMarginalValue_of_pos (m : HouseholdPrimitives) {z : Resources}
    (hz : 0 < z) :
    extendedRightMarginalValue m z = ENNReal.ofReal (rightMarginalValue m (z : ℝ)) := by
  simp [extendedRightMarginalValue, ne_of_gt hz]

/-- Extended nonnegative secant approximating the economic right marginal. -/
private def marginalSecantApprox (m : HouseholdPrimitives) (n : ℕ) (z : Resources) : ENNReal :=
  ENNReal.ofReal
    (slope (valueExtension m) (z : ℝ)
      ((z : ℝ) + m.prices.grossReturn * marginalStep n))

private theorem marginalSecantApprox_measurable (m : HouseholdPrimitives) (n : ℕ) :
    Measurable (marginalSecantApprox m n) := by
  apply ENNReal.continuous_ofReal.measurable.comp
  simp only [slope_def_field, add_sub_cancel_left]
  change Measurable (fun z : Resources =>
    (valueExtension m ((z : ℝ) + m.prices.grossReturn * marginalStep n) -
      valueExtension m (z : ℝ)) / (m.prices.grossReturn * marginalStep n))
  exact (((valueExtension_continuous m).comp
      (continuous_subtype_val.add continuous_const)).sub
      ((valueExtension_continuous m).comp continuous_subtype_val)).div_const _ |>.measurable

private theorem marginalSecantApprox_monotone (m : HouseholdPrimitives) :
    Monotone (marginalSecantApprox m) := by
  intro n k hnk z
  apply ENNReal.ofReal_le_ofReal
  apply rightSecant_antitone m (show 0 ≤ (z : ℝ) from z.property)
  · exact lt_add_of_pos_right _ (mul_pos m.prices.grossReturn_pos (marginalStep_pos k))
  · exact lt_add_of_pos_right _ (mul_pos m.prices.grossReturn_pos (marginalStep_pos n))
  · simpa [add_comm] using add_le_add_left
      (mul_le_mul_of_nonneg_left (marginalStep_antitone hnk) m.prices.grossReturn_pos.le) (z : ℝ)

private theorem marginalSecantApprox_tendsto (m : HouseholdPrimitives) (z : Resources) :
    Tendsto (fun n => marginalSecantApprox m n z) atTop
      (nhds (extendedRightMarginalValue m z)) := by
  by_cases hz : z = 0
  · subst z
    simpa [marginalSecantApprox, Function.comp_def] using
      (zeroRightMarginal_secant_limit m).comp
        (tendsto_add_marginalStep_right 0 m.prices.grossReturn m.prices.grossReturn_pos)
  · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr hz)]
    exact (ENNReal.continuous_ofReal.continuousAt.tendsto.comp
      (rightMarginalValue_secant_limit m (show 0 < (z : ℝ) by exact_mod_cast
        (pos_iff_ne_zero.mpr hz)))).comp
        (tendsto_add_marginalStep_right (z : ℝ) m.prices.grossReturn
          m.prices.grossReturn_pos)

theorem extendedRightMarginalValue_measurable (m : HouseholdPrimitives) :
    Measurable (extendedRightMarginalValue m) := by
  exact measurable_of_tendsto_metrizable (fun n => marginalSecantApprox_measurable m n)
    (tendsto_pi_nhds.2 fun z => marginalSecantApprox_tendsto m z)

/-- Bellman comparison obtained by preserving current consumption and saving an extra `h`. -/
theorem value_extraSaving_comparison (m : HouseholdPrimitives) (z : Resources) {h : ℝ}
    (hh : 0 < h) :
    valueExtension m ((z : ℝ) + h) - valueExtension m z ≥
      m.beta * ∫ l : m.income.Labor,
        (valueExtension m
            ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
              m.prices.grossReturn * h) -
          valueExtension m (m.prices.nextResources (assetPolicy m z) l : ℝ))
        ∂(m.income.law : Measure m.income.Labor) := by
  let zh : Resources := ⟨(z : ℝ) + h, add_nonneg z.property hh.le⟩
  let ah : Resources :=
    ⟨(assetPolicy m z : ℝ) + h, add_nonneg (assetPolicy m z).property hh.le⟩
  have hah : ah ≤ zh := by
    change (assetPolicy m z : ℝ) + h ≤ (z : ℝ) + h
    simpa [add_comm] using add_le_add_right
      (show (assetPolicy m z : ℝ) ≤ (z : ℝ) from assetPolicy_le_state m z) h
  have hmax := assetPolicy_maximizes m zh ah hah
  rw [(assetPolicy_optimal m zh).2] at hmax
  have hcur : (zh : ℝ) - (ah : ℝ) = (z : ℝ) - (assetPolicy m z : ℝ) := by
    change ((z : ℝ) + h) - ((assetPolicy m z : ℝ) + h) = _
    ring
  rw [bellmanObjective_feasible m _ zh ah hah, hcur] at hmax
  have hvz := (assetPolicy_optimal m z).2
  rw [bellmanObjective_feasible m _ z (assetPolicy m z) (assetPolicy_le_state m z)] at hvz
  have hcont : continuation m (valueFunction m) ah - continuation m (valueFunction m) (assetPolicy m z) =
      ∫ l : m.income.Labor,
        (valueExtension m
            ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
              m.prices.grossReturn * h) -
          valueExtension m (m.prices.nextResources (assetPolicy m z) l : ℝ))
        ∂(m.income.law : Measure m.income.Labor) := by
    rw [continuation, continuation, ← integral_sub
      (continuation_integrable m (valueFunction m) ah)
      (continuation_integrable m (valueFunction m) (assetPolicy m z))]
    apply integral_congr_ae
    filter_upwards [] with l
    congr 2
    · have hnext : (m.prices.nextResources ah l : ℝ) =
          (m.prices.nextResources (assetPolicy m z) l : ℝ) +
            m.prices.grossReturn * h := by
        change m.prices.grossReturn * ((assetPolicy m z : ℝ) + h) +
          m.prices.effectiveIncome l =
          m.prices.grossReturn * (assetPolicy m z : ℝ) +
            m.prices.effectiveIncome l + m.prices.grossReturn * h
        ring
      rw [← hnext]
      exact Real.toNNReal_coe.symm
    · exact Real.toNNReal_coe.symm
  have hez : valueExtension m (z : ℝ) = valueFunction m z := valueExtension_coe m z
  have hezh : valueExtension m ((z : ℝ) + h) = valueFunction m zh := by
    change valueExtension m (zh : ℝ) = valueFunction m zh
    exact valueExtension_coe m zh
  rw [hez, hezh]
  rw [← hcont]
  linarith

theorem transitionSecant_integrable (m : HouseholdPrimitives) (z : Resources) {h : ℝ}
    (_hh : 0 < h) :
    Integrable (fun l : m.income.Labor =>
      slope (valueExtension m) (m.prices.nextResources (assetPolicy m z) l : ℝ)
        ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
          m.prices.grossReturn * h))
      (m.income.law : Measure m.income.Labor) := by
  apply Continuous.integrable_of_hasCompactSupport
  · have hx : Continuous (fun l : m.income.Labor =>
        (m.prices.nextResources (assetPolicy m z) l : ℝ)) :=
      continuous_subtype_val.comp ((nextResources_continuous m).comp
        (continuous_const.prodMk continuous_id))
    simp only [slope_def_field, add_sub_cancel_left]
    exact (((valueExtension_continuous m).comp (hx.add continuous_const)).sub
      ((valueExtension_continuous m).comp hx)).div_const _
  · exact HasCompactSupport.of_compactSpace _

/-- Divide the extra-saving Bellman comparison by `h`; the continuation quotient carries
the chain-rule factor `R` before any limit is taken. -/
theorem secant_extraSaving_comparison (m : HouseholdPrimitives) (z : Resources) {h : ℝ}
    (hh : 0 < h) :
    slope (valueExtension m) (z : ℝ) ((z : ℝ) + h) ≥
      m.beta * m.prices.grossReturn * ∫ l : m.income.Labor,
        slope (valueExtension m)
          (m.prices.nextResources (assetPolicy m z) l : ℝ)
          ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
            m.prices.grossReturn * h)
        ∂(m.income.law : Measure m.income.Labor) := by
  have hb := value_extraSaving_comparison m z hh
  rw [slope_def_field, add_sub_cancel_left]
  apply (le_div_iff₀ hh).2
  calc
    (m.beta * m.prices.grossReturn *
        ∫ l : m.income.Labor,
          slope (valueExtension m)
            (m.prices.nextResources (assetPolicy m z) l : ℝ)
            ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
              m.prices.grossReturn * h)
          ∂(m.income.law : Measure m.income.Labor)) * h =
      m.beta * ∫ l : m.income.Labor,
        (valueExtension m
            ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
              m.prices.grossReturn * h) -
          valueExtension m (m.prices.nextResources (assetPolicy m z) l : ℝ))
        ∂(m.income.law : Measure m.income.Labor) := by
          calc
            _ = m.beta * ((∫ l : m.income.Labor,
                slope (valueExtension m)
                  (m.prices.nextResources (assetPolicy m z) l : ℝ)
                  ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
                    m.prices.grossReturn * h)
                ∂(m.income.law : Measure m.income.Labor)) *
                  (m.prices.grossReturn * h)) := by ring
            _ = m.beta * ∫ l : m.income.Labor,
                slope (valueExtension m)
                  (m.prices.nextResources (assetPolicy m z) l : ℝ)
                  ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
                    m.prices.grossReturn * h) * (m.prices.grossReturn * h)
                ∂(m.income.law : Measure m.income.Labor) := by rw [integral_mul_const]
            _ = _ := by
              apply congrArg (fun x : ℝ => m.beta * x)
              apply integral_congr_ae
              filter_upwards [] with l
              rw [slope_def_field, add_sub_cancel_left]
              field_simp [ne_of_gt m.prices.grossReturn_pos]
    _ ≤ _ := hb

/-- Finite-h extended inequality, with the continuation written as a `lintegral`. -/
theorem secant_extraSaving_lintegral (m : HouseholdPrimitives) (z : Resources) {h : ℝ}
    (hh : 0 < h) :
    ENNReal.ofReal (m.beta * m.prices.grossReturn) *
        ∫⁻ l : m.income.Labor,
          ENNReal.ofReal (slope (valueExtension m)
            (m.prices.nextResources (assetPolicy m z) l : ℝ)
            ((m.prices.nextResources (assetPolicy m z) l : ℝ) +
              m.prices.grossReturn * h))
          ∂(m.income.law : Measure m.income.Labor) ≤
      ENNReal.ofReal (slope (valueExtension m) (z : ℝ) ((z : ℝ) + h)) := by
  let f := fun l : m.income.Labor =>
    slope (valueExtension m) (m.prices.nextResources (assetPolicy m z) l : ℝ)
      ((m.prices.nextResources (assetPolicy m z) l : ℝ) + m.prices.grossReturn * h)
  have hf : Integrable f (m.income.law : Measure m.income.Labor) :=
    transitionSecant_integrable m z hh
  have hfn : 0 ≤ᵐ[(m.income.law : Measure m.income.Labor)] f :=
    Eventually.of_forall fun l => (rightSecant_pos m
      (m.prices.nextResources (assetPolicy m z) l).property
      (lt_add_of_pos_right _ (mul_pos m.prices.grossReturn_pos hh))).le
  rw [← ofReal_integral_eq_lintegral_ofReal hf hfn,
    ← ENNReal.ofReal_mul (mul_nonneg m.beta_pos.le m.prices.grossReturn_pos.le)]
  exact ENNReal.ofReal_le_ofReal (secant_extraSaving_comparison m z hh)

private theorem initialMarginalSecant_tendsto (m : HouseholdPrimitives) (z : Resources) :
    Tendsto (fun n => ENNReal.ofReal
      (slope (valueExtension m) (z : ℝ) ((z : ℝ) + marginalStep n))) atTop
      (nhds (extendedRightMarginalValue m z)) := by
  by_cases hz : z = 0
  · subst z
    simpa [Function.comp_def] using (zeroRightMarginal_secant_limit m).comp
      (tendsto_add_marginalStep_right 0 1 one_pos)
  · rw [extendedRightMarginalValue_of_pos m (pos_iff_ne_zero.mpr hz)]
    exact (ENNReal.continuous_ofReal.continuousAt.tendsto.comp
      (rightMarginalValue_secant_limit m (show 0 < (z : ℝ) by exact_mod_cast
        (pos_iff_ne_zero.mpr hz)))).comp
      (by simpa using tendsto_add_marginalStep_right (z : ℝ) 1 one_pos)

/-- H09's primary statement: the extended nonnegative marginal inequality is established
before any real integral is formed.  The zero state uses `zeroRightMarginal`, never the
arbitrary real expression `rightMarginalValue m 0`. -/
theorem extendedRightMarginalValue_superharmonic (m : HouseholdPrimitives) (z : Resources) :
    ENNReal.ofReal (m.beta * m.prices.grossReturn) *
        ∫⁻ l : m.income.Labor,
          extendedRightMarginalValue m
            (m.prices.nextResources (assetPolicy m z) l)
          ∂(m.income.law : Measure m.income.Labor) ≤
      extendedRightMarginalValue m z := by
  let F := fun n (l : m.income.Labor) =>
    marginalSecantApprox m n (m.prices.nextResources (assetPolicy m z) l)
  have hFm : ∀ n, AEMeasurable (F n) (m.income.law : Measure m.income.Labor) := by
    intro n
    exact (marginalSecantApprox_measurable m n).comp_aemeasurable
      (((nextResources_continuous m).comp
        (continuous_const.prodMk continuous_id)).measurable.aemeasurable)
  have hFmono : ∀ᵐ l ∂(m.income.law : Measure m.income.Labor), Monotone fun n => F n l :=
    Eventually.of_forall fun l _ _ hnk => marginalSecantApprox_monotone m hnk _
  have hFt : ∀ᵐ l ∂(m.income.law : Measure m.income.Labor),
      Tendsto (fun n => F n l) atTop
        (nhds (extendedRightMarginalValue m
          (m.prices.nextResources (assetPolicy m z) l))) :=
    Eventually.of_forall fun l => marginalSecantApprox_tendsto m _
  have hlin := lintegral_tendsto_of_tendsto_of_monotone hFm hFmono hFt
  have hlhs := ENNReal.Tendsto.const_mul
    (a := ENNReal.ofReal (m.beta * m.prices.grossReturn)) hlin
    (Or.inr ENNReal.ofReal_ne_top)
  exact le_of_tendsto_of_tendsto hlhs (initialMarginalSecant_tendsto m z)
    (Eventually.of_forall fun n => by
      simpa [F, marginalSecantApprox] using
        (secant_extraSaving_lintegral m z (marginalStep_pos n)))

theorem continuationMarginal_lintegral_lt_top (m : HouseholdPrimitives) (z : Resources)
    (hz : extendedRightMarginalValue m z < ⊤) :
    (∫⁻ l : m.income.Labor,
      extendedRightMarginalValue m (m.prices.nextResources (assetPolicy m z) l)
      ∂(m.income.law : Measure m.income.Labor)) < ⊤ := by
  let I := ∫⁻ l : m.income.Labor,
    extendedRightMarginalValue m (m.prices.nextResources (assetPolicy m z) l)
    ∂(m.income.law : Measure m.income.Labor)
  have hmain := extendedRightMarginalValue_superharmonic m z
  have hcne : ENNReal.ofReal (m.beta * m.prices.grossReturn) ≠ 0 :=
    by simp [not_le.mpr (mul_pos m.beta_pos m.prices.grossReturn_pos)]
  by_contra hI
  have hItop : I = ⊤ := top_unique (not_lt.mp hI)
  rw [show (∫⁻ l : m.income.Labor,
      extendedRightMarginalValue m (m.prices.nextResources (assetPolicy m z) l)
      ∂(m.income.law : Measure m.income.Labor)) = I from rfl,
    hItop, ENNReal.mul_top hcne] at hmain
  exact (not_le_of_gt hz) hmain

/-- H09: a finite left marginal makes the conditional extended expectation finite; only
then is the economically meaningful real integral introduced and bounded by the left marginal. -/
theorem rightMarginalValue_superharmonic (m : HouseholdPrimitives) (z : Resources)
    (hz : extendedRightMarginalValue m z < ⊤) :
    (∀ᵐ l ∂(m.income.law : Measure m.income.Labor),
      extendedRightMarginalValue m
        (m.prices.nextResources (assetPolicy m z) l) < ⊤) ∧
    Integrable (fun l : m.income.Labor =>
      (extendedRightMarginalValue m
        (m.prices.nextResources (assetPolicy m z) l)).toReal)
      (m.income.law : Measure m.income.Labor) ∧
    m.beta * m.prices.grossReturn * ∫ l : m.income.Labor,
        (extendedRightMarginalValue m
          (m.prices.nextResources (assetPolicy m z) l)).toReal
        ∂(m.income.law : Measure m.income.Labor) ≤
      (extendedRightMarginalValue m z).toReal := by
  let f := fun l : m.income.Labor =>
    extendedRightMarginalValue m (m.prices.nextResources (assetPolicy m z) l)
  have hfm : Measurable f := (extendedRightMarginalValue_measurable m).comp
    ((nextResources_continuous m).comp (continuous_const.prodMk continuous_id)).measurable
  have hI := continuationMarginal_lintegral_lt_top m z hz
  have hfi : Integrable (fun l => (f l).toReal)
      (m.income.law : Measure m.income.Labor) :=
    integrable_toReal_of_lintegral_ne_top hfm.aemeasurable hI.ne
  have hae : ∀ᵐ l ∂(m.income.law : Measure m.income.Labor), f l < ⊤ :=
    ae_lt_top hfm hI.ne
  refine ⟨hae, hfi, ?_⟩
  have hreal := (ENNReal.toReal_le_toReal
    (ENNReal.mul_ne_top
      (ENNReal.ofReal_ne_top)
      hI.ne) hz.ne).2 (extendedRightMarginalValue_superharmonic m z)
  rw [ENNReal.toReal_mul, ENNReal.toReal_ofReal
      (mul_nonneg m.beta_pos.le m.prices.grossReturn_pos.le)] at hreal
  have hint := integral_toReal hfm.aemeasurable hae
  rw [hint]
  simpa [f] using hreal

end
end Aiyagari1994
