import Aiyagari1994.Analysis.M07B1.FiniteProduct
import Mathlib.Probability.Kernel.Composition.MeasureCompProd
import Mathlib.Probability.Kernel.Composition.Prod

open MeasureTheory ProbabilityTheory Filter Set
open scoped BigOperators ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994.M07B1
noncomputable section


def resourceKernel {E : Type} [MeasurableSpace E]
    (nu : Measure E) (step : ℝ≥0 → E → ℝ≥0)
    (_hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2) : Kernel ℝ≥0 ℝ≥0 :=
  (Kernel.id ×ₖ Kernel.const ℝ≥0 nu).map (fun p => step p.1 p.2)

instance resourceKernel_isMarkov {E : Type} [MeasurableSpace E]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2) :
    IsMarkovKernel (resourceKernel nu step hs) := by
  unfold resourceKernel
  exact Kernel.IsMarkovKernel.map _ hs

theorem resourceKernel_apply {E : Type} [MeasurableSpace E]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2)
    (z : ℝ≥0) :
    resourceKernel nu step hs z = nu.map (step z) := by
  ext s hset
  rw [resourceKernel, Kernel.map_apply' _ hs _ hset,
    Kernel.id_prod_apply' _ _ (hs hset), Kernel.const_apply]
  rw [Measure.map_apply (f := step z) (μ := nu)
    (hs.comp (measurable_const.prodMk measurable_id)) hset]
  rfl

theorem resourceKernel_comp_eq_map {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2) :
    resourceKernel nu step hs ∘ₘ pi =
      Measure.map (fun p : ℝ≥0 × E => step p.1 p.2) (pi.prod nu) := by
  calc
    _ = (((Kernel.id : Kernel ℝ≥0 ℝ≥0) ×ₖ Kernel.const ℝ≥0 nu) ∘ₘ pi).map
        (fun p : ℝ≥0 × E => step p.1 p.2) := by
      exact (Measure.map_comp pi
        ((Kernel.id : Kernel ℝ≥0 ℝ≥0) ×ₖ Kernel.const ℝ≥0 nu) hs).symm
    _ = _ := by
      rw [← Measure.compProd_eq_comp_prod, Measure.compProd_const]

theorem kernel_ae_to_innovation_ae {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2)
    (c : ℝ≥0 → ℝ≥0) (hc : Measurable c)
    (h : ∀ᵐ zz' ∂pi.compProd (resourceKernel nu step hs), c zz'.2 = c zz'.1) :
    ∀ᵐ ze ∂pi.prod nu, c (step ze.1 ze.2) = c ze.1 := by
  have haa : ∀ᵐ z ∂pi, ∀ᵐ z' ∂resourceKernel nu step hs z, c z' = c z :=
    Measure.ae_ae_of_ae_compProd h
  apply (Measure.ae_prod_iff_ae_ae
    (measurableSet_eq_fun (hc.comp hs) (hc.comp measurable_fst))).2
  filter_upwards [haa] with z hz
  have hzmap : ∀ᵐ z' ∂nu.map (step z), c z' = c z := by
    simpa [resourceKernel_apply] using hz
  exact ae_of_ae_map
    (hs.comp (measurable_const.prodMk measurable_id)).aemeasurable hzmap

abbrev CoupledHistorySpace (E : Type) : ℕ → Type
  | 0 => ℝ≥0
  | n + 1 => CoupledHistorySpace E n × (E × E)

@[reducible] def coupledHistoryMeasurableSpace {E : Type} [MeasurableSpace E] : (n : ℕ) → MeasurableSpace (CoupledHistorySpace E n)
  | 0 => NNReal.measurableSpace
  | n + 1 => @Prod.instMeasurableSpace (CoupledHistorySpace E n) (E × E)
      (coupledHistoryMeasurableSpace n) (@Prod.instMeasurableSpace E E inferInstance inferInstance)

instance coupledHistoryMeasurable {E : Type} [MeasurableSpace E]
    (n : ℕ) : MeasurableSpace (CoupledHistorySpace E n) :=
  coupledHistoryMeasurableSpace n

def coupledHistoryLaw {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) (nu : Measure E) : (n : ℕ) → Measure (CoupledHistorySpace E n)
  | 0 => pi
  | n + 1 => (coupledHistoryLaw pi nu n).prod (nu.prod nu)

instance coupledHistoryLaw_isProbability {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu] :
    ∀ n, IsProbabilityMeasure (coupledHistoryLaw pi nu n)
  | 0 => by change IsProbabilityMeasure pi; infer_instance
  | n + 1 => by
      change IsProbabilityMeasure ((coupledHistoryLaw pi nu n).prod (nu.prod nu))
      letI := coupledHistoryLaw_isProbability pi nu n
      infer_instance

def leftResource {E : Type} (step : ℝ≥0 → E → ℝ≥0) : (n : ℕ) → CoupledHistorySpace E n → ℝ≥0
  | 0 => id
  | n + 1 => fun ω => step (leftResource step n ω.1) ω.2.1

def rightResource {E : Type} (step : ℝ≥0 → E → ℝ≥0) : (n : ℕ) → CoupledHistorySpace E n → ℝ≥0
  | 0 => id
  | n + 1 => fun ω => step (rightResource step n ω.1) ω.2.2

def initialResource {E : Type} : (n : ℕ) → CoupledHistorySpace E n → ℝ≥0
  | 0 => id
  | n + 1 => fun ω => initialResource n ω.1

theorem leftResource_measurable {E : Type} [MeasurableSpace E]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2) :
    ∀ n, Measurable (leftResource step n) := by
  intro n
  induction n with
  | zero => exact measurable_id
  | succ n ih =>
      simp only [leftResource]
      exact hs.comp ((ih.comp measurable_fst).prodMk (measurable_fst.comp measurable_snd))

theorem rightResource_measurable {E : Type} [MeasurableSpace E]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2) :
    ∀ n, Measurable (rightResource step n) := by
  intro n
  induction n with
  | zero => exact measurable_id
  | succ n ih =>
      simp only [rightResource]
      exact hs.comp ((ih.comp measurable_fst).prodMk (measurable_snd.comp measurable_snd))

