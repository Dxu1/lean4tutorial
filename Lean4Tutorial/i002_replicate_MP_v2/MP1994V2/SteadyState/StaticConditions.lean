import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.JobDestruction
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.JobCreation

/-!
# MP1994 v2: combined static conditions

This neutral combining module records the Milestone 3 capstone after the
independent job-destruction and job-creation theorem modules have been
compiled.  It does not define a reduced equilibrium.
-/

namespace MP1994V2

namespace ValueEquilibrium

variable {P : Primitives}

/-- Milestone 3 capstone.  Every existing value equilibrium generates the
paper-facing continuation identity and satisfies both reduced static residual
conditions.  This is a forward representation theorem, not an existence or
reverse-reconstruction result. -/
theorem milestone3_capstone
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.expectedExcess E.reservationCutoff =
        P.tailOptionValue E.reservationCutoff
      ∧ P.SatisfiesJobDestruction
          E.theta E.reservationCutoff
      ∧ P.SatisfiesJobCreation
          E.theta E.reservationCutoff := by
  exact ⟨E.expectedExcess_cutoff_eq_tailOptionValue A D M,
    E.satisfiesJobDestruction A D M,
    E.satisfiesJobCreation A D M⟩

end ValueEquilibrium

end MP1994V2
