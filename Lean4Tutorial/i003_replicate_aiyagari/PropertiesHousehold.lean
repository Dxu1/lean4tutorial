import Lean4Tutorial.i003_replicate_aiyagari.Equilibrium
import Lean4Tutorial.i003_replicate_aiyagari.AiyagariBellman
import Lean4Tutorial.i003_replicate_aiyagari.StochasticPaths

/-!
# Aiyagari (1994): household properties

The results below use the concrete budget and Bellman objects.  No theorem
accepts either its conclusion or an imported "source theorem" as a hypothesis.
-/

open Filter MeasureTheory Set Topology

namespace Aiyagari1994

noncomputable section

def discountedShiftedAssets (a : ℕ → ℝ) (debt r : ℝ) (n : ℕ) : ℝ :=
  (a (n + 1) + debt) / (1 + r) ^ n

/-- Discounted excess labor income accumulated between dates `1` and `n`.
Subtracting this term from discounted shifted assets removes the positive
income innovations and leaves a sequence that falls only through consumption.
This is the analytic device needed for the forward half of Aiyagari's
Proposition 1 with genuinely stochastic labor income. -/
def discountedExcessIncomePartial
    (w lmin r : ℝ) (l : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.range n,
    w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1)

/-- Discounted shifted assets net of accumulated excess labor income. -/
def compensatedDiscountedAssets
    (a l : ℕ → ℝ) (w lmin r : ℝ) (n : ℕ) : ℝ :=
  discountedShiftedAssets a (naturalDebtLimit w lmin r) r n -
    discountedExcessIncomePartial w lmin r l n

/-- Tail of a deterministic path starting at date `t`. -/
def pathTail (x : ℕ → ℝ) (t n : ℕ) : ℝ := x (t + n)

/-- Present value, at date `t`, of labor income from date `t+1` onward. -/
def futureLaborPresentValueAfter
    (w r : ℝ) (l : ℕ → ℝ) (t : ℕ) : ℝ :=
  ∑' k : ℕ, w * l (t + k + 1) / (1 + r) ^ (k + 1)

/-- Present value, at the beginning of date `t`, of labor income from date
`t` onward.  The recursive form is convenient for the budget proof. -/
def futureLaborPresentValue
    (w r : ℝ) (l : ℕ → ℝ) (t : ℕ) : ℝ :=
  (w * l t + futureLaborPresentValueAfter w r l t) / (1 + r)

/-- A deterministic upper bound for discounted income after the first `n`
future dates. -/
def maximumDiscountedIncomeTail
    (w lmax r : ℝ) (n : ℕ) : ℝ :=
  ∑' k : ℕ, w * lmax / (1 + r) ^ (k + n + 1)

lemma constant_discounted_income_tsum
    {w l r : ℝ} (hr : 0 < r) :
    (∑' k : ℕ, w * l / (1 + r) ^ (k + 1)) =
      naturalDebtLimit w l r := by
  let q : ℝ := (1 + r)⁻¹
  have hq0 : 0 ≤ q := by
    dsimp [q]
    positivity
  have hq1 : q < 1 := by
    dsimp [q]
    exact inv_lt_one_of_one_lt₀ (by linarith)
  calc
    (∑' k : ℕ, w * l / (1 + r) ^ (k + 1)) =
        ∑' k : ℕ, (w * l * q) * q ^ k := by
          congr 1
          funext k
          simp [q, div_eq_mul_inv, inv_pow, pow_succ]
          ring
    _ = (w * l * q) * ∑' k : ℕ, q ^ k := by rw [tsum_mul_left]
    _ = (w * l * q) * (1 - q)⁻¹ := by
      rw [tsum_geometric_of_lt_one hq0 hq1]
    _ = naturalDebtLimit w l r := by
      dsimp [q]
      unfold naturalDebtLimit
      field_simp [ne_of_gt hr, show 1 + r ≠ 0 by linarith]
      ring

lemma maximumDiscountedIncomeTail_tendsto_zero
    (w lmax r : ℝ) :
    Tendsto (maximumDiscountedIncomeTail w lmax r) atTop (𝓝 0) := by
  have htail := _root_.tendsto_sum_nat_add
    (f := fun j : ℕ => w * lmax / (1 + r) ^ (j + 1))
  apply htail.congr'
  filter_upwards [] with n
  unfold maximumDiscountedIncomeTail
  congr 1

lemma feasiblePath_pathTail
    {a c l : ℕ → ℝ} {w r : ℝ}
    (h : FeasiblePath w r a c l) (t : ℕ) :
    FeasiblePath w r (pathTail a t) (pathTail c t) (pathTail l t) := by
  intro n
  simpa [pathTail, Nat.add_assoc] using h (t + n)

lemma noPonzi_pathTail
    {a : ℕ → ℝ} {r : ℝ} (hr : 0 < r)
    (h : NoPonzi a r) (t : ℕ) :
    NoPonzi (pathTail a t) r := by
  rcases h with ⟨L, hL, hlim⟩
  let R : ℝ := 1 + r
  refine ⟨R ^ t * L, mul_nonneg (pow_nonneg (by linarith) _) hL, ?_⟩
  have htail := hlim.comp (tendsto_add_atTop_nat t)
  have hscaled := (tendsto_const_nhds.mul htail :
    Tendsto (fun n : ℕ => R ^ t *
      (a ((n + t) + 1) / R ^ (n + t))) atTop (𝓝 (R ^ t * L)))
  convert hscaled using 1
  funext n
  dsimp [pathTail, R]
  have hR0 : (1 + r) ≠ 0 := by linarith
  rw [pow_add]
  field_simp [pow_ne_zero _ hR0]
  ring

lemma stochastic_shifted_budget
    {a c l : ℕ → ℝ} {w lmin r : ℝ}
    (hr : r ≠ 0) (hfeas : FeasiblePath w r a c l) (t : ℕ) :
    c t + (a (t + 1) + naturalDebtLimit w lmin r) =
      (1 + r) * (a t + naturalDebtLimit w lmin r) +
        w * (l t - lmin) := by
  have hbudget := (hfeas t).2
  have hdebt : r * naturalDebtLimit w lmin r = w * lmin := by
    unfold naturalDebtLimit
    field_simp [hr]
  nlinarith

lemma compensatedDiscountedAssets_antitone
    {a c l : ℕ → ℝ} {w lmin r : ℝ}
    (hr : 0 < r) (hfeas : FeasiblePath w r a c l) :
    Antitone (compensatedDiscountedAssets a l w lmin r) := by
  have hR : 0 < 1 + r := by linarith
  apply antitone_nat_of_succ_le
  intro n
  have hbudget := stochastic_shifted_budget (lmin := lmin)
    (ne_of_gt hr) hfeas (n + 1)
  have hc := (hfeas (n + 1)).1
  have hpow : 0 < (1 + r) ^ (n + 1) := pow_pos hR _
  unfold compensatedDiscountedAssets discountedShiftedAssets
    discountedExcessIncomePartial
  rw [Finset.sum_range_succ, pow_succ]
  have hstep :
      (a (n + 2) + naturalDebtLimit w lmin r) / (1 + r) ^ (n + 1) ≤
        (a (n + 1) + naturalDebtLimit w lmin r) / (1 + r) ^ n +
          w * (l (n + 1) - lmin) / (1 + r) ^ (n + 1) := by
    apply (div_le_iff₀ hpow).2
    rw [pow_succ]
    field_simp [ne_of_gt hR]
    nlinarith
  have hstep' :
      (a (n + 2) + naturalDebtLimit w lmin r) /
          ((1 + r) ^ n * (1 + r)) ≤
        (a (n + 1) + naturalDebtLimit w lmin r) / (1 + r) ^ n +
          w * (l (n + 1) - lmin) / ((1 + r) ^ n * (1 + r)) := by
    simpa [pow_succ] using hstep
  calc
    (a (n + 1 + 1) + naturalDebtLimit w lmin r) /
          ((1 + r) ^ n * (1 + r)) -
        (∑ k ∈ Finset.range n,
          w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1) +
          w * (l (n + 1) - lmin) / ((1 + r) ^ n * (1 + r)))
        ≤ ((a (n + 1) + naturalDebtLimit w lmin r) / (1 + r) ^ n +
            w * (l (n + 1) - lmin) / ((1 + r) ^ n * (1 + r))) -
          (∑ k ∈ Finset.range n,
            w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1) +
            w * (l (n + 1) - lmin) / ((1 + r) ^ n * (1 + r))) := by
            apply sub_le_sub_right
            simpa only [show n + 1 + 1 = n + 2 by omega] using hstep'
    _ = (a (n + 1) + naturalDebtLimit w lmin r) / (1 + r) ^ n -
          ∑ k ∈ Finset.range n,
            w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1) := by ring

