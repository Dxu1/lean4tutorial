# Stage-07a usage report

Exact installed Codex CLI fields only. Cached input and reasoning output overlap their parent categories; they are not added again. Null means unavailable, never estimated. Availability smoke calls are separate.

| Gate | Executor calls/effort | High calls | XHigh? | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| M07A1/N01 | 1 / medium | 1 | False | 0 | 14550089 | 14227584 | 322505 | 41095 | 7620 |
| M07A2/N02 | 1 / medium | 2 | False | 0 | 7270352 | 6797184 | 473168 | 51639 | 10703 |
| M07A3/N03 | 1 / medium | 1 | False | 0 | 6622846 | 6360960 | 261886 | 35041 | 7984 |
| M07A4/N04 | 1 / medium | 1 | False | 0 | 12542796 | 12223744 | 319052 | 49344 | 9062 |

Workflow totals:

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

Average uncached input per gate: 344152.75.

Calls and review outcomes:

```json
{
  "executor_calls": 4,
  "high_calls": 5,
  "xhigh_calls": 0,
  "clean_high_acceptances": 4,
  "gates_requiring_xhigh": 0,
  "gates_requiring_executor_escalation": 0,
  "substantive_revisions": 0,
  "schema_retries": 1
}
```

Per-gate uncached-input averages and exact context sizes:

```json
[
  {
    "gate": "M07A1",
    "average_uncached_input_per_invocation": 161252.5,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2527,
        "gate_capsule_bytes": 6218,
        "packaged_context_bytes": 496934,
        "packaged_context_files": 9,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 6218,
        "packaged_context_bytes": 1487944,
        "packaged_context_files": 44,
        "source_evidence_bytes": 720140
      }
    ]
  },
  {
    "gate": "M07A2",
    "average_uncached_input_per_invocation": 157722.66666666666,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2527,
        "gate_capsule_bytes": 6243,
        "packaged_context_bytes": 487300,
        "packaged_context_files": 5,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 6243,
        "packaged_context_bytes": 1354065,
        "packaged_context_files": 26,
        "source_evidence_bytes": 720140
      },
      {
        "role": "reviewer_high",
        "invocation_number": 2,
        "prompt_characters": 4488,
        "gate_capsule_bytes": 6243,
        "packaged_context_bytes": 1354065,
        "packaged_context_files": 26,
        "source_evidence_bytes": 720140
      }
    ]
  },
  {
    "gate": "M07A3",
    "average_uncached_input_per_invocation": 130943.0,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2527,
        "gate_capsule_bytes": 6732,
        "packaged_context_bytes": 581641,
        "packaged_context_files": 9,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 6732,
        "packaged_context_bytes": 5206649,
        "packaged_context_files": 46,
        "source_evidence_bytes": 4345719
      }
    ]
  },
  {
    "gate": "M07A4",
    "average_uncached_input_per_invocation": 159526.0,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 2527,
        "gate_capsule_bytes": 6289,
        "packaged_context_bytes": 593528,
        "packaged_context_files": 9,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4403,
        "gate_capsule_bytes": 6289,
        "packaged_context_bytes": 1776438,
        "packaged_context_files": 62,
        "source_evidence_bytes": 720140
      }
    ]
  }
]
```

Preflight availability calls (separate from mathematical workflow):

```json
{
  "input_tokens": 12983,
  "cached_input_tokens": 10624,
  "cache_write_input_tokens": 0,
  "output_tokens": 10,
  "reasoning_output_tokens": 0,
  "uncached_input_tokens": 2359,
  "cached_input_share_percent": 81.83008549641839
}
```

Totals including preflight:

```json
{
  "input_tokens": 40999066,
  "cached_input_tokens": 39620096,
  "cache_write_input_tokens": 0,
  "output_tokens": 177129,
  "reasoning_output_tokens": 35369,
  "uncached_input_tokens": 1378970,
  "cached_input_share_percent": 96.63658191628073
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

Since the N02 parser repair (original N02 executor excluded):

```json
{
  "model_invocations": 6,
  "infrastructure_model_calls": 0,
  "totals": {
    "input_tokens": 19920185,
    "cached_input_tokens": 19220480,
    "cache_write_input_tokens": 0,
    "output_tokens": 103503,
    "reasoning_output_tokens": 20650,
    "uncached_input_tokens": 699705,
    "cached_input_share_percent": 96.48745732030099
  },
  "selection": "N02 fresh reviews and all N03/N04 workflow calls; excludes original N01 calls and original N02 executor."
}
```
