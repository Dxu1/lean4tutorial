import Mathlib.Topology.MetricSpace.Contracting
import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.MeasureTheory.Integral.BoundedContinuousFunction
import Mathlib.Probability.Kernel.Composition.MeasureComp
import Mathlib.Util.AssertNoSorry

/-! Milestone 00: generic API evidence only; no household or equilibrium theorem. -/
open MeasureTheory ProbabilityTheory Filter
open scoped NNReal ENNReal Topology ProbabilityTheory

namespace Aiyagari1994.Probes

abbrev State := ℝ≥0
abbrev ValueSpace := BoundedContinuousFunction State ℝ
abbrev CompactInterval := Set.Icc (0 : ℝ) 1

theorem value_complete : CompleteSpace ValueSpace := inferInstance

theorem sup_distance (f g : ValueSpace) (z : State) :
    dist (f z) (g z) ≤ dist f g := BoundedContinuousFunction.dist_coe_le_dist z

theorem state_complete : CompleteSpace State := inferInstance
theorem state_separable : TopologicalSpace.SeparableSpace State := inferInstance
theorem state_borel : BorelSpace State := inferInstance
theorem state_measurable_id : Measurable (id : State → State) := measurable_id

/-- Banach applied to the actual bounded-value space; contraction is a generic hypothesis. -/
theorem banach_on_values (T : ValueSpace → ValueSpace) (K : ℝ≥0)
    (hT : ContractingWith K T) : ∃! v : ValueSpace, T v = v := by
  exact ⟨hT.fixedPoint T, hT.fixedPoint_isFixedPt,
    fun _ hv => hT.fixedPoint_unique hv⟩

/-- A concrete inhabited contraction instance, independent of any economic primitives. -/
theorem zero_contraction : ContractingWith 0 (fun _ : ValueSpace => (0 : ValueSpace)) := by
  exact ⟨zero_lt_one, LipschitzWith.const 0⟩

theorem zero_fixed_point :
    zero_contraction.fixedPoint (fun _ : ValueSpace => (0 : ValueSpace)) = 0 := by
  exact (zero_contraction.fixedPoint_unique rfl).symm

theorem bounded_test_integrable (μ : ProbabilityMeasure State) (f : ValueSpace) :
    Integrable f (μ : Measure State) := f.integrable _

/-- General measurable pushforward with explicit integrability on both sides. -/
theorem pushforward_test (μ : ProbabilityMeasure State) (g : State → State)
    (hg : Measurable g) (f : ValueSpace) :
    Integrable f (μ.map hg.aemeasurable : Measure State) ∧
    Integrable (fun x => f (g x)) (μ : Measure State) ∧
    (∫ y, f y ∂(μ.map hg.aemeasurable : Measure State)) =
      ∫ x, f (g x) ∂(μ : Measure State) := by
  have hi : Integrable f ((μ : Measure State).map g) := f.integrable _
  refine ⟨hi, ?_, ?_⟩
  · exact (integrable_map_measure f.continuous.measurable.aestronglyMeasurable
      hg.aemeasurable).mp hi
  · exact integral_map hg.aemeasurable f.continuous.measurable.aestronglyMeasurable

theorem kernel_composition (κ η : Kernel State State) [IsMarkovKernel κ]
    [IsMarkovKernel η] : IsMarkovKernel (η ∘ₖ κ) := inferInstance

theorem kernel_identity (κ : Kernel State State) : κ ∘ₖ Kernel.id = κ :=
  Kernel.comp_id κ

theorem kernel_transport (μ : ProbabilityMeasure State) (g : State → State)
    (hg : Measurable g) :
    Kernel.deterministic g hg ∘ₘ (μ : Measure State) =
      (μ.map hg.aemeasurable : Measure State) :=
  Measure.deterministic_comp_eq_map hg

theorem deterministic_markov (g : State → State) (hg : Measurable g) :
    IsMarkovKernel (Kernel.deterministic g hg) := inferInstance

theorem transport_mass (κ : Kernel State State) [IsMarkovKernel κ]
    (μ : ProbabilityMeasure State) : (κ ∘ₘ (μ : Measure State)) Set.univ = 1 := by
  simp

theorem weak_test_convergence (μs : ℕ → ProbabilityMeasure State)
    (μ : ProbabilityMeasure State) (h : Tendsto μs atTop (𝓝 μ)) (f : ValueSpace) :
    Tendsto (fun n => ∫ x, f x ∂(μs n : Measure State)) atTop
      (𝓝 (∫ x, f x ∂(μ : Measure State))) :=
  ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mp h f

theorem compact_interval_laws : CompactSpace (ProbabilityMeasure CompactInterval) :=
  inferInstance

theorem individual_law_tight (μ : ProbabilityMeasure State) :
    IsTightMeasureSet {(μ : Measure State)} := isTightMeasureSet_singleton

theorem tight_family_compact (S : Set (ProbabilityMeasure State))
    (hS : IsTightMeasureSet {((μ : ProbabilityMeasure State) : Measure State) | μ ∈ S}) :
    IsCompact (closure S) := isCompact_closure_of_isTightMeasureSet hS

/-- Extended marginals can retain infinity at zero; no derivative is asserted. -/
theorem extended_zero_value : ∃ q : State → ℝ≥0∞, q 0 = ⊤ :=
  ⟨fun _ => ⊤, rfl⟩

end Aiyagari1994.Probes
