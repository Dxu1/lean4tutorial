# Milestone report: 00 / bootstrap

Date: September 11, 2026. Assigned prompt: `prompts/00_bootstrap.md` only.
Status: **REVIEW_READY**, pending external review; no GREEN status awarded.
Parent workspace HEAD: `65406a5df90ed0df6c282bb220541f882218bbf6`; the execution package is uncommitted.
Lean: `leanprover/lean4:v4.32.0`.
Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`.

## Results against the contract

No economic contract ID is assigned to milestone 00. All 57 theorem entries retain their original statements, assumptions, dependencies and UNFORMALIZED statuses. Only the manifest's package-level bootstrap/build metadata changed.

- Environment: a standalone package and exact lockfile, with all nine dependency commits verified against clean local source trees. Details: `00_environment.md`, `00_dependencies.json`.
- Sources: all ten approved PDFs passed size and SHA-256 checks through the unchanged whitelist extractor. Original ZIPs were absent in the checked locations. The user's explicitly permitted `reference/` PDFs supplied source-only reconstructed adapter archives. Their absolute paths and provenance are in `00_sources.md`; these are not represented as the original ZIPs.
- APIs: 21 generic proved theorems and three type abbreviations in `Probes/Core.lean`. Exact declarations, imports, assumptions, evidence, and unresolved work are in `00_api_inventory.md`, `logs/00_api_signatures.log`, and the ledger. There are no economic theorem placeholders.
- Build surface: `Aiyagari1994.lean` imports proved probes; `All.lean` imports the root; `Audit.lean` checks every probe declaration. Default build targets include the audit.

## Proof route and changes

Generic library instances and theorems establish complete bounded-value space, the Banach construction with a concrete zero-map witness, NNReal state structure, integrable probability pushforwards, Markov composition/transport, bounded-test weak convergence, compact interval-law space, and Prokhorov compactness. The readable proofs and elaborated signatures are synchronized in `docs/proof_ledger.md` and `.pdf`.

No mathematical architecture or economic assumption changed. Local adaptations: use the explicit `BoundedContinuousFunction` type instead of a notation requiring an additional scope; use a proved ordered-field inequality instead of `decide`; use `format.width` for audit formatting; use module names for downstream Mathlib cache retrieval. The Prokhorov compact-closure theorem is in the root namespace. Compiled dependency caches were copied from the clean parent workspace and validated, without reading old model dependencies.

Documentation-only changes fix empty-array expansion under macOS Bash, allow a ledger-only build, update its title, support literal Lean symbols, and add missing Markdown heading separators inherited from the initial ledger. No contract prose was altered by the heading fix.

## Verification evidence

Commands were run from the package directory. Success logs are separate from retained failed-attempt logs.

| Command/check | Result | Evidence |
|---|---|---|
| `python3 tools/extract_sources.py --aiyagari "$PWD/sources/input_archives/i003_replicate_aiyagari.zip" --citations "$PWD/sources/input_archives/citations.zip" --output sources/papers` | Exit 0, 10 PDFs verified | `logs/00_sources.log`, `sources/papers/extraction_report.json` |
| `lean --version`; `lake --version` | Exit 0, pinned versions | `logs/00_versions.log` |
| `lake exe cache get Mathlib.Topology.MetricSpace.Contracting Mathlib.MeasureTheory.Measure.Prokhorov Mathlib.Probability.Kernel.Composition.MeasureComp Mathlib.Util.AssertNoSorry` | Exit 0, 2609 files already decompressed | `logs/00_cache_modules.log` |
| `lake build Probes.Core` | Exit 0, 2625 jobs | `logs/00_probe_build.log` |
| `lake build` | Exit 0, includes root, All, Audit | `logs/00_full_build.log` |
| `lake env lean Audit.lean` | Exit 0; 24 no-sorry assertions | `logs/00_axioms.log` |
| `lake env lean Probes/ApiSignatures.lean` | Exit 0 | `logs/00_api_signatures.log` |
| `python3 tools/check_contracts.py` | Exit 0 | `logs/00_contracts.log` |
| Dependency revision/clean-tree comparison | All 9 match lock | `00_dependencies.json` |
| Original-package hash comparison and Lean placeholder/bypass scan | Passed | `logs/00_integrity.log` |
| `bash tools/build_docs.sh proof_ledger` | Exit 0 | `logs/00_docs_build.log` |
| PDF render and visual inspection | See final QA record | `logs/00_pdf_qa.md` |

Every audited declaration reports exactly `[propext, Classical.choice, Quot.sound]`. There is no `sorryAx`, custom axiom, or proof bypass. The preliminary elaboration failures are retained in `00_probe_attempt1.log`, `00_probe_attempt2.log`, and `00_full_attempt1.log`; generated error-recovery sorry warnings there are not successful proofs. The final source scan and transitive audit are clean.

The first documentation attempt failed internally on a Bash empty array although that shell invocation returned zero; inspection detected the stale PDF. The repaired build and actual output PDF were separately checked. The failed attempt is retained in `00_docs_attempt1.log`.

The release gate was not run: it intentionally requires GREEN economic contracts and accepted reviews, which are outside milestone 00. No source mathematical page audit, economic adequacy review, numerical computation, or milestone 01 work was performed.

## Adequacy audit

There are no transitive economic assumptions in the probe theorems. Generic contraction, Markov, measurable-map, weak-convergence and tight-family hypotheses are explicit. Future economic wrappers must derive these hypotheses from primitives. The zero contraction is a nonvacuous API witness; the economic primitive witness P03 remains unformalized.

NNReal is unbounded and the value space is bounded-continuous with a complete sup metric. ENNReal permits an infinite zero-state marginal without forcing a real integral; no value derivative has been asserted. Each real bounded test is integrable under a probability law, and the pushforward identity exports integrability of both sides. Weak convergence is tested only with bounded continuous functions. No first-moment convergence or invariant-law theorem is inferred. Normalized price coordinates retain their approved separation from the potentially divergent debt limit.

All paper-level claims, including Bellman verification, the source diagnostic, mixing/stationarity, boundary divergence and general equilibrium, remain unformalized. The approval target is the environment/source/API bootstrap only.

## Blockers and review request

No remaining blocker to the assigned bootstrap. Review the source-archive adaptation, exact pins, generic API evidence and readable ledger. No original archive was falsely claimed to be present. No accepted review record has been created.

**Stopped at milestone 00.** Milestone 01 is only the proposed next stage after explicit acceptance and assignment; it has not been opened or executed.

## Changed files

See `00_changed_files.md` for the complete package-relative inventory, including generated evidence and ignored local inputs. `PACKAGE_SHA256.json` remains the original design-package provenance; the bootstrap snapshot is separately recorded in `00_artifact_sha256.json`.
