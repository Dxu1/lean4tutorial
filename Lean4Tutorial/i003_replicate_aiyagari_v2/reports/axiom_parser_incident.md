# H12 axiom evidence parser incident

Classification: AXIOM_PARSER_FORMAT_DEFECT (infrastructure/evidence).

M03C/H12 stopped before Astra on NONSTANDARD_AXIOM. The old parser collected only
physical lines containing `depends on axioms:` and expected the entire bracketed
list on that same line. Lean wrapped the record for
`Aiyagari1994.eulerNextMarginal_eq_extendedRightMarginalValue` after `propext,`,
placing `Classical.choice` and `Quot.sound` on following lines. The missing closing
bracket on the header line was falsely classified as a nonstandard axiom.

Complete-record inspection finds 324 declarations and exactly the permitted union:
`propext`, `Classical.choice`, `Quot.sound`. No real nonstandard axiom was found.
The new parser also handles the earlier accepted H10/H11 outputs (316/318 records).
An exact 324-record output fixture retains the actual H12 wrapping; it contains
only axiom evidence, not H12 proof sources.

## Repair and tests

The deterministic parser searches for a declaration header, expects a list or
Lean's explicit no-axioms form, accumulates through the closing bracket, validates
list syntax, and checks exact names against the allowed set. It retains whole raw
records in consolidated evidence. Coverage is matched to every Audit `#print axioms`
declaration, including empty/no-axiom records; duplicates or missing declarations
fail. Unknown names report GENUINE_NONSTANDARD_AXIOM. Truncated or malformed
headers/lists and unexpected trailing syntax report AXIOM_EVIDENCE_MALFORMED.
No H12-specific name or wrapping exception is used in the parser.

Regression coverage includes one-line/multiline/indented/comma-wrapped forms,
empty lists, subsets/order/duplicates, unknown names, malformed/truncated records,
unrelated brackets, adjacent records, 324 synthetic records, one bad record among
hundreds, the actual H12 fixture, explicit no-axiom records, and exact declaration
coverage. Guarded-reconciliation tests preserve attempt, invocation, Medium effort
and zero revisions, and reject modified mathematical files or executor evidence.
All 194 mocked tests pass (158 retained plus 36 new); no models are invoked in tests.

Nearby parser inspection: signature verification retains the complete output and
checks assigned declarations; mathematical signature adequacy remains independently
reviewed. No-sorry/print/check inventories parse source commands, with successful
Audit execution and exact output coverage. Export inventory derives from audited
names. Source hashes are computed directly from approved PDF bytes. Build evidence
uses process exit codes and structured JSON records/summaries. Event logs are JSONL,
where line framing is the format itself. No identical multiline-output defect was
found in those paths; unrelated code is unchanged.

## Preservation and recovery

Initial branch: issue3. Initial HEAD: de0af9ba9adb00d736e466a031e9677807bfe9b9.
Receipt: `tmp_orchestration/axiom_parser_repair/preservation.json`.
SHA-256: bfee36212f9b7cc6b031c3f67150a7f382ec5ceeb1ad54c248334a99f4d243dd.
The receipt records runtime state, project hashes and every existing attempt file.
No H12 mathematical, contract/status, ledger, report or audit file was changed by
this repair. H12 remains attempt 1 / invocation 1 / Sol Medium / INITIAL / zero
substantive revisions. No executor rerun or effort escalation is authorized here.

Only parser/controller code, regression tests/output fixture and infrastructure
reports/documentation enter the separate repair commit. Guarded reconciliation
checks its direct relationship to the preserved baseline, unchanged submission and
accepted H09/H10/H11 evidence, then enables deterministic verification followed by
fresh read-only Astra XHigh review. Normal verdict policy remains mandatory.

Execution results, the repair commit SHA and eventual Astra verdict are retained
in `tmp_orchestration/axiom_parser_repair/outcome.json` after the controller returns.
Tests and preserved parser diagnosis are under the same runtime directory.
