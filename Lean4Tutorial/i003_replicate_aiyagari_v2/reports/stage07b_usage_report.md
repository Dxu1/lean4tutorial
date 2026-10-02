# Stage-07b usage report

Exact installed Codex CLI fields only. Cached input and reasoning output overlap their parent categories; they are not added again. Null means unavailable, never estimated. Availability smoke calls are separate.

| Gate | Executor calls/effort | High calls | XHigh? | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| M07B1/N05 | 2 / medium,high | 1 | False | 1 | 26655396 | 26045952 | 609444 | 113596 | 32220 |
| M07B2/N06 | 1 / medium | 1 | False | 0 | 3786413 | 3560448 | 225965 | 25224 | 4859 |
| M07B3/N07 | 2 / medium,medium | 1 | False | 0 | None | None | None | None | None |

Workflow totals:

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

Average uncached input per gate: None.

Calls and review outcomes:

```json
{
  "executor_calls": 5,
  "high_calls": 3,
  "xhigh_calls": 0,
  "clean_high_acceptances": 3,
  "gates_requiring_xhigh": 0,
  "gates_requiring_executor_escalation": 1,
  "substantive_revisions": 1,
  "schema_retries": 0
}
```

Per-gate uncached-input averages and exact context sizes:

```json
[
  {
    "gate": "M07B1",
    "average_uncached_input_per_invocation": 203148.0,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2882,
        "gate_capsule_bytes": 32930,
        "packaged_context_bytes": 597275,
        "packaged_context_files": 7,
        "source_evidence_bytes": 0
      },
      {
        "role": "executor",
        "invocation_number": 2,
        "prompt_characters": 9011,
        "gate_capsule_bytes": 39847,
        "packaged_context_bytes": 604192,
        "packaged_context_files": 7,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 39847,
        "packaged_context_bytes": 1596676,
        "packaged_context_files": 31,
        "source_evidence_bytes": 720140
      }
    ]
  },
  {
    "gate": "M07B2",
    "average_uncached_input_per_invocation": 112982.5,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2882,
        "gate_capsule_bytes": 10760,
        "packaged_context_bytes": 656561,
        "packaged_context_files": 10,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 10760,
        "packaged_context_bytes": 5258978,
        "packaged_context_files": 44,
        "source_evidence_bytes": 4345719
      }
    ]
  },
  {
    "gate": "M07B3",
    "average_uncached_input_per_invocation": null,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2882,
        "gate_capsule_bytes": 10729,
        "packaged_context_bytes": 639005,
        "packaged_context_files": 9,
        "source_evidence_bytes": 0
      },
      {
        "role": "executor",
        "invocation_number": 2,
        "prompt_characters": 2882,
        "gate_capsule_bytes": 10729,
        "packaged_context_bytes": 639005,
        "packaged_context_files": 9,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 10729,
        "packaged_context_bytes": 5195185,
        "packaged_context_files": 41,
        "source_evidence_bytes": 4345719
      }
    ]
  }
]
```

Preflight availability calls (separate from mathematical workflow):

```json
{
  "input_tokens": 14447,
  "cached_input_tokens": 0,
  "cache_write_input_tokens": 0,
  "output_tokens": 10,
  "reasoning_output_tokens": 0,
  "uncached_input_tokens": 14447,
  "cached_input_share_percent": 0.0
}
```

Totals including preflight:

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

All per-invocation fields and raw usage extracts are in the accompanying JSON. No additional calls were triggered for measurement.

Stage 04 used seven workflow calls, 24,702,116 input tokens, 23,830,528 cached input tokens, and 128,730 output tokens. Stage 05 used eleven workflow calls, 76,073,444 input tokens, 74,258,560 cached input tokens, and 290,825 output tokens. Theorem difficulty, proof-tool iterations and retries differ. These descriptive totals do not establish a causal token-saving percentage.

Original Stage-06 workflow totals (A03 checkpoint repair separately recorded):

```json
{
  "cache_write_input_tokens": 0,
  "cached_input_share_percent": 96.4202289431277,
  "cached_input_tokens": 42714496,
  "input_tokens": 44300347,
  "output_tokens": 203782,
  "reasoning_output_tokens": 47638,
  "uncached_input_tokens": 1585851
}
```

Differences reflect different contracts, proof difficulty, tool iterations and review outcomes; no causal token-saving claim is made.

Stage-07a workflow totals:

```json
{
  "input_tokens": 40986083,
  "cached_input_tokens": 39609472,
  "cache_write_input_tokens": 0,
  "output_tokens": 177119,
  "reasoning_output_tokens": 35369,
  "uncached_input_tokens": 1376611,
  "cached_input_share_percent": 96.64127211180438
}
```

Comparisons are descriptive; gate difficulty and review retries differ.

Parser infrastructure repair used zero model calls and consumed zero substantive revisions. The preserved N05 Medium attempt and authorized High coverage repair are distinct invocations in the JSON. The coverage defect was confirmed; the High repair was substantive revision 1. Original Medium evidence copies and original attempt files remain hash-valid.

N07 capacity failure occurred before mathematical work, emitted no token counts, and consumed zero substantive revisions. Full workflow totals are unavailable; null is not zero.

Exact subtotal over calls with emitted telemetry:
```json
{
  "covered_invocations": 7,
  "missing_usage_invocations": 1,
  "totals": {
    "input_tokens": 33503725,
    "cached_input_tokens": 32504064,
    "cache_write_input_tokens": 0,
    "output_tokens": 157156,
    "reasoning_output_tokens": 40148,
    "uncached_input_tokens": 999661,
    "cached_input_share_percent": 97.0162690864971
  },
  "complete": false
}
```

New N07 mathematical executor and reviewer usage:
```json
{
  "covered_invocations": 2,
  "missing_usage_invocations": 0,
  "totals": {
    "input_tokens": 3061916,
    "cached_input_tokens": 2897664,
    "cache_write_input_tokens": 0,
    "output_tokens": 18336,
    "reasoning_output_tokens": 3069,
    "uncached_input_tokens": 164252,
    "cached_input_share_percent": 94.63564643837388
  },
  "complete": true
}
```

Acceptance and call history:
- M07B1: 07dd2605ff6fb211d166192cc64c087f885234ca; mathematical executor calls 2; capacity-failed calls 0; substantive revisions 1
- M07B2: 7abd34d6e86d7ae7ebd8bbbdd63f1e1890d522ca; mathematical executor calls 1; capacity-failed calls 0; substantive revisions 0
- M07B3: af621d9fd26f77226b1e27e26ea724753fe9c99b; mathematical executor calls 1; capacity-failed calls 1; substantive revisions 0
