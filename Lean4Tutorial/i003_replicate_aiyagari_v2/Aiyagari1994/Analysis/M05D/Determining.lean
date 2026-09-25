import Mathlib.MeasureTheory.Integral.BoundedContinuousFunction
import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure
import Mathlib.Topology.ContinuousMap.StoneWeierstrass
import Mathlib.Analysis.Calculus.Deriv.Polynomial
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-! Private one-dimensional determining-class support for M05D. -/
open MeasureTheory Set
open Filter
open scoped Topology Polynomial

namespace Aiyagari1994
noncomputable section

abbrev RealInterval (a b : ℝ) := Set.Icc a b

private theorem polynomial_eq_sub_monotoneOn
    (a b : ℝ) (p : ℝ[X]) :
    ∃ g h : C(RealInterval a b, ℝ),
      Monotone g ∧ Monotone h ∧ p.toContinuousMapOn (Set.Icc a b) = g - h := by
  let K : Set ℝ := p.derivative.eval '' Set.Icc a b
  have hK : IsCompact K := isCompact_Icc.image p.derivative.continuous
  have hKb : BddBelow K := hK.bddBelow
  obtain ⟨c, hc⟩ := hKb
  let M : ℝ := max 0 (-c)
  have hM : 0 ≤ M := le_max_left _ _
  let g0 : ℝ → ℝ := fun x ↦ p.eval x + M * x
  let h0 : ℝ → ℝ := fun x ↦ M * x
  have hg0 : MonotoneOn g0 (Set.Icc a b) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc a b)
    · exact (p.continuous.add (continuous_const.mul continuous_id)).continuousOn
    · intro x hx
      exact (p.hasDerivAt x).add ((hasDerivAt_id x).const_mul M) |>.differentiableAt
        |>.differentiableWithinAt
    · intro x hx
      have hx' : x ∈ Set.Icc a b := interior_subset hx
      have hpderiv : c ≤ p.derivative.eval x := hc ⟨x, hx', rfl⟩
      have hMc : -c ≤ M := le_max_right _ _
      have hderiv : HasDerivAt g0 (p.derivative.eval x + M) x := by
        change HasDerivAt
          ((fun y ↦ p.eval y) + fun y ↦ M * y) (p.derivative.eval x + M) x
        simpa using (p.hasDerivAt x).add ((hasDerivAt_id x).const_mul M)
      change 0 ≤ deriv g0 x
      rw [hderiv.deriv]
      linarith
  have hh0 : MonotoneOn h0 (Set.Icc a b) := by
    intro x hx y hy hxy
    exact mul_le_mul_of_nonneg_left hxy hM
  let g : C(RealInterval a b, ℝ) :=
    ⟨fun x ↦ g0 x, (p.continuous.add (continuous_const.mul continuous_id)).comp continuous_subtype_val⟩
  let h : C(RealInterval a b, ℝ) :=
    ⟨fun x ↦ h0 x, (continuous_const.mul continuous_id).comp continuous_subtype_val⟩
  refine ⟨g, h, ?_, ?_, ?_⟩
  · intro x y hxy
    exact hg0 x.property y.property hxy
  · intro x y hxy
    exact hh0 x.property y.property hxy
  · ext x
    simp [g, h, g0, h0]

