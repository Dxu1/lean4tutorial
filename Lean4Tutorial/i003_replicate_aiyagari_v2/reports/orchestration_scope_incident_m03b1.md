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
