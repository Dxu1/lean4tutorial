import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ExpectedExcessDerivative
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.AppendixPaths
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.StaticCurves

/-! # Fixed-tightness dispersion calculation (paper equation (11)) -/

open Filter
open scoped Topology

namespace MP1994V2

namespace FixedTightnessSigmaPath

variable {P : Primitives} {theta : ℝ}

private theorem jd_derivative
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : FixedTightnessSigmaPath P theta) :
    L.cutoff P.sigma + P.sigma * L.cutoffSlope
      + P.lambda / (P.r + P.lambda) * P.expectedExcess (L.cutoff P.sigma)
      - (P.lambda * P.sigma / (P.r + P.lambda))
          * (1 - P.cdf (L.cutoff P.sigma)) * L.cutoffSlope = 0 := by
  let d0 := L.cutoff P.sigma
  have hH := (P.hasDerivAt_expectedExcess D L.cutoff_lt_epsUpper).comp
    P.sigma L.cutoff_hasDerivAt
  have hc := (hasDerivAt_id P.sigma).mul_const
    (P.lambda / (P.r + P.lambda))
  have hJD : HasDerivAt
      (fun s => P.p + s * L.cutoff s - P.b
        - (P.beta * P.c / (1 - P.beta)) * theta
        + (s * (P.lambda / (P.r + P.lambda))) *
            P.expectedExcess (L.cutoff s))
      (L.cutoff P.sigma + P.sigma * L.cutoffSlope
        + P.lambda / (P.r + P.lambda) * P.expectedExcess d0
        - (P.lambda * P.sigma / (P.r + P.lambda)) *
            (1 - P.cdf d0) * L.cutoffSlope) P.sigma := by
    have hcalc := ((((hasDerivAt_const P.sigma P.p).add
      ((hasDerivAt_id P.sigma).mul L.cutoff_hasDerivAt)).sub
      (hasDerivAt_const P.sigma P.b)).sub
      (hasDerivAt_const P.sigma
        ((P.beta * P.c / (1 - P.beta)) * theta))).add
      (hc.mul hH)
    convert hcalc using 1
    all_goals first | rfl | (simp [id, Function.comp_apply, d0] <;> ring)
  have hEq : (fun s => P.p + s * L.cutoff s - P.b
        - (P.beta * P.c / (1 - P.beta)) * theta
        + (s * (P.lambda / (P.r + P.lambda))) *
            P.expectedExcess (L.cutoff s)) =ᶠ[𝓝 P.sigma] fun _ => 0 := by
    filter_upwards [L.jd_eventually] with s hs
    simpa [Primitives.SatisfiesJobDestructionMeasure,
      Primitives.jobDestructionResidualMeasure, Primitives.expectedExcess,
      Primitives.withDispersion, div_eq_mul_inv, mul_assoc, mul_left_comm,
      mul_comm] using hs
  have hz := (hasDerivAt_const P.sigma (0 : ℝ)).congr_of_eventuallyEq hEq
  exact hJD.unique hz

/-- Paper equation (11), conditional on the supplied fixed-tightness JD path. -/
theorem equation11
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : FixedTightnessSigmaPath P theta) :
    P.sigma * L.cutoffSlope =
      ((P.r + P.lambda) / P.sigma) /
          (P.r + P.lambda * P.cdf (L.cutoff P.sigma)) *
        (P.p - P.b - P.searchOpportunityCostCoefficient * theta) := by
  have hder := jd_derivative A D L
  have hbase : P.SatisfiesJobDestructionMeasure theta (L.cutoff P.sigma) := by
    simpa only [Primitives.withDispersion_r, Primitives.withDispersion_lambda,
      Primitives.withDispersion_sigma, Primitives.withDispersion_beta,
      Primitives.withDispersion_c, Primitives.withDispersion_b,
      Primitives.withDispersion_p, Primitives.expectedExcess,
      Primitives.withDispersion]
      using L.jd_eventually.self_of_nhds
  have hs : P.sigma ≠ 0 := A.sigma_ne
  have hrl : P.r + P.lambda ≠ 0 := A.r_add_lambda_ne
  have hden : P.r + P.lambda * P.cdf (L.cutoff P.sigma) ≠ 0 :=
    (P.r_add_lambda_cdf_pos A _).ne'
  unfold Primitives.SatisfiesJobDestructionMeasure
    Primitives.jobDestructionResidualMeasure at hbase
  unfold Primitives.searchOpportunityCostCoefficient
  have hrel : P.sigma^2 *
      (P.r + P.lambda * P.cdf (L.cutoff P.sigma)) * L.cutoffSlope =
      (P.r + P.lambda) *
        (P.p - P.b - P.beta * P.c / (1-P.beta) * theta) := by
    field_simp [hrl] at hder hbase
    linear_combination -hbase + P.sigma * hder
  let X := P.p - P.b - P.beta * P.c / (1-P.beta) * theta
  let den := P.r + P.lambda * P.cdf (L.cutoff P.sigma)
  have hden' : den ≠ 0 := hden
  calc
    P.sigma * L.cutoffSlope =
        (P.sigma^2 * den * L.cutoffSlope) / (P.sigma * den) := by
          field_simp [hs, hden']
    _ = ((P.r + P.lambda) * X) / (P.sigma * den) := by
          dsimp [X, den]
          rw [hrel]
    _ = ((P.r + P.lambda) / P.sigma) / den * X := by ring

/-- The fixed-tightness cutoff response has exactly the sign stated below. -/
theorem cutoffSlope_pos_iff
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (L : FixedTightnessSigmaPath P theta) :
    0 < L.cutoffSlope ↔
      P.b + P.searchOpportunityCostCoefficient * theta < P.p := by
  rw [show 0 < L.cutoffSlope ↔ 0 < P.sigma * L.cutoffSlope by
    exact (mul_pos_iff_of_pos_left A.sigma_pos).symm]
  rw [L.equation11 A D]
  have hpref : 0 < (P.r + P.lambda) / P.sigma /
      (P.r + P.lambda * P.cdf (L.cutoff P.sigma)) :=
    div_pos (div_pos A.r_add_lambda_pos A.sigma_pos)
      (P.r_add_lambda_cdf_pos A _)
  rw [mul_pos_iff_of_pos_left hpref]
  unfold Primitives.searchOpportunityCostCoefficient
  constructor <;> intro h <;> linarith

end FixedTightnessSigmaPath

end MP1994V2
