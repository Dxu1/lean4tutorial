import Lean4Tutorial.i003_replicate_aiyagari.PropertiesEquilibrium

/-!
# Aiyagari (1994): Properties 18--20

This file proves the balanced-growth comparison and the algebra behind the
government-debt and monetary interpretations.
-/

namespace Aiyagari1994

noncomputable section

/-- Property 18: the incomplete-markets balanced-growth return lies below the
complete-markets formula, while normalized variables have the stationary law
supplied by the source result. -/
theorem property18_balanced_growth_extension
    (β g γ rIM : ℝ) (NormalizedVariablesStationary : Prop)
    (hreturn : rIM < balancedGrowthReturn β g γ)
    (hstationary : NormalizedVariablesStationary) :
    rIM < (1 + timePreferenceRate β) * (1 + g) ^ γ - 1 ∧
      NormalizedVariablesStationary := by
  simpa [balancedGrowthReturn] using And.intro hreturn hstationary

/-- Translating gross assets by government debt removes the tax and debt terms
from the household budget resources. -/
theorem debt_budget_translation
    (w l r d aNet : ℝ) :
    debtBudgetResources w l r d (aNet + d) - d =
      w * l + (1 + r) * aNet := by
  unfold debtBudgetResources
  ring

/-- The gross-asset debt budget is equivalent to the same budget written in
assets net of government debt. -/
theorem debt_budget_iff_net_budget
    (c aNextNet w l r d aNet : ℝ) :
    c + (aNextNet + d) =
        debtBudgetResources w l r d (aNet + d) ↔
      c + aNextNet = w * l + (1 + r) * aNet := by
  unfold debtBudgetResources
  constructor <;> intro h <;> linarith

/-- With the tax-adjusted present-value floor, translating by debt produces
the debt-free natural borrowing floor. -/
theorem taxAdjusted_floor_iff_net_natural_floor
    {w lmin r d aNet : ℝ} (hr : 0 < r) :
    taxAdjustedAssetFloor w lmin r d ≤ aNet + d ↔
      -(naturalDebtLimit w lmin r) ≤ aNet := by
  have hr0 : r ≠ 0 := ne_of_gt hr
  have hid :
      taxAdjustedAssetFloor w lmin r d - d =
        -(naturalDebtLimit w lmin r) := by
    unfold taxAdjustedAssetFloor naturalDebtLimit
    field_simp [hr0]
    ring
  constructor <;> intro h <;> linarith

/-- A fixed borrowing floor does not remain invariant after netting out debt:
the displayed witness is feasible with debt one but infeasible with debt zero. -/
theorem fixed_floor_not_debt_neutral_witness :
    ∃ (b d₀ d₁ aNet : ℝ),
      (-b ≤ aNet + d₁) ∧ ¬(-b ≤ aNet + d₀) := by
  refine ⟨0, 0, 1, -(1 / 2 : ℝ), by norm_num, by norm_num⟩

/-- Property 19: the tax-adjusted present-value constraint is debt neutral
under `aNet = a-d`, whereas a fixed floor admits a counterexample. -/
theorem property19_debt_neutrality_depends_on_constraint
    (c aNextNet w l r d aNet : ℝ) (hr : 0 < r) :
    (c + (aNextNet + d) =
        debtBudgetResources w l r d (aNet + d) ↔
      c + aNextNet = w * l + (1 + r) * aNet) ∧
      (taxAdjustedAssetFloor w l r d ≤ aNet + d ↔
        -(naturalDebtLimit w l r) ≤ aNet) ∧
      netOfDebt (aNet + d) d = aNet ∧
      (∃ (b d₀ d₁ x : ℝ),
        (-b ≤ x + d₁) ∧ ¬(-b ≤ x + d₀)) := by
  refine ⟨debt_budget_iff_net_budget c aNextNet w l r d aNet,
    taxAdjusted_floor_iff_net_natural_floor hr, ?_,
    fixed_floor_not_debt_neutral_witness⟩
  simp [netOfDebt]

