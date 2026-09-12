# M03B3 exact signatures

The signature probe is `Probes/M03B3Signatures.lean`. Its concise elaborated output is:

```text
Aiyagari1994.concave_hasDerivAt_of_lowerTouching {S : Set ℝ} {f g : ℝ → ℝ} {x d : ℝ}
  (hf : ConcaveOn ℝ S f) (hx : x ∈ interior S) (hg : HasDerivAt g d x)
  (heq : g x = f x) (htouch : ∀ᶠ (y : ℝ) in nhds x, g y ≤ f y) :
  HasDerivAt f d x

Aiyagari1994.value_envelope_at_positive_consumption
  (m : Aiyagari1994.HouseholdPrimitives)
  (hsmooth : Aiyagari1994.UtilitySmooth m.utility)
  (z : Aiyagari1994.Resources) (hz : 0 < z)
  (hc : 0 < Aiyagari1994.consumptionPolicy m z) :
  HasDerivAt (Aiyagari1994.valueExtension m)
      (deriv m.utility.utility ↑(Aiyagari1994.consumptionPolicy m z)) ↑z ∧
    Aiyagari1994.rightMarginalValue m ↑z =
      deriv m.utility.utility ↑(Aiyagari1994.consumptionPolicy m z)
```

For both declarations Lean reports the transitive axiom list
`[propext, Classical.choice, Quot.sound]`.
