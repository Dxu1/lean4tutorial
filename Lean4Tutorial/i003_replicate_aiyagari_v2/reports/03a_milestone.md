# Milestone M03A — policy order and right marginal value

Date: 2026-09-11. M02B_BASE: `b0bd1a77d97e88fb3add9b50168cbf02508c0522`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned request: record M02B acceptance, then execute H07 and H08 only under the split M03A review gate.

## Accepted predecessor

H05 was promoted to GREEN solely on the user's external ACCEPT decision. `reviews/02b_acceptance.md` records all ten substantive conclusions, including the finite-history-series interpretation and absence of a literal infinite-product path random variable. The synchronized ledger and normal acceptance checks passed before commit `b0bd1a77d97e88fb3add9b50168cbf02508c0522`, “Accept Aiyagari Milestone 02B lifetime verification”. Acceptance evidence is under reports/logs/02b_acceptance/. Review ZIPs remain ignored and untracked.

## Results against the contracts

H07, `Aiyagari1994.policies_order_lipschitz` in Household/PolicyOrder.lean: REVIEW_READY. Both shifted savings and consumption are nondecreasing, and each has the requested explicit real difference bounds between zero and the resource difference. H03/H04 supply concavity and unique maximization. These are weak order bounds, not derivative or strict monotonicity claims.

H08, `Aiyagari1994.rightMarginalValue_properties` in Household/RightMarginal.lean: REVIEW_READY. The canonical positive-state Real marginal is the negative infimum of the negative-value right secants, proved equal to their genuine one-sided limit and the supremum of the value right secants. It is positive, antitone and right-continuous, with the exact left-secant and utility-oscillation bounds. The zero marginal is the ENNReal supremum of nonnegative zero-state secants, equal to the supremum and monotone zero-state limit of converted positive marginals. Infinity is preserved, with an exact criterion. The Real function has economic meaning only for z>0; it is not used to define the boundary value.

Both contracts use BASIC only. No smoothness, Inada, differentiability, CoreRegularity, impatience, nondegeneracy, mean-one labor, invariant law, stationarity or bounded-asset premise was added. H01–H05 remain GREEN; H06 and H09 onward remain UNFORMALIZED. No later contract is implemented.

## Proof route and changes

The reusable Analysis/ConcaveReal.lean converts NNReal concavity to the real nonnegative half-line and proves a four-point concave-sum inequality. H07 uses it in two independent crossed optimality comparisons. Weak inequalities plus H04 uniqueness exclude reversals; the strict-utility assumption enters through that accepted uniqueness proof. Upper difference bounds follow from the other component's monotonicity and the budget identity.

H08 uses the actual pinned Mathlib convex-negative-value secant-infimum theorem, whose proof establishes boundedness and a finite limit. It never defines the marginal with ordinary deriv. The right-continuity proof sandwiches fixed secants against the monotone right limit. The zero marginal uses a complete-order supremum and a proved continuity-at-zero bridge to positive marginals. These are local proof-route adaptations only. All ten analytical adequacy questions are answered in reports/03a_analytical_audit.md; exact types and printed canonical definitions are in reports/03a_signatures.md.

## Verification evidence

Fresh targeted builds of Analysis.ConcaveReal, Household.PolicyOrder and Household.RightMarginal; full lake build; direct Audit.lean; exact M03A signature probe; check_contracts.py; all no-sorry assertions and transitive axiom checks; prohibited-pattern scan. Commands and successful exit statuses are in reports/logs/03a/commands.json. Fresh builds remove only these three modules' compiled .olean/.ilean files. The complete audit has 291 declarations, including all 37 new exports. Only propext, Classical.choice and Quot.sound occur.

The final ledger synchronization, PDF visual inspection, frozen-scope audit and whitespace validation passed. The 37-page PDF was reviewed on contact sheets, with M03A pages 16–20 inspected at full size and reinspected after final status-wording corrections. No overflow or missing-character warnings remain. Evidence is under reports/logs/03a/. Successfully audited Lean bytes are recorded in verified_sources.sha256. Early failed development attempts are retained only in ignored tmp/ and are not final build evidence.