/-- The sharp price is positive under positive return, wage, and minimum labor. -/
theorem sharpPrice_pos
    {rSharp w lmin : ℝ}
    (hrSharp : 0 < rSharp) (hw : 0 < w) (hlmin : 0 < lmin) :
    0 < sharpPrice rSharp w lmin := by
  exact div_pos hrSharp (mul_pos hw hlmin)

/-- At the sharp price, real balances equal the present value of minimum
earnings. -/
theorem one_div_sharpPrice_eq_naturalLimit
    {rSharp w lmin : ℝ}
    (hrSharp : rSharp ≠ 0) (hw : w ≠ 0) (hlmin : lmin ≠ 0) :
    1 / sharpPrice rSharp w lmin =
      naturalDebtLimit w lmin rSharp := by
  unfold sharpPrice naturalDebtLimit
  field_simp [hrSharp, hw, hlmin]

/-- If `p < p#` and `r > r#`, the money nonnegativity constraint is looser
than the natural debt limit and hence does not bind. -/
theorem monetary_constraint_slack_above_sharp_return
    {rSharp r w lmin p : ℝ}
    (hrSharp : 0 < rSharp) (hr : rSharp < r)
    (hw : 0 < w) (hlmin : 0 < lmin)
    (hp : 0 < p) (hpBelow : p < sharpPrice rSharp w lmin) :
    naturalDebtLimit w lmin r < 1 / p ∧
      effectiveBorrowingLimit (1 / p) w lmin r =
        naturalDebtLimit w lmin r := by
  have hwl : 0 < w * lmin := mul_pos hw hlmin
  have hNat :
      naturalDebtLimit w lmin r <
        naturalDebtLimit w lmin rSharp := by
    unfold naturalDebtLimit
    exact div_lt_div_of_pos_left hwl hrSharp hr
  have hpSharp : 0 < sharpPrice rSharp w lmin :=
    sharpPrice_pos hrSharp hw hlmin
  have hRecip : 1 / sharpPrice rSharp w lmin < 1 / p :=
    one_div_lt_one_div_of_lt hp hpBelow
  have hSharpIdentity :
      1 / sharpPrice rSharp w lmin =
        naturalDebtLimit w lmin rSharp :=
    one_div_sharpPrice_eq_naturalLimit
      (ne_of_gt hrSharp) (ne_of_gt hw) (ne_of_gt hlmin)
  have hNaturalLt : naturalDebtLimit w lmin r < 1 / p := by
    rw [hSharpIdentity] at hRecip
    exact lt_trans hNat hRecip
  constructor
  · exact hNaturalLt
  · apply effectiveBorrowingLimit_eq_natural_of_slack (lt_trans hrSharp hr)
    exact le_of_lt hNaturalLt

/-- Property 20: below `p#`, the constraint is slack above `r#`; if natural-
limit asset supply is nonzero there, no monetary equilibrium can have a return
above `r#`. -/
theorem property20_monetary_return_upper_bound
    (meanAssets : ℝ → ℝ → ℝ) (naturalLimitAssets : ℝ → ℝ)
    {rSharp r w lmin p : ℝ}
    (hrSharp : 0 < rSharp) (hw : 0 < w) (hlmin : 0 < lmin)
    (hp : 0 < p) (hpBelow : p < sharpPrice rSharp w lmin)
    (hUnaffected : ∀ r' p', rSharp < r' →
      0 < p' → p' < sharpPrice rSharp w lmin →
      meanAssets r' p' = naturalLimitAssets r')
    (hNoZeroAbove : ∀ r', rSharp < r' → naturalLimitAssets r' ≠ 0)
    (hmonetary : MonetaryEquilibrium meanAssets r p) :
    r ≤ rSharp := by
  by_contra hnot
  have hr : rSharp < r := lt_of_not_ge hnot
  have _hslack := monetary_constraint_slack_above_sharp_return
    hrSharp hr hw hlmin hp hpBelow
  have hassets := hUnaffected r p hr hp hpBelow
  unfold MonetaryEquilibrium at hmonetary
  exact hNoZeroAbove r hr (by linarith)

end

end Aiyagari1994
