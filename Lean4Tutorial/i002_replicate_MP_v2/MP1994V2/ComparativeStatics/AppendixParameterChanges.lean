import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ParameterChanges

/-!
# MP1994 v2 Appendix: dispersion changes

The Appendix varies `sigma` while holding every other primitive fixed.
-/

namespace MP1994V2

namespace Primitives

/-- Immutable update of shock dispersion `sigma`. -/
def withDispersion (P : Primitives) (sigmaNew : ℝ) : Primitives :=
  { P with sigma := sigmaNew }

@[simp] theorem withDispersion_r (P : Primitives) (x : ℝ) : (P.withDispersion x).r = P.r := rfl
@[simp] theorem withDispersion_lambda (P : Primitives) (x : ℝ) : (P.withDispersion x).lambda = P.lambda := rfl
@[simp] theorem withDispersion_sigma (P : Primitives) (x : ℝ) : (P.withDispersion x).sigma = x := rfl
@[simp] theorem withDispersion_beta (P : Primitives) (x : ℝ) : (P.withDispersion x).beta = P.beta := rfl
@[simp] theorem withDispersion_c (P : Primitives) (x : ℝ) : (P.withDispersion x).c = P.c := rfl
@[simp] theorem withDispersion_b (P : Primitives) (x : ℝ) : (P.withDispersion x).b = P.b := rfl
@[simp] theorem withDispersion_p (P : Primitives) (x : ℝ) : (P.withDispersion x).p = P.p := rfl
@[simp] theorem withDispersion_epsUpper (P : Primitives) (x : ℝ) : (P.withDispersion x).epsUpper = P.epsUpper := rfl
@[simp] theorem withDispersion_shock (P : Primitives) (x : ℝ) : (P.withDispersion x).shock = P.shock := rfl
@[simp] theorem withDispersion_q (P : Primitives) (x : ℝ) : (P.withDispersion x).q = P.q := rfl

end Primitives

namespace CoreEconomicAssumptions

theorem withDispersion {P : Primitives} (A : CoreEconomicAssumptions P)
    (x : ℝ) (hx : 0 < x) : CoreEconomicAssumptions (P.withDispersion x) :=
  ⟨A.r_pos, A.lambda_nonneg, hx, A.beta_pos, A.beta_lt_one, A.c_pos⟩

end CoreEconomicAssumptions

namespace ShockAssumptions

theorem withDispersion {P : Primitives} (D : ShockAssumptions P) (x : ℝ) :
    ShockAssumptions (P.withDispersion x) :=
  ⟨D.isProbability, D.upperSupport, D.noAtoms, D.firstMomentIntegrable⟩

end ShockAssumptions

namespace ShockNormalizationAssumptions

theorem withDispersion {P : Primitives} (N : ShockNormalizationAssumptions P)
    (x : ℝ) : ShockNormalizationAssumptions (P.withDispersion x) :=
  ⟨N.firstMomentIntegrable, N.secondMomentIntegrable,
    N.mean_zero, N.secondMoment_one⟩

end ShockNormalizationAssumptions

namespace MatchingAssumptions

theorem withDispersion {P : Primitives} (M : MatchingAssumptions P) (x : ℝ) :
    MatchingAssumptions (P.withDispersion x) :=
  ⟨M.vacancyMeetingRate_pos, M.vacancyMeetingRate_strictAntiOn,
    M.workerMeetingRate_monotoneOn⟩

end MatchingAssumptions

end MP1994V2
