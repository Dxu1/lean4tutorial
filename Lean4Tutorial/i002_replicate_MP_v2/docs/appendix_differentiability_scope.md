# M8 Appendix differentiability scope

## A. Results proved

Milestone 8 proves equation (11) and Appendix equations (A1)-(A12) along
supplied differentiable paths satisfying the local job-destruction and
job-creation equations. It proves that a higher shock-arrival rate has negative
cutoff and tightness derivatives, that a higher discount rate has a negative
tightness derivative while its cutoff derivative has the exact ambiguous sign
condition in (A8), and that higher dispersion has positive tightness and cutoff
derivatives when `b ≤ p`.

## B. Analytic primitive results

The analytic layer derives continuity of the induced CDF from atomlessness and
proves the fundamental-theorem-of-calculus derivative of `expectedExcess`.
Equation (A4) uses atomlessness and the almost-sure upper bound. The moment
identity needed for (A11) uses zero mean, unit second moment, and the same upper
bound. These facts are proved from the existing measure primitives; no arbitrary
expectation or independent CDF is introduced.

## C. Exact path closure

`LocalReducedEquilibriumPath` and `FixedTightnessSigmaPath` contain
differentiability and exact local JD/JC closure equations. They contain no sign
fields, no Appendix identities, and no comparative-static conclusions. The
reported derivatives are therefore consequences of exact equilibrium closure,
not assumed answers.

## D. Why the overall grade is AMBER

The analytic infrastructure is COMPLETE - GREEN. The supplied-path results are
COMPLETE - AMBER because M8 does not prove that a locally differentiable
equilibrium selection exists. A path premise is mathematically non-circular,
but it substitutes for the implicit-function-theorem construction that would
make the Appendix result fully unconditional relative to a regular equilibrium
point.

## E. No M5 inheritance

No M8 theorem takes `StaticExistenceAssumptions`, and no theorem selects an M5
existence witness. Every result is universal over a supplied local path. Thus
the AMBER grade is caused by the missing local path construction, not inherited
from M5's global lower-crossing assumption.

## F. Shock-arrival convention

Low-level lambda proofs use the core boundary convention `0 ≤ lambda`. The M8
lambda capstone additionally takes `0 < lambda`, making the paper's interior
Poisson-arrival convention explicit even though the algebraic sign proof is
valid at the boundary.

## G. M8b route to GREEN

A future, separately reviewed M8b can close the gap by:

1. defining the two-equation JD/JC residual map;
2. proving differentiability in parameters, cutoff, and tightness;
3. identifying its Jacobian with the Appendix coefficient matrix;
4. proving the required Jacobian determinant is nonzero at a supplied regular
   equilibrium point;
5. applying a suitable local implicit-function theorem; and
6. constructing `LocalReducedEquilibriumPath` and reusing the present M8
   theorems unchanged.

The supplied equilibrium point need not come from M5. A separate wrapper that
selects it using M5 would visibly inherit M5's AMBER existence qualification.

## H. Deferred optional strengthening

A direct derivative theorem for the worker meeting rate is optional and
deferred. The current Appendix layer needs only differentiability of `q` for
positive tightness and the economically standard elasticity restriction
`0 < eta < 1`.
