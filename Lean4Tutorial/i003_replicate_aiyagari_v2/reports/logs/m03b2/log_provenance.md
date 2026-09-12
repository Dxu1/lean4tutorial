# M03B2 log provenance

All final logs in this directory were generated in the existing pinned local environment on
2026-09-12 after the H10 implementation and manifest/ledger synchronization. No network,
external model, dependency update, staging, commit, orchestration edit, or manual review archive
was used.

`targeted_build.log`, `full_build.log`, `audit.log`, `signatures.log`, `contracts.log`, and
`docs_build.log` are direct command outputs. `assert_no_sorry.log` inventories the new M03B2
assertions executed by direct `Audit.lean`. `transitive_axioms.log` is extracted from that audit.
`prohibited_patterns.log` records the comment- and string-stripped project-wide Lean scan.
`verified_sources.sha256`, `git_diff_check.log`, `pdf_render.log`, and `pdf_qa.md` record the
remaining deterministic checks.

The two untracked files shown one directory above this project pre-existed this run and were not
read, changed, packaged, or otherwise used.
