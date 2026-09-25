# Independent Codex–Astra milestone orchestration

This standard-library Python controller implements the user-authorized M03 executor/reviewer workflow. M03A (H07/H08) is externally accepted. Setup did **not** execute H09. Running the mathematical workflow remains a separate action.

## Commands

Run from the Aiyagari v2 project directory:

```bash
python3 orchestration/orchestrate.py status
python3 orchestration/orchestrate.py preflight
python3 orchestration/orchestrate.py dry-run
python3 -m unittest discover -s orchestration/tests -v
python3 orchestration/orchestrate.py run
```

`status` is read-only. `preflight` verifies local CLI capabilities, ChatGPT authentication and model availability; its first successful Astra smoke uses a minimal amount of included Codex allowance. A successful capability smoke is cached for 24 hours for that version/model configuration, while authentication is checked again before every model process. `dry-run` writes the next executor prompt and planned review inputs; it launches no models. `run` executes the configured sequence and can accept multiple gates, stopping after M03F at `STAGE03_COMPLETE_HUMAN_CHECKPOINT`. Do not run it merely to inspect setup.

Use a normal host terminal that can access the user's Codex state/credential store. A surrounding desktop sandbox can prevent CLI initialization even though the child model sandbox is read-only. This is an environment failure, not permission to disable the model sandbox. Setup's initial restricted invocation failed locally; the authorized host invocation succeeded.

## Authentication and model roles

All model calls are fresh `codex exec` processes using the installed CLI. There is no HTTP client, OpenAI SDK, API CLI, API-key login, provider fallback or purchase mechanism in this controller. Preflight requires CLI >= 0.153.0, an explicit `Logged in using ChatGPT` status, and isolated configuration support. Missing or ambiguous authentication stops with the manual action `codex login`. API-key/provider environment variables are removed. Child invocations ignore user configuration/rules, force `forced_login_method="chatgpt"` and the built-in `openai` provider, disable automatic approvals, apps and multi-agent features, and use the default service tier. The built-in provider name selects Codex's subscription-authenticated service; it is not an instruction to call an API directly.

The default executor is `gpt-5.6-sol`, starting each new gate at `medium` and escalating only through the configured `executor_reasoning_effort_sequence`. Preflight validates every configured effort against the local model catalog. The executor receives the real project as its workspace and `workspace-write`. It may only reach REVIEW_READY, may not stage or commit, and cannot change orchestration, tools, pins, accepted theorem bodies or contract semantics under the controller's scope checks.

The reviewer is `gpt-6-astra`, initially at `high`, with a fresh independent `xhigh` adjudicator when High cannot authorize clean automatic acceptance. Capability metadata is checked for both efforts; an existing valid smoke cache is reused. It receives a distinct frozen snapshot and `read-only`. Every review uses `--ephemeral`, with no resume of any executor history. Automatic project-document discovery is disabled; prompts explicitly supply authority and direct the reviewer to the snapshot's documents. Reviewer output must satisfy the supplied JSON schema and a separate strict Python validator. JSONL events are stored as evidence; decisions do not parse undocumented event fields.

Fresh sessions, distinct working directories, read-only sandboxing and exact snapshot binding separate the roles. The reviewer sees the submission and evidence, not executor conversation history. This reduces shared-context bias; it does not establish that an automated mathematical review is infallible. The implementation agent cannot certify its own adequacy.

## Gates and authority

`gates.json` is workflow configuration, not a replacement theorem contract. This checkout has no `contracts/milestones.json`; the approved numbered prompts and theorem manifest remain authoritative.

| Gate | Contract |
| --- | --- |
| M03A | H07, H08 — already accepted |
| M03B1 | H09 |
| M03B2 | H10 |
| M03B3 | H11 |
| M03C | H12 |
| M03D | H13 |
| M03E | H14 |
| M03F | D01 |

Executor prompts point to deterministic gate capsules containing exact assigned contracts, profiles, selected proof routes, certified accepted interfaces and mandatory qualifications. Additional repository/library investigation remains available when needed. Full authority documents and historical acceptance records are not embedded by default.

**Never use `rightMarginalValue m 0` as the economic boundary marginal. At zero use the separate ENNReal `zeroRightMarginal`, possibly infinite.** Every reviewer receives this qualification and must block a misuse.

