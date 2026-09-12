# Milestone 00 environment report

Status: REVIEW_READY, awaiting external acceptance. Date: September 11, 2026.

Project: `/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2`. Package and namespace: `Aiyagari1994`.
Parent workspace HEAD: `65406a5df90ed0df6c282bb220541f882218bbf6`. This package is uncommitted; that HEAD is context, not a commit containing these results.

## Pins and provenance

Lean toolchain: `leanprover/lean4:v4.32.0`.
Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997` (local tag `v4.32.0`).

The version was obtained from the clean workspace dependency checkout at `/Users/davidxu/Documents/lean4tutorial/.lake/packages/mathlib` and its own `lean-toolchain` and `lake-manifest.json`, not from the failed model. Its tracked files were clean. No web-version assumption was needed. A fresh package configuration was written directly, preserving the design package. The top-level lock was constructed from Mathlib's dependency manifest and exact commit, then checked against every actual checkout.

All nine dependency directories (including preexisting compiled library caches) were copied with macOS `cp -cR` into this package's `.lake/packages/`; there are no dependency symlinks to the parent project. This uses filesystem copy-on-write where supported. Local source trees match their pinned commits. See `00_dependencies.json` for all URLs and hashes. On a fresh machine, `lake update` resolves the direct exact Mathlib pin; the committed lock retains its exact transitive resolutions.

Actual executable output:

```
Lean (version 4.32.0, arm64-apple-darwin24.6.0, commit 8c9756b28d64dab099da31a4c09229a9e6a2ef35, Release)
Lake version 5.0.0-src+8c9756b (Lean version 4.32.0)
```

## Cache and build

`lake exe cache get Mathlib.Topology.MetricSpace.Contracting Mathlib.MeasureTheory.Measure.Prokhorov Mathlib.Probability.Kernel.Composition.MeasureComp Mathlib.Util.AssertNoSorry` exited 0: no files to download; 2609 files already decompressed. This successfully reused the installed compatible cache, with no new network download. An initial invocation using repository-relative file paths failed; this downstream package requires module names. Both logs are retained.

`lake build Probes.Core`, `lake build`, `lake env lean Audit.lean`, and `lake env lean Probes/ApiSignatures.lean` succeeded. The root default build includes `Aiyagari1994`, `All`, and `Audit`. `All` imports only proved probe infrastructure; there are no economic declarations. Source hashes and audit logs are retained; generated caches/PDF sources are ignored.

The initial probe failures (bounded-function notation scope, use of `decide` on the real order) and audit formatting-option failure were corrected without changing assumptions or pins. Failed logs are explicitly named as attempts and are not success evidence.

## Dependency commits

- mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997` (tracked files clean).
- plausible: `e12c1910fe855cbfc38803cd4e55543906d5fa62` (tracked files clean).
- LeanSearchClient: `c5d5b8fe6e5158def25cd28eb94e4141ad97c843` (tracked files clean).
- importGraph: `7e9612bf0b9ee66db3cb5b9988a35afc706f5a12` (tracked files clean).
- proofwidgets: `6e311e2a844da9b2cc3971187df2fe0066947b93` (tracked files clean).
- aesop: `a7dbf0c63b694e47f425f3dcddbc0e178bb432d3` (tracked files clean).
- Qq: `38d591e778f100aec9762bb582f9c7f55f50e9dc` (tracked files clean).
- batteries: `023ce7d62a0531e22a5331e20b587817a80d49ff` (tracked files clean).
- Cli: `88679d088c9720c27ebdf2ba4dafe17341747f94` (tracked files clean).
