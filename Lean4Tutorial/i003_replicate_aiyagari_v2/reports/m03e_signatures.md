# M03E exact signatures

```text
Aiyagari1994.zero_income_atom_implies_nonbinding
  (m : Aiyagari1994.HouseholdPrimitives)
  (_hsmooth : Aiyagari1994.UtilitySmooth m.utility)
  (_hmin : Aiyagari1994.minimumEffectiveIncome m = 0)
  (hinada : Aiyagari1994.utilityZeroRightMarginal m = ⊤)
  (hatom : 0 < (m.income.law : Measure m.income.Labor)
    {l | m.prices.effectiveIncome l = 0})
  (z : Aiyagari1994.Resources) :
  0 < z → 0 < Aiyagari1994.assetPolicy m z
```

The declaration reports exactly `[propext, Classical.choice, Quot.sound]` under
`#print axioms` and passes `assert_no_sorry` in `Probes/M03ESignatures.lean` and `Audit.lean`.
