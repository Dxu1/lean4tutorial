import Lean4Tutorial.i003_replicate_aiyagari.PropertiesHousehold
import Lean4Tutorial.i003_replicate_aiyagari.MonotoneFeller

/-!
# Aiyagari (1994): boundedness, stationarity, and asset supply

The drift and contraction results use quantitative inequalities on the actual
transition/evolution maps.  They do not assume the existence, uniqueness, or
stability conclusions that they prove.
-/

open Filter Function MeasureTheory ProbabilityTheory Set Topology
open scoped BigOperators NNReal Topology

namespace Aiyagari1994

noncomputable section

/-- A bounded gap in consumption becomes asymptotically negligible for
marginal utility under bounded eventual relative risk aversion.  This is the
uniform comparison used across Aiyagari's bounded labor-support interval. -/
theorem rra_marginal_ratio_bounded_gap_tendsto_one
    (M : HouseholdPrimitives)
    (hU : BoundedFiniteUtility M)
    (hRRA : EventualRelativeRiskAversionBound M)
    (c : ExcessResource → ℝ)
    (xMin xMax : ExcessResource → ExcessResource)
    (d : ℝ) (hd : 0 ≤ d)
    (hcmono : Monotone c)
    (horder : ∀ x, xMin x ≤ xMax x)
    (hgap : ∀ x, c (xMax x) - c (xMin x) ≤ d)
    (hcMinTop : Tendsto (fun x => c (xMin x)) atTop atTop) :
    Tendsto (fun x => deriv M.utility (c (xMin x)) /
      deriv M.utility (c (xMax x))) atTop (𝓝 1) := by
  have huDiffAt : ∀ z ∈ Ioi (0 : ℝ), DifferentiableAt ℝ M.utility z := by
    intro z hz
    exact (hU.differentiableOn z hz).differentiableAt (Ioi_mem_nhds hz)
  have hmarginalAnti : AntitoneOn (deriv M.utility) (Ioi (0 : ℝ)) :=
    (hU.strictConcaveOn.concaveOn.subset Ioi_subset_Ici_self
      (convex_Ioi (0 : ℝ))).antitoneOn_deriv huDiffAt
  have hfixed : Tendsto (fun x => deriv M.utility (c (xMin x)) /
      deriv M.utility (c (xMin x) + d)) atTop (𝓝 1) := by
    simpa [Function.comp_def] using
      (hRRA.tendsto_marginal_ratio_add_const hU hd).comp hcMinTop
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le'
    tendsto_const_nhds hfixed ?_ ?_
  · filter_upwards [hcMinTop.eventually (eventually_ge_atTop hRRA.threshold)] with x hx
    have hcmin0 : 0 < c (xMin x) := hRRA.threshold_pos.trans_le hx
    have hcmax0 : 0 < c (xMax x) :=
      hcmin0.trans_le (hcmono (horder x))
    have hm := hmarginalAnti hcmin0 hcmax0 (hcmono (horder x))
    exact (one_le_div₀ (hRRA.marginal_pos _ hcmax0)).2 hm
  · filter_upwards [hcMinTop.eventually (eventually_ge_atTop hRRA.threshold)] with x hx
    have hcmin0 : 0 < c (xMin x) := hRRA.threshold_pos.trans_le hx
    have hcmax0 : 0 < c (xMax x) :=
      hcmin0.trans_le (hcmono (horder x))
    have hcgap0 : 0 < c (xMin x) + d := add_pos_of_pos_of_nonneg hcmin0 hd
    have hcmax_le : c (xMax x) ≤ c (xMin x) + d := by
      linarith [hgap x]
    have hmden : deriv M.utility (c (xMin x) + d) ≤
        deriv M.utility (c (xMax x)) :=
      hmarginalAnti hcmax0 hcgap0 hcmax_le
    exact div_le_div_of_nonneg_left
      (hRRA.marginal_pos _ hcmin0).le
      (hRRA.marginal_pos _ hcgap0) hmden

