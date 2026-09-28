import Mathlib.Probability.Moments.Variance
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Analysis.SpecificLimits.Basic

/-! Finite-product probability lemmas for the two-shock-string argument. -/
open MeasureTheory ProbabilityTheory Filter Set
open scoped BigOperators ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994.M07B1
noncomputable section

/-- A common nonnegative initial state and two finite shock strings. -/
abbrev TwoStringSpace (E : Type*) (n : ℕ) :=
  ℝ≥0 × (Fin n × Bool → E)

/-- Product law coupling a common initial state with two independent IID finite strings. -/
def twoStringLaw {E : Type*} [MeasurableSpace E]
    (pi : Measure ℝ≥0) (nu : Measure E) (n : ℕ) : Measure (TwoStringSpace E n) :=
  pi.prod (Measure.pi fun _ : Fin n × Bool ↦ nu)

/-- The discounted difference of two length-`n` shock strings.  The Boolean coordinate
selects the first (`false`) or second (`true`) independent copy. -/
def discountedShockDifference {E : Type*} (shock : E → ℝ) (R : ℝ) (n : ℕ)
    (e : Fin n × Bool → E) : ℝ :=
  ∑ j : Fin n, (R⁻¹) ^ (j.1 + 1) * (shock (e (j, false)) - shock (e (j, true)))

/-- The shock-string difference lifted to the common-initial-state product. -/
def twoStringDifference {E : Type*} (shock : E → ℝ) (R : ℝ) (n : ℕ) :
    TwoStringSpace E n → ℝ :=
  fun ω ↦ discountedShockDifference shock R n ω.2

theorem discountedShockDifference_measurable
    {E : Type*} [MeasurableSpace E] (shock : E → ℝ) (hshock : Measurable shock)
    (R : ℝ) (n : ℕ) : Measurable (discountedShockDifference shock R n) := by
  unfold discountedShockDifference
  fun_prop

