# Milestone M03D - qualified borrowing threshold

Date: 2026-09-12. Accepted baseline:
`49f74f9cf3bd62d5b85331eebd88f152d8901cba`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned scope: H13 only.

## Results against the contract

H13, `Aiyagari1994.binding_interval_exists` in
`Aiyagari1994/Household/BorrowingThreshold.lean`: REVIEW_READY. For BASIC primitives, SMOOTH
utility, `beta*R<1`, and either positive minimum effective income or finite
`utilityZeroRightMarginal`, it constructs `zHat>e_min` and proves the canonical shifted asset
policy is zero at every state in `[e_min,zHat]`.

The new audited definition `minimumEffectiveIncome : HouseholdPrimitives → Resources` is the
affine effective income at the lower labor endpoint. H08 supplies right-marginal monotonicity and
right limits, H10 supplies positive consumption and the finite-utility Lipschitz bound, and H12
supplies the integrable interior Euler equality. All accepted predecessor bodies and statuses are
preserved. H06, H14, D01, and all later contracts remain UNFORMALIZED.

## Proof route and changes

The finite-utility branch first converts H10's global value increment bound into
`zeroRightMarginal ≤ utilityZeroRightMarginal`, proving the economic value marginal at zero is
finite without using a default real derivative. In either threshold branch the endpoint value
marginal `Q` is finite and strictly positive.

If `A(z)>0`, every next resource is at least `e_min`. H08's antitonicity, H10/H11's positive-state
envelope identity, and H12's proved integrability plus Euler equality yield
`q(z) ≤ beta*R*Q`. Because `beta*R<1`, right continuity at positive `e_min`, or the extended
positive-marginal limit to `zeroRightMarginal` when `e_min=0`, gives a nontrivial neighborhood in
which `q(z)>beta*R*Q`. Thus saving cannot be interior. The endpoint is handled by
`assetPolicy_zero` at zero and by the same strict impatience contradiction when positive.

`minimumEffectiveIncome` is the only public API elaboration beyond the contracted theorem. It
makes the source's `e_min` explicit in the final signature. No theorem, assumption, dependency,
quantifier, primitive, pin, configuration, or contract meaning was weakened or changed.

Semantic files created or changed:

- `Aiyagari1994/Household/BorrowingThreshold.lean`
- `Probes/M03DSignatures.lean`
- `All.lean` and `Audit.lean`
- `contracts/theorems.json`
- `docs/proof_ledger.md`, `docs/proof_ledger.tex`, and `docs/proof_ledger.pdf`
- `reports/m03d_signatures.md`, `reports/m03d_analytical_audit.md`, and this report

No generic helper module was required under `Aiyagari1994/Analysis/M03D/`; all supporting lemmas
are private to the assigned H13 module.

## Verification evidence

All required commands were run with output to stdout under the controller-owned mechanical
evidence policy:

| Check | Exact command or operation | Result |
|---|---|---|
| Targeted build | `lake build Aiyagari1994.Household.BorrowingThreshold Probes.M03DSignatures` | exit 0; 2,703 jobs |
| Signature probe | `lake env lean Probes/M03DSignatures.lean` | exit 0 |
| Full build | `lake build` | exit 0; 2,742 jobs |
| Direct audit | `lake env lean Audit.lean` | exit 0 |
| Contract checker | `python3 tools/check_contracts.py` | exit 0 |
| No-sorry/prohibited scan | conditional `rg` scan over the new module and probe | exit 0; no matches |
| Transitive axioms | `#print axioms` in the direct audit and signature probe | both exports exactly `[propext, Classical.choice, Quot.sound]` |
| Scope and formatting | baseline file inventory, `git diff --check`, control-character scan, and pin/source comparison | pass; only assigned semantic outputs changed |
| Documentation | `bash tools/build_docs.sh proof_ledger` | exit 0; 43 pages; no overfull or undefined warnings |
| PDF QA | Poppler rendering at 160 dpi and full-resolution visual inspection | pass; source pages A93 PDF 39 and A94 PDF 10; ledger pages 1 and 26--28 |

The contract checker reports 57 contracts with status counts 14 GREEN, 42 UNFORMALIZED, and 1
REVIEW_READY. `Audit.lean` checks both new exports with `#check`, `assert_no_sorry`, and
`#print axioms`. The signature probe confirms the exact public quantifiers and endpoint
disjunction. The synchronized ledger title page identifies H13 as REVIEW_READY, pages 26--27
contain the complete H13 signature, assumptions, proof, boundary/integrability audit, sources,
and axiom result, and page 28 begins the unchanged H14 entry. There is no clipping, overlap,
broken glyph rendering, or illegible text on the inspected pages. No required check was skipped.

The controller independently owns all mechanical evidence paths; no executor logs or QA notes
were written under `reports/logs`.

## Adequacy audit

The state remains all `NNReal`; the labor law remains a general probability law on compact
positive labor support. H13 adds exactly SMOOTH, IMPATIENT, and THRESHOLD to BASIC. There is no
curvature, density, atom, stationary law, asset bound, numerical discretization, or assumed
threshold. P03 remains only the unchanged primitive consistency witness.

`zeroRightMarginal : ENNReal` remains the sole economic value marginal at zero and may be infinite
before the finite-utility threshold branch proves otherwise. `rightMarginalValue m 0` is never
used. H12's real conditional integral is used only together with its integrability certificate.
The analytical details and carry-forward qualifications are recorded in
`reports/m03d_analytical_audit.md`.

The A93 and A94 source hashes match the manifest. A93 Proposition 3 and following note, printed
p. 38 / PDF p. 39, and A94's threshold discussion, printed p. 667 / PDF p. 10, were rendered and
visually inspected. This result proves only the qualified binding interval. It does not certify
the unqualified nonbinding note. A successful build does not establish economic adequacy.

## Blockers and review request

No implementation blocker remains. H13 is submitted at REVIEW_READY for independent adequacy
review. No GREEN status is claimed. Stop at M03D; H14 and later gates are not authorized. Per the
orchestrated-run override, no manual review ZIP is created.