## Deterministic checks and snapshots

Before Astra: require the assigned module/report/analytical audit/signature probe; build the target and full project; compile Audit directly; check contracts; compare no-sorry/check/axiom name coverage; permit only `propext`, `Classical.choice`, `Quot.sound`; scan project Lean for prohibited bypasses; run the exact signature probe; rebuild documentation; verify ledger statuses and Git whitespace; freeze allowed changes and original contract semantics. Actual audit completeness for every helper/structure export is also an explicit substantive reviewer responsibility, beyond mechanical name matching. The nested-comment-aware source scan is conservative and may stop on a suspicious token inside a string.

Existing accepted Lean files may only be appended to when the gate explicitly permits the shared module or root aggregators. New helper files belong under `Aiyagari1994/Analysis/<gate>/`. No deletion or unapproved file is accepted. Any contract change except the assigned status is a hard stop; even a seemingly harmless declaration rename requires manual reconciliation in this first version. Helpers proving later economics are forbidden and reviewed substantively; this is not decidable by a filename check.

Version-2 snapshots include the current changed Lean files, selected internal helper source, exact contracts/profiles, certified predecessor interfaces, qualifications, relevant ledger sections, selected original proof-route/architecture text, source pages, and controller verification summaries. They exclude full ledgers, raw logs, unrelated modules and predecessor proof history by default. Each file is hash-bound; sorted compact UTF-8 JSON of the manifest determines `snapshot_sha256`, excluding the manifest's own bytes. Files/directories become 0444/0555. The controller verifies identity, completeness and immutable hashes before review and checks mutations afterward. Permissions supplement the read-only child sandbox; they are not a hostile same-user operating-system security boundary. The version-1 implementation remains only for historical compatibility and regression fixtures.

## State and decisions

State is atomically replaced and fsynced in `tmp_orchestration/state.json`; a process lock prevents concurrent controllers. State stores gate, attempt, revision count, workspace baseline, snapshot hash/path, verdict, ownership hashes and acceptance-commit status.

Normal transitions are READY_TO_EXECUTE → EXECUTOR_RUNNING → DETERMINISTIC_CHECKS → FROZEN_FOR_REVIEW → REVIEWER_RUNNING. Then:

- The operative PASS permits ACCEPTANCE_RECORDING only with HIGH confidence, no human-review flag, exact gate/attempt/hash, passed checks, no blockers and exactly one adequate assessment for every assigned contract.
- The operative REVISE with HIGH confidence, no human-review flag and a nonempty precise repair instruction returns to the same gate, at most twice. A third REVISE stops. Usage-failure retries do not consume this mathematical revision budget.
- Nonclean High reviews receive independent XHigh adjudication before any mathematical revision. An operative BLOCK, uncertainty, insufficient confidence or human flag produces HUMAN_STOP. Malformed output has one schema retry at each effort; malformed XHigh after retry stops. Infrastructure, identity, hash and scope failures stop immediately and retain existing evidence-repair lanes; they do not trigger mathematical escalation.

Acceptance is deterministic, not a third model's mathematical judgment. It records the exact independent verdict/qualifications, promotes only assigned statuses, synchronizes ledger status, reruns acceptance checks and preserves evidence under the gate's reports. An allowlist prohibits Lean/body/contract-semantic changes during recording. It then commits project files only, records the SHA in `tmp_orchestration/accepted/<gate>.json`, and selects the next configured gate. The post-commit crash window is recognized by parent SHA and exact acceptance message so rerunning cannot duplicate the commit. Accepted M03A's mathematical SHA is also recorded in `reports/M03A_BASE`; setup infrastructure commits are nonmathematical workspace baselines.

The outer Git index must be clean before starting. Untracked outer files are preserved. Project dirtiness not owned by the active attempt stops. The controller never resets, cleans, rewrites history, force-pushes or commits unrelated paths. Concurrent outer-status changes stop the workflow; this check does not inspect the prohibited prior implementation's contents. Start from a reviewed, clean infrastructure checkout. Scope checks detect unauthorized edits after an executor returns; they do not make a writable executor a hostile-code isolation boundary.

## Failure, stop and resume

Ctrl-C stops the controller and preserves work. Do not delete runtime state to conceal a blocker. Inspect `state.json`, the attempt's model outputs, checks, snapshot manifest and `controller_decision.json`.

