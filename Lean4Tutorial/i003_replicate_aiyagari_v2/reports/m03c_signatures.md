# M03C exact signatures

The signature probe is `Probes/M03CSignatures.lean`. Its concise elaborated output is:

```text
Aiyagari1994.continuationValue_hasDerivAt_of_asset_pos
  (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1)
  (a : Resources) (ha : 0 < a) :
  Integrable (fun l => deriv m.utility.utility
      (consumptionPolicy m (m.prices.nextResources a l) : Real)) m.income.law ∧
  HasDerivAt
    (fun x : Real => ∫ l, valueExtension m
      (m.prices.grossReturn * x + m.prices.effectiveIncome l) ∂m.income.law)
    (m.prices.grossReturn * ∫ l, deriv m.utility.utility
      (consumptionPolicy m (m.prices.nextResources a l) : Real) ∂m.income.law)
    (a : Real)

Aiyagari1994.eulerNextMarginal
  (m : HouseholdPrimitives) (z : Resources) : ENNReal

Aiyagari1994.eulerNextMarginal_zero (m : HouseholdPrimitives) :
  eulerNextMarginal m 0 = zeroRightMarginal m

Aiyagari1994.eulerNextMarginal_of_pos
  (m : HouseholdPrimitives) {z : Resources} (hz : 0 < z) :
  eulerNextMarginal m z =
    ENNReal.ofReal (deriv m.utility.utility (consumptionPolicy m z : Real))

Aiyagari1994.eulerNextMarginal_eq_extendedRightMarginalValue
  (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1) (z : Resources) :
  eulerNextMarginal m z = extendedRightMarginalValue m z

Aiyagari1994.euler_subcritical
  (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1)
  (z : Resources) (hz : 0 < z) :
  (∀ᵐ l ∂m.income.law,
    eulerNextMarginal m (m.prices.nextResources (assetPolicy m z) l) < ⊤) ∧
  Integrable (fun l =>
    (eulerNextMarginal m (m.prices.nextResources (assetPolicy m z) l)).toReal)
    m.income.law ∧
  m.beta * m.prices.grossReturn * ∫ l,
      (eulerNextMarginal m (m.prices.nextResources (assetPolicy m z) l)).toReal
      ∂m.income.law ≤
    deriv m.utility.utility (consumptionPolicy m z : Real) ∧
  (0 < assetPolicy m z →
    Integrable (fun l => deriv m.utility.utility
      (consumptionPolicy m (m.prices.nextResources (assetPolicy m z) l) : Real))
      m.income.law ∧
    (∀ l, eulerNextMarginal m (m.prices.nextResources (assetPolicy m z) l) =
      ENNReal.ofReal (deriv m.utility.utility
        (consumptionPolicy m (m.prices.nextResources (assetPolicy m z) l) : Real))) ∧
    m.beta * m.prices.grossReturn * ∫ l, deriv m.utility.utility
        (consumptionPolicy m (m.prices.nextResources (assetPolicy m z) l) : Real)
        ∂m.income.law =
      deriv m.utility.utility (consumptionPolicy m z : Real))
```

For all six declarations Lean reports exactly
`[propext, Classical.choice, Quot.sound]` as transitive axioms.
