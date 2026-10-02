import Aiyagari1994.Stationary.Supercritical
import Aiyagari1994.Stationary.Critical

/-! N07: exclusion of invariant household laws at and above the impatience boundary. -/
open MeasureTheory ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- N07: if `1 ≤ beta * R`, the canonical household kernel admits no invariant probability
law.  This theorem only assembles the accepted supercritical and critical exclusions. -/
theorem no_invariant_at_or_above_impatience (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hnd : IncomeNondegenerate m.income)
    (hatOrAbove : 1 ≤ m.beta * m.prices.grossReturn) :
    ¬ ∃ pi : ProbabilityMeasure Resources,
      householdKernel m ∘ₘ (pi : Measure Resources) = (pi : Measure Resources) := by
  rcases hatOrAbove.eq_or_lt with hcritical | hsupercritical
  · exact no_invariant_critical m hsmooth hnd hcritical.symm
  · exact no_invariant_supercritical m hsmooth hnd hsupercritical

end
end Aiyagari1994
