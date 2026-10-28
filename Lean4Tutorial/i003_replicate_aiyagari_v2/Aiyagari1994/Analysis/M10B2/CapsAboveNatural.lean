import Aiyagari1994.Budget.EffectiveLimit
import Aiyagari1994.Stationary.GlobalStability

/-! Gate-local proof that positive-rate finite caps weakly above the natural limit coincide. -/

open MeasureTheory Set

namespace Aiyagari1994
noncomputable section

namespace M10B2

/-- Original prices induced by a finite cap at a fixed positive net interest rate. -/
def capPrices (m : HouseholdPrimitives) (b : ℝ) (hb : 0 ≤ b)
    (w : ℝ) (hw : 0 < w) (r : ℝ) (hr : 0 < r) : OriginalPrices m.income :=
  finiteCapPrices m.income m.income_support b w r hb hw (by linarith)

/-- The normalized household induced by a finite cap at a fixed positive net interest rate. -/
def capHousehold (m : HouseholdPrimitives) (b : ℝ) (hb : 0 ≤ b)
    (w : ℝ) (hw : 0 < w) (r : ℝ) (hr : 0 < r) : HouseholdPrimitives where
  beta := m.beta
  beta_pos := m.beta_pos
  beta_lt_one := m.beta_lt_one
  utility := m.utility
  utility_base := m.utility_base
  income := m.income
  income_support := m.income_support
  prices := (capPrices m b hb w hw r hr).normalized

theorem effectiveLimit_eq_naturalLimit_of_le
    (b lo w r : ℝ) (hr : 0 < r) (hcap : naturalLimit lo w r ≤ b) :
    effectiveLimit b lo w r = naturalLimit lo w r := by
  simp only [effectiveLimit, hr, if_pos, naturalLimit]
  exact min_eq_right hcap

theorem capPrices_debtLimit_eq_naturalLimit
    (m : HouseholdPrimitives) (b : ℝ) (hb : 0 ≤ b)
    (w : ℝ) (hw : 0 < w) (r : ℝ) (hr : 0 < r)
    (hcap : naturalLimit m.income.lower w r ≤ b) :
    (capPrices m b hb w hw r hr).debtLimit = naturalLimit m.income.lower w r := by
  exact effectiveLimit_eq_naturalLimit_of_le b m.income.lower w r hr hcap

theorem capHousehold_eq_of_naturalLimit_le
    (m : HouseholdPrimitives) (b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (w : ℝ) (hw : 0 < w) (r : ℝ) (hr : 0 < r)
    (hcap₁ : naturalLimit m.income.lower w r ≤ b₁)
    (hcap₂ : naturalLimit m.income.lower w r ≤ b₂) :
    capHousehold m b₁ hb₁ w hw r hr = capHousehold m b₂ hb₂ w hw r hr := by
  have hphi₁ := effectiveLimit_eq_naturalLimit_of_le
    b₁ m.income.lower w r hr hcap₁
  have hphi₂ := effectiveLimit_eq_naturalLimit_of_le
    b₂ m.income.lower w r hr hcap₂
  have hp : (capPrices m b₁ hb₁ w hw r hr).normalized =
      (capPrices m b₂ hb₂ w hw r hr).normalized := by
    unfold capPrices finiteCapPrices OriginalPrices.normalized
    rw [NormalizedPrices.mk.injEq]
    exact ⟨rfl, rfl, by simp only; rw [hphi₁, hphi₂]⟩
  unfold capHousehold
  congr

/-- The compact upper endpoint selected by the accepted S05 existence theorem. -/
def stationaryBound (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    Resources :=
  Classical.choose (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR)

/-- The canonical stationary resource law selected directly from S05. -/
def stationaryLaw (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ProbabilityMeasure Resources :=
  Classical.choose (Classical.choose_spec
    (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))

theorem stationaryLaw_support (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ((stationaryLaw m hsmooth hcurvature hnd hbetaR : ProbabilityMeasure Resources) :
      Measure Resources)
        (Icc (lowerEffectiveIncome m) (stationaryBound m hsmooth hcurvature hnd hbetaR)) = 1 :=
  (Classical.choose_spec (Classical.choose_spec
    (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))).2.1

theorem stationaryLaw_invariant (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    householdLawStep m (stationaryLaw m hsmooth hcurvature hnd hbetaR) =
      stationaryLaw m hsmooth hcurvature hnd hbetaR :=
  (Classical.choose_spec (Classical.choose_spec
    (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))).2.2.1

theorem stationaryLaw_unique (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1)
    (rho : ProbabilityMeasure Resources) (hrho : householdLawStep m rho = rho) :
    rho = stationaryLaw m hsmooth hcurvature hnd hbetaR :=
  (Classical.choose_spec (Classical.choose_spec
    (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))).2.2.2.1 rho hrho

theorem stationaryAsset_integrable (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ))
      ((stationaryLaw m hsmooth hcurvature hnd hbetaR : ProbabilityMeasure Resources) :
        Measure Resources) := by
  let pi := stationaryLaw m hsmooth hcurvature hnd hbetaR
  let B := stationaryBound m hsmooth hcurvature hnd hbetaR
  letI : IsProbabilityMeasure (pi : Measure Resources) := pi.prop
  have hae : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc (lowerEffectiveIncome m) B :=
    (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by
      rw [stationaryLaw_support, measure_univ])
  have h := (continuous_subtype_val.comp (assetPolicy_continuous m)).continuousOn
    |>.integrableOn_compact (μ := (pi : Measure Resources)) (K := Icc (lowerEffectiveIncome m) B)
      isCompact_Icc
  change Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ))
    ((pi : Measure Resources).restrict (Icc (lowerEffectiveIncome m) B)) at h
  rwa [Measure.restrict_eq_self_of_ae_mem hae] at h

/-- Expected net assets under a resource law; finiteness is proved separately when S05 applies. -/
def stationaryNetAssetSupply (m : HouseholdPrimitives) (phi : ℝ)
    (pi : ProbabilityMeasure Resources) : ℝ :=
  ∫ z, (assetPolicy m z : ℝ) - phi ∂(pi : Measure Resources)

theorem stationaryNetAsset_integrable (m : HouseholdPrimitives) (phi : ℝ)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ) - phi)
      ((stationaryLaw m hsmooth hcurvature hnd hbetaR : ProbabilityMeasure Resources) :
        Measure Resources) :=
  (stationaryAsset_integrable m hsmooth hcurvature hnd hbetaR).sub (integrable_const phi)

