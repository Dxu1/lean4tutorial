# NP01 root-aggregator reconciliation

Incident: `ACCEPTED_LEAN_CHANGED: All.lean` → `APPEND_ONLY_GUARD_INCOMPATIBLE_WITH_ROOT_AGGREGATOR` → `ROOT_AGGREGATOR_IMPORT_RECONCILIATION`.

Verified starting branch issue3; local and remote HEAD 2e6bd77b55fa23252eac601ada028c0ed39fb12e. Original NP01 Sol Medium invocation 1 is preserved, substantive revisions zero, no mathematical reviewer invocation. One earlier availability smoke is separate. The repair invokes zero models.

All.lean is explicitly registered for M10A1 only. The accepted and candidate files are pure import lists with all 48 original imports retained exactly once in relative order and exactly one new import: Aiyagari1994.Budget.NoPonzi. Comments alone may vary. Non-import commands, removals, duplicates, reordering, wrong ownership, cycles, semantic reverse imports, missing modules, and future-stage imports fail closed. Actual reverse imports are Audit and four signature probes; no semantic project module reaches All, directly or transitively.

Original All SHA-256: c4657eedfad73fb6960bd66de67fb8a237eb767aca4811d615b5f9b1206c4a82. Candidate SHA-256: 6b93c48ff9e4c7a0d1076dce6b77ece436da8958f18f3b7bb722fcf7d75b09b5.

Certificates bind the baseline, exact candidate, full project source graph, contract contents, active gate, serializer and checker. All accepted mathematical sources are byte-identical. An independent deterministic Lean comparison checks all 51 previously accepted declarations' exact types, proof/definition values, universe parameters, metadata, project dependency closures and axiom closures across the original and candidate aggregator environments. Expressions use a lossless structural DAG with binder names, annotations and metadata retained; hash-table collisions are resolved by full ExprStructEq equality. No pretty-print normalization or short-hash equality substitutes for expression comparison.

Frozen-scope validation uses this lane only for registered gate/file pairs. All other files retain the existing raw-prefix or certified shared-module paths. REVIEW_CONTEXT_COMPLETE requires the current certificate and validates its exact input and artifact bindings. The integration checkpoint also validates the immutable NP01 review certificate against its accepted snapshot and the unchanged aggregator.

Preservation evidence: tmp_orchestration/stage10a/aggregator_repair/receipt.json and original_state.json, original/candidate All.lean, complete mathematical source snapshots, executor capsule/event/usage hashes. Receipt SHA-256 fd44dfdc3a88a7bb52e0a724605800b411f7c64a5750d3a40be91ca1243e7153. The explicit resume guard checks the direct infrastructure-only commit, unchanged submission/runtime hashes, exact executor identity and absence of reviews before transitioning to POST_EXECUTOR_RECONCILED. Sol is not rerun.

Regression verification: 660 tests PASS, including 39 new aggregator tests and the retained parser/ledger/shared-provenance suite. Tests are mocked, with zero real model calls. Test log: tmp_orchestration/stage10a/aggregator_repair/tests_v3.log. Fresh controller verification and independent review remain necessary after guarded reconciliation; this infrastructure report does not award GREEN.

Live deterministic accepted-interface audit: PASS for all 51 accepted contracts, exact original/candidate DAG records equal. Certificate input SHA-256 dfbcc5e04a40728130b080205bdd732e8a1b21bae83ebd275d4e2ef5950f20d7. Test log SHA-256 f327e998e8e1beda3bea958a1614af18975b64337f9f1196cdb22fe75f6bdf08.
