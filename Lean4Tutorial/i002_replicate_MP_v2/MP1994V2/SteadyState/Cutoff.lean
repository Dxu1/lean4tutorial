import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.AffineSurplus

/-!
# MP1994 v2: endogenous reservation cutoff

This module completes Milestone 2.  It constructs the unique zero of the actual
`ValueEquilibrium` surplus, then separately uses vacancy free entry and matching
positivity to prove that this zero lies strictly below `epsUpper`.

The cutoff is derived, not stored in `ValueEquilibrium`.  No claim is made that
it belongs to the topological support of the shock law; without a lower-support
assumption it may lie below the effective shock support.
-/

open MeasureTheory

namespace MP1994V2

namespace ValueEquilibrium

variable {P : Primitives}

/-- Candidate reservation productivity derived from an actual value
equilibrium:

`epsUpper - ((r + λ) S(epsUpper)) / σ`.

For arbitrary primitives this is only a formula.  The theorems below certify
its unique-zero and economic-admissibility interpretations under their stated
assumptions.
-/
noncomputable def reservationCutoff (E : ValueEquilibrium P) : ℝ :=
  P.epsUpper -
    ((P.r + P.lambda) *
      E.toValueCandidate.surplus P.epsUpper) / P.sigma

/-- The derived cutoff is a zero of the actual equilibrium surplus. -/
theorem surplus_reservationCutoff_eq_zero
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    E.toValueCandidate.surplus E.reservationCutoff = 0 := by
  have h :=
    E.surplus_difference_scaled_of_probability
      P.epsUpper E.reservationCutoff
  have hCutoffDifference :
      P.sigma * (E.reservationCutoff - P.epsUpper) =
        -(P.r + P.lambda) *
          E.toValueCandidate.surplus P.epsUpper := by
    unfold reservationCutoff
    field_simp [A.sigma_ne]
    ring
  rw [hCutoffDifference] at h
  have hProduct :
      (P.r + P.lambda) *
        E.toValueCandidate.surplus E.reservationCutoff = 0 := by
    nlinarith
  exact (mul_eq_zero.mp hProduct).resolve_left A.r_add_lambda_ne

/-- Paper-level wrapper for the zero-at-cutoff theorem. -/
theorem surplus_reservationCutoff_eq_zero_of_shockAssumptions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) :
    E.toValueCandidate.surplus E.reservationCutoff = 0 := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.surplus_reservationCutoff_eq_zero A

/-- Surplus vanishes exactly at the derived reservation cutoff. -/
theorem surplus_eq_zero_iff
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.surplus eps = 0 ↔
      eps = E.reservationCutoff := by
  have hMono := E.surplus_strictMono A
  have hZero := E.surplus_reservationCutoff_eq_zero A
  constructor
  · intro hEps
    by_contra hNe
    rcases lt_or_gt_of_ne hNe with hLt | hGt
    · have hStrict := hMono hLt
      rw [hEps, hZero] at hStrict
      exact (lt_irrefl 0) hStrict
    · have hStrict := hMono hGt
      rw [hZero, hEps] at hStrict
      exact (lt_irrefl 0) hStrict
  · intro hEq
    rw [hEq]
    exact hZero

/-- The actual equilibrium surplus has exactly one zero on all of `ℝ`. -/
theorem existsUnique_surplus_zero
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    ∃! eps : ℝ, E.toValueCandidate.surplus eps = 0 := by
  refine ⟨E.reservationCutoff, E.surplus_reservationCutoff_eq_zero A, ?_⟩
  intro eps hEps
  exact (E.surplus_eq_zero_iff A eps).mp hEps

/-- Paper-level wrapper for unique existence of the surplus zero. -/
theorem existsUnique_surplus_zero_of_shockAssumptions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) :
    ∃! eps : ℝ, E.toValueCandidate.surplus eps = 0 := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.existsUnique_surplus_zero A

/-- Equation (2), together with `r > 0`, implies the vacancy value is zero. -/
theorem vacancy_value_eq_zero
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    E.V = 0 := by
  have h := E.free_entry
  nlinarith [A.r_pos]

/-- Equations (1) and (2) imply the primitive free-entry product identity
`q(theta) J(epsUpper) = c`.
-/
theorem vacancy_meeting_mul_upper_firm_value_eq_cost
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    P.q E.theta * E.J P.epsUpper = P.c := by
  have hBellman := E.vacancy_bellman
  have hV := E.vacancy_value_eq_zero A
  rw [hV] at hBellman
  unfold Primitives.vacancyMeetingRate at hBellman
  nlinarith

