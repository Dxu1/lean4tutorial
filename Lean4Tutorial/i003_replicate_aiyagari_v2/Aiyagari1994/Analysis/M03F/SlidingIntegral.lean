import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Slope
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus

/-! Bounds for a translated unit-interval integral. -/
open MeasureTheory Set
open scoped Interval

namespace Aiyagari1994

/-- Translating both endpoints of a unit integral has derivative equal to the
endpoint difference times the translation speed. -/
theorem sliding_unit_integral_hasDerivAt (f : ℝ → ℝ) (hf : Continuous f) (R : ℝ) :
    HasDerivAt (fun a : ℝ => ∫ x in (0 : ℝ)..1, f (R * a + x))
      (R * (f 1 - f 0)) 0 := by
  let F : ℝ → ℝ := fun u => ∫ x in (0 : ℝ)..u, f x
  have hF (u : ℝ) : HasDerivAt F (f u) u := by
    exact intervalIntegral.integral_hasDerivAt_right
      (hf.intervalIntegrable 0 u)
      hf.aestronglyMeasurable.stronglyMeasurableAtFilter hf.continuousAt
  have hiU := (hasDerivAt_const (x := (0 : ℝ)) (c := (1 : ℝ))).add
    (hasDerivAt_const_mul (x := (0 : ℝ)) R)
  have hu := (hF (((fun _ : ℝ => (1 : ℝ)) + (fun a : ℝ => R * a)) (0 : ℝ))).comp 0 hiU
  simp only [Function.comp_apply, Pi.add_apply, mul_zero, add_zero, zero_add] at hu
  have hiL := hasDerivAt_const_mul (x := (0 : ℝ)) R
  have hl := (hF ((fun a : ℝ => R * a) 0)).comp 0 hiL
  simp only [Function.comp_apply, mul_zero] at hl
  have hsub := hu.sub hl
  have heq :
      (F ∘ ((fun _ : ℝ => (1 : ℝ)) + (fun a : ℝ => R * a))) -
        (F ∘ (fun a : ℝ => R * a)) =
      (fun a : ℝ => ∫ x in (0 : ℝ)..1, f (R * a + x)) := by
    funext a
    have hadd := intervalIntegral.integral_add_adjacent_intervals (μ := volume)
      (hf.intervalIntegrable (0 : ℝ) (R * a))
      (hf.intervalIntegrable (R * a) (1 + R * a))
    have hshift := intervalIntegral.integral_comp_add_right
      (a := (0 : ℝ)) (b := (1 : ℝ)) f (R * a)
    simp only [Pi.sub_apply, Function.comp_apply, Pi.add_apply]
    calc
      F (1 + R * a) - F (R * a) = ∫ x in R * a..1 + R * a, f x := by
        dsimp [F]
        linarith
      _ = ∫ x in (0 : ℝ)..1, f (x + R * a) := by simpa using hshift.symm
      _ = ∫ x in (0 : ℝ)..1, f (R * a + x) := by
        apply intervalIntegral.integral_congr
        intro x _
        simp [add_comm]
  rw [hasDerivAt_iff_tendsto_slope_zero]
  have ht := hsub.tendsto_slope_zero
  rw [heq] at ht
  simpa [mul_sub, mul_comm] using ht

/-- A nonnegative function bounded by `C` gains at most `C * h` when its
unit integration window is shifted to the right by `h`. -/
theorem sliding_unit_integral_sub_le {f : ℝ → ℝ} {C h : ℝ}
    (hf : Continuous f) (hC : ∀ x, 0 ≤ f x ∧ f x ≤ C) (hh : 0 ≤ h) :
    (∫ x in (0 : ℝ)..1, f (x + h)) - ∫ x in (0 : ℝ)..1, f x ≤ C * h := by
  have hi (a b : ℝ) : IntervalIntegrable f volume a b :=
    hf.intervalIntegrable a b
  have hshift : (∫ x in (0 : ℝ)..1, f (x + h)) = ∫ x in h..1 + h, f x := by
    simpa using intervalIntegral.integral_comp_add_right f h
  have hsplit₁ : (∫ x in h..1 + h, f x) =
      (∫ x in h..1, f x) + ∫ x in 1..1 + h, f x := by
    exact (intervalIntegral.integral_add_adjacent_intervals (hi h 1) (hi 1 (1 + h))).symm
  have hsplit₀ : (∫ x in (0 : ℝ)..1, f x) =
      (∫ x in (0 : ℝ)..h, f x) + ∫ x in h..1, f x := by
    exact (intervalIntegral.integral_add_adjacent_intervals (hi 0 h) (hi h 1)).symm
  have hlo : 0 ≤ ∫ x in (0 : ℝ)..h, f x := by
    exact intervalIntegral.integral_nonneg hh (fun x _ => (hC x).1)
  have hhi : (∫ x in (1 : ℝ)..1 + h, f x) ≤ C * h := by
    calc
      _ ≤ ∫ _x in (1 : ℝ)..1 + h, C :=
        intervalIntegral.integral_mono_on (by linarith) (hi 1 (1 + h))
          intervalIntegrable_const (fun x _ => (hC x).2)
      _ = C * h := by simp [intervalIntegral.integral_const, mul_comm]
  rw [hshift, hsplit₁, hsplit₀]
  linarith

end Aiyagari1994
