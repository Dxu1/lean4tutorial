import Lean4Tutorial.i003_replicate_aiyagari.AiyagariBellman
import Mathlib.Probability.Kernel.Composition.IntegralCompProd
import Mathlib.Probability.Kernel.Composition.MeasureComp

/-!
# Continuous-transition Feller and mixing foundations

This file isolates the reusable analytic notions needed for stationary laws.
In particular, Feller continuity and stochastic monotonicity are properties of
the transition itself.  The splitting condition is a genuine common-shock
coalescence condition; it does not contain an invariant measure or a
convergence conclusion.
-/

open Filter MeasureTheory ProbabilityTheory Set Topology
open scoped ENNReal ProbabilityTheory Topology

namespace Aiyagari1994

noncomputable section

/-- Feller property written for an i.i.d. random-map representation. -/
def IIDTransitionFeller
    {State Shock : Type*} [TopologicalSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) (transition : State → Shock → State) : Prop :=
  ∀ f : BoundedContinuousFunction State ℝ,
    Continuous (fun x => ∫ l, f (transition x l) ∂μ)

/-- Markov kernel induced by an i.i.d. shock law and a jointly measurable
random transition. -/
noncomputable def iidTransitionKernel
    {State Shock : Type*} [MeasurableSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry) : Kernel State State :=
  Kernel.mapOfMeasurable
    ((Kernel.id : Kernel State State) ×ₖ Kernel.const State μ)
    transition.uncurry htransition

instance iidTransitionKernel_isMarkov
    {State Shock : Type*} [MeasurableSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry) :
    IsMarkovKernel (iidTransitionKernel μ transition htransition) := by
  unfold iidTransitionKernel
  rw [Kernel.mapOfMeasurable_eq_map]
  exact Kernel.IsMarkovKernel.map _ htransition

theorem iidTransitionKernel_apply
    {State Shock : Type*} [MeasurableSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry) (x : State) :
    iidTransitionKernel μ transition htransition x =
      μ.map (transition x) := by
  ext s hs
  rw [iidTransitionKernel, Kernel.mapOfMeasurable_eq_map,
    Kernel.map_apply' _ htransition x hs,
    Kernel.id_prod_apply' _ x (hs.preimage htransition),
    Kernel.const_apply]
  have hxmeas : Measurable (transition x) :=
    htransition.comp measurable_prodMk_left
  rw [Measure.map_apply hxmeas hs]
  rfl

theorem integral_iidTransitionKernel
    {State Shock : Type*}
    [TopologicalSpace State] [MeasurableSpace State]
    [OpensMeasurableSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry) (x : State)
    (f : BoundedContinuousFunction State ℝ) :
    (∫ y, f y ∂iidTransitionKernel μ transition htransition x) =
      ∫ l, f (transition x l) ∂μ := by
  rw [iidTransitionKernel_apply]
  exact integral_map_of_stronglyMeasurable
    (htransition.comp measurable_prodMk_left) f.continuous.stronglyMeasurable

/-- Feller property for a Markov kernel, stated in the test-function form
needed by weak convergence of probability measures. -/
def KernelFeller
    {State : Type*} [TopologicalSpace State] [MeasurableSpace State]
    (κ : Kernel State State) : Prop :=
  ∀ f : BoundedContinuousFunction State ℝ,
    Continuous (fun x => ∫ y, f y ∂κ x)

/-- The test-function Feller property of an i.i.d. random transition is
exactly the Feller property of its induced Markov kernel. -/
theorem kernelFeller_iidTransitionKernel
    {State Shock : Type*}
    [TopologicalSpace State] [MeasurableSpace State]
    [OpensMeasurableSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry)
    (hFeller : IIDTransitionFeller μ transition) :
    KernelFeller (iidTransitionKernel μ transition htransition) := by
  intro f
  simpa only [integral_iidTransitionKernel] using hFeller f

/-- The Markov operator on bounded continuous test functions associated with
a Feller kernel on a compact state space. -/
def fellerMarkovOperator
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) (hκ : KernelFeller κ)
    (f : BoundedContinuousFunction State ℝ) :
    BoundedContinuousFunction State ℝ :=
  BoundedContinuousFunction.mkOfCompact
    ⟨fun x => ∫ y, f y ∂κ x, hκ f⟩

@[simp] theorem fellerMarkovOperator_apply
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) (hκ : KernelFeller κ)
    (f : BoundedContinuousFunction State ℝ) (x : State) :
    fellerMarkovOperator κ hκ f x = ∫ y, f y ∂κ x := rfl

/-- Oscillation seminorm `sup_{x,y}|f(x)-f(y)|`, represented as the ordinary
sup norm of the difference function on the product state space. -/
def bcfOscillation
    {State : Type*} [TopologicalSpace State]
    (f : BoundedContinuousFunction State ℝ) : ℝ :=
  ‖f.compContinuous ⟨Prod.fst, continuous_fst⟩ -
      f.compContinuous ⟨Prod.snd, continuous_snd⟩‖

theorem abs_sub_le_bcfOscillation
    {State : Type*} [TopologicalSpace State]
    (f : BoundedContinuousFunction State ℝ) (x y : State) :
    |f x - f y| ≤ bcfOscillation f := by
  simpa [bcfOscillation, Real.norm_eq_abs] using
    (f.compContinuous ⟨Prod.fst, continuous_fst⟩ -
      f.compContinuous ⟨Prod.snd, continuous_snd⟩).norm_coe_le_norm (x, y)

theorem bcfOscillation_nonneg
    {State : Type*} [TopologicalSpace State]
    (f : BoundedContinuousFunction State ℝ) :
    0 ≤ bcfOscillation f := norm_nonneg _

theorem bcfOscillation_le_two_norm
    {State : Type*} [TopologicalSpace State]
    (f : BoundedContinuousFunction State ℝ) :
    bcfOscillation f ≤ 2 * ‖f‖ := by
  unfold bcfOscillation
  calc
    ‖f.compContinuous ⟨Prod.fst, continuous_fst⟩ -
        f.compContinuous ⟨Prod.snd, continuous_snd⟩‖ ≤
        ‖f.compContinuous ⟨Prod.fst, continuous_fst⟩‖ +
          ‖f.compContinuous ⟨Prod.snd, continuous_snd⟩‖ := norm_sub_le _ _
    _ ≤ ‖f‖ + ‖f‖ := add_le_add
      (BoundedContinuousFunction.norm_compContinuous_le _ _)
      (BoundedContinuousFunction.norm_compContinuous_le _ _)
    _ = 2 * ‖f‖ := by ring

/-- A concrete kernel-level mixing condition: the Markov operator contracts
oscillation by a uniform factor below one.  Unlike a contraction assumption
on probability laws, this is a local condition that can be proved from a
Doeblin/common-shock splitting event. -/
def KernelOscillationMixing
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) (hκ : KernelFeller κ) : Prop :=
  ∃ q : ℝ, 0 ≤ q ∧ q < 1 ∧
    ∀ f : BoundedContinuousFunction State ℝ,
      bcfOscillation (fellerMarkovOperator κ hκ f) ≤
        q * bcfOscillation f

/-- Finite-step oscillation mixing.  This is the form naturally produced by
an Aiyagari low-income block followed by a reset shock: a positive power of
the one-period Markov operator contracts oscillation. -/
def KernelIterateOscillationMixing
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) (hκ : KernelFeller κ) : Prop :=
  ∃ m : ℕ, 0 < m ∧ ∃ q : ℝ, 0 ≤ q ∧ q < 1 ∧
    ∀ f : BoundedContinuousFunction State ℝ,
      bcfOscillation (((fellerMarkovOperator κ hκ)^[m]) f) ≤
        q * bcfOscillation f

theorem abs_integral_sub_integral_le_two_oscillation
    {State : Type*} [TopologicalSpace State] [Nonempty State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (f : BoundedContinuousFunction State ℝ)
    (μ ν : ProbabilityMeasure State) :
    |(∫ x, f x ∂(μ : Measure State)) -
        ∫ x, f x ∂(ν : Measure State)| ≤ 2 * bcfOscillation f := by
  let x₀ : State := Classical.choice (inferInstance : Nonempty State)
  let g : BoundedContinuousFunction State ℝ :=
    f - BoundedContinuousFunction.const State (f x₀)
  have hgpoint : ∀ x, ‖g x‖ ≤ bcfOscillation f := by
    intro x
    simpa [g, Real.norm_eq_abs] using abs_sub_le_bcfOscillation f x x₀
  have hgnorm : ‖g‖ ≤ bcfOscillation f :=
    BoundedContinuousFunction.norm_le_of_nonempty.mpr hgpoint
  have hμg : (∫ x, g x ∂(μ : Measure State)) =
      (∫ x, f x ∂(μ : Measure State)) - f x₀ := by
    change (∫ x, f x - f x₀ ∂(μ : Measure State)) = _
    rw [integral_sub (f.integrable _) (integrable_const _)]
    simp
  have hνg : (∫ x, g x ∂(ν : Measure State)) =
      (∫ x, f x ∂(ν : Measure State)) - f x₀ := by
    change (∫ x, f x - f x₀ ∂(ν : Measure State)) = _
    rw [integral_sub (f.integrable _) (integrable_const _)]
    simp
  have hμnorm : |∫ x, g x ∂(μ : Measure State)| ≤ ‖g‖ := by
    simpa [Real.norm_eq_abs] using g.norm_integral_le_norm (μ : Measure State)
  have hνnorm : |∫ x, g x ∂(ν : Measure State)| ≤ ‖g‖ := by
    simpa [Real.norm_eq_abs] using g.norm_integral_le_norm (ν : Measure State)
  rw [← sub_sub_sub_cancel_right _ _ (f x₀), ← hμg, ← hνg]
  exact (abs_sub _ _).trans (by linarith)

theorem bcfOscillation_iterate_le
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) (hκ : KernelFeller κ)
    (q : ℝ) (hq0 : 0 ≤ q)
    (hcontract : ∀ f : BoundedContinuousFunction State ℝ,
      bcfOscillation (fellerMarkovOperator κ hκ f) ≤
        q * bcfOscillation f)
    (f : BoundedContinuousFunction State ℝ) (n : ℕ) :
    bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f) ≤
      q ^ n * bcfOscillation f := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      calc
        bcfOscillation (fellerMarkovOperator κ hκ
            (((fellerMarkovOperator κ hκ)^[n]) f)) ≤
            q * bcfOscillation
              (((fellerMarkovOperator κ hκ)^[n]) f) := hcontract _
        _ ≤ q * (q ^ n * bcfOscillation f) :=
          mul_le_mul_of_nonneg_left ih hq0
        _ = q ^ (n + 1) * bcfOscillation f := by
          rw [pow_succ]
          ring

