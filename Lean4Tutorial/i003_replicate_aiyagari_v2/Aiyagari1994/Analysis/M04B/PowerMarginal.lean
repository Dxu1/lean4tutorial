import Aiyagari1994.Primitives.Basic
import Mathlib.Analysis.Calculus.ContDiff.Deriv
import Mathlib.Analysis.Calculus.Deriv.Pow

open Set

namespace Aiyagari1994

/-- An eventual relative-risk-aversion bound makes a sufficiently high integer power times
the marginal nondecreasing. -/
theorem power_mul_deriv_monotoneOn {u : UtilityData} (hs : UtilitySmooth u)
    (hc : UtilityCurvature u) :
    ∃ n : ℕ, 0 < n ∧ ∃ C > (0 : ℝ),
      MonotoneOn (fun c : ℝ => c ^ n * deriv u.utility c) (Ici C) := by
  obtain ⟨C, hC, M, hM⟩ := hc.risk_bound
  obtain ⟨n, hn⟩ := exists_nat_gt (max M 0)
  have hnpos : 0 < n := by
    exact_mod_cast (lt_of_le_of_lt (le_max_right M 0) hn)
  refine ⟨n, hnpos, C, hC, ?_⟩
  apply monotoneOn_of_deriv_nonneg (convex_Ici C)
  · exact (continuousOn_pow n).mul
      ((hc.smooth.continuousOn_deriv_of_isOpen isOpen_Ioi (by norm_num)).mono
        (fun x hx => hC.trans_le hx))
  · intro x hx
    have hxC : C < x := by simpa using hx
    have hx0 : 0 < x := hC.trans hxC
    have hdOn : DifferentiableOn ℝ (deriv u.utility) (Ioi 0) :=
      ((hc.smooth.deriv_of_isOpen isOpen_Ioi (by norm_num) :
        ContDiffOn ℝ 1 (deriv u.utility) (Ioi 0))).differentiableOn (by norm_num)
    have hu' : DifferentiableAt ℝ (deriv u.utility) x :=
      (hdOn x hx0).differentiableAt (Ioi_mem_nhds hx0)
    exact ((differentiableAt_pow n).mul hu').differentiableWithinAt
  · intro x hx
    have hxC : C < x := by simpa using hx
    have hx0 : 0 < x := hC.trans hxC
    have hupos : 0 < deriv u.utility x := hs.marginal_pos x hx0
    have hcurv := hM x hxC.le
    have hMn : M < (n : ℝ) := lt_of_le_of_lt (le_max_left M 0) hn
    have hcore : 0 ≤ (n : ℝ) * deriv u.utility x + x * deriv (deriv u.utility) x := by
      rw [div_le_iff₀ hupos] at hcurv
      nlinarith
    have hpow : 0 ≤ x ^ (n - 1) := (pow_nonneg hx0.le _)
    have hdOn : DifferentiableOn ℝ (deriv u.utility) (Ioi 0) :=
      ((hc.smooth.deriv_of_isOpen isOpen_Ioi (by norm_num) :
        ContDiffOn ℝ 1 (deriv u.utility) (Ioi 0))).differentiableOn (by norm_num)
    have hderiv_u : HasDerivAt (deriv u.utility) (deriv (deriv u.utility) x) x :=
      ((hdOn x hx0).differentiableAt (Ioi_mem_nhds hx0)).hasDerivAt
    rw [show deriv (fun c : ℝ => c ^ n * deriv u.utility c) x =
        (n : ℝ) * x ^ (n - 1) * deriv u.utility x +
          x ^ n * deriv (deriv u.utility) x by
      exact ((hasDerivAt_pow n x).mul hderiv_u).deriv]
    have hn_one : 1 ≤ n := hnpos
    have hpow_eq : x ^ n = x ^ (n - 1) * x := by
      rw [← pow_succ, Nat.sub_add_cancel hn_one]
    rw [show (n : ℝ) * x ^ (n - 1) * deriv u.utility x +
        x ^ n * deriv (deriv u.utility) x =
        x ^ (n - 1) * ((n : ℝ) * deriv u.utility x +
          x * deriv (deriv u.utility) x) by
      rw [hpow_eq]
      ring]
    positivity

end Aiyagari1994
