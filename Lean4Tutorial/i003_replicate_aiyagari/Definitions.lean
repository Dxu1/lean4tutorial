import Mathlib

/-!
# Aiyagari (1994): definitions and assumptions

This module formalizes only the objects appearing in
`aiyagari1994_theory_summary.tex`.  It deliberately separates algebraic
definitions from analytic facts imported by the summary from Aiyagari (1993a).
Those analytic facts are passed to the result theorems as explicit hypotheses;
no axiom and no `sorry` is used.
-/

open Filter MeasureTheory Set Topology
open scoped BigOperators ENNReal NNReal Topology

namespace Aiyagari1994

noncomputable section

/-- A household state consists of net assets and the labor endowment. -/
abbrev HouseholdState := ℝ × ℝ

/-- The time-preference rate `λ = (1-β)/β`. -/
def timePreferenceRate (β : ℝ) : ℝ :=
  (1 - β) / β

/-- The natural debt limit `w l_min / r`, defined when `r > 0`. -/
def naturalDebtLimit (w lmin r : ℝ) : ℝ :=
  w * lmin / r

/-- Equation (5) of the summary: the effective fixed borrowing limit. -/
def effectiveBorrowingLimit (b w lmin r : ℝ) : ℝ :=
  if 0 < r then min b (naturalDebtLimit w lmin r) else b

/-- Equation (6): the present-value borrowing limit. -/
def presentValueBorrowingLimit (w lmin r : ℝ) : ℝ :=
  naturalDebtLimit w lmin r

/-- Shifted assets `â = a + φ`. -/
def shiftedAsset (a φ : ℝ) : ℝ :=
  a + φ

/-- Total resources `z = w l + (1+r) â - r φ`. -/
def totalResources (w l r â φ : ℝ) : ℝ :=
  w * l + (1 + r) * â - r * φ

/-- Minimum resources `z_min = w l_min - r φ`. -/
def minimumResources (w lmin r φ : ℝ) : ℝ :=
  w * lmin - r * φ

/-- Consumption implied by total resources and the shifted asset policy. -/
def consumptionFromPolicy (A : ℝ → ℝ) (z : ℝ) : ℝ :=
  z - A z

/-- A path respects the natural debt bound at every date. -/
def NaturalDebtBound (a : ℕ → ℝ) (w lmin r : ℝ) : Prop :=
  ∀ t, -(naturalDebtLimit w lmin r) ≤ a t

/-- The paper's no-Ponzi condition: discounted assets have a finite
nonnegative limit. -/
def NoPonzi (a : ℕ → ℝ) (r : ℝ) : Prop :=
  ∃ L : ℝ, 0 ≤ L ∧
    Tendsto (fun t : ℕ => a (t + 1) / (1 + r) ^ t) atTop (𝓝 L)

/-- A predicate asserting that `V` solves a Bellman equation.  The exact
operator is intentionally abstract because the summary records the equation
but omits the analytic construction of its fixed point. -/
abbrev BellmanSolution := (ℝ → ℝ) → Prop

/-- A predicate asserting that a shifted next-asset choice is optimal at a
resource level. -/
abbrev PolicyOptimality := ℝ → ℝ → Prop

/-- `V` is the unique solution of a Bellman predicate. -/
def IsUniqueBellmanSolution
    (solves : BellmanSolution) (V : ℝ → ℝ) : Prop :=
  solves V ∧ ∀ W, solves W → W = V

/-- `A` is the unique optimizer selected by an optimality predicate. -/
def IsUniquePolicy
    (optimal : PolicyOptimality) (A : ℝ → ℝ) : Prop :=
  (∀ z, optimal z (A z)) ∧
    ∀ B : ℝ → ℝ, (∀ z, optimal z (B z)) → B = A

/-- The Euler inequality stated in Property 2. -/
def EulerInequality
    (marginalUtility expectedMarginalValue : ℝ → ℝ)
    (β r z : ℝ) : Prop :=
  β * (1 + r) * expectedMarginalValue z ≤ marginalUtility z

