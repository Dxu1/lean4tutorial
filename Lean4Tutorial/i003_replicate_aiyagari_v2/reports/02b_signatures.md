# M02B exact elaborated interfaces

Command: `lake env lean Probes/M02BSignatures.lean`. Exit status 0.

The following is the actual Lean output, including the plan structure fields. All printed declarations also pass `assert_no_sorry`. The full 254-declaration audit is in `reports/logs/02b/audit.log`.

```text
Aiyagari1994.FeasiblePlan (m : Aiyagari1994.HouseholdPrimitives) (z0 : Aiyagari1994.Resources) : Type
'Aiyagari1994.FeasiblePlan' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.planResources {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (t : ℕ) : Aiyagari1994.History m t → Aiyagari1994.Resources
'Aiyagari1994.planResources' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.planConsumption {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (t : ℕ) (h : Aiyagari1994.History m t) : Aiyagari1994.Resources
'Aiyagari1994.planConsumption' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.expectedFlow {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (t : ℕ) : ℝ
'Aiyagari1994.expectedFlow' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.finiteUtility {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (N : ℕ) : ℝ
'Aiyagari1994.finiteUtility' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.lifetimeUtility {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) : ℝ
'Aiyagari1994.lifetimeUtility' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.canonicalPlan (m : Aiyagari1994.HouseholdPrimitives) (z0 : Aiyagari1994.Resources) :
  Aiyagari1994.FeasiblePlan m z0
'Aiyagari1994.canonicalPlan' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.finiteHorizon_verification {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (N : ℕ) :
  Aiyagari1994.finiteUtility p N + m.beta ^ N * Aiyagari1994.expectedTerminalValue p N ≤
    (Aiyagari1994.valueFunction m) z0
'Aiyagari1994.finiteHorizon_verification' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.canonical_finiteHorizon_verification (m : Aiyagari1994.HouseholdPrimitives) (z0 : Aiyagari1994.Resources)
  (N : ℕ) :
  Aiyagari1994.finiteUtility (Aiyagari1994.canonicalPlan m z0) N +
      m.beta ^ N * Aiyagari1994.expectedTerminalValue (Aiyagari1994.canonicalPlan m z0) N =
    (Aiyagari1994.valueFunction m) z0
'Aiyagari1994.canonical_finiteHorizon_verification' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.canonicalPolicy_lifetime_optimal (m : Aiyagari1994.HouseholdPrimitives) (z0 : Aiyagari1994.Resources) :
  (∀ (p : Aiyagari1994.FeasiblePlan m z0), Summable fun (t : ℕ) => |m.beta ^ t * Aiyagari1994.expectedFlow p t|) ∧
    (∀ (p : Aiyagari1994.FeasiblePlan m z0), Aiyagari1994.lifetimeUtility p ≤ (Aiyagari1994.valueFunction m) z0) ∧
      Aiyagari1994.lifetimeUtility (Aiyagari1994.canonicalPlan m z0) = (Aiyagari1994.valueFunction m) z0 ∧
        ∀ (p : Aiyagari1994.FeasiblePlan m z0),
          Aiyagari1994.lifetimeUtility p ≤ Aiyagari1994.lifetimeUtility (Aiyagari1994.canonicalPlan m z0)
'Aiyagari1994.canonicalPolicy_lifetime_optimal' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.history_integral_step (m : Aiyagari1994.HouseholdPrimitives) (n : ℕ)
  (F : Aiyagari1994.History m (n + 1) → ℝ)
  (hF : MeasureTheory.Integrable F (Aiyagari1994.historyLaw m.income (n + 1))) :
  ∫ (h : Fin (n + 1) → ↑m.income.Labor), F h ∂Aiyagari1994.historyLaw m.income (n + 1) =
    ∫ (h : Fin n → ↑m.income.Labor),
      ∫ (l : ↑(Aiyagari1994.Labor m.income.lower m.income.upper)),
        F (Aiyagari1994.extendHistory m n l h) ∂↑m.income.law ∂Aiyagari1994.historyLaw m.income n
'Aiyagari1994.history_integral_step' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.original_shifted_trajectory_budget_iff {i : Aiyagari1994.IncomeData} (p : Aiyagari1994.OriginalPrices i)
  (assets consumption : ℕ → ℝ) (labor : ℕ → ↑i.Labor) :
  (∀ (t : ℕ),
      consumption t + assets (t + 1) = (1 + p.netRate) * assets t + p.wage * ↑(labor t) ∧
        -p.debtLimit ≤ assets (t + 1)) ↔
    ∀ (t : ℕ),
      consumption t + (assets (t + 1) + p.debtLimit) =
          p.normalized.grossReturn * (assets t + p.debtLimit) + p.wage * ↑(labor t) - p.netRate * p.debtLimit ∧
        0 ≤ assets (t + 1) + p.debtLimit
'Aiyagari1994.original_shifted_trajectory_budget_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.plan_original_budget_step {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (prices : Aiyagari1994.OriginalPrices m.income)
  (hp : prices.normalized = m.prices) (t : ℕ) (h : Aiyagari1994.History m (t + 1)) :
  ↑(Aiyagari1994.planConsumption p (t + 1) h) + (↑(p.action (t + 1) h) - prices.debtLimit) =
      (1 + prices.netRate) * (↑(p.action t (Aiyagari1994.previousHistory m t h)) - prices.debtLimit) +
        prices.wage * ↑(Aiyagari1994.newestShock m t h) ∧
    -prices.debtLimit ≤ ↑(p.action (t + 1) h) - prices.debtLimit
'Aiyagari1994.plan_original_budget_step' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.plan_original_budget_initial {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
  (p : Aiyagari1994.FeasiblePlan m z0) (prices : Aiyagari1994.OriginalPrices m.income) (initialAssets : ℝ)
  (initialLabor : ↑m.income.Labor)
  (hz :
    ↑z0 =
      (1 + prices.netRate) * (initialAssets + prices.debtLimit) + prices.wage * ↑initialLabor -
        prices.netRate * prices.debtLimit)
  (h : Aiyagari1994.History m 0) :
  ↑(Aiyagari1994.planConsumption p 0 h) + (↑(p.action 0 h) - prices.debtLimit) =
      (1 + prices.netRate) * initialAssets + prices.wage * ↑initialLabor ∧
    -prices.debtLimit ≤ ↑(p.action 0 h) - prices.debtLimit
'Aiyagari1994.plan_original_budget_initial' depends on axioms: [propext, Classical.choice, Quot.sound]
structure Aiyagari1994.FeasiblePlan (m : Aiyagari1994.HouseholdPrimitives) (z0 : Aiyagari1994.Resources) : Type
number of parameters: 2
fields:
  Aiyagari1994.FeasiblePlan.action : (t : ℕ) → Aiyagari1994.History m t → Aiyagari1994.Resources
  Aiyagari1994.FeasiblePlan.measurable_action : ∀ (t : ℕ), Measurable (self.action t)
  Aiyagari1994.FeasiblePlan.feasible : ∀ (t : ℕ) (h : Aiyagari1994.History m t),
      self.action t h ≤ Aiyagari1994.actionResources m z0 self.action t h
constructor:
  Aiyagari1994.FeasiblePlan.mk {m : Aiyagari1994.HouseholdPrimitives} {z0 : Aiyagari1994.Resources}
    (action : (t : ℕ) → Aiyagari1994.History m t → Aiyagari1994.Resources)
    (measurable_action : ∀ (t : ℕ), Measurable (action t))
    (feasible : ∀ (t : ℕ) (h : Aiyagari1994.History m t), action t h ≤ Aiyagari1994.actionResources m z0 action t h) :
    Aiyagari1994.FeasiblePlan m z0
```
