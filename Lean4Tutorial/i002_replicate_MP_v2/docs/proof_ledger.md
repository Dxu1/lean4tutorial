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

## M3 - Continuation value, job destruction, and job creation

**Paper references:** Mortensen and Pissarides (1994), Section 3; journal
page 401, equations (9) and (10); journal page 402, equation (13).

**Adequacy status:** COMPLETE - GREEN

### Mathematical definitions

The foundational continuation object is the expected excess over a proposed
cutoff:

```text
H(d) = ∫ max (x - d) 0 dP.shock.
```

The paper-facing option value uses the CDF induced by `P.shock`:

```text
T(d) = ∫_d^epsUpper [1 - F(x)] dx.
```

Lean also defines measure-form and CDF-tail job-destruction residuals and the
paper-form job-creation residual. Their zero predicates are
`SatisfiesJobDestructionMeasure`, `SatisfiesJobDestruction`, and
`SatisfiesJobCreation`.

### Continuation derivation and equation (9)

M2 proves

```text
max {S(x), 0}
  = [sigma / (r + lambda)] max {x - epsD, 0}.
```

Integrating gives the foundational measure-form identity

```text
∫ max {S(x), 0} dP.shock
  = [sigma / (r + lambda)] H(epsD).
```

Expected-excess integrability is not assumed. It is derived from the existing
`ValueEquilibrium.active_surplus_integrable` field and the nonzero positive
surplus slope.

Mathlib's strict-tail layer-cake theorem rewrites the expected excess as

```text
H(epsD)
  = ∫_{t>0} P.shock.real {x | t < max (x - epsD) 0} dt.
```

For `t > 0`, the level set is exactly `(epsD + t, infinity)`. Probability
normalization gives

```text
P.shock.real ((y, infinity)) = 1 - F(y).
```

The almost-sure upper bound makes this tail vanish beyond `epsUpper`.
Truncating and translating the Lebesgue integral therefore proves

```text
H(epsD) = T(epsD).
```

Substitution into equation (8) gives the measure and paper-facing forms of
equation (9):

```text
(r + lambda) S(eps)
  = p + sigma eps - b
    + [lambda sigma / (r + lambda)] H(epsD)
    - beta theta q(theta) S(epsUpper),
```

and the same expression with `T(epsD)` replacing `H(epsD)`.

Lean uses layer cake rather than formalizing the paper's informal derivative
notation and integration-by-parts step. This route works directly for the
measure-valued primitive and does not differentiate either surplus or the CDF.

### Equation (10): job destruction

Equations (1)-(2) and firm surplus sharing give the search-gain identity

```text
beta theta q(theta) S(epsUpper)
  = [beta c / (1 - beta)] theta.
```

Evaluating equation (9) at `epsD`, where `S(epsD) = 0`, gives

```text
p + sigma epsD
  = b
    + [beta c / (1 - beta)] theta
    - [lambda sigma / (r + lambda)] H(epsD).
```

Replacing `H(epsD)` by `T(epsD)` is paper equation (10). The middle term is
the worker's foregone search opportunity; the final subtraction is the option
value of retaining a temporarily unprofitable job in anticipation of a better
future draw.

### Equation (13): job creation

Independently of equation (10), equations (1)-(2), firm sharing, and affine
surplus at the designated new-job state give the robust product identity

```text
q(theta) (1 - beta)
  [sigma / (r + lambda)] (epsUpper - epsD) = c.
```

Positivity of every denominator yields paper equation (13):

```text
q(theta)
  = [c / (1 - beta)]
    [(r + lambda) / (sigma (epsUpper - epsD))].
```

The equation balances vacancy cost against the firm's share of the best new
match. A smaller `epsUpper - epsD` gap raises the required vacancy meeting
rate. Strict decrease of `q` implies lower market tightness, while the current
weak monotonicity assumption on the worker meeting rate implies a weakly lower
worker job-finding rate. M3 does not prove a comparative-static theorem across
equilibria.

### Exact Lean declarations

| Role | Declaration |
|---|---|
| Expected excess | `MP1994V2.Primitives.expectedExcess` |
| Strict tail probability | `MP1994V2.Primitives.tailProbability` |
| CDF-tail option value | `MP1994V2.Primitives.tailOptionValue` |
| Strict-tail/CDF identity | `MP1994V2.Primitives.measureReal_Ioi_eq_one_sub_cdf` |
| Cutoff excess integrability | `MP1994V2.ValueEquilibrium.positivePart_sub_cutoff_integrable` |
| Layer-cake cutoff identity | `MP1994V2.ValueEquilibrium.expectedExcess_cutoff_eq_tailOptionValue` |
| Active-surplus measure form | `MP1994V2.ValueEquilibrium.integral_activeSurplus_eq_slope_mul_expectedExcess` |
| Active-surplus tail form | `MP1994V2.ValueEquilibrium.integral_activeSurplus_eq_slope_mul_tailOptionValue` |
| Equation (9), measure form | `MP1994V2.ValueEquilibrium.equation9_measure` |
| Equation (9), paper form | `MP1994V2.ValueEquilibrium.equation9` |
| Search gain | `MP1994V2.ValueEquilibrium.search_gain_eq` |
| Equation (10), measure form | `MP1994V2.ValueEquilibrium.equation10_measure` |
| Equation (10), paper form | `MP1994V2.ValueEquilibrium.equation10` |
| Job-destruction residuals | `MP1994V2.Primitives.jobDestructionResidualMeasure`; `MP1994V2.Primitives.jobDestructionResidual` |
| Job-destruction predicates | `MP1994V2.Primitives.SatisfiesJobDestructionMeasure`; `MP1994V2.Primitives.SatisfiesJobDestruction` |
| Job-destruction witnesses | `MP1994V2.ValueEquilibrium.satisfiesJobDestructionMeasure`; `MP1994V2.ValueEquilibrium.satisfiesJobDestruction` |
| Job-creation product | `MP1994V2.ValueEquilibrium.job_creation_product_identity` |
| Equation (13) | `MP1994V2.ValueEquilibrium.equation13` |
| Job-creation residual | `MP1994V2.Primitives.jobCreationResidual` |
| Job-creation predicate | `MP1994V2.Primitives.SatisfiesJobCreation` |
| Job-creation witness | `MP1994V2.ValueEquilibrium.satisfiesJobCreation` |
| M3 capstone (`SteadyState/StaticConditions.lean`) | `MP1994V2.ValueEquilibrium.milestone3_capstone` |

### Assumption bundles and fields accessed

The paper-facing theorems formally carry
`A : CoreEconomicAssumptions P`, `D : ShockAssumptions P`, and
`M : MatchingAssumptions P`.

- Measure-form continuation and equation (9) use probability normalization,
  existing active-surplus integrability, and the core fields `r_pos`,
  `lambda_nonneg`, and `sigma_pos` through the positive nonzero slope.
