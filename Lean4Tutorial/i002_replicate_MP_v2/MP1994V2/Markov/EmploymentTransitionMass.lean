import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentTransition
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.TwoStateEmbedding
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Cyclical.TwoStateEmploymentImpact

/-!
# MP1994 v2: employment-transition mass identities

These are identities for the supplied transition operator. They are not the
creation/destruction accounting equations reserved for M10.3.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

noncomputable def currentMass
    (N : FiniteMarkovEmploymentDistribution P E i) : ENNReal := N.measure univ

noncomputable def incumbentNextMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) : ENNReal :=
  N.incumbentNextMeasure D DP j univ

noncomputable def rawNextMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal) : ENNReal :=
  N.rawNextMeasure D DP j creationMass univ

/-- Robust aggregate-cutoff re-evaluation decomposition, before subtraction. -/
theorem currentMass_eq_belowCutoff_add_survivingMass
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.currentMass = N.measure (Iio (E.cutoff j)) + N.survivingMass j := by
  have hUpper : ∀ᵐ x ∂N.measure, x ∈ Iic P.epsUpper := by
    rw [ae_iff]
    rw [show {x | x ∉ Iic P.epsUpper} = Ioi P.epsUpper by
      ext x
      simp]
    exact N.supported_below_upper
  have hRestrict : N.measure.restrict (Iic P.epsUpper) = N.measure :=
    Measure.restrict_eq_self_of_ae_mem hUpper
  have hIic :
      Iic P.epsUpper = Iio (E.cutoff j) ∪ Icc (E.cutoff j) P.epsUpper := by
    ext x
    simp only [mem_Iic, mem_union, mem_Iio, mem_Icc]
    constructor
    · intro hx
      by_cases hxd : x < E.cutoff j
      · exact Or.inl hxd
      · exact Or.inr ⟨le_of_not_gt hxd, hx⟩
    · rintro (hx | hx)
      · exact hx.le.trans (E.cutoff_lt_epsUpper j).le
      · exact hx.2
  have hDisjoint : Disjoint (Iio (E.cutoff j)) (Icc (E.cutoff j) P.epsUpper) := by
    exact Set.disjoint_left.2 fun _ hlt hge => (not_lt_of_ge hge.1) hlt
  have hMass := congrArg (fun μ : Measure ℝ => μ univ) hRestrict
  rw [Measure.restrict_apply_univ, hIic,
    measure_union hDisjoint measurableSet_Icc] at hMass
  simpa [currentMass, survivingMass, survivingMeasure] using hMass.symm

/-- Exact incumbent mass after no-redraw and surviving-redraw components. -/
theorem incumbentNextMass_eq
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.incumbentNextMass D DP j =
      ((1 - DP.redrawProb : NNReal) : ENNReal) * N.survivingMass j +
        (DP.redrawProb : ENNReal) * N.survivingMass j *
          P.shock (Icc (E.cutoff j) P.epsUpper) := by
  simp [incumbentNextMass, incumbentNextMeasure, Measure.add_apply]

/-- Exact full mass after adding the supplied creation atom. -/
theorem rawNextMass_eq
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (creationMass : ENNReal) :
    N.rawNextMass D DP j creationMass =
      N.incumbentNextMass D DP j + creationMass := by
  simp [rawNextMass, rawNextMeasure, incumbentNextMass, Measure.add_apply]

/-- With zero redraw probability, incumbents are exactly the cutoff restriction. -/
theorem incumbentNextMeasure_of_redrawProb_zero
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (hZero : DP.redrawProb = 0) :
    N.incumbentNextMeasure D DP j = N.survivingMeasure j := by
  simp [incumbentNextMeasure, noRedrawMeasure, redrawMeasure, hZero]

/-- With zero redraw and zero creation, the complete transition is cutoff
restriction and nothing else. -/
theorem rawNextMeasure_of_redrawProb_zero_creation_zero
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) (hZero : DP.redrawProb = 0) :
    N.rawNextMeasure D DP j 0 = N.survivingMeasure j := by
  rw [rawNextMeasure, N.incumbentNextMeasure_of_redrawProb_zero D DP j hZero]
  simp [upperCreationMeasure]

end FiniteMarkovEmploymentDistribution

namespace StateEmploymentDistribution

variable {P : Primitives} {T : TwoStatePrimitives P}
variable {A : CoreEconomicAssumptions P} {D : ShockAssumptions P}
variable {TA : TwoStateEconomicAssumptions P T} {M : MatchingAssumptions P}
variable {E : TwoStateValueEquilibrium P T} {s : AggregateState}

/-- The reviewed M9.3 impact operator is the zero-redraw/zero-creation
specialization of M10.2, provided the incumbent measure also satisfies the
explicit finite-state upper-support condition. -/
theorem m10_2_twoState_impact_embedding
    (N : StateEmploymentDistribution P T A D TA M E s)
    (hUpper : N.measure (Ioi P.epsUpper) = 0)
    (j : AggregateState) :
    let FE := E.toFiniteMarkovEquilibrium A D TA M
    let FN : FiniteMarkovEmploymentDistribution P FE s :=
      { measure := N.measure
        finite_measure := N.finite_measure
        mass_le_one := N.mass_le_one
        supported_above_cutoff := by
          change N.measure (Iio (E.reservationCutoff A D TA M s)) = 0
          exact N.supported_above_cutoff
        supported_below_upper := hUpper }
    FN.survivingMeasure j = (N.afterAggregateShock j).measure := by
  dsimp
  apply Measure.restrict_congr_set
  filter_upwards [show ∀ᵐ x ∂N.measure, x ≤ P.epsUpper by
    rw [ae_iff]
    rw [show {x : ℝ | ¬x ≤ P.epsUpper} = Ioi P.epsUpper by
      ext x
      simp]
    exact hUpper] with x hx
  rw [TwoStateValueEquilibrium.toFiniteMarkovEquilibrium_cutoff]
  apply propext
  constructor
  · intro hmem
    exact hmem.1
  · intro hmem
    exact ⟨hmem, hx⟩

end StateEmploymentDistribution
end MP1994V2
