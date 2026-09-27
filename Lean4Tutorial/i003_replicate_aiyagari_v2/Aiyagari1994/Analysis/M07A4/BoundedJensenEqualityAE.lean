import Aiyagari1994.Analysis.BoundedJensen

/-! Gate-local almost-everywhere critical bounded-Jensen equality. -/
open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal ProbabilityTheory
namespace Aiyagari1994.M07A4
noncomputable section

/-- At the critical coefficient, the bounded-Jensen argument only needs conditional
integrability and superharmonicity almost everywhere under the invariant law. -/
theorem stationary_bounded_jensen_ae_equality
    {Ω : Type*} [MeasurableSpace Ω]
    (P : Kernel Ω Ω) [IsMarkovKernel P]
    (pi : Measure Ω) [IsProbabilityMeasure pi] (q : Ω → ℝ)
    (hq : Measurable q) (hqpos : ∀ z, 0 < q z)
    (hcond : ∀ᵐ z ∂pi, Integrable q (P z))
    (hsuper : ∀ᵐ z ∂pi, ∫ z', q z' ∂(P z) ≤ q z)
    (hinv : P ∘ₘ pi = pi) :
    ∀ᵐ zz' ∂(pi ⊗ₘ P), q zz'.2 = q zz'.1 := by
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
  have hpsi_mono : ∀ {x y : ℝ}, 0 ≤ x → x ≤ y → psi x ≤ psi y := by
    intro x y hx hxy
    dsimp [psi]
    have hy : 0 ≤ y := hx.trans hxy
    rw [div_le_div_iff₀ (by linarith : 0 < 1 + x) (by linarith : 0 < 1 + y)]
    nlinarith
  have hjensen : ∀ᵐ z ∂pi, boundedAvg z ≤ psi (avg z) := by
    filter_upwards [hcond] with z hz
    let slopeAt : ℝ := 1 / (1 + avg z) ^ 2
    have htangent : ∀ x : ℝ, 0 ≤ x →
        psi x ≤ psi (avg z) + slopeAt * (x - avg z) := by
      intro x hx
      have hm1 : 0 < 1 + avg z := by linarith [havg_nonneg z]
      have hx1 : 0 < 1 + x := by linarith
      have hid : psi (avg z) + slopeAt * (x - avg z) - psi x =
          (x - avg z) ^ 2 / ((1 + avg z) ^ 2 * (1 + x)) := by
        dsimp [psi, slopeAt]
        field_simp
        ring
      rw [← sub_nonneg, hid]
      positivity
    calc
      boundedAvg z ≤ ∫ x, (psi (avg z) + slopeAt * (q x - avg z)) ∂(P z) :=
        integral_mono (hpsiq_cond z)
          ((integrable_const _).add ((hz.sub (integrable_const _)).const_mul slopeAt))
          (fun x ↦ htangent (q x) (hqpos x).le)
      _ = psi (avg z) := by
        have hcenter : Integrable (fun x ↦ q x - avg z) (P z) :=
          hz.sub (integrable_const _)
        have hlin : Integrable (fun x ↦ slopeAt * (q x - avg z)) (P z) :=
          hcenter.const_mul slopeAt
        change ∫ x, (fun _ : Ω ↦ psi (avg z)) x +
          (fun x ↦ slopeAt * (q x - avg z)) x ∂(P z) = psi (avg z)
        rw [integral_add (integrable_const _) hlin, integral_const,
          integral_const_mul, integral_sub hz (integrable_const _), integral_const]
        simp only [probReal_univ, one_smul]
        change psi (avg z) + slopeAt * (avg z - avg z) = psi (avg z)
        ring
  have hlast : (fun z ↦ psi (avg z)) ≤ᵐ[pi] fun z ↦ psi (q z) := by
    filter_upwards [hsuper] with z hz
    exact hpsi_mono (havg_nonneg z) hz
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
  have heqJensen : boundedAvg =ᵐ[pi] fun z ↦ psi (avg z) := by
    apply (integral_eq_iff_of_ae_le hboundedAvg_int havgPsi_int hjensen).1
    have h0 := integral_mono_ae hboundedAvg_int havgPsi_int hjensen
    have h1 := integral_mono_ae havgPsi_int hpsiq_int hlast
    change (∫ z, psi (avg z) ∂pi) ≤ ∫ z, psi (q z) ∂pi at h1
    rw [← hendpoints] at h1
    linarith
  have heqCurrent : (fun z ↦ psi (avg z)) =ᵐ[pi] fun z ↦ psi (q z) := by
    apply (integral_eq_iff_of_ae_le havgPsi_int hpsiq_int hlast).1
    change (∫ z, psi (avg z) ∂pi) = ∫ z, psi (q z) ∂pi
    rw [← hendpoints]
    exact integral_congr_ae heqJensen.symm
  have hcurrent : avg =ᵐ[pi] q := by
    filter_upwards [havg_pos, heqCurrent] with z hzpos hzeq
    dsimp [psi] at hzeq
    have hqz := hqpos z
    rw [div_eq_div_iff (by linarith : (1 + avg z) ≠ 0)
      (by linarith : (1 + q z) ≠ 0)] at hzeq
    nlinarith
  apply Measure.ae_compProd_of_ae_ae
  · exact measurableSet_eq_fun (hq.comp measurable_snd) (hq.comp measurable_fst)
  · filter_upwards [hcond, heqJensen, hcurrent] with z hzInt hzJ hzCurrent
    have hgap_int : Integrable
        (fun x ↦ (q x - avg z) ^ 2 / ((1 + avg z) ^ 2 * (1 + q x))) (P z) := by
      have hleft : Integrable
          (fun x ↦ psi (avg z) + (q x - avg z) / (1 + avg z) ^ 2 - psi (q x))
          (P z) := by
        exact ((integrable_const _).add
          ((hzInt.sub (integrable_const _)).div_const _)).sub (hpsiq_cond z)
      refine hleft.congr ?_
      filter_upwards [] with x
      have hm1 : 1 + avg z ≠ 0 := ne_of_gt (by linarith [havg_nonneg z])
      have hq1 : 1 + q x ≠ 0 := ne_of_gt (by linarith [hqpos x])
      dsimp [psi]
      field_simp [hm1, hq1]
      ring
    have hgap_nonneg : ∀ x, 0 ≤
        (q x - avg z) ^ 2 / ((1 + avg z) ^ 2 * (1 + q x)) := by
      intro x
      exact div_nonneg (sq_nonneg _)
        (mul_nonneg (sq_nonneg _) (by linarith [hqpos x]))
    have hgap_zero : ∫ x, (q x - avg z) ^ 2 /
        ((1 + avg z) ^ 2 * (1 + q x)) ∂(P z) = 0 := by
      have hidentity : (∫ x, (q x - avg z) ^ 2 /
          ((1 + avg z) ^ 2 * (1 + q x)) ∂(P z)) = psi (avg z) - boundedAvg z := by
        calc
          _ = ∫ x, (psi (avg z) + (q x - avg z) / (1 + avg z) ^ 2 - psi (q x))
                ∂(P z) := by
              apply integral_congr_ae
              filter_upwards [] with x
              have hm1 : 1 + avg z ≠ 0 := ne_of_gt (by linarith [havg_nonneg z])
              have hq1 : 1 + q x ≠ 0 := ne_of_gt (by linarith [hqpos x])
              dsimp [psi]
              field_simp [hm1, hq1]
              ring
          _ = psi (avg z) - boundedAvg z := by
              have hconst : Integrable (fun _ : Ω ↦ psi (avg z)) (P z) := integrable_const _
              have hcenter : Integrable (fun x ↦ q x - avg z) (P z) :=
                hzInt.sub (integrable_const _)
              have hdiv : Integrable (fun x ↦ (q x - avg z) / (1 + avg z) ^ 2) (P z) :=
                hcenter.div_const _
              have hsum : Integrable (fun x ↦ psi (avg z) +
                  (q x - avg z) / (1 + avg z) ^ 2) (P z) := hconst.add hdiv
              change ∫ x, (fun x ↦ psi (avg z) +
                (q x - avg z) / (1 + avg z) ^ 2) x -
                (psi ∘ q) x ∂(P z) = psi (avg z) - boundedAvg z
              rw [integral_sub hsum (hpsiq_cond z), integral_add hconst hdiv,
                integral_const, integral_div, integral_sub hzInt (integrable_const _),
                integral_const]
              simp only [probReal_univ, one_smul]
              change psi (avg z) + (avg z - avg z) / (1 + avg z) ^ 2 -
                boundedAvg z = psi (avg z) - boundedAvg z
              ring
      rw [hidentity, hzJ, sub_self]
    have hzero := (integral_eq_zero_iff_of_nonneg hgap_nonneg hgap_int).1 hgap_zero
    filter_upwards [hzero] with x hx
    simp only [Pi.zero_apply] at hx
    have hden : 0 < (1 + avg z) ^ 2 * (1 + q x) :=
      mul_pos (sq_pos_of_pos (by linarith [havg_nonneg z])) (by linarith [hqpos x])
    have hsquare : (q x - avg z) ^ 2 = 0 := by
      rcases div_eq_zero_iff.mp hx with h | h
      · exact h
      · exact False.elim (hden.ne' h)
    have hqx : q x = avg z := by nlinarith [sq_nonneg (q x - avg z)]
    exact hqx.trans hzCurrent

end
end Aiyagari1994.M07A4