lemma discounted_excess_income_summable
    {l : ℕ → ℝ} {w lmin lmax r : ℝ}
    (hr : 0 < r) (hw : 0 ≤ w)
    (hl : ∀ t, l t ∈ Icc lmin lmax) :
    Summable (fun k : ℕ =>
      w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1)) := by
  let q : ℝ := (1 + r)⁻¹
  let C : ℝ := w * (lmax - lmin)
  have hR : 1 < 1 + r := by linarith
  have hq0 : 0 ≤ q := by
    dsimp [q]
    positivity
  have hq1 : q < 1 := by
    dsimp [q]
    exact inv_lt_one_of_one_lt₀ hR
  have hqnorm : ‖q‖ < 1 := by simpa [Real.norm_eq_abs, abs_of_nonneg hq0]
  have hgeom : Summable (fun k : ℕ => C * q ^ (k + 1)) := by
    have hbase : Summable (fun k : ℕ => q ^ k) :=
      (summable_geometric_iff_norm_lt_one).2 hqnorm
    have hscaled := hbase.mul_left (C * q)
    simpa [pow_succ, mul_assoc, mul_left_comm, mul_comm] using hscaled
  apply hgeom.of_norm_bounded
  intro k
  have hgap0 : 0 ≤ l (k + 1) - lmin := sub_nonneg.mpr (hl (k + 1)).1
  have hgap : l (k + 1) - lmin ≤ lmax - lmin := by
    linarith [(hl (k + 1)).2]
  have hpow0 : 0 ≤ q ^ (k + 1) := pow_nonneg hq0 _
  have hterm0 :
      0 ≤ w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1) := by
    positivity
  rw [Real.norm_eq_abs, abs_of_nonneg hterm0]
  have hreform :
      w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1) =
        w * (l (k + 1) - lmin) * q ^ (k + 1) := by
    simp [q, div_eq_mul_inv, inv_pow]
  rw [hreform]
  dsimp [C]
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left hgap hw) hpow0

lemma futureLaborPresentValueAfter_summable
    {l : ℕ → ℝ} {w lmax r : ℝ}
    (hr : 0 < r) (hw : 0 ≤ w)
    (hl : ∀ t, l t ∈ Icc 0 lmax) (t : ℕ) :
    Summable (fun k : ℕ =>
      w * l (t + k + 1) / (1 + r) ^ (k + 1)) := by
  have htail : ∀ k, pathTail l t k ∈ Icc (0 : ℝ) lmax := by
    intro k
    exact hl (t + k)
  simpa [pathTail, Nat.add_assoc] using
    (discounted_excess_income_summable
      (l := pathTail l t) hr hw htail)

