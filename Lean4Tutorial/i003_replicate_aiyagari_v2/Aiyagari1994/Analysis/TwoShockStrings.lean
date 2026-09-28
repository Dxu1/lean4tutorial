import Aiyagari1994.Analysis.M07B1.FiniteProduct
import Aiyagari1994.Analysis.M07B1.FiniteHistoryBridge
import Aiyagari1994.Analysis.M07B1.Tightness
import Mathlib.MeasureTheory.Integral.Prod

/-! N05: the generic finite-product two-independent-histories contradiction. -/
open MeasureTheory ProbabilityTheory Filter Set
open scoped BigOperators ENNReal NNReal ProbabilityTheory

namespace Aiyagari1994
noncomputable section

/-- N05: for `R > 1`, a measurable state-dependent consumption rule and its actual resource
recursion cannot have a stationary probability law if consumption is almost surely unchanged
across the stationary one-step transition.  The proof internally couples a common initial state
with two independent finite IID shock strings, derives both terminal stationary laws, transfers
the N04-shaped almost-everywhere equality to the innovation products, and telescopes there.
No moment of the stationary state law is assumed. -/
theorem two_independent_histories_contradiction
    {E : Type} [MeasurableSpace E]
    (nu : Measure E) [IsProbabilityMeasure nu]
    (shock : E → ℝ) (hshock : Measurable shock)
    (B : ℝ) (hB : 0 ≤ B) (hbounded : ∀ e, |shock e| ≤ B)
    (hnonconstant : ¬ ∃ a : ℝ, shock =ᵐ[nu] fun _ ↦ a)
    (R : ℝ) (hR : 1 < R)
    (c : ℝ≥0 → ℝ≥0) (hc : Measurable c)
    (step : ℝ≥0 → E → ℝ≥0)
    (hstep : Measurable fun p : ℝ≥0 × E ↦ step p.1 p.2)
    (hrecursion : ∀ z e, ((step z e : ℝ≥0) : ℝ) =
      R * ((z : ℝ) - (c z : ℝ)) + shock e)
    (pi : Measure ℝ≥0) [IsProbabilityMeasure pi]
    (hinv : M07B1.resourceKernel nu step hstep ∘ₘ pi = pi)
    (hconstant : ∀ᵐ zz' ∂pi.compProd (M07B1.resourceKernel nu step hstep),
      c zz'.2 = c zz'.1) :
    False := by
  let q : ℝ := R⁻¹
  have hR0 : 0 < R := lt_trans zero_lt_one hR
  have hq0 : 0 ≤ q := inv_nonneg.2 hR0.le
  have hq1 : q < 1 := by simpa [q, inv_lt_one₀ hR0] using hR
  let v : ℝ := variance shock nu
  have hv : 0 < v := M07B1.variance_pos_of_not_ae_const
    nu shock hshock B hbounded hnonconstant
  have hstat : Measure.map (fun p : ℝ≥0 × E ↦ step p.1 p.2) (pi.prod nu) = pi := by
    rw [← M07B1.resourceKernel_comp_eq_map pi nu step hstep]
    exact hinv
  have hconstantInnovation : ∀ᵐ ze ∂pi.prod nu,
      c (step ze.1 ze.2) = c ze.1 :=
    M07B1.kernel_ae_to_innovation_ae pi nu step hstep c hc hconstant
  let L : ℝ := 2 * v * q ^ 2
  have hL : 0 < L := by dsimp [L]; positivity
  let C : ℝ := 2 * B / (1 - q)
  have hC : 0 ≤ C := by
    dsimp [C]
    positivity
  let a : ℝ := Real.sqrt L / 2
  have ha : 0 < a := by dsimp [a]; positivity
  have ha_sq : a ^ 2 = L / 4 := by
    dsimp [a]
    rw [div_pow, Real.sq_sqrt hL.le]
    norm_num
  let delta : ℝ := L / (8 * (C ^ 2 + 1))
  have hdelta : 0 < delta := by dsimp [delta]; positivity
  obtain ⟨K, hKtail⟩ := M07B1.probability_nnreal_tail_le pi
    (ENNReal.ofReal delta) (ENNReal.ofReal_pos.2 hdelta)
  have hpow : Tendsto (fun n : ℕ ↦ q ^ n) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one hq0 hq1
  have htarget : 0 < a / (2 * (K : ℝ) + 1) := by positivity
  have hevent : ∀ᶠ n in atTop, q ^ n < a / (2 * (K : ℝ) + 1) :=
    (tendsto_order.1 hpow).2 _ htarget
  obtain ⟨n, hnlarge, hnpos⟩ : ∃ n : ℕ,
      q ^ n < a / (2 * (K : ℝ) + 1) ∧ 1 ≤ n :=
    (hevent.and (eventually_ge_atTop 1)).exists
  let mu : Measure (M07B1.CoupledHistorySpace E n) := M07B1.coupledHistoryLaw pi nu n
  let D : M07B1.CoupledHistorySpace E n → ℝ :=
    M07B1.coupledDiscountedDifference shock R n
  let Z : M07B1.CoupledHistorySpace E n → ℝ≥0 := M07B1.leftResource step n
  let Z' : M07B1.CoupledHistorySpace E n → ℝ≥0 := M07B1.rightResource step n
  letI : IsProbabilityMeasure mu := by dsimp [mu]; infer_instance
  have hDmeas : Measurable D := by
    exact M07B1.coupledDiscountedDifference_measurable shock hshock R n
  have hDbound : ∀ ω, |D ω| ≤ C := by
    intro ω
    simpa [D, C, q] using
      M07B1.coupledDiscountedDifference_abs_le shock R B hR hB hbounded n ω
  have hendpoint := M07B1.coupled_endpoint_laws pi nu step hstep hstat n
  have hZmeas : Measurable Z := M07B1.leftResource_measurable step hstep n
  have hZ'meas : Measurable Z' := M07B1.rightResource_measurable step hstep n
  have hlawZ : Measure.map Z mu = pi := by simpa [Z, mu] using hendpoint.1
  have hlawZ' : Measure.map Z' mu = pi := by simpa [Z', mu] using hendpoint.2
  have hidentity : ∀ᵐ ω ∂mu,
      D ω = q ^ n * (((Z ω : ℝ≥0) : ℝ) - ((Z' ω : ℝ≥0) : ℝ)) := by
    simpa [D, Z, Z', q, mu] using
      M07B1.coupled_telescope pi nu shock R hR step hstep c hc hrecursion
        hstat hconstantInnovation n
  have hscale : q ^ n * (2 * (K : ℝ)) ≤ a := by
    have hqn : 0 ≤ q ^ n := pow_nonneg hq0 n
    have hK0 : 0 ≤ (K : ℝ) := NNReal.zero_le_coe
    have hden : 0 < 2 * (K : ℝ) + 1 := by positivity
    have hmain : q ^ n * (2 * (K : ℝ) + 1) < a := by
      exact (lt_div_iff₀ hden).mp hnlarge
    nlinarith
  have heventBound : mu {ω | a < |D ω|} ≤ 2 * pi (Ioi K) := by
    apply M07B1.scaled_difference_event_le_two_tails
      mu pi Z Z' hZmeas hZ'meas hlawZ hlawZ'
      D q hq0 n
    · exact hidentity
    · exact hscale
  have heventReal : (mu {ω | a < |D ω|}).toReal ≤ 2 * delta := by
    have hfinite : mu {ω | a < |D ω|} ≠ ∞ := measure_ne_top mu _
    have htailfinite : (2 * ENNReal.ofReal delta) ≠ ∞ :=
      ENNReal.mul_ne_top (by norm_num) ENNReal.ofReal_ne_top
    have hraw : (mu {ω | a < |D ω|}).toReal ≤
        (2 * ENNReal.ofReal delta).toReal :=
      (ENNReal.toReal_le_toReal hfinite htailfinite).2 <| by
        calc
          mu {ω | a < |D ω|} ≤ 2 * pi (Ioi K) := heventBound
          _ ≤ 2 * ENNReal.ofReal delta := mul_le_mul_right hKtail 2
    calc
      (mu {ω | a < |D ω|}).toReal ≤ (2 * ENNReal.ofReal delta).toReal := hraw
      _ = 2 * delta := by simp [ENNReal.toReal_ofReal hdelta.le]
  have hsecondUpper : ∫ ω, (D ω) ^ 2 ∂mu < L := by
    have hle := M07B1.secondMoment_le_of_uniform_bound
      mu D hDmeas C a hC ha.le hDbound
    calc
      ∫ ω, (D ω) ^ 2 ∂mu ≤
          a ^ 2 + C ^ 2 * (mu {ω | a < |D ω|}).toReal := hle
      _ ≤ a ^ 2 + C ^ 2 * (2 * delta) := by gcongr
      _ < L := by
        rw [ha_sq]
        dsimp [delta]
        have hden : 0 < C ^ 2 + 1 := by positivity
        field_simp
        nlinarith [sq_nonneg C]
  have hsecondExact : ∫ ω, (D ω) ^ 2 ∂mu =
      2 * v * ∑ j ∈ Finset.range n, q ^ (2 * (j + 1)) := by
    simpa [D, mu, v, q] using
      (M07B1.coupledDiscountedDifference_moments pi nu shock hshock B hbounded R n).2
  have hsecondLower : L ≤ ∫ ω, (D ω) ^ 2 ∂mu := by
    rw [hsecondExact]
    dsimp [L]
    have hfirst : q ^ 2 ≤ ∑ j ∈ Finset.range n, q ^ (2 * (j + 1)) := by
      have hj : q ^ (2 * (0 + 1)) ≤
          ∑ j ∈ Finset.range n, q ^ (2 * (j + 1)) := Finset.single_le_sum
        (f := fun j : ℕ ↦ q ^ (2 * (j + 1)))
        (fun j _ ↦ pow_nonneg hq0 _)
        (Finset.mem_range.mpr (lt_of_lt_of_le Nat.zero_lt_one hnpos))
      simpa using hj
    exact mul_le_mul_of_nonneg_left hfirst (by positivity)
  exact (not_lt_of_ge hsecondLower) hsecondUpper

end
end Aiyagari1994
