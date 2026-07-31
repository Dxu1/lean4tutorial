import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.ReducedAnalytic

/-!
# MP1994 v2: regularity of expected excess

This module proves order, Lipschitz, and continuity properties of
`H(d) = ∫ x, max (x - d) 0 ∂P.shock`.  Only probability normalization and
first-moment integrability are used from `ShockAssumptions`.
-/

open MeasureTheory

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- Raising the cutoff weakly lowers positive excess, pointwise. -/
theorem positivePart_sub_antitone
    {x d1 d2 : ℝ} (h : d1 ≤ d2) :
    positivePart (x - d2) ≤ positivePart (x - d1) := by
  unfold positivePart
  exact max_le_max_right 0 (sub_le_sub_left h x)

/-- Pointwise positive excess changes by no more than the cutoff. -/
theorem positivePart_sub_dist_le (x d1 d2 : ℝ) :
    dist (positivePart (x - d1)) (positivePart (x - d2)) ≤ dist d1 d2 := by
  unfold positivePart
  have h := MeasureTheory.Lp.lipschitzWith_pos_part.dist_le_mul (x - d1) (x - d2)
  calc
    dist (max (x - d1) 0) (max (x - d2) 0)
        ≤ dist (x - d1) (x - d2) := by simpa using h
    _ = dist d1 d2 := by
      simp only [Real.dist_eq]
      rw [abs_sub_comm d1 d2]
      congr 1
      ring

/-- Expected excess is antitone in the cutoff. -/
theorem expectedExcess_antitone
    (D : ShockAssumptions P) :
    Antitone P.expectedExcess := by
  intro d1 d2 h12
  letI : IsProbabilityMeasure P.shock := D.isProbability
  unfold expectedExcess
  exact integral_mono
    (P.positivePart_sub_integrable D d2)
    (P.positivePart_sub_integrable D d1)
    (fun x => positivePart_sub_antitone h12)

/-- Expected excess is one-Lipschitz in the cutoff. -/
theorem expectedExcess_lipschitz
    (D : ShockAssumptions P) :
    LipschitzWith 1 P.expectedExcess := by
  letI : IsProbabilityMeasure P.shock := D.isProbability
  apply LipschitzWith.mk_one
  intro d1 d2
  have h1 := P.positivePart_sub_integrable D d1
  have h2 := P.positivePart_sub_integrable D d2
  rw [Real.dist_eq, expectedExcess, expectedExcess,
    ← integral_sub h1 h2, ← Real.norm_eq_abs]
  calc
    ‖∫ x, positivePart (x - d1) - positivePart (x - d2) ∂P.shock‖
        ≤ |d1 - d2| * P.shock.real Set.univ := by
          apply norm_integral_le_of_norm_le_const
          filter_upwards with x
          rw [Real.norm_eq_abs]
          simpa [Real.dist_eq] using positivePart_sub_dist_le x d1 d2
    _ = |d1 - d2| := by simp
    _ = dist d1 d2 := by rw [Real.dist_eq]

/-- Continuity follows from the one-Lipschitz estimate. -/
theorem expectedExcess_continuous
    (D : ShockAssumptions P) :
    Continuous P.expectedExcess :=
  (P.expectedExcess_lipschitz D).continuous

end Primitives

end MP1994V2
