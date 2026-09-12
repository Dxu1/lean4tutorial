import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions

/-!
# MP1994 v2: matching notation and immediate consequences
-/

namespace MP1994V2

/-- Market tightness `θ = v/u`, represented directly as the ratio used by the
value system.  Vacancy and unemployment stocks are not equilibrium unknowns in
Milestone 0.
-/
abbrev MarketTightness := ℝ

namespace Primitives

variable {P : Primitives}

/-- A positive market tightness and a positive vacancy meeting rate imply a
positive worker meeting rate. -/
theorem workerMeetingRate_pos
    (A : MatchingAssumptions P) {theta : MarketTightness}
    (htheta : 0 < theta) :
    0 < P.workerMeetingRate theta := by
  exact mul_pos htheta (A.vacancyMeetingRate_pos htheta)

end Primitives

end MP1994V2
