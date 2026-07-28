import Lean4Tutorial.i003_replicate_aiyagari.Assumptions

/-!
# Continuous dynamic-programming foundations

This file proves the two analytic estimates that were previously hidden in an
abstract contraction certificate: integration against a probability law does
not enlarge the sup norm, and maximization over a compact action space is
one-Lipschitz.  They are independent of the special Aiyagari formulas and can
therefore be reused by the bounded and weighted Bellman constructions.
-/

open Filter MeasureTheory Set Topology
open scoped ENNReal NNReal ProbabilityTheory Topology

namespace Aiyagari1994

noncomputable section

section CompactContinuousFamily

variable {Param X : Type*} [UniformSpace Param]
  [WeaklyLocallyCompactSpace Param] [UniformSpace X] [CompactSpace X]

/-- A jointly continuous real family on a compact fiber, bundled as a bounded
continuous function.  Compactness supplies boundedness; no numerical bound is
part of the input. -/
def boundedContinuousFamily (f : Param → X → ℝ)
    (hf : Continuous f.uncurry) (p : Param) :
    BoundedContinuousFunction X ℝ :=
  BoundedContinuousFunction.mkOfCompact
    ⟨f p, hf.comp (continuous_const.prodMk continuous_id)⟩

@[simp] theorem boundedContinuousFamily_apply
    (f : Param → X → ℝ) (hf : Continuous f.uncurry)
    (p : Param) (x : X) :
    boundedContinuousFamily f hf p x = f p x := rfl

/-- Heine--Cantor upgrades joint continuity on a compact fiber to continuity
in the uniform norm.  This is the topology required by the parameterized
Banach fixed-point theorem below. -/
theorem continuous_boundedContinuousFamily
    (f : Param → X → ℝ) (hf : Continuous f.uncurry) :
    Continuous (boundedContinuousFamily f hf) := by
  rw [continuous_iff_continuousAt]
  intro p
  rw [ContinuousAt, BoundedContinuousFunction.tendsto_iff_tendstoUniformly]
  exact hf.tendstoUniformly f p

end CompactContinuousFamily

section CompactMaximum

variable {Action : Type*} [TopologicalSpace Action]
  [CompactSpace Action] [Nonempty Action]

/-- The attained maximum of a continuous real function on a nonempty compact
action space. -/
def compactMaximum (f : C(Action, ℝ)) : ℝ := sSup (Set.range f)

private lemma compactMaximum_bddAbove (f : C(Action, ℝ)) :
    BddAbove (Set.range f) := by
  simpa only [Set.image_univ] using
    (isCompact_univ.bddAbove_image f.continuous.continuousOn)

theorem exists_compactMaximum_eq (f : C(Action, ℝ)) :
    ∃ a : Action, compactMaximum f = f a := by
  obtain ⟨a, -, ha⟩ :=
    isCompact_univ.exists_isMaxOn Set.univ_nonempty f.continuous.continuousOn
  refine ⟨a, le_antisymm ?_ ?_⟩
  · apply csSup_le (Set.range_nonempty f)
    rintro y ⟨b, rfl⟩
    exact ha (Set.mem_univ b)
  · exact le_csSup (compactMaximum_bddAbove f) ⟨a, rfl⟩

theorem compactMaximum_le (f : C(Action, ℝ)) (a : Action) :
    f a ≤ compactMaximum f :=
  le_csSup (compactMaximum_bddAbove f) ⟨a, rfl⟩

/-- Taking a maximum cannot magnify a uniform perturbation. -/
theorem abs_compactMaximum_sub_le (f g : C(Action, ℝ)) :
    |compactMaximum f - compactMaximum g| ≤ dist f g := by
  obtain ⟨af, hf⟩ := exists_compactMaximum_eq f
  obtain ⟨ag, hg⟩ := exists_compactMaximum_eq g
  rw [hf, hg, abs_le]
  constructor
  · have hnorm := ContinuousMap.dist_apply_le_dist (f := f) (g := g) ag
    have hpoint : |f ag - g ag| ≤ dist f g := by
      simpa only [Real.dist_eq] using hnorm
    have hmax : f ag ≤ f af := by
      simpa [← hf] using compactMaximum_le f ag
    linarith [neg_le_of_abs_le hpoint]
  · have hnorm := ContinuousMap.dist_apply_le_dist (f := f) (g := g) af
    have hpoint : |f af - g af| ≤ dist f g := by
      simpa only [Real.dist_eq] using hnorm
    have hmax : g af ≤ g ag := by
      simpa [← hg] using compactMaximum_le g af
    linarith [le_of_abs_le hpoint]

theorem compactMaximum_lipschitz :
    LipschitzWith 1 (compactMaximum : C(Action, ℝ) → ℝ) := by
  rw [lipschitzWith_iff_dist_le_mul]
  intro f g
  simpa only [NNReal.coe_one, one_mul, Real.dist_eq] using
    abs_compactMaximum_sub_le f g

theorem continuous_compactMaximum :
    Continuous (compactMaximum : C(Action, ℝ) → ℝ) :=
  compactMaximum_lipschitz.continuous

end CompactMaximum

section ContinuousUniqueArgmax

variable {Param Action : Type*} [MetricSpace Param]
  [MetricSpace Action] [CompactSpace Action] [Nonempty Action]

/-- A maximizer selected from a jointly continuous objective family on a
common compact action space. -/
noncomputable def continuousFamilyArgmax
    (Q : Param → Action → ℝ) (hQ : Continuous Q.uncurry)
    (p : Param) : Action :=
  Classical.choose (exists_compactMaximum_eq
    ⟨Q p, hQ.comp (continuous_const.prodMk continuous_id)⟩)

