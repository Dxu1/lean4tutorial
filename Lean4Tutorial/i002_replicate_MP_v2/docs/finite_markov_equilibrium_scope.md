# M10.1 scope: finite-state continuous-time Markov equilibrium

**Status:** COMPLETE - GREEN (human review: 2026-08-04)

M10.1 formalizes the Section 5 equilibrium representation in paper equations
(32)-(34). It is conditional on a supplied `FiniteMarkovEquilibrium`; it does
not prove existence or uniqueness.

Human review found the representation faithful to the paper's continuous-time
equations (32)-(34). `aggregateArrival` is a marked-Poisson rate;
`transitionWeight i j` is the conditional distribution of the next aggregate
mark, with nonnegative unit-sum rows. Equation (32) keeps `q(theta_i)` distinct
from `theta_i*q(theta_i)`, while equation (34) contains the finite-state term
`mu * sum_j pi_ij * max (S_j eps) 0`. No existence, uniqueness, cutoff-sign
theorem, or conversion of a continuous-time rate into a one-period probability
is embedded. The deterministic-other-state construction faithfully embeds the
reviewed M9 two-state model.

## Economic system

For finite aggregate state `i`, `FiniteAggregateProcess.commonProductivity i`
is common productivity, `aggregateArrival` is the nonnegative marked-Poisson
arrival rate, and `transitionWeight i j` is the conditional probability of
next mark `j`. `FiniteAggregateProcessAssumptions` requires nonnegative weights
and unit row sums. The induced finite conditional expectation is

```text
nextExpectation K i f = sum_j transitionWeight i j * f j.
```

It preserves constants and addition, commutes with scalar multiplication, and
preserves nonnegativity and pointwise order.

`FiniteMarkovCandidate` stores only statewise tightness, cutoff, and raw
surplus. The worker meeting hazard is derived as `theta_i * q(theta_i)`, active
surplus is derived as `max (S_i eps) 0`, and the surviving-surplus integral is
derived by integrating `S_i` on `[d_i, epsUpper]` against `P.shock`.

`FiniteMarkovEquilibrium` adds positivity and integrability admissibility and
records exactly:

```text
q(theta_i) * (1-beta) * S_i(epsUpper) = c                 (32)
S_i(d_i) = 0                                               (33)
(r+lambda+mu) * S_i(eps)
  = p_i + sigma*eps - b
    - [theta_i*q(theta_i)] * beta * S_i(epsUpper)
    + lambda * integral_[d_i,epsUpper] S_i(x) dF(x)
    + mu * sum_j pi_ij * max(S_j(eps), 0).                 (34)
```

Here `P.shock` is the shock law, so Lean integration against `P.shock`
represents integration with respect to the induced `dF`. Vacancy contact
`q(theta_i)`, worker meeting `theta_i*q(theta_i)`, and any aggregate flow that
would multiply the worker rate by unemployment are distinct objects. The
worker rate is therefore derived from tightness, never stored independently.

## Public declarations

- Process: `FiniteAggregateProcess`, `FiniteAggregateProcessAssumptions`, and
  `FiniteAggregateProcess.statePrimitives`.
- Kernel: `FiniteAggregateProcess.nextExpectation` and the laws
  `nextExpectation_zero`, `nextExpectation_const`, `nextExpectation_add`,
  `nextExpectation_smul`, `nextExpectation_nonneg`, and
  `nextExpectation_mono`.
- Equilibrium: `FiniteMarkovCandidate`, `FiniteMarkovEquilibrium`, and the
  derived `workerMeetingHazard`, `activeSurplus`, and
  `survivingSurplusIntegral`.
- Paper equations: `FiniteMarkovEquilibrium.equation32`, `equation33`, and
  `equation34`.
- Immediate consequences: `q_mul_upperSurplus_eq`, `upperSurplus_pos`,
  `workerMeetingHazard_pos`, and `aggregateContinuation_nonneg`.
- Capstones: `FiniteMarkovEquilibrium.m10_1_finiteMarkov_capstone`,
  `m10_1_finiteState_foundations_capstone`, and
  `m10_1_twoState_foundations_capstone`.

The process assumptions are only nonnegative aggregate arrival and
row-stochastic finite weights. Statewise transports reuse
`CoreEconomicAssumptions`, `ShockAssumptions`, and `MatchingAssumptions`.
There is no irreducibility, productivity order, density, static-existence, or
equilibrium-selection assumption. The equilibrium stores no cutoff sign rule,
surplus monotonicity, employment stock, or numerical residual tolerance.

## Two-state specialization

`TwoStatePrimitives.toFiniteAggregateProcess` gives the recession/boom model a
deterministic-other-state kernel. Its row weights are stochastic and
`nextExpectation_toFiniteAggregateProcess` proves that expectation is exactly
evaluation at `i.other`. For every supplied M9 `TwoStateValueEquilibrium`,
`toFiniteMarkovCandidate` and `toFiniteMarkovEquilibrium` preserve tightness,
the derived reservation cutoff, and actual surplus. The embedding uses the M9
coupled surplus Bellman equation, interval-integral theorem, cutoff theorem,
and free-entry identity. It is forward only and does not select a two-state
equilibrium from primitives.

## Hard time-scale boundary

> `P.lambda` and `aggregateArrival` are continuous-time rates in M10.1.
> M10.2 must introduce explicit one-period probabilities before using
> coefficients such as `1 - redrawProb`.

M10.1 defines no employment transition and never interprets `1 - P.lambda`
as a probability. M10.2 is reserved for a measure-valued discrete-time
transition with a separate redraw probability and upper-support creation atom.
M10.3 is reserved for creation, destruction, no-double-counting, and the
employment-mass identity in equations (36)-(38). Both are NOT STARTED.

The three-state calibration, nonlinear numerical solution, simulation, and
equations (39)-(42) remain outside core Lean. Equation (31) also remains
unimplemented.
