# E01 ledger contract-ID list parser repair

Classification: LEDGER_CONTRACT_ID_LIST_CONJUNCTION_PARSER_DEFECT.

Original state: M10B1/E01 HUMAN_STOP, AMBIGUOUS_LEDGER_STATUS_CONFLICT, accepted HEAD 13ae5e3f8db0f7f4185aa042a3d103a773ec28ec. E01 has one completed Sol Medium invocation and zero substantive revisions; no mathematical review occurred. The original state, submission, ledger and executor/capsule/root-certificate evidence are hash-bound in tmp_orchestration/stage10b/ledger_parser_repair/receipt.json (SHA256 e02145e5ba07d08f4ece552eb5ea02a7476a032c6ccc0221865ddd6d47876786).

The exact overview says `E02 and E03 are **UNFORMALIZED**`. Both IDs exist and both statuses agree with the manifest and detailed sections. The old uppercase/comma-only regex omitted E02. Changing only the conjunction to a comma in memory removed the sole error; the original prose and all mathematical/ledger artifacts are preserved byte-for-byte.

A narrow tokenizer/parser now handles a single known ID, comma-separated IDs, and a final `and` or `&`, with or without an Oxford comma. It returns ordered IDs, rejects unknown IDs, duplicates, empty members, missing separators and misplaced conjunctions. It is used only in established overview/reference-list status slots, not for arbitrary prose. Status comparison is separate and remains manifest-authoritative. Historical sentence exemptions and code-fence exclusions remain unchanged. The stale-overview reconciliation lane consumes the same parsed representation.

Structured statuses already generate acceptance metadata in acceptance_status.promote_metadata and are checked by global_status.overview. No documentation-system redesign or broad ledger rewrite is needed: human-readable references use the grammar, structured status remains authoritative.

Guarded recovery validates the receipt/state, exact one-Medium-call identity, zero revisions/reviews, parser-only child commit and clean index, unchanged submission/runtime hashes, 54 accepted predecessors, unchanged root certificate and absent later candidates. It records the original HUMAN_STOP and returns only to POST_EXECUTOR_RECONCILED. It dispatches no model and requires the ordinary controller to rerun verification and REVIEW_CONTEXT_COMPLETE before the first Astra High review. It neither awards GREEN nor reruns Sol.

Regression coverage includes all requested list forms, malformed/unknown/duplicate IDs, prose conjunctions, real status mismatches, manifest/detail/global disagreement, historical scope, preserved E01 hashes, exact invocation identity, and verification-before-review ordering. Existing freeze tests now recognize the explicitly authorized Stage10b IDs and distinguish historical committed All.lean from the unaccepted candidate; their semantic freeze and fail-closed checks remain intact. Full mocked suite evidence: tmp_orchestration/stage10b/ledger_parser_repair/tests_final.log. No real model calls during repair.

Full mocked suite result: 779 tests run, 778 passed, one existing historical optional test skipped. All submission and original runtime hashes rechecked unchanged before committing.
