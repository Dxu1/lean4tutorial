# Stage-09c usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M09C1/A04 | 1 / medium | 1 | 0 | 0 | 9841290 | 9524608 | 316682 | 37485 | 8590 |
| M09C2/A05 | 1 / medium | 1 | 0 | 0 | 4660327 | 4387584 | 272743 | 33300 | 7090 |
| M09C3/G04 | 1 / medium | 1 | 0 | 0 | 3638089 | 3391872 | 246217 | 23501 | 5880 |
| M09C4/G05 | 1 / medium | 1 | 0 | 0 | 10234979 | 9923840 | 311139 | 47643 | 11926 |

Workflow totals:

```json
{
  "input_tokens": 28374685,
  "cached_input_tokens": 27227904,
  "cache_write_input_tokens": 0,
  "output_tokens": 141929,
  "reasoning_output_tokens": 33486,
  "uncached_input_tokens": 1146781,
  "cached_input_share_percent": 95.95843619056916
}
```

Coverage:

```json
{
  "input_tokens": {
    "reported": 8,
    "invocations": 8
  },
  "cached_input_tokens": {
    "reported": 8,
    "invocations": 8
  },
  "cache_write_input_tokens": {
    "reported": 8,
    "invocations": 8
  },
  "output_tokens": {
    "reported": 8,
    "invocations": 8
  },
  "reasoning_output_tokens": {
    "reported": 8,
    "invocations": 8
  }
}
```

Calls and review outcomes:

```json
{
  "executor_calls": 4,
  "high_calls": 4,
  "xhigh_calls": 0,
  "clean_high_pass_gates": 4,
  "gates_requiring_executor_escalation": 0,
  "substantive_revisions": 0
}
```

Context sizes:

```json
[
  {
    "gate": "M09C1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7613,
    "gate_capsule_bytes": 14097,
    "packaged_context_bytes": 732806,
    "packaged_context_files": 9,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09C1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 14097,
    "packaged_context_bytes": 5488242,
    "packaged_context_files": 51,
    "source_evidence_bytes": 4288195
  },
  {
    "gate": "M09C2",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7613,
    "gate_capsule_bytes": 14933,
    "packaged_context_bytes": 758584,
    "packaged_context_files": 9,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09C2",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 14933,
    "packaged_context_bytes": 2310240,
    "packaged_context_files": 95,
    "source_evidence_bytes": 662616
  },
  {
    "gate": "M09C3",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7613,
    "gate_capsule_bytes": 13710,
    "packaged_context_bytes": 724877,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09C3",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13710,
    "packaged_context_bytes": 5876528,
    "packaged_context_files": 100,
    "source_evidence_bytes": 4259195
  },
  {
    "gate": "M09C4",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 7613,
    "gate_capsule_bytes": 13432,
    "packaged_context_bytes": 733977,
    "packaged_context_files": 8,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09C4",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13432,
    "packaged_context_bytes": 2413122,
    "packaged_context_files": 109,
    "source_evidence_bytes": 633616
  }
]
```

Availability calls:

```json
{
  "input_tokens": 13631,
  "cached_input_tokens": 0,
  "cache_write_input_tokens": 0,
  "output_tokens": 10,
  "reasoning_output_tokens": 0,
  "uncached_input_tokens": 13631,
  "cached_input_share_percent": 0.0
}
```

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-09c runtime. Stage 04 and Stage 09a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.

Integration-provenance infrastructure repair: zero executor calls, zero reviewer calls, zero substantive revisions. All previously emitted usage totals and model event hashes remain unchanged.