- The tail representation accesses `D.isProbability` and `D.upperSupport`.
  It carries but does not access `D.noAtoms` or
  `D.firstMomentIntegrable`.
- The tail representation uses `M` only through the previously derived
  `reservationCutoff_lt_epsUpper`; that proof accesses
  `M.vacancyMeetingRate_pos`. The strict-antitonicity and worker-rate
  monotonicity fields remain formal bundled premises but are not referenced.
- Equation (10) additionally uses free entry and `beta_lt_one` through the
  search-gain identity. Its measure form requires no `MatchingAssumptions`.
- Equation (13) uses free entry, firm sharing, `r_pos`, `lambda_nonneg`,
  `sigma_pos`, `beta_lt_one`, `c_pos`, and cutoff admissibility. Its
  `D` bundle is used only to install probability normalization for M2's affine
  cutoff formula.

The development deliberately does not use shock mean zero, shock variance one,
`ShockNormalizationAssumptions`, atomlessness, matching elasticity,
differentiability, matching strict antitonicity, worker-meeting-rate
monotonicity, or comparative-static assumptions in any M3 proof term.

### Adequacy and limitations

M3 is a forward conditional representation theorem for every existing
`ValueEquilibrium`. It does not prove that a value equilibrium exists. It
introduces no `ReducedEquilibrium`, reverse reconstruction, joint-equilibrium
existence or uniqueness, unemployment stock, or comparative-static theorem.
The cutoff is the M2-derived cutoff; no second threshold is introduced.

Human mathematical and economic review found that the strict-tail layer-cake
derivation is valid and does not use atomlessness. Equations (9), (10), and
(13) match the paper, and equations (10) and (13) are derived independently.
The residual results are forward conditional theorems for an existing
`ValueEquilibrium`; no reduced equilibrium, reconstruction, or existence
theorem is proved.

### Residual admissibility warning

`SatisfiesJobDestruction` and `SatisfiesJobCreation` alone are not a complete
reduced equilibrium. M4 must add `theta > 0`, `d < epsUpper`, and the relevant
primitive, distributional, denominator, and other admissibility assumptions.
In particular, the quotient-form job-creation residual must not be used
without proving its denominator is nonzero. The product-form job-creation
identity is the robust foundational representation.

### Dependency unlocked

M4 may define `ReducedEquilibrium` only after supplying the missing
admissibility contract. The current tail identity obtains integrability from
an existing `ValueEquilibrium`; reverse reconstruction will require a generic
proof that `x ↦ positivePart (x - d)` is integrable from
`ShockAssumptions.firstMomentIntegrable`. M4 also needs the generic identity
`expectedExcess d = tailOptionValue d` for an arbitrary admissible cutoff `d`,
not only `E.reservationCutoff`, before constructing value functions from a
reduced pair.

---

## M4 — Reduced-equilibrium reconstruction and equivalence

**Paper reference.** Section 3, equations (10) and (13), and the journal
page 402 statement that these conditions jointly determine market tightness
and reservation productivity.

**Adequacy status: COMPLETE — GREEN.**

### Three distinct economic objects

- `ValueEquilibrium P` is the primitive value system: theta, V, U, J, W, wage,
  and equations (1)-(7).
- `ReducedEquilibrium P` is only the admissible pair `(theta, cutoff)` with the
  two robust static conditions.
- A full steady state would additionally contain unemployment and vacancy
  stocks. That object and equation (14) remain M6 work.

The robust structure stores `theta > 0`, `cutoff < epsUpper`, the measure-form
job-destruction condition, and the product-form job-creation condition. The
measure form is foundational because it integrates directly against the
primitive law `P.shock`; the CDF-tail form is derived by layer cake. The
product form avoids division by `epsUpper-cutoff`; quotient equation (13) is
derived only after cutoff admissibility and denominator signs are available.

### Generic analytic infrastructure

`Primitives.positivePart_sub_integrable D d` derives integrability of
`x ↦ max (x-d) 0` using `D.isProbability` and
`D.firstMomentIntegrable`, adding no assumption.
`Primitives.expectedExcess_eq_tailOptionValue D hd` proves for every
`d ≤ epsUpper` that expected excess under `P.shock` equals the integral of one
minus its induced CDF over `[d, epsUpper]`. It additionally accesses
`D.upperSupport`. Atomlessness is not used.

### Reconstruction

For a reduced pair `R`, Lean defines

```text
S_R(eps) = [sigma/(r + lambda)] (eps - R.cutoff)
V_R = 0
J_R(eps) = (1 - beta) S_R(eps)
U_R = [b + beta theta q(theta) S_R(epsUpper)] / r
W_R(eps) = U_R + beta S_R(eps)
w_R(eps) = beta [p + sigma eps] + (1 - beta)b + beta c theta.
```

The wage is the economically meaningful Nash wage, not an arbitrary Bellman
residual. `ValueEquilibrium.wage_eq_nash_formula` independently derives the
same formula for every primitive value equilibrium.

### Equations (1)-(7)

| Equation | Reconstruction proof |
|---|---|
| (1) | Product-form job creation gives `q(theta) J_R(epsUpper)=c`; with `V_R=0` this is the vacancy Bellman equation. |
| (2) | `V_R=0` makes `r V_R=0` definitionally. |
| (3) | `toValueCandidate_surplus` proves that surplus computed from J, W, U is exactly `S_R`. |
| (4) | `W_R-U_R=beta S_R` follows directly from the worker-value definition. |
| (5) | Candidate equation (8), continuation decomposition, firm share, and the wage-search identity prove the filled-job Bellman equation. |
| (6) | Candidate equation (8), equation (7), Nash sharing, continuation decomposition, and explicit wage prove the worker Bellman equation. |
| (7) | The definition of `U_R` and Nash sharing at `epsUpper` prove the unemployment Bellman equation. |

Candidate equation (8) is derived from measure-form job destruction,
product-form search gain, affine candidate surplus, and the reconstructed
active-surplus expectation.

### Principal Lean declarations

