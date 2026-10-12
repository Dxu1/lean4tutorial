import Aiyagari1994.Analysis.M10A1.BudgetTelescope
import Aiyagari1994.Budget.EffectiveLimit

/-! Gate-local proof that the natural original-asset floor implies No-Ponzi. -/

open Filter Finset MeasureTheory
open scoped Topology

namespace Aiyagari1994.M10A2

/-- On a feasible path, the natural original-asset floor makes discounted terminal wealth
converge to a finite nonnegative limit.  The conclusion deliberately permits a positive limit. -/
theorem naturalBound_implies_noPonzi_pathwise
    (r w laborMin laborMax : ℝ) (a c labor : ℕ → ℝ)
    (hr : 0 < r) (hw : 0 < w) (hlaborMin : 0 < laborMin)
    (hlabor : ∀ t : ℕ, laborMin ≤ labor t ∧ labor t ≤ laborMax)
    (hc : ∀ t : ℕ, 0 ≤ c t)
    (hbudget : ∀ t : ℕ,
      c t + a (t + 1) = (1 + r) * a t + w * labor t)
    (hfloor : ∀ t : ℕ, -naturalLimit laborMin w r ≤ a t) :
    ∃ L : ℝ, 0 ≤ L ∧
      Tendsto (fun T : ℕ => (1 + r)⁻¹ ^ T * a (T + 1)) atTop (nhds L) := by
  let R : ℝ := 1 + r
  let q : ℝ := R⁻¹
  have hR : 0 < R := by dsimp [R]; linarith
  have hR_one : 1 < R := by dsimp [R]; linarith
  have hq_pos : 0 < q := inv_pos.mpr hR
  have hq_nonneg : 0 ≤ q := hq_pos.le
  have hq_lt_one : q < 1 := (inv_lt_one₀ hR).2 hR_one
  have hlaborMax : 0 < laborMax :=
    lt_of_lt_of_le hlaborMin (le_trans (hlabor 0).1 (hlabor 0).2)
  have hnatural_nonneg : 0 ≤ naturalLimit laborMin w r :=
    naturalLimit_nonneg hlaborMin hw hr
  have hgeo : Summable (fun t : ℕ => q ^ t) :=
    summable_geometric_of_lt_one hq_nonneg hq_lt_one
  have hincome_nonneg : ∀ t : ℕ, 0 ≤ q ^ t * (w * labor t) := by
    intro t
    exact mul_nonneg (pow_nonneg hq_nonneg t)
      (mul_nonneg hw.le (le_trans hlaborMin.le (hlabor t).1))
  have hincome_le : ∀ t : ℕ, q ^ t * (w * labor t) ≤ q ^ t * (w * laborMax) := by
    intro t
    exact mul_le_mul_of_nonneg_left
      (mul_le_mul_of_nonneg_left (hlabor t).2 hw.le) (pow_nonneg hq_nonneg t)
  have hincome : Summable (fun t : ℕ => q ^ t * (w * labor t)) := by
    apply Summable.of_nonneg_of_le hincome_nonneg hincome_le
    simpa [mul_assoc] using hgeo.mul_right (w * laborMax)
  have hcons_nonneg : ∀ t : ℕ, 0 ≤ q ^ t * c t := by
    intro t
    exact mul_nonneg (pow_nonneg hq_nonneg t) (hc t)
  have hcons_bound : ∀ n : ℕ,
      ∑ t ∈ range n, q ^ t * c t ≤
        R * a 0 + ∑' t : ℕ, q ^ t * (w * labor t) + naturalLimit laborMin w r := by
    intro n
    cases n with
    | zero =>
        simp only [range_zero, sum_empty]
        have hbudget0 := hbudget 0
        have hfloor1 := hfloor 1
        have hlabor0 := (hlabor 0).1
        dsimp [R] at hbudget0 ⊢
        have hinc0 : 0 ≤ w * labor 0 :=
          mul_nonneg hw.le (le_trans hlaborMin.le hlabor0)
        have hinc_le_tsum : w * labor 0 ≤ ∑' t : ℕ, q ^ t * (w * labor t) := by
          have hsingle := hincome.sum_le_tsum ({0} : Finset ℕ)
            (fun i hi => hincome_nonneg i)
          simpa using hsingle
        have hresource :
            0 ≤ c 0 + a 1 + naturalLimit laborMin w r := by
          linarith [hc 0]
        linarith
    | succ T =>
        have htelescope :=
          Aiyagari1994.M10A1.discounted_budget_telescope_core
            R w a c labor hR (by simpa [R] using hbudget) T
        have hincome_partial :
            ∑ t ∈ range (T + 1), q ^ t * (w * labor t) ≤
              ∑' t : ℕ, q ^ t * (w * labor t) :=
          hincome.sum_le_tsum (range (T + 1)) (fun i hi => hincome_nonneg i)
        have hqpow_le_one : q ^ T ≤ 1 := pow_le_one₀ hq_nonneg hq_lt_one.le
        have hterminal_floor :
            -(q ^ T * a (T + 1)) ≤ q ^ T * naturalLimit laborMin w r := by
          have := mul_le_mul_of_nonneg_left (hfloor (T + 1)) (pow_nonneg hq_nonneg T)
          linarith
        have hnatural_term :
            q ^ T * naturalLimit laborMin w r ≤ naturalLimit laborMin w r := by
          nlinarith
        simpa [q] using
          (show
            ∑ t ∈ range (T + 1), R⁻¹ ^ t * c t ≤
              R * a 0 + ∑' t : ℕ, q ^ t * (w * labor t) +
                naturalLimit laborMin w r by
            rw [htelescope]
            linarith)
  have hcons : Summable (fun t : ℕ => q ^ t * c t) :=
    summable_of_sum_range_le hcons_nonneg hcons_bound
  let L : ℝ := R * a 0 + ∑' t : ℕ, q ^ t * (w * labor t) - ∑' t : ℕ, q ^ t * c t
  have hincome_tendsto :
      Tendsto (fun T : ℕ => ∑ t ∈ range (T + 1), q ^ t * (w * labor t))
        atTop (nhds (∑' t : ℕ, q ^ t * (w * labor t))) := by
    exact hincome.hasSum.tendsto_sum_nat.comp (Filter.tendsto_add_atTop_nat 1)
  have hcons_tendsto :
      Tendsto (fun T : ℕ => ∑ t ∈ range (T + 1), q ^ t * c t)
        atTop (nhds (∑' t : ℕ, q ^ t * c t)) := by
    exact hcons.hasSum.tendsto_sum_nat.comp (Filter.tendsto_add_atTop_nat 1)
  have hterminal_tendsto :
      Tendsto (fun T : ℕ => q ^ T * a (T + 1)) atTop (nhds L) := by
    have hconst : Tendsto (fun _ : ℕ => R * a 0) atTop (nhds (R * a 0)) :=
      tendsto_const_nhds
    have hrhs : Tendsto
        (fun T : ℕ => R * a 0 +
          ∑ t ∈ range (T + 1), q ^ t * (w * labor t) -
          ∑ t ∈ range (T + 1), q ^ t * c t)
        atTop (nhds L) := by
      simpa [L] using (hconst.add hincome_tendsto).sub hcons_tendsto
    apply hrhs.congr'
    filter_upwards [] with T
    have htelescope :=
      Aiyagari1994.M10A1.discounted_budget_telescope_core
        R w a c labor hR (by simpa [R] using hbudget) T
    rw [show q = R⁻¹ by rfl]
    linarith
  have hlower_tendsto :
      Tendsto (fun T : ℕ => -(q ^ T * naturalLimit laborMin w r)) atTop (nhds 0) := by
    simpa only [mul_neg, zero_mul, neg_zero] using
      (tendsto_pow_atTop_nhds_zero_of_lt_one hq_nonneg hq_lt_one).mul_const
        (-naturalLimit laborMin w r)
  have hL_nonneg : 0 ≤ L := by
    apply le_of_tendsto_of_tendsto' hlower_tendsto hterminal_tendsto
    intro T
    have := mul_le_mul_of_nonneg_left (hfloor (T + 1)) (pow_nonneg hq_nonneg T)
    linarith
  refine ⟨L, hL_nonneg, ?_⟩
  simpa [R, q] using hterminal_tendsto

/-- Datewise almost-sure path hypotheses lift the pathwise natural-floor implication to a
single almost-sure No-Ponzi conclusion. -/
theorem naturalBound_implies_noPonzi_ae
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (r w laborMin laborMax : ℝ) (a c labor : ℕ → Ω → ℝ)
    (hr : 0 < r) (hw : 0 < w) (hlaborMin : 0 < laborMin)
    (hlaborLower : ∀ t : ℕ, ∀ᵐ ω ∂μ, laborMin ≤ labor t ω)
    (hlaborUpper : ∀ t : ℕ, ∀ᵐ ω ∂μ, labor t ω ≤ laborMax)
    (hc : ∀ t : ℕ, ∀ᵐ ω ∂μ, 0 ≤ c t ω)
    (hbudget : ∀ t : ℕ, ∀ᵐ ω ∂μ,
      c t ω + a (t + 1) ω = (1 + r) * a t ω + w * labor t ω)
    (hfloor : ∀ t : ℕ, ∀ᵐ ω ∂μ,
      -naturalLimit laborMin w r ≤ a t ω) :
    ∀ᵐ ω ∂μ, ∃ L : ℝ, 0 ≤ L ∧
      Tendsto (fun T : ℕ => (1 + r)⁻¹ ^ T * a (T + 1) ω) atTop (nhds L) := by
  have hlower_all : ∀ᵐ ω ∂μ, ∀ t : ℕ, laborMin ≤ labor t ω :=
    MeasureTheory.ae_all_iff.mpr hlaborLower
  have hupper_all : ∀ᵐ ω ∂μ, ∀ t : ℕ, labor t ω ≤ laborMax :=
    MeasureTheory.ae_all_iff.mpr hlaborUpper
  have hc_all : ∀ᵐ ω ∂μ, ∀ t : ℕ, 0 ≤ c t ω :=
    MeasureTheory.ae_all_iff.mpr hc
  have hbudget_all : ∀ᵐ ω ∂μ, ∀ t : ℕ,
      c t ω + a (t + 1) ω = (1 + r) * a t ω + w * labor t ω :=
    MeasureTheory.ae_all_iff.mpr hbudget
  have hfloor_all : ∀ᵐ ω ∂μ, ∀ t : ℕ,
      -naturalLimit laborMin w r ≤ a t ω :=
    MeasureTheory.ae_all_iff.mpr hfloor
  filter_upwards [hlower_all, hupper_all, hc_all, hbudget_all, hfloor_all] with
      ω hlowerω hupperω hcω hbudgetω hfloorω
  exact naturalBound_implies_noPonzi_pathwise r w laborMin laborMax
    (fun t => a t ω) (fun t => c t ω) (fun t => labor t ω)
    hr hw hlaborMin (fun t => ⟨hlowerω t, hupperω t⟩) hcω hbudgetω hfloorω

end Aiyagari1994.M10A2