/-- Aiyagari's Proposition 4 in the unbounded-policy branch.  The optimal
asset policy, consumption policy, Euler equation, and envelope equation are
all the solved Bellman objects.  The only global closure supplied separately
is divergence of solved consumption at high resources. -/
theorem bounded_resource_dynamics_of_policy_tendsto_atTop
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hRRA : EventualRelativeRiskAversionBound M)
    (hClosure : HighResourceConsumptionClosure
      (boundedAiyagariConsumption M φ hM hφ hU))
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (hAatTop : Tendsto
      (boundedAiyagariAssetPolicy M φ hM hφ hU) atTop atTop) :
    ∃ xstar : ExcessResource, ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x := by
  let A := boundedAiyagariAssetPolicy M φ hM hφ hU
  let c := boundedAiyagariConsumption M φ hM hφ hU
  let V := boundedAiyagariValue M φ hM hφ hU
  let R := 1 + M.r
  let d := M.w * (M.lmax - M.lmin)
  let xMin : ExcessResource → ExcessResource := fun x =>
    ⟨R * A x, mul_nonneg (by dsimp [R]; linarith [hM.r_pos])
      (boundedAiyagariAssetPolicy_mem M φ hM hφ hU x).1⟩
  let xMax : ExcessResource → ExcessResource := fun x =>
    ⟨R * A x + d, add_nonneg
      (mul_nonneg (by dsimp [R]; linarith [hM.r_pos])
        (boundedAiyagariAssetPolicy_mem M φ hM hφ hU x).1)
      (mul_nonneg hM.w_pos.le (sub_nonneg.mpr hM.lmin_lt_lmax.le))⟩
  let μ : Measure (LaborSupportState M) := laborSupportProbability M hM
  have hRpos : 0 < R := by dsimp [R]; linarith [hM.r_pos]
  have hd : 0 ≤ d := by
    dsimp [d]
    exact mul_nonneg hM.w_pos.le (sub_nonneg.mpr hM.lmin_lt_lmax.le)
  have hMinTop : Tendsto xMin atTop atTop := by
    rw [tendsto_atTop]
    intro b
    have hev : ∀ᶠ x in atTop, (b : ℝ) / R ≤ A x :=
      hAatTop.eventually (eventually_ge_atTop ((b : ℝ) / R))
    filter_upwards [hev] with x hx
    change (b : ℝ) ≤ R * A x
    simpa [mul_comm] using (div_le_iff₀ hRpos).mp hx
  have hcMinTop : Tendsto (fun x => c (xMin x)) atTop atTop :=
    hClosure.consumption_tendsto_atTop.comp hMinTop
  have hxminmax : ∀ x, xMin x ≤ xMax x := by
    intro x
    exact_mod_cast le_add_of_nonneg_right hd
  have hcmono : Monotone c :=
    monotone_boundedAiyagariConsumption M φ hM hφ hU
  have hcgap : ∀ x, c (xMax x) - c (xMin x) ≤ d := by
    intro x
    have hinc := boundedAiyagariAssetPolicy_increment_bounds M φ hM hφ hU
      (hx := hxminmax x)
    have hstate : (xMax x : ℝ) - (xMin x : ℝ) = d := by
      change (R * A x + d) - R * A x = d
      ring
    change (resourceLevel M φ (xMax x) -
        boundedAiyagariAssetPolicy M φ hM hφ hU (xMax x)) -
      (resourceLevel M φ (xMin x) -
        boundedAiyagariAssetPolicy M φ hM hφ hU (xMin x)) ≤ d
    dsimp [resourceLevel]
    linarith [hinc.1]
  have hratio : Tendsto (fun x => deriv M.utility (c (xMin x)) /
      deriv M.utility (c (xMax x))) atTop (𝓝 1) :=
    rra_marginal_ratio_bounded_gap_tendsto_one M hU hRRA c xMin xMax d hd
      hcmono hxminmax hcgap hcMinTop
  let ε := (1 - M.β * R) / (2 * (M.β * R))
  have hβRpos : 0 < M.β * R := mul_pos hM.β_pos hRpos
  have hεpos : 0 < ε := by
    dsimp [ε]
    exact div_pos (sub_pos.mpr himp.discountedReturn_lt_one)
      (mul_pos (by norm_num) hβRpos)
  have hεeq : M.β * R * ε = (1 - M.β * R) / 2 := by
    dsimp [ε]
    field_simp [ne_of_gt hβRpos, ne_of_gt hM.β_pos, ne_of_gt hRpos]
  have hdiscount : M.β * R * (1 + ε) < 1 := by
    nlinarith [himp.discountedReturn_lt_one, hεeq]
  have hratioEventually : ∀ᶠ x in atTop,
      deriv M.utility (c (xMin x)) /
        deriv M.utility (c (xMax x)) < 1 + ε :=
    hratio.eventually (Iio_mem_nhds (lt_add_of_pos_right 1 hεpos))
  have hAposEventually : ∀ᶠ x in atTop, 0 < A x :=
    hAatTop.eventually (eventually_gt_atTop 0)
  have hcposEventually : ∀ᶠ x in atTop, 0 < c x :=
    hClosure.consumption_tendsto_atTop.eventually (eventually_gt_atTop 0)
  have hcMinPosEventually : ∀ᶠ x in atTop, 0 < c (xMin x) :=
    hcMinTop.eventually (eventually_gt_atTop 0)
  have hxposEventually : ∀ᶠ x : ExcessResource in atTop, 0 < (x : ℝ) :=
    eventually_gt_atTop 0
  have hdriftEventually : ∀ᶠ x in atTop, xMax x ≤ x := by
    filter_upwards [hratioEventually, hAposEventually, hcposEventually,
      hcMinPosEventually, hxposEventually] with x hratioX hApos hcx hcmin hxpos
    have hxminpos : 0 < (xMin x : ℝ) := by
      dsimp [xMin]
      exact mul_pos hRpos hApos
    have hcmax : 0 < c (xMax x) := hcmin.trans_le (hcmono (hxminmax x))
    have hmmaxpos : 0 < deriv M.utility (c (xMax x)) :=
      hU.marginal_pos _ hcmax
    have hmratio : deriv M.utility (c (xMin x)) <
        (1 + ε) * deriv M.utility (c (xMax x)) := by
      exact (div_lt_iff₀ hmmaxpos).mp hratioX
    have huDiffAt : ∀ z ∈ Ioi (0 : ℝ), DifferentiableAt ℝ M.utility z := by
      intro z hz
      exact (hU.differentiableOn z hz).differentiableAt (Ioi_mem_nhds hz)
    have hmarginalAnti : AntitoneOn (deriv M.utility) (Ioi (0 : ℝ)) :=
      (hU.strictConcaveOn.concaveOn.subset Ioi_subset_Ici_self
        (convex_Ioi (0 : ℝ))).antitoneOn_deriv huDiffAt
    have hpoint : ∀ l : LaborSupportState M,
        boundedContinuationDerivativeIntegrand M V (A x) l ≤
          R * (1 + ε) * deriv M.utility (c (xMax x)) := by
      intro l
      let X := solvedNextExcess M φ hM hφ hU x l
      have hminX : xMin x ≤ X := by
        apply Subtype.coe_le_coe.mp
        dsimp [xMin, X, solvedNextExcess]
        exact le_add_of_nonneg_right
          (mul_nonneg hM.w_pos.le (sub_nonneg.mpr l.property.1))
      have hXmax : X ≤ xMax x := by
        apply Subtype.coe_le_coe.mp
        change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
            M.w * ((l : ℝ) - M.lmin) ≤ R * A x + d
        have hl := mul_le_mul_of_nonneg_left
          (show (l : ℝ) - M.lmin ≤ M.lmax - M.lmin by linarith [l.property.2])
          hM.w_pos.le
        dsimp [R, A, d]
        linarith
      have hcX : 0 < c X := hcmin.trans_le (hcmono hminX)
      have hXpos : 0 < (X : ℝ) := by
        exact hxminpos.trans_le (Subtype.coe_le_coe.mpr hminX)
      have hcX' : 0 < resourceLevel M φ X -
          boundedAiyagariAssetPolicy M φ hM hφ hU X := by
        simpa only [c, boundedAiyagariConsumption] using hcX
      have henv := boundedAiyagari_envelope_of_consumption_pos
        M φ hM hφ hU X hXpos hcX'
      have hmarginal : deriv M.utility (c X) ≤ deriv M.utility (c (xMin x)) :=
        hmarginalAnti hcmin hcX (hcmono hminX)
      have hderivEq : deriv (liftedExcessValue V) (X : ℝ) =
          deriv M.utility (c X) := by
        simpa only [V, c, boundedAiyagariConsumption] using henv.deriv
      unfold boundedContinuationDerivativeIntegrand
      change R * deriv (liftedExcessValue V) (X : ℝ) ≤
        R * (1 + ε) * deriv M.utility (c (xMax x))
      rw [hderivEq]
      nlinarith
    have hcx' : 0 < resourceLevel M φ x -
        boundedAiyagariAssetPolicy M φ hM hφ hU x := by
      simpa only [c, boundedAiyagariConsumption] using hcx
    have heuler := (boundedAiyagari_euler_inequality
      M φ hM hφ hU x hcx' (hDiff x)).2 hApos
    have hderivIntegrable : Integrable
        (boundedContinuationDerivativeIntegrand M V (A x)) μ := by
      simpa [V, A, μ] using (hDiff x).hasDerivAt_integral.1
    have hintegral :
        (∫ l : LaborSupportState M,
          boundedContinuationDerivativeIntegrand M V (A x) l ∂μ) ≤
          R * (1 + ε) * deriv M.utility (c (xMax x)) := by
      have hmono := integral_mono_ae hderivIntegrable (integrable_const _)
        (Eventually.of_forall hpoint)
      simpa [μ] using hmono
    have hmarginalCurrent : deriv M.utility (c x) ≤
        M.β * R * (1 + ε) * deriv M.utility (c (xMax x)) := by
      have hscaled := mul_le_mul_of_nonneg_left hintegral hM.β_pos.le
      dsimp [V, A, μ] at heuler hscaled
      rw [heuler] at hscaled
      simpa only [c, boundedAiyagariConsumption, mul_assoc] using hscaled
    have hstrictMarginal : deriv M.utility (c x) <
        deriv M.utility (c (xMax x)) := by
      have hmpos := hU.marginal_pos _ hcmax
      nlinarith [hdiscount]
    have henvX := boundedAiyagari_envelope_of_consumption_pos
      M φ hM hφ hU x hxpos hcx'
    have hcmax' : 0 < resourceLevel M φ (xMax x) -
        boundedAiyagariAssetPolicy M φ hM hφ hU (xMax x) := by
      simpa only [c, boundedAiyagariConsumption] using hcmax
    have henvMax := boundedAiyagari_envelope_of_consumption_pos
      M φ hM hφ hU (xMax x)
        (hxminpos.trans_le (Subtype.coe_le_coe.mpr (hxminmax x))) hcmax'
    by_contra hnot
    have hxx : (x : ℝ) < (xMax x : ℝ) := by
      exact lt_of_not_ge hnot
    have hconc := boundedAiyagariValue_concave M φ hM hφ hU
    have hslopeUpper := hconc.slope_le_of_hasDerivAt
      (show (x : ℝ) ∈ Ici (0 : ℝ) from x.property)
      (show (xMax x : ℝ) ∈ Ici (0 : ℝ) from (xMax x).property)
      hxx henvX
    have hslopeLower := hconc.le_slope_of_hasDerivAt
      (show (x : ℝ) ∈ Ici (0 : ℝ) from x.property)
      (show (xMax x : ℝ) ∈ Ici (0 : ℝ) from (xMax x).property)
      hxx henvMax
    have hderivOrder : deriv M.utility
        (resourceLevel M φ (xMax x) -
          boundedAiyagariAssetPolicy M φ hM hφ hU (xMax x)) ≤
        deriv M.utility
          (resourceLevel M φ x -
            boundedAiyagariAssetPolicy M φ hM hφ hU x) :=
      hslopeLower.trans hslopeUpper
    exact (not_lt_of_ge hderivOrder) (by
      simpa only [c, boundedAiyagariConsumption] using hstrictMarginal)
  rcases (eventually_atTop.1 hdriftEventually) with ⟨xstar, hxstar⟩
  refine ⟨xstar, ?_⟩
  intro x l hx
  have hnextMax : solvedNextExcess M φ hM hφ hU x l ≤ xMax x := by
    apply Subtype.coe_le_coe.mp
    change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
        M.w * ((l : ℝ) - M.lmin) ≤ R * A x + d
    have hl := mul_le_mul_of_nonneg_left
      (show (l : ℝ) - M.lmin ≤ M.lmax - M.lmin by linarith [l.property.2])
      hM.w_pos.le
    dsimp [R, A, d]
    linarith
  exact hnextMax.trans (hxstar x hx)

/-- Property 6: the solved household transition admits a finite upper drift
threshold.  Bounded optimal saving gives the threshold directly; if saving is
unbounded, Aiyagari's Euler/envelope/RRA argument above supplies it. -/
theorem property06_bounded_resource_dynamics
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hRRA : EventualRelativeRiskAversionBound M)
    (hClosure : HighResourceConsumptionClosure
      (boundedAiyagariConsumption M φ hM hφ hU))
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x)) :
    ∃ xstar : ExcessResource, ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x := by
  let A := boundedAiyagariAssetPolicy M φ hM hφ hU
  by_cases hbdd : BddAbove (Set.range A)
  · rcases hbdd with ⟨K, hK⟩
    have hKall : ∀ x, A x ≤ K := fun x => hK ⟨x, rfl⟩
    let B := (1 + M.r) * K + M.w * (M.lmax - M.lmin)
    let xstar : ExcessResource := ⟨max 0 B, le_max_left _ _⟩
    refine ⟨xstar, ?_⟩
    intro x l hx
    apply Subtype.coe_le_coe.mp
    have hA : (1 + M.r) * A x ≤ (1 + M.r) * K :=
      mul_le_mul_of_nonneg_left (hKall x) (by linarith [hM.r_pos])
    have hl := mul_le_mul_of_nonneg_left
      (show (l : ℝ) - M.lmin ≤ M.lmax - M.lmin by linarith [l.property.2])
      hM.w_pos.le
    have hBx : B ≤ (x : ℝ) := by
      exact (le_max_right 0 B).trans (show xstar ≤ x from hx)
    change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * ((l : ℝ) - M.lmin) ≤ (x : ℝ)
    dsimp [A] at hA
    dsimp [B] at hBx
    linarith
  · have hAmono : Monotone A :=
      monotone_boundedAiyagariAssetPolicy M φ hM hφ hU
    have hcofinal : ∀ b : ℝ, ∃ x : ExcessResource, b ≤ A x := by
      intro b
      by_contra h
      push_neg at h
      apply hbdd
      refine ⟨b, ?_⟩
      rintro _ ⟨x, rfl⟩
      exact (h x).le
    have hAatTop : Tendsto A atTop atTop :=
      hAmono.tendsto_atTop_atTop hcofinal
    exact bounded_resource_dynamics_of_policy_tendsto_atTop
      M φ hM hφ hU himp hRRA hClosure hDiff hAatTop

