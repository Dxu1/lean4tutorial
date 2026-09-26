import Aiyagari1994.Aggregate.CrossSection
import Mathlib.Probability.Kernel.Composition.IntegralCompProd
import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.MeasureTheory.Constructions.BorelSpace.Real
import Mathlib.MeasureTheory.Integral.Prod

/-! Analytic implementation of stationary first moments and the aggregate budget identity. -/
open MeasureTheory ProbabilityTheory Set
open scoped NNReal ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- Mean net assets under a resource law. -/
def stationaryAssetSupply (m : HouseholdPrimitives) (phi : ℝ)
    (pi : ProbabilityMeasure Resources) : ℝ :=
  ∫ z, (assetPolicy m z : ℝ) - phi ∂(pi : Measure Resources)

/-- The upper endpoint returned by the S05 stationary-law construction. -/
def M06C.stationaryBound (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    Resources :=
  Classical.choose (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR)

/-- The canonical stationary resource law selected from S05. -/
def M06C.stationaryLaw (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ProbabilityMeasure Resources :=
  Classical.choose (Classical.choose_spec
    (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))

theorem M06C.stationaryLaw_properties (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    upperEffectiveIncome m ≤ M06C.stationaryBound m hsmooth hcurvature hnd hbetaR ∧
    ((M06C.stationaryLaw m hsmooth hcurvature hnd hbetaR :
        ProbabilityMeasure Resources) : Measure Resources)
        (Icc (lowerEffectiveIncome m)
          (M06C.stationaryBound m hsmooth hcurvature hnd hbetaR)) = 1 ∧
    householdLawStep m (M06C.stationaryLaw m hsmooth hcurvature hnd hbetaR) =
      M06C.stationaryLaw m hsmooth hcurvature hnd hbetaR := by
  exact ⟨(Classical.choose_spec (Classical.choose_spec
      (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))).1,
    (Classical.choose_spec (Classical.choose_spec
      (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))).2.1,
    (Classical.choose_spec (Classical.choose_spec
      (stationaryLaw_exists_unique_global m hsmooth hcurvature hnd hbetaR))).2.2.1⟩

theorem M06C.resource_integrable_of_compact_support (pi : ProbabilityMeasure Resources)
    (a b : Resources) (hsupport : (pi : Measure Resources) (Icc a b) = 1) :
    Integrable (fun z : Resources ↦ (z : ℝ)) (pi : Measure Resources) := by
  letI : IsProbabilityMeasure (pi : Measure Resources) := pi.prop
  have hae : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc a b :=
    (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by
      rw [hsupport, measure_univ])
  have h := continuous_subtype_val.continuousOn.integrableOn_compact
    (μ := (pi : Measure Resources)) (K := Icc a b) isCompact_Icc
  change Integrable (fun z : Resources ↦ (z : ℝ))
    ((pi : Measure Resources).restrict (Icc a b)) at h
  rwa [Measure.restrict_eq_self_of_ae_mem hae] at h

theorem M06C.asset_integrable_of_compact_support
    (m : HouseholdPrimitives) (pi : ProbabilityMeasure Resources) (a b : Resources)
    (hsupport : (pi : Measure Resources) (Icc a b) = 1) :
    Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ)) (pi : Measure Resources) := by
  letI : IsProbabilityMeasure (pi : Measure Resources) := pi.prop
  have hae : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc a b :=
    (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by
      rw [hsupport, measure_univ])
  have h := (continuous_subtype_val.comp (assetPolicy_continuous m)).continuousOn
    |>.integrableOn_compact (μ := (pi : Measure Resources)) (K := Icc a b) isCompact_Icc
  change Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ))
    ((pi : Measure Resources).restrict (Icc a b)) at h
  rwa [Measure.restrict_eq_self_of_ae_mem hae] at h

theorem M06C.consumption_integrable_of_compact_support
    (m : HouseholdPrimitives) (pi : ProbabilityMeasure Resources) (a b : Resources)
    (hsupport : (pi : Measure Resources) (Icc a b) = 1) :
    Integrable (fun z : Resources ↦ (consumptionPolicy m z : ℝ))
      (pi : Measure Resources) := by
  letI : IsProbabilityMeasure (pi : Measure Resources) := pi.prop
  have hae : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc a b :=
    (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by
      rw [hsupport, measure_univ])
  have h := (continuous_subtype_val.comp (consumptionPolicy_continuous m)).continuousOn
    |>.integrableOn_compact (μ := (pi : Measure Resources)) (K := Icc a b) isCompact_Icc
  change Integrable (fun z : Resources ↦ (consumptionPolicy m z : ℝ))
    ((pi : Measure Resources).restrict (Icc a b)) at h
  rwa [Measure.restrict_eq_self_of_ae_mem hae] at h

