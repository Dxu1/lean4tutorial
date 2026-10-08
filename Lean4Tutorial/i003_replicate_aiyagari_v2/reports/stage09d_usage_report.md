# Stage-09d usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M09D1/G06 | 1 / medium | 0 | 0 | 0 | 2532748 | 2409600 | 123148 | 14207 | 4199 |

Workflow totals:

```json
{
  "input_tokens": 2532748,
  "cached_input_tokens": 2409600,
  "cache_write_input_tokens": 0,
  "output_tokens": 14207,
  "reasoning_output_tokens": 4199,
  "uncached_input_tokens": 123148,
  "cached_input_share_percent": 95.13777130610704
}
```

Coverage:

```json
{
  "input_tokens": {
    "reported": 1,
    "invocations": 1
  },
  "cached_input_tokens": {
    "reported": 1,
    "invocations": 1
  },
  "cache_write_input_tokens": {
    "reported": 1,
    "invocations": 1
  },
  "output_tokens": {
    "reported": 1,
    "invocations": 1
  },
  "reasoning_output_tokens": {
    "reported": 1,
    "invocations": 1
  }
}
```

Calls and review outcomes:

```json
{
  "executor_calls": 1,
  "high_calls": 0,
  "xhigh_calls": 0,
  "clean_high_pass_gates": 0,
  "gates_requiring_executor_escalation": 0,
  "substantive_revisions": 0
}
```

Context sizes:

```json
[
  {
    "gate": "M09D1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 6694,
    "gate_capsule_bytes": 12669,
    "packaged_context_bytes": 749073,
    "packaged_context_files": 8,
    "source_evidence_bytes": 0
  }
]
```

Availability calls:

```json
{
  "input_tokens": null,
  "cached_input_tokens": null,
  "cache_write_input_tokens": null,
  "output_tokens": null,
  "reasoning_output_tokens": null,
  "uncached_input_tokens": null,
  "cached_input_share_percent": null
}
```

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-09d runtime. Stage 04 and Stage 09a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.
