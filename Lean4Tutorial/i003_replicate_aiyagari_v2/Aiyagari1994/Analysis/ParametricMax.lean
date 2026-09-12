import Mathlib.Topology.Order.Compact
import Mathlib.Topology.Maps.Proper.Basic
import Mathlib.Topology.MetricSpace.Contracting
import Mathlib.MeasureTheory.Integral.BoundedContinuousFunction

/-! Compact maximum values. The compact parameter is auxiliary, not an economic control. -/
open Set
open scoped Topology
namespace Aiyagari1994
noncomputable section

variable {X K : Type*} [TopologicalSpace X] [TopologicalSpace K]
  [CompactSpace K] [Nonempty K]

def compactMax (f : X → K → ℝ) (x : X) : ℝ := sSup (Set.range (f x))

omit [Nonempty K] in
theorem compactMax_continuous {f : X → K → ℝ} (hf : Continuous f.uncurry) :
    Continuous (compactMax f) := by
  change Continuous (fun x => sSup (Set.range (f x)))
  simpa only [image_univ] using isCompact_univ.continuous_sSup hf

theorem compactMax_attained {f : X → K → ℝ} (hf : Continuous f.uncurry) (x : X) :
    ∃ k, compactMax f x = f x k ∧ ∀ j, f x j ≤ f x k := by
  obtain ⟨k, _, he, hm⟩ := isCompact_univ.exists_sSup_image_eq_and_ge
    (Set.univ_nonempty : (Set.univ : Set K).Nonempty)
    (hf.comp (continuous_const.prodMk continuous_id)).continuousOn
  exact ⟨k, by simpa [compactMax, image_univ] using he, fun j => hm j (mem_univ j)⟩

theorem le_compactMax {f : X → K → ℝ} (hf : Continuous f.uncurry) (x : X) (k : K) :
    f x k ≤ compactMax f x := by
  obtain ⟨j, he, hm⟩ := compactMax_attained hf x
  rw [he]; exact hm k

theorem compactMax_le {f : X → K → ℝ} (hf : Continuous f.uncurry) (x : X)
    {b : ℝ} (h : ∀ k, f x k ≤ b) : compactMax f x ≤ b := by
  obtain ⟨k, he, _⟩ := compactMax_attained hf x
  rw [he]; exact h k


omit [Nonempty K] in
/-- A selected unique maximizer on a fixed compact space is continuous, by its closed graph. -/
theorem compact_unique_argmax_continuous {f : X → K → ℝ} (hf : Continuous f.uncurry)
    (A : X → K) (hA : ∀ x, f x (A x) = compactMax f x)
    (hu : ∀ x k, f x k = compactMax f x → k = A x) : Continuous A := by
  rw [continuous_iff_isClosed]
  intro S hS
  have hg : IsClosed {p : X × K | f p.1 p.2 = compactMax f p.1} :=
    isClosed_eq hf ((compactMax_continuous hf).comp continuous_fst)
  have hc := isClosedMap_fst_of_compactSpace _ (hg.inter (hS.preimage continuous_snd))
  have he : A ⁻¹' S = Prod.fst ''
      ({p : X × K | f p.1 p.2 = compactMax f p.1} ∩ Prod.snd ⁻¹' S) := by
    ext x
    constructor
    · intro hx; exact ⟨(x,A x), ⟨hA x,hx⟩, rfl⟩
    · rintro ⟨⟨y,k⟩, ⟨hk,hs⟩, hxy⟩
      dsimp at hxy; subst y
      change A x ∈ S
      rw [← hu x k hk]; exact hs
  rw [he]; exact hc

end
end Aiyagari1994
