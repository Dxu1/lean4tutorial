import Lean4Tutorial.i002_replicate_MP.Definitions

/-!
# Mortensen--Pissarides (1994): equilibrium objects

`ValueEquilibrium` records the Bellman, free-entry, bargaining, and reservation
conditions (paper equations (1)--(8)). `SteadyStateEquilibrium` records the
reduced three-equation equilibrium (10), (13), and (14).  The latter is the
most convenient interface for comparative statics and computation.
-/

open MeasureTheory Set
open scoped BigOperators

namespace MP1994

/-- The asset-value formulation of a stationary MP equilibrium. -/
structure ValueEquilibrium (P : Primitives) where
  /-- `θ = v/u` = market tightness. -/
  θ : ℝ
  /-- `εd = ε_d` = reservation shock that triggers job destruction. -/
  εd : ℝ
  /-- `V` = asset value of a vacancy. -/
  V : ℝ
  /-- `U` = asset value of unemployment. -/
  U : ℝ
  /-- `J(ε)` = firm's asset value of a filled job. -/
  J : ℝ → ℝ
  /-- `W(ε)` = worker's asset value of employment. -/
  W : ℝ → ℝ
  /-- `w(ε)` = productivity-contingent wage. -/
  w : ℝ → ℝ
  /-- `S(ε)` = total match surplus. -/
  S : ℝ → ℝ
  θ_pos : 0 < θ
  εd_lt_εu : εd < P.εu
  vacancy_bellman :
    P.VacancyBellman θ V (J P.εu)
  free_entry : P.FreeEntry V
  surplus_identity :
    Primitives.SurplusIdentity J W U S
  nash_sharing :
    P.NashSharing W U S
  filled_job_bellman : P.FilledJobBellman J w S
  worker_bellman : P.WorkerBellman W w S
  unemployed_bellman :
    P.UnemployedBellman θ U (W P.εu)
  cutoff_zero : S εd = 0
  reservation_rule : ∀ ε, 0 ≤ S ε ↔ εd ≤ ε

/-- The reduced stationary equilibrium characterized by equations (10), (13),
and (14). -/
structure SteadyStateEquilibrium (P : Primitives) where
  /-- `θ = v/u` = equilibrium market tightness. -/
  θ : ℝ
  /-- `εd = ε_d` = equilibrium job-destruction cutoff. -/
  εd : ℝ
  /-- `u` = equilibrium unemployment rate. -/
  u : ℝ
  θ_pos : 0 < θ
  εd_lt_εu : εd < P.εu
  u_nonneg : 0 ≤ u
  u_le_one : u ≤ 1
  job_destruction : P.JobDestructionCondition θ εd
  job_creation : P.JobCreationCondition θ εd
  beveridge : P.BeveridgeCondition θ εd u

namespace SteadyStateEquilibrium

variable {P : Primitives} (E : SteadyStateEquilibrium P)

/-- `v = θu` = equilibrium vacancy stock. -/
def v : ℝ := E.θ * E.u

/-- `n = 1-u` = equilibrium employment stock. -/
def n : ℝ := 1 - E.u

/-- `C` = gross job creation at the stationary allocation. -/
def C : ℝ := P.creationFlow E.θ E.u

/-- `D` = gross job destruction at the stationary allocation. -/
noncomputable def D : ℝ :=
  P.destructionFlow E.εd E.u

end SteadyStateEquilibrium

/-- A two-state aggregate-productivity equilibrium.  The ordering fields state
the equilibrium selection established in Section 4: booms have higher market
tightness and a lower destruction cutoff. -/
structure TwoStateEquilibrium (recession boom : Primitives) where
  recessionEq : SteadyStateEquilibrium recession
  boomEq : SteadyStateEquilibrium boom
  /-- `μ` = Poisson transition rate between aggregate states. -/
  μ : ℝ
  μ_nonneg : 0 ≤ μ
  p_order : recession.p < boom.p
  θ_order : recessionEq.θ < boomEq.θ
  εd_order : boomEq.εd < recessionEq.εd

