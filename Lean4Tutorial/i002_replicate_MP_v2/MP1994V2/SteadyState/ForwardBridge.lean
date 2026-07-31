import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.StaticConditions
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Equilibrium.Reduced

/-!
# MP1994 v2: forward bridge to the reduced equilibrium

Every existing primitive value equilibrium supplies an admissible reduced
pair.  This is the necessary direction of the M4 representation theorem.
-/

open MeasureTheory

namespace MP1994V2

namespace ValueEquilibrium

variable {P : Primitives}

/-- The M3 product identity as the robust job-creation predicate. -/
theorem satisfiesJobCreationProduct
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    P.SatisfiesJobCreationProduct
      E.theta E.reservationCutoff := by
  exact E.job_creation_product_identity A

/-- Map a primitive value equilibrium to its two-variable reduced pair. -/
noncomputable def toReducedEquilibrium
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    ReducedEquilibrium P := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact
    { theta := E.theta
      cutoff := E.reservationCutoff
      theta_pos := E.theta_pos
      cutoff_lt_epsUpper :=
        E.reservationCutoff_lt_epsUpper A M
      jobDestructionMeasure :=
        E.satisfiesJobDestructionMeasure A
      jobCreationProduct :=
        E.satisfiesJobCreationProduct A }

@[simp]
theorem toReducedEquilibrium_theta
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    (E.toReducedEquilibrium A D M).theta = E.theta :=
  rfl

@[simp]
theorem toReducedEquilibrium_cutoff
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    (E.toReducedEquilibrium A D M).cutoff =
      E.reservationCutoff :=
  rfl

/-- The forward reduced pair satisfies the two paper-facing static
conditions. -/
theorem toReducedEquilibrium_satisfies_paper_conditions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.SatisfiesJobDestruction
        (E.toReducedEquilibrium A D M).theta
        (E.toReducedEquilibrium A D M).cutoff
      ∧
    P.SatisfiesJobCreation
        (E.toReducedEquilibrium A D M).theta
        (E.toReducedEquilibrium A D M).cutoff := by
  simpa using
    And.intro (E.satisfiesJobDestruction A D M)
      (E.satisfiesJobCreation A D M)

end ValueEquilibrium

end MP1994V2