theorem continuousFamilyArgmax_isMax
    (Q : Param → Action → ℝ) (hQ : Continuous Q.uncurry)
    (p : Param) (a : Action) :
    Q p a ≤ Q p (continuousFamilyArgmax Q hQ p) := by
  let q : C(Action, ℝ) :=
    ⟨Q p, hQ.comp (continuous_const.prodMk continuous_id)⟩
  have hchosen := Classical.choose_spec (exists_compactMaximum_eq q)
  calc
    Q p a = q a := rfl
    _ ≤ compactMaximum q := compactMaximum_le q a
    _ = Q p (continuousFamilyArgmax Q hQ p) := by
      convert hchosen using 1 <;> simp only [q, continuousFamilyArgmax] <;> rfl

/-- Berge's maximum theorem in the single-valued case.  Compactness supplies
subsequential optimizer limits, joint continuity passes optimality to each
limit, and uniqueness identifies every limit with the selected optimizer. -/
theorem continuous_continuousFamilyArgmax
    (Q : Param → Action → ℝ) (hQ : Continuous Q.uncurry)
    (hUnique : ∀ p a b,
      (∀ c, Q p c ≤ Q p a) → (∀ c, Q p c ≤ Q p b) → a = b) :
    Continuous (continuousFamilyArgmax Q hQ) := by
  rw [continuous_iff_seqContinuous]
  intro u p hu
  apply tendsto_of_subseq_tendsto
  intro ns hns
  let aseq : ℕ → Action := fun n =>
    continuousFamilyArgmax Q hQ (u (ns n))
  obtain ⟨astar, ms, hmsMono, hastar⟩ := CompactSpace.tendsto_subseq aseq
  have hms : Tendsto ms atTop atTop := hmsMono.tendsto_atTop
  have hpseq : Tendsto (fun n => u (ns (ms n))) atTop (𝓝 p) :=
    hu.comp (hns.comp hms)
  have hastarMax : ∀ a, Q p a ≤ Q p astar := by
    intro a
    have hpairA : Tendsto (fun n => (u (ns (ms n)), a)) atTop
        (𝓝 (p, a)) := by
      simpa only [nhds_prod_eq] using hpseq.prodMk tendsto_const_nhds
    have hpairStar : Tendsto (fun n =>
        (u (ns (ms n)), aseq (ms n))) atTop (𝓝 (p, astar)) := by
      simpa only [nhds_prod_eq, Function.comp_apply] using hpseq.prodMk hastar
    have hleft := (hQ.tendsto (p, a)).comp hpairA
    have hright := (hQ.tendsto (p, astar)).comp hpairStar
    apply le_of_tendsto_of_tendsto hleft hright
    filter_upwards with n
    exact continuousFamilyArgmax_isMax Q hQ (u (ns (ms n))) a
  have hselectedMax : ∀ a, Q p a ≤
      Q p (continuousFamilyArgmax Q hQ p) :=
    continuousFamilyArgmax_isMax Q hQ p
  have heq : astar = continuousFamilyArgmax Q hQ p :=
    hUnique p astar (continuousFamilyArgmax Q hQ p)
      hastarMax hselectedMax
  refine ⟨ms, ?_⟩
  rw [← heq]
  simpa only [Function.comp_def, aseq] using hastar

end ContinuousUniqueArgmax

section MaximizedObjective

variable {State Action : Type*} [TopologicalSpace State]
  [TopologicalSpace Action] [CompactSpace Action] [Nonempty Action]

/-- Maximize a bounded continuous state-action objective over the fixed compact
action space. -/
def maximizeObjective
    (Q : BoundedContinuousFunction (State × Action) ℝ) :
    BoundedContinuousFunction State ℝ :=
  BoundedContinuousFunction.ofNormedAddCommGroup
    (fun x => compactMaximum (ContinuousMap.curry Q.toContinuousMap x))
    (continuous_compactMaximum.comp
      (ContinuousMap.curry Q.toContinuousMap).continuous)
    ‖Q‖
    (fun x => by
      obtain ⟨a, ha⟩ :=
        exists_compactMaximum_eq (ContinuousMap.curry Q.toContinuousMap x)
      rw [ha, Real.norm_eq_abs]
      change |Q (x, a)| ≤ ‖Q‖
      simpa only [Real.norm_eq_abs] using
        BoundedContinuousFunction.norm_coe_le_norm Q (x, a))

@[simp] theorem maximizeObjective_apply
    (Q : BoundedContinuousFunction (State × Action) ℝ) (x : State) :
    maximizeObjective Q x =
      compactMaximum (ContinuousMap.curry Q.toContinuousMap x) := rfl

/-- Maximization is nonexpansive in the sup norm. -/
theorem maximizeObjective_norm_sub_le
    (Q R : BoundedContinuousFunction (State × Action) ℝ) :
    ‖maximizeObjective Q - maximizeObjective R‖ ≤ ‖Q - R‖ := by
  rw [BoundedContinuousFunction.norm_le (norm_nonneg (Q - R))]
  intro x
  rw [Real.norm_eq_abs]
  calc
    |maximizeObjective Q x - maximizeObjective R x| ≤
        dist (ContinuousMap.curry Q.toContinuousMap x)
          (ContinuousMap.curry R.toContinuousMap x) :=
      abs_compactMaximum_sub_le _ _
    _ ≤ ‖Q - R‖ := by
      rw [ContinuousMap.dist_le (norm_nonneg (Q - R))]
      intro a
      change |Q (x, a) - R (x, a)| ≤ ‖Q - R‖
      have h := BoundedContinuousFunction.norm_coe_le_norm (Q - R) (x, a)
      change |Q (x, a) - R (x, a)| ≤ ‖Q - R‖ at h
      exact h