/-- Krylov--Bogoliubov applied to the actual solved household.  Property 6
produces an absorbing compact interval, and the solved policy makes its
kernel Feller, so an invariant probability exists without a distributional
contraction assumption. -/
theorem solvedHousehold_invariantProbability_exists
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hRRA : EventualRelativeRiskAversionBound M)
    (hClosure : HighResourceConsumptionClosure
      (boundedAiyagariConsumption M φ hM hφ hU))
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x)) :
    ∃ (xstar : ExcessResource)
      (hDrift : ∀ x l, xstar ≤ x →
        solvedNextExcess M φ hM hφ hU x l ≤ x)
      (μ : ProbabilityMeasure (BoundedExcessResource xstar)),
      markovLawEvolution
        (absorbingSolvedKernel M φ hM hφ hU xstar hDrift) μ = μ := by
  rcases property06_bounded_resource_dynamics
    M φ hM hφ hU himp hRRA hClosure hDiff with ⟨xstar, hDrift⟩
  rcases exists_invariantProbability_absorbingSolvedKernel
    M φ hM hφ hU xstar hDrift with ⟨μ, hμ⟩
  exact ⟨xstar, hDrift, μ, hμ⟩

/-- Under impatience, the solved resource map associated with the minimum
labor realization strictly lowers every positive excess-resource state.  This
is the deterministic core of Aiyagari's low-income-block mixing argument.

If the minimum-income successor were weakly above the current state, every
other labor realization would also produce a weakly higher successor.
Monotone consumption and concavity would then bound every continuation
marginal value by today's marginal utility times the gross return.  The
interior Euler equality would imply `1 ≤ β (1+r)`, contradicting
impatience. -/
theorem minimumLaborTransition_strictly_decreases
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x)) :
    ∀ x : ExcessResource, 0 < x →
      solvedNextExcess M φ hM hφ hU x
        ⟨M.lmin, le_rfl, hM.lmin_lt_lmax.le⟩ < x := by
  intro x hx
  let A := boundedAiyagariAssetPolicy M φ hM hφ hU
  let c := boundedAiyagariConsumption M φ hM hφ hU
  let V := boundedAiyagariValue M φ hM hφ hU
  let R := 1 + M.r
  let μ : Measure (LaborSupportState M) := laborSupportProbability M hM
  let lmin : LaborSupportState M :=
    ⟨M.lmin, le_rfl, hM.lmin_lt_lmax.le⟩
  have hRpos : 0 < R := by dsimp [R]; linarith [hM.r_pos]
  have hAnonneg : 0 ≤ A x :=
    (boundedAiyagariAssetPolicy_mem M φ hM hφ hU x).1
  by_cases hAzero : A x = 0
  · change solvedNextExcess M φ hM hφ hU x lmin < x
    apply Subtype.coe_lt_coe.mp
    simp [solvedNextExcess, lmin, A, hAzero]
    exact_mod_cast hx
  · have hApos : 0 < A x := lt_of_le_of_ne hAnonneg (Ne.symm hAzero)
    by_contra hnot
    have hxle : x ≤ solvedNextExcess M φ hM hφ hU x lmin :=
      le_of_not_gt hnot
    have hcmono := monotone_boundedAiyagariConsumption M φ hM hφ hU
    have hcpos : 0 < c x := by
      have hcx := hcmono (show (0 : ExcessResource) ≤ x from bot_le)
      simpa [c, boundedAiyagariConsumption] using hc0.trans_le hcx
    have heuler := (boundedAiyagari_euler_inequality
      M φ hM hφ hU x (by simpa [c, boundedAiyagariConsumption] using hcpos)
        (hDiff x)).2 hApos
    have huDiffAt : ∀ z ∈ Ioi (0 : ℝ), DifferentiableAt ℝ M.utility z := by
      intro z hz
      exact (hU.differentiableOn z hz).differentiableAt (Ioi_mem_nhds hz)
    have hmarginalAnti : AntitoneOn (deriv M.utility) (Ioi (0 : ℝ)) :=
      (hU.strictConcaveOn.concaveOn.subset Ioi_subset_Ici_self
        (convex_Ioi (0 : ℝ))).antitoneOn_deriv huDiffAt
    have hpoint : ∀ l : LaborSupportState M,
        boundedContinuationDerivativeIntegrand M V (A x) l ≤
          R * deriv M.utility (c x) := by
      intro l
      let X := solvedNextExcess M φ hM hφ hU x l
      have hminX : solvedNextExcess M φ hM hφ hU x lmin ≤ X := by
        apply Subtype.coe_le_coe.mp
        dsimp [X, lmin, solvedNextExcess]
        simp only [NNReal.coe_mk, sub_self, mul_zero, add_zero]
        exact le_add_of_nonneg_right
          (mul_nonneg hM.w_pos.le (sub_nonneg.mpr l.property.1))
      have hxX : x ≤ X := hxle.trans hminX
      have hcX : 0 < c X := hcpos.trans_le (hcmono hxX)
      have hXpos : 0 < (X : ℝ) := by
        exact_mod_cast hx.trans_le hxX
      have henv := boundedAiyagari_envelope_of_consumption_pos
        M φ hM hφ hU X hXpos
          (by simpa [c, boundedAiyagariConsumption] using hcX)
      have hmarginal := hmarginalAnti hcpos hcX (hcmono hxX)
      have hderivEq : deriv (liftedExcessValue V) (X : ℝ) =
          deriv M.utility (c X) := by
        simpa [V, c, boundedAiyagariConsumption] using henv.deriv
      unfold boundedContinuationDerivativeIntegrand
      change R * deriv (liftedExcessValue V) (X : ℝ) ≤
        R * deriv M.utility (c x)
      rw [hderivEq]
      exact mul_le_mul_of_nonneg_left hmarginal hRpos.le
    have hderivIntegrable : Integrable
        (boundedContinuationDerivativeIntegrand M V (A x)) μ := by
      simpa [V, A, μ] using (hDiff x).hasDerivAt_integral.1
    have hintegral :
        (∫ l : LaborSupportState M,
          boundedContinuationDerivativeIntegrand M V (A x) l ∂μ) ≤
            R * deriv M.utility (c x) := by
      have hmono := integral_mono_ae hderivIntegrable (integrable_const _)
        (Eventually.of_forall hpoint)
      simpa [μ] using hmono
    have hscaled := mul_le_mul_of_nonneg_left hintegral hM.β_pos.le
    have hmarginalPos : 0 < deriv M.utility (c x) :=
      hU.marginal_pos _ hcpos
    dsimp [V, A, c, R, μ] at heuler hscaled hmarginalPos
    rw [heuler] at hscaled
    have hle : deriv M.utility
          (resourceLevel M φ x - boundedAiyagariAssetPolicy M φ hM hφ hU x) ≤
        (M.β * (1 + M.r)) * deriv M.utility
          (boundedAiyagariConsumption M φ hM hφ hU x) := by
      calc
        _ ≤ M.β * ((1 + M.r) * deriv M.utility
            (boundedAiyagariConsumption M φ hM hφ hU x)) := hscaled
        _ = _ := by ring
    have hstrict : (M.β * (1 + M.r)) * deriv M.utility
          (boundedAiyagariConsumption M φ hM hφ hU x) <
        deriv M.utility (boundedAiyagariConsumption M φ hM hφ hU x) :=
      (mul_lt_iff_lt_one_left hmarginalPos).2 himp.discountedReturn_lt_one
    exact (not_lt_of_ge hle) hstrict

/-- The deterministic transition obtained by setting labor equal to the
lower support endpoint. -/
def minimumLaborTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) : ExcessResource → ExcessResource :=
  fun x => solvedNextExcess M φ hM hφ hU x
    ⟨M.lmin, le_rfl, hM.lmin_lt_lmax.le⟩

theorem continuous_minimumLaborTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    Continuous (minimumLaborTransition M φ hM hφ hU) := by
  apply Continuous.subtype_mk
  change Continuous (fun x : ExcessResource =>
    (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * (M.lmin - M.lmin))
  exact (continuous_const.mul
    (continuous_boundedAiyagariAssetPolicy M φ hM hφ hU)).add
      (continuous_const.mul continuous_const)

theorem monotone_minimumLaborTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    Monotone (minimumLaborTransition M φ hM hφ hU) := by
  exact monotone_solvedResourceTransition M φ hM hφ hU
    ⟨M.lmin, le_rfl, hM.lmin_lt_lmax.le⟩

/-- The minimum-income map fixes zero because impatience makes the borrowing
constraint bind at the minimum resource state. -/
theorem minimumLaborTransition_zero
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff0 : LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU 0)) :
    minimumLaborTransition M φ hM hφ hU 0 = 0 := by
  have hAzero := boundedAiyagariAssetPolicy_zero_at_minimum
    M φ hM hφ hU himp hc0 hDiff0
  apply Subtype.ext
  change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU 0 +
    M.w * (M.lmin - M.lmin) = (0 : ℝ)
  simp [hAzero]

