# Milestone M03F - exact continuous-state Inada counterexample

Date: 2026-09-12. Accepted baseline:
`1c17e1bd342e5fd87707a5774d39e1cfe8102918`.
Lean: `leanprover/lean4:v4.32.0`. Mathlib:
`81a5d257c8e410db227a6665ed08f64fea08e997`. Pins are unchanged.
Assigned scope: D01 only.

## Results against the contract

D01, `Aiyagari1994.inada_without_atom_binding_example` in
`Aiyagari1994/Diagnostics/InadaCounterexample.lean`: REVIEW_READY. The theorem constructs the
exact continuous-state witness with beta=1/2, R=w=3/2, r=1/2, phi=2, labor uniform on
`[2/3,4/3]`, and `U(c)=sqrt(c)/(1+sqrt(c))`. It proves all core primitive conditions, mean-one
labor, effective income uniform on `[0,1]`, zero minimum income with no zero-income atom, Inada,
`0≤V≤2`, and `A(z)=0` for every `0<z≤1/100`.

The exact elaborated signature and axiom print are in `reports/m03f_signatures.md` and the
synchronized proof ledger. The theorem has no premises: EXACT_DIAGNOSTIC is instantiated rather
than accepted as an assumed record. Its transitive economic content is BASIC, SMOOTH, CURVATURE,
NONDEGENERATE, and labor mean one. It assumes neither consumption positivity nor a generic
`beta*R<1` theorem hypothesis. H06 and all later contracts remain UNFORMALIZED.

## Proof route and changes

The labor law is defined as the continuous pushforward of the uniform probability law on
`[0,1]` by `e ↦ 2/3+(2/3)e`. Exact affine algebra maps labor back to effective income `e`, proving
the uniform income pushforward, endpoint support, mean one, and absence of an atom at zero.

Direct calculus proves the exact utility derivative, second derivative, Inada limit, and relative
risk aversion

`-c*U''(c)/U'(c) = 1/2 + sqrt(c)/(1+sqrt(c)) < 3/2`.

The accepted Bellman bounds yield `0≤V≤2`. New generic helpers under the assigned
`Analysis/M03F` directory prove both the exact moving-endpoint derivative

`d/da ∫_0^1 f(Ra+x)dx |_(a=0) = R(f(1)-f(0))`,

for continuous `f`, and a finite sliding-interval secant bound for every continuous function in
`[0,C]`. Instantiation of the first gives exactly `(3/2)(V(1)-V(0))`; application of the second
after the proved income pushforward and interval change of variables gives

`continuation(a)-continuation(0) ≤ 3a`.

After multiplication by beta, continuation can therefore gain at most `3a/2`. Exact utility
algebra gives `U'(z)>3/2` on `0<z≤1/100`; concavity makes the utility loss from every feasible
positive saving at least `3a/2`. Thus zero saving weakly maximizes the Bellman objective. The
accepted uniqueness theorem for the canonical policy identifies `assetPolicy z=0`.

The exact derivative is proved by the fundamental theorem of calculus for moving endpoints, not
by differentiating `V`. The separate finite secant bound supplies the global inequality needed to
compare every feasible action. The witness, interval, assumptions, quantifiers, and conclusion are
unchanged.
No numerical model, grid, or certificate is introduced.

Semantic files created or changed:

- `Aiyagari1994/Analysis/M03F/SlidingIntegral.lean`
- `Aiyagari1994/Diagnostics/InadaCounterexample.lean`
- `Probes/M03FSignatures.lean`
- `All.lean` and `Audit.lean`
- `contracts/theorems.json`
- `docs/proof_ledger.md`, generated `docs/proof_ledger.tex`, and rebuilt
  `docs/proof_ledger.pdf`
- `reports/m03f_signatures.md`, `reports/m03f_analytical_audit.md`, and this report

Existing accepted substantive declaration bodies were preserved byte-for-byte. `All.lean` and
`Audit.lean` were appended for the completed module and exhaustive export audit.

## Verification evidence

All required checks completed successfully in the existing pinned environment:

- Targeted build: `lake build Aiyagari1994.Diagnostics.InadaCounterexample
  Probes.M03FSignatures` exited 0 after 2,765 jobs.
- Direct signature probe: `lake env lean Probes/M03FSignatures.lean` exited 0. The contracted
  theorem passed `assert_no_sorry`; its transitive axioms are exactly `propext`,
  `Classical.choice`, and `Quot.sound`.
- Direct audit: `lake env lean Audit.lean` exited 0. Every new exported declaration has `#check`,
  `assert_no_sorry`, and `#print axioms`; no `sorryAx` or project axiom appears.
- Full substantive build: `lake build` exited 0 after 2,809 jobs. The new module has only Lean
  linter suggestions; there are no errors.
- Contract checker: `python3 tools/check_contracts.py` exited 0 with 57 contracts: 16 GREEN,
  D01 as the single REVIEW_READY entry, and 40 UNFORMALIZED.
- The prohibited-pattern scan over both new Lean files and the signature probe found no `sorry`,
  `admit`, project `axiom`, `native_decide`, `Lean.ofReduceBool`, or `unsafe` declaration.
  `git diff --check` exited 0.
- Documentation: `bash tools/build_docs.sh proof_ledger` exited 0 and rebuilt a 45-page PDF.
  There are no overfull boxes or undefined references; historical underfull-box warnings remain.
- PDF QA: proof-ledger pages 29--31 were rendered at 130 DPI and inspected. The complete D01
  entry on pages 29--30, including its signature, equations, status, and source qualification, is
  readable with no clipping, overlap, malformed glyphs, or truncated content. Page 31 begins D02
  cleanly. The authorized source pages A93 PDF p. 39 / printed p. 38 and A94 PDF p. 10 /
  printed p. 667 were separately rendered and visually inspected.
- Source SHA-256 values match the manifest: A93
  `274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`; A94
  `75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.

No required check was skipped. Under the controller-owned mechanical-evidence policy, command
output remained on stdout; no executor logs or QA records were written under `reports/logs`.

## Adequacy audit

The state and action spaces remain continuous `NNReal`; income is an exact continuous uniform
law. Every real continuation integral is used only after continuity/boundedness supplies
integrability. No real integral is assigned marginal meaning, and no marginal expectation is
formed. The proof does not use `rightMarginalValue`; consequently it never evaluates that object
at zero and fully preserves `zeroRightMarginal : ENNReal` as the separate economic boundary
object.

A93 Proposition 3 and the following note, printed p. 38 / PDF p. 39, state the qualified binding
result and the unqualified Inada/zero-minimum-income note. A94 printed p. 667 / PDF p. 10 provides
the corresponding shifted-policy and threshold discussion. D01 supplies an exact proposed
counterexample to the unqualified note, not to Proposition 3 itself. A successful build does not
establish economic adequacy; details and all carry-forward qualifications are recorded in
`reports/m03f_analytical_audit.md` and the proof ledger.

## Blockers and review request

No implementation blocker remains. D01 is submitted at REVIEW_READY for independent adequacy
review. No GREEN status or certified source correction is claimed. Stop at M03F; no later gate is
authorized. Per the orchestrated-run override, no manual review ZIP is created.
