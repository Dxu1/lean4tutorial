import Mathlib.Probability.Kernel.Composition.MeasureComp
import Mathlib.Probability.Kernel.Composition.MeasureCompProd

/-! Gate-local propagation of stationary one-step equality to every finite horizon. -/
open MeasureTheory ProbabilityTheory Filter
open scoped ProbabilityTheory
namespace Aiyagari1994.M07A4
noncomputable section

private theorem kernel_pow_isMarkov
    {Ω : Type*} [MeasurableSpace Ω] (P : Kernel Ω Ω) [IsMarkovKernel P] :
    ∀ n : ℕ, IsMarkovKernel (P ^ n) := by
  intro n
  induction n with
  | zero =>
      change IsMarkovKernel (Kernel.id : Kernel Ω Ω)
      infer_instance
  | succ n ih =>
      letI : IsMarkovKernel (P ^ n) := ih
      rw [pow_succ]
      change IsMarkovKernel ((P ^ n) ∘ₖ P)
      infer_instance

private theorem invariant_kernel_pow
    {Ω : Type*} [MeasurableSpace Ω] (P : Kernel Ω Ω) [IsMarkovKernel P]
    (pi : Measure Ω) [IsProbabilityMeasure pi] (hinv : P ∘ₘ pi = pi) :
    ∀ n : ℕ, (P ^ n) ∘ₘ pi = pi := by
  intro n
  induction n with
  | zero =>
      change Kernel.id ∘ₘ pi = pi
      exact Measure.id_comp
  | succ n ih =>
      rw [pow_succ]
      change ((P ^ n) ∘ₖ P) ∘ₘ pi = pi
      rw [← Measure.comp_assoc, hinv, ih]

/-- A measurable quantity that is unchanged across a stationary one-step transition is
unchanged between the endpoints of every finite stationary history. -/
theorem stationary_oneStep_eq_implies_kernelPow_eq
    {Ω E : Type*} [MeasurableSpace Ω] [MeasurableSingletonClass Ω]
    [MeasurableSpace E] [MeasurableEq E]
    (P : Kernel Ω Ω) [IsMarkovKernel P]
    (pi : Measure Ω) [IsProbabilityMeasure pi]
    (f : Ω → E) (hf : Measurable f)
    (hinv : P ∘ₘ pi = pi)
    (hone : ∀ᵐ zz' ∂(pi ⊗ₘ P), f zz'.2 = f zz'.1) :
    ∀ n : ℕ, ∀ᵐ zz' ∂(pi ⊗ₘ (P ^ n)), f zz'.2 = f zz'.1 := by
  have hone' : ∀ᵐ x ∂pi, ∀ᵐ y ∂P x, f y = f x :=
    Measure.ae_ae_of_ae_compProd hone
  intro n
  induction n with
  | zero =>
      apply Measure.ae_compProd_of_ae_ae
      · exact measurableSet_eq_fun (hf.comp measurable_snd) (hf.comp measurable_fst)
      · filter_upwards [] with x
        have hid : P ^ 0 = (Kernel.id : Kernel Ω Ω) := pow_zero P
        rw [hid, Kernel.id_apply]
        exact ae_eq_dirac f
  | succ n ihn =>
      letI : IsMarkovKernel (P ^ n) := kernel_pow_isMarkov P n
      have ihn' : ∀ᵐ x ∂pi, ∀ᵐ y ∂(P ^ n) x, f y = f x :=
        Measure.ae_ae_of_ae_compProd ihn
      have hgood : ∀ᵐ x ∂pi, ∀ᵐ y ∂P x, f y = f x := hone'
      have hreach : ∀ᵐ x ∂pi, ∀ᵐ y ∂(P ^ n) x, ∀ᵐ z ∂P y, f z = f y := by
        have hcomp : ∀ᵐ y ∂((P ^ n) ∘ₘ pi), ∀ᵐ z ∂P y, f z = f y := by
          rw [invariant_kernel_pow P pi hinv n]
          exact hgood
        exact Measure.ae_ae_of_ae_comp hcomp
      rw [pow_succ']
      apply Measure.ae_compProd_of_ae_ae
      · exact measurableSet_eq_fun (hf.comp measurable_snd) (hf.comp measurable_fst)
      · filter_upwards [ihn', hreach] with x hxPath hxReach
        apply Kernel.ae_comp_of_ae_ae
        · exact measurableSet_eq_fun hf measurable_const
        · filter_upwards [hxPath, hxReach] with y hyx hyStep
          filter_upwards [hyStep] with z hzy
          exact hzy.trans hyx

end
end Aiyagari1994.M07A4
