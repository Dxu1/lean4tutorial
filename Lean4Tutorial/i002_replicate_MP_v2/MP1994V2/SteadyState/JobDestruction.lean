import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Continuation

/-!
# MP1994 v2: job destruction

This module evaluates equation (9) at the derived reservation cutoff and uses
vacancy free entry to derive paper equation (10).  It then packages the result
as residual predicates suitable for Milestone 4, without defining a reduced
equilibrium.
-/

open MeasureTheory

namespace MP1994V2

namespace Primitives

variable (P : Primitives)

/-- Measure-form job-destruction residual. -/
noncomputable def jobDestructionResidualMeasure
    (theta d : ℝ) : ℝ :=
  P.p + P.sigma * d
    - P.b
    - (P.beta * P.c / (1 - P.beta)) * theta
    + (P.lambda * P.sigma / (P.r + P.lambda)) *
        P.expectedExcess d

/-- Paper-facing CDF-tail job-destruction residual. -/
noncomputable def jobDestructionResidual
    (theta d : ℝ) : ℝ :=
  P.p + P.sigma * d
    - P.b
    - (P.beta * P.c / (1 - P.beta)) * theta
    + (P.lambda * P.sigma / (P.r + P.lambda)) *
        P.tailOptionValue d

/-- A pair `(theta,d)` satisfies the measure-form job-destruction equation. -/
def SatisfiesJobDestructionMeasure (theta d : ℝ) : Prop :=
  P.jobDestructionResidualMeasure theta d = 0

/-- A pair `(theta,d)` satisfies paper equation (10). -/
def SatisfiesJobDestruction (theta d : ℝ) : Prop :=
  P.jobDestructionResidual theta d = 0

end Primitives

namespace ValueEquilibrium

variable {P : Primitives}

/-- Free entry converts the upper-job search term into the worker's foregone
search gain:

`beta theta q(theta) S(epsUpper) = [beta c/(1-beta)] theta`.

The proof uses the free-entry product directly and never divides by `q`.
-/
theorem search_gain_eq
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    P.beta * P.workerMeetingRate E.theta *
        E.toValueCandidate.surplus P.epsUpper =
      (P.beta * P.c / (1 - P.beta)) * E.theta := by
  have hFree :=
    E.vacancy_meeting_mul_upper_firm_value_eq_cost A
  rw [E.firm_share P.epsUpper] at hFree
  have hBeta : 1 - P.beta ≠ 0 := A.one_sub_beta_pos.ne'
  unfold Primitives.workerMeetingRate
  field_simp [hBeta]
  linear_combination P.beta * E.theta * hFree

/-- Measure-form paper equation (10), obtained by evaluating equation (9) at
the zero-surplus cutoff and substituting the free-entry search gain. -/
theorem equation10_measure
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    P.p + P.sigma * E.reservationCutoff =
      P.b
        + (P.beta * P.c / (1 - P.beta)) * E.theta
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.expectedExcess E.reservationCutoff := by
  have hNine := E.equation9_measure A E.reservationCutoff
  have hZero := E.surplus_reservationCutoff_eq_zero A
  have hSearch := E.search_gain_eq A
  rw [hZero, mul_zero, hSearch] at hNine
  linarith

/-- Paper equation (10), with the option value written as the CDF-tail
integral `∫_[epsD,epsUpper] (1-F(x)) dx`. -/
theorem equation10
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.p + P.sigma * E.reservationCutoff =
      P.b
        + (P.beta * P.c / (1 - P.beta)) * E.theta
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue E.reservationCutoff := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  rw [← E.expectedExcess_cutoff_eq_tailOptionValue A D M]
  exact E.equation10_measure A

/-- The equilibrium pair satisfies the foundational measure-form
job-destruction residual. -/
theorem satisfiesJobDestructionMeasure
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    P.SatisfiesJobDestructionMeasure
      E.theta E.reservationCutoff := by
  unfold Primitives.SatisfiesJobDestructionMeasure
    Primitives.jobDestructionResidualMeasure
  linarith [E.equation10_measure A]

/-- The equilibrium pair satisfies paper equation (10) in residual form. -/
theorem satisfiesJobDestruction
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.SatisfiesJobDestruction E.theta E.reservationCutoff := by
  unfold Primitives.SatisfiesJobDestruction
    Primitives.jobDestructionResidual
  linarith [E.equation10 A D M]

end ValueEquilibrium

end MP1994V2
