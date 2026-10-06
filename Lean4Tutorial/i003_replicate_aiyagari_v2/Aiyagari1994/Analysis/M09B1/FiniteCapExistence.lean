import Aiyagari1994.Aggregate.ParameterContinuity
import Aiyagari1994.Aggregate.UpperBoundary
import Aiyagari1994.Equilibrium.Definition
import Aiyagari1994.Equilibrium.LowerBracket

/-! Gate-local construction for finite-cap stationary-equilibrium existence. -/

open Filter MeasureTheory ProbabilityTheory Set Topology
open scoped NNReal ProbabilityTheory Topology

namespace Aiyagari1994
noncomputable section

namespace M09B1

private def criticalRate (m : HouseholdPrimitives) : ℝ := 1 / m.beta - 1

private theorem criticalRate_pos (m : HouseholdPrimitives) : 0 < criticalRate m := by
  rw [criticalRate, sub_pos]
  exact (lt_div_iff₀ m.beta_pos).2 (by simpa using m.beta_lt_one)

private theorem beta_one_add_criticalRate (m : HouseholdPrimitives) :
    m.beta * (1 + criticalRate m) = 1 := by
  rw [criticalRate]
  field_simp [ne_of_gt m.beta_pos]
  ring

private def admissibleOfOriginal {i : IncomeData} (prices : OriginalPrices i) :
    AdmissibleNormalizedPrices i :=
  ⟨((prices.normalized.grossReturn, prices.normalized.wage), prices.normalized.intercept),
    ⟨⟨prices.normalized.grossReturn_pos, prices.normalized.wage_pos⟩,
      prices.normalized.income_nonneg⟩⟩

private theorem admissibleOfOriginal_toPrices {i : IncomeData} (prices : OriginalPrices i) :
    (admissibleOfOriginal prices).toPrices = prices.normalized := rfl

private def finitePrices (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) (r : FirmRate p) :
    OriginalPrices m.income :=
  finiteCapPrices m.income m.income_support b (firmWage p hp r) r hb
    (firmWage_positive p hp r) (by
      have hr := r.property
      change -p.depreciation < (r : ℝ) at hr
      linarith [hp.depreciation_lt_one])

private def normalizedPath (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) (r : FirmRate p) :
    AdmissibleNormalizedPrices m.income :=
  admissibleOfOriginal (finitePrices m p hp b hb r)

private theorem debtShift_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) :
    Continuous (fun r : FirmRate p =>
      effectiveLimit b m.income.lower (firmWage p hp r) (r : ℝ)) := by
  have hpair : Continuous (fun r : FirmRate p => (firmWage p hp r, (r : ℝ))) :=
    (firmWage_continuous p hp).prodMk continuous_subtype_val
  have hrange : ∀ r : FirmRate p,
      (firmWage p hp r, (r : ℝ)) ∈ {x : ℝ × ℝ | 0 < x.1 ∧ -1 < x.2} := by
    intro r
    refine ⟨firmWage_positive p hp r, ?_⟩
    have hr := r.property
    change -p.depreciation < (r : ℝ) at hr
    linarith [hp.depreciation_lt_one]
  exact (effectiveLimit_continuous hb m.income_support.lower_pos).comp_continuous
    hpair hrange

private theorem normalizedPath_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) :
    Continuous (normalizedPath m p hp b hb) := by
  apply Continuous.subtype_mk
  change Continuous (fun r : FirmRate p =>
    ((1 + (r : ℝ), firmWage p hp r),
      -(r : ℝ) * effectiveLimit b m.income.lower (firmWage p hp r) (r : ℝ)))
  exact ((continuous_const.add continuous_subtype_val).prodMk
    (firmWage_continuous p hp)).prodMk
      (continuous_subtype_val.neg.mul (debtShift_continuous m p hp b hb))

private def criticalFirmRate (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) : FirmRate p :=
  ⟨criticalRate m, by
    have hm := criticalRate_pos m
    exact lt_trans (neg_lt_zero.mpr hp.depreciation_positive) hm⟩

