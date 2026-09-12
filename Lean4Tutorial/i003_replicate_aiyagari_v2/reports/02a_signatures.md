# M02A exact elaborated signatures

Direct command: `lake env lean Probes/M02ASignatures.lean`, exit 0.
The output prints the four contract anchors, canonical objects, ordinary
real concavity formula, and maximization equivalence. Ellipses are Lean
pretty-printer elision of proof arguments; no economic premises are elided.
The corresponding definitions and proofs are in the included Lean sources.

```text
Aiyagari1994.bellman_selfmap_contracting (m : Aiyagari1994.HouseholdPrimitives) :
  ContractingWith ⟨m.beta, ⋯⟩ (Aiyagari1994.bellmanOperator m)
'Aiyagari1994.bellman_selfmap_contracting' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.valueFunction_unique_fixedPoint (m : Aiyagari1994.HouseholdPrimitives) :
  Aiyagari1994.bellmanOperator m (Aiyagari1994.valueFunction m) = Aiyagari1994.valueFunction m ∧
    (∀ (v : Aiyagari1994.ValueSpace), Aiyagari1994.bellmanOperator m v = v → v = Aiyagari1994.valueFunction m) ∧
      (∀ (v : Aiyagari1994.ValueSpace),
          TendstoUniformly (fun n z => ((Aiyagari1994.bellmanOperator m)^[n] v) z) (⇑(Aiyagari1994.valueFunction m))
            Filter.atTop) ∧
        ∀ (z : Aiyagari1994.Resources),
          Aiyagari1994.utilityInf m / (1 - m.beta) ≤ (Aiyagari1994.valueFunction m) z ∧
            (Aiyagari1994.valueFunction m) z ≤ Aiyagari1994.utilitySup m / (1 - m.beta)
'Aiyagari1994.valueFunction_unique_fixedPoint' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.valueFunction_concave_strictMono (m : Aiyagari1994.HouseholdPrimitives) :
  Aiyagari1994.NNRealConcave ⇑(Aiyagari1994.valueFunction m) ∧ StrictMono ⇑(Aiyagari1994.valueFunction m)
'Aiyagari1994.valueFunction_concave_strictMono' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.assetPolicy_unique_continuous (m : Aiyagari1994.HouseholdPrimitives) :
  (∀ (z : Aiyagari1994.Resources),
      Aiyagari1994.AssetOptimal m z (Aiyagari1994.assetPolicy m z) ∧
        ∀ (a : Aiyagari1994.Resources), Aiyagari1994.AssetOptimal m z a → a = Aiyagari1994.assetPolicy m z) ∧
    Continuous (Aiyagari1994.assetPolicy m) ∧
      (∀ (z a : Aiyagari1994.Resources),
          a ≤ z →
            Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z a ≤
              Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z (Aiyagari1994.assetPolicy m z)) ∧
        (∀ (z : Aiyagari1994.Resources), 0 ≤ Aiyagari1994.assetPolicy m z ∧ Aiyagari1994.assetPolicy m z ≤ z) ∧
          (∀ (z : Aiyagari1994.Resources),
              ↑(Aiyagari1994.consumptionPolicy m z) = ↑z - ↑(Aiyagari1994.assetPolicy m z) ∧
                Aiyagari1994.consumptionPolicy m z + Aiyagari1994.assetPolicy m z = z) ∧
            Continuous (Aiyagari1994.consumptionPolicy m)
'Aiyagari1994.assetPolicy_unique_continuous' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.bellmanOperator (m : Aiyagari1994.HouseholdPrimitives) (v : Aiyagari1994.ValueSpace) :
  Aiyagari1994.ValueSpace
'Aiyagari1994.bellmanOperator' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.valueFunction (m : Aiyagari1994.HouseholdPrimitives) : Aiyagari1994.ValueSpace
'Aiyagari1994.valueFunction' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.assetPolicy (m : Aiyagari1994.HouseholdPrimitives) (z : Aiyagari1994.Resources) : Aiyagari1994.Resources
'Aiyagari1994.assetPolicy' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.consumptionPolicy (m : Aiyagari1994.HouseholdPrimitives) (z : Aiyagari1994.Resources) :
  Aiyagari1994.Resources
'Aiyagari1994.consumptionPolicy' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.AssetOptimal (m : Aiyagari1994.HouseholdPrimitives) (z a : Aiyagari1994.Resources) : Prop
'Aiyagari1994.AssetOptimal' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.NNRealConcave (f : Aiyagari1994.Resources → ℝ) : Prop
'Aiyagari1994.NNRealConcave' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.utilityRange (m : Aiyagari1994.HouseholdPrimitives) : Set ℝ
'Aiyagari1994.utilityRange' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.utilityInf (m : Aiyagari1994.HouseholdPrimitives) : ℝ
'Aiyagari1994.utilityInf' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.utilitySup (m : Aiyagari1994.HouseholdPrimitives) : ℝ
'Aiyagari1994.utilitySup' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.assetPolicy_existsUnique_maximizer (m : Aiyagari1994.HouseholdPrimitives) (z : Aiyagari1994.Resources) :
  ∃! a,
    a ≤ z ∧
      ∀ b ≤ z,
        Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z b ≤
          Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z a
'Aiyagari1994.assetPolicy_existsUnique_maximizer' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.assetOptimal_iff_maximizes (m : Aiyagari1994.HouseholdPrimitives) (z a : Aiyagari1994.Resources) :
  Aiyagari1994.AssetOptimal m z a ↔
    a ≤ z ∧
      ∀ b ≤ z,
        Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z b ≤
          Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z a
'Aiyagari1994.assetOptimal_iff_maximizes' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.NNRealConcave.real_combination {f : Aiyagari1994.Resources → ℝ} (hf : Aiyagari1994.NNRealConcave f)
  (x y : Aiyagari1994.Resources) (theta : ℝ) (h0 : 0 ≤ theta) (h1 : theta ≤ 1) :
  theta * f x + (1 - theta) * f y ≤ f ⟨theta * ↑x + (1 - theta) * ↑y, ⋯⟩
'Aiyagari1994.NNRealConcave.real_combination' depends on axioms: [propext, Classical.choice, Quot.sound]
structure Aiyagari1994.HouseholdPrimitives : Type
number of parameters: 0
fields:
  Aiyagari1994.HouseholdPrimitives.beta : ℝ
  Aiyagari1994.HouseholdPrimitives.beta_pos : 0 < self.beta
  Aiyagari1994.HouseholdPrimitives.beta_lt_one : self.beta < 1
  Aiyagari1994.HouseholdPrimitives.utility : Aiyagari1994.UtilityData
  Aiyagari1994.HouseholdPrimitives.utility_base : Aiyagari1994.UtilityBase self.utility
  Aiyagari1994.HouseholdPrimitives.income : Aiyagari1994.IncomeData
  Aiyagari1994.HouseholdPrimitives.income_support : Aiyagari1994.IncomeSupport self.income
  Aiyagari1994.HouseholdPrimitives.prices : Aiyagari1994.NormalizedPrices self.income
constructor:
  Aiyagari1994.HouseholdPrimitives.mk (beta : ℝ) (beta_pos : 0 < beta) (beta_lt_one : beta < 1)
    (utility : Aiyagari1994.UtilityData) (utility_base : Aiyagari1994.UtilityBase utility)
    (income : Aiyagari1994.IncomeData) (income_support : Aiyagari1994.IncomeSupport income)
    (prices : Aiyagari1994.NormalizedPrices income) : Aiyagari1994.HouseholdPrimitives
def Aiyagari1994.AssetOptimal : Aiyagari1994.HouseholdPrimitives →
  Aiyagari1994.Resources → Aiyagari1994.Resources → Prop :=
fun m z a =>
  a ≤ z ∧ Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z a = (Aiyagari1994.valueFunction m) z
def Aiyagari1994.NNRealConcave : (Aiyagari1994.Resources → ℝ) → Prop :=
fun f => ∀ (x y a b : Aiyagari1994.Resources), a + b = 1 → ↑a * f x + ↑b * f y ≤ f (a * x + b * y)
```
