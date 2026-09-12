# Proof ledger — Aiyagari theory replication

**Economic status:** P01, P02 and P03 are **GREEN**, externally accepted on 2026-09-11; the remaining 54 economic contracts are **UNFORMALIZED**. Milestone 00 generic API probes are **GREEN**, accepted on 2026-09-11 for bootstrap/environment/source/API infrastructure only, including build/audit infrastructure and representation preflight. M00 itself promotes no economic theorem; M01 has its separate acceptance in `reviews/01_acceptance.md`. The proof-plan sections refer to `architecture.pdf`; they are proposed mathematical arguments, not completed formal proofs.

The completed ledger must replace each plan pointer with the actual readable proof, exact elaborated Lean signature, all economic hypotheses, axiom output and review evidence.

## Milestone 00 — compiled API infrastructure

**Status:** GREEN / accepted 2026-09-11. Scope: bootstrap/environment/source/API infrastructure only, including build/audit infrastructure and representation preflight. See `reviews/00_acceptance.md` for the external decision and four reviewer qualifications. No economic adequacy is inferred from the probes. No economic contract is assigned to this milestone and none is promoted. Source bytes are verified; mathematical page locators below remain the approved design locators. The clean Lean 4.32.0 / pinned Mathlib build and audit evidence are in `reports/00_environment.md` and `reports/logs/00_axioms.log`.

**Actual economic assumptions:** none. The generic Banach result assumes `ContractingWith K T`; the kernel results assume the specified Markov instances and measurability; weak test convergence assumes weak convergence; family compactness assumes uniform tightness. These mathematical hypotheses are not household primitives or proved economic conclusions.

**Readable proofs.** The bounded continuous function instance gives completeness, and evaluation distance is at most the supremum distance. NNReal inherits its complete, separable metric and Borel structure. Banach supplies a fixed point and its uniqueness for a contraction on the bounded-value space. The constant zero operator has Lipschitz constant zero, strictly below one; uniqueness identifies its fixed point as zero. This is a concrete infrastructure witness, not the primitive economic consistency witness P03.

A bounded continuous real function is measurable and norm bounded, hence integrable against any finite probability measure. A measurable pushforward is again a probability law. The map-integrability equivalence proves integrability of the composed test, and the change-of-variables theorem gives the integral identity. The pushforward probe exports both integrability statements. Markov composition preserves probability mass; composing with the identity changes nothing. A deterministic kernel transports a measure to its pushforward. These are generic kernel facts, with no stationarity claim.

Weak convergence implies convergence of every bounded continuous test by its installed characterization. On the compact interval [0,1], the probability-law space is compact. Every single law on NNReal is tight by complete second-countable metrizability. Prokhorov gives compact closure for a uniformly tight family. It does not provide an unbounded-moment limit. Finally, a constant-infinity ENNReal function demonstrates that the marginal representation can retain infinity at zero; it asserts no derivative theorem.

**Exact elaborated declaration inventory and axiom output.** The following is the actual successful `lake env lean Audit.lean` output. Lean suppresses proof arguments with an ellipsis; the explicit source signatures and proofs are in `Probes/Core.lean`. All declarations pass `assert_no_sorry`; only the standard foundational axioms occur. The abbreviations are State = NNReal, ValueSpace = bounded continuous State-to-Real functions, and CompactInterval = [0,1] as a subtype.

