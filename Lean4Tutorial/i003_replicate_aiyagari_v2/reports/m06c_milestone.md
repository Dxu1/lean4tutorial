# Milestone M06C report: A02 stationary budget identity

Date: 2026-09-26. Assigned gate: M06C. Assigned contract: A02 only. Accepted baseline from the
capsule: `444ed99e5d4c6f74eda9c872685cb302007eddde`.

## Results against the contract

A02, `Aiyagari1994.stationary_budget_identity` in
`Aiyagari1994/Aggregate/AssetSupply.lean`: **REVIEW_READY**. For the S05-constructed canonical
stationary law, resources, shifted assets, net assets, consumption, and effective income are
integrable. The theorem first proves `E_pi z = R*E_pi A + E_nu e`, then
`S=E_pi A-phi`, and finally `E_pi c=r*S+w*E_nu l` under the explicit original-to-normalized price
identity.

Only A02's contract status changed. Every later contract remains unformalized. No GREEN status is
awarded here.

## Proof route and changes

The helper implementation in `Aiyagari1994/Analysis/M06C/StationaryBudget.lean` selects S05's
upper bound and invariant law after existence is proved. It derives all resource-side
integrability from S05's compact support and all labor-side integrability from compact labor
support.

The one-step resource law is the image of `pi x nu` through the household transition. Invariance,
integrability on the product, Fubini, and probability normalization give the resource identity.
Integral linearity yields mean net assets. The pointwise policy budget, together with the explicit
normalization equations `R=1+r` and `e(l)=w*l-r*phi`, yields the consumption identity.

The requested additional theorem `M06C.stationary_budget_of_invariant` handles any supplied
invariant law with explicit finite first moments. The organizational adaptation is to expose
separate compact-support integrability helpers and the direct resource/labor image identity in the
capsule helper directory. There is no semantic change to assumptions, timing, or conclusions.

## Verification evidence

The focused helper and target build completed successfully with 2,793 jobs. The integrated command
`lake build Probes.M06CSignatures All Audit` completed successfully with 2,876 jobs, and the final
`lake build` completed successfully with 2,876 jobs. The only warnings were pre-existing linter
warnings in M03F, M04A, and the diagnostic module; M06C introduced no build warning.

Every one of the 14 new public declarations is covered by `#check`, `assert_no_sorry`, and
`#print axioms` in both `Audit.lean` and `Probes/M06CSignatures.lean`. The full audit contains 508
matching check/no-sorry/axiom triplets. Every M06C transitive-axiom print is exactly `propext`,
`Classical.choice`, and `Quot.sound`.

`python3 tools/check_contracts.py` passed: 57 contracts, an acyclic dependency graph, and status
counts 27 GREEN, 1 REVIEW_READY, and 29 UNFORMALIZED. The contract diff changes only A02's
`status` field. The source-only prohibited-pattern scan found no match, and `git diff --check`
passed.

`bash tools/build_docs.sh proof_ledger` rebuilt the synchronized 56-page
`docs/proof_ledger.tex` and `docs/proof_ledger.pdf`. Rendered PDF pages 43--45, covering the full
A02 entry and its A01/A03 boundaries, were visually inspected after the final rebuild with no
clipping, overlap, black glyph, or illegible content. The PDF SHA-256 is
`ba3e6307d6d0c04fcc6b9a9c8808aa0ba64a3da0aaf04ad9d51815bd6f2fd995`.

The verified environment is Lean 4.32.0 (commit
`8c9756b28d64dab099da31a4c09229a9e6a2ef35`) and Mathlib commit
`81a5d257c8e410db227a6665ed08f64fea08e997`. No fresh source-PDF inspection was performed; this
gate used the authorized capsule extracts and inherited accepted source qualifications. The
controller owns verification logs and review archives, so none were created or edited here.

## Adequacy audit

S05's accepted smoothness, curvature, income-nondegeneracy, and strict-impatience hypotheses are
used only to construct the canonical compactly supported invariant law. Moment finiteness is
proved here from compact support, not inherited from S05 or weak convergence. IID is the explicit
product law. A01 retains the equivalent predetermined net-asset/current-labor interpretation and
does not become a continuum LLN.

The original-price identity remains conditional on normalization from `OriginalPrices`. Labor
mean one is not assumed. No boundary marginal object, stationary marginal-integrability claim,
asset-supply continuity, equilibrium result, finite-state approximation, or numerical model is
introduced. See `reports/m06c_analytical_audit.md` for the detailed audit.

## Blockers and review request

No A02 implementation blocker remains. Independent adequacy review is requested for A02 only.
Stop at REVIEW_READY; do not advance to A03.
