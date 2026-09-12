import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Probability
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Matching

/-!
# MP1994 v2: static unemployment hazards and flows

The economic destruction rule is strict: a job is destroyed after a redraw
when `eps < d`.  The paper writes its probability as `F(d)` because the shock
law has no atoms.  This file keeps the strict event foundational and proves the
paper-facing CDF representation separately.
-/

open MeasureTheory Set

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- Strict lower-tail shock mass `Pr(eps < d)`, matching the destruction rule. -/
noncomputable def strictShockBelow (P : Primitives) (d : ℝ) : ℝ :=
  (P.shock (Iio d)).toReal

/-- Atomlessness identifies the strict destruction probability with the CDF. -/
theorem strictShockBelow_eq_cdf
    (D : ShockAssumptions P) (d : ℝ) :
    P.strictShockBelow d = P.cdf d := by
  letI : NullSingletonClass P.shock := D.noAtoms
  unfold strictShockBelow cdf
  have hset : Iic d = Iio d ∪ {d} := by
    ext x
    simp [le_iff_lt_or_eq]
  rw [hset, measure_union]
  · simp
  · exact Set.disjoint_singleton_right.mpr (lt_irrefl d)
  · exact measurableSet_singleton d

theorem strictShockBelow_nonneg (d : ℝ) :
    0 ≤ P.strictShockBelow d :=
  ENNReal.toReal_nonneg

/-- Separation hazard `s(d) = lambda * Pr(eps < d)`. -/
noncomputable def jobSeparationRate (P : Primitives) (d : ℝ) : ℝ :=
  P.lambda * P.strictShockBelow d

/-- Paper-facing CDF form of the separation hazard. -/
theorem jobSeparationRate_eq_lambda_mul_cdf
    (D : ShockAssumptions P) (d : ℝ) :
    P.jobSeparationRate d = P.lambda * P.cdf d := by
  rw [jobSeparationRate, P.strictShockBelow_eq_cdf D]

/-- Job-finding hazard, an economic alias of the worker meeting rate. -/
def jobFindingRate (P : Primitives) (theta : ℝ) : ℝ :=
  P.workerMeetingRate theta

/-- Employment stock associated with unemployment rate `u`. -/
def employmentFromUnemployment (_P : Primitives) (u : ℝ) : ℝ :=
  1 - u

/-- Vacancy stock implied by market tightness and unemployment. -/
def vacanciesFromTightness (_P : Primitives) (theta u : ℝ) : ℝ :=
  theta * u

/-- Destruction flow `s(d) * (1-u)`. -/
noncomputable def jobDestructionFlow (P : Primitives) (d u : ℝ) : ℝ :=
  P.jobSeparationRate d * P.employmentFromUnemployment u

/-- Creation flow `theta * q(theta) * u`. -/
def jobCreationFlow (P : Primitives) (theta u : ℝ) : ℝ :=
  P.jobFindingRate theta * u

/-- Static unemployment-flow residual: destruction minus creation. -/
noncomputable def unemploymentFlowResidual
    (P : Primitives) (theta d u : ℝ) : ℝ :=
  P.jobDestructionFlow d u - P.jobCreationFlow theta u

/-- Local condition used only when positive unemployment is needed. -/
def HasPositiveSeparationAt (P : Primitives) (d : ℝ) : Prop :=
  0 < P.jobSeparationRate d

theorem jobSeparationRate_nonneg
    (A : CoreEconomicAssumptions P) (d : ℝ) :
    0 ≤ P.jobSeparationRate d :=
  mul_nonneg A.lambda_nonneg (P.strictShockBelow_nonneg d)

theorem jobFindingRate_pos
    (M : MatchingAssumptions P) {theta : ℝ} (htheta : 0 < theta) :
    0 < P.jobFindingRate theta :=
  P.workerMeetingRate_pos M htheta

theorem totalTransitionHazard_pos
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P) {theta d : ℝ} (htheta : 0 < theta) :
    0 < P.jobSeparationRate d + P.jobFindingRate theta :=
  add_pos_of_nonneg_of_pos (P.jobSeparationRate_nonneg A d)
    (P.jobFindingRate_pos M htheta)

theorem jobDestructionFlow_nonneg
    (A : CoreEconomicAssumptions P) {d u : ℝ}
    (hu : u ≤ 1) :
    0 ≤ P.jobDestructionFlow d u := by
  exact mul_nonneg (P.jobSeparationRate_nonneg A d) (sub_nonneg.mpr hu)

theorem jobCreationFlow_nonneg
    (M : MatchingAssumptions P) {theta u : ℝ}
    (htheta : 0 < theta) (hu : 0 ≤ u) :
    0 ≤ P.jobCreationFlow theta u := by
  exact mul_nonneg (P.jobFindingRate_pos M htheta).le hu

/-- Under no atoms, destruction flow has the paper form
`lambda * F(d) * (1-u)`. -/
theorem jobDestructionFlow_eq_lambda_cdf_mul_employment
    (D : ShockAssumptions P) (d u : ℝ) :
    P.jobDestructionFlow d u =
      (P.lambda * P.cdf d) * P.employmentFromUnemployment u := by
  rw [jobDestructionFlow, P.jobSeparationRate_eq_lambda_mul_cdf D]

/-- Positive lambda and positive CDF mass suffice for positive separation. -/
theorem hasPositiveSeparationAt_of_lambda_cdf_pos
    (D : ShockAssumptions P) {d : ℝ}
    (hlambda : 0 < P.lambda) (hcdf : 0 < P.cdf d) :
    P.HasPositiveSeparationAt d := by
  rw [HasPositiveSeparationAt, P.jobSeparationRate_eq_lambda_mul_cdf D]
  exact mul_pos hlambda hcdf

end Primitives

end MP1994V2
