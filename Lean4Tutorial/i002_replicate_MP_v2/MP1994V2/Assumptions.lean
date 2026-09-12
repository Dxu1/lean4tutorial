import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Definitions

/-!
# MP1994 v2: layered assumptions

Economic signs, shock-law regularity, normalization, and matching technology
are intentionally separate.  Later theorem families should import only the
bundles they actually need.
-/

open MeasureTheory Set

namespace MP1994V2

/-- Primitive sign and bargaining restrictions used by the economic core.

No restriction on `p - b` is imposed here.
-/
structure CoreEconomicAssumptions (P : Primitives) : Prop where
  r_pos : 0 < P.r
  lambda_nonneg : 0 ≤ P.lambda
  sigma_pos : 0 < P.sigma
  beta_pos : 0 < P.beta
  beta_lt_one : P.beta < 1
  c_pos : 0 < P.c

/-- Distributional assumptions needed for expectations in the value system.

The shock law itself is the primitive.  `NullSingletonClass P.shock` is the
exact measure-theoretic form of the paper's "no mass points" condition.
-/
structure ShockAssumptions (P : Primitives) : Prop where
  isProbability : IsProbabilityMeasure P.shock
  upperSupport : P.shock (Ioi P.epsUpper) = 0
  noAtoms : NullSingletonClass P.shock
  firstMomentIntegrable : Integrable (fun eps : ℝ => eps) P.shock

/-- Mean-zero, unit-second-moment normalization from the paper.

This optional bundle is deliberately not required by `ValueEquilibrium`.
-/
structure ShockNormalizationAssumptions (P : Primitives) : Prop where
  firstMomentIntegrable : Integrable (fun eps : ℝ => eps) P.shock
  secondMomentIntegrable : Integrable (fun eps : ℝ => eps ^ 2) P.shock
  mean_zero : ∫ eps, eps ∂P.shock = 0
  secondMoment_one : ∫ eps, eps ^ 2 ∂P.shock = 1

/-- Matching restrictions on the economically relevant domain `θ > 0`. -/
structure MatchingAssumptions (P : Primitives) : Prop where
  vacancyMeetingRate_pos :
    ∀ ⦃theta : ℝ⦄, 0 < theta → 0 < P.vacancyMeetingRate theta
  vacancyMeetingRate_strictAntiOn :
    StrictAntiOn P.vacancyMeetingRate (Ioi 0)
  workerMeetingRate_monotoneOn :
    MonotoneOn P.workerMeetingRate (Ioi 0)

end MP1994V2
