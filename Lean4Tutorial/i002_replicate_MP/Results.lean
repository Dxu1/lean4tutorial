import Lean4Tutorial.i002_replicate_MP.Equilibrium

/-!
# Mortensen--Pissarides (1994): derived results

This file proves reusable consequences of the equilibrium definitions.  The
results cover surplus sharing and free entry, stationary gross-flow balance,
the Beveridge equation, the signs of the paper's aggregate and dispersion
comparative statics, and the downturn scrapping asymmetry used in Section 4.

No theorem in this file uses `sorry` or an added axiom.  Economic ordering
hypotheses are explicit where the paper obtains them by implicit
differentiation of equations (10) and (13).
-/

open MeasureTheory Set

namespace MP1994

namespace ValueEquilibrium

variable {P : Primitives}

/-- Equations (3)--(7) imply equation (8): adding the firm's and worker's
Bellman equations and subtracting the unemployment equation yields the match
surplus Bellman equation. -/
theorem surplus_bellman
    (E : ValueEquilibrium P) : P.SurplusBellman E.θ E.S := by
  intro ε
  have hJ := E.filled_job_bellman ε
  have hW := E.worker_bellman ε
  have hU := E.unemployed_bellman
  have hS := E.surplus_identity ε
  have hShare := E.nash_sharing P.εu
  unfold Primitives.UnemployedBellman at hU
  rw [hS]
  rw [hShare] at hU
  linear_combination hJ + hW - hU - P.«λ» * hS

/-- The reservation rule and Nash sharing imply that the firm's value is zero
at the destruction cutoff, as used below equation (8). -/
theorem J_cutoff_eq_zero (E : ValueEquilibrium P) :
    E.J E.εd = 0 := by
  have hS := E.surplus_identity E.εd
  have hShare := E.nash_sharing E.εd
  rw [E.cutoff_zero] at hS hShare
  linarith

/-- Equations (1)--(2) imply the zero-profit value form of free entry. -/
theorem vacancy_free_entry_value
    (A : Assumptions P) (E : ValueEquilibrium P) :
    P.q E.θ * E.J P.εu =
      P.c := by
  have hr : P.r ≠ 0 := ne_of_gt A.r_pos
  have hV : E.V = 0 := by
    have hFree := E.free_entry
    unfold Primitives.FreeEntry at hFree
    exact (mul_eq_zero.mp hFree).resolve_left hr
  have hBell := E.vacancy_bellman
  unfold Primitives.VacancyBellman at hBell
  rw [hV] at hBell
  linarith

end ValueEquilibrium

namespace Primitives

variable {P : Primitives}

@[simp] theorem S_cutoff_self (εd : ℝ) :
    P.S_cutoff εd εd = 0 := by
  simp [S_cutoff]

theorem surplus_difference (εd ε₁ ε₂ : ℝ) :
    P.S_cutoff εd ε₂ - P.S_cutoff εd ε₁ =
      P.σ * (ε₂ - ε₁) /
        (P.r + P.«λ») := by
  simp only [S_cutoff]
  ring

/-- Equation (4): the two Nash shares exhaust total match surplus. -/
theorem nash_shares_exhaust_surplus (εd ε : ℝ) :
    P.J_cutoff εd ε + P.WminusU_cutoff εd ε =
      P.S_cutoff εd ε := by
  simp only [J_cutoff, WminusU_cutoff]
  ring

theorem surplus_nonneg
    (A : Assumptions P) {εd ε : ℝ} (hε : εd ≤ ε) :
    0 ≤ P.S_cutoff εd ε := by
  have hden : 0 < P.r + P.«λ» :=
    add_pos_of_pos_of_nonneg A.r_pos A.«λ_nonneg»
  exact div_nonneg
    (mul_nonneg (le_of_lt A.σ_pos) (sub_nonneg.mpr hε))
    (le_of_lt hden)

theorem J_cutoff_nonneg
    (A : Assumptions P) {εd ε : ℝ} (hε : εd ≤ ε) :
    0 ≤ P.J_cutoff εd ε := by
  exact mul_nonneg
    (sub_nonneg.mpr (le_of_lt A.β_lt_one))
    (surplus_nonneg A hε)