/-- A common finite block of minimum labor realizations drives every initial
state in a bounded interval strictly inside the solved binding region.  The
next transition therefore forgets the initial state.  Replacing the exact
endpoint block by a positive-probability relative neighborhood is the only
remaining step before constructing the household splitting event. -/
theorem minimumLaborBlock_uniformly_enters_bindingRegion
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource) :
    ∃ (xhat : ExcessResource) (N : ℕ), 0 < xhat ∧
      (∀ x ≤ xstar,
        ((minimumLaborTransition M φ hM hφ hU)^[N]) x < xhat) ∧
      ∀ x ≤ xhat,
        boundedAiyagariAssetPolicy M φ hM hφ hU x = 0 := by
  rcases boundedAiyagari_binding_cutoff M φ hM hφ hU himp hc0 hDiff with
    ⟨xhat, hxhat, hbind⟩
  let T := minimumLaborTransition M φ hM hφ hU
  have hTstrict : ∀ x : ExcessResource, 0 < x → T x < x := by
    intro x hx
    exact minimumLaborTransition_strictly_decreases
      M φ hM hφ hU himp hc0 hDiff x hx
  rcases exists_uniform_iterate_lt_of_monotone_strictDecrease
      T (continuous_minimumLaborTransition M φ hM hφ hU)
      (monotone_minimumLaborTransition M φ hM hφ hU)
      (minimumLaborTransition_zero M φ hM hφ hU himp hc0 (hDiff 0))
      hTstrict xstar xhat hxhat with ⟨N, hN⟩
  exact ⟨xhat, N, hxhat, hN, hbind⟩

/-- Resource transition when the labor shock is represented by its
nonnegative distance `δ` above the lower support endpoint.  This auxiliary
map is defined for every nonnegative offset; later we restrict `δ` to the
labor-support width. -/
def lowOffsetTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (δ x : ExcessResource) : ExcessResource :=
  ⟨(1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * (δ : ℝ),
    add_nonneg
      (mul_nonneg (by linarith [hM.r_pos])
        (boundedAiyagariAssetPolicy_mem M φ hM hφ hU x).1)
      (mul_nonneg hM.w_pos.le δ.property)⟩

@[simp] theorem lowOffsetTransition_zero
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) (x : ExcessResource) :
    lowOffsetTransition M φ hM hφ hU 0 x =
      minimumLaborTransition M φ hM hφ hU x := by
  apply Subtype.ext
  simp [lowOffsetTransition, minimumLaborTransition, solvedNextExcess]

theorem continuous_lowOffsetTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    Continuous (fun p : ExcessResource × ExcessResource =>
      lowOffsetTransition M φ hM hφ hU p.1 p.2) := by
  apply Continuous.subtype_mk
  exact (continuous_const.mul
      ((continuous_boundedAiyagariAssetPolicy M φ hM hφ hU).comp
        continuous_snd)).add
    (continuous_const.mul (continuous_subtype_val.comp continuous_fst))

theorem monotone_lowOffsetTransition_state
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) (δ : ExcessResource) :
    Monotone (lowOffsetTransition M φ hM hφ hU δ) := by
  intro x y hxy
  apply Subtype.coe_le_coe.mp
  change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * (δ : ℝ) ≤
    (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU y +
      M.w * (δ : ℝ)
  exact add_le_add_left
    (mul_le_mul_of_nonneg_left
      (monotone_boundedAiyagariAssetPolicy M φ hM hφ hU hxy)
      (by linarith [hM.r_pos])) (M.w * (δ : ℝ))

theorem monotone_lowOffsetTransition_offset
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) (x : ExcessResource) :
    Monotone (fun δ => lowOffsetTransition M φ hM hφ hU δ x) := by
  intro δ ε hδε
  apply Subtype.coe_le_coe.mp
  change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * (δ : ℝ) ≤
    (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * (ε : ℝ)
  exact add_le_add_right
    (mul_le_mul_of_nonneg_left (by exact_mod_cast hδε) hM.w_pos.le)
    ((1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x)

/-- Fixed-offset iteration is continuous in the offset. -/
theorem continuous_lowOffsetTransition_iterate
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (N : ℕ) (x : ExcessResource) :
    Continuous (fun δ : ExcessResource =>
      ((lowOffsetTransition M φ hM hφ hU δ)^[N]) x) := by
  induction N with
  | zero => simpa using
      (continuous_const : Continuous (fun _ : ExcessResource => x))
  | succ N ih =>
      rw [show (fun δ : ExcessResource =>
          ((lowOffsetTransition M φ hM hφ hU δ)^[N + 1]) x) =
        fun δ => lowOffsetTransition M φ hM hφ hU δ
          (((lowOffsetTransition M φ hM hφ hU δ)^[N]) x) by
            funext δ
            rw [Function.iterate_succ_apply']]
      simpa [Function.comp_def, Function.uncurry] using
        (continuous_lowOffsetTransition M φ hM hφ hU).comp
          (continuous_id.prodMk ih)

/-- Strict entrance under the exact endpoint block persists for all
sufficiently small positive labor offsets.  This supplies an actual open
shock neighborhood to which lower-support reachability can assign positive
probability. -/
theorem exists_positive_lowOffset_uniformly_enters_bindingRegion
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource) :
    ∃ (xhat : ExcessResource) (N : ℕ) (ε : ExcessResource),
      0 < xhat ∧ 0 < ε ∧
      ((lowOffsetTransition M φ hM hφ hU ε)^[N]) xstar < xhat ∧
      ∀ x ≤ xhat,
        boundedAiyagariAssetPolicy M φ hM hφ hU x = 0 := by
  rcases minimumLaborBlock_uniformly_enters_bindingRegion
      M φ hM hφ hU himp hc0 hDiff xstar with
    ⟨xhat, N, hxhat, hN, hbind⟩
  have hexact :
      ((lowOffsetTransition M φ hM hφ hU 0)^[N]) xstar < xhat := by
    have hmap : lowOffsetTransition M φ hM hφ hU 0 =
        minimumLaborTransition M φ hM hφ hU := by
      funext x
      exact lowOffsetTransition_zero M φ hM hφ hU x
    rw [hmap]
    exact hN xstar le_rfl
  have hopen : (fun δ : ExcessResource =>
      ((lowOffsetTransition M φ hM hφ hU δ)^[N]) xstar) ⁻¹' Iio xhat ∈
      𝓝 (0 : ExcessResource) :=
    (continuous_lowOffsetTransition_iterate M φ hM hφ hU N xstar).continuousAt
      (Iio_mem_nhds hexact)
  rcases NNReal.nhds_zero_basis.mem_iff.mp hopen with ⟨ε₀, hε₀, hεsub⟩
  let ε : ExcessResource := ε₀ / 2
  have hε : 0 < ε := half_pos hε₀
  have hεmem : ε ∈ Iio ε₀ := by
    change ε₀ / 2 < ε₀
    exact half_lt_self hε₀
  exact ⟨xhat, N, ε, hxhat, hε, hεsub hεmem, hbind⟩

/-- Resource path generated by a finite sequence of nonnegative labor
offsets.  Only coordinates `0,…,N-1` of `δ` affect the `N`-step value. -/
def lowOffsetBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    ℕ → (ℕ → ExcessResource) → ExcessResource → ExcessResource
  | 0, _, x => x
  | N + 1, δ, x => lowOffsetTransition M φ hM hφ hU (δ N)
      (lowOffsetBlockTransition M φ hM hφ hU N δ x)

/-- A coordinatewise low-offset block is dominated by iteration of the
constant upper offset.  This is the deterministic comparison needed to turn
an open lower-support box into a common entrance event. -/
theorem lowOffsetBlockTransition_le_constant
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (N : ℕ) (δ : ℕ → ExcessResource) (ε x xstar : ExcessResource)
    (hx : x ≤ xstar) (hδ : ∀ i < N, δ i ≤ ε) :
    lowOffsetBlockTransition M φ hM hφ hU N δ x ≤
      ((lowOffsetTransition M φ hM hφ hU ε)^[N]) xstar := by
  induction N with
  | zero => simpa [lowOffsetBlockTransition] using hx
  | succ N ih =>
      rw [show N + 1 = Nat.succ N by omega,
        lowOffsetBlockTransition, Function.iterate_succ_apply']
      have hoffset : δ N ≤ ε := hδ N (by omega)
      have hprev := ih (fun i hi => hδ i (by omega))
      exact (monotone_lowOffsetTransition_offset M φ hM hφ hU _ hoffset).trans
        (monotone_lowOffsetTransition_state M φ hM hφ hU ε hprev)

/-- Nonnegative distance of a supported labor realization above the lower
endpoint. -/
def supportedLaborOffset (M : HouseholdPrimitives)
    (l : LaborSupportState M) : ExcessResource :=
  ⟨(l : ℝ) - M.lmin, sub_nonneg.mpr l.property.1⟩

theorem solvedNextExcess_eq_lowOffsetTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (x : ExcessResource) (l : LaborSupportState M) :
    solvedNextExcess M φ hM hφ hU x l =
      lowOffsetTransition M φ hM hφ hU (supportedLaborOffset M l) x := by
  rfl

/-- The solved resource path under a finite sequence of supported labor
realizations. -/
def solvedLaborBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (N : ℕ) (l : ℕ → LaborSupportState M) (x : ExcessResource) :
    ExcessResource :=
  lowOffsetBlockTransition M φ hM hφ hU N
    (fun i => supportedLaborOffset M (l i)) x

/-- Every labor block lying in a sufficiently small relative neighborhood of
the lower support endpoint sends the whole bounded state interval into the
binding region. -/
theorem lowLaborNeighborhoodBlock_uniformly_enters_bindingRegion
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource) :
    ∃ (xhat : ExcessResource) (N : ℕ) (ε : ℝ),
      0 < xhat ∧ 0 < ε ∧
      (∀ x ≤ xstar, ∀ l : ℕ → LaborSupportState M,
        (∀ i < N, (l i : ℝ) ≤ M.lmin + ε) →
          solvedLaborBlockTransition M φ hM hφ hU N l x < xhat) ∧
      ∀ x ≤ xhat,
        boundedAiyagariAssetPolicy M φ hM hφ hU x = 0 := by
  rcases exists_positive_lowOffset_uniformly_enters_bindingRegion
      M φ hM hφ hU himp hc0 hDiff xstar with
    ⟨xhat, N, ε, hxhat, hε, hconstant, hbind⟩
  refine ⟨xhat, N, (ε : ℝ), hxhat, by exact_mod_cast hε, ?_, hbind⟩
  intro x hx l hlow
  have hoffset : ∀ i < N, supportedLaborOffset M (l i) ≤ ε := by
    intro i hi
    apply Subtype.coe_le_coe.mp
    change (l i : ℝ) - M.lmin ≤ (ε : ℝ)
    exact sub_le_iff_le_add.mpr (by simpa [add_comm] using hlow i hi)
  exact (lowOffsetBlockTransition_le_constant M φ hM hφ hU
    N (fun i => supportedLaborOffset M (l i)) ε x xstar hx hoffset).trans_lt
      hconstant

/-- Lower-support reachability gives the uniform entrance block strictly
positive probability under the canonical i.i.d. history measure.  Thus the
remaining stationarity work is kernel iteration/bookkeeping, not an assumed
probabilistic recurrence claim. -/
theorem lowIncomeBlock_positive_and_uniformEntrance
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hreach : LaborReachability M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource) :
    ∃ (xhat : ExcessResource) (N : ℕ) (ε : ℝ),
      0 < xhat ∧ 0 < ε ∧
      0 < laborHistoryMeasure M (lowerLaborBlock M 0 N ε) ∧
      (∀ x ≤ xstar, ∀ l : ℕ → LaborSupportState M,
        (∀ i < N, (l i : ℝ) ≤ M.lmin + ε) →
          solvedLaborBlockTransition M φ hM hφ hU N l x < xhat) ∧
      ∀ x ≤ xhat,
        boundedAiyagariAssetPolicy M φ hM hφ hU x = 0 := by
  rcases lowLaborNeighborhoodBlock_uniformly_enters_bindingRegion
      M φ hM hφ hU himp hc0 hDiff xstar with
    ⟨xhat, N, ε, hxhat, hε, huniform, hbind⟩
  exact ⟨xhat, N, ε, hxhat, hε,
    lowerLaborBlock_pos M hM hreach 0 N hε, huniform, hbind⟩

/-- Canonical histories of labor shocks already restricted to their compact
support. -/
abbrev SupportedLaborHistory (M : HouseholdPrimitives) :=
  ℕ → LaborSupportState M

/-- Infinite product of the supported one-period labor probability. -/
def supportedLaborHistoryMeasure
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M) :
    Measure (SupportedLaborHistory M) :=
  Measure.infinitePi (fun _ : ℕ =>
    (laborSupportProbability M hM : Measure (LaborSupportState M)))

instance supportedLaborHistoryMeasure_isProbability
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M) :
    IsProbabilityMeasure (supportedLaborHistoryMeasure M hM) := by
  unfold supportedLaborHistoryMeasure
  infer_instance

