# N02 signature-parser incident

Classification: `LEAN_UNIVERSE_SIGNATURE_PARSER_DEFECT`.

M07A2 attempt 1 reached REVIEW_READY with all deterministic checks passing, then
context extraction rejected the valid printed name
`Aiyagari1994.stationary_bounded_jensen_equality.{u_1}`. The old matcher allowed
only whitespace, a colon or an opening brace immediately after the base name;
it did not recognize the dot introducing universe parameters. No declaration or
type mismatch was found. The exact signature is retained in the regression fixture.
Historical accepted audit output also contains `compactMax.{u_1, u_2}` and
`compactMax_continuous.{u_1, u_2}`.

The repaired matcher separates the exact base name from an optional, strictly
validated list of universe parameter identifiers. It preserves the entire printed
signature for review. Adjacent checks cover indentation, wrapping after a name,
multiline types, missing/duplicate records and malformed suffixes. No theorem-type
normalization is introduced; controller-produced full signatures remain compared
exactly by context validation. Type changes cannot disappear through name parsing.

Regression coverage includes bare/single/multiple/generated universes, ordinary
names, comma whitespace, actual N02 and accepted historical fixtures, malformed
lists, wrong namespaces/names, arbitrary suffixes, type preservation and dispatch
ordering. Existing freeze tests retain all comparisons and now recognize the
explicitly authorized N01–N04 status transitions; N05 onward remain frozen.
The complete mocked suite is run without model calls; results are recorded with
this repair's runtime evidence.

Before edits, all submission hashes and 24 original attempt evidence files were
recorded under `tmp_orchestration/stage07a/signature_repair/receipt.json`.
The guarded reconciliation verifies those hashes and the unchanged N01 acceptance,
requires a separate infrastructure-only commit, and resumes the existing attempt
at deterministic verification. It neither reruns Sol nor escalates reasoning.
N02 remains invocation 1, Sol Medium, zero substantive revisions. Parser repair
itself makes zero model calls. Review results will be recorded by the normal
independent review workflow after corrected REVIEW_CONTEXT_COMPLETE validation.

Validation: 343 mocked orchestration tests passed (31.263 seconds), including all
315 pre-existing tests and 28 new tests. Submission hash comparison passed. N02's
full audit signature exactly equals its probe signature, including the universe
suffix and complete theorem type. `git diff --check` passed.