/-- Continuous increasing real tests determine finite Borel measures on a compact real interval. -/
theorem continuous_increasing_tests_determine
    (a b : ℝ) (_hab : a ≤ b)
    (mu nu : ProbabilityMeasure (RealInterval a b))
    (htest : ∀ f : BoundedContinuousFunction (RealInterval a b) ℝ,
      Monotone f → ∫ x, f x ∂(mu : Measure _) = ∫ x, f x ∂(nu : Measure _)) :
    mu = nu := by
  let Q : Set C(RealInterval a b, ℝ) :=
    {f | ∫ x, f x ∂(mu : Measure _) = ∫ x, f x ∂(nu : Measure _)}
  have hpoly : polynomialFunctions (Set.Icc a b) ≤ Q := by
    intro f hf
    obtain ⟨p, ⟨-, rfl⟩⟩ := hf
    obtain ⟨g, h, hg, hh, hp⟩ := polynomial_eq_sub_monotoneOn a b p
    change p.toContinuousMapOn (Set.Icc a b) ∈ Q
    rw [hp]
    have hgeq := htest (BoundedContinuousFunction.mkOfCompact g) hg
    have hheq := htest (BoundedContinuousFunction.mkOfCompact h) hh
    change (∫ x, g x ∂(mu : Measure _)) = ∫ x, g x ∂(nu : Measure _) at hgeq
    change (∫ x, h x ∂(mu : Measure _)) = ∫ x, h x ∂(nu : Measure _) at hheq
    have hgi : Integrable g (mu : Measure _) :=
      g.continuous.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _)
    have hhi : Integrable h (mu : Measure _) :=
      h.continuous.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _)
    have hgi' : Integrable g (nu : Measure _) :=
      g.continuous.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _)
    have hhi' : Integrable h (nu : Measure _) :=
      h.continuous.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _)
    change (∫ x, (g - h) x ∂(mu : Measure _)) =
      ∫ x, (g - h) x ∂(nu : Measure _)
    simp only [ContinuousMap.coe_sub, Pi.sub_apply]
    rw [integral_sub hgi hhi, integral_sub hgi' hhi']
    linarith
  apply MeasureTheory.ProbabilityMeasure.toMeasure_injective
  apply ext_of_forall_integral_eq_of_IsFiniteMeasure
  intro f
  apply eq_of_forall_dist_le
  intro eps heps
  obtain ⟨p, hp⟩ := exists_polynomial_near_continuousMap a b f.toContinuousMap
    (eps / 2) (half_pos heps)
  have hpeq :
      ∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _) =
        ∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(nu : Measure _) :=
    hpoly ⟨p, ⟨Set.mem_univ p, rfl⟩⟩
  have hpoint : ∀ x : RealInterval a b,
      ‖p.toContinuousMapOn (Set.Icc a b) x - f x‖ ≤ eps / 2 := by
    intro x
    exact (ContinuousMap.norm_coe_le_norm
      (p.toContinuousMapOn (Set.Icc a b) - f.toContinuousMap) x).trans hp.le
  have hmu : dist
      (∫ x, f x ∂(mu : Measure _))
      (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _)) ≤ eps / 2 := by
    have hfi : Integrable f (mu : Measure _) := f.integrable _
    have hpi : Integrable (p.toContinuousMapOn (Set.Icc a b)) (mu : Measure _) :=
      (p.toContinuousMapOn (Set.Icc a b)).continuous.integrable_of_hasCompactSupport
        (HasCompactSupport.of_compactSpace _)
    rw [dist_eq_norm, ← integral_sub hfi hpi]
    have hbound := norm_integral_le_of_norm_le_const (μ := (mu : Measure _))
      (f := fun x ↦ f x - p.toContinuousMapOn (Set.Icc a b) x)
      (C := eps / 2) (Filter.Eventually.of_forall fun x ↦ by
        simpa [norm_sub_rev] using hpoint x)
    simpa [probReal_univ] using hbound
  have hnu : dist
      (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(nu : Measure _))
      (∫ x, f x ∂(nu : Measure _)) ≤ eps / 2 := by
    have hpi : Integrable (p.toContinuousMapOn (Set.Icc a b)) (nu : Measure _) :=
      (p.toContinuousMapOn (Set.Icc a b)).continuous.integrable_of_hasCompactSupport
        (HasCompactSupport.of_compactSpace _)
    have hfi : Integrable f (nu : Measure _) := f.integrable _
    rw [dist_eq_norm, ← integral_sub hpi hfi]
    have hbound := norm_integral_le_of_norm_le_const (μ := (nu : Measure _))
      (f := fun x ↦ p.toContinuousMapOn (Set.Icc a b) x - f x)
      (C := eps / 2) (Filter.Eventually.of_forall hpoint)
    simpa [probReal_univ] using hbound
  calc
    dist (∫ x, f x ∂(mu : Measure _)) (∫ x, f x ∂(nu : Measure _))
        ≤ dist (∫ x, f x ∂(mu : Measure _))
            (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _)) +
          dist (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _))
            (∫ x, f x ∂(nu : Measure _)) := dist_triangle _ _ _
    _ = dist (∫ x, f x ∂(mu : Measure _))
            (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _)) +
          dist (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(nu : Measure _))
            (∫ x, f x ∂(nu : Measure _)) := by rw [hpeq]
    _ ≤ eps / 2 + eps / 2 := add_le_add hmu hnu
    _ = eps := by ring

