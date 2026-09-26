import Aiyagari1994.Aggregate.CrossSection
import Mathlib.Util.AssertNoSorry

set_option format.width 100
set_option pp.funBinderTypes true

-- Gate M06B: resource law versus independent asset/labor cross-section.
#check Aiyagari1994.M06B.netAsset
assert_no_sorry Aiyagari1994.M06B.netAsset
#print axioms Aiyagari1994.M06B.netAsset

#check Aiyagari1994.M06B.netAsset_continuous
assert_no_sorry Aiyagari1994.M06B.netAsset_continuous
#print axioms Aiyagari1994.M06B.netAsset_continuous

#check Aiyagari1994.M06B.netAssetLaw
assert_no_sorry Aiyagari1994.M06B.netAssetLaw
#print axioms Aiyagari1994.M06B.netAssetLaw

#check Aiyagari1994.M06B.assetLaborLaw
assert_no_sorry Aiyagari1994.M06B.assetLaborLaw
#print axioms Aiyagari1994.M06B.assetLaborLaw

#check Aiyagari1994.M06B.resourceFromAssetLabor
assert_no_sorry Aiyagari1994.M06B.resourceFromAssetLabor
#print axioms Aiyagari1994.M06B.resourceFromAssetLabor

#check Aiyagari1994.M06B.resourceFromAssetLabor_continuous
assert_no_sorry Aiyagari1994.M06B.resourceFromAssetLabor_continuous
#print axioms Aiyagari1994.M06B.resourceFromAssetLabor_continuous

#check Aiyagari1994.M06B.resourceImage_eq_lawStep
assert_no_sorry Aiyagari1994.M06B.resourceImage_eq_lawStep
#print axioms Aiyagari1994.M06B.resourceImage_eq_lawStep

#check Aiyagari1994.resource_asset_labor_law_bridge
assert_no_sorry Aiyagari1994.resource_asset_labor_law_bridge
#print axioms Aiyagari1994.resource_asset_labor_law_bridge
