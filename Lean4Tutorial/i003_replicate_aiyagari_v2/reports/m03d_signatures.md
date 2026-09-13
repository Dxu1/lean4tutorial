# M03D exact signatures

The signature probe is `Probes/M03DSignatures.lean`. Its concise elaborated output is:

```text
Aiyagari1994.minimumEffectiveIncome
  (m : HouseholdPrimitives) : Resources

Aiyagari1994.binding_interval_exists
  (m : HouseholdPrimitives)
  (hsmooth : UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1)
  (hthreshold : 0 < minimumEffectiveIncome m ∨
    utilityZeroRightMarginal m < ⊤) :
  ∃ zHat : Resources, minimumEffectiveIncome m < zHat ∧
    ∀ z : Resources, minimumEffectiveIncome m ≤ z → z ≤ zHat →
      assetPolicy m z = 0
```

For both declarations Lean reports exactly
`[propext, Classical.choice, Quot.sound]` as transitive axioms.
