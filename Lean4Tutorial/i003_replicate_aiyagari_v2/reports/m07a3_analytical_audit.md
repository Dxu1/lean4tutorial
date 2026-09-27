# M07A3 analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Does N03 assume or construct an invariant law at arbitrary returns? | No. The conclusion negates existence of a `ProbabilityMeasure Resources` invariant for the canonical kernel. A candidate law is introduced only after assuming that negation false. S05 is not imported or invoked. |
| Is the return branch exactly supercritical? | Yes. The sole return comparison is `1 < m.beta * m.prices.grossReturn`. No strict-impatience premise is present. |
| How is the zero boundary handled? | The real placeholder tests `extendedRightMarginalValue m z = top`; at zero this definition reduces through the economic `zeroRightMarginal : ENNReal`. The proof never uses `rightMarginalValue m 0`. N01 makes the infinite branch null under the candidate invariant law. |
| Is a stationary marginal moment assumed? | No. N01 supplies conditional integrability under the labor law almost everywhere. The household pushforward transports this to `Integrable q (householdKernel m z)` almost everywhere. The proof never forms `Integral q pi`; only the bounded transform `q/(1+q)` and bounded conditional transforms are integrated under `pi`. |
| Why is an almost-everywhere helper needed? | N02 deliberately exposes a reusable pointwise interface, whereas the economic N01 theorem produces finiteness, conditional integrability, and H09's real inequality only `pi`-almost everywhere. The gate-local helper repeats N02's approved bounded-transform argument with those two premises almost everywhere, preserving the null-set distinction instead of silently asserting universal boundary finiteness. |
| Is the conditional mean strictly positive where strictness is used? | Yes. The placeholder is positive at every state. On the full-measure set where it is conditionally integrable, positivity under the Markov probability law makes its conditional integral strictly positive. |
| Is stationarity applied only to bounded data? | Yes. It identifies the stationary integrals of `P(psi o q)` and `psi o q`, both bounded between zero and one. |
| Does the proof use the approved Jensen route? | Yes. The helper proves the same exact tangent-gap inequality as N02, then the chain `P psi(q) <= psi(Pq) <= psi(gamma*Pq) <= psi(q)`. Equal bounded endpoint integrals force equality of the middle terms, and `Pq>0` forces `gamma=1`. |
| Is the income law still general? | Yes. The theorem uses `IncomeNondegenerate` for a general compact iid law. It assumes neither atoms nor a density and does not replace the law by P03's two-point witness. |
| Are stronger conclusions introduced? | No. N03 proves only supercritical nonexistence of an invariant household resource law. It proves no critical-return result, pathwise divergence, convergence, moment divergence, consumption constancy, aggregation, or equilibrium claim. |
| Are prohibited devices present? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, numerical model, or changed mathematical premise. |

## Assumptions and predecessor qualifications

The public target retains exactly BASIC through `HouseholdPrimitives`, explicit SMOOTH through
`UtilitySmooth`, NONDEGENERATE through `IncomeNondegenerate`, and the strict supercritical branch.
The smoothness argument is passed to N01 as required by its accepted signature; no stronger
curvature or positivity theorem is imported.

All 640 entries in the supplied `predecessor_qualifications.json` remain operative and
unsuperseded. In particular, candidate invariant laws at arbitrary returns remain hypotheses;
H09's real inequality is used only after N01 establishes finite initial extended marginal almost
everywhere; `zeroRightMarginal : ENNReal` remains the zero-state object; conditional integrability
is never promoted to stationary `E[q]`; H11 stays local to positive consumption; and H10/H12 are
not used at supercritical or critical corners. The accepted source-inspection, evidence,
documentation, and metadata qualifications retain their original gate attribution.

## Source, dependency, and scope audit

The formal route uses exactly H09 through N01's accepted real inequality, S01 through the exact
household-kernel test integral, N01 for zero-state resolution and conditional finiteness, and N02's
approved bounded-Jensen construction through the gate-local almost-everywhere interface. A94
printed p. 669 / PDF p. 12 supplies the stationary-versus-pathwise context; CW00 supplies
background. The bounded-transform proof is a new reconstruction motivated by those approved
sources, not a theorem copied from them. No fresh source-PDF inspection is claimed.

Both new public declarations have `#check`, `assert_no_sorry`, and `#print axioms` in the global
audit and assigned signature probe. M07A3 changes only N03 to **REVIEW_READY**. It does not
advance N04, N05--N07, Stage 07b, Stage 08, or any later contract.
