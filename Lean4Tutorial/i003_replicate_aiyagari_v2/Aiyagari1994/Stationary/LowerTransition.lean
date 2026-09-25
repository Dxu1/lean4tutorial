import Aiyagari1994.Analysis.M05B.Iterates

/-! S02: strict lower-shock drift and convergence of its iterates. -/
open Filter Function
open scoped Topology
namespace Aiyagari1994
noncomputable section

/-- S02: the least-shock transition fixes least effective income, lies strictly below every
larger state, and its iterates from every finite upper state converge monotonically to the
least effective income. -/
theorem lower_transition_iterates_tendsto
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
    lowerTransition m (lowerEffectiveIncome m) = lowerEffectiveIncome m ∧
    (∀ z : Resources, lowerEffectiveIncome m < z → lowerTransition m z < z) ∧
    ∀ B : Resources, lowerEffectiveIncome m ≤ B →
      Antitone (fun n : ℕ ↦ (lowerTransition m)^[n] B) ∧
      Tendsto (fun n : ℕ ↦ (lowerTransition m)^[n] B) atTop
        (nhds (lowerEffectiveIncome m)) :=
  M05B_lower_transition_iterates_tendsto m hsmooth hbetaR

end
end Aiyagari1994