| Role | Declaration |
|---|---|
| Robust JC predicate | `MP1994V2.Primitives.SatisfiesJobCreationProduct` |
| Reduced pair | `MP1994V2.ReducedEquilibrium` |
| Generic integrability | `MP1994V2.Primitives.positivePart_sub_integrable` |
| Generic tail identity | `MP1994V2.Primitives.expectedExcess_eq_tailOptionValue` |
| Reduced equations | `MP1994V2.ReducedEquilibrium.equation10`; `MP1994V2.ReducedEquilibrium.equation13` |
| Forward bridge | `MP1994V2.ValueEquilibrium.toReducedEquilibrium` |
| Reconstructed objects | `surplusCandidate`; `vacancyValueCandidate`; `firmValueCandidate`; `unemploymentValueCandidate`; `workerValueCandidate`; `wageCandidate` in namespace `MP1994V2.ReducedEquilibrium` |
| Candidate equation (8) | `MP1994V2.ReducedEquilibrium.surplus_bellman` |
| Reconstructed equations | `vacancy_bellman`; `free_entry`; `nash_sharing`; `filled_job_bellman`; `worker_bellman`; `unemployed_bellman` |
| Reverse constructor | `MP1994V2.ReducedEquilibrium.toValueEquilibrium` |
| Cutoff preservation | `MP1994V2.ReducedEquilibrium.toValueEquilibrium_reservationCutoff` |
| Exact reduced round trip | `MP1994V2.ReducedEquilibrium.toValue_toReduced` |
| Explicit wage theorem | `MP1994V2.ValueEquilibrium.wage_eq_nash_formula` |
| Value-component round trip | `MP1994V2.ValueEquilibrium.reconstruction_components` |
| Complete economic round trip | `MP1994V2.ValueEquilibrium.reconstruction_economic_roundtrip` |
| Conditional equivalence | `MP1994V2.valueEquilibrium_nonempty_iff_reducedEquilibrium_nonempty` |
| Strengthened capstone | `MP1994V2.m4_representation_capstone`, containing the exact reduced round trip, complete value-side economic round trip, and nonemptiness equivalence |

### Assumption discipline

The forward bridge carries the core, shock, and matching bundles. Matching is
used through M2 cutoff admissibility, which accesses positive vacancy meeting
at positive theta. Probability normalization supports the affine and
job-destruction results.

Reverse reconstruction carries only the core and shock bundles. Core fields
used are `r_pos`, `lambda_nonneg`, `sigma_pos`, and `beta_lt_one`, chiefly
through nonzero denominators and the positive surplus slope. The reverse
constructor `ReducedEquilibrium.toValueEquilibrium` uses probability
normalization and first-moment integrability, but does not use upper support.
Upper support is needed separately for the paper-facing induced-CDF tail form
of equation (10). Reconstruction does not require the matching bundle.

Thus theorem signatures may carry the full `ShockAssumptions` bundle while
their proof terms access only the individual fields just listed.

The development deliberately does not use `noAtoms`, mean-zero or unit-variance
normalization, matching strict antitonicity, worker-rate monotonicity, matching
elasticity, differentiability, comparative-static assumptions, or any M5
endpoint/crossing hypothesis.

### Exact scope

M4 proves conditional forward representation, conditional reverse
reconstruction, exact equality of the reduced round trip, and equality of
every public economic component and surplus in the value round trip. Under
the maintained assumption bundles, nonemptiness of the two equilibrium types
is logically equivalent. Neither side is proved nonempty because the theorem
supplies no initial witness. Exact `ValueEquilibrium` structure equality is
not exported:
the structure contains proof-valued Bellman and admissibility fields, and
public componentwise equality is the stable economic interface.

M4 does **not** prove that either equilibrium type exists, does not prove
uniqueness of `(theta, cutoff)`, and does not introduce equation (14),
unemployment stocks, or comparative statics.

### Human-review conclusion

Human mathematical and economic review found that the reduced structure
contains the correct robust conditions and the reverse construction uses the
explicit Nash wage. Equations (1)-(7) are verified rather than assumed, and
the two representation directions are non-circular. The reduced round trip is
exact, while the value round trip preserves every economic object and surplus.
The generic excess and tail analysis is valid. No equilibrium-existence or
uniqueness theorem is proved. M4 is graded **COMPLETE — GREEN**.

### Dependency unlocked

M5 may study existence and uniqueness entirely in the reduced two-variable
system, knowing that every admissible solution reconstructs the original
primitive value equilibrium.

## M5 - Existence and uniqueness of the static reduced equilibrium

**Paper reference:** Section 3, equations (10) and (13), Figure 1, and the
uniqueness statement on journal page 402.

**Adequacy status:**

- Uniqueness: **COMPLETE - GREEN**
- Existence: **COMPLETE - AMBER**
- Overall M5: **COMPLETE - AMBER**

### Scalar curves and the Figure 1 argument

Write

```text
H(d) = integral max(x-d,0) dP.shock,
N_JD(d) = p + sigma d - b + [lambda sigma/(r+lambda)] H(d),
theta_JD(d) = N_JD(d) / [beta c/(1-beta)],
R(d) = q(theta_JD(d)) [(1-beta)sigma/(r+lambda)](epsUpper-d)-c.
```

Positive part is one-Lipschitz, so integration against the probability law
gives `|H(d2)-H(d1)| <= |d2-d1|`. Hence `H` is continuous and antitone. For
`d1 < d2`, the possible decline in expected excess cannot offset current
productivity: the net increase is bounded below by
`sigma r/(r+lambda) * (d2-d1) > 0`. Thus `theta_JD` is strictly increasing.

On positive tightness, strict decrease of `q` makes the JD locus upward
sloping and the robust JC locus downward sloping. Two reduced equilibria with
different cutoffs would therefore order their tightness in opposite ways.
Consequently `ReducedEquilibrium.unique` proves at most one intersection under
the maintained core, shock, and matching assumptions, without any existence
assumption.

### Corrected existence theorem

Slopes do not guarantee an intersection. M5 adds the explicit sufficient
closure condition

```lean
structure StaticExistenceAssumptions (P : Primitives) : Prop where
  q_continuousOn_pos : ContinuousOn P.q (Set.Ioi 0)
  lower_crossing :
    ∃ d0 : ℝ,
      d0 < P.epsUpper ∧
      0 < P.jobDestructionTheta d0 ∧
      0 < P.staticCrossingResidual d0
```

This is a bracket, not an equilibrium witness: its lower residual is strictly
positive, not zero. The upper residual is derived as `R(epsUpper) = -c < 0`.
Strict increase of `theta_JD` keeps tightness positive on the bracket;
continuity of `theta_JD` and the assumed continuity of `q` make `R`
continuous there. Mathlib's `intermediate_value_Icc'` then supplies a strictly
interior root. That root constructs a `ReducedEquilibrium`; M4 reconstruction
constructs a `ValueEquilibrium`.

Existence is therefore **proved under explicit additional existence
conditions**, not unconditionally under the paper's original primitive
assumptions.

`lower_crossing` is not circular because it assumes a strictly positive
residual rather than a zero. It nevertheless supplies the missing endpoint
condition required to prove an intersection. The paper's Figure 1 slope
argument establishes uniqueness, but slopes by themselves do not establish
existence. M5 is therefore a corrected conditional-existence theorem.

### Existence assumption and primitive upgrade path

The exact committed closure bundle is:

```lean
structure StaticExistenceAssumptions
    (P : Primitives) : Prop where

  q_continuousOn_pos :
    ContinuousOn P.q (Set.Ioi 0)

  lower_crossing :
    ∃ d0 : ℝ,
      d0 < P.epsUpper ∧
      0 < P.jobDestructionTheta d0 ∧
      0 < P.staticCrossingResidual d0
