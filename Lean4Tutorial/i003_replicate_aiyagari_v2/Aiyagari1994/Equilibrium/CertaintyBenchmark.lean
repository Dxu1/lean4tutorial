import Aiyagari1994.Analysis.M09C1.CertaintyStationary

/-! A04: the mean-income certainty stationary benchmark. -/
open MeasureTheory ProbabilityTheory Filter
open scoped Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- A04.  With deterministic labor fixed at the risky household's actual mean and strict
impatience, the canonical resource kernel converges weakly from every initial probability law to
its unique invariant point mass.  Shifted assets vanish there, so net assets are exactly minus the
certainty debt limit carried by the certainty price object. -/
theorem certainty_stationary_assets_at_limit
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1) :
    let m := M09C1.certaintyHousehold base p
    let ebar := lowerEffectiveIncome m
    let delta := M09C1.pointMass ebar
    (householdKernel m ∘ₘ (delta : Measure Resources) = (delta : Measure Resources)) ∧
    (∀ mu : ProbabilityMeasure Resources,
      ((M09C1.certaintyLawStep m mu : ProbabilityMeasure Resources) : Measure Resources) =
        householdKernel m ∘ₘ (mu : Measure Resources)) ∧
    (∀ mu : ProbabilityMeasure Resources,
      Tendsto (fun n : ℕ ↦ (M09C1.certaintyLawStep m)^[n] mu) Filter.atTop
        (nhds delta)) ∧
    (∀ mu : ProbabilityMeasure Resources,
      householdKernel m ∘ₘ (mu : Measure Resources) = (mu : Measure Resources) →
        mu = delta) ∧
    assetPolicy m ebar = 0 ∧
    Integrable (fun z : Resources ↦ ((assetPolicy m z : ℝ) - p.debtLimit))
      (delta : Measure Resources) ∧
    (∫ z : Resources, ((assetPolicy m z : ℝ) - p.debtLimit)
      ∂(delta : Measure Resources)) = -p.debtLimit :=
  M09C1_certainty_stationary_assets_at_limit base hsmooth p hbetaR

end
end Aiyagari1994