theorem maximizeObjective_lipschitz :
    LipschitzWith 1
      (maximizeObjective :
        BoundedContinuousFunction (State × Action) ℝ →
          BoundedContinuousFunction State ℝ) := by
  rw [lipschitzWith_iff_dist_le_mul]
  intro Q R
  simpa only [NNReal.coe_one, one_mul, dist_eq_norm] using
    maximizeObjective_norm_sub_le Q R

theorem continuous_maximizeObjective :
    Continuous
      (maximizeObjective :
        BoundedContinuousFunction (State × Action) ℝ →
          BoundedContinuousFunction State ℝ) :=
  maximizeObjective_lipschitz.continuous

end MaximizedObjective

section ProbabilityIntegral

variable {Shock : Type*} [MeasurableSpace Shock]
  {μ : Measure Shock} [IsProbabilityMeasure μ]

/-- Expectation under a probability law is bounded by the uniform norm. -/
theorem abs_integral_le_uniform_bound
    (f : Shock → ℝ) (C : ℝ) (_hf : AEStronglyMeasurable f μ)
    (hC : ∀ᵐ e ∂μ, |f e| ≤ C) :
    |∫ e, f e ∂μ| ≤ C := by
  rw [← Real.norm_eq_abs]
  simpa only [probReal_univ, mul_one] using
    (norm_integral_le_of_norm_le_const
      (μ := μ) (f := f) (C := C) (by
        filter_upwards [hC] with e he
        simpa only [Real.norm_eq_abs] using he))

/-- The expected difference of two bounded continuation values is no larger
than their sup-norm difference. -/
theorem abs_integral_bcf_sub_le
    {State : Type*} [TopologicalSpace State]
    (V W : BoundedContinuousFunction State ℝ) (next : Shock → State)
    (hmeasV : AEStronglyMeasurable (fun e => V (next e)) μ)
    (hmeasW : AEStronglyMeasurable (fun e => W (next e)) μ) :
    |(∫ e, V (next e) ∂μ) - ∫ e, W (next e) ∂μ| ≤ ‖V - W‖ := by
  have hintV : Integrable (fun e => V (next e)) μ :=
    Integrable.of_bound hmeasV ‖V‖ (by
      filter_upwards with e
      exact BoundedContinuousFunction.norm_coe_le_norm V (next e))
  have hintW : Integrable (fun e => W (next e)) μ :=
    Integrable.of_bound hmeasW ‖W‖ (by
      filter_upwards with e
      exact BoundedContinuousFunction.norm_coe_le_norm W (next e))
  rw [← integral_sub hintV hintW]
  apply abs_integral_le_uniform_bound _ ‖V - W‖ (hmeasV.sub hmeasW)
  filter_upwards with e
  simpa [Real.norm_eq_abs] using
    BoundedContinuousFunction.norm_coe_le_norm (V - W) (next e)

end ProbabilityIntegral

section ContinuousExpectation

variable {State Action Shock : Type*}
  [TopologicalSpace State] [PseudoMetricSpace State]
  [TopologicalSpace Action]
  [TopologicalSpace Shock] [MeasurableSpace Shock]
  [OpensMeasurableSpace Shock] [CompactSpace Shock]
  [SecondCountableTopology Shock]
  [FirstCountableTopology (State × Action)]
  [LocallyCompactSpace (State × Action)]
  (μ : Measure Shock) [IsProbabilityMeasure μ]

/-- The Feller continuation operator generated by a continuous transition and
a compactly supported probability law. -/
def expectedContinuationBCF
    (next : C((State × Action) × Shock, State))
    (V : BoundedContinuousFunction State ℝ) :
    BoundedContinuousFunction (State × Action) ℝ :=
  BoundedContinuousFunction.ofNormedAddCommGroup
    (fun p => ∫ e, V (next (p, e)) ∂μ)
    (by
      have hjoint : Continuous (fun q : (State × Action) × Shock =>
          V (next q)) := V.continuous.comp next.continuous
      simpa only [Measure.restrict_univ] using
        (continuous_parametric_integral_of_continuous
          (μ := μ) (f := fun p e => V (next (p, e))) hjoint
          (s := Set.univ) isCompact_univ))
    ‖V‖
    (fun p => by
      simpa only [probReal_univ, mul_one] using
        (norm_integral_le_of_norm_le_const
          (μ := μ) (f := fun e => V (next (p, e))) (C := ‖V‖) (by
            filter_upwards with e
            exact BoundedContinuousFunction.norm_coe_le_norm V (next (p, e)))))

@[simp] theorem expectedContinuationBCF_apply
    (next : C((State × Action) × Shock, State))
    (V : BoundedContinuousFunction State ℝ) (p : State × Action) :
    expectedContinuationBCF μ next V p = ∫ e, V (next (p, e)) ∂μ := rfl

/-- A Markov expectation is nonexpansive in the sup norm; this is proved from
the probability normalization rather than stored as a certificate. -/
theorem expectedContinuationBCF_norm_sub_le
    (next : C((State × Action) × Shock, State))
    (V W : BoundedContinuousFunction State ℝ) :
    ‖expectedContinuationBCF μ next V -
        expectedContinuationBCF μ next W‖ ≤ ‖V - W‖ := by
  rw [BoundedContinuousFunction.norm_le (norm_nonneg (V - W))]
  intro p
  rw [Real.norm_eq_abs]
  change |(∫ e, V (next (p, e)) ∂μ) -
    ∫ e, W (next (p, e)) ∂μ| ≤ ‖V - W‖
  have hnext : Continuous (fun e : Shock => next (p, e)) :=
    next.continuous.comp (continuous_const.prodMk continuous_id)
  exact abs_integral_bcf_sub_le V W (fun e => next (p, e))
    (V.continuous.comp hnext).aestronglyMeasurable
    (W.continuous.comp hnext).aestronglyMeasurable

