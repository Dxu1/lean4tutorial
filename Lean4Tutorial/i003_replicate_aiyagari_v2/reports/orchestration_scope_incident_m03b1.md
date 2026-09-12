# M03B1 orchestration scope incident

Classification: **ORCHESTRATION_SCOPE_ALLOWLIST_DEFECT**.

Original stop: `HUMAN_STOP`, M03B1/H09, attempt 1, diagnostic
`UNEXPECTED_DIRTY_PROJECT: reports/logs/03b1/new_exports.txt`.
Baseline: `7f7fb35e006804b358aba144126f69bee1df0440` on `issue3`.
The completed invocation was GPT-5.6 Sol / Medium / INITIAL; Astra had not run.

## Diagnosis

The offending file is untracked, 676 bytes, 16 newline-separated public declaration
names. It is an audit inventory, not executable Lean. The producer was the executor's
file-change event `item_95` (direct patch, not a repository generator script), adding
it alongside commands.json, log_provenance.md and pdf_qa.md. Exact producer evidence
is in `tmp_orchestration/runs/M03B1/attempt_001/executor_events.jsonl`.
Accepted M02B and M03A contain tracked `reports/logs/02b/new_exports.txt` and
`reports/logs/03a/new_exports.txt` with the same audit convention.

All names have #check, assert_no_sorry and #print axioms entries in Audit.lean.
Five exports construct the positive vanishing secant sequence; four define the
extended marginal and its boundary/measurability properties; four establish the
extra-saving and secant comparisons; three establish H09's extended inequality,
conditional finiteness and integrable real inequality. These are H09 helpers and
its contract, with no H10+ implementation. The only contract diff is H09 moving
UNFORMALIZED to REVIEW_READY. Accepted Lean bodies are unchanged; All.lean and
Audit.lean have appended content only. This classification is a scope diagnosis,
not independent mathematical acceptance.

Exact inventory (all in namespace Aiyagari1994):

```text
marginalStep
marginalStep_pos
marginalStep_antitone
marginalStep_tendsto_zero
tendsto_add_marginalStep_right
extendedRightMarginalValue
extendedRightMarginalValue_zero
extendedRightMarginalValue_of_pos
extendedRightMarginalValue_measurable
value_extraSaving_comparison
transitionSecant_integrable
secant_extraSaving_comparison
secant_extraSaving_lintegral
extendedRightMarginalValue_superharmonic
continuationMarginal_lintegral_lt_top
rightMarginalValue_superharmonic
```

## Narrow repair and preservation

