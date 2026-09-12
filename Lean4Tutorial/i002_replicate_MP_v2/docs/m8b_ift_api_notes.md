# M8b installed Mathlib implicit-function API

## Source of truth

The installed source is
`.lake/packages/mathlib/Mathlib/Analysis/Calculus/ImplicitContDiff.lean`, which
imports `Mathlib.Analysis.Calculus.ImplicitFunction.ProdDomain` and the
continuous-differentiable inverse-function theorem.

## Selected theorem

M8b.1 uses `ContDiffAt.implicitFunction` for an uncurried scalar residual
`f : ℝ × ℝ → ℝ` at `u = (t0,d0)`:

```lean
noncomputable def ContDiffAt.implicitFunction
    (cdf : ContDiffAt ℝ n f u)
    (pn : n ≠ 0)
    (if₂ : (fderiv ℝ f u ∘L ContinuousLinearMap.inr ℝ ℝ ℝ).IsInvertible) :
    ℝ → ℝ
```

The relevant companion theorems are:

- `ContDiffAt.implicitFunction_apply_self`, giving `g t0 = d0`;
- `ContDiffAt.eventually_apply_implicitFunction`, giving locally
  `f (t, g t) = f (t0,d0)`;
- `ContDiffAt.hasStrictFDerivAt_implicitFunction`, giving the derivative;
- `ContDiffAt.contDiffAt_implicitFunction`, preserving `C¹` regularity;
- `ContDiffAt.eventually_apply_eq_iff_implicitFunction`, exposing local
  uniqueness of the graph.

The spaces are Banach spaces over an `RCLike` field; M8b specializes all three
spaces to `ℝ`. The regularity hypothesis is `ContDiffAt ℝ 1` for the
uncurried residual. Invertibility is represented by the typeclass proposition
`IsInvertible` for the cutoff partial continuous linear map. M8b derives that
instance from the proved nonzero scalar cutoff derivative; it is not an
economic or path assumption.
