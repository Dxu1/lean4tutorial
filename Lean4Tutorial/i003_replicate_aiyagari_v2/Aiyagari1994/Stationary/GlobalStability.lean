import Aiyagari1994.Analysis.M05E.Global

/-! S05: global existence, uniqueness, and weak convergence of the stationary resource law. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- S05: under smoothness, eventual bounded relative risk aversion, endpoint nondegeneracy, and
strict impatience, the household resource kernel has one invariant probability law. It is
supported on a constructed compact interval and attracts every probability law weakly on the
full `NNReal` state space. -/
theorem stationaryLaw_exists_unique_global
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ∃ (B : Resources) (pi : ProbabilityMeasure Resources),
      upperEffectiveIncome m ≤ B ∧
      (pi : Measure Resources) (Icc (lowerEffectiveIncome m) B) = 1 ∧
      householdLawStep m pi = pi ∧
      (∀ rho : ProbabilityMeasure Resources, householdLawStep m rho = rho → rho = pi) ∧
      ∀ mu : ProbabilityMeasure Resources,
        Tendsto (fun n ↦ (householdLawStep m)^[n] mu) atTop (nhds pi) := by
  obtain ⟨B, hUpperB, hDrift, hInvariant⟩ :=
    M05E.exists_invariant_upper m hsmooth hcurvature hbetaR
  have haUpper : lowerEffectiveIncome m < upperEffectiveIncome m := by
    apply Subtype.coe_lt_coe.mp
    change m.prices.wage * m.income.lower + m.prices.intercept <
      m.prices.wage * m.income.upper + m.prices.intercept
    nlinarith [m.prices.wage_pos, hnd.endpoints_distinct]
  have hab : lowerEffectiveIncome m ≤ B := haUpper.le.trans hUpperB
  obtain ⟨piI, hpiI, hallI⟩ := M05E.economic_compact_stability m hsmooth hnd
    hbetaR B hUpperB hInvariant
  let pi := M05E.embedLaw (lowerEffectiveIncome m) B piI
  have hpi : householdLawStep m pi = pi := by
    rw [← M05E.embedLaw_lawStep m (lowerEffectiveIncome m) B hab hInvariant, hpiI]
  have hpoint := M05E.pointwise_global_stability m hsmooth hnd hbetaR B hUpperB hab
    hInvariant hDrift piI hpiI hallI
  have hall := M05E.global_stability_from_points m pi hpoint
  refine ⟨B, pi, hUpperB, M05E.embedLaw_support _ _ piI, hpi, ?_, hall⟩
  intro rho hrho
  have horbit : ∀ n, (householdLawStep m)^[n] rho = rho := by
    intro n
    induction n with
    | zero => rfl
    | succ n ih => rw [Function.iterate_succ_apply', ih, hrho]
  have hconstPi : Tendsto (fun _ : ℕ ↦ rho) atTop (nhds pi) := by
    simpa only [horbit] using hall rho
  have hconstRho : Tendsto (fun _ : ℕ ↦ rho) atTop (nhds rho) := tendsto_const_nhds
  exact (tendsto_nhds_unique hconstPi hconstRho).symm

end
end Aiyagari1994
