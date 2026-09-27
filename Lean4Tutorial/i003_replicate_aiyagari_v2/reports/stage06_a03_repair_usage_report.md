# A03 evidence repair and review usage

The same Sol Medium submission was preserved: one executor invocation, zero substantive revisions. Infrastructure and mocked tests made no model calls. The original Stage-06 usage reports are unchanged. The first blocked evidence reviews and the fresh corrected-snapshot review are separately recorded below; cached and reasoning counts are subsets of their parent categories. No values are estimated.

## Original executor

```json
{
  "input_tokens": 2355336,
  "cached_input_tokens": 2211328,
  "cache_write_input_tokens": 0,
  "output_tokens": 13917,
  "reasoning_output_tokens": 3848,
  "uncached_input_tokens": 144008,
  "cached_input_share_percent": 93.88588294833518
}
```

## Historical blocked reviews

```json
{
  "input_tokens": 2445664,
  "cached_input_tokens": 2197632,
  "cache_write_input_tokens": 0,
  "output_tokens": 30027,
  "reasoning_output_tokens": 4905,
  "uncached_input_tokens": 248032,
  "cached_input_share_percent": 89.8582961518835
}
```

## Fresh corrected-snapshot review

```json
{
  "input_tokens": 768319,
  "cached_input_tokens": 683392,
  "cache_write_input_tokens": 0,
  "output_tokens": 9223,
  "reasoning_output_tokens": 726,
  "uncached_input_tokens": 84927,
  "cached_input_share_percent": 88.94638815387879
}
```

Global overview: 3397 bytes. Snapshot: 5825065 bytes / 69 files. Exact per-invocation prompt/context sizes and usage records are in the JSON. Historical High BLOCK/HIGH and XHigh BLOCK/MEDIUM remain preserved; they do not constitute executor revisions.
