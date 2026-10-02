# M08A analytical audit

This audit covers B01 only and does not claim that the required independent review has occurred.

| Required question | Answer and proof evidence |
|---|---|
| Are the kernels probability Markov kernels? | Yes. The exact signature has `IsMarkovKernel` instances for every `Pseq n` and for `P`. The norm bounds used in the tail estimate depend on these instances. |
| Is Feller continuity explicit? | Yes. `hFellerSeq` covers every approximating kernel and `hFeller` covers the limiting kernel for every bounded continuous test. The latter constructs the fixed bounded continuous test used under weak convergence. |
| Is convergence local rather than global? | Yes. `hLocal` is `TendstoLocallyUniformly`; the proof invokes it only on the compact set selected from tightness. |
| Is the compact/tail bridge derived? | Yes. On the compact set the integral error is bounded by `eps/2`. On its complement, Markov expectation bounds give `norm(g_n-g)≤2*norm f`, and tightness gives the uniform tail mass `eta=eps/(4*(norm f+1))`, yielding a tail error strictly below `eps/2`. |
| Is weak convergence used only for bounded continuous tests? | Yes. It is applied to `f` and to the Feller-packaged limiting test `P f`; no unbounded integral or moment is passed through a weak limit. |
| Is invariance proved as measure equality? | Yes. Kernel integration and the supplied `P_n` invariance identities yield equality of integrals, and bounded-continuous separation proves `(mu.bind P)=mu`. |
| Are compact support or moment assumptions present? | No. Tightness is assumed directly for the family, but no member has bounded support and no first or higher moment is assumed. |
| Are household or boundary assumptions imported? | No. The module imports only the generic helper and Mathlib topology/measure APIs. It contains no household primitives, prices, policies, impatience, or critical-boundary theorem. |
| Are prohibited devices present? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model. |

## Scope and qualifications

All supplied predecessor qualifications remain mandatory, operative, and unsuperseded. B01 does
not mention marginal values, consumption, drift, stationary moments, income support, or price
normalization, so it neither uses nor strengthens those predecessor conclusions. In particular,
the accepted restrictions that weak convergence supplies no unbounded-moment convergence and
that S06's common compact support does not extend to the critical boundary are preserved.

The proof is the authorized project reconstruction related to the compact argument in SLP89
Theorem 12.13, with the noncompact tail passage proved directly. It is not attributed as a
literal SLP theorem. B02 and B03 remain unformalized; this gate establishes none of their
economic hypotheses or conclusions.

The three new public declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage
in both `Probes/M08ASignatures.lean` and `Audit.lean`. Their printed transitive axioms are exactly
`propext`, `Classical.choice`, and `Quot.sound`.