theorem initialResource_measurable {E : Type} [MeasurableSpace E] :
    ∀ n, Measurable (initialResource (E := E) n) := by
  intro n
  induction n with
  | zero => exact measurable_id
  | succ n ih => exact ih.comp measurable_fst

theorem coupled_endpoint_laws {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2)
    (hstat : Measure.map (fun p : ℝ≥0 × E => step p.1 p.2) (pi.prod nu) = pi) :
    ∀ n, Measure.map (leftResource step n) (coupledHistoryLaw pi nu n) = pi ∧
      Measure.map (rightResource step n) (coupledHistoryLaw pi nu n) = pi := by
  intro n
  induction n with
  | zero => exact ⟨Measure.map_id, Measure.map_id⟩
  | succ n ih =>
      have hpair1 : Measure.map Prod.fst (nu.prod nu) = nu := by simp
      have hpair2 : Measure.map Prod.snd (nu.prod nu) = nu := by simp
      constructor
      · rw [show Measure.map (leftResource step (n+1)) (coupledHistoryLaw pi nu (n+1)) =
            Measure.map (fun p : ℝ≥0 × E => step p.1 p.2)
              ((Measure.map (leftResource step n) (coupledHistoryLaw pi nu n)).prod
                (Measure.map Prod.fst (nu.prod nu))) by
              calc
                _ = Measure.map ((fun p : ℝ≥0 × E => step p.1 p.2) ∘
                      Prod.map (leftResource step n) Prod.fst)
                      ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) := rfl
                _ = Measure.map (fun p : ℝ≥0 × E => step p.1 p.2)
                      (Measure.map (Prod.map (leftResource step n) Prod.fst)
                        ((coupledHistoryLaw pi nu n).prod (nu.prod nu))) := by
                          rw [← Measure.map_map hs
                            ((leftResource_measurable step hs n).prodMap measurable_fst)]
                _ = _ := by
                  rw [Measure.map_prod_map _ _ (leftResource_measurable step hs n) measurable_fst]]
        rw [ih.1, hpair1, hstat]
      · rw [show Measure.map (rightResource step (n+1)) (coupledHistoryLaw pi nu (n+1)) =
            Measure.map (fun p : ℝ≥0 × E => step p.1 p.2)
              ((Measure.map (rightResource step n) (coupledHistoryLaw pi nu n)).prod
                (Measure.map Prod.snd (nu.prod nu))) by
              calc
                _ = Measure.map ((fun p : ℝ≥0 × E => step p.1 p.2) ∘
                      Prod.map (rightResource step n) Prod.snd)
                      ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) := rfl
                _ = Measure.map (fun p : ℝ≥0 × E => step p.1 p.2)
                      (Measure.map (Prod.map (rightResource step n) Prod.snd)
                        ((coupledHistoryLaw pi nu n).prod (nu.prod nu))) := by
                          rw [← Measure.map_map hs
                            ((rightResource_measurable step hs n).prodMap measurable_snd)]
                _ = _ := by
                  rw [Measure.map_prod_map _ _ (rightResource_measurable step hs n) measurable_snd]]
        rw [ih.2, hpair2, hstat]

