import Lean4Tutorial.i003_replicate_aiyagari.PropertiesStationary

/-!
# Aiyagari (1994): general-equilibrium properties
-/

open Set Topology

namespace Aiyagari1994

noncomputable section

/-- Property 11: excess household supply at the full-insurance return and a
single-crossing excess-demand curve imply a lower incomplete-markets return;
strictly decreasing capital demand then implies higher capital. -/
theorem property11_factor_price_and_capital_signs
    {P : Primitives} (T : TechnologyAssumptions P)
    (IM : StationaryRecursiveEquilibrium P)
    (FI : FullInsuranceEquilibrium P)
    (EaIM : AssetSupply)
    (hIMSupply : EaIM IM.r = IM.k)
    (hExcessFI : P.capitalDemand FI.r < EaIM FI.r)
    (hExcessAnti : StrictAnti (excessCapitalDemand P.capitalDemand EaIM)) :
    IM.r < FI.r ∧ FI.r = P.«λ» ∧ FI.k < IM.k := by
  have hIMZero : excessCapitalDemand P.capitalDemand EaIM IM.r = 0 := by
    unfold excessCapitalDemand
    rw [IM.capital_demand_clears, hIMSupply]
    ring
  have hFINeg : excessCapitalDemand P.capitalDemand EaIM FI.r < 0 := by
    unfold excessCapitalDemand
    linarith
  have hr : IM.r < FI.r := by
    by_contra hnot
    have hle : FI.r ≤ IM.r := le_of_not_gt hnot
    rcases hle.eq_or_lt with heq | hlt
    · rw [heq] at hFINeg
      linarith
    · have horder := hExcessAnti hlt
      linarith
  have hK := T.capitalDemand_strictAnti hr
  rw [FI.capital_demand_clears, IM.capital_demand_clears] at hK
  exact ⟨hr, FI.return_eq_timePreference, hK⟩

theorem netSaving_eq_zero_of_goods_clear
    (P : Primitives) {C k : ℝ}
    (hgoods : C + P.δ * k = P.production k) :
    P.production k - C - P.δ * k = 0 := by
  linarith

/-- Property 12 calls Property 11 for the capital ordering, then applies the
primitive monotonicity of the saving-rate formula. -/
theorem property12_saving_rate_sign
    {P : Primitives} (T : TechnologyAssumptions P)
    (IM : StationaryRecursiveEquilibrium P)
    (FI : FullInsuranceEquilibrium P)
    (EaIM : AssetSupply)
    (hIMSupply : EaIM IM.r = IM.k)
    (hExcessFI : P.capitalDemand FI.r < EaIM FI.r)
    (hExcessAnti : StrictAnti (excessCapitalDemand P.capitalDemand EaIM))
    (hsaving : StrictMono P.savingRate) :
    P.savingRate FI.k < P.savingRate IM.k ∧
      P.production IM.k - IM.C - P.δ * IM.k = 0 ∧
      P.production FI.k - FI.C - P.δ * FI.k = 0 := by
  have hcomparison := property11_factor_price_and_capital_signs
    T IM FI EaIM hIMSupply hExcessFI hExcessAnti
  exact ⟨hsaving hcomparison.2.2,
    netSaving_eq_zero_of_goods_clear P IM.goods_clear,
    netSaving_eq_zero_of_goods_clear P FI.goods_clear⟩

/-- Property 13: a normalized one-state asset aggregation has two distinct
market-clearing returns.  The witness is tied to finite-state aggregation,
rather than postulating an unrelated asset-supply function. -/
theorem property13_equilibrium_need_not_be_unique :
    ∃ (weight : Fin 1 → ℝ) (φ : ℝ → ℝ) (policy : ℝ → Fin 1 → ℝ)
      (K : CapitalDemand) (r₁ r₂ : ℝ),
      (∀ i, 0 ≤ weight i) ∧ (∑ i, weight i) = 1 ∧
      Nonmonotone (finiteStateMeanAssets weight φ policy) ∧
      r₁ ≠ r₂ ∧
      MarketClears K (finiteStateMeanAssets weight φ policy) r₁ ∧
      MarketClears K (finiteStateMeanAssets weight φ policy) r₂ := by
  let weight : Fin 1 → ℝ := fun _ => 1
  let φ : ℝ → ℝ := fun _ => 1
  let policy : ℝ → Fin 1 → ℝ := fun r _ => r ^ 2
  let K : CapitalDemand := fun _ => 0
  refine ⟨weight, φ, policy, K, -1, 1, fun _ => by simp [weight],
    by simp [weight], ?_, by norm_num, ?_, ?_⟩
  · have hform : finiteStateMeanAssets weight φ policy = fun r => r ^ 2 - 1 := by
      funext r
      simp [finiteStateMeanAssets, weight, φ, policy]
    rw [hform]
    constructor
    · intro hmono
      have h := hmono (show (-1 : ℝ) ≤ 0 by norm_num)
      norm_num at h
    · intro hanti
      have h := hanti (show (0 : ℝ) ≤ 1 by norm_num)
      norm_num at h
  · norm_num [MarketClears, finiteStateMeanAssets, weight, φ, policy, K]
  · norm_num [MarketClears, finiteStateMeanAssets, weight, φ, policy, K]

