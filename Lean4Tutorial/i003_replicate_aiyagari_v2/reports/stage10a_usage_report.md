# Stage-10a usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M10A1/NP01 | 1 / medium | 1 | 0 | 0 | 4416655 | 4212352 | 204303 | 27458 | 6603 |
| M10A2/NP02 | 1 / medium | 1 | 0 | 0 | 8308286 | 8042496 | 265790 | 33569 | 7740 |

Workflow totals:

```json
{
  "input_tokens": 12724941,
  "cached_input_tokens": 12254848,
  "cache_write_input_tokens": 0,
  "output_tokens": 61027,
  "reasoning_output_tokens": 14343,
  "uncached_input_tokens": 470093,
  "cached_input_share_percent": 96.30573532718148
}
```

Coverage:

```json
{
  "input_tokens": {
    "reported": 4,
    "invocations": 4
  },
  "cached_input_tokens": {
    "reported": 4,
    "invocations": 4
  },
  "cache_write_input_tokens": {
    "reported": 4,
    "invocations": 4
  },
  "output_tokens": {
    "reported": 4,
    "invocations": 4
  },
  "reasoning_output_tokens": {
    "reported": 4,
    "invocations": 4
  }
}
```

Calls and review outcomes:

```json
{
  "executor_calls": 2,
  "high_calls": 2,
  "xhigh_calls": 0,
  "clean_high_pass_gates": 2,
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
  },
  {
    "gate": "M10A1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4404,
    "gate_capsule_bytes": 12550,
    "packaged_context_bytes": 4960633,
    "packaged_context_files": 28,
    "source_evidence_bytes": 3961637
  },
  {
    "gate": "M10A2",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7202,
    "gate_capsule_bytes": 12702,
    "packaged_context_bytes": 766224,
    "packaged_context_files": 6,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M10A2",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4404,
    "gate_capsule_bytes": 12702,
    "packaged_context_bytes": 5057903,
    "packaged_context_files": 35,
    "source_evidence_bytes": 3961637
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

All invocations including availability:

```json
{
  "input_tokens": 12739348,
  "cached_input_tokens": 12260992,
  "cache_write_input_tokens": 0,
  "output_tokens": 61037,
  "reasoning_output_tokens": 14343,
  "uncached_input_tokens": 478356,
  "cached_input_share_percent": 96.24505115960409
}
```

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-10a runtime. Stage 09 and Stage 10a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.