/-- The anticipated two-state equilibrium characterized by equations (20),
(24), (28), and (30).  It keeps the common idiosyncratic primitives in `P` and
passes the low/high aggregate price components explicitly. -/
structure AnticipatedTwoStateEquilibrium (P : Primitives) where
  /-- `p` = aggregate productivity in recession. -/
  p : ℝ
  /-- `pStar = p*` = aggregate productivity in a boom. -/
  pStar : ℝ
  /-- `μ` = Poisson rate of aggregate-state transitions. -/
  μ : ℝ
  /-- `θ` = recession market tightness. -/
  θ : ℝ
  /-- `θStar = θ*` = boom market tightness. -/
  θStar : ℝ
  /-- `εd = ε_d` = recession destruction cutoff. -/
  εd : ℝ
  /-- `εdStar = ε_d*` = boom destruction cutoff. -/
  εdStar : ℝ
  p_order : p < pStar
  μ_nonneg : 0 ≤ μ
  θ_pos : 0 < θ
  θStar_pos : 0 < θStar
  εdStar_lt_εd : εdStar < εd
  εd_lt_εu : εd < P.εu
  boom_destruction :
    P.BoomDestructionCondition pStar θStar εdStar εd μ
  recession_destruction :
    P.RecessionDestructionCondition p θ εdStar εd μ
  /-- Equation (28), identical to stationary job creation conditional on the
  recession cutoff. -/
  recession_creation : P.JobCreationCondition θ εd
  boom_creation :
    P.BoomJobCreationCondition θStar εdStar εd μ

/-- State-contingent reduced equilibria for the Markov formulation in
equations (32)--(34). -/
structure MarkovEquilibrium (State : Type*) (P : State → Primitives) where
  /-- `E(s)` = reduced equilibrium in aggregate state `s`. -/
  E : ∀ s, SteadyStateEquilibrium (P s)
  /-- `G(t|s)` = transition probability from state `s` to state `t`. -/
  G : State → State → ℝ
  G_nonneg : ∀ s t, 0 ≤ G s t
  G_rows_sum_one : ∀ s, ∑' t, G s t = 1

/-- The value-function Markov equilibrium of equations (32)--(34).  This is
the anticipated-shock analogue of `ValueEquilibrium`. -/
structure GeneralMarkovValueEquilibrium
    (State : Type*) [Fintype State] (P : State → Primitives) where
  θ : State → ℝ
  εd : State → ℝ
  /-- `S(ε,s)` = match surplus in aggregate state `s`. -/
  S : ℝ → State → ℝ
  /-- `μ(s)` = aggregate-shock arrival rate in state `s`. -/
  μ : State → ℝ
  /-- `G(t|s)` = conditional next-state distribution. -/
  G : State → State → ℝ
  θ_pos : ∀ s, 0 < θ s
  εd_lt_εu : ∀ s, εd s < (P s).εu
  μ_nonneg : ∀ s, 0 ≤ μ s
  G_nonneg : ∀ s t, 0 ≤ G s t
  G_rows_sum_one : ∀ s, ∑ t, G s t = 1
  /-- Equation (32): free entry expressed with the worker meeting rate. -/
  free_entry : ∀ s,
    (P s).mWorker (θ s) * (1 - (P s).β) *
      S (P s).εu s = (P s).c
  /-- Equation (33): the state-contingent destruction cutoff. -/
  cutoff_zero : ∀ s, S (εd s) s = 0
  /-- Equation (34): the current-state Bellman equation, including the
  expectation over the next aggregate state. -/
  surplus_bellman : ∀ s ε,
    ((P s).r + (P s).«λ» + μ s) * S ε s =
      (P s).price ε - (P s).b -
        (P s).β * (P s).mWorker (θ s) *
          S (P s).εu s +
        (P s).«λ» *
          (P s).positiveContinuation (fun x => S x s) +
        μ s * ∑ t, G s t * max (S ε t) 0

/-- A discrete simulation path satisfying equations (36)--(38).  The ongoing
destruction term can be instantiated with the second term in equation (37),
while `immediate` is the mass between the old and new cutoffs. -/
structure SimulationPath (P : Primitives) where
  /-- `N(t)` = employment at the beginning of period `t`. -/
  N : ℕ → ℝ
  /-- `a(t)` = job meeting rate per unemployed worker. -/
  a : ℕ → ℝ
  /-- `D_immediate(t)` = jobs scrapped immediately after a cutoff jump. -/
  D_immediate : ℕ → ℝ
  /-- `D_ongoing(t)` = destruction caused by idiosyncratic shocks. -/
  D_ongoing : ℕ → ℝ
  /-- `C(t)` = job creation flow. -/
  C : ℕ → ℝ
  /-- `D(t)` = total job destruction flow. -/
  D : ℕ → ℝ
  creation_law : ∀ t,
    C t = Primitives.periodCreation (a t) (N t)
  destruction_law : ∀ t,
    D t = Primitives.periodDestruction (D_immediate t) (D_ongoing t)
  employment_law : ∀ t,
    N (t + 1) = Primitives.nextEmployment (N t) (C t) (D t)

end MP1994