/-- The Euler equality on states where the borrowing constraint is slack. -/
def EulerEqualityWhenInterior
    (A marginalUtility expectedMarginalValue : ℝ → ℝ)
    (β r : ℝ) : Prop :=
  ∀ z, 0 < A z →
    marginalUtility z = β * (1 + r) * expectedMarginalValue z

/-- A resource cutoff below which the household consumes all resources and
chooses zero shifted assets. -/
def IsBindingCutoff (A : ℝ → ℝ) (zmin zhat : ℝ) : Prop :=
  zmin < zhat ∧ ∀ z, z ≤ zhat → A z = 0

/-- Both consumption and shifted assets rise strictly above `zhat`. -/
def StrictlyIncreasingAbove
    (A : ℝ → ℝ) (zhat : ℝ) : Prop :=
  ∀ ⦃x y : ℝ⦄, zhat < x → x < y →
    A x < A y ∧
      consumptionFromPolicy A x < consumptionFromPolicy A y

/-- The policy slope lies strictly between zero and one wherever the supplied
derivative exists. -/
def PolicySlopeInUnitInterval
    (policyDerivative : ℝ → ℝ) (zhat : ℝ) : Prop :=
  ∀ z, zhat < z → 0 < policyDerivative z ∧ policyDerivative z < 1

/-- A policy under more risk is weakly above the baseline policy pointwise. -/
def PolicyShiftedUp (baseline moreRisk : ℝ → ℝ) : Prop :=
  ∀ z, baseline z ≤ moreRisk z

/-- The corresponding consumption policy is weakly lower. -/
def ConsumptionShiftedDown (baseline moreRisk : ℝ → ℝ) : Prop :=
  ∀ z, consumptionFromPolicy moreRisk z ≤ consumptionFromPolicy baseline z

/-- A resource transition cannot increase resources above a finite threshold. -/
def ResourcesBoundedAbove
    (transition : ℝ → ℝ → ℝ) (zstar : ℝ) : Prop :=
  ∀ z l, zstar ≤ z → transition z l ≤ z

/-- Abstract stationarity interface used for the analytic propositions. -/
structure StationaryLaw (Dist : Type*) where
  /-- The law induced after one transition. -/
  evolve : Dist → Dist
  /-- The distinguished invariant law. -/
  invariant : Dist

/-- A law is invariant under the transition operator. -/
def IsInvariant {Dist : Type*} (S : StationaryLaw Dist) (μ : Dist) : Prop :=
  S.evolve μ = μ

/-- Stability means every initial law converges according to an abstract
convergence predicate supplied by the chosen distribution space. -/
def IsStable {Dist : Type*}
    (S : StationaryLaw Dist) (Converges : (ℕ → Dist) → Dist → Prop) : Prop :=
  ∀ μ₀, Converges (fun n => S.evolve^[n] μ₀) S.invariant

/-- A compact record of the four conclusions in Property 7. -/
structure UniqueStableInvariantData (Dist : Type*) where
  law : StationaryLaw Dist
  invariant_is_invariant : IsInvariant law law.invariant
  invariant_unique : ∀ μ, IsInvariant law μ → μ = law.invariant
  Converges : (ℕ → Dist) → Dist → Prop
  stable : IsStable law Converges

/-- Per-capita assets supplied by households as a function of the return. -/
abbrev AssetSupply := ℝ → ℝ

/-- Capital demanded by firms as a function of the return. -/
abbrev CapitalDemand := ℝ → ℝ

/-- Market clearing is `K(r) = E_a(r)`. -/
def MarketClears (K : CapitalDemand) (Ea : AssetSupply) (r : ℝ) : Prop :=
  K r = Ea r

/-- The gross steady-state saving rate `δ k / f(k)`. -/
def grossSavingRate (δ : ℝ) (f : ℝ → ℝ) (k : ℝ) : ℝ :=
  δ * k / f k

