import Mathlib

/-!
# Mortensen--Pissarides (1994), v2: primitive definitions

This module contains only the paper's exogenous objects and notation needed for
the primitive value system (1)--(7).  In particular, it contains no endogenous
reservation threshold and no closed-form surplus.
-/

open MeasureTheory

namespace MP1994V2

/-- Exogenous parameters of the stationary Mortensen--Pissarides (1994) model.

The paper writes `λ`, `σ`, `β`, and `εᵤ`; the corresponding ASCII Lean fields
are `lambda`, `sigma`, `beta`, and `epsUpper`.  The shock law is the measure
`shock`; a CDF is derived from it in `Probability.lean`.
-/
structure Primitives where
  /-- `r`: continuous-time discount rate. -/
  r : ℝ
  /-- `λ`: Poisson arrival rate of job-specific productivity shocks. -/
  lambda : ℝ
  /-- `σ`: scale (dispersion) of idiosyncratic productivity. -/
  sigma : ℝ
  /-- `β`: worker's Nash share of match surplus. -/
  beta : ℝ
  /-- `c`: flow cost of maintaining a vacancy. -/
  c : ℝ
  /-- `b`: unemployment income or the flow value of leisure. -/
  b : ℝ
  /-- `p`: common component of match productivity. -/
  p : ℝ
  /-- `εᵤ`: finite upper support point for a newly formed match. -/
  epsUpper : ℝ
  /-- Probability law of the idiosyncratic shock `ε`. -/
  shock : Measure ℝ
  /-- `q(θ)`: vacancy meeting rate at market tightness `θ`. -/
  q : ℝ → ℝ

namespace Primitives

variable (P : Primitives)

/-- Flow productivity `p + σ ε` of a match in idiosyncratic state `ε`. -/
def productivity (eps : ℝ) : ℝ :=
  P.p + P.sigma * eps

/-- Vacancy meeting rate `q(θ)`. -/
def vacancyMeetingRate (theta : ℝ) : ℝ :=
  P.q theta

/-- Worker meeting rate `θ q(θ)`. -/
def workerMeetingRate (theta : ℝ) : ℝ :=
  theta * P.q theta

end Primitives

/-- Project-local notation for the positive part `max x 0`. -/
def positivePart (x : ℝ) : ℝ :=
  max x 0

/-- Match surplus from primitive value objects, paper equation (3):
`S(ε) = J(ε) + W(ε) - U`.

Surplus is derived from `J`, `W`, and `U`; it is never an independent
equilibrium field.
-/
def surplus (J W : ℝ → ℝ) (U eps : ℝ) : ℝ :=
  J eps + W eps - U

/-- Surplus retained after the costless destruction option:
`max {S(ε), 0}`. -/
def activeSurplus (J W : ℝ → ℝ) (U eps : ℝ) : ℝ :=
  positivePart (surplus J W U eps)

/-- The common continuation term in paper equations (5) and (6):

`∫ [max {S(x), 0} - S(ε)] dF(x)`.

Both Bellman equations call this single definition, so their continuation
values cannot drift apart syntactically.
-/
noncomputable def continuationTerm
    (P : Primitives) (J W : ℝ → ℝ) (U eps : ℝ) : ℝ :=
  ∫ x, (activeSurplus J W U x - surplus J W U eps) ∂P.shock

end MP1994V2
