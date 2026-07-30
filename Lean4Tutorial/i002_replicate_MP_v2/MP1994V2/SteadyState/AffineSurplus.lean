import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.Surplus

/-!
# MP1994 v2: affine surplus

This module begins Milestone 2 by subtracting paper equation (8) at two
idiosyncratic states.  The common continuation integral and upper-job search
term cancel, yielding the global affine-difference identity for the actual
`ValueEquilibrium` surplus.
-/

open MeasureTheory

namespace MP1994V2

namespace CoreEconomicAssumptions

variable {P : Primitives}

/-- The effective discount rate `r + λ` is positive under the core signs. -/
theorem r_add_lambda_pos (A : CoreEconomicAssumptions P) :
    0 < P.r + P.lambda :=
  add_pos_of_pos_of_nonneg A.r_pos A.lambda_nonneg

/-- The effective discount rate is nonzero. -/
theorem r_add_lambda_ne (A : CoreEconomicAssumptions P) :
    P.r + P.lambda ≠ 0 :=
  A.r_add_lambda_pos.ne'

/-- Positive productivity dispersion is nonzero. -/
theorem sigma_ne (A : CoreEconomicAssumptions P) :
    P.sigma ≠ 0 :=
  A.sigma_pos.ne'

/-- The affine surplus slope `σ / (r + λ)` is positive. -/
theorem surplus_slope_pos (A : CoreEconomicAssumptions P) :
    0 < P.sigma / (P.r + P.lambda) :=
  div_pos A.sigma_pos A.r_add_lambda_pos

/-- The firm's complementary Nash share `1 - β` is positive. -/
theorem one_sub_beta_pos (A : CoreEconomicAssumptions P) :
    0 < 1 - P.beta := by
  linarith [A.beta_lt_one]

end CoreEconomicAssumptions

namespace ValueEquilibrium

variable {P : Primitives}

/-- Subtracting equation (8) at `eps1` and `eps2` gives the minimal
two-point identity

`(r + λ) [S(eps2) - S(eps1)] = σ (eps2 - eps1)`.

Only probability normalization is needed; the expectation and upper-job
search terms are literally common to the two equation-(8) instances.
-/
theorem surplus_difference_scaled_of_probability
    [IsProbabilityMeasure P.shock]
    (E : ValueEquilibrium P) (eps1 eps2 : ℝ) :
    (P.r + P.lambda) *
        (E.toValueCandidate.surplus eps2 -
          E.toValueCandidate.surplus eps1) =
      P.sigma * (eps2 - eps1) := by
  have h2 := E.surplus_bellman_of_probability eps2
  have h1 := E.surplus_bellman_of_probability eps1
  -- The common integral and upper-support search term cancel on subtraction.
  linear_combination h2 - h1

/-- Paper-level wrapper for the scaled two-point surplus identity. -/
theorem surplus_difference_scaled
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) (eps1 eps2 : ℝ) :
    (P.r + P.lambda) *
        (E.toValueCandidate.surplus eps2 -
          E.toValueCandidate.surplus eps1) =
      P.sigma * (eps2 - eps1) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.surplus_difference_scaled_of_probability eps1 eps2

/-- Dividing the scaled identity by the positive effective discount rate gives
the affine-difference formula for actual equilibrium surplus.
-/
theorem surplus_difference
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) (eps1 eps2 : ℝ) :
    E.toValueCandidate.surplus eps2 -
        E.toValueCandidate.surplus eps1 =
      (P.sigma / (P.r + P.lambda)) * (eps2 - eps1) := by
  have h := E.surplus_difference_scaled_of_probability eps1 eps2
  field_simp [A.r_add_lambda_ne]
  simpa [mul_comm] using h

/-- Paper-level wrapper for the divided affine-difference identity. -/
theorem surplus_difference_of_shockAssumptions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) (eps1 eps2 : ℝ) :
    E.toValueCandidate.surplus eps2 -
        E.toValueCandidate.surplus eps1 =
      (P.sigma / (P.r + P.lambda)) * (eps2 - eps1) := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.surplus_difference A eps1 eps2

/-- The actual equilibrium surplus is globally strictly increasing on `ℝ`. -/
theorem surplus_strictMono
    [IsProbabilityMeasure P.shock]
    (A : CoreEconomicAssumptions P)
    (E : ValueEquilibrium P) :
    StrictMono E.toValueCandidate.surplus := by
  intro eps1 eps2 hlt
  have hDiff := E.surplus_difference A eps1 eps2
  have hSlope := A.surplus_slope_pos
  have hState : 0 < eps2 - eps1 := sub_pos.mpr hlt
  have hPositive :
      0 < (P.sigma / (P.r + P.lambda)) * (eps2 - eps1) :=
    mul_pos hSlope hState
  linarith

/-- Paper-level wrapper for strict monotonicity of surplus. -/
theorem surplus_strictMono_of_shockAssumptions
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (E : ValueEquilibrium P) :
    StrictMono E.toValueCandidate.surplus := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  exact E.surplus_strictMono A

end ValueEquilibrium

end MP1994V2
