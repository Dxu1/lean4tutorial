import Aiyagari1994.Analysis.M06C.StationaryBudget

/-! A02: finite stationary aggregates and the stationary household budget identity. -/
open MeasureTheory Set
namespace Aiyagari1994
noncomputable section

/-- A02. S05's compactly supported canonical invariant law has finite resource, shifted-asset,
net-asset, consumption, and effective-income first moments. Its resource identity is established
before the original-coordinate asset-supply and consumption identities. -/
theorem stationary_budget_identity
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1) (p : OriginalPrices m.income)
    (hprices : m.prices = p.normalized) :
    let pi := M06C.stationaryLaw m hsmooth hcurvature hnd hbetaR
    Integrable (fun z : Resources ↦ (z : ℝ)) (pi : Measure Resources) ∧
    Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ)) (pi : Measure Resources) ∧
    Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ) - p.debtLimit)
      (pi : Measure Resources) ∧
    Integrable (fun z : Resources ↦ (consumptionPolicy m z : ℝ))
      (pi : Measure Resources) ∧
    Integrable m.prices.effectiveIncome (m.income.law : Measure m.income.Labor) ∧
    ((∫ z, (z : ℝ) ∂(pi : Measure Resources)) =
      m.prices.grossReturn *
          ∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources) +
        ∫ l, m.prices.effectiveIncome l
          ∂(m.income.law : Measure m.income.Labor)) ∧
    stationaryAssetSupply m p.debtLimit pi =
      (∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources)) - p.debtLimit ∧
    (∫ z, (consumptionPolicy m z : ℝ) ∂(pi : Measure Resources)) =
      p.netRate * stationaryAssetSupply m p.debtLimit pi +
        p.wage * ∫ l, (l : ℝ) ∂(m.income.law : Measure m.income.Labor) := by
  dsimp only
  let pi := M06C.stationaryLaw m hsmooth hcurvature hnd hbetaR
  let B := M06C.stationaryBound m hsmooth hcurvature hnd hbetaR
  have hproperties := M06C.stationaryLaw_properties m hsmooth hcurvature hnd hbetaR
  have hsupport : (pi : Measure Resources) (Icc (lowerEffectiveIncome m) B) = 1 :=
    hproperties.2.1
  have hinv : householdLawStep m pi = pi := hproperties.2.2
  have hz := M06C.resource_integrable_of_compact_support pi (lowerEffectiveIncome m) B hsupport
  have hA := M06C.asset_integrable_of_compact_support m pi
    (lowerEffectiveIncome m) B hsupport
  have hc := M06C.consumption_integrable_of_compact_support m pi
    (lowerEffectiveIncome m) B hsupport
  have hnet : Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ) - p.debtLimit)
      (pi : Measure Resources) := hA.sub (integrable_const p.debtLimit)
  have he := M06C.effectiveIncome_integrable m
  have hid := M06C.stationary_budget_of_invariant m p hprices pi hinv hz hA hc
  exact ⟨hz, hA, hnet, hc, he, hid.1, hid.2.1, hid.2.2⟩

end
end Aiyagari1994
