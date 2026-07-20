import Mathlib

noncomputable section

-- Suppose Solow model is such that f(k) = A√k
-- And with full depreciation, k' = sA√k
def transition (s A k : ℝ) : ℝ :=
  s * A * Real.sqrt k

theorem solow_unique_positive_ss
    {s A k : ℝ}
    (hs : 0 < s)
    (hA : 0 < A)
    (hk : 0 < k)
    (hss : transition s A k = k) :
    k = (s * A)^2 := by
  unfold transition at hss

  -- Economically, positive capital means that its square root is also positive.
  have hsqrt_pos : 0 < Real.sqrt k := Real.sqrt_pos.2 hk

  -- Squaring the nonnegative square root recovers the capital stock k.
  have hsqrt_sq : (Real.sqrt k)^2 = k := by
    rw [Real.sq_sqrt (le_of_lt hk)]

  -- The steady-state equation and sqrt(k)^2 = k imply
  -- sqrt(k) * (sqrt(k) - sA) = 0.
  have hprod : Real.sqrt k * (Real.sqrt k - s * A) = 0 := by
    calc
      Real.sqrt k * (Real.sqrt k - s * A) =
          (Real.sqrt k)^2 - s * A * Real.sqrt k := by ring
      _ = 0 := by rw [hsqrt_sq, hss]; ring

  -- Since sqrt(k) is positive, the other factor must vanish: sqrt(k) = sA.
  have hsqrt_eq : Real.sqrt k = s * A := by
    have hdiff : Real.sqrt k - s * A = 0 :=
      (mul_eq_zero.mp hprod).resolve_left (ne_of_gt hsqrt_pos)
    have hsA_pos : 0 < s * A := mul_pos hs hA
    nlinarith

  -- Therefore k = sqrt(k)^2 = (sA)^2.
  calc
    k = (Real.sqrt k)^2 := hsqrt_sq.symm
    _ = (s * A)^2 := by rw [hsqrt_eq]
