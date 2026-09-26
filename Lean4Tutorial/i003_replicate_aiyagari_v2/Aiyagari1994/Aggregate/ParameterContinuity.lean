import Aiyagari1994.Analysis.M06D.ParameterContinuity

/-! A03: continuity of stationary mean net assets. -/
open scoped Topology
namespace Aiyagari1994
noncomputable section

/-- A03. With utility, beta, and the iid labor law fixed, stationary mean net assets are
continuous throughout the strictly impatient admissible normalized-price domain whenever the
associated original-coordinate debt shift is continuous. -/
theorem stationaryAssetSupply_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (phi : M06A.ImpatientPrices m → ℝ)
    (hphi : Continuous phi) :
    Continuous (M06D.stationaryAssetSupplyAtPrice m hsmooth hcurvature hnd phi) :=
  M06D.stationaryAssetSupply_continuous_core m hsmooth hcurvature hnd phi hphi

end
end Aiyagari1994