/-- A finite low-income block bounds the present value of all income after
the current date by the constant-low-income value plus a geometric tail. -/
lemma futureLaborPresentValueAfter_le_of_low_block
    {l : ℕ → ℝ} {w low lmax r : ℝ} {t n : ℕ}
    (hr : 0 < r) (hw : 0 ≤ w) (hlow : 0 ≤ low)
    (hl : ∀ s, l s ∈ Icc 0 lmax)
    (hblock : ∀ j, j ≤ n → l (t + j) ≤ low) :
    futureLaborPresentValueAfter w r l t ≤
      naturalDebtLimit w low r + maximumDiscountedIncomeTail w lmax r n := by
  let f : ℕ → ℝ := fun k =>
    w * l (t + k + 1) / (1 + r) ^ (k + 1)
  let g : ℕ → ℝ := fun k =>
    w * low / (1 + r) ^ (k + 1)
  let h : ℕ → ℝ := fun k =>
    w * lmax / (1 + r) ^ (k + 1)
  have hf : Summable f := by
    simpa [f] using futureLaborPresentValueAfter_summable hr hw hl t
  have hg : Summable g := by
    have hconst : ∀ s, (fun _ : ℕ => low) s ∈ Icc (0 : ℝ) low := by
      intro s
      exact ⟨hlow, le_rfl⟩
    simpa [g] using
      (futureLaborPresentValueAfter_summable
        (l := fun _ : ℕ => low) hr hw hconst 0)
  have hh : Summable h := by
    have hmax0 : 0 ≤ lmax := (hl 0).1.trans (hl 0).2
    have hconst : ∀ s, (fun _ : ℕ => lmax) s ∈ Icc (0 : ℝ) lmax := by
      intro s
      exact ⟨hmax0, le_rfl⟩
    simpa [h] using
      (futureLaborPresentValueAfter_summable
        (l := fun _ : ℕ => lmax) hr hw hconst 0)
  have hfinite : ∑ k ∈ Finset.range n, f k ≤
      ∑ k ∈ Finset.range n, g k := by
    apply Finset.sum_le_sum
    intro k hk
    have hklt : k < n := Finset.mem_range.mp hk
    have hlk : l (t + k + 1) ≤ low := by
      apply hblock (k + 1)
      omega
    have hpow : 0 ≤ (1 + r) ^ (k + 1) :=
      pow_nonneg (by linarith) _
    dsimp [f, g]
    exact div_le_div_of_nonneg_right
      (mul_le_mul_of_nonneg_left hlk hw) hpow
  have htail : (∑' k : ℕ, f (k + n)) ≤ ∑' k : ℕ, h (k + n) := by
    apply ((summable_nat_add_iff n).2 hf).tsum_le_tsum
    · intro k
      have hlk := (hl (t + (k + n) + 1)).2
      have hpow : 0 ≤ (1 + r) ^ (k + n + 1) :=
        pow_nonneg (by linarith) _
      dsimp [f, h]
      exact div_le_div_of_nonneg_right
        (mul_le_mul_of_nonneg_left hlk hw) hpow
    · exact (summable_nat_add_iff n).2 hh
  calc
    futureLaborPresentValueAfter w r l t =
        ∑ k ∈ Finset.range n, f k + ∑' k : ℕ, f (k + n) := by
          rw [hf.sum_add_tsum_nat_add n]
          rfl
    _ ≤ ∑ k ∈ Finset.range n, g k + ∑' k : ℕ, h (k + n) :=
      add_le_add hfinite htail
    _ ≤ (∑' k : ℕ, g k) + ∑' k : ℕ, h (k + n) := by
      exact add_le_add_left
        (hg.sum_le_tsum (Finset.range n) (fun k hk => by
          dsimp [g]
          positivity)) _
    _ = naturalDebtLimit w low r +
        maximumDiscountedIncomeTail w lmax r n := by
      rw [constant_discounted_income_tsum hr]
      rfl

/-- Including current labor income, a low block through date `t+n` makes
realized human wealth no more than the natural limit computed at the block's
income ceiling plus the remaining geometric tail. -/
lemma futureLaborPresentValue_le_of_low_block
    {l : ℕ → ℝ} {w low lmax r : ℝ} {t n : ℕ}
    (hr : 0 < r) (hw : 0 ≤ w) (hlow : 0 ≤ low)
    (hl : ∀ s, l s ∈ Icc 0 lmax)
    (hblock : ∀ j, j ≤ n → l (t + j) ≤ low) :
    futureLaborPresentValue w r l t ≤
      naturalDebtLimit w low r +
        maximumDiscountedIncomeTail w lmax r n / (1 + r) := by
  have hafter := futureLaborPresentValueAfter_le_of_low_block
    hr hw hlow hl hblock
  have hcurrent := hblock 0 (Nat.zero_le n)
  have hR : 0 < 1 + r := by linarith
  have hdebt : w * low + naturalDebtLimit w low r =
      (1 + r) * naturalDebtLimit w low r := by
    unfold naturalDebtLimit
    field_simp [ne_of_gt hr]
    ring
  unfold futureLaborPresentValue
  apply (div_le_iff₀ hR).2
  calc
    w * l t + futureLaborPresentValueAfter w r l t ≤
        w * low +
          (naturalDebtLimit w low r +
            maximumDiscountedIncomeTail w lmax r n) := by
      have hcurrent' : w * l t ≤ w * low := by
        exact mul_le_mul_of_nonneg_left (by simpa using hcurrent) hw
      exact add_le_add hcurrent' hafter
    _ = (naturalDebtLimit w low r +
          maximumDiscountedIncomeTail w lmax r n / (1 + r)) *
          (1 + r) := by
      field_simp [ne_of_gt hR]
      nlinarith [hdebt]

/-- A no-Ponzi feasible path cannot choose next-period assets below the
negative present value of all subsequent realized labor income. -/
lemma nextAsset_ge_neg_futureLaborPresentValueAfter
    {a c l : ℕ → ℝ} {w lmax r : ℝ}
    (hr : 0 < r) (hw : 0 ≤ w)
    (hfeas : FeasiblePath w r a c l)
    (hl : ∀ t, l t ∈ Icc 0 lmax)
    (hnp : NoPonzi a r) (t : ℕ) :
    -futureLaborPresentValueAfter w r l t ≤ a (t + 1) := by
  let atail := pathTail a t
  let ctail := pathTail c t
  let ltail := pathTail l t
  let incomeTerm : ℕ → ℝ := fun k =>
    w * ltail (k + 1) / (1 + r) ^ (k + 1)
  let incomePartial : ℕ → ℝ := fun n =>
    discountedExcessIncomePartial w 0 r ltail n
  let discounted : ℕ → ℝ := fun n =>
    discountedShiftedAssets atail 0 r n
  let compensated : ℕ → ℝ := fun n =>
    compensatedDiscountedAssets atail ltail w 0 r n
  have htailFeas : FeasiblePath w r atail ctail ltail := by
    simpa [atail, ctail, ltail] using feasiblePath_pathTail hfeas t
  have htailSupport : ∀ k, ltail k ∈ Icc (0 : ℝ) lmax := by
    intro k
    exact hl (t + k)
  have hincome : Summable incomeTerm := by
    simpa [incomeTerm, ltail, pathTail, Nat.add_assoc] using
      futureLaborPresentValueAfter_summable hr hw hl t
  have hincome_tendsto : Tendsto incomePartial atTop
      (𝓝 (futureLaborPresentValueAfter w r l t)) := by
    have h := hincome.hasSum.tendsto_sum_nat
    simpa [incomePartial, discountedExcessIncomePartial, incomeTerm,
      futureLaborPresentValueAfter, ltail, pathTail, Nat.add_assoc] using h
  rcases noPonzi_pathTail hr hnp t with ⟨L, hL, hdiscounted⟩
  have hdiscounted' : Tendsto discounted atTop (𝓝 L) := by
    simpa [discounted, atail, discountedShiftedAssets,
      naturalDebtLimit] using hdiscounted
  have hcomp_tendsto : Tendsto compensated atTop
      (𝓝 (L - futureLaborPresentValueAfter w r l t)) := by
    have hsub := hdiscounted'.sub hincome_tendsto
    have hidentity : compensated = fun n => discounted n - incomePartial n := by
      funext n
      simp [compensated, compensatedDiscountedAssets, discounted,
        incomePartial, naturalDebtLimit]
    rw [hidentity]
    simpa using hsub
  have hanti : Antitone compensated := by
    simpa [compensated, atail, ltail] using
      (compensatedDiscountedAssets_antitone hr htailFeas)
  have hlimit_le :
      L - futureLaborPresentValueAfter w r l t ≤ compensated 0 :=
    hanti.le_of_tendsto hcomp_tendsto 0
  have hzero : compensated 0 = a (t + 1) := by
    simp [compensated, compensatedDiscountedAssets,
      discountedShiftedAssets, discountedExcessIncomePartial,
      atail, ltail, pathTail, naturalDebtLimit]
  rw [hzero] at hlimit_le
  linarith

/-- Pathwise present-value solvency inequality implied by feasibility and the
no-Ponzi condition. -/
theorem noPonzi_implies_realized_presentValue_bound
    {a c l : ℕ → ℝ} {w lmax r : ℝ}
    (hr : 0 < r) (hw : 0 ≤ w)
    (hfeas : FeasiblePath w r a c l)
    (hl : ∀ t, l t ∈ Icc 0 lmax)
    (hnp : NoPonzi a r) (t : ℕ) :
    -futureLaborPresentValue w r l t ≤ a t := by
  have hnext := nextAsset_ge_neg_futureLaborPresentValueAfter
    hr hw hfeas hl hnp t
  have hbudget := (hfeas t).2
  have hc := (hfeas t).1
  unfold futureLaborPresentValue
  have hR : 0 < 1 + r := by linarith
  have hrewrite :
      -((w * l t + futureLaborPresentValueAfter w r l t) / (1 + r)) =
        (-(w * l t + futureLaborPresentValueAfter w r l t)) / (1 + r) := by
    ring
  rw [hrewrite]
  apply (div_le_iff₀ hR).2
  nlinarith

/-- The forward half of Property 1 for an arbitrary bounded labor history.
The proof does not replace labor by its minimum.  Instead it subtracts the
summable stream of discounted excess labor income, obtaining an antitone
sequence bounded below by the natural debt restriction. -/
theorem naturalDebtBound_implies_noPonzi_of_bounded_labor
    {a c l : ℕ → ℝ} {w lmin lmax r : ℝ}
    (hr : 0 < r) (hw : 0 ≤ w)
    (hfeas : FeasiblePath w r a c l)
    (hl : ∀ t, l t ∈ Icc lmin lmax)
    (hbound : NaturalDebtBound a w lmin r) :
    NoPonzi a r := by
  let incomeTerm : ℕ → ℝ := fun k =>
    w * (l (k + 1) - lmin) / (1 + r) ^ (k + 1)
  let incomePartial : ℕ → ℝ := fun n =>
    discountedExcessIncomePartial w lmin r l n
  let shifted : ℕ → ℝ := fun n =>
    discountedShiftedAssets a (naturalDebtLimit w lmin r) r n
  let compensated : ℕ → ℝ := fun n =>
    compensatedDiscountedAssets a l w lmin r n
  have hincome : Summable incomeTerm := by
    simpa [incomeTerm] using
      (discounted_excess_income_summable hr hw hl)
  have hincome_tendsto :
      Tendsto incomePartial atTop (𝓝 (∑' k, incomeTerm k)) := by
    simpa [incomePartial, discountedExcessIncomePartial, incomeTerm] using
      hincome.hasSum.tendsto_sum_nat
  have hcomp_anti : Antitone compensated := by
    simpa [compensated] using
      (compensatedDiscountedAssets_antitone hr hfeas)
  have hshift_nonneg : ∀ n, 0 ≤ shifted n := by
    intro n
    have hnum : 0 ≤ a (n + 1) + naturalDebtLimit w lmin r := by
      linarith [hbound (n + 1)]
    exact div_nonneg hnum (pow_nonneg (by linarith : 0 ≤ 1 + r) _)
  obtain ⟨B, hB⟩ := hincome_tendsto.bddAbove_range
  have hcomp_bdd : BddBelow (Set.range compensated) := by
    refine ⟨-B, ?_⟩
    rintro _ ⟨n, rfl⟩
    have hpartial : incomePartial n ≤ B := hB ⟨n, rfl⟩
    have hidentity : compensated n = shifted n - incomePartial n := by
      rfl
    rw [hidentity]
    linarith [hshift_nonneg n]
  let Lcomp : ℝ := ⨅ n, compensated n
  have hcomp_tendsto : Tendsto compensated atTop (𝓝 Lcomp) :=
    tendsto_atTop_ciInf hcomp_anti hcomp_bdd
  let L : ℝ := Lcomp + ∑' k, incomeTerm k
  have hshift_tendsto : Tendsto shifted atTop (𝓝 L) := by
    have hadd := hcomp_tendsto.add hincome_tendsto
    have hidentity : shifted = fun n => compensated n + incomePartial n := by
      funext n
      dsimp [shifted, compensated, incomePartial]
      unfold compensatedDiscountedAssets
      ring
    rw [hidentity]
    simpa [L] using hadd
  have hL : 0 ≤ L := ge_of_tendsto' hshift_tendsto hshift_nonneg
  refine ⟨L, hL, ?_⟩
  have hdebt : Tendsto
      (fun n : ℕ => naturalDebtLimit w lmin r / (1 + r) ^ n)
      atTop (𝓝 0) := by
    have hR : 1 < 1 + r := by linarith
    have hpow := tendsto_pow_const_div_const_pow_of_one_lt 0 hR
    have hconst : Tendsto (fun _ : ℕ => naturalDebtLimit w lmin r) atTop
        (𝓝 (naturalDebtLimit w lmin r)) := tendsto_const_nhds
    simpa [div_eq_mul_inv] using hconst.mul hpow
  have hsub := hshift_tendsto.sub hdebt
  have hidentity :
      (fun n => a (n + 1) / (1 + r) ^ n) =
        fun n => shifted n - naturalDebtLimit w lmin r / (1 + r) ^ n := by
    funext n
    dsimp [shifted, discountedShiftedAssets]
    ring
  rw [hidentity]
  simpa using hsub

/-- Almost-sure forward implication on the canonical i.i.d. history space.
All countably many budget and support conditions are first placed on one
full-measure event, after which the preceding pathwise theorem applies. -/
theorem canonical_naturalDebtBound_implies_noPonzi_ae
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (P : CanonicalIIDPlan M)
    (hbound : NaturalDebtBoundAE (laborHistoryMeasure M) P.assets
      M.w M.lmin M.r) :
    NoPonziAE (laborHistoryMeasure M) P.assets M.r := by
  have hfeasibleAll : ∀ᵐ ω ∂laborHistoryMeasure M, ∀ t,
      0 ≤ P.consumption t ω ∧
        P.consumption t ω + P.assets (t + 1) ω =
          M.w * canonicalLabor t ω + (1 + M.r) * P.assets t ω :=
    ae_all_iff.mpr P.feasible
  have hsupportAll : ∀ᵐ ω ∂laborHistoryMeasure M, ∀ t,
      canonicalLabor t ω ∈ Icc M.lmin M.lmax :=
    ae_all_iff.mpr (canonicalLabor_mem_support_ae M hM)
  have hboundAll : ∀ᵐ ω ∂laborHistoryMeasure M, ∀ t,
      -(naturalDebtLimit M.w M.lmin M.r) ≤ P.assets t ω :=
    ae_all_iff.mpr hbound
  filter_upwards [hfeasibleAll, hsupportAll, hboundAll] with ω hfeas hsupp hbnd
  exact naturalDebtBound_implies_noPonzi_of_bounded_labor
    (a := fun t => P.assets t ω)
    (c := fun t => P.consumption t ω)
    (l := fun t => canonicalLabor t ω)
    hM.r_pos hM.w_pos.le hfeas hsupp hbnd

/-- A positive-measure strict sublevel contains a positive-measure sublevel
separated from the threshold by a reciprocal-integer margin. -/
lemma exists_positive_margin_of_measure_lt_pos
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}
    {X : Ω → ℝ} {x : ℝ}
    (hpos : 0 < μ {ω | X ω < x}) :
    ∃ n : ℕ, 0 < μ {ω | X ω < x - 1 / (n + 1 : ℝ)} := by
  have hunion :
      (⋃ n : ℕ, {ω | X ω < x - 1 / (n + 1 : ℝ)}) =
        {ω | X ω < x} := by
    ext ω
    simp only [mem_iUnion, mem_setOf_eq]
    constructor
    · rintro ⟨n, hn⟩
      have hden : 0 < (n + 1 : ℝ) := by positivity
      have hinv : 0 < 1 / (n + 1 : ℝ) := one_div_pos.mpr hden
      linarith
    · intro hω
      obtain ⟨n, hn⟩ := exists_nat_one_div_lt (sub_pos.mpr hω)
      refine ⟨n, ?_⟩
      linarith
  apply exists_measure_pos_of_not_measure_iUnion_null
  rw [hunion]
  exact ne_of_gt hpos

/-- Quantitative reachability lemma for Property 1.  A sufficiently long
finite block near the lower support endpoint makes realized human wealth
strictly less than the natural limit plus any prescribed margin. -/
lemma exists_low_block_for_presentValue_margin
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    {t : ℕ} {δ : ℝ} (hδ : 0 < δ) :
    ∃ n : ℕ, ∃ ε : ℝ, 0 < ε ∧
      ∀ ω ∈ lowerLaborBlock M t n ε,
        (∀ s, canonicalLabor s ω ∈ Icc M.lmin M.lmax) →
        futureLaborPresentValue M.w M.r (fun s => canonicalLabor s ω) t <
          naturalDebtLimit M.w M.lmin M.r + δ := by
  let ε : ℝ := δ * M.r / (4 * M.w)
  have hε : 0 < ε := by
    dsimp [ε]
    exact div_pos (mul_pos hδ hM.r_pos) (mul_pos (by norm_num) hM.w_pos)
  have htailLim := maximumDiscountedIncomeTail_tendsto_zero
    M.w M.lmax M.r
  have htarget : 0 < δ * (1 + M.r) / 2 := by
    exact div_pos (mul_pos hδ (by linarith [hM.r_pos])) (by norm_num)
  obtain ⟨n, hn⟩ := ((tendsto_order.1 htailLim).2
    (δ * (1 + M.r) / 2) htarget).exists
  refine ⟨n, ε, hε, ?_⟩
  intro ω hblock hsupp
  have hsupp0 : ∀ s, canonicalLabor s ω ∈ Icc (0 : ℝ) M.lmax := by
    intro s
    exact ⟨hM.lmin_pos.le.trans (hsupp s).1, (hsupp s).2⟩
  have hblock' : ∀ j, j ≤ n → canonicalLabor (t + j) ω ≤ M.lmin + ε := by
    intro j hj
    have hij : t + j ∈ Finset.Icc t (t + n) := by
      apply Finset.mem_Icc.mpr
      omega
    have hmem := hblock (t + j) hij
    exact hmem.2.trans (min_le_right _ _)
  have hpv := futureLaborPresentValue_le_of_low_block
    (l := fun s => canonicalLabor s ω)
    (w := M.w) (low := M.lmin + ε) (lmax := M.lmax) (r := M.r)
    hM.r_pos hM.w_pos.le (by linarith [hM.lmin_pos]) hsupp0 hblock'
  have htail :
      maximumDiscountedIncomeTail M.w M.lmax M.r n / (1 + M.r) < δ / 2 := by
    apply (div_lt_iff₀ (by linarith [hM.r_pos])).2
    nlinarith
  have hdebtShift :
      naturalDebtLimit M.w (M.lmin + ε) M.r =
        naturalDebtLimit M.w M.lmin M.r + δ / 4 := by
    dsimp [ε]
    unfold naturalDebtLimit
    field_simp [ne_of_gt hM.r_pos, ne_of_gt hM.w_pos]
  rw [hdebtShift] at hpv
  linarith

/-- The reverse half of stochastic Property 1.  Predictability of next-period
assets makes a date-`t` debt violation independent of the labor block beginning
at `t`.  Lower-support reachability then supplies a positive-probability block
whose human wealth is too small to finance that violation under no Ponzi. -/
theorem canonical_noPonzi_implies_naturalDebtBound_ae
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hreach : LaborReachability M) (P : CanonicalIIDPlan M)
    (hnp : NoPonziAE (laborHistoryMeasure M) P.assets M.r) :
    NaturalDebtBoundAE (laborHistoryMeasure M) P.assets
      M.w M.lmin M.r := by
  letI : IsProbabilityMeasure M.laborLaw := hM.labor_probability
  letI : ∀ _ : ℕ, IsProbabilityMeasure M.laborLaw :=
    fun _ => hM.labor_probability
  letI : IsProbabilityMeasure (laborHistoryMeasure M) := by
    unfold laborHistoryMeasure
    infer_instance
  have hfeasibleAll : ∀ᵐ ω ∂laborHistoryMeasure M, ∀ s,
      0 ≤ P.consumption s ω ∧
        P.consumption s ω + P.assets (s + 1) ω =
          M.w * canonicalLabor s ω + (1 + M.r) * P.assets s ω :=
    ae_all_iff.mpr P.feasible
  have hsupportAll : ∀ᵐ ω ∂laborHistoryMeasure M, ∀ s,
      canonicalLabor s ω ∈ Icc M.lmin M.lmax :=
    ae_all_iff.mpr (canonicalLabor_mem_support_ae M hM)
  have hgood : ∀ᵐ ω ∂laborHistoryMeasure M,
      FeasiblePath M.w M.r
          (fun s => P.assets s ω) (fun s => P.consumption s ω)
          (fun s => canonicalLabor s ω) ∧
        (∀ s, canonicalLabor s ω ∈ Icc M.lmin M.lmax) ∧
        NoPonzi (fun s => P.assets s ω) M.r := by
    filter_upwards [hfeasibleAll, hsupportAll, hnp] with ω hfeas hsupp hno
    exact ⟨hfeas, hsupp, hno⟩
  intro t
  have hviolationZero : laborHistoryMeasure M
      {ω | P.assets t ω < -(naturalDebtLimit M.w M.lmin M.r)} = 0 := by
    by_contra hne
    have hpos : 0 < laborHistoryMeasure M
        {ω | P.assets t ω < -(naturalDebtLimit M.w M.lmin M.r)} :=
      pos_iff_ne_zero.mpr hne
    obtain ⟨m, hmpos⟩ := exists_positive_margin_of_measure_lt_pos hpos
    let δ : ℝ := 1 / (m + 1 : ℝ)
    have hδ : 0 < δ := by
      dsimp [δ]
      positivity
    obtain ⟨n, ε, hε, hpv⟩ :=
      exists_low_block_for_presentValue_margin M hM (t := t) hδ
    have hblockPos : 0 < laborHistoryMeasure M
        (lowerLaborBlock M t n ε) :=
      lowerLaborBlock_pos M hM hreach t n hε
    cases t with
    | zero =>
        obtain ⟨ω0, hω0⟩ := nonempty_of_measure_ne_zero hmpos.ne'
        have hinitial : P.initialAssets <
            -(naturalDebtLimit M.w M.lmin M.r) - δ := by
          simpa [δ, P.assets_zero] using hω0
        have hblockZero : laborHistoryMeasure M
            (lowerLaborBlock M 0 n ε) = 0 := by
          apply measure_eq_zero_iff_ae_notMem.mpr
          filter_upwards [hgood] with ω hω hmem
          rcases hω with ⟨hfeas, hsupp, hno⟩
          have hsupp0 : ∀ s, canonicalLabor s ω ∈ Icc (0 : ℝ) M.lmax := by
            intro s
            exact ⟨hM.lmin_pos.le.trans (hsupp s).1, (hsupp s).2⟩
          have hsolv := noPonzi_implies_realized_presentValue_bound
            hM.r_pos hM.w_pos.le hfeas hsupp0 hno 0
          have hpvω := hpv ω hmem hsupp
          have hasset : P.assets 0 ω <
              -(naturalDebtLimit M.w M.lmin M.r) - δ := by
            simpa [P.assets_zero] using hinitial
          linarith
        exact (ne_of_gt hblockPos) hblockZero
    | succ s =>
        let violation : Set LaborHistory :=
          {ω | P.assets (s + 1) ω <
            -(naturalDebtLimit M.w M.lmin M.r) - δ}
        let block : Set LaborHistory := lowerLaborBlock M (s + 1) n ε
        have hinterPos : 0 < laborHistoryMeasure M (violation ∩ block) := by
          have hproduct := measure_lt_inter_lowerLaborBlock M hM s n
            (P.assets_next_measurable s)
            (-(naturalDebtLimit M.w M.lmin M.r) - δ) ε
          change laborHistoryMeasure M (violation ∩ block) =
              laborHistoryMeasure M violation * laborHistoryMeasure M block
            at hproduct
          rw [hproduct]
          exact ENNReal.mul_pos hmpos.ne' hblockPos.ne'
        have hinterZero : laborHistoryMeasure M (violation ∩ block) = 0 := by
          apply measure_eq_zero_iff_ae_notMem.mpr
          filter_upwards [hgood] with ω hω hmem
          rcases hω with ⟨hfeas, hsupp, hno⟩
          rcases hmem with ⟨hasset, hblock⟩
          have hsupp0 : ∀ q, canonicalLabor q ω ∈ Icc (0 : ℝ) M.lmax := by
            intro q
            exact ⟨hM.lmin_pos.le.trans (hsupp q).1, (hsupp q).2⟩
          have hsolv := noPonzi_implies_realized_presentValue_bound
            hM.r_pos hM.w_pos.le hfeas hsupp0 hno (s + 1)
          have hpvω := hpv ω hblock hsupp
          change P.assets (s + 1) ω <
            -(naturalDebtLimit M.w M.lmin M.r) - δ at hasset
          linarith
        exact (ne_of_gt hinterPos) hinterZero
  have hnotMem := measure_eq_zero_iff_ae_notMem.mp hviolationZero
  filter_upwards [hnotMem] with ω hω
  simpa only [mem_setOf_eq, not_lt] using hω

/-- Property 1 in the canonical i.i.d. Aiyagari model.  For predictable
feasible plans, the natural debt restriction is equivalent to the paper's
almost-sure no-Ponzi condition.  The reverse direction uses genuine
lower-support reachability rather than replacing stochastic labor by its
minimum continuation. -/
theorem property01_naturalDebt_iff_noPonzi
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hreach : LaborReachability M) (P : CanonicalIIDPlan M) :
    NaturalDebtBoundAE (laborHistoryMeasure M) P.assets M.w M.lmin M.r ↔
      NoPonziAE (laborHistoryMeasure M) P.assets M.r := by
  constructor
  · exact canonical_naturalDebtBound_implies_noPonzi_ae M hM P
  · exact canonical_noPonzi_implies_naturalDebtBound_ae M hM hreach P

/-- Explicit almost-sure alias for Property 1, retained for the declaration
audit and for cross-references in the proof document. -/
theorem property01_naturalDebt_iff_noPonzi_ae
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hreach : LaborReachability M) (P : CanonicalIIDPlan M) :
    NaturalDebtBoundAE (laborHistoryMeasure M) P.assets M.w M.lmin M.r ↔
      NoPonziAE (laborHistoryMeasure M) P.assets M.r :=
  property01_naturalDebt_iff_noPonzi M hM hreach P

