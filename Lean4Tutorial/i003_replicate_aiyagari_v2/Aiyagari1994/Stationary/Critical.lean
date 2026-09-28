import Aiyagari1994.Analysis.M07B2.HouseholdBridge

/-! N06: exclusion of invariant household laws at the critical return. -/
open MeasureTheory ProbabilityTheory Filter Set
open scoped ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- N06: if `beta * R = 1`, nondegenerate effective income rules out an invariant probability
law for the canonical household kernel.  The candidate law is introduced only for contradiction;
no state moment or bounded-support premise is used. -/
theorem no_invariant_critical (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hnd : IncomeNondegenerate m.income)
    (hcritical : m.beta * m.prices.grossReturn = 1) :
    ¬ ∃ pi : ProbabilityMeasure Resources,
      householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources) := by
  rintro ⟨pi, hinv⟩
  have hR : 1 < m.prices.grossReturn := by
    nlinarith [m.beta_pos, m.beta_lt_one, m.prices.grossReturn_pos,
      mul_pos m.beta_pos m.prices.grossReturn_pos]
  obtain ⟨B, hB, hbounded⟩ := M07B2.effectiveIncome_abs_bounded m
  let step : Resources → m.income.Labor → Resources := fun z l ↦
    m.prices.nextResources (assetPolicy m z) l
  have hstep : Measurable (fun p : Resources × m.income.Labor ↦ step p.1 p.2) :=
    (householdTransition_continuous m).measurable
  have hkernel : M07B1.resourceKernel (m.income.law : Measure m.income.Labor)
      step hstep = householdKernel m := by
    exact M07B2.resourceKernel_canonical_eq m
  have hrecursion : ∀ z l, ((step z l : Resources) : ℝ) =
      m.prices.grossReturn * ((z : ℝ) - (consumptionPolicy m z : ℝ)) +
        m.prices.effectiveIncome l := by
    intro z l
    rw [consumptionPolicy_coe]
    change m.prices.grossReturn * (assetPolicy m z : ℝ) +
      m.prices.effectiveIncome l = _
    ring
  have hconstant := (critical_stationary_consumption_constant m hsmooth hnd pi hinv hcritical).1
  apply two_independent_histories_contradiction
    (m.income.law : Measure m.income.Labor)
    m.prices.effectiveIncome
    (by
      unfold NormalizedPrices.effectiveIncome
      fun_prop)
    B hB hbounded (M07B2.effectiveIncome_not_ae_const m hnd)
    m.prices.grossReturn hR
    (consumptionPolicy m) (consumptionPolicy_continuous m).measurable
    step hstep hrecursion (pi : Measure Resources)
  · simpa [hkernel] using hinv
  · simpa [hkernel] using hconstant

end
end Aiyagari1994
