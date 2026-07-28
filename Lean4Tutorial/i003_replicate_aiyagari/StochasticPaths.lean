import Lean4Tutorial.i003_replicate_aiyagari.Assumptions

/-!
# Canonical i.i.d. labor histories

These lemmas expose the probabilistic facts needed by the reverse direction
of Property 1 and by the later mixing proof.  In particular, low-income blocks
have explicitly computed, strictly positive probability.
-/

open Filter MeasureTheory ProbabilityTheory Set Topology
open scoped BigOperators ENNReal ProbabilityTheory

namespace Aiyagari1994

noncomputable section

/-- A finite block in which every labor realization lies within epsilon of
the lower support endpoint. -/
def lowerLaborBlock (M : HouseholdPrimitives)
    (t n : ℕ) (ε : ℝ) : Set LaborHistory :=
  Set.pi (Finset.Icc t (t + n))
    (fun _ => Icc M.lmin (min M.lmax (M.lmin + ε)))

/-- Labor coordinates in a finite block. -/
def laborBlockCoordinates (t n : ℕ) (ω : LaborHistory) :
    (Finset.Icc t (t + n) : Set ℕ) → ℝ :=
  fun i => ω i

/-- The product box corresponding to a low-income block. -/
def lowerLaborBox (M : HouseholdPrimitives)
    (t n : ℕ) (ε : ℝ) :
    Set ((Finset.Icc t (t + n) : Set ℕ) → ℝ) :=
  Set.pi univ (fun _ => Icc M.lmin (min M.lmax (M.lmin + ε)))

lemma lowerLaborBlock_eq_preimage (M : HouseholdPrimitives)
    (t n : ℕ) (ε : ℝ) :
    lowerLaborBlock M t n ε =
      laborBlockCoordinates t n ⁻¹' lowerLaborBox M t n ε := by
  ext ω
  simp only [lowerLaborBlock, lowerLaborBox, Set.mem_pi, Finset.mem_Icc,
    mem_preimage, mem_univ, true_implies, mem_Icc, Pi.le_def]
  constructor
  · intro h
    intro i
    exact h i i.2
  · intro h i hi
    exact h ⟨i, hi⟩

