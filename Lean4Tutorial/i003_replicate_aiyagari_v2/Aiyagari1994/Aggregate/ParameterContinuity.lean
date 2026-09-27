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

namespace Aiyagari1994
noncomputable section

/-- Joint A03 interface. With utility, beta, and the iid labor law fixed, the actual stationary
mean net-asset integral is continuous in an independently varying strictly impatient normalized
price and real debt shift. Economic original-coordinate use additionally requires the supplied
shift to be a compatible nonnegative debt limit. -/
theorem stationaryAssetSupply_joint_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) :
    Continuous (fun qphi : M06A.ImpatientPrices m × ℝ =>
      stationaryAssetSupply (m.withPrices qphi.1.1) qphi.2
        (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd qphi.1)) := by
  have heq :
      (fun qphi : M06A.ImpatientPrices m × ℝ =>
        stationaryAssetSupply (m.withPrices qphi.1.1) qphi.2
          (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd qphi.1)) =
      fun qphi =>
        M06D.stationaryMeanShiftedAssets m hsmooth hcurvature hnd qphi.1 - qphi.2 := by
    funext qphi
    exact M06C.stationaryAssetSupply_eq_mean_shifted_sub
      (m.withPrices qphi.1.1) qphi.2
      (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd qphi.1)
      (M06D.stationary_asset_integrable m hsmooth hcurvature hnd qphi.1)
  rw [heq]
  exact ((M06D.stationaryMeanShiftedAssets_continuous m hsmooth hcurvature hnd).comp
    continuous_fst).sub continuous_snd

end
end Aiyagari1994
