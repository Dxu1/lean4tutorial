# M6 static steady-state adequacy

## Review outcome

Milestone 6 is **COMPLETE - AMBER**. The grading is intentionally split:

- stock completion and paper equation (14): **GREEN**;
- full-state uniqueness: **GREEN**;
- full-state existence: **AMBER**;
- overall M6: **AMBER**.

Human mathematical and economic review found the stock-flow construction,
equation (14), the zero-separation treatment, and the reduced/full
representation faithful to Mortensen--Pissarides (1994). No M7 theorem is
included.

## What is green

For every reduced equilibrium, Lean constructs the unique unemployment stock
that balances creation and destruction. It derives employment as `1 - u`,
vacancies as `theta * u`, and proves

```text
u = lambda * F(cutoff) /
      (lambda * F(cutoff) + theta * q(theta)).
```

This is paper equation (14). The strict economic destruction event
`eps < cutoff` is connected to the induced weak-tail CDF by atomlessness.
Creation equals destruction, the reduced/full maps are exact inverses, and a
full steady state is unique whenever it exists.

The green results are collected by `m6_stock_completion_capstone`. This
theorem takes core, shock, and matching assumptions because its paper-facing
equation (14) component uses the no-atoms CDF bridge. The underlying pure
stock constructor and exact reduced/full representation omit the shock bundle:
they use the strict-tail measure directly and do not need probability
normalization or atomlessness.

## Why existence remains amber

M6 introduces no new existence closure assumption. Its AMBER existence status
is inherited entirely from M5 through
`StaticExistenceAssumptions.lower_crossing`:

```text
StaticExistenceAssumptions.lower_crossing
  -> reducedEquilibrium_nonempty
  -> ReducedEquilibrium.toSteadyStateEquilibrium
  -> steadyStateEquilibrium_nonempty.
```

The conditional result is isolated in `m6_conditional_existence_capstone`.
The combined `m6_full_steady_state_capstone` remains available, but its
existence conjunct is read with this inherited M5 qualification. Nothing in
M6 assumes a full steady state, an unemployment stock, or equation (14) as an
existence premise.

## Interiority and the zero-separation case

Interiority is separate from existence. If the separation hazard is zero,
flow balance and positive job finding imply `u = 0`; because vacancies are
defined as `v = theta * u`, this also gives `v = 0`. The unconditional stock
identity remains valid, but the literal ratio `v / u` is not meaningful.

Accordingly, Lean proves `v = theta * u` without a positive-separation
assumption and proves `v / u = theta` only under
`HasPositiveSeparationAt cutoff`, after establishing `0 < u` and `0 < v`.
This is an admissibility distinction, not an equilibrium-existence closure.

## Route to a green existence theorem

The primitive route is not formalized in M6. One sufficient route would
combine:

- `lambda > 0`;
- enough lower-tail richness or support to make separation positive at a
  suitable cutoff;
- cutoff admissibility, in particular a point below `epsUpper`;
- a matching boundary condition such as right-hand Inada behavior for `q`;
- upper-job profitability, `b < p + sigma * epsUpper`.

The last two items are the documented M5b route. Right-hand Inada behavior for
`q` alone is insufficient: the job-destruction equation must first imply
positive tightness somewhere below the upper state. Proving that route would
derive `StaticExistenceAssumptions.lower_crossing`, upgrading M5 existence and,
without changing the M6 architecture, the inherited M6 existence result.

## Scope boundary

M6 proves no unconditional equilibrium existence, Beveridge-curve slope or
convexity, comparative static, equation (15), dynamic law, or M7 result.
