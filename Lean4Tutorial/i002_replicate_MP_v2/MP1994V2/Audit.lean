import Mathlib.Util.AssertNoSorry
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.All

/-!
# MP1994 v2 audit through Milestone 1

This module checks the public foundation interfaces without adding substantive
economic theorems.
-/

#check MP1994V2.Primitives
#check MP1994V2.CoreEconomicAssumptions
#check MP1994V2.ShockAssumptions
#check MP1994V2.ShockNormalizationAssumptions
#check MP1994V2.MatchingAssumptions
#check MP1994V2.Primitives.cdf
#check MP1994V2.Primitives.IsShockUpperBound
#check MP1994V2.MarketTightness
#check MP1994V2.Primitives.vacancyMeetingRate
#check MP1994V2.Primitives.workerMeetingRate
#check MP1994V2.surplus
#check MP1994V2.activeSurplus
#check MP1994V2.continuationTerm
#check MP1994V2.ValueCandidate
#check MP1994V2.ValueEquilibrium
#check MP1994V2.continuationTerm_eq_integral_activeSurplus_sub
#check MP1994V2.ValueEquilibrium.firm_share
#check MP1994V2.ValueEquilibrium.surplus_flow_equation
#check MP1994V2.ValueEquilibrium.surplus_bellman_of_probability
#check MP1994V2.ValueEquilibrium.surplus_bellman

assert_no_sorry MP1994V2.Primitives.workerMeetingRate_pos
assert_no_sorry MP1994V2.ValueEquilibrium.surplus_eq
assert_no_sorry MP1994V2.continuationTerm_eq_integral_activeSurplus_sub
assert_no_sorry MP1994V2.ValueEquilibrium.firm_share
assert_no_sorry MP1994V2.ValueEquilibrium.surplus_flow_equation
assert_no_sorry MP1994V2.ValueEquilibrium.surplus_bellman_of_probability
assert_no_sorry MP1994V2.ValueEquilibrium.surplus_bellman

#print axioms MP1994V2.Primitives.workerMeetingRate_pos
#print axioms MP1994V2.ValueEquilibrium.surplus_eq
#print axioms MP1994V2.ValueEquilibrium.surplus_bellman_of_probability
#print axioms MP1994V2.ValueEquilibrium.surplus_bellman
