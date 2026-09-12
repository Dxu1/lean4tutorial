# M03B2 exact signatures

Actual output is recorded in `reports/logs/m03b2/targeted_build.log`.  The assigned contract
and every new public helper pass `assert_no_sorry`; the direct audit prints the complete set.

```text
Aiyagari1994.utilityZeroRightMarginal
  (m : Aiyagari1994.HouseholdPrimitives) : ENNReal

Aiyagari1994.utilityZeroSecant_antitone
  (m : Aiyagari1994.HouseholdPrimitives) :
  AntitoneOn (fun y : Real => ENNReal.ofReal (slope m.utility.utility 0 y)) (Set.Ioi 0)

Aiyagari1994.utilityZeroRightMarginal_secant_limit
  (m : Aiyagari1994.HouseholdPrimitives) :
  Filter.Tendsto
    (fun y : Real => ENNReal.ofReal (slope m.utility.utility 0 y))
    (nhdsWithin 0 (Set.Ioi 0))
    (nhds (Aiyagari1994.utilityZeroRightMarginal m))

Aiyagari1994.utilityZeroRightMarginal_pos
  (m : Aiyagari1994.HouseholdPrimitives) :
  0 < Aiyagari1994.utilityZeroRightMarginal m

Aiyagari1994.utility_secant_le_zeroRightMarginal
  (m : Aiyagari1994.HouseholdPrimitives) {x y : Real}
  (hx : 0 ≤ x) (hxy : x < y) :
  ENNReal.ofReal (slope m.utility.utility x y) ≤
    Aiyagari1994.utilityZeroRightMarginal m

Aiyagari1994.utility_increment_le_zeroMarginal
  (m : Aiyagari1994.HouseholdPrimitives)
  (hfinite : Aiyagari1994.utilityZeroRightMarginal m < ⊤)
  {x y : Real} (hx : 0 ≤ x) (hxy : x ≤ y) :
  m.utility.utility y - m.utility.utility x ≤
    (Aiyagari1994.utilityZeroRightMarginal m).toReal * (y - x)

Aiyagari1994.valueFunction_increment_le_zeroMarginal
  (m : Aiyagari1994.HouseholdPrimitives)
  (hfinite : Aiyagari1994.utilityZeroRightMarginal m < ⊤)
  (hbetaR : m.beta * m.prices.grossReturn ≤ 1)
  {x y : Aiyagari1994.Resources} (hxy : x ≤ y) :
  Aiyagari1994.valueFunction m y - Aiyagari1994.valueFunction m x ≤
    (Aiyagari1994.utilityZeroRightMarginal m).toReal * ((y : Real) - (x : Real))

Aiyagari1994.continuation_increment_le_zeroMarginal
  (m : Aiyagari1994.HouseholdPrimitives)
  (hfinite : Aiyagari1994.utilityZeroRightMarginal m < ⊤)
  (hbetaR : m.beta * m.prices.grossReturn ≤ 1)
  {a b : Aiyagari1994.Resources} (hab : a ≤ b) :
  Aiyagari1994.continuation m (Aiyagari1994.valueFunction m) b -
      Aiyagari1994.continuation m (Aiyagari1994.valueFunction m) a ≤
    (Aiyagari1994.utilityZeroRightMarginal m).toReal *
      m.prices.grossReturn * ((b : Real) - (a : Real))

Aiyagari1994.consumption_positive_subcritical
  (m : Aiyagari1994.HouseholdPrimitives)
  (_hsmooth : Aiyagari1994.UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1)
  (z : Aiyagari1994.Resources) :
  0 < z → 0 < Aiyagari1994.consumptionPolicy m z
```

Every declaration above has transitive axioms exactly
`[propext, Classical.choice, Quot.sound]`.
