import Lean4Tutorial.i003_replicate_aiyagari.Definitions

/-!
# Aiyagari (1994): primitive and local analytic assumptions

These records contain conditions on primitives.  They deliberately do not
contain any numbered property or any conclusion such as existence, uniqueness,
stationarity, or a comparative-static ordering.
-/

open Filter MeasureTheory Set Topology
open scoped ENNReal ProbabilityTheory Topology

namespace Aiyagari1994

/-- Sign and support conditions for the household problem. -/
structure HouseholdAssumptions (M : HouseholdPrimitives) : Prop where
  β_pos : 0 < M.β
  β_lt_one : M.β < 1
  r_pos : 0 < M.r
  w_pos : 0 < M.w
  b_nonneg : 0 ≤ M.b
  lmin_pos : 0 < M.lmin
  lmin_lt_lmax : M.lmin < M.lmax
  labor_probability : IsProbabilityMeasure M.laborLaw
  labor_support : M.laborLaw (Icc M.lmin M.lmax) = 1

namespace HouseholdAssumptions

/-- Primitive household assumptions survive a change in the statutory limit
provided the new limit is nonnegative. -/
theorem withBorrowingLimit
    {M : HouseholdPrimitives} (hM : HouseholdAssumptions M)
    {b : ℝ} (hb : 0 ≤ b) :
    HouseholdAssumptions (M.withBorrowingLimit b) where
  β_pos := hM.β_pos
  β_lt_one := hM.β_lt_one
  r_pos := hM.r_pos
  w_pos := hM.w_pos
  b_nonneg := hb
  lmin_pos := hM.lmin_pos
  lmin_lt_lmax := hM.lmin_lt_lmax
  labor_probability := hM.labor_probability
  labor_support := hM.labor_support

end HouseholdAssumptions

/-- The endpoints are in the topological support of the labor law.  These are
the primitive reachability conditions used by the full i.i.d. no-Ponzi proof
and by the mixing argument for the resource kernel. -/
structure LaborReachability (M : HouseholdPrimitives) : Prop where
  lower : ∀ ε : ℝ, 0 < ε →
    0 < M.laborLaw (Icc M.lmin (min M.lmax (M.lmin + ε)))
  upper : ∀ ε : ℝ, 0 < ε →
    0 < M.laborLaw (Icc (max M.lmin (M.lmax - ε)) M.lmax)

/-- A shifted borrowing limit is admissible when minimum resources remain
nonnegative.  This is a local restriction on a parameter, not a conclusion
about an optimal policy. -/
structure BorrowingLimitAdmissible
    (M : HouseholdPrimitives) (φ : ℝ) : Prop where
  minimumResources_nonneg :
    0 ≤ minimumResources M.w M.lmin M.r φ

namespace BorrowingLimitAdmissible

/-- Admissibility depends on prices, labor support, and the effective limit,
not on the primitive record's bookkeeping `b` field. -/
theorem withBorrowingLimit
    {M : HouseholdPrimitives} {φ b : ℝ}
    (hφ : BorrowingLimitAdmissible M φ) :
    BorrowingLimitAdmissible (M.withBorrowingLimit b) φ := by
  refine ⟨?_⟩
  exact hφ.minimumResources_nonneg

end BorrowingLimitAdmissible

/-- The impatience restriction used by the Euler, cutoff, and drift arguments.
It is deliberately separate from the basic sign assumptions because Property 1
does not require impatience. -/
structure ImpatientHousehold (M : HouseholdPrimitives) : Prop where
  discountedReturn_lt_one : M.β * (1 + M.r) < 1