The old scope predicate accepted logs/m03b1/*, but the executor followed the
accepted logs/03b1/* convention. It also omitted reports/m03b1_signatures.md.
The repair enumerates the known executor audit filenames in either current-gate
log spelling and the exact current-gate signatures report. Arbitrary files remain
forbidden, including unknown files even under the formerly broad m03b1 log rule.
No mathematical source or assumption is whitelisted by this repair.

An explicit reconcile-scope command validates the original stop, completed Medium
history, expected old/new HEAD, a single infrastructure-only commit, clean index,
unchanged outer status, preserved submission hashes and attempt-evidence hashes.
It records the transition, then run resumes after the executor. Independent checks
precede any review call. Documentation checks use scratch copies to preserve the
submitted ledger bytes. No H09 implementation was discarded, edited or rerun by
the repair; effort and invocation remain Medium / 1 / INITIAL.

Pre-repair receipt: tmp_orchestration/scope_incident_m03b1/preservation.json.
Receipt SHA-256: fde8e705f8f5ec6855a428dcecc285b3a43e125ab3b5414fa17ec4db795201f2.
Original state is preserved beside it. The repair commit SHA is resolved by
`git log --diff-filter=A --format=%H -- reports/orchestration_scope_incident_m03b1.md`
and recorded explicitly by reconciliation.json in that runtime directory. A commit
cannot contain its own SHA. Post-run outcome will be recorded below after execution.

## Regression verification

102 mocked orchestration tests passed before documentation finalization; the full
suite is rerun on the final repair. Tests cover allowed gate-local audit inventory,
wrong directories, unknown reports/Lean files, later-gate files, original dirty-tree
protections, submission and evidence tampering, infrastructure-only ancestry,
completed invocation/Medium preservation, and no Astra before scope/check success.
No model allowance is consumed by these tests.

## Execution outcome

At infrastructure-commit preparation: reconciliation and resumption pending;
no Astra verdict. Runtime transition and controller state are authoritative for
subsequent progress. The completed executor evidence is preserved in attempt_001.

### Post-reconciliation outcome (2026-09-12)

Infrastructure repair commit / current HEAD:
`e97828421e5442d63575b61125ba3268db7b8b3b`.
Final complete mocked suite: **102 tests passed** (11.588 seconds).
Reconciliation succeeded; the controller resumed the existing post-executor flow.
Scope validation passed. Original H09 files and original attempt evidence were
verified byte-for-byte unchanged after the run, including ledger TeX/PDF.
Executor remains attempt 1 / invocation 1 / gpt-5.6-sol / Medium / INITIAL.
No executor rerun or escalation occurred.

Controller deterministic targeted/full builds, direct audit, contracts, signatures,
documentation scratch build and tracked git diff check all exited 0. The complete
verification gate did **not** pass: the untracked-file whitespace check stopped at
`NEW_FILE_DIFF_CHECK: reports/logs/03b1/docs_build.log`. Reproducing that read-only
check reported trailing whitespace at lines 156 and 332, and a blank line at EOF
at line 360. The original raw log is preserved; no sanitization or workaround was
performed. The controller did not write a passing checks.json, freeze a snapshot,
invoke Astra, accept H09, or advance to H10.

Final state: **HUMAN_STOP**, current gate **M03B1/H09**, no Astra verdict.
No push was attempted because the user's push condition required all reconciliation
checks to succeed. The infrastructure commit is local. This new deterministic stop
requires human reconciliation; the infrastructure-specific recovery command and
ordinary --resume must not be used to bypass it.

Exact project-relative evidence locations:

- tmp_orchestration/scope_incident_m03b1/preservation.json
- tmp_orchestration/scope_incident_m03b1/original_state.json
- tmp_orchestration/scope_incident_m03b1/reconciliation.json
- tmp_orchestration/scope_incident_m03b1/reconcile_output.json
- tmp_orchestration/scope_incident_m03b1/tests.log
- tmp_orchestration/scope_incident_m03b1/final_preservation_check.log
- tmp_orchestration/runs/M03B1/attempt_001/pre_review_checks/
- tmp_orchestration/state.json

This outcome addendum updates the tracked incident report locally after the stop;
it is not committed, so the active controller's baseline HEAD remains intact.
No mathematical or executor artifact was changed to write this addendum.

## Second incident: generated compiler-output whitespace

Classification: **GENERATED_EVIDENCE_HYGIENE_DEFECT**.
Original second stop: `NEW_FILE_DIFF_CHECK: reports/logs/03b1/docs_build.log` at
baseline `e97828421e5442d63575b61125ba3268db7b8b3b`, M03B1 attempt 1.

The log is wholly generated stdout/stderr from `bash tools/build_docs.sh proof_ledger`
(Pandoc, latexmk, pdfTeX). The final producer was executor command event `item_107`,
exit 0, including the subsequent PDF render. Git's no-index check reported trailing
spaces at lines 156 and 332 and a blank line at EOF, line 360 (exit 3).
These are compiler formatting, not a proof or export failure. Accepted M01, M02A,
M02B and M03A have analogous docs_build.log files; their saved copies contain no
trailing whitespace or blank EOF. That precedent supports the artifact class,
not a claim that prior logs had identical whitespace.

All 20 current gate-log files were inspected. Sixteen are mechanically produced:
accepted_source_preservation.log, artifact_sha256.log, assert_no_sorry.log, audit.log,
changed_files.log, contracts.log, docs_build.log, full_build.log, git_diff_check.log,
pdf_render.log, prohibited_patterns.log, prohibited_patterns_hits.log, signatures.log,
targeted_build.log, transitive_axioms.log, verified_sources.sha256.
Only docs_build.log currently triggers whitespace diagnostics. The manually patched
commands.json, new_exports.txt, log_provenance.md and pdf_qa.md stay strict.

The exact repair moves whitespace checks into diff_checks and exempts only the
current gate's explicitly enumerated mechanical paths after checking recorded
successful producer commands. Producer records and SHA-256 hashes are written to
verification/generated_evidence.json, preserved with raw bytes in the frozen
snapshot. Independent command verification remains required. No generated file is
normalized, and no broad reports wildcard is introduced.

The reconciliation path supports this exact second stop, validates the previous
infrastructure transition plus original and current submission/attempt hashes,
and retains attempt 1 / invocation 1 / gpt-5.6-sol / Medium / INITIAL. New independent
checks use a distinct pre_review_checks_<HEAD> directory; old checks are preserved.
H09 was not rerun and its source, reports, manifest, ledger and raw logs remain
byte-for-byte unchanged throughout repair preparation.

All **112 orchestration tests passed** (13.948 seconds), retaining all previous
102 tests and adding generated whitespace/EOF, raw snapshot hash capture, producer
validation, unknown/wrong-gate path rejection, strict authored source checking,
second reconciliation/old evidence preservation and no model before checks coverage.
The tests use mocked model/Lean calls and consume no model allowance.

Second preservation receipt:
`tmp_orchestration/generated_log_incident_m03b1/preservation.json`.
SHA-256: `894e22961720cfcf65ce14c0b442caca32490d6f2520ffe333ae50c97c06fbe5`.
The prior incident report and runtime evidence are retained. This second commit also
records the previously uncommitted first-incident outcome addendum above. Its own
commit SHA will appear explicitly in the guarded reconciliation.json; it cannot be
embedded in its own commit content. Second reconciliation/push/review are pending at
commit preparation; any subsequent result is recorded below after the controller stops.

### Second-repair execution outcome

Repair commit: `e218bc1c5e1307771a1cae7e07344fafac7dc02a`.
Both infrastructure commits were pushed normally to origin/issue3, from 7f7fb35
through e978284 and e218bc1. No unaccepted mathematical work was pushed.

Guarded reconciliation succeeded and H09 was not rerun. Its sole substantive
executor remains attempt 1 / invocation 1 / Sol Medium / INITIAL.
All controller pre-review checks passed: scope, targeted/full builds, audit,
contracts, signatures, documentation, prohibited-pattern scan, transitive axioms,
tracked and new-file diff checks. The audit covered 307 declarations and 27 Lean
files. All generated output bytes were retained and hash-bound in the snapshot.
The original H09 Lean files, raw gate logs, original executor evidence and earlier
failed-check logs were rehashed after the run and remain unchanged.

Fresh read-only GPT-6 Astra / XHigh reviewed the existing H09 attempt and returned
PASS, HIGH confidence, no human-review requirement and no blockers. D01–D20 were
assessed; D11 was NOT_APPLICABLE, all other dimensions PASS. Nonblocking qualification:
the compact snapshot excluded the ledger PDF, so independent PDF layout verification
was not claimed; Markdown/TeX were inspected and the successful build was recorded.
All economic carry-forward qualifications are retained in reviews/m03b1_acceptance.json.

The controller accepted H09 and created commit
`390e5e9a3491a705f5b8bc3aee42b02bf693c2d4`. H09 acceptance is local and has not been
pushed; origin/issue3 remains e218bc1 as requested for the infrastructure push.

Autonomous execution continued to M03B2/H10, Sol Medium attempt 1. That executor
completed and reported its own checks successful. The controller then stopped at
scope validation with `UNEXPECTED_DIRTY_PROJECT: reports/logs/m03b2/frozen_scope.log`.
Final state: HUMAN_STOP, gate M03B2, attempt 1, no H10 Astra verdict. H10 independent
controller verification did not start. No later stop was bypassed or repaired.
The preserved H10 submission remains uncommitted. Stage 03 did not complete.

Relevant evidence (project-relative):

- tmp_orchestration/generated_log_incident_m03b1/reconciliation.json
- tmp_orchestration/generated_log_incident_m03b1/tests.log
- tmp_orchestration/generated_log_incident_m03b1/outcome.json
- tmp_orchestration/runs/M03B1/attempt_001/pre_review_checks_e218bc1c5e1307771a1cae7e07344fafac7dc02a/
- reviews/m03b1_acceptance.md and reviews/m03b1_acceptance.json
- reports/logs/m03b1/review/
- tmp_orchestration/runs/M03B2/attempt_001/
- reports/logs/m03b2/frozen_scope.log
- tmp_orchestration/state.json

This final outcome addendum is a local update to the tracked incident report after
the controller stop; it is not committed, preserving the active baseline HEAD.
