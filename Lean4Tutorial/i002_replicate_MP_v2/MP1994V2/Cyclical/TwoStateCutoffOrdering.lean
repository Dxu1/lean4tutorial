import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoff

/-!
# MP1994 v2: conditional cutoff geometry

This module records the interval signs implied by either possible cutoff order.
It deliberately contains no field, axiom, or theorem asserting which order
holds.  See `docs/two_state_cutoff_ordering_analysis.md` for the adequacy gate.
-/

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- If the boom cutoff is lower, both surpluses are negative below it. -/
theorem both_surplus_neg_below_boom_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hOrder : E.reservationCutoff A D TA M .boom <
      E.reservationCutoff A D TA M .recession)
    {eps : ℝ} (h : eps < E.reservationCutoff A D TA M .boom) :
    E.toTwoStateValueCandidate.surplus .boom eps < 0 ∧
      E.toTwoStateValueCandidate.surplus .recession eps < 0 := by
  constructor
  · exact (E.surplus_neg_iff_lt_reservationCutoff A D TA M .boom eps).2 h
  · exact (E.surplus_neg_iff_lt_reservationCutoff A D TA M .recession eps).2
      (lt_trans h hOrder)

/-- Under the paper order, boom surplus is nonnegative and recession surplus
is nonpositive between the cutoffs. -/
theorem surplus_signs_between_cutoffs_of_boom_lt_recession
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    {eps : ℝ}
    (hBoom : E.reservationCutoff A D TA M .boom ≤ eps)
    (hRecession : eps ≤ E.reservationCutoff A D TA M .recession) :
    0 ≤ E.toTwoStateValueCandidate.surplus .boom eps ∧
      E.toTwoStateValueCandidate.surplus .recession eps ≤ 0 := by
  constructor
  · exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .boom eps).2 hBoom
  · have hmono := (E.surplus_strictMono A D TA .recession).monotone hRecession
    rw [E.surplus_reservationCutoff_eq_zero A D TA M .recession] at hmono
    exact hmono

/-- If the boom cutoff is lower, both surpluses are nonnegative above the
recession cutoff. -/
theorem both_surplus_nonneg_above_recession_cutoff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hOrder : E.reservationCutoff A D TA M .boom <
      E.reservationCutoff A D TA M .recession)
    {eps : ℝ} (h : E.reservationCutoff A D TA M .recession ≤ eps) :
    0 ≤ E.toTwoStateValueCandidate.surplus .boom eps ∧
      0 ≤ E.toTwoStateValueCandidate.surplus .recession eps := by
  constructor
  · exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .boom eps).2
      (le_trans hOrder.le h)
  · exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .recession eps).2 h

/-- Under the reverse weak order, both surpluses are negative below the
recession cutoff. -/
theorem both_surplus_neg_below_recession_cutoff_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hOrder : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom)
    {eps : ℝ} (h : eps < E.reservationCutoff A D TA M .recession) :
    E.toTwoStateValueCandidate.surplus .recession eps < 0 ∧
      E.toTwoStateValueCandidate.surplus .boom eps < 0 := by
  constructor
  · exact (E.surplus_neg_iff_lt_reservationCutoff A D TA M .recession eps).2 h
  · exact (E.surplus_neg_iff_lt_reservationCutoff A D TA M .boom eps).2
      (lt_of_lt_of_le h hOrder)

/-- Under the reverse weak order, recession surplus is nonnegative and boom
surplus is nonpositive between the cutoffs. -/
theorem surplus_signs_between_cutoffs_of_recession_le_boom
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    {eps : ℝ}
    (hRecession : E.reservationCutoff A D TA M .recession ≤ eps)
    (hBoom : eps ≤ E.reservationCutoff A D TA M .boom) :
    0 ≤ E.toTwoStateValueCandidate.surplus .recession eps ∧
      E.toTwoStateValueCandidate.surplus .boom eps ≤ 0 := by
  constructor
  · exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .recession eps).2
      hRecession
  · have hmono := (E.surplus_strictMono A D TA .boom).monotone hBoom
    rw [E.surplus_reservationCutoff_eq_zero A D TA M .boom] at hmono
    exact hmono

/-- Under the reverse weak order, both surpluses are nonnegative above the boom
cutoff. -/
theorem both_surplus_nonneg_above_boom_cutoff_of_reverse_order
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T)
    (hOrder : E.reservationCutoff A D TA M .recession ≤
      E.reservationCutoff A D TA M .boom)
    {eps : ℝ} (h : E.reservationCutoff A D TA M .boom ≤ eps) :
    0 ≤ E.toTwoStateValueCandidate.surplus .recession eps ∧
      0 ≤ E.toTwoStateValueCandidate.surplus .boom eps := by
  constructor
  · exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .recession eps).2
      (le_trans hOrder h)
  · exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M .boom eps).2 h

end TwoStateValueEquilibrium
end MP1994V2
