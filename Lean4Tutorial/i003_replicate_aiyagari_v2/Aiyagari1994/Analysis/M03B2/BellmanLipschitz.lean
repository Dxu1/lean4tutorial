import Aiyagari1994.Analysis.M03B2.ZeroUtilityMarginal

/-! Finite-horizon Lipschitz propagation for the subcritical Bellman operator. -/
open MeasureTheory Set Filter
open scoped ENNReal NNReal Topology
namespace Aiyagari1994
noncomputable section

private theorem continuation_increment_le
    (m : HouseholdPrimitives) (v : ValueSpace) (L : ℝ)
    (hv : ∀ x y : Resources, x ≤ y →
      v y - v x ≤ L * ((y : ℝ) - (x : ℝ)))
    {a b : Resources} (hab : a ≤ b) :
    continuation m v b - continuation m v a ≤
      L * m.prices.grossReturn * ((b : ℝ) - (a : ℝ)) := by
  rw [continuation, continuation, ← integral_sub
    (continuation_integrable m v b) (continuation_integrable m v a)]
  have hsub : Integrable (fun l : m.income.Labor =>
      v (m.prices.nextResources b l) - v (m.prices.nextResources a l))
      (m.income.law : Measure m.income.Labor) :=
    (continuation_integrable m v b).sub (continuation_integrable m v a)
  have hconst : Integrable (fun _ : m.income.Labor =>
      L * m.prices.grossReturn * ((b : ℝ) - (a : ℝ)))
      (m.income.law : Measure m.income.Labor) := integrable_const _
  calc
    _ ≤ ∫ _ : m.income.Labor,
        L * m.prices.grossReturn * ((b : ℝ) - (a : ℝ))
        ∂(m.income.law : Measure m.income.Labor) := by
      apply integral_mono hsub hconst
      intro l
      have hn : m.prices.nextResources a l ≤ m.prices.nextResources b l := by
        change m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l ≤
          m.prices.grossReturn * (b : ℝ) + m.prices.effectiveIncome l
        simpa [add_comm] using add_le_add_right (mul_le_mul_of_nonneg_left
          (show (a : ℝ) ≤ (b : ℝ) from hab) m.prices.grossReturn_pos.le)
          (m.prices.effectiveIncome l)
      have h := hv _ _ hn
      have he : ((m.prices.nextResources b l : Resources) : ℝ) -
          ((m.prices.nextResources a l : Resources) : ℝ) =
          m.prices.grossReturn * ((b : ℝ) - (a : ℝ)) := by
        change (m.prices.grossReturn * (b : ℝ) + m.prices.effectiveIncome l) -
          (m.prices.grossReturn * (a : ℝ) + m.prices.effectiveIncome l) = _
        ring
      rw [he] at h
      simpa only [mul_assoc] using h
    _ = _ := by simp

private theorem bellman_preserves_orderLipschitz
    (m : HouseholdPrimitives) (L : ℝ) (hL : 0 ≤ L)
    (hbetaR : m.beta * m.prices.grossReturn ≤ 1)
    (v : ValueSpace)
    (hv : ∀ x y : Resources, x ≤ y →
      v y - v x ≤ L * ((y : ℝ) - (x : ℝ)))
    (hu : ∀ {x y : ℝ}, 0 ≤ x → x ≤ y →
      m.utility.utility y - m.utility.utility x ≤ L * (y - x)) :
    ∀ x y : Resources, x ≤ y →
      bellmanOperator m v y - bellmanOperator m v x ≤
        L * ((y : ℝ) - (x : ℝ)) := by
  intro x y hxy
  obtain ⟨a, ha, hya⟩ := bellmanValue_attained m v y
  by_cases hax : a ≤ x
  · have hxobj := objective_le_bellmanValue m v x a hax
    rw [bellmanOperator_apply, hya, bellmanOperator_apply]
    rw [bellmanObjective_feasible m v y a ha]
    rw [bellmanObjective_feasible m v x a hax] at hxobj
    have hui := hu (sub_nonneg.mpr (show (a : ℝ) ≤ (x : ℝ) from hax))
      (sub_le_sub_right (show (x : ℝ) ≤ (y : ℝ) from hxy) _)
    linarith
  · have hxa : x < a := lt_of_not_ge hax
    have hxobj := objective_le_bellmanValue m v x x le_rfl
    rw [bellmanOperator_apply, hya, bellmanOperator_apply]
    rw [bellmanObjective_feasible m v y a ha]
    rw [bellmanObjective_feasible m v x x le_rfl] at hxobj
    simp only [sub_self] at hxobj
    have hui := hu (show (0 : ℝ) ≤ 0 by simp)
      (sub_nonneg.mpr (show (a : ℝ) ≤ (y : ℝ) from ha))
    have hcont := continuation_increment_le m v L hv hxa.le
    have hcoef : m.beta * L * m.prices.grossReturn ≤ L := by
      calc
        m.beta * L * m.prices.grossReturn = L * (m.beta * m.prices.grossReturn) := by ring
        _ ≤ L * 1 := mul_le_mul_of_nonneg_left hbetaR hL
        _ = L := mul_one L
    have hcontbeta := mul_le_mul_of_nonneg_left hcont m.beta_pos.le
    have hterm : m.beta * (L * m.prices.grossReturn * ((a : ℝ) - (x : ℝ))) ≤
        L * ((a : ℝ) - (x : ℝ)) := by
      calc
        _ = (m.beta * L * m.prices.grossReturn) * ((a : ℝ) - (x : ℝ)) := by ring
        _ ≤ L * ((a : ℝ) - (x : ℝ)) :=
          mul_le_mul_of_nonneg_right hcoef (sub_nonneg.mpr (show (x : ℝ) ≤ (a : ℝ) from hxa.le))
    have hyaR : (a : ℝ) ≤ (y : ℝ) := ha
    have hxyR : (x : ℝ) ≤ (y : ℝ) := hxy
    linarith

