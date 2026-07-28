import Lean4Tutorial.i003_replicate_aiyagari.PropertiesEquilibrium

/-!
# Aiyagari (1994): growth, debt, and money
-/

open MeasureTheory

namespace Aiyagari1994

noncomputable section

def GrowsAtRate (x : ℕ → ℝ) (x0 g : ℝ) : Prop :=
  ∀ t, x t = x0 * (1 + g) ^ t

def normalizedPath (x : ℕ → ℝ) (g : ℝ) (t : ℕ) : ℝ :=
  x t / (1 + g) ^ t

lemma normalizedPath_eq
    {x : ℕ → ℝ} {x0 g : ℝ} (hg : 1 + g ≠ 0)
    (hx : GrowsAtRate x x0 g) (t : ℕ) :
    normalizedPath x g t = x0 := by
  rw [normalizedPath, hx t]
  field_simp

/-- Property 18: the return comparison follows from the strict balanced-growth
Euler wedge, while exact balanced-growth paths normalize to constants. -/
theorem property18_balanced_growth_extension
    (β g γ rIM : ℝ) (hβ : 0 < β) (hg : 1 + g ≠ 0)
    (hEulerWedge : β * (1 + rIM) < (1 + g) ^ γ)
    (earnings resources assets consumption : ℕ → ℝ)
    (e0 z0 a0 c0 : ℝ)
    (he : GrowsAtRate earnings e0 g)
    (hz : GrowsAtRate resources z0 g)
    (ha : GrowsAtRate assets a0 g)
    (hc : GrowsAtRate consumption c0 g) :
    rIM < balancedGrowthReturn β g γ ∧
      (∀ t, normalizedPath earnings g t = e0) ∧
      (∀ t, normalizedPath resources g t = z0) ∧
      (∀ t, normalizedPath assets g t = a0) ∧
      (∀ t, normalizedPath consumption g t = c0) := by
  have hβ0 : β ≠ 0 := ne_of_gt hβ
  have hid : 1 + timePreferenceRate β = 1 / β := by
    unfold timePreferenceRate
    field_simp [hβ0]
    ring
  have hreturn : rIM < balancedGrowthReturn β g γ := by
    unfold balancedGrowthReturn
    rw [hid]
    have hdiv : 1 + rIM < (1 + g) ^ γ / β := by
      apply (lt_div_iff₀ hβ).2
      nlinarith
    calc
      rIM < (1 + g) ^ γ / β - 1 := by linarith
      _ = 1 / β * (1 + g) ^ γ - 1 := by ring
  exact ⟨hreturn, normalizedPath_eq hg he, normalizedPath_eq hg hz,
    normalizedPath_eq hg ha, normalizedPath_eq hg hc⟩

theorem debt_budget_translation
    (w l r d aNet : ℝ) :
    debtBudgetResources w l r d (aNet + d) - d =
      w * l + (1 + r) * aNet := by
  unfold debtBudgetResources
  ring

theorem debt_budget_iff_net_budget
    (c aNextNet w l r d aNet : ℝ) :
    c + (aNextNet + d) =
        debtBudgetResources w l r d (aNet + d) ↔
      c + aNextNet = w * l + (1 + r) * aNet := by
  unfold debtBudgetResources
  constructor <;> intro h <;> linarith

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

def grossOfNet (d : ℝ) (aNet : ℕ → ℝ) (t : ℕ) : ℝ := aNet t + d

def netOfGross (d : ℝ) (a : ℕ → ℝ) (t : ℕ) : ℝ := a t - d

def DebtAdjustedFeasiblePath
    (w lmin r d : ℝ) (c a l : ℕ → ℝ) : Prop :=
  (∀ t, c t + a (t + 1) = debtBudgetResources w (l t) r d (a t)) ∧
    (∀ t, taxAdjustedAssetFloor w lmin r d ≤ a t)

