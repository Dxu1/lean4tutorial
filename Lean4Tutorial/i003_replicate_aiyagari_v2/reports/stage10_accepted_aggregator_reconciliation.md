# Stage-10 accepted root-aggregator provenance repair

Classification: `POST_ACCEPTANCE_ROOT_AGGREGATOR_PROVENANCE_REPLAY_ERROR`.

Integration called the active-candidate delta detector after E03 acceptance advanced the controller baseline to 074e9d70b7ef3b70d5839b77a14156fe403b92c7. Both baseline and current All.lean already contain `Aiyagari1994.Extensions.GovernmentDebt`. Thus C → C had no new import, while the active-gate path still required the historical authorized B → C addition. The unchanged reviewed E03 certificate already establishes that historical delta.

The accepted path now validates every hash-bound reviewed aggregator certificate, historical baseline/candidate blobs, authorized import list/order, commit ancestry and contiguous chain, historical kernel fingerprints and approved axioms, final current aggregator hash, and the current project graph for reverse imports/cycles. It verifies current Lean files against committed HEAD. Accepted gates use this path; unaccepted gates retain the original strict candidate detector, and the pre-executor path is unchanged. Missing or altered records, extra imports, ancestry breaks and graph defects fail closed.

No mathematical source, All.lean, Audit.lean, accepted reviewer/acceptance record, frozen manifest, assumption profile or proof-ledger artifact was modified. No executor/reviewer/model call and no substantive revision is consumed. The recovery entry point rechecks receipt/state/source/runtime hashes and calls full Stage-10 integration directly; it never enters a model-dispatch or availability-preflight loop. Fresh integration also builds all six Stage-10 target modules explicitly before their signature probes.

| Gate | Historical baseline commit | Accepted commit | Baseline All SHA-256 | Candidate All SHA-256 |
|---|---|---|---|---|
| M10A1 | `e6547268b34592a55e838b48e5267e59ba5478c3` | `29a54a6f86d0f69538e4a2e67ede00b46639d558` | `c4657eedfad73fb6960bd66de67fb8a237eb767aca4811d615b5f9b1206c4a82` | `6b93c48ff9e4c7a0d1076dce6b77ece436da8958f18f3b7bb722fcf7d75b09b5` |
| M10B1 | `0551b87fd82604719e8e611cb81daa75a49e5916` | `a070cfc574abc1fbd6fdabe735784cc173b938ae` | `6b93c48ff9e4c7a0d1076dce6b77ece436da8958f18f3b7bb722fcf7d75b09b5` | `841ded09d7255480ff1357db3e2e3f62d62b86869f7566666c4251ade2ccbfb6` |
| M10B3 | `0b34c91c26287a8774f9229678b1eefa35bb0f48` | `074e9d70b7ef3b70d5839b77a14156fe403b92c7` | `841ded09d7255480ff1357db3e2e3f62d62b86869f7566666c4251ade2ccbfb6` | `516a05b0beb63b807e096404af71fbc5166f5dc8f70f0bcd401e2d05642294d6` |

The final current All.lean SHA-256 is `516a05b0beb63b807e096404af71fbc5166f5dc8f70f0bcd401e2d05642294d6`, exactly the terminal accepted candidate. All 57 contracts remain GREEN. E03 remains revision 1 with operative Astra High PASS/HIGH. Final release audit is not authorized.

Regression validation: 922 tests run, 920 PASS, 2 historical SKIP. The 28 new tests cover accepted replay, sequential chains, missing/altered records, ancestry/order/hash errors, unauthorized imports, graph defects, unchanged candidate behavior and frozen accepted state. The complete existing mocked suite is retained. No real model calls.
