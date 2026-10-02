import Aiyagari1994.Analysis.M08A.KernelTest
import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.Topology.UniformSpace.LocallyUniformConvergence

/-! B01: invariant laws remain invariant under tight, locally uniform Feller-kernel limits. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- B01. For Feller Markov kernels on noncompact nonnegative resources, tightness and local
uniform convergence of every bounded-continuous one-step test suffice to pass invariance to a
weak limit. The proof uses no moments, bounded supports, or globally uniform convergence. -/
theorem tight_kernel_invariant_limit
    (Pseq : ℕ → Kernel ℝ≥0 ℝ≥0) (P : Kernel ℝ≥0 ℝ≥0)
    [hPseq : (n : ℕ) → IsMarkovKernel (Pseq n)] [hP : IsMarkovKernel P]
    (muSeq : ℕ → ProbabilityMeasure ℝ≥0) (mu : ProbabilityMeasure ℝ≥0)
    (hFellerSeq : ∀ n (f : BoundedContinuousFunction ℝ≥0 ℝ),
      Continuous (fun z ↦ ∫ y, f y ∂Pseq n z))
    (hFeller : ∀ f : BoundedContinuousFunction ℝ≥0 ℝ,
      Continuous (fun z ↦ ∫ y, f y ∂P z))
    (hLocal : ∀ f : BoundedContinuousFunction ℝ≥0 ℝ,
      TendstoLocallyUniformly
        (fun n z ↦ ∫ y, f y ∂Pseq n z) (fun z ↦ ∫ y, f y ∂P z) atTop)
    (hTight : IsTightMeasureSet
      {nu : Measure ℝ≥0 | ∃ n, nu = (muSeq n : Measure ℝ≥0)})
    (hWeak : Tendsto muSeq atTop (nhds mu))
    (hInvariant : ∀ n, Pseq n ∘ₘ (muSeq n : Measure ℝ≥0) = (muSeq n : Measure ℝ≥0)) :
    P ∘ₘ (mu : Measure ℝ≥0) = (mu : Measure ℝ≥0) := by
  apply ext_of_forall_integral_eq_of_IsFiniteMeasure
  intro f
  rw [Measure.comp_eq_comp_const_apply]
  rw [Kernel.integral_comp (f.integrable _)]
  let g : BoundedContinuousFunction ℝ≥0 ℝ := M08A.kernelTest P hFeller f
  let gseq : ℕ → BoundedContinuousFunction ℝ≥0 ℝ :=
    fun n ↦ M08A.kernelTest (Pseq n) (hFellerSeq n) f
  have hvary : Tendsto (fun n ↦
      ∫ z, (gseq n z - g z) ∂(muSeq n : Measure ℝ≥0)) atTop (nhds 0) := by
    rw [Metric.tendsto_nhds]
    intro eps heps
    let eta : ℝ := eps / (4 * (‖f‖ + 1))
    have heta : 0 < eta := div_pos heps (by positivity)
    obtain ⟨K, hKcompact, hKtail⟩ :=
      isTightMeasureSet_iff_exists_isCompact_measure_compl_le.mp hTight
        (ENNReal.ofReal eta) (ENNReal.ofReal_pos.2 heta)
    have hlocalK : TendstoUniformlyOn
        (fun n z ↦ ∫ y, f y ∂Pseq n z) (fun z ↦ ∫ y, f y ∂P z) atTop K :=
      (tendstoLocallyUniformly_iff_forall_isCompact.mp (hLocal f)) K hKcompact
    have hevent := (Metric.tendstoUniformlyOn_iff.mp hlocalK) (eps / 2) (half_pos heps)
    filter_upwards [hevent] with n hn
    have hrealTail : (muSeq n : Measure ℝ≥0).real Kᶜ ≤ eta := by
      have htail : (muSeq n : Measure ℝ≥0) Kᶜ ≤ ENNReal.ofReal eta :=
        hKtail _ ⟨n, rfl⟩
      rw [Measure.real, ← ENNReal.toReal_ofReal heta.le]
      exact ENNReal.toReal_le_toReal (measure_ne_top _ _) ENNReal.ofReal_ne_top |>.2 htail
    have hdiffInt : Integrable (fun z ↦ gseq n z - g z) (muSeq n : Measure ℝ≥0) :=
      (gseq n).integrable _ |>.sub (g.integrable _)
    have hsplit := integral_add_compl hKcompact.measurableSet hdiffInt
    have hcompactPart : ‖∫ z in K, (gseq n z - g z) ∂(muSeq n : Measure ℝ≥0)‖ ≤ eps / 2 := by
      calc
        ‖∫ z in K, (gseq n z - g z) ∂(muSeq n : Measure ℝ≥0)‖ ≤
            (eps / 2) * (muSeq n : Measure ℝ≥0).real K := by
          apply norm_setIntegral_le_of_norm_le_const (measure_lt_top _ _)
          intro z hz
          simpa [gseq, g, M08A.kernelTest, Real.dist_eq, abs_sub_comm] using (hn z hz).le
        _ ≤ (eps / 2) * 1 := by
          gcongr
          change ((muSeq n : Measure ℝ≥0) K).toReal ≤ 1
          rw [← ENNReal.toReal_one,
            ENNReal.toReal_le_toReal (measure_ne_top _ _) (by simp)]
          simpa using (measure_mono (Set.subset_univ K) :
            (muSeq n : Measure ℝ≥0) K ≤ (muSeq n : Measure ℝ≥0) Set.univ)
        _ = eps / 2 := by ring
    have htailPart : ‖∫ z in Kᶜ, (gseq n z - g z) ∂(muSeq n : Measure ℝ≥0)‖ ≤
        (2 * ‖f‖) * eta := by
      calc
        ‖∫ z in Kᶜ, (gseq n z - g z) ∂(muSeq n : Measure ℝ≥0)‖ ≤
            (2 * ‖f‖) * (muSeq n : Measure ℝ≥0).real Kᶜ := by
          apply norm_setIntegral_le_of_norm_le_const (measure_lt_top _ _)
          intro z _hz
          calc
            ‖gseq n z - g z‖ ≤ ‖gseq n z‖ + ‖g z‖ := norm_sub_le _ _
            _ ≤ ‖f‖ + ‖f‖ := add_le_add
              (M08A.kernelTest_norm_le (Pseq n) (hFellerSeq n) f z)
              (M08A.kernelTest_norm_le P hFeller f z)
            _ = 2 * ‖f‖ := by ring
        _ ≤ (2 * ‖f‖) * eta := by gcongr
    have htailSmall : (2 * ‖f‖) * eta < eps / 2 := by
      dsimp [eta]
      have hf : 0 ≤ ‖f‖ := norm_nonneg f
      have hden : 0 < 4 * (‖f‖ + 1) := by positivity
      rw [div_eq_mul_inv]
      field_simp
      nlinarith
    rw [dist_zero_right, ← hsplit]
    exact (norm_add_le _ _).trans_lt
      ((add_le_add hcompactPart htailPart).trans_lt (by linarith))
  have hfixed : Tendsto (fun n ↦ ∫ z, g z ∂(muSeq n : Measure ℝ≥0)) atTop
      (nhds (∫ z, g z ∂(mu : Measure ℝ≥0))) :=
    (ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hWeak) g
  have hleft : Tendsto (fun n ↦ ∫ z, gseq n z ∂(muSeq n : Measure ℝ≥0)) atTop
      (nhds (∫ z, g z ∂(mu : Measure ℝ≥0))) := by
    have heq : ∀ n,
        (∫ z, (gseq n z - g z) ∂(muSeq n : Measure ℝ≥0)) +
          ∫ z, g z ∂(muSeq n : Measure ℝ≥0) =
        ∫ z, gseq n z ∂(muSeq n : Measure ℝ≥0) := by
      intro n
      rw [integral_sub ((gseq n).integrable _) (g.integrable _)]
      ring
    simpa only [zero_add] using
      (hvary.add hfixed).congr' (Eventually.of_forall heq)
  have hright : Tendsto (fun n ↦ ∫ z, f z ∂(muSeq n : Measure ℝ≥0)) atTop
      (nhds (∫ z, f z ∂(mu : Measure ℝ≥0))) :=
    (ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hWeak) f
  have heq : ∀ n, ∫ z, gseq n z ∂(muSeq n : Measure ℝ≥0) =
      ∫ z, f z ∂(muSeq n : Measure ℝ≥0) := by
    intro n
    calc
      ∫ z, gseq n z ∂(muSeq n : Measure ℝ≥0) =
          ∫ z, f z ∂(Pseq n ∘ₘ (muSeq n : Measure ℝ≥0)) := by
        rw [Measure.comp_eq_comp_const_apply]
        rw [Kernel.integral_comp (f.integrable _)]
        simp [gseq, M08A.kernelTest]
      _ = ∫ z, f z ∂(muSeq n : Measure ℝ≥0) := by rw [hInvariant n]
  exact tendsto_nhds_unique (hleft.congr' (Eventually.of_forall heq)) hright

end
end Aiyagari1994