/-- On a compact real interval, convergence against continuous increasing tests is weak
convergence. This is the determining-class step needed by the one-dimensional SLP argument. -/
theorem tendsto_probabilityMeasure_of_increasing_tests
    (a b : ℝ) (muSeq : ℕ → ProbabilityMeasure (RealInterval a b))
    (mu : ProbabilityMeasure (RealInterval a b))
    (htest : ∀ f : BoundedContinuousFunction (RealInterval a b) ℝ,
      Monotone f → Tendsto (fun n ↦ ∫ x, f x ∂(muSeq n : Measure _)) atTop
        (𝓝 (∫ x, f x ∂(mu : Measure _)))) :
    Tendsto muSeq atTop (𝓝 mu) := by
  apply MeasureTheory.ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mpr
  intro f
  rw [Metric.tendsto_atTop]
  intro eps heps
  obtain ⟨p, hp⟩ := exists_polynomial_near_continuousMap a b f.toContinuousMap
    (eps / 3) (by positivity)
  obtain ⟨g, h, hg, hh, hpoly⟩ := polynomial_eq_sub_monotoneOn a b p
  have hgt := htest (BoundedContinuousFunction.mkOfCompact g) hg
  have hht := htest (BoundedContinuousFunction.mkOfCompact h) hh
  change Tendsto (fun n ↦ ∫ x, g x ∂(muSeq n : Measure _)) atTop
    (𝓝 (∫ x, g x ∂(mu : Measure _))) at hgt
  change Tendsto (fun n ↦ ∫ x, h x ∂(muSeq n : Measure _)) atTop
    (𝓝 (∫ x, h x ∂(mu : Measure _))) at hht
  have hpt : Tendsto
      (fun n ↦ ∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(muSeq n : Measure _)) atTop
      (𝓝 (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _))) := by
    have hsub := hgt.sub hht
    simpa only [hpoly, ContinuousMap.coe_sub, Pi.sub_apply,
      integral_sub (g.continuous.integrable_of_hasCompactSupport
        (HasCompactSupport.of_compactSpace _))
        (h.continuous.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _))]
      using hsub
  rw [Metric.tendsto_atTop] at hpt
  obtain ⟨N, hN⟩ := hpt (eps / 3) (by positivity)
  refine ⟨N, fun n hnN ↦ ?_⟩
  have hn := hN n hnN
  have hpoint : ∀ x : RealInterval a b,
      ‖p.toContinuousMapOn (Set.Icc a b) x - f x‖ ≤ eps / 3 := by
    intro x
    exact (ContinuousMap.norm_coe_le_norm
      (p.toContinuousMapOn (Set.Icc a b) - f.toContinuousMap) x).trans hp.le
  have left : dist
      (∫ x, f x ∂(muSeq n : Measure _))
      (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(muSeq n : Measure _)) ≤ eps / 3 := by
    have hfi : Integrable f (muSeq n : Measure _) := f.integrable _
    have hpi : Integrable (p.toContinuousMapOn (Set.Icc a b)) (muSeq n : Measure _) :=
      (p.toContinuousMapOn (Set.Icc a b)).continuous.integrable_of_hasCompactSupport
        (HasCompactSupport.of_compactSpace _)
    rw [dist_eq_norm, ← integral_sub hfi hpi]
    have hb := norm_integral_le_of_norm_le_const (μ := (muSeq n : Measure _))
      (f := fun x ↦ f x - p.toContinuousMapOn (Set.Icc a b) x)
      (C := eps / 3) (Filter.Eventually.of_forall fun x ↦ by
        simpa [norm_sub_rev] using hpoint x)
    simpa [probReal_univ] using hb
  have right : dist
      (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _))
      (∫ x, f x ∂(mu : Measure _)) ≤ eps / 3 := by
    have hpi : Integrable (p.toContinuousMapOn (Set.Icc a b)) (mu : Measure _) :=
      (p.toContinuousMapOn (Set.Icc a b)).continuous.integrable_of_hasCompactSupport
        (HasCompactSupport.of_compactSpace _)
    have hfi : Integrable f (mu : Measure _) := f.integrable _
    rw [dist_eq_norm, ← integral_sub hpi hfi]
    have hb := norm_integral_le_of_norm_le_const (μ := (mu : Measure _))
      (f := fun x ↦ p.toContinuousMapOn (Set.Icc a b) x - f x)
      (C := eps / 3) (Filter.Eventually.of_forall hpoint)
    simpa [probReal_univ] using hb
  calc
    dist (∫ x, f x ∂(muSeq n : Measure _)) (∫ x, f x ∂(mu : Measure _))
        ≤ dist (∫ x, f x ∂(muSeq n : Measure _))
            (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(muSeq n : Measure _)) +
          dist (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(muSeq n : Measure _))
            (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _)) +
          dist (∫ x, p.toContinuousMapOn (Set.Icc a b) x ∂(mu : Measure _))
            (∫ x, f x ∂(mu : Measure _)) := by
              exact dist_triangle4 _ _ _ _
    _ < eps := by nlinarith [left, hn, right]

end
end Aiyagari1994
