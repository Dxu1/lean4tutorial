import Aiyagari1994.Analysis.M05C.Crossing

/-! S03: the economic common-horizon crossing condition. -/
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- S03: on a forward-invariant interval, nondegenerate endpoint neighborhoods and strict
impatience yield a common finite horizon at which the endpoint laws cross an interior level. -/
theorem economic_crossing_condition
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hnd : IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (B : Resources) (hUpperB : upperEffectiveIncome m ≤ B)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome m ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome m ≤ m.prices.nextResources (assetPolicy m z) l ∧
          m.prices.nextResources (assetPolicy m z) l ≤ B) :
    ∃ (d : Resources) (N : ℕ) (ε : ℝ≥0∞),
      lowerEffectiveIncome m < d ∧ d < upperEffectiveIncome m ∧ 1 ≤ N ∧ 0 < ε ∧
      ε ≤ (householdKernel m ^ N) (lowerEffectiveIncome m) (Icc d B) ∧
      ε ≤ (householdKernel m ^ N) B (Icc (lowerEffectiveIncome m) d) :=
  M05C_economic_crossing_condition m hsmooth hnd hbetaR B hUpperB hInvariant

end
end Aiyagari1994
