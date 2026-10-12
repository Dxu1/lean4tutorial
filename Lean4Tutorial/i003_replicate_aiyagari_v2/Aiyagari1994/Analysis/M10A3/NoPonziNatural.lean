import Aiyagari1994.Analysis.M10A3.DebtBounds
import Aiyagari1994.Analysis.M10A3.LowBlock
import Aiyagari1994.Budget.EffectiveLimit

/-! NP03: No-Ponzi implies the natural original-asset floor on adapted IID paths. -/

open Filter Finset MeasureTheory Set
open scoped ENNReal Topology

namespace Aiyagari1994.M10A3
noncomputable section

/-- On the infinite IID product space, an adapted feasible original-asset plan with a finite
nonnegative discounted terminal limit satisfies the natural debt floor at every date a.s. -/
theorem noPonzi_implies_naturalBound_ae
    (i : IncomeData) (_hsupp : IncomeSupport i) (hnd : IncomeNondegenerate i)
    (r w : ℝ) (hr : 0 < r) (hw : 0 < w) (p : AdaptedOriginalPlan i)
    (hc : ∀ t : ℕ, ∀ᵐ omega ∂iidPathLaw i, 0 ≤ p.consumption t omega)
    (hbudget : ∀ t : ℕ, ∀ᵐ omega ∂iidPathLaw i,
      p.consumption t omega + p.asset (t + 1) omega =
        (1 + r) * p.asset t omega + w * (omega t : ℝ))
    (hnoPonzi : ∀ᵐ omega ∂iidPathLaw i, ∃ L : ℝ, 0 ≤ L ∧
      Tendsto (fun T : ℕ ↦ (1 + r)⁻¹ ^ T * p.asset (T + 1) omega)
        atTop (nhds L)) :
    ∀ t : ℕ, ∀ᵐ omega ∂iidPathLaw i,
      -naturalLimit i.lower w r ≤ p.asset t omega := by
  have hcAll : ∀ᵐ omega ∂iidPathLaw i, ∀ t : ℕ, 0 ≤ p.consumption t omega :=
    MeasureTheory.ae_all_iff.mpr hc
  have hbudgetAll : ∀ᵐ omega ∂iidPathLaw i, ∀ t : ℕ,
      p.consumption t omega + p.asset (t + 1) omega =
        (1 + r) * p.asset t omega + w * (omega t : ℝ) :=
    MeasureTheory.ae_all_iff.mpr hbudget
  have hgood : ∀ᵐ omega ∂iidPathLaw i,
      (∀ t : ℕ, 0 ≤ p.consumption t omega) ∧
      (∀ t : ℕ, p.consumption t omega + p.asset (t + 1) omega =
        (1 + r) * p.asset t omega + w * (omega t : ℝ)) ∧
      (∃ L : ℝ, 0 ≤ L ∧
        Tendsto (fun T : ℕ ↦ (1 + r)⁻¹ ^ T * p.asset (T + 1) omega)
          atTop (nhds L)) := by
    filter_upwards [hcAll, hbudgetAll, hnoPonzi] with omega hcOmega hbudgetOmega hnpOmega
    exact ⟨hcOmega, hbudgetOmega, hnpOmega⟩
  intro t
  by_contra hfloor
  have hbadNe : iidPathLaw i
      {omega | p.asset t omega < -naturalLimit i.lower w r} ≠ 0 := by
    intro hzero
    apply hfloor
    rw [MeasureTheory.ae_iff]
    simpa [not_le] using hzero
  have hbadUnion :
      {omega | p.asset t omega < -naturalLimit i.lower w r} =
        ⋃ n : ℕ, {omega | p.asset t omega ≤
          -naturalLimit i.lower w r - 1 / (n + 1 : ℝ)} := by
    ext omega
    constructor
    · intro hbad
      have hdiff : 0 < -naturalLimit i.lower w r - p.asset t omega :=
        sub_pos.mpr hbad
      obtain ⟨n, hn⟩ := exists_nat_one_div_lt
        hdiff
      exact Set.mem_iUnion.mpr ⟨n, by
        dsimp only [Set.mem_setOf_eq]
        linarith⟩
    · intro homega
      rcases Set.mem_iUnion.mp homega with ⟨n, hn⟩
      have hpos : 0 < (1 / (n + 1 : ℝ)) := by positivity
      dsimp only [Set.mem_setOf_eq] at hn
      exact lt_of_le_of_lt hn (sub_lt_self _ hpos)
  have hunionNe : iidPathLaw i
      (⋃ n : ℕ, {omega | p.asset t omega ≤
        -naturalLimit i.lower w r - 1 / (n + 1 : ℝ)}) ≠ 0 := by
    rwa [← hbadUnion]
  obtain ⟨n, hnPos⟩ :=
    MeasureTheory.exists_measure_pos_of_not_measure_iUnion_null hunionNe
  let eta : ℝ := 1 / (n + 1 : ℝ)
  have heta : 0 < eta := by dsimp [eta]; positivity
  let h : ℝ := eta * r / (8 * w)
  have hh : 0 < h := by dsimp [h]; positivity
  have hwidth : w * h / r < eta / 4 := by
    have hrne : r ≠ 0 := ne_of_gt hr
    have hwne : w ≠ 0 := ne_of_gt hw
    dsimp [h]
    field_simp [hrne, hwne]
    nlinarith [heta]
  have hgapPos : 0 < eta - w * h / r := by linarith
  let R : ℝ := 1 + r
  have hRone : 1 < R := by dsimp [R]; linarith
  have hpowEventually : ∀ᶠ N : ℕ in atTop,
      w * (i.upper - i.lower) / r /
          (eta - w * h / r) < R ^ N :=
    (tendsto_pow_atTop_atTop_of_one_lt hRone).eventually
      (eventually_gt_atTop (w * (i.upper - i.lower) / r /
        (eta - w * h / r)))
  obtain ⟨N, hNraw⟩ := hpowEventually.exists
  have hN : w * (i.upper - i.lower) / r <
      (1 + r) ^ N * (eta - w * h / r) := by
    dsimp [R] at hNraw
    exact (div_lt_iff₀ hgapPos).mp hNraw
  have hpastPos : 0 < iidPathLaw i
      {omega | p.assetPrefix t (fun j ↦ omega j.1) ≤
        -naturalLimit i.lower w r - eta} := by
    simpa [eta, AdaptedOriginalPlan.asset] using hnPos
  have hblockPos : 0 < iidPathLaw i {omega |
      p.assetPrefix t (fun j ↦ omega j.1) ≤
          -naturalLimit i.lower w r - eta ∧
      ∀ j < N, ((omega (t + j) : i.Labor) : ℝ) < i.lower + h} :=
    exists_past_and_finite_lowBlock i hnd t N h hh (p.assetPrefix t)
      (p.assetPrefix_measurable t) (-naturalLimit i.lower w r - eta) hpastPos
  have hfrequent : ∃ᵐ omega ∂iidPathLaw i,
      (p.assetPrefix t (fun j ↦ omega j.1) ≤
          -naturalLimit i.lower w r - eta ∧
        ∀ j < N, ((omega (t + j) : i.Labor) : ℝ) < i.lower + h) :=
    MeasureTheory.frequently_ae_iff.mpr hblockPos.ne'
  have hchosen := (hfrequent.and_eventually hgood).exists
  rcases hchosen with ⟨omega, ⟨hdebt, hlow⟩, hcOmega, hbudgetOmega, L, hL, hlimit⟩
  have hcoarse : ∀ s : ℕ, -w * i.upper / r ≤ p.asset s omega := by
    intro s
    exact coarseDebtBound_of_noPonzi_pathwise r w i.upper
      (fun k ↦ p.asset k omega) (fun k ↦ p.consumption k omega)
      (fun k ↦ (omega k : ℝ)) hr hw
      (fun k ↦ (omega k).2.2) hcOmega hbudgetOmega L hL hlimit s
  have hbelow : p.asset (t + N) omega < -w * i.upper / r := by
    apply lowBlock_forces_below_coarse r w i.lower i.upper eta h
      (fun k ↦ p.asset k omega) (fun k ↦ p.consumption k omega)
      (fun k ↦ (omega k : ℝ)) hr hw heta hh.le
      (lt_trans hwidth (by linarith [heta] : eta / 4 < eta)) t N hN
    · have hnat : -naturalLimit i.lower w r = -w * i.lower / r := by
        unfold naturalLimit
        ring
      rw [hnat] at hdebt
      exact hdebt
    · intro j hj
      exact (hlow j hj).le
    · intro j hj
      exact hcOmega (t + j)
    · intro j hj
      simpa [Nat.add_assoc] using hbudgetOmega (t + j)
  exact (not_lt_of_ge (hcoarse (t + N))) hbelow

end
end Aiyagari1994.M10A3
