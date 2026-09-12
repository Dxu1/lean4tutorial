import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitFunctionFoundation
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixComparativeStatics

/-! # M8b.2: IFT-derived discount-rate equilibrium path -/

open Filter Set
open scoped Topology ContDiff

namespace MP1994V2
namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

/-- The scalar crossing equation and JD graph construct a local reduced
equilibrium path as the discount rate varies. -/
theorem exists_discountEquilibriumPath_of_ift
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    ∃ L : DiscountEquilibriumPath P,
      L.cutoff P.r = R.cutoff ∧ L.theta P.r = R.theta := by
  let G : ℝ → ℝ → ℝ := P.discountStaticResidual
  have hG : ContDiffAt ℝ 1 (fun z : ℝ × ℝ => G z.1 z.2)
      (P.r, R.cutoff) :=
    R.discountStaticResidual_contDiffAt A D IFT
  have hslice : DifferentiableAt ℝ (fun d => G P.r d) R.cutoff := by
    have hpair : DifferentiableAt ℝ (fun d : ℝ => (P.r, d)) R.cutoff :=
      (differentiableAt_const P.r).prodMk differentiableAt_id
    exact (hG.differentiableAt (by norm_num)).comp R.cutoff hpair
  obtain ⟨g, hg0, hgcont, hgdiff, hgroot, _⟩ :=
    exists_localImplicitCutoffPath hG
      (R.discountStaticResidual_base_eq_zero A)
      hslice.hasDerivAt
      (R.discountStaticResidual_cutoffDerivative_ne A D M AM)
  let theta : ℝ → ℝ := fun t => P.discountJobDestructionTheta t (g t)
  have hpairCont : ContDiffAt ℝ 1 (fun t : ℝ => (t, g t)) P.r :=
    contDiffAt_id.prodMk hgcont
  have hthetaCont : ContDiffAt ℝ 1 theta P.r := by
    have hjoint := R.discountJobDestructionTheta_contDiffAt A D
    rw [← hg0] at hjoint
    exact hjoint.comp P.r hpairCont
  have htheta0 : theta P.r = R.theta := by
    simpa [theta, hg0] using R.discountJobDestructionTheta_base_eq A
  have hrPos : ∀ᶠ t in 𝓝 P.r, 0 < t := Ioi_mem_nhds A.r_pos
  have hcutoffUpper : ∀ᶠ t in 𝓝 P.r, g t < P.epsUpper :=
    hgcont.continuousAt.tendsto (Iio_mem_nhds (by simpa [hg0] using
      R.cutoff_lt_epsUpper))
  have hthetaPos : ∀ᶠ t in 𝓝 P.r, 0 < theta t :=
    hthetaCont.continuousAt.tendsto (Ioi_mem_nhds (by simpa [htheta0] using
      R.theta_pos))
  have hjd : ∀ᶠ t in 𝓝 P.r,
      (P.withDiscountRate t).SatisfiesJobDestructionMeasure
        (theta t) (g t) := by
    filter_upwards [hrPos] with t ht
    exact ((P.withDiscountRate t).satisfiesJobDestructionMeasure_iff
      (A.withDiscountRate t ht) (theta t) (g t)).mpr rfl
  have hjc : ∀ᶠ t in 𝓝 P.r,
      (P.withDiscountRate t).SatisfiesJobCreationProduct
        (theta t) (g t) := by
    filter_upwards [hgroot] with t ht
    simpa only [G, theta, Primitives.discountStaticResidual,
      Primitives.discountJobDestructionTheta,
      Primitives.staticCrossingResidual, Primitives.jobCreationScale,
      Primitives.SatisfiesJobCreationProduct,
      Primitives.withDiscountRate_r,
      Primitives.withDiscountRate_lambda,
      Primitives.withDiscountRate_sigma,
      Primitives.withDiscountRate_beta,
      Primitives.withDiscountRate_c,
      Primitives.withDiscountRate_epsUpper,
      Primitives.withDiscountRate_q,
      sub_eq_zero, mul_assoc] using ht
  let L : DiscountEquilibriumPath P :=
    { theta := theta
      cutoff := g
      thetaSlope := deriv theta P.r
      cutoffSlope := deriv g P.r
      theta_hasDerivAt := hthetaCont.differentiableAt (by norm_num) |>.hasDerivAt
      cutoff_hasDerivAt := hgdiff.hasDerivAt
      theta_pos := by simpa [htheta0] using R.theta_pos
      cutoff_lt_epsUpper := by simpa [hg0] using R.cutoff_lt_epsUpper
      jd_eventually := hjd
      jc_eventually := hjc }
  exact ⟨L, hg0, htheta0⟩

/-- A noncomputably selected local discount-rate equilibrium path. -/
noncomputable def toDiscountEquilibriumPathIFT
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) : DiscountEquilibriumPath P :=
  Classical.choose (R.exists_discountEquilibriumPath_of_ift A D M AM IFT)

theorem toDiscountEquilibriumPathIFT_cutoff_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    (R.toDiscountEquilibriumPathIFT A D M AM IFT).cutoff P.r = R.cutoff :=
  (Classical.choose_spec
    (R.exists_discountEquilibriumPath_of_ift A D M AM IFT)).1

theorem toDiscountEquilibriumPathIFT_theta_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    (R.toDiscountEquilibriumPathIFT A D M AM IFT).theta P.r = R.theta :=
  (Classical.choose_spec
    (R.exists_discountEquilibriumPath_of_ift A D M AM IFT)).2

/-- The paper's discount comparative statics for the IFT-derived path. -/
theorem m8b_discount_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) :
    let L := R.toDiscountEquilibriumPathIFT A D M AM IFT
    L.thetaSlope < 0 ∧
      (0 < L.cutoffSlope ↔
        P.searchOpportunityCostCoefficient * L.theta P.r /
            P.matchingElasticity (L.theta P.r) <
          P.lambda * P.sigma / (P.r + P.lambda) *
            P.expectedExcess (L.cutoff P.r)) := by
  exact (R.toDiscountEquilibriumPathIFT A D M AM IFT).m8_discount_capstone
    A D M AM

end ReducedEquilibrium
end MP1994V2
