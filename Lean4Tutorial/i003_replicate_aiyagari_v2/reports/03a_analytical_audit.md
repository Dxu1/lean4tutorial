# M03A analytical adequacy audit

M02B_BASE: `b0bd1a77d97e88fb3add9b50168cbf02508c0522`.

| Required question | Answer and proof evidence |
|---|---|
| 1. Constructed from secant limits? | Yes. Negative infimum of the convex negative-value secants; proved one-sided limit, with an equivalent supremum-of-value-secants bridge. |
| 2. Genuine finite Real at positive states? | Yes. ConvexOn.hasDerivWithinAt_sInf_slope_of_mem_interior proves existence using a finite secant bound; the economic wrapper negates it. No differentiability premise. |
| 3. Can zero marginal equal infinity? | Its type is ENNReal and no finiteness restriction is imposed. The exact infinity criterion is proved. No separate infinite-marginal household witness is constructed in this gate. |
| 4. Strict positivity without differentiability? | Yes. A strictly positive right secant lies below q(z). |
| 5. Right continuity proved? | Yes. ContinuousWithinAt q (Ici z) z for each z>0; the two-limit fixed-secant sandwich proves equality of the monotone right limit with q(z). |
| 6. H08 uses BASIC only? | Yes. Accepted value concavity, strict increase, continuity and bounds. No new economic premises. |
| 7. Both policy monotonicities proved? | Yes, with separate utility and continuation cross-comparisons. |
| 8. Weak/order 1-Lipschitz claims? | Yes. The final theorem exposes both explicit real difference bounds and both Monotone statements. No strict-order or derivative claim. |
| 9. Accidental beta R < 1 dependence? | No. No impatience or CoreRegularity premise or declaration is used. |
| 10. Accidental H05 dependence? | No. New substantive imports reach Value/Policy/Bellman/Basic; they do not import Verification. Optimality used here is Bellman maximization and uniqueness. |

## Proof-route adaptation

The direct policy comparisons use weak concavity plus H04 unique maximization, which was proved from strict utility concavity. Thus strict concavity is used through the accepted uniqueness theorem rather than reproved as strict increasing differences. H08 uses the pinned proved convex-negative-value secant-infimum theorem to construct the finite right derivative, and proves right continuity and the ENNReal zero bridge explicitly. These are proof-organization/API adaptations; no economic assumption, mathematical quantifier or conclusion changes.

## Detailed readable arguments

**Status:** REVIEW_READY, pending external adequacy review. **Scope:** core. **Review gate:** M03A.

**Target:** `Aiyagari1994.policies_order_lipschitz`.

**Module:** `Aiyagari1994/Household/PolicyOrder.lean`.

**Mathematical statement.** Both shifted saving $A$ and consumption $c$ are nondecreasing. For $0\leq z_1\leq z_2$,
$$0\leq A(z_2)-A(z_1)\leq z_2-z_1,\qquad 0\leq c(z_2)-c(z_1)\leq z_2-z_1.$$
The public theorem expresses these differences in Real with explicit NNReal coercions. It makes no strict-order or policy-derivative claim.

**Actual assumptions and dependencies.** BASIC only. H03 supplies concavity of the constructed value, H04 supplies the unique maximizing shifted-asset policy and the consumption budget. The proof uses no H05 lifetime-optimality result. No impatience, smoothness, Inada, income nondegeneracy, mean-one labor, stationary law, asset bound or CoreRegularity enters. The state remains all NNReal and labor retains its general compactly supported probability law.

**Reusable concavity inequality.** `concave_four_point` proves that, for $f$ concave on $[0,\infty)$,
$$0\leq x<y,\quad x\leq u,v\leq y,\quad u+v=x+y
\quad\Longrightarrow\quad f(x)+f(y)\leq f(u)+f(v).$$
For $w=u,v$, write
$$w=\frac{y-w}{y-x}x+\frac{w-x}{y-x}y.$$
Concavity gives the two weighted inequalities. Adding them and using $u+v=x+y$ makes each endpoint coefficient equal one. This helper is proved directly from the definition of concavity, without a comparative-statics assumption.

