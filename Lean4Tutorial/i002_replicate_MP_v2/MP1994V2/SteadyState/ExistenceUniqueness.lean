import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions.StaticExistence
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Equivalence

/-!
# MP1994 v2: existence and uniqueness of the static equilibrium

Uniqueness uses only the maintained economic, shock, and matching bundles.
Existence is explicitly conditional on `StaticExistenceAssumptions`: slopes
alone do not guarantee an intersection.
-/

open Set

namespace MP1994V2

namespace ReducedEquilibrium

/-- Figure 1 gives at most one reduced equilibrium.  No existence condition is
used. -/
theorem unique
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (R1 R2 : ReducedEquilibrium P) :
    R1 = R2 := by
  have hCutoff : R1.cutoff = R2.cutoff := by
    rcases lt_trichotomy R1.cutoff R2.cutoff with hlt | heq | hgt
    · have hJD : R1.theta < R2.theta :=
        jobDestruction_curve_strictMono A D
          R1.jobDestructionMeasure R2.jobDestructionMeasure hlt
      have hJC : R2.theta < R1.theta :=
        jobCreation_curve_strictAnti A M R1.theta_pos R2.theta_pos
          R1.cutoff_lt_epsUpper R2.cutoff_lt_epsUpper
          R1.jobCreationProduct R2.jobCreationProduct hlt
      exact False.elim (lt_asymm hJD hJC)
    · exact heq
    · have hJD : R2.theta < R1.theta :=
        jobDestruction_curve_strictMono A D
          R2.jobDestructionMeasure R1.jobDestructionMeasure hgt
      have hJC : R1.theta < R2.theta :=
        jobCreation_curve_strictAnti A M R2.theta_pos R1.theta_pos
          R2.cutoff_lt_epsUpper R1.cutoff_lt_epsUpper
          R2.jobCreationProduct R1.jobCreationProduct hgt
      exact False.elim (lt_asymm hJD hJC)
  have hTheta : R1.theta = R2.theta := by
    have h1 := (P.satisfiesJobDestructionMeasure_iff A R1.theta R1.cutoff).mp
      R1.jobDestructionMeasure
    have h2 := (P.satisfiesJobDestructionMeasure_iff A R2.theta R2.cutoff).mp
      R2.jobDestructionMeasure
    rw [h1, h2, hCutoff]
  exact ReducedEquilibrium.ext hTheta hCutoff

end ReducedEquilibrium

/-- Public at-most-one form, deliberately not an implicit instance. -/
theorem reducedEquilibrium_atMostOne
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    ∀ R1 R2 : ReducedEquilibrium P, R1 = R2 :=
  ReducedEquilibrium.unique A D M

namespace Primitives

/-- Continuity of the scalar residual on a bracket whose JD-implied tightness
is positive at the lower endpoint. -/
theorem staticCrossingResidual_continuousOn_Icc
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (X : StaticExistenceAssumptions P)
    (d0 : ℝ)
    (hd0 : d0 < P.epsUpper)
    (htheta0 : 0 < P.jobDestructionTheta d0) :
    ContinuousOn P.staticCrossingResidual (Icc d0 P.epsUpper) := by
  have hThetaContinuous := P.jobDestructionTheta_continuous A D
  have hMaps : MapsTo P.jobDestructionTheta (Icc d0 P.epsUpper) (Ioi 0) := by
    intro d hd
    exact lt_of_lt_of_le htheta0
      ((P.jobDestructionTheta_strictMono A D).monotone hd.1)
  have hq : ContinuousOn
      (fun d => P.q (P.jobDestructionTheta d)) (Icc d0 P.epsUpper) :=
    X.q_continuousOn_pos.comp' hThetaContinuous.continuousOn hMaps
  unfold staticCrossingResidual
  exact ((hq.mul_const P.jobCreationScale).mul
    (continuous_const.sub continuous_id).continuousOn).sub continuousOn_const

end Primitives

/-- The explicit bracket conditions yield a strictly interior admissible
crossing by `intermediate_value_Icc'`. -/
theorem exists_staticCrossing
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (X : StaticExistenceAssumptions P) :
    ∃ dStar : ℝ,
      dStar < P.epsUpper ∧
      0 < P.jobDestructionTheta dStar ∧
      P.staticCrossingResidual dStar = 0 := by
  rcases X.lower_crossing with ⟨d0, hd0, htheta0, hres0⟩
  have hcont := P.staticCrossingResidual_continuousOn_Icc A D X d0 hd0 htheta0
  have hzero : (0 : ℝ) ∈ Icc
      (P.staticCrossingResidual P.epsUpper)
      (P.staticCrossingResidual d0) := by
    constructor
    · exact (P.staticCrossingResidual_epsUpper_neg A).le
    · exact hres0.le
  rcases (intermediate_value_Icc' hd0.le hcont hzero) with
    ⟨dStar, hdStar, hroot⟩
  have hLowerStrict : d0 < dStar := by
    rcases hdStar.1.eq_or_lt with heq | hlt
    · subst dStar
      linarith
    · exact hlt
  have hUpperStrict : dStar < P.epsUpper := by
    rcases hdStar.2.eq_or_lt with heq | hlt
    · rw [heq, P.staticCrossingResidual_epsUpper] at hroot
      linarith [A.c_pos]
    · exact hlt
  have htheta : 0 < P.jobDestructionTheta dStar :=
    lt_of_lt_of_le htheta0
      ((P.jobDestructionTheta_strictMono A D).monotone hLowerStrict.le)
  exact ⟨dStar, hUpperStrict, htheta, hroot⟩

/-- Constructive-in-logic existence of the robust reduced equilibrium. -/
theorem reducedEquilibrium_nonempty
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (X : StaticExistenceAssumptions P) :
    Nonempty (ReducedEquilibrium P) := by
  rcases exists_staticCrossing A D X with ⟨d, hd, htheta, hroot⟩
  refine ⟨{
    theta := P.jobDestructionTheta d
    cutoff := d
    theta_pos := htheta
    cutoff_lt_epsUpper := hd
    jobDestructionMeasure := ?_
    jobCreationProduct := ?_ }⟩
  · exact (P.satisfiesJobDestructionMeasure_iff A _ _).mpr rfl
  · unfold Primitives.staticCrossingResidual at hroot
    unfold Primitives.SatisfiesJobCreationProduct
    simpa [Primitives.jobCreationScale, mul_assoc] using sub_eq_zero.mp hroot

/-- A noncomputable selected reduced equilibrium, useful only as a logical
representative. -/
noncomputable def staticReducedEquilibrium
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (X : StaticExistenceAssumptions P) :
    ReducedEquilibrium P :=
  Classical.choice (reducedEquilibrium_nonempty A D X)

theorem ReducedEquilibrium.eq_staticReducedEquilibrium
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P)
    (R : ReducedEquilibrium P) :
    R = staticReducedEquilibrium A D X :=
  R.unique A D M (staticReducedEquilibrium A D X)