theorem marketClearing_exists_of_sign_change
    (K : CapitalDemand) (Ea : AssetSupply)
    {rLow rHigh : ℝ} (hinterval : rLow ≤ rHigh)
    (hcontinuous : ContinuousOn
      (excessCapitalDemand K Ea) (Icc rLow rHigh))
    (hLow : 0 ≤ excessCapitalDemand K Ea rLow)
    (hHigh : excessCapitalDemand K Ea rHigh ≤ 0) :
    ∃ r ∈ Icc rLow rHigh, MarketClears K Ea r := by
  have hzero :
      (0 : ℝ) ∈ Icc
        (excessCapitalDemand K Ea rHigh)
        (excessCapitalDemand K Ea rLow) := ⟨hHigh, hLow⟩
  obtain ⟨r, hr, hroot⟩ :=
    intermediate_value_Icc' hinterval hcontinuous hzero
  refine ⟨r, hr, ?_⟩
  unfold MarketClears excessCapitalDemand at *
  linarith

/-- Property 14: the Intermediate Value Theorem converts verified endpoint
signs into positive- and negative-return equilibria.  Endpoint signs are local
numeric/analytic obligations, not equilibrium-existence assumptions. -/
theorem property14_existence_under_alternative_debt_limits
    (Kpv Kfixed : CapitalDemand) (Epv Efixed : AssetSupply)
    (rLow rHigh nLow nHigh : ℝ)
    (hrLowPos : 0 < rLow) (hrange : rLow ≤ rHigh)
    (hPVcontinuous : ContinuousOn
      (excessCapitalDemand Kpv Epv) (Icc rLow rHigh))
    (hPVLow : 0 ≤ excessCapitalDemand Kpv Epv rLow)
    (hPVHigh : excessCapitalDemand Kpv Epv rHigh ≤ 0)
    (hnrange : nLow ≤ nHigh) (hnHighNeg : nHigh < 0)
    (hFixedContinuous : ContinuousOn
      (excessCapitalDemand Kfixed Efixed) (Icc nLow nHigh))
    (hFixedLow : 0 ≤ excessCapitalDemand Kfixed Efixed nLow)
    (hFixedHigh : excessCapitalDemand Kfixed Efixed nHigh ≤ 0) :
    (∃ r > 0, MarketClears Kpv Epv r) ∧
      (∃ r < 0, MarketClears Kfixed Efixed r) := by
  obtain ⟨r, hr, hclear⟩ := marketClearing_exists_of_sign_change
    Kpv Epv hrange hPVcontinuous hPVLow hPVHigh
  obtain ⟨rn, hrn, hnclear⟩ := marketClearing_exists_of_sign_change
    Kfixed Efixed hnrange hFixedContinuous hFixedLow hFixedHigh
  exact ⟨⟨r, lt_of_lt_of_le hrLowPos hr.1, hclear⟩,
    ⟨rn, lt_of_le_of_lt hrn.2 hnHighNeg, hnclear⟩⟩

theorem assetSupply_eq_capitalDemand_at_equilibrium
    {K : CapitalDemand} {Ea : AssetSupply} {r : ℝ}
    (hclear : MarketClears K Ea r) : Ea r = K r := hclear.symm

theorem property15_general_equilibrium_disciplines_saving
    (K : CapitalDemand) (Ea : AssetSupply)
    (rPartial rEq : ℝ)
    (hexcessSupply : K rPartial < Ea rPartial)
    (hEq : MarketClears K Ea rEq) :
    ¬MarketClears K Ea rPartial ∧ Ea rEq = K rEq := by
  constructor
  · intro hclear
    unfold MarketClears at hclear
    linarith
  · exact assetSupply_eq_capitalDemand_at_equilibrium hEq

