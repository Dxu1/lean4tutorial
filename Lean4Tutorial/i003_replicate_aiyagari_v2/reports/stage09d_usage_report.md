# Stage-09d usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M09D1/G06 | 1 / medium | 1 | 0 | 0 | 3188443 | 2990080 | 198363 | 21676 | 5107 |
| M09D2/G07 | 1 / medium | 1 | 0 | 0 | 6648427 | 6370816 | 277611 | 27404 | 5629 |
| M09D3/G08 | 1 / medium | 1 | 0 | 0 | 4975664 | 4720000 | 255664 | 28956 | 6752 |

Workflow totals:

```json
{
  "input_tokens": 14812534,
  "cached_input_tokens": 14080896,
  "cache_write_input_tokens": 0,
  "output_tokens": 78036,
  "reasoning_output_tokens": 17488,
  "uncached_input_tokens": 731638,
  "cached_input_share_percent": 95.06068306746165
}
```

New usage since context reconciliation:

```json
{
  "input_tokens": 12279786,
  "cached_input_tokens": 11671296,
  "cache_write_input_tokens": 0,
  "output_tokens": 63829,
  "reasoning_output_tokens": 13289,
  "uncached_input_tokens": 608490,
  "cached_input_share_percent": 95.04478335371643
}
```

Preserved original G06 Medium usage:

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
  },
  {
    "gate": "M09D1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 12669,
    "packaged_context_bytes": 2415637,
    "packaged_context_files": 113,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09D2",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 6694,
    "gate_capsule_bytes": 12798,
    "packaged_context_bytes": 750628,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09D2",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 12798,
    "packaged_context_bytes": 2424798,
    "packaged_context_files": 112,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09D3",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 6694,
    "gate_capsule_bytes": 12812,
    "packaged_context_bytes": 760050,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09D3",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 12812,
    "packaged_context_bytes": 2450141,
    "packaged_context_files": 115,
    "source_evidence_bytes": 633616
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
