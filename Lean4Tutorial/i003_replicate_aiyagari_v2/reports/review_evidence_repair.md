# Review evidence and ledger synchronization repair

This infrastructure/documentation repair addresses the human-audited H10 evidence
BLOCK. The prior Astra review reported no mathematical defect and passed every
substantive dimension; D04 lacked the cited A94 PDF, D16 found contradictory ledger
status prose, and D20 therefore could not certify adequacy. The prior BLOCK remains
intact and is not relabeled REVISE or PASS. Only a fresh complete independent review
can authorize H10 acceptance.

The original selector used only `sources[]`. H10 listed A93 but its exact locator
also cites A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Selection now
unions the structured array with exact approved manifest IDs in the locator.
Arbitrary text cannot become a filename. Every PDF is checked against the approved
local name and SHA-256 before review; missing/hash-invalid evidence reports
SOURCE_EVIDENCE_INCOMPLETE. The immutable source index binds each source ID/hash
to every assigned contract's exact complete locator. A deterministic all-contract
consistency inventory accompanies both source validation logs and snapshots.

Twenty contracts have locator IDs absent from their structured arrays. We preserve
those arrays because their primary/background-source semantics are not uniformly
specified. The union rule prevents omissions without changing theorem statements,
assumptions, dependencies, proof plans or economic scope.

## Metadata discrepancies

| Contract | Locator IDs absent from sources |
| --- | --- |
| A03 | A94 |
| D01 | A94 |
| H01 | A94 |
| H02 | A94 |
| H03 | A94 |
| H04 | A94 |
| H06 | A94 |
| H07 | A94 |
| H10 | A94 |
| H12 | A94 |
| H13 | A94 |
| H14 | A94 |
| N01 | A94 |
| N02 | A94 |
| N04 | A94 |
| N05 | A94 |
| NP01 | A94 |
| NP02 | A94 |
| NP03 | A94 |
| S02 | SLP89 |

## Preservation and ledger repair

Preservation receipt: `tmp_orchestration/review_evidence_repair/preservation.json`.
SHA-256: `2d190535e929eafd37daced37f5f96f45027ab1f047b53c57bf3c27c3ea936e6`.
It records every project file, all prior attempt evidence and the exact state before
any repair. The guarded transition additionally requires unchanged Lean files,
Audit/probes, theorem metadata and predecessor records, plus exactly two permitted
Markdown status replacements. H09/H10 readable mathematical proofs are unchanged.
All Lean files and the entire theorem manifest were rechecked byte-for-byte.

The H08 boundary now explicitly labels the old status historically, points to the
current generated overview/headings and H09 acceptance. The H09 audit records its
independent GREEN acceptance and retains its qualifications. H10 remains
REVIEW_READY. TeX/PDF were regenerated; rendered PDF pages 20 and 22 were inspected
for the repaired text, with no clipping or overlap in those passages. The complete
ledger has 40 pages; this is targeted layout QA, not a new whole-ledger audit.

The new checker verifies global and section statuses and narrow current-status
claims, accepts sentence-local historical markers, and catches accepted sections
still awaiting review or future/REVIEW_READY sections claiming completion. It does
not infer mathematical truth from prose. Verification compares the submitted TeX
with a fresh deterministic generation. Authorized acceptance now regenerates the
tracked TeX/PDF after status promotion. Prefer generated overview and section
headings for changing current status rather than duplicated narrative statuses.

The prior infrastructure report's already-written outcome addendum is included
unchanged in this documentation commit. Existing H10 ledger exposition is likewise
preserved in the committed ledger; only the two status passages were edited here.
H10 Lean modules, All.lean, Audit.lean, probe and theorem status are not staged in
the infrastructure commit.

## Reconciliation and verification

REVIEW_EVIDENCE_REPAIR is explicitly limited to the exact hash-bound, human-audited
H10 review. All substantive dimensions must pass; a mathematical/design/source
conflict cannot enter this lane. It preserves attempt 1 / invocation 1 / Sol Medium
/ INITIAL / zero substantive revisions. A direct repair commit and unchanged
submission are required before POST_EXECUTOR_RECONCILED. No executor is called.

Fresh snapshots and review output paths preserve the old BLOCK, logs and manifest.
The reviewer receives the standard full D01-D20 prompt in a fresh read-only Astra
XHigh session, with no inherited-verdict instruction. Normal acceptance/revision/
human-stop policy applies afterward; later gates remain subject to independent
review and the Stage-03 checkpoint.

Validation evidence is retained in `tmp_orchestration/review_evidence_repair/`:
complete mocked suite (158 tests, including all 133 prior tests) `tests.log`, deterministic consistency report, documentation
build output, rendered repaired pages, preservation receipt and reconciliation.
Both approved local PDFs were hash-verified:

- A93: `274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`
- A94: `75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`

The exact A94 manifest hash is authoritative; see the source validation output.