lemma minimumIncome_shifted_budget
    {a c : ℕ → ℝ} {w lmin r : ℝ}
    (hr : r ≠ 0) (hfeas : MinimumIncomeFeasiblePath w lmin r a c) (t : ℕ) :
    c t + (a (t + 1) + naturalDebtLimit w lmin r) =
      (1 + r) * (a t + naturalDebtLimit w lmin r) := by
  have h := (hfeas t).2
  simp only at h
  have hdebt : r * naturalDebtLimit w lmin r = w * lmin := by
    unfold naturalDebtLimit
    field_simp [hr]
  nlinarith [hdebt]

lemma discountedShiftedAssets_antitone
    {a c : ℕ → ℝ} {w lmin r : ℝ}
    (hr : 0 < r) (hfeas : MinimumIncomeFeasiblePath w lmin r a c) :
    Antitone (discountedShiftedAssets a (naturalDebtLimit w lmin r) r) := by
  have hR : 0 < 1 + r := by linarith
  apply antitone_nat_of_succ_le
  intro n
  have hbudget := minimumIncome_shifted_budget (ne_of_gt hr) hfeas (n + 1)
  have hc := (hfeas (n + 1)).1
  have hstep :
      a (n + 2) + naturalDebtLimit w lmin r ≤
        (1 + r) * (a (n + 1) + naturalDebtLimit w lmin r) := by
    linarith
  unfold discountedShiftedAssets
  rw [show n + 1 + 1 = n + 2 by omega, pow_succ]
  have hpow : 0 < (1 + r) ^ n * (1 + r) := mul_pos (pow_pos hR n) hR
  apply (div_le_iff₀ hpow).2
  calc
    a (n + 2) + naturalDebtLimit w lmin r
        ≤ (1 + r) * (a (n + 1) + naturalDebtLimit w lmin r) := hstep
    _ = ((a (n + 1) + naturalDebtLimit w lmin r) / (1 + r) ^ n) *
          ((1 + r) ^ n * (1 + r)) := by
      field_simp [ne_of_gt hR]