```text
Aiyagari1994.Probes.State : Type
'Aiyagari1994.Probes.State' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.ValueSpace : Type
'Aiyagari1994.Probes.ValueSpace' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.CompactInterval : Set ℝ
'Aiyagari1994.Probes.CompactInterval' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.value_complete : CompleteSpace Aiyagari1994.Probes.ValueSpace
'Aiyagari1994.Probes.value_complete' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.sup_distance (f g : Aiyagari1994.Probes.ValueSpace) (z : Aiyagari1994.Probes.State) :
  dist (f z) (g z) ≤ dist f g
'Aiyagari1994.Probes.sup_distance' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.state_complete : CompleteSpace Aiyagari1994.Probes.State
'Aiyagari1994.Probes.state_complete' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.state_separable : TopologicalSpace.SeparableSpace Aiyagari1994.Probes.State
'Aiyagari1994.Probes.state_separable' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.state_borel : BorelSpace Aiyagari1994.Probes.State
'Aiyagari1994.Probes.state_borel' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.state_measurable_id : Measurable id
'Aiyagari1994.Probes.state_measurable_id' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.banach_on_values (T : Aiyagari1994.Probes.ValueSpace → Aiyagari1994.Probes.ValueSpace) (K : NNReal)
  (hT : ContractingWith K T) : ∃! v : Aiyagari1994.Probes.ValueSpace, T v = v
'Aiyagari1994.Probes.banach_on_values' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.zero_contraction : ContractingWith 0 fun (x : Aiyagari1994.Probes.ValueSpace) => 0
'Aiyagari1994.Probes.zero_contraction' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.zero_fixed_point :
  ContractingWith.fixedPoint (fun (x : Aiyagari1994.Probes.ValueSpace) => 0) Aiyagari1994.Probes.zero_contraction = 0
'Aiyagari1994.Probes.zero_fixed_point' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.bounded_test_integrable (μ : MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State)
  (f : Aiyagari1994.Probes.ValueSpace) : MeasureTheory.Integrable ⇑f ↑μ
'Aiyagari1994.Probes.bounded_test_integrable' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.pushforward_test (μ : MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State)
  (g : Aiyagari1994.Probes.State → Aiyagari1994.Probes.State) (hg : Measurable g) (f : Aiyagari1994.Probes.ValueSpace) :
  MeasureTheory.Integrable ⇑f ↑(μ.map ⋯) ∧
    MeasureTheory.Integrable (fun (x : Aiyagari1994.Probes.State) => f (g x)) ↑μ ∧
      ∫ (y : Aiyagari1994.Probes.State), f y ∂↑(μ.map ⋯) = ∫ (x : Aiyagari1994.Probes.State), f (g x) ∂↑μ
'Aiyagari1994.Probes.pushforward_test' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.kernel_composition
  (κ η : ProbabilityTheory.Kernel Aiyagari1994.Probes.State Aiyagari1994.Probes.State)
  [ProbabilityTheory.IsMarkovKernel κ] [ProbabilityTheory.IsMarkovKernel η] :
  ProbabilityTheory.IsMarkovKernel (η.comp κ)
'Aiyagari1994.Probes.kernel_composition' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.kernel_identity (κ : ProbabilityTheory.Kernel Aiyagari1994.Probes.State Aiyagari1994.Probes.State) :
  κ.comp ProbabilityTheory.Kernel.id = κ
'Aiyagari1994.Probes.kernel_identity' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.kernel_transport (μ : MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State)
  (g : Aiyagari1994.Probes.State → Aiyagari1994.Probes.State) (hg : Measurable g) :
  (↑μ).bind ⇑(ProbabilityTheory.Kernel.deterministic g hg) = ↑(μ.map ⋯)
'Aiyagari1994.Probes.kernel_transport' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.deterministic_markov (g : Aiyagari1994.Probes.State → Aiyagari1994.Probes.State)
  (hg : Measurable g) : ProbabilityTheory.IsMarkovKernel (ProbabilityTheory.Kernel.deterministic g hg)
'Aiyagari1994.Probes.deterministic_markov' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.transport_mass (κ : ProbabilityTheory.Kernel Aiyagari1994.Probes.State Aiyagari1994.Probes.State)
  [ProbabilityTheory.IsMarkovKernel κ] (μ : MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State) :
  ((↑μ).bind ⇑κ) Set.univ = 1
'Aiyagari1994.Probes.transport_mass' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.weak_test_convergence (μs : ℕ → MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State)
  (μ : MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State) (h : Filter.Tendsto μs Filter.atTop (nhds μ))
  (f : Aiyagari1994.Probes.ValueSpace) :
  Filter.Tendsto (fun (n : ℕ) => ∫ (x : Aiyagari1994.Probes.State), f x ∂↑(μs n)) Filter.atTop
    (nhds (∫ (x : Aiyagari1994.Probes.State), f x ∂↑μ))
'Aiyagari1994.Probes.weak_test_convergence' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.compact_interval_laws :
  CompactSpace (MeasureTheory.ProbabilityMeasure ↑Aiyagari1994.Probes.CompactInterval)
'Aiyagari1994.Probes.compact_interval_laws' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.individual_law_tight (μ : MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State) :
  MeasureTheory.IsTightMeasureSet {↑μ}
'Aiyagari1994.Probes.individual_law_tight' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.tight_family_compact (S : Set (MeasureTheory.ProbabilityMeasure Aiyagari1994.Probes.State))
  (hS : MeasureTheory.IsTightMeasureSet {x : MeasureTheory.Measure Aiyagari1994.Probes.State | ∃ μ ∈ S, ↑μ = x}) :
  IsCompact (closure S)
'Aiyagari1994.Probes.tight_family_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
Aiyagari1994.Probes.extended_zero_value : ∃ (q : Aiyagari1994.Probes.State → ENNReal), q 0 = ⊤
'Aiyagari1994.Probes.extended_zero_value' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**M00 review boundary:** the bootstrap acceptance certifies only its stated infrastructure scope. M01 was separately assigned and its results follow below; generic API success does not certify the later economic proofs.

## P01 — Shifted budget normalization

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Milestone:** 01.

**Target:** `Aiyagari1994.shifted_budget_iff` in `Aiyagari1994/Budget/Normalization.lean`.

**Actual statement and assumptions.** For arbitrary real net rate, wage, current labor, debt shift, current net assets, next net assets and consumption, the original budget equality together with the next borrowing inequality is equivalent to the shifted budget equality together with nonnegative next shifted assets. There are no economic premises: this algebraic result is stronger than its restriction to admissible prices. Gross return is structurally $1+r$; it is never independent data alongside $r$ in the original-price structure.

**Readable proof.** Expand $(1+r)(a+\phi)$ and cancel $r\phi$. Relative to the original equality, both sides acquire exactly $\phi$. Adding or subtracting $\phi$ also proves $-\phi\leq a_{next}$ iff $0\leq a_{next}+\phi$. The main theorem joins these two genuine equivalences. Consumption is the same real number in both systems, so a separate nonnegativity restriction on consumption is preserved without an additional premise in the algebraic identity.

The audited supporting declarations keep the components separate:

- `shifted_budget_equality_iff`: the budget equality component.
- `shifted_borrowing_iff`: the borrowing inequality component.
- `next_resource_identity`: next labor and shifted savings in the next-period resource equation.
- `original_normalized_coordinates`: the constructed map has $R=1+r$ and $k=-r\phi$.

**Source correspondence.** A94 equations (1b), (3a)-(4b), printed pp. 665-666 / PDF pp. 8-9, visually inspected in M01. No No-Ponzi equivalence or policy theorem is claimed.

**Exact elaborated signature and transitive axioms:**

```text
Aiyagari1994.shifted_budget_iff (r w l phi a a_next c : ℝ) :
  c + a_next = (1 + r) * a + w * l ∧ -phi ≤ a_next ↔
    c + (a_next + phi) = (1 + r) * (a + phi) + w * l - r * phi ∧ 0 ≤ a_next + phi
'Aiyagari1994.shifted_budget_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Integrability:** none; this is pathwise algebra. **Dependencies:** primitive real arithmetic only. **Adequacy caveat:** externally accepted in `reviews/01_acceptance.md`; no No-Ponzi claim is included.

## P02 — Effective borrowing limits

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Milestone:** 01.

**Target:** `Aiyagari1994.effectiveLimit_admissible_continuous`.

**Module:** `Aiyagari1994/Budget/EffectiveLimit.lean`.

**Actual assumptions.** The cap $b$ is a fixed nonnegative real and the labor floor $l_{min}$ is strictly positive. Scalar admissibility quantifies over positive wages and labor at least the floor. Finite-cap continuity is joint in $(w,r)$ on $w>0,r>-1$, for each fixed $b,l_{min}$. Its nonnegativity and effective-income inequalities are actually proved for every real rate. The original-price constructor additionally requires $r>-1$ to ensure positive gross return. The natural branch separately requires $r>0$ and has no finite-cap premise.

**Readable proof.** At $r>0$, both entries of $\min(b,w l_{min}/r)$ are nonnegative, and $r\phi\leq w l_{min}\leq w l$. At $r\leq0$, $\phi=b\geq0$ and $r b\leq0<w l_{min}\leq w l$. Thus effective income is nonnegative in each branch.

For continuity, the proof establishes the exact auxiliary identity

$$\phi(b,l_{min},w,r)=\frac{b(w l_{min})}{\max(w l_{min},br)}.$$

When $br\leq w l_{min}$ the expression equals $b$; otherwise the positive-rate minimum equals $w l_{min}/r$. The denominator is at least $w l_{min}>0$. Continuity of multiplication, maximum and division therefore proves joint continuity on the stated price domain. The case $b=0$ never requires division by $b$.

The explicit `effectiveLimit_zero_neighborhood` theorem also proves the source-sensitive boundary step: the continuous expression $w' l_{min}-b r'$ is positive near $(w,0)$. Consequently, if $r'>0$, then $b\leq w'l_{min}/r'$; the minimum equals $b$. For nearby nonpositive rates the definition is already $b$. This proves local constancy at zero, not a reliance on a convention for division by zero.

For the separate natural limit $\phi_{nat}=w l_{min}/r$, cancellation with $r>0$ gives $-r\phi_{nat}=-w l_{min}$. Effective income is exactly $w(l-l_{min})\geq0$. Raw natural-limit continuity is proved only on positive rates. No continuation of the raw debt limit through zero is claimed.