**Savings order.** Suppose $A(z_2)<A(z_1)$. Both actions are feasible at both states. The original consumptions are the endpoints $z_1-A(z_1)$ and $z_2-A(z_2)$. Swapping savings gives the two inward consumptions, preserving their sum. Apply the four-point inequality to utility. The sum of the two Bellman optimality inequalities has identical continuation terms on either side; together with the concavity inequality it forces equality in the lower-state comparison. The reversed action is therefore also optimal at $z_1$. H04's unique maximizer makes the two actions equal, contradicting reversal. Strict concavity of utility enters through this already proved uniqueness theorem; the new comparison uses only weak concavity.

**Consumption order.** This is a separate argument. Suppose $c(z_2)<c(z_1)$. Compare the canonical savings with $b_1=z_1-c(z_2)$ and $b_2=z_2-c(z_1)$. Both are nonnegative and feasible at their respective states. The two new savings lie between the original savings and preserve their sum. The continuation function is concave by H03, the affine transition and integration. Apply the four-point inequality to continuation, multiply by nonnegative beta, and combine the two optimality inequalities. Current utilities cancel because the comparison swaps consumption. Equality again gives a second lower-state optimizer, contradicting H04 uniqueness and the assumed consumption reversal.

**Lipschitz bounds.** The exact budget is $z=A(z)+c(z)$. Nonnegativity of each difference follows from its own monotonicity. Nonnegativity of the other component's difference supplies its upper bound by $z_2-z_1$. No differentiability or strict monotonicity is inferred.

**Source correspondence.** Approved locator: A93 Appendix Proposition 2, printed pp. 37–38 / PDF pp. 38–39; A94 equations (5)–(7), printed pp. 666–667 / PDF pp. 9–10. The A93 pages were visually checked again for M03A. The weak-order proof is reconstructed explicitly from architecture section 4; stronger envelope, Euler and strict-order claims remain outside this gate.

**Exact elaborated public theorem and axiom output.**

