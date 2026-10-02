import Mathlib.MeasureTheory.Integral.BoundedContinuousFunction
import Mathlib.Probability.Kernel.Composition.IntegralCompProd

/-! Bounded-continuous test operators for the noncompact kernel-limit argument. -/
open MeasureTheory ProbabilityTheory
open scoped NNReal

namespace Aiyagari1994.M08A
noncomputable section

/-- The expectation of a bounded continuous test under a Feller Markov kernel, packaged as a
bounded continuous function of the current state. -/
def kernelTest (P : Kernel ℝ≥0 ℝ≥0) [IsMarkovKernel P]
    (hFeller : ∀ f : BoundedContinuousFunction ℝ≥0 ℝ,
      Continuous (fun z ↦ ∫ y, f y ∂P z))
    (f : BoundedContinuousFunction ℝ≥0 ℝ) : BoundedContinuousFunction ℝ≥0 ℝ :=
  BoundedContinuousFunction.mkOfBound
    ⟨fun z ↦ ∫ y, f y ∂P z, hFeller f⟩
    (2 * ‖f‖) (by
      intro x y
      rw [Real.dist_eq]
      calc
        |∫ z, f z ∂P x - ∫ z, f z ∂P y| ≤
            |∫ z, f z ∂P x| + |∫ z, f z ∂P y| := abs_sub _ _
        _ ≤ ‖f‖ + ‖f‖ := by
          have hbound (w : ℝ≥0) : |∫ z, f z ∂P w| ≤ ‖f‖ := by
            have h := norm_integral_le_of_norm_le_const (μ := P w)
              (Filter.Eventually.of_forall fun z ↦ f.norm_coe_le_norm z)
            simpa [Real.norm_eq_abs] using h
          exact add_le_add (hbound x) (hbound y)
        _ = 2 * ‖f‖ := by ring)

/-- A Markov expectation cannot exceed the sup norm of its bounded test. -/
theorem kernelTest_norm_le (P : Kernel ℝ≥0 ℝ≥0) [IsMarkovKernel P]
    (hFeller : ∀ f : BoundedContinuousFunction ℝ≥0 ℝ,
      Continuous (fun z ↦ ∫ y, f y ∂P z))
    (f : BoundedContinuousFunction ℝ≥0 ℝ) (z : ℝ≥0) :
    ‖kernelTest P hFeller f z‖ ≤ ‖f‖ := by
  have h := norm_integral_le_of_norm_le_const (μ := P z)
    (Filter.Eventually.of_forall fun y ↦ f.norm_coe_le_norm y)
  simpa [kernelTest] using h

end
end Aiyagari1994.M08A
