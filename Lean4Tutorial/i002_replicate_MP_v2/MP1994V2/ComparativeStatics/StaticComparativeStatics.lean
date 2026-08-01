import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.FixedTightness
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.FlowImplications

/-!
# MP1994 v2: M7 static comparative-statics capstones

The capstones quantify over equilibria supplied by the caller.  They neither
select nor prove existence of an equilibrium and therefore do not use
`StaticExistenceAssumptions`.
-/

namespace MP1994V2

/-- GREEN M7 capstone for aggregate net productivity: higher `p` and higher
`b` move cutoffs, tightness, hazards, and steady-state stocks in opposite
directions. -/
theorem m7_aggregateNetProductivity_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {pLow pHigh bLow bHigh : ℝ}
    (hp : pLow < pHigh) (hb : bLow < bHigh)
    (SPLow : SteadyStateEquilibrium (P.withCommonProductivity pLow))
    (SPHigh : SteadyStateEquilibrium (P.withCommonProductivity pHigh))
    (SBLow : SteadyStateEquilibrium (P.withUnemploymentIncome bLow))
    (SBHigh : SteadyStateEquilibrium (P.withUnemploymentIncome bHigh)) :
    (SPHigh.cutoff < SPLow.cutoff
      ∧ SPLow.theta < SPHigh.theta
      ∧ (P.withCommonProductivity pHigh).jobSeparationRate SPHigh.cutoff ≤
          (P.withCommonProductivity pLow).jobSeparationRate SPLow.cutoff
      ∧ (P.withCommonProductivity pLow).jobFindingRate SPLow.theta ≤
          (P.withCommonProductivity pHigh).jobFindingRate SPHigh.theta
      ∧ SPHigh.unemployment ≤ SPLow.unemployment
      ∧ SPLow.employment ≤ SPHigh.employment)
    ∧
    (SBLow.cutoff < SBHigh.cutoff
      ∧ SBHigh.theta < SBLow.theta
      ∧ (P.withUnemploymentIncome bLow).jobSeparationRate SBLow.cutoff ≤
          (P.withUnemploymentIncome bHigh).jobSeparationRate SBHigh.cutoff
      ∧ (P.withUnemploymentIncome bHigh).jobFindingRate SBHigh.theta ≤
          (P.withUnemploymentIncome bLow).jobFindingRate SBLow.theta
      ∧ SBLow.unemployment ≤ SBHigh.unemployment
      ∧ SBHigh.employment ≤ SBLow.employment) := by
  exact
    ⟨SPLow.aggregateProductivity_capstone A D M hp SPHigh,
      SBLow.unemploymentIncome_capstone A D M hb SBHigh⟩

/-- GREEN M7 capstone for the robust `lambda` and `r` orders.  It intentionally
omits the equilibrium tightness response to `lambda` and the equilibrium
cutoff response to `r`. -/
theorem m7_otherParameters_capstone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {lambdaLow lambdaHigh rLow rHigh theta : ℝ}
    (hlambdaLow : 0 ≤ lambdaLow)
    (hlambda : lambdaLow < lambdaHigh)
    (hrLow : 0 < rLow) (hr : rLow < rHigh)
    (RLambdaLow : ReducedEquilibrium
      (P.withShockArrivalRate lambdaLow))
    (RLambdaHigh : ReducedEquilibrium
      (P.withShockArrivalRate lambdaHigh))
    (RrLow : ReducedEquilibrium (P.withDiscountRate rLow))
    (RrHigh : ReducedEquilibrium (P.withDiscountRate rHigh))
    {dLambdaLow dLambdaHigh drLow drHigh : ℝ}
    (hLambdaLow : Primitives.SatisfiesJobDestructionMeasure
      (P.withShockArrivalRate lambdaLow) theta dLambdaLow)
    (hLambdaHigh : Primitives.SatisfiesJobDestructionMeasure
      (P.withShockArrivalRate lambdaHigh) theta dLambdaHigh)
    (hrLowJD : Primitives.SatisfiesJobDestructionMeasure
      (P.withDiscountRate rLow) theta drLow)
    (hrHighJD : Primitives.SatisfiesJobDestructionMeasure
      (P.withDiscountRate rHigh) theta drHigh) :
    RLambdaHigh.cutoff < RLambdaLow.cutoff
      ∧ RrHigh.theta < RrLow.theta
      ∧ dLambdaHigh ≤ dLambdaLow
      ∧ drLow ≤ drHigh := by
  exact
    ⟨RLambdaLow.cutoff_strictAnti_shockArrival A D M
        hlambdaLow hlambda RLambdaHigh,
      RrLow.theta_strictAnti_discountRate A D M hrLow hr RrHigh,
      cutoff_antitone_shockArrival_at_fixed_theta A D
        hlambdaLow hlambda hLambdaLow hLambdaHigh,
      cutoff_monotone_discountRate_at_fixed_theta A D
        hrLow hr hrLowJD hrHighJD⟩

end MP1994V2