theorem destructionHazard_nonneg
    (A : Assumptions P) (εd : ℝ) :
    0 ≤ P.destructionHazard εd := by
  exact mul_nonneg A.«λ_nonneg» (A.F_nonneg εd)

/-- A higher reservation cutoff raises the endogenous separation hazard. -/
theorem destructionHazard_mono
    (A : Assumptions P) : Monotone P.destructionHazard := by
  intro x y hxy
  exact mul_le_mul_of_nonneg_left (A.F_monotone hxy)
    A.«λ_nonneg»

theorem mWorker_pos
    (A : Assumptions P) {θ : ℝ} (hθ : 0 < θ) :
    0 < P.mWorker θ := by
  exact mul_pos hθ (A.q_pos θ hθ)

/-- Equation (13) is exactly the zero-profit/free-entry condition when the
firm receives share `1-β` of equation (12)'s surplus. -/
theorem jobCreation_iff_freeEntryValue
    (A : Assumptions P) {θ εd : ℝ} (hcut : εd < P.εu) :
    P.JobCreationCondition θ εd ↔
      P.q θ *
        P.J_cutoff εd P.εu = P.c := by
  have hβ : 1 - P.β ≠ 0 :=
    ne_of_gt (sub_pos.mpr A.β_lt_one)
  have hσ : P.σ ≠ 0 := ne_of_gt A.σ_pos
  have hgap : P.εu - εd ≠ 0 := ne_of_gt (sub_pos.mpr hcut)
  have hrLambda : P.r + P.«λ» ≠ 0 :=
    ne_of_gt (add_pos_of_pos_of_nonneg
      A.r_pos A.«λ_nonneg»)
  constructor
  · intro hjc
    unfold JobCreationCondition at hjc
    rw [hjc]
    simp only [J_cutoff, S_cutoff]
    field_simp
  · intro hfree
    unfold JobCreationCondition
    simp only [J_cutoff, S_cutoff] at hfree
    field_simp at hfree ⊢
    all_goals nlinarith

/-- Figure 1's JC curve slopes down: a higher destruction cutoff implies
strictly lower market tightness `θ` along equation (13). -/
theorem jobCreationCurve_slopes_down
    (A : Assumptions P)
    {θ₁ θ₂ ε₁ ε₂ : ℝ}
    (hcut₁ : ε₁ < P.εu) (hcut₂ : ε₂ < P.εu)
    (hε : ε₁ < ε₂)
    (hJC₁ : P.JobCreationCondition θ₁ ε₁)
    (hJC₂ : P.JobCreationCondition θ₂ ε₂) :
    θ₂ < θ₁ := by
  let K : ℝ :=
    (P.c / (1 - P.β)) *
      ((P.r + P.«λ») / P.σ)
  have hβ : 0 < 1 - P.β := sub_pos.mpr A.β_lt_one
  have hrLambda : 0 < P.r + P.«λ» :=
    add_pos_of_pos_of_nonneg A.r_pos A.«λ_nonneg»
  have hK : 0 < K := by
    dsimp [K]
    exact mul_pos (div_pos A.c_pos hβ)
      (div_pos hrLambda A.σ_pos)
  have hgap₁ : 0 < P.εu - ε₁ := sub_pos.mpr hcut₁
  have hgap₂ : 0 < P.εu - ε₂ := sub_pos.mpr hcut₂
  have hgap : P.εu - ε₂ < P.εu - ε₁ := by linarith
  have hfrac : K / (P.εu - ε₁) < K / (P.εu - ε₂) := by
    rw [div_lt_div_iff₀ hgap₁ hgap₂]
    nlinarith
  have hq₁ : P.q θ₁ = K / (P.εu - ε₁) := by
    unfold JobCreationCondition at hJC₁
    rw [hJC₁]
    dsimp [K]
    field_simp
  have hq₂ : P.q θ₂ = K / (P.εu - ε₂) := by
    unfold JobCreationCondition at hJC₂
    rw [hJC₂]
    dsimp [K]
    field_simp
  have hq : P.q θ₁ < P.q θ₂ := by
    rw [hq₁, hq₂]
    exact hfrac
  by_contra hnot
  have hθ : θ₁ ≤ θ₂ := le_of_not_gt hnot
  exact (not_lt_of_ge (A.q_antitone hθ)) hq

