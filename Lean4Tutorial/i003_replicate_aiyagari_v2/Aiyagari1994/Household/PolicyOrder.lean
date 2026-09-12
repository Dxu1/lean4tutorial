import Aiyagari1994.Household.Policy
import Aiyagari1994.Analysis.ConcaveReal

open Set
open scoped NNReal
namespace Aiyagari1994
noncomputable section

theorem assetPolicy_monotone (m : HouseholdPrimitives) : Monotone (assetPolicy m) := by
  intro z1 z2 hz
  by_contra hn
  have ha : assetPolicy m z2 < assetPolicy m z1 := lt_of_not_ge hn
  have hf1 := assetPolicy_le_state m z1
  have hf2 := assetPolicy_le_state m z2
  have hcross : assetPolicy m z2 ≤ z1 := ha.le.trans hf1
  have hcross2 : assetPolicy m z1 ≤ z2 := hf1.trans hz
  have h1 := assetPolicy_maximizes m z1 (assetPolicy m z2) hcross
  have h2 := assetPolicy_maximizes m z2 (assetPolicy m z1) hcross2
  rw [bellmanObjective_feasible _ _ _ _ hcross, bellmanObjective_feasible _ _ _ _ hf1] at h1
  rw [bellmanObjective_feasible _ _ _ _ hcross2, bellmanObjective_feasible _ _ _ _ hf2] at h2
  have hrz : (z1:ℝ) ≤ (z2:ℝ) := hz
  have hra : (assetPolicy m z2:ℝ) < (assetPolicy m z1:ℝ) := ha
  have hr1 : (assetPolicy m z1:ℝ) ≤ (z1:ℝ) := hf1
  have hu := concave_four_point m.utility_base.concave.concaveOn
    (x := (z1:ℝ)-(assetPolicy m z1:ℝ)) (y := (z2:ℝ)-(assetPolicy m z2:ℝ))
    (u := (z1:ℝ)-(assetPolicy m z2:ℝ)) (v := (z2:ℝ)-(assetPolicy m z1:ℝ))
    (by linarith) (by linarith) (by linarith) (by linarith) (by linarith) (by linarith) (by ring)
  have he : bellmanObjective m (valueFunction m) z1 (assetPolicy m z2) = valueFunction m z1 := by
    rw [← (assetPolicy_optimal m z1).2]
    rw [bellmanObjective_feasible _ _ _ _ hcross, bellmanObjective_feasible _ _ _ _ hf1]
    linarith
  have heq := assetOptimal_unique m z1 (assetPolicy m z2) (assetPolicy m z1)
    ⟨hcross,he⟩ (assetPolicy_optimal m z1)
  exact (ne_of_lt ha) heq

