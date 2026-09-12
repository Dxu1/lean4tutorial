import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitFunctionFoundation
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixComparativeStatics

/-! # M8b.2: IFT-derived dispersion equilibrium path -/

open Filter Set
open scoped Topology ContDiff

namespace MP1994V2
namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

/-- The scalar crossing equation and JD graph construct a local reduced
equilibrium path as dispersion varies. -/
theorem exists_dispersionEquilibriumPath_of_ift
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    ∃ L : DispersionEquilibriumPath P,
      L.cutoff P.sigma = R.cutoff ∧ L.theta P.sigma = R.theta := by
  let G : ℝ → ℝ → ℝ := P.dispersionStaticResidual
  have hG : ContDiffAt ℝ 1 (fun z : ℝ × ℝ => G z.1 z.2)
      (P.sigma, R.cutoff) :=
    R.dispersionStaticResidual_contDiffAt A D IFT
  have hslice : DifferentiableAt ℝ (fun d => G P.sigma d) R.cutoff := by
    have hpair : DifferentiableAt ℝ (fun d : ℝ => (P.sigma, d)) R.cutoff :=
      (differentiableAt_const P.sigma).prodMk differentiableAt_id
    exact (hG.differentiableAt (by norm_num)).comp R.cutoff hpair
  obtain ⟨g, hg0, hgcont, hgdiff, hgroot, _⟩ :=
    exists_localImplicitCutoffPath hG
      (R.dispersionStaticResidual_base_eq_zero A)
      hslice.hasDerivAt
      (R.dispersionStaticResidual_cutoffDerivative_ne A D M AM)
  let theta : ℝ → ℝ := fun t => P.dispersionJobDestructionTheta t (g t)
  have hpairCont : ContDiffAt ℝ 1 (fun t : ℝ => (t, g t)) P.sigma :=
    contDiffAt_id.prodMk hgcont
  have hthetaCont : ContDiffAt ℝ 1 theta P.sigma := by
    have hjoint := R.dispersionJobDestructionTheta_contDiffAt A D
    rw [← hg0] at hjoint
    exact hjoint.comp P.sigma hpairCont
  have htheta0 : theta P.sigma = R.theta := by
    simpa [theta, hg0] using R.dispersionJobDestructionTheta_base_eq A
  have hsigmaPos : ∀ᶠ t in 𝓝 P.sigma, 0 < t := Ioi_mem_nhds A.sigma_pos
  have hcutoffUpper : ∀ᶠ t in 𝓝 P.sigma, g t < P.epsUpper :=
    hgcont.continuousAt.tendsto (Iio_mem_nhds (by simpa [hg0] using
      R.cutoff_lt_epsUpper))
  have hthetaPos : ∀ᶠ t in 𝓝 P.sigma, 0 < theta t :=
    hthetaCont.continuousAt.tendsto (Ioi_mem_nhds (by simpa [htheta0] using
      R.theta_pos))
  have hjd : ∀ᶠ t in 𝓝 P.sigma,
      (P.withDispersion t).SatisfiesJobDestructionMeasure
        (theta t) (g t) := by
    filter_upwards [hsigmaPos] with t ht
    exact ((P.withDispersion t).satisfiesJobDestructionMeasure_iff
      (A.withDispersion t ht) (theta t) (g t)).mpr rfl
  have hjc : ∀ᶠ t in 𝓝 P.sigma,
      (P.withDispersion t).SatisfiesJobCreationProduct
        (theta t) (g t) := by
    filter_upwards [hgroot] with t ht
    simpa only [G, theta, Primitives.dispersionStaticResidual,
      Primitives.dispersionJobDestructionTheta,
      Primitives.staticCrossingResidual, Primitives.jobCreationScale,
      Primitives.SatisfiesJobCreationProduct,
      Primitives.withDispersion_r,
      Primitives.withDispersion_lambda,
      Primitives.withDispersion_sigma,
      Primitives.withDispersion_beta,
      Primitives.withDispersion_c,
      Primitives.withDispersion_epsUpper,
      Primitives.withDispersion_q,
      sub_eq_zero, mul_assoc] using ht
  let L : DispersionEquilibriumPath P :=
    { theta := theta
      cutoff := g
      thetaSlope := deriv theta P.sigma
      cutoffSlope := deriv g P.sigma
      theta_hasDerivAt := hthetaCont.differentiableAt (by norm_num) |>.hasDerivAt
      cutoff_hasDerivAt := hgdiff.hasDerivAt
      theta_pos := by simpa [htheta0] using R.theta_pos
      cutoff_lt_epsUpper := by simpa [hg0] using R.cutoff_lt_epsUpper
      jd_eventually := hjd
      jc_eventually := hjc }
  exact ⟨L, hg0, htheta0⟩

/-- A noncomputably selected local dispersion equilibrium path. -/
noncomputable def toDispersionEquilibriumPathIFT
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) : DispersionEquilibriumPath P :=
  Classical.choose (R.exists_dispersionEquilibriumPath_of_ift A D M AM IFT)

theorem toDispersionEquilibriumPathIFT_cutoff_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    (R.toDispersionEquilibriumPathIFT A D M AM IFT).cutoff P.sigma =
      R.cutoff :=
  (Classical.choose_spec
    (R.exists_dispersionEquilibriumPath_of_ift A D M AM IFT)).1

theorem toDispersionEquilibriumPathIFT_theta_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    (R.toDispersionEquilibriumPathIFT A D M AM IFT).theta P.sigma =
      R.theta :=
  (Classical.choose_spec
    (R.exists_dispersionEquilibriumPath_of_ift A D M AM IFT)).2

/-- The paper's dispersion derivative signs for the IFT-derived path. -/
theorem m8b_dispersion_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (N : ShockNormalizationAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (IFT : AppendixIFTAssumptions P)
    (hbp : P.b ≤ P.p) :
    let L := R.toDispersionEquilibriumPathIFT A D M AM IFT
    0 < L.thetaSlope ∧ 0 < L.cutoffSlope := by
  exact (R.toDispersionEquilibriumPathIFT A D M AM IFT).m8_dispersion_capstone
    A D N M AM hbp

end ReducedEquilibrium
end MP1994V2
