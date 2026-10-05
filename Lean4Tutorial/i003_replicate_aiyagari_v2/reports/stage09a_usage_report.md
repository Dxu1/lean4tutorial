# Stage-09a usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M09A1/F01 | 1 / medium | 1 | 0 | 0 | 12285777 | 11994240 | 291537 | 48121 | 11875 |
| M09A2/G01 | 1 / medium | 1 | 0 | 0 | 2855358 | 2610560 | 244798 | 25803 | 5237 |
| M09A3/F02 | 1 / medium | 1 | 0 | 0 | 6353304 | 6107776 | 245528 | 31298 | 5377 |

Workflow totals:

```json
{
  "input_tokens": 21494439,
  "cached_input_tokens": 20712576,
  "cache_write_input_tokens": 0,
  "output_tokens": 105222,
  "reasoning_output_tokens": 22489,
  "uncached_input_tokens": 781863,
  "cached_input_share_percent": 96.36248706002516
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
    "gate": "M09A1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 5268,
    "gate_capsule_bytes": 13507,
    "packaged_context_bytes": 646326,
    "packaged_context_files": 5,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09A1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 13507,
    "packaged_context_bytes": 1560591,
    "packaged_context_files": 36,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09A2",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 5268,
    "gate_capsule_bytes": 9794,
    "packaged_context_bytes": 713965,
    "packaged_context_files": 10,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09A2",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 9794,
    "packaged_context_bytes": 1997902,
    "packaged_context_files": 84,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09A3",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 5268,
    "gate_capsule_bytes": 10280,
    "packaged_context_bytes": 702451,
    "packaged_context_files": 8,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09A3",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 10280,
    "packaged_context_bytes": 1964807,
    "packaged_context_files": 79,
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

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-09a runtime. Stage 04 and Stage 09a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.

G01 derived-overview repair used zero model calls and preserved its original Medium invocation. New usage since resumption is recorded separately in stage09a_resumption_usage.json.

## New usage since G01 ledger reconciliation

Three real calls: G01 Astra High, F02 Sol Medium, F02 Astra High. The ledger repair itself used zero model calls. The original G01 Medium invocation remains counted once in full-stage totals. Every field below was emitted for all three new calls.

```json
{
  "input_tokens": 6998018,
  "cached_input_tokens": 6670208,
  "output_tokens": 39214,
  "reasoning_output_tokens": 6950,
  "cache_write_input_tokens": 0,
  "uncached_input_tokens": 327810,
  "cached_input_share_percent": 95.31567366645812
}
```
