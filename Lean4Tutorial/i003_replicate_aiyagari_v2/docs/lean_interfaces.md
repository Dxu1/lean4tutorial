# Lean-facing interface design

This file specifies representations and typed relationships. It is **not compiled Lean code**. Prompt 00 determines the exact Mathlib spelling of probability/weak-topology APIs; Codex may adapt these representations without changing mathematical domains or quantifiers. Public target declarations are named in `contracts/theorems.json`.

## Base spaces and record split

Use the fixed state `NNReal` (or the equivalent nonnegative-real subtype). Use a compact labor subtype `{l : Real // l_min <= l ∧ l <= l_max}` carrying a probability measure. The lower/upper endpoints are numeric primitive data; positivity and order live in an income-assumption record. Endpoint-neighborhood positivity is a separate nondegeneracy hypothesis, not needed for the Bellman fixed point. Keep the labor law fixed in price-continuity results.

A useful split is:

- `UtilityData`: function `Real → Real`, with every economic property restricted to `Set.Ici 0`; evaluate it at coerced nonnegative consumption. Values at negative arguments are irrelevant and must not enter a theorem. This representation permits ordinary real differentiation on `Set.Ioi 0`.
- `UtilityBase`: continuity, boundedness, strict increase and strict concavity.
- `UtilitySmooth`: C1 and positive derivative at positive consumption.
- `UtilityCurvature`: C2 and eventual relative-risk-aversion bound.
- `IncomeData`: compact labor type and probability measure.
- `IncomeSupport`: positive essential endpoints; optional mean-one normalization.
- `NormalizedPrices`: `R>0`, plus a nonnegative continuous effective-income function on the fixed labor space. For the paper's affine model, store slope `w>0` and intercept `k` with `e(l)=w*l+k>=0`.
- `OriginalPrices`: net rate, wage and effective debt limit, with a proved map into `NormalizedPrices` using `k=-r*phi`.
- `FiniteCapFamily` and `NaturalCapFamily`: functions constructing original/normalized prices from their primitive arguments, **not** records containing stationary-law conclusions.
- `ProductionData` / `ProductionRegularity`: technology and its explicit neoclassical assumptions.

The normalized representation `(R,w,k)` is important: the natural-limit lower-boundary theorem has `phi→infinity`, but `k=-w*l_min` remains bounded. Continuity and uniform drift are stated for normalized parameters first. Keep `phi` outside the Bellman parameter so it only re-enters when converting shifted to net assets.

## Real derivatives versus the nonnegative state subtype

`NNReal` is not a real normed vector space. Do not apply ordinary real differential calculus directly to a function whose domain is `NNReal`. The default utility and production representations are `Real → Real`, with continuity/concavity/boundedness/nonnegativity restricted to the economic domain and differentiability only on strictly positive inputs. The Bellman state and feasible controls remain nonnegative.

For the bounded continuous value function on `NNReal`, use the real extension `x ↦ V(x.toNNReal)` when a real-domain derivative theorem is needed. This extension agrees with the economic function on nonnegative inputs; claim concavity only there, not on all real numbers. Define the right marginal by one-sided secant limits, not by the ordinary `deriv` operator before differentiability has been established. An ordinary derivative at a point of nondifferentiability must never silently become a zero marginal.

## Canonical objects versus proof records

After `H02`, define `valueFunction (model) : BoundedContinuousFunction NNReal Real` by the proved fixed-point constructor. After `H04`, define `assetPolicy (model) (z) : NNReal` by unique compact maximization, with a theorem `assetPolicy_le_state`. Define consumption by a nonnegative subtype construction using that bound, not truncated subtraction with unproved positivity.

A proposed dependency chain is:

```text
UtilityData + UtilityBase + IncomeData + NormalizedPrices
    -> bellmanOperator
    -> valueFunction and its uniqueness proof
    -> assetPolicy and argmax proof
    -> consumptionPolicy
    -> householdKernel
```

An optional record may bundle a *proved* object and its specification after construction. It must not be accepted as an independent primitive argument of the paper's existence theorem.

## Marginal types

Use a nonnegative extended-real right marginal (`ENNReal`, or an equivalent explicit finite/infinite sum type) before establishing finiteness. At each positive resource state concavity proves it finite; convert to a real-valued `rightMarginalValue` there. At zero, preserve the case distinction until N01 proves finite marginal or stationary null mass.

For (M), first use `lintegral` of nonnegative difference quotients. Prove the bound by a finite marginal; only then obtain a Bochner/real integral and rewrite. Never invoke `integral_undef` as an economic argument.

## Feasible plans

For fixed initial resources, date-t controls are measurable functions of length-t future labor histories (current period zero is already summarized by the initial resource state). States are recursively generated from past controls and newly drawn labor. Require feasibility almost everywhere for each finite history law. A full plan is a sequence of such controls; expected lifetime utility is the limit of finite discounted sums. Prove compatibility of finite products and one-step integration to obtain H05.

For the original No-Ponzi theorem, retain the paper's timing explicitly: `a_t` is measurable before `l_t`, while `c_t` and `a_(t+1)` can depend on `l_t`. This requires either an infinite product probability space or an abstract filtration with conditional independent labor; the latter must be instantiated by the iid product construction. No-Ponzi's tail event cannot simply be defined on one finite history.

## Kernels and invariant laws

Use `ProbabilityTheory.Kernel` with an `IsMarkovKernel` instance after checking the installed API. Define `IsInvariant (P) (mu)` by equality of the pushed law and `mu`, or equivalent equality of bounded-continuous test integrals after a proved separation lemma. The latter equivalence must not be assumed.

A generic `compact_monotone_feller_stability` theorem takes a compact interval, a Markov kernel, Feller and monotonicity proofs, and a **mathematical crossing hypothesis**. The paper wrapper derives those arguments. For the full-space law, define `stationaryLaw` only after S05 proves existence and uniqueness. Calling `Classical.choose` on an assumed existence field is prohibited.

## Aggregation and equilibrium

Define shifted and net law pushforwards explicitly. `stationaryAssetSupply` is the real integral of `A-phi`, accompanied by a compact-support/integrability theorem. Its domain is the impatient normalized model plus the effective debt shift, not an arbitrary supplied asset-supply curve.

The equilibrium type has a rate in `(-delta,infinity)`, the firm-derived wage and capital, a probability law, household optimality/canonical-policy identity, invariance, required first-moment integrability, and clearing. It must **not** contain `r<lambda`, `beta*R<1`, or a unique-equilibrium assertion. The existence function may construct equilibria on the subcritical branch; G04 must quantify over the larger equilibrium type.

## Assumption tags and declaration granularity

`contracts/assumptions.json` gives named mathematical profiles. In the theorem manifest, tags are dependency/context annotations, not instructions to concatenate every profile into one premise. Branches concerning finite and natural limits have their own arguments. Reusable sublemmas must use the weakest profile they need; final exported signatures must expose all transitive economic hypotheses actually used.

An ID can export one umbrella theorem plus clearly named helper declarations when its statement has several clauses. Keep the contracted main name as the audit anchor. Do not make it a vacuous conjunction of unrelated assumed results. Record the exact final elaborated signature in the ledger and compare it with the contract before review.
