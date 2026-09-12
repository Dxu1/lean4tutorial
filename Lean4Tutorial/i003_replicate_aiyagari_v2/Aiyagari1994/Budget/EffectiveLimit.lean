import Aiyagari1994.Budget.Normalization
open Set Filter
open scoped Topology
namespace Aiyagari1994

noncomputable def effectiveLimit (b lo w r : ℝ) : ℝ :=
  if 0 < r then min b (w*lo/r) else b

noncomputable def naturalLimit (lo w r : ℝ) : ℝ := w*lo/r

theorem effectiveLimit_nonneg {b lo w r : ℝ} (hb : 0 ≤ b) (hl : 0 < lo) (hw : 0 < w) :
    0 ≤ effectiveLimit b lo w r := by
  unfold effectiveLimit
  split_ifs with hr
  · exact le_min hb (div_nonneg (mul_pos hw hl).le hr.le)
  · exact hb

theorem effectiveLimit_income_nonneg {b lo w r l : ℝ}
    (hb : 0 ≤ b) (hl : 0 < lo) (hw : 0 < w) (hll : lo ≤ l) :
    0 ≤ w*l-r*effectiveLimit b lo w r := by
  have hwl : w*lo ≤ w*l := mul_le_mul_of_nonneg_left hll hw.le
  unfold effectiveLimit
  split_ifs with hr
  · have h := min_le_right b (w*lo/r)
    have h' : r*min b (w*lo/r) ≤ w*lo := by
      have := (le_div_iff₀ hr).mp h
      nlinarith
    linarith
  · have : r*b ≤ 0 := mul_nonpos_of_nonpos_of_nonneg (le_of_not_gt hr) hb
    have : 0 < w*lo := mul_pos hw hl
    linarith

