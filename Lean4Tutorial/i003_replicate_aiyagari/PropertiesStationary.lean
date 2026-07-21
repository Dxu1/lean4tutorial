import Lean4Tutorial.i003_replicate_aiyagari.Equilibrium

/-!
# Aiyagari (1994): Properties 6--10

This module formalizes boundedness, stationary distributions, and aggregate
asset supply.  The existence/ergodicity steps are the cited theorems from
Aiyagari (1993a); the summary does not include their measure-theoretic proofs,
so their analytic engines are named hypotheses rather than hidden axioms.
-/

open Filter Set Topology

namespace Aiyagari1994

/-- Property 6: bounded shocks, bounded eventual relative risk aversion, and
`β(1+r)<1` yield a finite upper resource threshold. -/
theorem property06_bounded_resource_dynamics
    (transition : ℝ → ℝ → ℝ) (β r : ℝ)
    (boundedShockSupport boundedRelativeRiskAversion : Prop)
    (hdiscount : β * (1 + r) < 1)
    (hshock : boundedShockSupport)
    (hrra : boundedRelativeRiskAversion)
    (sourceBoundednessTheorem :
      β * (1 + r) < 1 →
      boundedShockSupport →
      boundedRelativeRiskAversion →
      ∃ zstar, ResourcesBoundedAbove transition zstar) :
    ∃ zstar, ∀ z l, zstar ≤ z → transition z l ≤ z := by
  obtain ⟨zstar, hzstar⟩ :=
    sourceBoundednessTheorem hdiscount hshock hrra
  exact ⟨zstar, hzstar⟩

/-- Property 7: unpack the unique, stable invariant-law result and append the
paper's parameter-continuity conclusion. -/
theorem property07_unique_stable_invariant_distribution
    {Dist Params : Type*}
    (D : UniqueStableInvariantData Dist)
    (parameterizedInvariant : Params → Dist)
    (ContinuousInParameters : (Params → Dist) → Prop)
    (hcontinuous : ContinuousInParameters parameterizedInvariant) :
    IsInvariant D.law D.law.invariant ∧
      (∀ μ, IsInvariant D.law μ → μ = D.law.invariant) ∧
      IsStable D.law D.Converges ∧
      ContinuousInParameters parameterizedInvariant := by
  exact ⟨D.invariant_is_invariant, D.invariant_unique,
    D.stable, hcontinuous⟩

/-- A continuous nonmonotone curve exists, so continuity alone cannot justify
monotonicity of aggregate asset supply. -/
theorem continuous_nonmonotone_curve_exists :
    ∃ f : ℝ → ℝ, Continuous f ∧ Nonmonotone f := by
  refine ⟨fun r => r ^ 2, continuous_pow 2, ?_⟩
  constructor
  · intro hmono
    have h := hmono (show (-1 : ℝ) ≤ 0 by norm_num)
    norm_num at h
  · intro hanti
    have h := hanti (show (0 : ℝ) ≤ 1 by norm_num)
    norm_num at h

/-- Property 8: the supplied mean-asset curve is finite-valued and continuous;
neither continuity nor the model class guarantees monotonicity. -/
theorem property08_continuity_and_possible_nonmonotonicity
    (Ea : AssetSupply) (hcontinuous : Continuous Ea) :
    (∀ r, ∃ x : ℝ, Ea r = x) ∧
      Continuous Ea ∧
      (∃ candidate : AssetSupply,
        Continuous candidate ∧ Nonmonotone candidate) := by
  refine ⟨fun r => ⟨Ea r, rfl⟩, hcontinuous, ?_⟩
  exact continuous_nonmonotone_curve_exists

/-- Property 9: divergence at the time-preference rate and nonexistence of a
finite stationary asset supply at or above it imply every finite stationary
equilibrium has `r < λ`. -/
theorem property09_explosion_at_time_preference_rate
    (Ea : AssetSupply) (lambda : ℝ)
    (FiniteStationarySupply : ℝ → Prop)
    (hdiverges : DivergesToInfinityFromLeft Ea lambda)
    (hnoFinite : ∀ r, lambda ≤ r → ¬FiniteStationarySupply r) :
    DivergesToInfinityFromLeft Ea lambda ∧
      (∀ r, lambda ≤ r → ¬FiniteStationarySupply r) ∧
      (∀ r, FiniteStationarySupply r → r < lambda) := by
  refine ⟨hdiverges, hnoFinite, ?_⟩
  intro r hfinite
  by_contra hnot
  exact hnoFinite r (le_of_not_gt hnot) hfinite

/-- Property 10: the paper's near-benchmark dominance and possible equality
at low returns are recorded together. -/
theorem property10_uncertainty_raises_assets_near_benchmark
    (risky certain : AssetSupply) (lambda rLow : ℝ)
    (hnear : DominatesNear lambda risky certain)
    (hlow : risky rLow = certain rLow) :
    (∃ ε > 0, ∀ r, lambda - ε < r → r < lambda →
      certain r < risky r) ∧
      risky rLow = certain rLow := by
  exact ⟨hnear, hlow⟩

end Aiyagari1994
