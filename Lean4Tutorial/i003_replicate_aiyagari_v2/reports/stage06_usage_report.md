# Stage-06 usage report

Exact installed Codex CLI fields only. Cached input and reasoning output overlap their parent categories; they are not added again. Null means unavailable, never estimated. Availability smoke calls are separate.

| Gate | Executor calls/effort | High calls | XHigh? | Revisions | Input | Cached | Uncached | Output | Reasoning |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| M06A/S06 | 1 / medium | 1 | False | 0 | 14047880 | 13673216 | 374664 | 53436 | 12119 |
| M06B/A01 | 1 / medium | 1 | False | 0 | 5877242 | 5562880 | 314362 | 34209 | 8778 |
| M06C/A02 | 1 / medium | 1 | False | 0 | 16806330 | 16313472 | 492858 | 55291 | 12035 |
| M06D/A03 | 1 / medium | 1 | True | 0 | 7568895 | 7164928 | 403967 | 60846 | 14706 |

Workflow totals:

```json
{
  "input_tokens": 44300347,
  "cached_input_tokens": 42714496,
  "cache_write_input_tokens": 0,
  "output_tokens": 203782,
  "reasoning_output_tokens": 47638,
  "uncached_input_tokens": 1585851,
  "cached_input_share_percent": 96.4202289431277
}
```

Average uncached input per gate: 396462.75.

Calls and review outcomes:

```json
{
  "executor_calls": 4,
  "high_calls": 4,
  "xhigh_calls": 1,
  "clean_high_acceptances": 3,
  "gates_requiring_xhigh": 1,
  "gates_requiring_executor_escalation": 0,
  "substantive_revisions": 0,
  "schema_retries": 0
}
```

Per-gate uncached-input averages and exact context sizes:

```json
[
  {
    "gate": "M06A",
    "average_uncached_input_per_invocation": 187332.0,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 1450,
        "gate_capsule_bytes": 7520,
        "packaged_context_bytes": 353443,
        "packaged_context_files": 8,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4402,
        "gate_capsule_bytes": 7520,
        "packaged_context_bytes": 4549181,
        "packaged_context_files": 61,
        "source_evidence_bytes": 3701970
      }
    ]
  },
  {
    "gate": "M06B",
    "average_uncached_input_per_invocation": 157181.0,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 1450,
        "gate_capsule_bytes": 7030,
        "packaged_context_bytes": 357467,
        "packaged_context_files": 7,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4402,
        "gate_capsule_bytes": 7030,
        "packaged_context_bytes": 5075436,
        "packaged_context_files": 59,
        "source_evidence_bytes": 4297024
      }
    ]
  },
  {
    "gate": "M06C",
    "average_uncached_input_per_invocation": 246429.0,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 1450,
        "gate_capsule_bytes": 7502,
        "packaged_context_bytes": 420766,
        "packaged_context_files": 7,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4402,
        "gate_capsule_bytes": 7502,
        "packaged_context_bytes": 5241310,
        "packaged_context_files": 66,
        "source_evidence_bytes": 4297024
      }
    ]
  },
  {
    "gate": "M06D",
    "average_uncached_input_per_invocation": 134655.66666666666,
    "invocations": [
      {
        "role": "executor",
        "invocation_number": 1,
        "prompt_characters": 1450,
        "gate_capsule_bytes": 7615,
        "packaged_context_bytes": 500188,
        "packaged_context_files": 9,
        "source_evidence_bytes": 0
      },
      {
        "role": "reviewer_high",
        "invocation_number": 1,
        "prompt_characters": 4402,
        "gate_capsule_bytes": 7615,
        "packaged_context_bytes": 5802009,
        "packaged_context_files": 68,
        "source_evidence_bytes": 4776527
      },
      {
        "role": "reviewer_xhigh",
        "invocation_number": 1,
        "prompt_characters": 4402,
        "gate_capsule_bytes": 7615,
        "packaged_context_bytes": 5802009,
        "packaged_context_files": 68,
        "source_evidence_bytes": 4776527
      }
    ]
  }
]
```

Preflight availability calls (separate from mathematical workflow):

```json
{
  "input_tokens": 12975,
  "cached_input_tokens": 10624,
  "cache_write_input_tokens": 0,
  "output_tokens": 10,
  "reasoning_output_tokens": 0,
  "uncached_input_tokens": 2351,
  "cached_input_share_percent": 81.88053949903662
}
```

Totals including preflight:

```json
{
  "input_tokens": 44313322,
  "cached_input_tokens": 42725120,
  "cache_write_input_tokens": 0,
  "output_tokens": 203792,
  "reasoning_output_tokens": 47638,
  "uncached_input_tokens": 1588202,
  "cached_input_share_percent": 96.41597170259544
}
```

All per-invocation fields and raw usage extracts are in the accompanying JSON. No additional calls were triggered for measurement.

Stage 04 used seven workflow calls, 24,702,116 input tokens, 23,830,528 cached input tokens, and 128,730 output tokens. Stage 05 used eleven workflow calls, 76,073,444 input tokens, 74,258,560 cached input tokens, and 290,825 output tokens. Theorem difficulty, proof-tool iterations and retries differ. These descriptive totals do not establish a causal token-saving percentage.

Review outcomes: M06A, M06B and M06C received clean High PASS. M06D High requested revision over independent debt-coordinate coverage; a fresh XHigh review of the same original snapshot returned PASS and became operative under the authorized policy. Both verdicts and XHigh scope qualifications are preserved in the acceptance evidence. No executor revision was dispatched.

One availability smoke was emitted after the prior cache expired; it was an authentication/capability check, not a measurement-only call. Workflow counts above exclude this smoke; the JSON and totals including preflight include it. Mechanical whitespace, ledger-overview and interrupted-promotion recovery did not trigger new executor or reviewer invocations and did not consume substantive revisions.