/-- Every Markov operator expands oscillation by at most the harmless factor
two.  This coarse bound controls the finitely many remainder steps between
successive contracting blocks. -/
theorem bcfOscillation_fellerMarkovOperator_le_two
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [Nonempty State] [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ)
    (f : BoundedContinuousFunction State ℝ) :
    bcfOscillation (fellerMarkovOperator κ hκ f) ≤
      2 * bcfOscillation f := by
  apply (BoundedContinuousFunction.norm_le
    (mul_nonneg (by norm_num) (bcfOscillation_nonneg f))).2
  rintro ⟨x, y⟩
  change ‖(∫ z, f z ∂κ x) - ∫ z, f z ∂κ y‖ ≤ 2 * bcfOscillation f
  rw [Real.norm_eq_abs]
  exact abs_integral_sub_integral_le_two_oscillation f
    ⟨κ x, inferInstance⟩ ⟨κ y, inferInstance⟩

theorem bcfOscillation_iterate_le_two
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [Nonempty State] [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ)
    (f : BoundedContinuousFunction State ℝ) (n : ℕ) :
    bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f) ≤
      2 ^ n * bcfOscillation f := by
  exact bcfOscillation_iterate_le κ hκ 2 (by norm_num)
    (bcfOscillation_fellerMarkovOperator_le_two κ hκ) f n

/-- Iterating a contraction of the `m`-step operator gives geometric decay
at every complete block. -/
theorem bcfOscillation_mul_iterate_le
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) (hκ : KernelFeller κ)
    (m : ℕ) (q : ℝ) (hq0 : 0 ≤ q)
    (hcontract : ∀ f : BoundedContinuousFunction State ℝ,
      bcfOscillation (((fellerMarkovOperator κ hκ)^[m]) f) ≤
        q * bcfOscillation f)
    (f : BoundedContinuousFunction State ℝ) (k : ℕ) :
    bcfOscillation (((fellerMarkovOperator κ hκ)^[k * m]) f) ≤
      q ^ k * bcfOscillation f := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Nat.succ_mul, add_comm,
        Function.iterate_add_apply]
      calc
        bcfOscillation (((fellerMarkovOperator κ hκ)^[m])
            (((fellerMarkovOperator κ hκ)^[k * m]) f)) ≤
            q * bcfOscillation
              (((fellerMarkovOperator κ hκ)^[k * m]) f) := hcontract _
        _ ≤ q * (q ^ k * bcfOscillation f) :=
          mul_le_mul_of_nonneg_left ih hq0
        _ = q ^ (k + 1) * bcfOscillation f := by
          rw [pow_succ]
          ring

/-- A finite-step contraction forces the oscillation of every one-period
iterate to vanish; the noncontracting remainder has uniformly bounded
length. -/
theorem tendsto_bcfOscillation_iterate_of_finiteStepMixing
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [Nonempty State] [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ)
    (hMix : KernelIterateOscillationMixing κ hκ)
    (f : BoundedContinuousFunction State ℝ) :
    Tendsto (fun n =>
      bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f))
      atTop (𝓝 0) := by
  rcases hMix with ⟨m, hm, q, hq0, hq1, hcontract⟩
  have hm0 : m ≠ 0 := Nat.ne_of_gt hm
  have hbound : ∀ n,
      bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f) ≤
        2 ^ m * (q ^ (n / m) * bcfOscillation f) := by
    intro n
    calc
      bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f) =
          bcfOscillation (((fellerMarkovOperator κ hκ)^[n % m + (n / m) * m]) f) := by
        rw [Nat.mod_add_div']
      _ = bcfOscillation (((fellerMarkovOperator κ hκ)^[n % m])
          (((fellerMarkovOperator κ hκ)^[(n / m) * m]) f)) := by
        rw [Function.iterate_add_apply]
      _ ≤ 2 ^ (n % m) * bcfOscillation
            (((fellerMarkovOperator κ hκ)^[(n / m) * m]) f) :=
        bcfOscillation_iterate_le_two κ hκ _ _
      _ ≤ 2 ^ (n % m) *
          (q ^ (n / m) * bcfOscillation f) :=
        mul_le_mul_of_nonneg_left
          (bcfOscillation_mul_iterate_le κ hκ m q hq0 hcontract f (n / m))
          (pow_nonneg (by norm_num) _)
      _ ≤ 2 ^ m * (q ^ (n / m) * bcfOscillation f) := by
        apply mul_le_mul_of_nonneg_right
        · exact pow_le_pow_right₀ (by norm_num) (Nat.le_of_lt (Nat.mod_lt n hm))
        · exact mul_nonneg (pow_nonneg hq0 _) (bcfOscillation_nonneg f)
  apply squeeze_zero (fun _ => bcfOscillation_nonneg _) hbound
  have hqpow : Tendsto (fun n : ℕ => q ^ (n / m)) atTop (𝓝 0) :=
    (tendsto_pow_atTop_nhds_zero_of_lt_one hq0 hq1).comp
      (Nat.tendsto_div_const_atTop hm0)
  simpa using ((hqpow.mul_const (bcfOscillation f)).const_mul (2 ^ m))

/-- Evolution of a probability law by one application of a Markov kernel. -/
def markovLawEvolution
    {State : Type*} [MeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (μ : ProbabilityMeasure State) : ProbabilityMeasure State :=
  ⟨κ ∘ₘ (μ : Measure State), inferInstance⟩

/-- Integration against the evolved law is iterated integration against the
current law and then the kernel. -/
theorem integral_markovLawEvolution
    {State : Type*} [TopologicalSpace State] [MeasurableSpace State]
    [OpensMeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (μ : ProbabilityMeasure State)
    (f : BoundedContinuousFunction State ℝ) :
    (∫ y, f y ∂(markovLawEvolution κ μ : Measure State)) =
      ∫ x, (∫ y, f y ∂κ x) ∂(μ : Measure State) := by
  change (∫ y, f y ∂(κ ∘ₘ (μ : Measure State))) = _
  rw [Measure.comp_eq_comp_const_apply]
  exact Kernel.integral_comp (f.integrable _)

/-- Duality between iteration of probability laws and iteration of the
Feller Markov operator. -/
theorem integral_iterate_markovLawEvolution
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) (μ : ProbabilityMeasure State)
    (f : BoundedContinuousFunction State ℝ) (n : ℕ) :
    (∫ x, f x ∂((((markovLawEvolution κ)^[n]) μ :
      ProbabilityMeasure State) : Measure State)) =
      ∫ x, ((fellerMarkovOperator κ hκ)^[n]) f x ∂(μ : Measure State) := by
  induction n generalizing f with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      rw [integral_markovLawEvolution]
      change (∫ x, fellerMarkovOperator κ hκ f x
        ∂((((markovLawEvolution κ)^[n]) μ : ProbabilityMeasure State) :
          Measure State)) = _
      rw [ih]
      rw [Function.iterate_succ_apply]

/-- A Feller Markov kernel induces a continuous self-map of probability laws
on a compact state space. -/
theorem continuous_markovLawEvolution_of_feller
    {State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) :
    Continuous (markovLawEvolution κ) := by
  rw [ProbabilityMeasure.continuous_iff_forall_continuous_integral]
  intro f
  let g : BoundedContinuousFunction State ℝ :=
    BoundedContinuousFunction.mkOfCompact
      ⟨fun x => ∫ y, f y ∂κ x, hκ f⟩
  rw [show (fun μ : ProbabilityMeasure State =>
      ∫ y, f y ∂(markovLawEvolution κ μ : Measure State)) =
      fun μ : ProbabilityMeasure State => ∫ x, g x ∂(μ : Measure State) by
        funext μ
        rw [integral_markovLawEvolution]
        rfl]
  exact ProbabilityMeasure.continuous_integral_boundedContinuousFunction g

/-- Joint continuity of integration when both a bounded continuous integrand
and a probability measure vary.  The proof separates the change in the
integrand, controlled by the sup norm, from weak convergence of the measure
against the fixed limiting integrand. -/
theorem continuous_integral_bcf_probabilityMeasure
    {State : Type*} [MetricSpace State] [SecondCountableTopology State]
    [MeasurableSpace State] [BorelSpace State] :
    Continuous (fun q : BoundedContinuousFunction State ℝ ×
        ProbabilityMeasure State => ∫ x, q.1 x ∂(q.2 : Measure State)) := by
  apply SeqContinuous.continuous
  intro q p hq
  have hfun : Tendsto (fun n => (q n).1) atTop (𝓝 p.1) :=
    (continuous_fst.tendsto p).comp hq
  have hmeasure : Tendsto (fun n => (q n).2) atTop (𝓝 p.2) :=
    (continuous_snd.tendsto p).comp hq
  have hnorm : Tendsto (fun n => ‖(q n).1 - p.1‖) atTop (𝓝 0) := by
    have hdiff : Tendsto (fun n => (q n).1 - p.1) atTop (𝓝 0) := by
      simpa using hfun.sub
        (tendsto_const_nhds : Tendsto (fun _ : ℕ => p.1) atTop (𝓝 p.1))
    simpa [Function.comp_def] using
      continuous_norm.continuousAt.tendsto.comp hdiff
  have hvariable : Tendsto (fun n =>
      ∫ x, ((q n).1 - p.1) x ∂((q n).2 : Measure State)) atTop (𝓝 0) := by
    apply squeeze_zero_norm (a := fun n => ‖(q n).1 - p.1‖)
    · intro n
      exact ((q n).1 - p.1).norm_integral_le_norm ((q n).2 : Measure State)
    · exact hnorm
  have hfixed : Tendsto (fun n => ∫ x, p.1 x ∂((q n).2 : Measure State))
      atTop (𝓝 (∫ x, p.1 x ∂(p.2 : Measure State))) :=
    (ProbabilityMeasure.continuous_integral_boundedContinuousFunction p.1).tendsto
      p.2 |>.comp hmeasure
  have hadd := hvariable.add hfixed
  simpa only [Function.comp_apply, zero_add] using
    hadd.congr' (Filter.Eventually.of_forall fun n => by
      change (∫ x, (q n).1 x - p.1 x ∂((q n).2 : Measure State)) +
          ∫ x, p.1 x ∂((q n).2 : Measure State) =
        ∫ x, (q n).1 x ∂((q n).2 : Measure State)
      rw [integral_sub ((q n).1.integrable _) (p.1.integrable _)]
      ring)

private lemma kernel_comp_finsetSum
    {State ι : Type*} [MeasurableSpace State]
    (κ : Kernel State State) (s : Finset ι) (μ : ι → Measure State) :
    κ ∘ₘ (∑ i ∈ s, μ i) = ∑ i ∈ s, κ ∘ₘ μ i := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      simp [ha, Measure.comp_add, ih]

/-- Joint continuity on a compact shock space implies the Feller property.
This is the parametric-integral step used for the Aiyagari kernel. -/
theorem iidTransitionFeller_of_continuous
    {State Shock : Type*}
    [TopologicalSpace State] [FirstCountableTopology State]
    [LocallyCompactSpace State]
    [TopologicalSpace Shock] [MeasurableSpace Shock]
    [OpensMeasurableSpace Shock] [CompactSpace Shock]
    [SecondCountableTopologyEither Shock ℝ]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Continuous transition.uncurry) :
    IIDTransitionFeller μ transition := by
  intro f
  have hintegrand : Continuous
      (fun p : State × Shock => f (transition p.1 p.2)) :=
    f.continuous.comp htransition
  simpa only [Measure.restrict_univ] using
    (continuous_parametric_integral_of_continuous
      (μ := μ) hintegrand (isCompact_univ : IsCompact (Set.univ : Set Shock)))

