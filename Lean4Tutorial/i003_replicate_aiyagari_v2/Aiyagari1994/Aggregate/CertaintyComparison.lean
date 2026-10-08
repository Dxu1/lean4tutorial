import Aiyagari1994.Analysis.M09C2.CertaintyComparison

/-! A05: partial-equilibrium risky/certainty stationary-asset comparison. -/
open Filter
open scoped Topology
namespace Aiyagari1994
noncomputable section

/-- A05.  At a fixed positive wage, risky stationary net assets weakly exceed the mean-income
certainty benchmark at every strictly impatient admissible rate, for both the finite-cap and
natural-limit debt rules.  The comparison is strict throughout a one-sided neighborhood of the
impatience boundary in each respective rate domain. -/
theorem risky_assets_above_certainty_near_impatience (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w) :
    (∀ r : M09C2.SubcriticalRate m,
      M09C2.finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r ≥
        M09C2.finiteCertaintySupply m b w hb hw r) ∧
    (∀ r : M09C2.PositiveSubcriticalRate m,
      M09C2.naturalRiskSupply m hsmooth hcurvature hnd w hw r ≥
        M09C2.naturalCertaintySupply m w hw r) ∧
    (∀ᶠ r in Filter.comap ((↑·) : M09C2.SubcriticalRate m → ℝ)
        (nhds (M09C2.criticalRate m)),
      M09C2.finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r >
        M09C2.finiteCertaintySupply m b w hb hw r) ∧
    (∀ᶠ r in Filter.comap ((↑·) : M09C2.PositiveSubcriticalRate m → ℝ)
        (nhds (M09C2.criticalRate m)),
      M09C2.naturalRiskSupply m hsmooth hcurvature hnd w hw r >
        M09C2.naturalCertaintySupply m w hw r) :=
  M09C2.risky_assets_above_certainty_core m hsmooth hcurvature hnd b w hb hw

end
end Aiyagari1994
