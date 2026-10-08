import Aiyagari1994.Budget.EffectiveLimit
import Aiyagari1994.Aggregate.AssetSupply
import Aiyagari1994.Equilibrium.CertaintyBenchmark
import Aiyagari1994.Aggregate.UpperBoundary

/-! Gate-local implementation of A05. -/
open MeasureTheory Filter Set
open scoped Topology NNReal
namespace Aiyagari1994
noncomputable section

namespace M09C2

/-- Rates at which the fixed-wage finite-cap household is admissible and strictly impatient. -/
abbrev SubcriticalRate (m : HouseholdPrimitives) :=
  {r : ℝ // -1 < r ∧ m.beta * (1 + r) < 1}

/-- Positive strictly impatient rates, the domain of the natural debt-limit family. -/
abbrev PositiveSubcriticalRate (m : HouseholdPrimitives) :=
  {r : ℝ // 0 < r ∧ m.beta * (1 + r) < 1}

/-- The impatience-boundary net rate. -/
def criticalRate (m : HouseholdPrimitives) : ℝ := 1 / m.beta - 1

private theorem criticalRate_pos (m : HouseholdPrimitives) : 0 < criticalRate m := by
  rw [criticalRate, sub_pos]
  exact (lt_div_iff₀ m.beta_pos).2 (by simpa using m.beta_lt_one)

private theorem beta_critical (m : HouseholdPrimitives) :
    m.beta * (1 + criticalRate m) = 1 := by
  rw [criticalRate]
  field_simp [ne_of_gt m.beta_pos]
  ring

private theorem meanLabor_ge_lower (m : HouseholdPrimitives) :
    m.income.lower ≤ M09C1.meanLabor m := by
  calc
    m.income.lower = ∫ _l : m.income.Labor, m.income.lower
        ∂(m.income.law : Measure m.income.Labor) := by simp
    _ ≤ ∫ l : m.income.Labor, (l : ℝ)
        ∂(m.income.law : Measure m.income.Labor) := by
      exact integral_mono (integrable_const _) (labor_integrable m.income)
        (fun l ↦ l.property.1)

private theorem meanLabor_pos (m : HouseholdPrimitives) : 0 < M09C1.meanLabor m :=
  m.income_support.lower_pos.trans_le (meanLabor_ge_lower m)

/-- Risky finite-cap prices at fixed wage. -/
def finiteRiskPrices (m : HouseholdPrimitives) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w)
    (r : SubcriticalRate m) : OriginalPrices m.income :=
  finiteCapPrices m.income m.income_support b w (r : ℝ) hb hw r.property.1

/-- Mean-income certainty prices under the same institutional cap. -/
def finiteCertaintyPrices (m : HouseholdPrimitives) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w)
    (r : SubcriticalRate m) : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor m)) :=
  finiteCapPrices _ ⟨meanLabor_pos m, le_rfl⟩ b w (r : ℝ) hb hw r.property.1

/-- Risky natural-limit prices at fixed wage. -/
def naturalRiskPrices (m : HouseholdPrimitives) (w : ℝ) (hw : 0 < w)
    (r : PositiveSubcriticalRate m) : OriginalPrices m.income :=
  naturalCapPrices m.income m.income_support w (r : ℝ) hw r.property.1

/-- Mean-income certainty natural-limit prices. -/
def naturalCertaintyPrices (m : HouseholdPrimitives) (w : ℝ) (hw : 0 < w)
    (r : PositiveSubcriticalRate m) :
    OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor m)) :=
  naturalCapPrices _ ⟨meanLabor_pos m, le_rfl⟩ w (r : ℝ) hw r.property.1

private def admissibleOfOriginal {i : IncomeData} (p : OriginalPrices i) :
    AdmissibleNormalizedPrices i :=
  ⟨((p.normalized.grossReturn, p.normalized.wage), p.normalized.intercept),
    ⟨⟨p.normalized.grossReturn_pos, p.normalized.wage_pos⟩, p.normalized.income_nonneg⟩⟩

private theorem effectiveLimit_mono_lower (m : HouseholdPrimitives) (b w r : ℝ)
    (hw : 0 < w) :
    effectiveLimit b m.income.lower w r ≤ effectiveLimit b (M09C1.meanLabor m) w r := by
  unfold effectiveLimit
  split_ifs with hr
  · exact min_le_min_left b ((div_le_div_iff_of_pos_right hr).2
      (mul_le_mul_of_nonneg_left (meanLabor_ge_lower m) hw.le))
  · exact le_rfl

