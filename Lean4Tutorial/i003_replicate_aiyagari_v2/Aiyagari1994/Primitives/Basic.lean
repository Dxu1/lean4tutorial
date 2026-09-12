import Mathlib.Analysis.Convex.Deriv
import Mathlib.Analysis.Calculus.ContDiff.Operations
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure
import Mathlib.Probability.Independence.Basic
import Mathlib.MeasureTheory.Function.LocallyIntegrable
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.NormNum

/-! Primitive data only. Assets/resources are NNReal; labor laws may have arbitrary compact support. -/
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal NNReal Topology
namespace Aiyagari1994

abbrev Resources := NNReal

structure UtilityData where
  utility : ℝ → ℝ

structure UtilityBase (u : UtilityData) : Prop where
  continuous : ContinuousOn u.utility (Ici 0)
  bounded : ∃ C : ℝ, ∀ c ∈ Ici (0 : ℝ), |u.utility c| ≤ C
  increasing : StrictMonoOn u.utility (Ici 0)
  concave : StrictConcaveOn ℝ (Ici 0) u.utility

structure UtilitySmooth (u : UtilityData) : Prop where
  smooth : ContDiffOn ℝ 1 u.utility (Ioi 0)
  marginal_pos : ∀ c ∈ Ioi (0 : ℝ), 0 < deriv u.utility c

structure UtilityCurvature (u : UtilityData) : Prop where
  smooth : ContDiffOn ℝ 2 u.utility (Ioi 0)
  risk_bound : ∃ C > (0 : ℝ), ∃ M : ℝ, ∀ c ≥ C,
    -c * deriv (deriv u.utility) c / deriv u.utility c ≤ M

abbrev Labor (lo hi : ℝ) := Icc lo hi

structure IncomeData where
  lower : ℝ
  upper : ℝ
  law : ProbabilityMeasure (Labor lower upper)

abbrev IncomeData.Labor (i : IncomeData) := Aiyagari1994.Labor i.lower i.upper

structure IncomeSupport (i : IncomeData) : Prop where
  lower_pos : 0 < i.lower
  ordered : i.lower ≤ i.upper

structure IncomeNondegenerate (i : IncomeData) : Prop where
  endpoints_distinct : i.lower < i.upper
  lower_mass : ∀ ε > (0 : ℝ), 0 < (i.law : Measure i.Labor) {l | (l : ℝ) < i.lower + ε}
  upper_mass : ∀ ε > (0 : ℝ), 0 < (i.law : Measure i.Labor) {l | i.upper - ε < (l : ℝ)}

theorem labor_integrable (i : IncomeData) :
    Integrable (fun l : i.Labor => (l : ℝ)) (i.law : Measure i.Labor) :=
  Continuous.integrable_of_hasCompactSupport continuous_subtype_val (HasCompactSupport.of_compactSpace _)

structure LaborMeanOne (i : IncomeData) : Prop where
  mean_eq_one : ∫ l : i.Labor, (l : ℝ) ∂(i.law : Measure i.Labor) = 1

/-- IID finite histories are constructed, never assumed as economic conclusions. -/
noncomputable def historyLaw (i : IncomeData) (n : ℕ) : Measure (Fin n → i.Labor) :=
  Measure.pi (fun _ => (i.law : Measure i.Labor))

instance history_probability (i : IncomeData) (n : ℕ) : IsProbabilityMeasure (historyLaw i n) := by
  unfold historyLaw
  infer_instance

theorem history_marginal (i : IncomeData) (n : ℕ) (j : Fin n) :
    (historyLaw i n).map (Function.eval j) = (i.law : Measure i.Labor) :=
  (measurePreserving_eval (fun _ : Fin n => (i.law : Measure i.Labor)) j).map_eq

theorem history_independent (i : IncomeData) (n : ℕ) :
    iIndepFun (fun j : Fin n => fun h : Fin n → i.Labor => h j) (historyLaw i n) :=
  iIndepFun_pi (fun _ => aemeasurable_id)

theorem history_step (i : IncomeData) (n : ℕ) :
    MeasurePreserving (MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n+1) => i.Labor) 0)
      (historyLaw i (n+1)) ((i.law : Measure i.Labor).prod (historyLaw i n)) :=
  measurePreserving_piFinSuccAbove (fun _ => (i.law : Measure i.Labor)) 0

structure NormalizedPrices (i : IncomeData) where
  grossReturn : ℝ
  wage : ℝ
  intercept : ℝ
  grossReturn_pos : 0 < grossReturn
  wage_pos : 0 < wage
  income_nonneg : ∀ l : i.Labor, 0 ≤ wage * (l : ℝ) + intercept

structure OriginalPrices (i : IncomeData) where
  netRate : ℝ
  wage : ℝ
  debtLimit : ℝ
  netRate_gt : -1 < netRate
  wage_pos : 0 < wage
  debtLimit_nonneg : 0 ≤ debtLimit
  income_nonneg : ∀ l : i.Labor, 0 ≤ wage * (l : ℝ) - netRate * debtLimit

def OriginalPrices.normalized {i : IncomeData} (p : OriginalPrices i) : NormalizedPrices i where
  grossReturn := 1 + p.netRate
  wage := p.wage
  intercept := -p.netRate * p.debtLimit
  grossReturn_pos := by linarith [p.netRate_gt]
  wage_pos := p.wage_pos
  income_nonneg := by intro l; simpa [sub_eq_add_neg] using p.income_nonneg l

def NormalizedPrices.effectiveIncome {i : IncomeData} (p : NormalizedPrices i) (l : i.Labor) : ℝ :=
  p.wage * (l : ℝ) + p.intercept

def NormalizedPrices.nextResources {i : IncomeData} (p : NormalizedPrices i)
    (a : Resources) (l : i.Labor) : Resources :=
  ⟨p.grossReturn * (a : ℝ) + p.effectiveIncome l,
    add_nonneg (mul_nonneg p.grossReturn_pos.le a.property) (p.income_nonneg l)⟩

structure HouseholdPrimitives where
  beta : ℝ
  beta_pos : 0 < beta
  beta_lt_one : beta < 1
  utility : UtilityData
  utility_base : UtilityBase utility
  income : IncomeData
  income_support : IncomeSupport income
  prices : NormalizedPrices income

structure CoreRegularity (m : HouseholdPrimitives) : Prop where
  utility_smooth : UtilitySmooth m.utility
  utility_curvature : UtilityCurvature m.utility
  income_nondegenerate : IncomeNondegenerate m.income
  labor_mean_one : LaborMeanOne m.income

end Aiyagari1994
