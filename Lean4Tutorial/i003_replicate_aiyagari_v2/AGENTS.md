# Aiyagari theory replication: repository instructions

## Authority and scope

The user has assigned mathematical design to the Pro reviewer and implementation to Codex. The approved authority is `docs/architecture.md`, `contracts/theorems.json`, `contracts/assumptions.json`, and the current milestone prompt. Start by reading them. Execute **only the explicitly assigned milestone**; stop at its review gate. Do not start later phases autonomously.

This is a clean, theory-only Lean 4 project. No economic Python code, numerical solver, asset grid, calibration, table replication or numerical certificate. Python may extract approved sources, check metadata, or build documentation. Continuous assets and a general compactly supported iid income law are the core model. Finite labor support is allowed for exact consistency witnesses, not as a replacement theorem family.

## Source boundaries

Only extract the exact source-paper members listed in `contracts/source_manifest.json`. Never inspect, import, copy, summarize, or search the failed Aiyagari implementation or its generated theory/proof/audit documents. The approved MP formatting conventions are already represented by this package; its code is not an economic proof dependency. Do not redistribute the user's source PDFs in release archives.

Read the specified source pages, not the entire 593-page SLP book. PDF equations and scans must be checked visually; do not guess from garbled extraction. Record printed and PDF page numbers separately. External theorem text is not a Lean proof: formalize its needed mathematics or import a proved theorem from the pinned Mathlib checkout.

## Non-negotiable mathematics

- Construct the canonical value and savings policy from primitive utility, income and prices. `A(z)` means shifted next assets; net assets are `A(z)-phi`.
- Bellman construction is for every `R>0`. Do not put `beta*R<1` in the household primitive type or equilibrium definition.
- Never assume policy monotonicity, an absorbing bound, mixing, invariant existence/uniqueness, asset-supply continuity/divergence, or an excess-demand sign in a paper-level theorem.
- General analytic lemmas may assume their mathematical hypotheses. Economic wrappers must prove those hypotheses from primitives.
- A fixed point needs lifetime verification against all measurable nonanticipative feasible plans.
- No real-valued integral represents an expected economic quantity without its integrability theorem. Use extended nonnegative integrals for potentially infinite marginal values before proving finiteness.
- Weak convergence does not give unbounded moment convergence. Respect the common-compact interior argument and tightness-only critical-boundary argument.
- The right marginal of value need not equal marginal utility at a zero-consumption corner. Do not assume strictly positive consumption when `beta*R>=1`.
- Nonexistence of stationary laws, divergence of stationary means, and almost-sure pathwise divergence are distinct targets.
- Inada plus zero minimum income does not by itself give never-binding savings; certify the exact diagnostic before calling the source note corrected.
- No-Ponzi means a finite nonnegative discounted wealth limit here, not a zero limit.
- Gross saving is `delta*K/f(K)`. Stationary net saving is zero.

## Proof and tooling discipline

Pin a mutually compatible Lean toolchain and Mathlib commit in milestone 00. Record the actual versions and exact declarations used. Moving web documentation is a locator, not an installed API guarantee. Never downgrade/change dependencies mid-proof without a report.

No `sorry`, `admit`, project `axiom`, `native_decide`, `Lean.ofReduceBool`, unsafe proof bypass, or unproved closure record in completed modules. Kernel-checked tactics such as `simp`, `ring`, `linarith`, and `norm_num` are permitted. Standard `propext`, `Classical.choice`, and `Quot.sound` are not defects. Audit all transitive axioms; a new axiom is a blocker, not a workaround.

Classical choice may select an object only after a proved existence theorem. Keep unfinished mathematical targets in the manifest, not as placeholders in compiled Lean. `All.lean` imports completed substantive modules only. `Audit.lean` checks every exported contract declaration with `#check`, `assert_no_sorry`, and `#print axioms`.

A declaration name, helper lemma, local proof organization or API implementation may change when semantically equivalent and documented. Economic assumptions, quantifiers, conclusion strength, probability interpretation or state-space coverage may not change without a design review. Do not use impossible assumptions to obtain vacuous proofs.

## Documentation and gates

Update the proof ledger with exact declaration names, mathematical statements, all transitive economic assumptions, source locators, readable proofs, and axiom output. Proposed arguments remain labeled proposed until checked. A script checking labels or dependencies is not a proof of economic adequacy.

Statuses: `UNFORMALIZED`, `IN_PROGRESS`, `KERNEL_CHECKED`, `REVIEW_READY`, `GREEN`, `BLOCKED`. Codex can move an entry to `REVIEW_READY` after a build. Only an explicit accepted Pro/user adequacy review authorizes `GREEN`; record it in `reviews/`. Never self-award green because a build passes.

Every milestone returns the report specified in `reports/MILESTONE_REPORT_TEMPLATE.md`, build logs and a synchronized readable PDF. If blocked, preserve completed correct lemmas, write `reports/BLOCKER_TEMPLATE.md`'s requested details, and stop that target without weakening it. Complete independent assigned targets where possible; do not hide omissions.

## Milestone review archives

The repository root is `/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2`.
All milestone review archives must be written inside its `tmp_zip/` directory.
Create the directory if absent; never put review ZIPs at the repository root.

For milestone NN, after all implementation, documentation, builds, audits and verification,
automatically create `tmp_zip/review_mNN.zip` before stopping for review (M01: `review_m01.zip`,
M02: `review_m02.zip`, M05: `review_m05.zip`). This is mandatory even when the milestone prompt
omits it. A review-gate identifier may include a lowercase suffix: M02A uses
`tmp_zip/review_m02a.zip`; M02B uses `tmp_zip/review_m02b.zip`. The same packing,
exclusion, SHA-256 and untracked-file rules apply.
Creating the archive must not modify substantive source files.

Include all substantive Lean files created or modified, affected primitive/assumption/equilibrium
structures, All.lean, Audit.lean, milestone and relevant environment/build/audit reports, raw or
consolidated build logs, assert_no_sorry results, prohibited-pattern/bypass checks, transitive
#print axioms output, theorem/contract manifest changes, synchronized proof-ledger Markdown,
TeX and PDF, the complete git diff from the accepted previous-milestone baseline, and any blocker
reports needed for external mathematical, economic and Lean review.

Exclude .lake/, compiled Lean artifacts, source-paper PDFs, input ZIP archives, previous review
ZIPs, TeX auxiliary files, .DS_Store, __MACOSX, and numerical artifacts unrelated to this theory-only
project. Keep tmp_zip/ and all its contents untracked and ignored by git. Preserve this directory
convention in documentation. After creating the archive, report its exact absolute path and SHA-256.