theorem consumptionPolicy_monotone (m : HouseholdPrimitives) : Monotone (consumptionPolicy m) := by
  intro z1 z2 hz
  by_contra hn
  have hc : consumptionPolicy m z2 < consumptionPolicy m z1 := lt_of_not_ge hn
  have hcz1 := consumptionPolicy_budget m z1
  have hcz2 := consumptionPolicy_budget m z2
  have hrz : (z1:ℝ) ≤ (z2:ℝ) := hz
  have hrc : (consumptionPolicy m z2:ℝ) < (consumptionPolicy m z1:ℝ) := hc
  have hb1 : (consumptionPolicy m z1:ℝ)+(assetPolicy m z1:ℝ)=(z1:ℝ) := by exact_mod_cast hcz1.2
  have hb2 : (consumptionPolicy m z2:ℝ)+(assetPolicy m z2:ℝ)=(z2:ℝ) := by exact_mod_cast hcz2.2
  let b1 : Resources := ⟨(z1:ℝ)-(consumptionPolicy m z2:ℝ), by
    have hnn : (0:ℝ) ≤ (assetPolicy m z1:ℝ) := (assetPolicy m z1).property
    linarith only [hnn,hb1,hrc,hrz]⟩
  let b2 : Resources := ⟨(z2:ℝ)-(consumptionPolicy m z1:ℝ), by
    have hnn : (0:ℝ) ≤ (assetPolicy m z1:ℝ) := (assetPolicy m z1).property
    linarith only [hnn,hb1,hrc,hrz]⟩
  have hb1c : (b1:ℝ)=(z1:ℝ)-(consumptionPolicy m z2:ℝ) := rfl
  have hb2c : (b2:ℝ)=(z2:ℝ)-(consumptionPolicy m z1:ℝ) := rfl
  have hb1f : b1 ≤ z1 := by change (b1:ℝ) ≤ (z1:ℝ); rw [hb1c]; exact sub_le_self _ (consumptionPolicy m z2).property
  have hb2f : b2 ≤ z2 := by change (b2:ℝ) ≤ (z2:ℝ); rw [hb2c]; exact sub_le_self _ (consumptionPolicy m z1).property
  have h1 := assetPolicy_maximizes m z1 b1 hb1f
  have h2 := assetPolicy_maximizes m z2 b2 hb2f
  rw [bellmanObjective_feasible _ _ _ _ hb1f,
    bellmanObjective_feasible _ _ _ _ (assetPolicy_le_state m z1)] at h1
  rw [bellmanObjective_feasible _ _ _ _ hb2f,
    bellmanObjective_feasible _ _ _ _ (assetPolicy_le_state m z2)] at h2
  have he1 : (z1:ℝ)-(b1:ℝ)=(consumptionPolicy m z2:ℝ) := by rw [hb1c]; ring
  have he2 : (z2:ℝ)-(b2:ℝ)=(consumptionPolicy m z1:ℝ) := by rw [hb2c]; ring
  rw [he1,← consumptionPolicy_coe m z1] at h1
  rw [he2,← consumptionPolicy_coe m z2] at h2
  have hg := concave_four_point
    (continuation_concave m (valueFunction m) (valueFunction_concave m)).extension
    (x := (assetPolicy m z1:ℝ)) (y := (assetPolicy m z2:ℝ))
    (u := (b1:ℝ)) (v := (b2:ℝ))
    (assetPolicy m z1).property (by linarith)
    (by linarith) (by linarith) (by linarith) (by linarith) (by linarith)
  simp only [nonnegativeExtension,Real.toNNReal_coe] at hg
  have hgb := mul_le_mul_of_nonneg_left hg m.beta_pos.le
  have he : bellmanObjective m (valueFunction m) z1 b1 = valueFunction m z1 := by
    rw [← (assetPolicy_optimal m z1).2]
    rw [bellmanObjective_feasible _ _ _ _ hb1f,
      bellmanObjective_feasible _ _ _ _ (assetPolicy_le_state m z1),he1,← consumptionPolicy_coe m z1]
    linarith
  have heq := assetOptimal_unique m z1 b1 (assetPolicy m z1) ⟨hb1f,he⟩ (assetPolicy_optimal m z1)
  have heqr : (b1:ℝ)=(assetPolicy m z1:ℝ) := congrArg NNReal.toReal heq
  linarith

/-- H07: both components are nondecreasing and have real difference bounds of one. -/
theorem policies_order_lipschitz (m : HouseholdPrimitives) :
    Monotone (assetPolicy m) ∧ Monotone (consumptionPolicy m) ∧
    (∀ z1 z2 : Resources, z1 ≤ z2 →
      (0 ≤ (assetPolicy m z2:ℝ)-(assetPolicy m z1:ℝ) ∧
        (assetPolicy m z2:ℝ)-(assetPolicy m z1:ℝ) ≤ (z2:ℝ)-(z1:ℝ)) ∧
      (0 ≤ (consumptionPolicy m z2:ℝ)-(consumptionPolicy m z1:ℝ) ∧
        (consumptionPolicy m z2:ℝ)-(consumptionPolicy m z1:ℝ) ≤ (z2:ℝ)-(z1:ℝ))) := by
  refine ⟨assetPolicy_monotone m,consumptionPolicy_monotone m,?_⟩
  intro z1 z2 hz
  have ha : (assetPolicy m z1:ℝ) ≤ (assetPolicy m z2:ℝ) := assetPolicy_monotone m hz
  have hc : (consumptionPolicy m z1:ℝ) ≤ (consumptionPolicy m z2:ℝ) := consumptionPolicy_monotone m hz
  have h1 := consumptionPolicy_coe m z1
  have h2 := consumptionPolicy_coe m z2
  constructor <;> constructor <;> linarith

end
end Aiyagari1994
