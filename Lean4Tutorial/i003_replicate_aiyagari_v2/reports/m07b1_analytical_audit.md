# M07B1 analytical audit

This is the user-authorized `USER_COVERAGE_REVISION`, substantive revision 1. The separate
signature-record parser repair consumed no substantive revision and changed no mathematical bytes;
the preserved Medium submission remains under controller-owned runtime state. This audit covers the
revised Sol High proof bodies and does not claim that the required fresh independent Astra review has
occurred.

| Required question | Answer and proof evidence |
|---|---|
| Are horizons realized on one infinite path space? | No. `coupledHistoryLaw pi nu n` is constructed separately for each finite `n` by recursive finite products. |
| Is the initial state common and independent of both strings? | Yes. `CoupledHistorySpace E 0 = NNReal`; every successor appends an independent pair with law `nu.prod nu`. Both recursive resource paths therefore share exactly the same initial coordinate. |
| Is N04 strengthened from a.e. to pointwise history equality? | No. `kernel_ae_to_innovation_ae` pulls the N04-shaped stationary one-step a.e. premise back to `pi.prod nu`. `coupled_consumption_constant` inductively intersects only finitely many full-measure events. |
| Is the discounted identity exact? | Yes. `coupled_telescope` derives `D_n = R⁻¹^n (Z_n-Z'_n)` a.e. from the primitive recursion and the finite-event consumption bridge; it is not a public premise. |
| Are the endpoint laws derived? | Yes. `resourceKernel_comp_eq_map` converts kernel invariance to one-step pushforward stationarity, and `coupled_endpoint_laws` inducts over the actual resource recursion to prove both terminal maps have law `pi`. |
| Does the state-law argument assume a moment? | No. `probability_nnreal_tail_le` uses tightness of the single probability law. `scaled_difference_event_le_two_tails` uses only the common marginal and a union bound. |
| Why do second moments converge along changing spaces? | A uniform pointwise bound on `D_n` and a small large-deviation event give an explicit split inequality. No dominated-convergence theorem or common infinite probability space is used. |
| Is shock boundedness used? | Yes. It gives `MemLp shock 2`, a uniform geometric bound `2*B/(1-R⁻¹)` for every finite discounted difference, and integrability of its square. |
| Is the variance identity exact? | Yes. `pairedShock_secondMoment` proves the one-period `2*Var(shock)` identity, and `coupledDiscountedDifference_moments` inducts over independent shock pairs to prove `E[D_n²] = 2*Var(shock)*∑_j R⁻¹^(2(j+1))`. |
| Is variance positivity assumed? | No. `variance_pos_of_not_ae_const` derives it from boundedness and the premise that the shock is not a.e. constant, using the proved variance-zero characterization. Essential-endpoint nondegeneracy can discharge this premise later. |
| Are household assumptions present? | No. N05 is generic finite-product mathematics with primitive `c`, `step`, recursion, stationarity, and a.e. constancy inputs. There is no utility, policy optimality, positive consumption, stationary support, strict impatience, or S05 invariant law. |
| Are boundary ENNReal conversions controlled? | Yes. Tail probabilities stay in `ENNReal`; finiteness from probability measures is supplied before `toReal`, and `ofReal` conversion uses an explicitly positive real tolerance. |
| Are stronger conclusions asserted? | No. N05 proves only that the supplied primitive recursion, invariance, and stationary a.e. constancy interface is contradictory. N06 and N07 remain unformalized. |
| Are prohibited devices present? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, numerical model, or infinite path space. |

## Assumptions and predecessor qualifications

All entries in the supplied `predecessor_qualifications.json` remain operative and unsuperseded.
In particular, N04 retains only almost-everywhere endpoint consumption equality under
`pi.compProd(P^n)`; N05 does not reinterpret it as pointwise equality. N01--N04 do not construct
an invariant law, and S05 is not imported. The right-marginal boundary qualifications do not
enter this generic gate. Historical source, evidence, documentation, and metadata qualifications
retain their original attribution.

## Source, dependency, and scope audit

N05 has no theorem-contract dependency beyond installed Mathlib. A94 printed p. 669 / PDF p. 12
and CW00 supply motivation and the stationary-versus-pathwise distinction; the two-string proof
is a new reconstruction, not a cited theorem. No fresh source-PDF inspection is claimed.

The target and thirty-eight public helper declarations have `#check`, `assert_no_sorry`, and
`#print axioms` in both the global audit and `Probes/M07B1Signatures.lean`. M07B1 changes only N05 to
**REVIEW_READY** and does not advance N06, N07, Stage 08, or later work.

## Required substantive-coverage map

| Coverage item | Status | Proof declarations |
|---|---|---|
| `telescoping identity = derived` | Derived | `coupled_consumption_constant`, `coupled_telescope`; the public target has no `hidentity` premise. |
| `endpoint pi laws = derived` | Derived | `resourceKernel_comp_eq_map`, `coupled_endpoint_laws`; the public target has no `hlawZ` or `hlawZ'` premise. |
| `N04 bridge = a.e.-compatible` | A.e.-compatible | `kernel_ae_to_innovation_ae` consumes the stationary-kernel a.e. premise; `coupled_consumption_constant` uses only finite pullbacks/intersections. No pointwise history constancy is introduced. |
| `state moments = absent` | Absent | The public signature contains no state-integrability premise. `probability_nnreal_tail_le`, `scaled_difference_event_le_two_tails`, and `secondMoment_le_of_uniform_bound` implement the tightness/union-bound route. |