```

The first field is a regularity assumption: it supplies continuity of the
scalar crossing residual wherever JD-implied tightness is positive. The second
field is the substantive endpoint closure: it supplies a positive lower
residual, while Lean derives the upper residual as `-c < 0`. Because that lower
sign is not currently derived from primitive assumptions, existence remains
**COMPLETE - AMBER**.

A proposed, unformalized upgrade adds a right-hand vacancy-filling Inada
condition,

```text
q(theta) -> +infinity as theta -> 0 from above,
```

together with the separate primitive profitability condition

```text
b < p + sigma * epsUpper.
```

The Inada condition on `q` alone is insufficient. The JD curve must reach
positive tightness; if `jobDestructionNet d <= 0` everywhere, behavior of `q`
on positive tightness cannot produce a crossing.

The proposed five-step proof route is:

1. use the one-Lipschitz bound on expected excess to prove that
   `jobDestructionNet` is negative at some sufficiently low cutoff;
2. use upper support and upper-job profitability to prove it is positive at
   `epsUpper`;
3. use continuity and strict increase to obtain a unique zero-net,
   zero-tightness boundary cutoff below `epsUpper`;
4. use the right-hand Inada limit to obtain positive scalar residual just
   above that boundary; and
5. construct `StaticExistenceAssumptions` and reuse
   `reducedEquilibrium_nonempty A D X` unchanged.

For the standard specification
`q(theta) = kappa * theta^(-eta)`, with `kappa > 0` and `0 < eta < 1`, vacancy
filling is positive, strictly decreasing, and Inada at zero, while the worker
meeting rate is increasing. A future M5b can certify these facts with
`Real.rpow`, combine them with upper-job profitability, and upgrade existence
to green for that specification. No such theorem is currently implemented.

The detailed economic argument, comparison table, proposed assumption bundle,
and Lean theorem targets are recorded in
`docs/static_existence_foundation.md`.

### Principal Lean declarations

| Role | Declaration |
|---|---|
| Expected-excess regularity | `Primitives.expectedExcess_antitone`; `Primitives.expectedExcess_lipschitz`; `Primitives.expectedExcess_continuous` |
| Coefficients and JD curve | `Primitives.searchOpportunityCostCoefficient`; `Primitives.jobCreationScale`; `Primitives.jobDestructionNet`; `Primitives.jobDestructionTheta` |
| JD equivalence and slope | `Primitives.satisfiesJobDestructionMeasure_iff`; `Primitives.jobDestructionNet_strictMono`; `jobDestruction_curve_strictMono` |
| Scalar residual | `Primitives.staticCrossingResidual`; `Primitives.staticCrossingResidual_strictAntiOn`; `Primitives.staticCrossingResidual_epsUpper` |
| JC slope | `jobCreation_curve_strictAnti` |
| At most one | `ReducedEquilibrium.unique`; `reducedEquilibrium_atMostOne` |
| Existence bundle | `StaticExistenceAssumptions` |
| IVT crossing | `Primitives.staticCrossingResidual_continuousOn_Icc`; `exists_staticCrossing` |
| Conditional unique existence | `reducedEquilibrium_nonempty`; `HasUniqueReducedEquilibrium`; `reducedEquilibrium_existsUnique` |
| Value transport | `valueEquilibrium_nonempty`; `ValueEquilibrium.theta_eq`; `ValueEquilibrium.reservationCutoff_eq`; `ValueEquilibrium.economically_unique` |
| Capstone | `m5_static_equilibrium_capstone` |

The revised existence-only interfaces are:

```text
exists_staticCrossing A D X
reducedEquilibrium_nonempty A D X
staticReducedEquilibrium A D X
valueEquilibrium_nonempty A D X
```

None takes a `MatchingAssumptions` argument. The selected-equilibrium
comparison and all combined uniqueness capstones continue to take matching.

### Assumption discipline

Uniqueness signatures contain `CoreEconomicAssumptions`, `ShockAssumptions`,
and `MatchingAssumptions`. Proof terms access core positivity of `r`,
`lambda`, `sigma`, `beta`, `c`, and `1-beta`; shock probability normalization
and first-moment integrability; and vacancy-meeting positivity plus strict
decrease on positive tightness. They do not access upper support,
atomlessness, shock normalization, worker-meeting monotonicity,
differentiability, or elasticity.

The existence-only theorems take `CoreEconomicAssumptions`,
`ShockAssumptions`, and `StaticExistenceAssumptions`, but no
`MatchingAssumptions`. They access `ShockAssumptions.isProbability`,
`ShockAssumptions.firstMomentIntegrable`,
`StaticExistenceAssumptions.q_continuousOn_pos`, and
`StaticExistenceAssumptions.lower_crossing`. Combined unique-existence and
economic-uniqueness results retain `MatchingAssumptions` because their
uniqueness conjunct uses vacancy-meeting positivity and strict decrease.

### Exact scope

M5 proves at most one reduced equilibrium under the maintained assumptions;
conditional unique existence under the explicit continuity/bracket bundle;
value-equilibrium existence through M4 reconstruction; and economic
uniqueness of tightness, cutoff, values, wage, and surplus. It does not claim
exact equality of proof-valued value-equilibrium records.

M5 does **not** prove unconditional existence under only M0 assumptions,
equation (14), unemployment or vacancy stocks, comparative statics, or any
dynamic result.

### Human-review conclusion

The substantive uniqueness and IVT proofs passed mathematical review.
Uniqueness faithfully formalizes the Figure 1 slope argument and is
**COMPLETE - GREEN**. Existence is mathematically valid but depends on the
additional lower positive crossing condition, so it is **COMPLETE - AMBER**.
Overall M5 is **COMPLETE - AMBER**.

### Remaining foundational gap

Derive `StaticExistenceAssumptions.lower_crossing` from more primitive
boundary/range conditions on `q`, or certify it for a standard matching
function such as a Cobb-Douglas specification. Until that task is completed,
existence remains conditional. This does not block M6.

### Dependency unlocked

M6 may add unemployment flow balance and equation (14) to the uniquely
determined static pair.

## M6 - Unemployment flow balance and the full static steady state

**Paper reference:** Section 3, journal page 403, equation (14); journal page
404, the job-creation/job-destruction flow discussion; Figure 2.

**Adequacy status:** COMPLETE - AMBER

**Human-review grade:** stock completion and equation (14): COMPLETE - GREEN;
full-state uniqueness: COMPLETE - GREEN; transported full-state existence:
COMPLETE - AMBER; overall M6: COMPLETE - AMBER.

### Destruction rule, hazards, stocks, and flows

The economic destruction rule from M2 is strict: `eps < cutoff`. Accordingly,
Lean first defines

```text
strictShockBelow(d) = P.shock ((-infinity,d)).toReal
s(d) = jobSeparationRate(d) = lambda * strictShockBelow(d)
f(theta) = jobFindingRate(theta) = theta * q(theta)
D(d,u) = s(d) * (1-u)
C(theta,u) = f(theta) * u.
```

The paper writes the destruction probability as `F(d)`. Under
`D.noAtoms`, `Primitives.strictShockBelow_eq_cdf` proves that the strict lower
tail equals the weak-tail CDF induced by `P.shock`. Atomlessness is used at
this bridge; unlike M3's layer-cake identity, it is economically material here
because it connects the actual strict destruction event to the paper notation.

Employment and vacancies are derived:

```text
employment = 1 - u
vacancies = theta * u.
```

Vacancies are not stored in an equilibrium record, so the unconditional stock
identity cannot drift from the tightness coordinate.

### Derivation and uniqueness of equation (14)

Flow balance is

```text
s(d) * (1-u) = f(theta) * u.
```

For positive `theta`, matching positivity gives `f(theta) > 0`. Since
`lambda >= 0` and the strict lower-tail mass is nonnegative, `s(d) >= 0`, so
`s(d) + f(theta) > 0`. Rearranging therefore gives the unique real solution

```text
u = s(d) / (s(d) + f(theta)).
```

The theorem `Primitives.flow_balance_iff_unemployment_eq` establishes this
uniqueness without assuming stock bounds. The derived solution lies in
`[0,1)`, satisfies flow balance, and no-atoms replacement of the strict mass
gives paper equation (14):

```text
u = [lambda * F(d)] /
      [lambda * F(d) + theta * q(theta)].
