import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStatePrimitives

/-!
# MP1994 v2: primitive two-state value equilibrium

This is the anticipated two-state analogue of equations (1)--(7).  Surplus and
all continuation objects are derived from value functions, never stored as
independent equilibrium data.
-/

open MeasureTheory

namespace MP1994V2

/-- Candidate value functions and state-contingent market tightness. -/
structure TwoStateValueCandidate where
  theta : AggregateState → ℝ
  V : AggregateState → ℝ
  U : AggregateState → ℝ
  J : AggregateState → ℝ → ℝ
  W : AggregateState → ℝ → ℝ
  wage : AggregateState → ℝ → ℝ

namespace TwoStateValueCandidate

/-- State-contingent match surplus, derived from `J`, `W`, and `U`. -/
def surplus (C : TwoStateValueCandidate) (s : AggregateState) (eps : ℝ) : ℝ :=
  C.J s eps + C.W s eps - C.U s

/-- State-contingent positive surplus retained after the destruction option. -/
def activeSurplus (C : TwoStateValueCandidate) (s : AggregateState) (eps : ℝ) : ℝ :=
  positivePart (C.surplus s eps)

/-- The common idiosyncratic-shock continuation term in the two Bellman equations. -/
noncomputable def idiosyncraticContinuation (C : TwoStateValueCandidate)
    (P : Primitives) (s : AggregateState) (eps : ℝ) : ℝ :=
  continuationTerm P (C.J s) (C.W s) (C.U s) eps

/-- Surplus change at an aggregate transition, including the destruction option. -/
def aggregateSurplusTransition (C : TwoStateValueCandidate)
    (s : AggregateState) (eps : ℝ) : ℝ :=
  C.activeSurplus s.other eps - C.surplus s eps

/-- Worker's aggregate-transition continuation value.

It combines the unemployment-state change with the worker's Nash share of the
aggregate surplus transition and is reused verbatim in the worker equation.
-/
def workerAggregateContinuation (C : TwoStateValueCandidate)
    (P : Primitives) (s : AggregateState) (eps : ℝ) : ℝ :=
  C.U s.other - C.U s + P.beta * C.aggregateSurplusTransition s eps

end TwoStateValueCandidate

/-- Primitive anticipated two-state value equilibrium.

The equations use the raw primitives and the shared continuation definitions
above.  No cutoff, cutoff ordering, affine formula, reduced equilibrium, or
existence conclusion is a field of this structure.
-/
structure TwoStateValueEquilibrium (P : Primitives) (T : TwoStatePrimitives P)
    extends TwoStateValueCandidate where
  theta_pos : ∀ s, 0 < theta s
  active_surplus_integrable :
    ∀ s, Integrable (fun eps => toTwoStateValueCandidate.activeSurplus s eps) P.shock
  vacancy_bellman : ∀ s,
    P.r * V s =
      -P.c + P.q (theta s) * (J s P.epsUpper - V s)
        + T.aggregateArrival * (V s.other - V s)
  free_entry : ∀ s, P.r * V s = 0
  nash_sharing : ∀ s eps,
    W s eps - U s = P.beta * toTwoStateValueCandidate.surplus s eps
  filled_job_bellman : ∀ s eps,
    P.r * J s eps =
      T.productivity s eps - wage s eps
        + P.lambda * (1 - P.beta) *
            toTwoStateValueCandidate.idiosyncraticContinuation P s eps
        + T.aggregateArrival * (1 - P.beta) *
            toTwoStateValueCandidate.aggregateSurplusTransition s eps
  worker_bellman : ∀ s eps,
    P.r * W s eps =
      wage s eps
        + P.lambda * P.beta *
            toTwoStateValueCandidate.idiosyncraticContinuation P s eps
        + T.aggregateArrival *
            toTwoStateValueCandidate.workerAggregateContinuation P s eps
  unemployed_bellman : ∀ s,
    P.r * U s =
      P.b + P.workerMeetingRate (theta s) * (W s P.epsUpper - U s)
        + T.aggregateArrival * (U s.other - U s)

end MP1994V2
