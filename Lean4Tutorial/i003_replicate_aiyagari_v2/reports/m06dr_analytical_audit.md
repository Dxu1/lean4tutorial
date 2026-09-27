# M06DR analytical audit

| Required question | Answer and proof evidence |
|---|---|
| Is joint `(q, phi)` variation actually exposed? | Yes. `stationaryAssetSupply_joint_continuous` has domain `M06A.ImpatientPrices m × Real`; neither coordinate is a function of the other. Its conclusion is continuity of the actual `stationaryAssetSupply` integral. |
| Does coverage include the whole strictly impatient region? | Yes. The first coordinate ranges over the full subtype `M06A.ImpatientPrices m`. The theorem imposes no additional neighborhood, return-sign, or positive-net-rate restriction. D03's common compact bound is used locally at each point, as required for continuity, and is not asserted uniformly near `beta*R=1`. |
| Is the stationary object canonical? | Yes. At each `q`, the integral uses `M06A.stationaryLawAtPrice`, the S06-selected canonical S05 invariant resource law. |
| Is the actual asset-supply integral used? | Yes. The theorem's displayed function is `stationaryAssetSupply (m.withPrices q) phi pi_q`, which integrates `A_q(z)-phi`. The proof invokes A02's accepted integrability and decomposition theorem to rewrite it as `stationaryMeanShiftedAssets q-phi`. |
| Were accepted analytic proofs preserved? | Yes. `M06D.stationaryMeanShiftedAssets_continuous`, `M06D.stationary_asset_integrable`, and `M06C.stationaryAssetSupply_eq_mean_shifted_sub` are invoked through their accepted interfaces and their bodies are byte-for-byte unchanged. The historical graph theorem is also unchanged. |
| Why is the debt shift independent? | Normalized effective income contains `(R-1)*phi`; at zero net interest this product is zero for every `phi`, so normalized prices cannot recover the debt shift. Keeping `phi` as an independent coordinate avoids false identification. |
| What qualifies economic original-coordinate use? | The formal topology permits every real shift. Economic use requires `phi` to be the compatible nonnegative debt limit generated or supplied by the original-price normalization. The theorem does not manufacture that compatibility. |
| Is weak convergence incorrectly used for an unbounded moment? | No. That work remains inside the accepted mean-continuity theorem: D03 supplies a local common compact support, H06 gives uniform policy convergence there, and S06 weak continuity is applied only to a bounded continuous clipped test. |
| Are state-space and income scope preserved? | Yes. Resource laws remain on the fixed full `NNReal` space, and labor remains a general compactly supported iid law with no finite-support, atom, or density restriction. |
| Are zero-boundary qualifications preserved? | Yes. No marginal-value or derivative object appears. In particular, `rightMarginalValue m 0` is never substituted for `zeroRightMarginal`. |
| Are stronger claims introduced? | No. There is no total-variation continuity, arbitrary-law moment convergence, stationary marginal-utility integrability, critical-boundary continuity, divergence, equilibrium, continuum LLN, or numerical claim. |
| Are prohibited assumptions or bypasses introduced? | No. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, altered assumption, or vacuous premise. |

## Assumptions and predecessor qualifications

BASIC is inherited through `HouseholdPrimitives`. SMOOTH, CURVATURE, NONDEGENERATE, IID, and
strict IMPATIENT enter through the accepted construction and continuity of the canonical law.
M06DR adds no mathematical assumption. All entries in the supplied
`predecessor_qualifications.json` remain operative except that the historical acceptance of
graph-only interface coverage is expressly superseded by the user's joint-interface request.
Nothing else in those qualifications is superseded.

## Independent coverage conclusion

The new theorem does cover simultaneous, independent variation of normalized prices and the debt
shift throughout the strictly impatient region: its domain is exactly the product
`M06A.ImpatientPrices m × Real`, and its proof is continuity of the first-coordinate stationary
mean composed with `fst`, minus `snd`. The unrestricted real second coordinate is a formal
normalization interface; the nonnegative-debt and compatibility qualifications remain necessary
for economic interpretation.

## Source and scope

The repair uses architecture section 8 and the accepted A03/A02/S06 interfaces supplied by the
capsule. No fresh source-PDF inspection is claimed. The unchanged contract anchor and the one new
export are in `Probes/M06DRSignatures.lean`; the new export has `#check`, `assert_no_sorry`, and
`#print axioms` coverage there and in `Audit.lean`. A03 stops at **REVIEW_READY** and no later
contract is advanced.
