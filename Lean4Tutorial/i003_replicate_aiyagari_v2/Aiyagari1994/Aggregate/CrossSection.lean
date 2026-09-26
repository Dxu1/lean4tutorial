import Aiyagari1994.Analysis.M06B.CrossSectionBridge

/-! A01: stationary resource laws and independent asset/labor cross-sections. -/
open MeasureTheory
namespace Aiyagari1994
noncomputable section

/-- A01. If `rho` is the net-asset marginal induced by the saving policy, then the
independent current asset/labor cross-section has resource image `pi` exactly when `pi` is
stationary for the household resource kernel. Thus either stationary description determines
the other, without a continuum law of large numbers. -/
theorem resource_asset_labor_law_bridge (m : HouseholdPrimitives) (phi : ℝ)
    (pi : ProbabilityMeasure Resources) (rho : ProbabilityMeasure ℝ)
    (hrho : rho = M06B.netAssetLaw m phi pi) :
    (M06B.assetLaborLaw m rho).map
        (M06B.resourceFromAssetLabor_continuous m phi).measurable.aemeasurable = pi ↔
      householdLawStep m pi = pi := by
  subst rho
  rw [M06B.resourceImage_eq_lawStep]

end
end Aiyagari1994