/-- If the utility marginal at zero is finite and `beta * R <= 1`, the canonical value
function inherits its global one-sided Lipschitz bound from finite Bellman horizons. -/
theorem valueFunction_increment_le_zeroMarginal
    (m : HouseholdPrimitives)
    (hfinite : utilityZeroRightMarginal m < ⊤)
    (hbetaR : m.beta * m.prices.grossReturn ≤ 1)
    {x y : Resources} (hxy : x ≤ y) :
    valueFunction m y - valueFunction m x ≤
      (utilityZeroRightMarginal m).toReal * ((y : ℝ) - (x : ℝ)) := by
  let L := (utilityZeroRightMarginal m).toReal
  have hL : 0 ≤ L := ENNReal.toReal_nonneg
  have hu : ∀ {x y : ℝ}, 0 ≤ x → x ≤ y →
      m.utility.utility y - m.utility.utility x ≤ L * (y - x) := by
    intro x y hx hxy
    exact utility_increment_le_zeroMarginal m hfinite hx hxy
  have hi : ∀ n : ℕ, ∀ x y : Resources, x ≤ y →
      ((bellmanOperator m)^[n] (0 : ValueSpace)) y -
          ((bellmanOperator m)^[n] (0 : ValueSpace)) x ≤
        L * ((y : ℝ) - (x : ℝ)) := by
    intro n
    induction n with
    | zero =>
        intro x y hxy
        simpa using mul_nonneg hL
          (sub_nonneg.mpr (show (x : ℝ) ≤ (y : ℝ) from hxy))
    | succ n ih =>
        simpa only [Function.iterate_succ_apply'] using
          bellman_preserves_orderLipschitz m L hL hbetaR _ ih hu
  have ht := valueIteration_uniform m (0 : ValueSpace)
  exact le_of_tendsto_of_tendsto
    (((ht.tendsto_at y).sub (ht.tendsto_at x))) tendsto_const_nhds
    (Eventually.of_forall fun n => hi n x y hxy)

/-- The finite zero-marginal value bound passes through the expected continuation value. -/
theorem continuation_increment_le_zeroMarginal
    (m : HouseholdPrimitives)
    (hfinite : utilityZeroRightMarginal m < ⊤)
    (hbetaR : m.beta * m.prices.grossReturn ≤ 1)
    {a b : Resources} (hab : a ≤ b) :
    continuation m (valueFunction m) b - continuation m (valueFunction m) a ≤
      (utilityZeroRightMarginal m).toReal * m.prices.grossReturn *
        ((b : ℝ) - (a : ℝ)) := by
  exact continuation_increment_le m (valueFunction m)
    (utilityZeroRightMarginal m).toReal
    (fun _ _ hxy => valueFunction_increment_le_zeroMarginal m hfinite hbetaR hxy) hab

end
end Aiyagari1994