/-- Positive vacancy cost and a positive meeting rate make the upper-support
filled job strictly profitable to the firm.
-/
theorem upper_firm_value_pos
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    0 < E.J P.epsUpper := by
  have hProduct :=
    E.vacancy_meeting_mul_upper_firm_value_eq_cost A
  have hMeeting := M.vacancyMeetingRate_pos E.theta_pos
  change 0 < P.q E.theta at hMeeting
  nlinarith [A.c_pos]

/-- Since `J = (1 - beta) S` and `beta < 1`, profitability of the upper job
implies strictly positive upper-state surplus.
-/
theorem upper_surplus_pos
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    0 < E.toValueCandidate.surplus P.epsUpper := by
  have hFirm := E.upper_firm_value_pos A M
  have hShare := E.firm_share P.epsUpper
  have hWeight := A.one_sub_beta_pos
  nlinarith

/-- Economic admissibility: the derived cutoff lies strictly below
`epsUpper`.  This step uses equations (1)--(2), matching positivity, `c > 0`,
and `beta < 1`, but not probability normalization.
-/
theorem reservationCutoff_lt_epsUpper
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    E.reservationCutoff < P.epsUpper := by
  have hRate := A.r_add_lambda_pos
  have hSurplus := E.upper_surplus_pos A M
  have hRatio :
      0 <
        ((P.r + P.lambda) *
          E.toValueCandidate.surplus P.epsUpper) / P.sigma :=
    div_pos (mul_pos hRate hSurplus) A.sigma_pos
  unfold reservationCutoff
  linarith

/-- The cutoff is both below the upper support point and a surplus zero. -/
theorem reservationCutoff_is_admissible
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    E.reservationCutoff < P.epsUpper ∧
      E.toValueCandidate.surplus E.reservationCutoff = 0 := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact ⟨E.reservationCutoff_lt_epsUpper A M,
    E.surplus_reservationCutoff_eq_zero A⟩

/-- Paper equation (12):

`S(eps) - S(epsD) = sigma (eps - epsD) / (r + lambda)`.
-/
theorem equation12
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.surplus eps -
        E.toValueCandidate.surplus E.reservationCutoff =
      P.sigma * (eps - E.reservationCutoff) /
        (P.r + P.lambda) := by
  calc
    E.toValueCandidate.surplus eps -
        E.toValueCandidate.surplus E.reservationCutoff =
        (P.sigma / (P.r + P.lambda)) *
          (eps - E.reservationCutoff) :=
      E.surplus_difference A E.reservationCutoff eps
    _ = P.sigma * (eps - E.reservationCutoff) /
        (P.r + P.lambda) := by ring

/-- Paper-level wrapper for equation (12). -/
theorem equation12_of_shockAssumptions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.surplus eps -
        E.toValueCandidate.surplus E.reservationCutoff =
      P.sigma * (eps - E.reservationCutoff) /
        (P.r + P.lambda) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.equation12 A eps

/-- Equivalent zero-anchored affine representation of surplus. -/
theorem surplus_eq_slope_mul_sub_cutoff
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.surplus eps =
      (P.sigma / (P.r + P.lambda)) *
        (eps - E.reservationCutoff) := by
  have hEq12 := E.equation12 A eps
  have hZero := E.surplus_reservationCutoff_eq_zero A
  rw [hZero, sub_zero] at hEq12
  calc
    E.toValueCandidate.surplus eps =
        P.sigma * (eps - E.reservationCutoff) /
          (P.r + P.lambda) := hEq12
    _ = (P.sigma / (P.r + P.lambda)) *
        (eps - E.reservationCutoff) := by ring

/-- Paper-level wrapper for the zero-anchored affine representation. -/
theorem surplus_eq_slope_mul_sub_cutoff_of_shockAssumptions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.surplus eps =
      (P.sigma / (P.r + P.lambda)) *
        (eps - E.reservationCutoff) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.surplus_eq_slope_mul_sub_cutoff A eps

/-- Surplus is negative exactly below the reservation cutoff. -/
theorem surplus_neg_iff_lt_reservationCutoff
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.surplus eps < 0 ↔
      eps < E.reservationCutoff := by
  have hOrder :=
    (E.surplus_strictMono A).lt_iff_lt
      (a := eps) (b := E.reservationCutoff)
  rw [E.surplus_reservationCutoff_eq_zero A] at hOrder
  exact hOrder

/-- Surplus is positive exactly above the reservation cutoff. -/
theorem surplus_pos_iff_reservationCutoff_lt
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    0 < E.toValueCandidate.surplus eps ↔
      E.reservationCutoff < eps := by
  have hOrder :=
    (E.surplus_strictMono A).lt_iff_lt
      (a := E.reservationCutoff) (b := eps)
  rw [E.surplus_reservationCutoff_eq_zero A] at hOrder
  exact hOrder

