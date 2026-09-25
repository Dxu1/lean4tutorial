# Orchestration context and review efficiency refactor

Infrastructure only. Frozen baseline: `ea76b6c49f8349fc727686d174c89b35dce0cf80`, branch `issue3`. Stage 03 remains at `STAGE03_COMPLETE_HUMAN_CHECKPOINT`; H07–H14 and D01 remain GREEN under their unchanged prior reviews. This report is not a new mathematical adequacy review. M04 has not started.

## Motivation and context flow

Previously each gate embedded broad authority documents and acceptance history in its executor prompt, and shipped hundreds of files, full papers and raw verification logs to an XHigh reviewer. The new deterministic builder selects exact assigned contract/profile fields, original-text proof-route/architecture sections, accepted dependency interfaces and mandatory qualifications. The executor starts there and may investigate additional repository or pinned-library material when needed.

The reviewer starts with REVIEW_INDEX and gate_context. Its immutable submission contains current changed Lean, specifically needed internal helper source, exact accepted interfaces, qualifications, ledger extracts, selected approved pages, semantic differences, and hash-verified controller summaries. Identifier-based internal-helper closure records reasons and stops at certified theorem interfaces. Full ledgers/history/logs are no longer the default input. Original authoritative files remain unchanged.

## H12 historical comparison

The original accepted H12 frozen snapshot was verified against SHA-256 `6c9e800818cb8675b9251e67e3f262735b18a4c9e59b50d39a071fc5748608cc`. Its exact original executor/reviewer prompts and bundled controller logs were used. The optimized context was built against that historical submitted source and its original accepted baseline, not later Stage-03 proof additions. It passes `REVIEW_CONTEXT_COMPLETE`. No historical review or acceptance was rewritten and no reviewer was invoked.

| Measure | Historical | Optimized | Reduction |
| --- | ---: | ---: | ---: |
| bytes | 10,667,489 | 4,359,707 | 59.1309% |
| deterministic_log_bytes | 407,353 | 0 | 100.0000% |
| executor_prompt_bytes | 94,602 | 1,450 | 98.4673% |
| executor_prompt_characters | 94,412 | 1,450 | 98.4642% |
| files | 418 | 38 | 90.9091% |
| reviewer_prompt_bytes | 6,323 | 4,406 | 30.3179% |
| reviewer_prompt_characters | 6,321 | 4,402 | 30.3591% |
| source_evidence_bytes | 5,727,477 | 4,093,441 | 28.5298% |

The optimized executor additionally references 45,196 bytes of capsule, contracts, extracts, interfaces and qualifications. Thus its prompt plus those selected files totals 46,646 bytes. Prompt shrinkage alone is not total context shrinkage or measured usage savings. Snapshot bytes include selected PDFs and manifest; source-evidence bytes count PDF artifacts only. Deterministic-log bytes count raw `.log` files under verification. Counts are exact bytes/files/Unicode characters, not tokens. No tokenizer was installed and no model allowance was consumed to measure these changes.

H12 excerpts contain A93 PDF pages 38–39 and A94 PDF pages 9–10. Both original approved hashes and extracted artifacts are bound in the source index. Shared PDF resources explain why two-page excerpts can still be large. Optimized snapshot SHA-256: `f739618a4ee38b07796a12e80fdd5c5fd3b1f5429fac5659149b16d3e130d462`.

## M04 preview only

The existing original Stage-04 plan identifies H06/D02/D03: joint continuity and the uniform drift construction. `M04_PREVIEW` is a measurement label, not an added execution gate. D02 is an intra-gate dependency; six direct accepted interfaces cover H02, H04, H07, H08, H10 and H12.

- Gate capsule: 13,398 bytes.
- Preview executor prompt: 1,519 characters / 1,519 bytes, explicitly marked DO NOT INVOKE.
- Preview JSON input plus prompt: 125,953 bytes (includes preview metadata and references).
- Preview snapshot: 4,455,591 bytes / 29 files.
- Source excerpts: 4,320,259 bytes.
- Accepted dependency interfaces: 6.

