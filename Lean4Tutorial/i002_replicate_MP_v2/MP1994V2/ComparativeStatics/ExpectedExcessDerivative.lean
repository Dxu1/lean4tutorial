import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.ReducedAnalytic

/-!
# MP1994 v2 Appendix: expected-excess calculus

Atomlessness makes the induced CDF continuous. The interval-integral FTC then
gives `H'(d) = -(1-F(d))` without adding a differentiability assumption.
-/

open MeasureTheory Set Filter
open scoped Interval
open scoped Topology

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- Atomlessness implies continuity of the CDF induced by the shock measure. -/
theorem cdf_continuous (D : ShockAssumptions P) : Continuous P.cdf := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  letI : NullSingletonClass P.shock := D.noAtoms
  have hOne : Integrable (fun _ : ℝ => (1 : ℝ)) P.shock := integrable_const 1
  have hPrim : Continuous (fun x : ℝ => ∫ y in (0 : ℝ)..x, (1 : ℝ) ∂P.shock) :=
    hOne.continuous_primitive 0
  have hEq : P.cdf = fun x : ℝ => P.cdf 0 + ∫ y in (0 : ℝ)..x, (1 : ℝ) ∂P.shock := by
    funext x
    have hDiff :
        (∫ y in Iic x, (1 : ℝ) ∂P.shock) -
            (∫ y in Iic (0 : ℝ), (1 : ℝ) ∂P.shock) =
          ∫ y in (0 : ℝ)..x, (1 : ℝ) ∂P.shock :=
      intervalIntegral.integral_Iic_sub_Iic hOne.integrableOn hOne.integrableOn
    simp only [integral_const, smul_eq_mul, mul_one] at hDiff
    unfold cdf
    simpa [measureReal_def, sub_eq_iff_eq_add, add_comm] using hDiff
  rw [hEq]
  exact continuous_const.add hPrim

theorem cdf_continuousAt (D : ShockAssumptions P) (d : ℝ) :
    ContinuousAt P.cdf d :=
  (P.cdf_continuous D).continuousAt

/-- Appendix derivative `H'(d)=-(1-F(d))`. -/
theorem hasDerivAt_expectedExcess
    (D : ShockAssumptions P) {d : ℝ} (hd : d < P.epsUpper) :
    HasDerivAt P.expectedExcess (-(1 - P.cdf d)) d := by
  let f : ℝ → ℝ := fun x => 1 - P.cdf x
  have hfCont : Continuous f := continuous_const.sub (P.cdf_continuous D)
  have hTail : HasDerivAt P.tailOptionValue (-(1 - P.cdf d)) d := by
    unfold tailOptionValue
    exact intervalIntegral.integral_hasDerivAt_left
      (hfCont.intervalIntegrable d P.epsUpper)
      hfCont.stronglyMeasurable.stronglyMeasurableAtFilter
      hfCont.continuousAt
  have hEq : P.expectedExcess =ᶠ[𝓝 d] P.tailOptionValue := by
    filter_upwards [eventually_lt_nhds hd] with x hx
    exact P.expectedExcess_eq_tailOptionValue D hx.le
  exact hTail.congr_of_eventuallyEq hEq

/-- Equation (A4), weak form. -/
theorem expectedExcess_le_epsUpper_sub
    (D : ShockAssumptions P) {d : ℝ} (hd : d ≤ P.epsUpper) :
    P.expectedExcess d ≤ P.epsUpper - d := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hUpper : ∀ᵐ x ∂P.shock, x ≤ P.epsUpper := by
    rw [ae_iff]
    have hset : {x : ℝ | ¬x ≤ P.epsUpper} = Ioi P.epsUpper := by
      ext x
      simp
    rw [hset]
    exact D.upperSupport
  have hInt := P.positivePart_sub_integrable D d
  have hConst : Integrable (fun _ : ℝ => P.epsUpper - d) P.shock :=
    integrable_const _
  have hLe : (fun x : ℝ => positivePart (x - d)) ≤ᵐ[P.shock]
      (fun _ => P.epsUpper - d) := by
    filter_upwards [hUpper] with x hx
    unfold positivePart
    exact max_le (by linarith) (sub_nonneg.mpr hd)
  have h := integral_mono_ae hInt hConst hLe
  simpa [expectedExcess] using h

/-- Strict Appendix tail gap. Atomlessness rules out all probability mass at
the almost-sure upper bound. -/
theorem expectedExcess_lt_epsUpper_sub
    (D : ShockAssumptions P) {d : ℝ} (hd : d < P.epsUpper) :
    P.expectedExcess d < P.epsUpper - d := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  letI : NullSingletonClass P.shock := D.noAtoms
  have hUpper : ∀ᵐ x ∂P.shock, x ≤ P.epsUpper := by
    rw [ae_iff]
    have hset : {x : ℝ | ¬x ≤ P.epsUpper} = Ioi P.epsUpper := by
      ext x
      simp
    rw [hset]
    exact D.upperSupport
  have hStrict : ∀ᵐ x ∂P.shock,
      positivePart (x - d) < P.epsUpper - d := by
    filter_upwards [hUpper, P.shock.ae_ne P.epsUpper] with x hx hne
    have hxu : x < P.epsUpper := lt_of_le_of_ne hx hne
    unfold positivePart
    rw [max_lt_iff]
    exact ⟨by linarith, sub_pos.mpr hd⟩
  have hInt := P.positivePart_sub_integrable D d
  have hConst : Integrable (fun _ : ℝ => P.epsUpper - d) P.shock :=
    integrable_const _
  have hLe : (fun x : ℝ => positivePart (x - d)) ≤ᵐ[P.shock]
      (fun _ => P.epsUpper - d) :=
    hStrict.mono fun _ hx => hx.le
  have hWeak := integral_mono_ae hInt hConst hLe
  have hNe :
      (∫ x, positivePart (x - d) ∂P.shock) ≠
        ∫ _ : ℝ, P.epsUpper - d ∂P.shock := by
    intro hEq
    have hAEeq := (integral_eq_iff_of_ae_le hInt hConst hLe).1 hEq
    have hFalse : False := by
      rcases (hStrict.and hAEeq).exists with ⟨x, hx, heq⟩
      exact (ne_of_lt hx) heq
    exact hFalse.elim
  have hLt :
      (∫ x, positivePart (x - d) ∂P.shock) <
        ∫ _ : ℝ, P.epsUpper - d ∂P.shock :=
    lt_of_le_of_ne hWeak hNe
  simpa [expectedExcess] using hLt

end Primitives

end MP1994V2