theorem M06C.effectiveIncome_integrable (m : HouseholdPrimitives) :
    Integrable m.prices.effectiveIncome (m.income.law : Measure m.income.Labor) := by
  apply Continuous.integrable_of_hasCompactSupport
  · exact (continuous_const.mul continuous_subtype_val).add continuous_const
  · exact HasCompactSupport.of_compactSpace _

/-- The one-step resource law is the image of current resources and an independent current
labor draw under the household transition. -/
theorem M06C.resourceImage_eq_lawStep (m : HouseholdPrimitives)
    (pi : ProbabilityMeasure Resources) :
    (pi.prod m.income.law).map
        (householdTransition_continuous m).measurable.aemeasurable = householdLawStep m pi := by
  apply ProbabilityMeasure.toMeasure_injective
  simp only [ProbabilityMeasure.toMeasure_map, ProbabilityMeasure.toMeasure_prod]
  change Measure.map (householdTransition m)
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) =
    householdKernel m ∘ₘ (pi : Measure Resources)
  rw [← Measure.compProd_const]
  rw [Measure.compProd_eq_comp_prod]
  rw [Measure.map_comp _ _ (householdTransition_continuous m).measurable]
  rfl

theorem M06C.stationary_resource_identity_of_invariant
    (m : HouseholdPrimitives) (pi : ProbabilityMeasure Resources)
    (hinv : householdLawStep m pi = pi)
    (_hz : Integrable (fun z : Resources ↦ (z : ℝ)) (pi : Measure Resources))
    (hA : Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ))
      (pi : Measure Resources)) :
    (∫ z, (z : ℝ) ∂(pi : Measure Resources)) =
      m.prices.grossReturn *
          ∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources) +
        ∫ l, m.prices.effectiveIncome l ∂(m.income.law : Measure m.income.Labor) := by
  have he := M06C.effectiveIncome_integrable m
  have hRA : Integrable
      (fun zl : Resources × m.income.Labor ↦
        m.prices.grossReturn * (assetPolicy m zl.1 : ℝ))
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) :=
    (hA.const_mul m.prices.grossReturn).comp_fst _
  have heProd : Integrable
      (fun zl : Resources × m.income.Labor ↦ m.prices.effectiveIncome zl.2)
      ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor)) :=
    he.comp_snd _
  calc
    (∫ y, (y : ℝ) ∂(pi : Measure Resources)) =
        ∫ y, (y : ℝ) ∂(householdLawStep m pi : Measure Resources) := by rw [hinv]
    _ = ∫ y, (y : ℝ) ∂((pi.prod m.income.law).map
        (householdTransition_continuous m).measurable.aemeasurable : Measure Resources) := by
          rw [M06C.resourceImage_eq_lawStep]
    _ = _ := by
      change (∫ y, (y : ℝ) ∂Measure.map (householdTransition m)
          ((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor))) = _
      rw [integral_map (householdTransition_continuous m).measurable.aemeasurable
        measurable_coe_nnreal_real.aestronglyMeasurable]
      change (∫ zl, m.prices.grossReturn * (assetPolicy m zl.1 : ℝ) +
          m.prices.effectiveIncome zl.2
          ∂((pi : Measure Resources).prod (m.income.law : Measure m.income.Labor))) = _
      rw [integral_add hRA heProd]
      have hfst :
          (∫ zl, m.prices.grossReturn * (assetPolicy m zl.1 : ℝ)
              ∂((pi : Measure Resources).prod
                (m.income.law : Measure m.income.Labor))) =
            m.prices.grossReturn *
              ∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources) := by
        rw [integral_fun_fst (μ := (pi : Measure Resources))
          (ν := (m.income.law : Measure m.income.Labor))
          (fun z : Resources ↦ m.prices.grossReturn * (assetPolicy m z : ℝ))]
        simp [integral_const_mul]
      have hsnd :
          (∫ zl, m.prices.effectiveIncome zl.2
              ∂((pi : Measure Resources).prod
                (m.income.law : Measure m.income.Labor))) =
            ∫ l, m.prices.effectiveIncome l
              ∂(m.income.law : Measure m.income.Labor) := by
        rw [integral_fun_snd (μ := (pi : Measure Resources))
          (ν := (m.income.law : Measure m.income.Labor)) m.prices.effectiveIncome]
        simp
      rw [hfst, hsnd]

