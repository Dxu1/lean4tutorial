# M02A — Bellman value and continuous asset policy

Date: 2026-09-11. Assigned authority: the user's M01 ACCEPT decision and M02A
scope override. Only H01-H04 are assigned; the combined M02 prompt is not executed.

M01_BASE: `8039b914fd05997599a1d19f7caa39265c24269b`.

Lean: `leanprover/lean4:v4.32.0`.
Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`.
Dependency pins are unchanged from the accepted predecessor.

## Results against the contracts

| Contract | Exact declaration | Status | Result |
|:--|:--|:--|:--|
| H01 | `Aiyagari1994.bellman_selfmap_contracting` | REVIEW_READY | An actual bounded-continuous Bellman self-map on all NNReal, with beta contraction; pointwise and supremum-norm inequalities are separately proved. |
| H02 | `Aiyagari1994.valueFunction_unique_fixedPoint` | REVIEW_READY | One canonical fixed point, uniqueness among all bounded continuous fixed points, uniform convergence from every initial candidate, and exact utility-infimum/supremum bounds divided by 1-beta. |
| H03 | `Aiyagari1994.valueFunction_concave_strictMono` | REVIEW_READY | Ordinary real convex-combination concavity and strict increase of the canonical value function. |
| H04 | `Aiyagari1994.assetPolicy_unique_continuous` | REVIEW_READY | A canonical unique Bellman maximizer in actual shifted assets, continuous also at zero; feasible canonical consumption and exact budget identity. |

The four substantive implementation files are:

- `Aiyagari1994/Analysis/ParametricMax.lean`.
- `Aiyagari1994/Household/Bellman.lean`.
- `Aiyagari1994/Household/Value.lean`.
- `Aiyagari1994/Household/Policy.lean`.

Every economic wrapper requires only `m : HouseholdPrimitives`. No primitive
record is modified. The exact signatures and auxiliary predicate definitions
are printed in `reports/02a_signatures.md` and the direct signature log.
All 88 new exported declarations, including definitions and reusable lemmas,
are inventoried in `reports/02a_declarations.json` and audited in `Audit.lean`.
The readable proofs, economic hypotheses, integrability, compactness, source
correspondence and exact contract signatures appear in the synchronized ledger.

## Accepted predecessor and workflow

Recorded the external M01 decision in `reviews/01_acceptance.md` with all P01-P03
qualifications and the BASIC-only forward restriction. P01-P03 are GREEN by
that decision; M00 remains GREEN. Rebuilt and visually inspected the acceptance
ledger, reran the M01 acceptance checks, and committed only the v2 project as
`Accept Aiyagari Milestone 01 primitives`. Acceptance logs are in
`reports/logs/01_acceptance/`. No unrelated repository changes were included.

After that baseline, minimally extended the existing AGENTS review convention
to permit a lowercase suffix: M02A -> review_m02a.zip; M02B -> review_m02b.zip.
Existing archive exclusions, automatic packing, SHA-256 and untracked rules apply.
No other AGENTS instruction was rewritten. M02A changes remain uncommitted;
Git's index is empty. `tmp_zip/` remains ignored and untracked.

## Proof route and implementation adaptations

The economics, state space, quantifiers, assumptions and contract statements
are unchanged. The implementation uses these local analytic representations:

1. The installed compact supremum theorem already supplies maximum-value
   continuity. Small reusable wrappers add attainment and upper/lower bounds.
   The actual economic action remains a in [0,z]; a=t*z is only an auxiliary
   compact parametrization. The objective has a continuous extension outside
   its feasible set via NNReal subtraction, with a proved exact real formula
   on the feasible set. Utility is never evaluated at negative consumption.
2. Integral continuity uses the installed compact parametric integral theorem
   on the full labor subtype. The labor measure is arbitrary and has mass one;
   it is not restricted to finite support. All continuation integrals have
   explicit integrability proofs. Boundedness is global in the unbounded state.
3. H02's exact bounds are proved using infimum and supremum of the fixed point's
   bounded range. This requires no extremum attainment on the unbounded state
   space and does not weaken the utility-infimum/supremum bounds.
4. `NNRealConcave` uses two arbitrary nonnegative real weights represented as
   NNReal. A proved real-theta formulation confirms ordinary concavity. The
   zero-start iterations converge uniformly, and concavity/monotonicity pass
   through this proved convergence. Keeping the same saving action proves a
   stronger intermediate result: T v is strictly increasing for every candidate v.
5. Unique-argmax continuity is proved by closed-graph compact projection. It is
   applied to shares only for positive resources, where shares are unique.
   At zero, feasibility supplies the squeeze argument for actual assets. This
   follows the proposed positive-share/zero-boundary route, with the generic
   argmax lemma proved directly rather than imported as a ready-made theorem.

These are implementation adaptations, not changes to mathematical assumptions.

## Verification evidence

| Check | Command / evidence | Result |
|:--|:--|:--|
| Fresh targeted builds | `lake build Aiyagari1994.Analysis.ParametricMax Aiyagari1994.Household.Bellman Aiyagari1994.Household.Value Aiyagari1994.Household.Policy` | Exit 0; all four local module outputs removed first and rebuilt; 2647 jobs. |
| Full build | `lake build` | Exit 0; 2722 jobs. |
| Direct audit | `lake env lean Audit.lean` | Exit 0; 189 audited declarations, including all 88 new exports. |
| Exact signatures | `lake env lean Probes/M02ASignatures.lean` | Exit 0; all four anchors and four canonical types printed, plus predicate/maximization interfaces. |
| No-sorry | Direct `assert_no_sorry` commands in Audit and the signature probe | All pass; the command is silent on success. |
| Transitive axioms | Direct `#print axioms` output | Only `propext`, `Classical.choice`, `Quot.sound`, or subsets. No custom axiom. |
| Prohibited patterns | Scan of all project Lean sources, excluding comments | No placeholders or proof bypasses. |
| Contract checks | `python3 tools/check_contracts.py` | Exit 0; 3 GREEN, 4 REVIEW_READY, 50 UNFORMALIZED. |
| Baseline comparison | `reports/logs/02a/baseline_comparison.log` | Only H01-H04 statuses changed in the manifest. All statements, assumptions, dependencies, scope and source locators are unchanged. |
| Whitespace / complete diff | `reports/logs/02a/git_diff_check.log` | Tracked diff and every newly created text file checked; complete binary-capable diff is in the archive. |
| Documentation | `bash tools/build_docs.sh proof_ledger` plus PDF rendering | Synchronized Markdown/TeX/PDF; detailed visual evidence in `reports/logs/02a/pdf_qa.md`. |