/-- Continuous rational/max representation, whose denominator is strictly positive at w>0.
No division by b is used, including b=0. -/
theorem effectiveLimit_eq_max {b lo w r : ℝ} (hb : 0 ≤ b) (hl : 0 < lo) (hw : 0 < w) :
    effectiveLimit b lo w r = b*(w*lo) / max (w*lo) (b*r) := by
  have ht : 0 < w*lo := mul_pos hw hl
  unfold effectiveLimit
  by_cases hr : 0 < r
  · rw [if_pos hr]
    by_cases h : b*r ≤ w*lo
    · rw [min_eq_left ((le_div_iff₀ hr).mpr h), max_eq_left h]
      field_simp
    · have h' : w*lo ≤ b*r := le_of_not_ge h
      have hb' : 0 < b := by nlinarith
      rw [min_eq_right ((div_le_iff₀ hr).mpr h'), max_eq_right h']
      field_simp
  · rw [if_neg hr, max_eq_left (by nlinarith : b*r ≤ w*lo)]
    field_simp

theorem effectiveLimit_continuous {b lo : ℝ} (hb : 0 ≤ b) (hl : 0 < lo) :
    ContinuousOn (fun p : ℝ × ℝ => effectiveLimit b lo p.1 p.2)
      {p | 0 < p.1 ∧ -1 < p.2} := by
  intro p hp
  have hc : ContinuousAt (fun p : ℝ × ℝ => b*(p.1*lo) / max (p.1*lo) (b*p.2)) p := by
    apply ContinuousAt.div (by fun_prop) (by fun_prop)
    exact ne_of_gt (lt_of_lt_of_le (mul_pos hp.1 hl) (le_max_left _ _))
  apply hc.continuousWithinAt.congr
  · intro q hq
    exact effectiveLimit_eq_max hb hl hq.1
  · exact effectiveLimit_eq_max hb hl hp.1

/-- Explicit rate-zero neighborhood: the natural bound dominates b at positive nearby rates. -/
theorem effectiveLimit_zero_neighborhood {b lo w : ℝ} (hl : 0 < lo) (hw : 0 < w) :
    ∀ᶠ p : ℝ × ℝ in 𝓝 (w,0),
      (0 < p.2 → b ≤ p.1*lo/p.2) ∧ effectiveLimit b lo p.1 p.2 = b := by
  have hc : Continuous (fun p : ℝ × ℝ => p.1*lo-b*p.2) := by fun_prop
  have he : ∀ᶠ p : ℝ × ℝ in 𝓝 (w,0), 0 < p.1*lo-b*p.2 :=
    (isOpen_lt continuous_const hc).mem_nhds (by simpa using mul_pos hw hl)
  filter_upwards [he] with p hp
  have h : 0 < p.2 → b ≤ p.1*lo/p.2 := by
    intro hr
    apply (le_div_iff₀ hr).mpr
    linarith
  refine ⟨h, ?_⟩
  unfold effectiveLimit
  split_ifs with hr
  · exact min_eq_left (h hr)
  · rfl

theorem naturalLimit_nonneg {lo w r : ℝ} (hl : 0 < lo) (hw : 0 < w) (hr : 0 < r) :
    0 ≤ naturalLimit lo w r := (div_pos (mul_pos hw hl) hr).le

theorem naturalLimit_intercept {lo w r : ℝ} (hr : 0 < r) :
    -r * naturalLimit lo w r = -w*lo := by
  unfold naturalLimit
  field_simp

theorem naturalLimit_income {lo w r l : ℝ} (hr : 0 < r) :
    w*l-r*naturalLimit lo w r = w*(l-lo) := by
  have h := naturalLimit_intercept (lo := lo) (w := w) hr
  nlinarith

theorem naturalLimit_income_nonneg {lo w r l : ℝ}
    (hw : 0 < w) (hr : 0 < r) (hll : lo ≤ l) :
    0 ≤ w*l-r*naturalLimit lo w r := by
  rw [naturalLimit_income hr]
  exact mul_nonneg hw.le (sub_nonneg.mpr hll)

theorem naturalLimit_continuous (lo : ℝ) :
    ContinuousOn (fun p : ℝ × ℝ => naturalLimit lo p.1 p.2) {p | 0 < p.1 ∧ 0 < p.2} := by
  intro p hp
  exact ((continuous_fst.continuousAt.mul continuousAt_const).div
    continuous_snd.continuousAt (ne_of_gt hp.2)).continuousWithinAt

noncomputable def finiteCapPrices (i : IncomeData) (hi : IncomeSupport i)
    (b w r : ℝ) (hb : 0 ≤ b) (hw : 0 < w) (hr : -1 < r) : OriginalPrices i where
  netRate := r
  wage := w
  debtLimit := effectiveLimit b i.lower w r
  netRate_gt := hr
  wage_pos := hw
  debtLimit_nonneg := effectiveLimit_nonneg hb hi.lower_pos hw
  income_nonneg := fun l => effectiveLimit_income_nonneg hb hi.lower_pos hw l.property.1

noncomputable def naturalCapPrices (i : IncomeData) (hi : IncomeSupport i)
    (w r : ℝ) (hw : 0 < w) (hr : 0 < r) : OriginalPrices i where
  netRate := r
  wage := w
  debtLimit := naturalLimit i.lower w r
  netRate_gt := by linarith
  wage_pos := hw
  debtLimit_nonneg := naturalLimit_nonneg hi.lower_pos hw hr
  income_nonneg := fun l => naturalLimit_income_nonneg hw hr l.property.1

/-- Any feasible shifted choice generates a nonnegative next resource state. -/
theorem generated_resources_admissible {i : IncomeData} (p : NormalizedPrices i)
    (a : Resources) (l : i.Labor) :
    0 ≤ p.grossReturn*(a : ℝ)+p.effectiveIncome l := (p.nextResources a l).property

/-- P02: separate quantified finite/natural branches, with no simultaneous branch premise. -/
theorem effectiveLimit_admissible_continuous (b lo : ℝ) (hb : 0 ≤ b) (hl : 0 < lo) :
    (∀ w r, 0 < w → 0 ≤ effectiveLimit b lo w r) ∧
    (∀ w r l, 0 < w → lo ≤ l → 0 ≤ w*l-r*effectiveLimit b lo w r) ∧
    ContinuousOn (fun p : ℝ × ℝ => effectiveLimit b lo p.1 p.2) {p | 0 < p.1 ∧ -1 < p.2} ∧
    (∀ w, 0 < w → ∀ᶠ p : ℝ × ℝ in 𝓝 (w,0),
      (0 < p.2 → b ≤ p.1*lo/p.2) ∧ effectiveLimit b lo p.1 p.2 = b) ∧
    (∀ w r, 0 < w → 0 < r → 0 ≤ naturalLimit lo w r ∧
      -r*naturalLimit lo w r = -w*lo ∧
      ∀ l, lo ≤ l → w*l-r*naturalLimit lo w r = w*(l-lo) ∧
        0 ≤ w*l-r*naturalLimit lo w r) ∧
    ContinuousOn (fun p : ℝ × ℝ => naturalLimit lo p.1 p.2) {p | 0 < p.1 ∧ 0 < p.2} := by
  refine ⟨fun _ _ hw => effectiveLimit_nonneg hb hl hw,
    fun _ _ _ hw hll => effectiveLimit_income_nonneg hb hl hw hll,
    effectiveLimit_continuous hb hl,
    fun _ hw => effectiveLimit_zero_neighborhood hl hw, ?_, naturalLimit_continuous lo⟩
  intro w r hw hr
  exact ⟨naturalLimit_nonneg hl hw hr, naturalLimit_intercept hr,
    fun _ hll => ⟨naturalLimit_income hr, naturalLimit_income_nonneg hw hr hll⟩⟩
end Aiyagari1994
