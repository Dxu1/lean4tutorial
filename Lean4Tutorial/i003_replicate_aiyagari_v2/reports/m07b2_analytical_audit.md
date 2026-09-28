# M07B2 analytical audit

This audit covers N06 only and does not claim that the required independent review has occurred.

| Required question | Answer and proof evidence |
|---|---|
| Is the candidate invariant law assumed globally? | No. `no_invariant_critical` has a negated-existence conclusion and introduces `pi` only with `rintro` inside the contradiction. |
| Is `R>1` assumed? | No. It is derived from `beta*R=1`, `0<beta`, `beta<1`, and primitive return positivity. |
| Is the actual budget identity used? | Yes. `consumptionPolicy_coe` rewrites `c(z)=z-A(z)`, equivalently `c+A=z`. |
| Is the actual canonical transition used? | Yes. `step(z,l)` is definitionally `nextResources(assetPolicy(z),l)`, whose real value is `R*A(z)+effectiveIncome(l)`. |
| Is the N05 recursion derived? | Yes. The proof combines the preceding two identities to derive `step(z,l)=R*(z-c(z))+effectiveIncome(l)`; it is not assumed as a household premise. |
| Is the kernel bridge exact? | Yes. `M07B2.resourceKernel_canonical_eq` proves the N05 resource kernel is the canonical `householdKernel`. |
| Is N04 used only at its accepted strength? | Yes. N04 supplies stationary one-step consumption equality only almost everywhere under `pi.compProd(householdKernel)`. N06 passes exactly that premise to N05 after rewriting the kernel. |
| Is nondegeneracy converted to variance positivity legitimately? | Yes. Essential endpoint mass first proves labor is not a.e. constant; positive affine wages transfer this to effective income. N05 then proves positive variance from non-a.e.-constancy. |
| Are shocks bounded? | Yes. `effectiveIncome_abs_bounded` proves a pointwise affine endpoint bound on the compact labor interval. |
| Are endpoint laws or telescoping assumed by N06? | No. They are derived internally by the accepted N05 finite-product theorem. |
| Is any state moment used? | No. N06 supplies no state integrability premise. N05 uses tightness and a union bound for the arbitrary candidate probability law. |
| Is an infinite path space constructed? | No. N05 constructs a separate finite product for the selected finite horizon. |
| Are forbidden economic shortcuts present? | No. There is no bounded stationary support, strict impatience, assumed positive critical consumption, stationary marginal expectation, S05 existence result, ergodicity, or pathwise divergence claim. |
| Are prohibited proof devices present? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. |

## Assumptions and predecessor qualifications

All entries in the supplied `predecessor_qualifications.json` remain mandatory, operative, and
unsuperseded. In particular, N04 remains an almost-everywhere statement and does not provide
pointwise equality on every shock history; N05 is the accepted generic finite-product
reconstruction that performs the required transfer and finite intersection. N03 is not used and
N07 is not assembled in this gate. S01 identifies the canonical household kernel but proves no
invariant-law existence. Boundary marginal qualifications remain preserved through N04; N06
introduces no marginal or boundary conversion of its own.

## Source, dependency, and scope audit

The formal dependency route is exactly S01, N04, and N05. A94 printed p. 669 / PDF p. 12, notes
20--21, distinguishes stationary implications from pathwise claims; CW00 supplies background and
A93 supplies household context. The two-string stationary proof is a new reconstruction, not a
cited source theorem. No fresh source-PDF inspection is claimed by this gate.

All four new public helpers are confined to `Aiyagari1994/Analysis/M07B2/`. They and the N06
target have `#check`, `assert_no_sorry`, and `#print axioms` in both the global audit and
`Probes/M07B2Signatures.lean`. This gate changes only N06 to **REVIEW_READY** and does not advance
N07, Stage 08, or later work.