/-- Equation (11): if aggregate productivity `p` exceeds the opportunity cost
of employment, a rise in `σ` raises the reservation cutoff locally (with `θ`
fixed). -/
theorem dispersionCutoffResponse_pos
    (A : Assumptions P) {θ εd : ℝ}
    (hnet :
      P.b +
          (P.β * P.c / (1 - P.β)) * θ <
        P.p) :
    0 < P.dispersionCutoffResponse θ εd := by
  have hrLambda : 0 < P.r + P.«λ» :=
    add_pos_of_pos_of_nonneg A.r_pos A.«λ_nonneg»
  have hden :
      0 < P.r + P.«λ» * P.F εd :=
    add_pos_of_pos_of_nonneg A.r_pos
      (mul_nonneg A.«λ_nonneg» (A.F_nonneg εd))
  unfold dispersionCutoffResponse
  exact mul_pos (div_pos (div_pos hrLambda A.σ_pos) hden) (by linarith)

/-- With zero aggregate transition intensity, equation (30) collapses to the
stationary job-creation condition (13). -/
theorem boomJobCreation_zero_transition_iff
    {θStar εdStar εd : ℝ} :
    P.BoomJobCreationCondition θStar εdStar εd 0 ↔
      P.JobCreationCondition θStar εdStar := by
  unfold BoomJobCreationCondition JobCreationCondition
  constructor <;> intro h
  · rw [h]
    ring
  · rw [h]
    ring

/-- Equation (30)'s anticipation effect: for fixed cutoffs, a positive chance
of recession lowers boom tightness `θ*` relative to the no-transition benchmark.
This is the paper's formal reason that anticipated cyclical shocks dampen job
creation in booms. -/
theorem anticipation_reduces_boom_tightness
    (A : Assumptions P)
    {θStar₀ θStarμ εdStar εd μ : ℝ}
    (hμ : 0 < μ)
    (hcutoffs : εdStar < εd)
    (hrecessionCut : εd < P.εu)
    (hanticipatedDen :
      0 < P.σ * (P.εu - εdStar) -
        μ * P.σ * (εd - εdStar) /
          (P.r + P.«λ» + μ))
    (hNo : P.JobCreationCondition θStar₀ εdStar)
    (hAnt :
      P.BoomJobCreationCondition
        θStarμ εdStar εd μ) :
    θStarμ < θStar₀ := by
  let K : ℝ :=
    P.c * (P.r + P.«λ») /
      (1 - P.β)
  let denom₀ : ℝ := P.σ * (P.εu - εdStar)
  let penalty : ℝ :=
    μ * P.σ * (εd - εdStar) /
      (P.r + P.«λ» + μ)
  have hβ : 0 < 1 - P.β := sub_pos.mpr A.β_lt_one
  have hrLambda : 0 < P.r + P.«λ» :=
    add_pos_of_pos_of_nonneg A.r_pos A.«λ_nonneg»
  have hrLambdaMu : 0 < P.r + P.«λ» + μ := by linarith
  have hK : 0 < K := by
    dsimp [K]
    exact div_pos (mul_pos A.c_pos hrLambda) hβ
  have hboomCut : εdStar < P.εu := lt_trans hcutoffs hrecessionCut
  have hdenom₀ : 0 < denom₀ := by
    dsimp [denom₀]
    exact mul_pos A.σ_pos (sub_pos.mpr hboomCut)
  have hpenalty : 0 < penalty := by
    dsimp [penalty]
    exact div_pos
      (mul_pos (mul_pos hμ A.σ_pos) (sub_pos.mpr hcutoffs)) hrLambdaMu
  have hdenom : 0 < denom₀ - penalty := by
    simpa [denom₀, penalty] using hanticipatedDen
  have hfrac : K / denom₀ < K / (denom₀ - penalty) := by
    rw [div_lt_div_iff₀ hdenom₀ hdenom]
    nlinarith
  have hqNo : P.q θStar₀ = K / denom₀ := by
    unfold JobCreationCondition at hNo
    rw [hNo]
    dsimp [K, denom₀]
    field_simp
  have hqAnt : P.q θStarμ = K / (denom₀ - penalty) := by
    unfold BoomJobCreationCondition at hAnt
    rw [hAnt]
  have hq :
      P.q θStar₀ < P.q θStarμ := by
    rw [hqNo, hqAnt]
    exact hfrac
  by_contra hnot
  have hθ : θStar₀ ≤ θStarμ := le_of_not_gt hnot
  exact (not_lt_of_ge (A.q_antitone hθ)) hq

