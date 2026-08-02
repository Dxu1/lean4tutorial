# M8b.1 implicit-function scope

**Status:** COMPLETE - GREEN, reviewed 2026-08-01, relative to a supplied
regular reduced equilibrium and `AppendixIFTAssumptions`.

M8b.1 uses the installed Mathlib theorem `ContDiffAt.implicitFunction`, via
the project wrapper `exists_localImplicitCutoffPath`. The wrapper accepts a
locally `C¹` scalar residual, its proved base root, and a proved nonzero cutoff
derivative. It returns a noncomputably selected local `C¹` cutoff function,
the neighborhood residual equation, and Mathlib's local graph uniqueness.
The exact installed API is recorded in [`m8b_ift_api_notes.md`](m8b_ift_api_notes.md).

The parameterized residuals are
`Primitives.fixedTightnessSigmaResidual` and
`Primitives.lambdaStaticResidual`. For a supplied
`R : ReducedEquilibrium P`, the base roots are proved by
`ReducedEquilibrium.fixedTightnessSigmaResidual_base_eq_zero` and
`ReducedEquilibrium.lambdaStaticResidual_base_eq_zero`; neither is an
assumption. The cutoff partials are proved nonzero by
`fixedTightnessSigma_cutoffDerivative_pos` and
`lambdaStaticResidual_cutoffDerivative_neg`. The first uses
`sigma * (r + lambda * F(d)) / (r + lambda) > 0`; the second uses positive
JD-implied tightness, `d < epsUpper`, `q > 0`, `q' < 0`, and the positive JD
curve derivative.

`AppendixIFTAssumptions` adds only `ContDiffOn ℝ 1 P.q (Set.Ioi 0)`. This is
primitive local analytic regularity consistent with the paper's use of `q'`
and elasticity. It assumes neither an equilibrium path, a residual root,
Jacobian invertibility, nor any derivative sign. Expected-excess `C¹`
regularity is derived from `hasDerivAt_expectedExcess` and CDF continuity using
Mathlib's `contDiffAt_one_iff`.

`ReducedEquilibrium.exists_fixedTightnessSigmaPath_of_ift` constructs the
fixed-tightness JD path and
`ReducedEquilibrium.exists_lambdaEquilibriumPath_of_ift` constructs the lambda
cutoff and JD-implied tightness path, proving local JD and product-form JC.
Their selected versions feed `m8b_fixedTightness_capstone`,
`m8b_lambda_capstone`, and `m8b1_implicit_paths_capstone`. The construction
starts from the supplied `R`; it does not use `StaticExistenceAssumptions`, an
M5-selected witness, or M5's AMBER existence theorem.

The selected path is noncomputable. Mathlib supplies local uniqueness of the
implicit residual graph. The M8 derivative signs also hold for every supplied
differentiable equilibrium path, so they do not depend on arbitrary
selection. No global parameter-path uniqueness is claimed.

> M8b.1 removes the path-closure assumption for equation (11) and the lambda
> Appendix block. The discount and dispersion blocks remain path-conditional
> until M8b.2.

Human review graded the generic wrapper, fixed-tightness sigma construction,
lambda construction, and combined M8b.1 bridge COMPLETE - GREEN. This grade is
for the strengthened theorem under the explicit primitive technical condition
`AppendixIFTAssumptions.q_contDiffOn_pos`; it does not claim that the paper
explicitly states continuous differentiability of `q`. Base roots come from
the supplied equilibrium, nondegeneracy is proved, and no derivative sign is
assumed. No global path or global equilibrium uniqueness is claimed.

Accordingly, the M8b.1 layer is COMPLETE - GREEN, while overall
M8 remains COMPLETE - AMBER. M8b.2 is limited to locally `C¹` discount and
dispersion residuals, derived nondegeneracy, IFT path constructors, and bridges
to the already reviewed M8 identities; it must not begin Section 4.
