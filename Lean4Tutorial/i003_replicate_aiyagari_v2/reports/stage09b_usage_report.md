# Stage-09b usage report

Exact installed Codex CLI telemetry only. Null means unavailable, never zero or estimated. Totals sum only emitted fields; coverage counts are recorded in the JSON. Cached input and reasoning output overlap their parent categories and are not added again.

| Gate | Executor calls/effort | High calls | XHigh calls | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| M09B1/G02 | 3 / medium,medium,high | 2 | 1 | 1 | 12000858 | 11357440 | 643418 | 68281 | 16731 |
| M09B2/G03 | 1 / medium | 1 | 0 | 0 | 9300276 | 8989952 | 310324 | 33684 | 5633 |

Workflow totals:

```json
{
  "input_tokens": 21301134,
  "cached_input_tokens": 20347392,
  "cache_write_input_tokens": 0,
  "output_tokens": 101965,
  "reasoning_output_tokens": 22364,
  "uncached_input_tokens": 953742,
  "cached_input_share_percent": 95.52257640367878
}
```

Coverage:

```json
{
  "input_tokens": {
    "reported": 7,
    "invocations": 8
  },
  "cached_input_tokens": {
    "reported": 7,
    "invocations": 8
  },
  "cache_write_input_tokens": {
    "reported": 7,
    "invocations": 8
  },
  "output_tokens": {
    "reported": 7,
    "invocations": 8
  },
  "reasoning_output_tokens": {
    "reported": 7,
    "invocations": 8
  }
}
```

Calls and review outcomes:

```json
{
  "executor_calls": 4,
  "high_calls": 3,
  "xhigh_calls": 1,
  "clean_high_pass_gates": 1,
  "gates_requiring_executor_escalation": 1,
  "substantive_revisions": 1
}
```

Context sizes:

```json
[
  {
    "gate": "M09B1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 5929,
    "gate_capsule_bytes": 11046,
    "packaged_context_bytes": 729970,
    "packaged_context_files": 10,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09B1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 2,
    "substantive_revision_number": 0,
    "prompt_characters": 5929,
    "gate_capsule_bytes": 11046,
    "packaged_context_bytes": 729970,
    "packaged_context_files": 10,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09B1",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "high",
    "invocation_number": 3,
    "substantive_revision_number": 1,
    "prompt_characters": 7397,
    "gate_capsule_bytes": 11046,
    "packaged_context_bytes": 729970,
    "packaged_context_files": 10,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09B1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 11046,
    "packaged_context_bytes": 2094297,
    "packaged_context_files": 92,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09B1",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 2,
    "substantive_revision_number": 1,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 11046,
    "packaged_context_bytes": 2099720,
    "packaged_context_files": 92,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09B1",
    "role": "reviewer_xhigh",
    "model": "gpt-6-astra",
    "reasoning_effort": "xhigh",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 11046,
    "packaged_context_bytes": 2094297,
    "packaged_context_files": 92,
    "source_evidence_bytes": 633616
  },
  {
    "gate": "M09B2",
    "role": "executor",
    "model": "gpt-5.6-sol",
    "reasoning_effort": "medium",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 5929,
    "gate_capsule_bytes": 9417,
    "packaged_context_bytes": 744481,
    "packaged_context_files": 11,
    "source_evidence_bytes": 0
  },
  {
    "gate": "M09B2",
    "role": "reviewer_high",
    "model": "gpt-6-astra",
    "reasoning_effort": "high",
    "invocation_number": 1,
    "substantive_revision_number": 0,
    "prompt_characters": 4403,
    "gate_capsule_bytes": 9417,
    "packaged_context_bytes": 5761262,
    "packaged_context_files": 94,
    "source_evidence_bytes": 4252089
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

No additional calls were triggered to measure usage. All raw invocation evidence remains in the isolated Stage-09b runtime. Stage 04 and Stage 09a share compact gate contexts and exact telemetry; different theorem complexity and tool iterations prevent a causal token-savings comparison.

Since import reconciliation (new invocations only; repair itself used zero real model calls):

```json
{
  "invocations": [
    {
      "actual_usage": {
        "cache_write_input_tokens": 0,
        "cached_input_tokens": 882944,
        "input_tokens": 989952,
        "output_tokens": 7887,
        "reasoning_output_tokens": 897
      },
      "availability": "emitted by installed Codex CLI",
      "cached_accepted_interfaces_used": true,
      "events": [
        {
          "type": "turn.completed",
          "usage": {
            "cache_write_input_tokens": 0,
            "cached_input_tokens": 882944,
            "input_tokens": 989952,
            "output_tokens": 7887,
            "reasoning_output_tokens": 897
          }
        }
      ],
      "exit_code": 0,
      "finished_at": "2026-10-07T14:18:07.715781+00:00",
      "gate": "M09B2",
      "gate_capsule_bytes": 9417,
      "interface_cache_hits": {
        "A03": true,
        "B02": true,
        "B03": true,
        "F01": true,
        "G01": true,
        "P02": true
      },
      "invocation_number": 1,
      "malformed_jsonl_lines": 0,
      "model": "gpt-6-astra",
      "packaged_context_bytes": 5761262,
      "packaged_context_files": 94,
      "prompt_bytes": 4407,
      "prompt_characters": 4403,
      "raw_events_path": "/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2/tmp_orchestration/stage09b/runs/M09B2/attempt_001/reviewer_10ca55c2c8a8_initial_1/reviewer_events.jsonl",
      "raw_events_sha256": "64b98df13cfd24dee309df610c0e22ea96294924eb15bb86e00df1f0fe206c4d",
      "reasoning_effort": "high",
      "role": "reviewer_high",
      "source_evidence_bytes": 4252089,
      "stage": "09",
      "started_at": "2026-10-07T14:12:17.662794+00:00",
      "substantive_revision_number": 0
    }
  ],
  "totals": {
    "input_tokens": 989952,
    "cached_input_tokens": 882944,
    "cache_write_input_tokens": 0,
    "output_tokens": 7887,
    "reasoning_output_tokens": 897,
    "uncached_input_tokens": 107008,
    "cached_input_share_percent": 89.19058701836049
  },
  "coverage": {
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
  },
  "infrastructure_real_model_calls": 0,
  "original_G03_medium_duplicated": false
}
```
