# Dependency graph

The exact acyclic edges are in `contracts/theorems.json`. The thematic graph is:

```text
P01–P03: primitives, budgets, nonvacuity
    |
H01–H05: Bellman fixed point, optimal policy, lifetime verification
    |
H07–H14: order, right value marginals, envelope, Euler, thresholds
    |                         \
H06 + D02–D03: continuity/drift  N01–N04: zero state and bounded Jensen
    |                           |
S01–S05: kernel, mixing,         N05–N07: critical nonstationarity
         unique stable law       |
    |                            |
S06 + A01–A03: law continuity,   |
               aggregation       |
    \____________________________/
                    |
B01–B03: tightness and asset-supply boundary limits
                    |
F01–F02 + G01–G08: firms, noncircular equilibrium, existence,
                  rate/capital/gross-saving comparisons

P01 + feasible-history probability -> NP01–NP03: No-Ponzi equivalence
Core household/aggregation         -> E01–E03: exact extension identities
H02–H04                            -> D01: continuous-state Inada diagnostic
```

D01 is a diagnostic, not a premise of equilibrium existence. The critical nonstationarity proof does not use subcritical invariant-law existence, curvature, or compact asset bounds. Keeping this separation prevents an equilibrium conclusion from being smuggled into a stationary-law assumption.
