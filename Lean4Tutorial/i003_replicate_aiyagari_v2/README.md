# Aiyagari (1993/1994): theory-only Lean formalization

All **57 theorem contracts are GREEN**: 52 core contracts, two diagnostics, and three scoped extensions. The assembled release is **GREEN** following independent Astra High PASS/HIGH review, with no blockers or human-review flag.

The formalization uses continuous assets, a general probability law on a compact positive labor interval, iid finite-history income laws, and bounded utility. It constructs the canonical household value and policy, proves lifetime optimality over the admitted measurable full-history feasible plans, and establishes the contracted stationary-law, critical-boundary, asset-supply and equilibrium results. Strict impatience is imposed where the relevant contract requires it, not as a universal household or equilibrium assumption.

The No-Ponzi layer distinguishes finite-horizon accounting, a finite nonnegative terminal wealth limit, and the qualified weak-No-Ponzi converse. The extension layer contains E01's zero-rate finite-cap translation, E02's cap comparison with subcritical stationary qualifications, and E03's constant-debt pure-exchange correspondence under the tax-adjusted natural borrowing limit. E03 is not fixed-cap or production-economy debt neutrality.

This is a theorem-only project: no numerical calibration, asset grid, or simulated results. The release does not establish unbounded log/CRRA utility, persistent income, global asset-supply monotonicity, equilibrium uniqueness, arbitrary debt neutrality, monetary reinterpretation, or a growth model. Deferred and excluded claims remain explicit in `contracts/source_coverage.json`.

## Evidence and scope

- [Proof ledger](docs/proof_ledger.pdf), with editable [Markdown](docs/proof_ledger.md) and generated TeX: exact declarations, readable proofs, qualifications, sources and audit output.
- [Theorem manifest](contracts/theorems.json): authoritative statements, assumptions, dependencies and statuses.
- [Release audit](reports/11_milestone.md): Stage-11 progress, evidence and limitations.
- [Legacy acceptance bridge](reports/stage11_evidence/legacy_acceptance_bridge.json): ten explicitly authorized historical external ACCEPT contracts. Unavailable confidence/human-review fields remain null.
- [Modern acceptance index](reports/stage11_evidence/modern_acceptance_index.json): 47 contracts with operative structured PASS/HIGH reviews.
- `reviews/`: unchanged historical decisions and retained qualifications. Infrastructure checks do not replace independent adequacy review.

Lean is pinned by `lean-toolchain`; Mathlib and dependencies are pinned by `lakefile.toml` and `lake-manifest.json`. Audited transitive axioms are limited to **propext, Classical.choice, and Quot.sound**. The project is not advertised as axiom-free.

## Verification

```sh
lake build
lake env lean Audit.lean
python3 tools/check_contracts.py
python3 tools/check_contracts.py --release core
python3 tools/check_contracts.py --release extended
```

`Audit.lean` contains the declaration, no-sorry and transitive-axiom checks. The Python checker validates structural metadata and acceptance evidence; it does not independently authenticate reviewers or prove economic adequacy.

Source-paper PDFs are private inputs and are excluded from release archives. Only the exact whitelist in `contracts/source_manifest.json` may be extracted with `tools/extract_sources.py`. Do not use the failed prior implementation. Documentation rebuild instructions are in [docs/BUILD.md](docs/BUILD.md); regenerate the ledger with `bash tools/build_docs.sh proof_ledger` and inspect its rendering.
