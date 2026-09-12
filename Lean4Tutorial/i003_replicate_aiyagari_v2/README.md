# Aiyagari (1993/1994) — theory-only Lean execution package

**Version 1.0 · September 11, 2026 · Design package, not completed Lean proofs**

## Start

1. Unzip this package into a **new** project directory. Keep it separate from the unsuccessful implementation. Make `i003_replicate_aiyagari.zip` and `citations.zip` available as read-only input archives, either in the parent directory or another known location. The MP archive is not required to execute this package.
2. Open that new directory in Codex. Paste `prompts/00_bootstrap.md`. This sets up a clean pinned Lean project, verifies source hashes, tests the relevant Mathlib APIs, and stops. It does not implement the entire paper.
3. Return the milestone report, API findings, ledger, changed files and build logs for review. After an accepted review, run `prompts/01_primitives.md`. Continue in the numbered order, with the `07a` and `07b` split retained.

No new source download is needed for the contracted core. The archive PDFs are intentionally not duplicated in this package. `tools/extract_sources.py` copies only approved primary-source PDFs after verifying their SHA-256 hashes.

## Contents

- `docs/architecture.pdf` and `.md` / `.tex`: mathematical design, source corrections, substantive proof constructions, model scope and dependency policy.
- `docs/proof_ledger.pdf` and `.md` / `.tex`: initial theorem ledger. Every entry is **UNFORMALIZED**, with a target, dependencies and a proof-plan locator; it is not evidence of completed proofs.
- `docs/lean_interfaces.md`: typed interface design and representation decisions; illustrative, not a falsely advertised compiled Lean file.
- `contracts/theorems.json`: 57 theorem contracts, declaration names, files, dependencies, stages and statuses.
- `contracts/source_coverage.json`: what is core, diagnostic, extension, deferred or excluded by the user.
- `contracts/source_manifest.json`: exact paper inventory and hashes; original printed/PDF page locators.
- `contracts/assumptions.json`: primitive assumption profiles and prohibited conclusion-like fields.
- `contracts/api_sources.json`: official API locators, checked against the actual installed checkout in milestone 00.
- `AGENTS.md`: persistent Codex instructions.
- `prompts/`: 13 milestone prompts, including the separate marginal/Jensen and critical-boundary stages.
- `reports/`, `reviews/`: report templates and review-gate protocol.
- `tools/`: source extraction and structural manifest checks only; no economic computation.

## Status and scope

No Lean code was compiled in preparing this package. The mathematical constructions are proposed proof routes requiring both kernel checking and substantive adequacy review. The implementation destination is namespace `Aiyagari1994`, with a root `Aiyagari1994.lean`, `All.lean`, and `Audit.lean` created in milestone 00.

The primary release is **core stationary theory: continuous assets, iid income, bounded utility**. It includes the canonical household optimum, stationary distribution, critical-boundary nonstationarity and asset-supply divergence, both finite-cap and natural-limit equilibrium existence, and the capital/gross-saving comparison. It is not a full log/CRRA, persistent-income or pathwise-divergence replication. Deferred claims remain explicit in the coverage file. No grid-based or numerical fallback is allowed.

## Validation commands

Before any Lean implementation:

```sh
python3 tools/check_contracts.py
python3 tools/extract_sources.py --aiyagari /path/to/i003_replicate_aiyagari.zip \
  --citations /path/to/citations.zip --output sources/papers
```

The structural checker detects broken IDs, dependency cycles, missing prompts and malformed status/review records. It does **not** certify proofs or economic adequacy. `--release core` intentionally fails while required contracts are unformalized. The normal check is expected to pass for this design-only package.

After toolchain setup, run `lake build` and the exact audit commands recorded in the environment report. The PDF sources can be rebuilt with the commands in `docs/BUILD.md`.

## Reasoning levels

Use **High** for 00 and 01; **Extra-high** for 02–09 and the No-Ponzi part of 10; **High** for the algebraic extensions and final packaging. Medium is suitable only for subordinate formatting or mechanical refactoring after the theorem contract is fixed. These are recommendations, not required model-menu labels.
