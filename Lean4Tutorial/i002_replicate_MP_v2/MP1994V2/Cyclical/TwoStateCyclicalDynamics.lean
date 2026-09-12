import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateUnemploymentDynamics
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateEmploymentImpact

/-!
# MP1994 v2: M9.3 cyclical-dynamics capstone

This module combines the job-creation, fixed-state flow, and aggregate-impact
layers. It remains conditional on a supplied two-state value equilibrium and
admissible employment measures.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Full M9.3 result package. The Appendix matching bundle is used only for
strict monotonicity of the worker meeting hazard on positive tightness. -/
theorem m9_3_full_cyclical_dynamics_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    SatisfiesM93JobCreation A D TA M E ∧
      SatisfiesM93UnemploymentDynamics A D TA M E ∧
      ((∀ N : StateEmploymentDistribution P T A D TA M E .recession,
          (N.afterAggregateShock .boom).measure = N.measure ∧
          N.impactDestructionMass .boom = 0 ∧
          N.impactCreationMass = 0) ∧
        (∀ N : StateEmploymentDistribution P T A D TA M E .boom,
          N.impactDestructionMass .recession =
              N.measure
                (Set.Ico (E.reservationCutoff A D TA M .boom)
                  (E.reservationCutoff A D TA M .recession)) ∧
          N.impactCreationMass = 0 ∧
          (0 < N.measure
              (Set.Ico (E.reservationCutoff A D TA M .boom)
                (E.reservationCutoff A D TA M .recession)) →
            (N.afterAggregateShock .recession).measure Set.univ <
              N.measure Set.univ))) := by
  exact ⟨E.m9_3_jobCreation_capstone A D TA M,
    E.m9_3_unemployment_capstone A D TA M AM,
    E.m9_3_impact_asymmetry_capstone A D TA M⟩

end TwoStateValueEquilibrium
end MP1994V2
