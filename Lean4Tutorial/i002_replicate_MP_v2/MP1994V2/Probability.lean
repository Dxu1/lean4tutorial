import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions

/-!
# MP1994 v2: probability objects

All distributional notation is derived from `Primitives.shock`.  There is no
independent CDF primitive.
-/

open MeasureTheory Set

namespace MP1994V2

namespace Primitives

variable (P : Primitives)

/-- Shock CDF `F(x) = shock ((-∞, x])`, converted from `ℝ≥0∞` to `ℝ`. -/
noncomputable def cdf (x : ℝ) : ℝ :=
  (P.shock (Iic x)).toReal

/-- Probability of a shock weakly below `x`, useful for later separation
probabilities.  It is an alias of the derived CDF, not a second primitive. -/
noncomputable abbrev shockBelow (x : ℝ) : ℝ :=
  P.cdf x

/-- Predicate saying that `u` is an upper support bound for the shock law. -/
def IsShockUpperBound (u : ℝ) : Prop :=
  P.shock (Ioi u) = 0

end Primitives

end MP1994V2
