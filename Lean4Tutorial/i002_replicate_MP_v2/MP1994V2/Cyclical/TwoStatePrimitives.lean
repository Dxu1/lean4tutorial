import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ParameterChanges

/-!
# MP1994 v2: two-state cyclical primitives

This module adds only the exogenous recession/boom state and the Poisson rate
at which the aggregate state switches.  All non-productivity primitives remain
the common objects in `P`.
-/

namespace MP1994V2

/-- The two aggregate productivity states used in Section 4 of the paper. -/
inductive AggregateState where
  | recession
  | boom
  deriving DecidableEq, Fintype

namespace AggregateState

/-- The aggregate state reached at the next aggregate shock. -/
def other : AggregateState → AggregateState
  | recession => boom
  | boom => recession

@[simp] theorem other_recession : other recession = boom := rfl
@[simp] theorem other_boom : other boom = recession := rfl
@[simp] theorem other_other (s : AggregateState) : s.other.other = s := by
  cases s <;> rfl

theorem other_ne (s : AggregateState) : s.other ≠ s := by
  cases s <;> decide

end AggregateState

/-- The genuinely new primitives in the anticipated two-state economy.

`pHigh` is boom productivity and `aggregateArrival` is the aggregate-state
Poisson switching rate (the paper's aggregate arrival parameter).
-/
structure TwoStatePrimitives (P : Primitives) where
  pHigh : ℝ
  aggregateArrival : ℝ

namespace TwoStatePrimitives

variable {P : Primitives}

/-- The stationary primitive record seen in a given aggregate state. -/
def statePrimitives (T : TwoStatePrimitives P) : AggregateState → Primitives
  | .recession => P
  | .boom => P.withCommonProductivity T.pHigh

@[simp] theorem statePrimitives_recession (T : TwoStatePrimitives P) :
    T.statePrimitives .recession = P := rfl

@[simp] theorem statePrimitives_boom (T : TwoStatePrimitives P) :
    T.statePrimitives .boom = P.withCommonProductivity T.pHigh := rfl

/-- Match productivity in aggregate state `s` and idiosyncratic state `eps`. -/
def productivity (T : TwoStatePrimitives P) (s : AggregateState) (eps : ℝ) : ℝ :=
  (T.statePrimitives s).productivity eps

@[simp] theorem productivity_recession (T : TwoStatePrimitives P) (eps : ℝ) :
    T.productivity .recession eps = P.p + P.sigma * eps := rfl

@[simp] theorem productivity_boom (T : TwoStatePrimitives P) (eps : ℝ) :
    T.productivity .boom eps = T.pHigh + P.sigma * eps := rfl

@[simp] theorem statePrimitives_r (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).r = P.r := by cases s <;> rfl
@[simp] theorem statePrimitives_lambda (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).lambda = P.lambda := by cases s <;> rfl
@[simp] theorem statePrimitives_sigma (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).sigma = P.sigma := by cases s <;> rfl
@[simp] theorem statePrimitives_beta (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).beta = P.beta := by cases s <;> rfl
@[simp] theorem statePrimitives_c (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).c = P.c := by cases s <;> rfl
@[simp] theorem statePrimitives_b (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).b = P.b := by cases s <;> rfl
@[simp] theorem statePrimitives_epsUpper (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).epsUpper = P.epsUpper := by cases s <;> rfl
@[simp] theorem statePrimitives_shock (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).shock = P.shock := by cases s <;> rfl
@[simp] theorem statePrimitives_q (T : TwoStatePrimitives P) (s : AggregateState) :
    (T.statePrimitives s).q = P.q := by cases s <;> rfl

end TwoStatePrimitives

/-- Economic restrictions specific to the anticipated two-state extension. -/
structure TwoStateEconomicAssumptions (P : Primitives)
    (T : TwoStatePrimitives P) : Prop where
  p_lt_pHigh : P.p < T.pHigh
  aggregateArrival_pos : 0 < T.aggregateArrival

namespace TwoStateEconomicAssumptions

variable {P : Primitives} {T : TwoStatePrimitives P}

theorem productivity_recession_lt_boom (A : TwoStateEconomicAssumptions P T)
    (eps : ℝ) : T.productivity .recession eps < T.productivity .boom eps := by
  simp only [TwoStatePrimitives.productivity_recession,
    TwoStatePrimitives.productivity_boom]
  linarith [A.p_lt_pHigh]

end TwoStateEconomicAssumptions

namespace CoreEconomicAssumptions

theorem statePrimitives {P : Primitives} {T : TwoStatePrimitives P}
    (A : CoreEconomicAssumptions P) (s : AggregateState) :
    CoreEconomicAssumptions (T.statePrimitives s) := by
  cases s
  · exact A
  · exact A.withCommonProductivity T.pHigh

end CoreEconomicAssumptions

namespace ShockAssumptions

theorem statePrimitives {P : Primitives} {T : TwoStatePrimitives P}
    (D : ShockAssumptions P) (s : AggregateState) :
    ShockAssumptions (T.statePrimitives s) := by
  cases s
  · exact D
  · exact D.withCommonProductivity T.pHigh

end ShockAssumptions

namespace MatchingAssumptions

theorem statePrimitives {P : Primitives} {T : TwoStatePrimitives P}
    (M : MatchingAssumptions P) (s : AggregateState) :
    MatchingAssumptions (T.statePrimitives s) := by
  cases s
  · exact M
  · exact M.withCommonProductivity T.pHigh

end MatchingAssumptions

end MP1994V2
