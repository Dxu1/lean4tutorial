import Aiyagari1994.Household.ParameterContinuity
import Aiyagari1994.Household.UpperDrift
import Aiyagari1994.Stationary.GlobalStability
import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.Topology.ContinuousMap.Compact
import Mathlib.Topology.Sequences

/-! Analytic implementation for S06: continuity of the canonical stationary resource law. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- Admissible normalized prices satisfying strict impatience for a fixed household. -/
abbrev M06A.ImpatientPrices (m : HouseholdPrimitives) :=
  {q : AdmissibleNormalizedPrices m.income // m.beta * q.grossReturn < 1}

/-- The canonical invariant resource law, selected from S05. Uniqueness makes the selection
independent of the witness returned by the existence theorem. -/
def M06A.stationaryLaw (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    ProbabilityMeasure Resources :=
  Classical.choose (Classical.choose_spec (stationaryLaw_exists_unique_global
    m hsmooth hcurvature hnd hbetaR))

theorem M06A.stationaryLaw_invariant (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1) :
    householdLawStep m (M06A.stationaryLaw m hsmooth hcurvature hnd hbetaR) =
      M06A.stationaryLaw m hsmooth hcurvature hnd hbetaR := by
  exact (Classical.choose_spec (Classical.choose_spec (stationaryLaw_exists_unique_global
    m hsmooth hcurvature hnd hbetaR))).2.2.1

theorem M06A.stationaryLaw_unique (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (hbetaR : m.beta * m.prices.grossReturn < 1)
    (rho : ProbabilityMeasure Resources) (hrho : householdLawStep m rho = rho) :
    rho = M06A.stationaryLaw m hsmooth hcurvature hnd hbetaR := by
  exact (Classical.choose_spec (Classical.choose_spec (stationaryLaw_exists_unique_global
    m hsmooth hcurvature hnd hbetaR))).2.2.2.1 rho hrho

/-- The one-step bounded-continuous test operator is jointly continuous in prices and resources. -/
theorem M06A.parameterized_testStep_continuous (m : HouseholdPrimitives)
    (f : BoundedContinuousFunction Resources ℝ) :
    Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
      ∫ l, f (x.1.toPrices.nextResources (assetPolicy (m.withPrices x.1) x.2) l)
        ∂(m.income.law : Measure m.income.Labor)) := by
  apply MeasureTheory.continuous_of_dominated (bound := fun _ : m.income.Labor => ‖f‖)
  · intro x
    apply Continuous.aestronglyMeasurable
    apply f.continuous.comp
    apply Continuous.subtype_mk
    change Continuous (fun l : m.income.Labor =>
      x.1.grossReturn * (assetPolicy (m.withPrices x.1) x.2 : ℝ) +
        (x.1.wage * (l : ℝ) + x.1.intercept))
    fun_prop
  · intro x
    exact Filter.Eventually.of_forall fun l => f.norm_coe_le_norm _
  · exact integrable_const ‖f‖
  · exact Filter.Eventually.of_forall fun l => by
      apply f.continuous.comp
      apply Continuous.subtype_mk
      change Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
        x.1.grossReturn * (assetPolicy (m.withPrices x.1) x.2 : ℝ) +
          (x.1.wage * (l : ℝ) + x.1.intercept))
      have hR : Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
          x.1.grossReturn) :=
        ((continuous_fst.comp continuous_subtype_val).fst).comp continuous_fst
      have hW : Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
          x.1.wage) :=
        ((continuous_fst.comp continuous_subtype_val).snd).comp continuous_fst
      have hK : Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
          x.1.intercept) :=
        (continuous_snd.comp continuous_subtype_val).comp continuous_fst
      have hA : Continuous (fun x : AdmissibleNormalizedPrices m.income × Resources =>
          (assetPolicy (m.withPrices x.1) x.2 : ℝ)) :=
        continuous_subtype_val.comp (policy_jointly_continuous m).2
      exact (hR.mul hA).add ((hW.mul continuous_const).add hK)