/-- Above the natural limit, positive-rate caps yield the same normalized household and all
canonical H02/H04 transition objects. Under the separate S05 regularity and strict-impatience
premises, their canonical stationary laws and finite expected net asset supplies also coincide. -/
theorem caps_above_naturalLimit_equivalent
    (m : HouseholdPrimitives) (b₁ b₂ : ℝ) (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (w : ℝ) (hw : 0 < w) (r : ℝ) (hr : 0 < r)
    (hcap₁ : naturalLimit m.income.lower w r ≤ b₁)
    (hcap₂ : naturalLimit m.income.lower w r ≤ b₂) :
    let phi := naturalLimit m.income.lower w r
    let m₁ := capHousehold m b₁ hb₁ w hw r hr
    let m₂ := capHousehold m b₂ hb₂ w hw r hr
    effectiveLimit b₁ m.income.lower w r = phi ∧
      effectiveLimit b₂ m.income.lower w r = phi ∧
      m₁ = m₂ ∧
      valueFunction m₁ = valueFunction m₂ ∧
      assetPolicy m₁ = assetPolicy m₂ ∧
      consumptionPolicy m₁ = consumptionPolicy m₂ ∧
      householdKernel m₁ = householdKernel m₂ ∧
      householdLawStep m₁ = householdLawStep m₂ ∧
      ∀ (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
        (hnd : IncomeNondegenerate m.income)
        (hbetaR₁ : m₁.beta * m₁.prices.grossReturn < 1)
        (hbetaR₂ : m₂.beta * m₂.prices.grossReturn < 1),
        let pi₁ := stationaryLaw m₁ hsmooth hcurvature hnd hbetaR₁
        let pi₂ := stationaryLaw m₂ hsmooth hcurvature hnd hbetaR₂
        Integrable (fun z : Resources ↦ (assetPolicy m₁ z : ℝ) - phi)
            (pi₁ : Measure Resources) ∧
          Integrable (fun z : Resources ↦ (assetPolicy m₂ z : ℝ) - phi)
            (pi₂ : Measure Resources) ∧
          pi₁ = pi₂ ∧
          stationaryNetAssetSupply m₁ phi pi₁ =
            stationaryNetAssetSupply m₂ phi pi₂ := by
  dsimp only
  have hm := capHousehold_eq_of_naturalLimit_le m b₁ b₂ hb₁ hb₂ w hw r hr hcap₁ hcap₂
  refine ⟨effectiveLimit_eq_naturalLimit_of_le b₁ m.income.lower w r hr hcap₁,
    effectiveLimit_eq_naturalLimit_of_le b₂ m.income.lower w r hr hcap₂,
    hm, ?_⟩
  have hv := congrArg valueFunction hm
  have ha := congrArg assetPolicy hm
  have hc := congrArg consumptionPolicy hm
  have hkernel := congrArg householdKernel hm
  have hk := congrArg householdLawStep hm
  refine ⟨hv, ha, hc, hkernel, hk, ?_⟩
  intro hsmooth hcurvature hnd hbetaR₁ hbetaR₂
  have hpi : stationaryLaw (capHousehold m b₁ hb₁ w hw r hr)
      hsmooth hcurvature hnd hbetaR₁ =
      stationaryLaw (capHousehold m b₂ hb₂ w hw r hr)
        hsmooth hcurvature hnd hbetaR₂ := by
    apply stationaryLaw_unique (m := capHousehold m b₂ hb₂ w hw r hr)
      hsmooth hcurvature hnd hbetaR₂
    rw [← hk]
    exact stationaryLaw_invariant (m := capHousehold m b₁ hb₁ w hw r hr)
      hsmooth hcurvature hnd hbetaR₁
  refine ⟨stationaryNetAsset_integrable
      (m := capHousehold m b₁ hb₁ w hw r hr) _ hsmooth hcurvature hnd hbetaR₁,
    stationaryNetAsset_integrable
      (m := capHousehold m b₂ hb₂ w hw r hr) _ hsmooth hcurvature hnd hbetaR₂,
    hpi, ?_⟩
  simp only [stationaryNetAssetSupply]
  rw [ha, hpi]

end M10B2

end
end Aiyagari1994