theorem coupled_innovation_laws {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2)
    (hstat : Measure.map (fun p : ℝ≥0 × E => step p.1 p.2) (pi.prod nu) = pi)
    (n : ℕ) :
    Measure.map (fun ω : CoupledHistorySpace E n × (E × E) => (leftResource step n ω.1, ω.2.1))
        ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) = pi.prod nu ∧
    Measure.map (fun ω : CoupledHistorySpace E n × (E × E) => (rightResource step n ω.1, ω.2.2))
        ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) = pi.prod nu := by
  have hlaws := coupled_endpoint_laws pi nu step hs hstat n
  constructor
  · change Measure.map (Prod.map (leftResource step n) Prod.fst)
        ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) = pi.prod nu
    rw [← Measure.map_prod_map _ _ (leftResource_measurable step hs n) measurable_fst,
      hlaws.1]
    simp
  · change Measure.map (Prod.map (rightResource step n) Prod.snd)
        ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) = pi.prod nu
    rw [← Measure.map_prod_map _ _ (rightResource_measurable step hs n) measurable_snd,
      hlaws.2]
    simp

theorem coupled_consumption_constant {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2)
    (c : ℝ≥0 → ℝ≥0) (_hc : Measurable c)
    (hstat : Measure.map (fun p : ℝ≥0 × E => step p.1 p.2) (pi.prod nu) = pi)
    (hconst : ∀ᵐ p ∂(pi.prod nu), c (step p.1 p.2) = c p.1) :
    ∀ n,
      (∀ᵐ ω ∂coupledHistoryLaw pi nu n, c (leftResource step n ω) = c (initialResource n ω)) ∧
      (∀ᵐ ω ∂coupledHistoryLaw pi nu n, c (rightResource step n ω) = c (initialResource n ω)) := by
  intro n
  induction n with
  | zero => simp [leftResource, rightResource, initialResource]
  | succ n ih =>
      let mu := (coupledHistoryLaw pi nu n).prod (nu.prod nu)
      have hmaps := coupled_innovation_laws pi nu step hs hstat n
      have hleftStep : ∀ᵐ ω ∂mu,
          c (step (leftResource step n ω.1) ω.2.1) = c (leftResource step n ω.1) := by
        have hm : ∀ᵐ p ∂Measure.map
            (fun ω : CoupledHistorySpace E n × (E × E) => (leftResource step n ω.1, ω.2.1)) mu,
            c (step p.1 p.2) = c p.1 := by rw [hmaps.1]; exact hconst
        exact ae_of_ae_map
          (((leftResource_measurable step hs n).comp measurable_fst).prodMk
            (measurable_fst.comp measurable_snd)).aemeasurable hm
      have hrightStep : ∀ᵐ ω ∂mu,
          c (step (rightResource step n ω.1) ω.2.2) = c (rightResource step n ω.1) := by
        have hm : ∀ᵐ p ∂Measure.map
            (fun ω : CoupledHistorySpace E n × (E × E) => (rightResource step n ω.1, ω.2.2)) mu,
            c (step p.1 p.2) = c p.1 := by rw [hmaps.2]; exact hconst
        exact ae_of_ae_map
          (((rightResource_measurable step hs n).comp measurable_fst).prodMk
            (measurable_snd.comp measurable_snd)).aemeasurable hm
      have hleftPrev : ∀ᵐ ω ∂mu,
          c (leftResource step n ω.1) = c (initialResource n ω.1) := by
        have hm : ∀ᵐ ω ∂Measure.map Prod.fst mu,
            c (leftResource step n ω) = c (initialResource n ω) := by
          simpa [mu] using ih.1
        exact ae_of_ae_map measurable_fst.aemeasurable hm
      have hrightPrev : ∀ᵐ ω ∂mu,
          c (rightResource step n ω.1) = c (initialResource n ω.1) := by
        have hm : ∀ᵐ ω ∂Measure.map Prod.fst mu,
            c (rightResource step n ω) = c (initialResource n ω) := by
          simpa [mu] using ih.2
        exact ae_of_ae_map measurable_fst.aemeasurable hm
      constructor
      · filter_upwards [hleftStep, hleftPrev] with ω hstep hprev
        exact hstep.trans hprev
      · filter_upwards [hrightStep, hrightPrev] with ω hstep hprev
        exact hstep.trans hprev

