import Aiyagari1994.Aggregate.AssetSupply
import Aiyagari1994.Household.UpperDrift
import Mathlib.Topology.Sequences

/-! Gate-local analytic bridges for the natural-debt-limit lower boundary. -/
open MeasureTheory ProbabilityTheory Set Filter
open scoped ENNReal NNReal Topology ProbabilityTheory

namespace Aiyagari1994.M08C
noncomputable section

/-- The normalized natural-limit price triple.  Its effective income is
`w * (l - l_min)`; the divergent raw debt shift is not a component. -/
def normalizedPrices (m : HouseholdPrimitives) (r w : ℝ)
    (hr : 0 < r) (hw : 0 < w) : AdmissibleNormalizedPrices m.income :=
  ⟨((1 + r, w), -w * m.income.lower), ⟨⟨by linarith, hw⟩, by
    intro l
    have hl := l.property.1
    dsimp
    nlinarith [mul_nonneg hw.le (sub_nonneg.mpr hl)]⟩⟩

/-- The natural debt shift in original coordinates. -/
def naturalDebtShift (m : HouseholdPrimitives) (r w : ℝ) : ℝ :=
  w * m.income.lower / r

/-- Original prices corresponding to the normalized natural-limit problem. -/
def originalPrices (m : HouseholdPrimitives) (r w : ℝ)
    (hr : 0 < r) (hw : 0 < w) : OriginalPrices m.income where
  netRate := r
  wage := w
  debtLimit := naturalDebtShift m r w
  netRate_gt := by linarith
  wage_pos := hw
  debtLimit_nonneg := by
    exact div_nonneg (mul_nonneg hw.le m.income_support.lower_pos.le) hr.le
  income_nonneg := by
    intro l
    unfold naturalDebtShift
    field_simp [ne_of_gt hr]
    exact mul_nonneg hw.le (sub_nonneg.mpr l.property.1)

/-- Normalizing the original natural-limit prices recovers the bounded normalized triple. -/
theorem normalized_originalPrices (m : HouseholdPrimitives) (r w : ℝ)
    (hr : 0 < r) (hw : 0 < w) :
    (originalPrices m r w hr hw).normalized = (normalizedPrices m r w hr hw).toPrices := by
  rw [NormalizedPrices.mk.injEq]
  simp only [originalPrices, OriginalPrices.normalized, normalizedPrices,
    AdmissibleNormalizedPrices.toPrices, naturalDebtShift]
  refine ⟨rfl, rfl, ?_⟩
  unfold AdmissibleNormalizedPrices.intercept
  field_simp [ne_of_gt hr]

