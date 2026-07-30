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

M2 uses equation (8) as the reviewed dependency for the affine-surplus and
reservation results recorded next.

## M2 - Affine surplus and endogenous reservation cutoff

**Paper references:** Mortensen and Pissarides (1994), Section 3; journal
page 401, reservation-property paragraph; journal page 402, equation (12).

**Adequacy status:** COMPLETE — GREEN

### Mathematical statements

For every existing `ValueEquilibrium P`, equation (8) at two states implies

```text
(r + lambda) [S(eps2) - S(eps1)]
  = sigma (eps2 - eps1).
```

Under `r > 0`, `lambda >= 0`, and `sigma > 0`, this becomes

```text
S(eps2) - S(eps1)
  = [sigma / (r + lambda)] (eps2 - eps1),
```

so `S` is strictly increasing. Define the derived cutoff

```text
epsD
  = epsUpper
    - [(r + lambda) / sigma] S(epsUpper).
```

Lean proves on all of `R`:

```text
S(epsD) = 0,
S(eps) = 0  <->  eps = epsD,
S(eps) < 0  <->  eps < epsD,
0 <= S(eps)  <->  epsD <= eps.
```

Using `J(eps) = (1 - beta) S(eps)`, the corresponding firm-value signs are

```text
J(eps) < 0  <->  eps < epsD,
J(eps) = 0  <->  eps = epsD,
0 <= J(eps)  <->  epsD <= eps.
```

Paper equation (12) is represented explicitly:

```text
S(eps) - S(epsD)
  = sigma (eps - epsD) / (r + lambda).
```

The zero-anchored form and M3 bridge are:

```text
S(eps) = [sigma / (r + lambda)] (eps - epsD),
max {S(eps), 0}
  = [sigma / (r + lambda)] max {eps - epsD, 0}.
```

### Proof strategy and economic separation

The proof subtracts equation (8) at `eps2` and `eps1`. The continuation
integral and the upper-support search term cancel because neither depends on
the current state. The positive slope constructs a unique mathematical zero on
`R`.

Economic admissibility is a separate argument. Equation (2) and `r > 0` give
`V = 0`; substituting into equation (1) gives
`q(theta) J(epsUpper) = c`. Positive vacancy cost and meeting imply
`J(epsUpper) > 0`; because `1 - beta > 0`, upper-state surplus is positive.
Consequently `epsD < epsUpper`. Recruiting cost therefore places the
reservation productivity strictly below the productivity of a newly formed
upper-support match.

### Exact Lean declarations

| Role | Declaration |
|---|---|
| Positive effective discount rate | `MP1994V2.CoreEconomicAssumptions.r_add_lambda_pos` |
| Positive surplus slope | `MP1994V2.CoreEconomicAssumptions.surplus_slope_pos` |
| Scaled two-point identity | `MP1994V2.ValueEquilibrium.surplus_difference_scaled_of_probability` |
| Divided affine identity | `MP1994V2.ValueEquilibrium.surplus_difference` |
| Strict monotonicity | `MP1994V2.ValueEquilibrium.surplus_strictMono` |
| Derived cutoff | `MP1994V2.ValueEquilibrium.reservationCutoff` |
| Cutoff is a zero | `MP1994V2.ValueEquilibrium.surplus_reservationCutoff_eq_zero` |
| Unique zero characterization | `MP1994V2.ValueEquilibrium.surplus_eq_zero_iff` |
| Unique-zero existence | `MP1994V2.ValueEquilibrium.existsUnique_surplus_zero` |
| Vacancy value | `MP1994V2.ValueEquilibrium.vacancy_value_eq_zero` |
| Free-entry product | `MP1994V2.ValueEquilibrium.vacancy_meeting_mul_upper_firm_value_eq_cost` |
| Upper firm value | `MP1994V2.ValueEquilibrium.upper_firm_value_pos` |
| Upper surplus | `MP1994V2.ValueEquilibrium.upper_surplus_pos` |
| Cutoff below upper endpoint | `MP1994V2.ValueEquilibrium.reservationCutoff_lt_epsUpper` |
| Admissible cutoff | `MP1994V2.ValueEquilibrium.reservationCutoff_is_admissible` |
| Paper equation (12) | `MP1994V2.ValueEquilibrium.equation12` |
| Surplus reservation rule | `MP1994V2.ValueEquilibrium.surplus_neg_iff_lt_reservationCutoff` |
| Firm destruction rule | `MP1994V2.ValueEquilibrium.firm_value_neg_iff_lt_reservationCutoff` |
| Active-surplus bridge | `MP1994V2.ValueEquilibrium.activeSurplus_eq_slope_mul_positivePart` |
| M2 capstone | `MP1994V2.ValueEquilibrium.milestone2_capstone` |

The capstone explicitly includes

```text
for every eps, S(eps) = 0 <-> eps = reservationCutoff,
```

rather than merely asserting an unidentified unique zero.

### Assumptions by proof block

The affinity and cutoff theorems formally take
`A : CoreEconomicAssumptions P`. Within that bundle their proof terms access:

- `A.r_pos`;
- `A.lambda_nonneg`;
- `A.sigma_pos`.

Economic admissibility additionally accesses:

- `A.c_pos`;
- `A.beta_lt_one`;
- vacancy Bellman equation (1) and free entry equation (2);
- equilibrium `theta > 0`;
- positivity of `q(theta)`.

The paper-facing admissibility and capstone theorems formally take
`M : MatchingAssumptions P`. Their proof terms access only
`M.vacancyMeetingRate_pos`. The monotonicity fields remain part of the bundled
theorem premise even though they are not referenced by the proof term.

Wrappers taking `D : ShockAssumptions P` use only `D.isProbability` in the M2
affinity and zero arguments. The remaining distributional fields are carried
by the paper-level bundle but are not accessed by those proof terms.

Thus the formal paper-facing premises include the complete `A`, `D`, and `M`
bundles where shown in the theorem signatures. Within those bundles the proofs
do not access atomlessness, upper-support maximality, shock mean or variance
normalization, matching monotonicity, or any matching elasticity or
differentiability restriction.

### Equation (12) dependency

`equation12` follows directly from the affine-difference theorem evaluated at
the derived cutoff. The separate theorem
`surplus_reservationCutoff_eq_zero` is then required to simplify equation (12)
to

```text
S(eps) = [sigma / (r + lambda)] (eps - epsD).
```

### Economic interpretation and limitations

The positive affine slope says higher idiosyncratic productivity raises the
joint match surplus one-for-one up to the constant factor
`sigma / (r + lambda)`. The unique zero is the reservation productivity:
firms destroy matches below it, are indifferent at it, and retain matches at or
above it.

These are conditional representation theorems for an existing
`ValueEquilibrium`. M2 proves neither existence of that equilibrium nor
existence or uniqueness of the joint pair `(theta, epsD)`. It proves a unique
zero on `R` and that this zero is below `epsUpper`, but not that `epsD` belongs
to the topological support of `P.shock`. No lower-support assumption is present;
the cutoff may lie below the lower effective support, in which case the
destruction probability can be zero.

### Human-review conclusion

Human mathematical and economic review found the surplus-affinity proof
non-circular. The cutoff is derived from actual equilibrium values, and the
unique mathematical zero is kept separate from economic admissibility.
Equations (1)-(2) are used only for the admissibility argument. No M3 result is
assumed or proved. The reviewed capstone explicitly identifies every surplus
zero with `reservationCutoff`.

### Dependency unlocked

M3 may use the scaled positive-part formula for active surplus to derive the
continuation-value identity and then the job-destruction and job-creation
equations. M2 performs no integration of that formula.