/-- The denominator in the Beveridge curve is strictly positive. -/
theorem beveridge_denominator_pos
    (A : Assumptions P) {θ εd : ℝ} (hθ : 0 < θ) :
    0 < P.destructionHazard εd + P.mWorker θ := by
  exact add_pos_of_nonneg_of_pos
    (destructionHazard_nonneg A εd) (mWorker_pos A hθ)

/-- Gross creation rises with the worker meeting rate, holding unemployment
fixed. -/
theorem creationFlow_mono
    {θ₁ θ₂ u : ℝ} (hu : 0 ≤ u)
    (hθ : P.mWorker θ₁ ≤ P.mWorker θ₂) :
    P.creationFlow θ₁ u ≤ P.creationFlow θ₂ u := by
  exact mul_le_mul_of_nonneg_left hθ hu

/-- Gross destruction rises with the cutoff, holding unemployment fixed. -/
theorem destructionFlow_mono
    (A : Assumptions P) {εd₁ εd₂ u : ℝ}
    (hu : u ≤ 1) (hε : εd₁ ≤ εd₂) :
    P.destructionFlow εd₁ u ≤ P.destructionFlow εd₂ u := by
  exact mul_le_mul_of_nonneg_left
    (destructionHazard_mono A hε) (sub_nonneg.mpr hu)

/-- The weak flow implications of a positive aggregate shock, conditional on
the equilibrium ordering derived from equations (10) and (13). -/
theorem aggregateShock_flow_orders
    (A : Assumptions P) {θ₀ θ₁ εd₀ εd₁ u : ℝ}
    (hu0 : 0 ≤ u) (hu1 : u ≤ 1)
    (hθ : θ₀ ≤ θ₁) (hε : εd₁ ≤ εd₀) :
    P.creationFlow θ₀ u ≤ P.creationFlow θ₁ u ∧
      P.destructionFlow εd₁ u ≤ P.destructionFlow εd₀ u := by
  constructor
  · exact creationFlow_mono hu0 (A.mWorker_monotone hθ)
  · exact destructionFlow_mono A hu1 hε

/-- The weak flow implications of higher idiosyncratic dispersion `σ`:
equilibrium `θ` and `ε_d` both rise, so creation and destruction rise together. -/
theorem dispersionShock_flow_orders
    (A : Assumptions P) {θ₀ θ₁ εd₀ εd₁ u : ℝ}
    (hu0 : 0 ≤ u) (hu1 : u ≤ 1)
    (hθ : θ₀ ≤ θ₁) (hε : εd₀ ≤ εd₁) :
    P.creationFlow θ₀ u ≤ P.creationFlow θ₁ u ∧
      P.destructionFlow εd₀ u ≤ P.destructionFlow εd₁ u := by
  constructor
  · exact creationFlow_mono hu0 (A.mWorker_monotone hθ)
  · exact destructionFlow_mono A hu1 hε

end Primitives

namespace SteadyStateEquilibrium

variable {P : Primitives}

/-- Equation (14) implies equality of stationary gross job creation and job
destruction. -/
theorem gross_flows_balance
    (A : Assumptions P) (E : SteadyStateEquilibrium P) :
    E.C = E.D := by
  have hden :
      P.destructionHazard E.εd + P.mWorker E.θ ≠ 0 :=
    ne_of_gt (P.beveridge_denominator_pos A E.θ_pos)
  have hbev := E.beveridge
  unfold Primitives.BeveridgeCondition at hbev
  simp only [C, D,
    Primitives.creationFlow, Primitives.destructionFlow]
  rw [hbev]
  field_simp
  ring