/-- Pointwise order preservation of a random transition. -/
def IIDTransitionMonotone
    {State Shock : Type*} [Preorder State]
    (transition : State → Shock → State) : Prop :=
  ∀ l, Monotone (fun x => transition x l)

/-- A one-step common-shock splitting event.  On `splitSet`, the next state is
independent of the current state.  Iterated low-income blocks in Aiyagari's
model are intended to establish this condition for a finite-step transition.
-/
structure OneStepSplitting
    {State Shock : Type*} [MeasurableSpace Shock]
    (μ : Measure Shock) (transition : State → Shock → State) where
  splitSet : Set Shock
  measurable_splitSet : MeasurableSet splitSet
  splitSet_pos : 0 < μ splitSet
  reset : Shock → State
  coalesces : ∀ x l, l ∈ splitSet → transition x l = reset l

/-- On a common-shock reset event the transition integrands agree, so their
expectations differ only on the complementary event. -/
theorem abs_integral_transition_sub_le_compl_oscillation
    {State Shock : Type*}
    [TopologicalSpace State] [MeasurableSpace State]
    [OpensMeasurableSpace State] [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry)
    (hsplit : OneStepSplitting μ transition)
    (f : BoundedContinuousFunction State ℝ) (x y : State) :
    |(∫ l, f (transition x l) ∂μ) -
        ∫ l, f (transition y l) ∂μ| ≤
      μ.real hsplit.splitSetᶜ * bcfOscillation f := by
  let d : Shock → ℝ := fun l =>
    f (transition x l) - f (transition y l)
  have hxmeas : Measurable (transition x) :=
    htransition.comp measurable_prodMk_left
  have hymeas : Measurable (transition y) :=
    htransition.comp measurable_prodMk_left
  have hfx : Integrable (fun l => f (transition x l)) μ :=
    (integrable_map_measure
      f.continuous.aestronglyMeasurable hxmeas.aemeasurable).1
      (f.integrable (μ.map (transition x)))
  have hfy : Integrable (fun l => f (transition y l)) μ :=
    (integrable_map_measure
      f.continuous.aestronglyMeasurable hymeas.aemeasurable).1
      (f.integrable (μ.map (transition y)))
  have hd : Integrable d μ := hfx.sub hfy
  have hzero : (∫ l in hsplit.splitSet, d l ∂μ) = 0 := by
    apply integral_eq_zero_of_ae
    filter_upwards [ae_restrict_mem hsplit.measurable_splitSet] with l hl
    dsimp [d]
    rw [hsplit.coalesces x l hl, hsplit.coalesces y l hl]
    simp
  have hwhole : (∫ l, d l ∂μ) =
      ∫ l in hsplit.splitSetᶜ, d l ∂μ := by
    have hdecomp := integral_add_compl hsplit.measurable_splitSet hd
    rw [hzero, zero_add] at hdecomp
    exact hdecomp.symm
  have hbound : ‖∫ l in hsplit.splitSetᶜ, d l ∂μ‖ ≤
      bcfOscillation f * μ.real hsplit.splitSetᶜ := by
    apply norm_setIntegral_le_of_norm_le_const (measure_lt_top μ _)
    intro l hl
    simpa [d, Real.norm_eq_abs] using
      abs_sub_le_bcfOscillation f (transition x l) (transition y l)
  rw [← integral_sub hfx hfy, hwhole, ← Real.norm_eq_abs]
  simpa [mul_comm] using hbound

/-- A positive-probability common-shock reset proves oscillation mixing for
the induced i.i.d. Markov kernel, with coefficient equal to the probability
of the complementary event. -/
theorem kernelOscillationMixing_of_oneStepSplitting
    {State Shock : Type*}
    [TopologicalSpace State] [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry)
    (hFeller : IIDTransitionFeller μ transition)
    (hsplit : OneStepSplitting μ transition) :
    KernelOscillationMixing
      (iidTransitionKernel μ transition htransition)
      (kernelFeller_iidTransitionKernel μ transition htransition hFeller) := by
  let q := μ.real hsplit.splitSetᶜ
  have hq0 : 0 ≤ q := measureReal_nonneg
  have hsplitRealPos : 0 < μ.real hsplit.splitSet :=
    ENNReal.toReal_pos (ne_of_gt hsplit.splitSet_pos)
      (measure_ne_top μ hsplit.splitSet)
  have hq1 : q < 1 := by
    dsimp [q]
    rw [measureReal_compl hsplit.measurable_splitSet, probReal_univ]
    linarith
  refine ⟨q, hq0, hq1, ?_⟩
  intro f
  apply (BoundedContinuousFunction.norm_le (mul_nonneg hq0
    (bcfOscillation_nonneg f))).2
  rintro ⟨x, y⟩
  change ‖fellerMarkovOperator
      (iidTransitionKernel μ transition htransition)
        (kernelFeller_iidTransitionKernel μ transition htransition hFeller) f x -
    fellerMarkovOperator
      (iidTransitionKernel μ transition htransition)
        (kernelFeller_iidTransitionKernel μ transition htransition hFeller) f y‖ ≤
    q * bcfOscillation f
  rw [fellerMarkovOperator_apply, fellerMarkovOperator_apply,
    integral_iidTransitionKernel, integral_iidTransitionKernel]
  rw [Real.norm_eq_abs]
  exact abs_integral_transition_sub_le_compl_oscillation
    μ transition htransition hsplit f x y

/-- A common-reset random-map representation of a positive kernel iterate
proves finite-step oscillation mixing for the original kernel.  The
representation hypothesis is an equality of concrete Markov operators, not
a contraction or stationary-law conclusion. -/
theorem kernelIterateOscillationMixing_of_blockSplitting
    {State Shock : Type*}
    [TopologicalSpace State] [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    [MeasurableSpace Shock]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ)
    (m : ℕ) (hm : 0 < m)
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry)
    (hFeller : IIDTransitionFeller μ transition)
    (hsplit : OneStepSplitting μ transition)
    (hrep : ∀ f : BoundedContinuousFunction State ℝ,
      fellerMarkovOperator
          (iidTransitionKernel μ transition htransition)
          (kernelFeller_iidTransitionKernel μ transition htransition hFeller) f =
        ((fellerMarkovOperator κ hκ)^[m]) f) :
    KernelIterateOscillationMixing κ hκ := by
  rcases kernelOscillationMixing_of_oneStepSplitting
      μ transition htransition hFeller hsplit with
    ⟨q, hq0, hq1, hcontract⟩
  refine ⟨m, hm, q, hq0, hq1, ?_⟩
  intro f
  rw [← hrep f]
  exact hcontract f

/-- Chronological iteration of an i.i.d. random map along a finite shock
vector.  Coordinate zero is used first, followed by the recursively indexed
tail. -/
def finiteIIDBlockTransition
    {State Shock : Type*} (transition : State → Shock → State) :
    (n : ℕ) → State → (Fin n → Shock) → State
  | 0, x, _ => x
  | n + 1, x, l => finiteIIDBlockTransition transition n
      (transition x (l 0)) (fun i => l i.succ)