After a reported model/usage failure, wait for subscription access to recover, inspect the preserved state/files, then explicitly run:

```bash
python3 orchestration/orchestrate.py run --resume
```

For an executor failure, this starts a new fresh attempt on the same gate with owned changes preserved. For a reviewer failure, it launches a fresh read-only reviewer against the **same frozen snapshot**, preserving prior events in a separate retry directory; it does not rerun the executor. Authentication is rechecked; no paid API/provider fallback is used. Initial preflight failures can similarly resume after the stated manual action. A successful daily smoke cache does not guarantee that allowance remains at the next call; any call failure stops.

Semantic HUMAN_STOP conditions, unexplained interrupted phases and partially recorded acceptances require manual reconciliation; `--resume` cannot override them. Never hand-edit state to manufacture a PASS. Preserve the stopped attempt, obtain the required review, and explicitly reconcile a new clean baseline before another workflow. Runtime evidence is ignored and should be backed up if long-term crash recovery is important.

## Files, tests and extension

Tracked: controller, configuration, gate list, schema, role prompts, tests, authority amendments and setup report/evidence. Runtime (disposable crash-recovery cache): state/lock, preflight smoke, dry-run prompt, attempt prompts/events/finals/checks, frozen manifests/snapshots, decisions and accepted SHA receipts. No credentials are intentionally recorded; reports expose authentication only as `ChatGPT subscription`. Do not paste credentials into executor prompts or reports.

The tests use fake model responses and temporary fixture Git repositories; they consume no model allowance and prove no economics. They cover verdict rejection, auth rejection, environment stripping, snapshot tampering/exclusions, dirty scope, accepted-source protection, revisions, real controller acceptance commits, usage resume and crash idempotence. Setup also runs actual deterministic checks on already accepted M03A only.

To add stages after M03F, obtain explicit user/design authority, update the tracked gate configuration, prompts, allowlists and tests in a reviewed infrastructure change, and initialize an explicitly reconciled baseline. The default checkpoint must not be bypassed by treating the next original numbered prompt as authorization.


## Durable acceptance and hardening

When runtime state is absent, status reconstructs the accepted prefix from tracked theorem statuses and acceptance records. M03A requires H07/H08 GREEN and the existing tracked external acceptance; its new `reviews/03a_acceptance.json` represents the same external decision and preserves its exact boundary qualification. The historical hash identifies its reviewed ZIP, not a retrospectively invented snapshot-manifest hash.

Later gates require all assigned contracts GREEN, a tracked Markdown acceptance naming the gate and a valid reviewed snapshot SHA-256, and the matching tracked structured JSON record. A partial GREEN gate, absent/untracked/malformed record, record without GREEN, wrong gate/hash, or noncontiguous acceptance stops with ACCEPTANCE_STATE_INCONSISTENT. No status command writes a downgrade. Stable runtime caches must agree with this tracked prefix; active interrupted phases still retain their existing crash-recovery rules. The executor prompt and frozen-scope guard also explicitly refuse a GREEN target. After all configured gates are accepted, a fresh clone reconstructs STAGE03_COMPLETE_HUMAN_CHECKPOINT without invoking a model.

Structured acceptance records contain gate/contract IDs, reviewer type/model, reviewed hash, verdict, qualifications, nonblocking findings, evidence directory and commit provenance. An accepting commit cannot contain its own SHA: a newly generated record has accepted_commit_sha=null plus a Git creation-history locator; loading it resolves the actual SHA from tracked Git history once available. M03A's already-known accepted commit is recorded explicitly. The runtime accepted receipt also records the actual SHA after commit.

Every executor receives a MANDATORY CARRY-FORWARD QUALIFICATIONS section containing every accepted predecessor record, including nonblocking findings. Preserve these unless user/design authority explicitly revises them. The frozen reviewer snapshot includes both the individual tracked records and predecessor_acceptances.json. The hardcoded M03A zeroRightMarginal qualification is retained in addition to the complete record chain.

