import Aiyagari1994.Analysis.M10B2.CapsAboveNatural
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

namespace Aiyagari1994
noncomputable section
open MeasureTheory

/-- E02: positive-rate finite caps weakly above the natural limit induce the same normalized
household and canonical policies; under S05's separate premises, laws and net supply coincide. -/
theorem caps_above_naturalLimit_equivalent
    (m : HouseholdPrimitives) (b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (w : ℝ) (hw : 0 < w) (r : ℝ) (hr : 0 < r)
    (hcap₁ : naturalLimit m.income.lower w r ≤ b₁)
    (hcap₂ : naturalLimit m.income.lower w r ≤ b₂) :
    let phi := naturalLimit m.income.lower w r
    let m₁ := M10B2.capHousehold m b₁ hb₁ w hw r hr
    let m₂ := M10B2.capHousehold m b₂ hb₂ w hw r hr
    effectiveLimit b₁ m.income.lower w r = phi ∧
      effectiveLimit b₂ m.income.lower w r = phi ∧
      m₁ = m₂ ∧
      valueFunction m₁ = valueFunction m₂ ∧
      assetPolicy m₁ = assetPolicy m₂ ∧
      consumptionPolicy m₁ = consumptionPolicy m₂ ∧
      householdKernel m₁ = householdKernel m₂ ∧
      householdLawStep m₁ = householdLawStep m₂ ∧
      ∀ (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
        (hnd : IncomeNondegenerate m.income)
        (hbetaR₁ : m₁.beta * m₁.prices.grossReturn < 1)
        (hbetaR₂ : m₂.beta * m₂.prices.grossReturn < 1),
        let pi₁ := M10B2.stationaryLaw m₁ hsmooth hcurvature hnd hbetaR₁
        let pi₂ := M10B2.stationaryLaw m₂ hsmooth hcurvature hnd hbetaR₂
        Integrable (fun z : Resources ↦ (assetPolicy m₁ z : ℝ) - phi)
            (pi₁ : Measure Resources) ∧
          Integrable (fun z : Resources ↦ (assetPolicy m₂ z : ℝ) - phi)
            (pi₂ : Measure Resources) ∧
          pi₁ = pi₂ ∧
          M10B2.stationaryNetAssetSupply m₁ phi pi₁ =
            M10B2.stationaryNetAssetSupply m₂ phi pi₂ :=
  M10B2.caps_above_naturalLimit_equivalent m b₁ b₂ hb₁ hb₂ w hw r hr hcap₁ hcap₂

end
end Aiyagari1994