/-- Equivalent last-coordinate recursion for the chronological finite block.
This form is convenient when a final shock produces a common reset. -/
theorem finiteIIDBlockTransition_succ_last
    {State Shock : Type*} (transition : State → Shock → State)
    (n : ℕ) (x : State) (l : Fin (n + 1) → Shock) :
    finiteIIDBlockTransition transition (n + 1) x l =
      transition
        (finiteIIDBlockTransition transition n x (fun i => l i.castSucc))
        (l (Fin.last n)) := by
  induction n generalizing x with
  | zero => rfl
  | succ n ih =>
      change finiteIIDBlockTransition transition (n + 1)
          (transition x (l 0)) (fun i => l i.succ) = _
      rw [ih]
      congr 2

theorem measurable_finiteIIDBlockTransition
    {State Shock : Type*} [MeasurableSpace State] [MeasurableSpace Shock]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry) (n : ℕ) :
    Measurable (fun p : State × (Fin n → Shock) =>
      finiteIIDBlockTransition transition n p.1 p.2) := by
  induction n with
  | zero => simpa [finiteIIDBlockTransition] using
      (measurable_fst : Measurable (fun p : State × (Fin 0 → Shock) => p.1))
  | succ n ih =>
      rw [show (fun p : State × (Fin (n + 1) → Shock) =>
          finiteIIDBlockTransition transition (n + 1) p.1 p.2) =
        fun p => finiteIIDBlockTransition transition n
          (transition p.1 (p.2 0)) (fun i => p.2 i.succ) by
            funext p
            rfl]
      simpa [Function.comp_def, Function.uncurry] using ih.comp
        ((htransition.comp
        (measurable_fst.prodMk ((measurable_pi_apply 0).comp measurable_snd))).prodMk
        (measurable_pi_lambda _ fun i =>
          (measurable_pi_apply i.succ).comp measurable_snd))

theorem continuous_finiteIIDBlockTransition
    {State Shock : Type*} [TopologicalSpace State] [TopologicalSpace Shock]
    (transition : State → Shock → State)
    (htransition : Continuous transition.uncurry) (n : ℕ) :
    Continuous (fun p : State × (Fin n → Shock) =>
      finiteIIDBlockTransition transition n p.1 p.2) := by
  induction n with
  | zero => simpa [finiteIIDBlockTransition] using
      (continuous_fst : Continuous (fun p : State × (Fin 0 → Shock) => p.1))
  | succ n ih =>
      rw [show (fun p : State × (Fin (n + 1) → Shock) =>
          finiteIIDBlockTransition transition (n + 1) p.1 p.2) =
        fun p => finiteIIDBlockTransition transition n
          (transition p.1 (p.2 0)) (fun i => p.2 i.succ) by
            funext p
            rfl]
      simpa [Function.comp_def, Function.uncurry] using ih.comp
        ((htransition.comp
        (continuous_fst.prodMk (continuous_apply 0 |>.comp continuous_snd))).prodMk
        (continuous_pi fun i => continuous_apply i.succ |>.comp continuous_snd))

/-- The product law of `n` independent copies of a one-period shock law. -/
def finiteIIDBlockMeasure
    {Shock : Type*} [MeasurableSpace Shock]
    (μ : Measure Shock) (n : ℕ) : Measure (Fin n → Shock) :=
  Measure.pi (fun _ : Fin n => μ)

instance finiteIIDBlockMeasure_isProbability
    {Shock : Type*} [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ] (n : ℕ) :
    IsProbabilityMeasure (finiteIIDBlockMeasure μ n) := by
  unfold finiteIIDBlockMeasure
  infer_instance

