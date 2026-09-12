# M03B3 analytical audit

Baseline: `3b96d6654a2cc0771818ba0f6a381b497a5dae36`. Assigned contract: H11 only.

| Required question | Answer and proof evidence |
|---|---|
| Is the claimed derivative ordinary and two-sided? | Yes. The conclusion is a `HasDerivAt` certificate for `valueExtension m` at the positive real state, not merely a right derivative or Lean's default-valued `deriv`. |
| Does it equal current marginal utility? | Yes. Its derivative is exactly `deriv m.utility.utility (consumptionPolicy m z : Real)`. The theorem also identifies `rightMarginalValue m z` with the same number. |
| Is positive consumption local rather than globally assumed? | Yes. H11 takes `0 < consumptionPolicy m z` only at the quantified state. It neither invokes H10 nor assumes all states consume positively. |
| Is impatience absent? | Yes. The signature has no `beta * grossReturn < 1` premise and the proof contains no such inequality. `HouseholdPrimitives` retains only `0<beta<1` and `R>0`. |
| Is the lower-touching lemma actually formalized? | Yes. `concave_hasDerivAt_of_lowerTouching` quantifies over arbitrary real functions on an arbitrary convex domain through `ConcaveOn`, an interior point, a differentiable lower touch, equality at the point, and the local lower-bound relation. It proves `HasDerivAt` directly from one-sided secants. |
| Is the touching relation economically discharged? | Yes. Fixing canonical shifted savings `A(z)`, H04 maximization proves `U(x-A(z)) + beta G(A(z)) <= V(x)` whenever `x>A(z)`. H04's optimizer equality proves equality at `z`. |
| Is the neighborhood genuinely two-sided? | Yes. `c(z)>0` and the budget identity imply `A(z)<z`, so the open set `Ioi A(z)` is a neighborhood of `z`; it contains states on both sides of `z`. |
| Is utility differentiated only where SMOOTH applies? | Yes. Throughout that neighborhood, `x-A(z)>0`. At the contact point it equals positive `c(z)`, so `UtilitySmooth.smooth` on `Ioi 0` supplies the derivative. No differentiability at zero is assumed. |
| Is the continuation differentiated under its integral? | No. Savings is fixed, hence the continuation value is constant as `x` varies. The proof applies `add_const`; it does not exchange a derivative and integral or interpret a marginal expectation. |
| Is the accepted zero-marginal qualification preserved? | Yes. `rightMarginalValue` is used only at the explicitly positive state. `rightMarginalValue m 0` never occurs. `zeroRightMarginal : ENNReal` remains untouched and may be infinite. |
| Are H03/H04/H08 used in the intended roles? | Yes. H03 gives value concavity, H04 gives the canonical fixed-action lower touch and equality, and H08 gives the positive-state right secant limit for identification. No later theorem is used. |
| Is the general income law preserved? | Yes. No property beyond BASIC enters: there is no atom, density, nondegeneracy, positive effective-income minimum, finite support, or stationary distribution. |
| Does the proof claim an Euler equation or continuity of the derivative region? | No. H12 and all later conclusions remain unformalized. H11 proves only the pointwise local envelope statement. |

## Source audit

The approved A93 file has SHA-256
`274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.
Rendered inspection covered printed pp. 37-38 / PDF pp. 38-39. Proposition 2(c) gives the first
equality `V'(z_t)=U'(c_t)` and says it follows from the Benveniste-Scheinkman theorem; the Euler
inequality/equality that follows on printed p. 38 is outside this gate.

The approved BS79 file has SHA-256
`f1ae50d50f4574fa6e31ab480012c4bc6e74c231eeb85c5f58ae6a6ff99a5d65`.
Rendered inspection covered Lemma 1, printed p. 728 / PDF p. 3. It states that a real-valued
concave value function is differentiable at an interior contact point when a differentiable
concave function touches it locally from below. The Lean one-dimensional proof uses only the
weaker necessary hypotheses: differentiability and local lower touching of the comparison
function; concavity of the comparison function is not needed for the secant squeeze.

## Assumption and axiom conclusion

H11 exposes exactly BASIC and SMOOTH, plus the local positive-state and positive-consumption
hypotheses. The generic helper has mathematical assumptions only. No primitive record or field is
changed. Both new exports report only `propext`, `Classical.choice`, and `Quot.sound`; there is no
project axiom, `sorryAx`, unsafe bypass, or assumed closure record. H11 is REVIEW_READY, not GREEN.
