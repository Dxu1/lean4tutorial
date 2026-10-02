# Stage-08 usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M08A/B01 | 1 / medium | 1 | 0 | 0 | 6500259 | 6270336 | 229923 | 29078 | 6249 |
| M08B/B02 | 1 / medium | 1 | 0 | 0 | 14812465 | 14410496 | 401969 | 47080 | 9630 |
| M08C/B03 | 2 / medium,high | 2 | 1 | 1 | 13051963 | 12408576 | 643387 | 80558 | 17880 |

Workflow totals:

```json
{
  "input_tokens": 34364687,
  "cached_input_tokens": 33089408,
  "cache_write_input_tokens": 0,
  "output_tokens": 156716,
  "reasoning_output_tokens": 33759,
  "uncached_input_tokens": 1275279,
  "cached_input_share_percent": 96.28898409579578
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
    "gate": "M08A",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4331,
    "gate_capsule_bytes": 8826,
    "packaged_context_bytes": 612154,
    "packaged_context_files": 5,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M08A",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4402,
    "gate_capsule_bytes": 8826,
    "packaged_context_bytes": 851675,
    "packaged_context_files": 26,
    "source_evidence_bytes": 88400
  },
  {
    "gate": "M08B",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4331,
    "gate_capsule_bytes": 9611,
    "packaged_context_bytes": 682525,
    "packaged_context_files": 9,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M08B",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4402,
    "gate_capsule_bytes": 9611,
    "packaged_context_bytes": 1970294,
    "packaged_context_files": 73,
    "source_evidence_bytes": 712627
  },
  {
    "gate": "M08C",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4331,
    "gate_capsule_bytes": 8052,
    "packaged_context_bytes": 678168,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M08C",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "high",
    "invocation_number": 2,
    "substantive_revision_number": 1,
    "prompt_characters": 5462,
    "gate_capsule_bytes": 8052,
    "packaged_context_bytes": 678168,
    "packaged_context_files": 7,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M08C",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4402,
    "gate_capsule_bytes": 8052,
    "packaged_context_bytes": 5584758,
    "packaged_context_files": 71,
    "source_evidence_bytes": 4334427
  },
  {
    "gate": "M08C",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 2,
    "substantive_revision_number": 1,
    "prompt_characters": 4402,
    "gate_capsule_bytes": 8052,
    "packaged_context_bytes": 5595031,
    "packaged_context_files": 71,
    "source_evidence_bytes": 4334427
  },
  {
    "gate": "M08C",
    "role": "reviewer_xhigh",
    "model": "gpt-6-astra",
    "reasoning_effort": "xhigh",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4402,
    "gate_capsule_bytes": 8052,
    "packaged_context_bytes": 5584758,
    "packaged_context_files": 71,
    "source_evidence_bytes": 4334427
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

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-08 runtime. Stage 04 and Stage 08 share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.

B03 initial High and independent XHigh both returned REVISE for missing eventual-impatience tail coverage. Sol High substantive revision 1 repaired that scope; a fresh High review returned PASS/HIGH. B01 and B02 passed their initial High reviews. All nine invocations emitted all five tracked token fields.
