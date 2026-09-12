# Milestone report: 01 / primitives and budget normalization

Status: **REVIEW_READY**, pending external mathematical/economic/Lean review.
Assigned scope: Phases A/B acceptance and baseline, then `prompts/01_primitives.md` only.

M00_BASE: `858fcf8e5214e6d52eb9abb274fcaf55b5ae09ce`.
Baseline commit: `Accept Aiyagari Milestone 00 bootstrap`.
Lean: `leanprover/lean4:v4.32.0`.
Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`.
Date: 2026-09-11 (M00 external acceptance date; execution follows that decision).

## Accepted predecessor and permanent conventions

`reviews/00_acceptance.md` records the user's externally supplied ACCEPT/GREEN decision, reviewed archive SHA-256 and all four qualifications. The bootstrap metadata and readable ledger reflect that acceptance. At M00_BASE all 57 economic contracts were UNFORMALIZED; the acceptance promoted no economics.

`AGENTS.md` permanently requires automatic review ZIP creation in `tmp_zip/` after every milestone, with its exclusions, complete predecessor diff and SHA-256. `.gitignore` ignores that directory. Both were included in M00_BASE before any M01 Lean module was implemented. M00 probe/full/direct-audit/contract/document checks were rerun; evidence is in `reports/logs/00_acceptance/`. The baseline commit contains only this project, with no source PDFs, input ZIPs, build caches, temporary renders, review archives or unrelated project files.

## Results against the contracts

| Contract | Actual declaration and module | Status |
|---|---|---|
| P01 | `Aiyagari1994.shifted_budget_iff`; `Aiyagari1994/Budget/Normalization.lean` | REVIEW_READY |
| P02 | `Aiyagari1994.effectiveLimit_admissible_continuous`; `Aiyagari1994/Budget/EffectiveLimit.lean` | REVIEW_READY |
| P03 | `Aiyagari1994.corePrimitives_nonempty`; `Aiyagari1994/Primitives/Examples.lean` | REVIEW_READY |

P01 proves the budget equality and borrowing inequality as explicit equivalent conjuncts, with separate helpers and a next-resource identity. It assumes no economic premises because the algebra is valid for all real inputs. Original prices store net return only; gross return is derived as one plus net return.

P02 proves finite-cap nonnegativity, effective-income admissibility, joint (w,r) continuity for fixed cap/floor, an explicit locally constant neighborhood at zero, and the separate natural-cap nonnegativity/intercept/income/positive-rate-continuity statements. It constructs admissible prices in the shared structures. The generated-resource helper proves nonnegativity for any nonnegative shifted choice. Its only scalar economic assumptions are the nonnegative cap, positive labor floor and wage, labor above the floor, and the stated branch rate conditions.

P03 constructs the exact beta=1/2, R=1, w=1, b=0 witness in the general HouseholdPrimitives type, with all CoreRegularity properties proved. Utility is c/(1+c), restricted to nonnegative consumption for the base properties; both derivatives and the risk-aversion bound are proved. The labor law has half mass at 1/2 and 3/2, exact two-point support, positive endpoint-neighborhood mass and mean one. Assets remain continuous. Generic finite IID history laws have probability normalization, coordinate marginals, independence and a one-step product decomposition. The existential theorem assumes none of those conclusions.

All 54 other economic contracts retain exactly their baseline statements, assumptions, dependencies, scope and UNFORMALIZED statuses. M00 remains GREEN. No M01 declaration is GREEN. No H01/Bellman work or milestone 02 was started.

## Proof route and local adaptations

The actual readable proofs, exact elaborated signatures, integrability obligations, source locators and axiom output are synchronized in `docs/proof_ledger.md`, `.tex` and `.pdf`. The complete explicit declaration inventory is `reports/01_declarations.json`.

The finite-cap continuity proof uses the proved identity phi = b*(w*lo)/max(w*lo,b*r), whose denominator is strictly positive. A separate neighborhood proof explicitly obtains b <= w'*lo/r' at nearby positive rates. No division by b occurs. The natural branch is kept independent and no continuity through its zero-rate singularity is claimed.

Utility strict increase/concavity follow from first/second derivatives on the interior plus continuity at zero. A local equality of the first derivative with its rational formula justifies the second differentiation. UtilitySmooth and UtilityCurvature are separate from base utility; the eventual bound M is an arbitrary finite real exactly as authorized. All real labor integrals have integrability proofs before evaluation.

Library imports were narrowed to the installed modules used by the proof. The installed derivative power API uses `HasDerivAt.fun_pow` for a function-valued power. No dependency pin, mathematical assumption or contract conclusion changed to solve an elaboration issue. Preliminary failed development logs are retained as `*_attempt*.log`; they are not success evidence.

## Verification evidence

Commands ran from the repository root. Final successful build/audit logs end with the actual exit status. Three logs with emitted trailing whitespace were consolidated without changing diagnostics; see `reports/logs/01/log_provenance.md`.

- Fresh targeted builds: `lake build Aiyagari1994.Primitives.Basic Aiyagari1994.Budget.Normalization Aiyagari1994.Budget.EffectiveLimit Aiyagari1994.Primitives.UtilityExample Aiyagari1994.Primitives.IncomeExample Aiyagari1994.Primitives.Examples`; exit 0, all six substantive modules freshly built. Log: `reports/logs/01/targeted_build.log`.
- `lake build`; exit 0, root/All/Audit included. Log: `reports/logs/01/full_build.log`.
- `lake env lean Audit.lean`; exit 0. Log: `reports/logs/01/audit.log`. It checks all 77 new explicit declarations and the 24 M00 declarations, and prints all twelve primitive structures.
- All 101 `assert_no_sorry` commands passed. This command is silent on success; the consolidated names/results are `reports/logs/01/assert_no_sorry.log`.
- All transitive axiom lists contain only `propext`, `Classical.choice` and `Quot.sound`; raw and consolidated output: `audit.log` and `transitive_axioms.log`.
- `lake env lean Probes/M01Signatures.lean`; exit 0. Exact P01/P02/P03 signatures and axiom outputs: `reports/logs/01/contract_signatures.log`.
- Prohibited-placeholder/bypass scan, baseline assumption/pin comparison and unchanged-contract comparison passed: `reports/logs/01/prohibited_patterns.log`.
- `python3 tools/check_contracts.py`; exit 0: `reports/logs/01/contracts.log`.
- `git diff --check` and checks on every new text file: `reports/logs/01/git_diff_check.log`.
- `bash tools/build_docs.sh proof_ledger`; exit 0 after stable latexmk rebuilds: `reports/logs/01/docs_build.log`. PDF visual checks: `reports/logs/01/pdf_qa.md`.

No release-GREEN checker was run: it is not an M01 success criterion. There are no numerical tests or numerical outputs. Every required M01 build/audit/check was run; paper-level adequacy awaits the external reviewer.

## Adequacy audit and remaining work

See `reports/01_structural_audit.md` for the manual inspection of all primitive fields and their correspondence to authorized profiles. Zero-state utility behavior is unrestricted in the general model. The witness's real utility formulas do not concern the economic value marginal. No absorbing interval, uniform tightness, mixing, invariant law, asset supply or equilibrium conclusion is assumed.

No blocker remains for P01, P02 or P03. Main qualifications: the algebraic normalization does not certify No-Ponzi equivalence; finite-cap continuity keeps b and lo fixed while varying wages/rates; the natural debt limit is treated only on positive rates; IID results are finite-history constructions; P03 is a consistency witness rather than an optimization or equilibrium result. These are the approved scope boundaries, not replacement assumptions.

## Review transfer and stop

The automatic review archive is:

`/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2/tmp_zip/review_m01.zip`

Its exact SHA-256 is reported after packing in the adjacent ignored `review_m01_receipt.md` and the final response. A ZIP cannot contain its own final hash without a self-reference; the enclosed report and substantive sources are finalized before packing. The archive file listing follows below and is checked against the completed ZIP. `git_diff.txt` includes the full binary-capable diff from M00_BASE plus complete additions for untracked M01 files; no intent-to-add or M01 commit is needed to include them.

Stopped after M01 review preparation. Milestone 02 has not begun.

## Verified archive file listing

```text
.gitignore
AGENTS.md
Aiyagari1994.lean
Aiyagari1994/Budget/EffectiveLimit.lean
Aiyagari1994/Budget/Normalization.lean
Aiyagari1994/Primitives/Basic.lean
Aiyagari1994/Primitives/Examples.lean
Aiyagari1994/Primitives/IncomeExample.lean
Aiyagari1994/Primitives/UtilityExample.lean
All.lean
Audit.lean
Probes/ApiSignatures.lean
Probes/Core.lean
Probes/M01Signatures.lean
contracts/assumptions.json
contracts/source_manifest.json
contracts/theorems.json
docs/BUILD.md
docs/architecture.md
docs/header.tex
docs/lean_interfaces.md
docs/ledger_header.tex
docs/proof_ledger.md
docs/proof_ledger.pdf
docs/proof_ledger.tex
git_diff.txt
lake-manifest.json
lakefile.toml
lean-toolchain
reports/00_api_inventory.md
reports/00_dependencies.json
reports/00_environment.md
reports/00_sources.md
reports/01_artifact_sha256.json
reports/01_declarations.json
reports/01_milestone.md
reports/01_structural_audit.md
reports/M00_BASE
reports/logs/00_acceptance/audit.log
reports/logs/00_acceptance/contracts.log
reports/logs/00_acceptance/docs.log
reports/logs/00_acceptance/full.log
reports/logs/00_acceptance/probes.log
reports/logs/00_acceptance/verification.md
reports/logs/01/assert_no_sorry.log
reports/logs/01/audit.log
reports/logs/01/basic_attempt.log
reports/logs/01/contract_signatures.log
reports/logs/01/contracts.log
reports/logs/01/docs_build.log
reports/logs/01/examples_attempt.log
reports/logs/01/examples_attempt2.log
reports/logs/01/examples_attempt3.log
reports/logs/01/examples_attempt4.log
reports/logs/01/examples_attempt5.log
reports/logs/01/full_build.log
reports/logs/01/git_diff_check.log
reports/logs/01/limits_attempt.log
reports/logs/01/limits_attempt2.log
reports/logs/01/log_provenance.md
reports/logs/01/pdf_qa.md
reports/logs/01/pdf_render.log
reports/logs/01/primitives_attempt.log
reports/logs/01/prohibited_patterns.log
reports/logs/01/targeted_build.log
reports/logs/01/transitive_axioms.log
reports/logs/01/utility_attempt.log
reviews/00_acceptance.md
tools/build_docs.sh
```
