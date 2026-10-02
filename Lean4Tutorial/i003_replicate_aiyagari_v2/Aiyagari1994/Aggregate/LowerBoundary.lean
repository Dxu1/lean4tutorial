import Aiyagari1994.Analysis.M08C.LowerBoundary

/-! B03: stationary net asset supply diverges to minus infinity at the natural lower boundary. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- Full sequential natural-limit lower-boundary divergence.  Strict impatience is derived on a
tail from `beta < 1` and `r_n → 0`; no stationary existence is asserted at any critical or
supercritical prefix index.  The total sequence uses `M08C.naturalAssetSupplyExtension`, which is
eventually equal to actual canonical stationary asset supply. -/
theorem naturalAssetSupply_tendsTo_neg_infinity
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (rseq wseq : ℕ → ℝ) (w0 : ℝ)
    (hrpos : ∀ n, 0 < rseq n) (hwpos : ∀ n, 0 < wseq n)
    (hr : Tendsto rseq atTop (nhds 0)) (hw : Tendsto wseq atTop (nhds w0))
    (hw0 : 0 < w0) :
    Tendsto (fun n ↦ M08C.naturalAssetSupplyExtension m hsmooth hcurvature hnd
      (rseq n) (wseq n) (hrpos n) (hwpos n)) atTop atBot := by
  have hR : Tendsto (fun n ↦ 1 + rseq n) atTop (nhds 1) := by
    simpa using tendsto_const_nhds.add hr
  have hbetaR : Tendsto (fun n ↦ m.beta * (1 + rseq n)) atTop (nhds m.beta) := by
    simpa using tendsto_const_nhds.mul hR
  have hEventuallyImpatient : ∀ᶠ n in atTop, m.beta * (1 + rseq n) < 1 :=
    hbetaR.eventually (Iio_mem_nhds m.beta_lt_one)
  obtain ⟨N, hN⟩ := eventually_atTop.1 hEventuallyImpatient
  have htail := M08C.naturalAssetSupply_tendsTo_neg_infinity_of_forall_impatient
    m hsmooth hcurvature hnd (fun n ↦ rseq (n + N)) (fun n ↦ wseq (n + N)) w0
    (fun n ↦ hrpos (n + N)) (fun n ↦ hwpos (n + N))
    (fun n ↦ hN (n + N) (Nat.le_add_left N n))
    (hr.comp (tendsto_add_atTop_nat N)) (hw.comp (tendsto_add_atTop_nat N)) hw0
  apply (tendsto_add_atTop_iff_nat N).1
  simpa [M08C.naturalAssetSupplyExtension,
    fun n ↦ hN (n + N) (Nat.le_add_left N n)] using htail

/-- Contracted one-sided filter formulation of B03. -/
theorem naturalAssetSupply_tendsto_at_zero
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (w0 : ℝ) (hw0 : 0 < w0) :
    Tendsto (M08C.lowerBoundaryAssetSupply m hsmooth hcurvature hnd)
      (Filter.comap (fun x : M08C.LowerBoundaryPrices m ↦ x.1) (nhds (0, w0))) atBot := by
  rw [Filter.tendsto_iff_seq_tendsto]
  intro x hx
  have hxval : Tendsto (fun n ↦ (x n).1) atTop (nhds (0, w0)) :=
    tendsto_comap.comp hx
  have hr : Tendsto (fun n ↦ (x n).1.1) atTop (nhds 0) :=
    (continuous_fst.tendsto (0, w0)).comp hxval
  have hw : Tendsto (fun n ↦ (x n).1.2) atTop (nhds w0) :=
    (continuous_snd.tendsto (0, w0)).comp hxval
  have hseq := naturalAssetSupply_tendsTo_neg_infinity m hsmooth hcurvature hnd
    (fun n ↦ (x n).1.1) (fun n ↦ (x n).1.2) w0
    (fun n ↦ (x n).2.1) (fun n ↦ (x n).2.2.1) hr hw hw0
  simpa [Function.comp_def, M08C.lowerBoundaryAssetSupply,
    M08C.naturalAssetSupplyExtension, (x _).2.2.2] using hseq

end
end Aiyagari1994