```

The exact paper-facing theorem is
`SteadyStateEquilibrium.equation14`; the generic closed-form representation is
`Primitives.steadyStateUnemployment_eq_equation14`.

### Full static equilibrium and representation

`SteadyStateEquilibrium P` extends `ReducedEquilibrium P` with only:

- `unemployment`;
- `unemployment_nonneg` and `unemployment_le_one`;
- `flow_balance`.

It does not store employment, vacancies, equation (14), a value equilibrium,
existence, or uniqueness. Every reduced pair completes via
`ReducedEquilibrium.toSteadyStateEquilibrium`. Conversely, every stored flow
balance forces the same closed form. Exact round trips are public:

```text
ReducedEquilibrium.toSteady_toReduced
SteadyStateEquilibrium.toReduced_toSteady
steadyStateEquivReduced
```

The full state recovers a primitive value equilibrium through
`SteadyStateEquilibrium.toValueEquilibrium`; its theta and reservation cutoff
are preserved.

### Stock-flow identities and zero-separation degeneracy

Lean proves

```text
C = theta*q(theta)*u = q(theta)*vacancies
D = lambda*F(cutoff)*employment
C = D.
```

The general model permits `s(cutoff) = 0`. Equation (14) then gives `u = 0`,
and the derived vacancy stock is also zero. Thus `v/u` is not formed in the
general theorem. Under `HasPositiveSeparationAt cutoff`, Lean first proves
`0 < u < 1` and `0 < v`, then proves
`vacancies / unemployment = theta`. This is the precise distinction between
the unconditional identity `v = theta*u` and conditional literal ratio
identification.

### Principal Lean declarations

| Role | Declaration |
|---|---|
| Strict mass and no-atoms bridge | `Primitives.strictShockBelow`; `Primitives.strictShockBelow_eq_cdf` |
| Hazards | `Primitives.jobSeparationRate`; `Primitives.jobFindingRate`; `Primitives.totalTransitionHazard_pos` |
| Flows and residual | `Primitives.jobDestructionFlow`; `Primitives.jobCreationFlow`; `Primitives.unemploymentFlowResidual` |
| Closed form and balance | `Primitives.steadyStateUnemployment`; `Primitives.steadyStateUnemployment_flow_balance`; `Primitives.flow_balance_iff_unemployment_eq` |
| Full equilibrium | `SteadyStateEquilibrium`; `ReducedEquilibrium.toSteadyStateEquilibrium` |
| Equation (14) | `SteadyStateEquilibrium.equation14` |
| Stock/flow accounting | `SteadyStateEquilibrium.jobCreationFlow_eq_q_mul_vacancies`; `jobDestructionFlow_eq_lambda_cdf_mul_employment`; `jobCreation_eq_jobDestruction` |
| Positivity and ratio | `unemployment_pos_of_positiveSeparation`; `vacancies_div_unemployment_eq_theta`; zero-separation theorems |
| Exact representation | `ReducedEquilibrium.toSteady_toReduced`; `SteadyStateEquilibrium.toReduced_toSteady`; `steadyStateEquivReduced` |
| At most one | `SteadyStateEquilibrium.unique`; `steadyStateEquilibrium_atMostOne` |
| Conditional existence | `steadyStateEquilibrium_nonempty`; `steadyStateEquilibrium_existsUnique` |
| Green stock/uniqueness capstone | `m6_stock_completion_capstone` |
| Amber conditional-existence capstone | `m6_conditional_existence_capstone` |
| Combined capstone | `m6_full_steady_state_capstone` |

### Assumption discipline

Paper-facing signatures contain the core, shock, and matching bundles. The
stock-completion proof terms access only
`CoreEconomicAssumptions.lambda_nonneg`,
`ShockAssumptions.noAtoms` for strict-tail/CDF replacement, and
`MatchingAssumptions.vacancyMeetingRate_pos` at positive theta. Basic measure
nonnegativity needs no additional shock field. Full-state existence accesses
`StaticExistenceAssumptions` only through M5's reduced-equilibrium witness.

M6 does not access `r_pos`, `sigma_pos`, bargaining restrictions, vacancy
cost, first-moment integrability, upper support, shock normalization, matching
strict antitonicity, worker-meeting monotonicity, elasticity, or
differentiability in its stock-completion/equation (14) layer. Full-state
uniqueness inherits the fields used by `ReducedEquilibrium.unique`.

### Exact scope and adequacy

M6 proves the unique unemployment stock for a given reduced pair, equation
(14), employment/vacancy identities, creation/destruction equality, exact
reduced/full representation, and at most one full static steady state. These
results are GREEN and are exposed by `m6_stock_completion_capstone` without a
static-existence premise.

M6 introduces no new existence closure assumption. Its AMBER existence status
is inherited entirely from M5 through the chain

```text
StaticExistenceAssumptions.lower_crossing
  -> reducedEquilibrium_nonempty
  -> ReducedEquilibrium.toSteadyStateEquilibrium
  -> steadyStateEquilibrium_nonempty.
