import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentCreation

/-!
# MP1994 v2: staged employment destruction

Destruction is split into two sequentially disjoint stages: immediate loss at
the next aggregate-state cutoff, then unsuccessful redraws among the remaining
incumbents.  This ordering prevents double counting.
-/

open MeasureTheory Set

namespace MP1994V2
namespace FiniteMarkovEmploymentDistribution

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}

/-- Incumbents destroyed immediately by the next aggregate-state cutoff. -/
noncomputable def aggregateCutoffDestructionMass
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) : ENNReal :=
  N.measure (Iio (E.cutoff j))

/-- Aggregate survivors that redraw below the next-state cutoff. -/
noncomputable def redrawDestructionMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (_D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) : ENNReal :=
  (DP.redrawProb : ENNReal) * N.survivingMass j *
    P.shock (Iio (E.cutoff j))

/-- Total destruction across the two disjoint stages. -/
noncomputable def totalDestructionMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters)
    (j : ι) : ENNReal :=
  N.aggregateCutoffDestructionMass j + N.redrawDestructionMass D DP j

/-- The shock law partitions into draws below the cutoff and draws in the
closed survival interval. -/
theorem shock_belowCutoff_add_shockSurviving_eq_one
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (j : ι) :
    P.shock (Iio (E.cutoff j)) +
      P.shock (Icc (E.cutoff j) P.epsUpper) = 1 := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  have hIic : P.shock (Iic P.epsUpper) = 1 := by
    rw [← compl_Ioi, measure_compl measurableSet_Ioi]
    · simp [D.upperSupport]
    · simpa [D.upperSupport]
  have hUnion :
      Iic P.epsUpper =
        Iio (E.cutoff j) ∪ Icc (E.cutoff j) P.epsUpper := by
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
  have hDisjoint :
      Disjoint (Iio (E.cutoff j)) (Icc (E.cutoff j) P.epsUpper) :=
    Set.disjoint_left.2 fun _ hlt hge => (not_lt_of_ge hge.1) hlt
  rw [hUnion, measure_union hDisjoint measurableSet_Icc] at hIic
  exact hIic

/-- Atomlessness bridges the strict cutoff event used by destruction to the
project CDF, which is defined on the weak event `Iic`. -/
theorem shock_Iio_cutoff_eq_cdf
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (j : ι) :
    (P.shock (Iio (E.cutoff j))).toReal = P.cdf (E.cutoff j) := by
  have hUnion : Iic (E.cutoff j) = Iio (E.cutoff j) ∪ {E.cutoff j} := by
    ext x
    simp [lt_or_eq_of_le]
  have hDisjoint : Disjoint (Iio (E.cutoff j)) ({E.cutoff j} : Set ℝ) := by
    exact Set.disjoint_left.2 fun _ hlt heq =>
      (ne_of_lt hlt) (Set.mem_singleton_iff.mp heq)
  rw [Primitives.cdf, hUnion,
    measure_union hDisjoint (measurableSet_singleton (E.cutoff j))]
  simp [D.shock_singleton_eq_zero]

/-- Redraw survival and redraw destruction exhaust the redraw stage. -/
theorem redrawSurvivalMass_add_redrawDestructionMass_eq
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    (DP.redrawProb : ENNReal) * N.survivingMass j *
        P.shock (Icc (E.cutoff j) P.epsUpper) +
      N.redrawDestructionMass D DP j =
        (DP.redrawProb : ENNReal) * N.survivingMass j := by
  rw [redrawDestructionMass]
  calc
    (DP.redrawProb : ENNReal) * N.survivingMass j *
          P.shock (Icc (E.cutoff j) P.epsUpper) +
        (DP.redrawProb : ENNReal) * N.survivingMass j *
          P.shock (Iio (E.cutoff j)) =
      (DP.redrawProb : ENNReal) * N.survivingMass j *
        (P.shock (Icc (E.cutoff j) P.epsUpper) +
          P.shock (Iio (E.cutoff j))) := by rw [mul_add]
    _ = (DP.redrawProb : ENNReal) * N.survivingMass j := by
      rw [add_comm, N.shock_belowCutoff_add_shockSurviving_eq_one D j, mul_one]

