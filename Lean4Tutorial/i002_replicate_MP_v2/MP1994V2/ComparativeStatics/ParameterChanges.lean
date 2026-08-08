import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.Assumptions

/-!
# MP1994 v2: immutable one-parameter changes

Each update changes exactly one primitive.  Cross-economy comparative statics
therefore share all other primitives definitionally.
-/

namespace MP1994V2

set_option linter.style.longLine false

namespace Primitives

def withCommonProductivity (P : Primitives) (pNew : ℝ) : Primitives :=
  { P with p := pNew }

def withUnemploymentIncome (P : Primitives) (bNew : ℝ) : Primitives :=
  { P with b := bNew }

def withShockArrivalRate (P : Primitives) (lambdaNew : ℝ) : Primitives :=
  { P with lambda := lambdaNew }

def withDiscountRate (P : Primitives) (rNew : ℝ) : Primitives :=
  { P with r := rNew }

-- Explicit projection lemmas keep the public cross-economy interface stable.
@[simp] theorem withCommonProductivity_r (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).r = P.r := rfl
@[simp] theorem withCommonProductivity_lambda (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).lambda = P.lambda := rfl
@[simp] theorem withCommonProductivity_sigma (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).sigma = P.sigma := rfl
@[simp] theorem withCommonProductivity_beta (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).beta = P.beta := rfl
@[simp] theorem withCommonProductivity_c (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).c = P.c := rfl
@[simp] theorem withCommonProductivity_b (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).b = P.b := rfl
@[simp] theorem withCommonProductivity_p (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).p = x := rfl
@[simp] theorem withCommonProductivity_epsUpper (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).epsUpper = P.epsUpper := rfl
@[simp] theorem withCommonProductivity_shock (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).shock = P.shock := rfl
@[simp] theorem withCommonProductivity_q (P : Primitives) (x : ℝ) : (P.withCommonProductivity x).q = P.q := rfl

@[simp] theorem withUnemploymentIncome_r (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).r = P.r := rfl
@[simp] theorem withUnemploymentIncome_lambda (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).lambda = P.lambda := rfl
@[simp] theorem withUnemploymentIncome_sigma (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).sigma = P.sigma := rfl
@[simp] theorem withUnemploymentIncome_beta (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).beta = P.beta := rfl
@[simp] theorem withUnemploymentIncome_c (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).c = P.c := rfl
@[simp] theorem withUnemploymentIncome_b (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).b = x := rfl
@[simp] theorem withUnemploymentIncome_p (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).p = P.p := rfl
@[simp] theorem withUnemploymentIncome_epsUpper (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).epsUpper = P.epsUpper := rfl
@[simp] theorem withUnemploymentIncome_shock (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).shock = P.shock := rfl
@[simp] theorem withUnemploymentIncome_q (P : Primitives) (x : ℝ) : (P.withUnemploymentIncome x).q = P.q := rfl

@[simp] theorem withShockArrivalRate_r (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).r = P.r := rfl
@[simp] theorem withShockArrivalRate_lambda (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).lambda = x := rfl
@[simp] theorem withShockArrivalRate_sigma (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).sigma = P.sigma := rfl
@[simp] theorem withShockArrivalRate_beta (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).beta = P.beta := rfl
@[simp] theorem withShockArrivalRate_c (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).c = P.c := rfl
@[simp] theorem withShockArrivalRate_b (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).b = P.b := rfl
@[simp] theorem withShockArrivalRate_p (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).p = P.p := rfl
@[simp] theorem withShockArrivalRate_epsUpper (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).epsUpper = P.epsUpper := rfl
@[simp] theorem withShockArrivalRate_shock (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).shock = P.shock := rfl
@[simp] theorem withShockArrivalRate_q (P : Primitives) (x : ℝ) : (P.withShockArrivalRate x).q = P.q := rfl

@[simp] theorem withDiscountRate_r (P : Primitives) (x : ℝ) : (P.withDiscountRate x).r = x := rfl
@[simp] theorem withDiscountRate_lambda (P : Primitives) (x : ℝ) : (P.withDiscountRate x).lambda = P.lambda := rfl
@[simp] theorem withDiscountRate_sigma (P : Primitives) (x : ℝ) : (P.withDiscountRate x).sigma = P.sigma := rfl
@[simp] theorem withDiscountRate_beta (P : Primitives) (x : ℝ) : (P.withDiscountRate x).beta = P.beta := rfl
@[simp] theorem withDiscountRate_c (P : Primitives) (x : ℝ) : (P.withDiscountRate x).c = P.c := rfl
@[simp] theorem withDiscountRate_b (P : Primitives) (x : ℝ) : (P.withDiscountRate x).b = P.b := rfl
@[simp] theorem withDiscountRate_p (P : Primitives) (x : ℝ) : (P.withDiscountRate x).p = P.p := rfl
@[simp] theorem withDiscountRate_epsUpper (P : Primitives) (x : ℝ) : (P.withDiscountRate x).epsUpper = P.epsUpper := rfl
@[simp] theorem withDiscountRate_shock (P : Primitives) (x : ℝ) : (P.withDiscountRate x).shock = P.shock := rfl
@[simp] theorem withDiscountRate_q (P : Primitives) (x : ℝ) : (P.withDiscountRate x).q = P.q := rfl

