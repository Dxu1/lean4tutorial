# M02B structural and nonanticipativity audit

**Status:** REVIEW_READY, pending external adequacy review. **Scope:** core. **Milestone:** M02B.

**Target declaration:** `Aiyagari1994.canonicalPolicy_lifetime_optimal`.

**Module:** `Aiyagari1994/Household/Verification.lean`.

**Support module:** `Aiyagari1994/Household/History.lean`.

**Mathematical statement.** For every primitive household and initial resource $z_0\geq0$, every measurable nonanticipative feasible plan has an absolutely convergent expected discounted utility series. Its sum is at most $V(z_0)$. The recursively constructed canonical plan attains $V(z_0)$ and hence weakly dominates every such plan.

**Actual assumptions and scope.** BASIC is the existing `HouseholdPrimitives`: $0<\beta<1$, utility continuous, bounded, strictly increasing and strictly concave on nonnegative consumption, the existing compact labor support and probability law, and admissible normalized prices. H02 and H04 supply the constructed bounded continuous value and continuous feasible optimal asset policy. IID is discharged by the existing finite product `historyLaw`; there is no new independence field. No CoreRegularity, smoothness, Inada, $\beta R<1$, nondegeneracy, mean-one labor, bounded assets or stationary law is assumed. The entire NNReal resource space and a general compactly supported labor distribution remain covered. Dependencies P01, H02 and H04 are GREEN. Primitive consistency remains witnessed by P03.

**History and comparison class.** `History m t` is `Fin t` to labor. Coordinate zero is the newest shock. `historySplit` is the installed measurable equivalence `piFinSuccAbove` at zero; its two projections define `newestShock` and `previousHistory`, and its inverse defines `extendHistory`. Thus at date $t$ a plan can use all $t$ observed shocks, with no dependence on future shocks. The empty date-zero history is unique.

A `FeasiblePlan m z0` contains exactly an action family, its measurability proof and pointwise feasibility. The family has type `(t : Nat) -> History m t -> Resources`. It may vary with time and every observed coordinate; it need not factor through current resources and has no stationarity or optimality field. These are measurable functions of the given shock histories. No separate private randomization variable is added to the approved information space; the comparison class is not restricted to deterministic time sequences or current-state feedback. Pointwise feasibility at every history is the explicit M02B interface, replacing the older design's almost-everywhere wording.

**Derived resources and consumption.** The initial state is $z_0$. At date $t+1$, resources are `nextResources` of the date-$t$ action on the previous history and the newest shock. In particular the transition does not use the date-$t+1$ choice. These states are derived from the action family, not stored independently. Measurability follows by composition of measurable history projections, measurable actions and the continuous resource transition. Consumption is NNReal subtraction. Feasibility gives the exact real subtraction identity and $c_t+a_t=z_t$, so utility always receives a nonnegative consumption argument. Measurability of consumption and flow utility follows by subtraction and continuity of utility on NNReal.

**Integrability and the criterion.** `utilityBound` selects a finite bound from the proved primitive boundedness property; `utilityBound_spec` and `utilityBound_nonneg` certify it. Uniformly over plans, dates and histories, $|U(c_t)|\leq C$. Since each finite history law is a probability measure, `flowUtility_integrable` proves integrability and `expectedFlow_bound` proves $|E U(c_t)|\leq C$. The terminal value composed with measurable resources is likewise integrable, with expected absolute value bounded by $\|V\|_\infty$. The definition `lifetimeUtility` is the tsum of $\beta^t E U(c_t)$. Comparison with $C\beta^t$ proves absolute summability and convergence of the finite sums to this tsum, for every feasible plan. No unproved limiting expectation defines utility.

**The stochastic bridge.** `history_integral_step` takes an explicit integrability premise on the next-history function. The already constructed `history_step` proves that the history split preserves measure from the next finite product to labor law times previous-history law. Its inverse changes variables in the integral and transfers integrability. Mathlib's `integral_prod_symm` then yields previous-history outer integration and newest-shock inner integration. Applying this result to the next value function identifies the integrated continuation with the next expected terminal value. IID is proved through this product construction, rather than postulated as an expectation identity.