/-- Incumbent survivors plus redraw destruction recover all aggregate
survivors. -/
theorem incumbentNextMass_add_redrawDestructionMass_eq_survivingMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.incumbentNextMass D DP j + N.redrawDestructionMass D DP j =
      N.survivingMass j := by
  rw [N.incumbentNextMass_eq D DP j]
  rw [add_assoc, N.redrawSurvivalMass_add_redrawDestructionMass_eq D DP j]
  rw [← add_mul]
  have hProb :
      ((1 - DP.redrawProb : NNReal) : ENNReal) +
          (DP.redrawProb : ENNReal) = 1 := by
    exact_mod_cast tsub_add_cancel_of_le DP.redrawProb_le_one
  rw [hProb, one_mul]

/-- Staged destruction is exhaustive and non-overlapping: surviving
incumbents plus total destruction exactly recover current employment. -/
theorem incumbentNextMass_add_totalDestructionMass_eq_currentMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.incumbentNextMass D DP j + N.totalDestructionMass D DP j =
      N.currentMass := by
  rw [totalDestructionMass, aggregateCutoffDestructionMass]
  calc
    N.incumbentNextMass D DP j +
        (N.measure (Iio (E.cutoff j)) + N.redrawDestructionMass D DP j) =
      N.measure (Iio (E.cutoff j)) +
        (N.incumbentNextMass D DP j + N.redrawDestructionMass D DP j) := by
          ac_rfl
    _ = N.measure (Iio (E.cutoff j)) + N.survivingMass j := by
      rw [N.incumbentNextMass_add_redrawDestructionMass_eq_survivingMass D DP j]
    _ = N.currentMass := (N.currentMass_eq_belowCutoff_add_survivingMass j).symm

/-- Measure-valued equation (37), with the shock law on the strict cutoff
event.  Its real form below rewrites this probability as the induced CDF. -/
theorem equation37_ennreal
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.totalDestructionMass D DP j =
      N.measure (Iio (E.cutoff j)) +
        (DP.redrawProb : ENNReal) * N.survivingMass j *
          P.shock (Iio (E.cutoff j)) := rfl

theorem aggregateCutoffDestructionMass_le_currentMass
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.aggregateCutoffDestructionMass j ≤ N.currentMass := by
  unfold aggregateCutoffDestructionMass currentMass
  exact measure_mono (subset_univ _)

theorem redrawDestructionMass_le_survivingMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.redrawDestructionMass D DP j ≤ N.survivingMass j := by
  rw [← N.incumbentNextMass_add_redrawDestructionMass_eq_survivingMass D DP j]
  exact le_add_self

theorem totalDestructionMass_le_currentMass
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.totalDestructionMass D DP j ≤ N.currentMass := by
  rw [← N.incumbentNextMass_add_totalDestructionMass_eq_currentMass D DP j]
  exact le_add_self

theorem totalDestructionMass_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    N.totalDestructionMass D DP j ≠ ⊤ :=
  ne_of_lt ((N.totalDestructionMass_le_currentMass D DP j).trans_lt
    (lt_top_iff_ne_top.2 N.currentMass_ne_top))

theorem survivingMass_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.survivingMass j ≠ ⊤ :=
  ne_of_lt ((N.survivingMass_le_currentMass j).trans_lt
    (lt_top_iff_ne_top.2 N.currentMass_ne_top))

theorem belowCutoffMass_ne_top
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    N.measure (Iio (E.cutoff j)) ≠ ⊤ :=
  ne_of_lt ((measure_mono (subset_univ _)).trans_lt
    (lt_top_iff_ne_top.2 N.currentMass_ne_top))

