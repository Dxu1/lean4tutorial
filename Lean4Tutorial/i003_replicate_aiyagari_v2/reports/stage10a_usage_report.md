# Stage-10a usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M10A1/NP01 | 1 / medium | 0 | 0 | 0 | 4065537 | 3916800 | 148737 | 22311 | 5993 |

Workflow totals:

```json
{
  "input_tokens": 4065537,
  "cached_input_tokens": 3916800,
  "cache_write_input_tokens": 0,
  "output_tokens": 22311,
  "reasoning_output_tokens": 5993,
  "uncached_input_tokens": 148737,
  "cached_input_share_percent": 96.34151650815132
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
    "gate": "M10A1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7202,
    "gate_capsule_bytes": 12550,
    "packaged_context_bytes": 757432,
    "packaged_context_files": 6,
    "source_evidence_bytes": 0
  }
]
```

Availability calls:

```json
{
  "input_tokens": 14407,
  "cached_input_tokens": 6144,
  "cache_write_input_tokens": 0,
  "output_tokens": 10,
  "reasoning_output_tokens": 0,
  "uncached_input_tokens": 8263,
  "cached_input_share_percent": 42.64593600333171
}
```

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-10a runtime. Stage 09 and Stage 10a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.

All invocations including the one availability-only Astra smoke call:

```json
{
  "input_tokens": 4079944,
  "cached_input_tokens": 3922944,
  "uncached_input_tokens": 157000,
  "output_tokens": 22321,
  "reasoning_output_tokens": 5993,
  "cache_write_input_tokens": 0,
  "cached_input_share_percent": 96.15190796736425
}
```