```

The final step is an algebraic stock completion, not a further endpoint or
crossing assumption. `m6_conditional_existence_capstone` makes the inherited
premise explicit; `m6_full_steady_state_capstone` combines the green and amber
parts.

Interiority is also separate from existence. At zero separation, flow balance
gives `u = 0` and the derived stock identity gives `v = 0`. The identity
`v = theta * u` remains valid, while `v / u = theta` is proved only under
positive separation. No interiority premise is hidden in the full-state
constructor.

Human review judged equation (14), the stock/flow accounting, the
zero-separation treatment, exact representation, and uniqueness faithful and
non-circular. The full adequacy record is
[`static_steady_state_adequacy.md`](static_steady_state_adequacy.md).

Upgrading existence requires a separate primitive argument. The documented
M5b route combines a right-hand Inada condition on `q` with upper-job
profitability `b < p + sigma * epsUpper`; a more primitive interiority route
would additionally expose `lambda > 0`, lower-tail richness/support, and
cutoff admissibility. Proving M5b would upgrade both M5 and the inherited M6
existence result without changing M6's stock architecture.

M6 does not prove unconditional existence, a Beveridge-curve slope or
convexity result, comparative statics, equation (15), dynamics, or any M7+
result.

### Dependency unlocked

M7 may study static comparative statics; M9 may reuse the flow residual for
equation (15). M5b remains the separate route for upgrading existence.

## M7 - Static order comparative statics

**Paper reference:** Section 3, especially journal pages 401-404; equations
(10), (13), and (14); the JD/JC shifts around Figures 1 and 2.

**Adequacy status:** COMPLETE - GREEN

### Parameter-update notation

The four immutable updates

```text
Primitives.withCommonProductivity
Primitives.withUnemploymentIncome
Primitives.withShockArrivalRate
Primitives.withDiscountRate
```

change exactly one primitive and leave the common matching function and shock
law definitionally unchanged. Core, shock, and matching assumptions are
transported explicitly. The `lambda` transport requires a nonnegative new
rate and the `r` transport a positive new rate. No transport of
`StaticExistenceAssumptions` is supplied.

### Fixed-tightness and full-equilibrium results

At a common `theta`, the JD condition proves: higher `p` strictly lowers the
cutoff; higher `b` strictly raises it; higher `lambda` weakly lowers it; and
higher `r` weakly raises it. The weak signs correctly allow a zero option
value.

The reviewed strict refinements recover the paper's strict fixed-tightness
prose under explicit positive option value. Higher `lambda` strictly lowers
the cutoff when `0 < P.expectedExcess dLow`; higher `r` strictly raises it
under the same condition and `0 < P.lambda`.

For arbitrary supplied `ReducedEquilibrium` witnesses, higher `p` strictly
lowers the cutoff and raises tightness, while higher `b` strictly raises the
cutoff and lowers tightness. Higher `lambda` strictly lowers the equilibrium
cutoff. Higher `r` strictly lowers equilibrium tightness. These are the robust
Figure 1 order conclusions; the theorem family does not construct either
equilibrium.

The exact declarations are:

| Role | Declaration |
|---|---|
| Fixed `theta`, `p` | `cutoff_strictAnti_commonProductivity_at_fixed_theta` |
| Fixed `theta`, `b` | `cutoff_strictMono_unemploymentIncome_at_fixed_theta` |
| Fixed `theta`, `lambda` | `cutoff_antitone_shockArrival_at_fixed_theta` |
| Fixed `theta`, `r` | `cutoff_monotone_discountRate_at_fixed_theta` |
| Fixed `theta`, strict `lambda` | `cutoff_strictAnti_shockArrival_at_fixed_theta_of_expectedExcess_pos` |
| Fixed `theta`, strict `r` | `cutoff_strictMono_discountRate_at_fixed_theta_of_optionValue_pos` |
| Equilibrium `p` | `ReducedEquilibrium.order_of_commonProductivity` |
| Equilibrium `b` | `ReducedEquilibrium.order_of_unemploymentIncome` |
| Equilibrium `lambda` | `ReducedEquilibrium.cutoff_strictAnti_shockArrival` |
| Equilibrium `r` | `ReducedEquilibrium.theta_strictAnti_discountRate` |

### Hazards, initial flows, and steady stocks

`Primitives.strictShockBelow_mono` uses lower-tail set inclusion and finite
measure only; it does not use atomlessness. With nonnegative `lambda`, this
gives `jobSeparationRate_mono_cutoff`. Matching monotonicity gives
`jobFindingRate_mono`. At a common current `0 <= u <= 1`, the generic flow
lemmas multiply those hazard orders by the same nonnegative stock.

The algebraic theorem `steadyUnemployment_monotone` proves that lower
separation and higher finding imply weakly lower
`s / (s + f)`. The two supplied-full-state capstones are:

```text
SteadyStateEquilibrium.aggregateProductivity_capstone
SteadyStateEquilibrium.unemploymentIncome_capstone
```

They combine strict cutoff/tightness orders with weak separation, finding,
unemployment, and employment orders. The companion `aggregateProductivity_initialFlows`
and `unemploymentIncome_initialFlows` theorems give the paper's initial-impact
creation/destruction comparisons at a common unemployment stock.

The combined public endpoints are
`m7_aggregateNetProductivity_capstone` and
`m7_otherParameters_capstone`. Both quantify over existing equilibrium
witnesses and neither takes `StaticExistenceAssumptions`.

### Assumption bundles and accessed fields

The equilibrium signatures carry `CoreEconomicAssumptions`,
`ShockAssumptions`, and `MatchingAssumptions`. The p/b order proofs use the
positive JD/JC coefficients, probability and first-moment facts through
expected-excess monotonicity, and positive/strictly decreasing `q`. Flow
proofs additionally use `lambda_nonneg`, probability finiteness, and
`workerMeetingRate_monotoneOn`. The `lambda` and `r` arguments use the core
signs controlling their option-value fractions, JD strict monotonicity, and
the JC product with positive/strictly decreasing `q`.

Some public signatures carry the complete shock bundle because they invoke
existing JD monotonicity, even where `upperSupport` and `noAtoms` are not
accessed by the M7 proof term. The hazard-order theorem itself makes the
weaker finite-measure requirement explicit. Shock normalization, matching
elasticity, differentiability, and `StaticExistenceAssumptions` are unused.

### Adequacy and deferred results

The unemployment implications are weak: the CDF can be flat between ordered
cutoffs and the worker meeting rate is only weakly monotone. Strictness would
require positive shock mass between cutoffs or strict worker-rate
monotonicity. Vacancies equal `theta * u`; the two factors move oppositely, so
M7 asserts no vacancy sign.

M7 deliberately does not prove the equilibrium tightness effect of
`lambda`, the equilibrium cutoff effect of `r`, any `sigma` comparative
static, equation (11), or Appendix equations (A1)-(A12). Those require the
Appendix inequality or differentiable-path machinery and remain M8.

Because every core theorem is universally conditional on supplied witnesses,
M7 does not inherit M5's AMBER existence grade. Any future wrapper selecting
equilibria via `StaticExistenceAssumptions.lower_crossing` would be AMBER
inherited from M5 and must remain separate from the GREEN pairwise capstones.

Human mathematical/economic review found the following decomposition GREEN:
fixed-tightness `p` and `b`, equilibrium `p` and `b`, the equilibrium `lambda`
cutoff, and equilibrium `r` tightness are strict; the general fixed-tightness
`lambda` and `r` results are robustly weak, with the two strict refinements
GREEN under their explicit positive-option-value conditions; hazard, flow,
unemployment, and employment implications are weak. There is no vacancy sign
and no M5 existence assumption. These are universal conditional comparative
statics for supplied equilibria; M7 does not prove that the compared
equilibria exist, which does not make M7 AMBER.

**Human-review checklist:** [x] Human mathematical/economic review is complete.

The durable result matrix and scope explanation are in
[`static_comparative_statics_scope.md`](static_comparative_statics_scope.md).

## M8 - Appendix derivative comparative statics

**Paper reference:** Appendix, equations (A1)-(A12), together with equation
(11).

**Implementation status:** **COMPLETE - AMBER**, reviewed 2026-08-01.

**Adequacy:** analytic infrastructure **COMPLETE - GREEN**; supplied-path
comparative statics **COMPLETE - AMBER**; overall M8 **COMPLETE - AMBER**.

### Exact theorem contract

M8 proves derivative identities and signs for supplied objects satisfying
`LocalReducedEquilibriumPath` or `FixedTightnessSigmaPath`. Those structures
require differentiability and the exact local JD/JC closure equations, but
store no derivative signs or Appendix conclusions. The theorems therefore do
not assume their answers. M8 does not prove existence of a locally
differentiable equilibrium selection; that missing implicit-function step is
the sole reason the supplied-path layer is AMBER.

The public result interface is:

- `FixedTightnessSigmaPath.equation11` and
  `FixedTightnessSigmaPath.cutoffSlope_pos_iff`;
- `LambdaEquilibriumPath.equationA1` through `equationA4`,
  `cutoffSlope_neg`, and `thetaSlope_neg`;
- `DiscountEquilibriumPath.equationA5` through `equationA8`,
  `thetaSlope_neg`, and `cutoffSlope_pos_iff_A8_rhs_pos`;
- `DispersionEquilibriumPath.equationA9` through `equationA12`,
  `thetaSlope_pos`, `cutoffSlope_pos_iff_A12_expression_pos`, and
  `cutoffSlope_pos_of_b_le_p`;
- `FixedTightnessSigmaPath.m8_fixedTightness_capstone`,
  `LambdaEquilibriumPath.m8_lambda_capstone`,
  `DiscountEquilibriumPath.m8_discount_capstone`,
  `DispersionEquilibriumPath.m8_dispersion_capstone`, and
  `m8_appendix_capstone`.

The individual paper declarations remain public under their exact names:
`LambdaEquilibriumPath.equationA1`, `equationA2_crossMultiplied`,
`equationA2_normalized`, `equationA2`, `cutoffSlope_neg`, `equationA3`,
`equationA3_normalized`, `equationA4`, and `thetaSlope_neg`;
`DiscountEquilibriumPath.jd_derivative_raw`, `equationA6_crossMultiplied`,
`equationA5_normalized`, `equationA5`, `equationA6_normalized`, `equationA6`,
`thetaSlope_neg`, `equationA7`, `equationA8`,
`equationA8_leftCoefficient_pos`, and
`cutoffSlope_pos_iff_A8_rhs_pos`; and
`DispersionEquilibriumPath.jd_derivative_raw`,
`equationA10_crossMultiplied`, `equationA9`, `equationA10`,
`equationA11_signCarrier_pos`, `equationA11_slopeEquation`,
`equationA11_leftCoefficient_pos`, `thetaSlope_pos`, `equationA12`,
`equationA12_slopeEquation`, `equationA12_leftCoefficient_pos`,
`cutoffSlope_pos_iff_A12_expression_pos`, and
`cutoffSlope_pos_of_b_le_p`.

### Analytic and algebraic foundation

`AppendixMatchingAssumptions` supplies differentiability of `q` on positive
tightness and matching elasticity in `(0,1)`. `cdf_continuous` derives CDF
continuity from `ShockAssumptions.noAtoms`; `hasDerivAt_expectedExcess` proves
the FTC derivative of the expected-excess function. The strict upper-tail
bound used in (A4) follows from atomlessness and `upperSupport`. The moment
calculation used in (A11) explicitly takes `ShockNormalizationAssumptions`.
The scalar algebra is isolated in `AppendixAlgebra.lean`, including
`appendixA2_normalize`, `appendixA3_of_A1_A2`, `appendixA5_solve`,
`appendixA8_of_A5_A7`, and the (A9)-(A12) normalization and slope helpers.

### Assumption bundles and accessed fields

- `CoreEconomicAssumptions` supplies `r_pos`, `lambda_nonneg`, `sigma_pos`,
  `beta_pos`, `beta_lt_one`, and `c_pos`, chiefly through positive denominators
  `r_add_lambda_pos`, `one_sub_beta_pos`, and `sigma_ne`.
- `ShockAssumptions` supplies the probability instance, `upperSupport`,
  `noAtoms`, and first-moment integrability. Atomlessness gives CDF continuity
  and strict tail bounds; the almost-sure upper bound controls tail integrals.
- `ShockNormalizationAssumptions` is used for zero mean and unit second moment
  in the (A11) sign carrier and dispersion tightness. It is not needed by
  `cutoffSlope_pos_of_b_le_p`.
- `MatchingAssumptions` supplies positive vacancy meeting rates, hence nonzero
  `q`, on `theta > 0`. Worker-meeting monotonicity is not used for these signs.
- `AppendixMatchingAssumptions` supplies `q_differentiableOn_pos`,
  `elasticity_pos`, and `elasticity_lt_one` for
  `matchingElasticity(theta) = -theta * deriv q theta / q theta`.
- Path objects supply `theta_hasDerivAt`, `cutoff_hasDerivAt`, positivity,
  cutoff admissibility, and eventual exact JD/JC equations. They supply no
  sign, Jacobian condition, or existence witness.

The capstone records the paper's interior convention with `0 < P.lambda`;
lower-level lambda sign theorems remain valid under the core convention
`0 ≤ P.lambda`. The discount-rate cutoff sign is not forced: Lean proves the
exact (A8) iff condition. Dispersion raises both tightness and the cutoff under
the explicit economic condition `P.b ≤ P.p`.

### Dependency and adequacy audit

No M8 result imports or takes `StaticExistenceAssumptions`, and no M5 witness is
selected. The result is conditional on a supplied path, not on M5's global
existence foundation. No Section 4, cyclical, Markov, or M8b implicit-function
theorem is implemented. A direct worker-meeting-rate derivative is optional
and deferred. The exact boundary and six-step M8b route are recorded in
[`appendix_differentiability_scope.md`](appendix_differentiability_scope.md).

Human mathematical/economic review confirmed that the Appendix identities and
sign conclusions are faithful, that the path premise is non-circular, and that
the AMBER grade is caused only by the supplied differentiable local paths. It
is not inherited from M5. The paper-facing lambda capstone correctly states
the economically interior condition `0 < P.lambda`; M8b is the route from the
remaining path-conditional AMBER layer to GREEN.

**Human-review checklist:** [x] Human mathematical/economic review is complete
(2026-08-01).

## M8b.1 - Local IFT foundation and lambda path

**Implementation status:** **COMPLETE - GREEN**, reviewed 2026-08-01.

M8b.1 proves local `C¹` regularity for the fixed-tightness sigma residual and
the lambda scalar-crossing residual. At a supplied `R : ReducedEquilibrium P`,
the residual roots follow from `R.jobDestructionMeasure` and
`R.jobCreationProduct`. The cutoff partial derivatives are derived, not
assumed: the fixed-sigma partial is strictly positive and the lambda crossing
partial is strictly negative.

The generic theorem `exists_localImplicitCutoffPath` wraps Mathlib's
`ContDiffAt.implicitFunction`, constructs scalar invertibility from a proved
nonzero derivative, returns a local `C¹` cutoff function, and preserves the
local graph-uniqueness statement. The economic constructors are
`ReducedEquilibrium.exists_fixedTightnessSigmaPath_of_ift` and
`ReducedEquilibrium.exists_lambdaEquilibriumPath_of_ift`; their selected paths
feed the existing M8 equation (11) and lambda sign capstones.

Human review judged the generic scalar IFT wrapper, fixed-tightness sigma path,
lambda equilibrium path, and combined M8b.1 result **COMPLETE - GREEN**
relative to a supplied reduced equilibrium and explicit primitive `C¹`
regularity of `q`. Base roots are derived from that equilibrium; cutoff
nondegeneracy is proved; and no derivative sign is assumed.

No theorem imports or takes `StaticExistenceAssumptions`, selects an M5
equilibrium, assumes a residual root, assumes nondegeneracy, or assumes a
derivative sign. `AppendixIFTAssumptions` contains only local `C¹` regularity
of the primitive matching function on positive tightness. M8b.1 is therefore
targeted GREEN relative to a supplied equilibrium. At M8b.1 completion,
overall M8 remained COMPLETE - AMBER because the discount and dispersion
paths were still supplied. M8b.2 now constructs them and has passed review.

`AppendixIFTAssumptions.q_contDiffOn_pos` is an explicit technical regularity
strengthening, not a conclusion claimed by the paper. The theorem claims
neither global path uniqueness nor global equilibrium uniqueness.

**Human-review checklist:** [x] Human mathematical/economic review is complete
(2026-08-01).

## M8b.2 - Discount and dispersion IFT paths

**Implementation status:** **COMPLETE - GREEN**, reviewed 2026-08-02.

For each supplied `R : ReducedEquilibrium P`, M8b.2 parameterizes the scalar
JD/JC crossing residual by the discount rate and by dispersion. The base roots
and JD-implied base tightness are derived from the equations stored in `R`.
Both cutoff partials are proved strictly negative by reduction to
`Primitives.deriv_staticCrossingResidual_neg`; no Jacobian or nondegeneracy
condition is assumed.

The local `C¹` residual theorems feed
`exists_discountEquilibriumPath_of_ift` and
`exists_dispersionEquilibriumPath_of_ift`. These constructors prove local
parameter positivity, JD, product-form JC, base-point recovery, and
differentiability before creating the existing M8 path records. Their selected
paths feed `m8b_discount_capstone` and `m8b_dispersion_capstone`. The former
proves `thetaSlope < 0` and the exact A8 iff cutoff-sign characterization. The
latter uses normalization and `b ≤ p` only at the sign-capstone stage to prove
positive tightness and cutoff slopes; path construction needs neither.

`ReducedEquilibrium.m8b_full_appendix_capstone` combines all four IFT-derived
Appendix paths. It takes no path object, `StaticExistenceAssumptions`, M5
selection, derivative sign, or nondegeneracy assumption. Human review found
the discount residual/path, dispersion residual/path, and full capstone
**COMPLETE - GREEN**. The existing M8 equations and signs are reused unchanged.

The full Appendix IFT-derived package is therefore **COMPLETE - GREEN**
relative to a supplied regular reduced equilibrium, Appendix matching and IFT
regularity, and the explicitly stated sign conditions. The historical AMBER
grade for the original supplied-path M8 layer remains accurate. Selecting the
base equilibrium from primitives would be a separate wrapper and would inherit
M5's AMBER existence qualification.

**Human-review checklist:** [x] Human mathematical/economic review is complete
(2026-08-02).

## M9.1 - Anticipated two-state foundations

**Implementation status:** **COMPLETE - GREEN**, reviewed 2026-08-02

M9.1 defines recession and boom as an involutive two-state process. The boom
changes only common productivity from `P.p` to `T.pHigh`; all other primitives
and the idiosyncratic shock law remain common. `TwoStateValueEquilibrium P T`
records state-contingent versions of the primitive value equations with the
aggregate switching rate `T.aggregateArrival` included explicitly.

Surplus is the actual derived value
`J s eps + W s eps - U s`. The idiosyncratic, aggregate-surplus, and worker
aggregate continuation expressions are defined once and reused in the value
equations. From a supplied equilibrium, Lean derives firm sharing, zero
vacancy values, the statewise vacancy-cost identity, and the raw surplus flow
equation.

With `D : ShockAssumptions P`, `coupled_surplus_bellman` locally installs the
probability instance and proves the general max-based coupled system

```text
(r + lambda + aggregateArrival) S_s(eps)
  = productivity_s(eps) - b
    + lambda ∫ max(S_s(x), 0) dP.shock
    - beta * theta_s * q(theta_s) * S_s(epsUpper)
    + aggregateArrival * max(S_other(s)(eps), 0).
