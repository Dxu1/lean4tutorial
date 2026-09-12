import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateMonotonicity

/-!
# MP1994 v2: statewise reservation cutoffs

This module constructs the unique zero of each statewise surplus function.
The construction is independent of any ordering between the recession and boom
cutoffs.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Each statewise surplus has a zero strictly below the shock upper bound. -/
theorem exists_surplus_zero
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    ∃ eps < P.epsUpper,
      E.toTwoStateValueCandidate.surplus s eps = 0 := by
  obtain ⟨lo, hlo, hneg⟩ := E.exists_surplus_neg A D TA M s
  have hpos := E.upper_surplus_pos A M s
  have hmem : (0 : ℝ) ∈ Set.Icc
      (E.toTwoStateValueCandidate.surplus s lo)
      (E.toTwoStateValueCandidate.surplus s P.epsUpper) :=
    ⟨hneg.le, hpos.le⟩
  obtain ⟨eps, heps, hzero⟩ :=
    intermediate_value_Icc hlo.le (E.surplus_continuous A D TA s).continuousOn hmem
  have hne : eps ≠ P.epsUpper := by
    intro heq
    subst eps
    linarith
  exact ⟨eps, lt_of_le_of_ne heps.2 hne, hzero⟩

/-- The reservation cutoff in aggregate state `s` is the unique statewise
surplus zero. -/
noncomputable def reservationCutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) : ℝ :=
  Classical.choose (E.exists_surplus_zero A D TA M s)

/-- Surplus vanishes at the statewise reservation cutoff. -/
theorem surplus_reservationCutoff_eq_zero
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    E.toTwoStateValueCandidate.surplus s (E.reservationCutoff A D TA M s) = 0 :=
  (Classical.choose_spec (E.exists_surplus_zero A D TA M s)).2

/-- The statewise reservation cutoff is economically admissible: it lies
strictly below the shock upper bound. -/
theorem reservationCutoff_lt_epsUpper
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    E.reservationCutoff A D TA M s < P.epsUpper :=
  (Classical.choose_spec (E.exists_surplus_zero A D TA M s)).1

/-- A shock has zero surplus in state `s` exactly when it equals that state's
reservation cutoff. -/
theorem surplus_eq_zero_iff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    E.toTwoStateValueCandidate.surplus s eps = 0 ↔
      eps = E.reservationCutoff A D TA M s := by
  constructor
  · intro h
    apply (E.surplus_strictMono A D TA s).injective
    rw [h, E.surplus_reservationCutoff_eq_zero A D TA M s]
  · rintro rfl
    exact E.surplus_reservationCutoff_eq_zero A D TA M s

/-- Each aggregate state has exactly one surplus zero. -/
theorem existsUnique_surplus_zero
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    ∃! eps, E.toTwoStateValueCandidate.surplus s eps = 0 := by
  refine ⟨E.reservationCutoff A D TA M s,
    E.surplus_reservationCutoff_eq_zero A D TA M s, ?_⟩
  intro eps heps
  exact (E.surplus_eq_zero_iff A D TA M s eps).mp heps

/-- Surplus is negative exactly below the statewise cutoff. -/
theorem surplus_neg_iff_lt_reservationCutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    E.toTwoStateValueCandidate.surplus s eps < 0 ↔
      eps < E.reservationCutoff A D TA M s := by
  have h := (E.surplus_strictMono A D TA s).lt_iff_lt
    (a := eps) (b := E.reservationCutoff A D TA M s)
  rw [E.surplus_reservationCutoff_eq_zero A D TA M s] at h
  exact h

/-- Surplus is positive exactly above the statewise cutoff. -/
theorem surplus_pos_iff_reservationCutoff_lt
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    0 < E.toTwoStateValueCandidate.surplus s eps ↔
      E.reservationCutoff A D TA M s < eps := by
  have h := (E.surplus_strictMono A D TA s).lt_iff_lt
    (a := E.reservationCutoff A D TA M s) (b := eps)
  rw [E.surplus_reservationCutoff_eq_zero A D TA M s] at h
  exact h

/-- Surplus is nonnegative exactly at or above the statewise cutoff. -/
theorem surplus_nonneg_iff_reservationCutoff_le
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    0 ≤ E.toTwoStateValueCandidate.surplus s eps ↔
      E.reservationCutoff A D TA M s ≤ eps := by
  have h := (E.surplus_strictMono A D TA s).le_iff_le
    (a := E.reservationCutoff A D TA M s) (b := eps)
  rw [E.surplus_reservationCutoff_eq_zero A D TA M s] at h
  exact h

/-- Firm value is negative exactly below the statewise cutoff. -/
theorem firm_value_neg_iff_lt_reservationCutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    E.J s eps < 0 ↔ eps < E.reservationCutoff A D TA M s := by
  rw [E.firm_share s eps]
  have hβ : 0 < 1 - P.beta := sub_pos.mpr A.beta_lt_one
  constructor
  · intro h
    have hs : E.toTwoStateValueCandidate.surplus s eps < 0 := by
      nlinarith
    exact (E.surplus_neg_iff_lt_reservationCutoff A D TA M s eps).mp hs
  · intro h
    exact mul_neg_of_pos_of_neg hβ
      ((E.surplus_neg_iff_lt_reservationCutoff A D TA M s eps).mpr h)

/-- Firm value vanishes exactly at the statewise cutoff. -/
theorem firm_value_eq_zero_iff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    E.J s eps = 0 ↔ eps = E.reservationCutoff A D TA M s := by
  rw [E.firm_share s eps, mul_eq_zero]
  have hβ : 1 - P.beta ≠ 0 := (sub_pos.mpr A.beta_lt_one).ne'
  simp [hβ, E.surplus_eq_zero_iff A D TA M s eps]

/-- Firm value is nonnegative exactly at or above the statewise cutoff. -/
theorem firm_value_nonneg_iff_reservationCutoff_le
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) (eps : ℝ) :
    0 ≤ E.J s eps ↔ E.reservationCutoff A D TA M s ≤ eps := by
  rw [E.firm_share s eps]
  have hβ : 0 < 1 - P.beta := sub_pos.mpr A.beta_lt_one
  constructor
  · intro h
    have hs : 0 ≤ E.toTwoStateValueCandidate.surplus s eps := by
      nlinarith
    exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M s eps).mp hs
  · intro h
    exact mul_nonneg hβ.le
      ((E.surplus_nonneg_iff_reservationCutoff_le A D TA M s eps).mpr h)

end TwoStateValueEquilibrium
end MP1994V2
