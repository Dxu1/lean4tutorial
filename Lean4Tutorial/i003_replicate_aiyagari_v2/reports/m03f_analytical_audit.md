# M03F analytical audit

Baseline: `1c17e1bd342e5fd87707a5774d39e1cfe8102918`. Assigned contract: D01 only.

| Required question | Answer and proof evidence |
|---|---|
| Is EXACT_DIAGNOSTIC instantiated exactly? | Yes. Definitions fix beta=1/2, R=w=3/2, r=1/2, phi=2, labor on [2/3,4/3], and `U(c)=sqrt(c)/(1+sqrt(c))`. The theorem has no premises. |
| Is the state and income model continuous? | Yes. States and actions remain `NNReal`. Labor is the pushforward of the continuous uniform law on `[0,1]`, not a finite support or asset grid. The affine image theorem proves effective income has exactly `volume.restrict (Icc 0 1)`. |
| Are all core primitive conditions proved? | Yes. `CoreRegularity exactDiagnosticModel` packages smoothness, curvature, essential-endpoint nondegeneracy, and mean-one labor. `HouseholdPrimitives` contains beta bounds, BASIC utility properties, compact income support, positive R and wage, and nonnegative effective income. |
| Is Inada formally tied to utility? | Yes. The theorem states that the ordinary derivative on every `c>0` equals `exactDiagnosticMarginal c`, and that this explicit marginal tends to `atTop` as `c` approaches zero from the right. No derivative at zero is invoked. |
| Is the RRA algebra exact? | Yes. The exported lemma proves `-c*U''(c)/U'(c) = 1/2 + sqrt(c)/(1+sqrt(c)) < 3/2` for every `c>0`. This verifies the curvature profile analytically. |
| Are zero minimum income and absence of an atom both certified? | Yes. The lower labor endpoint realizes effective income zero. The exact pushforward to uniform `[0,1]` then proves the singleton zero has measure zero. |
| How are the value bounds obtained? | The exact utility satisfies `0≤U<1`; the accepted Bellman bounds with beta=1/2 yield `0≤V≤2` at every continuous resource state. |
| Are real integrals interpreted only after integrability? | Yes. The continuation integrands are continuous and bounded. Existing `continuation_integrable` and continuous interval-integrability facts justify the pushforward, change-of-variables, subtraction, and interval bounds before the real integrals are used economically. No marginal is integrated. |
| Is the sliding-integral derivative exact? | Yes. A generic moving-endpoint FTC lemma proves `d/da ∫_0^1 f(Ra+x)dx = R(f(1)-f(0))` at zero for continuous `f`. Instantiation with the continuous nonnegative extension of `V` gives exactly `(3/2)(V(1)-V(0))`. No differentiability of `V` is assumed. |
| What finite estimate drives the policy proof? | A companion analytic lemma proves directly that continuous `0≤f≤C` satisfies `∫_0^1 f(x+h)dx-∫_0^1 f(x)dx≤Ch`. Applied to `0≤V≤2` and `h=3a/2`, it bounds the undiscounted continuation gain by `3a`; this secant estimate turns the derivative comparison into a global feasible-action inequality. |
| Why does zero saving maximize the objective? | For `0<z≤1/100`, exact algebra gives `U'(z)>3/2`. Concavity gives current utility loss at least `(3/2)a`, while beta=1/2 times the continuation gain is at most `(3/2)a`. Thus every feasible action has objective no larger than action zero; uniqueness of the accepted H04 maximizer identifies `A(z)=0`. |
| Is the zero-state marginal qualification preserved? | Yes. Neither `rightMarginalValue` nor `zeroRightMarginal` is used. In particular, the proof never evaluates `rightMarginalValue m 0`; it makes no finite claim about the economic ENNReal zero-state marginal. |
| Are impatience or consumption positivity smuggled in? | No premise or imported theorem supplies either. The exact constants imply beta*R=3/4 as data, but the proof uses only their numerical values. No H10 result or positive-consumption hypothesis appears. |
| Are later claims inferred? | No. D01 proves only the exact diagnostic. It establishes no general atom-free theorem, no threshold maximality, no stationarity or equilibrium result, and does not alter Proposition 3. |

## Source audit

The approved A93 file has SHA-256
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.
Rendered inspection covered PDF p. 39, printed p. 38. Proposition 3 gives the qualified binding
interval and the following note states the unqualified Inada/zero-minimum-income nonbinding
claim. D01 targets the note only.

The approved A94 file has SHA-256
`75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.
Rendered inspection covered PDF p. 10, printed p. 667. It supplies the published threshold
discussion and shifted-policy context, not the counterexample proof.

## Assumption and axiom conclusion

D01 constructs every EXACT_DIAGNOSTIC datum and discharges the primitive profiles instead of
assuming a conclusion-bearing witness. Its transitive axiom output is exactly `propext`,
`Classical.choice`, and `Quot.sound`. No project axiom, `sorryAx`, unsafe bypass, numerical
certificate, marginal-integrability shortcut, or later theorem occurs. D01 is REVIEW_READY, not
GREEN; the source correction remains proposed pending independent adequacy review.
