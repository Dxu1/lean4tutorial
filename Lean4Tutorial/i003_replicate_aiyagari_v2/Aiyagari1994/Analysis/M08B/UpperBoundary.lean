import Aiyagari1994.Aggregate.AssetSupply
import Aiyagari1994.Analysis.M06A.ParameterContinuity
import Aiyagari1994.Analysis.TightKernelLimit
import Aiyagari1994.Household.ParameterContinuity
import Aiyagari1994.Stationary.NoInvariant
import Mathlib.MeasureTheory.Integral.Lebesgue.Markov
import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.Topology.UniformSpace.CompactConvergence
import Mathlib.Topology.UniformSpace.LocallyUniformConvergence

/-! Analytic bridges for the upper asset-supply boundary. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory

namespace Aiyagari1994.M08B
noncomputable section

/-- The contracted strictly-subcritical normalized/original-coordinate domain used by the
one-sided filter formulation. -/
def UpperBoundaryPrices (m : HouseholdPrimitives) :=
  {x : AdmissibleNormalizedPrices m.income × ℝ //
    0 ≤ x.2 ∧ x.1.intercept = -(x.1.grossReturn - 1) * x.2 ∧
      m.beta * x.1.grossReturn < 1}

/-- Canonical stationary net asset supply on the contracted upper-boundary domain. -/
def upperBoundaryAssetSupply (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (x : UpperBoundaryPrices m) : ℝ :=
  stationaryAssetSupply (m.withPrices x.1.1) x.1.2
    (M06C.stationaryLaw (m.withPrices x.1.1) hsmooth hcurvature hnd x.2.2.2)

/-- An admissible normalized price paired with a nonnegative debt shift and the normalization
identity determines original prices. -/
def originalPrices (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (phi : ℝ) (hphi : 0 ≤ phi)
    (hnorm : q.intercept = -(q.grossReturn - 1) * phi) : OriginalPrices m.income where
  netRate := q.grossReturn - 1
  wage := q.wage
  debtLimit := phi
  netRate_gt := by dsimp [AdmissibleNormalizedPrices.grossReturn]; linarith [q.property.1.1]
  wage_pos := q.property.1.2
  debtLimit_nonneg := hphi
  income_nonneg := by
    intro l
    dsimp [AdmissibleNormalizedPrices.wage, AdmissibleNormalizedPrices.grossReturn,
      AdmissibleNormalizedPrices.intercept] at hnorm ⊢
    linarith [q.property.2 l]

theorem normalized_originalPrices (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (phi : ℝ) (hphi : 0 ≤ phi)
    (hnorm : q.intercept = -(q.grossReturn - 1) * phi) :
    (originalPrices m q phi hphi hnorm).normalized = q.toPrices := by
  cases q with
  | mk q hq =>
      rcases q with ⟨⟨R, w⟩, k⟩
      simp only [AdmissibleNormalizedPrices.toPrices,
        AdmissibleNormalizedPrices.grossReturn, AdmissibleNormalizedPrices.wage,
        AdmissibleNormalizedPrices.intercept] at hnorm ⊢
      cases hnorm
      unfold originalPrices OriginalPrices.normalized
      rw [NormalizedPrices.mk.injEq]
      simp only [AdmissibleNormalizedPrices.grossReturn,
        AdmissibleNormalizedPrices.wage]
      constructor
      · ring
      constructor
      · trivial
      · trivial

/-- A uniform first-moment bound for probability laws on `NNReal` implies tightness. -/
theorem tight_of_uniform_first_moment
    (mu : ℕ → ProbabilityMeasure ℝ≥0)
    (hInt : ∀ n, Integrable (fun z : ℝ≥0 ↦ (z : ℝ)) (mu n : Measure ℝ≥0))
    (C : ℝ) (hC : 0 ≤ C)
    (hMean : ∀ n, (∫ z, (z : ℝ) ∂(mu n : Measure ℝ≥0)) ≤ C) :
    IsTightMeasureSet {nu : Measure ℝ≥0 | ∃ n, nu = (mu n : Measure ℝ≥0)} := by
  rw [isTightMeasureSet_iff_exists_isCompact_measure_compl_le]
  intro eps heps
  by_cases hepsTop : eps = ∞
  · refine ⟨{0}, isCompact_singleton, ?_⟩
    intro nu hnu
    simp [hepsTop]
  let epsR : ℝ := eps.toReal
  have hepsR : 0 < epsR := ENNReal.toReal_pos heps.ne' hepsTop
  let B : ℝ := (C + 1) / epsR
  have hB : 0 < B := div_pos (by linarith) hepsR
  let K : Set ℝ≥0 := Icc 0 ⟨B, hB.le⟩
  refine ⟨K, isCompact_Icc, ?_⟩
  intro nu hnu
  rcases hnu with ⟨n, rfl⟩
  have hmarkov := mul_meas_ge_le_integral_of_nonneg
    (μ := (mu n : Measure ℝ≥0))
    (f := fun z : ℝ≥0 ↦ (z : ℝ))
    (Filter.Eventually.of_forall fun z ↦ NNReal.zero_le_coe) (hInt n) B
  have htailset : Kᶜ ⊆ {z : ℝ≥0 | B ≤ (z : ℝ)} := by
    intro z hz
    simp only [K, mem_compl_iff, mem_Icc, not_and, not_le] at hz
    exact le_of_lt (hz bot_le)
  have hreal : B * ((mu n : Measure ℝ≥0) Kᶜ).toReal ≤ C := by
    have hmeasure : (mu n : Measure ℝ≥0) Kᶜ ≤
        (mu n : Measure ℝ≥0) {z : ℝ≥0 | B ≤ (z : ℝ)} :=
      measure_mono htailset
    have hmeasureReal : ((mu n : Measure ℝ≥0) Kᶜ).toReal ≤
        ((mu n : Measure ℝ≥0) {z : ℝ≥0 | B ≤ (z : ℝ)}).toReal :=
      (ENNReal.toReal_le_toReal
        (measure_ne_top (μ := (mu n : Measure ℝ≥0)) (s := Kᶜ))
        (measure_ne_top (μ := (mu n : Measure ℝ≥0))
          (s := {z : ℝ≥0 | B ≤ (z : ℝ)}))).2 hmeasure
    calc
      B * ((mu n : Measure ℝ≥0) Kᶜ).toReal ≤
          B * ((mu n : Measure ℝ≥0) {z : ℝ≥0 | B ≤ (z : ℝ)}).toReal := by
            exact mul_le_mul_of_nonneg_left hmeasureReal hB.le
      _ ≤ ∫ z, (z : ℝ) ∂(mu n : Measure ℝ≥0) := hmarkov
      _ ≤ C := hMean n
  have htailReal : ((mu n : Measure ℝ≥0) Kᶜ).toReal ≤ epsR := by
    have hBeps : B * epsR = C + 1 := by
      dsimp [B]
      field_simp [ne_of_gt hepsR]
    nlinarith [mul_nonneg hB.le (ENNReal.toReal_nonneg :
      0 ≤ ((mu n : Measure ℝ≥0) Kᶜ).toReal)]
  rw [← ENNReal.toReal_le_toReal (measure_ne_top _ _) hepsTop]
  simpa [epsR] using htailReal

/-- H06's joint policy continuity yields the compact-local bounded-test convergence required by
B01 for the canonical household kernels. -/
theorem householdKernel_tendstoLocallyUniformly
    (m : HouseholdPrimitives)
    (qseq : ℕ → AdmissibleNormalizedPrices m.income)
    (q : AdmissibleNormalizedPrices m.income)
    (hq : Tendsto qseq atTop (nhds q))
    (f : BoundedContinuousFunction Resources ℝ) :
    TendstoLocallyUniformly
      (fun n z ↦ ∫ y, f y ∂householdKernel (m.withPrices (qseq n)) z)
      (fun z ↦ ∫ y, f y ∂householdKernel (m.withPrices q) z) atTop := by
  rw [tendstoLocallyUniformly_iff_forall_isCompact]
  intro K hK
  obtain ⟨B, hB⟩ := hK.bddAbove
  let F : AdmissibleNormalizedPrices m.income → C(Icc (0 : Resources) B, ℝ) :=
    fun q' ↦ ⟨fun z ↦ M06A.parameterizedTestStep m f q' z,
      (M06A.parameterizedTestStep m f q').continuous.comp continuous_subtype_val⟩
  have hF : Tendsto (fun n ↦ F (qseq n)) atTop (nhds (F q)) :=
    (M06A.restricted_testStep_continuous m B f).tendsto q |>.comp hq
  have hFU : TendstoUniformly
      (fun n (z : Icc (0 : Resources) B) ↦ F (qseq n) z)
      (fun z : Icc (0 : Resources) B ↦ F q z) atTop :=
    ContinuousMap.tendsto_iff_tendstoUniformly.mp hF
  have hFUOn : TendstoUniformlyOn
      (fun n z ↦ M06A.parameterizedTestStep m f (qseq n) z)
      (fun z ↦ M06A.parameterizedTestStep m f q z) atTop (Icc (0 : Resources) B) := by
    exact tendstoUniformlyOn_iff_tendstoUniformly_comp_coe.mpr hFU
  have hFUKernel : TendstoUniformlyOn
      (fun n z ↦ ∫ y, f y ∂householdKernel (m.withPrices (qseq n)) z)
      (fun z ↦ ∫ y, f y ∂householdKernel (m.withPrices q) z)
      atTop (Icc (0 : Resources) B) := by
    apply TendstoUniformlyOn.congr_right
      (TendstoUniformlyOn.congr hFUOn (Filter.Eventually.of_forall fun n z hz ↦ ?_))
    · intro z hz
      exact (householdKernel_integral (m.withPrices q) z f
        f.continuous.measurable).symm
    · exact (householdKernel_integral (m.withPrices (qseq n)) z f
        f.continuous.measurable).symm
  apply TendstoUniformlyOn.mono
    (s := Icc (0 : Resources) B)
    hFUKernel
  intro z hz
  exact ⟨bot_le, hB hz⟩

end
end Aiyagari1994.M08B
