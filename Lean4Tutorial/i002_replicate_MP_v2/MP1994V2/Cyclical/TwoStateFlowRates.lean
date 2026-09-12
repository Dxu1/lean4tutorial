import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateJobCreation
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions.Appendix

/-!
# MP1994 v2: statewise hazards and labor flows

The vacancy contact rate is q(theta), while the unemployed-worker meeting
hazard is theta*q(theta). Aggregate job creation additionally multiplies the
worker hazard by unemployment.
-/

open MeasureTheory Set

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Statewise idiosyncratic job-destruction hazard, lambda*F(d_s). -/
noncomputable def idiosyncraticDestructionHazard
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) : ℝ :=
  P.lambda * P.cdf (E.reservationCutoff A D TA M s)

/-- Statewise unemployed-worker meeting hazard theta_s*q(theta_s). -/
def workerMeetingHazard
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) : ℝ :=
  P.workerMeetingRate (E.theta s)

/-- Continuous aggregate job-creation flow from unemployment u. -/
def jobCreationFlow
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) : ℝ :=
  u * E.workerMeetingHazard s

/-- Continuous idiosyncratic-destruction flow from employment 1-u. -/
noncomputable def idiosyncraticDestructionFlow
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) : ℝ :=
  (1 - u) * E.idiosyncraticDestructionHazard A D TA M s

theorem idiosyncraticDestructionHazard_nonneg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    0 ≤ E.idiosyncraticDestructionHazard A D TA M s := by
  unfold idiosyncraticDestructionHazard Primitives.cdf
  exact mul_nonneg A.lambda_nonneg ENNReal.toReal_nonneg

theorem workerMeetingHazard_pos
    (M : MatchingAssumptions P) (E : TwoStateValueEquilibrium P T)
    (s : AggregateState) :
    0 < E.workerMeetingHazard s := by
  unfold workerMeetingHazard
  exact P.workerMeetingRate_pos M (E.theta_pos s)

theorem jobCreationFlow_nonneg
    (M : MatchingAssumptions P) (E : TwoStateValueEquilibrium P T)
    (s : AggregateState) {u : ℝ} (hu : 0 ≤ u) :
    0 ≤ E.jobCreationFlow s u := by
  exact mul_nonneg hu (E.workerMeetingHazard_pos M s).le

theorem idiosyncraticDestructionFlow_nonneg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState)
    {u : ℝ} (hu : u ≤ 1) :
    0 ≤ E.idiosyncraticDestructionFlow A D TA M s u := by
  exact mul_nonneg (sub_nonneg.mpr hu)
    (E.idiosyncraticDestructionHazard_nonneg A D TA M s)

/-- Appendix elasticity restrictions make the worker meeting hazard strictly
increasing on positive tightness. No IFT assumption is needed. -/
theorem workerMeetingHazard_strictMonoOn_pos
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P) :
    StrictMonoOn P.workerMeetingRate (Ioi 0) := by
  apply strictMonoOn_of_deriv_pos (convex_Ioi (0 : ℝ))
  · unfold Primitives.workerMeetingRate
    exact differentiableOn_id.mul AM.q_differentiableOn_pos |>.continuousOn
  · intro theta hthetaInterior
    have htheta : 0 < theta := by simpa using hthetaInterior
    have hqAt : HasDerivAt P.q (deriv P.q theta) theta :=
      ((AM.q_differentiableOn_pos theta htheta).differentiableAt
        (Ioi_mem_nhds htheta)).hasDerivAt
    have hWorker := (hasDerivAt_id theta).mul hqAt
    have hDeriv :
        deriv P.workerMeetingRate theta =
          P.q theta * (1 - P.matchingElasticity theta) := by
      rw [show deriv P.workerMeetingRate theta =
          1 * P.q theta + theta * deriv P.q theta by
        exact hWorker.deriv]
      rw [P.deriv_q_eq_neg_elasticity_mul M htheta]
      field_simp [htheta.ne']
      ring
    rw [hDeriv]
    exact mul_pos (M.vacancyMeetingRate_pos htheta)
      (P.one_sub_matchingElasticity_pos AM htheta)

/-- A lower cutoff weakly lowers the CDF-induced destruction hazard. -/
theorem boom_destructionHazard_le_recession
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    E.idiosyncraticDestructionHazard A D TA M .boom ≤
      E.idiosyncraticDestructionHazard A D TA M .recession := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hCut := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hMeasure :
      P.shock (Iic (E.reservationCutoff A D TA M .boom)) ≤
        P.shock (Iic (E.reservationCutoff A D TA M .recession)) :=
    measure_mono (Iic_subset_Iic.mpr hCut.le)
  have hCDF :
      P.cdf (E.reservationCutoff A D TA M .boom) ≤
        P.cdf (E.reservationCutoff A D TA M .recession) := by
    unfold Primitives.cdf
    exact ENNReal.toReal_mono (measure_ne_top _ _) hMeasure
  exact mul_le_mul_of_nonneg_left hCDF A.lambda_nonneg

/-- Under Appendix matching elasticity, the boom worker meeting hazard is
strictly larger because boom tightness is strictly larger. -/
theorem recession_workerMeetingHazard_lt_boom
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    E.workerMeetingHazard .recession < E.workerMeetingHazard .boom := by
  exact workerMeetingHazard_strictMonoOn_pos (P := P) M AM
    (E.theta_pos .recession) (E.theta_pos .boom)
    (E.recession_tightness_lt_boom_tightness A D TA M)

/-- Strict hazard ordering requires both a positive redraw rate and a strict
CDF increase between the cutoffs. -/
theorem boom_destructionHazard_lt_recession
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hLambda : 0 < P.lambda)
    (hCDF :
      P.cdf (E.reservationCutoff A D TA M .boom) <
        P.cdf (E.reservationCutoff A D TA M .recession)) :
    E.idiosyncraticDestructionHazard A D TA M .boom <
      E.idiosyncraticDestructionHazard A D TA M .recession :=
  mul_lt_mul_of_pos_left hCDF hLambda

theorem recession_jobCreationFlow_lt_boom
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {u : ℝ} (hu : 0 < u) :
    E.jobCreationFlow .recession u < E.jobCreationFlow .boom u :=
  mul_lt_mul_of_pos_left
    (E.recession_workerMeetingHazard_lt_boom A D TA M AM) hu

theorem boom_idiosyncraticDestructionFlow_le_recession
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {u : ℝ} (hu : u ≤ 1) :
    E.idiosyncraticDestructionFlow A D TA M .boom u ≤
      E.idiosyncraticDestructionFlow A D TA M .recession u := by
  exact mul_le_mul_of_nonneg_left
    (E.boom_destructionHazard_le_recession A D TA M)
    (sub_nonneg.mpr hu)

theorem boom_idiosyncraticDestructionFlow_lt_recession
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {u : ℝ}
    (hu : u < 1) (hLambda : 0 < P.lambda)
    (hCDF :
      P.cdf (E.reservationCutoff A D TA M .boom) <
        P.cdf (E.reservationCutoff A D TA M .recession)) :
    E.idiosyncraticDestructionFlow A D TA M .boom u <
      E.idiosyncraticDestructionFlow A D TA M .recession u :=
  mul_lt_mul_of_pos_left
    (E.boom_destructionHazard_lt_recession A D TA M hLambda hCDF)
    (sub_pos.mpr hu)

end TwoStateValueEquilibrium
end MP1994V2
