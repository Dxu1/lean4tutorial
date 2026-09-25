# Stage-04 usage report

Exact token values below are emitted by installed Codex CLI `turn.completed.usage`; context bytes and characters are proxies, not token estimates. Cached-input and reasoning-output fields may overlap their parent categories and are not added to them. Availability smokes are listed separately.

| Gate | Executor effort/calls | Reviewer High calls | XHigh used? | Revisions | Actual input tokens | Actual output / reasoning-output tokens | Executor context bytes | Review snapshot bytes |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: |
| M04A/H06 | medium / 1 | 1 | False | 0 | 11085292 | 49043 / 9690 | 76510 | 4362150 |
| M04B/D02 | medium / 1 | 2 | False | 0 | 4027593 | 33911 / 5083 | 91377 | 3958224 |
| M04C/D03 | medium / 1 | 1 | False | 0 | 9589231 | 45776 / 9572 | 151354 | 4092859 |

## Exact per-invocation fields

| Invocation | input_tokens | cached_input_tokens | cache_write_input_tokens | output_tokens | reasoning_output_tokens |
| --- | ---: | ---: | ---: | ---: | ---: |
| M04A/executor_001 | 10581818 | 10296960 | 0 | 40303 | 8696 |
| M04A/reviewer_high_001 | 503474 | 429568 | 0 | 8740 | 994 |
| M04B/executor_001 | 3312746 | 3202560 | 0 | 17433 | 3305 |
| M04B/reviewer_high_001 | 280638 | 222080 | 0 | 7935 | 862 |
| M04B/reviewer_high_002 | 434209 | 375168 | 0 | 8543 | 916 |
| M04C/executor_001 | 8764320 | 8575104 | 0 | 35956 | 8231 |
| M04C/reviewer_high_001 | 824911 | 729088 | 0 | 9820 | 1341 |
| PREFLIGHT/reviewer_high_001 | 12975 | 0 | 0 | 10 | 0 |

## Totals and comparison

Stage-04 mathematical-workflow model invocations: 7; availability smoke calls: 1.

- `input_tokens`: 24,702,116; emitted by 7/7 workflow calls.
- `cached_input_tokens`: 23,830,528; emitted by 7/7 workflow calls.
- `cache_write_input_tokens`: 0; emitted by 7/7 workflow calls.
- `output_tokens`: 128,730; emitted by 7/7 workflow calls.
- `reasoning_output_tokens`: 24,345; emitted by 7/7 workflow calls.

Historical H12 snapshot: 10,667,489 bytes/418 files; optimized reconstruction: 4,359,707 bytes/38 files. H12 executor prompt: 94,412 → 1,450 characters; reviewer prompt: 6,321 → 4,402 characters.

These measurements show smaller default context packages and identify review-call savings when High suffices. Different theorem difficulty, tool use, cache behavior, schema retries and connection recovery prevent attributing an exact token-saving percentage to the refactor. The historical optimized H12 reconstruction did not invoke a model, so there is no comparable exact old/new H12 token experiment.

Per-invocation JSON includes prompt lengths, capsule/context/source bytes, cache use, timestamps, exact raw usage fields, reconnect counts and schema validation results. No API billing, web-UI scraping, token estimation or extra model calls were used to obtain measurements.

All three gates obtained valid High PASS/HIGH decisions; XHigh was avoided on all three. Each executor ran once at Medium, with zero substantive revisions or effort escalation. D02 required one schema retry because the first PASS omitted an applicability explanation. Its executor also recovered from three native CLI reconnection events within the same invocation. D03 required a generated-ledger overview correction before review; mathematical files and contracts were byte-preserved, and fresh checks ran before the immutable review snapshot was created. This repair invoked no model.
