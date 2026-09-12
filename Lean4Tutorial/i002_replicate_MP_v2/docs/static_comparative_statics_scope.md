# M7 static comparative-statics scope

Milestone 7 proves global order results for already-existing static equilibria.
It does not differentiate an equilibrium path, select an equilibrium, or prove
that the compared equilibria exist.

## Results

| Parameter change | Fixed-theta cutoff | Equilibrium cutoff | Equilibrium theta | Separation | Finding | Unemployment | Status |
|---|---:|---:|---:|---:|---:|---:|---|
| `p ↑` | strictly ↓ | strictly ↓ | strictly ↑ | weakly ↓ | weakly ↑ | weakly ↓ | COMPLETE - GREEN |
| `b ↑` | strictly ↑ | strictly ↑ | strictly ↓ | weakly ↑ | weakly ↓ | weakly ↑ | COMPLETE - GREEN |
| `lambda ↑` | weakly ↓ | strictly ↓ | deferred to M8 | not signed in M7 | not signed in M7 | not signed in M7 | COMPLETE - GREEN for shown cutoff results |
| `r ↑` | weakly ↑ | ambiguous / deferred | strictly ↓ | not signed in M7 | not separately formalized | not signed in M7 | COMPLETE - GREEN for shown orders |
| `sigma ↑` | deferred | deferred | deferred | deferred | deferred | deferred | M8 |

The general fixed-`theta` `lambda` and `r` entries are weak under the current
primitive architecture. The strict refinements
`cutoff_strictAnti_shockArrival_at_fixed_theta_of_expectedExcess_pos` and
`cutoff_strictMono_discountRate_at_fixed_theta_of_optionValue_pos` are proved
when the expected excess at the lower-cutoff comparison point is positive;
the strict `r` theorem additionally assumes `0 < lambda`.

The paper's strict prose is therefore recovered under explicit positive option
value. Deriving that positivity from the phrase "upper support" would require
an exact-support or upper-tail-richness theorem stronger than the present
almost-sure upper-bound field. This is a paper-fidelity refinement, not an
existence issue and not an AMBER inheritance from M5.

The fixed-tightness theorems compare two cutoffs satisfying the
job-destruction condition at a common `theta`; they do not use job creation.
The full-equilibrium theorems compare arbitrary supplied
`ReducedEquilibrium` witnesses and combine the JD and JC conditions.  Initial-
impact flow theorems hold a common current unemployment stock `u` fixed.  The
stock theorems compare the unemployment and employment rates stored in two
supplied `SteadyStateEquilibrium` witnesses.

The `p` and `b` results are global because their direct shifts and the opposing
monotonicity of the JD and JC curves determine the pairwise order without a
local derivative argument.  The robust `lambda` argument determines the
cutoff, but its tightness effect requires the paper's additional Appendix
inequality comparing option value with the productivity gap.  For `r`, the
robust order determines lower tightness while the cutoff response contains
opposing forces and remains ambiguous.  Dispersion changes both current flow
productivity and continuation option value, so `sigma` is also reserved for
M8.

For aggregate net productivity, cutoff ordering yields only a weak separation-
hazard order because the shock law may assign no mass between the two cutoffs.
Tightness ordering yields only a weak job-finding order because
`MatchingAssumptions.workerMeetingRate_monotoneOn` is weak.  Consequently the
steady unemployment and employment results are weak.  Strict stock effects
would require, for example, strict worker-meeting monotonicity or positive
shock mass between the ordered cutoffs.

No vacancy-stock sign is asserted.  Since vacancies equal `theta * u`, higher
tightness and lower unemployment move that product in opposite directions;
this is the ambiguity identified in the paper.

## Assumption discipline

The public equilibrium theorems carry `CoreEconomicAssumptions`,
`ShockAssumptions`, and `MatchingAssumptions`.  Their proof terms use positive
JD/JC coefficients, probability and first-moment facts needed by expected-
excess monotonicity, positive and strictly decreasing vacancy meeting rates,
and—only for flow implications—the weak monotonicity of the worker meeting
rate.  The strict lower-tail monotonicity lemma itself needs only finiteness of
the measure, not atomlessness.  Shock normalization, matching elasticity,
differentiability, and `StaticExistenceAssumptions` are not used.

Thus the M7 core is GREEN as a family of universal conditional comparative-
static theorems.  Any future wrapper that obtains selected equilibria from
M5's lower-crossing existence assumption must be graded AMBER—inherited from
M5—without changing the grade of these pairwise results.

The core dependency path is
`StaticCurves -> FixedTightness -> EquilibriumOrders`; it does not import the
M5 conditional-existence layer. `FlowImplications` combines
`SteadyState.Unemployment` with `EquilibriumOrders`, without importing the M6
transported-existence module `FullEquilibrium`.

## Deferred M8 contract

M8 may add an Appendix-specific differentiability and elasticity layer to
study the equilibrium tightness response to `lambda`, the equilibrium cutoff
response to `r`, dispersion comparative statics, and equations (A1)-(A12).
M7 contains no placeholder for those conclusions.
