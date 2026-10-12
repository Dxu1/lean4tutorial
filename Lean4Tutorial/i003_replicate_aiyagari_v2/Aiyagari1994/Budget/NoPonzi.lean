import Aiyagari1994.Analysis.M10A1.BudgetTelescope

/-! NP01: finite discounted original-asset budget identity. -/

namespace Aiyagari1994

/-- NP01.  Every finite original-budget path satisfies the exact discounted telescope. -/
theorem discounted_budget_telescope
    (R w : ℝ) (a c labor : ℕ → ℝ) (hR : 0 < R)
    (hbudget : ∀ t : ℕ, c t + a (t + 1) = R * a t + w * labor t)
    (T : ℕ) :
    ∑ t ∈ Finset.range (T + 1), R⁻¹ ^ t * c t =
      R * a 0 + ∑ t ∈ Finset.range (T + 1), R⁻¹ ^ t * (w * labor t) -
        R⁻¹ ^ T * a (T + 1) :=
  M10A1.discounted_budget_telescope_core R w a c labor hR hbudget T

end Aiyagari1994