theorem canonicalLabor_map_eq (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (t : ℕ) :
    (laborHistoryMeasure M).map (canonicalLabor t) = M.laborLaw := by
  letI : IsProbabilityMeasure M.laborLaw := hM.labor_probability
  exact Measure.infinitePi_map_eval (fun _ : ℕ => M.laborLaw) t

/-- Every coordinate of the canonical history lies in the primitive support
almost surely. -/
theorem canonicalLabor_mem_support_ae (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (t : ℕ) :
    ∀ᵐ ω ∂laborHistoryMeasure M,
      canonicalLabor t ω ∈ Icc M.lmin M.lmax := by
  letI : IsProbabilityMeasure M.laborLaw := hM.labor_probability
  letI : ∀ _ : ℕ, IsProbabilityMeasure M.laborLaw := fun _ => hM.labor_probability
  letI : IsProbabilityMeasure (laborHistoryMeasure M) := by
    unfold laborHistoryMeasure
    infer_instance
  have hset : NullMeasurableSet
      {ω : LaborHistory | canonicalLabor t ω ∈ Icc M.lmin M.lmax}
      (laborHistoryMeasure M) := by
    exact (measurable_pi_apply t measurableSet_Icc).nullMeasurableSet
  apply (ae_iff_measure_eq hset).2
  calc
    (laborHistoryMeasure M)
          {ω : LaborHistory | canonicalLabor t ω ∈ Icc M.lmin M.lmax} =
        (laborHistoryMeasure M).map (canonicalLabor t)
          (Icc M.lmin M.lmax) := by
            symm
            apply Measure.map_apply_of_aemeasurable
            · exact (measurable_pi_apply t).aemeasurable
            · exact measurableSet_Icc
    _ = M.laborLaw (Icc M.lmin M.lmax) := by
      rw [canonicalLabor_map_eq M hM t]
    _ = 1 := hM.labor_support
    _ = (laborHistoryMeasure M) univ := by simp

/-- A random variable measurable with respect to labor history through date
`s` is independent of every finite block beginning at date `s+1`.  This is
the past/future independence lemma required by the reverse direction of
Property 1. -/
theorem measurable_past_indep_futureLaborBlock
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    {X : LaborHistory → ℝ} (s n : ℕ)
    (hX : @Measurable LaborHistory ℝ (canonicalLaborFiltration s)
      inferInstance X) :
    IndepFun X (laborBlockCoordinates (s + 1) n) (laborHistoryMeasure M) := by
  letI : IsProbabilityMeasure M.laborLaw := hM.labor_probability
  letI : ∀ _ : ℕ, IsProbabilityMeasure M.laborLaw := fun _ => hM.labor_probability
  let S := Finset.range (s + 1)
  let T := Finset.Icc (s + 1) (s + 1 + n)
  have hX' : @Measurable LaborHistory ℝ
      (MeasurableSpace.comap (finiteLaborHistory s) inferInstance)
      inferInstance X := by
    change @Measurable LaborHistory ℝ
      (MeasurableSpace.comap (finiteLaborHistory s) inferInstance)
      inferInstance X at hX
    exact hX
  obtain ⟨g, hg, hfactor⟩ := hX'.exists_eq_measurable_comp
  have hcoords : iIndepFun (fun i : ℕ => canonicalLabor i)
      (laborHistoryMeasure M) := by
    have hraw := iIndepFun_infinitePi
      (P := fun _ : ℕ => M.laborLaw)
      (X := fun _ : ℕ => id) (fun _ => measurable_id)
    change iIndepFun (fun i : ℕ => canonicalLabor i)
      (laborHistoryMeasure M) at hraw
    exact hraw
  have hdisjoint : Disjoint S T := by
    refine Finset.disjoint_left.mpr ?_
    intro i hiS hiT
    have his : i < s + 1 := Finset.mem_range.mp hiS
    have hit : s + 1 ≤ i := (Finset.mem_Icc.mp hiT).1
    omega
  have hindep := hcoords.indepFun_finset S T hdisjoint
    (fun i => measurable_pi_apply i)
  have hcomp := hindep.comp hg measurable_id
  change IndepFun (g ∘ finiteLaborHistory s)
    (id ∘ laborBlockCoordinates (s + 1) n) (laborHistoryMeasure M) at hcomp
  rw [hfactor]
  simpa [Function.comp_def] using hcomp

/-- Independence gives the product formula for the intersection of a past
strict-inequality event with a future low-income block. -/
theorem measure_lt_inter_lowerLaborBlock
    (M : HouseholdPrimitives) (hM : HouseholdAssumptions M)
    {X : LaborHistory → ℝ} (s n : ℕ)
    (hX : @Measurable LaborHistory ℝ (canonicalLaborFiltration s)
      inferInstance X) (x ε : ℝ) :
    laborHistoryMeasure M
        ({ω | X ω < x} ∩ lowerLaborBlock M (s + 1) n ε) =
      laborHistoryMeasure M {ω | X ω < x} *
        laborHistoryMeasure M (lowerLaborBlock M (s + 1) n ε) := by
  have hindep := measurable_past_indep_futureLaborBlock M hM s n hX
  have hbox : MeasurableSet (lowerLaborBox M (s + 1) n ε) :=
    MeasurableSet.univ_pi (fun _ => measurableSet_Icc)
  have hproduct := hindep.measure_inter_preimage_eq_mul
    (Iio x) (lowerLaborBox M (s + 1) n ε) measurableSet_Iio hbox
  rw [lowerLaborBlock_eq_preimage M (s + 1) n ε]
  change laborHistoryMeasure M
      ({ω | X ω < x} ∩
        laborBlockCoordinates (s + 1) n ⁻¹' lowerLaborBox M (s + 1) n ε) =
    laborHistoryMeasure M {ω | X ω < x} *
      laborHistoryMeasure M
        (laborBlockCoordinates (s + 1) n ⁻¹' lowerLaborBox M (s + 1) n ε)
  change laborHistoryMeasure M
      ({ω | X ω < x} ∩
        laborBlockCoordinates (s + 1) n ⁻¹' lowerLaborBox M (s + 1) n ε) =
    laborHistoryMeasure M {ω | X ω < x} *
      laborHistoryMeasure M
        (laborBlockCoordinates (s + 1) n ⁻¹' lowerLaborBox M (s + 1) n ε)
    at hproduct
  exact hproduct

theorem measure_lowerLaborBlock (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (t n : ℕ) (ε : ℝ) :
    laborHistoryMeasure M (lowerLaborBlock M t n ε) =
      ∏ i ∈ Finset.Icc t (t + n),
        M.laborLaw (Icc M.lmin (min M.lmax (M.lmin + ε))) := by
  letI : IsProbabilityMeasure M.laborLaw := hM.labor_probability
  apply Measure.infinitePi_pi
  intro i hi
  exact measurableSet_Icc

/-- Lower-support reachability and independence imply positive probability of
every finite low-income block. -/
theorem lowerLaborBlock_pos (M : HouseholdPrimitives)
    (hM : HouseholdAssumptions M) (hreach : LaborReachability M)
    (t n : ℕ) {ε : ℝ} (hε : 0 < ε) :
    0 < laborHistoryMeasure M (lowerLaborBlock M t n ε) := by
  rw [measure_lowerLaborBlock M hM]
  rw [pos_iff_ne_zero]
  apply (Finset.prod_ne_zero_iff).2
  intro i hi
  exact ne_of_gt (hreach.lower ε hε)

end

end Aiyagari1994
