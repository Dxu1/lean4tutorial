# Milestone M03E - zero-income atom nonbinding diagnostic

Date: 2026-09-12. Accepted baseline:
`066c27b9b5f3ce01cd6114c1957c83719914b110`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned scope: H14 only.

## Results against the contract

H14, `Aiyagari1994.zero_income_atom_implies_nonbinding` in
`Aiyagari1994/Household/BorrowingThreshold.lean`: REVIEW_READY. Under BASIC and SMOOTH, with
zero minimum effective income, infinite utility right marginal at zero, and positive probability
of zero effective income, the canonical shifted asset policy is strictly positive at every
positive resource state. No impatience assumption occurs.

An internal H14 step proves that utility Inada forces the separate economic boundary value
marginal `zeroRightMarginal : ENNReal` to be infinite. Accepted
predecessor bodies and statuses are preserved. H06, D01, and all later contracts remain
UNFORMALIZED.

## Proof route and changes

Consuming an entire positive resource increment while keeping shifted saving at zero compares
utility and value secants at the origin. Their accepted ENNReal limit interfaces transfer utility
Inada to an infinite value boundary marginal.

If `A(z)=0`, take a small deviation `a=x/R`. Concavity bounds the finite current utility cost per
unit by the fixed secant between `z/2` and `z`. The continuation-value difference is nonnegative
for every income realization and equals `V(x)-V(0)` on the positive-probability zero-income event.
The resulting lower bound conflicts with a sufficiently large zero-state value secant. This uses
only `beta>0` and `R>0`, not impatience or consumption positivity.

No public API beyond the contracted theorem is added, and no separate helper module is needed.
The theorem is appended to its required shared module. No theorem, assumption, dependency,
quantifier, primitive, pin,
configuration, or contract meaning was weakened or changed.

Semantic files created or changed:

- `Aiyagari1994/Household/BorrowingThreshold.lean`
- `Probes/M03ESignatures.lean`
- `Audit.lean`
- `contracts/theorems.json`
- `docs/proof_ledger.md`, `docs/proof_ledger.tex`, and the rebuilt `docs/proof_ledger.pdf`
- `reports/m03e_signatures.md`, `reports/m03e_analytical_audit.md`, and this report

`All.lean` already imported the required shared module and required no byte change.

## Verification evidence

All required checks completed successfully in the existing pinned environment:

- Targeted build: `lake build Aiyagari1994.Household.BorrowingThreshold
  Probes.M03ESignatures` exited 0 after 2703 jobs.
- Direct signature probe: `lake env lean Probes/M03ESignatures.lean` exited 0. Its elaborated
  signature is reproduced in `reports/m03e_signatures.md` and the proof ledger.
- Full substantive build: `lake build` exited 0 after 2742 jobs.
- Direct audit: `lake env lean Audit.lean` exited 0. The H14 declaration passed `#check` and
  `assert_no_sorry`; `#print axioms` reported exactly `[propext, Classical.choice, Quot.sound]`.
- Contract checker: `python3 tools/check_contracts.py` exited 0 with 57 contracts: 15 GREEN,
  41 UNFORMALIZED, and H14 as the single REVIEW_READY entry.
- Prohibited-pattern scan over the new theorem and signature probe, using `rg --pcre2` for
  `sorry`, `admit`, project `axiom`, `native_decide`, `Lean.ofReduceBool`, and `unsafe`, exited
  with no matches. `git diff --check` exited 0.
- Documentation: `bash tools/build_docs.sh proof_ledger` exited 0 and rebuilt a 44-page PDF.
  The log contains no overfull boxes or undefined references; only historical underfull-box
  warnings remain.
- PDF QA: the title page and affected H14 pages 28--29 were rendered and inspected. Text,
  signatures, equations, status, source locators, and the page break are readable, with no
  clipping, overlap, malformed glyphs, or truncated content. The authorized source pages A93
  PDF p. 39 / printed p. 38 and A94 PDF p. 10 / printed p. 667 were also rendered and inspected.

No required check was skipped. Under the controller-owned mechanical-evidence policy, command
output was kept on stdout; no executor logs or QA notes were written under `reports/logs`.

## Adequacy audit

The state and action spaces remain continuous `NNReal`; labor remains a general compactly
supported probability law. The atom may contain one or multiple labor realizations and no density
or finite-support restriction is assumed. `zeroRightMarginal : ENNReal` is the only economic
zero-state value marginal, and no real expected marginal is constructed. Details and all
carry-forward qualifications are in `reports/m03e_analytical_audit.md`.

A93 Proposition 3 and following note, printed p. 38 / PDF p. 39, and A94's threshold discussion,
printed p. 667 / PDF p. 10, were hash-verified, rendered, and visually inspected. H14 proves the
corrected atom-sufficient statement; it does not certify the unqualified note without an atom.
A successful build does not establish economic adequacy.

## Blockers and review request

No implementation blocker remains. H14 is submitted at REVIEW_READY for independent adequacy
review. No GREEN status is claimed. Stop at M03E; D01 and later gates are not authorized. Per the
orchestrated-run override, no manual review ZIP is created.
