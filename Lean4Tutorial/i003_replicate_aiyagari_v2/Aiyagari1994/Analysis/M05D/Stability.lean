import Aiyagari1994.Analysis.M05D.Determining
import Mathlib.Probability.Kernel.Composition.IntegralCompProd
import Mathlib.Probability.Kernel.Invariance
import Mathlib.Topology.Sequences
import Mathlib.Topology.Order.MonotoneConvergence

/-! Analytic core of compact monotone--Feller stability. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal Topology ProbabilityTheory

namespace Aiyagari1994
noncomputable section

abbrev CI (a b : ℝ) := RealInterval a b

/-- One-step push-forward of a probability law by a Markov kernel on a compact interval. -/
def lawStep {a b : ℝ} (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (mu : ProbabilityMeasure (CI a b)) : ProbabilityMeasure (CI a b) :=
  ⟨k ∘ₘ (mu : Measure _), by infer_instance⟩

/-- The bounded-continuous Markov operator supplied by the Feller property. -/
def testStep {a b : ℝ} (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (f : BoundedContinuousFunction (CI a b) ℝ) :
    BoundedContinuousFunction (CI a b) ℝ :=
  BoundedContinuousFunction.mkOfCompact ⟨fun x ↦ ∫ y, f y ∂k x, hFeller f⟩

private theorem integral_lawStep {a b : ℝ} (k : Kernel (CI a b) (CI a b))
    [IsMarkovKernel k] (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (mu : ProbabilityMeasure (CI a b)) (f : BoundedContinuousFunction (CI a b) ℝ) :
    (∫ y, f y ∂(lawStep k mu : Measure _)) =
      ∫ x, testStep k hFeller f x ∂(mu : Measure _) := by
  change (∫ y, f y ∂(k ∘ₘ (mu : Measure _))) =
    ∫ x, (∫ y, f y ∂k x) ∂(mu : Measure _)
  rw [Measure.comp_eq_comp_const_apply]
  have hi : Integrable f ((k ∘ₖ Kernel.const Unit (mu : Measure _)) ()) := f.integrable _
  rw [Kernel.integral_comp hi]
  simp

private theorem lawStep_continuous {a b : ℝ} (k : Kernel (CI a b) (CI a b))
    [IsMarkovKernel k] (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x)) :
    Continuous (lawStep k) := by
  apply MeasureTheory.ProbabilityMeasure.continuous_iff_forall_continuous_integral.mpr
  intro f
  simp_rw [integral_lawStep k hFeller]
  exact MeasureTheory.ProbabilityMeasure.continuous_integral_boundedContinuousFunction
    (testStep k hFeller f)

private theorem testStep_mono {a b : ℝ} (k : Kernel (CI a b) (CI a b))
    [IsMarkovKernel k] (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x))
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f) :
    Monotone (testStep k hFeller f) := hMono f hf

private theorem integral_between_endpoints {a b : ℝ} (hab : a ≤ b)
    (mu : ProbabilityMeasure (CI a b))
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f) :
    f ⟨a, le_rfl, hab⟩ ≤ ∫ x, f x ∂(mu : Measure _) ∧
      ∫ x, f x ∂(mu : Measure _) ≤ f ⟨b, hab, le_rfl⟩ := by
  constructor
  · have hc : Integrable (fun _ : CI a b ↦ f ⟨a, le_rfl, hab⟩) (mu : Measure _) :=
      integrable_const _
    have hfi : Integrable f (mu : Measure _) := f.integrable _
    simpa using integral_mono_ae
      (μ := (mu : Measure _)) (f := fun _ ↦ f ⟨a, le_rfl, hab⟩) (g := f)
      hc hfi
      (Filter.Eventually.of_forall fun x ↦ hf x.property.1)
  · have hc : Integrable (fun _ : CI a b ↦ f ⟨b, hab, le_rfl⟩) (mu : Measure _) :=
      integrable_const _
    have hfi : Integrable f (mu : Measure _) := f.integrable _
    simpa using integral_mono_ae
      (μ := (mu : Measure _)) (f := f) (g := fun _ ↦ f ⟨b, hab, le_rfl⟩)
      hfi hc
      (Filter.Eventually.of_forall fun x ↦ hf x.property.2)