def DebtFreeFeasiblePath
    (w lmin r : ℝ) (c aNet l : ℕ → ℝ) : Prop :=
  (∀ t, c t + aNet (t + 1) = w * l t + (1 + r) * aNet t) ∧
    (∀ t, -(naturalDebtLimit w lmin r) ≤ aNet t)

lemma debtAdjustedFeasible_iff_net
    {w lmin r d : ℝ} (hr : 0 < r)
    (c aNet l : ℕ → ℝ) :
    DebtAdjustedFeasiblePath w lmin r d c (grossOfNet d aNet) l ↔
      DebtFreeFeasiblePath w lmin r c aNet l := by
  constructor
  · rintro ⟨hbudget, hfloor⟩
    constructor
    · intro t
      exact (debt_budget_iff_net_budget
        (c t) (aNet (t + 1)) w (l t) r d (aNet t)).mp (hbudget t)
    · intro t
      exact (taxAdjusted_floor_iff_net_natural_floor hr).mp (hfloor t)
  · rintro ⟨hbudget, hfloor⟩
    constructor
    · intro t
      exact (debt_budget_iff_net_budget
        (c t) (aNet (t + 1)) w (l t) r d (aNet t)).mpr (hbudget t)
    · intro t
      exact (taxAdjusted_floor_iff_net_natural_floor hr).mpr (hfloor t)

lemma debtAdjustedConsumption_grossAssetOfShifted
    (φ d z ahat : ℝ) :
    debtAdjustedConsumption φ d z (grossAssetOfShifted φ d ahat) =
      z - ahat := by
  unfold debtAdjustedConsumption grossAssetOfShifted
  ring

lemma debtAdjustedResourceTransition_grossAssetOfShifted
    (M : HouseholdPrimitives) (φ d ahat l : ℝ) :
    debtAdjustedResourceTransition M φ d
        (grossAssetOfShifted φ d ahat) l =
      resourceTransition M φ ahat l := by
  unfold debtAdjustedResourceTransition grossAssetOfShifted
    debtBudgetResources resourceTransition totalResources
  ring

lemma debtAdjustedBellmanObjective_grossAssetOfShifted
    (M : HouseholdPrimitives) (φ d : ℝ) (V : ℝ → ℝ)
    (z ahat : ℝ) :
    debtAdjustedBellmanObjective M φ d V z
        (grossAssetOfShifted φ d ahat) =
      bellmanObjective M φ V z ahat := by
  unfold debtAdjustedBellmanObjective bellmanObjective expectedContinuation
  rw [debtAdjustedConsumption_grossAssetOfShifted]
  congr 2
  apply integral_congr_ae
  filter_upwards [] with l
  rw [debtAdjustedResourceTransition_grossAssetOfShifted]

/-- The actual gross-debt Bellman operator is exactly the debt-free operator
after the affine asset-coordinate change. -/
theorem debtAdjustedBellmanOperator_eq_bellmanOperator
    (M : HouseholdPrimitives) (φ d : ℝ) (V : ℝ → ℝ) :
    debtAdjustedBellmanOperator M φ d V = bellmanOperator M φ V := by
  funext z
  unfold debtAdjustedBellmanOperator bellmanOperator
  apply congrArg sSup
  ext y
  constructor
  · rintro ⟨g, hg, rfl⟩
    let ahat : ℝ := g + φ - d
    have hahat : ahat ∈ feasibleChoices z := by
      unfold ahat feasibleChoices debtAdjustedFeasibleChoices at *
      constructor <;> linarith [hg.1, hg.2]
    refine ⟨ahat, hahat, ?_⟩
    have hgross : grossAssetOfShifted φ d ahat = g := by
      unfold grossAssetOfShifted ahat
      ring
    rw [← hgross, debtAdjustedBellmanObjective_grossAssetOfShifted]
  · rintro ⟨ahat, hahat, rfl⟩
    refine ⟨grossAssetOfShifted φ d ahat, ?_,
      debtAdjustedBellmanObjective_grossAssetOfShifted M φ d V z ahat⟩
    unfold feasibleChoices debtAdjustedFeasibleChoices grossAssetOfShifted at *
    constructor <;> linarith [hahat.1, hahat.2]

