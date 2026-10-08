import Aiyagari1994.Analysis.M09D2.GrossSaving

/-! G07: gross replacement-investment share above the certainty benchmark. -/

open MeasureTheory

namespace Aiyagari1994

/-- G07.  Every unrestricted risky stationary equilibrium has a strictly larger gross
replacement-investment share than the mean-one certainty benchmark. -/
theorem equilibrium_gross_saving_share_above_certainty
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    ∃ rFI : FirmRate p,
      (rFI : ℝ) = 1 / e.household.beta - 1 ∧
      p.depreciation * capitalDemand p hp rFI /
          p.output (capitalDemand p hp rFI) <
        p.depreciation *
            (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw) /
          p.output
            (∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw) :=
  M09D2.equilibrium_gross_saving_share_above_certainty_core p hp e

end Aiyagari1994
