import Aiyagari1994.Analysis.M08B.UpperBoundary

/-! B02: stationary net asset supply diverges at the upper impatience boundary. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- Sequential upper-boundary divergence. The normalization premise keeps the finite shift in
original coordinates, while the limiting normalized kernel is exactly critical. -/
theorem assetSupply_tendsTo_infinity_at_impatience
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (qseq : ℕ → AdmissibleNormalizedPrices m.income)
    (qstar : AdmissibleNormalizedPrices m.income)
    (phiSeq : ℕ → ℝ) (phiStar : ℝ)
    (hphiNonneg : ∀ n, 0 ≤ phiSeq n)
    (hnormalized : ∀ n,
      (qseq n).intercept = -((qseq n).grossReturn - 1) * phiSeq n)
    (hsubcritical : ∀ n, m.beta * (qseq n).grossReturn < 1)
    (hcritical : m.beta * qstar.grossReturn = 1)
    (hq : Tendsto qseq atTop (nhds qstar))
    (hphi : Tendsto phiSeq atTop (nhds phiStar)) :
    Tendsto (fun n ↦
      stationaryAssetSupply (m.withPrices (qseq n)) (phiSeq n)
        (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
          (hsubcritical n))) atTop atTop := by
  let pi : ℕ → ProbabilityMeasure Resources := fun n ↦
    M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
      (hsubcritical n)
  let S : ℕ → ℝ := fun n ↦
    stationaryAssetSupply (m.withPrices (qseq n)) (phiSeq n) (pi n)
  change Tendsto S atTop atTop
  rw [Filter.tendsto_atTop]
  intro b
  by_contra hnot
  have hfrequentS : ∃ᶠ n in atTop, S n < b := by
    by_contra hf
    have hev : ∀ᶠ n in atTop, ¬ S n < b := not_frequently.mp hf
    exact hnot (hev.mono fun n hn ↦ le_of_not_gt hn)
  have hphiUpper : ∀ᶠ n in atTop, phiSeq n < phiStar + 1 :=
    hphi.eventually (eventually_lt_nhds (by linarith))
  have hR : Tendsto (fun n ↦ (qseq n).grossReturn) atTop
      (nhds qstar.grossReturn) := by
    have hc : Continuous
        (AdmissibleNormalizedPrices.grossReturn :
          AdmissibleNormalizedPrices m.income → ℝ) := by
      exact (continuous_fst.comp continuous_subtype_val).fst
    exact (hc.tendsto qstar).comp hq
  have hRUpper : ∀ᶠ n in atTop, (qseq n).grossReturn < qstar.grossReturn + 1 :=
    hR.eventually (eventually_lt_nhds (by linarith))
  have hE : Tendsto (fun n ↦ M04CIncomeUpper m (qseq n)) atTop
      (nhds (M04CIncomeUpper m qstar)) := by
    have hc : Continuous (fun q : AdmissibleNormalizedPrices m.income ↦
        M04CIncomeUpper m q) := by
      unfold M04CIncomeUpper AdmissibleNormalizedPrices.wage
        AdmissibleNormalizedPrices.intercept
      fun_prop
    exact (hc.tendsto qstar).comp hq
  have hEUpper : ∀ᶠ n in atTop,
      M04CIncomeUpper m (qseq n) < M04CIncomeUpper m qstar + 1 :=
    hE.eventually (eventually_lt_nhds (by linarith))
  have hfrequent : ∃ᶠ n in atTop,
      S n < b ∧ phiSeq n < phiStar + 1 ∧
        (qseq n).grossReturn < qstar.grossReturn + 1 ∧
        M04CIncomeUpper m (qseq n) < M04CIncomeUpper m qstar + 1 :=
    hfrequentS.and_eventually (by
      filter_upwards [hphiUpper, hRUpper, hEUpper] with n hnphi hnR hnE
      exact ⟨hnphi, hnR, hnE⟩)
  obtain ⟨psi, hpsi, hpsiBounds⟩ := extraction_of_frequently_atTop hfrequent
  let qsub : ℕ → AdmissibleNormalizedPrices m.income := qseq ∘ psi
  let phisub : ℕ → ℝ := phiSeq ∘ psi
  let musub : ℕ → ProbabilityMeasure Resources := pi ∘ psi
  have hqsub : Tendsto qsub atTop (nhds qstar) := hq.comp hpsi.tendsto_atTop
  have hMeanData (n : ℕ) := stationary_budget_identity
    (m.withPrices (qsub n)) hsmooth hcurvature hnd (hsubcritical (psi n))
    (M08B.originalPrices m (qsub n) (phisub n) (hphiNonneg (psi n))
      (hnormalized (psi n)))
    (by
      change (qsub n).toPrices =
        (M08B.originalPrices m (qsub n) (phisub n) (hphiNonneg (psi n))
          (hnormalized (psi n))).normalized
      exact (M08B.normalized_originalPrices m (qsub n) (phisub n)
        (hphiNonneg (psi n)) (hnormalized (psi n))).symm)
  have hzInt : ∀ n, Integrable (fun z : Resources ↦ (z : ℝ))
      (musub n : Measure Resources) := fun n ↦ (hMeanData n).1
  have hAInt : ∀ n, Integrable
      (fun z : Resources ↦ (assetPolicy (m.withPrices (qsub n)) z : ℝ))
      (musub n : Measure Resources) := fun n ↦ (hMeanData n).2.1
  have hAMean (n : ℕ) :
      (∫ z, (assetPolicy (m.withPrices (qsub n)) z : ℝ)
          ∂(musub n : Measure Resources)) = S (psi n) + phisub n := by
    have hsupply := (hMeanData n).2.2.2.2.2.2.1
    change S (psi n) =
      (∫ z, (assetPolicy (m.withPrices (qsub n)) z : ℝ)
        ∂(musub n : Measure Resources)) - phisub n at hsupply
    linarith
  let Abar : ℝ := b + (phiStar + 1)
  have hAMeanUpper (n : ℕ) :
      (∫ z, (assetPolicy (m.withPrices (qsub n)) z : ℝ)
          ∂(musub n : Measure Resources)) ≤ Abar := by
    rw [hAMean n]
    dsimp [Abar, phisub]
    linarith [(hpsiBounds n).1, (hpsiBounds n).2.1]
  have heMeanUpper (n : ℕ) :
      (∫ l, (qsub n).toPrices.effectiveIncome l
          ∂(m.income.law : Measure m.income.Labor)) ≤
        M04CIncomeUpper m qstar + 1 := by
    have heInt := M06C.effectiveIncome_integrable (m.withPrices (qsub n))
    have hconst : Integrable
        (fun _ : m.income.Labor ↦ M04CIncomeUpper m (qsub n))
        (m.income.law : Measure m.income.Labor) := integrable_const _
    have hle : ∀ l : m.income.Labor,
        (qsub n).toPrices.effectiveIncome l ≤ M04CIncomeUpper m (qsub n) := by
      intro l
      dsimp [NormalizedPrices.effectiveIncome, M04CIncomeUpper,
        AdmissibleNormalizedPrices.wage, AdmissibleNormalizedPrices.intercept]
      simpa [add_comm] using add_le_add_right
        (mul_le_mul_of_nonneg_left l.property.2 (qsub n).property.1.2.le)
        (qsub n).intercept
    calc
      (∫ l, (qsub n).toPrices.effectiveIncome l
          ∂(m.income.law : Measure m.income.Labor)) ≤
          ∫ _l : m.income.Labor, M04CIncomeUpper m (qsub n)
            ∂(m.income.law : Measure m.income.Labor) :=
        integral_mono heInt hconst hle
      _ = M04CIncomeUpper m (qsub n) := by simp
      _ ≤ M04CIncomeUpper m qstar + 1 := (hpsiBounds n).2.2.2.le
  let C : ℝ := max 0
    ((qstar.grossReturn + 1) * Abar + (M04CIncomeUpper m qstar + 1))
  have hC : 0 ≤ C := le_max_left _ _
  have hzMeanUpper (n : ℕ) :
      (∫ z, (z : ℝ) ∂(musub n : Measure Resources)) ≤ C := by
    have hbudget := (hMeanData n).2.2.2.2.2.1
    change (∫ z, (z : ℝ) ∂(musub n : Measure Resources)) =
      (qsub n).grossReturn *
          ∫ z, (assetPolicy (m.withPrices (qsub n)) z : ℝ)
            ∂(musub n : Measure Resources) +
        ∫ l, (qsub n).toPrices.effectiveIncome l
          ∂(m.income.law : Measure m.income.Labor) at hbudget
    have hAnonneg : 0 ≤
        ∫ z, (assetPolicy (m.withPrices (qsub n)) z : ℝ)
          ∂(musub n : Measure Resources) :=
      integral_nonneg fun _ ↦ NNReal.zero_le_coe
    have hRnonneg : 0 ≤ (qsub n).grossReturn := (qsub n).property.1.1.le
    have hRbound : (qsub n).grossReturn ≤ qstar.grossReturn + 1 :=
      (hpsiBounds n).2.2.1.le
    have hRstarBoundNonneg : 0 ≤ qstar.grossReturn + 1 := by
      linarith [qstar.property.1.1]
    rw [hbudget]
    apply le_trans (add_le_add
      (mul_le_mul hRbound (hAMeanUpper n) hAnonneg hRstarBoundNonneg)
      (heMeanUpper n))
    exact le_max_right _ _
  have htight : IsTightMeasureSet
      {nu : Measure Resources | ∃ n, nu = (musub n : Measure Resources)} :=
    M08B.tight_of_uniform_first_moment musub hzInt C hC hzMeanUpper
  have hcompact : IsCompact (closure (Set.range musub)) :=
    isCompact_closure_of_isTightMeasureSet (by
      convert htight using 1
      ext nu
      simp [eq_comm])
  obtain ⟨mustar, _hmustar, chi, hchi, hmu⟩ :=
    hcompact.tendsto_subseq (fun n ↦ subset_closure ⟨n, rfl⟩)
  let qlimseq : ℕ → AdmissibleNormalizedPrices m.income := qsub ∘ chi
  let mulimseq : ℕ → ProbabilityMeasure Resources := musub ∘ chi
  have hqlim : Tendsto qlimseq atTop (nhds qstar) := hqsub.comp hchi.tendsto_atTop
  have htightlim : IsTightMeasureSet
      {nu : Measure Resources | ∃ n, nu = (mulimseq n : Measure Resources)} := by
    apply M08B.tight_of_uniform_first_moment mulimseq
      (fun n ↦ hzInt (chi n)) C hC
    intro n
    exact hzMeanUpper (chi n)
  have hinvariant (n : ℕ) :
      householdKernel (m.withPrices (qlimseq n)) ∘ₘ
          (mulimseq n : Measure Resources) = (mulimseq n : Measure Resources) := by
    have hi := (M06C.stationaryLaw_properties
      (m.withPrices (qseq (psi (chi n)))) hsmooth hcurvature hnd
        (hsubcritical (psi (chi n)))).2.2
    exact congrArg ProbabilityMeasure.toMeasure hi
  have hlimitInvariant := tight_kernel_invariant_limit
    (fun n ↦ householdKernel (m.withPrices (qlimseq n)))
    (householdKernel (m.withPrices qstar)) mulimseq mustar
    (fun n ↦ (householdKernel_feller_monotone (m.withPrices (qlimseq n))).2.1)
    (householdKernel_feller_monotone (m.withPrices qstar)).2.1
    (fun f ↦ M08B.householdKernel_tendstoLocallyUniformly m qlimseq qstar hqlim f)
    htightlim hmu hinvariant
  exact (no_invariant_at_or_above_impatience (m.withPrices qstar) hsmooth hnd
    (le_of_eq hcritical.symm)) ⟨mustar, hlimitInvariant⟩