/-- First `N` supported labor coordinates lie in a relative lower
neighborhood. -/
def supportedLowerLaborBlock
    (M : HouseholdPrimitives) (N : ℕ) (ε : ℝ) :
    Set (SupportedLaborHistory M) :=
  Set.pi (Finset.range N)
    (fun _ => {l : LaborSupportState M | (l : ℝ) ≤ M.lmin + ε})

theorem measurableSet_supportedLowerLaborBlock
    (M : HouseholdPrimitives) (N : ℕ) (ε : ℝ) :
    MeasurableSet (supportedLowerLaborBlock M N ε) := by
  apply MeasurableSet.pi (Finset.countable_toSet _)
  intro i hi
  exact measurableSet_Iic.preimage measurable_subtype_coe

theorem laborSupportProbability_lowerNeighborhood
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (ε : ℝ) :
    (laborSupportProbability M hM : Measure (LaborSupportState M))
        {l : LaborSupportState M | (l : ℝ) ≤ M.lmin + ε} =
      M.laborLaw (Icc M.lmin (min M.lmax (M.lmin + ε))) := by
  change laborSupportMeasure M
      {l : LaborSupportState M | (l : ℝ) ≤ M.lmin + ε} = _
  rw [laborSupportMeasure, comap_subtype_coe_apply measurableSet_Icc]
  congr 1
  ext z
  simp only [mem_image, mem_setOf_eq, mem_Icc]
  constructor
  · rintro ⟨l, hl, rfl⟩
    exact ⟨l.property.1, le_min l.property.2 hl⟩
  · intro hz
    exact ⟨⟨z, hz.1, hz.2.trans (min_le_left _ _)⟩,
      hz.2.trans (min_le_right _ _), rfl⟩

/-- Every finite relative lower block has positive probability under the
supported product law. -/
theorem supportedLowerLaborBlock_pos
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hreach : LaborReachability M) (N : ℕ) {ε : ℝ} (hε : 0 < ε) :
    0 < supportedLaborHistoryMeasure M hM
      (supportedLowerLaborBlock M N ε) := by
  unfold supportedLaborHistoryMeasure supportedLowerLaborBlock
  rw [Measure.infinitePi_pi]
  · rw [pos_iff_ne_zero]
    apply (Finset.prod_ne_zero_iff).2
    intro i hi
    rw [laborSupportProbability_lowerNeighborhood M hM]
    exact ne_of_gt (hreach.lower ε hε)
  · intro i hi
    exact measurableSet_Iic.preimage measurable_subtype_coe

/-- Iteration of the actual absorbing household random map along a supported
labor history. -/
def absorbingSolvedBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    ℕ → BoundedExcessResource xstar → SupportedLaborHistory M →
      BoundedExcessResource xstar
  | 0, x, _ => x
  | N + 1, x, l =>
      absorbingSolvedNext M φ hM hφ hU xstar hDrift
        (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x l)
        (l N)

theorem continuous_absorbingSolvedBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x)
    (N : ℕ) :
    Continuous (fun p : BoundedExcessResource xstar × SupportedLaborHistory M =>
      absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N p.1 p.2) := by
  induction N with
  | zero => simpa [absorbingSolvedBlockTransition] using
      (continuous_fst : Continuous (fun p :
        BoundedExcessResource xstar × SupportedLaborHistory M => p.1))
  | succ N ih =>
      rw [show (fun p : BoundedExcessResource xstar × SupportedLaborHistory M =>
          absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift (N + 1) p.1 p.2) =
        fun p => absorbingSolvedNext M φ hM hφ hU xstar hDrift
          (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N p.1 p.2)
          (p.2 N) by
            funext p
            rfl]
      simpa [Function.comp_def, Function.uncurry] using
        (continuous_absorbingSolvedNext M φ hM hφ hU xstar hDrift).comp
          (ih.prodMk (continuous_apply N |>.comp continuous_snd))

theorem absorbingSolvedBlockTransition_coe
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x)
    (N : ℕ) (x : BoundedExcessResource xstar)
    (l : SupportedLaborHistory M) :
    (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x l).1 =
      solvedLaborBlockTransition M φ hM hφ hU N l x.1 := by
  induction N with
  | zero => rfl
  | succ N ih =>
      change solvedNextExcess M φ hM hφ hU
          (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x l).1
          (l N) = _
      rw [ih]
      rfl

/-- The positive lower-income block followed by one additional shock is a
common-reset event for the actual iterated absorbing transition.  Once every
initial state has entered the binding region, the next asset choice is zero,
so the following resource state depends only on that final shock. -/
theorem exists_oneStepSplitting_absorbingSolvedBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hreach : LaborReachability M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    ∃ (N : ℕ) (ε : ℝ), 0 < ε ∧
      Nonempty (OneStepSplitting (supportedLaborHistoryMeasure M hM)
        (fun x l => absorbingSolvedBlockTransition
          M φ hM hφ hU xstar hDrift (N + 1) x l)) := by
  rcases lowLaborNeighborhoodBlock_uniformly_enters_bindingRegion
      M φ hM hφ hU himp hc0 hDiff xstar with
    ⟨xhat, N, ε, hxhat, hε, huniform, hbind⟩
  let xzero : BoundedExcessResource xstar := ⟨0, le_rfl, bot_le⟩
  let transition := fun x l => absorbingSolvedBlockTransition
    M φ hM hφ hU xstar hDrift (N + 1) x l
  refine ⟨N, ε, hε, ⟨{
    splitSet := supportedLowerLaborBlock M N ε
    measurable_splitSet := measurableSet_supportedLowerLaborBlock M N ε
    splitSet_pos := supportedLowerLaborBlock_pos M hM hreach N hε
    reset := fun l => transition xzero l
    coalesces := ?_ }⟩⟩
  intro x l hl
  have hlow : ∀ i < N, (l i : ℝ) ≤ M.lmin + ε := by
    intro i hi
    exact hl i (Finset.mem_range.mpr hi)
  have hxprev :
      (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x l).1 <
        xhat := by
    rw [absorbingSolvedBlockTransition_coe]
    exact huniform x.1 x.property.2 l hlow
  have h0prev :
      (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N xzero l).1 <
        xhat := by
    rw [absorbingSolvedBlockTransition_coe]
    exact huniform 0 bot_le l hlow
  have hxbind := hbind _ hxprev.le
  have h0bind := hbind _ h0prev.le
  apply Subtype.ext
  change solvedNextExcess M φ hM hφ hU
      (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x l).1
      (l N) =
    solvedNextExcess M φ hM hφ hU
      (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N xzero l).1
      (l N)
  simp [solvedNextExcess, hxbind, h0bind]

