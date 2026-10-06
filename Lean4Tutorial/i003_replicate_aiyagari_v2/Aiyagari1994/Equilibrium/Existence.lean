import Aiyagari1994.Analysis.M09B1.FiniteCapExistence

/-! G02: existence of a stationary equilibrium under every finite institutional debt cap. -/

namespace Aiyagari1994

/-- G02. Every finite nonnegative institutional debt cap admits an actual stationary equilibrium
that retains the supplied discount factor, utility, income law, and finite cap, and whose net
interest rate lies strictly between minus depreciation and the impatience rate. -/
theorem finiteCap_equilibrium_exists (p : ProductionData) (hp : ProductionRegularity p)
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (hmean : LaborMeanOne m.income) (b : ℝ) (hb : 0 ≤ b) :
    ∃ e : StationaryEquilibrium p hp,
      e.household.beta = m.beta ∧
        e.household.utility = m.utility ∧
        e.household.income = m.income ∧
        e.originalPrices.debtLimit =
          effectiveLimit b m.income.lower (firmWage p hp e.rate) (e.rate : ℝ) ∧
        -p.depreciation < (e.rate : ℝ) ∧ (e.rate : ℝ) < 1 / m.beta - 1 :=
  M09B1.finiteCap_equilibrium_exists_core p hp m hsmooth hcurvature hnd hmean b hb

end Aiyagari1994
