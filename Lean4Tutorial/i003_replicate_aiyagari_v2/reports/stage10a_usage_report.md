# Stage-10a usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M10A1/NP01 | 1 / medium | 1 | 0 | 0 | 4416655 | 4212352 | 204303 | 27458 | 6603 |
| M10A2/NP02 | 1 / medium | 1 | 0 | 0 | 8308286 | 8042496 | 265790 | 33569 | 7740 |
| M10A3/NP03 | 1 / medium | 1 | 0 | 0 | 14935788 | 14578176 | 357612 | 54935 | 12728 |

Workflow totals:

```json
{
  "input_tokens": 27660729,
  "cached_input_tokens": 26833024,
  "cache_write_input_tokens": 0,
  "output_tokens": 115962,
  "reasoning_output_tokens": 27071,
  "uncached_input_tokens": 827705,
  "cached_input_share_percent": 97.00765297978951
}
```

Coverage:

```json
{
  "input_tokens": {
    "reported": 6,
    "invocations": 6
  },
  "cached_input_tokens": {
    "reported": 6,
    "invocations": 6
  },
  "cache_write_input_tokens": {
    "reported": 6,
    "invocations": 6
  },
  "output_tokens": {
    "reported": 6,
    "invocations": 6
  },
  "reasoning_output_tokens": {
    "reported": 6,
    "invocations": 6
  }
}
```

Calls and review outcomes:

```json
{
  "executor_calls": 3,
  "high_calls": 3,
  "xhigh_calls": 0,
  "clean_high_pass_gates": 3,
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
  },
  {
    "gate": "M10A3",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7202,
    "gate_capsule_bytes": 13125,
    "packaged_context_bytes": 779631,
    "packaged_context_files": 6,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M10A3",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4404,
    "gate_capsule_bytes": 13125,
    "packaged_context_bytes": 5130358,
    "packaged_context_files": 39,
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
  "input_tokens": 27675136,
  "cached_input_tokens": 26839168,
  "cache_write_input_tokens": 0,
  "output_tokens": 115972,
  "reasoning_output_tokens": 27071,
  "uncached_input_tokens": 835968,
  "cached_input_share_percent": 96.97935359739515
}
```

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-10a runtime. Stage 09 and Stage 10a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.