def coupledDiscountedDifference {E : Type} (shock : E → ℝ) (R : ℝ) : (n : ℕ) → CoupledHistorySpace E n → ℝ
  | 0 => fun _ => 0
  | n + 1 => fun ω => coupledDiscountedDifference shock R n ω.1 +
      (R⁻¹) ^ (n + 1) * (shock ω.2.1 - shock ω.2.2)

theorem coupled_telescope {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ)
    (R : ℝ) (hR : 1 < R)
    (step : ℝ≥0 → E → ℝ≥0) (hs : Measurable fun p : ℝ≥0 × E => step p.1 p.2)
    (c : ℝ≥0 → ℝ≥0) (hc : Measurable c)
    (hrec : ∀ z e, ((step z e : ℝ≥0) : ℝ) =
      R * ((z : ℝ) - (c z : ℝ)) + shock e)
    (hstat : Measure.map (fun p : ℝ≥0 × E => step p.1 p.2) (pi.prod nu) = pi)
    (hconst : ∀ᵐ p ∂(pi.prod nu), c (step p.1 p.2) = c p.1) :
    ∀ n, ∀ᵐ ω ∂coupledHistoryLaw pi nu n,
      coupledDiscountedDifference shock R n ω = (R⁻¹)^n *
        (((leftResource step n ω : ℝ≥0) : ℝ) - ((rightResource step n ω : ℝ≥0) : ℝ)) := by
  intro n
  induction n with
  | zero => simp [coupledDiscountedDifference, leftResource, rightResource]
  | succ n ih =>
      let mu := (coupledHistoryLaw pi nu n).prod (nu.prod nu)
      have hprev : ∀ᵐ ω ∂mu,
          coupledDiscountedDifference shock R n ω.1 = (R⁻¹)^n *
            (((leftResource step n ω.1 : ℝ≥0) : ℝ) -
              ((rightResource step n ω.1 : ℝ≥0) : ℝ)) := by
        have hm : ∀ᵐ ω ∂Measure.map Prod.fst mu,
            coupledDiscountedDifference shock R n ω = (R⁻¹)^n *
              (((leftResource step n ω : ℝ≥0) : ℝ) -
                ((rightResource step n ω : ℝ≥0) : ℝ)) := by
          simpa [mu] using ih
        exact ae_of_ae_map measurable_fst.aemeasurable hm
      have hconsBase := coupled_consumption_constant pi nu step hs c hc hstat hconst n
      have hcons : ∀ᵐ ω ∂mu,
          c (leftResource step n ω.1) = c (rightResource step n ω.1) := by
        have hbase : ∀ᵐ ω ∂coupledHistoryLaw pi nu n,
            c (leftResource step n ω) = c (rightResource step n ω) := by
          filter_upwards [hconsBase.1, hconsBase.2] with ω hl hr
          exact hl.trans hr.symm
        have hm : ∀ᵐ ω ∂Measure.map Prod.fst mu,
            c (leftResource step n ω) = c (rightResource step n ω) := by
          simpa [mu] using hbase
        exact ae_of_ae_map measurable_fst.aemeasurable hm
      filter_upwards [hprev, hcons] with ω hprevω hconsω
      simp only [coupledDiscountedDifference, leftResource, rightResource]
      rw [hprevω, hrec, hrec]
      have hR0 : R ≠ 0 := ne_of_gt (lt_trans zero_lt_one hR)
      rw [pow_succ]
      field_simp
      rw [show ((c (leftResource step n ω.1) : ℝ≥0) : ℝ) =
        ((c (rightResource step n ω.1) : ℝ≥0) : ℝ) by exact_mod_cast hconsω]
      ring