/-- The finite chronological block and the countable-history block agree
whenever their first `N` shock coordinates agree. -/
theorem finiteIIDBlockTransition_eq_absorbingSolvedBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x)
    (N : ℕ) (x : BoundedExcessResource xstar)
    (l : Fin N → LaborSupportState M) (h : SupportedLaborHistory M)
    (hagrees : ∀ i : Fin N, h i = l i) :
    finiteIIDBlockTransition
        (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N x l =
      absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x h := by
  induction N generalizing x with
  | zero => rfl
  | succ N ih =>
      rw [finiteIIDBlockTransition_succ_last]
      change absorbingSolvedNext M φ hM hφ hU xstar hDrift
          (finiteIIDBlockTransition
            (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N x
            (fun i => l i.castSucc))
          (l (Fin.last N)) =
        absorbingSolvedNext M φ hM hφ hU xstar hDrift
          (absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x h)
          (h N)
      congr 1
      · exact ih x (fun i => l i.castSucc)
          (fun i => hagrees i.castSucc)
      · simpa using (hagrees (Fin.last N)).symm

/-- In a finite `N+1` shock vector, the first `N` coordinates lie in the
relative lower-support neighborhood; the final coordinate is unrestricted
and supplies the common reset shock. -/
def finiteSupportedLowerLaborBlock
    (M : HouseholdPrimitives) (N : ℕ) (ε : ℝ) :
    Set (Fin (N + 1) → LaborSupportState M) :=
  Set.pi (Finset.univ.erase (Fin.last N))
    (fun _ => {l : LaborSupportState M | (l : ℝ) ≤ M.lmin + ε})

theorem measurableSet_finiteSupportedLowerLaborBlock
    (M : HouseholdPrimitives) (N : ℕ) (ε : ℝ) :
    MeasurableSet (finiteSupportedLowerLaborBlock M N ε) := by
  apply MeasurableSet.pi (Finset.countable_toSet _)
  intro i hi
  exact measurableSet_Iic.preimage measurable_subtype_coe

theorem finiteSupportedLowerLaborBlock_pos
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hreach : LaborReachability M) (N : ℕ) {ε : ℝ} (hε : 0 < ε) :
    0 < finiteIIDBlockMeasure
        (laborSupportProbability M hM : Measure (LaborSupportState M)) (N + 1)
      (finiteSupportedLowerLaborBlock M N ε) := by
  unfold finiteIIDBlockMeasure finiteSupportedLowerLaborBlock
  rw [Measure.pi_pi_finset]
  rw [pos_iff_ne_zero]
  apply (Finset.prod_ne_zero_iff).2
  intro i hi
  rw [laborSupportProbability_lowerNeighborhood M hM]
  exact ne_of_gt (hreach.lower ε hε)

/-- Finite-product version of the actual household common-reset theorem.
This is the splitting object whose kernel is literally identified with a
power of the one-period household kernel by the generic Fubini theorem. -/
theorem exists_oneStepSplitting_finite_absorbingSolvedBlockTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hreach : LaborReachability M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    ∃ (N : ℕ) (ε : ℝ), 0 < ε ∧
      Nonempty (OneStepSplitting
        (finiteIIDBlockMeasure
          (laborSupportProbability M hM : Measure (LaborSupportState M))
          (N + 1))
        (finiteIIDBlockTransition
          (absorbingSolvedNext M φ hM hφ hU xstar hDrift) (N + 1))) := by
  rcases lowLaborNeighborhoodBlock_uniformly_enters_bindingRegion
      M φ hM hφ hU himp hc0 hDiff xstar with
    ⟨xhat, N, ε, hxhat, hε, huniform, hbind⟩
  let lminState : LaborSupportState M :=
    ⟨M.lmin, le_rfl, hM.lmin_lt_lmax.le⟩
  let xzero : BoundedExcessResource xstar := ⟨0, le_rfl, bot_le⟩
  let transition := finiteIIDBlockTransition
    (absorbingSolvedNext M φ hM hφ hU xstar hDrift) (N + 1)
  refine ⟨N, ε, hε, ⟨{
    splitSet := finiteSupportedLowerLaborBlock M N ε
    measurable_splitSet := measurableSet_finiteSupportedLowerLaborBlock M N ε
    splitSet_pos := finiteSupportedLowerLaborBlock_pos M hM hreach N hε
    reset := fun l => transition xzero l
    coalesces := ?_ }⟩⟩
  intro x l hl
  let hist : SupportedLaborHistory M := fun i =>
    if hi : i < N + 1 then l ⟨i, hi⟩ else lminState
  have hagreesPrefix : ∀ i : Fin N, hist i = l i.castSucc := by
    intro i
    rw [show hist i = l ⟨i, i.isLt.trans (Nat.lt_succ_self N)⟩ by
      simp [hist, i.isLt.trans (Nat.lt_succ_self N)]]
    apply congrArg l
    exact Fin.ext rfl
  have hlow : ∀ i < N, (hist i : ℝ) ≤ M.lmin + ε := by
    intro i hi
    have hi' : i < N + 1 := hi.trans (Nat.lt_succ_self N)
    have hmem : (⟨i, hi'⟩ : Fin (N + 1)) ∈
        Finset.univ.erase (Fin.last N) := by
      apply Finset.mem_erase.mpr
      constructor
      · intro heq
        have : i = N := by exact congrArg Fin.val heq
        omega
      · simp
    have := hl ⟨i, hi'⟩ hmem
    dsimp [hist]
    rw [dif_pos hi']
    exact this
  have hxfinite :
      finiteIIDBlockTransition
          (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N x
          (fun i => l i.castSucc) =
        absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N x hist :=
    finiteIIDBlockTransition_eq_absorbingSolvedBlockTransition
      M φ hM hφ hU xstar hDrift N x _ hist hagreesPrefix
  have h0finite :
      finiteIIDBlockTransition
          (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N xzero
          (fun i => l i.castSucc) =
        absorbingSolvedBlockTransition M φ hM hφ hU xstar hDrift N xzero hist :=
    finiteIIDBlockTransition_eq_absorbingSolvedBlockTransition
      M φ hM hφ hU xstar hDrift N xzero _ hist hagreesPrefix
  have hxprev :
      (finiteIIDBlockTransition
          (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N x
          (fun i => l i.castSucc)).1 < xhat := by
    rw [hxfinite, absorbingSolvedBlockTransition_coe]
    exact huniform x.1 x.property.2 hist hlow
  have h0prev :
      (finiteIIDBlockTransition
          (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N xzero
          (fun i => l i.castSucc)).1 < xhat := by
    rw [h0finite, absorbingSolvedBlockTransition_coe]
    exact huniform 0 bot_le hist hlow
  have hxbind := hbind _ hxprev.le
  have h0bind := hbind _ h0prev.le
  dsimp [transition]
  rw [finiteIIDBlockTransition_succ_last,
    finiteIIDBlockTransition_succ_last]
  apply Subtype.ext
  change solvedNextExcess M φ hM hφ hU
      (finiteIIDBlockTransition
        (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N x
        (fun i => l i.castSucc)).1 (l (Fin.last N)) =
    solvedNextExcess M φ hM hφ hU
      (finiteIIDBlockTransition
        (absorbingSolvedNext M φ hM hφ hU xstar hDrift) N xzero
        (fun i => l i.castSucc)).1 (l (Fin.last N))
  simp [solvedNextExcess, hxbind, h0bind]

/-- The solved household kernel satisfies finite-step oscillation mixing.
Unlike the former certificate hypothesis, this conclusion is derived from a
positive-probability block of low labor shocks, the common-reset argument,
and the finite-product Fubini identity identifying the block random map with
an iterate of the one-period Markov operator. -/
theorem absorbingSolvedKernel_finiteStepMixing
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hreach : LaborReachability M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    KernelIterateOscillationMixing
      (absorbingSolvedKernel M φ hM hφ hU xstar hDrift)
      (feller_absorbingSolvedKernel M φ hM hφ hU xstar hDrift) := by
  letI : CompactSpace (BoundedExcessResource xstar) :=
    isCompact_iff_compactSpace.mp isCompact_Icc
  letI : Nonempty (BoundedExcessResource xstar) :=
    ⟨⟨0, le_rfl, bot_le⟩⟩
  rcases exists_oneStepSplitting_finite_absorbingSolvedBlockTransition
      M φ hM hφ hU himp hreach hc0 hDiff xstar hDrift with
    ⟨N, ε, hε, ⟨hsplit⟩⟩
  let μ : Measure (LaborSupportState M) := laborSupportProbability M hM
  let transition := absorbingSolvedNext M φ hM hφ hU xstar hDrift
  have htransition : Continuous transition.uncurry :=
    continuous_absorbingSolvedNext M φ hM hφ hU xstar hDrift
  have hFeller : IIDTransitionFeller μ transition :=
    iidTransitionFeller_of_continuous μ transition htransition
  apply kernelIterateOscillationMixing_of_blockSplitting
    (absorbingSolvedKernel M φ hM hφ hU xstar hDrift)
    (feller_absorbingSolvedKernel M φ hM hφ hU xstar hDrift)
    (N + 1) (Nat.succ_pos N)
    (finiteIIDBlockMeasure μ (N + 1))
    (finiteIIDBlockTransition transition (N + 1))
    (measurable_finiteIIDBlockTransition transition
      htransition.measurable (N + 1))
    (finiteIIDBlockTransition_feller μ transition htransition (N + 1))
    hsplit
  intro f
  simpa [absorbingSolvedKernel, μ, transition] using
    (fellerMarkovOperator_finiteIIDBlock_eq_iterate
      μ transition htransition.measurable htransition hFeller f (N + 1))

/-- Property 7: the solved household kernel has a unique invariant law and
converges to it from every initial law.  Compactness and Feller continuity are
proved above, while finite-step oscillation mixing is derived from lower-tail
labor reachability and the actual household transition. -/
theorem property07_unique_stable_invariant_distribution
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (himp : ImpatientHousehold M)
    (hreach : LaborReachability M)
    (hc0 : 0 < resourceLevel M φ (0 : ExcessResource) -
      boundedAiyagariAssetPolicy M φ hM hφ hU 0)
    (hRRA : EventualRelativeRiskAversionBound M)
    (hClosure : HighResourceConsumptionClosure
      (boundedAiyagariConsumption M φ hM hφ hU))
    (hDiff : ∀ x : ExcessResource, LocalDominatedDerivative
      (laborSupportProbability M hM : Measure (LaborSupportState M))
      (boundedContinuationIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedContinuationDerivativeIntegrand M
        (boundedAiyagariValue M φ hM hφ hU))
      (boundedAiyagariAssetPolicy M φ hM hφ hU x))
    :
    ∃ (xstar : ExcessResource)
      (hDrift : ∀ x l, xstar ≤ x →
        solvedNextExcess M φ hM hφ hU x l ≤ x)
      (μ : ProbabilityMeasure (BoundedExcessResource xstar)),
      markovLawEvolution
          (absorbingSolvedKernel M φ hM hφ hU xstar hDrift) μ = μ ∧
      (∀ ν : ProbabilityMeasure (BoundedExcessResource xstar),
        markovLawEvolution
            (absorbingSolvedKernel M φ hM hφ hU xstar hDrift) ν = ν →
          ν = μ) ∧
      ∀ μ₀ : ProbabilityMeasure (BoundedExcessResource xstar),
        Tendsto (fun n =>
          ((markovLawEvolution
            (absorbingSolvedKernel M φ hM hφ hU xstar hDrift))^[n]) μ₀)
          atTop (𝓝 μ) := by
  rcases property06_bounded_resource_dynamics
    M φ hM hφ hU himp hRRA hClosure hDiff with ⟨xstar, hDrift⟩
  letI : CompactSpace (BoundedExcessResource xstar) :=
    isCompact_iff_compactSpace.mp isCompact_Icc
  letI : Nonempty (BoundedExcessResource xstar) :=
    ⟨⟨0, le_rfl, bot_le⟩⟩
  have hMix := absorbingSolvedKernel_finiteStepMixing
    M φ hM hφ hU himp hreach hc0 hDiff xstar hDrift
  rcases exists_unique_invariant_and_tendsto_of_feller_finiteStepMixing
      (absorbingSolvedKernel M φ hM hφ hU xstar hDrift)
      (feller_absorbingSolvedKernel M φ hM hφ hU xstar hDrift)
      hMix with ⟨μ, hμ, huniq, hconv⟩
  exact ⟨xstar, hDrift, μ, hμ, huniq, hconv⟩

/-! ## Full-state stationary solved households

The compact absorbing-state theorems above are the existence mechanism.  The
following equilibrium-facing record stores the resulting invariant law on the
common full excess-resource space.  This makes mean assets comparable across
borrowing limits without introducing an arbitrary asset-supply function.
-/

/-- A stationary law for the actual solved bounded household kernel. -/
structure SolvedStationaryHousehold
    (M : HouseholdPrimitives) (φ : ℝ) where
  hM : HouseholdAssumptions M
  hφ : BorrowingLimitAdmissible M φ
  hU : BoundedFiniteUtility M
  μ : Measure ExcessResource
  μ_probability : IsProbabilityMeasure μ
  invariant_distribution :
    ProbabilityTheory.Kernel.Invariant
      (solvedResourceKernel M φ hM hφ hU) μ
  net_assets_integrable :
    Integrable
      (fun x => boundedAiyagariAssetPolicy M φ hM hφ hU x - φ) μ

namespace SolvedStationaryHousehold

/-- Mean actual assets, constructed from the optimal policy and invariant law. -/
def meanAssets
    {M : HouseholdPrimitives} {φ : ℝ}
    (S : SolvedStationaryHousehold M φ) : ℝ :=
  ∫ x, boundedAiyagariAssetPolicy M φ S.hM S.hφ S.hU x - φ ∂S.μ

/-- Pointwise uniqueness of the invariant probability law for the solved
full-state kernel.  This is a theorem-level condition, not an assumption field
inside `SolvedStationaryHousehold`. -/
def UniqueInvariantLaw
    {M : HouseholdPrimitives} {φ : ℝ}
    (S : SolvedStationaryHousehold M φ) : Prop :=
  ∀ (ν : Measure ExcessResource), IsProbabilityMeasure ν →
    ProbabilityTheory.Kernel.Invariant
      (solvedResourceKernel M φ S.hM S.hφ S.hU) ν →
      ν = S.μ

/-- Equal effective limits and uniqueness of the invariant law force equality
of the concretely constructed stationary mean assets. -/
theorem meanAssets_eq_of_limit_eq_unique
    {M : HouseholdPrimitives} {φ₁ φ₂ : ℝ}
    (S₁ : SolvedStationaryHousehold M φ₁)
    (S₂ : SolvedStationaryHousehold M φ₂)
    (hφ : φ₁ = φ₂) (hunique : S₂.UniqueInvariantLaw) :
    S₁.meanAssets = S₂.meanAssets := by
  subst φ₂
  have hμ : S₁.μ = S₂.μ :=
    hunique S₁.μ S₁.μ_probability (by
      simpa only using S₁.invariant_distribution)
  unfold meanAssets
  rw [hμ]

end SolvedStationaryHousehold

/-- A complete solved stationary pure-exchange equilibrium indexed by the
model's actual stored statutory borrowing limit. -/
structure FixedLimitStationaryEquilibrium
    (M : HouseholdPrimitives) (b : ℝ) where
  stationary : SolvedStationaryHousehold (M.withBorrowingLimit b)
    (effectiveBorrowingLimit b M.w M.lmin M.r)
  asset_market_clears : stationary.meanAssets = 0

namespace FixedLimitStationaryEquilibrium

theorem b_nonneg
    {M : HouseholdPrimitives} {b : ℝ}
    (E : FixedLimitStationaryEquilibrium M b) : 0 ≤ b := by
  simpa using E.stationary.hM.b_nonneg

/-- Transport a complete stationary equilibrium across stored statutory
limits whose effective limits coincide. -/
noncomputable def transport
    (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (hU : BoundedFiniteUtility M)
    {b₁ b₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (hlimit : effectiveBorrowingLimit b₁ M.w M.lmin M.r =
      effectiveBorrowingLimit b₂ M.w M.lmin M.r)
    (E : FixedLimitStationaryEquilibrium M b₁) :
    FixedLimitStationaryEquilibrium M b₂ := by
  let φ₁ := effectiveBorrowingLimit b₁ M.w M.lmin M.r
  let φ₂ := effectiveBorrowingLimit b₂ M.w M.lmin M.r
  let hφ₁ : BorrowingLimitAdmissible M φ₁ :=
    effectiveBorrowingLimit_admissible M hM b₁
  let hφ₂ : BorrowingLimitAdmissible M φ₂ :=
    effectiveBorrowingLimit_admissible M hM b₂
  have hbehavior := solvedBoundedHousehold_behavior_eq_of_b_and_limit
    M hM hU hb₁ hb₂ hφ₁ hφ₂ hlimit
  have hkernel := solvedResourceKernel_eq_of_b_and_limit
    M hM hU hb₁ hb₂ hφ₁ hφ₂ hlimit
  have hinvariant₁ :
      ProbabilityTheory.Kernel.Invariant
        (solvedResourceKernel (M.withBorrowingLimit b₁) φ₁
          (hM.withBorrowingLimit hb₁) hφ₁.withBorrowingLimit
          (hU.withBorrowingLimit b₁)) E.stationary.μ := by
    simpa [φ₁] using E.stationary.invariant_distribution
  have hinvariant₂ :
      ProbabilityTheory.Kernel.Invariant
        (solvedResourceKernel (M.withBorrowingLimit b₂) φ₂
          (hM.withBorrowingLimit hb₂) hφ₂.withBorrowingLimit
          (hU.withBorrowingLimit b₂)) E.stationary.μ := by
    rw [← hkernel]
    exact hinvariant₁
  have hintegrand :
      (fun x => boundedAiyagariAssetPolicy
          (M.withBorrowingLimit b₁) φ₁
          (hM.withBorrowingLimit hb₁) hφ₁.withBorrowingLimit
          (hU.withBorrowingLimit b₁) x - φ₁) =
        (fun x => boundedAiyagariAssetPolicy
          (M.withBorrowingLimit b₂) φ₂
          (hM.withBorrowingLimit hb₂) hφ₂.withBorrowingLimit
          (hU.withBorrowingLimit b₂) x - φ₂) := by
    funext x
    rw [hbehavior.2.1, hlimit]
  have hintegrable₁ : Integrable
      (fun x => boundedAiyagariAssetPolicy
          (M.withBorrowingLimit b₁) φ₁
          (hM.withBorrowingLimit hb₁) hφ₁.withBorrowingLimit
          (hU.withBorrowingLimit b₁) x - φ₁) E.stationary.μ := by
    simpa [φ₁] using E.stationary.net_assets_integrable
  have hintegrable₂ : Integrable
      (fun x => boundedAiyagariAssetPolicy
          (M.withBorrowingLimit b₂) φ₂
          (hM.withBorrowingLimit hb₂) hφ₂.withBorrowingLimit
          (hU.withBorrowingLimit b₂) x - φ₂) E.stationary.μ := by
    rw [← hintegrand]
    exact hintegrable₁
  let S₂ : SolvedStationaryHousehold (M.withBorrowingLimit b₂) φ₂ :=
    { hM := hM.withBorrowingLimit hb₂
      hφ := hφ₂.withBorrowingLimit
      hU := hU.withBorrowingLimit b₂
      μ := E.stationary.μ
      μ_probability := E.stationary.μ_probability
      invariant_distribution := hinvariant₂
      net_assets_integrable := hintegrable₂ }
  refine { stationary := S₂, asset_market_clears := ?_ }
  unfold SolvedStationaryHousehold.meanAssets
  rw [← hintegrand]
  simpa [φ₁] using E.asset_market_clears

theorem transport_back_transport
    (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (hU : BoundedFiniteUtility M)
    {b₁ b₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (hlimit : effectiveBorrowingLimit b₁ M.w M.lmin M.r =
      effectiveBorrowingLimit b₂ M.w M.lmin M.r)
    (E : FixedLimitStationaryEquilibrium M b₁) :
    transport M hM hU hb₂ hb₁ hlimit.symm
        (transport M hM hU hb₁ hb₂ hlimit E) = E := by
  cases E
  rfl

theorem transport_transport_back
    (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (hU : BoundedFiniteUtility M)
    {b₁ b₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (hlimit : effectiveBorrowingLimit b₁ M.w M.lmin M.r =
      effectiveBorrowingLimit b₂ M.w M.lmin M.r)
    (E : FixedLimitStationaryEquilibrium M b₂) :
    transport M hM hU hb₁ hb₂ hlimit
        (transport M hM hU hb₂ hb₁ hlimit.symm E) = E := by
  cases E
  rfl

noncomputable def equivalence
    (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (hU : BoundedFiniteUtility M)
    {b₁ b₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (hlimit : effectiveBorrowingLimit b₁ M.w M.lmin M.r =
      effectiveBorrowingLimit b₂ M.w M.lmin M.r) :
    FixedLimitStationaryEquilibrium M b₁ ≃
      FixedLimitStationaryEquilibrium M b₂ where
  toFun := transport M hM hU hb₁ hb₂ hlimit
  invFun := transport M hM hU hb₂ hb₁ hlimit.symm
  left_inv := transport_back_transport M hM hU hb₁ hb₂ hlimit
  right_inv := transport_transport_back M hM hU hb₁ hb₂ hlimit

end FixedLimitStationaryEquilibrium

/-- Mean assets in a finite-state approximation with fixed stationary
weights. -/
def finiteStateMeanAssets {n : ℕ}
    (weight : Fin n → ℝ) (φ : ℝ → ℝ)
    (policy : ℝ → Fin n → ℝ) (r : ℝ) : ℝ :=
  ∑ i, weight i * (policy r i - φ r)

lemma finiteStateMeanAssets_continuous
    {n : ℕ} (weight : Fin n → ℝ) (φ : ℝ → ℝ)
    (policy : ℝ → Fin n → ℝ)
    (hφ : Continuous φ) (hpolicy : ∀ i, Continuous (fun r => policy r i)) :
    Continuous (finiteStateMeanAssets weight φ policy) := by
  unfold finiteStateMeanAssets
  fun_prop

/-- A certified one-state aggregation can be continuous and nonmonotone. -/
theorem continuous_nonmonotone_finiteState_supply :
    ∃ (weight : Fin 1 → ℝ) (φ : ℝ → ℝ) (policy : ℝ → Fin 1 → ℝ),
      (∀ i, 0 ≤ weight i) ∧
      (∑ i, weight i) = 1 ∧
      Continuous (finiteStateMeanAssets weight φ policy) ∧
      Nonmonotone (finiteStateMeanAssets weight φ policy) := by
  let weight : Fin 1 → ℝ := fun _ => 1
  let φ : ℝ → ℝ := fun _ => 0
  let policy : ℝ → Fin 1 → ℝ := fun r _ => r ^ 2
  refine ⟨weight, φ, policy, fun _ => by simp [weight], by simp [weight], ?_, ?_⟩
  · apply finiteStateMeanAssets_continuous
    · fun_prop
    · intro i
      fun_prop
  · have hform : finiteStateMeanAssets weight φ policy = fun r => r ^ 2 := by
      funext r
      simp [finiteStateMeanAssets, weight, φ, policy]
    rw [hform]
    constructor
    · intro hmono
      have h := hmono (show (-1 : ℝ) ≤ 0 by norm_num)
      norm_num at h
    · intro hanti
      have h := hanti (show (0 : ℝ) ≤ 1 by norm_num)
      norm_num at h

/-- Property 8: finite-state asset aggregation is continuous when every policy
component and the debt limit are continuous; a normalized one-state witness
shows that continuity alone does not imply monotonicity. -/
theorem property08_continuity_and_possible_nonmonotonicity
    {n : ℕ} (weight : Fin n → ℝ) (φ : ℝ → ℝ)
    (policy : ℝ → Fin n → ℝ)
    (hφ : Continuous φ) (hpolicy : ∀ i, Continuous (fun r => policy r i)) :
    Continuous (finiteStateMeanAssets weight φ policy) ∧
      (∃ (w : Fin 1 → ℝ) (d : ℝ → ℝ) (A : ℝ → Fin 1 → ℝ),
        (∀ i, 0 ≤ w i) ∧ (∑ i, w i) = 1 ∧
        Continuous (finiteStateMeanAssets w d A) ∧
        Nonmonotone (finiteStateMeanAssets w d A)) := by
  exact ⟨finiteStateMeanAssets_continuous weight φ policy hφ hpolicy,
    continuous_nonmonotone_finiteState_supply⟩

lemma reciprocal_gap_diverges (lambda : ℝ) :
    Tendsto (fun r : ℝ => (lambda - r)⁻¹) (𝓝[<] lambda) atTop := by
  have hc : Tendsto (fun _ : ℝ => lambda) (𝓝 lambda) (𝓝 lambda) :=
    tendsto_const_nhds
  have hi : Tendsto (fun r : ℝ => r) (𝓝 lambda) (𝓝 lambda) := tendsto_id
  have hzero : Tendsto (fun r : ℝ => lambda - r) (𝓝[<] lambda) (𝓝 0) := by
    simpa using (hc.sub hi).mono_left
      (show 𝓝[<] lambda ≤ 𝓝 lambda from nhdsWithin_le_nhds)
  have hpos : ∀ᶠ r : ℝ in 𝓝[<] lambda, lambda - r ∈ Ioi 0 := by
    filter_upwards [self_mem_nhdsWithin] with r hr
    exact sub_pos.mpr (by simpa using hr)
  have hright : Tendsto (fun r : ℝ => lambda - r)
      (𝓝[<] lambda) (𝓝[>] 0) := tendsto_nhdsWithin_iff.2 ⟨hzero, hpos⟩
  exact hright.inv_tendsto_nhdsGT_zero

/-- Property 9: a quantitative Euler-equation lower bound by the reciprocal
gap is sufficient for asset supply to explode at the time-preference rate. -/
theorem property09_explosion_at_time_preference_rate
    (Ea : AssetSupply) (lambda : ℝ)
    (hlower : ∀ᶠ r in 𝓝[<] lambda, (lambda - r)⁻¹ ≤ Ea r) :
    DivergesToInfinityFromLeft Ea lambda := by
  unfold DivergesToInfinityFromLeft
  exact tendsto_atTop_mono' (𝓝[<] lambda) hlower (reciprocal_gap_diverges lambda)

/-- Property 10: continuity and a strict precautionary gap at the benchmark
imply dominance throughout a left neighborhood. -/
theorem property10_uncertainty_raises_assets_near_benchmark
    (risky certain : AssetSupply) (lambda : ℝ)
    (hrisky : ContinuousAt risky lambda)
    (hcertain : ContinuousAt certain lambda)
    (hgap : certain lambda < risky lambda) :
    DominatesNear lambda risky certain := by
  have hevent : ∀ᶠ r in 𝓝 lambda, certain r < risky r :=
    hcertain.eventually_lt hrisky hgap
  obtain ⟨lo, hi, ⟨hlo, hhi⟩, hsub⟩ :=
    mem_nhds_iff_exists_Ioo_subset.mp hevent
  refine ⟨lambda - lo, sub_pos.mpr hlo, ?_⟩
  intro r hrleft hrright
  apply hsub
  constructor
  · linarith
  · exact hrright.trans hhi

end

end Aiyagari1994