`finiteCapPrices` and `naturalCapPrices` construct the same `OriginalPrices` type with these proved admissibility facts. `OriginalPrices.normalized` constructs normalized prices; `NormalizedPrices.nextResources` returns NNReal using nonnegative shifted savings and nonnegative effective income. The audited helper `generated_resources_admissible` gives the explicit generated-state inequality. No invariant or absorbing bound is used.

**Source correspondence.** A94 equations (2a)-(2b), printed p. 666 / PDF p. 9, visually inspected in M01. The explicit continuity argument and the rational/max helper are implementation mathematics consistent with architecture section 2.

**Exact elaborated signature and transitive axioms:**

```text
Aiyagari1994.effectiveLimit_admissible_continuous (b lo : ℝ) (hb : 0 ≤ b) (hl : 0 < lo) :
  (∀ (w r : ℝ), 0 < w → 0 ≤ Aiyagari1994.effectiveLimit b lo w r) ∧
    (∀ (w r l : ℝ), 0 < w → lo ≤ l → 0 ≤ w * l - r * Aiyagari1994.effectiveLimit b lo w r) ∧
      ContinuousOn (fun (p : ℝ × ℝ) => Aiyagari1994.effectiveLimit b lo p.1 p.2) {p : ℝ × ℝ | 0 < p.1 ∧ -1 < p.2} ∧
        (∀ (w : ℝ),
            0 < w →
              ∀ᶠ (p : ℝ × ℝ) in nhds (w, 0),
                (0 < p.2 → b ≤ p.1 * lo / p.2) ∧ Aiyagari1994.effectiveLimit b lo p.1 p.2 = b) ∧
          (∀ (w r : ℝ),
              0 < w →
                0 < r →
                  0 ≤ Aiyagari1994.naturalLimit lo w r ∧
                    -r * Aiyagari1994.naturalLimit lo w r = -w * lo ∧
                      ∀ (l : ℝ),
                        lo ≤ l →
                          w * l - r * Aiyagari1994.naturalLimit lo w r = w * (l - lo) ∧
                            0 ≤ w * l - r * Aiyagari1994.naturalLimit lo w r) ∧
            ContinuousOn (fun (p : ℝ × ℝ) => Aiyagari1994.naturalLimit lo p.1 p.2) {p : ℝ × ℝ | 0 < p.1 ∧ 0 < p.2}
'Aiyagari1994.effectiveLimit_admissible_continuous' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Integrability:** none; scalar budget/admissibility results. **Dependencies:** primitive real order, algebra and topology; P01 supplies the normalized-price context. **Adequacy caveat:** the quantified finite and natural clauses are independent branches. The statement does not require a household simultaneously to have both borrowing rules. External M01 review accepted this scope on 2026-09-11.

## P03 — Exact primitive consistency witness

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Milestone:** 01.

**Target:** `Aiyagari1994.corePrimitives_nonempty` in `Aiyagari1994/Primitives/Examples.lean`.

**Actual assumptions.** None are assumed by the existential theorem. It constructs an element of the same `HouseholdPrimitives` type used for arbitrary compact income laws, together with `CoreRegularity`. The exact output data are $\beta=1/2$, $R=1$, $w=1$, intercept zero, original rate zero, cap zero, debt limit zero, utility $U(c)=c/(1+c)$, and the law placing mass $1/2$ at each labor endpoint $1/2$ and $3/2$. Assets/resources remain NNReal. The finite shock distribution is only a witness, not a restriction on the model family.

**Readable utility proof.** The utility is a real-valued function by its declared type. On $c\geq0$, its denominator is positive, quotient continuity applies, and $0\leq U(c)<1$, so it is bounded above and below. Quotient differentiation proves

$$U'(c)=\frac{1}{(1+c)^2},\qquad U''(c)=-\frac{2}{(1+c)^3}.$$

The first derivative formula is proved for $c\geq0$ and the second for $c>0$. To differentiate the derivative, the proof first establishes the quotient's derivative formula on a neighborhood of each positive $c$, then transfers the derivative through that local equality. Positive first derivative and negative second derivative on the interior, together with continuity at zero, give strict increase and strict concavity on $[0,\infty)$. Quotient smoothness supplies C1/C2 (indeed every finite order) on $(0,\infty)$. Algebra gives

$$-cU''(c)/U'(c)=2c/(1+c)\leq2.$$

The curvature record uses threshold one and finite bound two. There is no assumption of global continuity or concavity across the singularity at $c=-1$, and the general primitive records require neither finite nor infinite marginal utility at zero.

**Readable income proof and integrability.** `witnessMeasure` is the sum of two half-weighted Dirac measures on the full subtype $[1/2,3/2]$. Its total mass is one. Each endpoint singleton has mass exactly one half; the complement of the two endpoints has zero mass. Every relative endpoint neighborhood contains the corresponding singleton and therefore has positive mass. These facts also prove the exact topological support and nondegeneracy.

`labor_integrable` proves labor integrability for every `IncomeData` law from continuity on the compact labor subtype and finiteness of the probability law. The direct mean computation separately checks integrability for each weighted Dirac term before using integral additivity, giving $(1/2)(1/2)+(1/2)(3/2)=1$.

`historyLaw` is the finite product of copies of the general labor law. For every finite horizon it is a probability measure, its coordinate pushforwards are the original law, its coordinates are independent, and the `piFinSuccAbove` measurable equivalence gives the current-draw/tail product decomposition. The same proved `history_probability`, `history_marginal`, `history_independent` and `history_step` declarations apply directly to `witnessIncome`; no IID conclusion is stored as an assumed primitive field. Lifetime Bellman verification and infinite-path construction remain later work.

Finally, `witnessModel` combines the utility, income and the normalized map of the finite-cap original prices. `witness_core_regular` supplies every required regularity proof. The main theorem packages that actual inhabitant and checks the exact parameter identities.

**Source correspondence.** New exact consistency witness specified by architecture section 2 and the accepted M01 instructions; not claimed to appear in the papers. A93 is the manifest source key for the modeled primitive context. The budget/income conventions match A94 printed pp. 665-666 / PDF pp. 8-9, inspected visually.

**Exact elaborated signature and transitive axioms:**

```text
Aiyagari1994.corePrimitives_nonempty :
  ∃ (m : Aiyagari1994.HouseholdPrimitives),
    Aiyagari1994.CoreRegularity m ∧
      m.beta = 1 / 2 ∧
        m.prices.grossReturn = 1 ∧
          m.prices.wage = 1 ∧
            m.prices.intercept = 0 ∧
              m.utility = Aiyagari1994.witnessUtility ∧
                m.income = Aiyagari1994.witnessIncome ∧
                  ∃ (p : Aiyagari1994.OriginalPrices m.income),
                    p.normalized = m.prices ∧
                      p.netRate = 0 ∧
                        p.wage = 1 ∧ p.debtLimit = 0 ∧ p.debtLimit = Aiyagari1994.effectiveLimit 0 m.income.lower 1 0
