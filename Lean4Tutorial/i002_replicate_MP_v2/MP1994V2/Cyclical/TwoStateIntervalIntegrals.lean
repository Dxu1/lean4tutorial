import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoff

/-!
# MP1994 v2: statewise surviving-surplus integrals

The max-based continuation integral is rewritten over the state-specific
survival interval.  No ordering between the two aggregate-state cutoffs is
used or asserted.
-/

open MeasureTheory Set

namespace MP1994V2
namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- Surplus integrated over the shocks that survive in aggregate state `s`. -/
noncomputable def survivingSurplusIntegral
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) : ℝ :=
  ∫ x in Icc (E.reservationCutoff A D TA M s) P.epsUpper,
    E.toTwoStateValueCandidate.surplus s x ∂P.shock

/-- Active surplus equals surplus integrated over the statewise survival
interval.  The almost-sure upper-support condition removes shocks above
`epsUpper`; cutoff uniqueness and monotonicity handle the lower endpoint. -/
theorem integral_activeSurplus_eq_survivingSurplusIntegral
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    (∫ x, E.toTwoStateValueCandidate.activeSurplus s x ∂P.shock) =
      E.survivingSurplusIntegral A D TA M s := by
  have hUpper : ∀ᵐ x ∂P.shock, x ≤ P.epsUpper := by
    rw [ae_iff]
    rw [show {x : ℝ | ¬x ≤ P.epsUpper} = Ioi P.epsUpper by
      ext x
      simp]
    exact D.upperSupport
  unfold survivingSurplusIntegral
  rw [← integral_indicator measurableSet_Icc]
  apply integral_congr_ae
  filter_upwards [hUpper] with x hx
  by_cases hcut : E.reservationCutoff A D TA M s ≤ x
  · have hmem : x ∈ Icc (E.reservationCutoff A D TA M s) P.epsUpper :=
      ⟨hcut, hx⟩
    rw [indicator_of_mem hmem]
    unfold TwoStateValueCandidate.activeSurplus positivePart
    rw [max_eq_left]
    exact (E.surplus_nonneg_iff_reservationCutoff_le A D TA M s x).2 hcut
  · have hnmem : x ∉ Icc (E.reservationCutoff A D TA M s) P.epsUpper := by
      intro hmem
      exact hcut hmem.1
    simp only [indicator_apply, hnmem, ↓reduceIte]
    unfold TwoStateValueCandidate.activeSurplus positivePart
    rw [max_eq_right]
    exact ((E.surplus_neg_iff_lt_reservationCutoff A D TA M s x).2
      (lt_of_not_ge hcut)).le

/-- Paper-facing statewise continuation identity, stated without any cross-state
cutoff-ordering hypothesis. -/
theorem statewise_continuation_integral_eq
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) :
    (∫ x, E.toTwoStateValueCandidate.activeSurplus s x ∂P.shock) =
      ∫ x in Icc (E.reservationCutoff A D TA M s) P.epsUpper,
        E.toTwoStateValueCandidate.surplus s x ∂P.shock := by
  exact E.integral_activeSurplus_eq_survivingSurplusIntegral A D TA M s

end TwoStateValueEquilibrium
end MP1994V2