theorem survivingMass_toReal_eq_currentMass_sub_belowCutoff
    (N : FiniteMarkovEmploymentDistribution P E i) (j : ι) :
    (N.survivingMass j).toReal =
      N.employmentMass - (N.measure (Iio (E.cutoff j))).toReal := by
  change (N.survivingMass j).toReal =
    (N.measure univ).toReal - (N.measure (Iio (E.cutoff j))).toReal
  have h := congrArg ENNReal.toReal (N.currentMass_eq_belowCutoff_add_survivingMass j)
  rw [ENNReal.toReal_add (N.belowCutoffMass_ne_top j) (N.survivingMass_ne_top j)] at h
  change (N.measure univ).toReal =
    (N.measure (Iio (E.cutoff j))).toReal + (N.survivingMass j).toReal at h
  linarith

/-- Paper-facing real equation (37).  The redraw coefficient is the explicit
one-period `redrawProb`, never the continuous-time rate `P.lambda`. -/
theorem equation37
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι) :
    (N.totalDestructionMass D DP j).toReal =
      (N.measure (Iio (E.cutoff j))).toReal +
        (DP.redrawProb : ℝ) * P.cdf (E.cutoff j) *
          (N.employmentMass -
            (N.measure (Iio (E.cutoff j))).toReal) := by
  rw [equation37_ennreal, ENNReal.toReal_add (N.belowCutoffMass_ne_top j)]
  · rw [ENNReal.toReal_mul, ENNReal.toReal_mul,
      N.shock_Iio_cutoff_eq_cdf D j,
      N.survivingMass_toReal_eq_currentMass_sub_belowCutoff j]
    simp only [ENNReal.coe_toReal]
    ring
  · exact ENNReal.mul_ne_top
      (ENNReal.mul_ne_top (by simp) (N.survivingMass_ne_top j))
      (by
        letI : IsProbabilityMeasure P.shock := D.isProbability
        exact ne_of_lt (measure_lt_top P.shock _))

theorem totalDestructionMass_of_redrawProb_eq_zero
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι)
    (hZero : DP.redrawProb = 0) :
    N.totalDestructionMass D DP j = N.aggregateCutoffDestructionMass j := by
  simp [totalDestructionMass, redrawDestructionMass, hZero]

theorem totalDestructionMass_of_no_aggregateCutoff_loss
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι)
    (hZero : N.measure (Iio (E.cutoff j)) = 0) :
    N.totalDestructionMass D DP j = N.redrawDestructionMass D DP j := by
  simp [totalDestructionMass, aggregateCutoffDestructionMass, hZero]

theorem incumbentNextMass_eq_currentMass_of_no_destruction
    (N : FiniteMarkovEmploymentDistribution P E i)
    (D : ShockAssumptions P) (DP : DiscreteEmploymentParameters) (j : ι)
    (hRedraw : DP.redrawProb = 0)
    (hCutoff : N.measure (Iio (E.cutoff j)) = 0) :
    N.incumbentNextMass D DP j = N.currentMass := by
  have hTotal : N.totalDestructionMass D DP j = 0 := by
    simp [totalDestructionMass, aggregateCutoffDestructionMass,
      redrawDestructionMass, hRedraw, hCutoff]
  simpa [hTotal] using N.incumbentNextMass_add_totalDestructionMass_eq_currentMass D DP j

end FiniteMarkovEmploymentDistribution

namespace StateEmploymentDistribution

variable {P : Primitives} {T : TwoStatePrimitives P}
variable {A : CoreEconomicAssumptions P} {D : ShockAssumptions P}
variable {TA : TwoStateEconomicAssumptions P T} {M : MatchingAssumptions P}
variable {E : TwoStateValueEquilibrium P T} {s : AggregateState}

/-- Under the reviewed finite-state embedding, M10.3 aggregate-cutoff
destruction is exactly the M9.3 impact-destruction mass. -/
theorem m10_3_twoState_aggregateDestruction_embedding
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
    FN.aggregateCutoffDestructionMass j = N.impactDestructionMass j := by
  change N.measure
      (Iio ((E.toFiniteMarkovEquilibrium A D TA M).cutoff j)) =
    N.measure (Iio (E.reservationCutoff A D TA M j))
  rw [TwoStateValueEquilibrium.toFiniteMarkovEquilibrium_cutoff]

end StateEmploymentDistribution
end MP1994V2
