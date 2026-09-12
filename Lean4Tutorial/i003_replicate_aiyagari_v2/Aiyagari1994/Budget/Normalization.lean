import Aiyagari1994.Primitives.Basic
namespace Aiyagari1994

/-- Pure algebra, valid without imposing extra economic restrictions. -/
theorem shifted_budget_equality_iff (r w l phi a a_next c : ℝ) :
    c + a_next = (1+r)*a + w*l ↔
      c + (a_next+phi) = (1+r)*(a+phi) + w*l - r*phi := by
  constructor <;> intro h <;> nlinarith [h]

theorem shifted_borrowing_iff (phi a_next : ℝ) :
    -phi ≤ a_next ↔ 0 ≤ a_next + phi := by constructor <;> intro h <;> linarith

/-- P01: equality and borrowing feasibility remain explicit, separate conjuncts. -/
theorem shifted_budget_iff (r w l phi a a_next c : ℝ) :
    (c + a_next = (1+r)*a + w*l ∧ -phi ≤ a_next) ↔
    (c + (a_next+phi) = (1+r)*(a+phi) + w*l-r*phi ∧ 0 ≤ a_next+phi) := by
  rw [shifted_budget_equality_iff, shifted_borrowing_iff]

/-- Current shifted savings and next labor, with the original-price intercept. -/
theorem next_resource_identity (r w phi a_next l_next : ℝ) :
    w*l_next + (1+r)*(a_next+phi)-r*phi =
      (1+r)*(a_next+phi) + (w*l_next + (-r*phi)) := by ring

theorem original_normalized_coordinates {i : IncomeData} (p : OriginalPrices i) :
    p.normalized.grossReturn = 1+p.netRate ∧
    p.normalized.intercept = -p.netRate*p.debtLimit := ⟨rfl, rfl⟩

end Aiyagari1994
