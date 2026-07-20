import Mathlib.Tactic.NormNum

namespace Lean4Tutorial.BasicExamples

theorem two_plus_two_by_rfl : (2 : ℕ) + 2 = 4 := by
  rfl

theorem two_plus_two_by_norm_num : (2 : ℕ) + 2 = 4 := by
  norm_num

end Lean4Tutorial.BasicExamples

#print axioms Lean4Tutorial.BasicExamples.two_plus_two_by_rfl