theorem expectedContinuationBCF_lipschitz
    (next : C((State × Action) × Shock, State)) :
    LipschitzWith 1 (expectedContinuationBCF μ next) := by
  rw [lipschitzWith_iff_dist_le_mul]
  intro V W
  simpa only [NNReal.coe_one, one_mul, dist_eq_norm] using
    expectedContinuationBCF_norm_sub_le μ next V W

theorem continuous_expectedContinuationBCF
    (next : C((State × Action) × Shock, State)) :
    Continuous (expectedContinuationBCF μ next) :=
  (expectedContinuationBCF_lipschitz μ next).continuous

end ContinuousExpectation

section CompactParameterizedExpectation

variable {Param State Action Shock : Type*}
  [MetricSpace Param] [LocallyCompactSpace Param]
  [MetricSpace State] [CompactSpace State]
  [MetricSpace Action] [CompactSpace Action]
  [TopologicalSpace Shock] [MeasurableSpace Shock]
  [OpensMeasurableSpace Shock] [CompactSpace Shock]
  [SecondCountableTopology Shock]
  (μ : Measure Shock) [IsProbabilityMeasure μ]

/-- Bundle a jointly continuous parameterized transition on a common compact
state space.  The common state is essential: it is what makes a change in the
transition uniformly small over all state-action-shock triples. -/
def compactParameterizedTransition
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) (p : Param) :
    C(((State × Action) × Shock), State) :=
  ⟨next p, hnext.comp (continuous_const.prodMk continuous_id)⟩

@[simp] theorem compactParameterizedTransition_apply
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) (p : Param)
    (q : (State × Action) × Shock) :
    compactParameterizedTransition next hnext p q = next p q := rfl

/-- For a fixed bounded continuous value, expected continuation is continuous
in a parameter whose transition varies jointly continuously on a common
compact state space. -/
theorem continuous_compactParameterizedExpectation_fixedValue
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry)
    (V : BoundedContinuousFunction State ℝ) :
    Continuous (fun p => expectedContinuationBCF μ
      (compactParameterizedTransition next hnext p) V) := by
  let f : Param → (State × Action) → ℝ := fun p sa =>
    ∫ e, V (next p (sa, e)) ∂μ
  have hf : Continuous f.uncurry := by
    have hint : Continuous (fun q : (Param × (State × Action)) × Shock =>
        V (next q.1.1 (q.1.2, q.2))) := by
      apply V.continuous.comp
      exact hnext.comp
        ((continuous_fst.comp continuous_fst).prodMk
          ((continuous_snd.comp continuous_fst).prodMk continuous_snd))
    change Continuous (fun q : Param × (State × Action) =>
      ∫ e, V (next q.1 (q.2, e)) ∂μ)
    simpa only [Measure.restrict_univ] using
      (continuous_parametric_integral_of_continuous (μ := μ)
        (f := fun q : Param × (State × Action) => fun e : Shock =>
          V (next q.1 (q.2, e))) hint (s := Set.univ) isCompact_univ)
  have hfamily := continuous_boundedContinuousFamily f hf
  have heq : (fun p => expectedContinuationBCF μ
      (compactParameterizedTransition next hnext p) V) =
      boundedContinuousFamily f hf := by
    funext p
    ext sa
    rfl
  rw [heq]
  exact hfamily

/-- Joint continuity of expected continuation in the transition parameter and
candidate value.  Continuity in the parameter comes from compactness; the
value argument is uniformly one-Lipschitz because the shock law is a
probability measure. -/
theorem continuous_compactParameterizedExpectation
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) :
    Continuous (fun q : Param × BoundedContinuousFunction State ℝ =>
      expectedContinuationBCF μ
        (compactParameterizedTransition next hnext q.1) q.2) := by
  apply continuous_prod_of_continuous_lipschitzWith' _ 1
  · intro p
    exact expectedContinuationBCF_lipschitz μ
      (compactParameterizedTransition next hnext p)
  · intro V
    exact continuous_compactParameterizedExpectation_fixedValue μ next hnext V

end CompactParameterizedExpectation

section ParameterizedContraction

variable {Param X : Type*} [TopologicalSpace Param]
  [MetricSpace X] [Nonempty X] [CompleteSpace X]

/-- The fixed point selected by Banach's theorem for a parameterized family
of maps sharing a contraction coefficient.  Only the maps and their primitive
contraction proofs are inputs; continuity of the selected fixed point is a
theorem below. -/
noncomputable def parameterizedContractionFixedPoint
    {K : ℝ≥0} (T : Param → X → X)
    (hContract : ∀ p, ContractingWith K (T p)) (p : Param) : X :=
  (hContract p).fixedPoint (T p)

theorem parameterizedContractionFixedPoint_isFixedPt
    {K : ℝ≥0} (T : Param → X → X)
    (hContract : ∀ p, ContractingWith K (T p)) (p : Param) :
    Function.IsFixedPt (T p)
      (parameterizedContractionFixedPoint T hContract p) :=
  (hContract p).fixedPoint_isFixedPt

/-- Quantitative perturbation estimate using only the residual of the new map
at the old fixed point.  This local estimate avoids any unjustified uniform
continuity assumption over the generally noncompact function space. -/
theorem dist_parameterizedContractionFixedPoint_le
    {K : ℝ≥0} (T : Param → X → X)
    (hContract : ∀ p, ContractingWith K (T p)) (p q : Param) :
    dist (parameterizedContractionFixedPoint T hContract p)
        (parameterizedContractionFixedPoint T hContract q) ≤
      dist (parameterizedContractionFixedPoint T hContract q)
          (T p (parameterizedContractionFixedPoint T hContract q)) /
        (1 - K) := by
  simpa only [dist_comm] using
    (hContract p).dist_le_of_fixedPoint
      (parameterizedContractionFixedPoint T hContract q)
      (parameterizedContractionFixedPoint_isFixedPt T hContract p)

