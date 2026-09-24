# M03F exact signatures

The direct probe `Probes/M03FSignatures.lean` elaborates the contracted export as follows
(namespace prefixes are retained where they disambiguate project objects):

```text
Aiyagari1994.inada_without_atom_binding_example :
  Aiyagari1994.CoreRegularity Aiyagari1994.exactDiagnosticModel ∧
  Aiyagari1994.exactDiagnosticOriginalPrices.netRate = 1 / 2 ∧
  Aiyagari1994.exactDiagnosticOriginalPrices.wage = 3 / 2 ∧
  Aiyagari1994.exactDiagnosticOriginalPrices.debtLimit = 2 ∧
  Aiyagari1994.exactDiagnosticModel.beta = 1 / 2 ∧
  Aiyagari1994.exactDiagnosticModel.prices.grossReturn = 3 / 2 ∧
  (∀ l : Aiyagari1994.exactDiagnosticIncome.Labor,
    Aiyagari1994.exactDiagnosticModel.prices.effectiveIncome l =
      3 / 2 * (l : ℝ) - 1) ∧
  MeasureTheory.Measure.map
      (fun l : Aiyagari1994.exactDiagnosticIncome.Labor =>
        Aiyagari1994.exactDiagnosticModel.prices.effectiveIncome l)
      Aiyagari1994.exactDiagnosticIncome.law =
    MeasureTheory.volume.restrict (Set.Icc 0 1) ∧
  Aiyagari1994.exactDiagnosticModel.prices.effectiveIncome
      Aiyagari1994.exactDiagnosticLowerLabor = 0 ∧
  (MeasureTheory.Measure.map
      (fun l : Aiyagari1994.exactDiagnosticIncome.Labor =>
        Aiyagari1994.exactDiagnosticModel.prices.effectiveIncome l)
      Aiyagari1994.exactDiagnosticIncome.law) {0} = 0 ∧
  Aiyagari1994.exactDiagnosticUtility.utility 0 = 0 ∧
  (∀ c : ℝ, 0 < c →
    deriv Aiyagari1994.exactDiagnosticUtility.utility c =
      Aiyagari1994.exactDiagnosticMarginal c) ∧
  Filter.Tendsto Aiyagari1994.exactDiagnosticMarginal
    (nhdsWithin 0 (Set.Ioi 0)) Filter.atTop ∧
  (∀ z : Aiyagari1994.Resources,
    0 ≤ Aiyagari1994.valueFunction Aiyagari1994.exactDiagnosticModel z ∧
    Aiyagari1994.valueFunction Aiyagari1994.exactDiagnosticModel z ≤ 2) ∧
  (∀ z : Aiyagari1994.Resources, 0 < z → z ≤ 1 / 100 →
    Aiyagari1994.assetPolicy Aiyagari1994.exactDiagnosticModel z = 0)
```

The proof-plan derivative export elaborates as:

```text
Aiyagari1994.exactDiagnostic_sliding_continuation_hasDerivAt :
  HasDerivAt
    (fun a : ℝ => ∫ x in (0 : ℝ)..1,
      nonnegativeExtension (valueFunction exactDiagnosticModel) (3 / 2 * a + x))
    (3 / 2 * (valueFunction exactDiagnosticModel (1 : Resources) -
      valueFunction exactDiagnosticModel (0 : Resources))) 0
```

The same probe's transitive axiom output is:

```text
'Aiyagari1994.inada_without_atom_binding_example' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

There are no theorem arguments: `EXACT_DIAGNOSTIC` is instantiated by definitions and proved
properties, not assumed as a record containing the conclusion.
