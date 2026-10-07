# Milestone report: M09C1 / A04 certainty stationary assets at limit

Date: 2026-10-07. Assigned gate: M09C1. Assigned contract: A04 only. Accepted baseline:
`aff0c3dcf7a7250097f8803cdf1c13361e63bf72`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, evidence, export inventories, and review
archives were not edited.

## Result

A04, `Aiyagari1994.certainty_stationary_assets_at_limit` in
`Aiyagari1994/Equilibrium/CertaintyBenchmark.lean`: **REVIEW_READY**.

The theorem constructs the deterministic household at the supplied risky household's actual mean
labor, uses certainty `OriginalPrices` and therefore its own debt limit, identifies the canonical
kernel with pushforward by the deterministic policy transition, proves weak convergence from every
initial probability law to the effective-income point mass, proves invariant-law uniqueness, and
derives zero shifted assets, explicit stationary net-asset integrability, and net assets equal to
minus the certainty debt limit.

Only A04's contract status changed. Every accepted predecessor remains unchanged; A05, G04-G08,
Stage 10, and all other unassigned contracts remain unchanged. No curvature, income
nondegeneracy, risky crossing, initial-law moment, compact-support, equilibrium, or comparison
claim is added. No GREEN status or stage advancement is awarded.

## Proof route

The degenerate income subtype has one labor value, the actual integral mean of the original labor
law. Thus the household kernel is Dirac at `h(z)=R*A(z)+ebar`. S02 supplies the fixed point, strict
descent above it, and monotone convergence from states above it; the lower transition bound places
any state below `ebar` above the endpoint after one step. Bounded-continuous tests composed with
the iterates converge pointwise and are uniformly dominated by their norm, so dominated
convergence proves weak convergence from arbitrary probability laws. Invariance plus this global
limit proves uniqueness. The fixed-point equation and positive gross return force `A(ebar)=0`,
and the Dirac integral of `A-phi` is `-phi`.

## Verification and review boundary

The focused helper/wrapper/probe build and the full `lake build` exited successfully; the full
build completed 3,132 jobs and rebuilt the global `Audit.lean` target. Every new public declaration
is registered for `#check`, `assert_no_sorry`, and `#print axioms` in
`Probes/M09C1Signatures.lean` and `Audit.lean`. Both the focused probe and global audit report only
`propext`, `Classical.choice`, and `Quot.sound`.

`python3 tools/check_contracts.py` passed all 57 contracts and reported exactly 44 GREEN, one
REVIEW_READY, and 12 UNFORMALIZED. Direct status inspection confirms A04 is REVIEW_READY while
A05, G04, and G05 remain UNFORMALIZED. The assigned-file prohibited-pattern scan and
`git diff --check` passed.

`bash tools/build_docs.sh proof_ledger` rebuilt synchronized Markdown, TeX, and a 72-page letter-
size PDF. Rendered page 1 and pages 46-48 were visually inspected; the opening overview, A04
signature/proof, transition to untouched A05, headers, footers, and page numbering have no
clipping, overlap, broken glyph, or new margin overflow. The PDF SHA-256 is
`c23c603194d5e8337c2ba9d159adc2f295eb4e53792085dd646848f22e94b443`.

A94 printed pp. 669-671 / PDF pp. 12-14 is the approved motivating locator. The complete global
convergence proof is identified as project reconstruction. The controller owns review archives,
so no manual ZIP is created. Independent adequacy review is requested for A04 only. Stop at
REVIEW_READY.
