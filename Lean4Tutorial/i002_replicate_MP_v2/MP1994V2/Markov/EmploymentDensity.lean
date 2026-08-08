import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Markov.EmploymentTransitionMass

/-!
# MP1994 v2: optional density representations

The core transition is measure-valued. These structures are optional witnesses
used only to recover the paper's density notation for equation (35).
-/

open MeasureTheory Set

namespace MP1994V2

/-- An optional Lebesgue-density representation of the primitive shock law. -/
structure ShockDensityRepresentation (P : Primitives) where
  density : ℝ → ENNReal
  measurable_density : Measurable density
  shock_eq : P.shock = volume.withDensity density

/-- An optional decomposition of employment into an interior density and the
separately tracked atom at `epsUpper`. -/
structure EmploymentDensityRepresentation
    {P : Primitives} {ι : Type*} [Fintype ι]
    {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}
    (N : FiniteMarkovEmploymentDistribution P E i) where
  interiorDensity : ℝ → ENNReal
  measurable_interiorDensity : Measurable interiorDensity
  upperMass : ENNReal
  measure_eq :
    N.measure = volume.withDensity interiorDensity +
      upperMass • Measure.dirac P.epsUpper
  density_zero_outside :
    interiorDensity =ᵐ[volume]
      (Ico (E.cutoff i) P.epsUpper).indicator interiorDensity

namespace EmploymentDensityRepresentation

variable {P : Primitives} {ι : Type*} [Fintype ι]
  {K : FiniteAggregateProcess P ι} {E : FiniteMarkovEquilibrium P K} {i : ι}
  {N : FiniteMarkovEmploymentDistribution P E i}

/-- The separately recorded upper mass is the actual current employment mass
at the upper support point. The Lebesgue-density component has no atom. -/
theorem measure_singleton_epsUpper_eq
    (ND : EmploymentDensityRepresentation N) :
    N.measure {P.epsUpper} = ND.upperMass := by
  rw [ND.measure_eq, Measure.add_apply, Measure.smul_apply]
  rw [MeasureTheory.withDensity_apply ND.interiorDensity
    (measurableSet_singleton P.epsUpper)]
  simp

end EmploymentDensityRepresentation

namespace ShockAssumptions

variable {P : Primitives}

/-- Atomlessness of the primitive shock law excludes an upper-support atom
(and, in fact, an atom at every singleton). -/
theorem shock_singleton_eq_zero (D : ShockAssumptions P) (eps : ℝ) :
    P.shock {eps} = 0 := by
  letI : NullSingletonClass P.shock := D.noAtoms
  simp

end ShockAssumptions

/-- Interior density after cutoff re-evaluation and incumbent redraw. -/
noncomputable def nextInteriorDensity
    (DP : DiscreteEmploymentParameters)
    (shockDensity currentDensity : ℝ → ENNReal)
    (survivingMass : ENNReal) (cutoff epsUpper eps : ℝ) : ENNReal :=
  if eps ∈ Ico cutoff epsUpper then
    (((1 - DP.redrawProb : NNReal) : ENNReal) * currentDensity eps) +
      (DP.redrawProb : ENNReal) * survivingMass * shockDensity eps
  else 0

/-- The upper-support atom retains non-redrawing incumbents and receives the
supplied creation mass. -/
noncomputable def nextUpperMass
    (DP : DiscreteEmploymentParameters) (upperMass creationMass : ENNReal) : ENNReal :=
  ((1 - DP.redrawProb : NNReal) : ENNReal) * upperMass + creationMass

theorem measurable_nextInteriorDensity
    (DP : DiscreteEmploymentParameters)
    {shockDensity currentDensity : ℝ → ENNReal}
    (hShock : Measurable shockDensity) (hCurrent : Measurable currentDensity)
    (survivingMass : ENNReal) (cutoff epsUpper : ℝ) :
    Measurable (nextInteriorDensity DP shockDensity currentDensity
      survivingMass cutoff epsUpper) := by
  unfold nextInteriorDensity
  have hInside : Measurable (fun eps =>
      (((1 - DP.redrawProb : NNReal) : ENNReal) * currentDensity eps) +
        (DP.redrawProb : ENNReal) * survivingMass * shockDensity eps) := by
    fun_prop
  exact hInside.piecewise measurableSet_Ico measurable_const

theorem nextInteriorDensity_of_mem
    (DP : DiscreteEmploymentParameters)
    (shockDensity currentDensity : ℝ → ENNReal)
    (survivingMass : ENNReal) {cutoff epsUpper eps : ℝ}
    (h : eps ∈ Ico cutoff epsUpper) :
    nextInteriorDensity DP shockDensity currentDensity survivingMass
        cutoff epsUpper eps =
      (((1 - DP.redrawProb : NNReal) : ENNReal) * currentDensity eps) +
        (DP.redrawProb : ENNReal) * survivingMass * shockDensity eps := by
  simp [nextInteriorDensity, h]

theorem nextInteriorDensity_of_not_mem
    (DP : DiscreteEmploymentParameters)
    (shockDensity currentDensity : ℝ → ENNReal)
    (survivingMass : ENNReal) {cutoff epsUpper eps : ℝ}
    (h : eps ∉ Ico cutoff epsUpper) :
    nextInteriorDensity DP shockDensity currentDensity survivingMass
        cutoff epsUpper eps = 0 := by
  simp [nextInteriorDensity, h]

end MP1994V2