/-- The full-insurance return equals the time-preference rate. -/
def FullInsuranceReturn (β r : ℝ) : Prop :=
  r = timePreferenceRate β

/-- A function is neither monotone nor antitone. -/
def Nonmonotone (f : ℝ → ℝ) : Prop :=
  ¬Monotone f ∧ ¬Antitone f

/-- An asset-supply curve dominates another near a benchmark return. -/
def DominatesNear
    (rbar : ℝ) (risky certain : AssetSupply) : Prop :=
  ∃ ε > 0, ∀ r, rbar - ε < r → r < rbar → certain r < risky r

/-- Asset supply diverges to positive infinity as the return approaches a
finite boundary from the left. -/
def DivergesToInfinityFromLeft (Ea : AssetSupply) (rbar : ℝ) : Prop :=
  Tendsto Ea (𝓝[<] rbar) atTop

/-- Asset supply diverges to negative infinity as the return approaches a
finite boundary from the right. -/
def DivergesToNegInfinityFromRight (Ea : AssetSupply) (rbar : ℝ) : Prop :=
  Tendsto Ea (𝓝[>] rbar) atBot

/-- Excess capital demand; an equilibrium is a zero of this function. -/
def excessCapitalDemand
    (K : CapitalDemand) (Ea : AssetSupply) (r : ℝ) : ℝ :=
  K r - Ea r

/-- A fixed borrowing limit is slack when the natural limit is no larger. -/
def FixedLimitSlack (b w lmin r : ℝ) : Prop :=
  naturalDebtLimit w lmin r ≤ b

/-- The complete-markets balanced-growth return. -/
def balancedGrowthReturn (β g γ : ℝ) : ℝ :=
  (1 + timePreferenceRate β) * (1 + g) ^ γ - 1

/-- The right-hand side of the government-debt budget equation. -/
def debtBudgetResources (w l r d a : ℝ) : ℝ :=
  w * l - r * d + (1 + r) * a

/-- Assets net of government debt. -/
def netOfDebt (a d : ℝ) : ℝ :=
  a - d

/-- The present-value borrowing floor adjusted for debt-financing taxes. -/
def taxAdjustedAssetFloor (w lmin r d : ℝ) : ℝ :=
  -(w * lmin - r * d) / r

/-- The monetary interpretation `a = (m-1)/p`. -/
def realNetMoneyAssets (m p : ℝ) : ℝ :=
  (m - 1) / p

/-- The price level associated with the monetary upper-bound return. -/
def sharpPrice (rSharp w lmin : ℝ) : ℝ :=
  rSharp / (w * lmin)

/-- A monetary equilibrium has zero mean net assets. -/
def MonetaryEquilibrium
    (meanAssets : ℝ → ℝ → ℝ) (r p : ℝ) : Prop :=
  meanAssets r p = 0

/-- Primitives used in the stationary production economy. -/
structure Primitives where
  β : ℝ
  δ : ℝ
  lmin : ℝ
  production : ℝ → ℝ
  marginalProductCapital : ℝ → ℝ
  wageFromCapital : ℝ → ℝ
  capitalDemand : CapitalDemand

/-- Sign and technology assumptions stated in the summary. -/
structure Assumptions (P : Primitives) : Prop where
  β_pos : 0 < P.β
  β_lt_one : P.β < 1
  δ_nonneg : 0 ≤ P.δ
  lmin_pos : 0 < P.lmin
  capitalDemand_strictAnti : StrictAnti P.capitalDemand
  production_pos : ∀ k, 0 < k → 0 < P.production k

namespace Primitives

variable (P : Primitives)

/-- The paper's time-preference rate for these primitives. -/
def «λ» : ℝ := timePreferenceRate P.β

/-- The gross saving-rate function generated by the production primitives. -/
def savingRate (k : ℝ) : ℝ :=
  grossSavingRate P.δ P.production k

end Primitives

end

end Aiyagari1994
