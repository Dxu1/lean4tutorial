# MP1994V2: foundations and primitive value equilibrium

`MP1994V2` is the clean, staged replication architecture for Mortensen and
Pissarides (1994). The legacy `MP1994` files remain unchanged and can be
consulted for generic Lean techniques, but their economic architecture is not
inherited.

The v2 design separates:

- **primitives**: exogenous parameters, the shock measure, and the meeting-rate
  function;
- **assumptions**: layered economic signs, shock regularity, optional moment
  normalization, and matching restrictions;
- **equilibrium definitions**: candidate values and paper equations (1)-(7);
- **derived theorems**: future milestones only.

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
         All
          ↓
        Audit
```

`All.lean` imports the five substantive modules directly. `Audit.lean` imports
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

Probability-based theorems, beginning with Milestone 1, must explicitly take
`D : ShockAssumptions P`. In particular, the proof of equation (8) must install
`D.isProbability` locally as an `IsProbabilityMeasure P.shock` instance before
using probability-measure integral identities.

The field `ShockAssumptions.upperSupport` states
`P.shock (Set.Ioi P.epsUpper) = 0`. Thus `epsUpper` is an almost-sure upper
bound. Milestone 0 does not require the stronger statement that it is the
maximal or exact endpoint of the support.

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

## Prohibited shortcuts

Milestone 0 contains no endogenous destruction threshold, reservation rule,
affine surplus formula, surplus Bellman equation (8), tail-integral equation
(9), reduced job-destruction or job-creation equations, reduced equilibrium,
steady-state equilibrium, existence or uniqueness result, comparative static,
Markov equilibrium, or finite-state witness.

The new modules contain no `sorry`, `admit`, or project `axiom`.

## Builds

Run from the repository root:

```sh
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Definitions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Assumptions.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Probability.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Matching.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Equilibrium/Value.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/All.lean
lake env lean Lean4Tutorial/i002_replicate_MP_v2/MP1994V2/Audit.lean
lake build
```

`All.lean` is the substantive aggregate import. `Audit.lean` depends on it,
checks the public interfaces, runs `assert_no_sorry` on the two small helper
theorems, and prints their transitive axioms.
