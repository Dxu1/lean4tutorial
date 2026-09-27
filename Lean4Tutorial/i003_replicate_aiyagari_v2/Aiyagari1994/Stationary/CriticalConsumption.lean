import Aiyagari1994.Analysis.M07A4.BoundedJensenEqualityAE
import Aiyagari1994.Analysis.M07A4.ConsumptionMarginal
import Aiyagari1994.Analysis.M07A4.FiniteHistory
import Aiyagari1994.Stationary.ZeroState

/-! N04: stationary consumption is constant along every finite history at the critical return. -/
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal NNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- N04: under `beta * R = 1`, a supplied invariant household law makes consumption equal
across a stationary one-step transition and between the endpoints of every finite stationary
history.  The proof uses only conditional marginal integrability.  At zero resources the
economic marginal remains `zeroRightMarginal : ENNReal`. -/
theorem critical_stationary_consumption_constant
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hnd : IncomeNondegenerate m.income)
    (pi : ProbabilityMeasure Resources)
    (hinv : householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources))
    (hcritical : m.beta * m.prices.grossReturn = 1) :
    (∀ᵐ zz' ∂((pi : Measure Resources) ⊗ₘ householdKernel m),
      consumptionPolicy m zz'.2 = consumptionPolicy m zz'.1) ∧
    ∀ n : ℕ, ∀ᵐ zz' ∂((pi : Measure Resources) ⊗ₘ ((householdKernel m) ^ n)),
      consumptionPolicy m zz'.2 = consumptionPolicy m zz'.1 := by
  let q : Resources → ℝ := fun z ↦
    if extendedRightMarginalValue m z = ⊤ then 1
    else (extendedRightMarginalValue m z).toReal
  have hqmeas : Measurable q := by
    apply Measurable.ite
    · exact (extendedRightMarginalValue_measurable m) (measurableSet_singleton ⊤)
    · exact measurable_const
    · exact (extendedRightMarginalValue_measurable m).ennreal_toReal
  have hqpos : ∀ z, 0 < q z := by
    intro z
    by_cases hz : extendedRightMarginalValue m z = ⊤
    · simp [q, hz]
    · simp only [q, hz, ↓reduceIte]
      exact ENNReal.toReal_pos
        (ne_of_gt (M07A1.extendedRightMarginalValue_pos m z)) hz
  have hstationary :=
    (stationary_zero_state_marginal_resolved m hsmooth hnd pi hinv).2
  have hcond : ∀ᵐ z ∂(pi : Measure Resources), Integrable q (householdKernel m z) := by
    filter_upwards [hstationary] with z hz
    rcases hz with ⟨_hzfinite, _hzpos, hnext, hint, _hineq⟩
    let transition : m.income.Labor → Resources := fun l ↦
      m.prices.nextResources (assetPolicy m z) l
    have htransition : Measurable transition :=
      ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id)).measurable
    have hkernel : householdKernel m z =
        (m.income.law : Measure m.income.Labor).map transition := by
      ext s hs
      rw [householdKernel, Kernel.map_apply' _
        (householdTransition_continuous m).measurable _ hs,
        Kernel.id_prod_apply' _ _ ((householdTransition_continuous m).measurable hs)]
      rw [Kernel.const_apply, Measure.map_apply htransition hs]
      rfl
    have hqnext :
        (fun l : m.income.Labor ↦ q (transition l))
          =ᵐ[(m.income.law : Measure m.income.Labor)]
        fun l ↦ (extendedRightMarginalValue m (transition l)).toReal := by
      filter_upwards [hnext] with l hl
      dsimp [transition]
      simp [q, ne_of_lt hl]
    have hcomp : Integrable (q ∘ transition)
        (m.income.law : Measure m.income.Labor) := hint.congr hqnext.symm
    rw [hkernel]
    exact (integrable_map_measure hqmeas.aestronglyMeasurable
      htransition.aemeasurable).2 hcomp
  have hineq : ∀ᵐ z ∂(pi : Measure Resources),
      ∫ z', q z' ∂householdKernel m z ≤ q z := by
    filter_upwards [hstationary] with z hz
    rcases hz with ⟨hzfinite, _hzpos, hnext, _hint, hzineq⟩
    have hqcurrent : q z = (extendedRightMarginalValue m z).toReal := by
      simp [q, ne_of_lt hzfinite]
    have hqnext :
        (fun l : m.income.Labor ↦
          q (m.prices.nextResources (assetPolicy m z) l))
          =ᵐ[(m.income.law : Measure m.income.Labor)]
        fun l ↦ (extendedRightMarginalValue m
          (m.prices.nextResources (assetPolicy m z) l)).toReal := by
      filter_upwards [hnext] with l hl
      simp [q, ne_of_lt hl]
    rw [householdKernel_integral m z q hqmeas, integral_congr_ae hqnext, hqcurrent]
    rw [hcritical] at hzineq
    simpa using hzineq
  have hqeq : ∀ᵐ zz' ∂((pi : Measure Resources) ⊗ₘ householdKernel m),
      q zz'.2 = q zz'.1 :=
    M07A4.stationary_bounded_jensen_ae_equality
      (householdKernel m) (pi : Measure Resources) q hqmeas hqpos hcond hineq hinv
  have hfinite : ∀ᵐ z ∂(pi : Measure Resources),
      extendedRightMarginalValue m z < ⊤ := hstationary.mono fun _ hz ↦ hz.1
  have hfiniteNext : ∀ᵐ z ∂(pi : Measure Resources),
      ∀ᵐ z' ∂householdKernel m z, extendedRightMarginalValue m z' < ⊤ := by
    have hcomp : ∀ᵐ z' ∂(householdKernel m ∘ₘ (pi : Measure Resources)),
        extendedRightMarginalValue m z' < ⊤ := by
      rw [hinv]
      exact hfinite
    exact Measure.ae_ae_of_ae_comp hcomp
  have hcons : ∀ᵐ zz' ∂((pi : Measure Resources) ⊗ₘ householdKernel m),
      consumptionPolicy m zz'.2 = consumptionPolicy m zz'.1 := by
    apply Measure.ae_compProd_of_ae_ae
    · exact measurableSet_eq_fun
        ((consumptionPolicy_continuous m).measurable.comp measurable_snd)
        ((consumptionPolicy_continuous m).measurable.comp measurable_fst)
    · have hqeq' := Measure.ae_ae_of_ae_compProd hqeq
      filter_upwards [hfinite, hfiniteNext, hqeq'] with z hzfinite hznext hzq
      filter_upwards [hznext, hzq] with z' hz'finite hz'q
      have hqz : q z = (extendedRightMarginalValue m z).toReal := by
        simp [q, ne_of_lt hzfinite]
      have hqz' : q z' = (extendedRightMarginalValue m z').toReal := by
        simp [q, ne_of_lt hz'finite]
      have hmarginal : extendedRightMarginalValue m z' =
          extendedRightMarginalValue m z := by
        apply (ENNReal.toReal_eq_toReal_iff' hz'finite.ne hzfinite.ne).mp
        rw [← hqz', ← hqz]
        exact hz'q
      exact M07A4.consumption_eq_of_extendedMarginal_eq m hsmooth z z'
        hzfinite hz'finite hmarginal
  refine ⟨hcons, ?_⟩
  exact M07A4.stationary_oneStep_eq_implies_kernelPow_eq
    (householdKernel m) (pi : Measure Resources) (consumptionPolicy m)
    (consumptionPolicy_continuous m).measurable hinv hcons

end
end Aiyagari1994
