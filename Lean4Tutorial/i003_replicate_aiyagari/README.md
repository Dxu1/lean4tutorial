# Aiyagari (1994) in Lean 4

This directory formalizes the theoretical model summarized in
`aiyagari1994_theory_summary.tex`.  The development separates model objects,
primitive assumptions, equilibrium definitions, and derived properties.

## Architecture

- `Definitions.lean`: concrete primitives and derived constructions: feasible
  paths and stochastic processes, debt bounds, Bellman operator and feasible
  choices, policy-induced Markov kernel, invariance, and integrated asset
  supply.
- `Assumptions.lean`: primitive sign, support, utility, impatience,
  technology, and drift conditions.  Numbered conclusions are excluded.
- `StochasticPaths.lean`: the canonical infinite-product labor history,
  coordinate laws, and positive-probability lower-support blocks.
- `DynamicProgramming.lean`: reusable compact-maximization, probability
  integration, sup-norm contraction, and Banach fixed-point theorems.
- `AiyagariBellman.lean`: the continuous excess-resource model, compact saving
  shares, bounded reward and transition, and the constructed bounded household
  value and unique continuous optimal policy.
- `MonotoneFeller.lean`: reusable Feller, order-preservation, and genuine
  common-shock splitting interfaces for the stationary-law layer.
- `Equilibrium.lean`: household and stationary equilibria using probability
  measures, the induced kernel, invariance, and distributional market clearing.
- `PropertiesHousehold.lean`: Properties 1--5 and the counterexamples needed to
  show why the former Property 1 statement was false without feasibility.
- `PropertiesStationary.lean`: Properties 6--10.  Stationary-law evolution is
  the push-forward by the policy-induced kernel, on probability laws equipped
  with the Lévy--Prokhorov metric.
- `PropertiesEquilibrium.lean`: Properties 11--17.
- `PropertiesExtensions.lean`: Properties 18--20, including a path-set
  equivalence for debt neutrality.
- `Verification.lean`: `assert_no_sorry` and transitive axiom audits for every
  numbered theorem.

## What changed

The old interfaces `UniqueStableInvariantData`, abstract `BellmanSolution`,
arbitrary `meanAssets`/`evolve` fields, and theorem-shaped hypotheses such as
`sourceCutoffTheorem` have been removed.  `HouseholdEquilibriumData` no longer
contains uniqueness.  Stationary equilibria carry an actual probability
measure invariant under the household policy's kernel, and market clearing is
an integral identity.

The numbered theorem names are preserved, but their types intentionally break
compatibility with the former circular statements.

## Established proof layers

- Property 1 is proved for the canonical i.i.d. history space.  The reverse
  implication combines predictability, independence, lower-support
  reachability, and discounted budget summation.  The minimum-income theorem
  remains a supporting result, and two deterministic counterexamples certify
  that neither old implication is valid without budget feasibility.
- In the bounded finite-at-zero branch, the Bellman self-map is constructed on
  bounded continuous functions.  Probability integration and compact
  maximization are proved nonexpansive, so the beta contraction, value
  existence, and value uniqueness follow directly from Banach's theorem.
  Bellman iteration proves value concavity; strict utility concavity gives a
  unique optimizer; a maximum-theorem argument proves policy continuity.
  The numbered Property 2 no longer accepts a contraction certificate, fixed
  point, or optimizer.
- Assets and consumption are both proved weakly increasing from optimality,
  and the global finite-difference bounds
  `0 ≤ A(x₂)-A(x₁) ≤ x₂-x₁` are derived.  A reusable two-sided slope-sandwich
  envelope lemma is also formalized.
- The solved excess-resource transition is proved jointly continuous, Feller,
  and order preserving.  A common-shock splitting interface records the extra
  primitive fact actually needed for stationary-law uniqueness.
- The current conditional resource-drift theorem has an explicit threshold.
  The older Banach proof for a contracting law push-forward is retained as an
  amber intermediate result; it is not treated as the intended monotone--
  Feller proof of Property 7.
- Continuity, reciprocal-gap divergence, local uncertainty dominance,
  intermediate-value existence, factor-price comparisons, saving-rate signs,
  borrowing-limit slackness, debt path equivalence, and the monetary return
  bound are proved from their displayed analytic conditions.

## Explicit frontier

The refactor does not disguise unfinished economics as theorem hypotheses.
The following stronger paper-level steps remain separate future proof layers:

- apply the envelope lemma to the solved Bellman objective, prove the Euler
  conditions and nondegenerate cutoff, parameter continuity, and the weighted
  Inada branch;
- derive the kernel contraction/drift and the quantitative asset-explosion
  bound from risk-aversion assumptions, then complete Krylov--Bogoliubov and
  finite-step splitting proofs for stationary laws;
- replace the normalized finite-state aggregation witnesses in Properties 8
  and 13 with certified optimal CRRA/Cobb--Douglas household models; and
- derive the uncertainty and monetary asset-supply comparisons from invariant
  law parameter-continuity rather than taking the displayed local comparison
  conditions as inputs.

These gaps are represented by narrower theorem statements, not by `sorry`,
axioms, arbitrary proposition parameters, or assumptions named after desired
conclusions.

## Build and audit

From the repository root:

```sh
lake build Lean4Tutorial.i003_replicate_aiyagari
lake env lean Lean4Tutorial/i003_replicate_aiyagari/Verification.lean
```

`Verification.lean` checks all twenty properties with `assert_no_sorry` and
prints each theorem's transitive axiom dependencies.  The source audit should
also find no `source...Theorem` argument in this directory.
