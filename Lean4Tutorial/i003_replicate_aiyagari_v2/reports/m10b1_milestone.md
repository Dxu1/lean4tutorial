# Milestone report: M10B1 / E01 zero-rate cap change

Date: 2026-10-12. Assigned gate: M10B1. Assigned contract: E01 only. Accepted baseline:
`13ae5e3f8db0f7f4185aa042a3d103a773ec28ec`. Work began from the controller-supplied capsule.
Controller-owned orchestration state, verification logs, export inventories, evidence and review
archives were not edited.

## Result

E01, `Aiyagari1994.zeroRate_cap_change_exact` in
`Aiyagari1994/Extensions/BorrowingCap.lean`: **REVIEW_READY**.

**Status:** REVIEW_READY.

At zero net interest and a fixed positive wage, two finite nonnegative caps normalize to the same
shifted household: gross return one, effective income `w*l`, and no cap-dependent intercept. The
theorem proves exact equality of its canonical value, shifted asset and consumption policies, and
S05 stationary resource law. Applying A02 to both debt shifts then proves exactly
`S(b2)-S(b1)=-(b2-b1)`. E02 and E03 remain unformalized. No GREEN status, checkpoint discharge or
stage advancement is awarded.

## Scope and proof route

`Analysis/M10B1/ZeroRateCap.lean` owns all helpers. It constructs zero-rate original prices and the
common shifted household, proves their exact normalization bridge, derives `beta*R=beta<1`, and
uses the canonical S05 law. The public extension module is a thin wrapper importing only that
helper module. The equality concerns shifted policies, not numerical equality of original/net
asset policies. No nonzero-rate, global monotonicity or equilibrium claim is made.

The approved source hashes are
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80` (A93) and
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f` (A94), matching the manifest.
A94 equation (2), printed 666/PDF 9, and the borrowing-limit discussion, printed 672--673/PDF
15--16, were rendered and visually inspected. The full approved A93 scan is supplied without an
invented extension-page attribution. Equality transport and the exact formal accounting proof are
project reconstructions.

Fresh verification completed successfully:

- `lake build Aiyagari1994.Analysis.M10B1.ZeroRateCap Aiyagari1994.Extensions.BorrowingCap All`
  completed 3,218 jobs.
- `lake build` completed 3,221 jobs, including `All.lean` and the global audit.
- `lake env lean Probes/M10B1Signatures.lean` passed for all nine new public declarations; every
  printed axiom inventory is exactly `propext`, `Classical.choice`, and `Quot.sound`.
- `lake env lean Audit.lean` passed all 716 `assert_no_sorry` declarations, including complete
  E01 coverage.
- `python3 tools/check_contracts.py` passed 57 contracts: 54 GREEN, E01 REVIEW_READY, and E02--E03
  UNFORMALIZED. Its contract diff changes only E01's status field.
- Lean prohibited-pattern, trailing-whitespace, final-newline and `git diff --check` scans passed.
- `bash tools/build_docs.sh proof_ledger` regenerated synchronized Markdown/TeX/PDF. The 79-page
  PDF was visually checked on pages 78--79, covering E01 and the unchanged E02/E03 status entries;
  no clipping or layout defect was found.

Final SHA-256 fingerprints are
`f014fa15074ac54ee25c619efc3051d315b0e6717932f11d5341a7e2338636ce` (gate helper),
`be8e21ce353a191ca353f48e0e1fa1ae79e682bd38815144b5b70bb3f8d0d6fd` (public wrapper),
`3824192706c914c20266fa25a57ac6d68bf43d0a1d4c8be0a98e13b04bee9cb4` (signature probe),
`89e4614ce7b33e0bb46133be6374cc54bd40afb2a86834c43baacddc12352e26` (D01--D20 audit),
`c1b3d92aacb648db2cf3c4cf98cccad8a2185cff6d3fa4f8f9920ee5d34900f9` (ledger Markdown),
`57affafa9f2e0aed0bb1ad4bb321f9b9f226200e2d93745a8375530d5308556d` (ledger TeX), and
`ebfc7568649839d70f372f3a9459a45e8665d47b9e42f4f9c8d91c691618d15e` (ledger PDF).

The controller owns review archives, so no manual ZIP is created.

REVIEW_CONTEXT_COMPLETE is requested for E01 only after deterministic verification of the actual
proof bodies, D01--D20 audit, exact signatures, frozen dependencies and assumptions, mandatory
predecessor qualifications, source evidence, and synchronized Markdown/TeX/PDF ledger.
