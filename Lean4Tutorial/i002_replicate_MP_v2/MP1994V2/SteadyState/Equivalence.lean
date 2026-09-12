import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.ForwardBridge
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Reconstruction

/-!
# MP1994 v2: reduced/value-equilibrium equivalence

This module completes the representation result of Milestone 4.  It proves
exact equality for the reduced round trip and public componentwise equality
for the value-object round trip.  The nonemptiness theorem is conditional in
both directions; it is not an equilibrium-existence theorem.
-/

namespace MP1994V2

namespace ReducedEquilibrium

variable {P : Primitives}

/-- Reconstructing values and reducing again recovers the original reduced
pair exactly. -/
theorem toValue_toReduced
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (R : ReducedEquilibrium P) :
    (R.toValueEquilibrium A D).toReducedEquilibrium A D M = R := by
  apply ReducedEquilibrium.ext
  · rfl
  · exact R.toValueEquilibrium_reservationCutoff A D

end ReducedEquilibrium

namespace ValueEquilibrium

variable {P : Primitives}

/-- Equations (4), (6), and (7), the surplus flow identity, and vacancy free
entry imply the paper's explicit Nash wage formula.  No probability or
matching assumption is used. -/
theorem wage_eq_nash_formula
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P)
    (eps : ℝ) :
    E.wage eps =
      P.beta * P.productivity eps
        + (1 - P.beta) * P.b
        + P.beta * P.c * E.theta := by
  have hWorker := E.worker_bellman eps
  have hUnemployed := E.unemployed_bellman
  have hFlow := E.surplus_flow_equation eps
  have hShare := E.nash_sharing eps
  have hUpperShare := E.nash_sharing P.epsUpper
  have hSearch := E.search_gain_eq A
  have hBeta : 1 - P.beta ≠ 0 := A.one_sub_beta_pos.ne'
  change
    P.r * E.W eps =
      E.wage eps + P.lambda * P.beta *
        E.toValueCandidate.continuation P eps at hWorker
  change E.W eps - E.U =
    P.beta * E.toValueCandidate.surplus eps at hShare
  change E.W P.epsUpper - E.U =
    P.beta * E.toValueCandidate.surplus P.epsUpper at hUpperShare
  rw [hUpperShare] at hUnemployed
  rw [hUpperShare] at hFlow
  have hIntermediate :
      E.wage eps =
        P.beta * P.productivity eps
          + (1 - P.beta) * P.b
          + P.beta * (1 - P.beta) *
              P.workerMeetingRate E.theta *
                E.toValueCandidate.surplus P.epsUpper := by
    linear_combination
      -hWorker + hUnemployed + P.r * hShare + P.beta * hFlow
  field_simp [hBeta] at hSearch
  linear_combination
    hIntermediate + hSearch

/-- The reconstructed surplus after reducing an existing value equilibrium is
the original surplus. -/
theorem reconstructed_surplus_eq
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P)
    (eps : ℝ) :
    let R := E.toReducedEquilibrium A D M
    (R.toValueEquilibrium A D).toValueCandidate.surplus eps =
      E.toValueCandidate.surplus eps := by
  let R := E.toReducedEquilibrium A D M
  dsimp only
  rw [R.toValueEquilibrium_surplus A D]
  unfold ReducedEquilibrium.surplusCandidate
  rw [E.toReducedEquilibrium_cutoff]
  exact
    (E.surplus_eq_slope_mul_sub_cutoff_of_shockAssumptions
      A D eps).symm

