import Aiyagari1994.Household.RightMarginal
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.Lebesgue.Add

/-! Small sequence lemmas used by the M03B1 monotone-convergence argument. -/
open Set Filter
open scoped Topology ENNReal
namespace Aiyagari1994
noncomputable section

/-- The positive sequence `1/(n+1)` used to approach a right endpoint. -/
def marginalStep (n : ℕ) : ℝ := 1 / (n + 1 : ℝ)

theorem marginalStep_pos (n : ℕ) : 0 < marginalStep n := by
  rw [marginalStep]
  positivity

theorem marginalStep_antitone : Antitone marginalStep := by
  intro n k hnk
  rw [marginalStep, marginalStep]
  exact one_div_le_one_div_of_le (by positivity) (by exact_mod_cast Nat.add_le_add_right hnk 1)

theorem marginalStep_tendsto_zero : Tendsto marginalStep atTop (nhds 0) := by
  have he : marginalStep = fun n : ℕ => 1 / ((n : ℝ) + 1) := by
    funext n
    simp [marginalStep]
  rw [he]
  exact tendsto_one_div_add_atTop_nhds_zero_nat

/-- Adding a positive multiple of `marginalStep` approaches `x` from the right. -/
theorem tendsto_add_marginalStep_right (x R : ℝ) (hR : 0 < R) :
    Tendsto (fun n => x + R * marginalStep n) atTop (nhdsWithin x (Ioi x)) := by
  rw [tendsto_nhdsWithin_iff]
  refine ⟨?_, ?_⟩
  · simpa using
      (tendsto_const_nhds.add (tendsto_const_nhds.mul marginalStep_tendsto_zero) :
        Tendsto (fun n => x + R * marginalStep n) atTop (nhds (x + R * 0)))
  exact Eventually.of_forall fun n => by
    simp only [mem_Ioi]
    exact lt_add_of_pos_right x (mul_pos hR (marginalStep_pos n))

end
end Aiyagari1994
