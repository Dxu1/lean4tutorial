import Aiyagari1994.Analysis.BoundedJensen

/-! Gate-local almost-everywhere interface for the bounded-Jensen argument. -/
open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal ProbabilityTheory
namespace Aiyagari1994.M07A3
noncomputable section

/-- The supercritical part of `stationary_bounded_jensen_equality` remains valid when
conditional integrability and the superharmonic inequality hold only almost everywhere under
the invariant law.  No integral of `q` against `pi` is formed. -/
theorem stationary_bounded_jensen_ae_gamma_eq_one
    {Ω : Type*} [MeasurableSpace Ω]
    (P : Kernel Ω Ω) [IsMarkovKernel P]
    (pi : Measure Ω) [IsProbabilityMeasure pi] (q : Ω → ℝ) (gamma : ℝ)
    (hq : Measurable q) (hqpos : ∀ z, 0 < q z)
    (hcond : ∀ᵐ z ∂pi, Integrable q (P z)) (hgamma : 1 ≤ gamma)
    (hsuper : ∀ᵐ z ∂pi, gamma * ∫ z', q z' ∂(P z) ≤ q z)
    (hinv : P ∘ₘ pi = pi) :
    gamma = 1 := by
  let psi : ℝ → ℝ := fun x ↦ x / (1 + x)
  let avg : Ω → ℝ := fun z ↦ ∫ z', q z' ∂(P z)
  let boundedAvg : Ω → ℝ := fun z ↦ ∫ z', psi (q z') ∂(P z)
  have hpsi_meas : Measurable psi := by fun_prop
  have hpsiq_meas : Measurable (psi ∘ q) := hpsi_meas.comp hq
  have havg_meas : Measurable avg := by
    simpa [avg] using
      ((hq.comp measurable_snd).stronglyMeasurable.integral_kernel_prod_right
        (f := fun _ z' ↦ q z') (κ := P)).measurable
  have hboundedAvg_meas : Measurable boundedAvg := by
    simpa [boundedAvg, Function.comp_def] using
      ((hpsiq_meas.comp measurable_snd).stronglyMeasurable.integral_kernel_prod_right
        (f := fun _ z' ↦ psi (q z')) (κ := P)).measurable
  have hpsi_nonneg : ∀ x : ℝ, 0 ≤ x → 0 ≤ psi x := by
    intro x hx
    dsimp [psi]
    positivity
  have hpsi_le_one : ∀ x : ℝ, 0 ≤ x → psi x ≤ 1 := by
    intro x hx
    dsimp [psi]
    rw [div_le_one (by positivity : 0 < 1 + x)]
    linarith
  have hpsiq_int : Integrable (psi ∘ q) pi := by
    refine Integrable.mono' (integrable_const (1 : ℝ)) hpsiq_meas.aestronglyMeasurable ?_
    filter_upwards [] with z
    change ‖psi (q z)‖ ≤ 1
    rw [Real.norm_of_nonneg (hpsi_nonneg _ (hqpos z).le)]
    exact hpsi_le_one _ (hqpos z).le
  have hpsiq_cond : ∀ z, Integrable (psi ∘ q) (P z) := by
    intro z
    refine Integrable.mono' (integrable_const (1 : ℝ))
      hpsiq_meas.aestronglyMeasurable ?_
    filter_upwards [] with z'
    change ‖psi (q z')‖ ≤ 1
    rw [Real.norm_of_nonneg (hpsi_nonneg _ (hqpos z').le)]
    exact hpsi_le_one _ (hqpos z').le
  have havg_nonneg : ∀ z, 0 ≤ avg z := by
    intro z
    exact integral_nonneg fun z' ↦ (hqpos z').le
  have havg_pos : ∀ᵐ z ∂pi, 0 < avg z := by
    filter_upwards [hcond] with z hz
    change 0 < ∫ z', q z' ∂(P z)
    rw [integral_pos_iff_support_of_nonneg (fun z' ↦ (hqpos z').le) hz]
    have hsupp : Function.support q = Set.univ := by
      ext z'
      simp [Function.mem_support, (hqpos z').ne']
    rw [hsupp, measure_univ]
    exact zero_lt_one
  have hboundedAvg_nonneg : ∀ z, 0 ≤ boundedAvg z := by
    intro z
    exact integral_nonneg fun z' ↦ hpsi_nonneg _ (hqpos z').le
  have hboundedAvg_le_one : ∀ z, boundedAvg z ≤ 1 := by
    intro z
    calc
      boundedAvg z ≤ ∫ _ : Ω, (1 : ℝ) ∂(P z) :=
        integral_mono (hpsiq_cond z) (integrable_const 1)
          (fun z' ↦ hpsi_le_one _ (hqpos z').le)
      _ = 1 := by simp
  have hboundedAvg_int : Integrable boundedAvg pi := by
    refine Integrable.mono' (integrable_const (1 : ℝ))
      hboundedAvg_meas.aestronglyMeasurable ?_
    filter_upwards [] with z
    rw [Real.norm_of_nonneg (hboundedAvg_nonneg z)]
    exact hboundedAvg_le_one z
  have havgPsi_int : Integrable (fun z ↦ psi (avg z)) pi := by
    refine Integrable.mono' (integrable_const (1 : ℝ))
      (hpsi_meas.comp havg_meas).aestronglyMeasurable ?_
    filter_upwards [] with z
    rw [Real.norm_of_nonneg (hpsi_nonneg _ (havg_nonneg z))]
    exact hpsi_le_one _ (havg_nonneg z)
  have hgamma_nonneg : 0 ≤ gamma := le_trans (by norm_num) hgamma
  have hgammaAvgPsi_int : Integrable (fun z ↦ psi (gamma * avg z)) pi := by
    refine Integrable.mono' (integrable_const (1 : ℝ))
      (hpsi_meas.comp (measurable_const.mul havg_meas)).aestronglyMeasurable ?_
    filter_upwards [] with z
    have hz : 0 ≤ gamma * avg z := mul_nonneg hgamma_nonneg (havg_nonneg z)
    rw [Real.norm_of_nonneg (hpsi_nonneg _ hz)]
    exact hpsi_le_one _ hz
  have hpsi_mono : ∀ {x y : ℝ}, 0 ≤ x → x ≤ y → psi x ≤ psi y := by
    intro x y hx hxy
    dsimp [psi]
    have hy : 0 ≤ y := hx.trans hxy
    rw [div_le_div_iff₀ (by linarith : 0 < 1 + x) (by linarith : 0 < 1 + y)]
    nlinarith
  have hjensen : ∀ᵐ z ∂pi, boundedAvg z ≤ psi (avg z) := by
    filter_upwards [hcond] with z hz
    let slope : ℝ := 1 / (1 + avg z) ^ 2
    have htangent : ∀ x : ℝ, 0 ≤ x →
        psi x ≤ psi (avg z) + slope * (x - avg z) := by
      intro x hx
      have hm1 : 0 < 1 + avg z := by linarith [havg_nonneg z]
      have hx1 : 0 < 1 + x := by linarith
      have hid : psi (avg z) + slope * (x - avg z) - psi x =
          (x - avg z) ^ 2 / ((1 + avg z) ^ 2 * (1 + x)) := by
        dsimp [psi, slope]
        field_simp
        ring
      rw [← sub_nonneg, hid]
      positivity
    calc
      boundedAvg z ≤ ∫ x, (psi (avg z) + slope * (q x - avg z)) ∂(P z) :=
        integral_mono (hpsiq_cond z)
          ((integrable_const _).add ((hz.sub (integrable_const _)).const_mul slope))
          (fun x ↦ htangent (q x) (hqpos x).le)
      _ = psi (avg z) := by
        have hcenter : Integrable (fun x ↦ q x - avg z) (P z) :=
          hz.sub (integrable_const _)
        have hlin : Integrable (fun x ↦ slope * (q x - avg z)) (P z) :=
          hcenter.const_mul slope
        change ∫ x, (fun _ : Ω ↦ psi (avg z)) x +
          (fun x ↦ slope * (q x - avg z)) x ∂(P z) = psi (avg z)
        rw [integral_add (integrable_const _) hlin, integral_const,
          integral_const_mul, integral_sub hz (integrable_const _), integral_const]
        simp only [probReal_univ, one_smul]
        change psi (avg z) + slope * (avg z - avg z) = psi (avg z)
        ring
  have hmiddle : (fun z ↦ psi (avg z)) ≤ᵐ[pi]
      fun z ↦ psi (gamma * avg z) := by
    filter_upwards [] with z
    exact hpsi_mono (havg_nonneg z) (by nlinarith [havg_nonneg z])
  have hlast : (fun z ↦ psi (gamma * avg z)) ≤ᵐ[pi]
      fun z ↦ psi (q z) := by
    filter_upwards [hsuper] with z hz
    exact hpsi_mono (mul_nonneg hgamma_nonneg (havg_nonneg z)) hz
  have hendpoints : ∫ z, boundedAvg z ∂pi = ∫ z, psi (q z) ∂pi := by
    have hcompInt : Integrable (psi ∘ q) (P ∘ₘ pi) := by
      simpa [hinv] using hpsiq_int
    have hjoint : Integrable (fun zz' : Ω × Ω ↦ psi (q zz'.2)) (pi ⊗ₘ P) :=
      (Measure.integrable_compProd_snd_iff
        hpsiq_meas.aestronglyMeasurable).2 hcompInt
    calc
      ∫ z, boundedAvg z ∂pi =
          ∫ zz', psi (q zz'.2) ∂(pi ⊗ₘ P) := by
            rw [Measure.integral_compProd hjoint]
      _ = ∫ z, psi (q z) ∂(P ∘ₘ pi) := by
            rw [← Measure.snd_compProd pi P, Measure.snd]
            exact (integral_map measurable_snd.aemeasurable
              hpsiq_meas.aestronglyMeasurable).symm
      _ = ∫ z, psi (q z) ∂pi := by rw [hinv]
  have heqMiddle : (fun z ↦ psi (avg z)) =ᵐ[pi]
      fun z ↦ psi (gamma * avg z) := by
    apply (integral_eq_iff_of_ae_le havgPsi_int hgammaAvgPsi_int hmiddle).1
    have h0 := integral_mono_ae hboundedAvg_int havgPsi_int hjensen
    have h1 := integral_mono_ae havgPsi_int hgammaAvgPsi_int hmiddle
    have h2 := integral_mono_ae hgammaAvgPsi_int hpsiq_int hlast
    change (∫ x, psi (gamma * avg x) ∂pi) ≤ ∫ x, psi (q x) ∂pi at h2
    rw [← hendpoints] at h2
    linarith
  obtain ⟨z, hzpos, hzeq⟩ := (havg_pos.and heqMiddle).exists
  dsimp [psi] at hzeq
  have hdenm : 0 < 1 + avg z := by linarith
  have hdengm : 0 < 1 + gamma * avg z := by positivity
  rw [div_eq_div_iff hdenm.ne' hdengm.ne'] at hzeq
  nlinarith

end
end Aiyagari1994.M07A3
