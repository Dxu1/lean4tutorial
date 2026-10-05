import Aiyagari1994.Analysis.M09A1.FirmConstruction

open Set

namespace Aiyagari1994

/-- F01: the constructed capital demand solves the marginal equation, is continuous and strictly
decreasing, yields a continuous positive wage, and is the global unique profit-maximizing ratio. -/
theorem capitalDemand_wage_constructed (p : ProductionData) (hp : ProductionRegularity p) :
    (∀ r : FirmRate p,
      deriv p.output (capitalDemand p hp r) = (r : ℝ) + p.depreciation ∧
      0 < firmWage p hp r ∧
      ∀ K ∈ Ici (0 : ℝ), K ≠ capitalDemand p hp r →
        firmProfit p r K < firmProfit p r (capitalDemand p hp r)) ∧
    Continuous (capitalDemand p hp) ∧ StrictAnti (capitalDemand p hp) ∧
    Continuous (firmWage p hp) :=
  capitalDemand_wage_constructed_core p hp

end Aiyagari1994