lemma tendsto_naturalDebtLimit_div_pow
    {w lmin r : ℝ} (hr : 0 < r) :
    Tendsto (fun n : ℕ => naturalDebtLimit w lmin r / (1 + r) ^ n)
      atTop (𝓝 0) := by
  have hR : 1 < 1 + r := by linarith
  have h := tendsto_pow_const_div_const_pow_of_one_lt 0 hR
  have hc : Tendsto (fun _ : ℕ => naturalDebtLimit w lmin r) atTop
      (𝓝 (naturalDebtLimit w lmin r)) := tendsto_const_nhds
  have hm := hc.mul h
  simpa [div_eq_mul_inv] using hm

/-- Property 1, proved from the discounted budget identity on the worst-case
minimum-income continuation.  This is the pathwise analytic core of the
paper's almost-sure proposition. -/
theorem minimumIncome_naturalDebt_iff_noPonzi
    (a c : ℕ → ℝ) (w lmin r : ℝ)
    (hr : 0 < r)
    (hfeas : MinimumIncomeFeasiblePath w lmin r a c) :
    NaturalDebtBound a w lmin r ↔ NoPonzi a r := by
  let debt := naturalDebtLimit w lmin r
  let y := discountedShiftedAssets a debt r
  have hyanti : Antitone y := discountedShiftedAssets_antitone hr hfeas
  have hdebt : Tendsto (fun n : ℕ => debt / (1 + r) ^ n) atTop (𝓝 0) :=
    tendsto_naturalDebtLimit_div_pow hr
  constructor
  · intro hbound
    have hy_nonneg : ∀ n, 0 ≤ y n := by
      intro n
      have hnum : 0 ≤ a (n + 1) + debt := by
        dsimp [debt]
        linarith [hbound (n + 1)]
      exact div_nonneg hnum (le_of_lt (pow_pos (by linarith : 0 < 1 + r) n))
    have hbdd : BddBelow (Set.range y) := by
      refine ⟨0, ?_⟩
      rintro _ ⟨n, rfl⟩
      exact hy_nonneg n
    let L : ℝ := ⨅ n, y n
    have hyL : Tendsto y atTop (𝓝 L) := tendsto_atTop_ciInf hyanti hbdd
    have hL : 0 ≤ L := by
      dsimp [L]
      exact le_ciInf hy_nonneg
    refine ⟨L, hL, ?_⟩
    have hsub := hyL.sub hdebt
    have hfun :
        (fun n => a (n + 1) / (1 + r) ^ n) =
          fun n => y n - debt / (1 + r) ^ n := by
      funext n
      dsimp [y, discountedShiftedAssets, debt]
      ring
    rw [hfun]
    simpa using hsub
  · rintro ⟨L, hL, haL⟩
    have hyL : Tendsto y atTop (𝓝 L) := by
      have hadd := haL.add hdebt
      have hfun : y = fun n =>
          a (n + 1) / (1 + r) ^ n + debt / (1 + r) ^ n := by
        funext n
        dsimp [y, discountedShiftedAssets, debt]
        ring
      rw [hfun]
      simpa using hadd
    have hLy : ∀ n, L ≤ y n := fun n => hyanti.le_of_tendsto hyL n
    intro t
    have hR : 0 < 1 + r := by linarith
    cases t with
    | zero =>
        have hy0 : 0 ≤ y 0 := hL.trans (hLy 0)
        have hbudget := minimumIncome_shifted_budget (ne_of_gt hr) hfeas 0
        have hc0 := (hfeas 0).1
        dsimp [y, discountedShiftedAssets, debt] at hy0
        dsimp [debt] at hbudget hy0
        norm_num at hy0
        nlinarith
    | succ n =>
        have hyn : 0 ≤ y n := hL.trans (hLy n)
        have hpow : 0 < (1 + r) ^ n := pow_pos hR n
        dsimp [y, discountedShiftedAssets, debt] at hyn
        have hnum : 0 ≤ a (n + 1) + naturalDebtLimit w lmin r := by
          have hmul := mul_nonneg hyn (le_of_lt hpow)
          rwa [div_mul_cancel₀ _ (ne_of_gt hpow)] at hmul
        linarith