private abbrev SubcriticalFirmRate (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) := Iio (criticalFirmRate m p hp)

private theorem subcritical_betaR (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : SubcriticalFirmRate m p hp) :
    m.beta * (1 + (r.1 : ℝ)) < 1 := by
  calc
    m.beta * (1 + (r.1 : ℝ)) < m.beta * (1 + criticalRate m) := by
      apply mul_lt_mul_of_pos_left _ m.beta_pos
      have hr := r.2
      change (r.1 : ℝ) < criticalRate m at hr
      linarith
    _ = 1 := beta_one_add_criticalRate m

private def impatientPath (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b)
    (r : SubcriticalFirmRate m p hp) : M06A.ImpatientPrices m :=
  ⟨normalizedPath m p hp b hb r.1, subcritical_betaR m p hp r⟩

private theorem impatientPath_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) :
    Continuous (impatientPath m p hp b hb) := by
  apply Continuous.subtype_mk
  exact (normalizedPath_continuous m p hp b hb).comp continuous_subtype_val

private def debtShiftPath (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b)
    (r : SubcriticalFirmRate m p hp) : ℝ :=
  (finitePrices m p hp b hb r.1).debtLimit

private theorem debtShiftPath_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) :
    Continuous (debtShiftPath m p hp b hb) := by
  exact (debtShift_continuous m p hp b hb).comp continuous_subtype_val

private def assetSupplyPath (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b)
    (r : SubcriticalFirmRate m p hp) : ℝ :=
  stationaryAssetSupply (m.withPrices (impatientPath m p hp b hb r).1)
    (debtShiftPath m p hp b hb r)
    (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd
      (impatientPath m p hp b hb r))

set_option maxHeartbeats 800000 in
private theorem assetSupplyPath_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) :
    Continuous (assetSupplyPath m hsmooth hcurvature hnd p hp b hb) := by
  exact (stationaryAssetSupply_joint_continuous m hsmooth hcurvature hnd).comp
    ((impatientPath_continuous m p hp b hb).prodMk
      (debtShiftPath_continuous m p hp b hb))

private def excessPath (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b)
    (r : SubcriticalFirmRate m p hp) : ℝ :=
  assetSupplyPath m hsmooth hcurvature hnd p hp b hb r - capitalDemand p hp r.1

private theorem excessPath_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) (b : ℝ) (hb : 0 ≤ b) :
    Continuous (excessPath m hsmooth hcurvature hnd p hp b hb) :=
  (assetSupplyPath_continuous m hsmooth hcurvature hnd p hp b hb).sub
    ((capitalDemand_continuous p hp).comp continuous_subtype_val)