/-- Informative unique-existence interface for the reduced system. -/
def HasUniqueReducedEquilibrium (P : Primitives) : Prop :=
  Nonempty (ReducedEquilibrium P) ∧
    ∀ R1 R2 : ReducedEquilibrium P, R1 = R2

theorem reducedEquilibrium_existsUnique
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    HasUniqueReducedEquilibrium P :=
  ⟨reducedEquilibrium_nonempty A D X,
    reducedEquilibrium_atMostOne A D M⟩

theorem ReducedEquilibrium.theta_eq
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (R1 R2 : ReducedEquilibrium P) :
    R1.theta = R2.theta := by
  rw [R1.unique A D M R2]

theorem ReducedEquilibrium.cutoff_eq
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (R1 R2 : ReducedEquilibrium P) :
    R1.cutoff = R2.cutoff := by
  rw [R1.unique A D M R2]

/-- Conditional value-equilibrium existence, transported through M4. -/
theorem valueEquilibrium_nonempty
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (X : StaticExistenceAssumptions P) :
    Nonempty (ValueEquilibrium P) :=
  (reducedEquilibrium_nonempty A D X).map
    (fun R => R.toValueEquilibrium A D)

namespace ValueEquilibrium

theorem theta_eq
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E1 E2 : ValueEquilibrium P) :
    E1.theta = E2.theta := by
  exact ReducedEquilibrium.theta_eq A D M
    (E1.toReducedEquilibrium A D M) (E2.toReducedEquilibrium A D M)

theorem reservationCutoff_eq
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E1 E2 : ValueEquilibrium P) :
    E1.reservationCutoff = E2.reservationCutoff := by
  exact ReducedEquilibrium.cutoff_eq A D M
    (E1.toReducedEquilibrium A D M) (E2.toReducedEquilibrium A D M)

/-- Equality of every public economic component, without claiming equality of
proof-valued equilibrium records. -/
def EconomicallyEquivalent
    {P : Primitives} (E1 E2 : ValueEquilibrium P) : Prop :=
  E1.theta = E2.theta ∧ E1.V = E2.V ∧ E1.U = E2.U ∧
    E1.J = E2.J ∧ E1.W = E2.W ∧ E1.wage = E2.wage ∧
    ∀ eps : ℝ,
      E1.toValueCandidate.surplus eps = E2.toValueCandidate.surplus eps

theorem economically_unique
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E1 E2 : ValueEquilibrium P) :
    E1.EconomicallyEquivalent E2 := by
  let R1 := E1.toReducedEquilibrium A D M
  let R2 := E2.toReducedEquilibrium A D M
  have hR : R1 = R2 := ReducedEquilibrium.unique A D M R1 R2
  have h1 := E1.reconstruction_economic_roundtrip A D M
  have h2 := E2.reconstruction_economic_roundtrip A D M
  dsimp only at h1 h2
  change E1.toReducedEquilibrium A D M =
    E2.toReducedEquilibrium A D M at hR
  rw [hR] at h1
  rcases h1 with ⟨ht1, hV1, hU1, hJ1, hW1, hw1, hS1⟩
  rcases h2 with ⟨ht2, hV2, hU2, hJ2, hW2, hw2, hS2⟩
  exact ⟨ht1.symm.trans ht2, hV1.symm.trans hV2,
    hU1.symm.trans hU2, hJ1.symm.trans hJ2,
    hW1.symm.trans hW2, hw1.symm.trans hw2,
    fun eps => (hS1 eps).symm.trans (hS2 eps)⟩

end ValueEquilibrium

theorem valueEquilibrium_exists_economicallyUnique
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    Nonempty (ValueEquilibrium P) ∧
      ∀ E1 E2 : ValueEquilibrium P,
        E1.EconomicallyEquivalent E2 :=
  ⟨valueEquilibrium_nonempty A D X,
    ValueEquilibrium.economically_unique A D M⟩

/-- M5 capstone: conditional unique existence of the reduced equilibrium and
economic unique existence of its primitive-value representation. -/
theorem m5_static_equilibrium_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (X : StaticExistenceAssumptions P) :
    HasUniqueReducedEquilibrium P ∧
      Nonempty (ValueEquilibrium P) ∧
      ∀ E1 E2 : ValueEquilibrium P,
        E1.EconomicallyEquivalent E2 :=
  ⟨reducedEquilibrium_existsUnique A D M X,
    valueEquilibrium_nonempty A D X,
    ValueEquilibrium.economically_unique A D M⟩

end MP1994V2