/-- Almost-sure lifting of Property 1.  Countability of dates converts the
date-by-date almost-sure debt restriction into a single full-measure event on
which the pathwise theorem applies. -/
theorem minimumIncome_naturalDebt_iff_noPonzi_ae
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (a c : RealProcess Ω) (w lmin r : ℝ)
    (hr : 0 < r)
    (hfeas : ∀ᵐ ω ∂μ,
      MinimumIncomeFeasiblePath w lmin r (fun t => a t ω) (fun t => c t ω)) :
    NaturalDebtBoundAE μ a w lmin r ↔ NoPonziAE μ a r := by
  constructor
  · intro hbound
    have hboundAll : ∀ᵐ ω ∂μ, ∀ t,
        -(naturalDebtLimit w lmin r) ≤ a t ω :=
      ae_all_iff.mpr hbound
    filter_upwards [hfeas, hboundAll] with ω hpath hω
    exact (minimumIncome_naturalDebt_iff_noPonzi
      (fun t => a t ω) (fun t => c t ω) w lmin r hr hpath).mp hω
  · intro hnp
    have hboundAll : ∀ᵐ ω ∂μ, ∀ t,
        -(naturalDebtLimit w lmin r) ≤ a t ω := by
      filter_upwards [hfeas, hnp] with ω hpath hω
      exact (minimumIncome_naturalDebt_iff_noPonzi
        (fun t => a t ω) (fun t => c t ω) w lmin r hr hpath).mpr hω
    exact ae_all_iff.mp hboundAll

def oscillatingAssets (t : ℕ) : ℝ :=
  (2 : ℝ) ^ t * if Even t then 1 else 3

/-- The old forward implication was false without budget feasibility. -/
theorem natural_bound_does_not_imply_noPonzi_without_feasibility :
    NaturalDebtBound oscillatingAssets 1 1 1 ∧
      ¬NoPonzi oscillatingAssets 1 := by
  constructor
  · intro t
    by_cases ht : Even t
    · have hp : 0 ≤ (2 : ℝ) ^ t := pow_nonneg (by norm_num) t
      simpa [naturalDebtLimit, oscillatingAssets, ht] using
        (le_trans (by norm_num : (-1 : ℝ) ≤ 0) hp)
    · have hp : 0 ≤ (2 : ℝ) ^ t * 3 :=
        mul_nonneg (pow_nonneg (by norm_num) t) (by norm_num)
      simpa [naturalDebtLimit, oscillatingAssets, ht] using
        (le_trans (by norm_num : (-1 : ℝ) ≤ 0) hp)
  · rintro ⟨L, -, hL⟩
    have hc := hL.cauchySeq
    rw [Metric.cauchySeq_iff] at hc
    obtain ⟨N, hN⟩ := hc 1 zero_lt_one
    have hbad := hN (2 * N) (by omega) (2 * N + 1) (by omega)
    have hodd : ¬Even (2 * N + 1) := by
      rintro ⟨k, hk⟩
      omega
    have heven : Even (2 * N + 1 + 1) := by
      refine ⟨N + 1, by omega⟩
    norm_num [oscillatingAssets, hodd, heven, pow_succ] at hbad
    have hp : (2 : ℝ) ^ (2 * N) ≠ 0 := pow_ne_zero _ (by norm_num)
    have hratio : (2 : ℝ) ^ (2 * N) * 2 * 3 / (2 : ℝ) ^ (2 * N) = 6 := by
      field_simp [hp]
      norm_num
    rw [hratio] at hbad
    norm_num [Real.dist_eq] at hbad

/-- The old reverse implication was also false without budget feasibility. -/
theorem noPonzi_does_not_imply_natural_bound_without_feasibility :
    let a : ℕ → ℝ := fun t => if t = 0 then -2 else 0
    NoPonzi a 1 ∧ ¬NaturalDebtBound a 1 1 1 := by
  dsimp
  constructor
  · refine ⟨0, le_rfl, ?_⟩
    simpa using (tendsto_const_nhds : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 0))
  · intro h
    have := h 0
    norm_num [naturalDebtLimit] at this

theorem beta_mul_one_add_timePreferenceRate
    {β : ℝ} (hβ : β ≠ 0) :
    β * (1 + timePreferenceRate β) = 1 := by
  unfold timePreferenceRate
  field_simp
  ring

/-- Property 2, bounded continuous core: the household solution is constructed
from primitives.  Its value is the unique bounded continuous Bellman fixed
point.  Bellman iteration proves value concavity; strict utility concavity then
gives a unique shifted-asset optimizer, and the maximum-theorem argument gives
policy continuity. -/
theorem property02_value_and_policy_regularity
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    let S := solveBoundedHousehold M φ hM hφ hU
    Function.IsFixedPt (boundedAiyagariBellman M φ hM hφ hU) S.value ∧
      (∀ V : BoundedContinuousFunction ExcessResource ℝ,
        Function.IsFixedPt (boundedAiyagariBellman M φ hM hφ hU) V →
          V = S.value) ∧
      ConcaveExcessValue S.value ∧
      Continuous S.policy ∧
      (∀ x, S.policy x ∈ Icc 0 (resourceLevel M φ x)) ∧
      (∀ x, StrictConcaveOn ℝ (Icc 0 (resourceLevel M φ x))
        (boundedAssetObjective M φ hM S.value (resourceLevel M φ x))) ∧
      (∀ x a, a ∈ Icc 0 (resourceLevel M φ x) →
        boundedAssetObjective M φ hM S.value (resourceLevel M φ x) a ≤
          boundedAssetObjective M φ hM S.value
            (resourceLevel M φ x) (S.policy x)) ∧
      (∀ x a, a ∈ Icc 0 (resourceLevel M φ x) →
        (∀ b ∈ Icc 0 (resourceLevel M φ x),
          boundedAssetObjective M φ hM S.value (resourceLevel M φ x) b ≤
            boundedAssetObjective M φ hM S.value (resourceLevel M φ x) a) →
        a = S.policy x) ∧
      (∀ x : ExcessResource, 0 < (x : ℝ) →
        0 < resourceLevel M φ x - S.policy x →
        HasDerivAt (liftedExcessValue S.value)
          (deriv M.utility (resourceLevel M φ x - S.policy x)) (x : ℝ)) ∧
      (∀ x : ExcessResource,
        (hc : 0 < resourceLevel M φ x - S.policy x) →
        (hDiff : LocalDominatedDerivative
          (laborSupportProbability M hM : Measure (LaborSupportState M))
          (boundedContinuationIntegrand M S.value)
          (boundedContinuationDerivativeIntegrand M S.value)
          (S.policy x)) →
        let marginal := deriv M.utility (resourceLevel M φ x - S.policy x)
        let expectedDerivative := ∫ l : LaborSupportState M,
          boundedContinuationDerivativeIntegrand M S.value (S.policy x) l
          ∂(laborSupportProbability M hM : Measure (LaborSupportState M))
        M.β * expectedDerivative ≤ marginal ∧
          (0 < S.policy x → M.β * expectedDerivative = marginal)) := by
  dsimp only
  refine ⟨boundedAiyagariValue_isFixedPoint M φ hM hφ hU, ?_,
    boundedAiyagariValue_concave M φ hM hφ hU,
    continuous_boundedAiyagariAssetPolicy M φ hM hφ hU,
    boundedAiyagariAssetPolicy_mem M φ hM hφ hU, ?_,
    boundedAiyagariAssetPolicy_isMax M φ hM hφ hU, ?_, ?_, ?_⟩
  · intro V hV
    exact boundedAiyagariValue_unique M φ hM hφ hU hV
  · intro x
    exact boundedAssetObjective_strictConcave M φ (resourceLevel M φ x)
      hM hφ hU (add_nonneg hφ.minimumResources_nonneg x.property)
  · intro x a ha hmax
    exact boundedOptimalAsset_unique M φ hM hφ hU x ha hmax
  · intro x hx hc
    exact boundedAiyagari_envelope_of_consumption_pos
      M φ hM hφ hU x hx hc
  · intro x hc hDiff
    exact boundedAiyagari_euler_inequality M φ hM hφ hU x hc hDiff