**One-step and finite-horizon verification.** At every history, feasibility places the plan's actual shifted-asset action in $[0,z_t]$. H04 maximization and the Bellman equality give
$$U(c_t)+\beta E_l V(Ra_t+e(l))\leq V(z_t).$$
All three terms have explicit integrability theorems. Integrating this inequality and using the history bridge gives
$$E U(c_t)+\beta T_{t+1}\leq T_t,$$
where $T_t$ is the plan's expected terminal value. At horizon zero the history law integrates the constant initial value to $V(z_0)$. Induction, multiplying the one-step inequality by nonnegative $\beta^N$, and the finite-sum successor identity give
$$\sum_{t<N}\beta^t E U(c_t)+\beta^N T_N\leq V(z_0).$$
This is the proved `finiteHorizon_verification`, with no telescoping assumption.

**Canonical construction and equality.** `canonicalResources` is defined recursively from the accepted asset policy and resource transition. Continuity of the asset policy and measurability of the history operations prove measurable canonical actions. The resource family derived from these actions agrees with the recursive family. The accepted bound $A(z)\leq z$ certifies feasibility, giving `canonicalPlan`. Every canonical action attains the Bellman maximum. Integrating the pointwise equality and repeating the same induction proves `canonical_finiteHorizon_verification` as an equality for every horizon.

**Infinite-horizon limit.** For every comparison plan,
$$|\beta^N T_N|\leq\beta^N\|V\|_\infty\longrightarrow0.$$
The proof uses only bounded $V$ and $0<\beta<1$, regardless of the growth of resources or assets. The finite discounted sums converge by absolute summability. Closedness of the real order gives lifetime utility at most $V(z_0)$; uniqueness of limits applied to the canonical finite-horizon identity gives canonical lifetime utility exactly $V(z_0)$. Substitution proves dominance.

**Original-budget bridge.** `original_shifted_trajectory_budget_iff` applies P01 at every date of arbitrary real asset and consumption trajectories. Writing shifted holdings as $\widehat a_t=a_t+\phi$, the conjunction of the original budget and $a_{t+1}\geq-\phi$ is equivalent to the shifted budget and $\widehat a_{t+1}\geq0$. For a concrete feasible history plan whose prices are `OriginalPrices.normalized`, `plan_original_budget_step` proves the original budget on every next history, identifying net assets with shifted actions minus $\phi$. The separate initial-date theorem uses the exact initial coordinate relation. Consumption is unchanged by the coordinate shift. These are conditional coordinate identities, not new assumptions on H05's general normalized theorem.

**Source correspondence.** A93 Appendix Proposition 2, printed pp. 37–38 / PDF pp. 38–39; A94 equations (5)–(7), printed pp. 666–667 / PDF pp. 9–10. These approved source pages were visually checked in the household source review. The finite-history product bridge, integrability and explicit verification details are reconstructed proofs, not claims that the papers contain Lean-ready statements. P01 supplies the original coordinate algebra.

**Exact elaborated main theorem and transitive axioms.**

```text
Aiyagari1994.canonicalPolicy_lifetime_optimal (m : Aiyagari1994.HouseholdPrimitives) (z0 : Aiyagari1994.Resources) :
  (∀ (p : Aiyagari1994.FeasiblePlan m z0), Summable fun (t : ℕ) => |m.beta ^ t * Aiyagari1994.expectedFlow p t|) ∧
    (∀ (p : Aiyagari1994.FeasiblePlan m z0), Aiyagari1994.lifetimeUtility p ≤ (Aiyagari1994.valueFunction m) z0) ∧
      Aiyagari1994.lifetimeUtility (Aiyagari1994.canonicalPlan m z0) = (Aiyagari1994.valueFunction m) z0 ∧
        ∀ (p : Aiyagari1994.FeasiblePlan m z0),
          Aiyagari1994.lifetimeUtility p ≤ Aiyagari1994.lifetimeUtility (Aiyagari1994.canonicalPlan m z0)
'Aiyagari1994.canonicalPolicy_lifetime_optimal' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Audit and review evidence.** Fresh builds of both M02B modules, the full project build, direct `Audit.lean`, exact signature probe, contract checker and prohibited-pattern scan pass. All 65 new exported declarations, including the feasible-plan projections, pass `assert_no_sorry` and transitive axiom printing. Across the entire audit there are 254 checked declarations; only `propext`, `Classical.choice` and `Quot.sound` occur. Exact required interfaces and structure fields appear in `reports/02b_signatures.md`; raw evidence is in `reports/logs/02b/`. H05 is not GREEN. H06 and all later contracts remain UNFORMALIZED; no M03 work is performed.

## Frozen baseline

M02A_BASE: `c6cc7477d7a7f6fa396f8a386f36a9e4b25f29ae`. All accepted primitive, budget, Bellman, value and policy source files are unchanged. No contract field except H05 status changes. H01–H04 remain GREEN.
