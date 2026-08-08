# M8b implicit-function scope

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

> M8b.1 removed the path-closure assumption for equation (11) and the lambda
> Appendix block. At that review point, discount and dispersion remained
> path-conditional; M8b.2 now supplies their reviewed IFT constructions.

Human review graded the generic wrapper, fixed-tightness sigma construction,
lambda construction, and combined M8b.1 bridge COMPLETE - GREEN. This grade is
for the strengthened theorem under the explicit primitive technical condition
`AppendixIFTAssumptions.q_contDiffOn_pos`; it does not claim that the paper
explicitly states continuous differentiability of `q`. Base roots come from
the supplied equilibrium, nondegeneracy is proved, and no derivative sign is
assumed. No global path or global equilibrium uniqueness is claimed.

Accordingly, the M8b.1 layer is COMPLETE - GREEN. M8b.2 is limited to locally
`C¹` discount and dispersion residuals, derived nondegeneracy, IFT path
constructors, and bridges to the already reviewed M8 identities; it does not
begin Section 4.

## M8b.2 discount and dispersion paths

**Status:** COMPLETE - GREEN, reviewed 2026-08-02, relative to a supplied
regular reduced equilibrium and `AppendixIFTAssumptions`.

The parameterized residuals are `Primitives.discountStaticResidual` and
`Primitives.dispersionStaticResidual`; their JD graphs are
`discountJobDestructionTheta` and `dispersionJobDestructionTheta`. For every
supplied `R : ReducedEquilibrium P`, the base roots and base tightness are
derived from `R.jobDestructionMeasure` and `R.jobCreationProduct`. Theorems
`discountStaticResidual_cutoffDerivative_neg` and
`dispersionStaticResidual_cutoffDerivative_neg` prove both base cutoff
partials strictly negative. Their nonzero corollaries are derived, not
assumed.

Joint local `C¹` regularity is proved for both JD graphs and scalar residuals.
The discount proof is local around `P.r > 0` and makes no global smoothness
claim across `r = -lambda`; the dispersion proof is local around
`P.sigma > 0` with constant positive denominator `r + lambda`.

`exists_discountEquilibriumPath_of_ift` and
`exists_dispersionEquilibriumPath_of_ift` construct the local cutoffs, define
tightness from the relevant JD graph, and prove local JD and product-form JC.
Their selected versions feed `m8b_discount_capstone` and
`m8b_dispersion_capstone`. Normalization and `b ≤ p` are not used for path
construction; they enter only the dispersion sign capstone. The discount
capstone preserves the exact A8 iff condition rather than asserting an
unconditional cutoff sign.

`ReducedEquilibrium.m8b_full_appendix_capstone` combines the fixed-tightness,
lambda, discount, and dispersion routes without taking a path object,
`StaticExistenceAssumptions`, an M5-selected equilibrium, a derivative sign,
or a nondegeneracy assumption. Human review found the discount path,
dispersion path, and full IFT-derived Appendix capstone COMPLETE - GREEN.
Together M8b.1 and M8b.2 derive all four paths, so the full Appendix package is
COMPLETE - GREEN relative to a supplied regular reduced equilibrium,
`AppendixMatchingAssumptions`, `AppendixIFTAssumptions`, and the explicit sign
conditions such as `0 < P.lambda` and `P.b ≤ P.p`.

The original M8 supplied-path theorem layer remains logically valid and its
historical AMBER grade is preserved. No `StaticExistenceAssumptions` or
M5-selected equilibrium is used in the GREEN route: residual roots are
derived, cutoff nondegeneracy is proved, and neither a path nor derivative sign
is assumed. `AppendixIFTAssumptions.q_contDiffOn_pos` remains an explicit
primitive technical strengthening. A future wrapper selecting the supplied
base equilibrium from primitives would separately inherit M5's AMBER
existence qualification.

**Human-review checklist:** [x] Human mathematical/economic review is complete
(2026-08-02).
