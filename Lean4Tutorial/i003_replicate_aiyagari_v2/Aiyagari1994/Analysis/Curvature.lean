import Aiyagari1994.Analysis.M04B.PowerMarginal

open Set

namespace Aiyagari1994

/-- Eventual bounded relative risk aversion bounds ratios of marginal utility by a power. -/
theorem marginalUtility_ratio_bound (m : HouseholdPrimitives)
    (hs : UtilitySmooth m.utility) (hc : UtilityCurvature m.utility) :
    ∃ n : ℕ, 0 < n ∧ ∃ C > (0 : ℝ), ∀ ⦃c₁ c₂ : ℝ⦄,
      C ≤ c₁ → c₁ ≤ c₂ →
        deriv m.utility.utility c₁ / deriv m.utility.utility c₂ ≤ (c₂ / c₁) ^ n := by
  obtain ⟨n, hn, C, hC, hmono⟩ := power_mul_deriv_monotoneOn hs hc
  refine ⟨n, hn, C, hC, fun {c₁ c₂} hc₁ h₁₂ => ?_⟩
  have hc₁pos : 0 < c₁ := hC.trans_le hc₁
  have hc₂pos : 0 < c₂ := hc₁pos.trans_le h₁₂
  have hu₁pos : 0 < deriv m.utility.utility c₁ := hs.marginal_pos c₁ hc₁pos
  have hu₂pos : 0 < deriv m.utility.utility c₂ := hs.marginal_pos c₂ hc₂pos
  have hpower := hmono hc₁ (hc₁.trans h₁₂) h₁₂
  rw [div_pow]
  rw [div_le_iff₀ hu₂pos, div_eq_mul_inv]
  field_simp
  nlinarith [mul_pos (pow_pos hc₁pos n) hu₂pos]

end Aiyagari1994
