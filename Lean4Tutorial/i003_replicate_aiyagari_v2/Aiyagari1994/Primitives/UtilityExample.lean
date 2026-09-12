import Aiyagari1994.Primitives.Basic
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Pow
open Set Filter
open scoped Topology
namespace Aiyagari1994

noncomputable def witnessUtility : UtilityData := ⟨fun c => c/(1+c)⟩

theorem witness_utility_continuous : ContinuousOn witnessUtility.utility (Ici 0) := by
  apply continuousOn_id.div (continuousOn_const.add continuousOn_id)
  intro c hc
  change 0 ≤ c at hc
  dsimp
  linarith

theorem witness_utility_bounds (c : ℝ) (hc : 0 ≤ c) :
    0 ≤ witnessUtility.utility c ∧ witnessUtility.utility c < 1 := by
  change 0 ≤ c/(1+c) ∧ c/(1+c) < 1
  have h : 0 < 1+c := by linarith
  exact ⟨div_nonneg hc h.le, (div_lt_one h).mpr (by linarith)⟩

theorem witness_utility_hasDerivAt (c : ℝ) (hc : 0 ≤ c) :
    HasDerivAt witnessUtility.utility (1/(1+c)^2) c := by
  have h : 1+c ≠ 0 := by linarith
  have hd : HasDerivAt (fun x : ℝ => x/(1+x)) ((1*(1+c)-c*1)/(1+c)^2) c :=
    (hasDerivAt_id c).div ((hasDerivAt_id c).const_add 1) h
  simpa only [witnessUtility, one_mul, mul_one, add_sub_cancel_right] using hd

theorem witness_utility_deriv (c : ℝ) (hc : 0 ≤ c) :
    deriv witnessUtility.utility c = 1/(1+c)^2 := (witness_utility_hasDerivAt c hc).deriv

theorem witness_utility_second_hasDerivAt (c : ℝ) (hc : 0 < c) :
    HasDerivAt (deriv witnessUtility.utility) (-2/(1+c)^3) c := by
  have h : 1+c ≠ 0 := by linarith
  have hp : HasDerivAt (fun x : ℝ => (1+x)^2) (2*(1+c)) c := by
    simpa using! ((hasDerivAt_id c).const_add 1).fun_pow 2
  have hd0 : HasDerivAt (fun x : ℝ => 1/(1+x)^2)
      ((0*(1+c)^2-1*(2*(1+c)))/((1+c)^2)^2) c :=
    (hasDerivAt_const c (1 : ℝ)).div hp (pow_ne_zero 2 h)
  have ha : (0*(1+c)^2-1*(2*(1+c)))/((1+c)^2)^2 = -2/(1+c)^3 := by
    field_simp
    ring
  have hd : HasDerivAt (fun x : ℝ => 1/(1+x)^2) (-2/(1+c)^3) c := ha ▸ hd0
  apply hd.congr_of_eventuallyEq
  filter_upwards [Ioi_mem_nhds hc] with x hx
  exact witness_utility_deriv x hx.le

theorem witness_utility_second (c : ℝ) (hc : 0 < c) :
    deriv (deriv witnessUtility.utility) c = -2/(1+c)^3 :=
  (witness_utility_second_hasDerivAt c hc).deriv

theorem witness_utility_contDiff (n : ℕ) : ContDiffOn ℝ n witnessUtility.utility (Ioi 0) := by
  apply contDiffOn_id.div (contDiffOn_const.add contDiffOn_id)
  intro c hc
  change 0 < c at hc
  dsimp
  linarith

theorem witness_utility_strictMono : StrictMonoOn witnessUtility.utility (Ici 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ici 0) witness_utility_continuous
  intro c hc
  have hc' : 0 < c := by simpa only [interior_Ici, mem_Ioi] using hc
  rw [witness_utility_deriv c hc'.le]
  positivity

theorem witness_utility_strictConcave : StrictConcaveOn ℝ (Ici 0) witnessUtility.utility := by
  apply strictConcaveOn_of_deriv2_neg (convex_Ici 0) witness_utility_continuous
  intro c hc
  have hc' : 0 < c := by simpa only [interior_Ici, mem_Ioi] using hc
  change deriv (deriv witnessUtility.utility) c < 0
  rw [witness_utility_second c hc']
  exact div_neg_of_neg_of_pos (by norm_num) (by positivity)

theorem witness_relative_risk_aversion (c : ℝ) (hc : 0 < c) :
    -c*deriv (deriv witnessUtility.utility) c / deriv witnessUtility.utility c = 2*c/(1+c) ∧
    2*c/(1+c) ≤ 2 := by
  rw [witness_utility_second c hc, witness_utility_deriv c hc.le]
  have h : 0 < 1+c := by linarith
  constructor
  · field_simp
  · apply (div_le_iff₀ h).mpr
    linarith

theorem witness_utility_base : UtilityBase witnessUtility where
  continuous := witness_utility_continuous
  bounded := ⟨1, fun c hc => by rw [abs_of_nonneg (witness_utility_bounds c hc).1]; exact (witness_utility_bounds c hc).2.le⟩
  increasing := witness_utility_strictMono
  concave := witness_utility_strictConcave

theorem witness_utility_smooth : UtilitySmooth witnessUtility where
  smooth := witness_utility_contDiff 1
  marginal_pos := by
    intro c hc
    rw [witness_utility_deriv c hc.le]
    have : 0 < 1+c := by have := hc; change 0 < c at this; linarith
    positivity

theorem witness_utility_curvature : UtilityCurvature witnessUtility where
  smooth := witness_utility_contDiff 2
  risk_bound := ⟨1, by norm_num, 2, fun c hc => by
    have h := witness_relative_risk_aversion c (by linarith)
    rw [h.1]; exact h.2⟩
end Aiyagari1994
