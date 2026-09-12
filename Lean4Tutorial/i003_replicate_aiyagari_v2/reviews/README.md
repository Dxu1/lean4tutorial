# Review gate

Codex produces `REVIEW_READY`, not `GREEN`. After the Pro/user reviewer accepts a milestone, record the decision in a JSON file in this directory. The record must identify the reviewed git commit, reviewer, accepted contract IDs, evidence paths and material qualifications. It must not be fabricated by Codex.

Example record schema (not an approval):

```json
{
  "accepted": true,
  "reviewer": "name or explicitly identified reviewer",
  "date": "YYYY-MM-DD",
  "git_commit": "actual reviewed commit",
  "contract_ids": ["P01"],
  "evidence": ["reports/01_primitives.md", "reports/01_build.log"],
  "qualifications": "none or explicit scope qualifications"
}
```

A metadata checker can verify that an approval record exists and names the required IDs. It cannot independently authenticate the reviewer or judge the economics; that remains a human/Pro review responsibility. Prompt 00 has an environment-only approval rather than theorem IDs.
