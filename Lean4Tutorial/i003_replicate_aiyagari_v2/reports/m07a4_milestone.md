# Milestone report: M07A4 / N04 critical stationary consumption constancy

Date: 2026-09-27. Assigned gate: M07A4. Assigned contract: N04 only. Accepted baseline from the
capsule: `2b4ee1a784ace7fc3c1a210e0425a5c388922b77`.

## Result

N04, `Aiyagari1994.critical_stationary_consumption_constant` in
`Aiyagari1994/Stationary/CriticalConsumption.lean`: **REVIEW_READY**. Under BASIC, SMOOTH,
NONDEGENERATE, a supplied invariant law, and `beta*R=1`, it proves stationary one-step
consumption equality and endpoint equality under every finite kernel power. It assumes neither a
stationary marginal moment nor bounded support of the candidate law.

Only N04's contract status changed. No GREEN status or later-contract advancement is awarded.

## Proof route

N01 supplies almost-everywhere finiteness, positivity, conditional integrability, and H09's real
critical superharmonic inequality. The gate-local bounded-Jensen helper preserves those
almost-everywhere premises and obtains one-step equality of finite marginal placeholders using
only bounded stationary integrals. The consumption bridge uses H11 at positive consumption and a
separate retained-saving comparison at zero consumption, preserving `zeroRightMarginal` as the
economic zero-state marginal. A generic invariant-kernel induction lifts adjacent equality to
every finite horizon.

The target and three new public helpers are audited. See
`reports/m07a4_analytical_audit.md` for the detailed mathematical and scope audit.

## Verification and review request

The targeted implementation and `Probes.M07A4Signatures` built successfully with 2,708 jobs. The
signature probe reports transitive axioms exactly `propext`, `Classical.choice`, and `Quot.sound`
for all four new exports. The final `lake build` completed successfully with 2,887 jobs, including
`All` and `Audit`; the audit contains 530 `assert_no_sorry` commands. Reported linter warnings are
in inherited files, not the M07A4 sources.

`python3 tools/check_contracts.py` passed for 57 contracts and an acyclic dependency graph, with
status counts 32 GREEN, 1 REVIEW_READY, and 24 UNFORMALIZED. The contract diff changes only N04's
`status` field. The source-only prohibited-pattern scan and `git diff --check` passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 61-page Markdown/TeX/PDF ledger.
Rendered pages 51--53 were visually inspected: the complete N04 entry is legible with no clipping,
overlap, broken glyph, or bad section transition, and N05--N07 remain UNFORMALIZED. The PDF SHA-256
is `49088f97eebeca553a9289b4406436900fc19e24b3899ce562ac726fc47daa22`.

The controller owns verification logs, export inventories, evidence, and review archives; none
are created or edited here. Independent adequacy review is requested for N04 only. Stop at
REVIEW_READY; do not execute N05--N07, Stage 07b, Stage 08, or any later gate.
