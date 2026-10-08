import Aiyagari1994.Equilibrium.MainTheorem
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-!
# Gross replacement-investment share

This file proves that `delta * K / f(K)` is strictly increasing on positive capital.  The
numerator in its derivative is the competitive wage, so F01 supplies its strict positivity.
G06 then transports the strict capital comparison to the gross investment-share comparison.
-/

open MeasureTheory Set

namespace Aiyagari1994
noncomputable section

namespace M09D2

/-- Gross replacement investment as a share of output at capital `K`. -/
def grossReplacementShare (p : ProductionData) (K : ℝ) : ℝ :=
  p.depreciation * K / p.output K

/-- At every positive capital stock, output net of the marginal product payment is positive.
This is F01's positive competitive wage, transported through the surjectivity of capital
demand onto positive capital. -/
theorem production_wage_gap_positive (p : ProductionData) (hp : ProductionRegularity p)
    {K : ℝ} (hK : 0 < K) :
    0 < p.output K - K * deriv p.output K := by
  let Kpos : Ioi (0 : ℝ) := ⟨K, hK⟩
  obtain ⟨r, hr⟩ := capitalDemandPositive_surjective p hp Kpos
  have hcapital : capitalDemand p hp r = K := by
    exact congrArg Subtype.val hr
  have hwage := (capitalDemand_wage_constructed p hp).1 r |>.2.1
  simpa only [firmWage, hcapital] using hwage

/-- Neoclassical output is positive at every positive capital stock. -/
theorem production_output_positive (p : ProductionData) (hp : ProductionRegularity p)
    {K : ℝ} (hK : 0 < K) : 0 < p.output K := by
  have hgap := production_wage_gap_positive p hp hK
  have hmarginal := hp.marginal_positive K hK
  have hproduct : 0 < K * deriv p.output K := mul_pos hK hmarginal
  linarith

/-- The derivative formula for the gross replacement-investment share on positive capital. -/
theorem grossReplacementShare_hasDerivAt
    (p : ProductionData) (hp : ProductionRegularity p)
    {K : ℝ} (hK : 0 < K) :
    HasDerivAt (grossReplacementShare p)
      (p.depreciation * (p.output K - K * deriv p.output K) / (p.output K) ^ 2) K := by
  have hdiff : DifferentiableAt ℝ p.output K :=
    (hp.smooth_positive.differentiableOn (by norm_num) K hK).differentiableAt
      (Ioi_mem_nhds hK)
  have houtput_ne : p.output K ≠ 0 := (production_output_positive p hp hK).ne'
  have hid : HasDerivAt (fun x : ℝ => x) 1 K := hasDerivAt_id K
  have hnum : HasDerivAt (fun x : ℝ => p.depreciation * x) p.depreciation K := by
    simpa only [mul_one] using hid.const_mul p.depreciation
  have hquot := hnum.div hdiff.hasDerivAt houtput_ne
  have hderiv_eq :
      (p.depreciation * p.output K -
          p.depreciation * K * deriv p.output K) / p.output K ^ 2 =
        p.depreciation * (p.output K - K * deriv p.output K) / p.output K ^ 2 := by
    ring
  rw [hderiv_eq] at hquot
  change HasDerivAt (fun x : ℝ => p.depreciation * x / p.output x)
    (p.depreciation * (p.output K - K * deriv p.output K) / (p.output K) ^ 2) K
  exact hquot

/-- The gross replacement-investment share is strictly increasing on positive capital. -/
theorem grossReplacementShare_strictMonoOn
    (p : ProductionData) (hp : ProductionRegularity p) :
    StrictMonoOn (grossReplacementShare p) (Ioi 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ioi 0)
  · apply ContinuousOn.div
    · exact (continuous_const.mul continuous_id).continuousOn
    · exact hp.continuous_nonnegative.mono (fun K hK =>
        (show 0 < K from hK).le)
    · intro K hK
      exact (production_output_positive p hp hK).ne'
  · intro K hK
    rw [interior_Ioi] at hK
    rw [(grossReplacementShare_hasDerivAt p hp hK).deriv]
    have hdelta := hp.depreciation_positive
    have hgap := production_wage_gap_positive p hp hK
    have houtput_sq : 0 < (p.output K) ^ 2 := sq_pos_of_pos (production_output_positive p hp hK)
    positivity

/-- Gate-local implementation of G07.  For every unrestricted risky stationary equilibrium,
the gross replacement-investment share at actual cleared net capital is strictly above the
share at the mean-one certainty benchmark. -/
theorem equilibrium_gross_saving_share_above_certainty_core
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    ∃ rFI : FirmRate p,
      (rFI : ℝ) = 1 / e.household.beta - 1 ∧
      p.depreciation * capitalDemand p hp rFI /
          p.output (capitalDemand p hp rFI) <
        p.depreciation *
            (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw) /
          p.output
            (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw) := by
  obtain ⟨rFI, hrFI, hcapital⟩ := equilibrium_capital_above_certainty p hp e
  refine ⟨rFI, hrFI, ?_⟩
  change grossReplacementShare p (capitalDemand p hp rFI) <
    grossReplacementShare p
      (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw)
  apply grossReplacementShare_strictMonoOn p hp
  · exact capitalDemand_positive p hp rFI
  · rw [e.capital_clearing]
    exact capitalDemand_positive p hp e.rate
  · exact hcapital

end M09D2

end
end Aiyagari1994