'Aiyagari1994.corePrimitives_nonempty' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Primitive audit.** All twelve structures are printed in the direct audit log. Their fields are utility data and authorized regularity, support/probability data, optional mean normalization, prices/admissibility, and discount data. No value function, policy, Bellman theorem, Euler/envelope equation, Feller/mixing condition, invariant distribution, asset bound, asset supply or equilibrium conclusion is a field. `HouseholdPrimitives` imposes $R>0$ and never $\beta R<1$.

**Adequacy caveat:** consistency of primitives does not prove optimality, stationarity, equilibrium or any later contract. P03 is GREEN by external acceptance on 2026-09-11, within this primitive-consistency scope. Helpers and exact source files are inventoried in `reports/01_declarations.json`.

## H01 — Bellman selfmap contracting
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 02.

**Target declaration:** `Aiyagari1994.bellman_selfmap_contracting`.  
**Module:** `Aiyagari1994/Household/Bellman.lean`.

**Mathematical contract.** The Bellman operator maps bounded continuous real functions on NNReal to themselves and contracts their sup distance by beta, for every admissible R>0.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H02 — Value Function unique fixed Point
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 02.

**Target declaration:** `Aiyagari1994.valueFunction_unique_fixedPoint`.  
**Module:** `Aiyagari1994/Household/Value.lean`.

**Mathematical contract.** There exists exactly one bounded continuous Bellman fixed point, canonically named valueFunction; its range is bounded by inf U/(1-beta) and sup U/(1-beta).

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H01. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H03 — Value Function concave strict Mono
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 02.

**Target declaration:** `Aiyagari1994.valueFunction_concave_strictMono`.  
**Module:** `Aiyagari1994/Household/Value.lean`.

**Mathematical contract.** The canonical value function is concave and strictly increasing on NNReal.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H02. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H04 — Asset Policy unique continuous
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 02.

**Target declaration:** `Aiyagari1994.assetPolicy_unique_continuous`.  
**Module:** `Aiyagari1994/Household/Policy.lean`.

**Mathematical contract.** Every state has a unique Bellman-maximizing shifted asset choice A(z) in [0,z]; the canonical choice is continuous and consumption equals z-A(z).

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H03. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H05 — Canonical Policy lifetime optimal
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 02.

**Target declaration:** `Aiyagari1994.canonicalPolicy_lifetime_optimal`.  
**Module:** `Aiyagari1994/Household/Verification.lean`.

**Mathematical contract.** For every initial resource state and every measurable nonanticipative feasible plan, the canonical policy achieves weakly greater expected infinite discounted utility. Prove the finite-horizon verification inequality and equality for the canonical plan, then the tail limit.

**Assumption profiles:** BASIC, IID. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01, H02, H04. **Source keys:** A93, A94.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H06 — Policy jointly continuous
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 04.

**Target declaration:** `Aiyagari1994.policy_jointly_continuous`.  
**Module:** `Aiyagari1994/Household/ParameterContinuity.lean`.

**Mathematical contract.** With U, nu and beta fixed, V_theta(z) and A_theta(z) are jointly continuous in state and admissible normalized prices, including beta\*R=1 and beta\*R>1.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H02, H04. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §6.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H07 — Policies order lipschitz
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.policies_order_lipschitz`.  
**Module:** `Aiyagari1994/Household/PolicyOrder.lean`.

**Mathematical contract.** For z1<=z2, 0<=A(z2)-A(z1)<=z2-z1 and 0<=c(z2)-c(z1)<=z2-z1. This is a weak-order/Lipschitz theorem, not a derivative or strict-order theorem.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H03, H04. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H08 — Right Marginal Value properties
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.rightMarginalValue_properties`.  
**Module:** `Aiyagari1994/Household/RightMarginal.lean`.

**Mathematical contract.** For each z>0, q(z)=V_right_prime(z) exists, is finite and strictly positive, is nonincreasing and right-continuous, and q(z)<=(V(z)-V(0))/z<=osc(U)/((1-beta)\*z). Define the zero-state slope as an extended nonnegative limit.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H03. **Source keys:** A93, CW00.

**Source locator:** New concave-analysis/value-marginal infrastructure for the Aiyagari claims; inspired by CW00 Sections 2-4. Not a literal numbered Aiyagari theorem.

**Readable proof plan:** Architecture §4.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H09 — Right Marginal Value superharmonic
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.rightMarginalValue_superharmonic`.  
**Module:** `Aiyagari1994/Household/MarginalInequality.lean`.

**Mathematical contract.** For every z with finite right marginal, q(z)>=beta\*R\*Integral q(R\*A(z)+e) dnu. Establish the extended-integral inequality first and deduce conditional integrability; it is valid without beta\*R<1 and without consumption positivity.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H08. **Source keys:** CW00.

**Source locator:** New concave-analysis/value-marginal infrastructure for the Aiyagari claims; inspired by CW00 Sections 2-4. Not a literal numbered Aiyagari theorem.

**Readable proof plan:** Architecture §4.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H10 — Consumption positive subcritical
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.consumption_positive_subcritical`.  
**Module:** `Aiyagari1994/Household/ConsumptionPositive.lean`.

**Mathematical contract.** If beta\*R<1, then c(z)>0 at every z>0, allowing either a finite or infinite right marginal of U at zero.

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H08. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §4.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H11 — Value envelope at positive consumption
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.value_envelope_at_positive_consumption`.  
**Module:** `Aiyagari1994/Household/Envelope.lean`.

**Mathematical contract.** Whenever z>0 and c(z)>0, V is differentiable at z and $V'(z)=U'(c(z))$. This local result does not impose beta\*R<1. Prove the one-dimensional differentiable lower-touching lemma.

**Assumption profiles:** BASIC, SMOOTH. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H03, H04, H08. **Source keys:** BS79, A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; BS79 Lemma 1, printed p. 728 / PDF p. 3.

**Readable proof plan:** Architecture §4.3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H12 — Euler subcritical
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.euler_subcritical`.  
**Module:** `Aiyagari1994/Household/Euler.lean`.

**Mathematical contract.** At positive states under $\beta R<1$, $U^{\prime}(c(z))\geq\beta R\,\mathbb E[U^{\prime}(c(z^{\prime}))]$, with equality if $A(z)>0$ and all needed conditional integrability proved. Zero-resource derivatives must remain explicit.

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H09, H10, H11. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof plan:** Architecture §4.3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H13 — Binding interval exists
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.binding_interval_exists`.  
**Module:** `Aiyagari1994/Household/BorrowingThreshold.lean`.

**Mathematical contract.** Under beta\*R<1 and either e_min>0 or finite U_right_prime(0), there exists zHat>e_min with A(z)=0 for every z in [e_min,zHat].

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT, THRESHOLD. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H08, H10, H12. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 3 and the following note, printed p. 38 / PDF p. 39; A94 threshold discussion, printed p. 667 / PDF p. 10.

**Readable proof plan:** Architecture §5.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## H14 — Zero income atom implies nonbinding
**Status:** UNFORMALIZED. **Scope:** diagnostic. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.zero_income_atom_implies_nonbinding`.  
**Module:** `Aiyagari1994/Household/BorrowingThreshold.lean`.

