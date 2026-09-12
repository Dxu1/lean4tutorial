# Milestone 00 changed files

Paths are relative to this standalone execution package. The containing Git workspace currently reports the whole package as untracked; comparison here uses the shipped `PACKAGE_SHA256.json` baseline.

## Modified design-package files

- `contracts/theorems.json`
- `docs/BUILD.md`
- `docs/ledger_header.tex`
- `docs/proof_ledger.md`
- `docs/proof_ledger.pdf`
- `docs/proof_ledger.tex`
- `tools/build_docs.sh`

## New configuration, Lean code and evidence

- `.gitignore`
- `Aiyagari1994.lean`
- `All.lean`
- `Audit.lean`
- `Probes/ApiSignatures.lean`
- `Probes/Core.lean`
- `lake-manifest.json`
- `lakefile.toml`
- `lean-toolchain`
- `reports/00_api_inventory.md`
- `reports/00_artifact_sha256.json`
- `reports/00_changed_files.md`
- `reports/00_dependencies.json`
- `reports/00_environment.md`
- `reports/00_milestone.md`
- `reports/00_sources.md`
- `reports/logs/00_api_signatures.log`
- `reports/logs/00_axioms.log`
- `reports/logs/00_cache.log`
- `reports/logs/00_cache_modules.log`
- `reports/logs/00_contracts.log`
- `reports/logs/00_docs_attempt1.log`
- `reports/logs/00_docs_build.log`
- `reports/logs/00_full_attempt1.log`
- `reports/logs/00_full_build.log`
- `reports/logs/00_integrity.log`
- `reports/logs/00_pdf_qa.md`
- `reports/logs/00_pdf_render.log`
- `reports/logs/00_probe_attempt1.log`
- `reports/logs/00_probe_attempt2.log`
- `reports/logs/00_probe_build.log`
- `reports/logs/00_sources.log`
- `reports/logs/00_versions.log`
- `sources/papers/extraction_report.json`

## Ignored local material

- `.lake/`: independent pinned dependency checkouts and compiled caches.
- `sources/input_archives/`: two source-only ZIP adapters constructed from the approved reference PDFs.
- `sources/papers/*.pdf`: ten verified whitelist outputs.
- `tmp/pdfs/`: ledger renders/contact sheets.
- TeX auxiliary files.

The supplied reference PDFs were read only for source-byte verification and not modified. No failed implementation files were accessed. No commits or review-acceptance records were created.
