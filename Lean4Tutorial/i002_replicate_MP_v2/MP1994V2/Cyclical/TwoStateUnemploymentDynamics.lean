import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateFlowRates

/-!
# MP1994 v2: fixed-state unemployment dynamics

Equation (15) is encoded as a transparent labor-flow vector field. A supplied
path may satisfy that vector field, but this module does not claim ODE
existence or uniqueness.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Inflow into unemployment from idiosyncratic destruction. -/
noncomputable def unemploymentInflow
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) : ℝ :=
  E.idiosyncraticDestructionFlow A D TA M s u

/-- Outflow from unemployment through continuous matching. -/
def unemploymentOutflow
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) : ℝ :=
  E.jobCreationFlow s u

/-- The statewise unemployment vector field. -/
noncomputable def unemploymentDrift
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) : ℝ :=
  E.unemploymentInflow A D TA M s u - E.unemploymentOutflow s u

/-- Paper equation (15), stated as a fixed-state labor-flow vector field. -/
theorem equation15
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) :
    E.unemploymentDrift A D TA M s u =
      (1 - u) * P.lambda *
          P.cdf (E.reservationCutoff A D TA M s) -
        u * P.workerMeetingRate (E.theta s) := by
  unfold unemploymentDrift unemploymentInflow unemploymentOutflow
    idiosyncraticDestructionFlow idiosyncraticDestructionHazard
    jobCreationFlow workerMeetingHazard
  ring

/-- A candidate differentiable unemployment path satisfies equation (15) in
state s when its derivative equals the statewise drift at every time. -/
def SatisfiesEquation15
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState)
    (u : ℝ → ℝ) : Prop :=
  ∀ t, HasDerivAt u (E.unemploymentDrift A D TA M s (u t)) t

/-- The unemployment drift is affine with hazard intercept delta_s. -/
theorem unemploymentDrift_affine
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (u : ℝ) :
    E.unemploymentDrift A D TA M s u =
      E.idiosyncraticDestructionHazard A D TA M s -
        (E.idiosyncraticDestructionHazard A D TA M s +
          E.workerMeetingHazard s) * u := by
  unfold unemploymentDrift unemploymentInflow unemploymentOutflow
    idiosyncraticDestructionFlow jobCreationFlow
  ring

/-- Fixed-state stationary unemployment delta_s/(delta_s+a_s). -/
noncomputable def stationaryUnemployment
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) : ℝ :=
  E.idiosyncraticDestructionHazard A D TA M s /
    (E.idiosyncraticDestructionHazard A D TA M s +
      E.workerMeetingHazard s)

theorem stationaryUnemployment_denominator_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    0 < E.idiosyncraticDestructionHazard A D TA M s +
      E.workerMeetingHazard s :=
  add_pos_of_nonneg_of_pos
    (E.idiosyncraticDestructionHazard_nonneg A D TA M s)
    (E.workerMeetingHazard_pos M s)

theorem stationaryUnemployment_nonneg
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    0 ≤ E.stationaryUnemployment A D TA M s := by
  unfold stationaryUnemployment
  exact div_nonneg (E.idiosyncraticDestructionHazard_nonneg A D TA M s)
    (E.stationaryUnemployment_denominator_pos A D TA M s).le

theorem stationaryUnemployment_lt_one
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    E.stationaryUnemployment A D TA M s < 1 := by
  unfold stationaryUnemployment
  apply (div_lt_one (E.stationaryUnemployment_denominator_pos A D TA M s)).2
  linarith [E.workerMeetingHazard_pos M s]

