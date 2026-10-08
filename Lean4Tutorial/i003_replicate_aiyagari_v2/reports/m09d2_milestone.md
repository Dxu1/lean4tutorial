# Milestone report: M09D2 / G07 equilibrium gross saving share above certainty

Date: 2026-10-08. Assigned gate: M09D2. Assigned contract: G07 only. Accepted baseline:
`509e32c9092055aced74a932db8a8dc8bd7a7858`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

G07, `Aiyagari1994.equilibrium_gross_saving_share_above_certainty` in
`Aiyagari1994/Equilibrium/Saving.lean`: **REVIEW_READY**.

For every unrestricted stationary equilibrium, the theorem returns the certified certainty
firm rate, identifies benchmark capital as `capitalDemand(rFI)`, and proves that its gross
replacement-investment share is strictly below the share at actual cleared equilibrium net
capital. Only G07's status changed. No GREEN status, G08 result, Stage-10 result, or stage
advancement is awarded.

## Proof route and exact dependencies

The gate-local helper defines `g(K)=delta*K/f(K)`. F01's positive capital-demand surjectivity
and positive wage prove `f(K)-K*f'(K)>0` at every positive capital stock; marginal-product
positivity then proves `f(K)>0`. The quotient rule derives the contracted derivative formula,
and Mathlib's mean-value monotonicity theorem proves `StrictMonoOn g (Ioi 0)`. G06 supplies
`K_FI<K`, while accepted capital clearing establishes positivity and the actual-net-capital
interpretation of `K`. Strict monotonicity gives `g(K_FI)<g(K)`.

The exact dependencies are F01 and G06. The proof introduces no interest-rate monotonicity,
equilibrium uniqueness, positive stationary net saving, net accumulation, capital growth, or
G08 argument.

## Verification and review boundary

The following fresh checks completed with exit status zero:

- `lake build Aiyagari1994.Analysis.M09D2.GrossSaving Aiyagari1994.Equilibrium.Saving`
- `lake env lean Probes/M09D2Signatures.lean`
- `lake build` (3140 jobs, including `All` and `Audit`)
- `python3 tools/check_contracts.py` (57 contracts, acyclic dependency graph)
- `bash tools/build_docs.sh proof_ledger` (76-page PDF)
- `git diff --check` and the targeted prohibited-pattern scan

The M09D2 signature probe and global audit cover every new declaration with `#check`,
`assert_no_sorry`, and `#print axioms`; all new axiom prints contain only `propext`,
`Classical.choice`, and `Quot.sound`. A baseline comparison confirms that the sole contract-field
change is G07 `status: UNFORMALIZED -> REVIEW_READY`.

The synchronized ledger hashes are Markdown
`65987003565ac44d4f3e77c8c4576df4b5f26ce90c884847d2e5f6c48df7ec84`, TeX
`cefad9a582642da80de8ec3fc72697282e747eea2087e890823f904baa882beb`, and PDF
`df3f1eee197834a171a406619acd8eb45c6d7b1274e855b8e3d3b32cebf35d0e`. Rendered ledger pages
72--74 were visually inspected; the G07 entry, its continuation, and the unchanged G08 boundary
are legible with no clipping or overlap.

A94 printed pp. 670--671 / original PDF pp. 13--14 supplies the approved comparison motivation.
Both repository copies match the manifest's original SHA-256
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f` and byte count 1,394,274;
original PDF pages 13--14 were freshly rendered and visually inspected, including notes 24--27.
The exact derivative and monotonicity proof is a project reconstruction. The controller owns
verification logs and review archives, so no manual log or ZIP is created. Independent adequacy
review is requested for G07 only. Stop at REVIEW_READY.

REVIEW_CONTEXT_COMPLETE: G07 implementation, analytical audit, exact signature probe, global
audit coverage, frozen contract metadata with status-only transition, and synchronized ledger
Markdown/TeX/PDF are present for controller verification and independent review.
