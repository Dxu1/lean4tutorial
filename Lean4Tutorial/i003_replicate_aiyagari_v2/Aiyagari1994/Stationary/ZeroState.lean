import Aiyagari1994.Analysis.M07A1.ZeroState

/-! N01: resolve the zero-resource marginal under an arbitrary candidate invariant law. -/
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal NNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- N01: for any candidate invariant probability law at any admissible positive gross return,
an infinite economic boundary marginal makes the zero state null.  Consequently the extended
value marginal is finite and positive almost everywhere.  H09 then supplies finite conditional
marginal expectations and the real superharmonic inequality state by state, without any
stationary marginal-moment assumption. -/
theorem stationary_zero_state_marginal_resolved (m : HouseholdPrimitives)
    (_hsmooth : UtilitySmooth m.utility) (hnd : IncomeNondegenerate m.income)
    (pi : ProbabilityMeasure Resources)
    (hinv : householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources)) :
    (zeroRightMarginal m = ⊤ → (pi : Measure Resources) {0} = 0) ∧
    ∀ᵐ z ∂(pi : Measure Resources),
      extendedRightMarginalValue m z < ⊤ ∧
      0 < extendedRightMarginalValue m z ∧
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
  refine ⟨M07A1.invariant_zero_measure_of_boundary_infinite m hnd pi hinv, ?_⟩
  have hfinite := M07A1.invariant_extendedMarginal_finite_ae m hnd pi hinv
  filter_upwards [hfinite] with z hz
  obtain ⟨hnext, hint, hineq⟩ := rightMarginalValue_superharmonic m z hz
  exact ⟨hz, M07A1.extendedRightMarginalValue_pos m z, hnext, hint, hineq⟩

end
end Aiyagari1994
