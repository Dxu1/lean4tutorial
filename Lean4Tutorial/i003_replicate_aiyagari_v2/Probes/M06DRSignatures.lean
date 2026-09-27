import Aiyagari1994.Aggregate.ParameterContinuity
import Mathlib.Util.AssertNoSorry

set_option format.width 100
set_option pp.funBinderTypes true

-- Unchanged A03 contract anchor.
#check Aiyagari1994.stationaryAssetSupply_continuous
assert_no_sorry Aiyagari1994.stationaryAssetSupply_continuous
#print axioms Aiyagari1994.stationaryAssetSupply_continuous

-- M06DR joint-interface export.
#check Aiyagari1994.stationaryAssetSupply_joint_continuous
assert_no_sorry Aiyagari1994.stationaryAssetSupply_joint_continuous
#print axioms Aiyagari1994.stationaryAssetSupply_joint_continuous
