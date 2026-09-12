# Mechanical verification artifact refactor

This is an infrastructure change. H10 has not been rerun, revised or regenerated.

## Diagnosis and preserved baseline

The nuisance stops at new_exports.txt, docs_build.log and frozen_scope.log arose
because executor-generated evidence shared a project namespace with semantic files.
Gate-directory spelling and raw compiler whitespace then affected scope validation.
Filename-by-filename exceptions could not fix producers choosing project log paths.

At entry: issue3, HEAD 390e5e9a3491a705f5b8bc3aee42b02bf693c2d4 (accepted H09),
M03B2 attempt 1, completed invocation 1, Sol Medium, INITIAL. H10 had no Astra review.
The exact stop was UNEXPECTED_DIRTY_PROJECT: reports/logs/m03b2/frozen_scope.log.

The file is a Git-diff inventory produced by executor command event item_64,
exit 0. It names the accepted H09 baseline, lists All.lean, Audit.lean,
contracts/theorems.json and the three ledger formats, then has an empty
“Accepted substantive predecessor modules changed (expected empty)” section.
Inspection and a fresh semantic scope comparison found no unauthorized scope
change. The executor followed inherited report-log instructions rather than a
controller-owned runtime evidence API. Classification: MECHANICAL_NAMESPACE_DEFECT.

Before edits, all project hashes, original runtime state and attempt-001 evidence
hashes were recorded under tmp_orchestration/mechanical_refactor/. Receipt:
preservation.json, SHA-256 d954bf13e53fc5db6e19b268491771e6d0214bbbf7742f4cacf07541faf4fc60.
The prior incident report and prior evidence remain preserved.

## Architecture

Semantic Lean, contracts, assumptions, proof-ledger source, milestone reports and
analytical audits remain strictly scoped in the project. Raw mechanical outputs
use a canonical runtime gate/attempt/check directory supplied by the controller.
A central artifacts.json registry defines producers, paths, mandatory status,
raw hygiene, hashing and compact retention. Future executors are explicitly told
to leave local check output in stdout/events and not invent project log locations.

AUTO_RECONCILE deterministically validates current-attempt provenance and the entire
semantic diff before copying a known legacy output. It records source/destination
hashes and producer events, verifies byte equality, then removes only untracked,
proven generated originals. The write-ahead migration journal supports interruption
recovery and rejects repeated/reappearing deviations. It is not an LLM classifier.
A frozen_scope output that reports predecessor mutations is a blocker.

Fourteen H10 outputs qualify for migration: targeted/full build, audit, contract,
signature, documentation, transitive-axiom, no-sorry, prohibited-pattern, diff,
PDF-render, source-hash, artifact-hash and frozen-scope logs. Four authored companion
files (commands.json, new_exports.txt, log_provenance.md, pdf_qa.md) stay in place;
their bytes and the main milestone/audit reports are never normalized or moved.
The controller now generates its own export inventory in runtime independently.

Runtime paths and registry records are validated. Unknown artifacts, ambiguous
provenance, symlinks, changed hashes, later-gate source, contract/assumption changes,
accepted Lean edits and reviewer/source-evidence failures remain fail-closed.
Recorded compound process exit status establishes provenance only; all mandatory
checks independently run before review. No raw-output whitespace normalization occurs.

Selected transient OS errors allow one logged mechanical-check retry. Nonzero proof
checks and model failures are not silently retried as transient OS errors. Operational
reconciliation never changes mathematical attempt, invocation, revision count or effort.

After independent PASS, compact durable summaries retain check names, exit results,
raw hashes/paths, counts, snapshot manifest, exact verdict/decision and executor
invocation metadata. New raw build/acceptance logs are not committed. Existing H09
and older evidence/history are untouched. Accepted-state reconstruction does not
depend on retaining the runtime directory.

## Verification and migration

133 mocked tests passed before final documentation changes. The original 112 tests
remain as explicit historical compatibility fixtures; 21 new runtime-architecture
tests cover namespace separation for every registered artifact, migration and
provenance, restart/idempotence, rejection of semantic/unknown/runtime tampering,
bounded retry, compact acceptance/reconstruction after runtime deletion, usage
resume, full automatic continuation, and H10 invocation/effort/predecessor preservation.
All calls in tests are mocks/temporary fixtures; no model allowance is consumed.
The complete suite is rerun on final code before the refactor commit.

The guarded reconcile-runtime operation requires the exact H10 stop and preservation
receipt, a single infrastructure-only child commit, unchanged submission and executor
hashes, unchanged accepted H09 and no staged work. Only after commit and push will
it migrate the completed attempt and allow independent verification/Astra. No H10
semantic content is part of the infrastructure commit.

At report preparation: commit/push/migration/review remain pending. Their exact
results will be recorded in a final addendum after the controller returns.
