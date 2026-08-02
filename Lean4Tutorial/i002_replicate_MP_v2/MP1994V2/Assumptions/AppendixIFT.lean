import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions.Appendix

/-! # MP1994 v2 Appendix: implicit-function regularity

This layer adds only local `C¹` regularity of the primitive matching function on
positive tightness.  It assumes neither an equilibrium path nor Jacobian
invertibility or any comparative-static conclusion.  The condition is the
technical smoothness counterpart of the paper's use of `q'` and matching
elasticity.
-/

open Set

namespace MP1994V2

/-- Primitive matching regularity used only by the M8b implicit-function
construction.  Elasticity restrictions remain in `AppendixMatchingAssumptions`. -/
structure AppendixIFTAssumptions (P : Primitives) : Prop where
  q_contDiffOn_pos : ContDiffOn ℝ 1 P.q (Ioi 0)

namespace AppendixIFTAssumptions

variable {P : Primitives}

theorem q_differentiableOn_pos (IFT : AppendixIFTAssumptions P) :
    DifferentiableOn ℝ P.q (Ioi 0) :=
  IFT.q_contDiffOn_pos.differentiableOn (by norm_num)

theorem q_continuousOn_pos (IFT : AppendixIFTAssumptions P) :
    ContinuousOn P.q (Ioi 0) :=
  IFT.q_contDiffOn_pos.continuousOn

theorem q_contDiffAt (IFT : AppendixIFTAssumptions P) {theta : ℝ}
    (htheta : 0 < theta) : ContDiffAt ℝ 1 P.q theta :=
  IFT.q_contDiffOn_pos.contDiffAt (Ioi_mem_nhds htheta)

end AppendixIFTAssumptions

end MP1994V2
