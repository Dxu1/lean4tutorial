import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Unemployment
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.ExistenceUniqueness

/-!
# MP1994 v2: full static equilibrium representation

This module proves exact equivalence between reduced equilibria and their
stock completions, transports M5's conditional existence result, and connects
the full static state back to the reconstructed primitive value equilibrium.
-/

namespace MP1994V2

namespace ReducedEquilibrium

variable {P : Primitives}

/-- Completing and projecting a reduced equilibrium is exactly the identity. -/
theorem toSteady_toReduced
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (R : ReducedEquilibrium P) :
    (R.toSteadyStateEquilibrium A M).toReducedEquilibrium = R :=
  rfl

end ReducedEquilibrium

namespace SteadyStateEquilibrium

variable {P : Primitives}

/-- Projecting and recompleting a full state recovers the full structure
exactly.  Unemployment equality follows from uniqueness of flow balance. -/
theorem toReduced_toSteady
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P) :
    S.toReducedEquilibrium.toSteadyStateEquilibrium A M = S := by
  apply SteadyStateEquilibrium.ext
  · rfl
  · exact (S.unemployment_eq_closedForm A M).symm

/-- Recover the primitive value equilibrium through the M4 reconstruction. -/
noncomputable def toValueEquilibrium
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (S : SteadyStateEquilibrium P) :
    ValueEquilibrium P :=
  S.toReducedEquilibrium.toValueEquilibrium A D

@[simp] theorem toValueEquilibrium_theta
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (S : SteadyStateEquilibrium P) :
    (S.toValueEquilibrium A D).theta = S.theta := rfl

theorem toValueEquilibrium_reservationCutoff
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (S : SteadyStateEquilibrium P) :
    (S.toValueEquilibrium A D).reservationCutoff = S.cutoff := by
  exact S.toReducedEquilibrium.toValueEquilibrium_reservationCutoff A D

/-- There is at most one full steady state under the maintained assumptions;
no existence bundle is used. -/
theorem unique
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (S₁ S₂ : SteadyStateEquilibrium P) :
    S₁ = S₂ := by
  have hReduced : S₁.toReducedEquilibrium = S₂.toReducedEquilibrium :=
    ReducedEquilibrium.unique A D M _ _
  calc
    S₁ = S₁.toReducedEquilibrium.toSteadyStateEquilibrium A M :=
      (S₁.toReduced_toSteady A M).symm
    _ = S₂.toReducedEquilibrium.toSteadyStateEquilibrium A M := by
      rw [hReduced]
    _ = S₂ := S₂.toReduced_toSteady A M

end SteadyStateEquilibrium

/-- Exact equivalence of the full static representation and the reduced pair. -/
noncomputable def steadyStateEquivReduced
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) :
    SteadyStateEquilibrium P ≃ ReducedEquilibrium P where
  toFun := SteadyStateEquilibrium.toReducedEquilibrium
  invFun := ReducedEquilibrium.toSteadyStateEquilibrium A M
  left_inv := SteadyStateEquilibrium.toReduced_toSteady A M
  right_inv := ReducedEquilibrium.toSteady_toReduced A M

/-- Public at-most-one form, independent of static existence assumptions. -/
theorem steadyStateEquilibrium_atMostOne
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    ∀ S₁ S₂ : SteadyStateEquilibrium P, S₁ = S₂ :=
  SteadyStateEquilibrium.unique A D M

/-- Conditional full-state nonemptiness, transported from M5. -/
theorem steadyStateEquilibrium_nonempty
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    Nonempty (SteadyStateEquilibrium P) :=
  (reducedEquilibrium_nonempty A D X).map
    (ReducedEquilibrium.toSteadyStateEquilibrium A M)

/-- Full-state nonemptiness is equivalent to reduced-equilibrium nonemptiness.
This is a representation theorem, not unconditional existence. -/
theorem steadyStateEquilibrium_nonempty_iff_reducedEquilibrium_nonempty
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) :
    Nonempty (SteadyStateEquilibrium P) ↔
      Nonempty (ReducedEquilibrium P) := by
  constructor
  · rintro ⟨S⟩
    exact ⟨S.toReducedEquilibrium⟩
  · rintro ⟨R⟩
    exact ⟨R.toSteadyStateEquilibrium A M⟩