The preview passes only `PREVIEW_CONTEXT_COMPLETE_NOT_REVIEW_READY`. It has no M04 implementation, new export signatures, successful builds or substantive review. Both capsule and preview metadata deny execution authority. The normal submission validator rejects it. No M04 statuses, gate configuration, executor or reviewer invocation changed.

## Reviewer policy and safeguards

A fresh subscription-authenticated read-only Astra/High review is initial. A fully valid PASS/HIGH with all contracts adequate, all D01–D20 acceptable, no blocking findings or human flag, immutable identity and deterministic success accepts normally. Any other substantive High result goes to fresh independent Astra/XHigh on the same snapshot, without High prose as authority. Each effort allows one schema retry. XHigh is operative: clean PASS accepts; valid same-gate REVISE uses the existing executor revision policy; BLOCK, uncertainty or human-required stops. Infrastructure/identity/hash failures stop before substantive escalation. There is no voting and reviewer escalation consumes no executor revision.

Compact reviews retain all twenty obligations, refs resolving to unambiguous evidence aliases, substantive summaries, applicability rules, exact identity and contract checks. PASS summaries are bounded at 240 characters (400 for seven subtle dimensions); non-PASS at 1000 with a higher explanation floor. Findings need references. Necessary qualifications are never truncated. Both reviews and the operative effort are journaled, revalidated on restart and persisted with acceptance evidence.

The context validator fails closed on missing exact contracts/profiles, direct certified dependencies, qualifications, changed Lean, required helper source, new exports/signatures/axioms, any of fourteen deterministic check categories, ledger status, required source pages/locator hashes or manifest coverage. Construction and pre-review validation regenerate summaries from controller-owned, hash-verified raw process outputs; executor prose cannot stand in for them. Existing mechanical reconciliation, evidence repair, source/ledger checks, complete-record multiline axiom parsing, semantic contract freeze, accepted-prefix protection, independent ephemeral sessions, read-only review and subscription-only authentication remain in place.

Sol's policy is unchanged: Medium initially, High for the first genuine same-gate revision, XHigh for the second. Infrastructure/evidence failures do not escalate mathematics; each new gate resets to Medium.

## Validation and preservation

258/258 mocked orchestration tests pass: all 194 pre-existing tests retained and 64 added. Legacy fixture configuration explicitly retains the old versioned format; production uses the new paths. Tests cover exact capsule/provenance, dependency selection/signature/qualification preservation, acceptance-key cache invalidation, source extraction/fallback, omissions/tampering, compact schema, High/XHigh policy and independence, restart journaling, operative revision dispatch, frozen content and the checkpoint's no-model early return. Python compilation and Git whitespace checks pass. No substantive executor, Astra review or availability smoke was invoked. Pinned Lean was used only for exact accepted-interface signature/axiom probes.

The preservation record verifies 457 protected pre-existing files, including every project Lean file, all contracts, mathematical documentation and acceptance records. The controller state file SHA-256 is identical before and after. No model calls, no mathematical status promotion, no numerical work. Test output, exact protected hashes and context validation evidence are included in the compact infrastructure review ZIP; large raw historical logs and source PDFs are excluded.

## Limitations and reproduction

Run `python3 -m unittest discover -s orchestration/tests -v` and `python3 orchestration/context_metrics.py`. Historical comparison requires the preserved original H12 runtime snapshot/prompts; the tool fails if missing or ambiguous. Interface caches can be reconstructed independently from tracked accepted records/sources and pinned Lean. The metrics tool writes runtime artifacts and deterministic tracked interface derivatives, never mathematical files or state.

Only approved mapped proof routes are implemented; future stage authorization must add reviewed route/gate configuration. Missing mappings stop. Helper selection is conservative rather than a Lean semantic dependency extractor; the reviewer must report any substantive gap, and evidence completeness checks cannot prove economic adequacy. Formal schema checks cannot establish the truth of prose. PDF extraction relies on already available pypdf and retains the verified full approved PDF if extraction fails. No claim of measured token/allowance savings or new mathematical adequacy is made.
