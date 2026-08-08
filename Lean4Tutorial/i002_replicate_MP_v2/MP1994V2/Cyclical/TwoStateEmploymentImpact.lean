import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateCutoffResults

/-!
# MP1994 v2: aggregate-shock employment impact

The impact operator implements the paper's timing convention: existing jobs
are restricted to the new survival region, while matching creates no mass at
the mathematical instant of the aggregate shock.
-/

open MeasureTheory Set

namespace MP1994V2

/-- A finite employment measure supported on jobs that survive in state s.
No density or positive interval-mass assumption is imposed. -/
structure StateEmploymentDistribution
    (P : Primitives) (T : TwoStatePrimitives P)
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) (s : AggregateState) where
  measure : Measure ℝ
  finite_measure : IsFiniteMeasure measure
  mass_le_one : measure univ ≤ 1
  supported_above_cutoff :
    measure (Iio (E.reservationCutoff A D TA M s)) = 0

namespace StateEmploymentDistribution

variable {P : Primitives} {T : TwoStatePrimitives P}
variable {A : CoreEconomicAssumptions P} {D : ShockAssumptions P}
variable {TA : TwoStateEconomicAssumptions P T} {M : MatchingAssumptions P}
variable {E : TwoStateValueEquilibrium P T} {s : AggregateState}

/-- Almost every employed match lies weakly above the current cutoff. -/
theorem ae_mem_Ici_cutoff
    (N : StateEmploymentDistribution P T A D TA M E s) :
    ∀ᵐ x ∂N.measure, x ∈ Ici (E.reservationCutoff A D TA M s) := by
  rw [ae_iff]
  change N.measure ((Ici (E.reservationCutoff A D TA M s))ᶜ) = 0
  simpa only [compl_Ici] using N.supported_above_cutoff

/-- Restrict the existing employment measure to jobs surviving the new state.
This definition contains no creation component. -/
noncomputable def afterAggregateShock
    (N : StateEmploymentDistribution P T A D TA M E s)
    (newState : AggregateState) :
    StateEmploymentDistribution P T A D TA M E newState := by
  letI : IsFiniteMeasure N.measure := N.finite_measure
  refine
    { measure :=
        N.measure.restrict
          (Ici (E.reservationCutoff A D TA M newState))
      finite_measure := inferInstance
      mass_le_one := ?_
      supported_above_cutoff := ?_ }
  · exact
      ((Measure.restrict_le_self :
        N.measure.restrict
            (Ici (E.reservationCutoff A D TA M newState)) ≤ N.measure)
          univ).trans N.mass_le_one
  · rw [Measure.restrict_apply measurableSet_Iio]
    simp only [Iio_inter_Ici, Ico_self, measure_empty]

/-- The post-shock employment measure is dominated by the pre-shock measure. -/
theorem afterAggregateShock_measure_le
    (N : StateEmploymentDistribution P T A D TA M E s)
    (newState : AggregateState) :
    (N.afterAggregateShock newState).measure ≤ N.measure :=
  Measure.restrict_le_self

/-- Impact destruction is exactly the pre-shock employment mass below the new
cutoff. -/
noncomputable def impactDestructionMass
    (N : StateEmploymentDistribution P T A D TA M E s)
    (newState : AggregateState) : ENNReal :=
  N.measure (Iio (E.reservationCutoff A D TA M newState))

/-- Impact creation is zero by the continuous-matching timing convention. -/
def impactCreationMass
    (_N : StateEmploymentDistribution P T A D TA M E s) : ENNReal :=
  0

@[simp] theorem impactCreationMass_eq_zero
    (N : StateEmploymentDistribution P T A D TA M E s) :
    N.impactCreationMass = 0 := rfl

/-- An upturn leaves a recession-supported employment measure unchanged. -/
theorem recession_to_boom_employmentMeasure_eq
    (N : StateEmploymentDistribution P T A D TA M E .recession) :
    (N.afterAggregateShock .boom).measure = N.measure := by
  apply Measure.restrict_eq_self_of_ae_mem
  filter_upwards [N.ae_mem_Ici_cutoff] with x hx
  exact (E.boom_cutoff_lt_recession_cutoff A D TA M).le.trans hx

/-- No incumbent job is destroyed on impact in a recession-to-boom move. -/
theorem recession_to_boom_impactDestruction_zero
    (N : StateEmploymentDistribution P T A D TA M E .recession) :
    N.impactDestructionMass .boom = 0 := by
  unfold impactDestructionMass
  apply measure_mono_null
    (show Iio (E.reservationCutoff A D TA M .boom) ⊆
        Iio (E.reservationCutoff A D TA M .recession) from
      Iio_subset_Iio (E.boom_cutoff_lt_recession_cutoff A D TA M).le)
  exact N.supported_above_cutoff

/-- Paper-facing upturn result: employment is unchanged, destruction is zero,
and impact creation is zero. -/
theorem recession_to_boom_no_impact_employment_change
    (N : StateEmploymentDistribution P T A D TA M E .recession) :
    (N.afterAggregateShock .boom).measure = N.measure ∧
      N.impactDestructionMass .boom = 0 ∧
      N.impactCreationMass = 0 :=
  ⟨N.recession_to_boom_employmentMeasure_eq,
    N.recession_to_boom_impactDestruction_zero, rfl⟩

