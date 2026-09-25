import Aiyagari1994.Analysis.M04A.JointContinuity

/-! H06: joint state-price continuity before stationarity. -/
open scoped Topology
namespace Aiyagari1994
noncomputable section

/--
H06.  With utility, the iid labor law, and beta fixed by `m`, the canonical value and shifted-asset
policy are jointly continuous in resources and every admissible normalized price triple `(R,w,k)`.
The domain assumes only `R > 0`, so it includes `beta * R = 1` and `beta * R > 1`.
-/
theorem policy_jointly_continuous (m : HouseholdPrimitives) :
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      valueFunction (m.withPrices x.1) x.2) ∧
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      assetPolicy (m.withPrices x.1) x.2) :=
  ⟨parameterized_value_continuous m, parameterized_assetPolicy_continuous m⟩

end
end Aiyagari1994