/-- The contracted strictly-impatient natural-limit domain. -/
def LowerBoundaryPrices (m : HouseholdPrimitives) :=
  {x : ℝ × ℝ // 0 < x.1 ∧ 0 < x.2 ∧ m.beta * (1 + x.1) < 1}

/-- Canonical stationary net asset supply on the contracted natural-limit domain. -/
def lowerBoundaryAssetSupply (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (x : LowerBoundaryPrices m) : ℝ :=
  let q := normalizedPrices m x.1.1 x.1.2 x.2.1 x.2.2.1
  stationaryAssetSupply (m.withPrices q) (naturalDebtShift m x.1.1 x.1.2)
    (M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd x.2.2.2)

/-- A total finite-prefix extension of natural-limit stationary asset supply.  At every strictly
impatient price it is the actual canonical stationary asset supply.  At a critical or
supercritical price it is set to zero and makes no stationary-existence claim.  Along a positive
rate sequence tending to zero, the fallback branch occurs only on a finite prefix. -/
def naturalAssetSupplyExtension (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income) (r w : ℝ) (hr : 0 < r) (hw : 0 < w) : ℝ :=
  if hbetaR : m.beta * (1 + r) < 1 then
    let q := normalizedPrices m r w hr hw
    stationaryAssetSupply (m.withPrices q) (naturalDebtShift m r w)
      (M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd hbetaR)
  else 0

/-- A D03 forward-invariant upper endpoint supports the canonical stationary law.  The proof
uses the weak drift exactly as qualified: it constructs an invariant law on the compact economic
interval and invokes uniqueness; it does not assert finite-time entry. -/
private theorem stationaryLaw_support_of_common_bound (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income)
    (q : AdmissibleNormalizedPrices m.income) (hbetaR : m.beta * q.grossReturn < 1)
    (B : Resources) (hUpperB : upperEffectiveIncome (m.withPrices q) ≤ B)
    (hInvariant : ∀ z : Resources, lowerEffectiveIncome (m.withPrices q) ≤ z → z ≤ B →
      ∀ l : m.income.Labor,
        lowerEffectiveIncome (m.withPrices q) ≤
            q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l ∧
          q.toPrices.nextResources (assetPolicy (m.withPrices q) z) l ≤ B) :
    (M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd hbetaR :
      Measure Resources) (Icc (0 : Resources) B) = 1 := by
  obtain ⟨piI, hpiI, _⟩ := M05E.economic_compact_stability
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
  have hrhoEq : rho = M06C.stationaryLaw (m.withPrices q)
      hsmooth hcurvature hnd hbetaR :=
    (Classical.choose_spec (Classical.choose_spec (stationaryLaw_exists_unique_global
      (m.withPrices q) hsmooth hcurvature hnd hbetaR))).2.2.2.1 rho hrho
  rw [← hrhoEq]
  have hsmall := M05E.embedLaw_support (lowerEffectiveIncome (m.withPrices q)) B piI
  have hmono : (rho : Measure Resources)
      (Icc (lowerEffectiveIncome (m.withPrices q)) B) ≤
      (rho : Measure Resources) (Icc (0 : Resources) B) :=
    measure_mono (fun _ hz ↦ ⟨bot_le, hz.2⟩)
  have hleOne : (rho : Measure Resources) (Icc (0 : Resources) B) ≤ 1 := by
    calc
      _ ≤ (rho : Measure Resources) Set.univ := measure_mono (Set.subset_univ _)
      _ = 1 := measure_univ
  rw [hsmall] at hmono
  exact le_antisymm hleOne hmono

/-- D03 gives a common compact support eventually along any normalized-price sequence converging
to a strictly impatient normalized price. -/
theorem eventually_common_stationary_support (m : HouseholdPrimitives)
    (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)
    (hnd : IncomeNondegenerate m.income)
    (qseq : ℕ → AdmissibleNormalizedPrices m.income)
    (q : AdmissibleNormalizedPrices m.income) (hq : Tendsto qseq atTop (nhds q))
    (hseqImpatient : ∀ n, m.beta * (qseq n).grossReturn < 1)
    (hqImpatient : m.beta * q.grossReturn < 1) :
    ∃ B : Resources, ∀ᶠ n in atTop,
      (M06C.stationaryLaw (m.withPrices (qseq n)) hsmooth hcurvature hnd
        (hseqImpatient n) : Measure Resources) (Icc (0 : Resources) B) = 1 := by
  let Rmin := q.grossReturn / 2
  let Rmax := q.grossReturn + 1
  let gamma := (m.beta * q.grossReturn + 1) / 2
  let EStar := M04CIncomeUpper m q + 1
  let DeltaStar := M04CIncomeUpper m q - M04CIncomeLower m q + 1
  let Q : Set (AdmissibleNormalizedPrices m.income) := {q' |
    Rmin ≤ q'.grossReturn ∧ q'.grossReturn ≤ Rmax ∧
      m.beta * q'.grossReturn ≤ gamma ∧ M04CIncomeUpper m q' ≤ EStar ∧
      M04CIncomeUpper m q' - M04CIncomeLower m q' ≤ DeltaStar}
  have hqR : 0 < q.grossReturn := q.property.1.1
  have hRmin : 0 < Rmin := by dsimp [Rmin]; linarith
  have hRmax : 0 < Rmax := by dsimp [Rmax]; linarith
  have hgamma : gamma < 1 := by dsimp [gamma]; linarith
  have hEU0 : 0 ≤ M04CIncomeUpper m q :=
    q.property.2 ⟨m.income.upper, m.income_support.ordered, le_rfl⟩
  have hEStar : 0 ≤ EStar := by dsimp [EStar]; linarith
  have hDeltaStar : 0 ≤ DeltaStar := by
    dsimp [DeltaStar, M04CIncomeUpper, M04CIncomeLower]
    unfold AdmissibleNormalizedPrices.wage AdmissibleNormalizedPrices.intercept
    have hwspan := mul_nonneg q.property.1.2.le
      (sub_nonneg.mpr m.income_support.ordered)
    linarith
  obtain ⟨Breal, hBpos, hB⟩ := uniform_upper_drift m hsmooth hcurvature Q
    Rmin Rmax gamma EStar DeltaStar hRmin hRmax hgamma hEStar hDeltaStar
      (fun _ h ↦ h)
  let B : Resources := ⟨Breal, hBpos.le⟩
  refine ⟨B, ?_⟩
  have hR : Tendsto (fun n ↦ (qseq n).grossReturn) atTop (nhds q.grossReturn) :=
    (((continuous_fst.comp continuous_subtype_val).fst).tendsto q).comp hq
  have hEU : Tendsto (fun n ↦ M04CIncomeUpper m (qseq n)) atTop
      (nhds (M04CIncomeUpper m q)) := by
    apply (show Continuous (fun q' : AdmissibleNormalizedPrices m.income ↦
      M04CIncomeUpper m q') by
        unfold M04CIncomeUpper AdmissibleNormalizedPrices.wage
          AdmissibleNormalizedPrices.intercept
        fun_prop).tendsto q |>.comp hq
  have hSpan : Tendsto (fun n ↦
      M04CIncomeUpper m (qseq n) - M04CIncomeLower m (qseq n)) atTop
      (nhds (M04CIncomeUpper m q - M04CIncomeLower m q)) := by
    apply (show Continuous (fun q' : AdmissibleNormalizedPrices m.income ↦
      M04CIncomeUpper m q' - M04CIncomeLower m q') by
        unfold M04CIncomeUpper M04CIncomeLower AdmissibleNormalizedPrices.wage
          AdmissibleNormalizedPrices.intercept
        fun_prop).tendsto q |>.comp hq
  have hRlow : ∀ᶠ n in atTop, Rmin ≤ (qseq n).grossReturn :=
    (hR.eventually (lt_mem_nhds (by dsimp [Rmin]; linarith))).mono (fun _ h ↦ h.le)
  have hRhigh : ∀ᶠ n in atTop, (qseq n).grossReturn ≤ Rmax :=
    (hR.eventually (eventually_lt_nhds (by dsimp [Rmax]; linarith))).mono
      (fun _ h ↦ h.le)
  have hGamma : ∀ᶠ n in atTop, m.beta * (qseq n).grossReturn ≤ gamma :=
    ((hR.const_mul m.beta).eventually
      (eventually_lt_nhds (by dsimp [gamma]; linarith))).mono (fun _ h ↦ h.le)
  have hE : ∀ᶠ n in atTop, M04CIncomeUpper m (qseq n) ≤ EStar :=
    (hEU.eventually (eventually_lt_nhds (by dsimp [EStar]; linarith))).mono
      (fun _ h ↦ h.le)
  have hD : ∀ᶠ n in atTop,
      M04CIncomeUpper m (qseq n) - M04CIncomeLower m (qseq n) ≤ DeltaStar :=
    (hSpan.eventually (eventually_lt_nhds (by dsimp [DeltaStar]; linarith))).mono
      (fun _ h ↦ h.le)
  filter_upwards [hRlow, hRhigh, hGamma, hE, hD] with n hn0 hn1 hn2 hn3 hn4
  rcases hB (qseq n) ⟨hn0, hn1, hn2, hn3, hn4⟩ with ⟨hUpper, _, hInv⟩
  apply stationaryLaw_support_of_common_bound m hsmooth hcurvature hnd
    (qseq n) (hseqImpatient n) B
  · exact_mod_cast hUpper
  · intro z hzLower hzUpper l
    exact_mod_cast hInv z (by exact_mod_cast hzLower) (by exact_mod_cast hzUpper) l

/-- Sequential natural-limit lower-boundary divergence when every index is already strictly
impatient.  This is the tail engine for the contract theorem.  D03 is applied only to the bounded
normalized family `(1+r_n, w_n, -w_n*l_min)`; A02 supplies integrability and the exact
`S_n = E[A_n] - phi_n` accounting identity. -/
theorem naturalAssetSupply_tendsTo_neg_infinity_of_forall_impatient
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)
    (rseq wseq : ℕ → ℝ) (w0 : ℝ)
    (hrpos : ∀ n, 0 < rseq n) (hwpos : ∀ n, 0 < wseq n)
    (hseqImpatient : ∀ n, m.beta * (1 + rseq n) < 1)
    (hr : Tendsto rseq atTop (nhds 0)) (hw : Tendsto wseq atTop (nhds w0))
    (hw0 : 0 < w0) :
    Tendsto (fun n ↦
      let q := normalizedPrices m (rseq n) (wseq n) (hrpos n) (hwpos n)
      stationaryAssetSupply (m.withPrices q) (naturalDebtShift m (rseq n) (wseq n))
        (M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd
          (hseqImpatient n))) atTop atBot := by
  let qseq : ℕ → AdmissibleNormalizedPrices m.income := fun n ↦
    normalizedPrices m (rseq n) (wseq n) (hrpos n) (hwpos n)
  let q0 : AdmissibleNormalizedPrices m.income :=
    ⟨((1, w0), -w0 * m.income.lower), ⟨⟨zero_lt_one, hw0⟩, by
      intro l
      dsimp
      nlinarith [mul_nonneg hw0.le (sub_nonneg.mpr l.property.1)]⟩⟩
  have hq : Tendsto qseq atTop (nhds q0) := by
    apply tendsto_subtype_rng.2
    change Tendsto (fun n ↦ ((1 + rseq n, wseq n), -wseq n * m.income.lower)) atTop
      (nhds ((1, w0), -w0 * m.income.lower))
    have hR : Tendsto (fun n ↦ 1 + rseq n) atTop (nhds (1 + 0)) :=
      tendsto_const_nhds.add hr
    have hk : Tendsto (fun n ↦ -wseq n * m.income.lower) atTop
        (nhds (-w0 * m.income.lower)) := hw.neg.mul_const _
    rw [nhds_prod_eq, nhds_prod_eq]
    simpa using (hR.prodMk hw).prodMk hk
  have hqImpatient : m.beta * q0.grossReturn < 1 := by
    change m.beta * 1 < 1
    simpa using m.beta_lt_one
  obtain ⟨B, hsupport⟩ := eventually_common_stationary_support
    m hsmooth hcurvature hnd qseq q0 hq hseqImpatient hqImpatient
  have hrWithin : Tendsto rseq atTop (nhdsWithin 0 (Ioi 0)) := by
    exact tendsto_nhdsWithin_iff.2 ⟨hr, Filter.Eventually.of_forall hrpos⟩
  have hphi : Tendsto (fun n ↦ naturalDebtShift m (rseq n) (wseq n))
      atTop atTop := by
    have hinv : Tendsto (fun n ↦ (rseq n)⁻¹) atTop atTop :=
      tendsto_inv_nhdsGT_zero.comp hrWithin
    have hnum : Tendsto (fun n ↦ wseq n * m.income.lower) atTop
        (nhds (w0 * m.income.lower)) := hw.mul_const _
    have hnumPos : 0 < w0 * m.income.lower :=
      mul_pos hw0 m.income_support.lower_pos
    let c := (w0 * m.income.lower) / 2
    have hc : 0 < c := by dsimp [c]; positivity
    have hnumLower : ∀ᶠ n in atTop, c ≤ wseq n * m.income.lower :=
      (hnum.eventually (lt_mem_nhds (by dsimp [c]; linarith))).mono
        (fun _ h ↦ h.le)
    have hinvNonneg : ∀ᶠ n in atTop, 0 ≤ (rseq n)⁻¹ :=
      Filter.Eventually.of_forall (fun n ↦ (inv_nonneg.mpr (hrpos n).le))
    apply tendsto_atTop_mono' atTop
      (show ∀ᶠ n in atTop, c * (rseq n)⁻¹ ≤
          naturalDebtShift m (rseq n) (wseq n) by
        filter_upwards [hnumLower, hinvNonneg] with n hn hri
        rw [naturalDebtShift, div_eq_mul_inv]
        exact mul_le_mul_of_nonneg_right hn hri)
    exact hinv.const_mul_atTop hc
  rw [tendsto_atBot]
  intro b
  have hphiLarge : ∀ᶠ n in atTop,
      (B : ℝ) - b ≤ naturalDebtShift m (rseq n) (wseq n) :=
    (tendsto_atTop.1 hphi ((B : ℝ) - b))
  filter_upwards [hsupport, hphiLarge] with n hnSupport hnPhi
  let q := qseq n
  let pi := M06C.stationaryLaw (m.withPrices q) hsmooth hcurvature hnd
    (hseqImpatient n)
  have hbudget := stationary_budget_identity (m.withPrices q) hsmooth hcurvature hnd
    (hseqImpatient n) (originalPrices m (rseq n) (wseq n) (hrpos n) (hwpos n))
    (by
      change q.toPrices =
        (originalPrices m (rseq n) (wseq n) (hrpos n) (hwpos n)).normalized
      exact (normalized_originalPrices m (rseq n) (wseq n)
        (hrpos n) (hwpos n)).symm)
  have hAInt : Integrable (fun z : Resources ↦
      (assetPolicy (m.withPrices q) z : ℝ)) (pi : Measure Resources) := hbudget.2.1
  have hae : ∀ᵐ z ∂(pi : Measure Resources), z ∈ Icc (0 : Resources) B :=
    (ae_mem_iff_measure_eq measurableSet_Icc.nullMeasurableSet).2 (by simpa [pi] using hnSupport)
  have hAmean : (∫ z, (assetPolicy (m.withPrices q) z : ℝ) ∂(pi : Measure Resources)) ≤ B := by
    calc
      _ ≤ ∫ _z : Resources, (B : ℝ) ∂(pi : Measure Resources) := by
        apply integral_mono_ae hAInt (integrable_const (B : ℝ))
        filter_upwards [hae] with z hz
        exact_mod_cast (assetPolicy_le_state (m.withPrices q) z).trans hz.2
      _ = B := by simp
  have hsupply := hbudget.2.2.2.2.2.2.1
  change stationaryAssetSupply (m.withPrices q)
      (naturalDebtShift m (rseq n) (wseq n)) pi =
    (∫ z, (assetPolicy (m.withPrices q) z : ℝ) ∂(pi : Measure Resources)) -
      naturalDebtShift m (rseq n) (wseq n) at hsupply
  dsimp only
  rw [hsupply]
  linarith

end
end Aiyagari1994.M08C
