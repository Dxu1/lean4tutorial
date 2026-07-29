import Mathlib.Util.AssertNoSorry
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.All

/-!
# MP1994 v2 Milestone 0 audit

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

assert_no_sorry MP1994V2.Primitives.workerMeetingRate_pos
assert_no_sorry MP1994V2.ValueEquilibrium.surplus_eq

#print axioms MP1994V2.Primitives.workerMeetingRate_pos
#print axioms MP1994V2.ValueEquilibrium.surplus_eq
