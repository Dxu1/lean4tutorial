import Mathlib

/-!
# Mortensen--Pissarides (1994): primitives and equations

This file formalizes the notation and the equations used in Sections 2--5 of
Mortensen and Pissarides, *Job Creation and Job Destruction in the Theory of
Unemployment*, Review of Economic Studies 61 (1994), 397--415.

The paper writes `ε` for the idiosyncratic component, `εᵤ` for its upper
support, `ε_d` for the destruction cutoff, `λ` for the Poisson arrival rate,
`σ` for dispersion, and `β` for the worker's Nash share.  Market tightness is
`θ = v / u`.
-/

open MeasureTheory Set
open scoped Interval

namespace MP1994

/-- Exogenous primitives of the MP (1994) model. -/
structure Primitives where
  /-- `r` = discount rate. -/
  r : ℝ
  /-- `λ` = Poisson arrival rate of job-specific shocks. -/
  «λ» : ℝ
  /-- `σ` = dispersion (standard deviation) of job-specific productivity. -/
  σ : ℝ
  /-- `β` = worker's share of match surplus. -/
  β : ℝ
  /-- `c` = flow cost of maintaining a vacancy. -/
  c : ℝ
  /-- `b` = value of leisure or unemployment income. -/
  b : ℝ
  /-- `p` = common/aggregate component of productivity. -/
  p : ℝ
  /-- `εu` = upper support `ε_u` of the idiosyncratic shock distribution. -/
  εu : ℝ
  /-- `dF` = probability measure induced by the paper's shock CDF `F`. -/
  dF : Measure ℝ
  /-- `q` = vacancy meeting rate, `q(θ) = m(v,u)/v`. -/
  q : ℝ → ℝ

namespace Primitives

variable (P : Primitives)

/-- The shock CDF `F(x)`. -/
noncomputable def F (x : ℝ) : ℝ :=
  (P.dF (Iic x)).toReal

/-- `θ = v/u` = market tightness. -/
noncomputable def θ (v u : ℝ) : ℝ :=
  v / u

/-- A searching worker's meeting rate `m(θ,1) = θ q(θ)`. -/
def mWorker (θ : ℝ) : ℝ :=
  θ * P.q θ

/-- `m(v,u) = v q(v/u)` = aggregate matches. -/
noncomputable def m (v u : ℝ) : ℝ :=
  v * P.q (θ v u)

/-- Output (or price) of a job with idiosyncratic component `ε`. -/
def price (ε : ℝ) : ℝ :=
  P.p + P.σ * ε

/-- The option-value integral in equations (9) and (10). -/
noncomputable def optionValueIntegral (εd : ℝ) : ℝ :=
  ∫ x in εd..P.εu, (1 - P.F x)

/-- A bounded tail integral of `1-F`, used in equations (19)--(24). -/
noncomputable def tailIntegral (lower upper : ℝ) : ℝ :=
  ∫ x in lower..upper, (1 - P.F x)

/-- The expectation of the positive continuation surplus in equations (5)--(8). -/
noncomputable def positiveContinuation (S : ℝ → ℝ) : ℝ :=
  ∫ x, max (S x) 0 ∂P.dF

/-- Endogenous separation hazard `λ F(ε_d)`. -/
noncomputable def destructionHazard (εd : ℝ) : ℝ :=
  P.«λ» * P.F εd

/-- Equation (12): match surplus relative to the destruction cutoff. -/
noncomputable def S_cutoff (εd ε : ℝ) : ℝ :=
  P.σ * (ε - εd) / (P.r + P.«λ»)

/-- The firm's Nash share of match surplus. -/
noncomputable def J_cutoff (εd ε : ℝ) : ℝ :=
  (1 - P.β) * P.S_cutoff εd ε

/-- The worker's gain over unemployment under Nash sharing. -/
noncomputable def WminusU_cutoff (εd ε : ℝ) : ℝ :=
  P.β * P.S_cutoff εd ε

/-- Equation (1), the vacancy Bellman equation. -/
def VacancyBellman (θ V Jupper : ℝ) : Prop :=
  P.r * V =
    -P.c + P.q θ * (Jupper - V)