/-- Contracted one-sided filter form of B02. Approaching the critical normalized price and a
finite shift through the strictly subcritical normalized/original-coordinate domain sends the
canonical stationary net asset supply to `+∞`. -/
theorem assetSupply_tendsto_at_impatience
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (qstar : AdmissibleNormalizedPrices m.income) (phiStar : ℝ)
    (hcritical : m.beta * qstar.grossReturn = 1) :
    Tendsto (M08B.upperBoundaryAssetSupply m hsmooth hcurvature hnd)
      (Filter.comap (fun x : M08B.UpperBoundaryPrices m ↦ x.1)
        (nhds (qstar, phiStar))) atTop := by
  rw [Filter.tendsto_iff_seq_tendsto]
  intro x hx
  have hxval : Tendsto (fun n ↦ (x n).1) atTop
      (nhds (qstar, phiStar)) := tendsto_comap.comp hx
  have hq : Tendsto (fun n ↦ (x n).1.1) atTop (nhds qstar) :=
    (continuous_fst.tendsto (qstar, phiStar)).comp hxval
  have hphi : Tendsto (fun n ↦ (x n).1.2) atTop (nhds phiStar) :=
    (continuous_snd.tendsto (qstar, phiStar)).comp hxval
  have hseq := assetSupply_tendsTo_infinity_at_impatience m hsmooth hcurvature hnd
    (fun n ↦ (x n).1.1) qstar (fun n ↦ (x n).1.2) phiStar
    (fun n ↦ (x n).2.1) (fun n ↦ (x n).2.2.1) (fun n ↦ (x n).2.2.2)
    hcritical hq hphi
  simpa [Function.comp_def, M08B.upperBoundaryAssetSupply] using hseq

end
end Aiyagari1994
