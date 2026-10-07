import Aiyagari1994.Aggregate.LowerBoundary
import Aiyagari1994.Aggregate.ParameterContinuity
import Aiyagari1994.Aggregate.UpperBoundary
import Aiyagari1994.Equilibrium.Definition

/-! Gate-local construction for natural-debt-limit stationary-equilibrium existence. -/

open Filter MeasureTheory ProbabilityTheory Set Topology
open scoped NNReal ProbabilityTheory Topology

namespace Aiyagari1994
noncomputable section

namespace M09B2

private def criticalRate (m : HouseholdPrimitives) : ℝ := 1 / m.beta - 1

private theorem criticalRate_pos (m : HouseholdPrimitives) : 0 < criticalRate m := by
  rw [criticalRate, sub_pos]
  exact (lt_div_iff₀ m.beta_pos).2 (by simpa using m.beta_lt_one)

private theorem beta_one_add_criticalRate (m : HouseholdPrimitives) :
    m.beta * (1 + criticalRate m) = 1 := by
  rw [criticalRate]
  field_simp [ne_of_gt m.beta_pos]
  ring

private abbrev NaturalRate (m : HouseholdPrimitives) := Ioo (0 : ℝ) (criticalRate m)

private def firmRateOf (p : ProductionData) (hp : ProductionRegularity p)
    {m : HouseholdPrimitives} (r : NaturalRate m) : FirmRate p :=
  ⟨r, lt_trans (neg_lt_zero.mpr hp.depreciation_positive) r.2.1⟩

private theorem firmRateOf_continuous (p : ProductionData) (hp : ProductionRegularity p)
    (m : HouseholdPrimitives) :
    Continuous (firmRateOf p hp : NaturalRate m → FirmRate p) := by
  apply Continuous.subtype_mk
  exact continuous_subtype_val

private theorem natural_betaR (m : HouseholdPrimitives) (r : NaturalRate m) :
    m.beta * (1 + (r : ℝ)) < 1 := by
  calc
    m.beta * (1 + (r : ℝ)) < m.beta * (1 + criticalRate m) := by
      exact mul_lt_mul_of_pos_left (by linarith [r.2.2]) m.beta_pos
    _ = 1 := beta_one_add_criticalRate m

private def naturalPrices (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) : OriginalPrices m.income :=
  naturalCapPrices m.income m.income_support (firmWage p hp (firmRateOf p hp r)) r
    (firmWage_positive p hp (firmRateOf p hp r)) r.2.1

private def normalizedPath (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) :
    AdmissibleNormalizedPrices m.income :=
  M08C.normalizedPrices m r (firmWage p hp (firmRateOf p hp r)) r.2.1
    (firmWage_positive p hp (firmRateOf p hp r))

private theorem naturalPrices_normalized (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) :
    (naturalPrices m p hp r).normalized = (normalizedPath m p hp r).toPrices := by
  rw [NormalizedPrices.mk.injEq]
  simp only [naturalPrices, naturalCapPrices, OriginalPrices.normalized, normalizedPath,
    M08C.normalizedPrices, AdmissibleNormalizedPrices.toPrices]
  refine ⟨rfl, rfl, ?_⟩
  exact naturalLimit_intercept r.2.1

private theorem normalizedPath_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) : Continuous (normalizedPath m p hp) := by
  apply Continuous.subtype_mk
  change Continuous (fun r : NaturalRate m =>
    ((1 + (r : ℝ), firmWage p hp (firmRateOf p hp r)),
      -firmWage p hp (firmRateOf p hp r) * m.income.lower))
  have hw : Continuous (fun r : NaturalRate m => firmWage p hp (firmRateOf p hp r)) :=
    (firmWage_continuous p hp).comp (firmRateOf_continuous p hp m)
  exact ((continuous_const.add continuous_subtype_val).prodMk hw).prodMk
    (hw.neg.mul continuous_const)

private def impatientPath (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) : M06A.ImpatientPrices m :=
  ⟨normalizedPath m p hp r, natural_betaR m r⟩

