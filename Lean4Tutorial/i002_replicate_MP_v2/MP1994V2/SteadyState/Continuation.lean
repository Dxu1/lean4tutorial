import Mathlib.MeasureTheory.Integral.Layercake
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Cutoff

/-!
# MP1994 v2: continuation value and paper equation (9)

This module derives the expected-excess representation of continuation value.
The primitive shock law is integrated directly first; the paper-facing CDF
formula is then obtained from Mathlib's strict-tail layer-cake theorem.
-/

open MeasureTheory Set
open scoped Interval

namespace MP1994V2

namespace Primitives

variable (P : Primitives)

/-- Expected excess over a proposed cutoff:
`H(d) = ∫ max (x - d) 0 dF(x)`. -/
noncomputable def expectedExcess (d : ℝ) : ℝ :=
  ∫ x, positivePart (x - d) ∂P.shock

/-- Strict upper-tail probability induced by the primitive shock law. -/
noncomputable def tailProbability (x : ℝ) : ℝ :=
  1 - P.cdf x

/-- Paper-facing option value
`∫_d^{epsUpper} [1 - F(x)] dx`, with respect to Lebesgue measure. -/
noncomputable def tailOptionValue (d : ℝ) : ℝ :=
  ∫ x in d..P.epsUpper, P.tailProbability x

/-- Under probability normalization, the strict upper-tail mass is one minus
the induced CDF.  Since `cdf x` is the mass of `(-∞, x]`, its complement is
the strict upper tail `(x, ∞)`. -/
theorem measureReal_Ioi_eq_one_sub_cdf
    [IsProbabilityMeasure P.shock] (x : ℝ) :
    P.shock.real (Ioi x) = 1 - P.cdf x := by
  rw [measureReal_def, ← compl_Iic, measure_compl measurableSet_Iic]
  · rw [ENNReal.toReal_sub_of_le]
    · simp [Primitives.cdf]
    · exact measure_mono (subset_univ _)
    · simp
  · simp

/-- Expected excess is nonnegative for every proposed cutoff. -/
theorem expectedExcess_nonneg (d : ℝ) :
    0 ≤ P.expectedExcess d := by
  exact integral_nonneg fun x => by simp [positivePart]

end Primitives

/-- The project positive part is pointwise nonnegative. -/
theorem positivePart_nonneg (x : ℝ) :
    0 ≤ positivePart x := by
  simp [positivePart]

/-- The excess payoff is measurable as a function of the shock. -/
theorem measurable_positivePart_sub (d : ℝ) :
    Measurable (fun x : ℝ => positivePart (x - d)) := by
  unfold positivePart
  fun_prop

namespace ValueEquilibrium

variable {P : Primitives}

