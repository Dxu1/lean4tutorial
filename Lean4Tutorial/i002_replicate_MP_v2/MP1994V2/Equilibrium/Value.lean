import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Probability
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Matching

/-!
# MP1994 v2: primitive value equilibrium

`ValueEquilibrium` records exactly paper equations (1)--(7).  Surplus is
computed from `J`, `W`, and `U`; there is no cutoff or reduced equilibrium.
-/

open MeasureTheory

namespace MP1994V2

/-- A candidate solution of the stationary asset-value system. -/
structure ValueCandidate where
  /-- `θ = v/u`: market tightness. -/
  theta : MarketTightness
  /-- `V`: value of an open vacancy. -/
  V : ℝ
  /-- `U`: value of unemployment. -/
  U : ℝ
  /-- `J(ε)`: firm's value of a filled job. -/
  J : ℝ → ℝ
  /-- `W(ε)`: worker's value of employment. -/
  W : ℝ → ℝ
  /-- `w(ε)`: state-contingent wage. -/
  wage : ℝ → ℝ

namespace ValueCandidate

variable (C : ValueCandidate)

/-- Candidate match surplus, defined rather than stored. -/
def surplus (eps : ℝ) : ℝ :=
  MP1994V2.surplus C.J C.W C.U eps

/-- Candidate active surplus `max {S(ε), 0}`. -/
def activeSurplus (eps : ℝ) : ℝ :=
  MP1994V2.activeSurplus C.J C.W C.U eps

/-- Candidate continuation term shared by the filled-job and worker equations. -/
noncomputable def continuation (P : Primitives) (eps : ℝ) : ℝ :=
  continuationTerm P C.J C.W C.U eps

end ValueCandidate

/-- Primitive stationary value equilibrium for paper equations (1)--(7).

The integrability field is technical admissibility for the Lebesgue integral,
not an economic conclusion.  No shock normalization is required.
-/
structure ValueEquilibrium (P : Primitives) extends ValueCandidate where
  theta_pos : 0 < theta
  /-- Value-function admissibility: active surplus has a finite expectation. -/
  active_surplus_integrable :
    Integrable (fun eps => activeSurplus J W U eps) P.shock
  /-- Paper equation (1): vacancy Bellman equation. -/
  vacancy_bellman :
    P.r * V =
      -P.c + P.vacancyMeetingRate theta * (J P.epsUpper - V)
  /-- Paper equation (2): free entry, kept in the paper's form `r V = 0`. -/
  free_entry :
    P.r * V = 0
  /-- Paper equation (4): Nash sharing, with equation (3) supplied by
  the definition `surplus J W U eps`. -/
  nash_sharing :
    ∀ eps, W eps - U = P.beta * MP1994V2.surplus J W U eps
  /-- Paper equation (5): filled-job Bellman equation. -/
  filled_job_bellman :
    ∀ eps,
      P.r * J eps =
        P.productivity eps - wage eps +
          P.lambda * (1 - P.beta) *
            continuationTerm P J W U eps
  /-- Paper equation (6): employed-worker Bellman equation. -/
  worker_bellman :
    ∀ eps,
      P.r * W eps =
        wage eps +
          P.lambda * P.beta *
            continuationTerm P J W U eps
  /-- Paper equation (7): unemployed-worker Bellman equation. -/
  unemployed_bellman :
    P.r * U =
      P.b + P.workerMeetingRate theta * (W P.epsUpper - U)

namespace ValueEquilibrium

variable {P : Primitives} (E : ValueEquilibrium P)

/-- Equation (3) as a definitional equality for a value equilibrium. -/
theorem surplus_eq (eps : ℝ) :
    E.toValueCandidate.surplus eps = E.J eps + E.W eps - E.U :=
  rfl

end ValueEquilibrium

end MP1994V2
