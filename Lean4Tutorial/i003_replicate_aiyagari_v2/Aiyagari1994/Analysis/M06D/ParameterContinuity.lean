import Aiyagari1994.Aggregate.AssetSupply
import Aiyagari1994.Stationary.ParameterContinuity
import Mathlib.Topology.ContinuousMap.Compact
import Mathlib.Topology.Sequences

/-! Analytic implementation for A03: continuity of stationary mean net assets. -/
open MeasureTheory Set Filter Function
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

/-- The shifted saving policy, restricted to a fixed compact resource interval, varies
continuously in the normalized price in the uniform norm. -/
theorem M06D.restricted_assetPolicy_continuous (m : HouseholdPrimitives) (B : Resources) :
    Continuous (fun q : AdmissibleNormalizedPrices m.income =>
      (⟨fun z : Icc (0 : Resources) B => (assetPolicy (m.withPrices q) z : ℝ),
        continuous_subtype_val.comp
          ((assetPolicy_continuous (m.withPrices q)).comp continuous_subtype_val)⟩ :
          C(Icc (0 : Resources) B, ℝ))) := by
  apply ContinuousMap.continuous_of_continuous_uncurry
  exact continuous_subtype_val.comp ((policy_jointly_continuous m).2.comp
    (continuous_fst.prodMk (continuous_subtype_val.comp continuous_snd)))