private theorem impatientPath_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) : Continuous (impatientPath m p hp) := by
  apply Continuous.subtype_mk
  exact normalizedPath_continuous m p hp

private def debtShiftPath (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) : ℝ :=
  naturalLimit m.income.lower (firmWage p hp (firmRateOf p hp r)) r

private theorem debtShiftPath_continuous (m : HouseholdPrimitives) (p : ProductionData)
    (hp : ProductionRegularity p) : Continuous (debtShiftPath m p hp) := by
  have hpair : Continuous (fun r : NaturalRate m =>
      (firmWage p hp (firmRateOf p hp r), (r : ℝ))) :=
    ((firmWage_continuous p hp).comp (firmRateOf_continuous p hp m)).prodMk
      continuous_subtype_val
  have hrange : ∀ r : NaturalRate m,
      (firmWage p hp (firmRateOf p hp r), (r : ℝ)) ∈
        {x : ℝ × ℝ | 0 < x.1 ∧ 0 < x.2} :=
    fun r => ⟨firmWage_positive p hp (firmRateOf p hp r), r.2.1⟩
  exact (naturalLimit_continuous m.income.lower).comp_continuous hpair hrange

private def assetSupplyPath (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) : ℝ :=
  stationaryAssetSupply (m.withPrices (impatientPath m p hp r).1)
    (debtShiftPath m p hp r)
    (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd (impatientPath m p hp r))

set_option maxHeartbeats 800000 in
private theorem assetSupplyPath_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) :
    Continuous (assetSupplyPath m hsmooth hcurvature hnd p hp) := by
  exact (stationaryAssetSupply_joint_continuous m hsmooth hcurvature hnd).comp
    ((impatientPath_continuous m p hp).prodMk (debtShiftPath_continuous m p hp))

private def excessPath (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) (r : NaturalRate m) : ℝ :=
  assetSupplyPath m hsmooth hcurvature hnd p hp r -
    capitalDemand p hp (firmRateOf p hp r)

private theorem excessPath_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (p : ProductionData)
    (hp : ProductionRegularity p) :
    Continuous (excessPath m hsmooth hcurvature hnd p hp) :=
  (assetSupplyPath_continuous m hsmooth hcurvature hnd p hp).sub
    ((capitalDemand_continuous p hp).comp (firmRateOf_continuous p hp m))

