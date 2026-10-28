# E03 generated signature-probe reconciliation

Classification: `GENERATED_SIGNATURE_PROBE_FORMAT_RECONCILIATION`.

Baseline is accepted E02 commit `97c8e041bf9a5cf79b4cebf47638148c2469bc95`. The original state is M10B3 / HUMAN_STOP / `NEW_FILE_DIFF_CHECK: Probes/M10B3Signatures.lean`, after one completed GPT-5.6 Sol Medium invocation, zero substantive revisions, and no independent mathematical review. All E03 mathematics, Audit additions, ledger, executor evidence, accepted E01/E02 evidence and root-aggregator certificate are hash-preserved in `tmp_orchestration/stage10b/signature_probe_repair/receipt.json`.

## Exact options and effect

The original probe has file-scoped `set_option format.width 72` at line 4 and `set_option pp.funBinderTypes true` at line 5. Neither uses the command-scoped `in` form. Imports precede both options; the remaining commands only inspect already compiled declarations.

The pinned Lean v4.32.0 sources establish the actual effects:

- `Lean/Data/Format.lean:23` registers `format.width` as a natural-number formatting option. `Format.pretty'` at line 38 passes it to the text layout function `pretty`. `Lean/PrettyPrinter/Formatter.lean:653` likewise passes it to `OneLine.pretty`. It changes rendered line width, not expression construction.
- `Lean/PrettyPrinter/Delaborator/Options.lean:68` registers `pp.funBinderTypes` with the description “(pretty printer) display types of lambda parameters.” Its accessor at line 245 is used by the binder delaborator in `Builtins.lean:922,936` to select printed type annotations. The LCNF occurrence in `Lean/Compiler/LCNF/PrettyPrinter.lean:101` constructs a `Format` for debug text; it does not alter generated code. Expr/TermElabM occurrences attach display annotations for diagnostics, not an elaboration-control option.

These settings control display only: neither changes parsing, typeclass resolution, reducibility, namespace resolution, theorem construction, kernel trust or code generation. The declaration-free grammar also disallows semantic declarations, arbitrary options, command-scoped options, quoted syntax, tactics and expressions. Earlier accepted M02B and M10B2 probes use exactly these values; numerous other accepted probes use width 100 and the same binder display option. E03 therefore follows an established evidence-formatting convention rather than introducing new semantic configuration. Source-file hashes and exact consumer search results are retained as `option_sources.json` and `option_consumers.txt` in the repair evidence directory.

## Grammar, identity and normalization

The existing generated-artifact registry now registers M10B3 with producer `completed_executor_file_change`, gate/contract identity, artifact kind `signature_probe`, and versioned grammar `signature_probe_v2`. Its exact template fixes two imports, the two printing options, and 69 targets with one each of `#check`, `assert_no_sorry`, and `#print axioms`: 211 commands total. Every target is either an E03 helper under `Aiyagari1994.M10B3` or the public E03 theorem. Audit coverage is verified for every target; accepted E01/E02 files remain frozen.

Only explicitly whitelisted display names/values can parse; the registry additionally fixes exact option values and command sequence. A changed check/print/axiom target, deleted or extra command, unknown or semantic option, or semantic declaration fails closed. Comments and approved whitespace do not affect command identity. Nested comments are scanned without joining tokens. The older probe grammar remains unchanged for its existing registration.

Canonicalization preserves every command and comment and removes only authorized whitespace. In this exact incident the original is the canonical output plus three newline bytes. Both option commands remain unchanged. The hash-bound journal records before/after hashes, identical parsed command sequences, producer event `item_59`, and the completed invocation. No other mathematical or evidence source is normalized.

The guarded resume requires a direct infrastructure-only child commit, unchanged source/runtime hashes, the original single Medium invocation and zero revisions/reviews. It preserves the original HUMAN_STOP and resumes fresh controller checks without rerunning Sol. Generated-probe certificates are required in M10B3 deterministic summaries and review-context validation. Full Stage-10 integration rechecks all registered accepted probes read-only, alongside the existing mathematical and provenance gates.

The infrastructure commit excludes the unaccepted E03 implementation and probe. The probe is canonicalized only by the guarded reconciliation afterward. No real model calls occur during this repair; only the subsequent independent review is authorized. Any mathematical reviewer objection remains separate from this formatting incident.

Validation: full mocked orchestration suite 860 run / 858 PASS / 2 historical SKIP, including 38 new probe-grammar/reconciliation tests. The two skips concern already-promoted historical candidate fixtures. All original E03 source, probe and runtime hashes remained unchanged before the infrastructure commit.
