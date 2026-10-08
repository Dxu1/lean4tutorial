import Aiyagari1994.Analysis.M09C3.EquilibriumRate

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
