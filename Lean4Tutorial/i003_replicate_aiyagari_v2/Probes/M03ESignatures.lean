import Aiyagari1994.Household.BorrowingThreshold
import Mathlib.Util.AssertNoSorry

-- M03E exact public signatures and transitive axiom checks.
set_option format.width 100
set_option pp.funBinderTypes true

#check Aiyagari1994.zero_income_atom_implies_nonbinding
assert_no_sorry Aiyagari1994.zero_income_atom_implies_nonbinding
#print axioms Aiyagari1994.zero_income_atom_implies_nonbinding