After independent acceptance, compact evidence is committed under reports/logs/<gate-lower>/review/: snapshot_manifest.json, reviewer_final.json, controller_decision.json, review_prompt.md, executor_final.md when available, and executor_invocations.json for the complete gate effort history. The successful retry's verdict/prompt/decision are selected after reviewer retries. Hash/decision consistency is checked before copying; common credential-token/private-key patterns cause a stop before persistence. The record points to this directory; deleting runtime cannot erase this compact acceptance history. Full snapshots, approved PDF bytes and raw JSONL events are not committed as acceptance evidence. Existing acceptance allowlists now admit only this selected review material in addition to the prior allowed files.

A reviewer must provide exactly twenty dimension_assessments, D01–D20, plus per-contract assessments. IDs are unique, statuses are enumerated and evidence must identify inspected material and supporting conclusions. Historical version-1 evidence has a mechanical minimum of 40 characters and six words; version-2 compact refs/summary limits are specified below. NOT_APPLICABLE requires at least 60 characters with an explicit applicability explanation; core dimensions D01, D02, D05, D06, D07, D13, D14, D15, D16, D17, D18, D19 and D20 cannot use it. Any FAIL or UNCERTAIN prevents automatic acceptance. In the compact policy, any operative UNCERTAIN also stops an attempted automatic revision: unreadable source evidence requires a human checkpoint. All prior HIGH-confidence/hash/no-blocker/contract-adequacy requirements remain. These checks reject shallow approvals; text length and structure alone cannot establish that evidence is accurate or mathematically adequate. Ask for conclusions and supporting evidence, never private chain-of-thought.

The reviewer inspects only the exact contract source locators/sections/pages using source_evidence/index.json. If the local PDF tools cannot reliably read those pages, D04 must be UNCERTAIN and the verdict BLOCK. Approved papers are review evidence only, never Lean proof dependencies. For H09, the approved source set is CW00 alone, chamberlain_wilson_2000.pdf (245,195 bytes); no unrelated paper or prior implementation is copied. Dry-run validates this source selection without copying a frozen submission or launching either role.

The orchestrated executor must not make a manual ZIP. The wrapper and final instruction explicitly override that historical AGENTS/milestone workflow: produce implementation, reports, audits, logs and ledger only; the controller freezes the review snapshot after checks. The original historical milestone prompt remains unchanged.

All original forty tests remain, extended with durable reconstruction/fresh-clone, cache mismatch, twenty-dimension, evidence persistence/retry, qualification and selective-source tests. They use synthetic fixture repositories and mocked model results, not real mathematical sessions.


## Executor reasoning policy

Every new gate starts with **GPT-5.6 Sol / Medium**. The upstream theorem design already supplies the high-level mathematical strategy; Medium is an implementation default, not a guarantee of sufficiency. Configuration defines `executor_reasoning_effort_sequence: ["medium", "high", "xhigh"]` next to the existing `executor_model`.

Only a completed substantive attempt followed by an authorized same-gate revision advances effort: **Medium → High → XHigh**. Astra REVISE uses this transition and consumes one of the existing maximum two revisions. Deterministic-check failures retain the existing stop-for-review behavior; this policy adds no automatic repair loop. The common authorization helper supports DETERMINISTIC_REPAIR if a separate controller decision authorizes it, under the same shared revision budget. Exhaustion stops rather than creating extra attempts.

Usage limits, missing authentication/Codex, OS/subprocess interruptions and other infrastructure failures do not increase effort. Explicit resume retains the planned effort. Ambiguous/crashed or malformed state still fails closed under the existing recovery rules. A new accepted-gate transition resets effort to Medium. Reviewer policy remains **GPT-6 Astra / XHigh**, fresh, ephemeral, read-only and hash-bound, with all twenty adequacy dimensions required.

Persistent state records the effort index, invocation reason and complete per-gate invocation history. `status` exposes the next executor model/effort/reason/gate; `dry-run` provides the explicit planned CLI command and policy metadata separately from the unchanged mathematical prompt. Each attempt records `executor_invocation.json` and cumulative `executor_invocations.json`: gate, physical invocation/attempt number, substantive round, requested model/effort, reason and completion/failure outcome. Physical invocations may repeat the same effort after infrastructure failure. Accepted compact review evidence retains the cumulative history; the frozen snapshot hashes it. No model selects or silently changes its own effort.

## Explicit M03B1 scope-incident reconciliation