/-- A jointly continuous, uniformly contracting family has a continuous
fixed-point selection.  This is the parameter-continuity theorem used for
Bellman value functions on complete sup-norm spaces. -/
theorem continuous_parameterizedContractionFixedPoint
    [SequentialSpace Param]
    {K : ℝ≥0} (T : Param → X → X)
    (hContract : ∀ p, ContractingWith K (T p))
    (hT : Continuous T.uncurry) :
    Continuous (parameterizedContractionFixedPoint T hContract) := by
  apply SeqContinuous.continuous
  intro u p hu
  let Vp := parameterizedContractionFixedPoint T hContract p
  have hpair : Tendsto (fun n => (u n, Vp)) atTop (𝓝 (p, Vp)) :=
    hu.prodMk_nhds tendsto_const_nhds
  have hTV : Tendsto (fun n => T (u n) Vp) atTop (𝓝 (T p Vp)) :=
    hT.continuousAt.tendsto.comp hpair
  have hfixed : T p Vp = Vp :=
    parameterizedContractionFixedPoint_isFixedPt T hContract p
  have hresidual : Tendsto (fun n => dist Vp (T (u n) Vp)) atTop (𝓝 0) := by
    simpa only [hfixed, dist_comm] using
      (tendsto_iff_dist_tendsto_zero.mp hTV)
  have hupper : Tendsto
      (fun n => dist Vp (T (u n) Vp) / (1 - (K : ℝ))) atTop (𝓝 0) := by
    simpa using hresidual.div_const (1 - (K : ℝ))
  rw [tendsto_iff_dist_tendsto_zero]
  apply squeeze_zero (fun n => dist_nonneg) (fun n => ?_) hupper
  simpa [Vp, dist_comm] using
    dist_parameterizedContractionFixedPoint_le T hContract (u n) p

end ParameterizedContraction

section DiscountedBellman

variable {State Action Shock : Type*}
  [TopologicalSpace State] [PseudoMetricSpace State]
  [TopologicalSpace Action] [CompactSpace Action] [Nonempty Action]
  [TopologicalSpace Shock] [MeasurableSpace Shock]
  [OpensMeasurableSpace Shock] [CompactSpace Shock]
  [SecondCountableTopology Shock]
  [FirstCountableTopology (State × Action)]
  [LocallyCompactSpace (State × Action)]
  (μ : Measure Shock) [IsProbabilityMeasure μ]

/-- A concrete discounted Bellman map: current reward plus the expectation of
the next value, followed by maximization over the compact action space. -/
def continuousBellmanOperator
    (β : ℝ) (reward : BoundedContinuousFunction (State × Action) ℝ)
    (next : C((State × Action) × Shock, State))
    (V : BoundedContinuousFunction State ℝ) :
    BoundedContinuousFunction State ℝ :=
  maximizeObjective
    (reward + β • expectedContinuationBCF μ next V)

/-- The Bellman contraction estimate, derived directly from the probability
law and compact maximization. -/
theorem continuousBellmanOperator_norm_sub_le
    (β : ℝ) (hβ : 0 ≤ β)
    (reward : BoundedContinuousFunction (State × Action) ℝ)
    (next : C((State × Action) × Shock, State))
    (V W : BoundedContinuousFunction State ℝ) :
    ‖continuousBellmanOperator μ β reward next V -
        continuousBellmanOperator μ β reward next W‖ ≤
      β * ‖V - W‖ := by
  calc
    ‖continuousBellmanOperator μ β reward next V -
        continuousBellmanOperator μ β reward next W‖ ≤
        ‖(reward + β • expectedContinuationBCF μ next V) -
          (reward + β • expectedContinuationBCF μ next W)‖ :=
      maximizeObjective_norm_sub_le _ _
    _ = β * ‖expectedContinuationBCF μ next V -
        expectedContinuationBCF μ next W‖ := by
      rw [show (reward + β • expectedContinuationBCF μ next V) -
          (reward + β • expectedContinuationBCF μ next W) =
          β • (expectedContinuationBCF μ next V -
            expectedContinuationBCF μ next W) by module]
      simp only [norm_smul, Real.norm_of_nonneg hβ]
    _ ≤ β * ‖V - W‖ :=
      mul_le_mul_of_nonneg_left
        (expectedContinuationBCF_norm_sub_le μ next V W) hβ

theorem continuousBellmanOperator_contracting
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : BoundedContinuousFunction (State × Action) ℝ)
    (next : C((State × Action) × Shock, State)) :
    ContractingWith ⟨β, hβ⟩
      (continuousBellmanOperator μ β reward next) := by
  constructor
  · exact hβ1
  · rw [lipschitzWith_iff_dist_le_mul]
    intro V W
    change dist (continuousBellmanOperator μ β reward next V)
      (continuousBellmanOperator μ β reward next W) ≤ β * dist V W
    simpa only [dist_eq_norm] using
      continuousBellmanOperator_norm_sub_le μ β hβ reward next V W

/-- With discount factor and transition fixed, the Bellman operator is jointly
continuous in the current reward function and candidate value function. -/
theorem continuous_continuousBellmanOperator_reward_value
    (β : ℝ)
    (next : C((State × Action) × Shock, State)) :
    Continuous (fun q :
        BoundedContinuousFunction (State × Action) ℝ ×
          BoundedContinuousFunction State ℝ =>
      continuousBellmanOperator μ β q.1 next q.2) := by
  apply continuous_maximizeObjective.comp
  exact continuous_fst.add
    (((continuous_expectedContinuationBCF μ next).comp continuous_snd).const_smul β)

