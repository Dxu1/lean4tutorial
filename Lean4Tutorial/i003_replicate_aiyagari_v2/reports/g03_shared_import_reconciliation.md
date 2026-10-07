# G03 shared-module import reconciliation

The stopped M09B2 submission is preserved under `tmp_orchestration/stage09b/shared_import_reconciliation/`. Its accepted baseline is G02 commit `b756f3d21530728a30a99534ea4aadcf60d796f3`; the preserved receipt SHA-256 is `79d696a34b59bf4fe5b4407e3ae8308af4e07c0d7962a79fefe81dc6b0b6b2ab`.

The incident is `ACCEPTED_LEAN_CHANGED → APPEND_ONLY_GUARD_REJECTS_SHARED_MODULE_IMPORT → SHARED_MODULE_IMPORT_ONLY_RECONCILIATION`. This is an infrastructure classification, not mathematical acceptance of G03.

The sole authorized inserted header line is `import Aiyagari1994.Analysis.M09B2.NaturalCapExistence`. Removing it restores the entire accepted G02 file as an exact byte prefix. Only the assigned G03 public wrapper and its documentation follow. The helper's 80-module project import graph is acyclic and contains neither the shared Existence module nor G02/F02 modules. Its actual elaborated proof dependency closure contains no contracted declaration outside G03's exact manifest dependency closure.

## Semantic preservation

Lean 4.32.0's environment enumerates every declaration owned by the shared module. The accepted environment contains `Aiyagari1994.finiteCap_equilibrium_exists`; the candidate adds only the assigned G03 wrapper. The baseline module is freshly compiled from the accepted Git source, in a separate temporary package tree whose unchanged sibling artifacts are linked from the checked project. The candidate is freshly built. All accepted sibling Lean source bytes are checked against the accepted commit.

For each accepted theorem, the collector records its fully qualified name, universe parameters, structural `Expr` representations of its elaborated type and proof value, declaration kind, safety/partial flags, opaque-theorem reducibility, mutual block, transitive project-constant closure, and transitive axioms. It uses actual theorem values, not type pretty-printing or an LLM summary. Structural representations retain binders and metadata without normalization. Unsupported declaration kinds, absent values, changed inventories or unequal fields fail closed. No weakened fallback was used.

The baseline and candidate accepted-declaration JSON files are byte-identical, each SHA-256 `770344fb992a2ec8806c4586b2b009333f8bc6a2e42093a974e0a7fdf1d64c59`. Their canonical field hashes are:

| Field | Equal baseline/candidate SHA-256 |
| --- | --- |
| Elaborated type | `edb7c3693032c75c9c6629c366173652a03c5e5c7e0f36dd5c367b2c570e4a35` |
| Proof value | `88e3ad5593c2b5b9c10bc010e585666315c591d16e921721ec56fdaa3b805c75` |
| Project dependency closure | `a47ef884fc828d01e7cc7c9bf738a9c2a8d91ea75d7566febd0cde99bd0644fc` |

Universe parameters remain empty. Both axiom closures are exactly `Classical.choice`, `Quot.sound`, `propext`. Full expression/dependency evidence and command logs remain in the hash-bound runtime certificate directory; compact field fingerprints are also embedded in the controller verification summary and immutable reviewer snapshot. Controller checks regenerate the comparison at pre-review, acceptance and integration.

## Guard and tests

The ordinary append-only guard remains the default. The explicit M09B2 exception requires its authorized shared module and import, unchanged source prefix, gate-owned suffix declarations, acyclic authorized imports, exact accepted semantic equality, and unchanged contract/status discipline. Other modules, source edits, hidden formal dependencies and semantic differences stop. No status is promoted by this reconciliation.

The full mocked orchestration suite passes 462 tests, including 31 new reconciliation regressions. The prior status-freeze fixture now recognizes already-authorized G02/G03 status transitions while continuing to compare every non-status contract field exactly. Existing parser, global-status and stale-ledger tests remain active. Logs are `tmp_orchestration/stage09b/shared_import_reconciliation/tests_final.log` and `new_tests.log`.

The repair itself invokes zero real models and changes no submitted mathematical source. The preserved execution identity is one completed GPT-5.6 Sol Medium invocation, invocation 1, zero substantive revisions, with no G03 reviewer invocation before reconciliation. Receipt-based resumption requires an immediate infrastructure-only child commit, unchanged submission and executor evidence, unchanged protected predecessors, unchanged outside-project state, and no prior G03 review. It resumes fresh controller checks, never the executor. Astra remains gated by `REVIEW_CONTEXT_COMPLETE`; independent adequacy review and separate acceptance are still required.

No A04/A05/G04–G08 or Stage-10 implementation is authorized.


## Compact-context guard follow-up

Fresh controller verification passed all 15 checks after the initial infrastructure commit `178a22f02ddd7ef3c42f3a9d231f29faf5ab8c36`, but snapshot export enumeration retained a second strict prefix check. It stopped with `REVIEW_CONTEXT_INCOMPLETE: accepted source prefix changed` before any G03 Astra invocation. That guard now delegates the same authorized import-only case to the semantic certificate before extracting and auditing the appended suffix. Four additional mocked regressions cover this path and its rejection cases. The new stop receipt is preserved separately under `shared_import_reconciliation/context_stop/`; its narrowly scoped continuation permits only this infrastructure follow-up, with the same Medium invocation and zero revisions. All original submission hashes remain unchanged. No real models were called by either repair.
