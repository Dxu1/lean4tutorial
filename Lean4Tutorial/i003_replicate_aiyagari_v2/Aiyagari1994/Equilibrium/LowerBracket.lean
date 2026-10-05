import Aiyagari1994.Analysis.M09A3.LowerBracket

namespace Aiyagari1994

/-- F02: for every finite institutional cap, a derived feasible negative rate has canonical
stationary asset supply strictly below the firm's capital demand. -/
theorem finiteCap_lower_bracket (p : ProductionData) (hp : ProductionRegularity p)
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (hmean : LaborMeanOne m.income) (b : ℝ) (hb : 0 ≤ b) :
    ∃ K_L : ℝ, 0 < K_L ∧
      ∃ r_L : FirmRate p,
        capitalDemand p hp r_L = K_L ∧
        ∃ hrneg : (r_L : ℝ) < 0,
        deriv p.output K_L < p.depreciation ∧
        p.output K_L < p.depreciation * K_L ∧
        let prices := M09A3.lowerOriginalPrices m p hp b hb r_L
        let household := M09A3.lowerHousehold m p hp b hb r_L
        let hbetaR : household.beta * household.prices.grossReturn < 1 := by
          change m.beta * (1 + (r_L : ℝ)) < 1
          exact M09A3.lower_betaR m p hp r_L hrneg
        prices.debtLimit = b ∧
        0 < 1 + (r_L : ℝ) ∧
        household.beta * household.prices.grossReturn < 1 ∧
        stationaryAssetSupply household prices.debtLimit
            (M06C.stationaryLaw household hsmooth hcurvature hnd hbetaR) < K_L :=
  finiteCap_lower_bracket_core p hp m hsmooth hcurvature hnd hmean b hb

end Aiyagari1994