private def pointLaw {a b : ℝ} (x : CI a b) : ProbabilityMeasure (CI a b) :=
  ⟨Measure.dirac x, by infer_instance⟩

private def lawOrbit {a b : ℝ} (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (mu : ProbabilityMeasure (CI a b)) (n : ℕ) : ProbabilityMeasure (CI a b) :=
  (lawStep k)^[n] mu

private theorem integral_lawOrbit {a b : ℝ} (k : Kernel (CI a b) (CI a b))
    [IsMarkovKernel k] (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (mu : ProbabilityMeasure (CI a b)) (f : BoundedContinuousFunction (CI a b) ℝ) :
    ∀ n, (∫ y, f y ∂(lawOrbit k mu n : Measure _)) =
      ∫ x, (testStep k hFeller)^[n] f x ∂(mu : Measure _) := by
  intro n
  induction n generalizing f with
  | zero => simp [lawOrbit]
  | succ n ih =>
      rw [lawOrbit, Function.iterate_succ_apply']
      rw [integral_lawStep k hFeller]
      change (∫ x, testStep k hFeller f x ∂(lawOrbit k mu n : Measure _)) = _
      rw [ih (testStep k hFeller f)]
      rw [Function.iterate_succ_apply]

private theorem testStep_iterate_mono {a b : ℝ} (k : Kernel (CI a b) (CI a b))
    [IsMarkovKernel k] (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x))
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f) :
    ∀ n, Monotone ((testStep k hFeller)^[n] f) := by
  intro n
  induction n with
  | zero => simpa using hf
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      exact testStep_mono k hFeller hMono _ ih

private theorem integral_pointLaw {a b : ℝ} (x : CI a b)
    (f : BoundedContinuousFunction (CI a b) ℝ) :
    (∫ y, f y ∂(pointLaw x : Measure _)) = f x := by
  simp [pointLaw]

private theorem endpoint_integral_sequences
    {a b : ℝ} (hab : a ≤ b) (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x))
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f) :
    Monotone (fun n ↦ ∫ x, f x ∂(lawOrbit k (pointLaw ⟨a, le_rfl, hab⟩) n : Measure _)) ∧
    Antitone (fun n ↦ ∫ x, f x ∂(lawOrbit k (pointLaw ⟨b, hab, le_rfl⟩) n : Measure _)) := by
  let lo : CI a b := ⟨a, le_rfl, hab⟩
  let hi : CI a b := ⟨b, hab, le_rfl⟩
  constructor
  · apply monotone_nat_of_le_succ
    intro n
    rw [integral_lawOrbit k hFeller, integral_lawOrbit k hFeller]
    rw [integral_pointLaw, integral_pointLaw]
    rw [Function.iterate_succ_apply']
    exact (integral_between_endpoints hab (⟨k lo, by infer_instance⟩ : ProbabilityMeasure _)
      ((testStep k hFeller)^[n] f) (testStep_iterate_mono k hFeller hMono f hf n)).1
  · apply antitone_nat_of_succ_le
    intro n
    rw [integral_lawOrbit k hFeller, integral_lawOrbit k hFeller]
    rw [integral_pointLaw, integral_pointLaw]
    rw [Function.iterate_succ_apply']
    exact (integral_between_endpoints hab (⟨k hi, by infer_instance⟩ : ProbabilityMeasure _)
      ((testStep k hFeller)^[n] f) (testStep_iterate_mono k hFeller hMono f hf n)).2

private theorem lower_endpoint_limit
    {a b : ℝ} (hab : a ≤ b) (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x)) :
    ∃ pi : ProbabilityMeasure (CI a b),
      Tendsto (lawOrbit k (pointLaw ⟨a, le_rfl, hab⟩)) atTop (𝓝 pi) ∧
      lawStep k pi = pi := by
  let lo : CI a b := ⟨a, le_rfl, hab⟩
  let hi : CI a b := ⟨b, hab, le_rfl⟩
  obtain ⟨pi, phi, hphi, hcluster⟩ :=
    CompactSpace.tendsto_subseq (lawOrbit k (pointLaw lo))
  have htests : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Tendsto (fun n ↦ ∫ x, f x ∂(lawOrbit k (pointLaw lo) n : Measure _)) atTop
        (𝓝 (∫ x, f x ∂(pi : Measure _))) := by
    intro f hf
    let s : ℕ → ℝ := fun n ↦ ∫ x, f x ∂(lawOrbit k (pointLaw lo) n : Measure _)
    have hsmono : Monotone s := (endpoint_integral_sequences hab k hFeller hMono f hf).1
    have hsbdd : BddAbove (Set.range s) := by
      refine ⟨f hi, ?_⟩
      rintro _ ⟨n, rfl⟩
      exact (integral_between_endpoints hab (lawOrbit k (pointLaw lo) n) f hf).2
    have hs := tendsto_atTop_ciSup hsmono hsbdd
    have hsSub := hs.comp hphi.tendsto_atTop
    have hweakSub :=
      MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hcluster f
    have heq : (⨆ n, s n) = ∫ x, f x ∂(pi : Measure _) :=
      tendsto_nhds_unique hsSub hweakSub
    simpa [s, heq] using hs
  have hconv : Tendsto (lawOrbit k (pointLaw lo)) atTop (𝓝 pi) :=
    tendsto_probabilityMeasure_of_increasing_tests a b _ pi htests
  refine ⟨pi, hconv, ?_⟩
  have hstep := (lawStep_continuous k hFeller).tendsto pi |>.comp hconv
  have hshift : Tendsto (fun n ↦ lawOrbit k (pointLaw lo) (n + 1)) atTop (𝓝 pi) :=
    (tendsto_add_atTop_iff_nat 1).2 hconv
  have horbit : (fun n ↦ lawStep k (lawOrbit k (pointLaw lo) n)) =
      fun n ↦ lawOrbit k (pointLaw lo) (n + 1) := by
    funext n
    simp [lawOrbit, Function.iterate_succ_apply']
  change Tendsto (fun n ↦ lawStep k (lawOrbit k (pointLaw lo) n)) atTop
    (𝓝 (lawStep k pi)) at hstep
  rw [horbit] at hstep
  exact tendsto_nhds_unique hstep hshift

private theorem upper_endpoint_limit
    {a b : ℝ} (hab : a ≤ b) (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x)) :
    ∃ pi : ProbabilityMeasure (CI a b),
      Tendsto (lawOrbit k (pointLaw ⟨b, hab, le_rfl⟩)) atTop (𝓝 pi) ∧
      lawStep k pi = pi := by
  let lo : CI a b := ⟨a, le_rfl, hab⟩
  let hi : CI a b := ⟨b, hab, le_rfl⟩
  obtain ⟨pi, phi, hphi, hcluster⟩ :=
    CompactSpace.tendsto_subseq (lawOrbit k (pointLaw hi))
  have htests : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Tendsto (fun n ↦ ∫ x, f x ∂(lawOrbit k (pointLaw hi) n : Measure _)) atTop
        (𝓝 (∫ x, f x ∂(pi : Measure _))) := by
    intro f hf
    let s : ℕ → ℝ := fun n ↦ ∫ x, f x ∂(lawOrbit k (pointLaw hi) n : Measure _)
    have hsanti : Antitone s := (endpoint_integral_sequences hab k hFeller hMono f hf).2
    have hsbdd : BddBelow (Set.range s) := by
      refine ⟨f lo, ?_⟩
      rintro _ ⟨n, rfl⟩
      exact (integral_between_endpoints hab (lawOrbit k (pointLaw hi) n) f hf).1
    have hs := tendsto_atTop_ciInf hsanti hsbdd
    have hsSub := hs.comp hphi.tendsto_atTop
    have hweakSub :=
      MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hcluster f
    have heq : (⨅ n, s n) = ∫ x, f x ∂(pi : Measure _) :=
      tendsto_nhds_unique hsSub hweakSub
    simpa [s, heq] using hs
  have hconv : Tendsto (lawOrbit k (pointLaw hi)) atTop (𝓝 pi) :=
    tendsto_probabilityMeasure_of_increasing_tests a b _ pi htests
  refine ⟨pi, hconv, ?_⟩
  have hstep := (lawStep_continuous k hFeller).tendsto pi |>.comp hconv
  have hshift : Tendsto (fun n ↦ lawOrbit k (pointLaw hi) (n + 1)) atTop (𝓝 pi) :=
    (tendsto_add_atTop_iff_nat 1).2 hconv
  have horbit : (fun n ↦ lawStep k (lawOrbit k (pointLaw hi) n)) =
      fun n ↦ lawOrbit k (pointLaw hi) (n + 1) := by
    funext n
    simp [lawOrbit, Function.iterate_succ_apply']
  change Tendsto (fun n ↦ lawStep k (lawOrbit k (pointLaw hi) n)) atTop
    (𝓝 (lawStep k pi)) at hstep
  rw [horbit] at hstep
  exact tendsto_nhds_unique hstep hshift

private theorem oscillation_contraction
    {a b : ℝ} (hab : a ≤ b) (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x))
    (d : CI a b) (N : ℕ) (eps : ℝ) (_heps0 : 0 < eps) (heps1 : eps ≤ 1)
    (hCross : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      eps * f d + (1 - eps) * f ⟨a, le_rfl, hab⟩ ≤
          (testStep k hFeller)^[N] f ⟨a, le_rfl, hab⟩ ∧
        (testStep k hFeller)^[N] f ⟨b, hab, le_rfl⟩ ≤
          eps * f d + (1 - eps) * f ⟨b, hab, le_rfl⟩)
    (f : BoundedContinuousFunction (CI a b) ℝ) (hf : Monotone f) :
    ∀ m,
      ((testStep k hFeller)^[N])^[m] f ⟨b, hab, le_rfl⟩ -
          ((testStep k hFeller)^[N])^[m] f ⟨a, le_rfl, hab⟩ ≤
        (1 - eps) ^ m * (f ⟨b, hab, le_rfl⟩ - f ⟨a, le_rfl, hab⟩) := by
  let T := testStep k hFeller
  let lo : CI a b := ⟨a, le_rfl, hab⟩
  let hi : CI a b := ⟨b, hab, le_rfl⟩
  have hblockmono : ∀ m, Monotone ((T^[N])^[m] f) := by
    intro m
    induction m with
    | zero => simpa using hf
    | succ m ih =>
        rw [Function.iterate_succ_apply']
        exact testStep_iterate_mono k hFeller hMono _ ih N
  intro m
  induction m with
  | zero => simp
  | succ m ih =>
      let g := (T^[N])^[m] f
      have hg : Monotone g := hblockmono m
      obtain ⟨hlow, hupp⟩ := hCross g hg
      have hone : 0 ≤ 1 - eps := sub_nonneg.mpr heps1
      have hosc : (T^[N] g) hi - (T^[N] g) lo ≤ (1 - eps) * (g hi - g lo) := by
        linarith
      rw [Function.iterate_succ_apply']
      change (T^[N] g) hi - (T^[N] g) lo ≤ _
      calc
        (T^[N] g) hi - (T^[N] g) lo ≤ (1 - eps) * (g hi - g lo) := hosc
        _ ≤ (1 - eps) * ((1 - eps) ^ m * (f hi - f lo)) :=
          mul_le_mul_of_nonneg_left ih hone
        _ = (1 - eps) ^ (m + 1) * (f hi - f lo) := by ring

/-- M05D analytic core: endpoint invariant construction, crossing contraction, uniqueness, and
weak convergence for every initial probability law. -/
theorem M05D_compact_monotone_feller_stability
    {a b : ℝ} (hab : a ≤ b) (k : Kernel (CI a b) (CI a b)) [IsMarkovKernel k]
    (hFeller : ∀ f : BoundedContinuousFunction (CI a b) ℝ,
      Continuous (fun x ↦ ∫ y, f y ∂k x))
    (hMono : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      Monotone (fun x ↦ ∫ y, f y ∂k x))
    (d : CI a b) (N : ℕ) (hN : 1 ≤ N) (eps : ℝ) (heps0 : 0 < eps) (heps1 : eps ≤ 1)
    (hCross : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
      eps * f d + (1 - eps) * f ⟨a, le_rfl, hab⟩ ≤
          (testStep k hFeller)^[N] f ⟨a, le_rfl, hab⟩ ∧
        (testStep k hFeller)^[N] f ⟨b, hab, le_rfl⟩ ≤
          eps * f d + (1 - eps) * f ⟨b, hab, le_rfl⟩) :
    (∃! pi : ProbabilityMeasure (CI a b),
      lawStep k pi = pi ∧
      ∀ mu : ProbabilityMeasure (CI a b),
        Tendsto (fun n ↦ (lawStep k)^[n] mu) atTop (𝓝 pi)) ∧
    ∀ (f : BoundedContinuousFunction (CI a b) ℝ), Monotone f → ∀ m,
      ((testStep k hFeller)^[N])^[m] f ⟨b, hab, le_rfl⟩ -
          ((testStep k hFeller)^[N])^[m] f ⟨a, le_rfl, hab⟩ ≤
        (1 - eps) ^ m * (f ⟨b, hab, le_rfl⟩ - f ⟨a, le_rfl, hab⟩) := by
  let lo : CI a b := ⟨a, le_rfl, hab⟩
  let hi : CI a b := ⟨b, hab, le_rfl⟩
  obtain ⟨piL, hpiL, hinvL⟩ := lower_endpoint_limit hab k hFeller hMono
  obtain ⟨piU, hpiU, hinvU⟩ := upper_endpoint_limit hab k hFeller hMono
  have hNm : Tendsto (fun m : ℕ ↦ N * m) atTop atTop := by
    exact tendsto_id.const_mul_atTop' (Nat.zero_lt_of_lt hN)
  have hpiEq : piL = piU := by
    apply continuous_increasing_tests_determine a b hab
    intro f hf
    have hLint :=
      (MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hpiL f).comp hNm
    have hUint :=
      (MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hpiU f).comp hNm
    have hdiffLim := hUint.sub hLint
    have hmonoBlocks : ∀ m, Monotone (((testStep k hFeller)^[N])^[m] f) := by
      intro m
      induction m with
      | zero => simpa using hf
      | succ m ih =>
          rw [Function.iterate_succ_apply']
          exact testStep_iterate_mono k hFeller hMono _ ih N
    have hdiff_nonneg : ∀ m,
        0 ≤ (∫ x, f x ∂(lawOrbit k (pointLaw hi) (N * m) : Measure _)) -
          ∫ x, f x ∂(lawOrbit k (pointLaw lo) (N * m) : Measure _) := by
      intro m
      rw [integral_lawOrbit k hFeller, integral_lawOrbit k hFeller]
      rw [integral_pointLaw, integral_pointLaw]
      rw [Function.iterate_mul]
      exact sub_nonneg.mpr (hmonoBlocks m (show lo ≤ hi from hab))
    have hdiff_bound : ∀ m,
        (∫ x, f x ∂(lawOrbit k (pointLaw hi) (N * m) : Measure _)) -
            ∫ x, f x ∂(lawOrbit k (pointLaw lo) (N * m) : Measure _) ≤
          (1 - eps) ^ m * (f hi - f lo) := by
      intro m
      rw [integral_lawOrbit k hFeller, integral_lawOrbit k hFeller]
      rw [integral_pointLaw, integral_pointLaw]
      rw [Function.iterate_mul]
      exact oscillation_contraction hab k hFeller hMono d N eps heps0 heps1 hCross f hf m
    have hpow : Tendsto (fun m : ℕ ↦ (1 - eps) ^ m * (f hi - f lo)) atTop (𝓝 0) := by
      have hbase := tendsto_pow_atTop_nhds_zero_of_lt_one (sub_nonneg.mpr heps1) (by linarith)
      simpa using hbase.mul_const (f hi - f lo)
    have hdiff0 := squeeze_zero hdiff_nonneg hdiff_bound hpow
    have hz : (∫ x, f x ∂(piU : Measure _)) - ∫ x, f x ∂(piL : Measure _) = 0 :=
      tendsto_nhds_unique hdiffLim hdiff0
    linarith
  subst piU
  have hall : ∀ mu : ProbabilityMeasure (CI a b),
      Tendsto (fun n ↦ (lawStep k)^[n] mu) atTop (𝓝 piL) := by
    intro mu
    change Tendsto (lawOrbit k mu) atTop (𝓝 piL)
    have htests : ∀ f : BoundedContinuousFunction (CI a b) ℝ, Monotone f →
        Tendsto (fun n ↦ ∫ x, f x ∂(lawOrbit k mu n : Measure _)) atTop
          (𝓝 (∫ x, f x ∂(piL : Measure _))) := by
      intro f hf
      have hlow := MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hpiL f
      have hupp := MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp hpiU f
      apply tendsto_of_tendsto_of_tendsto_of_le_of_le hlow hupp
      · intro n
        change (∫ x, f x ∂(lawOrbit k (pointLaw lo) n : Measure _)) ≤
          ∫ x, f x ∂(lawOrbit k mu n : Measure _)
        rw [integral_lawOrbit k hFeller, integral_lawOrbit k hFeller]
        rw [integral_pointLaw]
        exact (integral_between_endpoints hab mu ((testStep k hFeller)^[n] f)
          (testStep_iterate_mono k hFeller hMono f hf n)).1
      · intro n
        change (∫ x, f x ∂(lawOrbit k mu n : Measure _)) ≤
          ∫ x, f x ∂(lawOrbit k (pointLaw hi) n : Measure _)
        rw [integral_lawOrbit k hFeller, integral_lawOrbit k hFeller]
        rw [integral_pointLaw]
        exact (integral_between_endpoints hab mu ((testStep k hFeller)^[n] f)
          (testStep_iterate_mono k hFeller hMono f hf n)).2
    exact tendsto_probabilityMeasure_of_increasing_tests a b _ piL htests
  constructor
  · refine ⟨piL, ⟨hinvL, hall⟩, ?_⟩
    intro rho hrho
    have horbit : ∀ n, (lawStep k)^[n] rho = rho := by
      intro n
      induction n with
      | zero => simp
      | succ n ih => rw [Function.iterate_succ_apply', ih, hrho.1]
    have hconst : Tendsto (fun _ : ℕ ↦ rho) atTop (𝓝 piL) := by
      simpa only [horbit] using hall rho
    exact (tendsto_nhds_unique hconst
      (tendsto_const_nhds : Tendsto (fun _ : ℕ ↦ rho) atTop (𝓝 rho))).symm
  · exact oscillation_contraction hab k hFeller hMono d N eps heps0 heps1 hCross

end
end Aiyagari1994