theorem debtAdjustedBellmanFixedPoint_of_fixedPoint
    (M : HouseholdPrimitives) (φ d : ℝ) (V : ℝ → ℝ)
    (hV : IsBellmanFixedPoint M φ V) :
    IsDebtAdjustedBellmanFixedPoint M φ d V := by
  unfold IsDebtAdjustedBellmanFixedPoint
  rw [debtAdjustedBellmanOperator_eq_bellmanOperator]
  exact hV

/-- Bellman optimality is preserved by the affine change from shifted net
assets to gross government-debt assets.  This is the household-optimality
component missing from a mere pathwise budget identity. -/
theorem debtAdjustedPolicy_optimal_of_optimal
    (M : HouseholdPrimitives) (φ d : ℝ) (V A : ℝ → ℝ)
    (hA : IsOptimalPolicy M φ V A) :
    IsDebtAdjustedOptimalPolicy M φ d V
      (debtAdjustedAssetPolicy φ d A) := by
  intro z
  rcases hA z with ⟨hAFeasible, hAOptimal⟩
  constructor
  · constructor <;>
      simp only [debtAdjustedAssetPolicy, grossAssetOfShifted] <;> linarith [hAFeasible.1,
        hAFeasible.2]
  · intro g hg
    let ahat : ℝ := g + φ - d
    have hahat : ahat ∈ feasibleChoices z := by
      unfold ahat feasibleChoices debtAdjustedFeasibleChoices at *
      constructor <;> linarith [hg.1, hg.2]
    have hmax := hAOptimal ahat hahat
    have hgross : grossAssetOfShifted φ d ahat = g := by
      unfold grossAssetOfShifted ahat
      ring
    rw [← hgross,
      debtAdjustedBellmanObjective_grossAssetOfShifted,
      show debtAdjustedAssetPolicy φ d A z =
          grossAssetOfShifted φ d (A z) by rfl,
      debtAdjustedBellmanObjective_grossAssetOfShifted]
    exact hmax

lemma debtAdjustedResourceTransition_policy
    (M : HouseholdPrimitives) (φ d : ℝ) (A : ℝ → ℝ) (z l : ℝ) :
    debtAdjustedResourceTransition M φ d
        (debtAdjustedAssetPolicy φ d A z) l =
      resourceTransition M φ (A z) l := by
  exact debtAdjustedResourceTransition_grossAssetOfShifted M φ d (A z) l

/-- Translate a complete debt-free stationary equilibrium into the economy
with per-capita government debt `d`.  Household optimality is supplied by the
proved affine Bellman equivalence, not by a new behavioral assumption. -/
noncomputable def debtFreeToTaxAdjusted
    {M : HouseholdPrimitives} {φ d : ℝ}
    (E : DebtFreeStationaryEquilibrium M φ) :
    TaxAdjustedDebtStationaryEquilibrium M φ d := by
  letI := E.μ_probability
  have hconst : Integrable (fun _ : ℝ => d) E.μ := integrable_const d
  have hgross :
      Integrable (debtAdjustedAssetPolicy φ d E.household.A) E.μ := by
    rw [show debtAdjustedAssetPolicy φ d E.household.A =
        (fun z => E.household.A z - φ) + (fun _ => d) by
      funext z
      simp [debtAdjustedAssetPolicy, grossAssetOfShifted]]
    exact E.net_assets_integrable.add hconst
  have hclear :
      (∫ z, debtAdjustedAssetPolicy φ d E.household.A z ∂E.μ) = d := by
    rw [show debtAdjustedAssetPolicy φ d E.household.A =
        fun z => (E.household.A z - φ) + d by
      funext z
      rfl]
    rw [integral_add E.net_assets_integrable hconst,
      E.asset_market_clears]
    simp
  exact
    { household := E.household
      debt_value_solves :=
        debtAdjustedBellmanFixedPoint_of_fixedPoint M φ d
          E.household.V E.household.value_solves
      debt_policy_optimal :=
        debtAdjustedPolicy_optimal_of_optimal M φ d
          E.household.V E.household.A E.household.policy_optimal
      μ := E.μ
      μ_probability := E.μ_probability
      invariant_distribution := E.invariant_distribution
      gross_assets_integrable := hgross
      asset_market_clears := hclear }

