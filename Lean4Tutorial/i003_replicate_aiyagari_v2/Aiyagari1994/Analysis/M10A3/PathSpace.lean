import Aiyagari1994.Analysis.M10A1.BudgetTelescope
import Mathlib.Probability.Independence.InfinitePi

/-! The infinite IID path space and the adapted original-asset plan interface for NP03. -/

open Filter Finset MeasureTheory ProbabilityTheory Set
open scoped ENNReal ProbabilityTheory Topology

namespace Aiyagari1994.M10A3
noncomputable section

/-- Infinite IID labor histories. -/
abbrev IIDPath (i : IncomeData) := ℕ → i.Labor

/-- The product law on infinite labor histories. -/
def iidPathLaw (i : IncomeData) : Measure (IIDPath i) :=
  Measure.infinitePi (fun _ : ℕ ↦ (i.law : Measure i.Labor))

instance iidPathLaw_probability (i : IncomeData) : IsProbabilityMeasure (iidPathLaw i) := by
  unfold iidPathLaw
  infer_instance

/-- An original-asset plan with the paper's information timing.  Date-`t` assets use only
the first `t` labor draws, while date-`t` consumption may also use the current draw. -/
structure AdaptedOriginalPlan (i : IncomeData) where
  assetPrefix : (t : ℕ) → (↑(Finset.range t) → i.Labor) → ℝ
  consumptionPrefix : (t : ℕ) → (↑(Finset.range (t + 1)) → i.Labor) → ℝ
  assetPrefix_measurable : ∀ t, Measurable (assetPrefix t)
  consumptionPrefix_measurable : ∀ t, Measurable (consumptionPrefix t)

def AdaptedOriginalPlan.asset {i : IncomeData} (p : AdaptedOriginalPlan i)
    (t : ℕ) (omega : IIDPath i) : ℝ :=
  p.assetPrefix t (fun j ↦ omega j.1)

def AdaptedOriginalPlan.consumption {i : IncomeData} (p : AdaptedOriginalPlan i)
    (t : ℕ) (omega : IIDPath i) : ℝ :=
  p.consumptionPrefix t (fun j ↦ omega j.1)

theorem AdaptedOriginalPlan.asset_measurable {i : IncomeData} (p : AdaptedOriginalPlan i)
    (t : ℕ) : Measurable (p.asset t) := by
  exact (p.assetPrefix_measurable t).comp (by fun_prop)

theorem AdaptedOriginalPlan.consumption_measurable {i : IncomeData}
    (p : AdaptedOriginalPlan i) (t : ℕ) : Measurable (p.consumption t) := by
  exact (p.consumptionPrefix_measurable t).comp (by fun_prop)

/-- The labor coordinate process on the infinite product space is IID with the primitive law. -/
theorem iidPath_independent (i : IncomeData) :
    iIndepFun (fun t : ℕ ↦ fun omega : IIDPath i ↦ omega t) (iidPathLaw i) := by
  exact iIndepFun_infinitePi (X := fun _ x ↦ x) (fun _ ↦ measurable_id)

/-- Every labor coordinate has the primitive marginal law. -/
theorem iidPath_marginal (i : IncomeData) (t : ℕ) :
    (iidPathLaw i).map (fun omega : IIDPath i ↦ omega t) = (i.law : Measure i.Labor) := by
  exact Measure.infinitePi_map_eval (fun _ : ℕ ↦ (i.law : Measure i.Labor)) t

end
end Aiyagari1994.M10A3
