import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitFixedTightness
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitLambda

/-! # M8b.1 capstone: IFT-derived paths -/

namespace MP1994V2

/-- Combined M8b.1 result.  Starting from a supplied reduced equilibrium, the
fixed-tightness sigma path and the lambda equilibrium path are constructed by
the IFT and satisfy the existing M8 conclusions. -/
theorem m8b1_implicit_paths_capstone
    {P : Primitives} (R : ReducedEquilibrium P)
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (IFT : AppendixIFTAssumptions P) (hLambda : 0 < P.lambda) :
    (let F := R.toFixedTightnessSigmaPathIFT A D
      ;
      P.sigma * F.cutoffSlope =
          ((P.r + P.lambda) / P.sigma) /
            (P.r + P.lambda * P.cdf (F.cutoff P.sigma)) *
            (P.p - P.b - P.searchOpportunityCostCoefficient * R.theta)
        ∧
      (0 < F.cutoffSlope ↔
        P.b + P.searchOpportunityCostCoefficient * R.theta < P.p))
      ∧
    (let L := R.toLambdaEquilibriumPathIFT A D M AM IFT hLambda
      ;
      L.cutoffSlope < 0 ∧ L.thetaSlope < 0) := by
  exact ⟨R.m8b_fixedTightness_capstone A D,
    R.m8b_lambda_capstone A D M AM IFT hLambda⟩

end MP1994V2