/-- The full-space bounded-continuous test obtained after one household transition. -/
def M06A.parameterizedTestStep (m : HouseholdPrimitives)
    (f : BoundedContinuousFunction Resources ℝ)
    (q : AdmissibleNormalizedPrices m.income) : BoundedContinuousFunction Resources ℝ :=
  BoundedContinuousFunction.mkOfBound
    ⟨fun z => ∫ l, f (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l)
        ∂(m.income.law : Measure m.income.Labor),
      (M06A.parameterized_testStep_continuous m f).comp
        (continuous_const.prodMk continuous_id)⟩
    (2 * ‖f‖) (by
      intro x y
      rw [Real.dist_eq]
      calc
        |∫ l, f (q.toPrices.nextResources (assetPolicy (m.withPrices q) x) l)
              ∂(m.income.law : Measure m.income.Labor) -
            ∫ l, f (q.toPrices.nextResources (assetPolicy (m.withPrices q) y) l)
              ∂(m.income.law : Measure m.income.Labor)|
            ≤ |∫ l, f (q.toPrices.nextResources (assetPolicy (m.withPrices q) x) l)
              ∂(m.income.law : Measure m.income.Labor)| +
              |∫ l, f (q.toPrices.nextResources (assetPolicy (m.withPrices q) y) l)
                ∂(m.income.law : Measure m.income.Labor)| := abs_sub _ _
        _ ≤ ‖f‖ + ‖f‖ := by
          have hbound (z : Resources) :
              |∫ l, f (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l)
                  ∂(m.income.law : Measure m.income.Labor)| ≤ ‖f‖ := by
            have h := norm_integral_le_of_norm_le_const
              (μ := (m.income.law : Measure m.income.Labor))
              (Filter.Eventually.of_forall fun l => f.norm_coe_le_norm
                (q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l))
            simpa [Real.norm_eq_abs] using h
          exact add_le_add (hbound x) (hbound y)
        _ = 2 * ‖f‖ := by ring)

/-- On a fixed compact resource interval, the one-step test varies continuously in prices in
the uniform norm. This is the joint-kernel-continuity input to the subsequence argument. -/
theorem M06A.restricted_testStep_continuous (m : HouseholdPrimitives)
    (B : Resources) (f : BoundedContinuousFunction Resources ℝ) :
    Continuous (fun q : AdmissibleNormalizedPrices m.income =>
      (⟨fun z : Set.Icc (0 : Resources) B => M06A.parameterizedTestStep m f q z,
        (M06A.parameterizedTestStep m f q).continuous.comp continuous_subtype_val⟩ :
          C(Set.Icc (0 : Resources) B, ℝ))) := by
  apply ContinuousMap.continuous_of_continuous_uncurry
  exact (M06A.parameterized_testStep_continuous m f).comp
    (continuous_fst.prodMk (continuous_subtype_val.comp continuous_snd))

theorem M06A.integral_householdLawStep (m : HouseholdPrimitives)
    (mu : ProbabilityMeasure Resources) (f : BoundedContinuousFunction Resources ℝ) :
    (∫ y, f y ∂(householdLawStep m mu : Measure Resources)) =
      ∫ z, M06A.parameterizedTestStep m f
        ⟨((m.prices.grossReturn, m.prices.wage), m.prices.intercept),
          ⟨⟨m.prices.grossReturn_pos, m.prices.wage_pos⟩, m.prices.income_nonneg⟩⟩ z
        ∂(mu : Measure Resources) := by
  change (∫ y, f y ∂(householdKernel m ∘ₘ (mu : Measure Resources))) = _
  rw [Measure.comp_eq_comp_const_apply]
  rw [Kernel.integral_comp (f.integrable _)]
  simp_rw [householdKernel_integral m _ f f.continuous.measurable]
  rfl

theorem M06A.integral_householdLawStep_withPrices (m : HouseholdPrimitives)
    (q : AdmissibleNormalizedPrices m.income) (mu : ProbabilityMeasure Resources)
    (f : BoundedContinuousFunction Resources ℝ) :
    (∫ y, f y ∂(householdLawStep (m.withPrices q) mu : Measure Resources)) =
      ∫ z, M06A.parameterizedTestStep m f q z ∂(mu : Measure Resources) := by
  change (∫ y, f y ∂(householdKernel (m.withPrices q) ∘ₘ
    (mu : Measure Resources))) = _
  rw [Measure.comp_eq_comp_const_apply]
  rw [Kernel.integral_comp (f.integrable _)]
  simp_rw [householdKernel_integral (m.withPrices q) _ f f.continuous.measurable]
  rfl