/-- A local domination package for differentiating a parameterized
expectation.  This is an analytic closure condition only: it records
measurability, integrability, a common neighborhood, a dominating function,
and pointwise derivatives.  It does not assume the derivative of the
expectation or any Euler equation. -/
structure LocalDominatedDerivative
    {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (F F' : ℝ → α → ℝ) (x₀ : ℝ) where
  neighborhood : Set ℝ
  neighborhood_mem : neighborhood ∈ 𝓝 x₀
  integrand_measurable : ∀ᶠ x in 𝓝 x₀, AEStronglyMeasurable (F x) μ
  integrand_integrable : Integrable (F x₀) μ
  derivative_measurable : AEStronglyMeasurable (F' x₀) μ
  bound : α → ℝ
  derivative_bound : ∀ᵐ a ∂μ, ∀ x ∈ neighborhood, ‖F' x a‖ ≤ bound a
  bound_integrable : Integrable bound μ
  pointwise_derivative : ∀ᵐ a ∂μ, ∀ x ∈ neighborhood,
    HasDerivAt (F · a) (F' x a) x

theorem LocalDominatedDerivative.hasDerivAt_integral
    {α : Type*} [MeasurableSpace α]
    {μ : Measure α} {F F' : ℝ → α → ℝ} {x₀ : ℝ}
    (h : LocalDominatedDerivative μ F F' x₀) :
    Integrable (F' x₀) μ ∧
      HasDerivAt (fun x => ∫ a, F x a ∂μ) (∫ a, F' x₀ a ∂μ) x₀ := by
  exact hasDerivAt_integral_of_dominated_loc_of_deriv_le
    h.neighborhood_mem h.integrand_measurable h.integrand_integrable
    h.derivative_measurable h.derivative_bound h.bound_integrable
    h.pointwise_derivative

/-- Smooth, increasing, strictly concave utility on positive consumption. -/
structure UtilityAssumptions (M : HouseholdPrimitives) : Prop where
  continuousOn : ContinuousOn M.utility (Ici 0)
  strictMonoOn : StrictMonoOn M.utility (Ici 0)
  strictConcaveOn : StrictConcaveOn ℝ (Ici 0) M.utility
  differentiableOn : DifferentiableOn ℝ M.utility (Ioi 0)
  marginal_pos : ∀ c, 0 < c → 0 < deriv M.utility c

/-- Finite-at-zero branch used by the cutoff result. -/
structure FiniteAtZeroUtility (M : HouseholdPrimitives) : Prop where
  continuousAt_zero : ContinuousAt M.utility 0
  finite_marginalAtZero : ∃ m : ℝ,
    HasDerivWithinAt M.utility m (Ici 0) 0

/-- The bounded finite-at-zero regime used for the ordinary sup-norm Bellman
construction.  Boundedness is the sufficient condition stated in Aiyagari's
working-paper formulation. -/
structure BoundedFiniteUtility (M : HouseholdPrimitives) : Prop
    extends UtilityAssumptions M, FiniteAtZeroUtility M where
  twice_smooth : ContDiffOn ℝ 2 M.utility (Ioi 0)
  lower_bound : ∃ umin : ℝ, ∀ c, 0 ≤ c → umin ≤ M.utility c
  upper_bound : ∃ umax : ℝ, ∀ c, 0 ≤ c → M.utility c ≤ umax
  second_deriv_neg : ∀ c, 0 < c → deriv (deriv M.utility) c < 0

namespace BoundedFiniteUtility

/-- Utility assumptions are unchanged when only the statutory borrowing-limit
field changes. -/
theorem withBorrowingLimit
    {M : HouseholdPrimitives} (hU : BoundedFiniteUtility M) (b : ℝ) :
    BoundedFiniteUtility (M.withBorrowingLimit b) where
  continuousOn := hU.continuousOn
  strictMonoOn := hU.strictMonoOn
  strictConcaveOn := hU.strictConcaveOn
  differentiableOn := hU.differentiableOn
  marginal_pos := hU.marginal_pos
  continuousAt_zero := hU.continuousAt_zero
  finite_marginalAtZero := hU.finite_marginalAtZero
  twice_smooth := hU.twice_smooth
  lower_bound := hU.lower_bound
  upper_bound := hU.upper_bound
  second_deriv_neg := hU.second_deriv_neg

end BoundedFiniteUtility

/-- Convex marginal utility, the curvature condition used by the
mean-preserving-spread comparison. -/
structure ConvexMarginalUtility (M : HouseholdPrimitives) : Prop where
  marginal_convex : ConvexOn ℝ (Ioi 0) (deriv M.utility)

/-- Eventual upper bound on relative risk aversion. -/
structure EventualRelativeRiskAversionBound
    (M : HouseholdPrimitives) where
  bound : ℝ
  threshold : ℝ
  bound_nonneg : 0 ≤ bound
  threshold_pos : 0 < threshold
  marginal_pos : ∀ c, 0 < c → 0 < deriv M.utility c
  marginal_differentiable :
    DifferentiableOn ℝ (deriv M.utility) (Ioi threshold)
  relativeRiskAversion_le : ∀ c, threshold ≤ c →
    -(c * deriv (deriv M.utility) c) / deriv M.utility c ≤ bound

/-- The integrated form of the eventual relative-risk-aversion bound.  Above
the threshold, a marginal-utility ratio is bounded by the corresponding
consumption ratio raised to the RRA bound.  This is the analytic inequality
used in Aiyagari's Proposition 4. -/
theorem EventualRelativeRiskAversionBound.marginal_ratio_le_rpow
    {M : HouseholdPrimitives}
    (hU : BoundedFiniteUtility M)
    (h : EventualRelativeRiskAversionBound M)
    {a b : ℝ} (ha : h.threshold ≤ a) (hab : a ≤ b) :
    deriv M.utility a / deriv M.utility b ≤ (b / a) ^ h.bound := by
  have ha0 : 0 < a := h.threshold_pos.trans_le ha
  have hb0 : 0 < b := ha0.trans_le hab
  let f : ℝ → ℝ := fun c =>
    Real.log (deriv M.utility c) + h.bound * Real.log c
  have hmcont : ContinuousOn (deriv M.utility) (Icc a b) := by
    apply (hU.twice_smooth.continuousOn_deriv_of_isOpen isOpen_Ioi (by norm_num)).mono
    intro c hc
    exact h.threshold_pos.trans_le (ha.trans hc.1)
  have hfcont : ContinuousOn f (Icc a b) := by
    apply ContinuousOn.add
    · exact hmcont.log (fun c hc => ne_of_gt (h.marginal_pos c
        (h.threshold_pos.trans_le (ha.trans hc.1))))
    · exact continuousOn_id.log (fun c hc => ne_of_gt
        (h.threshold_pos.trans_le (ha.trans hc.1))) |>.const_mul h.bound
  have hfdiff : DifferentiableOn ℝ f (interior (Icc a b)) := by
    rw [interior_Icc]
    apply DifferentiableOn.add
    · apply (h.marginal_differentiable.mono ?_).log
      · intro c hc
        exact ne_of_gt (h.marginal_pos c
          (h.threshold_pos.trans (ha.trans_lt hc.1)))
      · intro c hc
        exact ha.trans_lt hc.1
    · apply (differentiableOn_id.log ?_).const_mul
      intro c hc
      exact ne_of_gt (h.threshold_pos.trans (ha.trans_lt hc.1))
  have hfderiv : ∀ c ∈ interior (Icc a b), 0 ≤ deriv f c := by
    intro c hc
    rw [interior_Icc] at hc
    have hc_threshold : h.threshold ≤ c := ha.trans hc.1.le
    have hc0 : 0 < c := h.threshold_pos.trans_le hc_threshold
    have hm0 : 0 < deriv M.utility c := h.marginal_pos c hc0
    have hmDiffAt : DifferentiableAt ℝ (deriv M.utility) c :=
      (h.marginal_differentiable c (ha.trans_lt hc.1)).differentiableAt
        (Ioi_mem_nhds (ha.trans_lt hc.1))
    have hmhas := hmDiffAt.hasDerivAt
    have hfhas : HasDerivAt f
        (deriv (deriv M.utility) c / deriv M.utility c + h.bound / c) c := by
      change HasDerivAt
        ((fun y => Real.log (deriv M.utility y)) +
          (fun y => h.bound * Real.log y))
        (deriv (deriv M.utility) c / deriv M.utility c + h.bound / c) c
      simpa only [div_eq_mul_inv] using
        (hmhas.log (ne_of_gt hm0)).add
          ((Real.hasDerivAt_log (ne_of_gt hc0)).const_mul h.bound)
    rw [hfhas.deriv]
    have hrra := (div_le_iff₀ hm0).mp
      (h.relativeRiskAversion_le c hc_threshold)
    have hnum : 0 ≤ c * deriv (deriv M.utility) c +
        h.bound * deriv M.utility c := by
      linarith
    rw [show deriv (deriv M.utility) c / deriv M.utility c + h.bound / c =
        (c * deriv (deriv M.utility) c +
          h.bound * deriv M.utility c) /
            (c * deriv M.utility c) by field_simp]
    exact div_nonneg hnum (mul_pos hc0 hm0).le
  have hfmono : MonotoneOn f (Icc a b) :=
    monotoneOn_of_deriv_nonneg (convex_Icc a b) hfcont hfdiff hfderiv
  have hfab : f a ≤ f b := hfmono ⟨le_rfl, hab⟩ ⟨hab, le_rfl⟩ hab
  have hma : 0 < deriv M.utility a := h.marginal_pos a ha0
  have hmb : 0 < deriv M.utility b := h.marginal_pos b hb0
  have hratio : 0 < b / a := div_pos hb0 ha0
  rw [Real.rpow_def_of_pos hratio]
  rw [← Real.exp_log (div_pos hma hmb)]
  rw [Real.exp_le_exp]
  rw [Real.log_div (ne_of_gt hma) (ne_of_gt hmb)]
  rw [Real.log_div (ne_of_gt hb0) (ne_of_gt ha0)]
  dsimp [f] at hfab
  linarith

/-- With a fixed nonnegative consumption gap, the marginal-utility ratio
converges to one at high consumption.  This is the limiting step in the
bounded-resource proof; unlike a policy drift bound, it follows directly from
eventual bounded relative risk aversion. -/
theorem EventualRelativeRiskAversionBound.tendsto_marginal_ratio_add_const
    {M : HouseholdPrimitives}
    (hU : BoundedFiniteUtility M)
    (h : EventualRelativeRiskAversionBound M)
    {d : ℝ} (hd : 0 ≤ d) :
    Tendsto (fun c => deriv M.utility c / deriv M.utility (c + d))
      atTop (𝓝 1) := by
  have huDiffAt : ∀ c ∈ Ioi (0 : ℝ), DifferentiableAt ℝ M.utility c := by
    intro c hc
    exact (hU.differentiableOn c hc).differentiableAt (Ioi_mem_nhds hc)
  have hmarginalAnti : AntitoneOn (deriv M.utility) (Ioi (0 : ℝ)) :=
    (hU.strictConcaveOn.concaveOn.subset Ioi_subset_Ici_self
      (convex_Ioi (0 : ℝ))).antitoneOn_deriv huDiffAt
  have hgapZero : Tendsto (fun c : ℝ => d / c) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop tendsto_id
  have hbase : Tendsto (fun c : ℝ => 1 + d / c) atTop (𝓝 1) := by
    simpa using tendsto_const_nhds.add hgapZero
  have hupperTendsto : Tendsto (fun c : ℝ => (1 + d / c) ^ h.bound)
      atTop (𝓝 1) := by
    have hp := hbase.rpow_const (p := h.bound) (Or.inl one_ne_zero)
    simpa using hp
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le'
    tendsto_const_nhds hupperTendsto ?_ ?_
  · filter_upwards [eventually_ge_atTop h.threshold] with c hc
    have hc0 : 0 < c := h.threshold_pos.trans_le hc
    have hcd0 : 0 < c + d := add_pos_of_pos_of_nonneg hc0 hd
    have hmmono : deriv M.utility (c + d) ≤ deriv M.utility c :=
      hmarginalAnti hc0 hcd0 (le_add_of_nonneg_right hd)
    exact (le_div_iff₀ (h.marginal_pos (c + d) hcd0)).mpr (by simpa using hmmono)
  · filter_upwards [eventually_ge_atTop h.threshold] with c hc
    have hratio := h.marginal_ratio_le_rpow hU hc (le_add_of_nonneg_right hd)
    have hc0 : c ≠ 0 := ne_of_gt (h.threshold_pos.trans_le hc)
    rwa [show (c + d) / c = 1 + d / c by field_simp] at hratio

/-- **Labeled global-policy closure for Proposition 4.**  Solved optimal
consumption diverges when excess resources diverge.  Aiyagari's paper obtains
this from boundedness and concavity of the value function together with the
Euler/envelope system.  The present formalization isolates exactly that still
missing global analytic passage: this record contains no drift bound, policy
slope, absorbing set, invariant law, or numbered-property conclusion. -/
structure HighResourceConsumptionClosure
    (consumption : ExcessResource → ℝ) : Prop where
  consumption_tendsto_atTop : Tendsto consumption atTop atTop

/-- Inada branch, stated as a right-hand derivative limit. -/
structure InadaUtility (M : HouseholdPrimitives) : Prop where
  marginal_tendsto : Tendsto (fun c => deriv M.utility c) (𝓝[>] 0) atTop

/-- Primitive assumptions for utility defined only at positive consumption.
The growth estimate is what makes the weighted Bellman distance finite. -/
structure PositiveInadaUtility
    (M : PositiveHouseholdPrimitives) where
  β_pos : 0 < M.β
  β_lt_one : M.β < 1
  r_pos : 0 < M.r
  w_pos : 0 < M.w
  lmin_nonneg : 0 ≤ M.lmin
  lmin_lt_lmax : M.lmin < M.lmax
  labor_probability : IsProbabilityMeasure M.laborLaw
  labor_support : M.laborLaw (Icc M.lmin M.lmax) = 1
  continuousOn :
    ContinuousOn M.utility.onPositive (Ioi 0)
  strictMonoOn :
    StrictMonoOn M.utility.onPositive (Ioi 0)
  strictConcaveOn :
    StrictConcaveOn ℝ (Ioi 0) M.utility.onPositive
  twice_smooth :
    ContDiffOn ℝ 2 M.utility.onPositive (Ioi 0)
  marginal_pos : ∀ c, 0 < c →
    0 < deriv M.utility.onPositive c
  marginal_tendsto :
    Tendsto (fun c => deriv M.utility.onPositive c) (𝓝[>] 0) atTop
  weightExponent : ℝ
  weightExponent_nonneg : 0 ≤ weightExponent
  growthConstant : ℝ
  growthConstant_nonneg : 0 ≤ growthConstant
  utility_growth : ∀ c, 0 < c →
    |M.utility.onPositive c| ≤
      growthConstant * (1 + c ^ weightExponent)

/-- Neoclassical sign and technology assumptions. -/
structure TechnologyAssumptions (P : Primitives) : Prop where
  β_pos : 0 < P.β
  β_lt_one : P.β < 1
  δ_nonneg : 0 ≤ P.δ
  lmin_pos : 0 < P.lmin
  capitalDemand_strictAnti : StrictAnti P.capitalDemand
  production_pos : ∀ k, 0 < k → 0 < P.production k

/-- A quantitative drift condition.  Unlike the old source-theorem argument,
this is a pointwise inequality on the actual transition. -/
structure ResourceDriftAssumptions
    (transition : ℝ → ℝ → ℝ) (zstar lmin lmax : ℝ) : Prop where
  shock_order : lmin ≤ lmax
  drift : ∀ z l, zstar ≤ z → l ∈ Icc lmin lmax → transition z l ≤ z

end Aiyagari1994
