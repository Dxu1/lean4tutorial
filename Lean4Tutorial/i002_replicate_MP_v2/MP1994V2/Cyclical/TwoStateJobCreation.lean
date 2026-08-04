import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoffResults

/-!
# MP1994 v2: two-state job-creation equations

This module derives paper equations (25)--(30) from the reviewed M9.2 regional
surplus results and statewise free entry. No numbered equation is an
equilibrium field.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Paper equation (25), valid at and above the recession cutoff. -/
theorem equation25
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
      P.sigma * (eps - E.reservationCutoff A D TA M .recession) +
        T.aggregateArrival *
          (E.surplus .boom eps -
            E.surplus .boom
              (E.reservationCutoff A D TA M .recession)) := by
  have hR := E.recession_surplus_above_recession_cutoff A D TA M hEps
  have hB := E.boom_surplus_difference_above_recession_cutoff
    A D TA M (le_refl _) hEps
  have hRate : P.r + P.lambda ≠ 0 := (by
    linarith [A.r_pos, A.lambda_nonneg] : 0 < P.r + P.lambda).ne'
  rw [hR, hB]
  field_simp [hRate]

/-- Paper equation (26), valid at and above the recession cutoff. -/
theorem equation26
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    (P.r + P.lambda + T.aggregateArrival) *
        (E.surplus .boom eps -
          E.surplus .boom
            (E.reservationCutoff A D TA M .recession)) =
      P.sigma * (eps - E.reservationCutoff A D TA M .recession) +
        T.aggregateArrival * E.surplus .recession eps := by
  have hR := E.recession_surplus_above_recession_cutoff A D TA M hEps
  have hB := E.boom_surplus_difference_above_recession_cutoff
    A D TA M (le_refl _) hEps
  have hRate : P.r + P.lambda ≠ 0 := (by
    linarith [A.r_pos, A.lambda_nonneg] : 0 < P.r + P.lambda).ne'
  rw [hR, hB]
  field_simp [hRate]

/-- Paper equation (27). The reviewed M9.2C affine theorem is stronger than
the scalar elimination of equations (25)--(26), so this alias reuses it. -/
theorem equation27
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    E.surplus .recession eps =
      P.sigma * (eps - E.reservationCutoff A D TA M .recession) /
        (P.r + P.lambda) := by
  rw [E.recession_surplus_above_recession_cutoff A D TA M hEps]
  ring

/-- Paper equation (28), the recession job-creation condition. -/
theorem equation28
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    P.q (E.theta .recession) =
      (P.c / (1 - P.beta)) * (P.r + P.lambda) /
        (P.sigma *
          (P.epsUpper -
            E.reservationCutoff A D TA M .recession)) := by
  let dR := E.reservationCutoff A D TA M .recession
  have hGap : 0 < P.epsUpper - dR :=
    sub_pos.mpr (E.reservationCutoff_lt_epsUpper A D TA M .recession)
  have hSigmaGap : P.sigma * (P.epsUpper - dR) ≠ 0 :=
    (mul_pos A.sigma_pos hGap).ne'
  have hRate : P.r + P.lambda ≠ 0 :=
    (by linarith [A.r_pos, A.lambda_nonneg] : 0 < P.r + P.lambda).ne'
  have hSurplus := E.equation27 A D TA M
    (E.reservationCutoff_lt_epsUpper A D TA M .recession).le
  have hFree := E.statewise_q_mul_surplus_upper_eq A .recession
  dsimp [dR] at hGap hSigmaGap hSurplus ⊢
  rw [hSurplus] at hFree
  apply (eq_div_iff hSigmaGap).2
  calc
    P.q (E.theta .recession) *
        (P.sigma *
          (P.epsUpper -
            E.reservationCutoff A D TA M .recession)) =
      (P.r + P.lambda) *
        (P.q (E.theta .recession) *
          (P.sigma *
            (P.epsUpper -
              E.reservationCutoff A D TA M .recession) /
                (P.r + P.lambda))) := by
          field_simp [hRate]
    _ = (P.r + P.lambda) * (P.c / (1 - P.beta)) := by rw [hFree]
    _ = (P.c / (1 - P.beta)) * (P.r + P.lambda) := by ring

