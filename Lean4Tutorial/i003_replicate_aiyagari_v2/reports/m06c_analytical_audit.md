# M06C analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Is the stationary law constructed rather than assumed? | Yes. `M06C.stationaryLaw` and `M06C.stationaryBound` select witnesses only from `stationaryLaw_exists_unique_global`. `M06C.stationaryLaw_properties` recovers S05's support and invariance clauses. |
| Are all real aggregates integrable before use? | Yes. The target explicitly returns integrability of resources, shifted assets, net assets, consumption, and effective income. The first four follow from the S05 compact support interval and continuity; effective income follows from compact labor support. |
| Does the proof smuggle moment convergence into S05? | No. S05 is used only for existence, compact support, and invariance. Each moment is established directly by restriction to the compact support; no weak-limit or unbounded-test argument is used. |
| Is the resource identity proved first? | Yes. `M06C.stationary_resource_identity_of_invariant` proves `E_pi z = R E_pi A + E_nu e` from the invariant image law and an integrable product calculation. The asset-supply and consumption identities are separate later conjuncts. |
| Is IID represented correctly? | Yes. `M06C.resourceImage_eq_lawStep` maps `pi.prod m.income.law` through the household transition. This is the current resource/current iid-labor product law, not a continuum law of large numbers. A01 supplies the equivalent predetermined net-asset/current-labor interpretation. |
| Is asset supply net rather than shifted? | Yes. `stationaryAssetSupply m phi pi` is `Integral (A(z)-phi) d pi`, and `M06C.stationaryAssetSupply_eq_mean_shifted_sub` proves `S=E_pi A-phi`. |
| Is the original-price bridge explicit? | Yes. Both budget theorems require `p : OriginalPrices m.income` and `m.prices = p.normalized`. Hence `R=1+r` and the intercept is `-r*phi`; P01 is not strengthened to an unconditional bridge or No-Ponzi result. |
| Is labor mean one assumed? | No. The final identity retains `w * Integral l d nu`. A later general-equilibrium specialization may use a separate `LaborMeanOne` premise. |
| Does the arbitrary-law lemma have legitimate hypotheses? | Yes. `M06C.stationary_budget_of_invariant` accepts invariance and explicit finite resource, shifted-asset, and consumption first moments. This is suitable for an equilibrium record. The canonical theorem separately derives those moments. |
| Are state space and income scope preserved? | Yes. Resources and assets remain continuous; labor is the general compactly supported law. No finite support, atom, density, discretization, or numerical certificate is introduced. |
| Are zero-boundary qualifications preserved? | Yes. A02 uses no marginal-value declaration. It never substitutes `rightMarginalValue m 0` for `zeroRightMarginal`, and it asserts no stationary marginal integrability. |
| Are prohibited assumptions or bypasses introduced? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, absorbing-bound assumption, moment-convergence assumption, continuum LLN, or numerical model. |

## Assumptions and predecessor qualifications

BASIC is inherited from `HouseholdPrimitives` and `OriginalPrices`. SMOOTH, CURVATURE,
NONDEGENERATE, and strict IMPATIENT enter exactly through the S05 canonical stationary-law
construction. IID is implemented by the product law. The generic accounting lemmas use weaker
assumptions, while the contracted target exposes every transitive economic premise actually used.

All entries in `tmp_orchestration/contexts/M06C/predecessor_qualifications.json` remain operative
and unsuperseded. In particular, S05 supplies no moment result; A01 forms no expectation; weak
convergence is not used for an unbounded moment; P01 is not No-Ponzi; and all inherited
zero-boundary marginal restrictions remain untouched.

## Source and scope

The proof implements architecture section 8 and the capsule's A94 stationary aggregation locator,
with A93 Proposition 5 providing invariant-law context. It relies on the authorized capsule
extracts and accepted source qualifications and does not claim fresh source-PDF inspection.

Every new public declaration is covered by `#check`, `assert_no_sorry`, and `#print axioms` in both
audit files. A02 is submitted as **REVIEW_READY** only; this audit does not certify A03 or any later
contract.
