import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.StaticCurves

/-!
# MP1994 v2: explicit static-existence closure assumptions

Curve slopes imply uniqueness but do not ensure an intersection.  This
separate analytic bundle supplies continuity of `q` on positive tightness and
a lower point with a strictly positive crossing residual.  It contains no
root, equilibrium witness, or uniqueness conclusion.  The upper negative
endpoint is derived from `staticCrossingResidual_epsUpper` and `c > 0`.
-/

open Set

namespace MP1994V2

/-- Sufficient bracket conditions for existence of the static equilibrium.

Continuity is consistent with the paper's use of `q' < 0`; the lower crossing
closes an endpoint condition not fully stated in the paper. -/
structure StaticExistenceAssumptions (P : Primitives) : Prop where
  q_continuousOn_pos : ContinuousOn P.q (Ioi 0)
  lower_crossing :
    ∃ d0 : ℝ,
      d0 < P.epsUpper ∧
      0 < P.jobDestructionTheta d0 ∧
      0 < P.staticCrossingResidual d0

end MP1994V2