/-- Paper equation (29), valid at and above the recession cutoff. -/
theorem equation29
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) {eps : ℝ}
    (hEps : E.reservationCutoff A D TA M .recession ≤ eps) :
    E.surplus .boom eps =
      P.sigma *
          (eps - E.reservationCutoff A D TA M .boom) /
            (P.r + P.lambda + T.aggregateArrival) +
        T.aggregateArrival / (P.r + P.lambda + T.aggregateArrival) *
          E.surplus .recession eps := by
  have hBoom := E.boom_surplus_above_recession_cutoff A D TA M hEps
  have hBridge := E.equation23 A D TA M
  have hRec := E.equation27 A D TA M hEps
  have hRate : P.r + P.lambda ≠ 0 :=
    (by linarith [A.r_pos, A.lambda_nonneg] : 0 < P.r + P.lambda).ne'
  have hTotal : P.r + P.lambda + T.aggregateArrival ≠ 0 :=
    (by linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos] :
      0 < P.r + P.lambda + T.aggregateArrival).ne'
  rw [hBoom, hBridge, hRec]
  field_simp [hRate, hTotal]
  ring

/-- The boom job-creation denominator in paper equation (30). -/
noncomputable def boomJobCreationDenominator
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) : ℝ :=
  P.sigma *
      (P.epsUpper - E.reservationCutoff A D TA M .boom) -
    (T.aggregateArrival * P.sigma /
      (P.r + P.lambda + T.aggregateArrival)) *
      (E.reservationCutoff A D TA M .recession -
        E.reservationCutoff A D TA M .boom)

/-- The boom denominator is (r + lambda) times upper-support boom surplus. -/
theorem boomJobCreationDenominator_eq
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    boomJobCreationDenominator A D TA M E =
      (P.r + P.lambda) * E.surplus .boom P.epsUpper := by
  have hEq := E.equation29 A D TA M
    (E.reservationCutoff_lt_epsUpper A D TA M .recession).le
  have hRec := E.equation27 A D TA M
    (E.reservationCutoff_lt_epsUpper A D TA M .recession).le
  have hRate : P.r + P.lambda ≠ 0 :=
    (by linarith [A.r_pos, A.lambda_nonneg] : 0 < P.r + P.lambda).ne'
  have hTotal : P.r + P.lambda + T.aggregateArrival ≠ 0 :=
    (by linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos] :
      0 < P.r + P.lambda + T.aggregateArrival).ne'
  rw [hRec] at hEq
  unfold boomJobCreationDenominator
  rw [hEq]
  field_simp [hRate, hTotal]
  ring

/-- Positivity of the denominator in equation (30). -/
theorem boomJobCreationDenominator_pos
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    0 < boomJobCreationDenominator A D TA M E := by
  rw [E.boomJobCreationDenominator_eq A D TA M]
  exact mul_pos (by linarith [A.r_pos, A.lambda_nonneg])
    (E.upper_surplus_pos A M .boom)