/-- A weak subsequential limit of invariant laws on one common compact resource interval is
invariant for the limiting price. -/
theorem M06A.subsequential_limit_invariant (m : HouseholdPrimitives)
    (qseq : ℕ → AdmissibleNormalizedPrices m.income)
    (q : AdmissibleNormalizedPrices m.income) (piSeq : ℕ → ProbabilityMeasure Resources)
    (pi : ProbabilityMeasure Resources) (B : Resources)
    (hq : Tendsto qseq atTop (nhds q)) (hpi : Tendsto piSeq atTop (nhds pi))
    (hsupport : ∀ n, (piSeq n : Measure Resources) (Set.Icc (0 : Resources) B) = 1)
    (hinvariant : ∀ n, householdLawStep (m.withPrices (qseq n)) (piSeq n) = piSeq n) :
    householdLawStep (m.withPrices q) pi = pi := by
  have hstep : Tendsto
      (fun n => householdLawStep (m.withPrices (qseq n)) (piSeq n)) atTop
      (nhds (householdLawStep (m.withPrices q) pi)) := by
    apply ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mpr
    intro f
    rw [M06A.integral_householdLawStep_withPrices]
    simp_rw [M06A.integral_householdLawStep_withPrices]
    let F : AdmissibleNormalizedPrices m.income → C(Set.Icc (0 : Resources) B, ℝ) :=
      fun q' => ⟨fun z => M06A.parameterizedTestStep m f q' z,
        (M06A.parameterizedTestStep m f q').continuous.comp continuous_subtype_val⟩
    have hF : Tendsto (fun n => F (qseq n)) atTop (nhds (F q)) :=
      (M06A.restricted_testStep_continuous m B f).tendsto q |>.comp hq
    have hFnorm : Tendsto (fun n => ‖F (qseq n) - F q‖) atTop (nhds 0) := by
      have hc : Tendsto (fun _n : ℕ => F q) atTop (nhds (F q)) := tendsto_const_nhds
      simpa only [sub_self, norm_zero] using (hF.sub hc).norm
    have hdiff : Tendsto (fun n =>
        ∫ z, (M06A.parameterizedTestStep m f (qseq n) z -
          M06A.parameterizedTestStep m f q z) ∂(piSeq n : Measure Resources))
        atTop (nhds 0) := by
      rw [tendsto_zero_iff_norm_tendsto_zero]
      apply squeeze_zero (fun n => norm_nonneg _) (fun n => ?_) hFnorm
      have hae : ∀ᵐ z ∂(piSeq n : Measure Resources), z ∈ Set.Icc (0 : Resources) B :=
        (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by
          simpa using hsupport n)
      have hb := norm_integral_le_of_norm_le_const
        (μ := (piSeq n : Measure Resources))
        (f := fun z => M06A.parameterizedTestStep m f (qseq n) z -
          M06A.parameterizedTestStep m f q z)
        (C := ‖F (qseq n) - F q‖) (by
          filter_upwards [hae] with z hz
          have h := ContinuousMap.norm_coe_le_norm (F (qseq n) - F q) ⟨z, hz⟩
          change ‖M06A.parameterizedTestStep m f (qseq n) z -
            M06A.parameterizedTestStep m f q z‖ ≤ ‖F (qseq n) - F q‖ at h
          exact h)
      simpa using hb
    have hfixed : Tendsto (fun n =>
        ∫ z, M06A.parameterizedTestStep m f q z ∂(piSeq n : Measure Resources))
        atTop (nhds (∫ z, M06A.parameterizedTestStep m f q z
          ∂(pi : Measure Resources))) :=
      (ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hpi)
        (M06A.parameterizedTestStep m f q)
    have heq : ∀ n,
        (∫ z, (M06A.parameterizedTestStep m f (qseq n) z -
            M06A.parameterizedTestStep m f q z) ∂(piSeq n : Measure Resources)) +
          ∫ z, M06A.parameterizedTestStep m f q z ∂(piSeq n : Measure Resources) =
        ∫ z, M06A.parameterizedTestStep m f (qseq n) z
          ∂(piSeq n : Measure Resources) := by
      intro n
      rw [integral_sub ((M06A.parameterizedTestStep m f (qseq n)).integrable _)
        ((M06A.parameterizedTestStep m f q).integrable _)]
      ring
    simpa only [zero_add] using
      (hdiff.add hfixed).congr' (Filter.Eventually.of_forall heq)
  have hs := hstep.congr' (Filter.Eventually.of_forall fun n => hinvariant n)
  exact tendsto_nhds_unique hs hpi

/-- Any forward-invariant upper bound also supports the canonical invariant law. The argument
constructs an invariant law on the economic interval and then invokes S05 uniqueness. -/
theorem M06A.stationaryLaw_support_of_common_bound (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income)
    (q : AdmissibleNormalizedPrices m.income) (hbetaR : m.beta * q.grossReturn < 1)
    (B : Resources) (hUpperB : upperEffectiveIncome (m.withPrices q) ≤ B)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome (m.withPrices q) ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome (m.withPrices q) ≤
            q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l ∧
          q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l ≤ B) :
    (M06A.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd hbetaR :
      Measure Resources) (Set.Icc (0 : Resources) B) = 1 := by
  obtain ⟨piI, hpiI, _hallI⟩ := M05E.economic_compact_stability
    (m.withPrices q) hsmooth hnd hbetaR B hUpperB hInvariant
  have haB : lowerEffectiveIncome (m.withPrices q) ≤ B := by
    apply le_trans (le_of_lt ?_) hUpperB
    apply Subtype.coe_lt_coe.mp
    change q.wage * m.income.lower + q.intercept <
      q.wage * m.income.upper + q.intercept
    unfold AdmissibleNormalizedPrices.wage AdmissibleNormalizedPrices.intercept
    simpa [add_comm] using add_lt_add_right
      (mul_lt_mul_of_pos_left hnd.endpoints_distinct q.property.1.2) q.intercept
  let rho := M05E.embedLaw (lowerEffectiveIncome (m.withPrices q)) B piI
  have hrho : householdLawStep (m.withPrices q) rho = rho := by
    rw [← M05E.embedLaw_lawStep (m.withPrices q)
      (lowerEffectiveIncome (m.withPrices q)) B haB hInvariant, hpiI]
  have hrhoEq : rho = M06A.stationaryLaw (m.withPrices q)
      hsmooth hcurvature hnd hbetaR :=
    M06A.stationaryLaw_unique (m.withPrices q) hsmooth hcurvature hnd hbetaR rho hrho
  rw [← hrhoEq]
  have hsmall := M05E.embedLaw_support (lowerEffectiveIncome (m.withPrices q)) B piI
  have hmono : (rho : Measure Resources)
      (Set.Icc (lowerEffectiveIncome (m.withPrices q)) B) ≤
      (rho : Measure Resources) (Set.Icc (0 : Resources) B) :=
    measure_mono (by
      intro z hz
      exact ⟨bot_le, hz.2⟩)
  have hleOne : (rho : Measure Resources) (Set.Icc (0 : Resources) B) ≤ 1 := by
    calc
      (rho : Measure Resources) (Set.Icc (0 : Resources) B) ≤
          (rho : Measure Resources) Set.univ :=
        measure_mono (Set.subset_univ (Set.Icc (0 : Resources) B))
      _ = 1 := measure_univ
  rw [hsmall] at hmono
  exact le_antisymm hleOne hmono