/-- The bounded value function supplied by Banach's fixed-point theorem. -/
def boundedBellmanValue
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : BoundedContinuousFunction (State × Action) ℝ)
    (next : C((State × Action) × Shock, State)) :
    BoundedContinuousFunction State ℝ :=
  (continuousBellmanOperator_contracting μ β hβ hβ1 reward next).fixedPoint
    (continuousBellmanOperator μ β reward next)

theorem boundedBellmanValue_isFixedPoint
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : BoundedContinuousFunction (State × Action) ℝ)
    (next : C((State × Action) × Shock, State)) :
    Function.IsFixedPt (continuousBellmanOperator μ β reward next)
      (boundedBellmanValue μ β hβ hβ1 reward next) :=
  (continuousBellmanOperator_contracting μ β hβ hβ1 reward next).fixedPoint_isFixedPt

theorem boundedBellmanValue_unique
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : BoundedContinuousFunction (State × Action) ℝ)
    (next : C((State × Action) × Shock, State))
    {V : BoundedContinuousFunction State ℝ}
    (hV : Function.IsFixedPt (continuousBellmanOperator μ β reward next) V) :
    V = boundedBellmanValue μ β hβ hβ1 reward next :=
  (continuousBellmanOperator_contracting μ β hβ hβ1 reward next).fixedPoint_unique hV

/-- Continuous dependence of the bounded Bellman value on the current reward
function, with discount factor and transition held fixed.  This is the first
concrete application of the parameterized Banach theorem. -/
theorem continuous_boundedBellmanValue_reward
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (next : C((State × Action) × Shock, State)) :
    Continuous (fun reward : BoundedContinuousFunction (State × Action) ℝ =>
      boundedBellmanValue μ β hβ hβ1 reward next) := by
  let T := fun reward : BoundedContinuousFunction (State × Action) ℝ =>
    continuousBellmanOperator μ β reward next
  let hContract : ∀ reward, ContractingWith ⟨β, hβ⟩ (T reward) :=
    fun reward => continuousBellmanOperator_contracting μ β hβ hβ1 reward next
  have hT : Continuous T.uncurry := by
    change Continuous (fun q :
        BoundedContinuousFunction (State × Action) ℝ ×
          BoundedContinuousFunction State ℝ =>
      continuousBellmanOperator μ β q.1 next q.2)
    exact continuous_continuousBellmanOperator_reward_value μ β next
  have hcontinuous :=
    continuous_parameterizedContractionFixedPoint T hContract hT
  have heq : (fun reward : BoundedContinuousFunction (State × Action) ℝ =>
      boundedBellmanValue μ β hβ hβ1 reward next) =
      parameterizedContractionFixedPoint T hContract := by
    funext reward
    exact (boundedBellmanValue_unique μ β hβ hβ1 reward next
      (parameterizedContractionFixedPoint_isFixedPt T hContract reward)).symm
  rw [heq]
  exact hcontinuous

end DiscountedBellman

section CompactParameterizedBellman

variable {Param State Action Shock : Type*}
  [MetricSpace Param] [LocallyCompactSpace Param]
  [MetricSpace State] [CompactSpace State]
  [MetricSpace Action] [CompactSpace Action] [Nonempty Action]
  [TopologicalSpace Shock] [MeasurableSpace Shock]
  [OpensMeasurableSpace Shock] [CompactSpace Shock]
  [SecondCountableTopology Shock]
  (μ : Measure Shock) [IsProbabilityMeasure μ]

/-- A discounted Bellman family whose state, action, and shock spaces are
common compact spaces across parameters. -/
def compactParameterizedBellmanOperator
    (β : ℝ)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry)
    (p : Param) (V : BoundedContinuousFunction State ℝ) :
    BoundedContinuousFunction State ℝ :=
  continuousBellmanOperator μ β (reward p)
    (compactParameterizedTransition next hnext p) V

/-- Joint continuity of a compact parameterized Bellman family follows from
continuity of primitive rewards and transitions. -/
theorem continuous_compactParameterizedBellmanOperator
    (β : ℝ)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (hreward : Continuous reward)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) :
    Continuous (compactParameterizedBellmanOperator μ β reward next hnext).uncurry := by
  apply continuous_maximizeObjective.comp
  exact (hreward.comp continuous_fst).add
    ((continuous_compactParameterizedExpectation μ next hnext).const_smul β)

/-- The Banach-selected value of the compact parameterized Bellman family. -/
def compactParameterizedBellmanValue
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) (p : Param) :
    BoundedContinuousFunction State ℝ :=
  boundedBellmanValue μ β hβ hβ1 (reward p)
    (compactParameterizedTransition next hnext p)

/-- On a common compact state space, the solved bounded Bellman value is
continuous in every parameter entering the reward and transition jointly
continuously.  No fixed-point continuity certificate is assumed. -/
theorem continuous_compactParameterizedBellmanValue
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (hreward : Continuous reward)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) :
    Continuous (compactParameterizedBellmanValue μ β hβ hβ1
      reward next hnext) := by
  let T := compactParameterizedBellmanOperator μ β reward next hnext
  let hContract : ∀ p, ContractingWith ⟨β, hβ⟩ (T p) := fun p =>
    continuousBellmanOperator_contracting μ β hβ hβ1 (reward p)
      (compactParameterizedTransition next hnext p)
  have hT : Continuous T.uncurry :=
    continuous_compactParameterizedBellmanOperator μ β reward hreward next hnext
  have hcontinuous :=
    continuous_parameterizedContractionFixedPoint T hContract hT
  have heq : compactParameterizedBellmanValue μ β hβ hβ1
      reward next hnext =
      parameterizedContractionFixedPoint T hContract := by
    funext p
    exact (boundedBellmanValue_unique μ β hβ hβ1 (reward p)
      (compactParameterizedTransition next hnext p)
      (parameterizedContractionFixedPoint_isFixedPt T hContract p)).symm
  rw [heq]
  exact hcontinuous

