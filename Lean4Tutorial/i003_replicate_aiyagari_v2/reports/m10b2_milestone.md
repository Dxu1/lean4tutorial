# Milestone report: M10B2 / E02 caps above the natural limit

Date: 2026-10-28. Assigned gate: M10B2. Assigned contract: E02 only. Work began from the
controller-supplied capsule at accepted baseline `a070cfc574abc1fbd6fdabe735784cc173b938ae`.
Controller-owned orchestration state, verification logs, export inventories, evidence and review
archives were not edited.

## Result

E02, `Aiyagari1994.caps_above_naturalLimit_equivalent` in
`Aiyagari1994/Extensions/BorrowingCap.lean`: **REVIEW_READY**.

**Status:** REVIEW_READY.

At positive net interest, two finite nonnegative caps weakly above `w*l_min/r` have the same
effective limit, including at equality. The theorem proves unconditional equality of normalized
household primitives, canonical value, shifted asset and consumption policies, transition kernel,
and resource-law transition under BASIC. A separate clause carries S05's exact smoothness,
curvature, endpoint-nondegeneracy and strict-impatience premises and proves equality of the
canonical stationary laws, integrability of both net-asset random variables, and equality of net
asset supply. E01 remains GREEN and E03 remains unformalized. No GREEN status, checkpoint discharge
or stage advancement is awarded.

## Scope and proof route

`Analysis/M10B2/CapsAboveNatural.lean` owns every new helper. It constructs the two finite-cap
price records and normalized households directly from P02, proves both `min(b,w*l_min/r)` terms
equal the natural limit, and transports equality through H02/H04 and the household kernel. It
selects its canonical stationary law directly from S05 and proves compact-support integrability
locally, so E02 imports neither A02 nor E01. The accepted BorrowingCap wrapper is preserved byte for
byte except for the certified new header import and appended public theorem. `All.lean` is unchanged.

The approved source hashes are
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80` (A93) and
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f` (A94), matching the manifest.
A94 equation (2), printed 666/PDF 9, and the borrowing-limit discussion, printed 672--673/PDF
15--16, were rendered and visually inspected. The full approved A93 scan is supplied without an
invented extension-page attribution. Equality transport, weak-boundary inclusion, canonical-law
identification and compact-support integrability are project reconstructions.

Fresh verification completed successfully:

- The targeted helper and wrapper build completed 2,797 jobs.
- `lake build` completed 3,222 jobs, including `All.lean` and the global audit.
- `lake env lean Probes/M10B2Signatures.lean` passed for all 15 new public declarations; every
  printed axiom inventory is exactly `propext`, `Classical.choice`, and `Quot.sound`.
- The global `Audit.lean` passed all 731 `assert_no_sorry` declarations, including complete E02
  coverage.
- `python3 tools/check_contracts.py` passed 57 contracts: 55 GREEN, E02 REVIEW_READY, and E03
  UNFORMALIZED. A direct capsule comparison confirms that only E02's status field changed.
- Prohibited-pattern, trailing-whitespace, final-newline, and `git diff --check` scans passed.
- `bash tools/build_docs.sh proof_ledger` regenerated synchronized Markdown/TeX/PDF. The 80-page
  PDF was visually checked on pages 78--80; the E02 entry and adjacent E01/E03 entries are legible,
  unclipped, and free of layout defects.

Final SHA-256 fingerprints are
`0ebb6b12d4d14b28c1e53ed660c9c1984da3483a359034e9a1db9b63483cd989` (gate helper),
`b0e998d58dd03cd976214a21516741961ff6b744ea22f71be052c3cffa1e07c8` (public wrapper),
`0683f07cb61c5f1ee55810532ca0b6d7f34e69314a61469b0dba407d8cca25a8` (signature probe),
`fa8cbc6df5f711e27138448cac595a4d88b88c0bdbaaaccadf5cdf2e11be1e5d` (global audit),
`0e7b5a4e9504365b9c99f5c5143685c6ba0b282ece091ab65f58a4b76094300c` (ledger Markdown),
`1caec9598394c5b5be85835c6803fcd876786a101f88f52a23ace324509c153e` (ledger TeX), and
`3582631b3c4856f384330f8177cbdefc0d7a2447171bd043069d03967b4ae2a1` (ledger PDF).

The controller owns review archives, so no manual ZIP is created.

REVIEW_CONTEXT_COMPLETE is requested for E02 only after deterministic verification of the actual
proof bodies, D01--D20 audit, exact signatures, frozen dependencies and assumptions, mandatory
predecessor qualifications, source evidence, and synchronized Markdown/TeX/PDF ledger.
