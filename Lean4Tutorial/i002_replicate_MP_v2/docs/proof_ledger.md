# MP1994V2 proof ledger

This cumulative ledger records what Lean has actually proved. The milestone
tracker records project state; this document records theorem content,
dependencies, and adequacy.

## M1 - Surplus Bellman equation

**Paper reference:** Mortensen and Pissarides (1994), Section 3, journal
page 401, equation (8).

**Adequacy status:** COMPLETE — GREEN

### Mathematical statement

For the actual equilibrium surplus

```text
S(eps) = J(eps) + W(eps) - U,
```

Equation (8) is a conditional representation theorem: for every object
satisfying `ValueEquilibrium P`, Lean proves that the surplus derived from its
value functions satisfies, for every idiosyncratic state `eps`,

```text
(r + lambda) S(eps)
  = p + sigma eps - b
    + lambda ∫ max {S(x), 0} dF(x)
    - beta theta q(theta) S(epsUpper).
```

Here `P.shock` is the probability law of the idiosyncratic shock; its induced
CDF is `F`, and integration with respect to `dF` is represented in Lean by
integration against `P.shock`. Also,
`theta q(theta) = P.workerMeetingRate E.theta`.

M1 does not prove existence of a `ValueEquilibrium`.

### Economic interpretation

- `p + sigma eps` is current match output.
- `b` is the unemployment opportunity cost.
- `lambda ∫ max {S(x), 0} dF(x)` is the option value of future
  idiosyncratic productivity draws, allowing costless rejection of a
  nonpositive continuation surplus.
- `beta theta q(theta) S(epsUpper)` is the employed worker's foregone search
  gain at the upper-support job.

### Exact Lean declarations

| Role | Declaration |
|---|---|
| Continuation decomposition | `MP1994V2.continuationTerm_eq_integral_activeSurplus_sub` |
| Firm surplus share | `MP1994V2.ValueEquilibrium.firm_share` |
| Algebraic surplus flow | `MP1994V2.ValueEquilibrium.surplus_flow_equation` |
| Minimal probability theorem | `MP1994V2.ValueEquilibrium.surplus_bellman_of_probability` |
| Paper-level wrapper | `MP1994V2.ValueEquilibrium.surplus_bellman` |

### Assumptions actually used

- Equation (3), through the definition of actual surplus.
- Equation (4), Nash sharing, only to rewrite the upper-state worker gain.
- Equations (5) and (6), added to cancel the wage.
- Equation (7), subtracted to account for unemployment value.
- Probability normalization of `P.shock`.
- The existing `ValueEquilibrium.active_surplus_integrable` field.

The main probability theorem assumes only
`[IsProbabilityMeasure P.shock]`; the paper-level wrapper takes
`D : ShockAssumptions P`, installs `D.isProbability` locally, and uses no other
field of `D`.

### Assumptions deliberately not used

- Parameter sign restrictions.
- `CoreEconomicAssumptions`.
- Upper-support restrictions or support maximality.
- Atomlessness.
- Mean zero or unit variance.
- `ShockNormalizationAssumptions`.
- Matching positivity or monotonicity.
- `MatchingAssumptions`.
- Vacancy Bellman equation (1) or free entry equation (2).

### Proof ledger

First, equations (5) and (6) are added. The wage cancels and the Nash weights
sum to one:

```text
r [J(eps) + W(eps)]
  = p + sigma eps + lambda C(eps),
```

where

```text
C(eps) = ∫ [max {S(x), 0} - S(eps)] dF(x).
```

Subtracting equation (7), and using
`S(eps) = J(eps) + W(eps) - U`, gives the purely algebraic flow identity:

```text
r S(eps)
  = p + sigma eps - b
    + lambda C(eps)
    - theta q(theta) [W(epsUpper) - U].
```

Equation (4) at `epsUpper` gives:

```text
W(epsUpper) - U = beta S(epsUpper).
```

Because `P.shock` is a probability measure and active surplus is integrable:

```text
C(eps)
  = ∫ max {S(x), 0} dF(x) - S(eps).
```

Substitution and moving `-lambda S(eps)` to the left yields equation (8).

### Adequacy statement

The theorem uses the actual surplus of `ValueEquilibrium`; no replacement
surplus was defined. Equation (8) was derived rather than added as an
assumption or equilibrium field. No destruction cutoff, reservation rule, or
affine-surplus result was used. It is conditional on an existing
`ValueEquilibrium` and does not establish that such an equilibrium exists.

Human mathematical and economic review concluded that equation (8) matches the
paper and is derived non-circularly from equations (3)-(7). The actual
equilibrium surplus is used, with no cutoff, affinity result, or reduced
equilibrium. The theorem is explicitly conditional on an existing
`ValueEquilibrium`.

### Dependency unlocked

M2 may subtract equation (8) at two productivity states to derive the
two-point surplus-difference identity, then prove affine surplus and its
monotonicity consequences. No such M2 result is implemented here.