/-- The state-action objective evaluated at the solved compact value. -/
def compactParameterizedSolvedObjective
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) (p : Param) :
    BoundedContinuousFunction (State × Action) ℝ :=
  reward p + β • expectedContinuationBCF μ
    (compactParameterizedTransition next hnext p)
    (compactParameterizedBellmanValue μ β hβ hβ1 reward next hnext p)

theorem continuous_compactParameterizedSolvedObjective
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (hreward : Continuous reward)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) :
    Continuous (compactParameterizedSolvedObjective μ β hβ hβ1
      reward next hnext) := by
  have hvalue := continuous_compactParameterizedBellmanValue μ β hβ hβ1
    reward hreward next hnext
  have hpair : Continuous (fun p => (p,
      compactParameterizedBellmanValue μ β hβ hβ1 reward next hnext p)) :=
    continuous_id.prodMk hvalue
  have hexpect :=
    (continuous_compactParameterizedExpectation μ next hnext).comp hpair
  exact hreward.add (hexpect.const_smul β)

/-- Joint continuity of the solved objective in parameter and state-action. -/
theorem continuous_compactParameterizedSolvedObjective_apply
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (hreward : Continuous reward)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) :
    Continuous (fun q : Param × (State × Action) =>
      compactParameterizedSolvedObjective μ β hβ hβ1
        reward next hnext q.1 q.2) := by
  exact ContinuousEval.continuous_eval.comp
    ((continuous_compactParameterizedSolvedObjective μ β hβ hβ1
      reward hreward next hnext).comp continuous_fst |>.prodMk continuous_snd)

/-- The unique optimal action of the solved compact Bellman family, selected
from the primitive objective. -/
def compactParameterizedSolvedPolicy
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (hreward : Continuous reward)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry) (p : Param) (x : State) : Action :=
  let Q : (Param × State) → Action → ℝ := fun q a =>
    compactParameterizedSolvedObjective μ β hβ hβ1
      reward next hnext q.1 (q.2, a)
  let hQ : Continuous Q.uncurry :=
    (continuous_compactParameterizedSolvedObjective_apply μ β hβ hβ1
      reward hreward next hnext).comp
        ((continuous_fst.comp continuous_fst).prodMk
          ((continuous_snd.comp continuous_fst).prodMk continuous_snd))
  continuousFamilyArgmax Q hQ (p, x)

/-- Parameter continuity of the unique optimal action is a consequence of
the solved value's continuity and Berge's theorem. -/
theorem continuous_compactParameterizedSolvedPolicy
    (β : ℝ) (hβ : 0 ≤ β) (hβ1 : β < 1)
    (reward : Param → BoundedContinuousFunction (State × Action) ℝ)
    (hreward : Continuous reward)
    (next : Param → ((State × Action) × Shock) → State)
    (hnext : Continuous next.uncurry)
    (hUnique : ∀ p x a b,
      (∀ c, compactParameterizedSolvedObjective μ β hβ hβ1
          reward next hnext p (x, c) ≤
        compactParameterizedSolvedObjective μ β hβ hβ1
          reward next hnext p (x, a)) →
      (∀ c, compactParameterizedSolvedObjective μ β hβ hβ1
          reward next hnext p (x, c) ≤
        compactParameterizedSolvedObjective μ β hβ hβ1
          reward next hnext p (x, b)) → a = b) :
    Continuous (fun q : Param × State =>
      compactParameterizedSolvedPolicy μ β hβ hβ1
        reward hreward next hnext q.1 q.2) := by
  let Q : (Param × State) → Action → ℝ := fun q a =>
    compactParameterizedSolvedObjective μ β hβ hβ1
      reward next hnext q.1 (q.2, a)
  have hQ : Continuous Q.uncurry :=
    (continuous_compactParameterizedSolvedObjective_apply μ β hβ hβ1
      reward hreward next hnext).comp
        ((continuous_fst.comp continuous_fst).prodMk
          ((continuous_snd.comp continuous_fst).prodMk continuous_snd))
  have hpolicy := continuous_continuousFamilyArgmax Q hQ (fun q =>
    hUnique q.1 q.2)
  simpa only [compactParameterizedSolvedPolicy, Q] using hpolicy

end CompactParameterizedBellman

/-! ## One-dimensional envelope lemma -/

/-- A two-sided envelope theorem stated in the form used by the household
problem.  Optimality supplies different slope bounds to the left and right of
the state.  If both comparison secants converge to the same marginal payoff,
the value function is differentiable even though differentiability of the
value was not assumed. -/
theorem hasDerivAt_of_twoSided_slope_sandwich
    {V lowerLeft upperLeft lowerRight upperRight : ℝ → ℝ}
    {z marginal : ℝ}
    (hll : Tendsto lowerLeft (𝓝[<] z) (𝓝 marginal))
    (hul : Tendsto upperLeft (𝓝[<] z) (𝓝 marginal))
    (hlr : Tendsto lowerRight (𝓝[>] z) (𝓝 marginal))
    (hur : Tendsto upperRight (𝓝[>] z) (𝓝 marginal))
    (hleft : ∀ᶠ y in 𝓝[<] z,
      lowerLeft y ≤ slope V z y ∧ slope V z y ≤ upperLeft y)
    (hright : ∀ᶠ y in 𝓝[>] z,
      lowerRight y ≤ slope V z y ∧ slope V z y ≤ upperRight y) :
    HasDerivAt V marginal z := by
  rw [hasDerivAt_iff_tendsto_slope_left_right]
  constructor
  · exact tendsto_of_tendsto_of_tendsto_of_le_of_le' hll hul
      (hleft.mono fun _ hy => hy.1) (hleft.mono fun _ hy => hy.2)
  · exact tendsto_of_tendsto_of_tendsto_of_le_of_le' hlr hur
      (hright.mono fun _ hy => hy.1) (hright.mono fun _ hy => hy.2)