/-- Finite-product Fubini identity for an i.i.d. random map: expectation
after `n` independently sampled shocks equals `n` applications of the
one-period Feller Markov operator. -/
theorem integral_finiteIIDBlockTransition_eq_operator_iterate
    {State Shock : Type*}
    [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    [MeasurableSpace Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Measurable transition.uncurry)
    (hFeller : IIDTransitionFeller μ transition)
    (f : BoundedContinuousFunction State ℝ) (x : State) (n : ℕ) :
    (∫ l, f (finiteIIDBlockTransition transition n x l)
        ∂finiteIIDBlockMeasure μ n) =
      ((fellerMarkovOperator
        (iidTransitionKernel μ transition htransition)
        (kernelFeller_iidTransitionKernel μ transition htransition hFeller))^[n]) f x := by
  induction n generalizing x f with
  | zero => simp [finiteIIDBlockMeasure, finiteIIDBlockTransition]
  | succ n ih =>
      let πn : Measure (Fin n → Shock) := finiteIIDBlockMeasure μ n
      let πs : Measure (Fin (n + 1) → Shock) := finiteIIDBlockMeasure μ (n + 1)
      let F := fellerMarkovOperator
        (iidTransitionKernel μ transition htransition)
        (kernelFeller_iidTransitionKernel μ transition htransition hFeller)
      have hblockMeas : Measurable (fun p : Shock × (Fin n → Shock) =>
          f (finiteIIDBlockTransition transition n
            (transition x p.1) p.2)) := by
        exact f.continuous.measurable.comp
          ((measurable_finiteIIDBlockTransition transition htransition n).comp
            ((htransition.comp (measurable_const.prodMk measurable_fst)).prodMk
              measurable_snd))
      have hblockInt : Integrable (fun p : Shock × (Fin n → Shock) =>
          f (finiteIIDBlockTransition transition n
            (transition x p.1) p.2)) (μ.prod πn) := by
        apply Integrable.mono' (integrable_const ‖f‖)
          hblockMeas.aestronglyMeasurable
        filter_upwards with p
        exact f.norm_coe_le_norm _
      calc
        (∫ l, f (finiteIIDBlockTransition transition (n + 1) x l) ∂πs) =
            ∫ p : Shock × (Fin n → Shock),
              f (finiteIIDBlockTransition transition n
                (transition x p.1) p.2) ∂(μ.prod πn) := by
          dsimp [πs, πn, finiteIIDBlockMeasure]
          have hpres := (measurePreserving_piFinSuccAbove
            (fun _ : Fin (n + 1) => μ) 0).symm
          rw [← hpres.integral_comp']
          rfl
        _ = ∫ l : Shock, (∫ tail : Fin n → Shock,
              f (finiteIIDBlockTransition transition n
                (transition x l) tail) ∂πn) ∂μ := by
          exact MeasureTheory.integral_prod _ hblockInt
        _ = ∫ l : Shock, ((F^[n]) f) (transition x l) ∂μ := by
          apply integral_congr_ae
          filter_upwards with l
          exact ih f (transition x l)
        _ = (F^[n + 1]) f x := by
          rw [Function.iterate_succ_apply']
          change (∫ l : Shock, ((F^[n]) f) (transition x l) ∂μ) =
            ∫ y, ((F^[n]) f) y ∂iidTransitionKernel μ transition htransition x
          rw [integral_iidTransitionKernel]

/-- A continuous one-period random map induces a Feller finite-block random
map under the finite i.i.d. product law. -/
theorem finiteIIDBlockTransition_feller
    {State Shock : Type*}
    [TopologicalSpace State] [FirstCountableTopology State]
    [LocallyCompactSpace State]
    [TopologicalSpace Shock] [MeasurableSpace Shock]
    [BorelSpace Shock] [CompactSpace Shock]
    [SecondCountableTopology Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransition : Continuous transition.uncurry) (n : ℕ) :
    IIDTransitionFeller (finiteIIDBlockMeasure μ n)
      (finiteIIDBlockTransition transition n) := by
  apply iidTransitionFeller_of_continuous
  exact continuous_finiteIIDBlockTransition transition htransition n

/-- Operator form of the finite-product Fubini identity.  The Feller Markov
operator of the `n`-shock block kernel is definitionally the `n`th iterate of
the one-period operator. -/
theorem fellerMarkovOperator_finiteIIDBlock_eq_iterate
    {State Shock : Type*}
    [TopologicalSpace State] [FirstCountableTopology State]
    [LocallyCompactSpace State] [CompactSpace State]
    [MeasurableSpace State] [BorelSpace State]
    [TopologicalSpace Shock] [MeasurableSpace Shock]
    [BorelSpace Shock] [CompactSpace Shock]
    [SecondCountableTopology Shock]
    (μ : Measure Shock) [IsProbabilityMeasure μ]
    (transition : State → Shock → State)
    (htransitionMeasurable : Measurable transition.uncurry)
    (htransition : Continuous transition.uncurry)
    (hFeller : IIDTransitionFeller μ transition)
    (f : BoundedContinuousFunction State ℝ) (n : ℕ) :
    fellerMarkovOperator
        (iidTransitionKernel (finiteIIDBlockMeasure μ n)
          (finiteIIDBlockTransition transition n)
          (measurable_finiteIIDBlockTransition transition
            htransitionMeasurable n))
        (kernelFeller_iidTransitionKernel
          (finiteIIDBlockMeasure μ n)
          (finiteIIDBlockTransition transition n)
          (measurable_finiteIIDBlockTransition transition
            htransitionMeasurable n)
          (finiteIIDBlockTransition_feller μ transition htransition n)) f =
      ((fellerMarkovOperator
        (iidTransitionKernel μ transition htransitionMeasurable)
        (kernelFeller_iidTransitionKernel μ transition
          htransitionMeasurable hFeller))^[n]) f := by
  ext x
  rw [fellerMarkovOperator_apply, integral_iidTransitionKernel]
  exact integral_finiteIIDBlockTransition_eq_operator_iterate
    μ transition htransitionMeasurable hFeller f x n

/-- Cesàro average of the first `n+1` iterates of a probability-law
evolution.  Using `n+1` avoids an artificial zero-length case. -/
def probabilityCesaroAverage
    {State : Type*} [MeasurableSpace State]
    (T : ProbabilityMeasure State → ProbabilityMeasure State)
    (μ₀ : ProbabilityMeasure State) (n : ℕ) : ProbabilityMeasure State :=
  ⟨((n + 1 : ℕ) : ℝ≥0∞)⁻¹ •
      ∑ i ∈ Finset.range (n + 1),
        (((T^[i]) μ₀ : ProbabilityMeasure State) : Measure State),
    ⟨by
      simp only [Measure.smul_apply, smul_eq_mul, Measure.coe_finsetSum,
        Finset.sum_apply, IsProbabilityMeasure.measure_univ,
        Finset.sum_const, Finset.card_range, nsmul_eq_mul]
      simpa using ENNReal.inv_mul_cancel
        (show ((n + 1 : ℕ) : ℝ≥0∞) ≠ 0 by simp)
        (show ((n + 1 : ℕ) : ℝ≥0∞) ≠ ∞ by simp)⟩⟩

theorem integral_probabilityCesaroAverage
    {State : Type*} [MeasurableSpace State] [TopologicalSpace State]
    [OpensMeasurableSpace State]
    (T : ProbabilityMeasure State → ProbabilityMeasure State)
    (μ₀ : ProbabilityMeasure State) (n : ℕ)
    (f : BoundedContinuousFunction State ℝ) :
    (∫ x, f x ∂(probabilityCesaroAverage T μ₀ n : Measure State)) =
      (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal *
        ∑ i ∈ Finset.range (n + 1),
          ∫ x, f x ∂(((T^[i]) μ₀ : ProbabilityMeasure State) : Measure State) := by
  rw [show (probabilityCesaroAverage T μ₀ n : Measure State) =
      ((n + 1 : ℕ) : ℝ≥0∞)⁻¹ •
        ∑ i ∈ Finset.range (n + 1),
          (((T^[i]) μ₀ : ProbabilityMeasure State) : Measure State) from rfl]
  rw [integral_smul_measure]
  rw [integral_finsetSum_measure]
  · simp [smul_eq_mul]
  · intro i hi
    exact f.integrable _

/-- Markov evolution is affine, hence it maps a Cesàro orbit average to the
Cesàro average of the one-step-shifted orbit. -/
theorem markovLawEvolution_probabilityCesaroAverage
    {State : Type*} [MeasurableSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (μ₀ : ProbabilityMeasure State) (n : ℕ) :
    markovLawEvolution κ
        (probabilityCesaroAverage (markovLawEvolution κ) μ₀ n) =
      probabilityCesaroAverage (markovLawEvolution κ)
        (markovLawEvolution κ μ₀) n := by
  classical
  apply Subtype.ext
  change κ ∘ₘ
      (((n + 1 : ℕ) : ℝ≥0∞)⁻¹ •
        ∑ i ∈ Finset.range (n + 1),
          ((((markovLawEvolution κ)^[i]) μ₀ : ProbabilityMeasure State) :
            Measure State)) = _
  rw [Measure.comp_smul, kernel_comp_finsetSum]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  change ((markovLawEvolution κ
      (((markovLawEvolution κ)^[i]) μ₀) : ProbabilityMeasure State) :
        Measure State) =
    ((((markovLawEvolution κ)^[i]) (markovLawEvolution κ μ₀) :
      ProbabilityMeasure State) : Measure State)
  congr 1
  rw [← Function.iterate_succ_apply, Function.iterate_succ_apply']

lemma sum_range_succ_shift_sub (g : ℕ → ℝ) (n : ℕ) :
    (∑ i ∈ Finset.range (n + 1), g (i + 1)) -
        ∑ i ∈ Finset.range (n + 1), g i = g (n + 1) - g 0 := by
  have hfirst := Finset.sum_range_succ' g (n + 1)
  have hlast := Finset.sum_range_succ g (n + 1)
  linarith

/-- The elementary telescoping part of Krylov--Bogoliubov averaging.  It only
uses that the law evolution maps an orbit average to the average of the
one-step-shifted orbit, an affine identity later verified for Markov
evolution. -/
theorem cesaro_residual_tendsto_zero_of_map_average
    {State : Type*} [MeasurableSpace State] [TopologicalSpace State]
    [OpensMeasurableSpace State]
    (T : ProbabilityMeasure State → ProbabilityMeasure State)
    (μ₀ : ProbabilityMeasure State)
    (haverage : ∀ n,
      T (probabilityCesaroAverage T μ₀ n) =
        probabilityCesaroAverage T (T μ₀) n)
    (f : BoundedContinuousFunction State ℝ) :
    Tendsto (fun n =>
      (∫ x, f x ∂(T (probabilityCesaroAverage T μ₀ n) : Measure State)) -
        ∫ x, f x ∂(probabilityCesaroAverage T μ₀ n : Measure State))
      atTop (𝓝 0) := by
  let g : ℕ → ℝ := fun i =>
    ∫ x, f x ∂(((T^[i]) μ₀ : ProbabilityMeasure State) : Measure State)
  have hshift : ∀ i,
      (∫ x, f x ∂(((T^[i]) (T μ₀) : ProbabilityMeasure State) : Measure State)) =
        g (i + 1) := by
    intro i
    simp only [g]
    rw [Function.iterate_succ_apply]
  have hidentity : ∀ n,
      (∫ x, f x ∂(T (probabilityCesaroAverage T μ₀ n) : Measure State)) -
          ∫ x, f x ∂(probabilityCesaroAverage T μ₀ n : Measure State) =
        (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal * (g (n + 1) - g 0) := by
    intro n
    rw [haverage n, integral_probabilityCesaroAverage,
      integral_probabilityCesaroAverage]
    simp_rw [hshift]
    rw [← mul_sub]
    congr 1
    exact sum_range_succ_shift_sub g n
  rw [show (fun n =>
      (∫ x, f x ∂(T (probabilityCesaroAverage T μ₀ n) : Measure State)) -
        ∫ x, f x ∂(probabilityCesaroAverage T μ₀ n : Measure State)) =
      fun n => (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal * (g (n + 1) - g 0) by
        funext n; exact hidentity n]
  have hcoeff : Tendsto
      (fun n : ℕ => (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal) atTop (𝓝 0) := by
    have hfun : (fun n : ℕ => (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal) =
        fun n : ℕ => 1 / ((n : ℝ) + 1) := by
      funext n
      rw [ENNReal.toReal_inv, ENNReal.toReal_natCast]
      norm_num [Nat.cast_add, one_div]
    rw [hfun]
    exact tendsto_one_div_add_atTop_nhds_zero_nat
  apply squeeze_zero_norm (a := fun n =>
    (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal * (2 * ‖f‖))
  · intro n
    have hgn : |g (n + 1)| ≤ ‖f‖ := by
      simpa [g, Real.norm_eq_abs] using
        f.norm_integral_le_norm
          (((T^[n + 1]) μ₀ : ProbabilityMeasure State) : Measure State)
    have hg0 : |g 0| ≤ ‖f‖ := by
      simpa [g, Real.norm_eq_abs] using
        f.norm_integral_le_norm (μ₀ : Measure State)
    have hcoefnonneg : 0 ≤ (((n + 1 : ℕ) : ℝ≥0∞)⁻¹).toReal :=
      ENNReal.toReal_nonneg
    rw [Real.norm_eq_abs, abs_mul]
    rw [abs_of_nonneg hcoefnonneg]
    apply mul_le_mul_of_nonneg_left _ hcoefnonneg
    exact (abs_sub _ _).trans (by linarith)
  · simpa [mul_comm] using hcoeff.const_mul (2 * ‖f‖)

/-- Krylov--Bogoliubov compactness step.  A convergent subsequence of the
concrete Cesàro averages is invariant whenever the one-step residual vanishes
against every bounded continuous test function.  No invariant law is included
in the hypotheses. -/
theorem exists_fixedPoint_of_compact_cesaro
    {State : Type*} [MetricSpace State]
    [SecondCountableTopology State] [CompactSpace State]
    [MeasurableSpace State] [BorelSpace State]
    (T : ProbabilityMeasure State → ProbabilityMeasure State)
    (hT : Continuous T) (μ₀ : ProbabilityMeasure State)
    (hresidual : ∀ f : BoundedContinuousFunction State ℝ,
      Tendsto (fun n =>
        (∫ x, f x ∂(T (probabilityCesaroAverage T μ₀ n) : Measure State)) -
          ∫ x, f x ∂(probabilityCesaroAverage T μ₀ n : Measure State))
        atTop (𝓝 0)) :
    ∃ μ : ProbabilityMeasure State, T μ = μ := by
  let avg : ℕ → ProbabilityMeasure State := probabilityCesaroAverage T μ₀
  rcases CompactSpace.tendsto_subseq avg with ⟨μ, ψ, hψ, havg⟩
  have hTavg : Tendsto (fun n => T (avg (ψ n))) atTop (𝓝 (T μ)) :=
    hT.continuousAt.tendsto.comp havg
  have hTavg_to_μ : Tendsto (fun n => T (avg (ψ n))) atTop (𝓝 μ) := by
    rw [ProbabilityMeasure.tendsto_iff_forall_integral_tendsto]
    intro f
    have hbase :=
      (ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.1 havg) f
    have hres := (hresidual f).comp hψ.tendsto_atTop
    have hadd := hres.add hbase
    convert hadd using 1 <;> simp [avg]
  exact ⟨μ, tendsto_nhds_unique hTavg hTavg_to_μ⟩

/-- Krylov--Bogoliubov existence in the form used for Markov evolution: a
continuous law map on a compact metric state space has a fixed point once it
maps every Cesàro orbit average to the average of the shifted orbit.  The
affine identity is proved below for the law map induced by a Markov kernel. -/
theorem exists_fixedPoint_of_compact_cesaro_map_average
    {State : Type*} [MetricSpace State]
    [SecondCountableTopology State] [CompactSpace State]
    [MeasurableSpace State] [BorelSpace State]
    (T : ProbabilityMeasure State → ProbabilityMeasure State)
    (hT : Continuous T) (μ₀ : ProbabilityMeasure State)
    (haverage : ∀ n,
      T (probabilityCesaroAverage T μ₀ n) =
        probabilityCesaroAverage T (T μ₀) n) :
    ∃ μ : ProbabilityMeasure State, T μ = μ := by
  apply exists_fixedPoint_of_compact_cesaro T hT μ₀
  intro f
  exact cesaro_residual_tendsto_zero_of_map_average T μ₀ haverage f

/-- Krylov--Bogoliubov existence for a Feller Markov kernel on a nonempty
compact metric state space.  This is an invariant probability measure in the
literal sense `κ ∘ₘ μ = μ`; no invariant law is supplied as data. -/
theorem exists_invariantProbability_of_feller_compact
    {State : Type*} [MetricSpace State] [SecondCountableTopology State]
    [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) :
    ∃ μ : ProbabilityMeasure State, markovLawEvolution κ μ = μ := by
  let x₀ : State := Classical.choice (inferInstance : Nonempty State)
  let μ₀ : ProbabilityMeasure State :=
    ⟨Measure.dirac x₀, inferInstance⟩
  exact exists_fixedPoint_of_compact_cesaro_map_average
    (markovLawEvolution κ)
    (continuous_markovLawEvolution_of_feller κ hκ) μ₀
    (markovLawEvolution_probabilityCesaroAverage κ μ₀)

/-- Oscillation contraction implies weak convergence of every initial law to
any invariant probability. -/
theorem tendsto_iterate_of_kernelOscillationMixing
    {State : Type*} [MetricSpace State] [SecondCountableTopology State]
    [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) (hMix : KernelOscillationMixing κ hκ)
    (μ : ProbabilityMeasure State)
    (hμ : markovLawEvolution κ μ = μ)
    (μ₀ : ProbabilityMeasure State) :
    Tendsto (fun n => ((markovLawEvolution κ)^[n]) μ₀)
      atTop (𝓝 μ) := by
  rcases hMix with ⟨q, hq0, hq1, hcontract⟩
  rw [ProbabilityMeasure.tendsto_iff_forall_integral_tendsto]
  intro f
  rw [← tendsto_sub_nhds_zero_iff]
  apply squeeze_zero_norm (a := fun n =>
    2 * (q ^ n * bcfOscillation f))
  · intro n
    rw [Real.norm_eq_abs, integral_iterate_markovLawEvolution κ hκ μ₀ f n]
    have hμn : ((markovLawEvolution κ)^[n]) μ = μ :=
      (show Function.IsFixedPt (markovLawEvolution κ) μ from hμ).iterate n
    have hdualμ := integral_iterate_markovLawEvolution κ hκ μ f n
    rw [hμn] at hdualμ
    rw [hdualμ]
    calc
      |(∫ x, ((fellerMarkovOperator κ hκ)^[n]) f x
            ∂(μ₀ : Measure State)) -
          ∫ x, ((fellerMarkovOperator κ hκ)^[n]) f x
            ∂(μ : Measure State)| ≤
          2 * bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f) :=
        abs_integral_sub_integral_le_two_oscillation _ μ₀ μ
      _ ≤ 2 * (q ^ n * bcfOscillation f) :=
        mul_le_mul_of_nonneg_left
          (bcfOscillation_iterate_le κ hκ q hq0 hcontract f n)
          (by norm_num)
  · simpa using ((tendsto_pow_atTop_nhds_zero_of_lt_one hq0 hq1).mul_const
      (bcfOscillation f)).const_mul 2

/-- Finite-step oscillation contraction is enough for convergence at every
date of the original one-period chain, not merely along the skeleton
subsequence. -/
theorem tendsto_iterate_of_kernelIterateOscillationMixing
    {State : Type*} [MetricSpace State] [SecondCountableTopology State]
    [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) (hMix : KernelIterateOscillationMixing κ hκ)
    (μ : ProbabilityMeasure State)
    (hμ : markovLawEvolution κ μ = μ)
    (μ₀ : ProbabilityMeasure State) :
    Tendsto (fun n => ((markovLawEvolution κ)^[n]) μ₀)
      atTop (𝓝 μ) := by
  rw [ProbabilityMeasure.tendsto_iff_forall_integral_tendsto]
  intro f
  rw [← tendsto_sub_nhds_zero_iff]
  apply squeeze_zero_norm (a := fun n =>
    2 * bcfOscillation (((fellerMarkovOperator κ hκ)^[n]) f))
  · intro n
    rw [Real.norm_eq_abs, integral_iterate_markovLawEvolution κ hκ μ₀ f n]
    have hμn : ((markovLawEvolution κ)^[n]) μ = μ :=
      (show Function.IsFixedPt (markovLawEvolution κ) μ from hμ).iterate n
    have hdualμ := integral_iterate_markovLawEvolution κ hκ μ f n
    rw [hμn] at hdualμ
    rw [hdualμ]
    exact abs_integral_sub_integral_le_two_oscillation
      (((fellerMarkovOperator κ hκ)^[n]) f) μ₀ μ
  · simpa using
      (tendsto_bcfOscillation_iterate_of_finiteStepMixing
        κ hκ hMix f).const_mul 2

/-- Monotone-Feller stationarity core: compactness gives existence, while a
kernel-level oscillation mixing condition gives uniqueness and convergence
from every initial probability law. -/
theorem exists_unique_invariant_and_tendsto_of_feller_mixing
    {State : Type*} [MetricSpace State] [SecondCountableTopology State]
    [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) (hMix : KernelOscillationMixing κ hκ) :
    ∃ μ : ProbabilityMeasure State,
      markovLawEvolution κ μ = μ ∧
      (∀ ν : ProbabilityMeasure State,
        markovLawEvolution κ ν = ν → ν = μ) ∧
      ∀ μ₀ : ProbabilityMeasure State,
        Tendsto (fun n => ((markovLawEvolution κ)^[n]) μ₀)
          atTop (𝓝 μ) := by
  rcases exists_invariantProbability_of_feller_compact κ hκ with ⟨μ, hμ⟩
  refine ⟨μ, hμ, ?_, tendsto_iterate_of_kernelOscillationMixing κ hκ hMix μ hμ⟩
  intro ν hν
  have hconv := tendsto_iterate_of_kernelOscillationMixing
    κ hκ hMix μ hμ ν
  have hconst : (fun n => ((markovLawEvolution κ)^[n]) ν) =
      fun _ : ℕ => ν := by
    funext n
    exact (show Function.IsFixedPt (markovLawEvolution κ) ν from hν).iterate n
  rw [hconst] at hconv
  exact (tendsto_nhds_unique hconv tendsto_const_nhds).symm

/-- Compact Feller existence plus a contraction of any positive kernel
iterate gives a unique invariant law and convergence of the original chain
from every initial law. -/
theorem exists_unique_invariant_and_tendsto_of_feller_finiteStepMixing
    {State : Type*} [MetricSpace State] [SecondCountableTopology State]
    [CompactSpace State] [Nonempty State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Kernel State State) [IsMarkovKernel κ]
    (hκ : KernelFeller κ) (hMix : KernelIterateOscillationMixing κ hκ) :
    ∃ μ : ProbabilityMeasure State,
      markovLawEvolution κ μ = μ ∧
      (∀ ν : ProbabilityMeasure State,
        markovLawEvolution κ ν = ν → ν = μ) ∧
      ∀ μ₀ : ProbabilityMeasure State,
        Tendsto (fun n => ((markovLawEvolution κ)^[n]) μ₀)
          atTop (𝓝 μ) := by
  rcases exists_invariantProbability_of_feller_compact κ hκ with ⟨μ, hμ⟩
  refine ⟨μ, hμ, ?_,
    tendsto_iterate_of_kernelIterateOscillationMixing κ hκ hMix μ hμ⟩
  intro ν hν
  have hconv := tendsto_iterate_of_kernelIterateOscillationMixing
    κ hκ hMix μ hμ ν
  have hconst : (fun n => ((markovLawEvolution κ)^[n]) ν) =
      fun _ : ℕ => ν := by
    funext n
    exact (show Function.IsFixedPt (markovLawEvolution κ) ν from hν).iterate n
  rw [hconst] at hconv
  exact (tendsto_nhds_unique hconv tendsto_const_nhds).symm

/-- A compact unique-fixed-point theorem for parameterized maps.  If the
state update is jointly continuous in the parameter and state, and every
parameter has a specified unique fixed point, then the fixed-point selection
is continuous.

This is the topological core of continuity of an invariant probability law.
It does not assume continuity of the selection: compactness supplies cluster
points, joint continuity makes every cluster point a fixed point at the limit
parameter, and pointwise uniqueness identifies it. -/
theorem continuous_fixedPoint_of_compact_unique
    {Param Fixed : Type*}
    [TopologicalSpace Param] [SequentialSpace Param]
    [TopologicalSpace Fixed] [FirstCountableTopology Fixed]
    [CompactSpace Fixed] [T2Space Fixed]
    (T : Param → Fixed → Fixed)
    (hT : Continuous T.uncurry)
    (fixed : Param → Fixed)
    (hfixed : ∀ p, T p (fixed p) = fixed p)
    (hunique : ∀ p x, T p x = x → x = fixed p) :
    Continuous fixed := by
  apply SeqContinuous.continuous
  intro u p hu
  apply tendsto_nhds_of_unique_mapClusterPt
  intro x hx
  rcases hx.tendsto_subseq with ⟨φ, hφ, hxφ⟩
  have hpφ : Tendsto (u ∘ φ) atTop (𝓝 p) :=
    hu.comp hφ.tendsto_atTop
  have hpair : Tendsto (fun n => (u (φ n), fixed (u (φ n)))) atTop
      (𝓝 (p, x)) :=
    hpφ.prodMk_nhds hxφ
  have hTlim : Tendsto (fun n => T (u (φ n)) (fixed (u (φ n)))) atTop
      (𝓝 (T p x)) :=
    hT.continuousAt.tendsto.comp hpair
  have hfixedlim : Tendsto (fun n => fixed (u (φ n))) atTop
      (𝓝 (T p x)) :=
    hTlim.congr' (Filter.Eventually.of_forall fun n => hfixed (u (φ n)))
  have hlimit : T p x = x := tendsto_nhds_unique hfixedlim hxφ
  exact hunique p x hlimit

/-- Law evolution for a parameterized family of Markov kernels, with the
Markov instance supplied pointwise rather than stored as an invariant-law
certificate. -/
noncomputable def parameterizedMarkovLawEvolution
    {Param State : Type*} [MeasurableSpace State]
    (κ : Param → Kernel State State)
    (hMarkov : ∀ p, IsMarkovKernel (κ p))
    (p : Param) (μ : ProbabilityMeasure State) : ProbabilityMeasure State := by
  letI : IsMarkovKernel (κ p) := hMarkov p
  exact markovLawEvolution (κ p) μ

/-- The Feller operator of a parameterized kernel family.  The proof of the
Feller property is supplied pointwise, while continuity in the parameter is
kept as a separate theorem obligation. -/
def parameterizedFellerMarkovOperator
    {Param State : Type*} [TopologicalSpace State] [CompactSpace State]
    [MeasurableSpace State] [OpensMeasurableSpace State]
    (κ : Param → Kernel State State)
    (hFeller : ∀ p, KernelFeller (κ p))
    (p : Param) (f : BoundedContinuousFunction State ℝ) :
    BoundedContinuousFunction State ℝ :=
  fellerMarkovOperator (κ p) (hFeller p) f

/-- Sup-norm continuity of every parameterized Feller operator implies joint
continuity of the induced Markov evolution in the parameter and current
probability law.  This is the analytic bridge between continuous household
policies and continuity of the invariant distribution. -/
theorem continuous_parameterizedMarkovLawEvolution_of_continuous_fellerOperator
    {Param State : Type*} [TopologicalSpace Param]
    [MetricSpace State] [SecondCountableTopology State] [CompactSpace State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Param → Kernel State State)
    (hMarkov : ∀ p, IsMarkovKernel (κ p))
    (hFeller : ∀ p, KernelFeller (κ p))
    (hOperator : ∀ f : BoundedContinuousFunction State ℝ,
      Continuous (fun p => parameterizedFellerMarkovOperator κ hFeller p f)) :
    Continuous (fun q : Param × ProbabilityMeasure State =>
      parameterizedMarkovLawEvolution κ hMarkov q.1 q.2) := by
  rw [ProbabilityMeasure.continuous_iff_forall_continuous_integral]
  intro f
  have hpair : Continuous (fun q : Param × ProbabilityMeasure State =>
      (parameterizedFellerMarkovOperator κ hFeller q.1 f, q.2)) :=
    ((hOperator f).comp continuous_fst).prodMk continuous_snd
  have hcontinuous := continuous_integral_bcf_probabilityMeasure.comp hpair
  convert hcontinuous using 1
  funext q
  letI : IsMarkovKernel (κ q.1) := hMarkov q.1
  change (∫ y, f y ∂(markovLawEvolution (κ q.1) q.2 : Measure State)) = _
  rw [integral_markovLawEvolution]
  rfl

/-- Continuity of a unique invariant probability law for a jointly continuous
parameterized family of Markov evolutions on a compact state space.

The substantial model-specific premise is joint continuity of law evolution:
it must be proved from continuity of the transition kernel in both the model
parameter and the current state.  Invariant-law continuity is then a
consequence, rather than an assumption stored with the stationary solution. -/
theorem continuous_invariantProbability_of_jointlyContinuous_evolution
    {Param State : Type*}
    [TopologicalSpace Param] [SequentialSpace Param]
    [MetricSpace State] [SecondCountableTopology State] [CompactSpace State]
    [MeasurableSpace State] [BorelSpace State]
    (κ : Param → Kernel State State)
    (hMarkov : ∀ p, IsMarkovKernel (κ p))
    (hEvolution : Continuous (fun q : Param × ProbabilityMeasure State =>
      parameterizedMarkovLawEvolution κ hMarkov q.1 q.2))
    (invariant : Param → ProbabilityMeasure State)
    (hInvariant : ∀ p,
      parameterizedMarkovLawEvolution κ hMarkov p (invariant p) = invariant p)
    (hUnique : ∀ p μ,
      parameterizedMarkovLawEvolution κ hMarkov p μ = μ → μ = invariant p) :
    Continuous invariant := by
  apply continuous_fixedPoint_of_compact_unique
    (parameterizedMarkovLawEvolution κ hMarkov) hEvolution invariant
  · exact hInvariant
  · exact hUnique

/-- Next excess resources under the solved shifted-asset policy. -/
def solvedNextExcess
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (x : ExcessResource) (l : LaborSupportState M) : ExcessResource :=
  ⟨(1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x +
      M.w * ((l : ℝ) - M.lmin),
    add_nonneg
      (mul_nonneg (by linarith [hM.r_pos])
        (boundedAiyagariAssetPolicy_mem M φ hM hφ hU x).1)
      (mul_nonneg hM.w_pos.le (sub_nonneg.mpr l.property.1))⟩

/-- Equal effective limits induce exactly the same solved resource transition,
not merely equal pointwise asset choices. -/
theorem solvedNextExcess_eq_of_limit_eq
    (M : HouseholdPrimitives) {φ₁ φ₂ : ℝ}
    (hM : HouseholdAssumptions M)
    (hφ₁ : BorrowingLimitAdmissible M φ₁)
    (hφ₂ : BorrowingLimitAdmissible M φ₂)
    (hU : BoundedFiniteUtility M) (hφ : φ₁ = φ₂) :
    solvedNextExcess M φ₁ hM hφ₁ hU =
      solvedNextExcess M φ₂ hM hφ₂ hU := by
  subst φ₂
  have hproof : hφ₁ = hφ₂ := Subsingleton.elim _ _
  subst hφ₂
  rfl

/-- Solved resource transition indexed directly by the statutory limit. -/
def effectiveSolvedNextExcess
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hU : BoundedFiniteUtility M) (b : ℝ) :=
  solvedNextExcess M (effectiveBorrowingLimit b M.w M.lmin M.r) hM
    (effectiveBorrowingLimit_admissible M hM b) hU

/-- The solved Aiyagari resource transition is monotone in the current excess
resource state. -/
theorem monotone_solvedResourceTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    IIDTransitionMonotone
      (solvedNextExcess M φ hM hφ hU) := by
  intro l x₁ x₂ hx
  apply Subtype.coe_le_coe.mp
  change (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x₁ +
      M.w * ((l : ℝ) - M.lmin) ≤
    (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU x₂ +
      M.w * ((l : ℝ) - M.lmin)
  have hA := monotone_boundedAiyagariAssetPolicy M φ hM hφ hU hx
  have hR : 0 ≤ 1 + M.r := by linarith [hM.r_pos]
  simpa [add_comm] using
    (add_le_add_right (mul_le_mul_of_nonneg_left hA hR)
      (M.w * ((l : ℝ) - M.lmin)))

/-- The solved transition is jointly continuous in state and shock. -/
theorem continuous_solvedResourceTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    Continuous (fun p : ExcessResource × LaborSupportState M =>
      solvedNextExcess M φ hM hφ hU p.1 p.2) := by
  apply Continuous.subtype_mk
  exact ((continuous_const.mul
      ((continuous_boundedAiyagariAssetPolicy M φ hM hφ hU).comp
        continuous_fst)).add
    (continuous_const.mul
      ((continuous_subtype_val.comp continuous_snd).sub continuous_const)))

/-- The full-state Markov kernel induced by the solved household policy. -/
def solvedResourceKernel
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) : Kernel ExcessResource ExcessResource :=
  iidTransitionKernel (laborSupportProbability M hM :
      Measure (LaborSupportState M))
    (solvedNextExcess M φ hM hφ hU)
    (continuous_solvedResourceTransition M φ hM hφ hU).measurable

/-- Equal limits induce the same full policy kernel. -/
theorem solvedResourceKernel_eq_of_limit_eq
    (M : HouseholdPrimitives) {φ₁ φ₂ : ℝ}
    (hM : HouseholdAssumptions M)
    (hφ₁ : BorrowingLimitAdmissible M φ₁)
    (hφ₂ : BorrowingLimitAdmissible M φ₂)
    (hU : BoundedFiniteUtility M) (hφ : φ₁ = φ₂) :
    solvedResourceKernel M φ₁ hM hφ₁ hU =
      solvedResourceKernel M φ₂ hM hφ₂ hU := by
  subst φ₂
  have hproof : hφ₁ = hφ₂ := Subsingleton.elim _ _
  subst hφ₂
  rfl

/-- At a fixed effective limit, changing only the primitive bookkeeping `b`
field leaves the solved full-state transition unchanged. -/
theorem solvedNextExcess_eq_of_borrowingLimit_update
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    {b₁ b₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂) :
    solvedNextExcess (M.withBorrowingLimit b₁) φ
        (hM.withBorrowingLimit hb₁) hφ.withBorrowingLimit
        (hU.withBorrowingLimit b₁) =
      solvedNextExcess (M.withBorrowingLimit b₂) φ
        (hM.withBorrowingLimit hb₂) hφ.withBorrowingLimit
        (hU.withBorrowingLimit b₂) := by
  rfl

/-- The corresponding full-state Markov kernels are identical. -/
theorem solvedResourceKernel_eq_of_borrowingLimit_update
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    {b₁ b₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂) :
    solvedResourceKernel (M.withBorrowingLimit b₁) φ
        (hM.withBorrowingLimit hb₁) hφ.withBorrowingLimit
        (hU.withBorrowingLimit b₁) =
      solvedResourceKernel (M.withBorrowingLimit b₂) φ
        (hM.withBorrowingLimit hb₂) hφ.withBorrowingLimit
        (hU.withBorrowingLimit b₂) := by
  rfl

/-- Equal effective limits remain behaviorally and distributionally identical
after changing the stored statutory limit. -/
theorem solvedResourceKernel_eq_of_b_and_limit
    (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (hU : BoundedFiniteUtility M)
    {b₁ b₂ φ₁ φ₂ : ℝ} (hb₁ : 0 ≤ b₁) (hb₂ : 0 ≤ b₂)
    (hφ₁ : BorrowingLimitAdmissible M φ₁)
    (hφ₂ : BorrowingLimitAdmissible M φ₂) (hlimit : φ₁ = φ₂) :
    solvedResourceKernel (M.withBorrowingLimit b₁) φ₁
        (hM.withBorrowingLimit hb₁) hφ₁.withBorrowingLimit
        (hU.withBorrowingLimit b₁) =
      solvedResourceKernel (M.withBorrowingLimit b₂) φ₂
        (hM.withBorrowingLimit hb₂) hφ₂.withBorrowingLimit
        (hU.withBorrowingLimit b₂) := by
  subst φ₂
  rfl

/-- Solved full-state kernel indexed directly by the statutory limit. -/
def effectiveSolvedResourceKernel
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    (hU : BoundedFiniteUtility M) (b : ℝ) :=
  solvedResourceKernel M (effectiveBorrowingLimit b M.w M.lmin M.r) hM
    (effectiveBorrowingLimit_admissible M hM b) hU

/-- Consequently, the solved continuous-state household transition is
Feller. -/
theorem feller_solvedResourceTransition
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M) :
    IIDTransitionFeller (laborSupportProbability M hM :
      Measure (LaborSupportState M))
      (solvedNextExcess M φ hM hφ hU) := by
  apply iidTransitionFeller_of_continuous
  exact continuous_solvedResourceTransition M φ hM hφ hU

/-- A continuous monotone self-map of nonnegative resources whose only
non-strict descent point is zero has iterates converging to zero.  This lemma
turns the pointwise Euler-equation descent into a finite, uniform entrance
time on every bounded interval. -/
theorem tendsto_iterate_zero_of_monotone_strictDecrease
    (T : ExcessResource → ExcessResource)
    (hTcontinuous : Continuous T)
    (hTmonotone : Monotone T)
    (hTzero : T 0 = 0)
    (hTstrict : ∀ x : ExcessResource, 0 < x → T x < x)
    (x₀ : ExcessResource) :
    Tendsto (fun n : ℕ => (T^[n]) x₀) atTop (𝓝 0) := by
  let s : ℕ → ExcessResource := fun n => (T^[n]) x₀
  have hTle : ∀ x : ExcessResource, T x ≤ x := by
    intro x
    rcases eq_or_lt_of_le (show (0 : ExcessResource) ≤ x from bot_le) with
      hzero | hpos
    · subst x
      simp [hTzero]
    · exact (hTstrict x hpos).le
  have hsanti : Antitone s := by
    apply antitone_nat_of_succ_le
    intro n
    change (T^[n + 1]) x₀ ≤ (T^[n]) x₀
    rw [Function.iterate_succ_apply']
    exact hTle _
  have hsconv : Tendsto s atTop (𝓝 (⨅ n, s n)) :=
    tendsto_atTop_ciInf (f := s) hsanti (OrderBot.bddBelow _)
  let L : ExcessResource := ⨅ n, s n
  have hTconv : Tendsto (fun n => T (s n)) atTop (𝓝 (T L)) := by
    exact hTcontinuous.continuousAt.tendsto.comp (by simpa [L] using hsconv)
  have hshift : Tendsto (fun n => s (n + 1)) atTop (𝓝 L) := by
    change Tendsto (s ∘ fun n => n + 1) atTop (𝓝 L)
    exact hsconv.comp (tendsto_add_atTop_nat 1)
  have hsucc : (fun n => T (s n)) = fun n => s (n + 1) := by
    funext n
    simp [s, Function.iterate_succ_apply']
  have hfixed : T L = L := by
    apply tendsto_nhds_unique hTconv
    simpa [hsucc] using hshift
  have hLzero : L = 0 := by
    by_contra hne
    have hLpos : 0 < L := lt_of_le_of_ne bot_le (Ne.symm hne)
    exact (ne_of_lt (hTstrict L hLpos)) hfixed
  simpa [s, L, hLzero] using hsconv

/-- On a bounded initial interval, the preceding convergence gives a common
finite iterate that enters any prescribed positive neighborhood of zero. -/
theorem exists_uniform_iterate_lt_of_monotone_strictDecrease
    (T : ExcessResource → ExcessResource)
    (hTcontinuous : Continuous T)
    (hTmonotone : Monotone T)
    (hTzero : T 0 = 0)
    (hTstrict : ∀ x : ExcessResource, 0 < x → T x < x)
    (xstar xhat : ExcessResource) (hxhat : 0 < xhat) :
    ∃ N : ℕ, ∀ x ≤ xstar, (T^[N]) x < xhat := by
  have hconv := tendsto_iterate_zero_of_monotone_strictDecrease
    T hTcontinuous hTmonotone hTzero hTstrict xstar
  have hevent : ∀ᶠ n in atTop, (T^[n]) xstar < xhat :=
    hconv.eventually (Iio_mem_nhds hxhat)
  rcases (eventually_atTop.1 hevent) with ⟨N, hN⟩
  refine ⟨N, ?_⟩
  intro x hx
  exact (hTmonotone.iterate N hx).trans_lt (hN N le_rfl)

/-- Excess resources restricted to a closed upper interval. -/
abbrev BoundedExcessResource (xstar : ExcessResource) :=
  Set.Icc (0 : ExcessResource) xstar

/-- Monotonicity turns the high-state drift inequality at `xstar` into
positive invariance of the whole interval `[0,xstar]`. -/
theorem solvedNextExcess_le_driftThreshold
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x)
    (x : BoundedExcessResource xstar) (l : LaborSupportState M) :
    solvedNextExcess M φ hM hφ hU x.1 l ≤ xstar := by
  have hmono := monotone_solvedResourceTransition M φ hM hφ hU
  exact (hmono l x.property.2).trans (hDrift xstar l le_rfl)

/-- The solved resource transition restricted to its absorbing compact
interval. -/
def absorbingSolvedNext
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x)
    (x : BoundedExcessResource xstar) (l : LaborSupportState M) :
    BoundedExcessResource xstar :=
  ⟨solvedNextExcess M φ hM hφ hU x.1 l,
    ⟨bot_le,
      solvedNextExcess_le_driftThreshold M φ hM hφ hU xstar hDrift x l⟩⟩

theorem continuous_absorbingSolvedNext
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    Continuous (fun p : BoundedExcessResource xstar × LaborSupportState M =>
      absorbingSolvedNext M φ hM hφ hU xstar hDrift p.1 p.2) := by
  apply Continuous.subtype_mk
  change Continuous (fun p :
    BoundedExcessResource xstar × LaborSupportState M =>
      solvedNextExcess M φ hM hφ hU p.1.1 p.2)
  have hx : Continuous (fun p :
      BoundedExcessResource xstar × LaborSupportState M => p.1.1) :=
    continuous_subtype_val.comp continuous_fst
  have hl : Continuous (fun p :
      BoundedExcessResource xstar × LaborSupportState M => (p.2 : ℝ)) :=
    continuous_subtype_val.comp continuous_snd
  apply Continuous.subtype_mk
  change Continuous (fun p :
    BoundedExcessResource xstar × LaborSupportState M =>
      (1 + M.r) * boundedAiyagariAssetPolicy M φ hM hφ hU p.1.1 +
        M.w * ((p.2 : ℝ) - M.lmin))
  exact (continuous_const.mul
      ((continuous_boundedAiyagariAssetPolicy M φ hM hφ hU).comp hx)).add
    (continuous_const.mul (hl.sub continuous_const))

/-- Markov kernel of the solved household on the absorbing compact
resource interval. -/
def absorbingSolvedKernel
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    Kernel (BoundedExcessResource xstar) (BoundedExcessResource xstar) :=
  iidTransitionKernel
    (laborSupportProbability M hM : Measure (LaborSupportState M))
    (absorbingSolvedNext M φ hM hφ hU xstar hDrift)
    (continuous_absorbingSolvedNext M φ hM hφ hU xstar hDrift).measurable

instance absorbingSolvedKernel_isMarkov
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    IsMarkovKernel
      (absorbingSolvedKernel M φ hM hφ hU xstar hDrift) := by
  unfold absorbingSolvedKernel
  infer_instance

theorem feller_absorbingSolvedKernel
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    KernelFeller
      (absorbingSolvedKernel M φ hM hφ hU xstar hDrift) := by
  letI : CompactSpace (BoundedExcessResource xstar) :=
    isCompact_iff_compactSpace.mp isCompact_Icc
  apply kernelFeller_iidTransitionKernel
  apply iidTransitionFeller_of_continuous
  exact continuous_absorbingSolvedNext M φ hM hφ hU xstar hDrift

/-- The solved bounded-utility household has at least one invariant
probability law on every absorbing interval furnished by the drift theorem. -/
theorem exists_invariantProbability_absorbingSolvedKernel
    (M : HouseholdPrimitives) (φ : ℝ)
    (hM : HouseholdAssumptions M)
    (hφ : BorrowingLimitAdmissible M φ)
    (hU : BoundedFiniteUtility M)
    (xstar : ExcessResource)
    (hDrift : ∀ x l, xstar ≤ x →
      solvedNextExcess M φ hM hφ hU x l ≤ x) :
    ∃ μ : ProbabilityMeasure (BoundedExcessResource xstar),
      markovLawEvolution
        (absorbingSolvedKernel M φ hM hφ hU xstar hDrift) μ = μ := by
  letI : CompactSpace (BoundedExcessResource xstar) :=
    isCompact_iff_compactSpace.mp isCompact_Icc
  letI : Nonempty (BoundedExcessResource xstar) :=
    ⟨⟨0, le_rfl, bot_le⟩⟩
  apply exists_invariantProbability_of_feller_compact
  exact feller_absorbingSolvedKernel M φ hM hφ hU xstar hDrift

end

end Aiyagari1994
