import Aiyagari1994.Analysis.M05D.Stability

/-! Compact one-dimensional monotone--Feller stability. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal Topology ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- S04: a monotone Feller Markov kernel on a nonempty compact real interval, with a
common-horizon endpoint-crossing bound, has a unique invariant probability law. Every initial
probability law converges weakly to it. The final conjunct records the geometric endpoint
oscillation contraction used for uniqueness. -/
theorem compact_monotone_feller_stability
    {a b : ℝ} (hab : a ≤ b) (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x))
    (d : CI a b) (N : ℕ) (hN : 1 ≤ N) (eps : ℝ) (heps0 : 0 < eps) (heps1 : eps ≤ 1)
    (hCross : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      eps * f d + (1 - eps) * f ⟨a, le_rfl, hab⟩ ≤
          (testStep k hFeller)^[N] f ⟨a, le_rfl, hab⟩ ∧
        (testStep k hFeller)^[N] f ⟨b, hab, le_rfl⟩ ≤
          eps * f d + (1 - eps) * f ⟨b, hab, le_rfl⟩) :
    (∃! pi : ProbabilityMeasure (CI a b),
      lawStep k pi = pi ∧
      ∀ mu : ProbabilityMeasure (CI a b),
        Tendsto (fun n ↦ (lawStep k)^[n] mu) atTop (𝓝 pi)) ∧
    ∀ (f : BoundedContinuousFunction (CI a b) ℝ), Monotone f → ∀ m,
      ((testStep k hFeller)^[N])^[m] f ⟨b, hab, le_rfl⟩ -
          ((testStep k hFeller)^[N])^[m] f ⟨a, le_rfl, hab⟩ ≤
        (1 - eps) ^ m * (f ⟨b, hab, le_rfl⟩ - f ⟨a, le_rfl, hab⟩) := by
  exact M05D_compact_monotone_feller_stability hab k hFeller hMono d N hN eps
    heps0 heps1 hCross

end
end Aiyagari1994