The executor evidence convention uses `reports/logs/03b1/`, whereas the original
controller expected `reports/logs/m03b1/`. Both current-gate spellings now permit
only the enumerated `EXECUTOR_LOG_NAMES` basenames. Unknown filenames, other gates,
subdirectories and arbitrary reports remain forbidden. The gate-local exact-signatures
report is also enumerated. Source scope and accepted-interface checks are unchanged.

For the externally authorized M03B1 attempt-1 incident only, `reconcile-scope`
requires `--receipt`, `--receipt-sha256`, and `--expected-head`. The preservation
receipt must have been captured before infrastructure edits and contain the original
state hash, baseline, all project file hashes and all attempt file hashes.
The new HEAD must be one direct infrastructure-only child of that baseline; only
controller, tests, this README and the named incident report may be committed.
No staged files, altered submission, changed attempt evidence, prior review or other
stop identity is accepted. Reconciliation records the commit transition and moves
to `POST_EXECUTOR_RECONCILED`; it does not invoke a model or increment an attempt.

The next `run` performs scope and independent deterministic checks before preflight,
snapshotting and reviewing the existing attempt. Documentation is rebuilt in a
scratch copy, preserving the submitted TeX/PDF. Any mismatch or failed check stops.
The normal reviewer decision and subsequent gate logic remain unchanged. This is
not a general override for semantic stops, and `--resume` still cannot override them.

## Generated verification output hygiene

`GENERATED_LOG_PRODUCERS` enumerates 16 mechanical output basenames. Exemption from
whitespace checking requires an exact current-gate log path and a recorded completed
executor command that redirects to that path, contains the expected producer, and
exits zero. The last recorded write must succeed. Missing/malformed provenance fails
closed. These event records establish provenance only; they never decide adequacy.
Independent builds, audits, contracts and all other checks remain mandatory.

The controller records unchanged output hashes and producer evidence in
`verification/generated_evidence.json`. Raw output bytes and this inventory are
included in the frozen snapshot manifest. Only these exact validated paths are
excluded from tracked/untracked whitespace checks. Authored reports, command
summaries, export inventories patched by the executor, QA/provenance Markdown,
Lean and contracts remain strict. No logs are normalized or overwritten.

The second externally authorized M03B1 reconciliation accepts only classification
`GENERATED_EVIDENCE_HYGIENE_DEFECT` and the exact docs_build.log stop. In addition to
all original guards it verifies the prior reconciliation hash/commit, original H09
submission and original executor evidence. Its record is separate under
`tmp_orchestration/generated_log_incident_m03b1/`. Fresh checks are written to
`attempt_001/pre_review_checks_<infrastructure-HEAD>/`; prior check logs remain
unchanged. Snapshotting selects that verified directory. Any future substantive
reviewer-authorized attempt resets this directory selector. No effort or invocation
increment is caused by either infrastructure incident.

## Current architecture: semantic submissions and runtime verification

Version 1 of `orchestration/artifacts.json` is enabled by configuration. The old
filename-exemption code remains only for compatibility with stored historical
workflows and the original regression fixtures; new production runs use the runtime
architecture. Accepted historical evidence is never rewritten or migrated.

Semantic Lean, contracts, ledger source, milestone reports, analytical audits and
acceptance records remain in the project tree under strict gate scope. Raw outputs
belong under `tmp_orchestration/runs/M03B2/attempt_001/checks/`, with one canonical
mapping implemented by `MechanicalEvidence.paths`, `batch`, and `artifact`.
Each independent pre-review/acceptance pass gets a fresh numbered batch. Status
exposes the canonical paths. The controller owns log paths, arguments and capture;
the executor receives an explicit override to keep local check stdout in its event
stream, write only semantic reports, and let the controller collect final evidence.

The configuration registry defines artifact types, controller producer identities,
mandatory/conditional status, raw hygiene, hash recording and summary-only durable
retention. Unknown types, unknown runtime outputs, wrong paths, symlinks and hash
mismatches fail closed. A filename extension alone never authorizes an artifact.

Legacy outputs from the current attempt can take the AUTO_RECONCILE lane only after
recorded producer/output provenance and full semantic-scope validation. A frozen
scope report must not signal predecessor mutation. The controller records original
path/hash, producer process/event and runtime/snapshot destinations, verifies the
copy, and only then removes the untracked generated original. A write-ahead journal
supports interrupted copy/unlink recovery. Reappearing migrated files cannot trigger
an infinite loop. Existing authored metadata companions stay semantic; milestone
reports and analytical audits are never moved. Mandatory independent checks rerun,
so a compound shell's final exit is never substituted for proof/build verification.

