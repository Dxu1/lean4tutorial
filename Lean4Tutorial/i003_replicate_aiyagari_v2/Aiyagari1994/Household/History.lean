import Aiyagari1994.Primitives.Basic
import Mathlib.MeasureTheory.Integral.Prod

/-! Finite histories: coordinate zero is newest, the remaining coordinates are the past. -/
open MeasureTheory
namespace Aiyagari1994
noncomputable section

abbrev History (m : HouseholdPrimitives) (n : ℕ) := Fin n → m.income.Labor

def historySplit (m : HouseholdPrimitives) (n : ℕ) :
    History m (n+1) ≃ᵐ m.income.Labor × History m n :=
  MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n+1) => m.income.Labor) 0

def newestShock (m : HouseholdPrimitives) (n : ℕ) (h : History m (n+1)) : m.income.Labor :=
  (historySplit m n h).1

def previousHistory (m : HouseholdPrimitives) (n : ℕ) (h : History m (n+1)) : History m n :=
  (historySplit m n h).2

def extendHistory (m : HouseholdPrimitives) (n : ℕ) (l : m.income.Labor) (h : History m n) :
    History m (n+1) := (historySplit m n).symm (l,h)

theorem newestShock_measurable (m : HouseholdPrimitives) (n : ℕ) : Measurable (newestShock m n) :=
  (historySplit m n).measurable.fst

theorem previousHistory_measurable (m : HouseholdPrimitives) (n : ℕ) : Measurable (previousHistory m n) :=
  (historySplit m n).measurable.snd

theorem extendHistory_measurable (m : HouseholdPrimitives) (n : ℕ) :
    Measurable (fun p : m.income.Labor × History m n => extendHistory m n p.1 p.2) :=
  (historySplit m n).symm.measurable

@[simp] theorem newestShock_extend (m : HouseholdPrimitives) (n : ℕ)
    (l : m.income.Labor) (h : History m n) : newestShock m n (extendHistory m n l h) = l := by
  simp [newestShock,extendHistory]

@[simp] theorem previousHistory_extend (m : HouseholdPrimitives) (n : ℕ)
    (l : m.income.Labor) (h : History m n) : previousHistory m n (extendHistory m n l h) = h := by
  simp [previousHistory,extendHistory]

/-- The expectation identity is derived from history_step and Fubini, not assumed as IID data. -/
theorem history_integral_step (m : HouseholdPrimitives) (n : ℕ)
    (F : History m (n+1) → ℝ) (hF : Integrable F (historyLaw m.income (n+1))) :
    (∫ h, F h ∂historyLaw m.income (n+1)) =
      ∫ h, (∫ l, F (extendHistory m n l h) ∂(m.income.law : Measure m.income.Labor))
        ∂historyLaw m.income n := by
  have hp : MeasurePreserving (historySplit m n) (historyLaw m.income (n+1))
      ((m.income.law : Measure m.income.Labor).prod (historyLaw m.income n)) :=
    history_step m.income n
  have hs := hp.symm
  have hi := hs.integrable_comp_of_integrable hF
  calc
    _ = ∫ p, F ((historySplit m n).symm p)
        ∂((m.income.law : Measure m.income.Labor).prod (historyLaw m.income n)) :=
      (hs.integral_comp (historySplit m n).symm.measurableEmbedding F).symm
    _ = _ := integral_prod_symm _ hi

end
end Aiyagari1994
