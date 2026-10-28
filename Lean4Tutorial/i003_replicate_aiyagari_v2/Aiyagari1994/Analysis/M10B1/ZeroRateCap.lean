import Aiyagari1994.Budget.EffectiveLimit
import Aiyagari1994.Aggregate.AssetSupply

/-! Gate-local proof of the exact zero-rate finite-cap translation. -/

open MeasureTheory

namespace Aiyagari1994
noncomputable section

namespace M10B1

/-- Original prices for a finite borrowing cap at zero net interest. -/
def zeroRatePrices (m : HouseholdPrimitives) (b : ℝ) (hb : 0 ≤ b)
    (w : ℝ) (hw : 0 < w) : OriginalPrices m.income :=
  finiteCapPrices m.income m.income_support b w 0 hb hw (by norm_num)

/-- The household obtained from a finite cap at zero net interest. -/
def zeroRateHousehold (m : HouseholdPrimitives) (_b : ℝ) (_hb : 0 ≤ _b)
    (w : ℝ) (hw : 0 < w) : HouseholdPrimitives where
  beta := m.beta
  beta_pos := m.beta_pos
  beta_lt_one := m.beta_lt_one
  utility := m.utility
  utility_base := m.utility_base
  income := m.income
  income_support := m.income_support
  prices :=
    { grossReturn := 1
      wage := w
      intercept := 0
      grossReturn_pos := by norm_num
      wage_pos := hw
      income_nonneg := fun l => by
        simp only [add_zero]
        exact mul_nonneg hw.le (m.income_support.lower_pos.le.trans l.property.1) }

theorem effectiveLimit_zero (b lo w : ℝ) : effectiveLimit b lo w 0 = b := by
  simp [effectiveLimit]

theorem zeroRatePrices_debtLimit (m : HouseholdPrimitives) (b : ℝ) (hb : 0 ≤ b)
    (w : ℝ) (hw : 0 < w) : (zeroRatePrices m b hb w hw).debtLimit = b := by
  simp [zeroRatePrices, finiteCapPrices, effectiveLimit_zero]

theorem zeroRateHousehold_prices (m : HouseholdPrimitives) (b : ℝ) (hb : 0 ≤ b)
    (w : ℝ) (hw : 0 < w) :
    (zeroRateHousehold m b hb w hw).prices = (zeroRatePrices m b hb w hw).normalized := by
  simp only [zeroRateHousehold, zeroRatePrices, finiteCapPrices, OriginalPrices.normalized,
    effectiveLimit_zero]
  congr <;> norm_num

theorem zeroRateHousehold_eq (m : HouseholdPrimitives)
    (b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂) (w : ℝ) (hw : 0 < w) :
    zeroRateHousehold m b₁ hb₁ w hw = zeroRateHousehold m b₂ hb₂ w hw := by
  rfl

theorem zeroRate_beta_grossReturn_lt_one (m : HouseholdPrimitives)
    (b : ℝ) (hb : 0 ≤ b) (w : ℝ) (hw : 0 < w) :
    (zeroRateHousehold m b hb w hw).beta *
        (zeroRateHousehold m b hb w hw).prices.grossReturn < 1 := by
  simpa [zeroRateHousehold] using m.beta_lt_one

/-- At zero interest, finite caps give the same shifted household, canonical H02 value,
H04 shifted asset and consumption policies, and canonical S05 stationary law. A02's integrable
accounting identity then gives the exact one-for-one translation in stationary net supply. -/
theorem zeroRate_cap_change_exact
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂) (w : ℝ) (hw : 0 < w) :
    let m₁ := zeroRateHousehold m b₁ hb₁ w hw
    let m₂ := zeroRateHousehold m b₂ hb₂ w hw
    let h₁ := zeroRate_beta_grossReturn_lt_one m b₁ hb₁ w hw
    let h₂ := zeroRate_beta_grossReturn_lt_one m b₂ hb₂ w hw
    let pi₁ := M06C.stationaryLaw m₁ hsmooth hcurvature hnd h₁
    let pi₂ := M06C.stationaryLaw m₂ hsmooth hcurvature hnd h₂
    m₁ = m₂ ∧
      valueFunction m₁ = valueFunction m₂ ∧
      assetPolicy m₁ = assetPolicy m₂ ∧
      consumptionPolicy m₁ = consumptionPolicy m₂ ∧
      pi₁ = pi₂ ∧
      stationaryAssetSupply m₂ b₂ pi₂ - stationaryAssetSupply m₁ b₁ pi₁ =
        -(b₂ - b₁) := by
  dsimp only
  have hpi : M06C.stationaryLaw (zeroRateHousehold m b₁ hb₁ w hw)
      hsmooth hcurvature hnd (zeroRate_beta_grossReturn_lt_one m b₁ hb₁ w hw) =
      M06C.stationaryLaw (zeroRateHousehold m b₁ hb₁ w hw)
        hsmooth hcurvature hnd (zeroRate_beta_grossReturn_lt_one m b₂ hb₂ w hw) := by
    congr
  have haccount₁ := stationary_budget_identity
    (zeroRateHousehold m b₁ hb₁ w hw) hsmooth hcurvature hnd
    (zeroRate_beta_grossReturn_lt_one m b₁ hb₁ w hw)
    (zeroRatePrices m b₁ hb₁ w hw) (zeroRateHousehold_prices m b₁ hb₁ w hw)
  have haccount₂ := stationary_budget_identity
    (zeroRateHousehold m b₁ hb₁ w hw) hsmooth hcurvature hnd
    (zeroRate_beta_grossReturn_lt_one m b₂ hb₂ w hw)
    (zeroRatePrices m b₂ hb₂ w hw) (zeroRateHousehold_prices m b₂ hb₂ w hw)
  refine ⟨rfl, rfl, rfl, rfl, ?_, ?_⟩
  · exact hpi
  · have hs₁ := haccount₁.2.2.2.2.2.2.1
    have hs₂ := haccount₂.2.2.2.2.2.2.1
    simp only [zeroRatePrices_debtLimit] at hs₁ hs₂
    change stationaryAssetSupply (zeroRateHousehold m b₁ hb₁ w hw) b₂
          (M06C.stationaryLaw (zeroRateHousehold m b₁ hb₁ w hw)
            hsmooth hcurvature hnd (zeroRate_beta_grossReturn_lt_one m b₂ hb₂ w hw)) -
        stationaryAssetSupply (zeroRateHousehold m b₁ hb₁ w hw) b₁
          (M06C.stationaryLaw (zeroRateHousehold m b₁ hb₁ w hw)
            hsmooth hcurvature hnd (zeroRate_beta_grossReturn_lt_one m b₁ hb₁ w hw)) =
      -(b₂ - b₁)
    rw [hs₁, hs₂, hpi]
    ring

end M10B1

end
end Aiyagari1994
