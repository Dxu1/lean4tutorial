import Aiyagari1994.Analysis.M10A1.BudgetTelescope
import Aiyagari1994.Analysis.M10A2.NaturalNoPonzi

/-! NP01: finite discounted original-asset budget identity. -/

namespace Aiyagari1994

/-- NP01.  Every finite original-budget path satisfies the exact discounted telescope. -/
theorem discounted_budget_telescope
    (R w : ℝ) (a c labor : ℕ → ℝ) (hR : 0 < R)
    (hbudget : ∀ t : ℕ, c t + a (t + 1) = R * a t + w * labor t)
    (T : ℕ) :
    ∑ t ∈ Finset.range (T + 1), R⁻¹ ^ t * c t =
      R * a 0 + ∑ t ∈ Finset.range (T + 1), R⁻¹ ^ t * (w * labor t) -
        R⁻¹ ^ T * a (T + 1) :=
  M10A1.discounted_budget_telescope_core R w a c labor hR hbudget T

end Aiyagari1994

namespace Aiyagari1994

/-- NP02.  A natural original-asset floor implies a finite nonnegative discounted terminal
wealth limit almost surely; the limit is not asserted to vanish. -/
theorem naturalBound_implies_noPonzi
    {Ω : Type*} [MeasurableSpace Ω] (μ : MeasureTheory.Measure Ω)
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
      Filter.Tendsto (fun T : ℕ => (1 + r)⁻¹ ^ T * a (T + 1) ω)
        Filter.atTop (nhds L) :=
  M10A2.naturalBound_implies_noPonzi_ae μ r w laborMin laborMax a c labor
    hr hw hlaborMin hlaborLower hlaborUpper hc hbudget hfloor

end Aiyagari1994