A temporary OS failure (EINTR, EAGAIN or ETIMEDOUT) may retry the same mechanical
command once. Every attempt and raw interrupted output is retained. Nonzero Lean
or other check exits are not silently retried as OS failures. Neither AUTO_RECONCILE
nor RETRY_INFRASTRUCTURE changes gate, executor invocation or reasoning effort.
Substantive REVISE remains governed by the existing Medium → High → XHigh policy.
Ambiguous provenance and semantic violations remain HUMAN_STOP/HUMAN_REVIEW;
unrecoverable operational failures remain HUMAN_STOP/INFRASTRUCTURE.

Successful checks produce process_records.json and deterministic_summary.json with
exit statuses, raw-file hashes, paths and audit counts. Snapshots contain independent
raw evidence and any migrated legacy evidence, all hash-bound. After PASS, only the
compact review bundle (summaries, manifest, exact verdict/decision, invocation summary
and qualifications) is committed. Raw acceptance/build logs stay in ignored runtime.
Tracked acceptance reconstruction remains possible without runtime logs.

For the already completed H10 attempt only, `reconcile-runtime --receipt ...
--receipt-sha256 ... --expected-head ...` verifies the old/new direct infrastructure
commit relationship, preserved state/source/report/attempt hashes, unchanged accepted
H09, exact M03B2 invocation 1 Medium INITIAL, and empty staging. It performs guarded
legacy migration and moves to POST_EXECUTOR_RECONCILED. The next run invokes checks
and review, not the executor. It must follow the explicitly authorized refactor
commit/push. Other semantic stops do not gain a general override.

Review source evidence uses the union of structured `sources` and exact source IDs
in each assigned `source_locator`. Only `contracts/source_manifest.json` defines
recognized IDs and filenames. Arrays retain their existing semantics; discrepancies
are reported rather than silently rewritten. Run `python3 orchestration/review_evidence.py`
for the deterministic all-contract consistency and ledger-status report. Snapshots
include that source consistency inventory and an exact locator/hash binding for
every required approved PDF. Missing or hash-invalid evidence stops before any
review call with `SOURCE_EVIDENCE_INCOMPLETE`.

Before review, explicit overview and section statuses must agree with contracts.
Narrow current-status and pending-review prose patterns are checked; sentence-local
historical markers are allowed. This is a consistency check, not natural-language
mathematical verification. Prefer the generated overview and section Status lines
for current status, and clearly dated historical text elsewhere. Freshly generated
TeX must match the submitted TeX exactly. Acceptance regenerates tracked TeX/PDF
following authorized status promotion, retaining the raw build log in runtime.

`reconcile-evidence --receipt ... --receipt-sha256 ... --expected-head ...` is a
REVIEW_EVIDENCE_REPAIR lane for the specifically human-audited H10 BLOCK only.
It binds the exact prior review bytes, requires all substantive dimensions PASS,
and verifies the original Medium invocation, zero revisions, predecessor acceptance,
unchanged mathematical files/contracts, and precisely the two permitted ledger
status replacements. A direct infrastructure/documentation commit is required.
The subsequent controller run rebuilds deterministic evidence and creates a fresh
snapshot and reviewer output directory without overwriting the old BLOCK or
snapshot manifest. The fresh reviewer receives the normal complete review prompt.
No BLOCK is automatically converted into REVISE or PASS. Other mathematical,
design, source-conflict or uncertain stops retain the normal human-review policy.

Axiom evidence is parsed by `axiom_records.py` as complete declaration records.
The parser recognizes both bracketed lists and Lean's explicit no-axioms record,
retains complete raw records, and checks exact declaration coverage against Audit.
Whitespace and line wrapping do not alter axiom names. Duplicate permitted list
items are harmless; duplicate declarations, missing records, truncated/nested lists,
malformed headers/list syntax and trailing junk fail closed. Unknown exact axiom
names stop as GENUINE_NONSTANDARD_AXIOM; malformed evidence stops as
AXIOM_EVIDENCE_MALFORMED. Build success never substitutes for these checks.

