# M09A1 analytical audit

This audit covers F01 only and does not claim independent adequacy review.

| Required bridge | Derived evidence |
|---|---|
| Exact PRODUCTION profile | `ProductionRegularity` has precisely zero output, nonnegative-domain continuity, positive-domain C2 regularity, positive marginal product, negative second derivative, both endpoint limits, and `0<delta<1`. |
| No assumed schedules | `ProductionData` contains only output and depreciation. `capitalDemand` and `firmWage` are constructed definitions. |
| Existence for every untruncated rate | `FirmRate p = Ioi (-delta)` makes `r+delta>0`; the two marginal-product limits and IVT give a positive solution. |
| Uniqueness | `production_marginal_strictAntiOn` follows from negative second derivative and makes the positive solution unique. |
| Global optimization | `capitalDemand_unique_profit_maximizer` quantifies over every `K>=0` unequal to demand and proves strict profit loss using strict-concavity secant inequalities. |
| Wage sign | `firmWage_positive` derives `f'(K)<f(K)/K` from strict concavity and `f(0)=0`; positivity is not a field or premise. |
| Demand continuity | The positive-capital demand map is surjective and antitone; order-dual monotone-surjection continuity proves continuity of the inverse. |
| Wage continuity | The marginal equation rewrites wage as `f(K(r))-K(r)(r+delta)`, a composition of continuous functions. |
| Production nonvacuity | `sqrtProduction_regular` verifies `sqrt(K)` and `delta=1/2`, including both derivative limits. |
| Full primitive nonvacuity | `fullEquilibriumPrimitives_nonempty` combines the square-root production witness with P03's household primitive witness. |

The general firm theorem has no dependency on P03 and no household, stationary-law, integrability,
asset-supply, equilibrium, lower-bracket, Cobb--Douglas-only, or later-stage premise. All inherited
predecessor qualifications remain mandatory and unsuperseded. The square-root/full-package
witness is a project construction rather than a literal A94 claim.

The contracted wrapper remains in `Aiyagari1994/Firms/Neoclassical.lean`; all supporting proof
declarations and witnesses live in `Aiyagari1994/Analysis/M09A1/`, the capsule helper directory.
Every new public declaration has `#check`, `assert_no_sorry`, and `#print axioms` coverage in the
gate probe and global audit. No `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or
numerical model is used.
