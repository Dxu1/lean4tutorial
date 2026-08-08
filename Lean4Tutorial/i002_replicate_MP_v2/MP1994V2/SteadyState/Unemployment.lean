import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Equilibrium.SteadyState

/-!
# MP1994 v2: unemployment stock completion

For a reduced pair, the separation hazard `s` and job-finding hazard `f`
determine the unique balanced unemployment stock `u = s / (s + f)`.  The CDF
form is then paper equation (14).
-/

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- Foundational strict-event closed form `u = s / (s+f)`. -/
noncomputable def steadyStateUnemployment
    (P : Primitives) (theta d : ℝ) : ℝ :=
  P.jobSeparationRate d /
    (P.jobSeparationRate d + P.jobFindingRate theta)

theorem steadyStateUnemployment_nonneg
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) {theta d : ℝ}
    (htheta : 0 < theta) :
    0 ≤ P.steadyStateUnemployment theta d := by
  exact div_nonneg (P.jobSeparationRate_nonneg A d)
    (P.totalTransitionHazard_pos A M htheta).le

theorem steadyStateUnemployment_lt_one
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) {theta d : ℝ}
    (htheta : 0 < theta) :
    P.steadyStateUnemployment theta d < 1 := by
  apply (div_lt_one (P.totalTransitionHazard_pos A M htheta)).mpr
  linarith [P.jobFindingRate_pos M htheta]

/-- The closed form satisfies destruction-flow equals creation-flow. -/
theorem steadyStateUnemployment_flow_balance
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) {theta d : ℝ}
    (htheta : 0 < theta) :
    P.jobDestructionFlow d (P.steadyStateUnemployment theta d) =
      P.jobCreationFlow theta (P.steadyStateUnemployment theta d) := by
  have htotal := P.totalTransitionHazard_pos A M (d := d) htheta
  unfold steadyStateUnemployment jobDestructionFlow jobCreationFlow
    employmentFromUnemployment
  field_simp [htotal.ne']
  ring

/-- Flow balance uniquely determines the unemployment stock, without a stock
bounds premise. -/
theorem flow_balance_iff_unemployment_eq
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) {theta d u : ℝ}
    (htheta : 0 < theta) :
    P.unemploymentFlowResidual theta d u = 0 ↔
      u = P.steadyStateUnemployment theta d := by
  have htotal := P.totalTransitionHazard_pos A M (d := d) htheta
  unfold unemploymentFlowResidual jobDestructionFlow jobCreationFlow
    employmentFromUnemployment steadyStateUnemployment
  constructor
  · intro h
    field_simp [htotal.ne']
    linear_combination -h
  · intro h
    rw [h]
    field_simp [htotal.ne']
    ring

/-- Paper equation (14), obtained from the strict-event formula using no
atoms. -/
theorem steadyStateUnemployment_eq_equation14
    (D : ShockAssumptions P) (theta d : ℝ) :
    P.steadyStateUnemployment theta d =
      (P.lambda * P.cdf d) /
        (P.lambda * P.cdf d + P.workerMeetingRate theta) := by
  rw [steadyStateUnemployment, P.jobSeparationRate_eq_lambda_mul_cdf D]
  rfl

end Primitives

namespace ReducedEquilibrium

variable {P : Primitives}

/-- Complete any existing reduced equilibrium with its unique balanced
unemployment stock.  This is not an existence theorem for the reduced pair. -/
noncomputable def toSteadyStateEquilibrium
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (R : ReducedEquilibrium P) :
    SteadyStateEquilibrium P where
  toReducedEquilibrium := R
  unemployment := P.steadyStateUnemployment R.theta R.cutoff
  unemployment_nonneg :=
    P.steadyStateUnemployment_nonneg A M R.theta_pos
  unemployment_le_one :=
    (P.steadyStateUnemployment_lt_one A M R.theta_pos).le
  flow_balance :=
    P.steadyStateUnemployment_flow_balance A M R.theta_pos

@[simp] theorem toSteadyStateEquilibrium_theta
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) (R : ReducedEquilibrium P) :
    (R.toSteadyStateEquilibrium A M).theta = R.theta := rfl

@[simp] theorem toSteadyStateEquilibrium_cutoff
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) (R : ReducedEquilibrium P) :
    (R.toSteadyStateEquilibrium A M).cutoff = R.cutoff := rfl

@[simp] theorem toSteadyStateEquilibrium_unemployment
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) (R : ReducedEquilibrium P) :
    (R.toSteadyStateEquilibrium A M).unemployment =
      P.steadyStateUnemployment R.theta R.cutoff := rfl

end ReducedEquilibrium

namespace SteadyStateEquilibrium

variable {P : Primitives}

/-- Every full steady state's stored flow balance forces the strict-event
closed form. -/
theorem unemployment_eq_closedForm
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P) :
    S.unemployment =
      P.steadyStateUnemployment S.theta S.cutoff := by
  apply (P.flow_balance_iff_unemployment_eq A M S.theta_pos).mp
  unfold Primitives.unemploymentFlowResidual
  rw [S.flow_balance]
  simp