/-- Surplus is nonnegative exactly at or above the reservation cutoff. -/
theorem surplus_nonneg_iff_reservationCutoff_le
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    0 ≤ E.toValueCandidate.surplus eps ↔
      E.reservationCutoff ≤ eps := by
  have hOrder :=
    (E.surplus_strictMono A).le_iff_le
      (a := E.reservationCutoff) (b := eps)
  rw [E.surplus_reservationCutoff_eq_zero A] at hOrder
  exact hOrder

/-- Firm value is negative exactly for states below the cutoff. -/
theorem firm_value_neg_iff_lt_reservationCutoff
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.J eps < 0 ↔ eps < E.reservationCutoff := by
  rw [E.firm_share eps]
  constructor
  · intro hFirm
    have hSurplus : E.toValueCandidate.surplus eps < 0 := by
      nlinarith [A.one_sub_beta_pos]
    exact (E.surplus_neg_iff_lt_reservationCutoff A eps).mp hSurplus
  · intro hLt
    have hSurplus :=
      (E.surplus_neg_iff_lt_reservationCutoff A eps).mpr hLt
    exact mul_neg_of_pos_of_neg A.one_sub_beta_pos hSurplus

/-- Firm value is zero exactly at the reservation cutoff. -/
theorem firm_value_eq_zero_iff
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.J eps = 0 ↔ eps = E.reservationCutoff := by
  rw [E.firm_share eps, mul_eq_zero]
  simp [A.one_sub_beta_pos.ne',
    E.surplus_eq_zero_iff A eps]

/-- Firm value is nonnegative exactly at or above the cutoff. -/
theorem firm_value_nonneg_iff_reservationCutoff_le
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    0 ≤ E.J eps ↔ E.reservationCutoff ≤ eps := by
  rw [E.firm_share eps]
  constructor
  · intro hFirm
    have hSurplus : 0 ≤ E.toValueCandidate.surplus eps := by
      nlinarith [A.one_sub_beta_pos]
    exact (E.surplus_nonneg_iff_reservationCutoff_le A eps).mp hSurplus
  · intro hLe
    have hSurplus :=
      (E.surplus_nonneg_iff_reservationCutoff_le A eps).mpr hLe
    exact mul_nonneg A.one_sub_beta_pos.le hSurplus

/-- Active surplus is the positive part of distance from the cutoff, scaled by
the positive affine slope.  This is the bridge needed by Milestone 3; no
integration is performed here.
-/
theorem activeSurplus_eq_slope_mul_positivePart
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps : ℝ) :
    E.toValueCandidate.activeSurplus eps =
      (P.sigma / (P.r + P.lambda)) *
        positivePart (eps - E.reservationCutoff) := by
  change positivePart (E.toValueCandidate.surplus eps) =
    (P.sigma / (P.r + P.lambda)) *
      positivePart (eps - E.reservationCutoff)
  rw [E.surplus_eq_slope_mul_sub_cutoff A eps]
  by_cases hNeg : eps - E.reservationCutoff < 0
  · have hProduct :
        (P.sigma / (P.r + P.lambda)) *
            (eps - E.reservationCutoff) < 0 :=
      mul_neg_of_pos_of_neg A.surplus_slope_pos hNeg
    simp [positivePart, max_eq_right hProduct.le, max_eq_right hNeg.le]
  · have hNonneg : 0 ≤ eps - E.reservationCutoff := le_of_not_gt hNeg
    have hProduct :
        0 ≤ (P.sigma / (P.r + P.lambda)) *
            (eps - E.reservationCutoff) :=
      mul_nonneg A.surplus_slope_pos.le hNonneg
    simp [positivePart, max_eq_left hProduct, max_eq_left hNonneg]

/-- Capstone for Milestone 2.  Conditional on an existing value equilibrium,
surplus is strictly increasing with a unique, economically admissible zero;
firm value is negative exactly below it; and equation (12) holds.
-/
theorem milestone2_capstone
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (E : ValueEquilibrium P) :
    StrictMono E.toValueCandidate.surplus ∧
      (∀ eps : ℝ,
        E.toValueCandidate.surplus eps = 0 ↔
          eps = E.reservationCutoff) ∧
      E.reservationCutoff < P.epsUpper ∧
      (∀ eps : ℝ, E.J eps < 0 ↔ eps < E.reservationCutoff) ∧
      (∀ eps : ℝ,
        E.toValueCandidate.surplus eps -
            E.toValueCandidate.surplus E.reservationCutoff =
          P.sigma * (eps - E.reservationCutoff) /
            (P.r + P.lambda)) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact ⟨E.surplus_strictMono A,
    fun eps => E.surplus_eq_zero_iff A eps,
    E.reservationCutoff_lt_epsUpper A M,
    fun eps => E.firm_value_neg_iff_lt_reservationCutoff A eps,
    fun eps => E.equation12 A eps⟩

end ValueEquilibrium

end MP1994V2