/-- A boom-supported measure decomposes into recession survivors and the
destroyed interval [dB,dR). -/
theorem boom_to_recession_measure_decomposition
    (N : StateEmploymentDistribution P T A D TA M E .boom) :
    N.measure =
      N.measure.restrict
          (Ici (E.reservationCutoff A D TA M .recession)) +
        N.measure.restrict
          (Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession)) := by
  have hSelf :
      N.measure.restrict
          (Ici (E.reservationCutoff A D TA M .boom)) = N.measure :=
    Measure.restrict_eq_self_of_ae_mem N.ae_mem_Ici_cutoff
  have hUnion :
      Ici (E.reservationCutoff A D TA M .boom) =
        Ici (E.reservationCutoff A D TA M .recession) ∪
          Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession) := by
    ext x
    simp only [mem_Ici, mem_union, mem_Ico]
    constructor
    · intro hx
      by_cases hR : E.reservationCutoff A D TA M .recession ≤ x
      · exact Or.inl hR
      · exact Or.inr ⟨hx, lt_of_not_ge hR⟩
    · rintro (hx | hx)
      · exact (E.boom_cutoff_lt_recession_cutoff A D TA M).le.trans hx
      · exact hx.1
  have hDisjoint :
      Disjoint
        (Ici (E.reservationCutoff A D TA M .recession))
        (Ico (E.reservationCutoff A D TA M .boom)
          (E.reservationCutoff A D TA M .recession)) := by
    rw [Set.disjoint_left]
    intro x hxR hxBetween
    exact (not_lt_of_ge hxR) hxBetween.2
  calc
    N.measure =
        N.measure.restrict
          (Ici (E.reservationCutoff A D TA M .boom)) := hSelf.symm
    _ = N.measure.restrict
          (Ici (E.reservationCutoff A D TA M .recession)) +
        N.measure.restrict
          (Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession)) := by
      rw [hUnion, Measure.restrict_union hDisjoint measurableSet_Ico]

/-- The mass removed in a downturn is exactly employment in [dB,dR). -/
theorem boom_to_recession_impactDestruction_eq
    (N : StateEmploymentDistribution P T A D TA M E .boom) :
    N.impactDestructionMass .recession =
      N.measure
        (Ico (E.reservationCutoff A D TA M .boom)
          (E.reservationCutoff A D TA M .recession)) := by
  unfold impactDestructionMass
  have hUnion :
      Iio (E.reservationCutoff A D TA M .recession) =
        Iio (E.reservationCutoff A D TA M .boom) ∪
          Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession) := by
    ext x
    simp only [mem_Iio, mem_union, mem_Ico]
    constructor
    · intro hx
      by_cases hB : x < E.reservationCutoff A D TA M .boom
      · exact Or.inl hB
      · exact Or.inr ⟨le_of_not_gt hB, hx⟩
    · rintro (hx | hx)
      · exact hx.trans (E.boom_cutoff_lt_recession_cutoff A D TA M)
      · exact hx.2
  have hDisjoint :
      Disjoint
        (Iio (E.reservationCutoff A D TA M .boom))
        (Ico (E.reservationCutoff A D TA M .boom)
          (E.reservationCutoff A D TA M .recession)) := by
    rw [Set.disjoint_left]
    intro x hxBelow hxBetween
    exact (not_lt_of_ge hxBetween.1) hxBelow
  rw [hUnion, measure_union hDisjoint measurableSet_Ico,
    N.supported_above_cutoff, zero_add]

/-- Exact ENNReal employment accounting for a downturn impact. -/
theorem boom_to_recession_totalMass_accounting
    (N : StateEmploymentDistribution P T A D TA M E .boom) :
    (N.afterAggregateShock .recession).measure univ +
        N.measure
          (Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession)) =
      N.measure univ := by
  have hDecomposition :=
    congrArg (fun μ : Measure ℝ => μ univ)
      N.boom_to_recession_measure_decomposition
  simpa [afterAggregateShock, Measure.restrict_apply_univ] using
    hDecomposition.symm

/-- Strict positive interval mass gives a strict downturn employment loss. -/
theorem boom_to_recession_employmentMass_lt
    (N : StateEmploymentDistribution P T A D TA M E .boom)
    (hMass : 0 <
      N.measure
        (Ico (E.reservationCutoff A D TA M .boom)
          (E.reservationCutoff A D TA M .recession))) :
    (N.afterAggregateShock .recession).measure univ < N.measure univ := by
  letI : IsFiniteMeasure N.measure := N.finite_measure
  letI : IsFiniteMeasure (N.afterAggregateShock .recession).measure :=
    (N.afterAggregateShock .recession).finite_measure
  have hPostFinite :
      (N.afterAggregateShock .recession).measure univ ≠ ⊤ :=
    measure_ne_top _ _
  have hLt :
      (N.afterAggregateShock .recession).measure univ <
        (N.afterAggregateShock .recession).measure univ +
          N.measure
            (Ico (E.reservationCutoff A D TA M .boom)
              (E.reservationCutoff A D TA M .recession)) :=
    ENNReal.lt_add_right hPostFinite hMass.ne'
  rw [N.boom_to_recession_totalMass_accounting] at hLt
  exact hLt