/-- Supporting endpoint argument: a locally decreasing Bellman objective
forces the borrowing
constraint to bind.  The hypothesis is a derivative/shape condition on the
objective, not the desired cutoff conclusion. -/
theorem strictAntiObjective_implies_binding_region
    (M : HouseholdPrimitives) (φ zmin zhat : ℝ) (V A : ℝ → ℝ)
    (hzmin : 0 ≤ zmin) (hcut : zmin < zhat)
    (hA : IsOptimalPolicy M φ V A)
    (hdecreasing : ∀ z ∈ Icc zmin zhat,
      StrictAntiOn (bellmanObjective M φ V z) (feasibleChoices z)) :
    IsBindingCutoff A zmin zhat ∧
      ∀ z ∈ Icc zmin zhat, consumptionFromPolicy A z = z := by
  have hbind : ∀ z ∈ Icc zmin zhat, A z = 0 := by
    intro z hz
    have hz0 : 0 ≤ z := hzmin.trans hz.1
    have hzero : (0 : ℝ) ∈ feasibleChoices z := ⟨le_rfl, hz0⟩
    have hAz := (hA z).1
    have hAnonneg : 0 ≤ A z := hAz.1
    apply le_antisymm ?_ hAnonneg
    by_contra hnot
    have hpos : 0 < A z := lt_of_not_ge hnot
    have hstrict := hdecreasing z hz hzero hAz hpos
    have hmax := (hA z).2 0 hzero
    exact (not_lt_of_ge hmax) hstrict
  refine ⟨⟨hcut, hbind⟩, ?_⟩
  intro z hz
  simp [consumptionFromPolicy, hbind z hz]

/-- Property 3, finite-at-zero branch.  Impatience, the solved Bellman
problem, the envelope/Euler results, and the explicitly labeled local
dominated-differentiation condition imply a nondegenerate interval on which
the borrowing constraint binds.  In that interval consumption therefore
absorbs every additional unit of excess resources. -/
theorem property03_binding_region_at_low_resources
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x)) :
    ∃ xhat : ExcessResource, 0 < (xhat : ℝ) ∧
      ∀ x : ExcessResource, x ≤ xhat →
        boundedAiyagariAssetPolicy M φ hM hφ hU x = 0 ∧
          resourceLevel M φ x -
            boundedAiyagariAssetPolicy M φ hM hφ hU x =
              resourceLevel M φ x := by
  rcases boundedAiyagari_binding_cutoff M φ hM hφ hU himp hc0 hDiff with
    ⟨xhat, hxhat, hbind⟩
  refine ⟨xhat, hxhat, ?_⟩
  intro x hx
  have hzero := hbind x hx
  exact ⟨hzero, by simp [hzero]⟩

/-- In the Inada regime, a positive feasible optimizer cannot equal zero. -/
theorem property03_inada_exception
    (A : ℝ → ℝ) (zmin : ℝ)
    (hpositive : ∀ z, zmin < z → 0 < A z) :
    ∀ z, zmin < z → A z ≠ 0 := by
  intro z hz
  exact ne_of_gt (hpositive z hz)

