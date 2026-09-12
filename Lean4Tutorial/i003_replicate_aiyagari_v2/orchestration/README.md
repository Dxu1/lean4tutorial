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

The default executor is `gpt-5.6-sol` at `xhigh`, verified in the local Codex model catalog. Configure another supported non-Astra model in `config.json`; preflight validates its reasoning setting against the local catalog. The executor receives the real project as its workspace and `workspace-write`. It may only reach REVIEW_READY, may not stage or commit, and cannot change orchestration, tools, pins, accepted theorem bodies or contract semantics under the controller's scope checks.

The reviewer is always `gpt-6-astra` at `xhigh`, verified by a harmless actual subscription CLI smoke. It receives a distinct frozen snapshot and `read-only`. Every review uses `--ephemeral`, with no resume of any executor history. Automatic project-document discovery is disabled; prompts explicitly supply authority and direct the reviewer to the snapshot's documents. Reviewer output must satisfy the supplied JSON schema and a separate strict Python validator. JSONL events are stored as evidence; decisions do not parse undocumented event fields.

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

Executor prompts compose AGENTS, the original M03 prompt, exact assigned theorem entries/source locators, assumptions, architecture/interfaces, dependency graph, accepted predecessors and M03A's qualification. The wrapper narrows the original stage prompt to one gate. H09 explicitly requires the extra-initial-saving-h Bellman comparison, nonnegative concave difference quotients, monotone convergence, extended integral first, conditional finiteness from the finite left marginal, then real integral, for every R>0 without beta*R<1 or consumption positivity.

**Never use `rightMarginalValue m 0` as the economic boundary marginal. At zero use the separate ENNReal `zeroRightMarginal`, possibly infinite.** Every reviewer receives this qualification and must block a misuse.

## Deterministic checks and snapshots

Before Astra: require the assigned module/report/analytical audit/signature probe; build the target and full project; compile Audit directly; check contracts; compare no-sorry/check/axiom name coverage; permit only `propext`, `Classical.choice`, `Quot.sound`; scan project Lean for prohibited bypasses; run the exact signature probe; rebuild documentation; verify ledger statuses and Git whitespace; freeze allowed changes and original contract semantics. Actual audit completeness for every helper/structure export is also an explicit substantive reviewer responsibility, beyond mechanical name matching. The nested-comment-aware source scan is conservative and may stop on a suspicious token inside a string.

Existing accepted Lean files may only be appended to when the gate explicitly permits the shared module or root aggregators. New helper files belong under `Aiyagari1994/Analysis/<gate>/`. No deletion or unapproved file is accepted. Any contract change except the assigned status is a hard stop; even a seemingly harmless declaration rename requires manual reconciliation in this first version. Helpers proving later economics are forbidden and reviewed substantively; this is not decidable by a filename check.

Snapshots include project Lean, compact authority/docs/contracts/prompts/reviews/reports/tools, fresh checks, complete tracked-plus-untracked baseline diff and Git metadata. They exclude Git, Lake, source PDFs, archives, compiled objects, caches and unrelated repository files. Each included file is hashed; sorted compact UTF-8 JSON of the manifest determines `snapshot_sha256`. The manifest excludes its own bytes. Snapshot files/directories become 0444/0555. The controller verifies all hashes before and after review and requires the exact hash in the verdict. Permissions supplement the read-only child sandbox; they are not a hostile same-user operating-system security boundary.

## State and decisions

State is atomically replaced and fsynced in `tmp_orchestration/state.json`; a process lock prevents concurrent controllers. State stores gate, attempt, revision count, workspace baseline, snapshot hash/path, verdict, ownership hashes and acceptance-commit status.

Normal transitions are READY_TO_EXECUTE → EXECUTOR_RUNNING → DETERMINISTIC_CHECKS → FROZEN_FOR_REVIEW → REVIEWER_RUNNING. Then:

- PASS permits ACCEPTANCE_RECORDING only with HIGH confidence, no human-review flag, exact gate/attempt/hash, passed checks, no blockers and exactly one adequate assessment for every assigned contract.
- REVISE with HIGH confidence, no human-review flag and a nonempty precise repair instruction returns to the same gate, at most twice. A third REVISE stops. Usage-failure retries do not consume this mathematical revision budget.
- BLOCK, malformed output, insufficient confidence, uncertain authority, failed deterministic checks, hash mismatch or unexpected changes produces HUMAN_STOP. Deterministic failures stop before spending Astra allowance; this first version does not automatically repair them.

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

Tracked: controller, configuration, gate list, schema, role prompts, tests, authority amendments and setup report/evidence. Runtime: state/lock, preflight smoke, dry-run prompt, attempt prompts/events/finals/checks, frozen manifests/snapshots, decisions and accepted SHA receipts. No credentials are intentionally recorded; reports expose authentication only as `ChatGPT subscription`. Do not paste credentials into executor prompts or reports.

The tests use fake model responses and temporary fixture Git repositories; they consume no model allowance and prove no economics. They cover verdict rejection, auth rejection, environment stripping, snapshot tampering/exclusions, dirty scope, accepted-source protection, revisions, real controller acceptance commits, usage resume and crash idempotence. Setup also runs actual deterministic checks on already accepted M03A only.

To add stages after M03F, obtain explicit user/design authority, update the tracked gate configuration, prompts, allowlists and tests in a reviewed infrastructure change, and initialize an explicitly reconciled baseline. The default checkpoint must not be bypassed by treating the next original numbered prompt as authorization.