/-- Gate-local G02 engine. It derives the two signs for the actual finite-cap household/firm
path, applies the IVT, and fills every field of the unchanged G01 equilibrium structure. -/
theorem finiteCap_equilibrium_exists_core (p : ProductionData) (hp : ProductionRegularity p)
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (hmean : LaborMeanOne m.income) (b : ℝ) (hb : 0 ≤ b) :
    ∃ e : StationaryEquilibrium p hp,
      e.household.beta = m.beta ∧
        e.household.utility = m.utility ∧
        e.household.income = m.income ∧
        e.originalPrices.debtLimit =
          effectiveLimit b m.income.lower (firmWage p hp e.rate) (e.rate : ℝ) ∧
        -p.depreciation < (e.rate : ℝ) ∧ (e.rate : ℝ) < 1 / m.beta - 1 := by
  obtain ⟨K_L, hK_L, r_L, hKdemand, hrneg, _hmarg, _houtput,
    _hcap, hRpos, hbetaL, hsupplyL⟩ :=
    finiteCap_lower_bracket p hp m hsmooth hcurvature hnd hmean b hb
  let lower : SubcriticalFirmRate m p hp := ⟨r_L, by
    change (r_L : ℝ) < criticalRate m
    linarith [criticalRate_pos m]⟩
  have hexcessL : excessPath m hsmooth hcurvature hnd p hp b hb lower < 0 := by
    change stationaryAssetSupply
        (m.withPrices (impatientPath m p hp b hb lower).1)
        (debtShiftPath m p hp b hb lower)
        (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd
          (impatientPath m p hp b hb lower)) - capitalDemand p hp r_L < 0
    have hprices : finitePrices m p hp b hb r_L =
        M09A3.lowerOriginalPrices m p hp b hb r_L := rfl
    have hhousehold :
        m.withPrices (normalizedPath m p hp b hb r_L) =
          M09A3.lowerHousehold m p hp b hb r_L := by
      rfl
    change stationaryAssetSupply
        (m.withPrices (normalizedPath m p hp b hb r_L))
        (finitePrices m p hp b hb r_L).debtLimit
        (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd
          (impatientPath m p hp b hb lower)) - capitalDemand p hp r_L < 0
    have hlaw : M06A.stationaryLawAtPrice m hsmooth hcurvature hnd
          (impatientPath m p hp b hb lower) =
        M06C.stationaryLaw (M09A3.lowerHousehold m p hp b hb r_L)
          hsmooth hcurvature hnd hbetaL := by
      have hinvariantLower := (M06C.stationaryLaw_properties
        (M09A3.lowerHousehold m p hp b hb r_L) hsmooth hcurvature hnd hbetaL).2.2
      have hinvariantOwn : householdLawStep
          (m.withPrices (normalizedPath m p hp b hb r_L))
          (M06C.stationaryLaw (M09A3.lowerHousehold m p hp b hb r_L)
            hsmooth hcurvature hnd hbetaL) =
          M06C.stationaryLaw (M09A3.lowerHousehold m p hp b hb r_L)
            hsmooth hcurvature hnd hbetaL := by
        rw [hhousehold]
        exact hinvariantLower
      symm
      simpa [M06A.stationaryLawAtPrice, impatientPath] using
        (M06A.stationaryLaw_unique
          (m.withPrices (normalizedPath m p hp b hb r_L)) hsmooth hcurvature hnd
          (subcritical_betaR m p hp lower)
          (M06C.stationaryLaw (M09A3.lowerHousehold m p hp b hb r_L)
            hsmooth hcurvature hnd hbetaL) hinvariantOwn)
    rw [hprices, hhousehold]
    rw [hlaw, hKdemand]
    exact sub_neg.mpr hsupplyL
  let lambda := criticalRate m
  have hlambda : 0 < lambda := criticalRate_pos m
  let c := (lambda + p.depreciation) / 2
  have hc : 0 < c := by dsimp [c]; linarith [hp.depreciation_positive]
  let rseqReal : ℕ → ℝ := fun n => lambda - c * marginalStep n
  have hrseqLower (n : ℕ) : -p.depreciation < rseqReal n := by
    have hstep := marginalStep_pos n
    have hstepLe : marginalStep n ≤ 1 := by
      calc
        marginalStep n ≤ marginalStep 0 := marginalStep_antitone (Nat.zero_le n)
        _ = 1 := by norm_num [marginalStep]
    dsimp [rseqReal, c]
    nlinarith [hp.depreciation_positive]
  let rseq : ℕ → FirmRate p := fun n => ⟨rseqReal n, hrseqLower n⟩
  have hrseqUpper (n : ℕ) : rseqReal n < lambda := by
    dsimp [rseqReal]
    exact sub_lt_self _ (mul_pos hc (marginalStep_pos n))
  have hrseqImpatient (n : ℕ) : m.beta * (1 + rseqReal n) < 1 := by
    calc
      m.beta * (1 + rseqReal n) < m.beta * (1 + lambda) := by
        exact mul_lt_mul_of_pos_left (by linarith [hrseqUpper n]) m.beta_pos
      _ = 1 := by
        dsimp [lambda]
        exact beta_one_add_criticalRate m
  have hrseq : Tendsto rseq atTop (nhds (⟨lambda, by
      exact lt_trans (neg_lt_zero.mpr hp.depreciation_positive) hlambda⟩ : FirmRate p)) := by
    apply tendsto_subtype_rng.2
    change Tendsto rseqReal atTop (nhds lambda)
    simpa [rseqReal] using
      (tendsto_const_nhds.sub (tendsto_const_nhds.mul marginalStep_tendsto_zero) :
        Tendsto (fun n => lambda - c * marginalStep n) atTop (nhds (lambda - c * 0)))
  let pricesSeq : ℕ → OriginalPrices m.income := fun n => finitePrices m p hp b hb (rseq n)
  let qseq : ℕ → AdmissibleNormalizedPrices m.income := fun n =>
    admissibleOfOriginal (pricesSeq n)
  let rstar : FirmRate p := ⟨lambda, by
    exact lt_trans (neg_lt_zero.mpr hp.depreciation_positive) hlambda⟩
  let pricesStar := finitePrices m p hp b hb rstar
  let qstar : AdmissibleNormalizedPrices m.income := admissibleOfOriginal pricesStar
  have hwseq : Tendsto (fun n => firmWage p hp (rseq n)) atTop
      (nhds (firmWage p hp rstar)) :=
    ((firmWage_continuous p hp).tendsto rstar).comp hrseq
  have hpair : Tendsto (fun n => (firmWage p hp (rseq n), rseqReal n)) atTop
      (nhds (firmWage p hp rstar, lambda)) := by
    rw [nhds_prod_eq]
    exact hwseq.prodMk (by
      change Tendsto (fun n => (rseq n : ℝ)) atTop (nhds (rstar : ℝ))
      exact (continuous_subtype_val.tendsto rstar).comp hrseq)
  have hphi : Tendsto (fun n => (pricesSeq n).debtLimit) atTop
      (nhds pricesStar.debtLimit) := by
    have hwithin : Tendsto (fun n => (firmWage p hp (rseq n), rseqReal n)) atTop
        (nhdsWithin (firmWage p hp rstar, lambda)
          {x : ℝ × ℝ | 0 < x.1 ∧ -1 < x.2}) := by
      rw [tendsto_nhdsWithin_iff]
      refine ⟨hpair, Filter.Eventually.of_forall fun n => ?_⟩
      exact ⟨firmWage_positive p hp (rseq n), by
        have := hrseqLower n
        linarith [hp.depreciation_lt_one]⟩
    have hcphi := (effectiveLimit_continuous hb m.income_support.lower_pos)
      (firmWage p hp rstar, lambda) ⟨firmWage_positive p hp rstar, by
        dsimp [lambda]
        linarith [hlambda]⟩
    change Tendsto
      (fun n => effectiveLimit b m.income.lower
        (firmWage p hp (rseq n)) (rseqReal n)) atTop
      (nhds (effectiveLimit b m.income.lower (firmWage p hp rstar) lambda))
    exact hcphi.tendsto.comp hwithin
  have hq : Tendsto qseq atTop (nhds qstar) := by
    apply tendsto_subtype_rng.2
    change Tendsto (fun n =>
      ((1 + rseqReal n, firmWage p hp (rseq n)),
        -rseqReal n * (pricesSeq n).debtLimit)) atTop
      (nhds ((1 + lambda, firmWage p hp rstar), -lambda * pricesStar.debtLimit))
    rw [nhds_prod_eq, nhds_prod_eq]
    have hrreal : Tendsto rseqReal atTop (nhds lambda) := by
      change Tendsto (fun n => (rseq n : ℝ)) atTop (nhds (rstar : ℝ))
      exact (continuous_subtype_val.tendsto rstar).comp hrseq
    exact ((tendsto_const_nhds.add hrreal).prodMk hwseq).prodMk (hrreal.neg.mul hphi)
  have hsupplyTop : Tendsto (fun n =>
      stationaryAssetSupply (m.withPrices (qseq n)) (pricesSeq n).debtLimit
        (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
          (by change m.beta * (1 + rseqReal n) < 1; exact hrseqImpatient n)))
      atTop atTop := by
    have hphiNonneg : ∀ n, 0 ≤ (pricesSeq n).debtLimit :=
      fun n => (pricesSeq n).debtLimit_nonneg
    have hnormalized : ∀ n,
        (qseq n).intercept = -((qseq n).grossReturn - 1) * (pricesSeq n).debtLimit := by
      intro n
      simp only [qseq, admissibleOfOriginal, AdmissibleNormalizedPrices.intercept,
        AdmissibleNormalizedPrices.grossReturn, pricesSeq, finitePrices,
        OriginalPrices.normalized]
      ring
    have hsubcritical : ∀ n, m.beta * (qseq n).grossReturn < 1 := by
      intro n
      change m.beta * (1 + rseqReal n) < 1
      exact hrseqImpatient n
    have hcritical : m.beta * qstar.grossReturn = 1 := by
      change m.beta * (1 + lambda) = 1
      dsimp [lambda]
      exact beta_one_add_criticalRate m
    exact assetSupply_tendsTo_infinity_at_impatience m hsmooth hcurvature hnd
      qseq qstar (fun n => (pricesSeq n).debtLimit) pricesStar.debtLimit
      hphiNonneg hnormalized hsubcritical hcritical hq hphi
  have hKseq : Tendsto (fun n => capitalDemand p hp (rseq n)) atTop
      (nhds (capitalDemand p hp rstar)) :=
    ((capitalDemand_continuous p hp).tendsto rstar).comp hrseq
  have heventSupply : ∀ᶠ n in atTop,
      capitalDemand p hp rstar + 1 ≤
        stationaryAssetSupply (m.withPrices (qseq n)) (pricesSeq n).debtLimit
          (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
            (by change m.beta * (1 + rseqReal n) < 1; exact hrseqImpatient n)) :=
    (tendsto_atTop.1 hsupplyTop (capitalDemand p hp rstar + 1))
  have heventK : ∀ᶠ n in atTop,
      capitalDemand p hp (rseq n) < capitalDemand p hp rstar + 1 :=
    hKseq.eventually (eventually_lt_nhds (by linarith))
  have heventAbove : ∀ᶠ n in atTop, (r_L : ℝ) < rseqReal n := by
    have hrreal : Tendsto rseqReal atTop (nhds lambda) := by
      change Tendsto (fun n => (rseq n : ℝ)) atTop (nhds (rstar : ℝ))
      exact (continuous_subtype_val.tendsto rstar).comp hrseq
    exact hrreal.eventually (eventually_gt_nhds (by linarith))
  obtain ⟨n, hsupplyN, hKN, habove⟩ :=
    (heventSupply.and (heventK.and heventAbove)).exists
  let upper : SubcriticalFirmRate m p hp := ⟨rseq n, by
    change rseqReal n < criticalRate m
    simpa [lambda] using hrseqUpper n⟩
  have hexcessU : 0 < excessPath m hsmooth hcurvature hnd p hp b hb upper := by
    change 0 < stationaryAssetSupply
        (m.withPrices (impatientPath m p hp b hb upper).1)
        (debtShiftPath m p hp b hb upper)
        (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd
          (impatientPath m p hp b hb upper)) - capitalDemand p hp (rseq n)
    have hsupplyActual : capitalDemand p hp (rseq n) < stationaryAssetSupply
        (m.withPrices (qseq n)) (pricesSeq n).debtLimit
        (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
          (by change m.beta * (1 + rseqReal n) < 1; exact hrseqImpatient n)) :=
      lt_of_lt_of_le hKN hsupplyN
    simpa [impatientPath, normalizedPath, debtShiftPath, finitePrices, qseq, pricesSeq,
      admissibleOfOriginal, M06A.stationaryLawAtPrice, M06A.stationaryLaw,
      M06C.stationaryLaw] using sub_pos.mpr hsupplyActual
  have hlowerUpper : lower ≤ upper := by
    apply Subtype.coe_le_coe.mp
    exact habove.le
  have hzeroMem : (0 : ℝ) ∈ Set.Icc
      (excessPath m hsmooth hcurvature hnd p hp b hb lower)
      (excessPath m hsmooth hcurvature hnd p hp b hb upper) :=
    ⟨hexcessL.le, hexcessU.le⟩
  let rateSegment : unitInterval → SubcriticalFirmRate m p hp := fun t =>
    ⟨⟨(1 - (t : ℝ)) * (lower.1 : ℝ) + (t : ℝ) * (upper.1 : ℝ), by
        have ht0 : 0 ≤ (t : ℝ) := t.property.1
        have ht1 : (t : ℝ) ≤ 1 := t.property.2
        have hlfirm := lower.1.property
        have hufirm := upper.1.property
        change -p.depreciation < (lower.1 : ℝ) at hlfirm
        change -p.depreciation < (upper.1 : ℝ) at hufirm
        change -p.depreciation <
          (1 - (t : ℝ)) * (lower.1 : ℝ) + (t : ℝ) * (upper.1 : ℝ)
        nlinarith⟩,
      by
        have ht0 : 0 ≤ (t : ℝ) := t.property.1
        have ht1 : (t : ℝ) ≤ 1 := t.property.2
        have hlcrit := lower.2
        have hucrit := upper.2
        change (lower.1 : ℝ) < criticalRate m at hlcrit
        change (upper.1 : ℝ) < criticalRate m at hucrit
        change (1 - (t : ℝ)) * (lower.1 : ℝ) + (t : ℝ) * (upper.1 : ℝ) <
          criticalRate m
        nlinarith⟩
  have hrateSegment : Continuous rateSegment := by
    apply Continuous.subtype_mk
    apply Continuous.subtype_mk
    change Continuous (fun t : unitInterval =>
      (1 - (t : ℝ)) * (lower.1 : ℝ) + (t : ℝ) * (upper.1 : ℝ))
    fun_prop
  have hsegmentZero : excessPath m hsmooth hcurvature hnd p hp b hb
      (rateSegment 0) = excessPath m hsmooth hcurvature hnd p hp b hb lower := by
    congr 1
    ext
    simp [rateSegment]
  have hsegmentOne : excessPath m hsmooth hcurvature hnd p hp b hb
      (rateSegment 1) = excessPath m hsmooth hcurvature hnd p hp b hb upper := by
    congr 1
    ext
    simp [rateSegment]
  have hzeroSegment : (0 : ℝ) ∈ Set.Icc
      (excessPath m hsmooth hcurvature hnd p hp b hb (rateSegment 0))
      (excessPath m hsmooth hcurvature hnd p hp b hb (rateSegment 1)) := by
    simpa [hsegmentZero, hsegmentOne] using hzeroMem
  obtain ⟨troot, hroot⟩ :=
    (intermediate_value_univ (0 : unitInterval) (1 : unitInterval)
      ((excessPath_continuous m hsmooth hcurvature hnd p hp b hb).comp
        hrateSegment)) hzeroSegment
  let root := rateSegment troot
  have hrootZero : excessPath m hsmooth hcurvature hnd p hp b hb root = 0 := by
    simpa [root, Function.comp_def] using hroot
  have htrootPos : 0 < (troot : ℝ) := by
    rcases troot.property.1.eq_or_lt with hzero | hpos
    · have htrootZero : troot = (0 : unitInterval) := by
        apply Subtype.ext
        exact hzero.symm
      have hendpoint : excessPath m hsmooth hcurvature hnd p hp b hb lower = 0 := by
        rw [htrootZero] at hroot
        simpa [Function.comp_def, hsegmentZero] using hroot
      linarith
    · exact hpos
  have htrootLtOne : (troot : ℝ) < 1 := by
    rcases troot.property.2.lt_or_eq with hlt | hone
    · exact hlt
    · have htrootOne : troot = (1 : unitInterval) := by
        apply Subtype.ext
        exact hone
      have hendpoint : excessPath m hsmooth hcurvature hnd p hp b hb upper = 0 := by
        rw [htrootOne] at hroot
        simpa [Function.comp_def, hsegmentOne] using hroot
      linarith
  have hrootInterior : (lower.1 : ℝ) < (root.1 : ℝ) ∧
      (root.1 : ℝ) < (upper.1 : ℝ) := by
    have hlowerUpperReal : (lower.1 : ℝ) < (upper.1 : ℝ) := by
      exact habove
    dsimp [root, rateSegment]
    constructor <;> nlinarith
  let prices := finitePrices m p hp b hb root.1
  let q := impatientPath m p hp b hb root
  let household := m.withPrices q.1
  let pi := M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q
  have hinvariant : householdLawStep household pi = pi := by
    exact M06A.stationaryLaw_invariant household hsmooth hcurvature hnd q.2
  have hsupport := (M06C.stationaryLaw_properties household hsmooth hcurvature hnd q.2).2.1
  have hzInt : Integrable (fun z : Resources => (z : ℝ)) (pi : Measure Resources) := by
    apply M06C.resource_integrable_of_compact_support pi (lowerEffectiveIncome household)
      (M06C.stationaryBound household hsmooth hcurvature hnd q.2)
    simpa [pi, M06A.stationaryLawAtPrice, M06A.stationaryLaw, M06C.stationaryLaw]
      using hsupport
  have hAInt : Integrable (fun z : Resources => (assetPolicy household z : ℝ))
      (pi : Measure Resources) := by
    simpa [household, pi, q] using
      (M06D.stationary_asset_integrable m hsmooth hcurvature hnd q)
  have hnetInt : Integrable (M06B.netAsset household prices.debtLimit)
      (pi : Measure Resources) := by
    exact hAInt.sub (integrable_const prices.debtLimit)
  have hclearing : (∫ z, M06B.netAsset household prices.debtLimit z ∂(pi : Measure Resources)) =
      capitalDemand p hp root.1 := by
    have hx : assetSupplyPath m hsmooth hcurvature hnd p hp b hb root -
        capitalDemand p hp root.1 = 0 := by
      simpa [excessPath] using hrootZero
    change stationaryAssetSupply household prices.debtLimit pi = capitalDemand p hp root.1
    have := sub_eq_zero.mp hx
    simpa [assetSupplyPath, household, prices, pi, q, impatientPath, debtShiftPath]
      using this
  let e : StationaryEquilibrium p hp :=
    { rate := root.1
      household := household
      utility_smooth := hsmooth
      income_nondegenerate := hnd
      labor_mean_one := hmean
      iid_histories := fun k => history_independent m.income k
      originalPrices := prices
      original_rate := rfl
      original_wage := rfl
      normalized_prices := by
        exact admissibleOfOriginal_toPrices prices
      resourceLaw := pi
      resource_integrable := hzInt
      net_assets_integrable := hnetInt
      capital_clearing := hclearing
      firm_optimization := capitalDemand_wage_constructed p hp
      lifetime_optimality := fun z => canonicalPolicy_lifetime_optimal household z
      household_kernel := householdKernel_feller_monotone household
      budget_normalization := fun r w l phi a aNext c =>
        shifted_budget_iff r w l phi a aNext c
      resource_stationary := hinvariant }
  refine ⟨e, rfl, rfl, rfl, rfl, root.1.property, ?_⟩
  exact hrootInterior.2.trans upper.2

end M09B1

end
end Aiyagari1994
