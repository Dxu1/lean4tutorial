import Aiyagari1994.Budget.Normalization

/-! Gate-local implementation of the finite original-asset budget telescope. -/

open Finset

namespace Aiyagari1994.M10A1

/-- The original one-period budgets telescope after discounting.  The terminal asset at date
`T + 1` is discounted by `T`, because the date-`t` budget has resources `R * a t`. -/
theorem discounted_budget_telescope_core
    (R w : ℝ) (a c labor : ℕ → ℝ) (hR : 0 < R)
    (hbudget : ∀ t : ℕ, c t + a (t + 1) = R * a t + w * labor t)
    (T : ℕ) :
    ∑ t ∈ range (T + 1), R⁻¹ ^ t * c t =
      R * a 0 + ∑ t ∈ range (T + 1), R⁻¹ ^ t * (w * labor t) -
        R⁻¹ ^ T * a (T + 1) := by
  induction T with
  | zero =>
      simp only [zero_add, sum_range_one, pow_zero, one_mul]
      linarith [hbudget 0]
  | succ T ih =>
      rw [Finset.sum_range_succ (fun t => R⁻¹ ^ t * c t) (T + 1)]
      rw [Finset.sum_range_succ (fun t => R⁻¹ ^ t * (w * labor t)) (T + 1)]
      rw [ih]
      have hRne : R ≠ 0 := ne_of_gt hR
      have hscale : R⁻¹ ^ (T + 1) * R = R⁻¹ ^ T := by
        rw [pow_succ]
        field_simp
      have hstep := hbudget (T + 1)
      rw [show T + 1 + 1 = T + 2 by omega] at hstep
      have hweighted :
          R⁻¹ ^ (T + 1) * c (T + 1) + R⁻¹ ^ (T + 1) * a (T + 2) =
            R⁻¹ ^ T * a (T + 1) +
              R⁻¹ ^ (T + 1) * (w * labor (T + 1)) := by
        calc
          _ = R⁻¹ ^ (T + 1) * (c (T + 1) + a (T + 2)) := by ring
          _ = R⁻¹ ^ (T + 1) * (R * a (T + 1) + w * labor (T + 1)) := by
            rw [hstep]
          _ = (R⁻¹ ^ (T + 1) * R) * a (T + 1) +
                R⁻¹ ^ (T + 1) * (w * labor (T + 1)) := by ring
          _ = _ := by rw [hscale]
      rw [show T + 1 + 1 = T + 2 by omega]
      linarith

end Aiyagari1994.M10A1
