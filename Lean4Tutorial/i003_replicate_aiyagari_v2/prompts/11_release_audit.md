# Milestone 11: release audit

Recommended reasoning: **High**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Every required core contract has an accepted implementation review; diagnostic corrections must be certified before being described as established.

**Contract IDs:** Environment and source verification only; no economic theorem claimed.

## Final release is an audit, not a theorem-repair phase

Read the entire source-coverage manifest. The release label is **core stationary theory, continuous assets / iid income / bounded utility**. Do not call the result a proof for log/CRRA, persistent labor, every source footnote, all extensions, or the numerical paper. Do not solve an audit failure by deleting a target or relabeling it out of scope without approval.

Perform a clean rebuild from the pinned dependency files. Ensure `All.lean` imports every completed substantive module, and the root package exports them. `Audit.lean` must check every contracted declaration and inspect transitive axioms. Inspect actual project theorem signatures for hidden impossible assumptions, arbitrary behavior functions, conclusion-containing records, implicit invariant-law premises and circular rate restrictions. Confirm the consistency witness still instantiates the actual core primitives.

Check the full theorem DAG and actual import graph. No missing-foundation theorem may sit in a transitive proof path. Include every exported helper's relevant assumptions/axioms where needed; a bare main-theorem `#check` is not enough. Prohibit `sorryAx`, project axioms, `native_decide`/`Lean.ofReduceBool` or unsafe proof bypasses in the accepted dependency chain. Explain permitted standard Lean foundations accurately.

Synchronize the human-readable ledger: exact statement and Lean declaration; source passage locator; primitives and every additional hypothesis; actual readable proof; dependence on generic mathematical lemmas; source-fidelity qualification; status and review evidence. Distinguish a corrected source statement from a literal reproduction. Every certified source correction needs its own verified witness/argument. Deferred claims remain visible in the coverage appendix.

Generate a clean readable PDF modeled on the reference's proof-ledger conventions. Compile and visually inspect all pages, especially long equations, tables, theorem headings and monospace declaration names. Check that the mathematical prose matches the elaborated Lean signature, not just a preimplementation plan.

Run `python3 tools/check_contracts.py --release core`. To claim the exact extension layer too, additionally run `--release extended`. These are structural gate checks only; retain the independent adequacy reviews.

Create a release ZIP containing source Lean, dependency locks, documentation source/PDF, manifests, build/audit evidence and review records. Exclude caches, private source PDFs, old failed-project files, font files and numerical code. The manifest should record the exact audited git commit. Return the final theorem coverage table and all remaining deferred items. No amber or closure-assumed item may be presented as a completed core theorem.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