private theorem naturalLimit_mono_lower (m : HouseholdPrimitives) (w r : ℝ)
    (hw : 0 < w) (hr : 0 < r) :
    naturalLimit m.income.lower w r ≤ naturalLimit (M09C1.meanLabor m) w r := by
  unfold naturalLimit
  exact (div_le_div_iff_of_pos_right hr).2
    (mul_le_mul_of_nonneg_left (meanLabor_ge_lower m) hw.le)

/-- Canonical risky stationary net assets in the finite-cap family. -/
def finiteRiskSupply (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w) (r : SubcriticalRate m) : ℝ :=
  let p := finiteRiskPrices m b w hb hw r
  let q := admissibleOfOriginal p
  stationaryAssetSupply (m.withPrices q) p.debtLimit
    (M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd r.property.2)

/-- Canonical risky stationary net assets in the natural-limit family. -/
def naturalRiskSupply (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (w : ℝ) (hw : 0 < w) (r : PositiveSubcriticalRate m) : ℝ :=
  let p := naturalRiskPrices m w hw r
  let q := admissibleOfOriginal p
  stationaryAssetSupply (m.withPrices q) p.debtLimit
    (M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd r.property.2)

/-- Actual A04 stationary net-asset integral for the finite-cap certainty household. -/
def finiteCertaintySupply (m : HouseholdPrimitives) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w)
    (r : SubcriticalRate m) : ℝ :=
  let p := finiteCertaintyPrices m b w hb hw r
  let mc := M09C1.certaintyHousehold m p
  let delta := M09C1.pointMass (lowerEffectiveIncome mc)
  ∫ z : Resources, (assetPolicy mc z : ℝ) - p.debtLimit ∂(delta : Measure Resources)

/-- Actual A04 stationary net-asset integral for the natural-limit certainty household. -/
def naturalCertaintySupply (m : HouseholdPrimitives) (w : ℝ) (hw : 0 < w)
    (r : PositiveSubcriticalRate m) : ℝ :=
  let p := naturalCertaintyPrices m w hw r
  let mc := M09C1.certaintyHousehold m p
  let delta := M09C1.pointMass (lowerEffectiveIncome mc)
  ∫ z : Resources, (assetPolicy mc z : ℝ) - p.debtLimit ∂(delta : Measure Resources)

private theorem finite_certainty_eq (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w)
    (r : SubcriticalRate m) :
    finiteCertaintySupply m b w hb hw r =
      -(finiteCertaintyPrices m b w hb hw r).debtLimit := by
  exact (certainty_stationary_assets_at_limit m hsmooth
    (finiteCertaintyPrices m b w hb hw r) r.property.2).2.2.2.2.2.2