theorem M06C.stationaryAssetSupply_eq_mean_shifted_sub
    (m : HouseholdPrimitives) (phi : ℝ) (pi : ProbabilityMeasure Resources)
    (hA : Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ))
      (pi : Measure Resources)) :
    stationaryAssetSupply m phi pi =
      (∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources)) - phi := by
  rw [stationaryAssetSupply, integral_sub hA (integrable_const phi), integral_const]
  simp

theorem M06C.mean_effectiveIncome_of_original
    (m : HouseholdPrimitives) (p : OriginalPrices m.income)
    (hprices : m.prices = p.normalized) :
    (∫ l, m.prices.effectiveIncome l ∂(m.income.law : Measure m.income.Labor)) =
      p.wage * ∫ l, (l : ℝ) ∂(m.income.law : Measure m.income.Labor) -
        p.netRate * p.debtLimit := by
  rw [hprices]
  change (∫ l, p.wage * (l : ℝ) + (-p.netRate * p.debtLimit)
      ∂(m.income.law : Measure m.income.Labor)) = _
  rw [integral_add ((labor_integrable m.income).const_mul p.wage) (integrable_const _),
    integral_const_mul, integral_const]
  simp
  ring

/-- Stationary accounting for any invariant resource law with explicit finite first moments.
This is the reusable form intended for equilibrium records whose law is supplied rather than
constructed by S05. -/
theorem M06C.stationary_budget_of_invariant
    (m : HouseholdPrimitives) (p : OriginalPrices m.income)
    (hprices : m.prices = p.normalized) (pi : ProbabilityMeasure Resources)
    (hinv : householdLawStep m pi = pi)
    (hz : Integrable (fun z : Resources ↦ (z : ℝ)) (pi : Measure Resources))
    (hA : Integrable (fun z : Resources ↦ (assetPolicy m z : ℝ))
      (pi : Measure Resources))
    (_hc : Integrable (fun z : Resources ↦ (consumptionPolicy m z : ℝ))
      (pi : Measure Resources)) :
    ((∫ z, (z : ℝ) ∂(pi : Measure Resources)) =
        m.prices.grossReturn *
            ∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources) +
          ∫ l, m.prices.effectiveIncome l
            ∂(m.income.law : Measure m.income.Labor)) ∧
    stationaryAssetSupply m p.debtLimit pi =
      (∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources)) - p.debtLimit ∧
    (∫ z, (consumptionPolicy m z : ℝ) ∂(pi : Measure Resources)) =
      p.netRate * stationaryAssetSupply m p.debtLimit pi +
        p.wage * ∫ l, (l : ℝ) ∂(m.income.law : Measure m.income.Labor) := by
  have hresource := M06C.stationary_resource_identity_of_invariant m pi hinv hz hA
  have hsupply := M06C.stationaryAssetSupply_eq_mean_shifted_sub m p.debtLimit pi hA
  refine ⟨hresource, hsupply, ?_⟩
  have hconsumption :
      (∫ z, (consumptionPolicy m z : ℝ) ∂(pi : Measure Resources)) =
        (∫ z, (z : ℝ) ∂(pi : Measure Resources)) -
          ∫ z, (assetPolicy m z : ℝ) ∂(pi : Measure Resources) := by
    calc
      (∫ z, (consumptionPolicy m z : ℝ) ∂(pi : Measure Resources)) =
          ∫ z, (z : ℝ) - (assetPolicy m z : ℝ) ∂(pi : Measure Resources) := by
            apply integral_congr_ae
            exact Filter.Eventually.of_forall (consumptionPolicy_coe m)
      _ = _ := integral_sub hz hA
  rw [hconsumption, hresource, M06C.mean_effectiveIncome_of_original m p hprices, hsupply]
  have hR : m.prices.grossReturn = 1 + p.netRate := by
    rw [hprices]
    rfl
  rw [hR]
  ring

end
end Aiyagari1994
