import Aiyagari1994.Analysis.M04C.DriftBounds

/-! D03: a locally uniform upper drift and common forward-invariant interval. -/
open Set
open scoped NNReal
namespace Aiyagari1994
noncomputable section

/-- D03. Uniform primitive bounds on a specified set of normalized prices produce one finite
upper resource bound. Above it the maximal next resource is weakly below the current state, and
each price-specific interval between minimum effective income and the common bound is forward
invariant. No finite-time entry claim is made. -/
theorem uniform_upper_drift (m : HouseholdPrimitives)
    (hs : UtilitySmooth m.utility) (hc : UtilityCurvature m.utility)
    (Q : Set (AdmissibleNormalizedPrices m.income))
    (Rmin Rmax gammaStar EStar DeltaStar : ℝ)
    (hRmin : 0 < Rmin) (hRmax : 0 < Rmax)
    (hgamma : gammaStar < 1) (hEStar : 0 ≤ EStar) (hDeltaStar : 0 ≤ DeltaStar)
    (hQ : ∀ q ∈ Q,
      Rmin ≤ q.grossReturn ∧ q.grossReturn ≤ Rmax ∧
      m.beta * q.grossReturn ≤ gammaStar ∧
      M04CIncomeUpper m q ≤ EStar ∧
      M04CIncomeUpper m q - M04CIncomeLower m q ≤ DeltaStar) :
    ∃ B : ℝ, 0 < B ∧ ∀ q ∈ Q,
      M04CIncomeUpper m q ≤ B ∧
      (∀ z : Resources, B ≤ (z : ℝ) →
        q.grossReturn * (assetPolicy (m.withPrices q) z : ℝ) +
          M04CIncomeUpper m q ≤ (z : ℝ)) ∧
      (∀ z : Resources, M04CIncomeLower m q ≤ (z : ℝ) → (z : ℝ) ≤ B →
        ∀ l : m.income.Labor,
          M04CIncomeLower m q ≤
              (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l : ℝ) ∧
            (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l : ℝ) ≤ B) := by
  obtain ⟨n, hn, C₀, hC₀, hratio⟩ := marginalUtility_ratio_bound m hs hc
  obtain ⟨C, hC₀C, hC, hfactor⟩ :=
    M04C_exists_consumption_buffer gammaStar DeltaStar C₀ n hgamma hDeltaStar
  let D : ℝ := utilityOscillation m / (1 - m.beta)
  let L : ℝ := D / deriv m.utility.utility C + 1
  have huC : 0 < deriv m.utility.utility C := hs.marginal_pos C hC
  have hD : 0 ≤ D := by
    have hb := utility_bounds m (0 : Resources)
    have hosc : 0 ≤ utilityOscillation m := by
      unfold utilityOscillation
      linarith
    exact div_nonneg hosc (sub_nonneg.mpr m.beta_lt_one.le)
  have hLpos : 0 < L := by
    dsimp [L]
    positivity
  have hL : utilityOscillation m / (1 - m.beta) /
      deriv m.utility.utility C < L := by
    dsimp [L, D]
    linarith
  let K : ℝ := (L + 1) / Rmin
  have hKpos : 0 < K := div_pos (by linarith) hRmin
  let B : ℝ := Rmax * K + EStar + 1
  have hBpos : 0 < B := by
    dsimp [B]
    positivity
  refine ⟨B, hBpos, ?_⟩
  intro q hq
  rcases hQ q hq with ⟨hqMin, hqMax, hqBeta, hqE, hqSpan⟩
  have hRK : L < q.grossReturn * K := by
    have hRKmin : Rmin * K = L + 1 := by
      dsimp [K]
      field_simp
    have hmul := mul_le_mul_of_nonneg_right hqMin hKpos.le
    nlinarith
  have hKB : q.grossReturn * K + M04CIncomeUpper m q ≤ B := by
    have hmul := mul_le_mul_of_nonneg_right hqMax hKpos.le
    dsimp [B]
    linarith
  have hdrift := M04C_upper_drift_at_price m q hs n C₀ C L K B gammaStar DeltaStar
    hratio hC₀C hC hgamma hDeltaStar hfactor hL q.property.1.1 hqBeta hKpos hRK hKB
    hBpos hqSpan
  refine ⟨hqE.trans (by dsimp [B]; linarith [mul_pos hRmax hKpos]), hdrift, ?_⟩
  intro z _hzLower hzUpper l
  let b : Resources := ⟨B, hBpos.le⟩
  have hzb : z ≤ b := by exact_mod_cast hzUpper
  have haMono : assetPolicy (m.withPrices q) z ≤ assetPolicy (m.withPrices q) b :=
    assetPolicy_monotone (m.withPrices q) hzb
  have hnextUpper :
      (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l : ℝ) ≤
        q.grossReturn * (assetPolicy (m.withPrices q) b : ℝ) +
          M04CIncomeUpper m q := by
    change q.grossReturn * (assetPolicy (m.withPrices q) z : ℝ) +
        q.toPrices.effectiveIncome l ≤ _
    have haReal : (assetPolicy (m.withPrices q) z : ℝ) ≤
        (assetPolicy (m.withPrices q) b : ℝ) := by exact_mod_cast haMono
    exact add_le_add (mul_le_mul_of_nonneg_left haReal q.property.1.1.le)
      (M04CIncome_between m q l).2
  have hbDrift := hdrift b (by rfl)
  have hnextLower : M04CIncomeLower m q ≤
      (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l : ℝ) := by
    change M04CIncomeLower m q ≤
      q.grossReturn * (assetPolicy (m.withPrices q) z : ℝ) + q.toPrices.effectiveIncome l
    exact (M04CIncome_between m q l).1.trans
      (le_add_of_nonneg_left (mul_nonneg q.property.1.1.le
        (assetPolicy (m.withPrices q) z).property))
  exact ⟨hnextLower, hnextUpper.trans hbDrift⟩

end
end Aiyagari1994