/-- Supporting calculus result: derivative bounds imply strict monotonicity of assets and
consumption; the already-proved cutoff gives the one-for-one response. -/
theorem derivativeBounds_imply_monotonicity_and_one_for_one_response
    (A : ℝ → ℝ) (zmin zhat : ℝ)
    (hbind : IsBindingCutoff A zmin zhat)
    (hAdiff : DifferentiableOn ℝ A (Ioi zhat))
    (hslope : ∀ z, zhat < z → 0 < deriv A z ∧ deriv A z < 1) :
    StrictMonoOn A (Ioi zhat) ∧
      StrictMonoOn (consumptionFromPolicy A) (Ioi zhat) ∧
      ∀ z ε, z ∈ Icc zmin zhat → z + ε ∈ Icc zmin zhat →
        consumptionFromPolicy A (z + ε) -
          consumptionFromPolicy A z = ε := by
  have hAmono : StrictMonoOn A (Ioi zhat) :=
    strictMonoOn_of_deriv_pos (convex_Ioi zhat) hAdiff.continuousOn
      (by simpa using fun z hz => (hslope z hz).1)
  have hCdiff : DifferentiableOn ℝ (consumptionFromPolicy A) (Ioi zhat) := by
    intro z hz
    exact differentiableWithinAt_id.sub (hAdiff z hz)
  have hCderiv : ∀ z ∈ interior (Ioi zhat),
      0 < deriv (consumptionFromPolicy A) z := by
    intro z hz
    have hz' : zhat < z := by simpa using hz
    have hAat : DifferentiableAt ℝ A z :=
      hAdiff.differentiableAt (Ioi_mem_nhds hz')
    change 0 < deriv (fun x : ℝ => id x - A x) z
    have hderiv := deriv_sub differentiableAt_id hAat
    change deriv (fun x : ℝ => id x - A x) z =
      deriv id z - deriv A z at hderiv
    rw [hderiv, deriv_id]
    linarith [(hslope z hz').2]
  have hCmono : StrictMonoOn (consumptionFromPolicy A) (Ioi zhat) :=
    strictMonoOn_of_deriv_pos (convex_Ioi zhat) hCdiff.continuousOn hCderiv
  refine ⟨hAmono, hCmono, ?_⟩
  intro z ε hz hze
  have hAz := hbind.2 z hz
  have hAze := hbind.2 (z + ε) hze
  simp [consumptionFromPolicy, hAz, hAze]

/-- Property 4, foundational solved-policy part.  The shifted-asset policy is
continuous and weakly increasing, and its induced consumption is continuous
and nonnegative.  Strict inequalities and the derivative bounds are deferred
to the envelope/Euler/nondegeneracy layer rather than assumed. -/
theorem property04_monotonicity_and_one_for_one_response
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    Monotone (boundedAiyagariAssetPolicy M φ hM hφ hU) ∧
      Monotone (fun x : ExcessResource => resourceLevel M φ x -
        boundedAiyagariAssetPolicy M φ hM hφ hU x) ∧
      Continuous (boundedAiyagariAssetPolicy M φ hM hφ hU) ∧
      Continuous (fun x : ExcessResource => resourceLevel M φ x -
        boundedAiyagariAssetPolicy M φ hM hφ hU x) ∧
      (∀ ⦃x₁ x₂ : ExcessResource⦄, x₁ ≤ x₂ →
        0 ≤ boundedAiyagariAssetPolicy M φ hM hφ hU x₂ -
            boundedAiyagariAssetPolicy M φ hM hφ hU x₁ ∧
          boundedAiyagariAssetPolicy M φ hM hφ hU x₂ -
              boundedAiyagariAssetPolicy M φ hM hφ hU x₁ ≤
            (x₂ : ℝ) - (x₁ : ℝ)) ∧
      (∀ x : ExcessResource, 0 ≤ resourceLevel M φ x -
        boundedAiyagariAssetPolicy M φ hM hφ hU x) := by
  refine ⟨monotone_boundedAiyagariAssetPolicy M φ hM hφ hU,
    monotone_boundedAiyagariConsumption M φ hM hφ hU,
    continuous_boundedAiyagariAssetPolicy M φ hM hφ hU, ?_,
    (by intro x₁ x₂ hx
        exact boundedAiyagariAssetPolicy_increment_bounds M φ hM hφ hU hx), ?_⟩
  · have hresource : Continuous
        (fun x : ExcessResource => resourceLevel M φ x) := by
      unfold resourceLevel
      fun_prop
    exact hresource.sub
      (continuous_boundedAiyagariAssetPolicy M φ hM hφ hU)
  · intro x
    exact sub_nonneg.mpr
      (boundedAiyagariAssetPolicy_mem M φ hM hφ hU x).2

theorem consumptionShiftedDown_of_policyShiftedUp
    {baseline moreRisk : ℝ → ℝ}
    (hshift : PolicyShiftedUp baseline moreRisk) :
    ConsumptionShiftedDown baseline moreRisk := by
  intro z
  unfold consumptionFromPolicy
  linarith [hshift z]

/-- Pointwise policy ordering does order mean assets when the probability law
is held fixed.  This is the exact integration step that is available before
any invariant-law comparative statics are proved. -/
theorem stationaryMeanAssets_mono_same_law
    {φ : ℝ} {baseline moreRisk : ℝ → ℝ} {μ : Measure ℝ}
    (hbase : Integrable (fun z => baseline z - φ) μ)
    (hrisk : Integrable (fun z => moreRisk z - φ) μ)
    (hshift : PolicyShiftedUp baseline moreRisk) :
    stationaryMeanAssets φ baseline μ ≤
      stationaryMeanAssets φ moreRisk μ := by
  unfold stationaryMeanAssets
  exact integral_mono_ae hbase hrisk
    (Filter.Eventually.of_forall fun z => sub_le_sub_right (hshift z) φ)

/-- Convex order includes equality of first moments by definition. -/
theorem mean_eq_of_meanPreservingSpread
    {baseline spread : Measure ℝ}
    (h : MeanPreservingSpread baseline spread) :
    (∫ x, x ∂baseline) = ∫ x, x ∂spread :=
  h.2.2.1

/-- Miller's continuation-value class in the form directly used by the
Rothschild--Stiglitz comparison.  Under differentiability this shifted-
difference condition is the four-point characterization of concavity with a
convex marginal value. -/
def MillerContinuationClass (V : ℝ → ℝ) : Prop :=
  ConcaveOn ℝ univ V ∧
    ∀ x₁ x₂, x₁ ≤ x₂ →
      ConcaveOn ℝ univ (fun y => V (x₁ + y) - V (x₂ + y))

/-- One-period consumption objective with current wealth x, gross return R,
shock law μ, and continuation value V. -/
def oneStepConsumptionObjective
    (β R x : ℝ) (μ : Measure ℝ) (u V : ℝ → ℝ) (c : ℝ) : ℝ :=
  u c + β * ∫ y, V (R * (x - c) + y) ∂μ

/-- Convex order reverses the expectation ordering for every integrable
concave test function. -/
theorem integral_mono_of_convexOrder_concave
    {μ ν : Measure ℝ} {f : ℝ → ℝ}
    (horder : ConvexOrder μ ν)
    (hf : ConcaveOn ℝ univ f)
    (hμ : Integrable f μ) (hν : Integrable f ν) :
    (∫ x, f x ∂ν) ≤ ∫ x, f x ∂μ := by
  have hneg := horder.2.2.2 (fun x => -f x) hf.neg hμ.neg hν.neg
  simpa only [integral_neg, neg_le_neg_iff] using hneg

/-- Miller's equation (10): a mean-preserving spread raises the continuation
return advantage of the lower-consumption (higher-saving) choice whenever the
continuation value has convex marginal value in shifted-difference form. -/
theorem continuationSavingGap_mono_of_meanPreservingSpread
    {μ ν : Measure ℝ} {V : ℝ → ℝ} {R x cLow cHigh : ℝ}
    (hspread : MeanPreservingSpread μ ν)
    (hV : MillerContinuationClass V)
    (hR : 0 ≤ R) (hc : cLow ≤ cHigh)
    (hμLow : Integrable (fun y => V (R * (x - cLow) + y)) μ)
    (hμHigh : Integrable (fun y => V (R * (x - cHigh) + y)) μ)
    (hνLow : Integrable (fun y => V (R * (x - cLow) + y)) ν)
    (hνHigh : Integrable (fun y => V (R * (x - cHigh) + y)) ν) :
    (∫ y, V (R * (x - cLow) + y) ∂μ) -
        ∫ y, V (R * (x - cHigh) + y) ∂μ ≤
      (∫ y, V (R * (x - cLow) + y) ∂ν) -
        ∫ y, V (R * (x - cHigh) + y) ∂ν := by
  have hnext : R * (x - cHigh) ≤ R * (x - cLow) := by
    exact mul_le_mul_of_nonneg_left (sub_le_sub_left hc x) hR
  let f : ℝ → ℝ := fun y =>
    V (R * (x - cHigh) + y) - V (R * (x - cLow) + y)
  have hf : ConcaveOn ℝ univ f := hV.2 _ _ hnext
  have hμf : Integrable f μ := hμHigh.sub hμLow
  have hνf : Integrable f ν := hνHigh.sub hνLow
  have hcomp := integral_mono_of_convexOrder_concave hspread hf hμf hνf
  dsimp only [f] at hcomp
  rw [integral_sub hνHigh hνLow, integral_sub hμHigh hμLow] at hcomp
  linarith

/-- The preceding continuation comparison carries over to the full one-step
objective because current utility is the same under the two shock laws. -/
theorem oneStepObjectiveSavingGap_mono_of_meanPreservingSpread
    {μ ν : Measure ℝ} {u V : ℝ → ℝ} {β R x cLow cHigh : ℝ}
    (hspread : MeanPreservingSpread μ ν)
    (hV : MillerContinuationClass V)
    (hβ : 0 ≤ β) (hR : 0 ≤ R) (hc : cLow ≤ cHigh)
    (hμLow : Integrable (fun y => V (R * (x - cLow) + y)) μ)
    (hμHigh : Integrable (fun y => V (R * (x - cHigh) + y)) μ)
    (hνLow : Integrable (fun y => V (R * (x - cLow) + y)) ν)
    (hνHigh : Integrable (fun y => V (R * (x - cHigh) + y)) ν) :
    oneStepConsumptionObjective β R x μ u V cLow -
        oneStepConsumptionObjective β R x μ u V cHigh ≤
      oneStepConsumptionObjective β R x ν u V cLow -
        oneStepConsumptionObjective β R x ν u V cHigh := by
  have hgap := continuationSavingGap_mono_of_meanPreservingSpread
    hspread hV hR hc hμLow hμHigh hνLow hνHigh
  have hscaled := mul_le_mul_of_nonneg_left hgap hβ
  unfold oneStepConsumptionObjective
  linarith

/-- One-step Sibley--Miller policy comparison.  With a common continuation
value in Miller's class, a mean-preserving spread cannot raise the unique
optimal consumption choice and therefore cannot lower saving. -/
theorem optimalConsumption_antitone_of_meanPreservingSpread_sameContinuation
    {μ ν : Measure ℝ} {u V : ℝ → ℝ} {β R x cBase cRisk : ℝ}
    (hspread : MeanPreservingSpread μ ν)
    (hV : MillerContinuationClass V)
    (hβ : 0 ≤ β) (hR : 0 ≤ R)
    (hμBase : Integrable (fun y => V (R * (x - cBase) + y)) μ)
    (hμRisk : Integrable (fun y => V (R * (x - cRisk) + y)) μ)
    (hνBase : Integrable (fun y => V (R * (x - cBase) + y)) ν)
    (hνRisk : Integrable (fun y => V (R * (x - cRisk) + y)) ν)
    (hBaseMax : ∀ c,
      oneStepConsumptionObjective β R x μ u V c ≤
        oneStepConsumptionObjective β R x μ u V cBase)
    (hRiskMax : ∀ c,
      oneStepConsumptionObjective β R x ν u V c ≤
        oneStepConsumptionObjective β R x ν u V cRisk)
    (hRiskUnique : ∀ c,
      oneStepConsumptionObjective β R x ν u V c =
        oneStepConsumptionObjective β R x ν u V cRisk → c = cRisk) :
    cRisk ≤ cBase := by
  by_contra hnot
  have hlt : cBase < cRisk := lt_of_not_ge hnot
  have hgap := oneStepObjectiveSavingGap_mono_of_meanPreservingSpread (u := u)
    hspread hV hβ hR hlt.le hμBase hμRisk hνBase hνRisk
  have hbaseGap : 0 ≤
      oneStepConsumptionObjective β R x μ u V cBase -
        oneStepConsumptionObjective β R x μ u V cRisk :=
    sub_nonneg.mpr (hBaseMax cRisk)
  have hriskGap : 0 ≤
      oneStepConsumptionObjective β R x ν u V cBase -
        oneStepConsumptionObjective β R x ν u V cRisk :=
    hbaseGap.trans hgap
  have heq :
      oneStepConsumptionObjective β R x ν u V cBase =
        oneStepConsumptionObjective β R x ν u V cRisk :=
    le_antisymm (hRiskMax cBase) (sub_nonneg.mp hriskGap)
  have := hRiskUnique cBase heq
  linarith

/-- Property 5, rigorous one-step core.  The result is universal over
continuous shock laws and proves both lower consumption and higher saving.
The remaining infinite-horizon step is to prove Miller-class preservation by
the two law-specific Bellman fixed points. -/
theorem property05_mean_preserving_spread
    {μ ν : Measure ℝ} {u V : ℝ → ℝ} {β R x cBase cRisk : ℝ}
    (hspread : MeanPreservingSpread μ ν)
    (hV : MillerContinuationClass V)
    (hβ : 0 ≤ β) (hR : 0 ≤ R)
    (hμBase : Integrable (fun y => V (R * (x - cBase) + y)) μ)
    (hμRisk : Integrable (fun y => V (R * (x - cRisk) + y)) μ)
    (hνBase : Integrable (fun y => V (R * (x - cBase) + y)) ν)
    (hνRisk : Integrable (fun y => V (R * (x - cRisk) + y)) ν)
    (hBaseMax : ∀ c,
      oneStepConsumptionObjective β R x μ u V c ≤
        oneStepConsumptionObjective β R x μ u V cBase)
    (hRiskMax : ∀ c,
      oneStepConsumptionObjective β R x ν u V c ≤
        oneStepConsumptionObjective β R x ν u V cRisk)
    (hRiskUnique : ∀ c,
      oneStepConsumptionObjective β R x ν u V c =
        oneStepConsumptionObjective β R x ν u V cRisk → c = cRisk) :
    cRisk ≤ cBase ∧ x - cBase ≤ x - cRisk := by
  have hc := optimalConsumption_antitone_of_meanPreservingSpread_sameContinuation
    hspread hV hβ hR hμBase hμRisk hνBase hνRisk
      hBaseMax hRiskMax hRiskUnique
  exact ⟨hc, sub_le_sub_left hc x⟩

end

end Aiyagari1994