theorem coupledDiscountedDifference_measurable {E : Type} [MeasurableSpace E]
    (shock : E → ℝ) (hshock : Measurable shock) (R : ℝ) :
    ∀ n, Measurable (coupledDiscountedDifference shock R n) := by
  intro n
  induction n with
  | zero => exact measurable_const
  | succ n ih =>
      simp only [coupledDiscountedDifference]
      fun_prop

theorem pairedShock_mean_zero {E : Type} [MeasurableSpace E]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock) (B : ℝ)
    (hbounded : ∀ x, |shock x| ≤ B) :
    ∫ p, (shock p.1 - shock p.2) ∂(nu.prod nu) = 0 := by
  have hm : MemLp shock 2 nu := MemLp.of_bound hshock.aestronglyMeasurable B
    (Filter.Eventually.of_forall hbounded)
  have hf : Integrable (fun p : E × E => shock p.1) (nu.prod nu) :=
    (hm.comp_fst nu).integrable one_le_two
  have hg : Integrable (fun p : E × E => shock p.2) (nu.prod nu) :=
    (hm.comp_snd nu).integrable one_le_two
  rw [integral_sub hf hg, integral_fun_fst, integral_fun_snd]
  simp

theorem pairedShock_secondMoment {E : Type} [MeasurableSpace E]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock) (B : ℝ)
    (hbounded : ∀ x, |shock x| ≤ B) :
    ∫ p, (shock p.1 - shock p.2) ^ 2 ∂(nu.prod nu) = 2 * variance shock nu := by
  have hm : MemLp shock 2 nu := MemLp.of_bound hshock.aestronglyMeasurable B
    (Filter.Eventually.of_forall hbounded)
  have hpair : MemLp (fun p : E × E => shock p.1 - shock p.2) 2 (nu.prod nu) :=
    (hm.comp_fst nu).sub (hm.comp_snd nu)
  have hmean := pairedShock_mean_zero nu shock hshock B hbounded
  have hv : variance (fun p : E × E => shock p.1 - shock p.2) (nu.prod nu) =
      2 * variance shock nu := by
    rw [show (fun p : E × E => shock p.1 - shock p.2) =
      fun p => shock p.1 + (-shock) p.2 by rfl]
    rw [variance_add_prod hm hm.neg, variance_neg]
    ring
  calc
    _ = variance (fun p : E × E => shock p.1 - shock p.2) (nu.prod nu) := by
      symm
      have heq := variance_eq_sub hpair
      change variance (fun p : E × E => shock p.1 - shock p.2) (nu.prod nu) =
        (∫ p, (shock p.1 - shock p.2)^2 ∂(nu.prod nu)) -
          (∫ p, shock p.1 - shock p.2 ∂(nu.prod nu))^2 at heq
      rw [hmean] at heq
      simpa using heq
    _ = _ := hv

