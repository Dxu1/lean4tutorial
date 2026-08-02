import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitFunctionFoundation
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixComparativeStatics

/-! # M8b.1: derived fixed-tightness sigma path -/

open Filter
open scoped Topology

namespace MP1994V2
namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

/-- The scalar IFT constructs a local fixed-tightness JD path through any
supplied reduced equilibrium.  No path or nondegeneracy condition is assumed. -/
theorem exists_fixedTightnessSigmaPath_of_ift
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    ∃ L : FixedTightnessSigmaPath P R.theta,
      L.cutoff P.sigma = R.cutoff := by
  let G : ℝ → ℝ → ℝ := fun sigma d =>
    P.fixedTightnessSigmaResidual R.theta sigma d
  have hG : ContDiffAt ℝ 1 (fun z : ℝ × ℝ => G z.1 z.2)
      (P.sigma, R.cutoff) :=
    R.fixedTightnessSigmaResidual_contDiffAt A D
  have hslice : DifferentiableAt ℝ (fun d => G P.sigma d) R.cutoff := by
    have hpair : DifferentiableAt ℝ (fun d : ℝ => (P.sigma, d)) R.cutoff :=
      (differentiableAt_const P.sigma).prodMk differentiableAt_id
    exact (hG.differentiableAt (by norm_num)).comp R.cutoff hpair
  obtain ⟨g, hg0, _, hgdiff, hgroot, _⟩ :=
    exists_localImplicitCutoffPath hG
      R.fixedTightnessSigmaResidual_base_eq_zero
      hslice.hasDerivAt
      (R.fixedTightnessSigma_cutoffDerivative_ne A D)
  let L : FixedTightnessSigmaPath P R.theta :=
    { cutoff := g
      cutoffSlope := deriv g P.sigma
      cutoff_hasDerivAt := hgdiff.hasDerivAt
      theta_pos := R.theta_pos
      cutoff_lt_epsUpper := by simpa [hg0] using R.cutoff_lt_epsUpper
      jd_eventually := by
        filter_upwards [hgroot] with sigma hsigma
        exact hsigma }
  exact ⟨L, hg0⟩

/-- A noncomputably selected local fixed-tightness sigma path. -/
noncomputable def toFixedTightnessSigmaPathIFT
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    FixedTightnessSigmaPath P R.theta :=
  Classical.choose (R.exists_fixedTightnessSigmaPath_of_ift A D)

theorem toFixedTightnessSigmaPathIFT_cutoff_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    (R.toFixedTightnessSigmaPathIFT A D).cutoff P.sigma = R.cutoff :=
  Classical.choose_spec (R.exists_fixedTightnessSigmaPath_of_ift A D)

/-- Equation (11) and its sign characterization for the IFT-derived path. -/
theorem m8b_fixedTightness_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P) :
    let L := R.toFixedTightnessSigmaPathIFT A D
    P.sigma * L.cutoffSlope =
        ((P.r + P.lambda) / P.sigma) /
          (P.r + P.lambda * P.cdf (L.cutoff P.sigma)) *
          (P.p - P.b - P.searchOpportunityCostCoefficient * R.theta)
      ∧
    (0 < L.cutoffSlope ↔
      P.b + P.searchOpportunityCostCoefficient * R.theta < P.p) := by
  exact (R.toFixedTightnessSigmaPathIFT A D).m8_fixedTightness_capstone A D

end ReducedEquilibrium
end MP1994V2