/-- Paper equation (14) for every full static steady state. -/
theorem equation14
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P) :
    S.unemployment =
      (P.lambda * P.cdf S.cutoff) /
        (P.lambda * P.cdf S.cutoff +
          P.workerMeetingRate S.theta) := by
  rw [S.unemployment_eq_closedForm A M,
    P.steadyStateUnemployment_eq_equation14 D]

theorem employment_nonneg (S : SteadyStateEquilibrium P) :
    0 ≤ S.employment :=
  sub_nonneg.mpr S.unemployment_le_one

theorem employment_le_one (S : SteadyStateEquilibrium P) :
    S.employment ≤ 1 := by
  unfold employment Primitives.employmentFromUnemployment
  linarith [S.unemployment_nonneg]

theorem employment_pos
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P) :
    0 < S.employment := by
  unfold employment Primitives.employmentFromUnemployment
  rw [S.unemployment_eq_closedForm A M]
  exact sub_pos.mpr
    (P.steadyStateUnemployment_lt_one A M S.theta_pos)

theorem vacancies_nonneg (S : SteadyStateEquilibrium P) :
    0 ≤ S.vacancies := by
  exact mul_nonneg S.theta_pos.le S.unemployment_nonneg

/-- Creation can be written either as `theta*q(theta)*u` or `q(theta)*v`. -/
theorem jobCreationFlow_eq_q_mul_vacancies
    (S : SteadyStateEquilibrium P) :
    P.jobCreationFlow S.theta S.unemployment =
      P.q S.theta * S.vacancies := by
  unfold Primitives.jobCreationFlow Primitives.jobFindingRate
    Primitives.workerMeetingRate vacancies Primitives.vacanciesFromTightness
  ring

/-- Destruction has the paper form `lambda*F(d)*(1-u)`. -/
theorem jobDestructionFlow_eq_lambda_cdf_mul_employment
    (D : ShockAssumptions P) (S : SteadyStateEquilibrium P) :
    P.jobDestructionFlow S.cutoff S.unemployment =
      (P.lambda * P.cdf S.cutoff) * S.employment := by
  exact P.jobDestructionFlow_eq_lambda_cdf_mul_employment
    D S.cutoff S.unemployment

/-- Steady-state job creation equals job destruction. -/
theorem jobCreation_eq_jobDestruction (S : SteadyStateEquilibrium P) :
    P.jobCreationFlow S.theta S.unemployment =
      P.jobDestructionFlow S.cutoff S.unemployment :=
  S.flow_balance.symm

theorem unemployment_pos_of_positiveSeparation
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P)
    (hsep : P.HasPositiveSeparationAt S.cutoff) :
    0 < S.unemployment := by
  rw [S.unemployment_eq_closedForm A M]
  exact div_pos hsep (P.totalTransitionHazard_pos A M S.theta_pos)

theorem unemployment_mem_Ioo_of_positiveSeparation
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P)
    (hsep : P.HasPositiveSeparationAt S.cutoff) :
    S.unemployment ∈ Set.Ioo (0 : ℝ) 1 :=
  ⟨S.unemployment_pos_of_positiveSeparation A M hsep,
    by
      rw [S.unemployment_eq_closedForm A M]
      exact P.steadyStateUnemployment_lt_one A M S.theta_pos⟩

theorem vacancies_pos_of_positiveSeparation
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P)
    (hsep : P.HasPositiveSeparationAt S.cutoff) :
    0 < S.vacancies :=
  mul_pos S.theta_pos
    (S.unemployment_pos_of_positiveSeparation A M hsep)

/-- The literal stock ratio `v/u = theta` requires positive unemployment. -/
theorem vacancies_div_unemployment_eq_theta
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P)
    (hsep : P.HasPositiveSeparationAt S.cutoff) :
    S.vacancies / S.unemployment = S.theta := by
  unfold vacancies Primitives.vacanciesFromTightness
  exact mul_div_cancel_right₀ S.theta
    (S.unemployment_pos_of_positiveSeparation A M hsep).ne'

/-- With zero separation, the stock completion has zero unemployment. -/
theorem unemployment_eq_zero_of_separation_eq_zero
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P)
    (hsep : P.jobSeparationRate S.cutoff = 0) :
    S.unemployment = 0 := by
  rw [S.unemployment_eq_closedForm A M]
  unfold Primitives.steadyStateUnemployment
  rw [hsep]
  simp

theorem vacancies_eq_zero_of_separation_eq_zero
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (S : SteadyStateEquilibrium P)
    (hsep : P.jobSeparationRate S.cutoff = 0) :
    S.vacancies = 0 := by
  unfold vacancies Primitives.vacanciesFromTightness
  rw [S.unemployment_eq_zero_of_separation_eq_zero A M hsep]
  simp

end SteadyStateEquilibrium

end MP1994V2
