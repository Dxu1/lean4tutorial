# Milestone M03C - subcritical Euler theorem

Date: 2026-09-12. Accepted baseline:
`de0af9ba9adb00d736e466a031e9677807bfe9b9`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned scope: H12 only.

## Results against the contract

H12, `Aiyagari1994.euler_subcritical` in `Aiyagari1994/Household/Euler.lean`:
REVIEW_READY. For BASIC primitives, SMOOTH utility, `beta*R<1`, and every positive resource
state, it proves a.e. finiteness and integrability of the explicit conditional next marginal and
the Euler inequality. At positive shifted savings, it separately proves ordinary marginal-utility
integrability, pointwise exclusion of the zero branch, and the Euler equality.

The new boundary-safe object `eulerNextMarginal : Resources → ENNReal` equals
`zeroRightMarginal` at zero and `ENNReal.ofReal (deriv U (c z))` at positive resources. The new
audited Analysis helper `continuationValue_hasDerivAt_of_asset_pos` is in
`Aiyagari1994/Analysis/M03C/ContinuationDerivative.lean`. H09 supplies the extended inequality and
conditional finiteness, H10 supplies derived positive consumption, and H11 supplies the envelope
identity. All accepted predecessor bodies and statuses are preserved. H06 and H13 onward remain
UNFORMALIZED.

## Proof route and changes

The weak inequality rewrites H09's conditionally integrable extended value marginal using H10 and
H11 at positive next resources while retaining the separate extended value marginal at zero. At
the positive current state H11 rewrites the left side to current marginal utility.

For the equality branch, positive shifted savings produce a common strictly positive next-resource
floor. On an action neighborhood above half the optimizer, concavity bounds continuation
derivatives by an integrable constant. A dominated parametric-integral theorem proves the expected
continuation derivative and the ordinary marginal-utility integrability certificate. Positive
consumption and positive savings make the canonical action a local interior maximum of the actual
Bellman objective; Fermat's theorem yields equality.

The explicit `eulerNextMarginal` interface is an implementation elaboration required to preserve
the accepted zero-state qualification, not a change in theorem scope or economic content. No
theorem, assumption, dependency, quantifier, primitive, pin, or configuration was weakened or
changed.

Semantic files created or changed:

- `Aiyagari1994/Analysis/M03C/ContinuationDerivative.lean`
- `Aiyagari1994/Household/Euler.lean`
- `Probes/M03CSignatures.lean`
- `All.lean` and `Audit.lean`
- `contracts/theorems.json`
- `docs/proof_ledger.md`, `docs/proof_ledger.tex`, and `docs/proof_ledger.pdf`
- `reports/m03c_signatures.md`, `reports/m03c_analytical_audit.md`, and this report

## Verification evidence

All required commands were run with output to stdout under the controller-owned mechanical
evidence policy:

| Check | Exact command or operation | Result |
|---|---|---|
| Targeted build | `lake build Aiyagari1994.Analysis.M03C.ContinuationDerivative Aiyagari1994.Household.Euler Probes.M03CSignatures` | exit 0 |
| Signature probe | `lake env lean Probes/M03CSignatures.lean` | exit 0 |
| Full build | `lake build` | exit 0; 2,741 jobs |
| Direct audit | `lake env lean Audit.lean` | exit 0 |
| Contract checker | `python3 tools/check_contracts.py` | exit 0 |
| Prohibited/no-sorry scan | conditional `rg` scan over the two new modules and probe | wrapper exit 0; no matches |
| Scope and pins | `git diff --quiet` against the accepted baseline for tracked predecessor sources, pins, tools, orchestration, and reviews; `git diff --check`; index check | exit 0 |
| Documentation | `bash tools/build_docs.sh proof_ledger` | exit 0; 42 pages; no overfull boxes |
| PDF QA | `pdfinfo`, Poppler rendering at 150 dpi, and full-resolution visual inspection | pass; pages 1 and 25--26 |

Every listed command completed successfully. The targeted modules and signature probe built; the
full build completed 2,741 jobs; direct `Audit.lean` elaboration passed; and the contract checker
reported 57 contracts with status counts 13 GREEN, 43 UNFORMALIZED, and 1 REVIEW_READY. Targeted
no-sorry and prohibited-pattern scans returned no matches. Baseline-scope checks confirmed that
the accepted predecessor theorem bodies, dependency pins, orchestration, and tool files are
unchanged. Exact signatures are in `reports/m03c_signatures.md`. All six new exports print exactly
`[propext, Classical.choice, Quot.sound]` as transitive axioms.

The documentation build completed successfully and produced a 42-page ledger. Poppler-rendered
page 1 and the H12 pages 25--26 were inspected at full resolution: the title and REVIEW_READY
status are legible, the H12 statement and proof are complete, and there is no clipping, overlap,
or broken glyph rendering. No required check was skipped.

Per the mechanical-evidence override, no executor logs were written under `reports/logs`; the
controller independently owns those output paths.

## Adequacy audit

The state remains all `NNReal`; the labor law remains a general probability law on compact
positive support. H12 adds only SMOOTH, IMPATIENT, and positive current resources to BASIC.
Equality adds positive shifted savings. There is no curvature, density, atom, positive effective
income minimum, stationary law, or asset bound. P03 remains the unchanged consistency witness.

No economic real integral is introduced before integrability. The zero state is represented only
by `zeroRightMarginal : ENNReal`, which may be infinite. `rightMarginalValue m 0` is never used.
The source hashes match the manifest; A93 printed pp. 37-38 / PDF pp. 38-39 and A94 printed
pp. 666-667 / PDF pp. 9-10 were rendered and visually inspected. A successful build does not
establish economic adequacy.

The structured H12 `sources` array lists A93 while its approved locator also names A94. Both
approved passages were inspected; the assigned manifest metadata was not silently revised.

## Blockers and review request

No implementation blocker remains. H12 is submitted at REVIEW_READY for independent adequacy
review. No GREEN status is claimed. Stop at M03C; H13 and later gates are not authorized. Per the
orchestrated-run override, no manual review ZIP was created.