/-- Property 16's equilibrium-ordering step.  It needs only the economically
relevant strict asset-supply comparison at the old equilibrium; it no longer
forces the entire new schedule to be an artificial constant translation. -/
theorem property16_more_borrowing_reduces_capital
    (K : CapitalDemand) (EaNoBorrow EaMoreBorrow : AssetSupply)
    (rNoBorrow rMoreBorrow : ℝ)
    (hK : StrictAnti K)
    (hSupplyAtOld : EaMoreBorrow rNoBorrow < EaNoBorrow rNoBorrow)
    (hExcess : StrictAnti (excessCapitalDemand K EaMoreBorrow))
    (hNoClear : MarketClears K EaNoBorrow rNoBorrow)
    (hMoreClear : MarketClears K EaMoreBorrow rMoreBorrow) :
    rNoBorrow < rMoreBorrow ∧ K rMoreBorrow < K rNoBorrow := by
  have hOldPositive :
      0 < excessCapitalDemand K EaMoreBorrow rNoBorrow := by
    unfold excessCapitalDemand MarketClears at *
    linarith
  have hNewZero :
      excessCapitalDemand K EaMoreBorrow rMoreBorrow = 0 := by
    unfold excessCapitalDemand MarketClears at *
    linarith
  have hr : rNoBorrow < rMoreBorrow := by
    by_contra hnot
    have hle : rMoreBorrow ≤ rNoBorrow := le_of_not_gt hnot
    rcases hle.eq_or_lt with heq | hlt
    · subst rMoreBorrow
      linarith
    · have horder := hExcess hlt
      linarith
  exact ⟨hr, hK hr⟩

theorem property16_more_borrowing_reduces_saving_rate
    (P : Primitives)
    {rNoBorrow rMoreBorrow : ℝ}
    (hK : StrictAnti P.capitalDemand) (hs : StrictMono P.savingRate)
    (hr : rNoBorrow < rMoreBorrow) :
    P.savingRate (P.capitalDemand rMoreBorrow) <
      P.savingRate (P.capitalDemand rNoBorrow) := hs (hK hr)

theorem effectiveBorrowingLimit_eq_natural_of_slack
    {b w lmin r : ℝ} (hr : 0 < r)
    (hslack : FixedLimitSlack b w lmin r) :
    effectiveBorrowingLimit b w lmin r = naturalDebtLimit w lmin r := by
  simp [effectiveBorrowingLimit, hr, min_eq_right hslack]

theorem property17_no_effect_when_fixed_limit_slack
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hU : BoundedFiniteUtility M) {b₁ b₂ : ℝ}
    (hslack₁ : FixedLimitSlack b₁ M.w M.lmin M.r)
    (hslack₂ : FixedLimitSlack b₂ M.w M.lmin M.r) :
    effectiveBorrowingLimit b₁ M.w M.lmin M.r =
        effectiveBorrowingLimit b₂ M.w M.lmin M.r ∧
      effectiveBoundedAiyagariValue M hM hU b₁ =
        effectiveBoundedAiyagariValue M hM hU b₂ ∧
      effectiveBoundedAiyagariAssetPolicy M hM hU b₁ =
      effectiveBoundedAiyagariAssetPolicy M hM hU b₂ ∧
      effectiveBoundedAiyagariConsumption M hM hU b₁ =
      effectiveBoundedAiyagariConsumption M hM hU b₂ ∧
      effectiveSolvedNextExcess M hM hU b₁ =
        effectiveSolvedNextExcess M hM hU b₂ ∧
      effectiveSolvedResourceKernel M hM hU b₁ =
        effectiveSolvedResourceKernel M hM hU b₂ ∧
      ∀ μ : MeasureTheory.Measure ExcessResource,
        ProbabilityTheory.Kernel.Invariant
            (effectiveSolvedResourceKernel M hM hU b₁) μ ↔
          ProbabilityTheory.Kernel.Invariant
            (effectiveSolvedResourceKernel M hM hU b₂) μ := by
  have h₁ := effectiveBorrowingLimit_eq_natural_of_slack hM.r_pos hslack₁
  have h₂ := effectiveBorrowingLimit_eq_natural_of_slack hM.r_pos hslack₂
  have hlimit : effectiveBorrowingLimit b₁ M.w M.lmin M.r =
      effectiveBorrowingLimit b₂ M.w M.lmin M.r := h₁.trans h₂.symm
  have hbehavior := solvedBoundedHousehold_behavior_eq_of_limit_eq M hM
    (effectiveBorrowingLimit_admissible M hM b₁)
    (effectiveBorrowingLimit_admissible M hM b₂) hU hlimit
  have htransition := solvedNextExcess_eq_of_limit_eq M hM
    (effectiveBorrowingLimit_admissible M hM b₁)
    (effectiveBorrowingLimit_admissible M hM b₂) hU hlimit
  have hkernel := solvedResourceKernel_eq_of_limit_eq M hM
    (effectiveBorrowingLimit_admissible M hM b₁)
    (effectiveBorrowingLimit_admissible M hM b₂) hU hlimit
  refine ⟨hlimit, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simpa only [effectiveBoundedAiyagariValue] using hbehavior.1
  · simpa only [effectiveBoundedAiyagariAssetPolicy] using hbehavior.2.1
  · simpa only [effectiveBoundedAiyagariConsumption] using hbehavior.2.2
  · simpa only [effectiveSolvedNextExcess] using htransition
  · simpa only [effectiveSolvedResourceKernel] using hkernel
  · intro μ
    simpa only [effectiveSolvedResourceKernel, hkernel]

end

end Aiyagari1994
