import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ParameterChanges

/-!
# MP1994 v2: finite aggregate-state primitives

This module represents the continuous-time marked-Poisson aggregate process
used in equations (32)--(34). The aggregate arrival parameter is a rate; the
row weights are conditional probabilities of the next aggregate mark.
-/

namespace MP1994V2

/-- A finite aggregate productivity process sharing all non-productivity
primitives with `P`. -/
structure FiniteAggregateProcess (P : Primitives) (ι : Type*) [Fintype ι] where
  commonProductivity : ι → ℝ
  aggregateArrival : ℝ
  transitionWeight : ι → ι → ℝ

namespace FiniteAggregateProcess

variable {P : Primitives} {ι : Type*} [Fintype ι]

/-- The primitive economy conditional on aggregate state `i`. -/
def statePrimitives (K : FiniteAggregateProcess P ι) (i : ι) : Primitives :=
  P.withCommonProductivity (K.commonProductivity i)

@[simp] theorem statePrimitives_r (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).r = P.r := rfl
@[simp] theorem statePrimitives_lambda (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).lambda = P.lambda := rfl
@[simp] theorem statePrimitives_sigma (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).sigma = P.sigma := rfl
@[simp] theorem statePrimitives_beta (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).beta = P.beta := rfl
@[simp] theorem statePrimitives_c (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).c = P.c := rfl
@[simp] theorem statePrimitives_b (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).b = P.b := rfl
@[simp] theorem statePrimitives_epsUpper (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).epsUpper = P.epsUpper := rfl
@[simp] theorem statePrimitives_shock (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).shock = P.shock := rfl
@[simp] theorem statePrimitives_q (K : FiniteAggregateProcess P ι) (i : ι) :
    (K.statePrimitives i).q = P.q := rfl

end FiniteAggregateProcess

/-- Economic and probabilistic restrictions on the finite marked-Poisson
aggregate process. Zero aggregate arrival remains an admissible benchmark. -/
structure FiniteAggregateProcessAssumptions
    (P : Primitives) {ι : Type*} [Fintype ι]
    (K : FiniteAggregateProcess P ι) : Prop where
  aggregateArrival_nonneg : 0 ≤ K.aggregateArrival
  transitionWeight_nonneg : ∀ i j, 0 ≤ K.transitionWeight i j
  transitionWeight_sum_one : ∀ i, ∑ j, K.transitionWeight i j = 1

namespace CoreEconomicAssumptions

theorem finiteStatePrimitives {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι} (A : CoreEconomicAssumptions P) (i : ι) :
    CoreEconomicAssumptions (K.statePrimitives i) :=
  A.withCommonProductivity (K.commonProductivity i)

end CoreEconomicAssumptions

namespace ShockAssumptions

theorem finiteStatePrimitives {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι} (D : ShockAssumptions P) (i : ι) :
    ShockAssumptions (K.statePrimitives i) :=
  D.withCommonProductivity (K.commonProductivity i)

end ShockAssumptions

namespace MatchingAssumptions

theorem finiteStatePrimitives {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι} (M : MatchingAssumptions P) (i : ι) :
    MatchingAssumptions (K.statePrimitives i) :=
  M.withCommonProductivity (K.commonProductivity i)

end MatchingAssumptions

end MP1994V2