**Mathematical contract.** If e_min=0, U has Inada marginal at zero, and Pr(e=0)>0, then A(z)>0 for every z>0. No impatience assumption is needed for this sufficient condition.

**Assumption profiles:** BASIC, SMOOTH, ATOM_INADA. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H03, H04, H08. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 3 and the following note, printed p. 38 / PDF p. 39; A94 threshold discussion, printed p. 667 / PDF p. 10.

**Readable proof plan:** Architecture §5.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## D01 — Inada without atom binding example
**Status:** UNFORMALIZED. **Scope:** diagnostic. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.inada_without_atom_binding_example`.  
**Module:** `Aiyagari1994/Diagnostics/InadaCounterexample.lean`.

**Mathematical contract.** In the exact continuous-state uniform-income model in EXACT_DIAGNOSTIC, all core primitive conditions hold and A(z)=0 whenever 0<z<=1/100, despite Inada and e_min=0.

**Assumption profiles:** EXACT_DIAGNOSTIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H02, H03, H04. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 3 and the following note, printed p. 38 / PDF p. 39; A94 threshold discussion, printed p. 667 / PDF p. 10.

**Readable proof plan:** Architecture §5.3.

**Adequacy note.** A proposed correction to the unqualified note after Proposition 3, not to Proposition 3 itself.

## D02 — Marginal Utility ratio bound
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 04.

**Target declaration:** `Aiyagari1994.marginalUtility_ratio_bound`.  
**Module:** `Aiyagari1994/Analysis/Curvature.lean`.

**Mathematical contract.** For a sufficiently large positive integer m dominating eventual relative risk aversion, U_prime(c1)/U_prime(c2)<=(c2/c1)^m whenever C0<=c1<=c2.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** SE77, A93.

**Source locator:** A93 Appendix Proposition 4, printed pp. 38-39 / PDF pp. 39-40; SE77 Theorems 3.8-3.9, printed pp. 161-162 / PDF pp. 11-12.

**Readable proof plan:** Architecture §6.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## D03 — Uniform upper drift
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 04.

**Target declaration:** `Aiyagari1994.uniform_upper_drift`.  
**Module:** `Aiyagari1994/Household/UpperDrift.lean`.

**Mathematical contract.** On any specified LOCAL_IMPATIENT parameter neighborhood, construct a common finite B>=all e_max such that R\*A_theta(z)+e_max<=z for z>=B, and [e_min,B] is forward invariant. Do not claim finite-time entry.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, LOCAL_IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H07, H08, H10, H12, D02. **Source keys:** SE77, A93.

**Source locator:** A93 Appendix Proposition 4, printed pp. 38-39 / PDF pp. 39-40; SE77 Theorems 3.8-3.9, printed pp. 161-162 / PDF pp. 11-12.

**Readable proof plan:** Architecture §6.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## S01 — Household Kernel feller monotone
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.householdKernel_feller_monotone`.  
**Module:** `Aiyagari1994/Stationary/Kernel.lean`.

**Mathematical contract.** The pushforward of nu under l↦R\*A(z)+e(l) is a probability Markov kernel, is Feller, and preserves stochastic order. Establish the kernel test-function integral formula.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H07. **Source keys:** A93, SLP89.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Readable proof plan:** Architecture §7.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## S02 — Lower transition iterates tendsto
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.lower_transition_iterates_tendsto`.  
**Module:** `Aiyagari1994/Stationary/LowerTransition.lean`.

**Mathematical contract.** Under beta\*R<1, h_min(e_min)=e_min, h_min(z)<z for z>e_min, and h_min iterated from any finite upper bound decreases to e_min.

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H08, H12. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Readable proof plan:** Architecture §7.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## S03 — Economic crossing condition
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.economic_crossing_condition`.  
**Module:** `Aiyagari1994/Stationary/Crossing.lean`.

**Mathematical contract.** On a compact invariant interval, construct d in (e_min,e_max), N>=1, epsilon>0 with P^N(e_min,[d,B])>=epsilon and P^N(B,[e_min,d])>=epsilon from endpoint-neighborhood probabilities.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** D03, S01, S02. **Source keys:** A93, SLP89.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Readable proof plan:** Architecture §7.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## S04 — Compact monotone feller stability
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.compact_monotone_feller_stability`.  
**Module:** `Aiyagari1994/Analysis/MonotoneFeller.lean`.

**Mathematical contract.** A monotone Feller kernel on a nonempty compact real interval satisfying the common-horizon endpoint-crossing condition has exactly one invariant probability law; every initial probability law converges weakly to it. Prove endpoint invariant existence and oscillation contraction.

**Assumption profiles:** Generic mathematical hypotheses stated in the contract. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** SLP89.

**Source locator:** SLP89 Assumption 12.1, Lemma 12.11 and Theorem 12.12, printed pp. 381-383 / PDF pp. 391-393.

**Readable proof plan:** Architecture §7.2.

**Adequacy note.** Generic mathematical theorem. Its crossing hypothesis is legitimate here; S05 must discharge it from S03.

## S05 — Stationary Law exists unique global
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.stationaryLaw_exists_unique_global`.  
**Module:** `Aiyagari1994/Stationary/GlobalStability.lean`.

**Mathematical contract.** For the core strictly impatient household, construct one invariant probability law supported on [e_min,B]. It is the only invariant probability law on all NNReal, and every initial probability law converges weakly to it.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** D03, S01, S03, S04. **Source keys:** A93, SLP89.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Readable proof plan:** Architecture §7.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## S06 — Stationary Law weakly continuous
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 06.

**Target declaration:** `Aiyagari1994.stationaryLaw_weakly_continuous`.  
**Module:** `Aiyagari1994/Stationary/ParameterContinuity.lean`.

**Mathematical contract.** With fixed U, nu and beta, the canonical invariant law is weakly continuous at every strictly impatient normalized price vector. Prove that each subsequential limit is invariant on a common compact state interval.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H06, D03, S05. **Source keys:** A93, SLP89.

**Source locator:** A93 Appendix Proposition 5; SLP89 Theorem 12.13, printed pp. 384-385 / PDF pp. 394-395.

**Readable proof plan:** Architecture §8.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## A01 — Resource asset labor law bridge
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 06.

**Target declaration:** `Aiyagari1994.resource_asset_labor_law_bridge`.  
**Module:** `Aiyagari1994/Aggregate/CrossSection.lean`.

**Mathematical contract.** If rho=(A-phi)#pi is the net-asset law, then current predetermined assets and independent labor have law rho×nu, whose resource image is pi. Give both directions of the stationary resource-law versus asset/labor-law correspondence.

**Assumption profiles:** BASIC, IID, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01, S05. **Source keys:** A93, A94.