/-- A globally bounded continuous version of shifted saving. It agrees with saving on `[0,B]`
because feasibility gives `A(z) ≤ z`. -/
def M06D.clippedAssetPolicy (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (B : Resources) :
    BoundedContinuousFunction Resources ℝ :=
  BoundedContinuousFunction.mkOfBound
    ⟨fun z => min (assetPolicy (m.withPrices q) z : ℝ) (B : ℝ),
      ((continuous_subtype_val.comp (assetPolicy_continuous (m.withPrices q))).min
        continuous_const)⟩
    (2 * (B : ℝ)) (by
      intro x y
      rw [Real.dist_eq]
      have hx0 : 0 ≤ min (assetPolicy (m.withPrices q) x : ℝ) (B : ℝ) :=
        le_min (NNReal.coe_nonneg _) B.property
      have hy0 : 0 ≤ min (assetPolicy (m.withPrices q) y : ℝ) (B : ℝ) :=
        le_min (NNReal.coe_nonneg _) B.property
      have hxB : min (assetPolicy (m.withPrices q) x : ℝ) (B : ℝ) ≤ B := min_le_right _ _
      have hyB : min (assetPolicy (m.withPrices q) y : ℝ) (B : ℝ) ≤ B := min_le_right _ _
      calc
        |min (assetPolicy (m.withPrices q) x : ℝ) (B : ℝ) -
            min (assetPolicy (m.withPrices q) y : ℝ) (B : ℝ)|
            ≤ |min (assetPolicy (m.withPrices q) x : ℝ) (B : ℝ)| +
              |min (assetPolicy (m.withPrices q) y : ℝ) (B : ℝ)| := abs_sub _ _
        _ ≤ (B : ℝ) + B := add_le_add (abs_le.2 ⟨by linarith, hxB⟩)
          (abs_le.2 ⟨by linarith, hyB⟩)
        _ = 2 * B := by ring)

theorem M06D.assetPolicy_eq_clipped_of_mem (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (B : Resources) (z : Resources)
    (hz : z ∈ Icc (0 : Resources) B) :
    (assetPolicy (m.withPrices q) z : ℝ) = M06D.clippedAssetPolicy m q B z := by
  change (assetPolicy (m.withPrices q) z : ℝ) =
    min (assetPolicy (m.withPrices q) z : ℝ) (B : ℝ)
  rw [min_eq_left]
  exact_mod_cast (assetPolicy_le_state (m.withPrices q) z).trans hz.2

theorem M06D.support_mono (pi : ProbabilityMeasure Resources) (B C : Resources)
    (hBC : B ≤ C) (hB : (pi : Measure Resources) (Icc (0 : Resources) B) = 1) :
    (pi : Measure Resources) (Icc (0 : Resources) C) = 1 := by
  have hB' : (pi : Measure Resources) (Icc (0 : Resources) B) =
      (pi : Measure Resources) univ := by simpa using hB
  have hae : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc (0 : Resources) B :=
    (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 hB'
  have haeC : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc (0 : Resources) C := by
    filter_upwards [hae] with z hz
    exact ⟨hz.1, hz.2.trans hBC⟩
  have hC := (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).1 haeC
  simpa using hC

/-- The mean shifted saving under the canonical stationary law. -/
def M06D.stationaryMeanShiftedAssets (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (q : M06A.ImpatientPrices m) : ℝ :=
  ∫ z, (assetPolicy (m.withPrices q.1) z : ℝ)
    ∂(M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q : Measure Resources)

/-- The stationary mean shifted asset holding is continuous on the strictly impatient price
domain. The proof uses a local common compact support before applying weak convergence. -/
theorem M06D.stationaryMeanShiftedAssets_continuous (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) :
    Continuous (M06D.stationaryMeanShiftedAssets m hsmooth hcurvature hnd) := by
  rw [continuous_iff_seqContinuous]
  intro qseq q hq
  have hqval : Tendsto (fun n => (qseq n).1) atTop (nhds q.1) :=
    (continuous_subtype_val.tendsto q).comp hq
  let piSeq : ℕ → ProbabilityMeasure Resources :=
    fun n => M06A.stationaryLawAtPrice m hsmooth hcurvature hnd (qseq n)
  let pi0 : ProbabilityMeasure Resources :=
    M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q
  have hpi : Tendsto piSeq atTop (nhds pi0) :=
    (stationaryLaw_weakly_continuous m hsmooth hcurvature hnd).tendsto q |>.comp hq
  obtain ⟨Bseq, hseqEventually⟩ := M06A.eventually_common_stationary_support
    m hsmooth hcurvature hnd (fun n => (qseq n).1) q.1 hqval (fun n => (qseq n).2) q.2
  obtain ⟨B0, hzeroEventually⟩ := M06A.eventually_common_stationary_support
    m hsmooth hcurvature hnd (fun _n => q.1) q.1 tendsto_const_nhds (fun _n => q.2) q.2
  rw [Filter.eventually_atTop] at hseqEventually hzeroEventually
  obtain ⟨N, hseq⟩ := hseqEventually
  obtain ⟨N0, hzero⟩ := hzeroEventually
  let B : Resources := max Bseq B0
  have hpi0Support : (pi0 : Measure Resources) (Icc (0 : Resources) B) = 1 := by
    apply M06D.support_mono pi0 B0 B (le_max_right _ _)
    change (M06A.stationaryLaw (m.withPrices q.1) hsmooth hcurvature hnd q.2 :
      Measure Resources) (Icc (0 : Resources) B0) = 1
    exact hzero N0 (le_refl N0)
  have hpiSeqSupport : ∀ n, N ≤ n →
      (piSeq n : Measure Resources) (Icc (0 : Resources) B) = 1 := by
    intro n hn
    apply M06D.support_mono (piSeq n) Bseq B (le_max_left _ _)
    change (M06A.stationaryLaw (m.withPrices (qseq n).1) hsmooth hcurvature hnd
      (qseq n).2 : Measure Resources) (Icc (0 : Resources) Bseq) = 1
    exact hseq n hn
  let F : AdmissibleNormalizedPrices m.income → C(Icc (0 : Resources) B, ℝ) :=
    fun q' => ⟨fun z => (assetPolicy (m.withPrices q') z : ℝ),
      continuous_subtype_val.comp
        ((assetPolicy_continuous (m.withPrices q')).comp continuous_subtype_val)⟩
  have hF : Tendsto (fun n => F (qseq n).1) atTop (nhds (F q.1)) :=
    (M06D.restricted_assetPolicy_continuous m B).tendsto q.1 |>.comp hqval
  have hFnorm : Tendsto (fun n => ‖F (qseq n).1 - F q.1‖) atTop (nhds 0) := by
    have hc : Tendsto (fun _n : ℕ => F q.1) atTop (nhds (F q.1)) := tendsto_const_nhds
    simpa only [sub_self, norm_zero] using (hF.sub hc).norm
  have hdiff : Tendsto (fun n =>
      ∫ z, ((assetPolicy (m.withPrices (qseq n).1) z : ℝ) -
        (assetPolicy (m.withPrices q.1) z : ℝ)) ∂(piSeq n : Measure Resources))
      atTop (nhds 0) := by
    rw [tendsto_zero_iff_norm_tendsto_zero]
    apply squeeze_zero' (Filter.Eventually.of_forall fun n => norm_nonneg _) ?_ hFnorm
    rw [Filter.eventually_atTop]
    refine ⟨N, fun n hn => ?_⟩
    · have hsupp' : (piSeq n : Measure Resources) (Icc (0 : Resources) B) =
          (piSeq n : Measure Resources) univ := by simpa using hpiSeqSupport n hn
      have hae : ∀ᵐ z ∂(piSeq n : Measure Resources), z ∈ Icc (0 : Resources) B :=
        (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 hsupp'
      have hb := norm_integral_le_of_norm_le_const
        (μ := (piSeq n : Measure Resources))
        (f := fun z => (assetPolicy (m.withPrices (qseq n).1) z : ℝ) -
          (assetPolicy (m.withPrices q.1) z : ℝ))
        (C := ‖F (qseq n).1 - F q.1‖) (by
          filter_upwards [hae] with z hz
          have h := ContinuousMap.norm_coe_le_norm
            (F (qseq n).1 - F q.1) ⟨z, hz⟩
          exact h)
      simpa using hb
  have hfixed : Tendsto (fun n =>
      ∫ z, (M06D.clippedAssetPolicy m q.1 B) z ∂(piSeq n : Measure Resources))
      atTop (nhds (∫ z, (M06D.clippedAssetPolicy m q.1 B) z
        ∂(pi0 : Measure Resources))) :=
    (ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hpi)
      (M06D.clippedAssetPolicy m q.1 B)
  have hfixedEq : ∀ n, N ≤ n →
      (∫ z, (M06D.clippedAssetPolicy m q.1 B) z ∂(piSeq n : Measure Resources)) =
        ∫ z, (assetPolicy (m.withPrices q.1) z : ℝ) ∂(piSeq n : Measure Resources) := by
    intro n hn
    apply integral_congr_ae
    have hsupp' : (piSeq n : Measure Resources) (Icc (0 : Resources) B) =
        (piSeq n : Measure Resources) univ := by simpa using hpiSeqSupport n hn
    have hae : ∀ᵐ z ∂(piSeq n : Measure Resources), z ∈ Icc (0 : Resources) B :=
      (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 hsupp'
    filter_upwards [hae] with z hz
    exact (M06D.assetPolicy_eq_clipped_of_mem m q.1 B z hz).symm
  have hfixed0 :
      (∫ z, (M06D.clippedAssetPolicy m q.1 B) z ∂(pi0 : Measure Resources)) =
        ∫ z, (assetPolicy (m.withPrices q.1) z : ℝ) ∂(pi0 : Measure Resources) := by
    apply integral_congr_ae
    have hsupp' : (pi0 : Measure Resources) (Icc (0 : Resources) B) =
        (pi0 : Measure Resources) univ := by simpa using hpi0Support
    have hae : ∀ᵐ z ∂(pi0 : Measure Resources), z ∈ Icc (0 : Resources) B :=
      (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 hsupp'
    filter_upwards [hae] with z hz
    exact (M06D.assetPolicy_eq_clipped_of_mem m q.1 B z hz).symm
  have hfixedRaw : Tendsto (fun n =>
      ∫ z, (assetPolicy (m.withPrices q.1) z : ℝ) ∂(piSeq n : Measure Resources))
      atTop (nhds (∫ z, (assetPolicy (m.withPrices q.1) z : ℝ)
        ∂(pi0 : Measure Resources))) := by
    rw [← hfixed0]
    apply hfixed.congr'
    exact Filter.eventually_atTop.2 ⟨N, fun n hn => hfixedEq n hn⟩
  have heq : ∀ᶠ n in atTop,
      (∫ z, ((assetPolicy (m.withPrices (qseq n).1) z : ℝ) -
          (assetPolicy (m.withPrices q.1) z : ℝ)) ∂(piSeq n : Measure Resources)) +
        ∫ z, (assetPolicy (m.withPrices q.1) z : ℝ) ∂(piSeq n : Measure Resources) =
      ∫ z, (assetPolicy (m.withPrices (qseq n).1) z : ℝ)
        ∂(piSeq n : Measure Resources) := by
    rw [Filter.eventually_atTop]
    refine ⟨N, fun n hn => ?_⟩
    have hAn := M06C.asset_integrable_of_compact_support (m.withPrices (qseq n).1)
      (piSeq n) 0 B (hpiSeqSupport n hn)
    have hA0 := M06C.asset_integrable_of_compact_support (m.withPrices q.1)
      (piSeq n) 0 B (hpiSeqSupport n hn)
    rw [integral_sub hAn hA0]
    ring
  change Tendsto (fun n =>
      ∫ z, (assetPolicy (m.withPrices (qseq n).1) z : ℝ)
        ∂(M06A.stationaryLawAtPrice m hsmooth hcurvature hnd (qseq n) : Measure Resources))
    atTop (nhds (∫ z, (assetPolicy (m.withPrices q.1) z : ℝ)
      ∂(M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q : Measure Resources)))
  simpa only [piSeq, pi0, zero_add] using
    (hdiff.add hfixedRaw).congr' heq

theorem M06D.stationary_asset_integrable (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (q : M06A.ImpatientPrices m) :
    Integrable (fun z : Resources => (assetPolicy (m.withPrices q.1) z : ℝ))
      (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q : Measure Resources) := by
  obtain ⟨B, hsupportEventually⟩ := M06A.eventually_common_stationary_support
    m hsmooth hcurvature hnd (fun _n => q.1) q.1 tendsto_const_nhds (fun _n => q.2) q.2
  rw [Filter.eventually_atTop] at hsupportEventually
  obtain ⟨N, hsupport⟩ := hsupportEventually
  apply M06C.asset_integrable_of_compact_support (m.withPrices q.1)
    (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q) 0 B
  change (M06A.stationaryLaw (m.withPrices q.1) hsmooth hcurvature hnd q.2 :
    Measure Resources) (Icc (0 : Resources) B) = 1
  exact hsupport N (le_refl N)

/-- Stationary mean net assets for a continuous choice of the original-coordinate debt shift. -/
def M06D.stationaryAssetSupplyAtPrice (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (phi : M06A.ImpatientPrices m → ℝ)
    (q : M06A.ImpatientPrices m) : ℝ :=
  stationaryAssetSupply (m.withPrices q.1) (phi q)
    (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q)

theorem M06D.stationaryAssetSupply_continuous_core (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (phi : M06A.ImpatientPrices m → ℝ)
    (hphi : Continuous phi) :
    Continuous (M06D.stationaryAssetSupplyAtPrice m hsmooth hcurvature hnd phi) := by
  have heq : M06D.stationaryAssetSupplyAtPrice m hsmooth hcurvature hnd phi =
      fun q => M06D.stationaryMeanShiftedAssets m hsmooth hcurvature hnd q - phi q := by
    funext q
    exact M06C.stationaryAssetSupply_eq_mean_shifted_sub
      (m.withPrices q.1) (phi q)
      (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q)
      (M06D.stationary_asset_integrable m hsmooth hcurvature hnd q)
  rw [heq]
  exact (M06D.stationaryMeanShiftedAssets_continuous m hsmooth hcurvature hnd).sub hphi

end
end Aiyagari1994
