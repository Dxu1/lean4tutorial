import Aiyagari1994.Analysis.M10A3.PathSpace
import Mathlib.Analysis.SpecificLimits.Normed

/-! Deterministic debt bounds used by the stochastic NP03 contradiction. -/

open Filter Finset
open scoped Topology

namespace Aiyagari1994.M10A3

/-- A finite nonnegative discounted terminal limit and nonnegative consumption imply the coarse
maximum-income debt floor.  This is the pathwise consequence of NP01 used by NP03. -/
theorem coarseDebtBound_of_noPonzi_pathwise
    (r w laborMax : ℝ) (a c labor : ℕ → ℝ)
    (hr : 0 < r) (hw : 0 < w)
    (hlaborUpper : ∀ s : ℕ, labor s ≤ laborMax)
    (hc : ∀ s : ℕ, 0 ≤ c s)
    (hbudget : ∀ s : ℕ, c s + a (s + 1) = (1 + r) * a s + w * labor s)
    (L : ℝ) (hL : 0 ≤ L)
    (hlimit : Tendsto (fun T : ℕ ↦ (1 + r)⁻¹ ^ T * a (T + 1)) atTop (nhds L))
    (t : ℕ) :
    -w * laborMax / r ≤ a t := by
  let R : ℝ := 1 + r
  let q : ℝ := R⁻¹
  have hR : 0 < R := by dsimp [R]; linarith
  have hR_one : 1 < R := by dsimp [R]; linarith
  have hq_nonneg : 0 ≤ q := (inv_pos.mpr hR).le
  have hq_lt_one : q < 1 := (inv_lt_one₀ hR).2 hR_one
  have hlocalLimit :
      Tendsto (fun n : ℕ ↦ q ^ n * a (t + n + 1)) atTop (nhds (R ^ t * L)) := by
    have hshift := hlimit.comp (tendsto_add_atTop_nat t)
    have hshift' : Tendsto (fun n : ℕ ↦ R⁻¹ ^ (t + n) * a (t + n + 1))
        atTop (nhds L) := by
      apply hshift.congr'
      filter_upwards [] with n
      dsimp [R, Function.comp_def]
      rw [inv_pow]
      simp only [Nat.add_comm, Nat.add_assoc]
      rw [inv_pow]
    have hscaled := (tendsto_const_nhds.mul hshift' :
      Tendsto (fun n : ℕ ↦ R ^ t * (R⁻¹ ^ (t + n) * a (t + n + 1)))
        atTop (nhds (R ^ t * L)))
    apply hscaled.congr'
    filter_upwards [] with n
    dsimp [q]
    rw [pow_add]
    have hRne : R ≠ 0 := ne_of_gt hR
    have htinv : R ^ t * R⁻¹ ^ t = 1 := by
      rw [← mul_pow, mul_inv_cancel₀ hRne, one_pow]
    calc
      R ^ t * ((R⁻¹ ^ t * R⁻¹ ^ n) * a (t + n + 1)) =
          (R ^ t * R⁻¹ ^ t) * R⁻¹ ^ n * a (t + n + 1) := by ring
      _ = R⁻¹ ^ n * a (t + n + 1) := by rw [htinv, one_mul]
  have hupper : ∀ n : ℕ,
      q ^ n * a (t + n + 1) ≤
        R * a t + ∑ j ∈ range (n + 1), q ^ j * (w * laborMax) := by
    intro n
    have htelescope := Aiyagari1994.M10A1.discounted_budget_telescope_core
      R w (fun j ↦ a (t + j)) (fun j ↦ c (t + j)) (fun j ↦ labor (t + j))
      hR (by intro j; simpa [R, Nat.add_assoc] using hbudget (t + j)) n
    have hconsNonneg :
        0 ≤ ∑ j ∈ range (n + 1), q ^ j * c (t + j) := by
      exact sum_nonneg fun j _ ↦ mul_nonneg (pow_nonneg hq_nonneg j) (hc (t + j))
    have hincomeUpper :
        ∑ j ∈ range (n + 1), q ^ j * (w * labor (t + j)) ≤
          ∑ j ∈ range (n + 1), q ^ j * (w * laborMax) := by
      apply sum_le_sum
      intro j _
      exact mul_le_mul_of_nonneg_left
        (mul_le_mul_of_nonneg_left (hlaborUpper (t + j)) hw.le)
        (pow_nonneg hq_nonneg j)
    rw [show t + (n + 1) = t + n + 1 by omega] at htelescope
    dsimp [q] at htelescope ⊢
    linarith
  have hsumLimit :
      Tendsto (fun n : ℕ ↦ R * a t + ∑ j ∈ range (n + 1), q ^ j * (w * laborMax))
        atTop (nhds (R * a t + (1 - q)⁻¹ * (w * laborMax))) := by
    have hgeo := (summable_geometric_of_lt_one hq_nonneg hq_lt_one).hasSum
    have hgeo' : Tendsto (fun n : ℕ ↦ ∑ j ∈ range (n + 1), q ^ j)
        atTop (nhds (1 - q)⁻¹) := by
      have ht := hgeo.tendsto_sum_nat.comp (tendsto_add_atTop_nat 1)
      rw [tsum_geometric_of_lt_one hq_nonneg hq_lt_one] at ht
      change Tendsto ((fun n : ℕ ↦ ∑ j ∈ range n, q ^ j) ∘ fun n ↦ n + 1)
        atTop (nhds (1 - q)⁻¹)
      exact ht
    simpa [sum_mul] using (tendsto_const_nhds.add (hgeo'.mul_const (w * laborMax)))
  have hlimitUpper : R ^ t * L ≤ R * a t + (1 - q)⁻¹ * (w * laborMax) :=
    le_of_tendsto_of_tendsto' hlocalLimit hsumLimit hupper
  have hnonneg : 0 ≤ R ^ t * L := mul_nonneg (pow_nonneg hR.le t) hL
  have hfactor : (1 - q)⁻¹ = R / r := by
    have hrne : r ≠ 0 := ne_of_gt hr
    dsimp [q, R]
    field_simp [hrne]
    ring
  rw [hfactor] at hlimitUpper
  have hresources : 0 ≤ R * a t + R / r * (w * laborMax) :=
    le_trans hnonneg hlimitUpper
  have hrne : r ≠ 0 := ne_of_gt hr
  field_simp [hrne] at hresources ⊢
  nlinarith

/-- A finite block of near-minimum income amplifies a uniform debt gap until it violates the
coarse maximum-income floor. -/
theorem lowBlock_forces_below_coarse
    (r w laborMin laborMax eta h : ℝ) (a c labor : ℕ → ℝ)
    (hr : 0 < r) (hw : 0 < w) (_heta : 0 < eta)
    (hh : 0 ≤ h) (_hgap : w * h / r < eta)
    (t N : ℕ)
    (hN : w * (laborMax - laborMin) / r <
      (1 + r) ^ N * (eta - w * h / r))
    (hasset : a t ≤ -w * laborMin / r - eta)
    (hlow : ∀ j < N, labor (t + j) ≤ laborMin + h)
    (hc : ∀ j < N, 0 ≤ c (t + j))
    (hbudget : ∀ j < N,
      c (t + j) + a (t + j + 1) =
        (1 + r) * a (t + j) + w * labor (t + j)) :
    a (t + N) < -w * laborMax / r := by
  let R : ℝ := 1 + r
  let d : ℕ → ℝ := fun n ↦ R ^ n * (eta - w * h / r) + w * h / r
  have hR : 0 < R := by dsimp [R]; linarith
  have hd : ∀ n ≤ N, a (t + n) ≤ -w * laborMin / r - d n := by
    intro n hn
    induction n with
    | zero =>
        simpa [d] using hasset
    | succ n ih =>
        have hnN : n < N := Nat.lt_of_succ_le hn
        have hstep := hbudget n hnN
        have hcstep := hc n hnN
        have hlstep := hlow n hnN
        have hprev := ih (Nat.le_of_succ_le hn)
        have hdstep : d (n + 1) = R * d n - w * h := by
          dsimp [d]
          rw [pow_succ]
          dsimp [R]
          field_simp
          ring
        rw [hdstep]
        rw [show t + n + 1 = t + (n + 1) by omega] at hstep
        calc
          a (t + (n + 1)) ≤ R * a (t + n) + w * labor (t + n) := by
            dsimp [R]
            linarith
          _ ≤ R * (-w * laborMin / r - d n) + w * (laborMin + h) := by
            exact add_le_add (mul_le_mul_of_nonneg_left hprev hR.le)
              (mul_le_mul_of_nonneg_left hlstep hw.le)
          _ = -w * laborMin / r - (R * d n - w * h) := by
            have hrne : r ≠ 0 := ne_of_gt hr
            dsimp [R]
            field_simp [hrne]
            ring
  have hterminal := hd N (le_refl N)
  have hdN : w * (laborMax - laborMin) / r < d N := by
    dsimp [d, R]
    linarith [div_nonneg (mul_nonneg hw.le hh) hr.le]
  have hrne : r ≠ 0 := ne_of_gt hr
  field_simp [hrne] at hterminal hdN ⊢
  nlinarith

end Aiyagari1994.M10A3
