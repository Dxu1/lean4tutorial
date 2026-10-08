import Aiyagari1994.Equilibrium.Definition
import Aiyagari1994.Stationary.NoInvariant

/-!
# Every stationary-equilibrium rate is strictly subcritical

The argument uses the invariant resource law carried by the unrestricted G01 equilibrium
record.  If its household return were at or above the impatience boundary, N07 would exclude
that very probability law.  The original/normalized price identities then translate the strict
household inequality into the net-rate bound.
-/

open MeasureTheory ProbabilityTheory

namespace Aiyagari1994
noncomputable section

namespace M09C3

/-- Gate-local implementation of G04 for an arbitrary unrestricted G01 equilibrium. -/
theorem every_equilibrium_rate_below_impatience_core
    (p : ProductionData) (hp : ProductionRegularity p)
    (e : StationaryEquilibrium p hp) :
    (e.rate : ℝ) < 1 / e.household.beta - 1 := by
  have hinvariant :
      householdKernel e.household ∘ₘ (e.resourceLaw : Measure Resources) =
        (e.resourceLaw : Measure Resources) := by
    exact congrArg ProbabilityMeasure.toMeasure e.resource_stationary
  have hbetaR :
      e.household.beta * e.household.prices.grossReturn < 1 := by
    by_contra hnot
    have hatOrAbove :
        1 ≤ e.household.beta * e.household.prices.grossReturn := le_of_not_gt hnot
    exact (no_invariant_at_or_above_impatience e.household e.utility_smooth
      e.income_nondegenerate hatOrAbove) ⟨e.resourceLaw, hinvariant⟩
  have hreturn :
      e.household.prices.grossReturn = 1 + (e.rate : ℝ) := by
    calc
      e.household.prices.grossReturn = e.originalPrices.normalized.grossReturn :=
        congrArg NormalizedPrices.grossReturn e.normalized_prices.symm
      _ = 1 + e.originalPrices.netRate := rfl
      _ = 1 + (e.rate : ℝ) := by rw [e.original_rate]
  rw [hreturn] at hbetaR
  apply (lt_sub_iff_add_lt).2
  apply (lt_div_iff₀ e.household.beta_pos).2
  nlinarith [hbetaR]

end M09C3

end
end Aiyagari1994
