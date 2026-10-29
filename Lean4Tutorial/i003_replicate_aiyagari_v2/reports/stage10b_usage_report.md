# Stage-10b usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M10B1/E01 | 1 / medium | 1 | 0 | 0 | 8608941 | 8338176 | 270765 | 32638 | 6291 |
| M10B2/E02 | 1 / medium | 1 | 0 | 0 | 8218468 | 7986176 | 232292 | 34922 | 6566 |
| M10B3/E03 | 2 / medium,high | 2 | 1 | 1 | 25470612 | 24659328 | 811284 | 107440 | 26607 |

Workflow totals:

```json
{
  "input_tokens": 42298021,
  "cached_input_tokens": 40983680,
  "cache_write_input_tokens": 0,
  "output_tokens": 175000,
  "reasoning_output_tokens": 39464,
  "uncached_input_tokens": 1314341,
  "cached_input_share_percent": 96.89266549846387
}
```

New usage after parser repair:

```json
{
  "input_tokens": 34421847,
  "cached_input_tokens": 33291776,
  "cache_write_input_tokens": 0,
  "output_tokens": 148616,
  "reasoning_output_tokens": 33459,
  "uncached_input_tokens": 1130071,
  "cached_input_share_percent": 96.71699487828181
}
```

New usage after header/suffix repair:

```json
{
  "input_tokens": 26227843,
  "cached_input_tokens": 25328896,
  "cache_write_input_tokens": 0,
  "output_tokens": 114810,
  "reasoning_output_tokens": 27339,
  "uncached_input_tokens": 898947,
  "cached_input_share_percent": 96.57254696850214
}
```

New review usage after probe repair:

```json
{
  "input_tokens": 2240728,
  "cached_input_tokens": 1935744,
  "cache_write_input_tokens": 0,
  "output_tokens": 27388,
  "reasoning_output_tokens": 6494,
  "uncached_input_tokens": 304984,
  "cached_input_share_percent": 86.38906641055942
}
```

New review usage after revision probe repair:

```json
{
  "input_tokens": 766834,
  "cached_input_tokens": 634112,
  "cache_write_input_tokens": 0,
  "output_tokens": 7544,
  "reasoning_output_tokens": 782,
  "uncached_input_tokens": 132722,
  "cached_input_share_percent": 82.69221239538153
}
```

Coverage:

```json
{
  "input_tokens": {
    "reported": 9,
    "invocations": 9
  },
  "cached_input_tokens": {
    "reported": 9,
    "invocations": 9
  },
  "cache_write_input_tokens": {
    "reported": 9,
    "invocations": 9
  },
  "output_tokens": {
    "reported": 9,
    "invocations": 9
  },
  "reasoning_output_tokens": {
    "reported": 9,
    "invocations": 9
  }
}
```

Calls and review outcomes:

```json
{
  "executor_calls": 4,
  "high_calls": 4,
  "xhigh_calls": 1,
  "clean_high_pass_gates": 2,
  "gates_requiring_executor_escalation": 1,
  "substantive_revisions": 1
}
```

Context sizes:

```json
[
  {
    "gate": "M10B1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 8124,
    "gate_capsule_bytes": 14070,
    "packaged_context_bytes": 851565,
    "packaged_context_files": 10,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M10B1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 14070,
    "packaged_context_bytes": 6897736,
    "packaged_context_files": 116,
    "source_evidence_bytes": 4982599
  },
  {
    "gate": "M10B2",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 8124,
    "gate_capsule_bytes": 13404,
    "packaged_context_bytes": 825510,
    "packaged_context_files": 9,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M10B2",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13404,
    "packaged_context_bytes": 6901414,
    "packaged_context_files": 116,
    "source_evidence_bytes": 4982599
  },
  {
    "gate": "M10B3",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 8124,
    "gate_capsule_bytes": 13655,
    "packaged_context_bytes": 801220,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M10B3",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "high",
    "invocation_number": 2,
    "substantive_revision_number": 1,
    "prompt_characters": 9581,
    "gate_capsule_bytes": 13655,
    "packaged_context_bytes": 801220,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M10B3",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13655,
    "packaged_context_bytes": 6247813,
    "packaged_context_files": 38,
    "source_evidence_bytes": 4957685
  },
  {
    "gate": "M10B3",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 2,
    "substantive_revision_number": 1,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13655,
    "packaged_context_bytes": 6334704,
    "packaged_context_files": 38,
    "source_evidence_bytes": 4957685
  },
  {
    "gate": "M10B3",
    "role": "reviewer_xhigh",
    "model": "gpt-6-astra",
    "reasoning_effort": "xhigh",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13655,
    "packaged_context_bytes": 6247813,
    "packaged_context_files": 38,
    "source_evidence_bytes": 4957685
  }
]
```

Availability calls:

```json
{
  "input_tokens": 14311,
  "cached_input_tokens": 12032,
  "cache_write_input_tokens": 0,
  "output_tokens": 10,
  "reasoning_output_tokens": 0,
  "uncached_input_tokens": 2279,
  "cached_input_share_percent": 84.0751869191531
}
```

All invocations including availability:

```json
{
  "input_tokens": 42312332,
  "cached_input_tokens": 40995712,
  "cache_write_input_tokens": 0,
  "output_tokens": 175010,
  "reasoning_output_tokens": 39464,
  "uncached_input_tokens": 1316620,
  "cached_input_share_percent": 96.88833033357746
}
```

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-10b runtime. Stage 10a and Stage 10b share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.
