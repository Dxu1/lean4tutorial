import Aiyagari1994.Analysis.M09A2.EquilibriumDefinition

/-! G01: a noncircular stationary-equilibrium definition and its exact cross-sectional bridge. -/

namespace Aiyagari1994

/-- G01. For an equilibrium core carrying firm optimization, canonical lifetime household
optimality, the actual household kernel, exact budget normalization, finite first moments and
capital clearing, resource-law stationarity is equivalent to the induced predetermined-net-asset
and fresh-current-labor product-law formulation. -/
theorem equilibrium_resource_asset_iff {p : ProductionData} {hp : ProductionRegularity p}
    (e : EquilibriumCore p hp) :
    resourceLawForm e ↔ assetLaborLawForm e :=
  resource_asset_labor_form_iff e

end Aiyagari1994
