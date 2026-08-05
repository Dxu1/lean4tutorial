import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.FiniteStateEquilibriumConsequences

/-!
# MP1994 v2: discrete employment-transition parameters

Equation (35) uses a one-period redraw probability. This is deliberately a
new object and is not the continuous-time shock-arrival rate `P.lambda`.
-/

namespace MP1994V2

/-- Parameters used only by the discrete one-period employment transition. -/
structure DiscreteEmploymentParameters where
  redrawProb : NNReal
  redrawProb_le_one : redrawProb ≤ 1

namespace DiscreteEmploymentParameters

/-- Nonnegativity is supplied by the `NNReal` type. -/
theorem redrawProb_nonneg (DP : DiscreteEmploymentParameters) :
    0 ≤ DP.redrawProb := by positivity

/-- The probability of retaining the current idiosyncratic shock. -/
theorem one_sub_redrawProb_nonneg (DP : DiscreteEmploymentParameters) :
    0 ≤ 1 - DP.redrawProb := by positivity

/-- The real coercion of the redraw probability lies in the unit interval. -/
theorem redrawProb_coe_mem_unitInterval (DP : DiscreteEmploymentParameters) :
    (DP.redrawProb : ℝ) ∈ Set.Icc 0 1 := by
  constructor
  · exact_mod_cast DP.redrawProb_nonneg
  · exact_mod_cast DP.redrawProb_le_one

end DiscreteEmploymentParameters
end MP1994V2
