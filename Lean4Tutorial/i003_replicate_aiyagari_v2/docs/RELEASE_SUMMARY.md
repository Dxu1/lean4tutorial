# Release summary

The completed release contains 57 accepted theorem contracts: 52 core results, two diagnostics, and three exact extensions. It formalizes the defined continuous-asset, iid-income, bounded-utility Aiyagari theorem family. The mathematical release commit is `fa1c6188837f9f460481868679d3847a12dbb7e9`. Subsequent documentation maintenance preserves that release and its evidence.

## What was formalized

Households face a general probability law on a compact positive labor interval, with iid future draws. Atoms are allowed and a density is unnecessary. The analytic state space is the nonnegative reals; no asset grid or finite-support approximation replaces it. Utility is bounded, continuous, strictly increasing and strictly concave, with additional smoothness and curvature hypotheses only where the relevant results require them.

The normalization shifts net assets by the effective debt limit: `aHat = a + phi`. Resources satisfy `z = R*aHat + e(l)`, and the canonical policy `A(z)` chooses next-period shifted assets. Net assets are `A(z) - phi`. This fixed state space permits price comparisons without changing domains.

The household Bellman construction works for every admissible positive gross return. Strict impatience, `βR < 1`, enters stationary-law and related subcritical results. It is not assumed in the general equilibrium definition.

## Main economic results

**Household optimization.** A contracting Bellman operator constructs a unique bounded continuous value function and a unique continuous optimal policy. Lifetime verification covers the admitted measurable nonanticipative feasible plans. Policy order, Lipschitz bounds, joint price/state continuity, right marginals, and qualified envelope and Euler conditions support the later analysis.

**Stationary household behavior.** The actual policy-induced kernel is Feller and monotone. Derived drift and endpoint-crossing properties establish a unique invariant probability law on the full nonnegative state space and global weak convergence under the contracted strict-impatience assumptions. Common compact bounds yield interior stationary-law and asset-supply continuity; weak convergence alone is not used to pass unbounded moments.

**Boundary behavior.** Nondegenerate iid income rules out invariant probability laws when `βR ≥ 1`, including laws without finite first moments. Tightness and invariant-limit arguments imply that stationary asset supply diverges upward as the impatience boundary is approached under the contracted price limits. In the natural-limit family, net asset supply diverges downward as the positive interest rate approaches zero.

**General equilibrium.** The competitive firm side yields continuous capital demand and wages. Stationary equilibria exist for every finite institutional cap and for the natural-limit family. Every stationary equilibrium satisfies `r < 1/β - 1`; this is proved for the full equilibrium definition, not built into it. Every risky equilibrium has strictly more capital than the mean-income certainty benchmark, a higher gross replacement-investment/output share, and aggregate goods-market clearing. Equilibrium uniqueness is not claimed.

**Borrowing and debt.** Finite-horizon budget accounting leads to the qualified natural-bound/No-Ponzi correspondence. E01 proves the exact zero-rate translation of net asset supply when the cap changes. E02 identifies household problems beyond the natural cap, with stationary conclusions on the subcritical branch. E03 proves a government-debt/debt-free correspondence in pure exchange under the tax-adjusted natural borrowing bound.

## Important qualifications and corrections

- **Zero-state marginal:** use `zeroRightMarginal` for the economic marginal at zero. Never interpret `rightMarginalValue m 0` as that marginal.
- **D01 diagnostic:** Inada utility and zero minimum effective income alone do not ensure that saving is positive at every positive state. The accepted continuous-income example has a binding region; an atom at zero provides the separate sufficient condition in H14.
- **Policy order and precautionary comparison:** policy monotonicity is weak, with Lipschitz bounds. A05 gives a weak risky-versus-certainty asset comparison throughout its subcritical domain and strictness sufficiently near the impatience boundary. It is not a general risk-order theorem or global interest-rate monotonicity result.
- **Gross versus net saving:** G07 compares `δK/f(K)`, the gross replacement-investment/output share. Stationary net saving is zero.
- **No-Ponzi:** the discounted terminal wealth limit is finite and nonnegative, not necessarily zero. The converse retains adaptedness, feasibility and the specified iid income conditions.
- **Lifetime utility:** H05 uses limits of expected finite discounted sums; its original acceptance does not claim construction of a literal infinite-product random lifetime utility variable.
- **Debt scope:** E03 concerns pure exchange with a tax-adjusted natural bound. It is not fixed-cap or production-economy debt neutrality.

The release does not cover quantitative calibration or simulation, empirical estimation, general unbounded log/CRRA utility, persistent labor income, arbitrary debt neutrality, or monetary/growth models. The [coverage record](source_coverage.md) retains deferred claims. The [qualification register](../reports/stage11_final_evidence/qualification_register.json) preserves the full accepted restrictions.

## Verification and provenance

All 57 contracts and the assembled release are GREEN. Stage 11 completed a fresh clean build (3,224 jobs), 826 no-sorry checks with corresponding axiom outputs, exact-signature/dependency checks, source-fidelity checks, and shared/root provenance audits. The permitted transitive axioms are `propext`, `Classical.choice`, and `Quot.sound`.

Lean kernel verification checks proof terms against their formal statements. Independent Astra High release review returned PASS/HIGH with no blockers and no human-review flag; no XHigh review was needed. Adequacy review assesses economic interpretation and source fidelity and is separate from the kernel.

The acceptance chain includes 47 modern structured contracts and ten authorized legacy external ACCEPT contracts. The legacy records retain null confidence and human-review fields; later-schema metadata was not fabricated. Their reviewed archive hashes, acceptance commits, qualifications and final-environment preservation were validated explicitly. No theorem was re-accepted during the legacy compatibility repair.

The local `aiyagari_release.zip` remains the frozen mathematical-release package. Its SHA-256 is `8a99f0fc3b186c3413a8ba743ef6c0a8032dc8c7da8cbedf5bf769761f6be769`. This documentation pass does not replace it or alter its receipt.

## Navigation

- New readers: [project README](../README.md) and [theorem index](THEOREM_INDEX.md).
- Detailed proofs and exact signatures: [proof ledger PDF](proof_ledger.pdf) and [Markdown](proof_ledger.md).
- Contributors: [repository instructions](../AGENTS.md), [architecture](architecture.md), [interfaces](lean_interfaces.md), and [build documentation](BUILD.md).
- Auditors: [theorem manifest](../contracts/theorems.json), [assumption profiles](../contracts/assumptions.json), [Stage-11 report](../reports/11_milestone.md), and [release decision](../reviews/stage11_release_acceptance.json).
- Historical execution: [milestone prompts](../prompts/INDEX.md), [review records](../reviews/README.md), and [orchestration documentation](../orchestration/README.md).