```text
Aiyagari1994.policies_order_lipschitz (m : Aiyagari1994.HouseholdPrimitives) :
  Monotone (Aiyagari1994.assetPolicy m) ∧
    Monotone (Aiyagari1994.consumptionPolicy m) ∧
      ∀ (z1 z2 : Aiyagari1994.Resources),
        z1 ≤ z2 →
          (0 ≤ ↑(Aiyagari1994.assetPolicy m z2) - ↑(Aiyagari1994.assetPolicy m z1) ∧
              ↑(Aiyagari1994.assetPolicy m z2) - ↑(Aiyagari1994.assetPolicy m z1) ≤ ↑z2 - ↑z1) ∧
            0 ≤ ↑(Aiyagari1994.consumptionPolicy m z2) - ↑(Aiyagari1994.consumptionPolicy m z1) ∧
              ↑(Aiyagari1994.consumptionPolicy m z2) - ↑(Aiyagari1994.consumptionPolicy m z1) ≤ ↑z2 - ↑z1
'Aiyagari1994.policies_order_lipschitz' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Verification:** fresh module build, full build, direct audit and no-sorry/axiom checks pass. Only standard foundational axioms occur. External review is pending.

**Status:** REVIEW_READY, pending external adequacy review. **Scope:** core. **Review gate:** M03A.

**Target:** `Aiyagari1994.rightMarginalValue_properties`.

**Module:** `Aiyagari1994/Household/RightMarginal.lean`.

**Mathematical statement.** At every positive real state the canonical right marginal exists as a finite Real, is strictly positive, nonincreasing and continuous from the right, and satisfies
$$0<q(z)\leq\frac{V(z)-V(0)}z\leq\frac{\operatorname{osc}(U)}{(1-\beta)z}.$$
At zero a separate ENNReal marginal preserves the possible infinite limit. Positive-state marginals converge increasingly to this extended value as states decrease to zero.

**Actual assumptions and dependencies.** BASIC only, through the accepted H03 concavity and strict increase. H02's exact value bounds supply the oscillation estimate. This bound uses existing constructed objects, not a new hypothesis; the manifest dependency tags remain unchanged. The module imports value analysis, not PolicyOrder or lifetime verification. No derivative of utility, value or policy is assumed. No CoreRegularity, impatience, Inada, stationary law or bounded-state assumption enters.

**Real-domain representation.** `valueExtension m x` is $V(x.\mathrm{toNNReal})$. `NNRealConcave.extension` converts the accepted NNReal convex-combination inequality to real concavity on $[0,\infty)$. The extension is continuous and strictly increasing on that economic domain. Concavity is never asserted for negative arguments.

**Secants and canonical construction.** Write
$$S(z,y)=\frac{V(y)-V(z)}{y-z},\qquad y>z\geq0.$$
The increment form is exactly $S(z,z+h)=[V(z+h)-V(z)]/h$, certified by `rightSecant_increment`. Concavity yields
$$z<y_1\leq y_2\quad\Longrightarrow\quad S(z,y_2)\leq S(z,y_1).$$
Apply the pinned Mathlib theorem for a convex function's right secant infimum to $-V$ on $[0,\infty)$ at the interior point $z>0$. That theorem proves boundedness of the secants using a point to the left and constructs their finite one-sided limit. Define
$$q(z)=-\inf\{S_{-V}(z,y):y\geq0,\ y>z\}.$$
Negating the proved limit gives `rightMarginalValue_hasDerivWithinAt` and the explicit secant limit. There is no ordinary `deriv` definition. A separate bridge proves the equivalent, finite supremum representation
$$q(z)=\sup_{y>z}S(z,y).$$
The real function's economic interpretation is restricted to positive states; its value at zero is not the boundary marginal.

**Secant inequalities and positivity.** Every right secant obeys $S(z,y)\leq q(z)$. For $0\leq x<z<t$, concavity gives $S(z,t)\leq S(x,z)$. Letting $t$ decrease to $z$ gives $q(z)\leq S(x,z)$. Consequently,
$$q(y)\leq S(z,y)\leq q(z)\qquad(0<z<y).$$
This proves monotonicity. Strict increase of $V$ makes $S(z,z+1)>0$; hence $q(z)>0$ without differentiability assumptions. Choosing $x=0$ gives the left-secant bound.

**Oscillation bound.** `utilityOscillation` is precisely `utilitySup - utilityInf`, using H02's bounded utility range. Subtract the lower bound for $V(0)$ from the upper bound for $V(z)$:
$$V(z)-V(0)\leq\frac{U_{\rm sup}-U_{\rm inf}}{1-\beta}.$$
Divide by positive $z$. This yields the stated estimate on all positive states, with no artificial cutoff.

**Right continuity, proved.** For fixed $z>0$, monotonicity bounds $q(x)$ for $x>z$ above by $q(z)$. Let $L=\sup_{x>z}q(x)$. The monotone-limit theorem gives $q(x)\to L$ as $x\downarrow z$ and $L\leq q(z)$. For fixed $y>z$ and nearby $z<x<y$,
$$S(x,y)\leq q(x)\leq L.$$
Continuity of $V$ and the nonzero fixed secant denominator give $S(z,y)\leq L$ on sending $x\downarrow z$. Send $y\downarrow z$ using the already proved secant limit to get $q(z)\leq L$. Thus $L=q(z)$. The public result is `ContinuousWithinAt (rightMarginalValue m) (Ici z) z` for every $z>0$, not merely semicontinuity; it implies convergence along every positive sequence decreasing to $z$.

**Extended boundary marginal.** Define
$$q_0=\sup_{y>0}\operatorname{ofReal}(S(0,y))\quad\hbox{in ENNReal}.$$
Every secant here is positive, so the nonnegative conversion does not discard an economic sign. The antitone secants converge to this complete-order supremum as $y\downarrow0$. The inequality $q(z)\leq S(0,z)$ bounds every converted positive marginal by $q_0$. Conversely, fix $y>0$. For $0<x<y$, $S(x,y)\leq q(x)$; continuity at zero allows $x\downarrow0$, and then taking the supremum over $y$ proves
$$q_0=\sup_{z>0}\operatorname{ofReal}(q(z)).$$
Since positive marginals are antitone in state, the complete-order monotone-limit theorem now proves their convergence to $q_0$ as $z\downarrow0$, even when the limit is infinity. The theorem `zeroRightMarginal_eq_top_iff` characterizes infinity by arbitrarily large converted positive marginals. No theorem assumes or concludes universal finiteness at zero. This gate does not construct a separate economic example with infinite boundary marginal and does not impose an Inada condition.

**Source correspondence.** This is new concave-analysis/value-marginal infrastructure under architecture section 4.1, inspired by the CW00 context in the manifest, not a literal numbered Aiyagari theorem or an imported economic result. The actual imported analysis is from the pinned Mathlib source: convex negative-value right secant limits, concave secant order and monotone limits. A93's broader differentiability/envelope statements are not inferred here.

**Exact elaborated public theorem and axiom output.**

```text
Aiyagari1994.rightMarginalValue_properties (m : Aiyagari1994.HouseholdPrimitives) :
  (∀ (z : ℝ),
      0 < z →
        Filter.Tendsto (slope (Aiyagari1994.valueExtension m) z) (nhdsWithin z (Set.Ioi z))
            (nhds (Aiyagari1994.rightMarginalValue m z)) ∧
          0 < Aiyagari1994.rightMarginalValue m z ∧
            ContinuousWithinAt (Aiyagari1994.rightMarginalValue m) (Set.Ici z) z ∧
              Aiyagari1994.rightMarginalValue m z ≤
                  (Aiyagari1994.valueExtension m z - Aiyagari1994.valueExtension m 0) / z ∧
                (Aiyagari1994.valueExtension m z - Aiyagari1994.valueExtension m 0) / z ≤
                  Aiyagari1994.utilityOscillation m / ((1 - m.beta) * z)) ∧
    AntitoneOn (Aiyagari1994.rightMarginalValue m) (Set.Ioi 0) ∧
      Filter.Tendsto (fun (y : ℝ) => ENNReal.ofReal (slope (Aiyagari1994.valueExtension m) 0 y))
          (nhdsWithin 0 (Set.Ioi 0)) (nhds (Aiyagari1994.zeroRightMarginal m)) ∧
        Filter.Tendsto (fun (z : ℝ) => ENNReal.ofReal (Aiyagari1994.rightMarginalValue m z)) (nhdsWithin 0 (Set.Ioi 0))
          (nhds (Aiyagari1994.zeroRightMarginal m))
'Aiyagari1994.rightMarginalValue_properties' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Exact canonical definition types.**

```text
Aiyagari1994.rightMarginalValue (m : Aiyagari1994.HouseholdPrimitives) (z : ℝ) : ℝ
'Aiyagari1994.rightMarginalValue' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.zeroRightMarginal (m : Aiyagari1994.HouseholdPrimitives) : ENNReal
'Aiyagari1994.zeroRightMarginal' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Verification and boundary of this gate.** Both M03A targets and all supporting exports pass fresh builds, the full build, direct `Audit.lean`, no-sorry assertions, the prohibited-pattern scan and transitive axiom checks. Only `propext`, `Classical.choice` and `Quot.sound` occur. The exact signature report contains all secant, right-continuity and boundary-limit interfaces plus the printed definitions. H07 and H08 are REVIEW_READY; H01–H05 remain GREEN. H06 and H09 onward remain UNFORMALIZED. No H09 or later proof is begun.
