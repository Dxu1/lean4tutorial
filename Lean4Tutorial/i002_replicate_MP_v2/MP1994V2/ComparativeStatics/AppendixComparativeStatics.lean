import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixFixedTightness
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixLambda
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixDiscount
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixDispersion

/-!
# M8 Appendix derivative comparative-statics capstones

These theorems collect conclusions already derived for supplied differentiable
local paths. They do not construct such paths, select an M5 equilibrium, or
assume a derivative sign.
-/

namespace MP1994V2

/-- Equation (11) and its exact fixed-tightness cutoff-sign characterization. -/
theorem FixedTightnessSigmaPath.m8_fixedTightness_capstone
    {P : Primitives} {theta : ℝ}
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : FixedTightnessSigmaPath P theta) :
    P.sigma * L.cutoffSlope =
        ((P.r + P.lambda) / P.sigma) /
          (P.r + P.lambda * P.cdf (L.cutoff P.sigma)) *
          (P.p - P.b - P.searchOpportunityCostCoefficient * theta)
      ∧
    (0 < L.cutoffSlope ↔
      P.b + P.searchOpportunityCostCoefficient * theta < P.p) := by
  exact ⟨L.equation11 A D, L.cutoffSlope_pos_iff A D⟩

/-- Lambda comparative-statics capstone. The hypothesis `hLambda` is the
economic-interiority qualification for interpreting the ordinary derivatives
as two-sided responses around a positive shock-arrival rate. The low-level
Appendix identities and signs remain valid under the core restriction
`0 ≤ P.lambda`. -/
theorem LambdaEquilibriumPath.m8_lambda_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : LambdaEquilibriumPath P) (hLambda : 0 < P.lambda) :
    L.cutoffSlope < 0 ∧ L.thetaSlope < 0 := by
  exact ⟨L.cutoffSlope_neg A D M AM, L.thetaSlope_neg A D M AM⟩

/-- Discount comparative-statics capstone: tightness falls, while the cutoff
derivative has the exact A8 sign characterization and no maintained sign. -/
theorem DiscountEquilibriumPath.m8_discount_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (M : MatchingAssumptions P) (AM : AppendixMatchingAssumptions P)
    (L : DiscountEquilibriumPath P) :
    L.thetaSlope < 0
      ∧
    (0 < L.cutoffSlope ↔
      P.searchOpportunityCostCoefficient * L.theta P.r /
          P.matchingElasticity (L.theta P.r) <
        P.lambda * P.sigma / (P.r + P.lambda) *
          P.expectedExcess (L.cutoff P.r)) := by
  exact ⟨L.thetaSlope_neg A D M AM,
    L.cutoffSlope_pos_iff_A8_rhs_pos A D M AM⟩

/-- Dispersion comparative-statics capstone: tightness rises, and the cutoff
rises under the sufficient condition `b ≤ p`. Normalization is needed for the
A11 tightness result but not for the cutoff theorem. -/
theorem DispersionEquilibriumPath.m8_dispersion_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (N : ShockNormalizationAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P) (L : DispersionEquilibriumPath P)
    (hbp : P.b ≤ P.p) :
    0 < L.thetaSlope ∧ 0 < L.cutoffSlope := by
  exact ⟨L.thetaSlope_pos A D N M AM,
    L.cutoffSlope_pos_of_b_le_p A D M AM hbp⟩

/-- Overall M8 capstone for supplied fixed-tightness, lambda, discount, and
dispersion paths. Its assumptions contain no M5 equilibrium selection or
implicit-function theorem. -/
theorem m8_appendix_capstone
    {P : Primitives} {theta : ℝ}
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (N : ShockNormalizationAssumptions P) (M : MatchingAssumptions P)
    (AM : AppendixMatchingAssumptions P)
    (F : FixedTightnessSigmaPath P theta)
    (L : LambdaEquilibriumPath P) (R : DiscountEquilibriumPath P)
    (S : DispersionEquilibriumPath P)
    (hLambda : 0 < P.lambda) (hbp : P.b ≤ P.p) :
    (P.sigma * F.cutoffSlope =
        ((P.r + P.lambda) / P.sigma) /
          (P.r + P.lambda * P.cdf (F.cutoff P.sigma)) *
          (P.p - P.b - P.searchOpportunityCostCoefficient * theta)
      ∧
      (0 < F.cutoffSlope ↔
        P.b + P.searchOpportunityCostCoefficient * theta < P.p))
      ∧
    (L.cutoffSlope < 0 ∧ L.thetaSlope < 0)
      ∧
    (R.thetaSlope < 0
      ∧
      (0 < R.cutoffSlope ↔
        P.searchOpportunityCostCoefficient * R.theta P.r /
            P.matchingElasticity (R.theta P.r) <
          P.lambda * P.sigma / (P.r + P.lambda) *
            P.expectedExcess (R.cutoff P.r)))
      ∧
    (0 < S.thetaSlope ∧ 0 < S.cutoffSlope) := by
  exact ⟨F.m8_fixedTightness_capstone A D,
    ⟨L.m8_lambda_capstone A D M AM hLambda,
      ⟨R.m8_discount_capstone A D M AM,
        S.m8_dispersion_capstone A D N M AM hbp⟩⟩⟩

end MP1994V2
