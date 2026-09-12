import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.FiniteStatePrimitives

/-!
# MP1994 v2: finite conditional aggregate expectation

The expectation is a finite weighted sum. No measurable-state kernel or
employment transition is introduced here.
-/

namespace MP1994V2
namespace FiniteAggregateProcess

variable {P : Primitives} {ι : Type*} [Fintype ι]

/-- Conditional expectation over the next aggregate mark. -/
def nextExpectation (K : FiniteAggregateProcess P ι) (i : ι)
    (f : ι → ℝ) : ℝ :=
  ∑ j, K.transitionWeight i j * f j

@[simp] theorem nextExpectation_zero (K : FiniteAggregateProcess P ι) (i : ι) :
    K.nextExpectation i (fun _ => 0) = 0 := by
  simp [nextExpectation]

theorem nextExpectation_const (K : FiniteAggregateProcess P ι)
    (KA : FiniteAggregateProcessAssumptions P K) (i : ι) (c : ℝ) :
    K.nextExpectation i (fun _ => c) = c := by
  rw [nextExpectation]
  calc
    ∑ j, K.transitionWeight i j * c = (∑ j, K.transitionWeight i j) * c := by
      rw [Finset.sum_mul]
    _ = c := by rw [KA.transitionWeight_sum_one i, one_mul]

theorem nextExpectation_add (K : FiniteAggregateProcess P ι) (i : ι)
    (f g : ι → ℝ) :
    K.nextExpectation i (fun j => f j + g j) =
      K.nextExpectation i f + K.nextExpectation i g := by
  simp only [nextExpectation, mul_add, Finset.sum_add_distrib]

theorem nextExpectation_smul (K : FiniteAggregateProcess P ι) (i : ι)
    (a : ℝ) (f : ι → ℝ) :
    K.nextExpectation i (fun j => a * f j) = a * K.nextExpectation i f := by
  simp only [nextExpectation]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem nextExpectation_nonneg (K : FiniteAggregateProcess P ι)
    (KA : FiniteAggregateProcessAssumptions P K) (i : ι)
    {f : ι → ℝ} (hf : ∀ j, 0 ≤ f j) :
    0 ≤ K.nextExpectation i f := by
  exact Finset.sum_nonneg fun j _ =>
    mul_nonneg (KA.transitionWeight_nonneg i j) (hf j)

theorem nextExpectation_mono (K : FiniteAggregateProcess P ι)
    (KA : FiniteAggregateProcessAssumptions P K) (i : ι)
    {f g : ι → ℝ} (hfg : ∀ j, f j ≤ g j) :
    K.nextExpectation i f ≤ K.nextExpectation i g := by
  apply Finset.sum_le_sum
  intro j _
  exact mul_le_mul_of_nonneg_left (hfg j) (KA.transitionWeight_nonneg i j)

end FiniteAggregateProcess
end MP1994V2