/-- Equation (2), free entry/exhaustion of vacancy rents. -/
def FreeEntry (V : ℝ) : Prop :=
  P.r * V = 0

/-- Equation (3), the definition of total match surplus. -/
def SurplusIdentity (J W : ℝ → ℝ) (U : ℝ) (S : ℝ → ℝ) : Prop :=
  ∀ ε, S ε = J ε + W ε - U

/-- Equation (4), Nash sharing of match surplus. -/
def NashSharing (W : ℝ → ℝ) (U : ℝ) (S : ℝ → ℝ) : Prop :=
  ∀ ε, W ε - U = P.β * S ε

/-- Equation (5), the filled-job Bellman equation. -/
noncomputable def FilledJobBellman
    (J w S : ℝ → ℝ) : Prop :=
  ∀ ε,
    P.r * J ε =
      P.price ε - w ε +
        P.«λ» * (1 - P.β) *
          (P.positiveContinuation S - S ε)

/-- Equation (6), the employed worker's Bellman equation. -/
noncomputable def WorkerBellman
    (W w S : ℝ → ℝ) : Prop :=
  ∀ ε,
    P.r * W ε =
      w ε + P.«λ» * P.β *
        (P.positiveContinuation S - S ε)

/-- Equation (7), the unemployed worker's Bellman equation. -/
def UnemployedBellman (θ U Wupper : ℝ) : Prop :=
  P.r * U =
    P.b + P.mWorker θ * (Wupper - U)

/-- Equation (8), the Bellman equation for total match surplus. -/
noncomputable def SurplusBellman (θ : ℝ) (S : ℝ → ℝ) : Prop :=
  ∀ ε,
    (P.r + P.«λ») * S ε =
      P.price ε - P.b +
        P.«λ» * P.positiveContinuation S -
        P.β * P.mWorker θ * S P.εu

/-- Equation (10), the reduced job-destruction condition. -/
noncomputable def JobDestructionCondition (θ εd : ℝ) : Prop :=
  P.price εd =
    P.b +
      (P.β * P.c / (1 - P.β)) * θ -
      (P.σ * P.«λ» /
        (P.r + P.«λ»)) * P.optionValueIntegral εd

/-- The right-hand side of equation (11), i.e. the local elasticity-like
quantity `σ ∂ε_d/∂σ` while market tightness `θ` is held fixed. -/
noncomputable def dispersionCutoffResponse (θ εd : ℝ) : ℝ :=
  (((P.r + P.«λ») / P.σ) /
      (P.r + P.«λ» * P.F εd)) *
    (P.p - P.b -
      (P.β * P.c / (1 - P.β)) * θ)

/-- Equation (13), the reduced job-creation/free-entry condition. -/
def JobCreationCondition (θ εd : ℝ) : Prop :=
  P.q θ =
    (P.c / (1 - P.β)) *
      ((P.r + P.«λ») /
        (P.σ * (P.εu - εd)))

/-- Equation (20), the boom destruction condition when aggregate switching is
anticipated at Poisson rate `μ`.  The same idiosyncratic primitives are used in
both aggregate states. -/
noncomputable def BoomDestructionCondition
    (pStar θStar εdStar εd μ : ℝ) : Prop :=
  pStar + P.σ * εdStar =
    P.b +
      (P.β * P.c / (1 - P.β)) * θStar -
      (P.«λ» * P.σ /
        (P.r + P.«λ» + μ)) *
          P.tailIntegral εdStar εd -
      (P.«λ» * P.σ /
        (P.r + P.«λ»)) *
          P.tailIntegral εd P.εu

/-- Equation (24), the recession destruction condition under anticipated
aggregate switching. -/
noncomputable def RecessionDestructionCondition
    (p θ εdStar εd μ : ℝ) : Prop :=
  p + P.σ * εd =
    P.b +
      (P.β * P.c / (1 - P.β)) * θ -
      (P.«λ» * P.σ /
        (P.r + P.«λ»)) *
          P.tailIntegral εd P.εu -
      (μ * P.σ /
        (P.r + P.«λ» + μ)) *
          (εd - εdStar)

