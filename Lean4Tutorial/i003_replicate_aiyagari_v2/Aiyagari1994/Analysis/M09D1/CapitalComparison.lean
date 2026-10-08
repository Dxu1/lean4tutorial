import Aiyagari1994.Analysis.M09C3.EquilibriumRate
import Aiyagari1994.Equilibrium.CertaintyBenchmark

/-!
# Equilibrium capital exceeds the certainty benchmark

For an arbitrary unrestricted stationary equilibrium, G04 places its rate strictly below the
impatience rate.  G05 supplies a firm-rate representative of that certainty rate, and F01's
strictly decreasing capital demand reverses the rate inequality.  G01 capital clearing then
identifies the larger demand value with actual equilibrium net capital.
-/

open MeasureTheory

namespace Aiyagari1994
noncomputable section

namespace M09D1

/-- Gate-local implementation of G06.  The returned `rFI` identifies the certainty benchmark
rate with `lambda`; its capital demand is strictly below the arbitrary equilibrium's cleared
net-capital integral. -/
theorem equilibrium_capital_above_certainty_core
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    ∃ rFI : FirmRate p,
      (rFI : ℝ) = 1 / e.household.beta - 1 ∧
      capitalDemand p hp rFI <
        ∫ z, M06B.netAsset e.household e.originalPrices.debtLimit z ∂e.resourceLaw := by
  rcases certainty_benchmark_verified e.household e.utility_smooth e.labor_mean_one p hp with
    ⟨rFI, hrFI, _⟩
  have hrate : e.rate < rFI := by
    change (e.rate : ℝ) < (rFI : ℝ)
    rw [hrFI]
    exact M09C3.every_equilibrium_rate_below_impatience_core p hp e
  have hcapital : capitalDemand p hp rFI < capitalDemand p hp e.rate :=
    (capitalDemand_wage_constructed p hp).2.2.1 hrate
  refine ⟨rFI, hrFI, ?_⟩
  rw [e.capital_clearing]
  exact hcapital

end M09D1

end
end Aiyagari1994
