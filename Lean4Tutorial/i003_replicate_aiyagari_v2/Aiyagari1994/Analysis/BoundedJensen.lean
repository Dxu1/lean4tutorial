import Mathlib.Probability.Kernel.Composition.IntegralCompProd
import Mathlib.Probability.Kernel.Composition.MeasureComp
import Mathlib.Util.AssertNoSorry

/-! N02: a bounded strict-Jensen argument under a stationary law. -/
open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- N02: let `q` be a positive measurable real function whose one-step conditional means are
finite, and suppose `q ≥ γ Pq` under a stationary probability law, with `γ ≥ 1`.  Then
`γ = 1`, and `q` agrees at the two ends of a stationary one-step transition almost surely.

The conclusion is obtained by applying the bounded transform `ψ(x) = x / (1 + x)` and the
exact tangent-gap identity

`ψ(m) + (x - m) / (1 + m)^2 - ψ(x) = (x - m)^2 / ((1 + m)^2 (1 + x))`.

Only the displayed conditional integrability is assumed; in particular, no integrability of
`q` under `π` is required. -/
theorem stationary_bounded_jensen_equality
    {Ω : Type*} [MeasurableSpace Ω]
    (P : Kernel Ω Ω) [IsMarkovKernel P]
    (π : Measure Ω) [IsProbabilityMeasure π] (q : Ω → ℝ) (γ : ℝ)
    (hq : Measurable q) (hqpos : ∀ z, 0 < q z)
    (hcond : ∀ z, Integrable q (P z))
    (hγ : 1 ≤ γ)
    (hsuper : ∀ z, γ * ∫ z', q z' ∂(P z) ≤ q z)
    (hinv : P ∘ₘ π = π) :
    γ = 1 ∧
      ∀ᵐ zz' ∂(π ⊗ₘ P), q zz'.2 = q zz'.1 := by
  let ψ : ℝ → ℝ := fun x ↦ x / (1 + x)
  let m : Ω → ℝ := fun z ↦ ∫ z', q z' ∂(P z)
  let e : Ω → ℝ := fun z ↦ ∫ z', ψ (q z') ∂(P z)
  have hψ_meas : Measurable ψ := by
    fun_prop
  have hψq_meas : Measurable (ψ ∘ q) := hψ_meas.comp hq
  have hm_meas : Measurable m := by
    simpa [m] using
      ((hq.comp measurable_snd).stronglyMeasurable.integral_kernel_prod_right
        (f := fun _ z' ↦ q z') (κ := P)).measurable
  have he_meas : Measurable e := by
    simpa [e, Function.comp_def] using
      ((hψq_meas.comp measurable_snd).stronglyMeasurable.integral_kernel_prod_right
        (f := fun _ z' ↦ ψ (q z')) (κ := P)).measurable
  have hψ_nonneg : ∀ x : ℝ, 0 ≤ x → 0 ≤ ψ x := by
    intro x hx
    dsimp [ψ]
    positivity
  have hψ_le_one : ∀ x : ℝ, 0 ≤ x → ψ x ≤ 1 := by
    intro x hx
    dsimp [ψ]
    rw [div_le_one (by positivity : 0 < 1 + x)]
    linarith
  have hψq_int : Integrable (ψ ∘ q) π := by
    refine Integrable.mono' (integrable_const (1 : ℝ)) hψq_meas.aestronglyMeasurable ?_
    filter_upwards [] with z
    change ‖ψ (q z)‖ ≤ 1
    rw [Real.norm_of_nonneg (hψ_nonneg _ (hqpos z).le)]
    exact hψ_le_one _ (hqpos z).le
  have hψq_cond : ∀ z, Integrable (ψ ∘ q) (P z) := by
    intro z
    refine Integrable.mono' (integrable_const (1 : ℝ))
      hψq_meas.aestronglyMeasurable ?_
    filter_upwards [] with z'
    change ‖ψ (q z')‖ ≤ 1
    rw [Real.norm_of_nonneg (hψ_nonneg _ (hqpos z').le)]
    exact hψ_le_one _ (hqpos z').le
  have hm_pos : ∀ z, 0 < m z := by
    intro z
    change 0 < ∫ z', q z' ∂(P z)
    rw [integral_pos_iff_support_of_nonneg (fun z' ↦ (hqpos z').le) (hcond z)]
    have hsupp : Function.support q = Set.univ := by
      ext z'
      simp [Function.mem_support, (hqpos z').ne']
    rw [hsupp, measure_univ]
    exact zero_lt_one
  have he_nonneg : ∀ z, 0 ≤ e z := by
    intro z
    exact integral_nonneg fun z' ↦ hψ_nonneg _ (hqpos z').le
  have he_le_one : ∀ z, e z ≤ 1 := by
    intro z
    calc
      e z ≤ ∫ _ : Ω, (1 : ℝ) ∂(P z) := integral_mono (hψq_cond z) (integrable_const 1)
        (fun z' ↦ hψ_le_one _ (hqpos z').le)
      _ = 1 := by simp
  have he_int : Integrable e π := by
    refine Integrable.mono' (integrable_const (1 : ℝ)) he_meas.aestronglyMeasurable ?_
    filter_upwards [] with z
    rw [Real.norm_of_nonneg (he_nonneg z)]
    exact he_le_one z
  have hmψ_int : Integrable (fun z ↦ ψ (m z)) π := by
    refine Integrable.mono' (integrable_const (1 : ℝ))
      (hψ_meas.comp hm_meas).aestronglyMeasurable ?_
    filter_upwards [] with z
    rw [Real.norm_of_nonneg (hψ_nonneg _ (hm_pos z).le)]
    exact hψ_le_one _ (hm_pos z).le
  have hγ_nonneg : 0 ≤ γ := le_trans (by norm_num) hγ
  have hγmψ_int : Integrable (fun z ↦ ψ (γ * m z)) π := by
    refine Integrable.mono' (integrable_const (1 : ℝ))
      (hψ_meas.comp (measurable_const.mul hm_meas)).aestronglyMeasurable ?_
    filter_upwards [] with z
    have hz : 0 ≤ γ * m z := mul_nonneg hγ_nonneg (hm_pos z).le
    rw [Real.norm_of_nonneg (hψ_nonneg _ hz)]
    exact hψ_le_one _ hz
  have hψ_mono : ∀ {x y : ℝ}, 0 ≤ x → x ≤ y → ψ x ≤ ψ y := by
    intro x y hx hxy
    dsimp [ψ]
    have hy : 0 ≤ y := hx.trans hxy
    rw [div_le_div_iff₀ (by linarith : 0 < 1 + x) (by linarith : 0 < 1 + y)]
    nlinarith
  have hjensen : ∀ z, e z ≤ ψ (m z) := by
    intro z
    let slope : ℝ := 1 / (1 + m z) ^ 2
    have htangent : ∀ x : ℝ, 0 ≤ x →
        ψ x ≤ ψ (m z) + slope * (x - m z) := by
      intro x hx
      have hm1 : 0 < 1 + m z := by linarith [hm_pos z]
      have hx1 : 0 < 1 + x := by linarith
      have hid : ψ (m z) + slope * (x - m z) - ψ x =
          (x - m z) ^ 2 / ((1 + m z) ^ 2 * (1 + x)) := by
        dsimp [ψ, slope]
        field_simp
        ring
      rw [← sub_nonneg]
      rw [hid]
      positivity
    calc
      e z ≤ ∫ x, (ψ (m z) + slope * (q x - m z)) ∂(P z) :=
        integral_mono (hψq_cond z)
          ((integrable_const _).add ((hcond z |>.sub (integrable_const _)).const_mul slope))
          (fun x ↦ htangent (q x) (hqpos x).le)
      _ = ψ (m z) := by
        have hconst : Integrable (fun _ : Ω ↦ ψ (m z)) (P z) := integrable_const _
        have hcenter : Integrable (fun x ↦ q x - m z) (P z) :=
          (hcond z).sub (integrable_const _)
        have hlin : Integrable (fun x ↦ slope * (q x - m z)) (P z) :=
          hcenter.const_mul slope
        change ∫ x, (fun _ : Ω ↦ ψ (m z)) x +
          (fun x ↦ slope * (q x - m z)) x ∂(P z) = ψ (m z)
        rw [integral_add (integrable_const _)
          hlin, integral_const,
          integral_const_mul, integral_sub (hcond z) (integrable_const _), integral_const]
        simp only [probReal_univ, one_smul]
        change ψ (m z) + slope * (m z - m z) = ψ (m z)
        ring
  have hchain₀ : ∀ z, e z ≤ ψ (m z) := hjensen
  have hchain₁ : ∀ z, ψ (m z) ≤ ψ (γ * m z) := by
    intro z
    exact hψ_mono (hm_pos z).le (by nlinarith [hm_pos z])
  have hchain₂ : ∀ z, ψ (γ * m z) ≤ ψ (q z) := by
    intro z
    exact hψ_mono (mul_nonneg hγ_nonneg (hm_pos z).le) (hsuper z)
  have hendpoints : ∫ z, e z ∂π = ∫ z, ψ (q z) ∂π := by
    have hcompInt : Integrable (ψ ∘ q) (P ∘ₘ π) := by
      simpa [hinv] using hψq_int
    have hjoint : Integrable (fun zz' : Ω × Ω ↦ ψ (q zz'.2))
        (π ⊗ₘ P) := by
      exact (Measure.integrable_compProd_snd_iff
        hψq_meas.aestronglyMeasurable).2 hcompInt
    calc
      ∫ z, e z ∂π =
          ∫ zz', ψ (q zz'.2) ∂(π ⊗ₘ P) := by
            rw [Measure.integral_compProd hjoint]
      _ = ∫ z, ψ (q z) ∂(P ∘ₘ π) := by
            rw [← Measure.snd_compProd π P, Measure.snd]
            exact (MeasureTheory.integral_map measurable_snd.aemeasurable
              hψq_meas.aestronglyMeasurable).symm
      _ = ∫ z, ψ (q z) ∂π := by rw [hinv]
  have heq₀ : e =ᵐ[π] fun z ↦ ψ (m z) := by
    apply (integral_eq_iff_of_ae_le he_int hmψ_int (Eventually.of_forall hchain₀)).1
    have h₀ := integral_mono he_int hmψ_int hchain₀
    have h₁ := integral_mono hmψ_int hγmψ_int hchain₁
    have h₂ := integral_mono hγmψ_int hψq_int hchain₂
    change (∫ x, ψ (γ * m x) ∂π) ≤ ∫ x, ψ (q x) ∂π at h₂
    rw [← hendpoints] at h₂
    linarith
  have heq₁ : (fun z ↦ ψ (m z)) =ᵐ[π] fun z ↦ ψ (γ * m z) := by
    apply (integral_eq_iff_of_ae_le hmψ_int hγmψ_int
      (Eventually.of_forall hchain₁)).1
    have h₀ := integral_mono he_int hmψ_int hchain₀
    have h₁ := integral_mono hmψ_int hγmψ_int hchain₁
    have h₂ := integral_mono hγmψ_int hψq_int hchain₂
    change (∫ x, ψ (γ * m x) ∂π) ≤ ∫ x, ψ (q x) ∂π at h₂
    rw [← hendpoints] at h₂
    linarith
  have hγeq : γ = 1 := by
    obtain ⟨z, hz⟩ := heq₁.exists
    have hmz := hm_pos z
    dsimp [ψ] at hz
    have hdenm : 0 < 1 + m z := by linarith
    have hdengm : 0 < 1 + γ * m z := by positivity
    rw [div_eq_div_iff hdenm.ne' hdengm.ne'] at hz
    nlinarith
  subst γ
  have heq_current : (fun z ↦ ψ (m z)) =ᵐ[π] fun z ↦ ψ (q z) := by
    have hle : (fun z ↦ ψ (m z)) ≤ᵐ[π] (ψ ∘ q) := by
      filter_upwards [] with z
      simpa using hchain₂ z
    apply (integral_eq_iff_of_ae_le hmψ_int hψq_int hle).1
    change (∫ z, ψ (m z) ∂π) = ∫ z, ψ (q z) ∂π
    rw [← hendpoints]
    exact integral_congr_ae heq₀.symm
  have hcurrent : m =ᵐ[π] q := by
    filter_upwards [heq_current] with z hz
    dsimp [ψ] at hz
    have hmz : 0 < m z := hm_pos z
    have hqz : 0 < q z := hqpos z
    rw [div_eq_div_iff (by linarith : (1 + m z) ≠ 0) (by linarith : (1 + q z) ≠ 0)] at hz
    nlinarith
  refine ⟨rfl, ?_⟩
  apply Measure.ae_compProd_of_ae_ae
  · exact measurableSet_eq_fun (hq.comp measurable_snd) (hq.comp measurable_fst)
  · filter_upwards [heq₀, hcurrent] with z hzJ hzcurrent
    have hgap_int : Integrable
        (fun x ↦ (q x - m z) ^ 2 / ((1 + m z) ^ 2 * (1 + q x))) (P z) := by
      have hleft : Integrable
          (fun x ↦ ψ (m z) + (q x - m z) / (1 + m z) ^ 2 - ψ (q x)) (P z) := by
        exact ((integrable_const _).add ((hcond z).sub (integrable_const _) |>.div_const _)).sub
          (hψq_cond z)
      refine hleft.congr ?_
      filter_upwards [] with x
      have hm1 : 1 + m z ≠ 0 := ne_of_gt (by linarith [hm_pos z])
      have hq1 : 1 + q x ≠ 0 := ne_of_gt (by linarith [hqpos x])
      dsimp [ψ]
      field_simp [hm1, hq1]
      ring
    have hgap_nonneg : ∀ x, 0 ≤ (q x - m z) ^ 2 / ((1 + m z) ^ 2 * (1 + q x)) := by
      intro x
      exact div_nonneg (sq_nonneg _) (mul_nonneg (sq_nonneg _) (by linarith [hqpos x]))
    have hgap_zero : ∫ x, (q x - m z) ^ 2 / ((1 + m z) ^ 2 * (1 + q x)) ∂(P z) = 0 := by
      have hidentity : (∫ x,
          (q x - m z) ^ 2 / ((1 + m z) ^ 2 * (1 + q x)) ∂(P z)) =
          ψ (m z) - e z := by
        calc
          _ = ∫ x, (ψ (m z) + (q x - m z) / (1 + m z) ^ 2 - ψ (q x))
                ∂(P z) := by
              apply integral_congr_ae
              filter_upwards [] with x
              have hm1 : 1 + m z ≠ 0 := ne_of_gt (by linarith [hm_pos z])
              have hq1 : 1 + q x ≠ 0 := ne_of_gt (by linarith [hqpos x])
              dsimp [ψ]
              field_simp [hm1, hq1]
              ring
          _ = ψ (m z) - e z := by
              have hconst : Integrable (fun _ : Ω ↦ ψ (m z)) (P z) := integrable_const _
              have hcenter : Integrable (fun x ↦ q x - m z) (P z) :=
                (hcond z).sub (integrable_const _)
              have hdiv : Integrable (fun x ↦ (q x - m z) / (1 + m z) ^ 2) (P z) :=
                hcenter.div_const _
              have hsum : Integrable (fun x ↦ ψ (m z) +
                  (q x - m z) / (1 + m z) ^ 2) (P z) := hconst.add hdiv
              change ∫ x, (fun x ↦ ψ (m z) +
                (q x - m z) / (1 + m z) ^ 2) x -
                (ψ ∘ q) x ∂(P z) = ψ (m z) - e z
              rw [integral_sub hsum (hψq_cond z),
                integral_add hconst hdiv, integral_const,
                integral_div, integral_sub (hcond z) (integrable_const _), integral_const]
              simp only [probReal_univ, one_smul]
              change ψ (m z) + (m z - m z) / (1 + m z) ^ 2 - e z = ψ (m z) - e z
              ring
      rw [hidentity, hzJ, sub_self]
    have hqeqm : ∀ᵐ x ∂(P z), q x = m z := by
      have hzero := (integral_eq_zero_iff_of_nonneg
        hgap_nonneg hgap_int).1 hgap_zero
      filter_upwards [hzero] with x hx
      simp only [Pi.zero_apply] at hx
      have hden : 0 < (1 + m z) ^ 2 * (1 + q x) :=
        mul_pos (sq_pos_of_pos (by linarith [hm_pos z])) (by linarith [hqpos x])
      rw [div_eq_zero_iff] at hx
      exact sub_eq_zero.mp (sq_eq_zero_iff.mp (hx.resolve_right hden.ne'))
    filter_upwards [hqeqm] with x hx
    exact hx.trans hzcurrent

end
end Aiyagari1994
