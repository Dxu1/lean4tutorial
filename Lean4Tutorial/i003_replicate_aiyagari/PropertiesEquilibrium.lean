import Lean4Tutorial.i003_replicate_aiyagari.Equilibrium

/-!
# Aiyagari (1994): Properties 11--17

This module proves the general-equilibrium comparisons, existence results,
and borrowing-limit comparative statics.  Ordering conclusions that the paper
obtains economically are explicit hypotheses; Lean then verifies every stated
capital, saving-rate, market-clearing, and sign implication.
-/

open Set Topology

namespace Aiyagari1994

noncomputable section

/-- Property 11: a lower incomplete-markets return implies a larger capital
stock because firm capital demand is strictly decreasing. -/
theorem property11_factor_price_and_capital_signs
    {P : Primitives} (A : Assumptions P)
    (IM : StationaryRecursiveEquilibrium P)
    (FI : FullInsuranceEquilibrium P)
    (hreturn : IM.r < FI.r) :
    IM.r < FI.r ∧ FI.r = P.«λ» ∧ FI.k < IM.k := by
  have hK : P.capitalDemand FI.r < P.capitalDemand IM.r :=
    A.capitalDemand_strictAnti hreturn
  rw [FI.capital_demand_clears, IM.capital_demand_clears] at hK
  exact ⟨hreturn, FI.return_eq_timePreference, hK⟩

/-- Net saving is zero whenever the stationary resource constraint holds. -/
theorem netSaving_eq_zero_of_goods_clear
    (P : Primitives) {C k : ℝ}
    (hgoods : C + P.δ * k = P.production k) :
    P.production k - C - P.δ * k = 0 := by
  linarith

/-- Property 12: if the gross saving-rate function is strictly increasing in
capital, the higher incomplete-markets stock has a higher gross saving rate;
both no-growth allocations have zero net saving. -/
theorem property12_saving_rate_sign
    {P : Primitives}
    (IM : StationaryRecursiveEquilibrium P)
    (FI : FullInsuranceEquilibrium P)
    (hsaving : StrictMono P.savingRate)
    (hcapital : FI.k < IM.k) :
    P.savingRate FI.k < P.savingRate IM.k ∧
      P.production IM.k - IM.C - P.δ * IM.k = 0 ∧
      P.production FI.k - FI.C - P.δ * FI.k = 0 := by
  exact ⟨hsaving hcapital,
    netSaving_eq_zero_of_goods_clear P IM.goods_clear,
    netSaving_eq_zero_of_goods_clear P FI.goods_clear⟩

/-- Property 13: a continuous nonmonotone asset-supply curve can generate two
distinct market-clearing returns, so uniqueness does not follow. -/
theorem property13_equilibrium_need_not_be_unique :
    ∃ (K : CapitalDemand) (Ea : AssetSupply) (r₁ r₂ : ℝ),
      Nonmonotone Ea ∧ r₁ ≠ r₂ ∧
      MarketClears K Ea r₁ ∧ MarketClears K Ea r₂ := by
  refine ⟨fun _ => 0, fun r => r ^ 2 - 1, -1, 1, ?_, by norm_num, ?_, ?_⟩
  · constructor
    · intro hmono
      have h := hmono (show (-1 : ℝ) ≤ 0 by norm_num)
      norm_num at h
    · intro hanti
      have h := hanti (show (0 : ℝ) ≤ 1 by norm_num)
      norm_num at h
  · norm_num [MarketClears]
  · norm_num [MarketClears]

