# Orchestration hardening report

The external infrastructure audit's six requested fixes are implemented. The independent fresh Codex executor / fresh GPT-6 Astra reviewer / deterministic controller architecture is retained. No mathematical theorem, Lean file, contract statement/assumption/dependency, accepted proof, or economic document was changed. H09 was not started.

## Durable acceptance state

Without runtime state, the controller reconstructs the contiguous accepted gate prefix from tracked repository evidence. M03A requires H07/H08 GREEN and the original tracked external acceptance. Later gates require all assigned entries GREEN plus matching tracked Markdown/JSON acceptance records identifying the gate/contracts and a valid reviewed snapshot SHA-256. Missing, untracked, malformed, partially GREEN, mismatched or noncontiguous evidence stops with ACCEPTANCE_STATE_INCONSISTENT. All Stage-03 gates accepted reconstructs STAGE03_COMPLETE_HUMAN_CHECKPOINT. Stable runtime caches are checked against this prefix. The prompt and frozen-scope guards independently refuse any GREEN target, preventing reruns or downgrades even with stale cache state.

The new reviews/03a_acceptance.json represents the already accepted external M03A decision, original reviewed ZIP hash, known accepted commit, exact substantive conclusions and boundary qualification. It makes no new mathematical claim and does not promote another contract. Existing M03A Markdown is unchanged.

## Structured independent review

The output schema and strict Python validator require exactly one dimension_assessment for D01–D20. Every entry has an enumerated status and evidence; duplicates, missing dimensions and shallow/empty evidence are rejected. Evidence has a 40-character/six-word floor. NOT_APPLICABLE needs a specific applicability explanation of at least 60 characters; thirteen core dimensions cannot use it. Any FAIL/UNCERTAIN prevents automatic acceptance. Source-fidelity D04 UNCERTAIN stops even an attempted automatic revision. All existing confidence, human-review flag, contract adequacy, blocker, gate/attempt/hash and deterministic-check requirements remain. A generic “Looks correct” assessment without dimension evidence cannot reach ACCEPTANCE_RECORDING.

The prompt requests conclusions and supporting inspected evidence, not private chain-of-thought. These structural/content-floor checks cannot prove that a reviewer supplied truthful evidence; substantive independent review remains necessary.

## Qualifications and durable evidence

Every executor receives all accepted predecessor records under MANDATORY CARRY-FORWARD QUALIFICATIONS, including exact qualifications and nonblocking findings. Later work must preserve them unless explicitly revised by user/design authority. Frozen snapshots include the individual records and predecessor_acceptances.json. M03A's separate ENNReal zeroRightMarginal qualification remains mandatory.

Automated acceptance writes Markdown plus structured JSON containing gate/contracts, reviewer identity, snapshot hash, verdict, qualifications, nonblocking findings, evidence directory and commit provenance. The accepting commit cannot contain its own SHA: the new record initially contains null and a Git creation-history locator; the loader resolves its actual SHA once committed, and the existing runtime receipt also records it. This preserves a clean single acceptance commit and works after runtime deletion.

The allowlisted tracked reports/logs/<gate>/review/ directory receives snapshot_manifest.json, reviewer_final.json, controller_decision.json, review_prompt.md and executor_final.md when available. The successful reviewer retry's artifacts are used. Manifest/verdict/decision consistency is checked before copying; common credential token/private-key patterns stop persistence. Full snapshots, source PDFs and raw JSONL streams are not committed as review evidence. Tests verify the compact artifacts remain after deleting runtime state.

## Executor packaging and approved sources

The orchestration wrapper and final instruction explicitly override historical manual-ZIP instructions. The executor produces implementation, reports, audits, logs and synchronized ledger only; the controller freezes the review snapshot after checks. The original historical milestone prompt remains unchanged.

Assigned source IDs resolve only through contracts/source_manifest.json. Required local files are hashed before snapshot creation; missing PDFs, hash mismatches, unknown IDs, missing locators, path escapes and symlinks fail closed. Only verified assigned PDFs enter read-only source_evidence/, and their bytes enter the canonical snapshot manifest. The index supplies exact contract locators. PDFs remain review evidence, never Lean dependencies. The reviewer must inspect only relevant locator sections/pages; unreliable PDF reading requires D04 UNCERTAIN and BLOCK.

Actual local H09 source validation passed for CW00 alone: chamberlain_wilson_2000.pdf, 245,195 bytes, SHA-256 da7a2fb270c597cbc9ac8b827674b45316c58cbe70af7e647af01b30afbdc173. No unrelated papers or prior implementation were inspected/copied. This hardening release archive excludes all source PDFs.

## Verification

- Entire standard-library suite: **73 tests passed**, retaining all original 40 tests and adding 33 hardening regressions. Models and mathematical builds are mocked inside temporary synthetic fixture repositories. Tests consume no model allowance and prove no economics.
- Reconstruction: initial M03A, accepted H09, multiple later acceptances, actual local fresh clone, all-gates checkpoint, inconsistent records, noncontiguous acceptance, stale cache and no-GREEN-rerun guards pass.
- Independent review: shallow/missing/duplicate/empty evidence, all FAIL/UNCERTAIN dimensions, core NOT_APPLICABLE and unjustified NOT_APPLICABLE rejection pass.
- Qualification propagation, durable evidence after runtime deletion, successful-retry evidence selection, credential-pattern rejection and selective approved-source failures pass.
- H09 dry-run: PASS, next gate M03B1/H09, complete original proof route, exact inherited qualification and explicit no-manual-ZIP override. No executor/reviewer mathematical session launched.
- Preflight: existing successful gpt-6-astra/xhigh smoke reused; CLI version/authentication rechecked as ChatGPT subscription. No new model calls, direct API use, API keys or fallback.
- Scope: all 24 project-owned Lean files and 43 protected Lean/contract/document/original-prompt files remain byte-identical to pre-hardening HEAD f44740d19cb52d1804cea5c94cde6a24e98551cc. H09–H14 and D01 remain UNFORMALIZED. No H09 module exists.

Full evidence is in reports/logs/orchestration_hardening/. The requested comparison baseline is infrastructure commit 24663b525872c8b2cda20bb5a759d72ffbb554b0; the package diff also includes the intervening already-existing setup-report identifier metadata. No existing commit is amended.

## Review handoff

Archive: tmp_zip/review_orchestration_hardening.zip.
Receipt: tmp_zip/review_orchestration_hardening_receipt.md.

The post-commit receipt and archive commit_provenance.json carry the exact hardening commit SHA. The external receipt carries the final ZIP SHA-256, avoiding a self-referential archive hash. The archive includes only orchestration source/config/schema/prompts/tests/README, new structured acceptance metadata, the requested baseline diff, full tests, dry-run prompt, state/scope evidence, this report and hash metadata. No Lake/Git directories, source PDFs, credentials, caches, prior ZIPs or real mathematical attempts are included.
