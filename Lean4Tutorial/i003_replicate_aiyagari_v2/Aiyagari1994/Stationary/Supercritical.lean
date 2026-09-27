import Aiyagari1994.Analysis.M07A3.BoundedJensenAE
import Aiyagari1994.Stationary.ZeroState

/-! N03: exclusion of invariant household laws at supercritical returns. -/
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal NNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- N03: if `beta * R > 1`, the canonical household kernel admits no invariant probability
law.  The candidate law is supplied only for contradiction; no stationary moment or bounded
support is assumed. -/
theorem no_invariant_supercritical (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hnd : IncomeNondegenerate m.income)
    (hsupercritical : 1 < m.beta * m.prices.grossReturn) :
    ¬ ∃ pi : ProbabilityMeasure Resources,
      householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources) := by
  rintro ⟨pi, hinv⟩
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
        (fun l : m.income.Labor ↦ q (transition l)) =ᵐ[(m.income.law : Measure m.income.Labor)]
          fun l ↦ (extendedRightMarginalValue m (transition l)).toReal := by
      filter_upwards [hnext] with l hl
      dsimp [transition]
      simp [q, ne_of_lt hl]
    have hcomp : Integrable (q ∘ transition)
        (m.income.law : Measure m.income.Labor) := by
      exact hint.congr hqnext.symm
    rw [hkernel]
    exact (integrable_map_measure hqmeas.aestronglyMeasurable
      htransition.aemeasurable).2 hcomp
  have hineq : ∀ᵐ z ∂(pi : Measure Resources),
      m.beta * m.prices.grossReturn * ∫ z', q z' ∂householdKernel m z ≤ q z := by
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
    exact hzineq
  have hgamma := M07A3.stationary_bounded_jensen_ae_gamma_eq_one
    (householdKernel m) (pi : Measure Resources) q
    (m.beta * m.prices.grossReturn) hqmeas hqpos hcond
    hsupercritical.le hineq hinv
  exact (ne_of_gt hsupercritical) hgamma

end
end Aiyagari1994