end Primitives

namespace CoreEconomicAssumptions

variable {P : Primitives}

theorem withCommonProductivity (A : CoreEconomicAssumptions P) (x : ℝ) :
    CoreEconomicAssumptions (P.withCommonProductivity x) :=
  ⟨A.r_pos, A.lambda_nonneg, A.sigma_pos, A.beta_pos, A.beta_lt_one, A.c_pos⟩

theorem withUnemploymentIncome (A : CoreEconomicAssumptions P) (x : ℝ) :
    CoreEconomicAssumptions (P.withUnemploymentIncome x) :=
  ⟨A.r_pos, A.lambda_nonneg, A.sigma_pos, A.beta_pos, A.beta_lt_one, A.c_pos⟩

theorem withShockArrivalRate (A : CoreEconomicAssumptions P) (x : ℝ) (hx : 0 ≤ x) :
    CoreEconomicAssumptions (P.withShockArrivalRate x) :=
  ⟨A.r_pos, hx, A.sigma_pos, A.beta_pos, A.beta_lt_one, A.c_pos⟩

theorem withDiscountRate (A : CoreEconomicAssumptions P) (x : ℝ) (hx : 0 < x) :
    CoreEconomicAssumptions (P.withDiscountRate x) :=
  ⟨hx, A.lambda_nonneg, A.sigma_pos, A.beta_pos, A.beta_lt_one, A.c_pos⟩

end CoreEconomicAssumptions

namespace ShockAssumptions

variable {P : Primitives}

theorem withCommonProductivity (D : ShockAssumptions P) (x : ℝ) : ShockAssumptions (P.withCommonProductivity x) :=
  ⟨D.isProbability, D.upperSupport, D.noAtoms, D.firstMomentIntegrable⟩
theorem withUnemploymentIncome (D : ShockAssumptions P) (x : ℝ) : ShockAssumptions (P.withUnemploymentIncome x) :=
  ⟨D.isProbability, D.upperSupport, D.noAtoms, D.firstMomentIntegrable⟩
theorem withShockArrivalRate (D : ShockAssumptions P) (x : ℝ) : ShockAssumptions (P.withShockArrivalRate x) :=
  ⟨D.isProbability, D.upperSupport, D.noAtoms, D.firstMomentIntegrable⟩
theorem withDiscountRate (D : ShockAssumptions P) (x : ℝ) : ShockAssumptions (P.withDiscountRate x) :=
  ⟨D.isProbability, D.upperSupport, D.noAtoms, D.firstMomentIntegrable⟩

end ShockAssumptions

namespace MatchingAssumptions

variable {P : Primitives}

theorem withCommonProductivity (M : MatchingAssumptions P) (x : ℝ) : MatchingAssumptions (P.withCommonProductivity x) :=
  ⟨M.vacancyMeetingRate_pos, M.vacancyMeetingRate_strictAntiOn, M.workerMeetingRate_monotoneOn⟩
theorem withUnemploymentIncome (M : MatchingAssumptions P) (x : ℝ) : MatchingAssumptions (P.withUnemploymentIncome x) :=
  ⟨M.vacancyMeetingRate_pos, M.vacancyMeetingRate_strictAntiOn, M.workerMeetingRate_monotoneOn⟩
theorem withShockArrivalRate (M : MatchingAssumptions P) (x : ℝ) : MatchingAssumptions (P.withShockArrivalRate x) :=
  ⟨M.vacancyMeetingRate_pos, M.vacancyMeetingRate_strictAntiOn, M.workerMeetingRate_monotoneOn⟩
theorem withDiscountRate (M : MatchingAssumptions P) (x : ℝ) : MatchingAssumptions (P.withDiscountRate x) :=
  ⟨M.vacancyMeetingRate_pos, M.vacancyMeetingRate_strictAntiOn, M.workerMeetingRate_monotoneOn⟩

end MatchingAssumptions

end MP1994V2