/-- Integrability of excess productivity at the equilibrium cutoff is derived
from the value-equilibrium admissibility of active surplus and the nonzero M2
surplus slope. -/
theorem positivePart_sub_cutoff_integrable
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    Integrable
      (fun x => positivePart (x - E.reservationCutoff))
      P.shock := by
  have hScaled :
      Integrable
        (fun x =>
          (P.sigma / (P.r + P.lambda)) *
            positivePart (x - E.reservationCutoff))
        P.shock := by
    exact E.active_surplus_integrable.congr
      (Filter.Eventually.of_forall fun x =>
        E.activeSurplus_eq_slope_mul_positivePart A x)
  exact
    (integrable_const_mul_iff
      (isUnit_iff_ne_zero.mpr A.surplus_slope_pos.ne')
      (fun x => positivePart (x - E.reservationCutoff))).mp hScaled

/-- Integrating M2's active-surplus identity gives the foundational
measure-form continuation representation. -/
theorem integral_activeSurplus_eq_slope_mul_expectedExcess
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    (∫ x, E.toValueCandidate.activeSurplus x ∂P.shock) =
      (P.sigma / (P.r + P.lambda)) *
        P.expectedExcess E.reservationCutoff := by
  rw [Primitives.expectedExcess, ← integral_const_mul]
  exact integral_congr_ae
    (Filter.Eventually.of_forall fun x =>
      E.activeSurplus_eq_slope_mul_positivePart A x)

/-- The expected excess at the equilibrium cutoff equals the paper's CDF-tail
integral.  The proof uses the strict-tail layer-cake formula, so the paper's
no-mass-points assumption is not needed for this identity.  The matching
bundle is used only to establish `reservationCutoff < epsUpper`. -/
theorem expectedExcess_cutoff_eq_tailOptionValue
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    P.expectedExcess E.reservationCutoff =
      P.tailOptionValue E.reservationCutoff := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  let d := E.reservationCutoff
  let u := P.epsUpper - d
  have hdu : d < P.epsUpper := E.reservationCutoff_lt_epsUpper A M
  have hu : 0 ≤ u := sub_nonneg.mpr hdu.le
  have hInt :
      Integrable (fun x => positivePart (x - d)) P.shock := by
    simpa [d] using E.positivePart_sub_cutoff_integrable A
  have hLayer :=
    hInt.integral_eq_integral_meas_lt
      (Filter.Eventually.of_forall fun x =>
        positivePart_nonneg (x - d))
  have hLevelSet :
      ∀ t : ℝ, 0 < t →
        {x : ℝ | t < positivePart (x - d)} = Ioi (d + t) := by
    intro t ht
    ext x
    simp only [mem_setOf_eq, mem_Ioi]
    unfold positivePart
    rw [lt_max_iff]
    constructor
    · intro h
      rcases h with h | h
      · linarith
      · linarith
    · intro h
      left
      linarith
  have hTailOnPositive :
      (∫ t in Ioi 0,
          P.shock.real {x : ℝ | t < positivePart (x - d)}) =
        (∫ t in Ioi 0, P.tailProbability (d + t)) := by
    refine setIntegral_congr_fun measurableSet_Ioi ?_
    intro t ht
    change
      P.shock.real {x : ℝ | t < positivePart (x - d)} =
        P.tailProbability (d + t)
    rw [hLevelSet t ht]
    exact P.measureReal_Ioi_eq_one_sub_cdf (d + t)
  have hTruncate :
      (∫ t in Ioi 0, P.tailProbability (d + t)) =
        ∫ t in Ioc 0 u, P.tailProbability (d + t) := by
    apply setIntegral_eq_of_subset_of_ae_sdiff_eq_zero
      nullMeasurableSet_Ioi Ioc_subset_Ioi_self
    apply Filter.Eventually.of_forall
    intro t ht
    have htu : u < t := by
      have hnotle : ¬ t ≤ u := fun hle => ht.2 ⟨ht.1, hle⟩
      exact lt_of_not_ge hnotle
    have hUpper : P.epsUpper < d + t := by
      dsimp [u] at htu
      linarith
    have hTailZero : P.shock (Ioi (d + t)) = 0 :=
      measure_mono_null (Ioi_subset_Ioi hUpper.le) D.upperSupport
    rw [Primitives.tailProbability,
      ← P.measureReal_Ioi_eq_one_sub_cdf (d + t),
      measureReal_def, hTailZero]
    simp
  calc
    P.expectedExcess E.reservationCutoff =
        ∫ x, positivePart (x - d) ∂P.shock := by
      simp [Primitives.expectedExcess, d]
    _ = ∫ t in Ioi 0,
          P.shock.real {x : ℝ | t < positivePart (x - d)} := hLayer
    _ = ∫ t in Ioi 0, P.tailProbability (d + t) := hTailOnPositive
    _ = ∫ t in Ioc 0 u, P.tailProbability (d + t) := hTruncate
    _ = ∫ t in 0..u, P.tailProbability (d + t) := by
      rw [intervalIntegral.integral_of_le hu]
    _ = ∫ x in d..P.epsUpper, P.tailProbability x := by
      have hTranslate :=
        intervalIntegral.integral_comp_add_left
          (P.tailProbability) d
          (a := 0) (b := u)
      dsimp [u] at hTranslate ⊢
      rw [show d + (P.epsUpper - d) = P.epsUpper by ring] at hTranslate
      simpa only [add_zero] using hTranslate
    _ = P.tailOptionValue E.reservationCutoff := by
      simp [Primitives.tailOptionValue, d]

/-- Paper-facing continuation representation obtained by combining the
measure-form M2 identity with the layer-cake/CDF theorem. -/
theorem integral_activeSurplus_eq_slope_mul_tailOptionValue
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    (∫ x, E.toValueCandidate.activeSurplus x ∂P.shock) =
      (P.sigma / (P.r + P.lambda)) *
        P.tailOptionValue E.reservationCutoff := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  rw [E.integral_activeSurplus_eq_slope_mul_expectedExcess A,
    E.expectedExcess_cutoff_eq_tailOptionValue A D M]

/-- Measure-form paper equation (9), obtained from equation (8) by replacing
the active-surplus expectation with the M2 expected-excess representation. -/
theorem equation9_measure
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P)
    (eps : ℝ) :
    (P.r + P.lambda) * E.toValueCandidate.surplus eps =
      P.p + P.sigma * eps - P.b
        + (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.expectedExcess E.reservationCutoff
        - P.beta * P.workerMeetingRate E.theta *
            E.toValueCandidate.surplus P.epsUpper := by
  have hEight := E.surplus_bellman_of_probability eps
  have hContinuation :=
    E.integral_activeSurplus_eq_slope_mul_expectedExcess A
  rw [hContinuation] at hEight
  calc
    (P.r + P.lambda) * E.toValueCandidate.surplus eps =
        P.p + P.sigma * eps - P.b
          + P.lambda *
              ((P.sigma / (P.r + P.lambda)) *
                P.expectedExcess E.reservationCutoff)
          - P.beta * P.workerMeetingRate E.theta *
              E.toValueCandidate.surplus P.epsUpper := hEight
    _ = P.p + P.sigma * eps - P.b
          + (P.lambda * P.sigma / (P.r + P.lambda)) *
              P.expectedExcess E.reservationCutoff
          - P.beta * P.workerMeetingRate E.theta *
              E.toValueCandidate.surplus P.epsUpper := by ring

/-- Paper-facing equation (9):

`(r+lambda)S(eps) = p + sigma eps - b
  + [sigma lambda/(r+lambda)] ∫_[epsD,epsUpper] (1-F(x)) dx
  - beta theta q(theta) S(epsUpper)`.

Lean obtains this identity through affine surplus and strict-tail layer cake,
not by formalizing the paper's informal derivative notation for `S'`.
-/
theorem equation9
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P)
    (eps : ℝ) :
    (P.r + P.lambda) * E.toValueCandidate.surplus eps =
      P.p + P.sigma * eps - P.b
        + (P.lambda * P.sigma / (P.r + P.lambda)) *
            P.tailOptionValue E.reservationCutoff
        - P.beta * P.workerMeetingRate E.theta *
            E.toValueCandidate.surplus P.epsUpper := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  rw [← E.expectedExcess_cutoff_eq_tailOptionValue A D M]
  exact E.equation9_measure A eps

end ValueEquilibrium

end MP1994V2