/-- Real-valued employment mass. -/
noncomputable def employmentMass
    (N : StateEmploymentDistribution P T A D TA M E s) : ℝ :=
  (N.measure univ).toReal

/-- Real-valued unemployment mass, using a unit labor force. -/
noncomputable def unemploymentMass
    (N : StateEmploymentDistribution P T A D TA M E s) : ℝ :=
  1 - N.employmentMass

theorem employmentMass_nonneg
    (N : StateEmploymentDistribution P T A D TA M E s) :
    0 ≤ N.employmentMass :=
  ENNReal.toReal_nonneg

theorem employmentMass_le_one
    (N : StateEmploymentDistribution P T A D TA M E s) :
    N.employmentMass ≤ 1 := by
  unfold employmentMass
  simpa using ENNReal.toReal_mono (by simp : (1 : ENNReal) ≠ ⊤) N.mass_le_one

theorem unemploymentMass_nonneg
    (N : StateEmploymentDistribution P T A D TA M E s) :
    0 ≤ N.unemploymentMass := by
  unfold unemploymentMass
  linarith [N.employmentMass_le_one]

theorem unemploymentMass_le_one
    (N : StateEmploymentDistribution P T A D TA M E s) :
    N.unemploymentMass ≤ 1 := by
  unfold unemploymentMass
  linarith [N.employmentMass_nonneg]

theorem employmentMass_add_unemploymentMass
    (N : StateEmploymentDistribution P T A D TA M E s) :
    N.employmentMass + N.unemploymentMass = 1 := by
  unfold unemploymentMass
  ring

/-- Real-valued downturn unemployment jump equals the destroyed interval mass. -/
theorem boom_to_recession_unemploymentMass_eq
    (N : StateEmploymentDistribution P T A D TA M E .boom) :
    (N.afterAggregateShock .recession).unemploymentMass =
      N.unemploymentMass +
        (N.measure
          (Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession))).toReal := by
  letI : IsFiniteMeasure N.measure := N.finite_measure
  letI : IsFiniteMeasure (N.afterAggregateShock .recession).measure :=
    (N.afterAggregateShock .recession).finite_measure
  have hAccounting := N.boom_to_recession_totalMass_accounting
  have hPostFinite :
      (N.afterAggregateShock .recession).measure univ ≠ ⊤ :=
    measure_ne_top _ _
  have hDestroyedFinite :
      N.measure
          (Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession)) ≠ ⊤ :=
    measure_ne_top _ _
  have hReal := congrArg ENNReal.toReal hAccounting
  rw [ENNReal.toReal_add hPostFinite hDestroyedFinite] at hReal
  unfold unemploymentMass employmentMass
  linarith

/-- Real-valued upturn unemployment is unchanged on impact. -/
theorem recession_to_boom_unemploymentMass_eq
    (N : StateEmploymentDistribution P T A D TA M E .recession) :
    (N.afterAggregateShock .boom).unemploymentMass =
      N.unemploymentMass := by
  unfold unemploymentMass employmentMass
  rw [N.recession_to_boom_employmentMeasure_eq]

end StateEmploymentDistribution

namespace TwoStateValueEquilibrium

variable {P : Primitives} {T : TwoStatePrimitives P}

/-- M9.3 impact-asymmetry capstone, universally quantified over admissible
employment measures. -/
theorem m9_3_impact_asymmetry_capstone
    (A : CoreEconomicAssumptions P) (D : ShockAssumptions P)
    (TA : TwoStateEconomicAssumptions P T) (M : MatchingAssumptions P)
    (E : TwoStateValueEquilibrium P T) :
    (∀ N : StateEmploymentDistribution P T A D TA M E .recession,
      (N.afterAggregateShock .boom).measure = N.measure ∧
      N.impactDestructionMass .boom = 0 ∧
      N.impactCreationMass = 0) ∧
    (∀ N : StateEmploymentDistribution P T A D TA M E .boom,
      N.impactDestructionMass .recession =
          N.measure
            (Ico (E.reservationCutoff A D TA M .boom)
              (E.reservationCutoff A D TA M .recession)) ∧
      N.impactCreationMass = 0 ∧
      (0 < N.measure
          (Ico (E.reservationCutoff A D TA M .boom)
            (E.reservationCutoff A D TA M .recession)) →
        (N.afterAggregateShock .recession).measure univ <
          N.measure univ)) := by
  constructor
  · intro N
    exact N.recession_to_boom_no_impact_employment_change
  · intro N
    exact ⟨N.boom_to_recession_impactDestruction_eq, rfl,
      N.boom_to_recession_employmentMass_lt⟩

end TwoStateValueEquilibrium
end MP1994V2
