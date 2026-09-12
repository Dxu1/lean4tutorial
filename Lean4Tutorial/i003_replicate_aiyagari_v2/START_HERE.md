# First Codex message

Unzip this package into a clean project directory and make the two original input archives available locally. Then paste the following into Codex:

```text
This directory contains the approved Aiyagari (1993/1994) theory-only Lean execution package.

Read AGENTS.md, README.md, docs/architecture.md, docs/lean_interfaces.md,
and the contracts relevant to the current milestone.

Execute prompts/00_bootstrap.md only. Resolve the actual local paths to
citations.zip and i003_replicate_aiyagari.zip, and use the supplied whitelist
extractor. Do not inspect the failed Aiyagari implementation or its proof
summaries. Do not implement a numerical model.

Set up and pin the Lean/Mathlib environment, compile the API probes, and
return the environment/source/API report and build evidence. Do not change
mathematical assumptions, self-award GREEN status, or continue to milestone 01.
Stop for the requested review.
```

After milestone 00 is accepted, the first mathematical implementation prompt is `prompts/01_primitives.md`. The later prompts are in `prompts/INDEX.md`. Execute one milestone at a time, bringing its report and changed files back for review.
