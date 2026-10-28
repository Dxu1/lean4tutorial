import Aiyagari1994.Analysis.M10B1.ZeroRateCap

namespace Aiyagari1994
noncomputable section

/-- E01: zero-rate finite-cap changes preserve the shifted canonical household and translate
stationary net asset supply one-for-one. -/
theorem zeroRate_cap_change_exact
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂) (w : ℝ) (hw : 0 < w) :
    let m₁ := M10B1.zeroRateHousehold m b₁ hb₁ w hw
    let m₂ := M10B1.zeroRateHousehold m b₂ hb₂ w hw
    let h₁ := M10B1.zeroRate_beta_grossReturn_lt_one m b₁ hb₁ w hw
    let h₂ := M10B1.zeroRate_beta_grossReturn_lt_one m b₂ hb₂ w hw
    let pi₁ := M06C.stationaryLaw m₁ hsmooth hcurvature hnd h₁
    let pi₂ := M06C.stationaryLaw m₂ hsmooth hcurvature hnd h₂
    m₁ = m₂ ∧
      valueFunction m₁ = valueFunction m₂ ∧
      assetPolicy m₁ = assetPolicy m₂ ∧
      consumptionPolicy m₁ = consumptionPolicy m₂ ∧
      pi₁ = pi₂ ∧
      stationaryAssetSupply m₂ b₂ pi₂ - stationaryAssetSupply m₁ b₁ pi₁ =
        -(b₂ - b₁) :=
  M10B1.zeroRate_cap_change_exact m hsmooth hcurvature hnd b₁ b₂ hb₁ hb₂ w hw

end
end Aiyagari1994