```

`recession_surplus_bellman` and `boom_surplus_bellman` specialize this system.
The declarations `equation16_of_boom_surplus_nonneg`,
`equation17_of_recession_surplus_nonneg`, and
`equation18_of_recession_surplus_nonpos` prove the paper's regional algebra
only under explicit pointwise sign hypotheses.

The result is conditional on a supplied `TwoStateValueEquilibrium`; M9.1 does
not prove its existence. It contains no statewise cutoff, cutoff ordering,
affinity result, reduced two-state equilibrium, job-creation system,
unemployment dynamics, or impact-asymmetry conclusion. See
[`two_state_foundations_scope.md`](two_state_foundations_scope.md).

The paper writes equations (16)–(18) after using the expected ordering of boom
and recession cutoffs. M9.1 instead formalizes one general max-based system.
M9.2 must prove the ordering before interval-specific formulas are certified.

Human review confirmed that aggregate capital gains are present in all four
primitive value equations and that the coupled surplus equation is derived,
not assumed. The equation-(16)-(18) results are max-form sign reductions, not
yet cutoff-indexed interval-integral formulas. Conditionality on an existing
`TwoStateValueEquilibrium` is the theorem's correct scope and does not make it
AMBER. No cutoff or ordering assumption is present.

**Human-review checklist:** [x] Human mathematical/economic review is complete
(2026-08-02).