/-- A continuous excess-demand function that is nonnegative at the left
endpoint and nonpositive at the right endpoint has a zero in the interval. -/
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
    (intermediate_value_Icc' hinterval hcontinuous hzero)
  refine ⟨r, hr, ?_⟩
  unfold MarketClears excessCapitalDemand at *
  linarith

/-- Property 14: endpoint signs implied by the two limit results produce a
positive-return equilibrium under the present-value limit and can produce a
negative-return equilibrium under a fixed limit. -/
theorem property14_existence_under_alternative_debt_limits
    (Kpv Kfixed : CapitalDemand)
    (Epv Efixed : AssetSupply)
    (lambda rLow rHigh nLow nHigh : ℝ)
    (hPVnegInf : DivergesToNegInfinityFromRight Epv 0)
    (hPVposInf : DivergesToInfinityFromLeft Epv lambda)
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
    DivergesToNegInfinityFromRight Epv 0 ∧
      DivergesToInfinityFromLeft Epv lambda ∧
      (∃ r > 0, MarketClears Kpv Epv r) ∧
      (∃ r < 0, MarketClears Kfixed Efixed r) := by
  obtain ⟨r, hr, hclear⟩ := marketClearing_exists_of_sign_change
    Kpv Epv hrange hPVcontinuous hPVLow hPVHigh
  obtain ⟨rn, hrn, hnclear⟩ := marketClearing_exists_of_sign_change
    Kfixed Efixed hnrange hFixedContinuous hFixedLow hFixedHigh
  exact ⟨hPVnegInf, hPVposInf,
    ⟨r, lt_of_lt_of_le hrLowPos hr.1, hclear⟩,
    ⟨rn, lt_of_le_of_lt hrn.2 hnHighNeg, hnclear⟩⟩

/-- At a market-clearing return, household asset supply cannot exceed finite
firm capital demand. -/
theorem assetSupply_eq_capitalDemand_at_equilibrium
    {K : CapitalDemand} {Ea : AssetSupply} {r : ℝ}
    (hclear : MarketClears K Ea r) : Ea r = K r := by
  exact hclear.symm

/-- Property 15: a partial-equilibrium return with excess household asset
supply cannot be a general-equilibrium return; endogenous market clearing pins
asset supply to capital demand. -/
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

/-- Property 16: if allowing more borrowing shifts asset supply left and the
new excess-demand curve is strictly decreasing, the new clearing return is
higher and firm capital demand is lower. -/
theorem property16_more_borrowing_reduces_capital
    (K : CapitalDemand) (EaNoBorrow EaMoreBorrow : AssetSupply)
    (rNoBorrow rMoreBorrow : ℝ)
    (hK : StrictAnti K)
    (hExcess : StrictAnti (excessCapitalDemand K EaMoreBorrow))
    (hNoClear : MarketClears K EaNoBorrow rNoBorrow)
    (hMoreClear : MarketClears K EaMoreBorrow rMoreBorrow)
    (hShift : EaMoreBorrow rNoBorrow < EaNoBorrow rNoBorrow) :
    rNoBorrow < rMoreBorrow ∧
      K rMoreBorrow < K rNoBorrow := by
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

/-- Under the additional monotonic saving-rate condition, Property 16 also
lowers the gross saving rate. -/
theorem property16_more_borrowing_reduces_saving_rate
    (K : CapitalDemand) (savingRate : ℝ → ℝ)
    {rNoBorrow rMoreBorrow : ℝ}
    (hK : StrictAnti K) (hs : StrictMono savingRate)
    (hr : rNoBorrow < rMoreBorrow) :
    savingRate (K rMoreBorrow) < savingRate (K rNoBorrow) := by
  exact hs (hK hr)

/-- A slack fixed limit reduces exactly to the natural borrowing limit. -/
theorem effectiveBorrowingLimit_eq_natural_of_slack
    {b w lmin r : ℝ} (hr : 0 < r)
    (hslack : FixedLimitSlack b w lmin r) :
    effectiveBorrowingLimit b w lmin r = naturalDebtLimit w lmin r := by
  simp [effectiveBorrowingLimit, hr,
    min_eq_right hslack]

/-- Property 17: two fixed limits that are both slack generate the same
effective limit and hence the same behavior for every object that depends only
on that effective limit. -/
theorem property17_no_effect_when_fixed_limit_slack
    {Behavior : Type*} (behavior : ℝ → Behavior)
    {b₁ b₂ w lmin r : ℝ} (hr : 0 < r)
    (hslack₁ : FixedLimitSlack b₁ w lmin r)
    (hslack₂ : FixedLimitSlack b₂ w lmin r) :
    effectiveBorrowingLimit b₁ w lmin r =
        effectiveBorrowingLimit b₂ w lmin r ∧
      behavior (effectiveBorrowingLimit b₁ w lmin r) =
        behavior (effectiveBorrowingLimit b₂ w lmin r) := by
  have h₁ := effectiveBorrowingLimit_eq_natural_of_slack hr hslack₁
  have h₂ := effectiveBorrowingLimit_eq_natural_of_slack hr hslack₂
  constructor
  · rw [h₁, h₂]
  · rw [h₁, h₂]

end

end Aiyagari1994
