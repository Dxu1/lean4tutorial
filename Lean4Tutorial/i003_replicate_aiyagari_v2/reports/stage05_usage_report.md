# Stage-05 usage report

Exact installed Codex CLI fields only. Cached input and reasoning output overlap their parent categories; they are not added again. Preflight availability calls are separate.

| Gate | Executor calls/effort | High calls | XHigh? | Revisions | Input | Cached input | Output | Reasoning | Context bytes (executor/reviewer) |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | --- |
| M05A/S01 | 1 / medium | 1 | False | 0 | 7643128 | 7374976 | 36675 | 5998 | 147079 / 4042628 |
| M05B/S02 | 1 / medium | 1 | False | 0 | 7353470 | 7001344 | 42962 | 6536 | 178594 / 4129103 |
| M05C/S03 | 1 / medium | 1 | False | 0 | 7866527 | 7583104 | 42014 | 8587 | 255365 / 4190031 |
| M05D/S04 | 1 / medium | 1 | True | 0 | 23001262 | 22549888 | 83777 | 22015 | 226622 / 499109,499109 |
| M05E/S05 | 1 / medium | 1 | False | 0 | 30209057 | 29749248 | 85397 | 17665 | 348233 / 4581312 |

Totals (workflow calls only):

```json
{
  "input_tokens": 76073444,
  "cached_input_tokens": 74258560,
  "cache_write_input_tokens": 0,
  "output_tokens": 290825,
  "reasoning_output_tokens": 60801,
  "uncached_input_tokens": 1814884,
  "cached_input_share_percent": 97.6143002017892
}
```

Model calls: 11. Full per-invocation metadata and exact raw usage extracts are in the JSON. Null means not emitted by the installed CLI or invocation still running. No calls were triggered for measurement.

Stage 04 used seven workflow calls, 24,702,116 input tokens, 23,830,528 cached input tokens, and 128,730 output tokens. Theorem difficulty, proof-tool iterations and retries differ between stages; this comparison is descriptive and does not establish a causal token-saving percentage.

All five gates used exactly one Sol Medium executor, with zero substantive revisions or executor escalation. Four gates received clean initial Astra High PASS/HIGH decisions. M05D High requested REVISE; fresh independent XHigh on the same immutable snapshot returned operative PASS/HIGH. S04's accepted qualification required the S03-to-S04 test-function crossing bridge in S05, which S05 subsequently proved and its reviewer accepted. Both S04 verdicts remain in the durable evidence.

There were 11 workflow calls: five executors, five High reviewers and one XHigh adjudicator. Stage 04 had seven calls across three gates; Stage 05 had five gates and substantial generic stability and full-state transport proofs. These differences prevent a causal efficiency comparison. Reported input cache share was 97.6143002017892%; input minus cached input was 1,814,884 tokens. No unavailable token total has been estimated.

Infrastructure repairs did not trigger new model calls or effort escalation: generated ledger overviews for M05A/M05C/M05E; the SLP abbreviated-locator validator; and one trailing blank line in the M05E signature probe. Hash-bound receipts preserve scope and execution history.
