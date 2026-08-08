import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Cutoff

/-!
# MP1994 v2: job creation

This module derives paper equation (13) from vacancy free entry, Nash surplus
sharing, and the M2 affine surplus formula at `epsUpper`.  It is independent of
the job-destruction equation and the M3 tail integral.
-/

open MeasureTheory

namespace MP1994V2

namespace Primitives

variable (P : Primitives)

/-- Paper equation (13) written as a zero residual. -/
noncomputable def jobCreationResidual (theta d : ℝ) : ℝ :=
  P.q theta
    - (P.c / (1 - P.beta)) *
        ((P.r + P.lambda) /
          (P.sigma * (P.epsUpper - d)))

/-- A pair `(theta,d)` satisfies the paper's job-creation condition. -/
def SatisfiesJobCreation (theta d : ℝ) : Prop :=
  P.jobCreationResidual theta d = 0

end Primitives

namespace ValueEquilibrium

variable {P : Primitives}

/-- Robust non-divided form of the job-creation condition.  It combines
equations (1)--(2), firm surplus sharing, and M2 affine surplus at the
designated new-job state. -/
theorem job_creation_product_identity
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    P.q E.theta
        * (1 - P.beta)
        * (P.sigma / (P.r + P.lambda))
        * (P.epsUpper - E.reservationCutoff) =
      P.c := by
  have hFree :=
    E.vacancy_meeting_mul_upper_firm_value_eq_cost A
  rw [E.firm_share P.epsUpper,
    E.surplus_eq_slope_mul_sub_cutoff A P.epsUpper] at hFree
  simpa only [mul_assoc] using hFree

/-- Paper equation (13):

`q(theta) = [c/(1-beta)]
  [(r+lambda)/(sigma (epsUpper-epsD))]`.

The theorem uses free entry and M2; it does not use equation (10).
-/
theorem equation13
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.q E.theta =
      (P.c / (1 - P.beta)) *
        ((P.r + P.lambda) /
          (P.sigma *
            (P.epsUpper - E.reservationCutoff))) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hProduct := E.job_creation_product_identity A
  have hBeta : 1 - P.beta ≠ 0 := A.one_sub_beta_pos.ne'
  have hRate : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  have hSigma : P.sigma ≠ 0 := A.sigma_ne
  have hGapPos :
      0 < P.epsUpper - E.reservationCutoff :=
    sub_pos.mpr (E.reservationCutoff_lt_epsUpper A M)
  have hGap : P.epsUpper - E.reservationCutoff ≠ 0 :=
    hGapPos.ne'
  field_simp [hBeta, hRate, hSigma, hGap] at hProduct ⊢
  simpa [mul_assoc, mul_left_comm, mul_comm] using hProduct

/-- The equilibrium tightness and cutoff satisfy equation (13) in residual
form. -/
theorem satisfiesJobCreation
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.SatisfiesJobCreation E.theta E.reservationCutoff := by
  unfold Primitives.SatisfiesJobCreation
    Primitives.jobCreationResidual
  rw [E.equation13 A D M]
  ring

end ValueEquilibrium

end MP1994V2
