# Milestone M02B — H05 lifetime verification

Date: 2026-09-11. M02A_BASE: `c6cc7477d7a7f6fa396f8a386f36a9e4b25f29ae`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Dependencies remain pinned.
Assigned scope: the user's M02A acceptance and M02B H05 execution request. The accepted baseline was committed as “Accept Aiyagari Milestone 02A Bellman and policy”; acceptance evidence is in `reviews/02a_acceptance.md` and `reports/logs/02a_acceptance/`.

## Results against the contract

H05: `Aiyagari1994.canonicalPolicy_lifetime_optimal`, implemented in `Aiyagari1994/Household/Verification.lean`, is REVIEW_READY. It proves absolute convergence, the upper bound by V(z0), canonical equality and canonical dominance against every feasible measurable full-history plan for every initial resource. The plan contains only actions, measurability and pointwise feasibility. Actions may depend on time and the entire observed history. Resources follow the prior action and newest shock. No current-state factorization is required.

Actual economic assumptions are exactly the existing BASIC primitive profile inherited through H02/H04. IID is constructed by historyLaw. There is no additional independence axiom or regularity, impatience, bounded-state, stationary or finite-state assumption. Original/shifted trajectory equivalence and original budget identities for concrete history plans use accepted P01. Dependencies P01, H02 and H04 are GREEN; H01–H04 remain GREEN. H05 alone is REVIEW_READY; 49 later contracts remain UNFORMALIZED.

## Proof route and changes

The approved route is implemented: measurable histories; derived resources and consumption; bounded integrable utility flows; absolutely convergent discounted expected utility; Bellman inequality; measure-preserving history split and integrable Fubini; finite-horizon induction; recursively constructed canonical plan and equality; bounded terminal term tending to zero; infinite-horizon comparison; original-budget bridge.

The installed piFinSuccAbove equivalence at coordinate zero implements newest-first histories. Its inverse and integral_prod_symm supply the requested integral orientation. Explicit function arguments resolve the installed Summable.of_norm elaboration. These are local API adaptations. Pointwise feasibility at every history follows the user's explicit M02B interface, superseding older design wording about almost-everywhere feasibility. No other quantifier, assumption or contract field changes. The formal information space consists of the given observed labor histories; no private randomization space is introduced. The comparison includes arbitrary measurable history-dependent actions, rather than only deterministic time paths or Markov policies.

The 65 new audited public exports are listed in `reports/logs/02b/new_exports.txt`. Exact required elaborated interfaces and all FeasiblePlan fields appear in `reports/02b_signatures.md`. The detailed readable proof and structural audit are in `docs/proof_ledger.md` and `reports/02b_structural_audit.md`.

## Verification evidence

- Fresh targeted build: removed only the two M02B module .olean/.ilean outputs, then `lake build Aiyagari1994.Household.History Aiyagari1994.Household.Verification`; exit 0, both modules rebuilt.
- `lake build`; exit 0.
- `lake env lean Audit.lean`; exit 0, including all 254 no-sorry assertions and transitive axiom outputs.
- `lake env lean Probes/M02BSignatures.lean`; exit 0.
- `python3 tools/check_contracts.py`; exit 0.
- Comment-stripped project Lean prohibited-pattern scan; exit 0. Only propext, Classical.choice and Quot.sound appear in transitive axiom output.

Logs are under `reports/logs/02b/`; commands.json records executed command exits. assert_no_sorry.log consolidates the assertions that pass silently during the successful direct audit. Early attempt logs, if retained, are development diagnostics and do not replace the final fresh builds. Source hashes in verified_sources.sha256 identify the successfully audited Lean bytes. Final whitespace and frozen-scope checks passed. The synchronized 34-page ledger was rendered and visually inspected: all pages via contact sheets and H05 pages 13–16 at full size. There are no overflow or missing-character diagnostics. Evidence is in git_diff_check.log, frozen_scope.log and pdf_qa.md in that directory.

## Adequacy audit

