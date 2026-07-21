import Lean4Tutorial.i003_replicate_aiyagari.Equilibrium

/-!
# Aiyagari (1994): Properties 1--5

These results cover the household problem and policy functions.  Properties
1--3 invoke analytic implications proved in the appendix of Aiyagari (1993a)
but omitted from the supplied summary.  They are therefore explicit theorem
hypotheses here.  The order and accounting consequences are proved directly.
-/

open Filter Set Topology

namespace Aiyagari1994

/-- Property 1: the natural debt bound and the no-Ponzi condition are
equivalent.  The two analytic directions are explicit because the source
summary states but does not prove them. -/
theorem property01_naturalDebt_iff_noPonzi
    (a : ℕ → ℝ) (w lmin r : ℝ)
    (debt_implies_noPonzi : NaturalDebtBound a w lmin r → NoPonzi a r)
    (noPonzi_implies_debt : NoPonzi a r → NaturalDebtBound a w lmin r) :
    NaturalDebtBound a w lmin r ↔ NoPonzi a r := by
  exact ⟨debt_implies_noPonzi, noPonzi_implies_debt⟩

/-- The paper's normalization satisfies `β(1+λ)=1`. -/
theorem beta_mul_one_add_timePreferenceRate
    {β : ℝ} (hβ : β ≠ 0) :
    β * (1 + timePreferenceRate β) = 1 := by
  unfold timePreferenceRate
  field_simp
  ring

/-- Property 2: collect uniqueness, continuity, positivity,
differentiability, and the Euler inequality/equality into the exact regularity
conclusion recorded in the summary. -/
theorem property02_value_and_policy_regularity
    (solves : BellmanSolution) (optimal : PolicyOptimality)
    (V A marginalUtility expectedMarginalValue : ℝ → ℝ)
    (β r zmin : ℝ)
    (hV : IsUniqueBellmanSolution solves V)
    (hA : IsUniquePolicy optimal A)
    (hAcont : Continuous A)
    (hcpos : ∀ z, zmin < z → 0 < consumptionFromPolicy A z)
    (hVdiff : DifferentiableOn ℝ V (Ioi zmin))
    (heuler : ∀ z, zmin < z →
      EulerInequality marginalUtility expectedMarginalValue β r z)
    (heq : EulerEqualityWhenInterior
      A marginalUtility expectedMarginalValue β r) :
    IsUniqueBellmanSolution solves V ∧
      IsUniquePolicy optimal A ∧
      Continuous A ∧
      (∀ z, zmin < z → 0 < consumptionFromPolicy A z) ∧
      DifferentiableOn ℝ V (Ioi zmin) ∧
      (∀ z, zmin < z →
        EulerInequality marginalUtility expectedMarginalValue β r z) ∧
      EulerEqualityWhenInterior
        A marginalUtility expectedMarginalValue β r := by
  exact ⟨hV, hA, hAcont, hcpos, hVdiff, heuler, heq⟩

/-- Property 3: the source cutoff theorem turns either finiteness of marginal
utility at zero or positive minimum resources into a binding interval. -/
theorem property03_binding_region_at_low_resources
    (A : ℝ → ℝ) (zmin : ℝ) (finiteMarginalAtZero : Prop)
    (hcondition : finiteMarginalAtZero ∨ 0 < zmin)
    (sourceCutoffTheorem :
      finiteMarginalAtZero ∨ 0 < zmin →
        ∃ zhat, IsBindingCutoff A zmin zhat) :
    ∃ zhat > zmin, ∀ z, z ≤ zhat →
      consumptionFromPolicy A z = z ∧ A z = 0 := by
  obtain ⟨zhat, hzmin, hbind⟩ := sourceCutoffTheorem hcondition
  refine ⟨zhat, hzmin, ?_⟩
  intro z hz
  have hAz : A z = 0 := hbind z hz
  constructor
  · simp [consumptionFromPolicy, hAz]
  · exact hAz

/-- The exceptional Inada case in Property 3: if the supplied source theorem
says the limit is never attained, then shifted assets remain positive. -/
theorem property03_inada_exception
    (A : ℝ → ℝ) (zmin : ℝ)
    (hInada : zmin = 0 → ∀ z, 0 < z → 0 < A z)
    (hzmin : zmin = 0) :
    ∀ z, 0 < z → A z ≠ 0 := by
  intro z hz
  exact ne_of_gt (hInada hzmin z hz)

/-- Property 4: above the cutoff, consumption and assets rise and the policy
slope lies in `(0,1)`; inside the binding region a resource innovation passes
one-for-one into consumption. -/
theorem property04_monotonicity_and_one_for_one_response
    (A policyDerivative : ℝ → ℝ) (zmin zhat : ℝ)
    (hbind : IsBindingCutoff A zmin zhat)
    (hincreasing : StrictlyIncreasingAbove A zhat)
    (hslope : PolicySlopeInUnitInterval policyDerivative zhat) :
    StrictlyIncreasingAbove A zhat ∧
      PolicySlopeInUnitInterval policyDerivative zhat ∧
      ∀ z ε, z ≤ zhat → z + ε ≤ zhat →
        consumptionFromPolicy A (z + ε) -
          consumptionFromPolicy A z = ε := by
  refine ⟨hincreasing, hslope, ?_⟩
  intro z ε hz hze
  have hAz : A z = 0 := hbind.2 z hz
  have hAze : A (z + ε) = 0 := hbind.2 (z + ε) hze
  simp [consumptionFromPolicy, hAz, hAze]

/-- Pointwise higher asset demand mechanically means pointwise lower
consumption at fixed resources. -/
theorem consumptionShiftedDown_of_policyShiftedUp
    {baseline moreRisk : ℝ → ℝ}
    (hshift : PolicyShiftedUp baseline moreRisk) :
    ConsumptionShiftedDown baseline moreRisk := by
  intro z
  unfold consumptionFromPolicy
  linarith [hshift z]

/-- Property 5: convex marginal utility supplies the pointwise policy shift;
the stationary aggregate effect remains an explicit, unsigned object because
the invariant distribution changes. -/
theorem property05_mean_preserving_spread
    (baseline moreRisk : ℝ → ℝ)
    (convexMarginalUtility : Prop)
    (sourcePolicyShift :
      convexMarginalUtility → PolicyShiftedUp baseline moreRisk)
    (hconvex : convexMarginalUtility)
    (aggregateEffectUnsigned : Prop)
    (haggregateEffectUnsigned : aggregateEffectUnsigned) :
    PolicyShiftedUp baseline moreRisk ∧
      ConsumptionShiftedDown baseline moreRisk ∧
      aggregateEffectUnsigned := by
  have hshift := sourcePolicyShift hconvex
  exact ⟨hshift, consumptionShiftedDown_of_policyShiftedUp hshift,
    haggregateEffectUnsigned⟩

end Aiyagari1994