/-- Remove government debt from a complete tax-adjusted equilibrium by
subtracting `d` from every gross asset holding. -/
noncomputable def taxAdjustedToDebtFree
    {M : HouseholdPrimitives} {φ d : ℝ}
    (E : TaxAdjustedDebtStationaryEquilibrium M φ d) :
    DebtFreeStationaryEquilibrium M φ := by
  letI := E.μ_probability
  have hconst : Integrable (fun _ : ℝ => d) E.μ := integrable_const d
  have hnet : Integrable (fun z => E.household.A z - φ) E.μ := by
    have hsub := E.gross_assets_integrable.sub hconst
    rw [show (fun z => E.household.A z - φ) =
        debtAdjustedAssetPolicy φ d E.household.A - (fun _ => d) by
      funext z
      simp [debtAdjustedAssetPolicy, grossAssetOfShifted]]
    exact hsub
  have hclear : (∫ z, E.household.A z - φ ∂E.μ) = 0 := by
    have hgross := E.asset_market_clears
    rw [show debtAdjustedAssetPolicy φ d E.household.A =
        fun z => (E.household.A z - φ) + d by
      funext z
      rfl,
      integral_add hnet hconst] at hgross
    simpa using sub_eq_zero.mp (sub_eq_zero.mpr hgross)
  exact
    { household := E.household
      μ := E.μ
      μ_probability := E.μ_probability
      invariant_distribution := E.invariant_distribution
      net_assets_integrable := hnet
      asset_market_clears := hclear }

lemma taxAdjustedToDebtFree_debtFreeToTaxAdjusted
    {M : HouseholdPrimitives} {φ d : ℝ}
    (E : DebtFreeStationaryEquilibrium M φ) :
    taxAdjustedToDebtFree (d := d) (debtFreeToTaxAdjusted E) = E := by
  cases E
  rfl

lemma debtFreeToTaxAdjusted_taxAdjustedToDebtFree
    {M : HouseholdPrimitives} {φ d : ℝ}
    (E : TaxAdjustedDebtStationaryEquilibrium M φ d) :
    debtFreeToTaxAdjusted (taxAdjustedToDebtFree E) = E := by
  cases E
  rfl

/-- Complete debt-adjusted and debt-free stationary equilibrium sets are
equivalent. -/
noncomputable def debtNeutralityEquiv
    (M : HouseholdPrimitives) (φ d : ℝ) :
    DebtFreeStationaryEquilibrium M φ ≃
      TaxAdjustedDebtStationaryEquilibrium M φ d where
  toFun := debtFreeToTaxAdjusted
  invFun := taxAdjustedToDebtFree
  left_inv := taxAdjustedToDebtFree_debtFreeToTaxAdjusted
  right_inv := debtFreeToTaxAdjusted_taxAdjustedToDebtFree

lemma taxAdjustedAssetFloor_eq_debt_sub_natural
    {w lmin r d : ℝ} (hr : 0 < r) :
    taxAdjustedAssetFloor w lmin r d =
      d - naturalDebtLimit w lmin r := by
  have hr0 : r ≠ 0 := ne_of_gt hr
  unfold taxAdjustedAssetFloor naturalDebtLimit
  field_simp [hr0]
  ring

theorem fixed_floor_not_debt_neutral_witness :
    ∃ (b d₀ d₁ aNet : ℝ),
      (-b ≤ aNet + d₁) ∧ ¬(-b ≤ aNet + d₀) := by
  refine ⟨0, 0, 1, -(1 / 2 : ℝ), by norm_num, by norm_num⟩

