import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.JobDestruction
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.JobCreation

/-!
# MP1994 v2: reduced static equilibrium

The reduced equilibrium retains only market tightness and the reservation
productivity.  Its two economic conditions use robust, non-divided forms of
job destruction and job creation.  It is not the full steady state: no
unemployment stock is present.
-/

namespace MP1994V2

namespace Primitives

/-- Robust product-form job-creation condition.  Unlike paper equation (13),
this predicate does not divide by the productivity gap. -/
def SatisfiesJobCreationProduct
    (P : Primitives) (theta d : ℝ) : Prop :=
  P.q theta
      * (1 - P.beta)
      * (P.sigma / (P.r + P.lambda))
      * (P.epsUpper - d) =
    P.c

end Primitives

/-- The two-variable reduced static equilibrium.

The stored equations are the measure-form job-destruction condition and the
product-form job-creation condition.  Paper-facing tail and quotient forms are
derived theorems.
-/
structure ReducedEquilibrium (P : Primitives) where
  theta : ℝ
  cutoff : ℝ
  theta_pos : 0 < theta
  cutoff_lt_epsUpper : cutoff < P.epsUpper
  jobDestructionMeasure :
    P.SatisfiesJobDestructionMeasure theta cutoff
  jobCreationProduct :
    P.SatisfiesJobCreationProduct theta cutoff

namespace ReducedEquilibrium

variable {P : Primitives} (R : ReducedEquilibrium P)

theorem cutoff_le_epsUpper :
    R.cutoff ≤ P.epsUpper :=
  R.cutoff_lt_epsUpper.le

theorem epsUpper_sub_cutoff_pos :
    0 < P.epsUpper - R.cutoff :=
  sub_pos.mpr R.cutoff_lt_epsUpper

theorem epsUpper_sub_cutoff_ne :
    P.epsUpper - R.cutoff ≠ 0 :=
  R.epsUpper_sub_cutoff_pos.ne'

@[ext]
theorem ext
    {R₁ R₂ : ReducedEquilibrium P}
    (hTheta : R₁.theta = R₂.theta)
    (hCutoff : R₁.cutoff = R₂.cutoff) :
    R₁ = R₂ := by
  cases R₁
  cases R₂
  simp_all

end ReducedEquilibrium

end MP1994V2