/-- A concave-envelope theorem tailored to dynamic programming.  A concave
value function is differentiable at an interior state whenever it has a local
differentiable lower support there.  No differentiability of the optimizer or
continuation value is assumed: concavity produces the two one-sided
derivatives, and the support inequality forces both to equal the derivative
of the support. -/
theorem hasDerivAt_of_concave_local_lowerSupport
    {V support : ℝ → ℝ} {x marginal : ℝ}
    (hV : ConcaveOn ℝ (Ici (0 : ℝ)) V)
    (hx : 0 < x)
    (hsupportDeriv : HasDerivAt support marginal x)
    (htouch : support x = V x)
    (hlower : ∀ᶠ y in 𝓝 x, support y ≤ V y) :
    HasDerivAt V marginal x := by
  have hxint : x ∈ interior (Ici (0 : ℝ)) := by
    simpa [interior_Ici] using hx
  have hVright : DifferentiableWithinAt ℝ V (Ioi x) x := by
    have hn := hV.neg.differentiableWithinAt_Ioi_of_mem_interior hxint
    simpa only [Pi.neg_apply, neg_neg] using hn.neg
  have hVleft : DifferentiableWithinAt ℝ V (Iio x) x := by
    have hn := hV.neg.differentiableWithinAt_Iio_of_mem_interior hxint
    simpa only [Pi.neg_apply, neg_neg] using hn.neg
  let dR := derivWithin V (Ioi x) x
  let dL := derivWithin V (Iio x) x
  have hslopeSupportRight : Tendsto (slope support x) (𝓝[>] x) (𝓝 marginal) :=
    hsupportDeriv.tendsto_slope.mono_left (nhdsGT_le_nhdsNE x)
  have hslopeSupportLeft : Tendsto (slope support x) (𝓝[<] x) (𝓝 marginal) :=
    hsupportDeriv.tendsto_slope.mono_left (nhdsLT_le_nhdsNE x)
  have hslopeVRight : Tendsto (slope V x) (𝓝[>] x) (𝓝 dR) := by
    exact (hasDerivWithinAt_iff_tendsto_slope' self_notMem_Ioi).mp
      hVright.hasDerivWithinAt
  have hslopeVLeft : Tendsto (slope V x) (𝓝[<] x) (𝓝 dL) := by
    exact (hasDerivWithinAt_iff_tendsto_slope' self_notMem_Iio).mp
      hVleft.hasDerivWithinAt
  have hrightOrder : ∀ᶠ y in 𝓝[>] x,
      slope support x y ≤ slope V x y := by
    filter_upwards [hlower.filter_mono nhdsWithin_le_nhds, self_mem_nhdsWithin]
      with y hy hxy
    have hxy' : x < y := by simpa using hxy
    rw [slope_def_field, slope_def_field, htouch]
    exact (div_le_div_iff_of_pos_right (sub_pos.mpr hxy')).2
      (sub_le_sub_right hy (V x))
  have hleftOrder : ∀ᶠ y in 𝓝[<] x,
      slope V x y ≤ slope support x y := by
    filter_upwards [hlower.filter_mono nhdsWithin_le_nhds, self_mem_nhdsWithin]
      with y hy hyx
    have hyx' : y < x := by simpa using hyx
    rw [slope_def_field, slope_def_field, htouch]
    exact div_le_div_of_nonpos_of_le (sub_neg.mpr hyx').le
      (sub_le_sub_right hy (V x))
  have hmR : marginal ≤ dR :=
    le_of_tendsto_of_tendsto hslopeSupportRight hslopeVRight hrightOrder
  have hLm : dL ≤ marginal :=
    le_of_tendsto_of_tendsto hslopeVLeft hslopeSupportLeft hleftOrder
  have hRL : dR ≤ dL := by
    have hneg := hV.neg.leftDeriv_le_rightDeriv_of_mem_interior hxint
    have hnegLeft : derivWithin (-V) (Iio x) x = -dL := by
      dsimp [dL]
      exact derivWithin.neg
    have hnegRight : derivWithin (-V) (Ioi x) x = -dR := by
      dsimp [dR]
      exact derivWithin.neg
    rw [hnegLeft, hnegRight] at hneg
    linarith
  have hReq : dR = marginal := le_antisymm (hRL.trans hLm) hmR
  have hLeq : dL = marginal := le_antisymm hLm (hmR.trans hRL)
  rw [hasDerivAt_iff_tendsto_slope_left_right]
  exact ⟨by simpa [hLeq] using hslopeVLeft,
    by simpa [hReq] using hslopeVRight⟩

/-- A right-feasible first-order condition.  If a differentiable objective
cannot rise at points immediately to the right, its derivative is nonpositive.
This is the boundary case needed for the Euler inequality at a binding
borrowing constraint. -/
theorem HasDerivAt.nonpos_of_eventually_right_max
    {f : ℝ → ℝ} {x d : ℝ} (hderiv : HasDerivAt f d x)
    (hmax : ∀ᶠ y in 𝓝[>] x, f y ≤ f x) : d ≤ 0 := by
  have hslope : Tendsto (slope f x) (𝓝[>] x) (𝓝 d) :=
    hderiv.tendsto_slope.mono_left (nhdsGT_le_nhdsNE x)
  apply le_of_tendsto hslope
  filter_upwards [hmax, self_mem_nhdsWithin] with y hy hxy
  have hxy' : x < y := by simpa using hxy
  rw [slope_def_field]
  exact div_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr hy)
    (sub_nonneg.mpr hxy'.le)

end

end Aiyagari1994