/-- Property 19: under the tax-adjusted natural floor, translation by
government debt is a bijection between complete stationary equilibrium sets.
The theorem also retains the pathwise budget equivalence and a certified
counterexample showing that an unadjusted fixed floor is not neutral. -/
theorem property19_debt_neutrality_depends_on_constraint
    (M : HouseholdPrimitives) (φ d : ℝ)
    (_hM : HouseholdAssumptions M)
    (hr : 0 < M.r)
    (hφ : φ = naturalDebtLimit M.w M.lmin M.r)
    (c aNet l : ℕ → ℝ) :
    Function.Bijective
        (debtFreeToTaxAdjusted (M := M) (φ := φ) (d := d)) ∧
      taxAdjustedAssetFloor M.w M.lmin M.r d = d - φ ∧
      (DebtAdjustedFeasiblePath M.w M.lmin M.r d c
          (grossOfNet d aNet) l ↔
        DebtFreeFeasiblePath M.w M.lmin M.r c aNet l) ∧
      (∀ t, netOfGross d (grossOfNet d aNet) t = aNet t) ∧
      (∃ (b d₀ d₁ x : ℝ),
        (-b ≤ x + d₁) ∧ ¬(-b ≤ x + d₀)) := by
  refine ⟨(debtNeutralityEquiv M φ d).bijective, ?_,
    debtAdjustedFeasible_iff_net hr c aNet l, ?_,
    fixed_floor_not_debt_neutral_witness⟩
  · rw [hφ]
    exact taxAdjustedAssetFloor_eq_debt_sub_natural hr
  intro t
  simp [netOfGross, grossOfNet]

theorem sharpPrice_pos
    {rSharp w lmin : ℝ}
    (hrSharp : 0 < rSharp) (hw : 0 < w) (hlmin : 0 < lmin) :
    0 < sharpPrice rSharp w lmin := by
  exact div_pos hrSharp (mul_pos hw hlmin)

theorem one_div_sharpPrice_eq_naturalLimit
    {rSharp w lmin : ℝ}
    (hrSharp : rSharp ≠ 0) (hw : w ≠ 0) (hlmin : lmin ≠ 0) :
    1 / sharpPrice rSharp w lmin = naturalDebtLimit w lmin rSharp := by
  unfold sharpPrice naturalDebtLimit
  field_simp [hrSharp, hw, hlmin]

theorem monetary_constraint_slack_above_sharp_return
    {rSharp r w lmin p : ℝ}
    (hrSharp : 0 < rSharp) (hr : rSharp < r)
    (hw : 0 < w) (hlmin : 0 < lmin)
    (hp : 0 < p) (hpBelow : p < sharpPrice rSharp w lmin) :
    naturalDebtLimit w lmin r < 1 / p ∧
      effectiveBorrowingLimit (1 / p) w lmin r = naturalDebtLimit w lmin r := by
  have hwl : 0 < w * lmin := mul_pos hw hlmin
  have hNat : naturalDebtLimit w lmin r < naturalDebtLimit w lmin rSharp := by
    unfold naturalDebtLimit
    exact div_lt_div_of_pos_left hwl hrSharp hr
  have hpSharp : 0 < sharpPrice rSharp w lmin :=
    sharpPrice_pos hrSharp hw hlmin
  have hRecip : 1 / sharpPrice rSharp w lmin < 1 / p :=
    one_div_lt_one_div_of_lt hp hpBelow
  have hSharpIdentity :
      1 / sharpPrice rSharp w lmin = naturalDebtLimit w lmin rSharp :=
    one_div_sharpPrice_eq_naturalLimit
      (ne_of_gt hrSharp) (ne_of_gt hw) (ne_of_gt hlmin)
  have hNaturalLt : naturalDebtLimit w lmin r < 1 / p := by
    rw [hSharpIdentity] at hRecip
    exact lt_trans hNat hRecip
  exact ⟨hNaturalLt,
    effectiveBorrowingLimit_eq_natural_of_slack (lt_trans hrSharp hr)
      (le_of_lt hNaturalLt)⟩