private theorem natural_certainty_eq (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (w : ℝ) (hw : 0 < w)
    (r : PositiveSubcriticalRate m) :
    naturalCertaintySupply m w hw r =
      -(naturalCertaintyPrices m w hw r).debtLimit := by
  exact (certainty_stationary_assets_at_limit m hsmooth
    (naturalCertaintyPrices m w hw r) r.property.2).2.2.2.2.2.2

private theorem finite_weak (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w) (r : SubcriticalRate m) :
    finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r ≥
      finiteCertaintySupply m b w hb hw r := by
  let p := finiteRiskPrices m b w hb hw r
  let q := admissibleOfOriginal p
  let mr := m.withPrices q
  let pi := M06C.stationaryLaw mr hsmooth hcurvature hnd r.property.2
  have hbudget := stationary_budget_identity mr hsmooth hcurvature hnd r.property.2 p rfl
  have hA_nonneg : 0 ≤ ∫ z, (assetPolicy mr z : ℝ) ∂(pi : Measure Resources) :=
    integral_nonneg (fun _ ↦ NNReal.zero_le_coe)
  have hshift : p.debtLimit ≤ (finiteCertaintyPrices m b w hb hw r).debtLimit :=
    effectiveLimit_mono_lower m b w r hw
  rw [show finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r =
      (∫ z, (assetPolicy mr z : ℝ) ∂(pi : Measure Resources)) - p.debtLimit by
    exact hbudget.2.2.2.2.2.2.1]
  rw [finite_certainty_eq m hsmooth b w hb hw r]
  linarith

private theorem natural_weak (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (w : ℝ) (hw : 0 < w) (r : PositiveSubcriticalRate m) :
    naturalRiskSupply m hsmooth hcurvature hnd w hw r ≥
      naturalCertaintySupply m w hw r := by
  let p := naturalRiskPrices m w hw r
  let q := admissibleOfOriginal p
  let mr := m.withPrices q
  let pi := M06C.stationaryLaw mr hsmooth hcurvature hnd r.property.2
  have hbudget := stationary_budget_identity mr hsmooth hcurvature hnd r.property.2 p rfl
  have hA_nonneg : 0 ≤ ∫ z, (assetPolicy mr z : ℝ) ∂(pi : Measure Resources) :=
    integral_nonneg (fun _ ↦ NNReal.zero_le_coe)
  have hshift : p.debtLimit ≤ (naturalCertaintyPrices m w hw r).debtLimit :=
    naturalLimit_mono_lower m w r hw r.property.1
  rw [show naturalRiskSupply m hsmooth hcurvature hnd w hw r =
      (∫ z, (assetPolicy mr z : ℝ) ∂(pi : Measure Resources)) - p.debtLimit by
    exact hbudget.2.2.2.2.2.2.1]
  rw [natural_certainty_eq m hsmooth w hw r]
  linarith

private theorem finite_tendsto_top (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w) :
    Tendsto (finiteRiskSupply m hsmooth hcurvature hnd b w hb hw)
      (Filter.comap ((↑·) : SubcriticalRate m → ℝ) (nhds (criticalRate m))) atTop := by
  rw [tendsto_iff_seq_tendsto]
  intro rs hrs
  have hr : Tendsto (fun n ↦ (rs n : ℝ)) atTop (nhds (criticalRate m)) :=
    tendsto_comap.comp hrs
  let ps : ℕ → OriginalPrices m.income := fun n ↦ finiteRiskPrices m b w hb hw (rs n)
  let qs : ℕ → AdmissibleNormalizedPrices m.income := fun n ↦ admissibleOfOriginal (ps n)
  let pstar : OriginalPrices m.income := finiteCapPrices m.income m.income_support b w
    (criticalRate m) hb hw (by linarith [criticalRate_pos m])
  let qstar := admissibleOfOriginal pstar
  have hpair : Tendsto (fun n ↦ (w, (rs n : ℝ))) atTop
      (nhds (w, criticalRate m)) := by
    rw [nhds_prod_eq]
    exact tendsto_const_nhds.prodMk hr
  have hwithin : Tendsto (fun n ↦ (w, (rs n : ℝ))) atTop
      (nhdsWithin (w, criticalRate m) {x : ℝ × ℝ | 0 < x.1 ∧ -1 < x.2}) := by
    rw [tendsto_nhdsWithin_iff]
    exact ⟨hpair, Filter.Eventually.of_forall fun n ↦ ⟨hw, (rs n).property.1⟩⟩
  have hphi : Tendsto (fun n ↦ (ps n).debtLimit) atTop (nhds pstar.debtLimit) :=
    ((effectiveLimit_admissible_continuous b m.income.lower hb
        m.income_support.lower_pos).2.2.1
      (w, criticalRate m) ⟨hw, by linarith [criticalRate_pos m]⟩).tendsto.comp hwithin
  have hq : Tendsto qs atTop (nhds qstar) := by
    apply tendsto_subtype_rng.2
    change Tendsto (fun n ↦ ((1 + (rs n : ℝ), w), -(rs n : ℝ) * (ps n).debtLimit))
      atTop (nhds ((1 + criticalRate m, w), -criticalRate m * pstar.debtLimit))
    rw [nhds_prod_eq, nhds_prod_eq]
    exact ((tendsto_const_nhds.add hr).prodMk tendsto_const_nhds).prodMk (hr.neg.mul hphi)
  have htop := assetSupply_tendsTo_infinity_at_impatience m hsmooth hcurvature hnd
    qs qstar (fun n ↦ (ps n).debtLimit) pstar.debtLimit
    (fun n ↦ (ps n).debtLimit_nonneg) (fun n ↦ by
      change -(rs n : ℝ) * (ps n).debtLimit = -((1 + (rs n : ℝ)) - 1) * (ps n).debtLimit
      ring)
    (fun n ↦ (rs n).property.2) (by exact beta_critical m) hq hphi
  apply htop.congr'
  exact Filter.Eventually.of_forall fun n ↦ by
    simp only [Function.comp_apply, finiteRiskSupply, ps, qs]

private theorem natural_tendsto_top (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (w : ℝ) (hw : 0 < w) :
    Tendsto (naturalRiskSupply m hsmooth hcurvature hnd w hw)
      (Filter.comap ((↑·) : PositiveSubcriticalRate m → ℝ) (nhds (criticalRate m))) atTop := by
  rw [tendsto_iff_seq_tendsto]
  intro rs hrs
  have hr : Tendsto (fun n ↦ (rs n : ℝ)) atTop (nhds (criticalRate m)) :=
    tendsto_comap.comp hrs
  let ps : ℕ → OriginalPrices m.income := fun n ↦ naturalRiskPrices m w hw (rs n)
  let qs : ℕ → AdmissibleNormalizedPrices m.income := fun n ↦ admissibleOfOriginal (ps n)
  let pstar : OriginalPrices m.income := naturalCapPrices m.income m.income_support w
    (criticalRate m) hw (criticalRate_pos m)
  let qstar := admissibleOfOriginal pstar
  have hphi : Tendsto (fun n ↦ (ps n).debtLimit) atTop (nhds pstar.debtLimit) := by
    change Tendsto (fun n ↦ naturalLimit m.income.lower w (rs n)) atTop
      (nhds (naturalLimit m.income.lower w (criticalRate m)))
    exact ((tendsto_const_nhds.mul_const _).div hr (ne_of_gt (criticalRate_pos m)))
  have hq : Tendsto qs atTop (nhds qstar) := by
    apply tendsto_subtype_rng.2
    change Tendsto (fun n ↦ ((1 + (rs n : ℝ), w), -(rs n : ℝ) * (ps n).debtLimit))
      atTop (nhds ((1 + criticalRate m, w), -criticalRate m * pstar.debtLimit))
    rw [nhds_prod_eq, nhds_prod_eq]
    exact ((tendsto_const_nhds.add hr).prodMk tendsto_const_nhds).prodMk (hr.neg.mul hphi)
  have htop := assetSupply_tendsTo_infinity_at_impatience m hsmooth hcurvature hnd
    qs qstar (fun n ↦ (ps n).debtLimit) pstar.debtLimit
    (fun n ↦ (ps n).debtLimit_nonneg) (fun n ↦ by
      change -(rs n : ℝ) * (ps n).debtLimit = -((1 + (rs n : ℝ)) - 1) * (ps n).debtLimit
      ring)
    (fun n ↦ (rs n).property.2) (beta_critical m) hq hphi
  apply htop.congr'
  exact Filter.Eventually.of_forall fun n ↦ by
    simp only [Function.comp_apply, naturalRiskSupply, ps, qs]

/-- A05 analytic core.  Both debt-rule families use certainty labor at the actual risky mean.
Weak comparison holds at every admissible strictly impatient rate; strict comparison holds on a
whole one-sided neighborhood of the impatience boundary in each family's rate domain. -/
theorem risky_assets_above_certainty_core (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (b w : ℝ) (hb : 0 ≤ b) (hw : 0 < w) :
    (∀ r : SubcriticalRate m,
      finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r ≥
        finiteCertaintySupply m b w hb hw r) ∧
    (∀ r : PositiveSubcriticalRate m,
      naturalRiskSupply m hsmooth hcurvature hnd w hw r ≥
        naturalCertaintySupply m w hw r) ∧
    (∀ᶠ r in Filter.comap ((↑·) : SubcriticalRate m → ℝ) (nhds (criticalRate m)),
      finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r >
        finiteCertaintySupply m b w hb hw r) ∧
    (∀ᶠ r in Filter.comap ((↑·) : PositiveSubcriticalRate m → ℝ) (nhds (criticalRate m)),
      naturalRiskSupply m hsmooth hcurvature hnd w hw r >
        naturalCertaintySupply m w hw r) := by
  refine ⟨finite_weak m hsmooth hcurvature hnd b w hb hw,
    natural_weak m hsmooth hcurvature hnd w hw, ?_, ?_⟩
  · have hpos : ∀ᶠ r in Filter.comap ((↑·) : SubcriticalRate m → ℝ)
        (nhds (criticalRate m)), 0 < finiteRiskSupply m hsmooth hcurvature hnd b w hb hw r :=
      (tendsto_atTop.1 (finite_tendsto_top m hsmooth hcurvature hnd b w hb hw) 1).mono
        (fun _ h ↦ lt_of_lt_of_le zero_lt_one h)
    filter_upwards [hpos] with r hr
    have hc := (finiteCertaintyPrices m b w hb hw r).debtLimit_nonneg
    rw [finite_certainty_eq m hsmooth b w hb hw r]
    linarith
  · have hpos : ∀ᶠ r in Filter.comap ((↑·) : PositiveSubcriticalRate m → ℝ)
        (nhds (criticalRate m)), 0 < naturalRiskSupply m hsmooth hcurvature hnd w hw r :=
      (tendsto_atTop.1 (natural_tendsto_top m hsmooth hcurvature hnd w hw) 1).mono
        (fun _ h ↦ lt_of_lt_of_le zero_lt_one h)
    filter_upwards [hpos] with r hr
    have hc := (naturalCertaintyPrices m w hw r).debtLimit_nonneg
    rw [natural_certainty_eq m hsmooth w hw r]
    linarith

end M09C2
end
end Aiyagari1994
