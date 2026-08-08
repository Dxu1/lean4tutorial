import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitComparativeStatics
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitDiscount
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ImplicitDispersion

/-! # M8b.2 capstone: IFT-derived Appendix paths -/

namespace MP1994V2
namespace ReducedEquilibrium

/-- Full Appendix comparative statics for paths constructed locally from a
supplied reduced equilibrium. No path, M5 selection, derivative sign, or
nondegeneracy assumption is supplied. -/
theorem m8b_full_appendix_capstone
    {P : Primitives} (R : ReducedEquilibrium P)
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (N : ShockNormalizationAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (IFT : AppendixIFTAssumptions P)
    (hLambda : 0 < P.lambda) (hbp : P.b ≤ P.p) :
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
      ; L.cutoffSlope < 0 ∧ L.thetaSlope < 0)
      ∧
    (let Q := R.toDiscountEquilibriumPathIFT A D M AM IFT
      ;
      Q.thetaSlope < 0 ∧
        (0 < Q.cutoffSlope ↔
          P.searchOpportunityCostCoefficient * Q.theta P.r /
              P.matchingElasticity (Q.theta P.r) <
            P.lambda * P.sigma / (P.r + P.lambda) *
              P.expectedExcess (Q.cutoff P.r)))
      ∧
    (let S := R.toDispersionEquilibriumPathIFT A D M AM IFT
      ; 0 < S.thetaSlope ∧ 0 < S.cutoffSlope) := by
  exact ⟨R.m8b_fixedTightness_capstone A D,
    R.m8b_lambda_capstone A D M AM IFT hLambda,
    R.m8b_discount_capstone A D M AM IFT,
    R.m8b_dispersion_capstone A D N M AM IFT hbp⟩

end ReducedEquilibrium
end MP1994V2