/-- Primitive environments agree except for the return and the bookkeeping
borrowing-limit field.  This prevents Property 20's return comparison from
silently changing preferences, wages, or the labor process. -/
def SameHouseholdEnvironmentExceptReturn
    (M₁ M₂ : HouseholdPrimitives) : Prop :=
  M₁.β = M₂.β ∧ M₁.w = M₂.w ∧ M₁.lmin = M₂.lmin ∧
    M₁.lmax = M₂.lmax ∧ M₁.utility = M₂.utility ∧
    M₁.laborLaw = M₂.laborLaw

/-- A monetary equilibrium built from the solved household policy and its
actual invariant probability law. -/
structure SolvedMonetaryStationaryEquilibrium
    (M : HouseholdPrimitives) where
  p : ℝ
  p_pos : 0 < p
  statutory_limit_matches : M.b = 1 / p
  stationary : SolvedStationaryHousehold M
    (effectiveBorrowingLimit (1 / p) M.w M.lmin M.r)
  asset_market_clears : stationary.meanAssets = 0

/-- A natural-limit stationary household whose net asset market clears at
zero.  This is the concrete meaning of a candidate sharp return. -/
structure NaturalLimitZeroAssetEquilibrium
    (M : HouseholdPrimitives) where
  stationary : SolvedStationaryHousehold M
    (naturalDebtLimit M.w M.lmin M.r)
  asset_market_clears : stationary.meanAssets = 0

/-- When the monetary limit is slack, uniqueness of the natural-limit
invariant law identifies both actual laws and therefore both policy integrals.
No arbitrary asset-supply schedule or representation hypothesis is used. -/
lemma monetaryMeanAssets_eq_natural_of_slack
    {M : HouseholdPrimitives}
    (E : SolvedMonetaryStationaryEquilibrium M)
    (N : SolvedStationaryHousehold M
      (naturalDebtLimit M.w M.lmin M.r))
    (hunique : N.UniqueInvariantLaw)
    (hslack : effectiveBorrowingLimit (1 / E.p) M.w M.lmin M.r =
      naturalDebtLimit M.w M.lmin M.r) :
    E.stationary.meanAssets = N.meanAssets := by
  exact SolvedStationaryHousehold.meanAssets_eq_of_limit_eq_unique
    E.stationary N hslack hunique

/-- Property 20: a monetary clearing return cannot exceed a natural-limit
zero-asset return when the concretely constructed natural-limit stationary
mean asset integral is strictly ordered between those two returns. -/
theorem property20_monetary_return_upper_bound
    (M MSharp : HouseholdPrimitives)
    (E : SolvedMonetaryStationaryEquilibrium M)
    (N : SolvedStationaryHousehold M
      (naturalDebtLimit M.w M.lmin M.r))
    (ESharp : NaturalLimitZeroAssetEquilibrium MSharp)
    (_hsame : SameHouseholdEnvironmentExceptReturn MSharp M)
    (hunique : N.UniqueInvariantLaw)
    (hpBelow : E.p < sharpPrice MSharp.r M.w M.lmin)
    (horder : MSharp.r < M.r →
      ESharp.stationary.meanAssets < N.meanAssets) :
    M.r ≤ MSharp.r := by
  by_contra hnot
  have hr : MSharp.r < M.r := lt_of_not_ge hnot
  have hMSharp := ESharp.stationary.hM
  have hM := E.stationary.hM
  have hslack := (monetary_constraint_slack_above_sharp_return
    hMSharp.r_pos hr hM.w_pos hM.lmin_pos E.p_pos hpBelow).2
  have hmean := monetaryMeanAssets_eq_natural_of_slack E N hunique hslack
  have hcurrentZero : N.meanAssets = 0 := by
    rw [← hmean]
    exact E.asset_market_clears
  have hlt := horder hr
  rw [ESharp.asset_market_clears, hcurrentZero] at hlt
  exact (lt_irrefl 0) hlt

end

end Aiyagari1994