theorem coupledDiscountedDifference_abs_le {E : Type} (shock : E → ℝ) (R B : ℝ)
    (hR : 1 < R) (hB : 0 ≤ B) (hbounded : ∀ x, |shock x| ≤ B) :
    ∀ n (omega : CoupledHistorySpace E n), |coupledDiscountedDifference shock R n omega| ≤ 2 * B / (1 - R⁻¹) := by
  intro n
  let q := R⁻¹
  have hR0 : 0 < R := lt_trans zero_lt_one hR
  have hq0 : 0 ≤ q := inv_nonneg.2 hR0.le
  have hq1 : q < 1 := by simpa [q, inv_lt_one₀ hR0] using hR
  have hpartial : ∀ k (omega : CoupledHistorySpace E k),
      |coupledDiscountedDifference shock R k omega| ≤ ∑ j ∈ Finset.range k, q ^ (j+1) * (2*B) := by
    intro k
    induction k with
    | zero => simp [coupledDiscountedDifference]
    | succ k ih =>
        intro omega
        rw [coupledDiscountedDifference]
        calc
          _ ≤ |coupledDiscountedDifference shock R k omega.1| +
              |q^(k+1) * (shock omega.2.1 - shock omega.2.2)| := abs_add_le _ _
          _ ≤ (∑ j ∈ Finset.range k, q^(j+1) * (2*B)) + q^(k+1)*(2*B) := by
            apply add_le_add (ih omega.1)
            rw [abs_mul, abs_of_nonneg (pow_nonneg hq0 _)]
            apply mul_le_mul_of_nonneg_left _ (pow_nonneg hq0 _)
            calc
              _ ≤ B+B := (abs_sub _ _).trans (add_le_add (hbounded _) (hbounded _))
              _ = 2*B := by ring
          _ = ∑ j ∈ Finset.range (k+1), q^(j+1) * (2*B) := by
            rw [Finset.sum_range_succ]
  intro omega
  calc
    _ ≤ ∑ j ∈ Finset.range n, q^(j+1) * (2*B) := hpartial n omega
    _ ≤ (∑' j : ℕ, q^j) * (2*B) := by
      rw [← Finset.sum_mul]
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      calc
        ∑ j ∈ Finset.range n, q^(j+1) ≤ ∑ j ∈ Finset.range n, q^j := by
          apply Finset.sum_le_sum
          intro j hj
          rw [pow_succ]
          exact mul_le_of_le_one_right (pow_nonneg hq0 _) hq1.le
        _ ≤ ∑' j : ℕ, q^j :=
          (summable_geometric_of_lt_one hq0 hq1).sum_le_tsum (Finset.range n)
            (fun j _ ↦ pow_nonneg hq0 j)
    _ = _ := by
      rw [tsum_geometric_of_lt_one hq0 hq1]
      dsimp [q]
      field_simp

theorem coupledDiscountedDifference_memLp {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock) (B R : ℝ)
    (hbounded : ∀ x, |shock x| ≤ B) :
    ∀ n, MemLp (coupledDiscountedDifference shock R n) 2 (coupledHistoryLaw pi nu n) := by
  intro n
  induction n with
  | zero => exact MemLp.zero
  | succ n ih =>
      have hm : MemLp shock 2 nu := MemLp.of_bound hshock.aestronglyMeasurable B
        (Filter.Eventually.of_forall hbounded)
      have hpair : MemLp (fun p : E × E => shock p.1 - shock p.2) 2 (nu.prod nu) :=
        (hm.comp_fst nu).sub (hm.comp_snd nu)
      change MemLp (fun omega : CoupledHistorySpace E n × (E × E) =>
        coupledDiscountedDifference shock R n omega.1 + (R⁻¹)^(n+1) *
          (shock omega.2.1 - shock omega.2.2)) 2
        ((coupledHistoryLaw pi nu n).prod (nu.prod nu))
      exact (ih.comp_fst (nu.prod nu)).add
        ((hpair.const_mul ((R⁻¹)^(n+1))).comp_snd (coupledHistoryLaw pi nu n))

theorem coupledDiscountedDifference_moments {E : Type} [MeasurableSpace E]
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock) (B : ℝ)
    (hbounded : ∀ x, |shock x| ≤ B) (R : ℝ) :
    ∀ n,
      (∫ ω, coupledDiscountedDifference shock R n ω ∂coupledHistoryLaw pi nu n = 0) ∧
      (∫ ω, (coupledDiscountedDifference shock R n ω) ^ 2 ∂coupledHistoryLaw pi nu n =
        2 * variance shock nu * ∑ j ∈ Finset.range n, (R⁻¹) ^ (2 * (j + 1))) := by
  intro n
  induction n with
  | zero => simp [coupledDiscountedDifference, coupledHistoryLaw]
  | succ n ih =>
      let X : E × E → ℝ := fun p => shock p.1 - shock p.2
      let w : ℝ := (R⁻¹)^(n+1)
      have hm : MemLp shock 2 nu := MemLp.of_bound hshock.aestronglyMeasurable B
        (Filter.Eventually.of_forall hbounded)
      have hDmem := coupledDiscountedDifference_memLp pi nu shock hshock B R hbounded n
      have hXmem : MemLp X 2 (nu.prod nu) :=
        (hm.comp_fst nu).sub (hm.comp_snd nu)
      have hDint := hDmem.integrable one_le_two
      have hXint := hXmem.integrable one_le_two
      have hsumMem : MemLp (fun omega : CoupledHistorySpace E n × (E × E) =>
          coupledDiscountedDifference shock R n omega.1 + w * X omega.2) 2
          ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) :=
        (hDmem.comp_fst (nu.prod nu)).add
          ((hXmem.const_mul w).comp_snd (coupledHistoryLaw pi nu n))
      have hmean : ∫ omega : CoupledHistorySpace E n × (E × E),
          coupledDiscountedDifference shock R n omega.1 + w * X omega.2
          ∂((coupledHistoryLaw pi nu n).prod (nu.prod nu)) = 0 := by
        rw [integral_add (hDint.comp_fst (nu.prod nu))
            ((hXint.const_mul w).comp_snd (coupledHistoryLaw pi nu n)),
          integral_fun_fst, integral_const_mul, integral_fun_snd, ih.1]
        have hxzero : ∫ p, X p ∂(nu.prod nu) = 0 :=
          pairedShock_mean_zero nu shock hshock B hbounded
        simp [hxzero]
      constructor
      · exact hmean
      · have hDvar : variance (coupledDiscountedDifference shock R n) (coupledHistoryLaw pi nu n) =
            2 * variance shock nu * ∑ j ∈ Finset.range n,
              (R⁻¹) ^ (2 * (j+1)) := by
            have heq := variance_eq_sub hDmem
            change variance (coupledDiscountedDifference shock R n) (coupledHistoryLaw pi nu n) =
              (∫ omega, (coupledDiscountedDifference shock R n omega)^2 ∂coupledHistoryLaw pi nu n) -
                (∫ omega, coupledDiscountedDifference shock R n omega ∂coupledHistoryLaw pi nu n)^2 at heq
            rw [ih.1, ih.2] at heq
            have hzero : (0 : ℝ)^2 = 0 := by norm_num
            rw [hzero, sub_zero] at heq
            exact heq
        have hXvar : variance X (nu.prod nu) = 2 * variance shock nu := by
          have heq := variance_eq_sub hXmem
          change variance X (nu.prod nu) = (∫ p, (X p)^2 ∂(nu.prod nu)) -
            (∫ p, X p ∂(nu.prod nu))^2 at heq
          have hxzero : ∫ p, X p ∂(nu.prod nu) = 0 :=
            pairedShock_mean_zero nu shock hshock B hbounded
          have hxsecond : ∫ p, (X p)^2 ∂(nu.prod nu) = 2 * variance shock nu :=
            pairedShock_secondMoment nu shock hshock B hbounded
          rw [hxzero, hxsecond] at heq
          norm_num at heq
          exact heq
        have hvar : variance (fun omega : CoupledHistorySpace E n × (E × E) =>
            coupledDiscountedDifference shock R n omega.1 + w * X omega.2)
            ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) =
            2 * variance shock nu * ∑ j ∈ Finset.range (n+1),
              (R⁻¹) ^ (2 * (j+1)) := by
          rw [variance_add_prod hDmem (hXmem.const_mul w), hDvar,
            variance_const_mul, hXvar, Finset.sum_range_succ]
          dsimp [w]
          ring
        change (∫ omega : CoupledHistorySpace E n × (E × E),
            (coupledDiscountedDifference shock R n omega.1 + w * X omega.2)^2
            ∂((coupledHistoryLaw pi nu n).prod (nu.prod nu))) = _
        have hvariance := variance_eq_sub hsumMem
        change variance (fun omega : CoupledHistorySpace E n × (E × E) =>
            coupledDiscountedDifference shock R n omega.1 + w * X omega.2)
            ((coupledHistoryLaw pi nu n).prod (nu.prod nu)) =
          (∫ omega, (coupledDiscountedDifference shock R n omega.1 + w * X omega.2)^2
            ∂((coupledHistoryLaw pi nu n).prod (nu.prod nu))) -
          (∫ omega, coupledDiscountedDifference shock R n omega.1 + w * X omega.2
            ∂((coupledHistoryLaw pi nu n).prod (nu.prod nu)))^2 at hvariance
        rw [hmean] at hvariance
        norm_num at hvariance
        rw [← hvar]
        exact hvariance.symm

end
end Aiyagari1994.M07B1