/-- D03 supplies one common compact support along the tail of every price sequence converging to
a strictly impatient price. No uniform claim is made as the impatience boundary is approached. -/
theorem M06A.eventually_common_stationary_support (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income)
    (qseq : ℕ → AdmissibleNormalizedPrices m.income)
    (q : AdmissibleNormalizedPrices m.income) (hq : Tendsto qseq atTop (nhds q))
    (hseqImpatient : ∀ n, m.beta * (qseq n).grossReturn < 1)
    (hqImpatient : m.beta * q.grossReturn < 1) :
    ∃ B : Resources, ∀ᶠ n in atTop,
      (M06A.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
        (hseqImpatient n) : Measure Resources) (Set.Icc (0 : Resources) B) = 1 := by
  let Rmin : ℝ := q.grossReturn / 2
  let Rmax : ℝ := q.grossReturn + 1
  let gamma : ℝ := (m.beta * q.grossReturn + 1) / 2
  let EStar : ℝ := M04CIncomeUpper m q + 1
  let DeltaStar : ℝ := (M04CIncomeUpper m q - M04CIncomeLower m q) + 1
  let Q : Set (AdmissibleNormalizedPrices m.income) := {q' |
    Rmin ≤ q'.grossReturn ∧ q'.grossReturn ≤ Rmax ∧
      m.beta * q'.grossReturn ≤ gamma ∧
      M04CIncomeUpper m q' ≤ EStar ∧
      M04CIncomeUpper m q' - M04CIncomeLower m q' ≤ DeltaStar}
  have hqR : 0 < q.grossReturn := q.property.1.1
  have hqEU0 : 0 ≤ M04CIncomeUpper m q := by
    exact q.property.2 ⟨m.income.upper, m.income_support.ordered, le_rfl⟩
  have hRmin : 0 < Rmin := by dsimp [Rmin]; linarith
  have hRmax : 0 < Rmax := by dsimp [Rmax]; linarith
  have hgamma : gamma < 1 := by dsimp [gamma]; linarith
  have hEStar : 0 ≤ EStar := by
    dsimp [EStar]
    linarith
  have hDeltaStar : 0 ≤ DeltaStar := by
    dsimp [DeltaStar, M04CIncomeUpper, M04CIncomeLower]
    have hwspan : 0 ≤ q.wage * (m.income.upper - m.income.lower) :=
      mul_nonneg q.property.1.2.le (sub_nonneg.mpr m.income_support.ordered)
    linarith
  have hQ : ∀ q' ∈ Q,
      Rmin ≤ q'.grossReturn ∧ q'.grossReturn ≤ Rmax ∧
        m.beta * q'.grossReturn ≤ gamma ∧
        M04CIncomeUpper m q' ≤ EStar ∧
        M04CIncomeUpper m q' - M04CIncomeLower m q' ≤ DeltaStar := by
    intro q' hq'
    exact hq'
  obtain ⟨Breal, hBpos, hB⟩ := uniform_upper_drift m hsmooth hcurvature Q
    Rmin Rmax gamma EStar DeltaStar hRmin hRmax hgamma hEStar hDeltaStar hQ
  let B : Resources := ⟨Breal, hBpos.le⟩
  refine ⟨B, ?_⟩
  have hR : Tendsto (fun n => (qseq n).grossReturn) atTop (nhds q.grossReturn) := by
    have hc : Continuous
        (AdmissibleNormalizedPrices.grossReturn :
          AdmissibleNormalizedPrices m.income → ℝ) :=
      (continuous_fst.comp continuous_subtype_val).fst
    exact (hc.tendsto q).comp hq
  have hEU : Tendsto (fun n => M04CIncomeUpper m (qseq n)) atTop
      (nhds (M04CIncomeUpper m q)) := by
    have hc : Continuous (fun q' : AdmissibleNormalizedPrices m.income =>
        M04CIncomeUpper m q') := by
      unfold M04CIncomeUpper AdmissibleNormalizedPrices.wage
        AdmissibleNormalizedPrices.intercept
      exact (((continuous_fst.comp continuous_subtype_val).snd.mul continuous_const).add
        (continuous_snd.comp continuous_subtype_val))
    exact (hc.tendsto q).comp hq
  have hSpan : Tendsto (fun n =>
      M04CIncomeUpper m (qseq n) - M04CIncomeLower m (qseq n)) atTop
      (nhds (M04CIncomeUpper m q - M04CIncomeLower m q)) := by
    have hc : Continuous (fun q' : AdmissibleNormalizedPrices m.income =>
        M04CIncomeUpper m q' - M04CIncomeLower m q') := by
      unfold M04CIncomeUpper M04CIncomeLower AdmissibleNormalizedPrices.wage
        AdmissibleNormalizedPrices.intercept
      fun_prop
    exact (hc.tendsto q).comp hq
  have hRlow : ∀ᶠ n in atTop, Rmin ≤ (qseq n).grossReturn :=
    (hR.eventually (lt_mem_nhds (by dsimp [Rmin]; linarith))).mono
      fun _ hn => hn.le
  have hRhigh : ∀ᶠ n in atTop, (qseq n).grossReturn ≤ Rmax :=
    (hR.eventually (eventually_lt_nhds (by dsimp [Rmax]; linarith))).mono
      fun _ hn => hn.le
  have hGamma : ∀ᶠ n in atTop, m.beta * (qseq n).grossReturn ≤ gamma := by
    have ht := hR.const_mul m.beta
    exact (ht.eventually (eventually_lt_nhds (by dsimp [gamma]; linarith))).mono
      fun _ hn => hn.le
  have hE : ∀ᶠ n in atTop, M04CIncomeUpper m (qseq n) ≤ EStar :=
    (hEU.eventually (eventually_lt_nhds (by dsimp [EStar]; linarith))).mono
      fun _ hn => hn.le
  have hD : ∀ᶠ n in atTop,
      M04CIncomeUpper m (qseq n) - M04CIncomeLower m (qseq n) ≤ DeltaStar :=
    (hSpan.eventually (eventually_lt_nhds (by dsimp [DeltaStar]; linarith))).mono
      fun _ hn => hn.le
  filter_upwards [hRlow, hRhigh, hGamma, hE, hD] with n hn0 hn1 hn2 hn3 hn4
  have hqn : qseq n ∈ Q := ⟨hn0, hn1, hn2, hn3, hn4⟩
  rcases hB (qseq n) hqn with ⟨hUpper, _hDrift, hInv⟩
  apply M06A.stationaryLaw_support_of_common_bound m hsmooth hcurvature hnd
    (qseq n) (hseqImpatient n) B
  · exact_mod_cast hUpper
  · intro z hzLower hzUpper l
    have hzLower' : M04CIncomeLower m (qseq n) ≤ (z : ℝ) := by
      exact_mod_cast hzLower
    have hzUpper' : (z : ℝ) ≤ Breal := by exact_mod_cast hzUpper
    exact_mod_cast hInv z hzLower' hzUpper' l

/-- The canonical stationary law as a function on the open strict-impatience price domain. -/
def M06A.stationaryLawAtPrice (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (q : M06A.ImpatientPrices m) :
    ProbabilityMeasure Resources :=
  M06A.stationaryLaw (m.withPrices q.1) hsmooth hcurvature hnd q.2

/-- Sequential form of S06. Every cluster point is invariant for the limiting kernel on the
common D03 compact interval and hence equals the S05-unique invariant law. -/
theorem M06A.stationaryLawAtPrice_tendsto (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income)
    (qseq : ℕ → M06A.ImpatientPrices m) (q : M06A.ImpatientPrices m)
    (hq : Tendsto qseq atTop (nhds q)) :
    Tendsto (fun n => M06A.stationaryLawAtPrice m hsmooth hcurvature hnd (qseq n))
      atTop (nhds (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q)) := by
  have hqval : Tendsto (fun n => (qseq n).1) atTop (nhds q.1) :=
    (continuous_subtype_val.tendsto q).comp hq
  obtain ⟨B, hsupportEventually⟩ := M06A.eventually_common_stationary_support
    m hsmooth hcurvature hnd (fun n => (qseq n).1) q.1 hqval
      (fun n => (qseq n).2) q.2
  rw [Filter.eventually_atTop] at hsupportEventually
  obtain ⟨N, hsupportN⟩ := hsupportEventually
  let piSeq : ℕ → ProbabilityMeasure Resources :=
    fun n => M06A.stationaryLawAtPrice m hsmooth hcurvature hnd (qseq n)
  let piTail : ℕ → ProbabilityMeasure Resources := fun n => piSeq (n + N)
  let qTail : ℕ → AdmissibleNormalizedPrices m.income := fun n => (qseq (n + N)).1
  let pi0 := M06A.stationaryLawAtPrice m hsmooth hcurvature hnd q
  have hqTail : Tendsto qTail atTop (nhds q.1) := by
    exact (tendsto_add_atTop_iff_nat N).2 hqval
  have hsupportTail : ∀ n,
      (piTail n : Measure Resources) (Set.Icc (0 : Resources) B) = 1 := by
    intro n
    exact hsupportN (n + N) (Nat.le_add_left N n)
  have hInvariantTail : ∀ n,
      householdLawStep (m.withPrices (qTail n)) (piTail n) = piTail n := by
    intro n
    exact M06A.stationaryLaw_invariant (m.withPrices (qseq (n + N)).1)
      hsmooth hcurvature hnd (qseq (n + N)).2
  have htight : IsTightMeasureSet
      {((mu : ProbabilityMeasure Resources) : Measure Resources) |
        mu ∈ Set.range piTail} := by
    rw [isTightMeasureSet_iff_exists_isCompact_measure_compl_le]
    intro eps heps
    refine ⟨Set.Icc (0 : Resources) B, isCompact_Icc, ?_⟩
    intro mu hmu
    rcases hmu with ⟨rho, ⟨n, rfl⟩, rfl⟩
    have hae : ∀ᵐ z ∂(piTail n : Measure Resources),
        z ∈ Set.Icc (0 : Resources) B :=
      (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by
        simpa using hsupportTail n)
    have hzero : (piTail n : Measure Resources) (Set.Icc (0 : Resources) B)ᶜ = 0 :=
      ae_iff.mp hae
    rw [hzero]
    exact bot_le
  have hcompact : IsCompact (closure (Set.range piTail)) :=
    isCompact_closure_of_isTightMeasureSet htight
  have htail : Tendsto piTail atTop (nhds pi0) := by
    show map piTail atTop ≤ nhds pi0
    apply hcompact.le_nhds_of_unique_clusterPt
    · rw [mem_map]
      exact Filter.Eventually.of_forall fun n => subset_closure ⟨n, rfl⟩
    · intro rho _hrho hcluster
      have hmapCluster : MapClusterPt rho atTop piTail := hcluster
      obtain ⟨phi, hphi, hphiPi⟩ := hmapCluster.tendsto_subseq
      have hphiQ : Tendsto (qTail ∘ phi) atTop (nhds q.1) :=
        hqTail.comp hphi.tendsto_atTop
      have hphiSupport : ∀ n,
          (piTail (phi n) : Measure Resources) (Set.Icc (0 : Resources) B) = 1 :=
        fun n => hsupportTail (phi n)
      have hphiInvariant : ∀ n,
          householdLawStep (m.withPrices ((qTail ∘ phi) n))
            ((piTail ∘ phi) n) = (piTail ∘ phi) n :=
        fun n => hInvariantTail (phi n)
      have hrhoInvariant := M06A.subsequential_limit_invariant m (qTail ∘ phi) q.1
        (piTail ∘ phi) rho B hphiQ hphiPi hphiSupport hphiInvariant
      exact M06A.stationaryLaw_unique (m.withPrices q.1) hsmooth hcurvature hnd q.2
        rho hrhoInvariant
  exact (tendsto_add_atTop_iff_nat N).1 htail

/-- S06. With utility, beta, and the iid labor law fixed, the canonical invariant resource law
is weakly continuous at every strictly impatient admissible normalized price vector. -/
theorem M06A.stationaryLaw_weakly_continuous_core (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) :
    Continuous (M06A.stationaryLawAtPrice m hsmooth hcurvature hnd) := by
  rw [continuous_iff_seqContinuous]
  intro qseq q hq
  exact M06A.stationaryLawAtPrice_tendsto m hsmooth hcurvature hnd qseq q hq

end
end Aiyagari1994
