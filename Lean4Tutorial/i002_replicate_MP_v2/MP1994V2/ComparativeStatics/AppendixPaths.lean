import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions.Appendix
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixParameterChanges
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Equilibrium.Reduced

/-! # MP1994 v2 Appendix: supplied differentiable equilibrium paths

These records are the explicit analytic closure used in M8.  They assume that
the robust JD and JC equations hold locally, but assume neither derivative
signs nor any Appendix conclusion.
-/

open Filter
open scoped Topology

namespace MP1994V2

/-- A supplied differentiable local solution path of the robust reduced
equilibrium equations.  No existence claim is made. -/
structure LocalReducedEquilibriumPath
    (Ppath : ℝ → Primitives) (t0 : ℝ) where
  theta : ℝ → ℝ
  cutoff : ℝ → ℝ
  thetaSlope : ℝ
  cutoffSlope : ℝ
  theta_hasDerivAt : HasDerivAt theta thetaSlope t0
  cutoff_hasDerivAt : HasDerivAt cutoff cutoffSlope t0
  theta_pos : 0 < theta t0
  cutoff_lt_epsUpper : cutoff t0 < (Ppath t0).epsUpper
  jd_eventually :
    ∀ᶠ t in 𝓝 t0,
      (Ppath t).SatisfiesJobDestructionMeasure (theta t) (cutoff t)
  jc_eventually :
    ∀ᶠ t in 𝓝 t0,
      (Ppath t).SatisfiesJobCreationProduct (theta t) (cutoff t)

namespace LocalReducedEquilibriumPath

def theta0 {Ppath : ℝ → Primitives} {t0 : ℝ}
    (L : LocalReducedEquilibriumPath Ppath t0) : ℝ := L.theta t0

def cutoff0 {Ppath : ℝ → Primitives} {t0 : ℝ}
    (L : LocalReducedEquilibriumPath Ppath t0) : ℝ := L.cutoff t0

end LocalReducedEquilibriumPath

abbrev LambdaEquilibriumPath (P : Primitives) :=
  LocalReducedEquilibriumPath (fun x => P.withShockArrivalRate x) P.lambda

abbrev DiscountEquilibriumPath (P : Primitives) :=
  LocalReducedEquilibriumPath (fun x => P.withDiscountRate x) P.r

abbrev DispersionEquilibriumPath (P : Primitives) :=
  LocalReducedEquilibriumPath (fun x => P.withDispersion x) P.sigma

/-- A supplied differentiable JD path for equation (11), holding tightness
fixed.  Job creation is deliberately not assumed. -/
structure FixedTightnessSigmaPath (P : Primitives) (theta : ℝ) where
  cutoff : ℝ → ℝ
  cutoffSlope : ℝ
  cutoff_hasDerivAt : HasDerivAt cutoff cutoffSlope P.sigma
  theta_pos : 0 < theta
  cutoff_lt_epsUpper : cutoff P.sigma < P.epsUpper
  jd_eventually :
    ∀ᶠ sigma in 𝓝 P.sigma,
      (P.withDispersion sigma).SatisfiesJobDestructionMeasure
        theta (cutoff sigma)

end MP1994V2
