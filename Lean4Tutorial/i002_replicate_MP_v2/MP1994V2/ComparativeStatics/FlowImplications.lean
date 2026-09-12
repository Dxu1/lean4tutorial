import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Unemployment
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.EquilibriumOrders

/-!
# MP1994 v2: hazard, flow, and stock implications

These results turn the M7 cutoff and tightness orders into weak hazard, initial
flow, unemployment, and employment orders.  The compared full equilibria are
supplied as witnesses; no existence assumption is used.
-/

open MeasureTheory Set

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- Lower cutoffs weakly reduce strict lower-tail probability.  Finiteness,
not atomlessness, is the only distributional requirement. -/
theorem strictShockBelow_mono
    [IsFiniteMeasure P.shock] {d2 d1 : ℝ} (hd : d2 ≤ d1) :
    P.strictShockBelow d2 ≤ P.strictShockBelow d1 := by
  unfold strictShockBelow
  exact ENNReal.toReal_mono (measure_ne_top P.shock (Iio d1))
    (measure_mono (Iio_subset_Iio hd))

/-- With a common nonnegative redraw rate, a lower cutoff weakly reduces the
separation hazard. -/
theorem jobSeparationRate_mono_cutoff
    [IsFiniteMeasure P.shock]
    (A : CoreEconomicAssumptions P) {d2 d1 : ℝ} (hd : d2 ≤ d1) :
    P.jobSeparationRate d2 ≤ P.jobSeparationRate d1 := by
  unfold jobSeparationRate
  exact mul_le_mul_of_nonneg_left (P.strictShockBelow_mono hd)
    A.lambda_nonneg

/-- Weakly higher tightness weakly raises the worker job-finding rate under
the maintained matching monotonicity assumption. -/
theorem jobFindingRate_mono
    (M : MatchingAssumptions P) {theta1 theta2 : ℝ}
    (htheta1 : 0 < theta1) (htheta2 : 0 < theta2)
    (htheta : theta1 ≤ theta2) :
    P.jobFindingRate theta1 ≤ P.jobFindingRate theta2 := by
  exact M.workerMeetingRate_monotoneOn htheta1 htheta2 htheta

/-- At a common current unemployment stock, a higher finding hazard weakly
raises job creation. -/
theorem jobCreationFlow_mono_of_findingRate
    {P1 P2 : Primitives} {theta1 theta2 u : ℝ}
    (hu : 0 ≤ u)
    (hf : P1.jobFindingRate theta1 ≤ P2.jobFindingRate theta2) :
    P1.jobCreationFlow theta1 u ≤ P2.jobCreationFlow theta2 u := by
  unfold jobCreationFlow
  exact mul_le_mul_of_nonneg_right hf hu

/-- At a common current unemployment stock, a lower separation hazard weakly
reduces job destruction. -/
theorem jobDestructionFlow_mono_of_separationRate
    {P1 P2 : Primitives} {d1 d2 u : ℝ}
    (hu : u ≤ 1)
    (hs : P1.jobSeparationRate d1 ≤ P2.jobSeparationRate d2) :
    P1.jobDestructionFlow d1 u ≤ P2.jobDestructionFlow d2 u := by
  unfold jobDestructionFlow employmentFromUnemployment
  exact mul_le_mul_of_nonneg_right hs (sub_nonneg.mpr hu)

end Primitives

/-- Lower separation and higher finding imply weakly lower steady-state
unemployment. -/
theorem steadyUnemployment_monotone
    {s1 s2 f1 f2 : ℝ}
    (hs2 : 0 ≤ s2) (hs : s2 ≤ s1)
    (hf1 : 0 < f1) (hf : f1 ≤ f2) :
    s2 / (s2 + f2) ≤ s1 / (s1 + f1) := by
  have hs1 : 0 ≤ s1 := hs2.trans hs
  have hf2 : 0 < f2 := hf1.trans_le hf
  have hden2 : 0 < s2 + f2 := add_pos_of_nonneg_of_pos hs2 hf2
  have hden1 : 0 < s1 + f1 := add_pos_of_nonneg_of_pos hs1 hf1
  rw [div_le_div_iff₀ hden2 hden1]
  have hsf : s2 * f1 ≤ s1 * f2 :=
    calc
      s2 * f1 ≤ s1 * f1 := mul_le_mul_of_nonneg_right hs hf1.le
      _ ≤ s1 * f2 := mul_le_mul_of_nonneg_left hf hs1
  nlinarith

