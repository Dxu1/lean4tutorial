# Post-completion documentation cleanup

## Scope and starting state

Classification: documentation polish and conservative repository hygiene only. The mathematical release remains `fa1c6188837f9f460481868679d3847a12dbb7e9`, verified on local `issue3` and `origin/issue3` before edits. All 57 contracts and the top-level release remain GREEN. No new theorem review, acceptance or mathematical change was performed.

## Files changed

- Repository-root `README.md`: replace the stale minimal-template description with a link to the completed Aiyagari project; distinguish root tutorial setup from the project's environment.
- Project `README.md`: explain scope, grouped results, exclusions, verification, repository layout, sources and mathematical-release provenance.
- `docs/RELEASE_SUMMARY.md`: add a research-oriented summary with the accepted marginal, diagnostic, comparison, No-Ponzi and debt qualifications.
- `docs/THEOREM_INDEX.md`: add 57 short navigation rows with exact declaration names, module links and GREEN statuses. The ledger has no compact contents/index table; this index does not reproduce formal statements.
- `docs/architecture.md`, generated `.tex` and `.pdf`: replace only the obsolete opening implementation-status paragraph; retain the original design and proof plan. Regeneration also reflects nonsemantic Pandoc template changes.
- `docs/lean_interfaces.md`: identify the historical design specification and link to accepted signatures/modules.
- `docs/source_coverage.md`: replace the obsolete UNFORMALIZED opening; retain all deferred/excluded claims.
- `docs/BUILD.md`: clarify the project working directory and completed ledger status.
- Repository-root `.gitignore`: add exact paths for the 36 existing local Aiyagari review/release archives and receipts. No wildcard hides future reports, no artifact was moved or deleted, and all 36 hashes were preserved.
- This cleanup report.

The accepted proof ledger Markdown, TeX and 82-page PDF are byte-for-byte unchanged. Historical prompts, reports, acceptance records and provenance evidence remain unchanged. The project ignore policy already covers `.lake/`, `tmp_zip/`, `tmp_orchestration/`, Python caches and TeX auxiliary files; it needed no additional rules.

## Files removed

Only the ignored project-root `.DS_Store` was removed. Runtime directories, raw audit evidence, review archives, private source inputs, the final release ZIP and its receipt were retained because they may support provenance or reproducibility.

## Preservation and validation

A before/after SHA-256 inventory verified 380 protected files, including all tracked project Lean files, contracts, reviews, Stage-11 evidence, ledger artifacts, environment pins and the 36 outer transfer artifacts. All tracked project Lean bytes also match the frozen mathematical candidate `25b507c7d224c68f4d7d33f9c127bd7272611192`. No theorem statement, assumption, dependency, signature or proof body changed.

| Check | Result |
| --- | --- |
| `lake build` | PASS, 3,224 jobs; existing build tree used for this documentation pass |
| `lake env lean Audit.lean` | PASS; 826 no-sorry checks and axiom outputs |
| Audit/signature preservation | Entire fresh Audit stdout byte-identical to the accepted release output |
| `python3 tools/check_contracts.py` | PASS, 57 GREEN, acyclic contract graph |
| `python3 tools/check_contracts.py --release core` | PASS |
| `python3 tools/check_contracts.py --release extended` | PASS |
| `bash tools/build_docs.sh architecture` | PASS, 16 pages; no overfull/underfull boxes in the build log |
| Architecture visual review | All 16 pages inspected as a contact sheet; updated status page inspected separately |
| Pandoc conversion of README, summary and index | PASS |
| Relative Markdown links and theorem-index rows | Validated against existing paths and all 57 manifest entries |
| `git diff --check` | PASS |

The audited transitive axiom union remains `propext`, `Classical.choice`, `Quot.sound`. The Audit SHA-256 remains `e0e76e56b576ce59dd1fa5bb6266e2ca6f1dc84c36b6b6c944bdb8eebf3ddef2`. No proof-ledger rebuild was needed because its sources and rendered PDF were untouched. Raw maintenance logs and the before/after inventory are retained locally under ignored `tmp/post_completion/`.

The frozen release ZIP SHA-256 remains `8a99f0fc3b186c3413a8ba743ef6c0a8032dc8c7da8cbedf5bf769761f6be769`; the receipt SHA-256 remains `e4bea92607b176e1b33e3e7bf73dbda16354f42e2424ee6f21da83f9805fd642`. No replacement package was created.

## Git publication

Documentation commit and verified push result will be recorded after the normal fast-forward push. No accepted history will be rewritten. The mathematical release SHA above remains the provenance anchor; this cleanup is not a new mathematical release.

## Optional dissemination

No existing tags were found. A tag such as `aiyagari-v1.0` on the mathematical release commit would help readers identify the accepted theorem snapshot, but requires explicit authorization. No tag or GitHub Release was created. A public release announcement or a separate documentation distribution is optional; neither is needed for formalization completion.
