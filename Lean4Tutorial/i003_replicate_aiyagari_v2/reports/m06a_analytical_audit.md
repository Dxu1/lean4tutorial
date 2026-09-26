# M06A analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Is the stationary object canonical? | Yes. `M06A.stationaryLaw` selects the S05 existence witness, while `stationaryLaw_unique` proves every invariant full-space probability law equals it. Continuity is therefore independent of the choice witness. |
| Are utility, beta, and the iid labor law fixed? | Yes. Prices vary only through `HouseholdPrimitives.withPrices`; utility, beta, income support, and the labor probability law remain definitionally fixed. IID remains the kernel construction, not a new premise. |
| Is strict impatience local rather than uniform up to the boundary? | Yes. The domain is `M06A.ImpatientPrices m`. For a sequence converging to a strictly impatient price, `eventually_common_stationary_support` chooses a neighborhood-specific margin `gamma < 1`. No bound is asserted as `beta*R` approaches one. |
| Is the varying lower endpoint handled correctly? | Yes. All tightness and limit arguments use the fixed full-space interval `[0,B]`. Price-specific economic intervals `[e_min(q),B]` are used only to construct invariant laws, then S05 uniqueness identifies them with the canonical full-space law. No varying subtype spaces are silently identified. |
| Is the common compact interval derived from primitives? | Yes. Sequence convergence yields eventual return, impatience, upper-income, and income-span bounds. D03 produces one finite `B`; `stationaryLaw_support_of_common_bound` combines forward invariance, compact economic-kernel existence, and S05 uniqueness to put every tail law on `[0,B]`. |
| Is joint kernel continuity proved? | Yes. For every bounded continuous test, `parameterized_testStep_continuous` integrates the jointly continuous affine transition and H06 policy against the fixed compact labor law under a constant bound. `restricted_testStep_continuous` upgrades this to uniform-norm continuity on `[0,B]`. |
| Is every subsequential limit explicitly shown invariant? | Yes. `subsequential_limit_invariant` splits the varying invariance identity into uniform convergence of the one-step test on `[0,B]` and weak convergence against the fixed limiting test. It then identifies both probability measures through bounded-continuous tests. |
| Does uniqueness identify the limit? | Yes. The limiting invariant law is identified by S05 full-space uniqueness. Prokhorov compactness and the unique-cluster-point criterion then give convergence of the whole sequence. |
| Is the conclusion only weak continuity? | Yes. The codomain is Mathlib's weak topology on `ProbabilityMeasure Resources`. No total-variation or moment convergence is claimed, and no unbounded integrand is passed through weak convergence. |
| Are zero-state marginal qualifications preserved? | Yes. S06 uses no value-marginal object. It never evaluates `rightMarginalValue m 0`; `zeroRightMarginal` and all predecessor boundary qualifications remain untouched. |
| Are prohibited assumptions or bypasses introduced? | No. There is no density, finite-state law, positive minimum income, stationary moment, finite-time entry, policy differentiability, continuum LLN, `sorry`, `admit`, project axiom, `native_decide`, `unsafe`, or numerical model. |

## Source correspondence

The indexed M06A extracts were hash-checked and rendered with Poppler for visual inspection. A93 extraction pages 1--2 correspond to printed pp. 39--40 / original PDF pp. 40--41. Proposition 5 states the unique stable invariant distribution and its continuity in the price parameters, and its proof points to SLP Theorem 12.13. SLP89 extraction pages 1--2 correspond to printed pp. 384--385 / original PDF pp. 394--395. Theorem 12.13 assumes a compact state space, joint weak continuity of the transition law, and uniqueness; its proof takes weakly convergent subsequences, proves each limit invariant through uniform convergence of transition operators, and identifies it by uniqueness. S06 is an explicit reconstruction: D03 supplies the locally common compact interval in the unbounded resource model, H06 supplies joint policy continuity, and S05 supplies full-space uniqueness.

## Scope and inherited qualifications

All entries in `tmp_orchestration/contexts/M06A/predecessor_qualifications.json` remain operative and unsuperseded. In particular, D03 supplies weak upper drift and local forward invariance, not finite-time entry; S05 supplies weak full-space convergence without moments, not total-variation or moment convergence; H06 covers all admissible returns but S06 restricts its stationary-law domain to strict impatience. The maintained model remains bounded utility, continuous resources, and a general compact iid labor law. Earlier source-inspection and documentation-evidence qualifications retain their original gate attribution.

S06 is submitted as **REVIEW_READY** only. This audit does not certify A01 or any later contract.