theorem unemploymentDrift_stationary_eq_zero
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    E.unemploymentDrift A D TA M s
        (E.stationaryUnemployment A D TA M s) = 0 := by
  rw [E.unemploymentDrift_affine A D TA M]
  unfold stationaryUnemployment
  field_simp [(E.stationaryUnemployment_denominator_pos A D TA M s).ne']
  ring

theorem unemploymentDrift_pos_of_lt_stationary
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) {u : ℝ}
    (hu : u < E.stationaryUnemployment A D TA M s) :
    0 < E.unemploymentDrift A D TA M s u := by
  have hDen := E.stationaryUnemployment_denominator_pos A D TA M s
  have hScaled :
      u * (E.idiosyncraticDestructionHazard A D TA M s +
          E.workerMeetingHazard s) <
        E.idiosyncraticDestructionHazard A D TA M s := by
    exact (lt_div_iff₀ hDen).mp (by simpa [stationaryUnemployment] using hu)
  rw [E.unemploymentDrift_affine A D TA M]
  linarith

theorem unemploymentDrift_neg_of_stationary_lt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) {u : ℝ}
    (hu : E.stationaryUnemployment A D TA M s < u) :
    E.unemploymentDrift A D TA M s u < 0 := by
  have hDen := E.stationaryUnemployment_denominator_pos A D TA M s
  have hScaled :
      E.idiosyncraticDestructionHazard A D TA M s <
        u * (E.idiosyncraticDestructionHazard A D TA M s +
          E.workerMeetingHazard s) := by
    exact (div_lt_iff₀ hDen).mp (by simpa [stationaryUnemployment] using hu)
  rw [E.unemploymentDrift_affine A D TA M]
  linarith

/-- At a common interior unemployment stock, the boom vector field points
strictly more toward lower unemployment. -/
theorem boom_unemploymentDrift_lt_recession
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {u : ℝ}
    (hu : 0 < u) (huOne : u ≤ 1) :
    E.unemploymentDrift A D TA M .boom u <
      E.unemploymentDrift A D TA M .recession u := by
  have hD := E.boom_idiosyncraticDestructionFlow_le_recession
    A D TA M huOne
  have hC := E.recession_jobCreationFlow_lt_boom A D TA M AM hu
  unfold unemploymentDrift unemploymentInflow unemploymentOutflow
  linarith

/-- M9.3 fixed-state unemployment and flow-accounting result bundle. -/
def SatisfiesM93UnemploymentDynamics
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) : Prop :=
  (∀ s u,
    E.unemploymentDrift A D TA M s u =
      (1 - u) * P.lambda *
          P.cdf (E.reservationCutoff A D TA M s) -
        u * P.workerMeetingRate (E.theta s)) ∧
  (∀ s,
    0 ≤ E.stationaryUnemployment A D TA M s ∧
    E.stationaryUnemployment A D TA M s < 1 ∧
    E.unemploymentDrift A D TA M s
      (E.stationaryUnemployment A D TA M s) = 0) ∧
  (∀ u, 0 < u → u ≤ 1 →
    E.jobCreationFlow .recession u < E.jobCreationFlow .boom u ∧
    E.idiosyncraticDestructionFlow A D TA M .boom u ≤
      E.idiosyncraticDestructionFlow A D TA M .recession u ∧
    E.unemploymentDrift A D TA M .boom u <
      E.unemploymentDrift A D TA M .recession u)

/-- M9.3 unemployment-dynamics capstone. -/
theorem m9_3_unemployment_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    SatisfiesM93UnemploymentDynamics A D TA M E := by
  unfold SatisfiesM93UnemploymentDynamics
  refine ⟨fun s u => E.equation15 A D TA M s u, ?_, ?_⟩
  · intro s
    exact ⟨E.stationaryUnemployment_nonneg A D TA M s,
      E.stationaryUnemployment_lt_one A D TA M s,
      E.unemploymentDrift_stationary_eq_zero A D TA M s⟩
  · intro u hu huOne
    exact ⟨E.recession_jobCreationFlow_lt_boom A D TA M AM hu,
      E.boom_idiosyncraticDestructionFlow_le_recession A D TA M huOne,
      E.boom_unemploymentDrift_lt_recession A D TA M AM hu huOne⟩

end TwoStateValueEquilibrium
end MP1994V2