The explicitly authorized H12 AXIOM_PARSER_FORMAT_DEFECT can be reconciled with
`reconcile-axioms --receipt ... --receipt-sha256 ... --expected-head ...` after a
separate infrastructure commit/push. It requires the preserved HUMAN_STOP, exact
completed initial Sol Medium invocation, unchanged semantic files (including ledger,
contracts, reports and Audit), all prior attempt evidence, accepted predecessors,
and a direct infrastructure-only commit. It re-parses all 324 original records
before enabling POST_EXECUTOR_RECONCILED. The normal run then verifies and reviews
the same submission without calling Sol. This is not a generic audit-stop bypass.


## Token-efficient gate context

`context_version: 1` selects `gate_context.py`. `tmp_orchestration/contexts/<gate>/` contains exact `gate_context.json`, assigned `contracts.json`, selected original-text `extracts/`, accepted `dependencies/`, and `predecessor_qualifications.json`. Original file hashes, headings/line ranges and fields establish provenance. Qualifications retain exact text and originating gates/contracts; prompts reference this file once. The capsule is a derivative, not design or execution authority. The controller's approved gate list and dispatch remain necessary. Unknown proof-route mappings fail closed; authorizing a new stage requires an explicit reviewed mapping and gate configuration.

## Accepted dependency interfaces

`reports/accepted_interfaces/*.json` stores deterministic hash-enveloped derivatives for dependencies used by the measured H12/M04 cases. Each records exact pinned-Lean elaborated signatures, actual/allowed axioms, assumptions/dependencies, accepted source hash, acceptance commit and snapshot, evidence paths and full qualifications. Reconstruction uses tracked accepted sources and records, verified preserved source prefixes and pinned `lake env lean` signature/axiom probes. Runtime caches key on contract, acceptance/source hashes, commit, toolchain and Mathlib manifest; a changed acceptance key regenerates the interface, while corrupt cache hashes stop. Runtime generation never silently updates tracked interface files. Early human acceptance qualifications are retained verbatim from their accepted Markdown records.

## Compact reviewer snapshots

Begin at `REVIEW_INDEX.md` and `gate_context.json`; investigate packaged evidence as needed for D01–D20. Direct accepted results are represented by certified interfaces. Identifier-reference closure selects specific source modules when current proofs use uncertified internal definitions/helpers, retaining their semantics. Merely importing a predecessor does not automatically ship its entire proof history. Selection is conservative and can include substantial helper source; missing context must never be guessed. `support_source_reasons.json` explains the closure. Exact changed exports, signatures and axiom summaries accompany a semantic Lean/relevant-ledger diff. Raw verification logs stay in hash-bound runtime evidence.

## Reviewer High → XHigh adjudication

`reviewer_policy_version: 1` uses a fresh High reviewer first. Only fully valid PASS/HIGH, all contracts adequate, no blockers, no human flag, all twenty dimensions acceptable, exact identity and successful deterministic checks authorize acceptance. All other substantive High outcomes go to fresh independent XHigh on the same immutable snapshot. XHigh gets no High prose or verdict as authority. There is no voting. XHigh is operative: PASS accepts, valid REVISE uses the existing executor budget, and BLOCK/UNCERTAIN/human-required stops. Each effort allows one schema retry; failures of infrastructure, identity or immutability stop immediately. Completed calls are journaled by snapshot hash and reused after permitted restarts. Both verdicts, schema-attempt metadata, raw-output hashes and the operative reviewer are retained in acceptance evidence. Reviewer escalation never increments executor revisions. Sol remains Medium → High → XHigh for genuine same-gate mathematical revisions only.

## Compact D01–D20 output

The compact JSON schema preserves all twenty dimensions and all original substantive obligations. Each needs 1–5 exact aliases from `evidence_aliases.json` and a specific summary. PASS maximum is 240 characters, or 400 for D02/D03/D04/D09/D10/D11/D17. Non-PASS maximum is 1000, with a substantive explanation floor. Core dimensions cannot be N/A. Python additionally checks unique coverage, reference resolution, applicability, verdict conditions and concise assessments. Findings need evidence references. Qualifications are never length-truncated. Schema compliance alone cannot establish truth or adequacy; that remains the independent reviewer's responsibility. Legacy reviews continue to validate under their original evidence format; new policy calls require compact records.

