import Aiyagari1994.Analysis.M09C3.EquilibriumRate
import Aiyagari1994.Analysis.M09D1.CapitalComparison

/-! G04: every unrestricted stationary-equilibrium rate lies below impatience. -/

namespace Aiyagari1994

/-- G04.  Every stationary equilibrium of the unchanged G01 type has a net interest rate below
`1 / beta - 1`.  The quantifier is over arbitrary equilibrium witnesses, not only the particular
finite-cap or natural-limit equilibria constructed by G02 and G03. -/
theorem every_equilibrium_rate_below_impatience
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    (e.rate : ℝ) < 1 / e.household.beta - 1 :=
  M09C3.every_equilibrium_rate_below_impatience_core p hp e

end Aiyagari1994

namespace Aiyagari1994

/-- G06.  Every unrestricted risky stationary equilibrium clears at strictly more net capital
than the mean-one certainty benchmark `K(1 / beta - 1)`. -/
theorem equilibrium_capital_above_certainty
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    ∃ rFI : FirmRate p,
      (rFI : ℝ) = 1 / e.household.beta - 1 ∧
      capitalDemand p hp rFI <
        ∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw :=
  M09D1.equilibrium_capital_above_certainty_core p hp e

end Aiyagari1994