All utility arguments are nonnegative NNReal consumption, including zero. Real subtraction and the exact resource budget follow from feasibility. Every expected flow, terminal value and continuation has explicit integrability. The finite-history laws have unit mass even at horizon zero. Product-law integration is proved, not an IID premise. Absolute convergence is geometric domination by the primitive utility bound; terminal convergence uses bounded value alone. It does not require an asset bound or beta R < 1. P03's accepted witnesses remain available, including impatience-failing primitives. This milestone proves lifetime optimality only: policy parameter continuity, stationary laws and every other later source claim remain unformalized.

Source locators: A93 Appendix Proposition 2, printed pp. 37–38 / PDF pp. 38–39; A94 equations (5)–(7), printed pp. 666–667 / PDF pp. 9–10. These pages were visually checked during the household source review; verification details are reconstructed explicitly. Source PDFs and the failed implementation are excluded from the review archive.

## Blockers and review request

No mathematical or Lean blocker remains. H05 is submitted for external adequacy review, not promoted to GREEN. The archive contains the complete tracked and new-file diff from M02A_BASE. It is ignored/untracked at tmp_zip/review_m02b.zip. Stop after packaging; do not begin H06 or M03.

## Archive file listing

82 entries, relative to the v2 project root:

```text
.gitignore
AGENTS.md
Aiyagari1994.lean
Aiyagari1994/Analysis/ParametricMax.lean
Aiyagari1994/Budget/EffectiveLimit.lean
Aiyagari1994/Budget/Normalization.lean
Aiyagari1994/Household/Bellman.lean
Aiyagari1994/Household/History.lean
Aiyagari1994/Household/Policy.lean
Aiyagari1994/Household/Value.lean
Aiyagari1994/Household/Verification.lean
Aiyagari1994/Primitives/Basic.lean
Aiyagari1994/Primitives/Examples.lean
Aiyagari1994/Primitives/IncomeExample.lean
Aiyagari1994/Primitives/UtilityExample.lean
All.lean
Audit.lean
Probes/ApiSignatures.lean
Probes/Core.lean
Probes/M01Signatures.lean
Probes/M02ASignatures.lean
Probes/M02BSignatures.lean
README.md
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
reports/00_environment.md
reports/00_sources.md
reports/02a_milestone.md
reports/02a_signatures.md
reports/02b_artifact_sha256.json
reports/02b_milestone.md
reports/02b_signatures.md
reports/02b_structural_audit.md
reports/M01_BASE
reports/M02A_BASE
reports/logs/02a_acceptance/assert_no_sorry.log
reports/logs/02a_acceptance/audit.log
reports/logs/02a_acceptance/contracts.log
reports/logs/02a_acceptance/docs_build.log
reports/logs/02a_acceptance/full_build.log
reports/logs/02a_acceptance/git_diff_check.log
reports/logs/02a_acceptance/pdf_qa.md
reports/logs/02a_acceptance/pdf_render.log
reports/logs/02a_acceptance/prohibited_patterns.log
reports/logs/02a_acceptance/targeted_build.log
reports/logs/02a_acceptance/transitive_axioms.log
reports/logs/02b/assert_no_sorry.log
reports/logs/02b/audit.log
reports/logs/02b/commands.json
reports/logs/02b/contracts.log
reports/logs/02b/docs_build.log
reports/logs/02b/frozen_scope.log
reports/logs/02b/full_build.log
reports/logs/02b/git_diff_check.log
reports/logs/02b/log_provenance.md
reports/logs/02b/new_exports.txt
reports/logs/02b/pdf_qa.md
reports/logs/02b/pdf_render.log
reports/logs/02b/prohibited_patterns.log
reports/logs/02b/signatures.log
reports/logs/02b/targeted_build.log
reports/logs/02b/transitive_axioms.log
reports/logs/02b/verified_sources.sha256
reviews/00_acceptance.md
reviews/01_acceptance.md
reviews/02a_acceptance.md
tools/build_docs.sh
tools/check_contracts.py
```