**Source locator:** A94 equation (8) and stationary aggregation discussion, printed pp. 667-670 / PDF pp. 10-13; A93 Proposition 5 for invariant-law dependence.

**Readable proof plan:** Architecture §8.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## A02 — Stationary budget identity
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 06.

**Target declaration:** `Aiyagari1994.stationary_budget_identity`.  
**Module:** `Aiyagari1994/Aggregate/AssetSupply.lean`.

**Mathematical contract.** The stationary resource, asset and consumption integrals are finite; S=E_pi A-phi and E_pi c=r\*S+w\*E_nu l. Prove E_pi z=R\*E_pi A+E e before using the identity.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** S05, A01. **Source keys:** A93, A94.

**Source locator:** A94 equation (8) and stationary aggregation discussion, printed pp. 667-670 / PDF pp. 10-13; A93 Proposition 5 for invariant-law dependence.

**Readable proof plan:** Architecture §8.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## A03 — Stationary Asset Supply continuous
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 06.

**Target declaration:** `Aiyagari1994.stationaryAssetSupply_continuous`.  
**Module:** `Aiyagari1994/Aggregate/ParameterContinuity.lean`.

**Mathematical contract.** S(theta)=Integral(A_theta-phi_theta) dpi_theta is continuous throughout the strictly impatient admissible parameter region. Use a common compact interval and uniform-on-compact policy convergence.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H06, D03, S06, A02. **Source keys:** A93, C90.

**Source locator:** A94 equation (8) and stationary aggregation discussion, printed pp. 667-670 / PDF pp. 10-13; A93 Proposition 5 for invariant-law dependence.

**Readable proof plan:** Architecture §8.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## A04 — Certainty stationary assets at limit
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.certainty_stationary_assets_at_limit`.  
**Module:** `Aiyagari1994/Equilibrium/CertaintyBenchmark.lean`.

**Mathematical contract.** For deterministic positive labor and beta\*R<1, the canonical resource kernel has the unique invariant law concentrated at its constant effective income e_bar. The stationary asset policy is zero in shifted units, so stationary net assets equal minus the appropriate certainty debt limit. Prove global weak convergence by iterating the strictly decreasing deterministic transition above e_bar; no income nondegeneracy or curvature hypothesis is needed.

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H10, H12, S02. **Source keys:** A93, A94.

**Source locator:** A94 mean-income certainty and precautionary-assets discussion, printed pp. 669-670 / PDF pp. 12-13, especially notes 22-23; deterministic benchmark on p. 671 / PDF p. 14.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** The certainty labor value is the mean of risky labor. Its natural debt limit uses that mean, not the risky minimum.

## A05 — Risky assets above certainty near impatience
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.risky_assets_above_certainty_near_impatience`.  
**Module:** `Aiyagari1994/Aggregate/CertaintyComparison.lean`.

**Mathematical contract.** At fixed positive wages and the same institutional cap, or in the two respective natural-limit families, risky stationary mean assets are weakly above the mean-income certainty level at every strictly impatient admissible rate. They are strictly above it for all rates sufficiently close to lambda from below. The weak bound follows from nonnegative shifted assets and the ordering of effective debt limits; the strict near-boundary result follows from B02. Do not assume convex marginal utility or assert a general ordering across two risky distributions.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, IMPATIENT, FINITE_CAP, NATURAL_CAP. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P02, A02, A04, B02. **Source keys:** A94.

**Source locator:** A94 mean-income certainty and precautionary-assets discussion, printed pp. 669-670 / PDF pp. 12-13, especially notes 22-23; deterministic benchmark on p. 671 / PDF p. 14.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** This contracts the qualified precautionary-assets claim; it is not the deferred Sibley/Miller aggregate risk-order question.

## N01 — Stationary zero state marginal resolved
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07a.

**Target declaration:** `Aiyagari1994.stationary_zero_state_marginal_resolved`.  
**Module:** `Aiyagari1994/Stationary/ZeroState.lean`.

**Mathematical contract.** For any candidate invariant probability law at arbitrary R>0, the value marginal is finite and positive almost everywhere: if q(0)=infinity then pi{0}=0. Prove the atom/no-atom cases and conditional marginal integrability before real-valued integration.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H08, H09, S01. **Source keys:** CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## N02 — Stationary bounded jensen equality
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07a.

**Target declaration:** `Aiyagari1994.stationary_bounded_jensen_equality`.  
**Module:** `Aiyagari1994/Analysis/BoundedJensen.lean`.

**Mathematical contract.** For positive finite measurable q with q>=gamma\*Pq and a stationary law, psi(q) with psi(x)=x/(1+x) rules out gamma>1. At gamma=1 it implies q(next)=q(current) almost surely. Require only pointwise conditional integrability, not finite stationary E q.

**Assumption profiles:** Generic mathematical hypotheses stated in the contract. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.2.

**Adequacy note.** Proposed reusable lemma. Prove strict Jensen with the exact tangent-gap identity in architecture §9.2.

## N03 — No invariant supercritical
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07a.

**Target declaration:** `Aiyagari1994.no_invariant_supercritical`.  
**Module:** `Aiyagari1994/Stationary/Supercritical.lean`.

**Mathematical contract.** When beta\*R>1 and effective income is nondegenerate, the canonical household kernel has no invariant probability law on NNReal. No moment or bounded-support hypothesis is allowed on that law.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H09, S01, N01, N02. **Source keys:** A93, A94, CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## N04 — Critical stationary consumption constant
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07a.

**Target declaration:** `Aiyagari1994.critical_stationary_consumption_constant`.  
**Module:** `Aiyagari1994/Stationary/CriticalConsumption.lean`.

**Mathematical contract.** Under beta\*R=1, any putative stationary law would imply equal consumption across every adjacent pair and every finite stationary history. Include zero-consumption corners via equal right value marginals.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H11, H09, N01, N02. **Source keys:** CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## N05 — Two independent histories contradiction
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07b.

**Target declaration:** `Aiyagari1994.two_independent_histories_contradiction`.  
**Module:** `Aiyagari1994/Analysis/TwoShockStrings.lean`.

**Mathematical contract.** For R>1, a state-dependent consumption rule c(z), and resource recursion Z_next=R\*(Z-c(Z))+e_next with nonnegative resources and bounded nondegenerate iid income, a stationary probability law under which consumption remains constant along finite histories is impossible. Couple the same initial state with two independent future shock strings and contradict a strictly positive discounted-shock variance. No state moments are assumed.

**Assumption profiles:** NONDEGENERATE, IID. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.4.

**Adequacy note.** Proposed new finite-history proof construction; not presented as a theorem copied from the source.

## N06 — No invariant critical
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07b.

**Target declaration:** `Aiyagari1994.no_invariant_critical`.  
**Module:** `Aiyagari1994/Stationary/Critical.lean`.