The logs are under `reports/logs/02a/`. Failed development attempts are explicitly
named attempt/diagnostic and are not final success evidence. Some tool logs are
consolidated only by trimming trailing whitespace; raw hashes and provenance
are recorded in `log_provenance.md`.

## Adequacy and forward compatibility

`reports/02a_structural_audit.md` records the complete forward audit. In particular:

- valueFunction and assetPolicy are canonical constructed definitions, not fields.
- No CoreRegularity, beta*R<1, Inada, derivative-at-zero, IID-history,
  nondegeneracy, mean-one, invariant-law or bounded-asset assumption is added.
- Arbitrary positive R is covered, including beta*R>=1.
- The state and assets remain continuous NNReal; the labor law remains general.
- No differentiation of V or policy, compact absorbing set, stationarity theorem,
  equilibrium claim, or H05 lifetime-optimality result is introduced.
- The unique-maximization property is exposed equivalently as an actual
  existential-unique maximizer over every feasible shifted asset.

Source pages were checked visually: A94 printed 666-667 / PDF 9-10, equations
(4)-(7), and A93 printed 37-38 / PDF 38-39, Appendix Proposition 2 context.
The latter discusses further differentiability and envelope claims outside this
stage. Source hashes still match the approved source manifest. No failed prior
implementation or its generated proof material was inspected. No numerical
model, grid, solver, calibration or results were produced.

## Review boundary and package

No blockers remain. H01-H04 are REVIEW_READY, not GREEN. M00 and P01-P03 retain
their externally accepted GREEN status. All remaining 50 economic contracts,
including H05, remain UNFORMALIZED. `Household/Verification.lean` does not exist.

The review package is `tmp_zip/review_m02a.zip`. It includes the complete diff
from M01_BASE, including all new files, and excludes caches, compiled Lean
artifacts, source PDFs, input/previous ZIPs, TeX auxiliaries and numerical files.
The final SHA-256 is reported in the adjacent receipt and final response; the
archive cannot contain its own hash without circularity. Packing verifies the
frozen source bytes and does not modify substantive sources.

Stop for external M02A review. Do not begin H05/M02B or Milestone 03.

## Archive file listing

78 entries, relative to the v2 project root:

```text
.gitignore
AGENTS.md
Aiyagari1994.lean
Aiyagari1994/Analysis/ParametricMax.lean
Aiyagari1994/Budget/EffectiveLimit.lean
Aiyagari1994/Budget/Normalization.lean
Aiyagari1994/Household/Bellman.lean
Aiyagari1994/Household/Policy.lean
Aiyagari1994/Household/Value.lean
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
reports/02a_artifact_sha256.json
reports/02a_declarations.json
reports/02a_milestone.md
reports/02a_signatures.md
reports/02a_structural_audit.md
reports/M01_BASE
reports/logs/02a/assert_no_sorry.log
reports/logs/02a/audit.log
reports/logs/02a/baseline_comparison.log
reports/logs/02a/concavity_diagnostic.log
reports/logs/02a/contracts.log
reports/logs/02a/docs_build.log
reports/logs/02a/environment_sources.log
reports/logs/02a/full_build.log
reports/logs/02a/git_diff_check.log
reports/logs/02a/h01_attempt1.log
reports/logs/02a/h01_attempt2.log
reports/logs/02a/h01_attempt3.log
reports/logs/02a/h02_attempt1.log
reports/logs/02a/h02_attempt2.log
reports/logs/02a/h03_attempt1.log
reports/logs/02a/h03_attempt2.log
reports/logs/02a/h04_attempt1.log
reports/logs/02a/h04_attempt2.log
reports/logs/02a/h04_attempt3.log
reports/logs/02a/h04_attempt4.log
reports/logs/02a/h04_attempt5.log
reports/logs/02a/h04_attempt6.log
reports/logs/02a/h04_attempt7.log
reports/logs/02a/h04_attempt8.log
reports/logs/02a/h04_attempt9.log
reports/logs/02a/log_provenance.md
reports/logs/02a/pdf_qa.md
reports/logs/02a/pdf_render.log
reports/logs/02a/prohibited_patterns.log
reports/logs/02a/signatures.log
reports/logs/02a/signatures_attempt.log
reports/logs/02a/targeted_build.log
reports/logs/02a/transitive_axioms.log
reports/logs/02a/verified_sources.sha256
reviews/00_acceptance.md
reviews/01_acceptance.md
tools/build_docs.sh
tools/check_contracts.py
```
