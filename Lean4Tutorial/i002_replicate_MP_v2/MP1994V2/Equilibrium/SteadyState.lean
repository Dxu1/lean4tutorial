import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Equilibrium.Reduced
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Flows

/-!
# MP1994 v2: full static steady-state equilibrium

This structure extends the reduced pair `(theta, cutoff)` by the unemployment
stock whose creation and destruction flows balance.  Employment and vacancies
are derived, not stored.  It is a static Section 3 object, not the Section 4
aggregate-state equilibrium.
-/

namespace MP1994V2

/-- A reduced static equilibrium completed with its unemployment stock. -/
structure SteadyStateEquilibrium (P : Primitives)
    extends ReducedEquilibrium P where
  unemployment : ℝ
  unemployment_nonneg : 0 ≤ unemployment
  unemployment_le_one : unemployment ≤ 1
  flow_balance :
    P.jobDestructionFlow cutoff unemployment =
      P.jobCreationFlow theta unemployment

namespace SteadyStateEquilibrium

variable {P : Primitives} (S : SteadyStateEquilibrium P)

/-- Employment is the population share not unemployed. -/
def employment : ℝ :=
  P.employmentFromUnemployment S.unemployment

/-- Vacancies are implied by the stock identity `v = theta * u`. -/
def vacancies : ℝ :=
  P.vacanciesFromTightness S.theta S.unemployment

@[ext]
theorem ext
    {S₁ S₂ : SteadyStateEquilibrium P}
    (hReduced : S₁.toReducedEquilibrium = S₂.toReducedEquilibrium)
    (hUnemployment : S₁.unemployment = S₂.unemployment) :
    S₁ = S₂ := by
  cases S₁
  cases S₂
  simp_all

end SteadyStateEquilibrium

end MP1994V2
