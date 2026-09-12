# Setup verification provenance

Unit tests use mocked models and temporary fixture repositories only. They do not implement H09 or consume model allowance.

The actual controller deterministic-check integration ran against already accepted M03A: RightMarginal target, full project, Audit.lean, M03A signatures, contracts, prohibited patterns, ledger status/documentation and Git sanity. All passed. Recorded log copies strip trailing whitespace only; raw originals remain in ignored tmp_orchestration/integration_m03a_checks. An initial invocation mistakenly wrote raw logs into the project-scoped Git input and stopped on their trailing whitespace; the corrected run used the intended ignored runtime directory and passed.

The first restricted Astra smoke failed before model initialization because the surrounding sandbox blocked Codex local state/app-server access. No model was reached. The authorized host retry ran the same read-only, ephemeral, ChatGPT-only CLI smoke and returned ASTRA_SUBSCRIPTION_OK with exit 0. No API key or direct API call was used. Subsequent preflight checks reused this successful capability smoke and rechecked login status/version.

Dry-run composes M03B1/H09 instructions without invoking either role. All 24 project Lean files and the entire theorem manifest remain byte-identical to the accepted M03A commit. All H09–H14 and D01 statuses remain UNFORMALIZED. No mathematical workflow run command was invoked against this project.
