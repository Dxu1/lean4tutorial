import Mathlib.Analysis.Calculus.ImplicitContDiff
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitResiduals

/-! # M8b.1 generic scalar implicit-function wrapper -/

open Filter ContinuousLinearMap
open scoped Topology ContDiff

namespace MP1994V2

/-- A reusable scalar IFT.  Nondegeneracy is supplied as a proved nonzero
cutoff derivative and converted here into Mathlib's invertible partial map. -/
theorem exists_localImplicitCutoffPath
    {G : ℝ → ℝ → ℝ} {t0 d0 a : ℝ}
    (hG : ContDiffAt ℝ 1 (fun z : ℝ × ℝ => G z.1 z.2) (t0, d0))
    (hroot : G t0 d0 = 0)
    (hpartial : HasDerivAt (fun d => G t0 d) a d0)
    (ha : a ≠ 0) :
    ∃ g : ℝ → ℝ,
      g t0 = d0 ∧
      ContDiffAt ℝ 1 g t0 ∧
      DifferentiableAt ℝ g t0 ∧
      (∀ᶠ t in 𝓝 t0, G t (g t) = 0) ∧
      (∀ᶠ z : ℝ × ℝ in 𝓝 (t0, d0),
        G z.1 z.2 = 0 ↔ g z.1 = z.2) := by
  let f : ℝ × ℝ → ℝ := fun z => G z.1 z.2
  let u : ℝ × ℝ := (t0, d0)
  let dPartial := fderiv ℝ f u ∘L inr ℝ ℝ ℝ
  have hpair : HasFDerivAt (fun d : ℝ => (t0, d)) (inr ℝ ℝ ℝ) d0 := by
    exact hasFDerivAt_prodMk_right t0 d0
  have hslice : HasFDerivAt (fun d => G t0 d) dPartial d0 := by
    change HasFDerivAt (f ∘ fun d : ℝ => (t0, d)) dPartial d0
    exact (hG.differentiableAt (by norm_num)).hasFDerivAt.comp d0 hpair
  have hpartialEq : dPartial = toSpanSingleton ℝ a := by
    exact hslice.unique hpartial.hasFDerivAt
  have hspanInv : (toSpanSingleton ℝ a).IsInvertible := by
    let ua : ℝˣ := Units.mk0 a ha
    refine ⟨ContinuousLinearEquiv.smulLeft (R₁ := ℝ) (M₁ := ℝ) ua, ?_⟩
    ext x
    simp [ua, Units.smul_def]
  have hpartialInv : dPartial.IsInvertible := by
    rw [hpartialEq]
    exact hspanInv
  let g : ℝ → ℝ := hG.implicitFunction (by norm_num) hpartialInv
  refine ⟨g, ?_, ?_, ?_, ?_, ?_⟩
  · exact hG.implicitFunction_apply_self (by norm_num) hpartialInv
  · exact hG.contDiffAt_implicitFunction (by norm_num) hpartialInv
  · exact (hG.contDiffAt_implicitFunction (by norm_num) hpartialInv).differentiableAt
      (by norm_num)
  · have heq := hG.eventually_apply_implicitFunction (by norm_num) hpartialInv
    filter_upwards [heq] with t ht
    simpa [f, u, g, hroot] using ht
  · have huniq := hG.eventually_apply_eq_iff_implicitFunction
      (by norm_num) hpartialInv
    filter_upwards [huniq] with z hz
    simpa [f, u, g, hroot] using hz

end MP1994V2