## Context-completeness safety floor

`REVIEW_CONTEXT_COMPLETE` validates exact capsule/contract/profile provenance, direct certified dependencies, every mandatory qualification, changed semantic Lean files and required helper closure, exact new exports/signatures/axioms, all fourteen deterministic check categories, relevant ledger status, source IDs/locators/page lists and hash coverage. At construction and immediately before review, summaries are regenerated from hash-verified controller process outputs and compared exactly. Every file is included in the immutable manifest. Missing evidence stops before Astra. Existing source/ledger guards, multiline axiom parser, mechanical-artifact reconciliation, review-evidence repair, contract/status freeze and accepted-prefix checks remain active.

## Source-page extraction

The builder verifies each approved original PDF hash, parses its exact printed/PDF locator, and extracts only the specified PDF pages. D01 additionally includes its approved maintained-assumption context. Local `pypdf`, or an already installed bundled Codex Python containing it, performs extraction and verifies page count. No package installation, OCR or network fetch is used. If reliable extraction is unavailable or fails, the approved full PDF is retained explicitly as a fallback. `source_evidence/index.json` binds original/extract hashes, original page numbers, printed locator text and exact contract locators. Extract page 1 corresponds to the first listed original PDF page. Shared font/image resources can limit byte savings even with few extracted pages. Release review archives omit the PDF artifacts.

## Efficiency metrics

Run `python3 orchestration/context_metrics.py` from this checkout after the infrastructure refactor. This makes no model calls and writes runtime comparisons under `tmp_orchestration/token_efficiency_refactor/`; it reconstructs H12 from its existing immutable historical snapshot and creates a non-executable M04 preview for H06/D02/D03. It also writes derived certified interfaces under `reports/accepted_interfaces/`; review these deterministic infrastructure artifacts before committing. Historical measurement needs the preserved original H12 snapshot/prompts; absence fails rather than inventing a baseline. Dependency-interface reconstruction itself remains possible from tracked evidence without that runtime snapshot.

The preview is marked `execution_authorized: false` and `not_review_ready`; it contains no M04 implementation or successful build evidence and cannot pass the submission validator. It does not extend `gates.json`, alter statuses, run an executor/reviewer, or move the Stage-03 checkpoint. Metrics report exact bytes, files, Unicode characters and percentage reductions, not token counts or measured allowance savings. Short prompts reference separate evidence files, so prompt reduction alone is not total context reduction. The report records separate context/snapshot/source sizes.

## Authorized Stage 04 execution and telemetry

The explicit Stage-04 authorization extends the gate list by exactly M04A/H06,
M04B/D02 and M04C/D03, then stops at STAGE04_COMPLETE_HUMAN_CHECKPOINT. Their
organizational order adds no formal theorem dependency. No Stage-05 gate exists.
After committing reviewed configuration, `python3 orchestration/orchestrate.py
activate-stage04` verifies a clean checkout and the unchanged accepted Stage-03
prefix, preserves its entire old state in runtime evidence, and initializes M04A
at Sol Medium. It cannot silently bypass a HUMAN_STOP or reactivate a started stage.
The approved refactor push was verified by a fresh remote query before configuration.

`usage.py` observes existing CLI processes only. The installed historical H12
JSONL actually emits `turn.completed.usage` with `input_tokens`,
`cached_input_tokens`, `cache_write_input_tokens`, `output_tokens` and
`reasoning_output_tokens`. Exact numeric usage records are retained; unavailable
fields are null with `availability: not emitted by installed Codex CLI`. No
unobserved total-token field, character-based token estimate or API call is added.
Cached inputs and reasoning outputs are reported as their own emitted fields;
we do not assume they are disjoint from input/output totals.

Each invocation records stage/gate/role, model/effort, invocation and substantive
revision numbers, prompt lengths, packaged context sizes, source PDF bytes,
observed interface-cache use, timestamps, raw-event hash and exact usage under
`tmp_orchestration/usage/`. Availability smokes are recorded separately under
PREFLIGHT, never described as mathematical reviews. Telemetry parsing failures
preserve normal execution and raw evidence. After each accepted Stage-04 gate,
the controller writes `reports/stage04_usage_metrics.json` as part of that gate's
acceptance commit. These observational metadata cannot authorize GREEN.
