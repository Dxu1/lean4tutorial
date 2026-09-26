import Aiyagari1994.Analysis.M06A.ParameterContinuity

/-! S06: weak continuity of the canonical stationary resource law in normalized prices. -/
open MeasureTheory
open scoped Topology
namespace Aiyagari1994
noncomputable section

/-- S06. With utility, beta, and the iid labor law fixed, the canonical invariant resource law
is weakly continuous at every strictly impatient admissible normalized price vector. The proof
uses D03 only locally, so it makes no uniform-support claim at the impatience boundary. -/
theorem stationaryLaw_weakly_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) :
    Continuous (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd) :=
  M06A.stationaryLaw_weakly_continuous_core m hsmooth hcurvature hnd

end
end Aiyagari1994