/-- Gate-local G03 engine. It derives both endpoint signs on the positive natural-limit firm
path, applies the IVT, and fills every field of the unchanged G01 equilibrium structure. -/
theorem naturalCap_equilibrium_exists_core (p : ProductionData) (hp : ProductionRegularity p)
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (hmean : LaborMeanOne m.income) :
    ∃ e : StationaryEquilibrium p hp,
      e.household.beta = m.beta ∧
        e.household.utility = m.utility ∧
        e.household.income = m.income ∧
        e.originalPrices.debtLimit =
          naturalLimit m.income.lower (firmWage p hp e.rate) (e.rate : ℝ) ∧
        0 < (e.rate : ℝ) ∧ (e.rate : ℝ) < 1 / m.beta - 1 := by
  let lambda := criticalRate m
  have hlambda : 0 < lambda := criticalRate_pos m
  let c := lambda / 2
  have hc : 0 < c := by dsimp [c]; linarith
  have hcLt : c < lambda := by dsimp [c]; linarith
  let lowerRateReal : ℕ → ℝ := fun n => c * marginalStep n
  have hlowerPos (n : ℕ) : 0 < lowerRateReal n :=
    mul_pos hc (marginalStep_pos n)
  have hstepLe (n : ℕ) : marginalStep n ≤ 1 := by
    calc
      marginalStep n ≤ marginalStep 0 := marginalStep_antitone (Nat.zero_le n)
      _ = 1 := by norm_num [marginalStep]
  have hlowerUpper (n : ℕ) : lowerRateReal n < lambda := by
    dsimp [lowerRateReal]
    exact (mul_le_of_le_one_right hc.le (hstepLe n)).trans_lt hcLt
  let lowerRates : ℕ → NaturalRate m := fun n =>
    ⟨lowerRateReal n, hlowerPos n, by simpa [lambda] using hlowerUpper n⟩
  let zeroFirmRate : FirmRate p :=
    ⟨0, neg_lt_zero.mpr hp.depreciation_positive⟩
  have hlowerTendsto : Tendsto lowerRateReal atTop (nhds 0) := by
    simpa [lowerRateReal] using
      (tendsto_const_nhds.mul marginalStep_tendsto_zero :
        Tendsto (fun n => c * marginalStep n) atTop (nhds (c * 0)))
  have hlowerFirmTendsto : Tendsto
      (fun n => firmRateOf p hp (lowerRates n)) atTop (nhds zeroFirmRate) := by
    apply tendsto_subtype_rng.2
    simpa [lowerRates, firmRateOf, zeroFirmRate] using hlowerTendsto
  have hwLower : Tendsto
      (fun n => firmWage p hp (firmRateOf p hp (lowerRates n))) atTop
      (nhds (firmWage p hp zeroFirmRate)) :=
    ((firmWage_continuous p hp).tendsto zeroFirmRate).comp hlowerFirmTendsto
  have hKLower : Tendsto
      (fun n => capitalDemand p hp (firmRateOf p hp (lowerRates n))) atTop
      (nhds (capitalDemand p hp zeroFirmRate)) :=
    ((capitalDemand_continuous p hp).tendsto zeroFirmRate).comp hlowerFirmTendsto
  have hsupplyBot := naturalAssetSupply_tendsTo_neg_infinity m hsmooth hcurvature hnd
    lowerRateReal (fun n => firmWage p hp (firmRateOf p hp (lowerRates n)))
    (firmWage p hp zeroFirmRate) hlowerPos
    (fun n => firmWage_positive p hp (firmRateOf p hp (lowerRates n)))
    hlowerTendsto hwLower (firmWage_positive p hp zeroFirmRate)
  have heventSupply : ∀ᶠ n in atTop,
      M08C.naturalAssetSupplyExtension m hsmooth hcurvature hnd
        (lowerRateReal n) (firmWage p hp (firmRateOf p hp (lowerRates n)))
        (hlowerPos n) (firmWage_positive p hp (firmRateOf p hp (lowerRates n))) ≤
          capitalDemand p hp zeroFirmRate - 1 :=
    tendsto_atBot.1 hsupplyBot (capitalDemand p hp zeroFirmRate - 1)
  have heventK : ∀ᶠ n in atTop,
      capitalDemand p hp zeroFirmRate - 1 <
        capitalDemand p hp (firmRateOf p hp (lowerRates n)) :=
    hKLower.eventually (eventually_gt_nhds (by linarith))
  obtain ⟨nL, hsupplyL, hKL⟩ := (heventSupply.and heventK).exists
  let lower : NaturalRate m := lowerRates nL
  have hexcessL : excessPath m hsmooth hcurvature hnd p hp lower < 0 := by
    have hactual : M08C.naturalAssetSupplyExtension m hsmooth hcurvature hnd
        (lowerRateReal nL) (firmWage p hp (firmRateOf p hp (lowerRates nL)))
        (hlowerPos nL) (firmWage_positive p hp (firmRateOf p hp (lowerRates nL))) <
        capitalDemand p hp (firmRateOf p hp (lowerRates nL)) :=
      lt_of_le_of_lt hsupplyL hKL
    have himpatient : m.beta * (1 + lowerRateReal nL) < 1 := by
      simpa [lower, lowerRates] using natural_betaR m lower
    simp only [M08C.naturalAssetSupplyExtension, dif_pos himpatient] at hactual
    rw [show excessPath m hsmooth hcurvature hnd p hp lower =
        assetSupplyPath m hsmooth hcurvature hnd p hp lower -
          capitalDemand p hp (firmRateOf p hp lower) by rfl]
    rw [sub_lt_zero]
    simpa [lower, lowerRates, assetSupplyPath, impatientPath, normalizedPath,
      debtShiftPath, natural_betaR,
      M06A.stationaryLawAtPrice, M06A.stationaryLaw, M06C.stationaryLaw,
      M08C.naturalDebtShift, naturalLimit] using hactual
  let upperRateReal : ℕ → ℝ := fun n => lambda - c * marginalStep n
  have hupperPos (n : ℕ) : 0 < upperRateReal n := by
    dsimp [upperRateReal]
    nlinarith [mul_le_of_le_one_right hc.le (hstepLe n)]
  have hupperLt (n : ℕ) : upperRateReal n < lambda := by
    dsimp [upperRateReal]
    exact sub_lt_self _ (mul_pos hc (marginalStep_pos n))
  let upperRates : ℕ → NaturalRate m := fun n =>
    ⟨upperRateReal n, hupperPos n, by simpa [lambda] using hupperLt n⟩
  let criticalFirmRate : FirmRate p :=
    ⟨lambda, lt_trans (neg_lt_zero.mpr hp.depreciation_positive) hlambda⟩
  have hupperTendsto : Tendsto upperRateReal atTop (nhds lambda) := by
    simpa [upperRateReal] using
      (tendsto_const_nhds.sub (tendsto_const_nhds.mul marginalStep_tendsto_zero) :
        Tendsto (fun n => lambda - c * marginalStep n) atTop (nhds (lambda - c * 0)))
  have hupperFirmTendsto : Tendsto
      (fun n => firmRateOf p hp (upperRates n)) atTop (nhds criticalFirmRate) := by
    apply tendsto_subtype_rng.2
    simpa [upperRates, firmRateOf, criticalFirmRate] using hupperTendsto
  have hwUpper : Tendsto
      (fun n => firmWage p hp (firmRateOf p hp (upperRates n))) atTop
      (nhds (firmWage p hp criticalFirmRate)) :=
    ((firmWage_continuous p hp).tendsto criticalFirmRate).comp hupperFirmTendsto
  have hKUpper : Tendsto
      (fun n => capitalDemand p hp (firmRateOf p hp (upperRates n))) atTop
      (nhds (capitalDemand p hp criticalFirmRate)) :=
    ((capitalDemand_continuous p hp).tendsto criticalFirmRate).comp hupperFirmTendsto
  let qseq : ℕ → AdmissibleNormalizedPrices m.income := fun n =>
    normalizedPath m p hp (upperRates n)
  let qstar : AdmissibleNormalizedPrices m.income :=
    M08C.normalizedPrices m lambda (firmWage p hp criticalFirmRate) hlambda
      (firmWage_positive p hp criticalFirmRate)
  let phiSeq : ℕ → ℝ := fun n => debtShiftPath m p hp (upperRates n)
  let phiStar : ℝ := naturalLimit m.income.lower
    (firmWage p hp criticalFirmRate) lambda
  have hq : Tendsto qseq atTop (nhds qstar) := by
    apply tendsto_subtype_rng.2
    change Tendsto (fun n =>
      ((1 + upperRateReal n, firmWage p hp (firmRateOf p hp (upperRates n))),
        -firmWage p hp (firmRateOf p hp (upperRates n)) * m.income.lower)) atTop
      (nhds ((1 + lambda, firmWage p hp criticalFirmRate),
        -firmWage p hp criticalFirmRate * m.income.lower))
    rw [nhds_prod_eq, nhds_prod_eq]
    exact ((tendsto_const_nhds.add hupperTendsto).prodMk hwUpper).prodMk
      (hwUpper.neg.mul_const _)
  have hphi : Tendsto phiSeq atTop (nhds phiStar) := by
    change Tendsto (fun n => naturalLimit m.income.lower
      (firmWage p hp (firmRateOf p hp (upperRates n))) (upperRateReal n)) atTop
      (nhds (naturalLimit m.income.lower (firmWage p hp criticalFirmRate) lambda))
    exact ((hwUpper.mul_const _).div hupperTendsto (ne_of_gt hlambda))
  have hsupplyTop : Tendsto (fun n =>
      stationaryAssetSupply (m.withPrices (qseq n)) (phiSeq n)
        (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
          (natural_betaR m (upperRates n)))) atTop atTop := by
    apply assetSupply_tendsTo_infinity_at_impatience m hsmooth hcurvature hnd
      qseq qstar phiSeq phiStar
    · intro n
      exact naturalLimit_nonneg m.income_support.lower_pos
        (firmWage_positive p hp (firmRateOf p hp (upperRates n))) (upperRates n).2.1
    · intro n
      change -firmWage p hp (firmRateOf p hp (upperRates n)) * m.income.lower =
        -((1 + (upperRates n : ℝ)) - 1) *
          naturalLimit m.income.lower
            (firmWage p hp (firmRateOf p hp (upperRates n))) (upperRates n)
      have hintercept := naturalLimit_intercept (lo := m.income.lower)
        (w := firmWage p hp (firmRateOf p hp (upperRates n))) (upperRates n).2.1
      nlinarith
    · dsimp [qstar, M08C.normalizedPrices]
      change m.beta * (1 + lambda) = 1
      dsimp [lambda]
      exact beta_one_add_criticalRate m
    · exact hq
    · exact hphi
  have heventSupplyU : ∀ᶠ n in atTop,
      capitalDemand p hp criticalFirmRate + 1 ≤
        stationaryAssetSupply (m.withPrices (qseq n)) (phiSeq n)
          (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
            (natural_betaR m (upperRates n))) :=
    tendsto_atTop.1 hsupplyTop (capitalDemand p hp criticalFirmRate + 1)
  have heventKU : ∀ᶠ n in atTop,
      capitalDemand p hp (firmRateOf p hp (upperRates n)) <
        capitalDemand p hp criticalFirmRate + 1 :=
    hKUpper.eventually (eventually_lt_nhds (by linarith))
  have heventAbove : ∀ᶠ n in atTop, (lower : ℝ) < upperRateReal n :=
    hupperTendsto.eventually (eventually_gt_nhds lower.2.2)
  obtain ⟨nU, hsupplyU, hKU, habove⟩ :=
    (heventSupplyU.and (heventKU.and heventAbove)).exists
  let upper : NaturalRate m := upperRates nU
  have hexcessU : 0 < excessPath m hsmooth hcurvature hnd p hp upper := by
    rw [show excessPath m hsmooth hcurvature hnd p hp upper =
        assetSupplyPath m hsmooth hcurvature hnd p hp upper -
          capitalDemand p hp (firmRateOf p hp upper) by rfl]
    rw [sub_pos]
    have hactual : capitalDemand p hp (firmRateOf p hp (upperRates nU)) <
        stationaryAssetSupply (m.withPrices (qseq nU)) (phiSeq nU)
          (M06C.stationaryLaw (m.withPrices (qseq nU)) hsmooth hcurvature hnd
            (natural_betaR m (upperRates nU))) :=
      lt_of_lt_of_le hKU hsupplyU
    simpa [upper, qseq, phiSeq, assetSupplyPath, impatientPath, debtShiftPath,
      M06A.stationaryLawAtPrice, M06A.stationaryLaw, M06C.stationaryLaw] using hactual
  have hlowerUpper : lower ≤ upper := by
    exact habove.le
  have hzeroMem : (0 : ℝ) ∈ Set.Icc
      (excessPath m hsmooth hcurvature hnd p hp lower)
      (excessPath m hsmooth hcurvature hnd p hp upper) :=
    ⟨hexcessL.le, hexcessU.le⟩
  let rateSegment : unitInterval → NaturalRate m := fun t =>
    ⟨(1 - (t : ℝ)) * (lower : ℝ) + (t : ℝ) * (upper : ℝ), by
      have ht0 : 0 ≤ (t : ℝ) := t.property.1
      have ht1 : (t : ℝ) ≤ 1 := t.property.2
      nlinarith [lower.2.1, upper.2.1], by
      have ht0 : 0 ≤ (t : ℝ) := t.property.1
      have ht1 : (t : ℝ) ≤ 1 := t.property.2
      nlinarith [lower.2.2, upper.2.2]⟩
  have hrateSegment : Continuous rateSegment := by
    apply Continuous.subtype_mk
    change Continuous (fun t : unitInterval =>
      (1 - (t : ℝ)) * (lower : ℝ) + (t : ℝ) * (upper : ℝ))
    fun_prop
  have hsegmentZero : excessPath m hsmooth hcurvature hnd p hp (rateSegment 0) =
      excessPath m hsmooth hcurvature hnd p hp lower := by
    congr 1
    ext
    simp [rateSegment]
  have hsegmentOne : excessPath m hsmooth hcurvature hnd p hp (rateSegment 1) =
      excessPath m hsmooth hcurvature hnd p hp upper := by
    congr 1
    ext
    simp [rateSegment]
  have hzeroSegment : (0 : ℝ) ∈ Set.Icc
      (excessPath m hsmooth hcurvature hnd p hp (rateSegment 0))
      (excessPath m hsmooth hcurvature hnd p hp (rateSegment 1)) := by
    simpa [hsegmentZero, hsegmentOne] using hzeroMem
  obtain ⟨troot, hroot⟩ :=
    (intermediate_value_univ (0 : unitInterval) (1 : unitInterval)
      ((excessPath_continuous m hsmooth hcurvature hnd p hp).comp hrateSegment))
      hzeroSegment
  let root := rateSegment troot
  have hrootZero : excessPath m hsmooth hcurvature hnd p hp root = 0 := by
    simpa [root, Function.comp_def] using hroot
  have htrootPos : 0 < (troot : ℝ) := by
    rcases troot.property.1.eq_or_lt with hzero | hpos
    · have htrootZero : troot = (0 : unitInterval) := by
        apply Subtype.ext
        exact hzero.symm
      have hendpoint : excessPath m hsmooth hcurvature hnd p hp lower = 0 := by
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
      have hendpoint : excessPath m hsmooth hcurvature hnd p hp upper = 0 := by
        rw [htrootOne] at hroot
        simpa [Function.comp_def, hsegmentOne] using hroot
      linarith
  have hrootInterior : (lower : ℝ) < (root : ℝ) ∧
      (root : ℝ) < (upper : ℝ) := by
    have hlowerUpperReal : (lower : ℝ) < (upper : ℝ) := habove
    dsimp [root, rateSegment]
    constructor <;> nlinarith
  let prices := naturalPrices m p hp root
  let q := impatientPath m p hp root
  let household := m.withPrices q.1
  let pi := M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q
  have hinvariant : householdLawStep household pi = pi :=
    M06A.stationaryLaw_invariant household hsmooth hcurvature hnd q.2
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
      (pi : Measure Resources) :=
    hAInt.sub (integrable_const prices.debtLimit)
  have hclearing :
      (∫ z, M06B.netAsset household prices.debtLimit z ∂(pi : Measure Resources)) =
        capitalDemand p hp (firmRateOf p hp root) := by
    have hx : assetSupplyPath m hsmooth hcurvature hnd p hp root -
        capitalDemand p hp (firmRateOf p hp root) = 0 := by
      simpa [excessPath] using hrootZero
    change stationaryAssetSupply household prices.debtLimit pi =
      capitalDemand p hp (firmRateOf p hp root)
    have := sub_eq_zero.mp hx
    simpa [assetSupplyPath, household, prices, naturalPrices, naturalCapPrices, pi, q,
      impatientPath, debtShiftPath] using this
  let e : StationaryEquilibrium p hp :=
    { rate := firmRateOf p hp root
      household := household
      utility_smooth := hsmooth
      income_nondegenerate := hnd
      labor_mean_one := hmean
      iid_histories := fun k => history_independent m.income k
      originalPrices := prices
      original_rate := rfl
      original_wage := rfl
      normalized_prices := naturalPrices_normalized m p hp root
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
  refine ⟨e, rfl, rfl, rfl, rfl, lower.2.1.trans hrootInterior.1, ?_⟩
  exact hrootInterior.2.trans upper.2.2

end M09B2

end
end Aiyagari1994
