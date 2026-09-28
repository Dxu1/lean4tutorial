# N05: separate parser incident and substantive coverage audit

## Preserved checkpoint

Branch issue3; local baseline 31b36f34f25d0ef7c21f7ce1c24d9d138b6199e6.
Remote at inspection f07b205b9d7889613a07004017ee6f8e02f87cc6. The two local commits
54ec494 and 31b36f3 configure and authorize isolated Stage-07b gates; neither accepts N05.
The original submission, execution identity, evidence and hashes are preserved under
`tmp_orchestration/stage07b/n05_repair/`. Original executor: M07B1/N05, Sol Medium,
invocation 1, completed, zero substantive revisions. No Astra invocation occurred.

## Infrastructure: SIGNATURE_RECORD_BOUNDARY_PARSER_DEFECT

The actual signature log has a declaration header for `Aiyagari1994.M07B1.TwoStringSpace`
at line 2. At line 11 the same name occurs as the indented result type of
`Aiyagari1994.M07B1.twoStringDifference`. Scanning every line independently falsely
counted two declarations. The repair parses and consumes complete pretty-printer
records sequentially before selecting exact names. Continuation text is retained,
including nested constants, binders, universes and arrows. True duplicate records
and malformed/missing records remain errors; type text is never normalized away.

The hash-bound reconciliation permits only committed infrastructure changes, preserves
all mathematical bytes and Medium metadata, and reruns deterministic checks plus context
validation without invoking a model. Parser repair consumes zero substantive revisions.
The separate authorized coverage transition is explicitly USER_COVERAGE_REVISION.

## Mathematics: N05_CONTRACT_COVERAGE_DEFECT — CONFIRMED

Authority: exact N05 statement in contracts/theorems.json, architecture §9.4,
and prompts/07b_critical_nonstationarity.md. No contract semantics or dependency changes.

| Public premise or conclusion | Current Medium implementation | Required coverage |
| --- | --- | --- |
| R > 1; bounded nonconstant iid shocks | nu, shock, B, hbounded, hnonconstant, hR; finite product law | Present |
| Stationary probability pi | pi is only a probability measure; arbitrary endpoint maps Z/Z' supplied | Derive endpoints from the actual stationary one-step resource recursion |
| State-dependent consumption and resource recursion | No c or recursion in public signature | Primitive inputs to the generic theorem |
| Endpoint laws | hlawZ and hlawZ' assume map (Z n) = pi for every n | Derive by finite-horizon induction |
| Discounted telescope | hidentity assumes the a.e. identity for every positive n | Derive by recursion and a.e. consumption cancellation |
| Conclusion | False | Correct conclusion, under materially incomplete input interface |

A. YES: `hidentity` assumes precisely the contracted discounted two-string identity.
B. YES: `hlawZ` and `hlawZ'` assume both terminal pi laws. No helper constructs
resource paths or derives these laws from one-step invariance.
C. The public theorem does NOT assume vanishing second moments, positive variance,
shock-sum moment formula, or tightness as a primitive. `FiniteProduct.lean` proves
measurability, a uniform bound, variance positivity from non-a.e.-constancy, and the
exact second moment by independent product coordinates. `Tightness.lean` proves a
probability NNReal tail bound and a generic second-moment bound. Its generic
`scaled_difference_event_le_two_tails` takes endpoint laws and an identity, which
is legitimate as an estimate only if the public proof first derives those inputs.
The public body combines these estimates into a moment-free contradiction.
D. NO adequate N04 bridge exists yet: the public signature has no consumption-constancy
premise at all. Its comment defers the endpoint and telescoping derivations to the
later household wrapper. N04 certifies a.e. equal consumption under finite stationary
joint laws, not pointwise equality on arbitrary deterministic shock histories.
That missing bridge must be proved in N05, not pushed into N06.

## Authorized substantive revision and review requirements

The initial Medium attempt remains preserved. The user authorizes Sol High as
substantive revision 1 only after parser reconciliation passes. Repair N05 only.
Construct two finite iid shock strings with common initial state of law pi; derive
endpoint pi laws from stationarity of the actual recursion. Transfer N04-compatible
a.e. finite-history equalities to these finite products, intersect the finitely many
full-measure events, and telescope there. Do not strengthen to pointwise constancy.
Keep state moments absent. Derive the shock second-moment formula and positive
variance internally; establish the contracted vanishing second-moment/tightness
argument, not a conclusion-like input. Generic estimates may remain, but a chain
of helpers must actually prove all intermediate bridges from primitive hypotheses.

The repaired analytical audit must explicitly map proof declarations for:
`telescoping identity = derived`, `endpoint pi laws = derived`,
`N04 bridge = a.e.-compatible`, `state moments = absent`.
Fresh independent Astra must inspect the actual public and helper proof bodies,
the finite-event bridge, tightness, variance positivity and attribution. The proof
is a project reconstruction with source motivation, not a literal CW00/A94 theorem.
No N06 before N05 acceptance and no Stage 08. No mathematical adequacy is claimed
by this infrastructure report or by deterministic build success.

## Infrastructure validation

Full mocked orchestration suite: 368 tests PASS (32.240 seconds), no model calls.
The exact preserved signatures.log and audit.log both parse the TwoStringSpace
record once. Regression coverage includes all fifteen requested cases, retaining
existing universe and exact-type validation tests. Mathematical submission hashes
remain unchanged. Raw test output is preserved in the runtime repair directory.
