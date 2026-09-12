import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitFunctionFoundation
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixComparativeStatics

/-! # M8b.1: IFT-derived lambda equilibrium path -/

open Filter Set
open scoped Topology ContDiff

namespace MP1994V2
namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

/-- The scalar crossing equation and JD graph construct a local reduced
equilibrium path as `lambda` varies. -/
theorem exists_lambdaEquilibriumPath_of_ift
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) (hLambda : 0 < P.lambda) :
    ∃ L : LambdaEquilibriumPath P,
      L.cutoff P.lambda = R.cutoff ∧ L.theta P.lambda = R.theta := by
  let G : ℝ → ℝ → ℝ := P.lambdaStaticResidual
  have hG : ContDiffAt ℝ 1 (fun z : ℝ × ℝ => G z.1 z.2)
      (P.lambda, R.cutoff) :=
    R.lambdaStaticResidual_contDiffAt A D IFT
  have hslice : DifferentiableAt ℝ (fun d => G P.lambda d) R.cutoff := by
    have hpair : DifferentiableAt ℝ (fun d : ℝ => (P.lambda, d)) R.cutoff :=
      (differentiableAt_const P.lambda).prodMk differentiableAt_id
    exact (hG.differentiableAt (by norm_num)).comp R.cutoff hpair
  obtain ⟨g, hg0, hgcont, hgdiff, hgroot, _⟩ :=
    exists_localImplicitCutoffPath hG
      (R.lambdaStaticResidual_base_eq_zero A)
      hslice.hasDerivAt
      (R.lambdaStaticResidual_cutoffDerivative_ne A D M AM)
  let theta : ℝ → ℝ := fun t => P.lambdaJobDestructionTheta t (g t)
  have hpairCont : ContDiffAt ℝ 1 (fun t : ℝ => (t, g t)) P.lambda :=
    contDiffAt_id.prodMk hgcont
  have hthetaCont : ContDiffAt ℝ 1 theta P.lambda := by
    have hjoint := R.lambdaJobDestructionTheta_contDiffAt A D
    rw [← hg0] at hjoint
    exact hjoint.comp P.lambda hpairCont
  have htheta0 : theta P.lambda = R.theta := by
    simpa [theta, hg0] using R.lambdaJobDestructionTheta_base_eq A
  have hlambdaPos : ∀ᶠ t in 𝓝 P.lambda, 0 < t :=
    Ioi_mem_nhds hLambda
  have hcutoffUpper : ∀ᶠ t in 𝓝 P.lambda, g t < P.epsUpper :=
    hgcont.continuousAt.tendsto (Iio_mem_nhds (by simpa [hg0] using
      R.cutoff_lt_epsUpper))
  have hthetaPos : ∀ᶠ t in 𝓝 P.lambda, 0 < theta t :=
    hthetaCont.continuousAt.tendsto (Ioi_mem_nhds (by simpa [htheta0] using
      R.theta_pos))
  have hjd : ∀ᶠ t in 𝓝 P.lambda,
      (P.withShockArrivalRate t).SatisfiesJobDestructionMeasure
        (theta t) (g t) := by
    filter_upwards [hlambdaPos] with t ht
    exact ((P.withShockArrivalRate t).satisfiesJobDestructionMeasure_iff
      (A.withShockArrivalRate t ht.le) (theta t) (g t)).mpr rfl
  have hjc : ∀ᶠ t in 𝓝 P.lambda,
      (P.withShockArrivalRate t).SatisfiesJobCreationProduct
        (theta t) (g t) := by
    filter_upwards [hgroot] with t ht
    simpa only [G, theta, Primitives.lambdaStaticResidual,
      Primitives.lambdaJobDestructionTheta,
      Primitives.staticCrossingResidual, Primitives.jobCreationScale,
      Primitives.SatisfiesJobCreationProduct,
      Primitives.withShockArrivalRate_r,
      Primitives.withShockArrivalRate_lambda,
      Primitives.withShockArrivalRate_sigma,
      Primitives.withShockArrivalRate_beta,
      Primitives.withShockArrivalRate_c,
      Primitives.withShockArrivalRate_epsUpper,
      Primitives.withShockArrivalRate_q,
      sub_eq_zero, mul_assoc] using ht
  let L : LambdaEquilibriumPath P :=
    { theta := theta
      cutoff := g
      thetaSlope := deriv theta P.lambda
      cutoffSlope := deriv g P.lambda
      theta_hasDerivAt := hthetaCont.differentiableAt (by norm_num) |>.hasDerivAt
      cutoff_hasDerivAt := hgdiff.hasDerivAt
      theta_pos := by simpa [htheta0] using R.theta_pos
      cutoff_lt_epsUpper := by simpa [hg0] using R.cutoff_lt_epsUpper
      jd_eventually := hjd
      jc_eventually := hjc }
  exact ⟨L, hg0, htheta0⟩

/-- A noncomputably selected local lambda equilibrium path. -/
noncomputable def toLambdaEquilibriumPathIFT
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) (hLambda : 0 < P.lambda) :
    LambdaEquilibriumPath P :=
  Classical.choose
    (R.exists_lambdaEquilibriumPath_of_ift A D M AM IFT hLambda)

theorem toLambdaEquilibriumPathIFT_cutoff_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) (hLambda : 0 < P.lambda) :
    (R.toLambdaEquilibriumPathIFT A D M AM IFT hLambda).cutoff P.lambda =
      R.cutoff :=
  (Classical.choose_spec
    (R.exists_lambdaEquilibriumPath_of_ift A D M AM IFT hLambda)).1

theorem toLambdaEquilibriumPathIFT_theta_base
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) (hLambda : 0 < P.lambda) :
    (R.toLambdaEquilibriumPathIFT A D M AM IFT hLambda).theta P.lambda =
      R.theta :=
  (Classical.choose_spec
    (R.exists_lambdaEquilibriumPath_of_ift A D M AM IFT hLambda)).2

/-- The paper's lambda derivative signs for the IFT-derived path. -/
theorem m8b_lambda_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) (hLambda : 0 < P.lambda) :
    let L := R.toLambdaEquilibriumPathIFT A D M AM IFT hLambda
    L.cutoffSlope < 0 ∧ L.thetaSlope < 0 := by
  exact (R.toLambdaEquilibriumPathIFT A D M AM IFT hLambda).m8_lambda_capstone
    A D M AM hLambda

end ReducedEquilibrium
end MP1994V2
