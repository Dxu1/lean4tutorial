import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.FiniteStateKernel

/-!
# MP1994 v2: finite-state Markov equilibrium representation

Equations (32)--(34) define a supplied continuous-time finite-state
equilibrium. M10.1 proves no existence or uniqueness theorem, and it does not
claim a general reservation-sign characterization around each stored cutoff.
-/

open MeasureTheory Set

namespace MP1994V2

/-- Candidate tightness, cutoff, and raw surplus functions. Meeting hazards,
active surplus, and expectations remain derived objects. -/
structure FiniteMarkovCandidate (P : Primitives) {ι : Type*} [Fintype ι]
    (K : FiniteAggregateProcess P ι) where
  theta : ι → ℝ
  cutoff : ι → ℝ
  surplus : ι → ℝ → ℝ

namespace FiniteMarkovCandidate

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι}

/-- The unemployed-worker meeting hazard `theta_i*q(theta_i)`. -/
def workerMeetingHazard (C : FiniteMarkovCandidate P K) (i : ι) : ℝ :=
  P.workerMeetingRate (C.theta i)

/-- Raw surplus truncated at zero after a new aggregate mark. -/
def activeSurplus (C : FiniteMarkovCandidate P K) (i : ι) (eps : ℝ) : ℝ :=
  max (C.surplus i eps) 0

/-- Surplus of matches that survive the state-`i` cutoff, integrated over the
paper's almost-sure shock support. -/
noncomputable def survivingSurplusIntegral
    (C : FiniteMarkovCandidate P K) (i : ι) : ℝ :=
  ∫ x in Icc (C.cutoff i) P.epsUpper, C.surplus i x ∂P.shock

end FiniteMarkovCandidate

/-- A supplied finite-state equilibrium satisfying paper equations (32)--(34).

The structure stores no meeting hazard, active surplus, integral, cutoff
ordering, surplus monotonicity, employment stock, or existence witness.
-/
structure FiniteMarkovEquilibrium (P : Primitives) {ι : Type*} [Fintype ι]
    (K : FiniteAggregateProcess P ι)
    extends FiniteMarkovCandidate P K where
  theta_pos : ∀ i, 0 < theta i
  cutoff_lt_epsUpper : ∀ i, cutoff i < P.epsUpper
  surviving_surplus_integrable :
    ∀ i, Integrable (fun x => surplus i x)
      (P.shock.restrict (Icc (cutoff i) P.epsUpper))
  equation32_freeEntry :
    ∀ i, P.q (theta i) * (1 - P.beta) * surplus i P.epsUpper = P.c
  equation33_cutoff :
    ∀ i, surplus i (cutoff i) = 0
  equation34_surplus :
    ∀ i eps,
      (P.r + P.lambda + K.aggregateArrival) * surplus i eps =
        K.commonProductivity i + P.sigma * eps - P.b
          - P.workerMeetingRate (theta i) * P.beta * surplus i P.epsUpper
          + P.lambda *
              toFiniteMarkovCandidate.survivingSurplusIntegral i
          + K.aggregateArrival *
              K.nextExpectation i
                (fun j => toFiniteMarkovCandidate.activeSurplus j eps)

end MP1994V2