namespace SteadyStateEquilibrium

/-- Initial-impact creation rises and destruction falls after higher common
productivity, at every common admissible unemployment stock. -/
theorem aggregateProductivity_initialFlows
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {pLow pHigh : ℝ} (hp : pLow < pHigh)
    (SLow : SteadyStateEquilibrium (P.withCommonProductivity pLow))
    (SHigh : SteadyStateEquilibrium (P.withCommonProductivity pHigh))
    {u : ℝ} (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    (P.withCommonProductivity pLow).jobCreationFlow SLow.theta u ≤
        (P.withCommonProductivity pHigh).jobCreationFlow SHigh.theta u
      ∧
    (P.withCommonProductivity pHigh).jobDestructionFlow SHigh.cutoff u ≤
        (P.withCommonProductivity pLow).jobDestructionFlow SLow.cutoff u := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hord := SLow.toReducedEquilibrium.order_of_commonProductivity
    A D M hp SHigh.toReducedEquilibrium
  have hfind : P.jobFindingRate SLow.theta ≤
      P.jobFindingRate SHigh.theta :=
    P.jobFindingRate_mono M SLow.theta_pos SHigh.theta_pos hord.2.le
  have hsep : P.jobSeparationRate SHigh.cutoff ≤
      P.jobSeparationRate SLow.cutoff :=
    P.jobSeparationRate_mono_cutoff A hord.1.le
  constructor
  · change P.jobCreationFlow SLow.theta u ≤
      P.jobCreationFlow SHigh.theta u
    exact Primitives.jobCreationFlow_mono_of_findingRate hu0 hfind
  · change P.jobDestructionFlow SHigh.cutoff u ≤
      P.jobDestructionFlow SLow.cutoff u
    exact Primitives.jobDestructionFlow_mono_of_separationRate hu1 hsep

/-- GREEN full-state productivity capstone.  Flow and stock effects are weak
because neither the CDF nor the worker meeting rate is assumed strictly
increasing. -/
theorem aggregateProductivity_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {pLow pHigh : ℝ} (hp : pLow < pHigh)
    (SLow : SteadyStateEquilibrium (P.withCommonProductivity pLow))
    (SHigh : SteadyStateEquilibrium (P.withCommonProductivity pHigh)) :
    SHigh.cutoff < SLow.cutoff
      ∧ SLow.theta < SHigh.theta
      ∧ (P.withCommonProductivity pHigh).jobSeparationRate SHigh.cutoff ≤
          (P.withCommonProductivity pLow).jobSeparationRate SLow.cutoff
      ∧ (P.withCommonProductivity pLow).jobFindingRate SLow.theta ≤
          (P.withCommonProductivity pHigh).jobFindingRate SHigh.theta
      ∧ SHigh.unemployment ≤ SLow.unemployment
      ∧ SLow.employment ≤ SHigh.employment := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hord := SLow.toReducedEquilibrium.order_of_commonProductivity
    A D M hp SHigh.toReducedEquilibrium
  have hsep : P.jobSeparationRate SHigh.cutoff ≤
      P.jobSeparationRate SLow.cutoff :=
    P.jobSeparationRate_mono_cutoff A hord.1.le
  have hfind : P.jobFindingRate SLow.theta ≤
      P.jobFindingRate SHigh.theta :=
    P.jobFindingRate_mono M SLow.theta_pos SHigh.theta_pos hord.2.le
  have hu : SHigh.unemployment ≤ SLow.unemployment := by
    rw [SHigh.unemployment_eq_closedForm
          (A.withCommonProductivity pHigh) (M.withCommonProductivity pHigh),
      SLow.unemployment_eq_closedForm
          (A.withCommonProductivity pLow) (M.withCommonProductivity pLow)]
    exact steadyUnemployment_monotone
      (P.jobSeparationRate_nonneg A SHigh.cutoff) hsep
      (P.jobFindingRate_pos M SLow.theta_pos) hfind
  have hemp : SLow.employment ≤ SHigh.employment := by
    unfold employment Primitives.employmentFromUnemployment
    linarith
  refine ⟨hord.1, hord.2, ?_, ?_, hu, hemp⟩
  · change P.jobSeparationRate SHigh.cutoff ≤
      P.jobSeparationRate SLow.cutoff
    exact hsep
  · change P.jobFindingRate SLow.theta ≤
      P.jobFindingRate SHigh.theta
    exact hfind

/-- Initial-impact creation falls and destruction rises after higher
unemployment income, at every common admissible unemployment stock. -/
theorem unemploymentIncome_initialFlows
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {bLow bHigh : ℝ} (hb : bLow < bHigh)
    (SLow : SteadyStateEquilibrium (P.withUnemploymentIncome bLow))
    (SHigh : SteadyStateEquilibrium (P.withUnemploymentIncome bHigh))
    {u : ℝ} (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    (P.withUnemploymentIncome bHigh).jobCreationFlow SHigh.theta u ≤
        (P.withUnemploymentIncome bLow).jobCreationFlow SLow.theta u
      ∧
    (P.withUnemploymentIncome bLow).jobDestructionFlow SLow.cutoff u ≤
        (P.withUnemploymentIncome bHigh).jobDestructionFlow SHigh.cutoff u := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hord := SLow.toReducedEquilibrium.order_of_unemploymentIncome
    A D M hb SHigh.toReducedEquilibrium
  have hfind : P.jobFindingRate SHigh.theta ≤
      P.jobFindingRate SLow.theta :=
    P.jobFindingRate_mono M SHigh.theta_pos SLow.theta_pos hord.2.le
  have hsep : P.jobSeparationRate SLow.cutoff ≤
      P.jobSeparationRate SHigh.cutoff :=
    P.jobSeparationRate_mono_cutoff A hord.1.le
  constructor
  · change P.jobCreationFlow SHigh.theta u ≤
      P.jobCreationFlow SLow.theta u
    exact Primitives.jobCreationFlow_mono_of_findingRate hu0 hfind
  · change P.jobDestructionFlow SLow.cutoff u ≤
      P.jobDestructionFlow SHigh.cutoff u
    exact Primitives.jobDestructionFlow_mono_of_separationRate hu1 hsep

/-- GREEN full-state unemployment-income capstone. -/
theorem unemploymentIncome_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {bLow bHigh : ℝ} (hb : bLow < bHigh)
    (SLow : SteadyStateEquilibrium (P.withUnemploymentIncome bLow))
    (SHigh : SteadyStateEquilibrium (P.withUnemploymentIncome bHigh)) :
    SLow.cutoff < SHigh.cutoff
      ∧ SHigh.theta < SLow.theta
      ∧ (P.withUnemploymentIncome bLow).jobSeparationRate SLow.cutoff ≤
          (P.withUnemploymentIncome bHigh).jobSeparationRate SHigh.cutoff
      ∧ (P.withUnemploymentIncome bHigh).jobFindingRate SHigh.theta ≤
          (P.withUnemploymentIncome bLow).jobFindingRate SLow.theta
      ∧ SLow.unemployment ≤ SHigh.unemployment
      ∧ SHigh.employment ≤ SLow.employment := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hord := SLow.toReducedEquilibrium.order_of_unemploymentIncome
    A D M hb SHigh.toReducedEquilibrium
  have hsep : P.jobSeparationRate SLow.cutoff ≤
      P.jobSeparationRate SHigh.cutoff :=
    P.jobSeparationRate_mono_cutoff A hord.1.le
  have hfind : P.jobFindingRate SHigh.theta ≤
      P.jobFindingRate SLow.theta :=
    P.jobFindingRate_mono M SHigh.theta_pos SLow.theta_pos hord.2.le
  have hu : SLow.unemployment ≤ SHigh.unemployment := by
    rw [SLow.unemployment_eq_closedForm
          (A.withUnemploymentIncome bLow) (M.withUnemploymentIncome bLow),
      SHigh.unemployment_eq_closedForm
          (A.withUnemploymentIncome bHigh) (M.withUnemploymentIncome bHigh)]
    exact steadyUnemployment_monotone
      (P.jobSeparationRate_nonneg A SLow.cutoff) hsep
      (P.jobFindingRate_pos M SHigh.theta_pos) hfind
  have hemp : SHigh.employment ≤ SLow.employment := by
    unfold employment Primitives.employmentFromUnemployment
    linarith
  refine ⟨hord.1, hord.2, ?_, ?_, hu, hemp⟩
  · change P.jobSeparationRate SLow.cutoff ≤
      P.jobSeparationRate SHigh.cutoff
    exact hsep
  · change P.jobFindingRate SHigh.theta ≤
      P.jobFindingRate SLow.theta
    exact hfind

end SteadyStateEquilibrium

end MP1994V2