/-- The stationary equilibrium makes equation (15)'s unemployment drift zero. -/
theorem unemploymentDrift_eq_zero
    (A : Assumptions P) (E : SteadyStateEquilibrium P) :
    P.unemploymentDrift E.θ E.εd E.u = 0 := by
  rw [Primitives.unemploymentDrift]
  change E.D - E.C = 0
  rw [gross_flows_balance A E]
  ring

/-- The equilibrium vacancy stock lies on the ray `v = θu` in Figure 2. -/
theorem v_eq_θ_mul_u
    (E : SteadyStateEquilibrium P) :
    E.v = E.θ * E.u := rfl

end SteadyStateEquilibrium

/-- Qualitative negative co-movement: the first flow rises while the second
falls. -/
def MovesOpposite (xLow xHigh yLow yHigh : ℝ) : Prop :=
  (xHigh - xLow) * (yHigh - yLow) < 0

/-- Qualitative positive co-movement: both changes have the same sign. -/
def MovesTogether (xLow xHigh yLow yHigh : ℝ) : Prop :=
  0 < (xHigh - xLow) * (yHigh - yLow)

/-- Section 3's aggregate-shock result: higher productivity `p` raises job
creation and lowers job destruction, hence the two flows move oppositely. -/
theorem aggregateShock_negative_comovement
    {C₀ C₁ D₀ D₁ : ℝ}
    (hC : C₀ < C₁)
    (hD : D₁ < D₀) :
    MovesOpposite C₀ C₁ D₀ D₁ := by
  unfold MovesOpposite
  exact mul_neg_of_pos_of_neg (sub_pos.mpr hC) (sub_neg.mpr hD)

/-- Section 3's dispersion-shock result: higher `σ` raises both job
creation and job destruction. -/
theorem dispersionShock_positive_comovement
    {C₀ C₁ D₀ D₁ : ℝ}
    (hC : C₀ < C₁)
    (hD : D₀ < D₁) :
    MovesTogether C₀ C₁ D₀ D₁ := by
  unfold MovesTogether
  exact mul_pos (sub_pos.mpr hC) (sub_pos.mpr hD)

/-- Equation (15): unemployment rises exactly when destruction exceeds
creation. -/
theorem unemploymentDrift_pos_iff
    (P : Primitives) (θ εd u : ℝ) :
    0 < P.unemploymentDrift θ εd u ↔
      P.creationFlow θ u < P.destructionFlow εd u := by
  unfold Primitives.unemploymentDrift
  exact sub_pos

/-- Equation (38) rewritten as the change in employment. -/
theorem employment_change_identity
    (N C D : ℝ) :
    Primitives.nextEmployment N C D - N = C - D := by
  unfold Primitives.nextEmployment
  ring

/-- The Section 4 asymmetry: after a downturn, any positive mass of jobs
between the old and new cutoffs makes destruction strictly exceed its ongoing
Poisson component. -/
theorem downturn_destruction_exceeds_ongoing
    {D_immediate D_ongoing : ℝ} (h : 0 < D_immediate) :
    D_ongoing < Primitives.periodDestruction D_immediate D_ongoing := by
  simp only [Primitives.periodDestruction]
  linarith

/-- A boom has no analogous one-off scrapping term. -/
theorem boom_without_scrapping
    (D_ongoing : ℝ) :
    Primitives.periodDestruction 0 D_ongoing = D_ongoing := by
  simp [Primitives.periodDestruction]

/-- The accounting law of every simulation path is equation (38). -/
theorem SimulationPath.employment_change
    {P : Primitives} (path : SimulationPath P) (t : ℕ) :
    path.N (t + 1) - path.N t =
      path.C t - path.D t := by
  rw [path.employment_law]
  unfold Primitives.nextEmployment
  ring

end MP1994