/-- Informative unique-existence proposition for the full static state. -/
def HasUniqueSteadyStateEquilibrium (P : Primitives) : Prop :=
  Nonempty (SteadyStateEquilibrium P) ∧
    ∀ S₁ S₂ : SteadyStateEquilibrium P, S₁ = S₂

/-- Conditional unique existence, inheriting M5's lower-crossing premise. -/
theorem steadyStateEquilibrium_existsUnique
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    HasUniqueSteadyStateEquilibrium P :=
  ⟨steadyStateEquilibrium_nonempty A D M X,
    steadyStateEquilibrium_atMostOne A D M⟩

/-- GREEN M6 capstone: equation (14), balanced flows, exact reduced/full
representation, and at-most-one full state.  This theorem takes no static
existence assumption. -/
theorem m6_stock_completion_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    (∀ S : SteadyStateEquilibrium P,
      S.unemployment =
        (P.lambda * P.cdf S.cutoff) /
          (P.lambda * P.cdf S.cutoff +
            P.workerMeetingRate S.theta))
      ∧
    (∀ S : SteadyStateEquilibrium P,
      P.jobCreationFlow S.theta S.unemployment =
        P.jobDestructionFlow S.cutoff S.unemployment)
      ∧
    (∀ R : ReducedEquilibrium P,
      (R.toSteadyStateEquilibrium A M).toReducedEquilibrium = R)
      ∧
    (∀ S : SteadyStateEquilibrium P,
      S.toReducedEquilibrium.toSteadyStateEquilibrium A M = S)
      ∧
    (∀ S₁ S₂ : SteadyStateEquilibrium P, S₁ = S₂) := by
  exact
    ⟨fun S => S.equation14 A D M,
      fun S => S.jobCreation_eq_jobDestruction,
      fun R => R.toSteady_toReduced A M,
      fun S => S.toReduced_toSteady A M,
      steadyStateEquilibrium_atMostOne A D M⟩

/-- AMBER M6 capstone: full-state nonemptiness and unique existence inherited
entirely from M5's `StaticExistenceAssumptions.lower_crossing`. -/
theorem m6_conditional_existence_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    Nonempty (SteadyStateEquilibrium P) ∧
      HasUniqueSteadyStateEquilibrium P :=
  ⟨steadyStateEquilibrium_nonempty A D M X,
    steadyStateEquilibrium_existsUnique A D M X⟩

/-- Convenience wrapper combining the GREEN stock-completion capstone with the
AMBER conditional-existence capstone.  Its AMBER status comes solely from the
M5-dependent existence component. -/
theorem m6_full_steady_state_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    (∀ S : SteadyStateEquilibrium P,
      S.unemployment =
        (P.lambda * P.cdf S.cutoff) /
          (P.lambda * P.cdf S.cutoff +
            P.workerMeetingRate S.theta))
      ∧
    (∀ S : SteadyStateEquilibrium P,
      P.jobCreationFlow S.theta S.unemployment =
        P.jobDestructionFlow S.cutoff S.unemployment)
      ∧
    (∀ R : ReducedEquilibrium P,
      (R.toSteadyStateEquilibrium A M).toReducedEquilibrium = R)
      ∧
    (∀ S : SteadyStateEquilibrium P,
      S.toReducedEquilibrium.toSteadyStateEquilibrium A M = S)
      ∧
    (∀ S₁ S₂ : SteadyStateEquilibrium P, S₁ = S₂)
      ∧
    Nonempty (SteadyStateEquilibrium P)
      ∧
    HasUniqueSteadyStateEquilibrium P := by
  rcases m6_stock_completion_capstone A D M with
    ⟨heq14, hflows, hreduce, hsteady, hunique⟩
  rcases m6_conditional_existence_capstone A D M X with
    ⟨hnonempty, hexistsUnique⟩
  exact
    ⟨heq14, hflows, hreduce, hsteady, hunique,
      hnonempty, hexistsUnique⟩

end MP1994V2