/-- Equation (29), the boom surplus in terms of recession surplus. -/
noncomputable def boomSurplus
    (εdStar εd μ ε : ℝ) : ℝ :=
  P.σ * (ε - εdStar) /
      (P.r + P.«λ» + μ) +
    (μ / (P.r + P.«λ» + μ)) *
      P.S_cutoff εd ε

/-- Equation (30), free entry/job creation in a boom when a future recession
is anticipated. -/
def BoomJobCreationCondition
    (θStar εdStar εd μ : ℝ) : Prop :=
  P.q θStar =
    (P.c * (P.r + P.«λ») /
      (1 - P.β)) /
      (P.σ * (P.εu - εdStar) -
        μ * P.σ * (εd - εdStar) /
          (P.r + P.«λ» + μ))

/-- Equation (14), the steady-state Beveridge curve. -/
noncomputable def BeveridgeCondition (θ εd u : ℝ) : Prop :=
  u =
    P.destructionHazard εd /
      (P.destructionHazard εd + P.mWorker θ)

/-- Job creation conditional on the current unemployment stock. -/
def creationFlow (θ u : ℝ) : ℝ :=
  u * P.mWorker θ

/-- Job destruction conditional on the current employment stock. -/
noncomputable def destructionFlow (εd u : ℝ) : ℝ :=
  (1 - u) * P.destructionHazard εd

/-- Equation (15), the continuous-time law of motion for unemployment. -/
noncomputable def unemploymentDrift (θ εd u : ℝ) : ℝ :=
  P.destructionFlow εd u - P.creationFlow θ u

/-- Equation (36): creation in a discrete simulation period. -/
def periodCreation (a N : ℝ) : ℝ :=
  a * (1 - N)

/-- The one-off destruction caused by raising the cutoff after a downturn. -/
noncomputable def immediateScrapping
    (n : ℝ → ℝ) (εdOld εdNew : ℝ) : ℝ :=
  ∫ x in εdOld..εdNew, n x

/-- Equation (37), written as immediate scrapping plus ongoing destruction. -/
def periodDestruction (D_immediate D_ongoing : ℝ) : ℝ :=
  D_immediate + D_ongoing

/-- Equation (38), the employment accounting identity. -/
def nextEmployment (N C D : ℝ) : ℝ :=
  N + C - D

end Primitives

/-- Standard sign, support, CDF, and matching assumptions used by the paper. -/
structure Assumptions (P : Primitives) : Prop where
  /-- `r > 0`: the discount rate is positive. -/
  r_pos : 0 < P.r
  /-- `λ ≥ 0`: the job-specific shock arrival rate is nonnegative. -/
  «λ_nonneg» : 0 ≤ P.«λ»
  /-- `σ > 0`: idiosyncratic dispersion is positive. -/
  σ_pos : 0 < P.σ
  /-- `β > 0`: the worker receives a positive surplus share. -/
  β_pos : 0 < P.β
  /-- `β < 1`: the firm also receives a positive surplus share. -/
  β_lt_one : P.β < 1
  /-- `c > 0`: maintaining a vacancy is costly. -/
  c_pos : 0 < P.c
  /-- `dF` has total mass one. -/
  dF_probability : P.dF univ = 1
  /-- `εu` is an upper support point of `dF`. -/
  dF_support_upper : P.dF (Iic P.εu) = 1
  /-- `0 ≤ F(x)`. -/
  F_nonneg : ∀ x, 0 ≤ P.F x
  /-- `F(x) ≤ 1`. -/
  F_le_one : ∀ x, P.F x ≤ 1
  /-- `F` is a CDF and hence monotone. -/
  F_monotone : Monotone P.F
  /-- `q(θ) > 0` at positive market tightness. -/
  q_pos : ∀ θ, 0 < θ → 0 < P.q θ
  /-- `q` is decreasing in market tightness. -/
  q_antitone : Antitone P.q
  /-- `m(θ,1) = θq(θ)` is increasing in market tightness. -/
  mWorker_monotone : Monotone P.mWorker

end MP1994