/-- Reducing and reconstructing preserves every public economic component of
the primitive value equilibrium. -/
theorem reconstruction_components
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    let R := E.toReducedEquilibrium A D M
    let E' := R.toValueEquilibrium A D
    E'.theta = E.theta
      ∧ E'.V = E.V
      ∧ E'.U = E.U
      ∧ E'.J = E.J
      ∧ E'.W = E.W
      ∧ E'.wage = E.wage := by
  let R := E.toReducedEquilibrium A D M
  let E' := R.toValueEquilibrium A D
  have hSurplus :
      ∀ eps, E'.toValueCandidate.surplus eps =
        E.toValueCandidate.surplus eps := by
    intro eps
    exact E.reconstructed_surplus_eq A D M eps
  have hTheta : E'.theta = E.theta := rfl
  have hV : E'.V = E.V := by
    change R.vacancyValueCandidate = E.V
    rw [E.vacancy_value_eq_zero A]
    rfl
  have hJ : E'.J = E.J := by
    funext eps
    change R.firmValueCandidate eps = E.J eps
    rw [E.firm_share eps]
    unfold ReducedEquilibrium.firmValueCandidate
    rw [← R.toValueEquilibrium_surplus A D eps, hSurplus eps]
  have hU : E'.U = E.U := by
    have hOriginal := E.unemployed_bellman
    rw [E.nash_sharing P.epsUpper] at hOriginal
    change
      P.r * E.U =
        P.b + P.workerMeetingRate E.theta *
          (P.beta * E.toValueCandidate.surplus P.epsUpper)
        at hOriginal
    have hr : P.r ≠ 0 := A.r_pos.ne'
    change R.unemploymentValueCandidate = E.U
    unfold ReducedEquilibrium.unemploymentValueCandidate
    rw [E.toReducedEquilibrium_theta]
    unfold Primitives.workerMeetingRate
    field_simp [hr]
    rw [← R.toValueEquilibrium_surplus A D P.epsUpper,
      hSurplus P.epsUpper]
    unfold Primitives.workerMeetingRate at hOriginal
    linear_combination -hOriginal
  have hW : E'.W = E.W := by
    funext eps
    change R.workerValueCandidate eps = E.W eps
    unfold ReducedEquilibrium.workerValueCandidate
    change E'.U + P.beta * R.surplusCandidate eps = E.W eps
    rw [hU, ← R.toValueEquilibrium_surplus A D eps,
      hSurplus eps]
    have hShare := E.nash_sharing eps
    change E.W eps - E.U =
      P.beta * E.toValueCandidate.surplus eps at hShare
    linarith
  have hWage : E'.wage = E.wage := by
    funext eps
    change R.wageCandidate eps = E.wage eps
    unfold ReducedEquilibrium.wageCandidate
    rw [E.toReducedEquilibrium_theta,
      E.wage_eq_nash_formula A eps]
  exact ⟨hTheta, hV, hU, hJ, hW, hWage⟩

/-- The complete public economic round trip: reducing and reconstructing
preserves every stored economic component and the derived surplus. -/
theorem reconstruction_economic_roundtrip
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    let R := E.toReducedEquilibrium A D M
    let E' := R.toValueEquilibrium A D
    E'.theta = E.theta
      ∧ E'.V = E.V
      ∧ E'.U = E.U
      ∧ E'.J = E.J
      ∧ E'.W = E.W
      ∧ E'.wage = E.wage
      ∧
        (∀ eps : ℝ,
          E'.toValueCandidate.surplus eps =
            E.toValueCandidate.surplus eps) := by
  rcases E.reconstruction_components A D M with
    ⟨hTheta, hV, hU, hJ, hW, hWage⟩
  exact
    ⟨hTheta, hV, hU, hJ, hW, hWage,
      fun eps => E.reconstructed_surplus_eq A D M eps⟩

end ValueEquilibrium

/-- A primitive value equilibrium is inhabited exactly when the robust
two-variable reduced equilibrium is inhabited.  Each implication consumes a
witness supplied by the other side. -/
theorem valueEquilibrium_nonempty_iff_reducedEquilibrium_nonempty
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    Nonempty (ValueEquilibrium P) ↔
      Nonempty (ReducedEquilibrium P) := by
  constructor
  · rintro ⟨E⟩
    exact ⟨E.toReducedEquilibrium A D M⟩
  · rintro ⟨R⟩
    exact ⟨R.toValueEquilibrium A D⟩

/-- Existential spelling of the conditional representation equivalence. -/
theorem exists_valueEquilibrium_iff_exists_reducedEquilibrium
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    (∃ _ : ValueEquilibrium P, True) ↔
      (∃ _ : ReducedEquilibrium P, True) := by
  constructor
  · rintro ⟨E, -⟩
    exact ⟨E.toReducedEquilibrium A D M, trivial⟩
  · rintro ⟨R, -⟩
    exact ⟨R.toValueEquilibrium A D, trivial⟩

/-- Milestone 4 capstone: exact reduced round trip, complete public economic
value round trip, and logical equivalence of equilibrium nonemptiness. -/
theorem m4_representation_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    (∀ R : ReducedEquilibrium P,
      (R.toValueEquilibrium A D).toReducedEquilibrium A D M = R)
      ∧
    (∀ E : ValueEquilibrium P,
      let R := E.toReducedEquilibrium A D M
      let E' := R.toValueEquilibrium A D
      E'.theta = E.theta
        ∧ E'.V = E.V
        ∧ E'.U = E.U
        ∧ E'.J = E.J
        ∧ E'.W = E.W
        ∧ E'.wage = E.wage
        ∧
          (∀ eps : ℝ,
            E'.toValueCandidate.surplus eps =
              E.toValueCandidate.surplus eps))
      ∧
    (Nonempty (ValueEquilibrium P) ↔
      Nonempty (ReducedEquilibrium P)) := by
  exact
    ⟨fun R => R.toValue_toReduced A D M,
      fun E => E.reconstruction_economic_roundtrip A D M,
      valueEquilibrium_nonempty_iff_reducedEquilibrium_nonempty A D M⟩

end MP1994V2