/-- Paper equation (30), the boom job-creation condition. -/
theorem equation30
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    P.q (E.theta .boom) =
      (P.c * (P.r + P.lambda) / (1 - P.beta)) /
        boomJobCreationDenominator A D TA M E := by
  have hFree := E.statewise_q_mul_surplus_upper_eq A .boom
  have hDen := E.boomJobCreationDenominator_eq A D TA M
  have hDenPos := E.boomJobCreationDenominator_pos A D TA M
  apply (eq_div_iff hDenPos.ne').2
  rw [hDen]
  calc
    P.q (E.theta .boom) *
        ((P.r + P.lambda) * E.surplus .boom P.epsUpper) =
      (P.r + P.lambda) *
        (P.q (E.theta .boom) * E.surplus .boom P.epsUpper) := by ring
    _ = (P.r + P.lambda) * (P.c / (1 - P.beta)) := by rw [hFree]
    _ = P.c * (P.r + P.lambda) / (1 - P.beta) := by ring

/-- Anticipation strictly lowers the boom denominator relative to the static
surplus gap with the same cutoffs. -/
theorem boomJobCreationDenominator_lt_staticGap
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    boomJobCreationDenominator A D TA M E <
      P.sigma *
        (P.epsUpper - E.reservationCutoff A D TA M .boom) := by
  have hOrder := E.boom_cutoff_lt_recession_cutoff A D TA M
  have hTotal : 0 < P.r + P.lambda + T.aggregateArrival := by
    linarith [A.r_pos, A.lambda_nonneg, TA.aggregateArrival_pos]
  have hWedge : 0 <
      (T.aggregateArrival * P.sigma /
        (P.r + P.lambda + T.aggregateArrival)) *
        (E.reservationCutoff A D TA M .recession -
          E.reservationCutoff A D TA M .boom) :=
    mul_pos
      (div_pos (mul_pos TA.aggregateArrival_pos A.sigma_pos) hTotal)
      (sub_pos.mpr hOrder)
  unfold boomJobCreationDenominator
  linarith

/-- The anticipated boom vacancy-contact target exceeds the corresponding
static target evaluated at the same boom cutoff. -/
theorem staticJobCreationTarget_lt_boomVacancyMeetingRate
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (P.c * (P.r + P.lambda) / (1 - P.beta)) /
        (P.sigma *
          (P.epsUpper - E.reservationCutoff A D TA M .boom)) <
      P.q (E.theta .boom) := by
  have hGap : 0 <
      P.sigma *
        (P.epsUpper - E.reservationCutoff A D TA M .boom) :=
    mul_pos A.sigma_pos
      (sub_pos.mpr (E.reservationCutoff_lt_epsUpper A D TA M .boom))
  have hDen := E.boomJobCreationDenominator_pos A D TA M
  have hLt := E.boomJobCreationDenominator_lt_staticGap A D TA M
  have hNum : 0 < P.c * (P.r + P.lambda) / (1 - P.beta) :=
    div_pos (mul_pos A.c_pos (by linarith [A.r_pos, A.lambda_nonneg]))
      (sub_pos.mpr A.beta_lt_one)
  rw [E.equation30 A D TA M]
  exact (div_lt_div_iff₀ hGap hDen).2 (by nlinarith)

/-- Compact result bundle for paper equations (25)--(30). -/
def SatisfiesM93JobCreation
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) : Prop :=
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    (P.r + P.lambda + T.aggregateArrival) * E.surplus .recession eps =
      P.sigma * (eps - E.reservationCutoff A D TA M .recession) +
        T.aggregateArrival *
          (E.surplus .boom eps -
            E.surplus .boom
              (E.reservationCutoff A D TA M .recession))) ∧
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    (P.r + P.lambda + T.aggregateArrival) *
        (E.surplus .boom eps -
          E.surplus .boom
            (E.reservationCutoff A D TA M .recession)) =
      P.sigma * (eps - E.reservationCutoff A D TA M .recession) +
        T.aggregateArrival * E.surplus .recession eps) ∧
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    E.surplus .recession eps =
      P.sigma * (eps - E.reservationCutoff A D TA M .recession) /
        (P.r + P.lambda)) ∧
  P.q (E.theta .recession) =
    (P.c / (1 - P.beta)) * (P.r + P.lambda) /
      (P.sigma *
        (P.epsUpper - E.reservationCutoff A D TA M .recession)) ∧
  (∀ eps, E.reservationCutoff A D TA M .recession ≤ eps →
    E.surplus .boom eps =
      P.sigma * (eps - E.reservationCutoff A D TA M .boom) /
          (P.r + P.lambda + T.aggregateArrival) +
        T.aggregateArrival / (P.r + P.lambda + T.aggregateArrival) *
          E.surplus .recession eps) ∧
  0 < boomJobCreationDenominator A D TA M E ∧
  P.q (E.theta .boom) =
    (P.c * (P.r + P.lambda) / (1 - P.beta)) /
      boomJobCreationDenominator A D TA M E ∧
  boomJobCreationDenominator A D TA M E <
    P.sigma * (P.epsUpper - E.reservationCutoff A D TA M .boom) ∧
  (P.c * (P.r + P.lambda) / (1 - P.beta)) /
      (P.sigma * (P.epsUpper -
        E.reservationCutoff A D TA M .boom)) <
    P.q (E.theta .boom)

/-- M9.3 job-creation capstone. -/
theorem m9_3_jobCreation_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    SatisfiesM93JobCreation A D TA M E := by
  unfold SatisfiesM93JobCreation
  exact ⟨fun _ h => E.equation25 A D TA M h,
    fun _ h => E.equation26 A D TA M h,
    fun _ h => E.equation27 A D TA M h,
    E.equation28 A D TA M,
    fun _ h => E.equation29 A D TA M h,
    E.boomJobCreationDenominator_pos A D TA M,
    E.equation30 A D TA M,
    E.boomJobCreationDenominator_lt_staticGap A D TA M,
    E.staticJobCreationTarget_lt_boomVacancyMeetingRate A D TA M⟩

end TwoStateValueEquilibrium
end MP1994V2