**Mathematical contract.** When beta\*R=1 and effective income is nondegenerate, the canonical household kernel has no invariant probability law on NNReal, including laws of infinite first moment.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** S01, N04, N05. **Source keys:** A93, A94, CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## N07 — No invariant at or above impatience
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 07b.

**Target declaration:** `Aiyagari1994.no_invariant_at_or_above_impatience`.  
**Module:** `Aiyagari1994/Stationary/NoInvariant.lean`.

**Mathematical contract.** For beta\*R>=1 and nondegenerate iid effective income, no invariant probability law exists for the canonical household kernel.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** N03, N06. **Source keys:** A93, A94, CW00.

**Source locator:** A94 printed p. 669 / PDF p. 12, notes 20-21, distinguishes pathwise claims from the stationary implication. CW00 supplies background; the bounded-Jensen/two-string stationary proof here is a new reconstruction, not a cited source theorem.

**Readable proof plan:** Architecture §9.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## B01 — Tight kernel invariant limit
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 08.

**Target declaration:** `Aiyagari1994.tight_kernel_invariant_limit`.  
**Module:** `Aiyagari1994/Analysis/TightKernelLimit.lean`.

**Mathematical contract.** For Feller probability Markov kernels P_n and P on NNReal, suppose invariant probability laws mu_n form a tight family and converge weakly along a subsequence, and P_n f converges locally uniformly to P f for each bounded continuous f. Then the limit law is invariant for P. Prove the compact/tail split and use continuity of P f when passing the fixed test through weak convergence.

**Assumption profiles:** Generic mathematical hypotheses stated in the contract. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** SLP89.

**Source locator:** New generic tight-kernel limit lemma; related to the compact parameter argument in SLP89 Theorem 12.13, but the noncompact tail passage is proved here.

**Readable proof plan:** Architecture §10.1.

**Adequacy note.** Generic lemma, not a primitive closure assumption; demonstrate hypotheses in B02.

## B02 — Asset Supply tends To infinity at impatience
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 08.

**Target declaration:** `Aiyagari1994.assetSupply_tendsTo_infinity_at_impatience`.  
**Module:** `Aiyagari1994/Aggregate/UpperBoundary.lean`.

**Mathematical contract.** If r_n<lambda, r_n→lambda, w_n→w_star>0 and phi_n→finite phi_star through admissible prices, then S_n→+infinity. Prove sequentially via bounded-mean subsequence, tightness, B01 and N07, then translate to one-sided filters.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H06, A02, B01, N07. **Source keys:** A94, C90.

**Source locator:** C90 Proposition 2.4, printed p. 548 / PDF p. 7 (stated without proof); A94 note 19 and upper-boundary discussion. The proof route in architecture Section 10.1 is a reconstruction.

**Readable proof plan:** Architecture §10.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## B03 — Natural Asset Supply tends To neg infinity
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 08.

**Target declaration:** `Aiyagari1994.naturalAssetSupply_tendsTo_neg_infinity`.  
**Module:** `Aiyagari1994/Aggregate/LowerBoundary.lean`.

**Mathematical contract.** Under the natural limit, r_n>0 tends to zero and w_n→w0>0 imply S_n→-infinity. Uniformly bound shifted saving in normalized effective-income coordinates before subtracting phi_n→infinity.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, NATURAL_CAP. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** D03, A02. **Source keys:** A93, A94, C90.

**Source locator:** A94 natural-limit boundary discussion, printed p. 673 / PDF p. 16; C90 Proposition 2.4, printed p. 548 / PDF p. 7.

**Readable proof plan:** Architecture §10.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## F01 — Capital Demand wage constructed
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.capitalDemand_wage_constructed`.  
**Module:** `Aiyagari1994/Firms/Neoclassical.lean`.

**Mathematical contract.** For r>-delta, construct the unique K(r)>0 satisfying f_prime(K)=r+delta and w(r)=f(K)-K\*f_prime(K)>0. Prove firm optimization, continuity of both functions and strict decrease of K.

**Assumption profiles:** PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** A94.

**Source locator:** A94 firm-side general-equilibrium discussion, printed pp. 670-671 / PDF pp. 13-14; explicit primitive assumptions and consistency witness are supplied here.

**Readable proof plan:** Architecture §11.

**Adequacy note.** Also construct f(K)=sqrt(K), delta=1/2 as a production witness and combine it with P03 to demonstrate nonempty full equilibrium primitives.

## F02 — Finite Cap lower bracket
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.finiteCap_lower_bracket`.  
**Module:** `Aiyagari1994/Equilibrium/LowerBracket.lean`.

**Mathematical contract.** For every finite b>=0, derive r_L in (-delta,0) with stationary asset supply S(r_L,w(r_L))<K(r_L), using f(K)/K→0 and E c=w+rS>=0. Do not assume an excess-supply sign.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, FINITE_CAP, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P02, A02, F01. **Source keys:** A94.

**Source locator:** New derived lower-bracket lemma supporting A94 equilibrium existence; not a theorem explicitly proved by the source.

**Readable proof plan:** Architecture §11.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G01 — Equilibrium resource asset iff
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.equilibrium_resource_asset_iff`.  
**Module:** `Aiyagari1994/Equilibrium/Definition.lean`.

**Mathematical contract.** Define stationary equilibrium with firm optimization, canonical lifetime-optimal policy, invariant cross-sectional law, integrability and market clearing. Prove resource-law and net-asset/current-labor formulations equivalent. The definition allows all r>-delta and does not require r<lambda.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01, H05, S01, A01, F01. **Source keys:** A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G02 — Finite Cap equilibrium exists
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.finiteCap_equilibrium_exists`.  
**Module:** `Aiyagari1994/Equilibrium/Existence.lean`.

**Mathematical contract.** For every finite b>=0 and the core economic primitives, there exists a stationary equilibrium with r in (-delta,lambda). Derive both signs from F02 and B02 and apply continuity/IVT. Do not assert uniqueness or positive interest.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, FINITE_CAP, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P02, A03, B02, F02, G01. **Source keys:** A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G03 — Natural Cap equilibrium exists
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.naturalCap_equilibrium_exists`.  
**Module:** `Aiyagari1994/Equilibrium/Existence.lean`.

**Mathematical contract.** For the natural-limit model and the core economic primitives, a stationary equilibrium exists with 0<r<lambda. Derive endpoint signs from B03 and B02 along the firm wage schedule.

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, NATURAL_CAP, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P02, A03, B02, B03, F01, G01. **Source keys:** A93, A94.

**Source locator:** A94 natural-limit existence discussion and note 30, printed p. 673 / PDF p. 16.

**Readable proof plan:** Architecture §11.3.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G04 — Every equilibrium rate below impatience
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.every_equilibrium_rate_below_impatience`.  
**Module:** `Aiyagari1994/Equilibrium/MainTheorem.lean`.

