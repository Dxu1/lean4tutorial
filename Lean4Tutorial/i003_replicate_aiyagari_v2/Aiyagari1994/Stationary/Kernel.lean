import Aiyagari1994.Analysis.M05A.KernelTransition
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import Mathlib.Probability.Kernel.Composition.Prod
import Mathlib.Probability.Kernel.Composition.MapComap
import Mathlib.Probability.Kernel.Integral

/-! The household transition kernel induced by the optimal shifted-asset policy. -/
open MeasureTheory ProbabilityTheory Set
open scoped NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- The law of tomorrow's resources, conditional on resources today. -/
def householdKernel (m : HouseholdPrimitives) : Kernel Resources Resources :=
  (Kernel.id ×ₖ Kernel.const Resources (m.income.law : Measure m.income.Labor)).map
    (householdTransition m)

instance householdKernel_isMarkov (m : HouseholdPrimitives) :
    IsMarkovKernel (householdKernel m) := by
  unfold householdKernel
  exact Kernel.IsMarkovKernel.map _ (householdTransition_continuous m).measurable

theorem householdKernel_integral (m : HouseholdPrimitives) (z : Resources)
    (f : Resources → ℝ) (hf : Measurable f) :
    (∫ y, f y ∂householdKernel m z) =
      ∫ l, f (m.prices.nextResources (assetPolicy m z) l)
        ∂(m.income.law : Measure m.income.Labor) := by
  rw [show householdKernel m z =
      (m.income.law : Measure m.income.Labor).map
        (fun l => m.prices.nextResources (assetPolicy m z) l) by
    ext s hs
    rw [householdKernel, Kernel.map_apply' _ (householdTransition_continuous m).measurable _ hs,
      Kernel.id_prod_apply' _ _ ((householdTransition_continuous m).measurable hs)]
    rw [Kernel.const_apply]
    have hmeas : Measurable (fun l => m.prices.nextResources (assetPolicy m z) l) :=
      ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id)).measurable
    rw [Measure.map_apply hmeas hs]
    rfl]
  exact integral_map
    ((householdTransition_continuous m).measurable.comp measurable_prodMk_left).aemeasurable
    hf.aestronglyMeasurable

/-- S01: the policy-induced pushforward is Markov and Feller, has the exact test-function
formula, and preserves the weak stochastic order through increasing tests. -/
theorem householdKernel_feller_monotone (m : HouseholdPrimitives) :
    IsMarkovKernel (householdKernel m) ∧
    (∀ f : BoundedContinuousFunction Resources ℝ,
      Continuous (fun z => ∫ y, f y ∂householdKernel m z)) ∧
    (∀ f : BoundedContinuousFunction Resources ℝ, Monotone f →
      Monotone (fun z => ∫ y, f y ∂householdKernel m z)) ∧
    ∀ (z : Resources) (f : Resources → ℝ), Measurable f →
      (∫ y, f y ∂householdKernel m z) =
        ∫ l, f (m.prices.nextResources (assetPolicy m z) l)
          ∂(m.income.law : Measure m.income.Labor) := by
  refine ⟨inferInstance, ?_, ?_, ?_⟩
  · intro f
    simp_rw [householdKernel_integral m _ f f.continuous.measurable]
    apply MeasureTheory.continuous_of_dominated
        (bound := fun _ : m.income.Labor => ‖f‖)
    · intro z
      exact (f.continuous.comp ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id))).aestronglyMeasurable
    · intro z
      exact Filter.Eventually.of_forall fun l => f.norm_coe_le_norm _
    · exact integrable_const ‖f‖
    · exact Filter.Eventually.of_forall fun l => f.continuous.comp
        ((householdTransition_continuous m).comp (continuous_id.prodMk continuous_const))
  · intro f hmono z₁ z₂ hz
    simp_rw [householdKernel_integral m _ f f.continuous.measurable]
    apply integral_mono
    · exact (f.continuous.comp ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id))).integrable_of_hasCompactSupport
          (HasCompactSupport.of_compactSpace _)
    · exact (f.continuous.comp ((householdTransition_continuous m).comp
        (continuous_const.prodMk continuous_id))).integrable_of_hasCompactSupport
          (HasCompactSupport.of_compactSpace _)
    · exact fun l => hmono (by
        apply Subtype.coe_le_coe.mp
        have ha : (assetPolicy m z₁ : ℝ) ≤ (assetPolicy m z₂ : ℝ) := assetPolicy_monotone m hz
        change m.prices.grossReturn * (assetPolicy m z₁ : ℝ) + m.prices.effectiveIncome l ≤
          m.prices.grossReturn * (assetPolicy m z₂ : ℝ) + m.prices.effectiveIncome l
        exact add_le_add (mul_le_mul_of_nonneg_left ha
          m.prices.grossReturn_pos.le) le_rfl)
  · intro z f hf
    exact householdKernel_integral m z f hf

end
end Aiyagari1994
