# Aiyagari (1994) Lean Formalization

A completed Lean 4 formalization of the project's Aiyagari (1993/1994) theorem family: household optimization, stationary distributions, asset supply, general equilibrium, and exact borrowing-limit and debt correspondences. This is a theory-only project with continuous assets, iid bounded labor income, and bounded utility.

## Status

All **57 theorem contracts are GREEN**: 52 core results, two diagnostics, and three scoped extensions. The assembled release is **GREEN** following independent Astra High **PASS/HIGH** review. The final clean build passed; the release audit checked 826 declarations for `sorry` and transitive axioms.

Lean's kernel checks formal proofs. The separate economic/source adequacy review assesses whether their statements and assumptions support the intended claims. The only permitted transitive axioms are `propext`, `Classical.choice`, and `Quot.sound`; this is not an axiom-free claim.

## Scope and main results

- **Household problem:** construct the canonical Bellman value and unique continuous policy; prove lifetime optimality, weak policy monotonicity, continuity, and the qualified envelope, Euler and marginal results.
- **Stationary distributions:** construct the Feller, monotone household kernel; under the contracted strict-impatience and regularity hypotheses, prove existence, uniqueness on the full state space, global weak convergence, and stationary asset-supply continuity.
- **Impatience boundary:** with nondegenerate iid income, rule out invariant laws at or above `βR = 1`. Establish asset-supply divergence at the upper boundary and the natural-limit lower boundary.
- **General equilibrium:** prove existence for finite and natural borrowing limits, universal equilibrium subcriticality, and goods-market clearing. Every risky stationary equilibrium has more capital and a higher gross replacement-investment/output share than the mean-income certainty benchmark.
- **Extensions:** prove the qualified No-Ponzi/natural-bound correspondence, the zero-rate borrowing-cap translation, equality beyond the natural cap, and the government-debt correspondence in pure exchange with tax-adjusted natural borrowing.

The model admits general probability laws on a compact positive labor interval, including atoms; it does not require finite support or a density. Strict impatience is imposed by the results that need it, not by the primitive household or equilibrium definition. See the [release summary](docs/RELEASE_SUMMARY.md) for the economic interpretation and qualifications.

## Important qualifications

The release does not cover numerical calibration, simulation, asset grids or estimation; general unbounded log/CRRA utility; persistent income; equilibrium uniqueness; or global asset-supply monotonicity. Debt results do not establish arbitrary, production-economy or fixed-cap neutrality. Monetary and growth extensions remain outside the contracted release. [Source coverage](docs/source_coverage.md) distinguishes completed, deferred and excluded claims.

## Repository structure

| Area | Purpose |
| --- | --- |
| `Aiyagari1994/`, `Aiyagari1994.lean`, `All.lean` | Formal mathematics and import roots |
| `Audit.lean`, `Probes/` | Declaration, no-sorry, axiom and API checks |
| `contracts/` | Authoritative theorem statements, assumptions, dependencies and source manifests |
| `docs/` | Proof ledger, release summary, theorem index and design specifications |
| `reviews/`, `reports/` | Acceptance decisions, qualifications and verification evidence |
| `prompts/` | Historical milestone execution instructions |
| `orchestration/`, `tools/` | Review-controller infrastructure and deterministic audit/document tools |

## Building and verification

Run from `Lean4Tutorial/i003_replicate_aiyagari_v2`, with Elan and Python 3 available:

```sh
lake build
lake env lean Audit.lean
python3 tools/check_contracts.py
python3 tools/check_contracts.py --release core
python3 tools/check_contracts.py --release extended
```

[lean-toolchain](lean-toolchain), [lakefile.toml](lakefile.toml) and [lake-manifest.json](lake-manifest.json) pin the environment. Preserve these pins. `Audit.lean` performs declaration, no-sorry and axiom checks. The Python checker validates structural contracts and acceptance evidence; it is not an economic proof. Full historical acceptance validation also requires the preserved local review artifacts referenced by the records; those archives are not all distributed in a source checkout.

## Proof documentation

Start with the [release summary](docs/RELEASE_SUMMARY.md) and [57-result theorem index](docs/THEOREM_INDEX.md). The authoritative detailed record is the [proof-ledger PDF](docs/proof_ledger.pdf), also available as [Markdown](docs/proof_ledger.md). Contributors should read [AGENTS.md](AGENTS.md), the [architecture](docs/architecture.md), [interface design](docs/lean_interfaces.md), and [documentation build instructions](docs/BUILD.md). The design documents preserve the original proof plan; the ledger records the accepted implementation.

Auditors can begin with the [Stage-11 report](reports/11_milestone.md), [release decision](reviews/stage11_release_acceptance.json), [modern acceptance index](reports/stage11_final_evidence/modern_acceptance_index.json), and [legacy acceptance bridge](reports/stage11_evidence/legacy_acceptance_bridge.json). Ten contracts retain historical external ACCEPT decisions with unavailable confidence/human-review fields left null; 47 have modern structured operative PASS/HIGH reviews.

## Source papers

The principal sources are Aiyagari's December 1993 Working Paper 502 and the 1994 *Quarterly Journal of Economics* article, both titled *Uninsured Idiosyncratic Risk and Aggregate Saving*. Supporting sources include Stokey–Lucas–Prescott (1989), Benveniste–Scheinkman (1979), Schechtman–Escudero (1977), and the other references in the [source manifest](contracts/source_manifest.json) and [architecture bibliography](docs/architecture.md). Source PDFs are private inputs and are not redistributed. The [source-fidelity audit](reports/stage11_final_evidence/source_locator_audit.json) records the release evidence.

## Release provenance

The mathematical release commit is **`fa1c6188837f9f460481868679d3847a12dbb7e9`**. Its completed controller state is `STAGE11_RELEASE_COMPLETE_HUMAN_CHECKPOINT`; see the [checkpoint record](reports/stage11_release_checkpoint.json). The accepted ZIP and receipt remain frozen local distribution artifacts. Later documentation commits do not constitute a new mathematical release; the [cleanup report](reports/post_completion_cleanup.md) records this documentation pass.