**Mathematical contract.** Every stationary equilibrium satisfying the untruncated definition has r<lambda, because its invariant law contradicts N07 if beta\*(1+r)>=1. This is not restricted to the particular equilibria constructed by G02/G03.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** N07, G01. **Source keys:** A93, A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G05 — Certainty benchmark verified
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.certainty_benchmark_verified`.  
**Module:** `Aiyagari1994/Equilibrium/CertaintyBenchmark.lean`.

**Mathematical contract.** Construct and verify the mean-income certainty steady state r=lambda, K=K(lambda), positive stationary consumption. Use utility concavity and the deterministic present-value budget, not just an Euler equality.

**Assumption profiles:** BASIC, SMOOTH, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01, H05, F01. **Source keys:** A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G06 — Equilibrium capital above certainty
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.equilibrium_capital_above_certainty`.  
**Module:** `Aiyagari1994/Equilibrium/MainTheorem.lean`.

**Mathematical contract.** Every risky stationary equilibrium has K>K_FI=K(lambda).

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** F01, G04, G05. **Source keys:** A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G07 — Equilibrium gross saving share above certainty
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.equilibrium_gross_saving_share_above_certainty`.  
**Module:** `Aiyagari1994/Equilibrium/Saving.lean`.

**Mathematical contract.** Every risky stationary equilibrium has delta\*K/f(K)>delta\*K_FI/f(K_FI). Prove that the gross investment share is strictly increasing using f(K)-K\*f_prime(K)>0. Net saving is not the outcome.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** F01, G06. **Source keys:** A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## G08 — Equilibrium goods market clears
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 09.

**Target declaration:** `Aiyagari1994.equilibrium_goods_market_clears`.  
**Module:** `Aiyagari1994/Equilibrium/Saving.lean`.

**Mathematical contract.** At every stationary equilibrium, E c + delta\*K=f(K), deriving goods clearing from household stationarity and competitive factor payments. Establish required moment statements for a general equilibrium law.

**Assumption profiles:** BASIC, SMOOTH, NONDEGENERATE, IID, LABOR_MEAN_ONE, PRODUCTION. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** G01, F01. **Source keys:** A94.

**Source locator:** A94 general-equilibrium and certainty comparison, printed pp. 670-671 / PDF pp. 13-14, especially notes 24-27.

**Readable proof plan:** Architecture §11.4.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## NP01 — Discounted budget telescope
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 10.

**Target declaration:** `Aiyagari1994.discounted_budget_telescope`.  
**Module:** `Aiyagari1994/Budget/NoPonzi.lean`.

**Mathematical contract.** For every finite T, sum(t=0..T) R^(-t)c_t=R\*a_0+sum(t=0..T) R^(-t)w\*l_t-R^(-T)\*a_(T+1). Prove exactly the timing and discount exponents used by the source.

**Assumption profiles:** BASIC, PATH_FEASIBILITY. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 1, printed p. 37 / PDF p. 38; A94 p. 666 / PDF p. 9, note 16.

**Readable proof plan:** Architecture §12.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## NP02 — Natural Bound implies no Ponzi
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 10.

**Target declaration:** `Aiyagari1994.naturalBound_implies_noPonzi`.  
**Module:** `Aiyagari1994/Budget/NoPonzi.lean`.

**Mathematical contract.** For r>0, bounded income and the natural asset floor imply existence of a finite nonnegative discounted terminal wealth limit, almost surely. Do not strengthen nonnegative to zero.

**Assumption profiles:** BASIC, PATH_FEASIBILITY, NATURAL_CAP. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** NP01. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 1, printed p. 37 / PDF p. 38; A94 p. 666 / PDF p. 9, note 16.

**Readable proof plan:** Architecture §12.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## NP03 — No Ponzi implies natural Bound
**Status:** UNFORMALIZED. **Scope:** core. **Milestone:** 10.

**Target declaration:** `Aiyagari1994.noPonzi_implies_naturalBound`.  
**Module:** `Aiyagari1994/Budget/NoPonzi.lean`.

**Mathematical contract.** For r>0 and an adapted feasible plan, existence of a finite nonnegative discounted terminal wealth limit almost surely implies the natural debt floor at every date almost surely. Use a positive-probability debt violation and a finite low-income history.

**Assumption profiles:** BASIC, NONDEGENERATE, IID, PATH_FEASIBILITY. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** NP01. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 1, printed p. 37 / PDF p. 38; A94 p. 666 / PDF p. 9, note 16.

**Readable proof plan:** Architecture §12.1.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## E01 — Zero Rate cap change exact
**Status:** UNFORMALIZED. **Scope:** extension. **Milestone:** 10.

**Target declaration:** `Aiyagari1994.zeroRate_cap_change_exact`.  
**Module:** `Aiyagari1994/Extensions/BorrowingCap.lean`.

**Mathematical contract.** At r=0 and fixed w, changing b from b1 to b2 does not change the shifted problem or its canonical policy/law and changes stationary net asset supply by -(b2-b1).

**Assumption profiles:** BASIC, SMOOTH, CURVATURE, NONDEGENERATE, IID, FINITE_CAP. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P02, H02, H04, S05, A02. **Source keys:** A93, A94.

**Source locator:** A94 borrowing-limit discussion, printed pp. 672-673 / PDF pp. 15-16, and equation (2) on printed p. 666 / PDF p. 9.

**Readable proof plan:** Architecture §12.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## E02 — Caps above natural Limit equivalent
**Status:** UNFORMALIZED. **Scope:** extension. **Milestone:** 10.

**Target declaration:** `Aiyagari1994.caps_above_naturalLimit_equivalent`.  
**Module:** `Aiyagari1994/Extensions/BorrowingCap.lean`.

**Mathematical contract.** At r>0, any two finite caps weakly above w\*l_min/r induce identical effective household primitives, policies and, when subcritical, stationary laws and net asset supply.

**Assumption profiles:** BASIC, FINITE_CAP. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P02, H02, H04, S05. **Source keys:** A93, A94.

**Source locator:** A94 borrowing-limit discussion, printed pp. 672-673 / PDF pp. 15-16, and equation (2) on printed p. 666 / PDF p. 9.

**Readable proof plan:** Architecture §12.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

## E03 — Natural Bound government Debt correspondence
**Status:** UNFORMALIZED. **Scope:** extension. **Milestone:** 10.

**Target declaration:** `Aiyagari1994.naturalBound_governmentDebt_correspondence`.  
**Module:** `Aiyagari1994/Extensions/GovernmentDebt.lean`.

**Mathematical contract.** In pure exchange under tax-adjusted natural borrowing, x=a-d maps budget, admissibility, lifetime optimality, invariant laws and bond clearing bijectively between government-debt and debt-free economies. It is not a statement about capital demand or a fixed borrowing cap.

**Assumption profiles:** BASIC, IID, PURE_EXCHANGE_DEBT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** P01, H05. **Source keys:** A93, A94.

**Source locator:** A94 government-debt reinterpretation, printed pp. 673-674 / PDF pp. 16-17.

**Readable proof plan:** Architecture §12.2.

**Adequacy note.** No proof or adequacy certification is asserted by this initial entry.

