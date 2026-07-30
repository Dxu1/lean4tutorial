# MP1994V2: value equilibrium, affine surplus, and reservation cutoff

`MP1994V2` is the clean, staged replication architecture for Mortensen and
Pissarides (1994), implemented through Milestone 2. The legacy `MP1994` files
remain unchanged and can be consulted for generic Lean techniques, but their
economic architecture is not inherited.

The v2 design separates:

- **primitives**: exogenous parameters, the shock measure, and the meeting-rate
  function;
- **assumptions**: layered economic signs, shock regularity, optional moment
  normalization, and matching restrictions;
- **equilibrium definitions**: candidate values and paper equations (1)-(7);
- **theorem modules**: results proved in dependency order; M1 derives the
  surplus Bellman equation (8), and M2 derives affine surplus, the reservation
  rule, and equation (12).

## Import graph

```text
Definitions
  ├── Assumptions
  │     ├── Probability
  │     └── Matching
  └──────────────┘
          ↓
  Equilibrium.Value
          ↓
  SteadyState.Surplus
          ↓
  SteadyState.AffineSurplus
          ↓
  SteadyState.Cutoff
          ↓
         All
          ↓
        Audit
```

`All.lean` imports the eight substantive modules directly, including the three
theorem modules under `SteadyState`. `Audit.lean` imports
`All.lean` and adds compile-time checks. No substantive Milestone 0 module or
`All.lean` imports `Audit.lean`, and no Milestone 0 module imports a future
theorem directory.

## Milestone 0 scope

Milestone 0 provides:

- `Primitives`;
- `CoreEconomicAssumptions`;
- `ShockAssumptions`;
- `ShockNormalizationAssumptions`;
- `MatchingAssumptions`;
- the CDF derived from `Primitives.shock`;
- vacancy and worker meeting rates;
- surplus and active surplus derived from `J`, `W`, and `U`;
- one shared measure-theoretic continuation term;
- `ValueCandidate` and `ValueEquilibrium`;
- compile-time interface and no-`sorry` audits.

The optional shock normalization is not required by `ValueEquilibrium`.
Integrability of active surplus is labeled as value-function admissibility.

## Probability contract for later theorems

`ValueEquilibrium P` records equations (1)-(7) for raw primitives. It does not
silently install probability normalization or bundle the distributional
assumptions into the equilibrium structure.

Probability-based theorems explicitly take `D : ShockAssumptions P`. The
paper-level equation (8) wrapper installs `D.isProbability` locally as an
`IsProbabilityMeasure P.shock` instance before invoking the theorem stated
under the minimal probability typeclass.

`epsUpper` is the designated productivity state of a newly formed job in
equations (1) and (7). The field `ShockAssumptions.upperSupport` states
`P.shock (Set.Ioi P.epsUpper) = 0`, so it is also an almost-sure upper bound
under that assumption bundle. The development does not prove that `epsUpper`
is the maximal or exact endpoint of the topological support.

## Paper equations (1)-(7)

| Paper equation | `ValueEquilibrium` interface | Content |
|---|---|---|
| (1) | `vacancy_bellman` | `r V = -c + q(theta) [J(epsUpper) - V]` |
| (2) | `free_entry` | `r V = 0` |
| (3) | definition `surplus`; theorem `surplus_eq` | `S(eps) = J(eps) + W(eps) - U` |
| (4) | `nash_sharing` | `W(eps) - U = beta S(eps)` |
| (5) | `filled_job_bellman` | filled-job value equation using `continuationTerm` |
| (6) | `worker_bellman` | employed-worker value equation using the same `continuationTerm` |
| (7) | `unemployed_bellman` | `r U = b + theta q(theta) [W(epsUpper) - U]` |

Equation (3) is not stored as an independent consistency condition: it is true
by the definition of surplus.

## Milestone 1: equation (8)

`SteadyState/Surplus.lean` proves:

- the probability-measure decomposition of `continuationTerm`;
- the firm's Nash share from equations (3) and (4);
- the pre-normalization surplus flow equation from equations (5)-(7);
- paper equation (8) under `[IsProbabilityMeasure P.shock]`;
- a paper-facing wrapper taking `ShockAssumptions P`.

The actual `ValueEquilibrium` surplus is used throughout. Equation (8) is a
theorem, not a structure field or assumption.

## Milestone 2: affine surplus and reservation cutoff

`SteadyState/AffineSurplus.lean` subtracts equation (8) at two states, derives
the affine surplus-difference identity, and proves that actual equilibrium
surplus is strictly increasing.

`SteadyState/Cutoff.lean` defines `ValueEquilibrium.reservationCutoff` from the
actual equilibrium values and proves that it is the unique surplus zero.
Separately, equations (1)-(2), positive vacancy cost and meeting, and
`beta < 1` imply that the cutoff lies strictly below `epsUpper`. The cutoff is
derived rather than assumed and is not a field of `ValueEquilibrium`.

M2 remains conditional on an existing `ValueEquilibrium`; it does not prove
joint existence or uniqueness of `(theta, epsD)`. The continuation identity
(9), job-destruction equation (10), and job-creation equation (13) remain
future milestones.

## Prohibited shortcuts

M2 has now derived, rather than assumed, affine surplus, strict monotonicity,
the unique surplus zero, an endogenous reservation cutoff, the surplus and
firm-value reservation rules, and equation (12).

The development still contains no equation (9) tail-integral result, equation
(10) job-destruction condition, equation (13) job-creation condition, reduced
equilibrium, joint-equilibrium existence or uniqueness, unemployment equation
(14), comparative statics, cyclical or Markov extension, or finite-state
witness. M2 remains conditional on an existing `ValueEquilibrium`.

The new modules contain no `sorry`, `admit`, or project `axiom`.

## Builds

Run from the repository root:

```sh
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Definitions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Assumptions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Probability.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Matching.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Equilibrium/Value.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Surplus.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/AffineSurplus.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/SteadyState/Cutoff.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/All.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Audit.lean
lake build
```

`All.lean` is the substantive aggregate import. `Audit.lean` depends on it,
checks the public interfaces, runs `assert_no_sorry` through M2, and prints
transitive axioms for the main equation (8), unique-zero, admissibility,
equation (12), and active-surplus theorems.

The cumulative human-readable theorem account is in
`docs/proof_ledger.{md,tex,pdf}`.

## Review archives

Beginning with Milestone 3, review bundles use the project-local names
`review_m3.zip`, `review_m4.zip`, and so on. Review archives remain untracked
and must never be committed.