/-- Bounded shocks give one bound for every finite discounted difference. -/
theorem discountedShockDifference_abs_le
    {E : Type*} (shock : E → ℝ) (R B : ℝ) (hR : 1 < R) (hB : 0 ≤ B)
    (hbounded : ∀ x, |shock x| ≤ B) (n : ℕ) (e : Fin n × Bool → E) :
    |discountedShockDifference shock R n e| ≤ 2 * B / (1 - R⁻¹) := by
  let q := R⁻¹
  have hR0 : 0 < R := lt_trans zero_lt_one hR
  have hq0 : 0 ≤ q := inv_nonneg.2 hR0.le
  have hq1 : q < 1 := by simpa [q, inv_lt_one₀ hR0] using hR
  have hterm (j : Fin n) :
      |q ^ (j.1 + 1) * (shock (e (j, false)) - shock (e (j, true)))| ≤
        q ^ j.1 * (2 * B) := by
    have hdiff : |shock (e (j, false)) - shock (e (j, true))| ≤ 2 * B := by
      calc
        |shock (e (j, false)) - shock (e (j, true))| ≤
            |shock (e (j, false))| + |shock (e (j, true))| := abs_sub _ _
        _ ≤ B + B := add_le_add (hbounded _) (hbounded _)
        _ = 2 * B := by ring
    rw [abs_mul, abs_of_nonneg (pow_nonneg hq0 _)]
    have hpow : q ^ (j.1 + 1) ≤ q ^ j.1 := by
      rw [pow_succ]
      exact mul_le_of_le_one_right (pow_nonneg hq0 _) hq1.le
    exact (mul_le_mul hpow hdiff (abs_nonneg _) (pow_nonneg hq0 _)).trans_eq (by ring)
  calc
    |discountedShockDifference shock R n e| ≤
        ∑ j : Fin n, |q ^ (j.1 + 1) *
          (shock (e (j, false)) - shock (e (j, true)))| := by
      simpa [discountedShockDifference, q] using
        Finset.abs_sum_le_sum_abs
          (fun j : Fin n ↦ q ^ (j.1 + 1) *
            (shock (e (j, false)) - shock (e (j, true)))) Finset.univ
    _ ≤ ∑ j : Fin n, q ^ j.1 * (2 * B) := Finset.sum_le_sum fun j _ ↦ hterm j
    _ = (∑ j : Fin n, q ^ j.1) * (2 * B) := by rw [Finset.sum_mul]
    _ ≤ (∑' k : ℕ, q ^ k) * (2 * B) := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      rw [Fin.sum_univ_eq_sum_range]
      exact (summable_geometric_of_lt_one hq0 hq1).sum_le_tsum (Finset.range n)
        (fun k _ ↦ pow_nonneg hq0 k)
    _ = 2 * B / (1 - R⁻¹) := by
      rw [tsum_geometric_of_lt_one hq0 hq1]
      dsimp [q]
      field_simp

/-- A bounded nonconstant real random variable has strictly positive variance. -/
theorem variance_pos_of_not_ae_const
    {E : Type*} [MeasurableSpace E] (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock) (B : ℝ)
    (hbounded : ∀ x, |shock x| ≤ B)
    (hnonconstant : ¬ ∃ a : ℝ, shock =ᵐ[nu] fun _ ↦ a) :
    0 < variance shock nu := by
  have hmem : MemLp shock 2 nu :=
    MemLp.of_bound hshock.aestronglyMeasurable B
      (Filter.Eventually.of_forall fun x ↦ hbounded x)
  have hne : variance shock nu ≠ 0 := by
    intro hz
    exact hnonconstant ⟨∫ x, shock x ∂nu,
      ae_eq_integral_of_variance_eq_zero hmem hz⟩
  exact lt_of_le_of_ne (variance_nonneg shock nu) (Ne.symm hne)

private def signedWeight (R : ℝ) {n : ℕ} (i : Fin n × Bool) : ℝ :=
  if i.2 then -((R⁻¹) ^ (i.1.1 + 1)) else (R⁻¹) ^ (i.1.1 + 1)

private theorem discountedShockDifference_eq_sum
    {E : Type*} (shock : E → ℝ) (R : ℝ) (n : ℕ) (e : Fin n × Bool → E) :
    discountedShockDifference shock R n e =
      ∑ i : Fin n × Bool, signedWeight R i * shock (e i) := by
  rw [Fintype.sum_prod_type]
  simp only [discountedShockDifference, signedWeight]
  apply Finset.sum_congr rfl
  intro j _
  simp
  ring

/-- Exact finite-product variance identity for two independent IID shock strings. -/
theorem discountedShockDifference_secondMoment
    {E : Type*} [MeasurableSpace E] (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock) (B : ℝ)
    (hbounded : ∀ x, |shock x| ≤ B) (R : ℝ) (n : ℕ) :
    ∫ e, (discountedShockDifference shock R n e) ^ 2
        ∂Measure.pi (fun _ : Fin n × Bool ↦ nu) =
      2 * variance shock nu * ∑ j : Fin n, (R⁻¹) ^ (2 * (j.1 + 1)) := by
  let mu : Measure (Fin n × Bool → E) := Measure.pi (fun _ : Fin n × Bool ↦ nu)
  let X : (Fin n × Bool) → (Fin n × Bool → E) → ℝ :=
    fun i e ↦ signedWeight R i * shock (e i)
  have hmemShock : MemLp shock 2 nu :=
    MemLp.of_bound hshock.aestronglyMeasurable B
      (Filter.Eventually.of_forall fun x ↦ hbounded x)
  have hmem : ∀ i : Fin n × Bool,
      MemLp (fun x ↦ signedWeight R i * shock x) 2 nu := fun i ↦
    hmemShock.const_mul (signedWeight R i)
  have hvar : variance (∑ i, X i) mu =
      ∑ i : Fin n × Bool,
        variance (fun x ↦ signedWeight R i * shock x) nu := by
    simpa [mu, X] using variance_sum_pi hmem
  have heval (i : Fin n × Bool) :
      ∫ a, shock (a i) ∂mu = ∫ x, shock x ∂nu := by
    let p := measurePreserving_eval (fun _ : Fin n × Bool ↦ nu) i
    calc
      ∫ a, shock (a i) ∂mu = ∫ x, shock x ∂Measure.map (Function.eval i) mu := by
        symm
        exact integral_map (measurable_pi_apply i).aemeasurable
          (by simpa [p.map_eq] using hshock.aestronglyMeasurable)
      _ = ∫ x, shock x ∂nu := by rw [p.map_eq]
  have hmean : ∫ e, ∑ i, X i e ∂mu = 0 := by
    rw [integral_finsetSum]
    · simp_rw [X, integral_const_mul, heval]
      rw [Fintype.sum_prod_type]
      apply Finset.sum_eq_zero
      intro j _
      simp [signedWeight]
    · intro i _
      exact (hmem i).comp_measurePreserving
        (measurePreserving_eval (fun _ : Fin n × Bool ↦ nu) i) |>.integrable one_le_two
  have hsquare : ∫ e, (∑ i, X i e) ^ 2 ∂mu = variance (∑ i, X i) mu := by
    rw [variance_eq_sub]
    · simp [hmean]
    · convert
        (memLp_finsetSum Finset.univ fun i _ ↦
          (hmem i).comp_measurePreserving
            (measurePreserving_eval (fun _ : Fin n × Bool ↦ nu) i)) using 1
      ext e
      simp [X]
  change (∫ e, (discountedShockDifference shock R n e) ^ 2 ∂mu) = _
  simp_rw [discountedShockDifference_eq_sum]
  rw [hsquare, hvar, Fintype.sum_prod_type]
  simp only [signedWeight, variance_const_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  simp
  ring_nf

end
end Aiyagari1994.M07B1
