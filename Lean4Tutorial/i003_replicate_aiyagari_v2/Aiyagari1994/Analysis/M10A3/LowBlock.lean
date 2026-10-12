import Aiyagari1994.Analysis.M10A3.PathSpace

/-! Positive-probability finite low-income blocks after a past-measurable event. -/

open Finset MeasureTheory ProbabilityTheory Set
open scoped ENNReal ProbabilityTheory

namespace Aiyagari1994.M10A3
noncomputable section

/-- A positive-probability event determined by dates before `t` remains possible jointly with
any prescribed finite block of lower-endpoint neighborhoods starting at `t`. -/
theorem exists_past_and_finite_lowBlock
    (i : IncomeData) (hnd : IncomeNondegenerate i)
    (t N : ℕ) (h : ℝ) (hh : 0 < h)
    (past : (↑(range t) → i.Labor) → ℝ)
    (hpastMeas : Measurable past) (b : ℝ)
    (hpastPos : 0 < iidPathLaw i
      {omega | past (fun j ↦ omega j.1) ≤ b}) :
    0 < iidPathLaw i {omega |
      past (fun j ↦ omega j.1) ≤ b ∧
      ∀ j < N, ((omega (t + j) : i.Labor) : ℝ) < i.lower + h} := by
  classical
  let S : Finset ℕ := range t
  let T : Finset ℕ := Ico t (t + N)
  let X : IIDPath i → (↑S → i.Labor) :=
    fun omega j ↦ omega j.1
  let Y : IIDPath i → (↑T → i.Labor) :=
    fun omega j ↦ omega j.1
  let D : Set (↑S → i.Labor) :=
    {x | past (fun j ↦ x ⟨j.1, by simpa [S] using j.2⟩) ≤ b}
  let U : Set (↑T → i.Labor) :=
    {x | ∀ j, ((x j : i.Labor) : ℝ) < i.lower + h}
  have hST : Disjoint S T := by
    apply Finset.disjoint_left.mpr
    intro a haS haT
    simp [S] at haS
    simp [T] at haT
    omega
  have hcoords := iidPath_independent i
  have hXY : IndepFun X Y (iidPathLaw i) := by
    simpa [X, Y] using
      hcoords.indepFun_finset S T hST (fun _ ↦ measurable_pi_apply _)
  have hD : MeasurableSet D := by
    apply measurableSet_le
    · exact hpastMeas.comp (by fun_prop)
    · fun_prop
  have hU : MeasurableSet U := by
    have hm (j : ↑T) : Measurable (fun x : (↑T → i.Labor) ↦ ((x j : i.Labor) : ℝ)) :=
      continuous_subtype_val.measurable.comp (measurable_pi_apply j)
    have hj (j : ↑T) : MeasurableSet
        {x : (↑T → i.Labor) | ((x j : i.Labor) : ℝ) < i.lower + h} :=
      measurableSet_lt (hm j) measurable_const
    change MeasurableSet
      {x : (↑T → i.Labor) |
        ∀ j, ((x j : i.Labor) : ℝ) < i.lower + h}
    rw [show {x : (↑T → i.Labor) |
        ∀ j, ((x j : i.Labor) : ℝ) < i.lower + h} =
        ⋂ j : ↑T, {x | ((x j : i.Labor) : ℝ) < i.lower + h} by ext; simp]
    exact MeasurableSet.iInter hj
  have hlowerPos : 0 < (i.law : Measure i.Labor)
      {l | (l : ℝ) < i.lower + h} := hnd.lower_mass h hh
  have hYPos : 0 < iidPathLaw i (Y ⁻¹' U) := by
    have hmap : (iidPathLaw i).map Y = Measure.pi
        (fun _ : ↑T ↦ (i.law : Measure i.Labor)) := by
      dsimp [iidPathLaw, Y]
      exact Measure.infinitePi_map_restrict
        (fun _ : ℕ ↦ (i.law : Measure i.Labor))
    have hpi : 0 < Measure.pi
        (fun _ : ↑T ↦ (i.law : Measure i.Labor)) U := by
      have hUeq : U = Set.pi Set.univ
          (fun _ : ↑T ↦
            {l : i.Labor | (l : ℝ) < i.lower + h}) := by
        ext x
        simp [U]
      rw [hUeq, Measure.pi_pi]
      rw [pos_iff_ne_zero, Finset.prod_ne_zero_iff]
      intro j hj
      exact hlowerPos.ne'
    rw [← hmap] at hpi
    rw [Measure.map_apply (by fun_prop) hU] at hpi
    exact hpi
  have hXPos : 0 < iidPathLaw i (X ⁻¹' D) := by
    simpa [X, D, S] using hpastPos
  have hinterPos : 0 < iidPathLaw i (X ⁻¹' D ∩ Y ⁻¹' U) := by
    rw [hXY.measure_inter_preimage_eq_mul D U hD hU]
    exact ENNReal.mul_pos hXPos.ne' hYPos.ne'
  convert hinterPos using 1
  congr 1
  ext omega
  simp only [Set.mem_inter_iff, Set.mem_preimage, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hDomega, hUomega⟩
    refine ⟨?_, ?_⟩
    · exact hDomega
    · change ∀ j : ↑T, ((omega j.1 : i.Labor) : ℝ) < i.lower + h
      intro j
      have hjmem : j.1 ∈ Finset.Ico t (t + N) := by simpa [T] using j.2
      have hjlo : t ≤ j.1 := (Finset.mem_Ico.mp hjmem).1
      have hjhi : j.1 < t + N := (Finset.mem_Ico.mp hjmem).2
      obtain ⟨k, hk⟩ := Nat.exists_eq_add_of_le hjlo
      rw [hk]
      exact hUomega k (by omega)
  · rintro ⟨hDomega, hlow⟩
    refine ⟨hDomega, ?_⟩
    intro j hj
    exact hlow ⟨t + j, by simp [T, hj]⟩

end
end Aiyagari1994.M10A3