## Source and adequacy scope

A93 Appendix Proposition 2, printed pp. 37–38 / PDF pp. 38–39, was visually checked again. A94 equations (5)–(7), printed pp. 666–667 / PDF pp. 9–10, are the accepted Bellman source context. H08 is new concave-analysis infrastructure inspired by the CW00 context in the manifest, not a claim to reproduce a literal numbered source theorem. The mathematical proofs use the approved architecture and pinned Mathlib. Source PDFs are excluded from the archive and the failed implementation was not inspected.

The state is all NNReal, including zero, and the labor law remains general on its compact support. P03 consistency witnesses remain available. The right slope at zero is not asserted finite; no infinite-slope economic witness or envelope equality is claimed. No later Euler, drift, borrowing-threshold or stationary result is proved in this gate.

## Blockers and review gate

No blocker remains. H07/H08 await external adequacy review and are not GREEN. Automatically package tmp_zip/review_m03a.zip with the complete tracked and new-file diff from M02B_BASE, then stop. Do not begin H09 or any later contract.

## Archive file listing

90 entries, relative to the v2 project root:

```text
.gitignore
AGENTS.md
Aiyagari1994.lean
Aiyagari1994/Analysis/ConcaveReal.lean
Aiyagari1994/Analysis/ParametricMax.lean
Aiyagari1994/Budget/EffectiveLimit.lean
Aiyagari1994/Budget/Normalization.lean
Aiyagari1994/Household/Bellman.lean
Aiyagari1994/Household/History.lean
Aiyagari1994/Household/Policy.lean
Aiyagari1994/Household/PolicyOrder.lean
Aiyagari1994/Household/RightMarginal.lean
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
Probes/M03ASignatures.lean
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
reports/02b_milestone.md
reports/02b_signatures.md
reports/03a_analytical_audit.md
reports/03a_artifact_sha256.json
reports/03a_milestone.md
reports/03a_signatures.md
reports/M02A_BASE
reports/M02B_BASE
reports/logs/02b_acceptance/assert_no_sorry.log
reports/logs/02b_acceptance/audit.log
reports/logs/02b_acceptance/commands.json
reports/logs/02b_acceptance/contracts.log
reports/logs/02b_acceptance/docs_build.log
reports/logs/02b_acceptance/full_build.log
reports/logs/02b_acceptance/git_diff_check.log
reports/logs/02b_acceptance/pdf_qa.md
reports/logs/02b_acceptance/pdf_render.log
reports/logs/02b_acceptance/prohibited_patterns.log
reports/logs/02b_acceptance/signatures.log
reports/logs/02b_acceptance/targeted_build.log
reports/logs/02b_acceptance/transitive_axioms.log
reports/logs/02b_acceptance/verified_sources.sha256
reports/logs/03a/assert_no_sorry.log
reports/logs/03a/audit.log
reports/logs/03a/commands.json
reports/logs/03a/contracts.log
reports/logs/03a/docs_build.log
reports/logs/03a/frozen_scope.log
reports/logs/03a/full_build.log
reports/logs/03a/git_diff_check.log
reports/logs/03a/log_provenance.md
reports/logs/03a/new_exports.txt
reports/logs/03a/pdf_qa.md
reports/logs/03a/pdf_render.log
reports/logs/03a/prohibited_patterns.log
reports/logs/03a/signatures.log
reports/logs/03a/targeted_build.log
reports/logs/03a/transitive_axioms.log
reports/logs/03a/verified_sources.sha256
reviews/00_acceptance.md
reviews/01_acceptance.md
reviews/02a_acceptance.md
reviews/02b_acceptance.md
tools/build_docs.sh
tools/check_contracts.py
```
