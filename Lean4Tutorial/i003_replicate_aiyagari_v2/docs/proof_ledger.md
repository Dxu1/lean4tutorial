# Proof ledger — Aiyagari theory replication

**Economic status:** P01, P02, P03, H01, H02, H03, H04, H05, H06, H07, H08, H09, H10, H11, H12, H13, H14, D01, D02, D03, S01, S02, S03, S04 are **GREEN**; S05, S06, A01, A02, A03, A04, A05, N01, N02, N03, N04, N05, N06, N07, B01, B02, B03, F01, F02, G01, G02, G03, G04, G05, G06, G07, G08, NP01, NP02, NP03, E01, E02, E03 are **UNFORMALIZED**. M00 bootstrap acceptance remains infrastructure only. Exact acceptance records are in `reviews/`. Proposed proof plans remain proposed until checked.

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

## H01 — Bellman self-map and contraction

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Review gate:** M02A. See `reviews/02a_acceptance.md`.

**Target:** `Aiyagari1994.bellman_selfmap_contracting` in `Aiyagari1994/Household/Bellman.lean`.

**Actual assumptions.** Only `HouseholdPrimitives`. The construction uses $0<\beta<1$, utility continuity and boundedness on nonnegative consumption, the finite probability law on the compact labor subtype, and nonnegative affine generated resources. Strict utility increase and concavity are available in BASIC but not needed for H01. No return-discount restriction is imposed: every admissible $R>0$ is covered.

**Definition and integrability.** For $a\in[0,z]$,

$$Q_v(z,a)=U(z-a)+\beta\int v(Ra+e(l))\,d\nu(l).$$

The transition and integrand facts are proved separately:

- `nextResources_continuous`: joint transition continuity.
- `continuation_integrand_continuous`: joint integrand continuity.
- `continuation_integrand_bound`: the bound by $\|v\|_\infty$.

 `continuation_integrable` proves integrability for every action by continuity on the compact labor subtype and finiteness of its probability measure. `continuation_continuous` applies the installed compact parametric integral theorem on the whole labor subtype. Integral subtraction in the contraction proof uses the two explicit integrability results.

The objective has a continuous extension using NNReal subtraction outside the feasible set. `bellmanObjective_feasible` identifies it with the displayed real-subtraction formula whenever $a\leq z$. Thus no negative-consumption utility value enters the maximization. Joint objective continuity is proved by composing primitive utility continuity with nonnegative consumption and adding the continuous continuation term.

**Maximum and boundedness proof.** The actual action is shifted savings $a$. For maximum-value continuity only, `shareObjective` evaluates $a=tz$ on the fixed compact subtype $t\in[0,1]$. `share_feasible` and `feasible_share` prove that this parametrization covers exactly $[0,z]$; at zero, all shares give the same singleton action. `compactMax_continuous` wraps the installed compact supremum theorem; `compactMax_attained`, `le_compactMax` and `compactMax_le` give attainment and bounds. These are reusable generic theorems in `Analysis/ParametricMax.lean`, with their mathematical hypotheses discharged by `shareObjective_continuous`.

For a primitive bound $|U(c)|\leq C$ and bounded continuous $v$,

$$|Q_v(z,a)|\leq C+\beta\|v\|_\infty.$$

`bellmanValue_bound` transfers the bound through an attained optimizer. The distance between any two Bellman values is consequently bounded by twice this constant, supplying the bounded-continuous constructor. There is no bound on $z$, assets or the state space.

**Contraction proof.** The probability mass is one, so `continuation_sub_bound` gives
$|E[v(Ra+e)]-E[w(Ra+e)]|\leq\|v-w\|_\infty$.
Current utility cancels at the same action, giving `objective_sub_bound`. Take an optimizer for $v$ at $z$. Its objective under $w$ is no greater than the maximum for $w$, hence
$T v(z)-T w(z)\leq\beta\|v-w\|_\infty$.
Reverse the candidates and use symmetry of the norm to obtain the absolute-value bound. `bellman_pointwise_contraction` and `bellman_norm_contraction` turn this into the supremum-norm bound, then the installed `ContractingWith` type. No subtraction is moved through a maximum.

**Exact elaborated anchor and canonical self-map:**

```text
Aiyagari1994.bellman_selfmap_contracting (m : Aiyagari1994.HouseholdPrimitives) :
  ContractingWith ⟨m.beta, ⋯⟩ (Aiyagari1994.bellmanOperator m)
'Aiyagari1994.bellman_selfmap_contracting' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```text
Aiyagari1994.bellmanOperator (m : Aiyagari1994.HouseholdPrimitives) (v : Aiyagari1994.ValueSpace) :
  Aiyagari1994.ValueSpace
'Aiyagari1994.bellmanOperator' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Source correspondence:** A94 equations (4)-(7), printed pp. 666-667 / PDF pp. 9-10, visually inspected. A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39, is the manifest context and was also inspected. Its differentiability and envelope claims are outside M02A; the BASIC Bellman construction is explicitly reconstructed under architecture section 3.

**Dependencies and qualification.** P01 supplies the established shifted-budget interpretation; the normalized-price type is unchanged. The kernel-checked result is a Bellman self-map, not lifetime verification or an equilibrium result. All H01 exports pass direct no-sorry and transitive-axiom audits; only the accepted foundational axioms occur.

## H02 — Canonical bounded continuous value function

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Review gate:** M02A. See `reviews/02a_acceptance.md`.

**Target:** `Aiyagari1994.valueFunction_unique_fixedPoint`.

**Module:** `Aiyagari1994/Household/Value.lean`.

**Actual assumptions and dependencies.** Only `HouseholdPrimitives`, using H01. The bounded-continuous real function space on all NNReal is complete. No value function is supplied as a premise, and no extra economic assumption is introduced.

**Fixed-point and convergence proof.** Define `valueFunction m` once using the installed `ContractingWith.fixedPoint` applied to `bellmanOperator m` and `bellman_selfmap_contracting m`. The installed fixed-point and uniqueness theorems prove `valueFunction_fixedPoint` and `valueFunction_unique` among all bounded continuous candidates. `valueIteration_tendsto` gives convergence in the supremum metric from every initial bounded continuous function. `valueIteration_uniform` uses the installed equivalence with uniform convergence, not merely a pointwise assertion. Later modules use exactly this canonical definition.

**Exact range bounds.** `utilityRange` is the image of all nonnegative real consumption under $U$. `utilityRange_nonempty` witnesses consumption zero. `utilityRange_bounded` derives both real bounds from the primitive absolute bound. Define

$$U_{inf}=\operatorname{sInf}(\operatorname{range}U),\qquad
U_{sup}=\operatorname{sSup}(\operatorname{range}U).$$

The functions here have NNReal consumption arguments coerced to real. Thus these are exactly the finite real infimum and supremum over $c\geq0$. `utility_bounds` supplies the order inequalities. Likewise `valueRange_bounded` bounds the range of any bounded continuous candidate by its norm.

Let $L=\inf V$ and $H=\sup V$. Explicit integrability and integral monotonicity imply $L\leq E[V(Ra+e)]\leq H$ (`continuation_range_bounds`). The feasible action zero gives $V(z)\geq U_{inf}+\beta L$; an attained optimizer gives $V(z)\leq U_{sup}+\beta H$. Taking infimum and supremum, respectively, yields

$$U_{inf}+\beta L\leq L,\qquad H\leq U_{sup}+\beta H.$$

Since $1-\beta>0$, division and $L\leq V(z)\leq H$ give exactly

$$\frac{U_{inf}}{1-\beta}\leq V(z)\leq\frac{U_{sup}}{1-\beta}.$$

No attainment of the infimum or supremum of $V$ on the unbounded state space is assumed. This argument uses conditional-completeness lemmas with proved nonemptiness and boundedness; it does not replace the bounds by an arbitrary symmetric constant.

**Exact elaborated anchor and canonical definition type:**

```text
Aiyagari1994.valueFunction_unique_fixedPoint (m : Aiyagari1994.HouseholdPrimitives) :
  Aiyagari1994.bellmanOperator m (Aiyagari1994.valueFunction m) = Aiyagari1994.valueFunction m ∧
    (∀ (v : Aiyagari1994.ValueSpace), Aiyagari1994.bellmanOperator m v = v → v = Aiyagari1994.valueFunction m) ∧
      (∀ (v : Aiyagari1994.ValueSpace),
          TendstoUniformly (fun n z => ((Aiyagari1994.bellmanOperator m)^[n] v) z) (⇑(Aiyagari1994.valueFunction m))
            Filter.atTop) ∧
        ∀ (z : Aiyagari1994.Resources),
          Aiyagari1994.utilityInf m / (1 - m.beta) ≤ (Aiyagari1994.valueFunction m) z ∧
            (Aiyagari1994.valueFunction m) z ≤ Aiyagari1994.utilitySup m / (1 - m.beta)
'Aiyagari1994.valueFunction_unique_fixedPoint' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```text
Aiyagari1994.valueFunction (m : Aiyagari1994.HouseholdPrimitives) : Aiyagari1994.ValueSpace
'Aiyagari1994.valueFunction' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Source correspondence:** A94 equations (4)-(7), printed pp. 666-667 / PDF pp. 9-10, visually inspected. A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39, is the manifest context and was also inspected. Its differentiability and envelope claims are outside M02A; the BASIC Bellman construction is explicitly reconstructed under architecture section 3.

**Qualification.** The canonical function is the unique bounded continuous Bellman fixed point. Its interpretation as lifetime-optimal expected utility remains H05. Audit results contain only `propext`, `Classical.choice`, and `Quot.sound`.

## H03 — Value concavity and strict increase

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Review gate:** M02A. See `reviews/02a_acceptance.md`.

**Target:** `Aiyagari1994.valueFunction_concave_strictMono`.

**Module:** `Aiyagari1994/Household/Value.lean`.

**Actual assumptions and dependencies.** Only BASIC, through the canonical H02 value function, primitive strict concavity and strict monotonicity of utility, and the affine nonnegative transition. No differentiability, IID histories, income nondegeneracy or impatience condition is used.

**Ordinary concavity.** `NNRealConcave` quantifies over all states $x,y$ and all nonnegative real weights $a,b$ summing to one, represented as NNReal. It asserts $a f(x)+b f(y)\leq f(ax+by)$. `NNRealConcave.real_combination` explicitly yields the usual formula with any real $\theta\in[0,1]$. This avoids imposing a real vector-space instance on NNReal without weakening real convex-combination concavity.

**Preservation proof.** Given feasible savings $s\leq x$ and $t\leq y$, $as+bt\leq ax+by$. Consumption at the combined pair is $a(x-s)+b(y-t)$. Primitive strict concavity supplies ordinary utility concavity. `transition_convex_combination` proves the affine identity for next resources, including the constant income term by $a+b=1$. Concavity of $v$ therefore gives a pointwise continuation inequality. `continuation_concave` integrates it with explicit integrability of each summand and uses integral addition and scalar multiplication. Multiplication by positive beta and addition of the utility inequality prove `objective_convex_combination`.

Take attained optimizers at the two original states. Their convex combination is feasible at the combined state and cannot exceed that state's maximum. This proves `bellman_preserves_concavity`.

**Iteration and limit.** Zero is concave and weakly increasing (`nnrealConcave_zero`, `monotone_const`). Induction gives `valueIteration_concave` and `valueIteration_monotone` for zero-start iterates. The uniform convergence established in H02 supplies the convergent evaluations at each of the three states in the concavity inequality, and at both states in the monotonicity inequality. Passing inequalities through these proved limits establishes `valueFunction_concave` and `valueFunction_monotone`. No unproved limit principle is used.

**Strict increase.** For $x<y$, take an optimizer at $x$ and keep the same saving action at $y$. It remains feasible. Current consumption strictly increases; the continuation term is exactly unchanged. Strict utility monotonicity makes the new feasible objective strictly exceed the old maximum. Therefore $T v$ is strictly increasing for every candidate $v$ (`bellman_strictMono`), a slightly stronger intermediate result than monotonicity preservation. Applying the fixed-point identity proves `valueFunction_strictMono`. No envelope theorem or derivative is involved.

**Exact elaborated anchor and real concavity formula:**

```text
Aiyagari1994.valueFunction_concave_strictMono (m : Aiyagari1994.HouseholdPrimitives) :
  Aiyagari1994.NNRealConcave ⇑(Aiyagari1994.valueFunction m) ∧ StrictMono ⇑(Aiyagari1994.valueFunction m)
'Aiyagari1994.valueFunction_concave_strictMono' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```text
Aiyagari1994.NNRealConcave.real_combination {f : Aiyagari1994.Resources → ℝ} (hf : Aiyagari1994.NNRealConcave f)
  (x y : Aiyagari1994.Resources) (theta : ℝ) (h0 : 0 ≤ theta) (h1 : theta ≤ 1) :
  theta * f x + (1 - theta) * f y ≤ f ⟨theta * ↑x + (1 - theta) * ↑y, ⋯⟩
'Aiyagari1994.NNRealConcave.real_combination' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Source correspondence:** A94 equations (4)-(7), printed pp. 666-667 / PDF pp. 9-10, visually inspected. A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39, is the manifest context and was also inspected. Its differentiability and envelope claims are outside M02A; the BASIC Bellman construction is explicitly reconstructed under architecture section 3.

**Qualification.** This is concavity and strict increase of the canonical value function only. Policy monotonicity, differentiability and drift remain later contracts. The no-sorry and transitive-axiom audits pass with the accepted foundational axioms.

## H04 — Unique continuous shifted-asset policy

**Status:** GREEN, externally accepted 2026-09-11. **Scope:** core. **Review gate:** M02A. See `reviews/02a_acceptance.md`.

**Target:** `Aiyagari1994.assetPolicy_unique_continuous`.

**Module:** `Aiyagari1994/Household/Policy.lean`.

**Actual assumptions and dependencies.** Only BASIC and H03's canonical concave value function. In particular, there is no supplied optimizer/policy, derivative, Euler condition, positive-consumption premise, finite labor law, bounded asset space or invariant law.

**Existence and uniqueness.** `AssetOptimal m z a` means $a\leq z$ and $Q_V(z,a)=V(z)$; $a$ is NNReal. H01 attainment and the H02 fixed-point equation prove `assetOptimal_exists`. For two distinct feasible actions, consumption $z-a$ is distinct. `objective_strictConcave_assets` proves strict concavity for every positive pair of real convex weights by adding strict current utility concavity and weak expected continuation concavity. Combined actions remain feasible.

At zero all feasible actions equal zero. Otherwise two distinct maximizing actions would give a midpoint with objective strictly above their common maximum, a contradiction. This proves `assetOptimal_unique` and then `assetOptimal_existsUnique`. Classical choice from this proved unique existence defines the canonical `assetPolicy`. It is never a primitive field. `assetPolicy_optimal` and `assetPolicy_le_state` give maximization and feasibility. `assetOptimal_iff_maximizes` proves equivalence with maximization over every feasible shifted asset; `assetPolicy_existsUnique_maximizer` exposes this as genuine unique existence for use by H05.

**Reusable continuity lemma:** `compact_unique_argmax_continuous`.

**Analysis module:** `Analysis/ParametricMax.lean`.

**Continuity proof.** The reusable lemma uses a closed-graph proof. For a closed choice set $S$, intersect the graph $f(x,k)=\max_j f(x,j)$ with $X\times S$. It is closed by joint objective and maximum-value continuity. Projection to $X$ is closed because the choice space is compact. Uniqueness identifies this projection with the inverse image of $S$ under the selected optimizer; hence the optimizer is continuous.

Apply this theorem to the share optimizer only on the open subtype of strictly positive resources. Define `positiveAssetShare` as $A(z)/z$; feasibility puts it in $[0,1]$. `positiveAssetShare_mul` recovers the actual asset choice. At positive $z$, multiplication by $z$ is injective, so uniqueness of assets implies uniqueness of the share. Joint share-objective continuity supplies the remaining generic hypothesis. Multiplying the continuous share by $z$ gives `assetPolicy_continuous_positive`.

At zero, `assetPolicy_zero` and $0\leq A(z)\leq z$ imply convergence to zero by squeezing. Joining this boundary argument with continuity on the open positive domain proves `assetPolicy_continuous`. No unique share at zero is asserted. Continuity of $V$ alone is never used as a policy-continuity argument.

**Consumption and forward interface.** Define `consumptionPolicy m z = z - assetPolicy m z` in NNReal. The proven asset bound gives its exact real-subtraction identity, nonnegativity, and $c(z)+A(z)=z$ (`consumptionPolicy_coe`, `consumptionPolicy_budget`). It is continuous by subtraction. The main theorem exposes canonical uniqueness, feasibility, domination of every feasible objective, budget and continuity.

**Exact elaborated anchor and maximization interface:**

```text
Aiyagari1994.assetPolicy_unique_continuous (m : Aiyagari1994.HouseholdPrimitives) :
  (∀ (z : Aiyagari1994.Resources),
      Aiyagari1994.AssetOptimal m z (Aiyagari1994.assetPolicy m z) ∧
        ∀ (a : Aiyagari1994.Resources), Aiyagari1994.AssetOptimal m z a → a = Aiyagari1994.assetPolicy m z) ∧
    Continuous (Aiyagari1994.assetPolicy m) ∧
      (∀ (z a : Aiyagari1994.Resources),
          a ≤ z →
            Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z a ≤
              Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z (Aiyagari1994.assetPolicy m z)) ∧
        (∀ (z : Aiyagari1994.Resources), 0 ≤ Aiyagari1994.assetPolicy m z ∧ Aiyagari1994.assetPolicy m z ≤ z) ∧
          (∀ (z : Aiyagari1994.Resources),
              ↑(Aiyagari1994.consumptionPolicy m z) = ↑z - ↑(Aiyagari1994.assetPolicy m z) ∧
                Aiyagari1994.consumptionPolicy m z + Aiyagari1994.assetPolicy m z = z) ∧
            Continuous (Aiyagari1994.consumptionPolicy m)
'Aiyagari1994.assetPolicy_unique_continuous' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```text
Aiyagari1994.assetPolicy_existsUnique_maximizer (m : Aiyagari1994.HouseholdPrimitives) (z : Aiyagari1994.Resources) :
  ∃! a,
    a ≤ z ∧
      ∀ b ≤ z,
        Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z b ≤
          Aiyagari1994.bellmanObjective m (Aiyagari1994.valueFunction m) z a
'Aiyagari1994.assetPolicy_existsUnique_maximizer' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```text
Aiyagari1994.assetPolicy (m : Aiyagari1994.HouseholdPrimitives) (z : Aiyagari1994.Resources) : Aiyagari1994.Resources
'Aiyagari1994.assetPolicy' depends on axioms: [propext, Classical.choice, Quot.sound]
```

```text
Aiyagari1994.consumptionPolicy (m : Aiyagari1994.HouseholdPrimitives) (z : Aiyagari1994.Resources) :
  Aiyagari1994.Resources
'Aiyagari1994.consumptionPolicy' depends on axioms: [propext, Classical.choice, Quot.sound]
```

**Source correspondence:** A94 equations (4)-(7), printed pp. 666-667 / PDF pp. 9-10, visually inspected. A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39, is the manifest context and was also inspected. Its differentiability and envelope claims are outside M02A; the BASIC Bellman construction is explicitly reconstructed under architecture section 3.

**Qualification.** The asset action is shifted next-period assets, not a share or net assets. These results do not claim policy monotonicity, strict positivity of consumption, or H05 lifetime optimality. Only accepted foundational axioms occur. H05 was UNFORMALIZED at the accepted M02A boundary; the separate M02B entry below records its implementation and external acceptance.

## H05 — Canonical Policy lifetime optimal

**Status:** GREEN, externally accepted on 2026-09-11. **Scope:** core. **Milestone:** M02B.

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

**Audit and review evidence.** Fresh builds of both M02B modules, the full project build, direct `Audit.lean`, exact signature probe, contract checker and prohibited-pattern scan pass. All 65 new exported declarations, including the feasible-plan projections, pass `assert_no_sorry` and transitive axiom printing. Across the entire audit there are 254 checked declarations; only `propext`, `Classical.choice` and `Quot.sound` occur. Exact required interfaces and structure fields appear in `reports/02b_signatures.md`; raw evidence is in `reports/logs/02b/`. H05 is GREEN by external review in `reviews/02b_acceptance.md`. Lifetime utility is a series of expectations under consistent finite-history laws; no literal infinite-product path random variable has been constructed. At the accepted M02B boundary, H06 and all later contracts were UNFORMALIZED; no M03 work was included. The M03A entries below record the separate H07/H08 review submission.

\newpage

## H06 — Policy jointly continuous
**Status:** GREEN. Independent Astra acceptance: `reviews/m04a_acceptance.md`. **Scope:** core. **Review gate:** M04A.

**Target declaration:** `Aiyagari1994.policy_jointly_continuous`.  
**Module:** `Aiyagari1994/Household/ParameterContinuity.lean`.

**Mathematical statement and parameter domain.** Fix a `HouseholdPrimitives` object `m`, hence its utility, utility proof, compact iid labor law, income support and discount factor. `AdmissibleNormalizedPrices m.income` is the subtype of real triples $(R,w,k)$ satisfying $R>0$, $w>0$, and $w\ell+k\geq0$ on the fixed labor support. `m.withPrices q` changes only this normalized price triple. The theorem proves that
$$
(q,z)\longmapsto V_{m[q]}(z),\qquad
(q,z)\longmapsto A_{m[q]}(z)
$$
are continuous on the full product of admissible prices and nonnegative resources. There is no condition on $\beta R$; critical and supercritical returns are included.

**Actual assumptions and dependencies.** BASIC only. H02 supplies the canonical bounded continuous Bellman fixed point and contraction iteration; H04 supplies the canonical unique shifted-asset maximizer and $0\leq A(z)\leq z$. Utility, the labor probability law, and beta are fixed definitionally by `withPrices`. No smoothness, Inada condition, CoreRegularity, income nondegeneracy, mean normalization, consumption positivity, invariant law, bounded state space, or impatience condition $\beta R<1$ is assumed.

**Value proof.** Starting from the zero bounded value, each finite Bellman iterate is jointly continuous in $(q,z)$. The transition $(q,a,\ell)\mapsto Ra+w\ell+k$ is continuous, compact-support parametric integration preserves continuity, and maximization uses the fixed compact share set $[0,1]$. If $|U|\leq C$, contraction gives the price-uniform tail estimate
$$
\left|T_q^n0(z)-V_q(z)\right|
\leq \beta^n\frac{C}{1-\beta}.
$$
Thus the jointly continuous finite iterates converge uniformly over all admissible $(q,z)$ to the parameterized value function. This does not assert or use global sup-norm continuity of $q\mapsto T_q$ on the unbounded state space.

**Policy proof and zero boundary.** On $z>0$, express the policy as the unique maximizing share times resources. The objective is jointly continuous because the newly proved value function is jointly continuous and the labor integral is over the fixed compact probability space. The compact unique-argmax theorem makes the share continuous, hence $A_q(z)$ is jointly continuous on positive resources. At $z=0$, uniqueness of shares is neither claimed nor needed: H04 gives $0\leq A_q(z)\leq z$ uniformly in prices, so the squeeze theorem proves joint continuity at every $(q,0)$.

**Exact elaborated contract signature and transitive axioms.**

```text
Aiyagari1994.policy_jointly_continuous (m : Aiyagari1994.HouseholdPrimitives) :
  (Continuous fun x =>
      (Aiyagari1994.valueFunction (Aiyagari1994.HouseholdPrimitives.withPrices m x.1)) x.2) ∧
    Continuous fun x =>
      Aiyagari1994.assetPolicy (Aiyagari1994.HouseholdPrimitives.withPrices m x.1) x.2
'Aiyagari1994.policy_jointly_continuous' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Every new public declaration is covered by `#check`, `assert_no_sorry`, and `#print axioms` in `Audit.lean` and `Probes/M04ASignatures.lean`. Only `propext`, `Classical.choice`, and `Quot.sound` occur.

**Source correspondence and qualifications.** Approved locator: A93 Appendix Proposition 2, printed pp. 37–38 / PDF pp. 38–39; A94 equations (5)–(7), printed pp. 666–667 / PDF pp. 9–10. The finite-horizon, uniform-tail, normalized-parameter and zero-boundary details are the explicitly approved reconstruction in architecture §6.1, not a claim that the paper prints this Lean proof. All mandatory predecessor qualifications remain in force. In particular, H06 does not invoke any marginal object, does not identify `rightMarginalValue m 0` with the economic boundary marginal, and makes no stationarity, tightness, drift, invariant-law, or equilibrium claim. REVIEW_READY is not GREEN and does not authorize any later contract.

## H07 — Policy order and Lipschitz bounds

**Status:** GREEN, externally accepted on 2026-09-11; see `reviews/03a_acceptance.md`. **Scope:** core. **Review gate:** M03A.

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

**Verification:** fresh module build, full build, direct audit and no-sorry/axiom checks pass. Only standard foundational axioms occur. External review accepted H07; see `reviews/03a_acceptance.md`.

## H08 — Right marginal value

**Status:** GREEN, externally accepted on 2026-09-11; see `reviews/03a_acceptance.md`. **Scope:** core. **Review gate:** M03A.

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

**Verification and boundary of the predecessor gate.** Both M03A targets and all supporting exports pass fresh builds, the full build, direct `Audit.lean`, no-sorry assertions, the prohibited-pattern scan and transitive axiom checks. Only `propext`, `Classical.choice` and `Quot.sound` occur. The exact signature report contains all secant, right-continuity and boundary-limit interfaces plus the printed definitions. H07 and H08 are GREEN by external review; H01–H05 remain GREEN. Historically, at M03A acceptance, H09 and later targets were UNFORMALIZED. Current statuses are generated in the economic-status overview and individual contract headings. H09 passed independent Astra review; see `reviews/m03b1_acceptance.md` and its structured counterpart. The H10 heading records its current independent-review status. The accepted boundary qualification remains mandatory: never use `rightMarginalValue m 0` as the economic zero-state marginal; use the separate extended `zeroRightMarginal`.

## H09 — Right Marginal Value superharmonic
**Status:** GREEN. Independent Astra acceptance: `reviews/m03b1_acceptance.md`.

**Scope:** core. **Milestone:** 03. **Review gate:** M03B1.

**Target declaration:** `Aiyagari1994.rightMarginalValue_superharmonic`.  
**Module:** `Aiyagari1994/Household/MarginalInequality.lean`.

**Mathematical contract.** For every z with finite right marginal, q(z)>=beta\*R\*Integral q(R\*A(z)+e) dnu. Establish the extended-integral inequality first and deduce conditional integrability; it is valid without beta\*R<1 and without consumption positivity.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H08. **Source keys:** CW00.

**Source locator:** New concave-analysis/value-marginal infrastructure for the Aiyagari claims; inspired by CW00 Sections 2-4. Not a literal numbered Aiyagari theorem.

**Exact state-space interface.** The new ENNReal-valued marginal is defined on all
`Resources`.  At `z=0` it is exactly `zeroRightMarginal m`; at positive `z` it converts the
accepted finite real marginal with `ENNReal.ofReal`.  Thus the economic zero marginal can be
infinite, and the real marginal function is never evaluated economically at zero.

The primary extended theorem proves the unconditional `lintegral` inequality.  The contracted
theorem `rightMarginalValue_superharmonic` assumes only that the left marginal is finite and
exposes almost-everywhere continuation finiteness, Bochner integrability of `toReal`, and the
real integral inequality.

**Actual assumptions and dependencies.** BASIC only.  The proof uses H04's canonical Bellman
optimizer and H08's concave right-secant limits, including its separate extended boundary
limit.  Positivity of beta and gross return comes from `HouseholdPrimitives`.  There is no
`beta*R<1`, consumption-positivity, smoothness, Inada, nondegeneracy, stationarity, invariant
law, or bounded-asset premise.  The state is all `NNReal`, and the labor law is the original
general compactly supported probability law.

**Readable proof.** Fix a state `z`, its canonical shifted saving `A(z)`, and `h>0`.  At state
`z+h`, choose shifted saving `A(z)+h`.  It is feasible because `A(z)<=z`, and it preserves
current consumption exactly.  Bellman optimality therefore gives
$$
 V(z+h)-V(z)\geq\beta\int
 [V(RA(z)+e(\ell)+Rh)-V(RA(z)+e(\ell))],d\nu(\ell).
$$
The finite-h integrands are continuous and integrable.  Divide by `h`; rewriting each
continuation quotient as a secant introduces the exact positive factor `R`:
$$
 S(z,z+h)\geq\beta R\int S(x(\ell),x(\ell)+Rh),d\nu(\ell),
 \qquad x(\ell)=RA(z)+e(\ell).
$$
Every secant is nonnegative by strict increase of value, so the proved finite-h real integral
identity can be converted to a `lintegral` without assigning economic meaning to an unproved
marginal integral.

Take `h_n=1/(n+1)`.  Concavity makes the nonnegative continuation secants increase pointwise
as `n` increases.  At a positive continuation state H08 identifies their limit with
`ofReal(q)`; at a zero continuation state it identifies the limit with the separate
`zeroRightMarginal`.  Mathlib's monotone convergence theorem for `lintegral` therefore gives
$$
 \operatorname{ofReal}(\beta R)\int^- \bar q(RA(z)+e(\ell)),d\nu(\ell)
 \leq \bar q(z),
$$
where `bar q` denotes `extendedRightMarginalValue`.  This theorem holds even if either side is
infinite.

If `bar q(z)<infinity`, positivity of beta and `R` makes the extended continuation integral
finite.  Measurability plus this finite `lintegral` proves `bar q(x(ell))<infinity` almost
everywhere and integrability of its `toReal`.  Only then does `integral_toReal` identify the
real integral with the extended integral's finite real value and yield
$$
 \beta R\int \bar q(RA(z)+e(\ell)).\mathrm{toReal}\,d\nu(\ell)
 \leq \bar q(z).\mathrm{toReal}.
$$
At positive `z`, H08 makes the right side exactly the finite real `q(z)`.  At zero, the premise
and conclusion continue to refer to `zeroRightMarginal`.

**Source correspondence.** CW00 motivates the value-marginal supermartingale inequality in
its overview, printed p. 367 / PDF p. 3, and states the corresponding conditional right-value-
derivative inequality in Lemma 1(a), printed p. 372 / PDF p. 8.  The paper calls the proof
standard and omits it; the Lean proof
is the new secant/monotone-convergence construction required by architecture section 4.1, not
a formalization of a literal numbered Aiyagari theorem.

**Exact elaborated contract signature.** The full kernel print, including the extended
prerequisite theorem, is also in the M03B1 signature report and probe.

```text
Aiyagari1994.rightMarginalValue_superharmonic
  (m : Aiyagari1994.HouseholdPrimitives)
  (z : Aiyagari1994.Resources)
  (hz : Aiyagari1994.extendedRightMarginalValue m z < ⊤) :
  Filter.Eventually
    (fun l : m.income.Labor =>
      Aiyagari1994.extendedRightMarginalValue m
        (m.prices.nextResources (Aiyagari1994.assetPolicy m z) l) < ⊤)
    (Measure.ae (m.income.law : Measure m.income.Labor)) ∧
  MeasureTheory.Integrable
    (fun l : m.income.Labor =>
      (Aiyagari1994.extendedRightMarginalValue m
        (m.prices.nextResources (Aiyagari1994.assetPolicy m z) l)).toReal)
    (m.income.law : Measure m.income.Labor) ∧
  m.beta * m.prices.grossReturn * ∫ l : m.income.Labor,
      (Aiyagari1994.extendedRightMarginalValue m
        (m.prices.nextResources (Aiyagari1994.assetPolicy m z) l)).toReal
      ∂(m.income.law : Measure m.income.Labor) ≤
    (Aiyagari1994.extendedRightMarginalValue m z).toReal
'Aiyagari1994.rightMarginalValue_superharmonic' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

**Audit result.** The contracted declaration and every new public helper are checked by
`Audit.lean` with `#check`, `assert_no_sorry`, and `#print axioms`.  The transitive axiom output
contains only `propext`, `Classical.choice`, and `Quot.sound`.  Kernel checking is complete. H09 passed independent Astra review and is GREEN; see
`reviews/m03b1_acceptance.md` and `reviews/m03b1_acceptance.json`. All qualifications in that
acceptance, including the finite-left boundary qualification, remain in force.

## H10 — Consumption positive subcritical
**Status:** GREEN. Independent Astra acceptance: `reviews/m03b2_acceptance.md`.

**Scope:** core. **Milestone:** 03. **Review gate:** M03B2.

- **Target declaration:** `Aiyagari1994.consumption_positive_subcritical`.
- **Module:** `Aiyagari1994/Household/ConsumptionPositive.lean`.

**Mathematical contract.** If beta\*R<1, then c(z)>0 at every z>0, allowing either a finite or infinite right marginal of U at zero.

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H08. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Exact state-space and boundary interface.** The theorem quantifies over every positive
`z : Resources` on the continuous `NNReal` state space.  The new object
`utilityZeroRightMarginal m : ENNReal` is the supremum of nonnegative utility secants from
zero and may equal infinity.  This is distinct from the accepted value boundary object
`zeroRightMarginal m : ENNReal`.  The proof never evaluates `rightMarginalValue m 0` and does
not identify the right marginal of value with the right marginal of utility at a corner.

**Actual and transitive economic assumptions.**

The public signature takes
`m : HouseholdPrimitives`, `UtilitySmooth m.utility`, and the strict impatience premise
`m.beta * m.prices.grossReturn < 1`.  Thus the exposed profiles are exactly BASIC, SMOOTH,
and IMPATIENT.  The mathematical proof uses BASIC's bounded continuous strictly increasing
strictly concave utility, positive beta and return, H04's constructed canonical optimizer,
H08's finite positive-state right value marginal, and IMPATIENT.  Smoothness is retained in
the contracted interface for the source theorem family, although the secant proof establishes
this positivity conclusion without differentiating utility.  No curvature, nondegeneracy,
income density or atom, positive minimum effective income, stationarity, asset bound, or
integrability of a marginal expectation is assumed.  H09 is accepted but is not needed by
this proof; the manifest dependencies remain exactly H04 and H08.

**Readable proof.** Define the zero utility marginal by
$$
 L_0=\sup_{h>0}\operatorname{ofReal}
       \frac{U(h)-U(0)}h\in[0,\infty].
$$
Strict increase makes $L_0>0$, while concavity makes the secants antitone in $h$ and gives
their extended-real limit $L_0$ as $h\downarrow0$.

First suppose $L_0<\infty$ and write $L=L_0.\mathrm{toReal}$.  Concavity bounds every
economic-domain utility increment by $L(y-x)$.  Starting from the zero function, finite-horizon
induction proves that the Bellman operator preserves the same ordered Lipschitz bound whenever
$\beta R\leq1$.  If the optimizer at the larger state is feasible at the smaller state, keep
that action fixed.  Otherwise use the smaller state's consume-zero action: the resource
increment splits between current consumption and additional saving, whose discounted
continuation contribution is bounded by $\beta R L$ and hence by $L$.  Uniform convergence of
Bellman iterates passes the bound to the canonical value function and integration passes it to
the continuation value.

If $c(z)=0$, then H04's budget identity gives $A(z)=z$.  For $0<h\leq z$, choosing $z-h$
instead yields current consumption $h$.  Optimality and the continuation Lipschitz bound imply
$$
 \frac{U(h)-U(0)}h\leq\beta R L.
$$
Taking the extended secant limit gives $L\leq\beta R L$, contradicting $L>0$ and
$\beta R<1$.

If $L_0=\infty$, retain saving $A(z)=z$ at the larger state $z+h$.  This consumes the entire
increment without changing continuation value, so
$$
 \frac{U(h)-U(0)}h\leq\frac{V(z+h)-V(z)}h.
$$
The left side tends to infinity in `ENNReal`; H08 identifies the right side's limit with the
finite positive-state `rightMarginalValue m z`.  This is impossible.  This branch uses neither
a real conversion of the infinite endpoint marginal nor an integral.

**Exact elaborated contract signature.** Full helper signatures and kernel prints are in
`reports/m03b2_signatures.md` and `Probes/M03B2Signatures.lean`.

```text
Aiyagari1994.consumption_positive_subcritical
  (m : Aiyagari1994.HouseholdPrimitives)
  (_hsmooth : Aiyagari1994.UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1)
  (z : Aiyagari1994.Resources) :
  0 < z → 0 < Aiyagari1994.consumptionPolicy m z
'Aiyagari1994.consumption_positive_subcritical' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

**Source correspondence.** A93 Appendix Proposition 2(a), printed p. 37 through the first
line of printed p. 38 / PDF pp. 38-39, states positive consumption and gives the source's
concavity case argument.  A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10, give the
Bellman problem, shifted saving policy and resource transition.  The finite/infinite endpoint
split and finite-horizon Lipschitz construction are the explicit reconstruction required by
architecture section 4.2; no lifetime or later envelope/Euler conclusion is claimed here.

**Audit result.** The contracted theorem and every new public helper are checked in
`Audit.lean` by `#check`, `assert_no_sorry`, and `#print axioms`.  The only transitive Lean
axioms are `propext`, `Classical.choice`, and `Quot.sound`, inherited from the canonical Bellman
construction.  Kernel checking supports REVIEW_READY only; no economic adequacy or GREEN
status is self-awarded.

## H11 — Value envelope at positive consumption

**Status:** GREEN. Independent Astra acceptance: `reviews/m03b3_acceptance.md`.

**Scope:** core. **Milestone:** M03B3.

**Target declaration:** `Aiyagari1994.value_envelope_at_positive_consumption`.  
**Module:** `Aiyagari1994/Household/Envelope.lean`.

**Mathematical contract.** For every canonical household model, positive resource state $z$, and positive canonical consumption $c(z)$, the real extension of $V$ has derivative $U'(c(z))$ at $z$. Its previously constructed positive-state right marginal therefore equals the same utility derivative. The theorem is local and has no $\beta R<1$ premise.

**Actual and transitive economic assumptions.** `HouseholdPrimitives m` supplies BASIC: $0<\beta<1$, bounded continuous strictly increasing and strictly concave utility on nonnegative consumption, a general compact positive labor support and probability law, $R>0$, $w>0$, and nonnegative effective income. `UtilitySmooth m.utility` supplies SMOOTH: $C^1$ regularity and a positive derivative on strictly positive consumption. The local hypotheses are `0 < z` and `0 < consumptionPolicy m z`. No IMPATIENT, CURVATURE, atom, density, nondegeneracy, stationary-law, asset-bound, endpoint-derivative, or consumption-positivity theorem is assumed.

**Dependencies:** H03, H04, H08. **Source keys:** BS79, A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; BS79 Lemma 1, printed p. 728 / PDF p. 3.

**Exact elaborated signatures.** Lean reports:

```text
Aiyagari1994.concave_hasDerivAt_of_lowerTouching {S : Set ℝ} {f g : ℝ → ℝ} {x d : ℝ}
  (hf : ConcaveOn ℝ S f) (hx : x ∈ interior S) (hg : HasDerivAt g d x)
  (heq : g x = f x) (htouch : ∀ᶠ (y : ℝ) in nhds x, g y ≤ f y) : HasDerivAt f d x

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

**Readable proof.** The generic one-dimensional lemma constructs the finite right derivative of a concave real function at an interior point from its right secants. Concavity orders every left secant above that right derivative. Because the differentiable function touches from below and agrees at the point, its right secants lie below the concave function's right secants, while the concave function's left secants lie below the touching function's left secants. Taking limits identifies the right derivative with the touching derivative and squeezes the left secants to the same value. The two one-sided secant limits give an ordinary derivative.

For the economic wrapper, fix the actual shifted optimizer $A(z)$ and define
$W(x)=U(x-A(z))+\beta\,\mathrm{continuation}(A(z))$. Positive consumption gives $A(z)<z$, so on the open neighborhood $x>A(z)$ the action remains feasible and its consumption remains strictly positive. H04 optimality gives $W(x)\leq V(x)$ there and equality at $z$. SMOOTH differentiates $W$ with derivative $U'(c(z))$. H03 concavity and the lower-touching lemma yield the full derivative of the value extension. Uniqueness of the right secant limit identifies H08's `rightMarginalValue` with that derivative.

**Boundary and integrability audit.** H11 is stated only at positive $z$ and positive $c(z)$. It never evaluates `rightMarginalValue m 0` and never uses or alters the distinct `zeroRightMarginal : ENNReal`. The continuation term is constant as $x$ varies; no differentiation under an integral and no marginal expectation occurs. Its underlying bounded value integral is the already-integrable H01 continuation object, so no new real-integral economic interpretation is made.

**Source correspondence.** A93 Appendix Proposition 2(c), printed pp. 37-38 / PDF pp. 38-39, states the envelope equality and explicitly attributes it to Benveniste–Scheinkman. BS79 Lemma 1, printed p. 728 / PDF p. 3, gives the differentiable lower-touching criterion for a concave value function. The Lean helper proves the required one-dimensional version directly from left/right secants rather than importing the paper as an axiom.

**Audit result.** Both new exported declarations are checked in `Audit.lean` with `#check`, `assert_no_sorry`, and `#print axioms`. Their transitive Lean axioms are exactly `propext`, `Classical.choice`, and `Quot.sound`; the economic theorem inherits choice from the canonical optimizer/fixed point. At the M03B3 REVIEW_READY submission boundary, kernel checking alone did not certify economic adequacy or GREEN status. Subsequent independent Astra review accepted H11; see `reviews/m03b3_acceptance.md`.

## H12 — Euler subcritical
**Status:** GREEN. Independent Astra acceptance: `reviews/m03c_acceptance.md`.

**Scope:** core. **Milestone:** M03C.

**Target declaration:** `Aiyagari1994.euler_subcritical`.  
**Module:** `Aiyagari1994/Household/Euler.lean`.

**Exact signature (abridged only by notation).** For `m : HouseholdPrimitives`,
`hsmooth : UtilitySmooth m.utility`, `hbetaR : m.beta * m.prices.grossReturn < 1`,
`z : Resources`, and `hz : 0 < z`, `euler_subcritical` proves: (i) the conditional
`eulerNextMarginal` is finite almost everywhere; (ii) its real conversion is integrable; (iii)
`beta * R * integral eulerNextMarginal.toReal <= deriv U (c z)`; and (iv), if
`0 < assetPolicy m z`, ordinary next-period marginal utility is integrable, agrees pointwise with
the explicit extended marginal, and the preceding inequality is an equality. The complete
elaborated signature is in `reports/m03c_signatures.md`.

`eulerNextMarginal m x : ENNReal` is `zeroRightMarginal m` when `x=0` and
`ENNReal.ofReal (deriv U (c x))` when `x>0`. Thus the conditional expectation has an explicit
economic boundary object and never uses `rightMarginalValue m 0` or a default real derivative at
zero.

**Actual and transitive economic assumptions.** BASIC is carried by `HouseholdPrimitives`:
$0<\beta<1$, bounded continuous strictly increasing and strictly concave utility on nonnegative
consumption, a compact positive labor support with a probability law, $R>0$, and nonnegative
effective income. H12 adds SMOOTH (`UtilitySmooth`) and IMPATIENT (`beta*R<1`). It also quantifies
over a positive state. Interior equality adds only `0 < assetPolicy m z`. There is no curvature,
nondegeneracy, density, atom, positive income floor, stationary law, or bounded-asset assumption.

**Dependencies:** H09, H10, H11. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 2, printed pp. 37-38 / PDF pp. 38-39; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10. Lifetime and parameter details are reconstructed explicitly.

**Readable proof.** H10 makes current consumption positive, and H11 identifies the finite
positive-state value marginal with current marginal utility. H09 first supplies its unconditional
`ENNReal` superharmonic inequality; finiteness of the positive current marginal then proves the
conditional `lintegral` finite and only afterward yields a real integrable conditional marginal.
The pointwise bridge `eulerNextMarginal_eq_extendedRightMarginalValue` rewrites this certified H09
expectation into H12's utility marginal at positive next states while retaining
`zeroRightMarginal` at a zero next state.

For positive shifted savings, every next resource is at least $RA(z)>0$. The assigned
positive-asset continuation helper works on the common neighborhood
$a>A(z)/2$: concavity bounds every absolute continuation derivative by the constant
$R q(RA(z)/2)$, which is integrable under the probability law. Differentiation under the
integral therefore proves both conditional marginal-utility integrability and the derivative
$R\mathbb E U'(c(z'))$. Since H10 and H11 apply to every positive next state, no endpoint
derivative enters this branch. The canonical optimizer is locally interior because both savings
and consumption are positive. Fermat's theorem applied to the actual Bellman objective gives the
Euler equality.

**Boundary and integrability audit.** `zeroRightMarginal : ENNReal` remains the sole value
marginal at zero resources and may be infinite. The public theorem exposes its almost-everywhere
finiteness under the particular conditional law before calling `.toReal`; the associated real
integrability certificate is returned before the real integral inequality. In the equality branch,
positive savings rules out zero next resources pointwise and ordinary marginal utility receives a
separate `Integrable` certificate.

**Source correspondence.** A93 Appendix Proposition 2(c), printed pp. 37-38 / PDF pp. 38-39,
states the envelope/Euler inequality and equality for positive next assets. A94 equations (5)-(7),
printed pp. 666-667 / PDF pp. 9-10, record the Bellman objective, shifted asset policy, and next
resource transition used here. Both exact page ranges were hash-verified, rendered, and visually
inspected. The conditional integrability and explicit zero-state reconstruction are formal
qualifications supplied by this project rather than assumptions imported from the papers.

**Audit result.** All six M03C exports pass `assert_no_sorry`. Their printed transitive axioms are
exactly `propext`, `Classical.choice`, and `Quot.sound`. At the M03C REVIEW_READY submission boundary, kernel checking alone did not certify economic adequacy or GREEN status. Subsequent independent Astra review accepted H12; see `reviews/m03c_acceptance.md`.

## H13 — Binding interval exists
**Status:** GREEN. Independent Astra acceptance: `reviews/m03d_acceptance.md`.

**Scope:** core. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.binding_interval_exists`.  
**Module:** `Aiyagari1994/Household/BorrowingThreshold.lean`.

**Mathematical contract.** Under beta\*R<1 and either e_min>0 or finite U_right_prime(0), there exists zHat>e_min with A(z)=0 for every z in [e_min,zHat].

**Assumption profiles:** BASIC, SMOOTH, IMPATIENT, THRESHOLD. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H08, H10, H12. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 3 and the following note, printed p. 38 / PDF p. 39; A94 threshold discussion, printed p. 667 / PDF p. 10.

**Exact signature.** The formal endpoint is
`minimumEffectiveIncome m : Resources`, the effective income at the lower labor endpoint. The
contract theorem is
```text
binding_interval_exists
  (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
  (hbetaR : m.beta * m.prices.grossReturn < 1)
  (hthreshold : Or (0 < minimumEffectiveIncome m)
    (utilityZeroRightMarginal m < OrderTop.top)) :
  Exists fun zHat : Resources =>
    And (minimumEffectiveIncome m < zHat)
      (forall z : Resources, minimumEffectiveIncome m <= z -> z <= zHat ->
        assetPolicy m z = 0)
```

**Actual and transitive economic assumptions.** `HouseholdPrimitives` supplies BASIC: bounded,
continuous, strictly increasing and strictly concave utility; positive beta below one; a general
probability law on fixed compact positive labor support; positive wage and gross return; and
nonnegative affine effective income. `UtilitySmooth` supplies SMOOTH. The strict inequality
`beta*R<1` is IMPATIENT. THRESHOLD is the displayed disjunction: either the derived minimum
effective income is positive or the separate utility endpoint marginal
`utilityZeroRightMarginal : ENNReal` is finite. There is no curvature, density, atom,
nondegeneracy, stationarity, compact asset bound, consumption-positivity premise, or assumed
policy threshold. H10 derives consumption positivity. H08 and H12 supply the marginal facts.

**Readable proof.** Let `e_min` be minimum effective income and let `Q` be its extended value
marginal, using `zeroRightMarginal` when `e_min = 0` and the finite positive-state marginal
otherwise. If `e_min > 0`, H08 makes `Q` finite. If `e_min = 0` and the utility endpoint marginal
is finite, H10's finite-horizon Lipschitz construction proves the global value increment bound.
Applying that bound to every secant from zero gives
`zeroRightMarginal <= utilityZeroRightMarginal < infinity`. Thus in either branch
`0 < Q < infinity`.

Suppose `A(z) > 0`. H10 makes current and next consumption positive. H12 first proves the next
marginal-utility integrand is integrable and then gives the interior Euler equality. Every next
resource satisfies `R*A(z) + e(l) >= e_min`. H08's antitonicity therefore bounds each next value
marginal by `Q`. H11 identifies these positive-state value marginals with marginal utility, so
integration and the Euler equality yield `q(z) <= beta*R*Q`. No real integral is used until H12's
integrability certificate is available.

Since `0 < beta*R < 1`, `beta*R*Q < Q`. When `e_min > 0`, H08's genuine right continuity gives a
right neighborhood of `e_min` on which `q(z) > beta*R*Q`. When `e_min = 0`, H08's convergence of
positive-state marginals to the separate finite `zeroRightMarginal : ENNReal` gives the same
strict inequality on a punctured right neighborhood. Hence an interior choice is impossible
there. At `e_min = 0`, `assetPolicy_zero` handles the endpoint. At `e_min > 0`, the interior upper
bound applied at `e_min` itself contradicts `Q <= beta*R*Q`, so the endpoint also binds.
Choosing a smaller positive neighborhood endpoint produces the required `zHat` and establishes
`A(z)=0` throughout the closed interval.

**Boundary and integrability audit.** The proof never evaluates `rightMarginalValue m 0`.
`zeroRightMarginal : ENNReal` is the sole value marginal at zero and may be infinite before the
THRESHOLD branch proves it finite. `utilityZeroRightMarginal` is a distinct utility endpoint
object. The only new economic real integral is inherited through H12 together with its explicit
integrability proof.

**Source correspondence.** A93 Appendix Proposition 3, printed p. 38 / PDF p. 39, states the
qualified threshold and argues from the interior marginal equality, monotonicity, and
`beta*R<1`. A94 printed p. 667 / PDF p. 10 records the shifted policy, transition, and threshold
discussion. Both approved pages were hash-verified, rendered, and visually inspected. The formal
proof reconstructs the endpoint finiteness and neighborhood argument; it does not certify the
unqualified Inada note following Proposition 3.

**Audit result.** Both M03D exports pass `assert_no_sorry`. Their printed transitive axioms are
exactly `propext`, `Classical.choice`, and `Quot.sound`. At the M03D REVIEW_READY submission boundary, kernel checking alone did not certify economic adequacy or GREEN status. Subsequent independent Astra review accepted H13; see `reviews/m03d_acceptance.md`.

## H14 — Zero income atom implies nonbinding
**Status:** GREEN. Independent Astra acceptance: `reviews/m03e_acceptance.md`. **Scope:** diagnostic. **Milestone:** 03.

**Target declaration:** `Aiyagari1994.zero_income_atom_implies_nonbinding`.  
**Module:** `Aiyagari1994/Household/BorrowingThreshold.lean`.

**Mathematical contract.** If e_min=0, U has Inada marginal at zero, and Pr(e=0)>0, then A(z)>0 for every z>0. No impatience assumption is needed for this sufficient condition.

**Actual assumptions.** BASIC is carried by `HouseholdPrimitives`. The public signature separately assumes `UtilitySmooth`, `minimumEffectiveIncome m = 0`, `utilityZeroRightMarginal m = ⊤`, and positive probability of the measurable zero-effective-income event. There is no impatience, curvature, density, nondegeneracy, consumption-positivity, stationarity, or asset-bound premise. Smoothness and the explicit minimum-income equality are retained as contract premises; the proof itself needs only BASIC, utility Inada, and the atom.

**Dependencies:** H03, H04, H08. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 3 and the following note, printed p. 38 / PDF p. 39; A94 threshold discussion, printed p. 667 / PDF p. 10.

**Exact elaborated signatures and transitive axioms:**

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
'Aiyagari1994.zero_income_atom_implies_nonbinding' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

**Readable proof.** First, for every $h>0$, choosing zero shifted saving at resource state $h$ and comparing with the forced zero action at state zero gives

$$U(h)-U(0)\leq V(h)-V(0).$$

Passing to the already-constructed ENNReal secant limits shows
`utilityZeroRightMarginal m ≤ zeroRightMarginal m`; Inada therefore implies
`zeroRightMarginal m = ⊤` inside the H14 proof.

Fix $z>0$ and suppose, for contradiction, that $A(z)=0$. Let $p>0$ be the real probability of the event $E=\{e=0\}$. Concavity and strict increase of utility give a finite positive bound
$C=\operatorname{slope}(U;z/2,z)$ on the current-utility cost per unit of any deviation
$0<a<z/2$. Since the zero-state value secants converge to infinity, choose $x>0$ so small that
$a=x/R<z/2$ and

$$\operatorname{slope}(V;0,x)>\frac{C}{\beta pR}+1.$$

The bounded value function makes both continuation-value integrands integrable. Their difference is nonnegative for every labor realization by monotonicity of $V$, and on $E$ it equals $V(x)-V(0)$. Integrating the indicator lower bound yields

$$p[V(x)-V(0)]\leq G(a)-G(0).$$

Optimality of the assumed zero action and the utility secant bound then imply

$$\beta pR\,\operatorname{slope}(V;0,x)\leq C,$$

contradicting the choice of $x$. Hence $A(z)>0$ for every positive state.

**Boundary and integrability audit.** The economic zero-state object is exclusively
`zeroRightMarginal : ENNReal`; the proof never evaluates `rightMarginalValue m 0`. It takes no
real integral of a marginal. The only real integrals are finite continuation-value differences;
their integrability is proved before `integral_mono` is used. The atom event is measurable because
effective income is continuous, and its ENNReal probability is converted to a positive real only
after its finiteness under the probability law is proved.

**Source correspondence.** A93 Appendix Proposition 3 and its following note, printed p. 38 /
PDF p. 39, state the qualified binding result and then the unqualified Inada/zero-minimum-income
nonbinding note. A94 printed p. 667 / PDF p. 10 records the shifted policy, transition, and
threshold discussion. Both approved pages were hash-verified, rendered, and visually inspected.
H14 proves the architecture's corrected atom-sufficient statement; it does not validate the
unqualified note without an atom or certify D01.

**Audit result.** The M03E export passes `assert_no_sorry`; its printed transitive axioms are
exactly `propext`, `Classical.choice`, and `Quot.sound`. At the M03E REVIEW_READY submission boundary, kernel checking alone did not certify economic adequacy or GREEN status. Subsequent independent Astra review accepted H14; see `reviews/m03e_acceptance.md`.

## D01 — Inada without atom binding example
**Status:** GREEN. Independent Astra acceptance: `reviews/m03f_acceptance.md`.

**Scope:** diagnostic. **Milestone:** 03F.

**Target declaration:** `Aiyagari1994.inada_without_atom_binding_example`.  
**Module:** `Aiyagari1994/Diagnostics/InadaCounterexample.lean`.

**Mathematical contract.** In the exact continuous-state uniform-income model in EXACT_DIAGNOSTIC, all core primitive conditions hold and A(z)=0 whenever 0<z<=1/100, despite Inada and e_min=0.

**Actual and transitive assumptions.** The theorem has no arguments: it constructs the
EXACT_DIAGNOSTIC witness. Its definitions fix $\beta=1/2$, $R=w=3/2$, $r=1/2$, $\phi=2$,
labor as the continuous pushforward of uniform $e\in[0,1]$ under
$\ell=2/3+(2/3)e$, and $U(c)=\sqrt c/(1+\sqrt c)$. The returned
`CoreRegularity` proof supplies BASIC, SMOOTH, CURVATURE, NONDEGENERATE, and labor mean one.
No consumption-positivity, impatience premise, atom, stationarity, compact asset bound, or
numerical-grid premise occurs.

**Dependencies:** H02, H03, H04. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 3 and the following note, printed p. 38 / PDF p. 39; A94 threshold discussion, printed p. 667 / PDF p. 10.

**Exact elaborated signature and transitive axioms:**

```text
Aiyagari1994.inada_without_atom_binding_example :
  CoreRegularity exactDiagnosticModel ∧
  exactDiagnosticOriginalPrices.netRate = 1 / 2 ∧
  exactDiagnosticOriginalPrices.wage = 3 / 2 ∧
  exactDiagnosticOriginalPrices.debtLimit = 2 ∧
  exactDiagnosticModel.beta = 1 / 2 ∧
  exactDiagnosticModel.prices.grossReturn = 3 / 2 ∧
  (∀ l, exactDiagnosticModel.prices.effectiveIncome l = 3 / 2 * (l : ℝ) - 1) ∧
  Measure.map (fun l => exactDiagnosticModel.prices.effectiveIncome l)
    exactDiagnosticIncome.law = volume.restrict (Set.Icc 0 1) ∧
  exactDiagnosticModel.prices.effectiveIncome exactDiagnosticLowerLabor = 0 ∧
  (Measure.map (fun l => exactDiagnosticModel.prices.effectiveIncome l)
    exactDiagnosticIncome.law) {0} = 0 ∧
  exactDiagnosticUtility.utility 0 = 0 ∧
  (∀ c : ℝ, 0 < c → deriv exactDiagnosticUtility.utility c =
    exactDiagnosticMarginal c) ∧
  Tendsto exactDiagnosticMarginal (nhdsWithin 0 (Set.Ioi 0)) atTop ∧
  (∀ z, 0 ≤ valueFunction exactDiagnosticModel z ∧
    valueFunction exactDiagnosticModel z ≤ 2) ∧
  (∀ z, 0 < z → z ≤ (1 / 100 : Resources) →
    assetPolicy exactDiagnosticModel z = 0)
'Aiyagari1994.inada_without_atom_binding_example' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

**Readable proof.** Direct differentiation on $c>0$ gives

$$U'(c)=\frac{1}{2\sqrt c(1+\sqrt c)^2},\qquad
-\frac{cU''(c)}{U'(c)}=\frac12+\frac{\sqrt c}{1+\sqrt c}<\frac32.$$

The displayed derivative tends to infinity from the right. The affine labor construction sends
uniform $e\in[0,1]$ exactly to labor uniform on $[2/3,4/3]$, has mean one, and sends effective
income back to $e$. Hence effective income is uniform on $[0,1]$, its minimum is zero, and zero
has probability zero.

The accepted Bellman bounds, together with $0\leq U<1$ and $\beta=1/2$, give
$0\leq V\leq2$. Continuity makes every continuation integrand integrable before its real
integral is used. After the proved pushforward and interval-integral changes of variables,

$$G(a)=\int_0^1V(3a/2+e)\,de.$$

A generic moving-endpoint fundamental-theorem lemma proves the exact identity

$$G'_+(0)=\frac32[V(1)-V(0)].$$

The sliding-interval identity and $0\leq V\leq2$ yield
$G(a)-G(0)\leq3a$. Thus the discounted continuation gain is at most $3a/2$.
For $0<z\leq1/100$, the exact formula gives $U'(z)>3/2$. Concavity of $U$ therefore gives
$U(z-a)+(3/2)a\leq U(z)$ for every $0\leq a\leq z$. Combining the inequalities shows that the
Bellman objective at any feasible $a$ is no larger than at zero. The accepted uniqueness of the
canonical maximizer then proves $A(z)=0$ throughout the stated interval.

**Boundary and scope audit.** The proof never uses `rightMarginalValue`, at zero or elsewhere;
in particular it does not replace the economic `zeroRightMarginal : ENNReal`. No expected
marginal is represented by a real integral. Assets and income are continuous, and the result is
an exact analytic witness rather than a computation or finite-grid certificate.

**Source correspondence and adequacy note.** A93 Appendix Proposition 3 and its following note,
printed p. 38 / PDF p. 39, and A94's threshold discussion, printed p. 667 / PDF p. 10, were
hash-verified, rendered, and visually inspected. D01 is a proposed correction to the unqualified
note after Proposition 3, not to Proposition 3 itself. At the M03F REVIEW_READY submission boundary, kernel checking alone did not certify the counterexample or its source-correction interpretation. Subsequent independent Astra review accepted D01, including the compatibility of the continuous atom-free witness with A93's maintained assumptions and the qualified correction to the unqualified note after Proposition 3; see `reviews/m03f_acceptance.md`.

## D02 — Marginal Utility ratio bound
**Status:** GREEN. Independent Astra acceptance: `reviews/m04b_acceptance.md`. **Scope:** core. **Milestone:** 04.

**Target declaration:** `Aiyagari1994.marginalUtility_ratio_bound`.  
**Module:** `Aiyagari1994/Analysis/Curvature.lean`.

**Kernel-checked statement.** For every `m : HouseholdPrimitives` with
`hs : UtilitySmooth m.utility` and `hc : UtilityCurvature m.utility`, there are a positive
integer `n` and a positive real threshold `C` such that, whenever `C ≤ c1 ≤ c2`,
\[
  \frac{U'(c_1)}{U'(c_2)}\leq\left(\frac{c_2}{c_1}\right)^n.
\]

The exact public signature is:

```text
Aiyagari1994.marginalUtility_ratio_bound (m : HouseholdPrimitives)
  (hs : UtilitySmooth m.utility) (hc : UtilityCurvature m.utility) :
  ∃ n : ℕ, 0 < n ∧ ∃ C > (0 : ℝ), ∀ {c1 c2 : ℝ},
    C ≤ c1 → c1 ≤ c2 →
      deriv m.utility.utility c1 / deriv m.utility.utility c2 ≤ (c2 / c1) ^ n
```

**Actual and transitive economic assumptions.** `HouseholdPrimitives m` supplies BASIC, while
`UtilitySmooth m.utility` supplies a strictly positive first derivative on positive consumption
and `UtilityCurvature m.utility` supplies $C^2$ regularity on positive consumption together with
an eventual finite upper bound on $-cU''(c)/U'(c)$. The proof uses no impatience, income
nondegeneracy, atom, density, invariant-law, bounded-state, policy, envelope, Euler, or endpoint
differentiability assumption. BASIC's utility and income fields enter the contracted wrapper but
are not needed by the reusable analytic helper.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** SE77, A93.

**Source locator:** A93 Appendix Proposition 4, printed pp. 38-39 / PDF pp. 39-40; SE77 Theorems 3.8-3.9, printed pp. 161-162 / PDF pp. 11-12.

**Readable proof.** Take the curvature witnesses $C>0$ and $M\in\mathbb R$, and use the
Archimedean property to choose a positive integer $n>\max\{M,0\}$. For $c>C$, positivity of
$U'(c)$ lets the RRA inequality be rearranged to
\[
  0\leq nU'(c)+cU''(c).
\]
Consequently
\[
  \frac{d}{dc}\bigl(c^nU'(c)\bigr)
  =c^{n-1}\bigl(nU'(c)+cU''(c)\bigr)\geq0.
\]
Continuity at the threshold and differentiability on its interior make $c^nU'(c)$ nondecreasing
on $[C,\infty)$. Thus $c_1^nU'(c_1)\leq c_2^nU'(c_2)$ for
$C\leq c_1\leq c_2$. Since $c_1,c_2,U'(c_1),U'(c_2)$ are positive, division gives the stated
ratio bound.

The reusable helper `power_mul_deriv_monotoneOn` states the intermediate monotonicity result. It
is confined to the authorized helper file `Analysis/M04B/PowerMarginal.lean`.

**Boundary, source, and adequacy note.** This is a positive-consumption analytic statement. It
does not evaluate `rightMarginalValue m 0`, replace `zeroRightMarginal`, form a real expected
marginal integral, or derive D03's drift and invariant interval. The proof implements the
authorized Architecture §6.2 reconstruction corresponding to A93 Appendix Proposition 4,
printed pp. 38–39 / PDF pp. 39–40, and SE77 Theorems 3.8–3.9, printed pp. 161–162 / PDF
pp. 11–12. The source pages were not re-inspected for this gate; source correspondence relies on
the supplied capsule and accepted repository design. Kernel checks establish formal validity,
not independent mathematical or source adequacy.

**Audit.** `#check`, `assert_no_sorry`, and `#print axioms` cover both new public declarations.
Their transitive axiom output is exactly `propext`, `Classical.choice`, and `Quot.sound`.

## D03 — Uniform upper drift
**Status:** GREEN. Independent Astra acceptance: `reviews/m04c_acceptance.md`. **Scope:** core. **Milestone:** 04.

**Target declaration:** `Aiyagari1994.uniform_upper_drift`.  
**Module:** `Aiyagari1994/Household/UpperDrift.lean`.

**Kernel-checked statement.** Fix the utility, discount factor, compact iid labor law, and a
specified set `Q` of admissible normalized price triples. Assume explicit common bounds
`0<Rmin≤R≤Rmax`, `beta*R≤gammaStar<1`, `e_max≤EStar`, and
`e_max-e_min≤DeltaStar`, with nonnegative `EStar` and `DeltaStar`. Then
`uniform_upper_drift` constructs one real `B>0`, independent of `q∈Q`, such that
`e_max(q)≤B`,
`R(q)*A_q(z)+e_max(q)≤z` whenever `B≤z`, and every transition from
`z∈[e_min(q),B]` remains in `[e_min(q),B]`.

**Actual assumptions.** `HouseholdPrimitives` supplies BASIC. `UtilitySmooth` supplies positive
marginal utility on positive consumption, and `UtilityCurvature` supplies the eventual RRA
bound used through D02. LOCAL_IMPATIENT is represented exactly by the displayed primitive
uniform bounds on the specified set `Q`; no continuity or compactness of `Q`, continuously
selected pointwise cap, income density, atom, nondegeneracy, invariant law, or stationary
integrability premise is added.

**Dependencies:** H07, H08, H10, H12, D02. **Source keys:** SE77, A93.

**Source locator:** A93 Appendix Proposition 4, printed pp. 38-39 / PDF pp. 39-40; SE77 Theorems 3.8-3.9, printed pp. 161-162 / PDF pp. 11-12.

**Readable proof.** D02 gives a positive integer `n` and tail threshold `C0`. Since
`gammaStar<1`, the limit of `gammaStar*(1+DeltaStar/C)^n` as `C` tends to infinity is
`gammaStar`, so choose
`C≥C0` with this expression below one. H08's secant bound and H10/H11's positive-state
envelope identity imply that consumption exceeds `C` above one common resource level `L`.
Choose `K` with `Rmin*K>L` and then `B>Rmax*K+EStar`.

For `z≥B`, if `A_q(z)≤K`, the maximal next resource is at most `B≤z`. Otherwise every
next resource exceeds `L`. H07 bounds the difference between extreme next consumptions by the
income span. D02 therefore bounds every next marginal utility by
`(1+DeltaStar/C)^n` times the marginal at the maximal next state. H12's interior Euler equality
and `beta*R≤gammaStar` make the current marginal strictly smaller than that maximal-next
marginal. H08's positive-state antitonicity then forces the maximal next state below `z`.
Finally H07's monotonicity of `A_q`, together with endpoint income bounds, proves forward
invariance below `B`.

**Boundary and scope audit.** All uses of `rightMarginalValue` occur at proved positive resource
states. The proof never evaluates `rightMarginalValue m 0`; `zeroRightMarginal : ENNReal`
remains the economic boundary object and may be infinite. H07 is used only in its accepted weak
order/Lipschitz form. Weak downward drift is not strengthened to strict drift everywhere and no
finite-time entry, stationary law, tightness, convergence, asset supply, or equilibrium result
is claimed.

**Audit.** All nine new public declarations in the authorized M04C helper and target modules are
covered by `#check`, `assert_no_sorry`, and `#print axioms` in `Audit.lean` and
`Probes/M04CSignatures.lean`. Their transitive axioms are only `propext`, `Classical.choice`, and
`Quot.sound`.

## S01 — Household Kernel feller monotone
**Status:** GREEN. Independent Astra acceptance: `reviews/m05a_acceptance.md`. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.householdKernel_feller_monotone`.  
**Module:** `Aiyagari1994/Stationary/Kernel.lean`.

**Mathematical contract.** The pushforward of nu under l↦R\*A(z)+e(l) is a probability Markov kernel, is Feller, and preserves stochastic order. Establish the kernel test-function integral formula.

**Assumption profiles:** BASIC. These are branch-sensitive context tags; the completed signature must list the actual premises.

**Dependencies:** H04, H07. **Source keys:** A93, SLP89.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Checked statement.** For every household primitive object `m`, `householdKernel m` is a
probability Markov kernel. For every bounded continuous real test `f`, the map
`z ↦ ∫ y, f y ∂ householdKernel m z` is continuous. If such an `f` is nondecreasing, this
map is nondecreasing. More generally, for every measurable real test `f`,
```
∫ y, f y ∂ householdKernel m z
  = ∫ l, f (m.prices.nextResources (assetPolicy m z) l) ∂ m.income.law.
```
The last identity therefore covers the contracted bounded-measurable test class and is slightly
more general at the API level.

**Readable proof.** The authorized helper defines the jointly continuous map
`householdTransition m (z,l) = R*A(z)+e(l)`. Continuity follows from H04's continuity of `A`
and the affine transition. The kernel takes the product of the identity Dirac kernel with the
constant labor-law kernel and maps that product through `householdTransition`; Mathlib's product
and map instances make it Markov. The product-kernel and measure-map formulas reduce integration
against the kernel to integration over the labor law. Dominated continuity, with the uniform
bound supplied by the bounded continuous test, gives the Feller conclusion. For `z1 <= z2`, H07
gives `A(z1) <= A(z2)`; positivity of `R` makes the transition pointwise ordered under the same
labor draw, and integral monotonicity gives stochastic monotonicity.

**Boundary and scope audit.** The construction uses the general compactly supported probability
law in `IncomeData`, not the finite witness. It uses H07 only at weak order strength. It introduces
no differentiability, strict order, crossing, invariant-law, convergence, moment, asset-supply,
or equilibrium claim. It does not use any marginal-value object, so the required distinction
between `zeroRightMarginal` and `rightMarginalValue m 0` is untouched.

\newpage

**Audit.** The six new public declarations are:

- `householdTransition` and `householdTransition_continuous`;
- `householdKernel` and `householdKernel_isMarkov`;
- `householdKernel_integral`; and
- `householdKernel_feller_monotone`.

Each has `#check`, `assert_no_sorry`, and `#print axioms` coverage in `Audit.lean` and the M05A
signature probe. Their transitive axioms are only `propext`, `Classical.choice`, and `Quot.sound`.

## S02 — Lower transition iterates tendsto
**Status:** GREEN. Independent Astra acceptance: `reviews/m05b_acceptance.md`. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.lower_transition_iterates_tendsto`.  
**Module:** `Aiyagari1994/Stationary/LowerTransition.lean`.

**Mathematical contract.** Under beta\*R < 1, h_min(e_min)=e_min, h_min(z) < z for z > e_min, and h_min iterated from any finite upper bound decreases to e_min.

**Actual economic assumptions.** `m : HouseholdPrimitives` supplies BASIC: bounded strictly increasing and strictly concave utility on nonnegative consumption, continuous resources, a general compact iid labor law, positive wage and gross return, and nonnegative effective income. The explicit premises are `hsmooth : UtilitySmooth m.utility` and `hbetaR : m.beta * m.prices.grossReturn < 1`. No density, endpoint atom, finite labor support, nondegeneracy, invariant interval, or upper asset bound is assumed.

**Dependencies:** H04, H08, H12. **Source keys:** A93.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Exact elaborated signature.**

```text
Aiyagari1994.lower_transition_iterates_tendsto
    (m : Aiyagari1994.HouseholdPrimitives)
    (hsmooth : Aiyagari1994.UtilitySmooth m.utility)
    (hbetaR : m.beta * m.prices.grossReturn < 1) :
  Aiyagari1994.lowerTransition m (Aiyagari1994.lowerEffectiveIncome m) =
      Aiyagari1994.lowerEffectiveIncome m ∧
  (∀ z, Aiyagari1994.lowerEffectiveIncome m < z →
      Aiyagari1994.lowerTransition m z < z) ∧
  ∀ B, Aiyagari1994.lowerEffectiveIncome m ≤ B →
    Antitone (fun n ↦ (Aiyagari1994.lowerTransition m)^[n] B) ∧
    Filter.Tendsto (fun n ↦ (Aiyagari1994.lowerTransition m)^[n] B)
      Filter.atTop (nhds (Aiyagari1994.lowerEffectiveIncome m))
```

**Readable proof.** Define `lowerEffectiveIncome` by evaluating affine effective income at the lower endpoint of labor support, and define `lowerTransition z = R*A(z)+e_min`. It is continuous by H04 policy continuity and the affine transition formula, and it always lies weakly above `e_min`.

Suppose at a positive state with positive shifted saving that `z ≤ lowerTransition z`. Every labor realization then gives next resources at least `lowerTransition z`, hence at least `z`. H12 gives the interior Euler equality. H10 supplies positive consumption and H11 identifies its marginal utility with H08's positive-state right value marginal. H08 antitonicity therefore bounds every next marginal by the current strictly positive marginal. Probability normalization bounds the integral by that same marginal. Multiplication by `beta*R < 1` makes the Euler equality strictly smaller than its right side, a contradiction. If saving is zero, the lower transition is exactly `e_min`. Thus it is strictly below every `z>e_min`. At the endpoint, zero saving gives the fixed-point identity directly; positive saving is ruled out by the same Euler contradiction (with `A(0)=0` handling a zero endpoint).

For any `B≥e_min`, every iterate remains above `e_min`, while endpoint fixation and strict drift make the sequence antitone. Its real coercion is bounded below and hence converges. Continuity of the lower transition makes the limit a fixed point. Strict drift excludes every fixed point above `e_min`, so the limit equals `e_min`.

**Boundary and integrability audit.** Euler reasoning is used only at positive current resources and only after positive saving is proved. H12 supplies integrability of the ordinary next marginal under positive saving. The proof never evaluates `rightMarginalValue m 0`; the zero endpoint is handled by `assetPolicy_zero`, preserving `zeroRightMarginal` as the distinct extended boundary object. The convergence is deterministic convergence of the lower-shock transition iterates, not kernel convergence, invariant-law existence, mixing, or moment convergence.

**Audit.** The six new public declarations are:

- `lowerEffectiveIncome`;
- `lowerTransition`;
- `lowerTransition_continuous`;
- `lowerEffectiveIncome_le_lowerTransition`;
- `M05B_lower_transition_iterates_tendsto`; and
- `lower_transition_iterates_tendsto`.

Each has `#check`, `assert_no_sorry`, and `#print axioms` coverage in the global audit and the M05B signature probe. Their transitive axioms are only `propext`, `Classical.choice`, and `Quot.sound`.

**Adequacy note.** The implementation is kernel checked and submitted as REVIEW_READY only. No adequacy certification or GREEN status is self-awarded.

## S03 — Economic crossing condition
**Status:** GREEN. Independent Astra acceptance: `reviews/m05c_acceptance.md`. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.economic_crossing_condition`.  
**Module:** `Aiyagari1994/Stationary/Crossing.lean`.

**Mathematical contract.** On a compact invariant interval, construct $d\in(e_{\min},e_{\max})$, $N\geq1$, and $\varepsilon>0$ with $P^N(e_{\min},[d,B])\geq\varepsilon$ and $P^N(B,[e_{\min},d])\geq\varepsilon$ from endpoint-neighborhood probabilities.

**Actual economic assumptions.** `m : HouseholdPrimitives` supplies BASIC, including the general compact labor law, positive wage and return, and nonnegative effective income. `hsmooth : UtilitySmooth m.utility` and `hbetaR : m.beta * m.prices.grossReturn < 1` are exactly the SMOOTH and IMPATIENT premises inherited through S02. `hnd : IncomeNondegenerate m.income` gives distinct essential endpoints and positive mass in every relative endpoint neighborhood; it requires neither atoms nor a density. IID is implemented by powers of the S01 policy-induced Markov kernel. The local compact-interval premises are `upperEffectiveIncome m ≤ B` and forward invariance of `[lowerEffectiveIncome m,B]` for every labor realization; these are exactly the price-specific consequences supplied by D03's common-bound conclusion. No invariant probability law, mixing theorem, finite labor support, density, endpoint atom, or upper fixed-point uniqueness is assumed.

**Dependencies:** D03, S01, S02. **Source keys:** A93, SLP89.

**Source locator:** A93 Appendix Proposition 5 and proof, printed pp. 39-40 / PDF pp. 40-41; SLP89 Section 12.4. The explicit primitive-to-crossing construction is reconstructed here.

**Exact elaborated signature.**

```lean
Aiyagari1994.economic_crossing_condition
    (m : Aiyagari1994.HouseholdPrimitives)
    (hsmooth : Aiyagari1994.UtilitySmooth m.utility)
    (hnd : Aiyagari1994.IncomeNondegenerate m.income)
    (hbetaR : m.beta * m.prices.grossReturn < 1)
    (B : Aiyagari1994.Resources)
    (hUpperB : Aiyagari1994.upperEffectiveIncome m ≤ B)
    (hInvariant : ∀ z, Aiyagari1994.lowerEffectiveIncome m ≤ z → z ≤ B →
      ∀ l,
        Aiyagari1994.lowerEffectiveIncome m ≤
            m.prices.nextResources (Aiyagari1994.assetPolicy m z) l ∧
          m.prices.nextResources (Aiyagari1994.assetPolicy m z) l ≤ B) :
  ∃ d N eps, Aiyagari1994.lowerEffectiveIncome m < d ∧
    d < Aiyagari1994.upperEffectiveIncome m ∧ 1 ≤ N ∧ 0 < eps ∧
    eps ≤ (Aiyagari1994.householdKernel m ^ N)
      (Aiyagari1994.lowerEffectiveIncome m) (Set.Icc d B) ∧
    eps ≤ (Aiyagari1994.householdKernel m ^ N) B
      (Set.Icc (Aiyagari1994.lowerEffectiveIncome m) d)
```

**Readable proof.** Let $e_{\min}$ and $e_{\max}$ be effective income at the two labor-support endpoints and choose their midpoint $d$. Wage positivity and endpoint distinctness give $e_{\min}<d<e_{\max}$, while the invariant-interval premises give $e_{\min}\leq B$. S02 implies that the iterated minimum-shock transition from $B$ eventually lies below $d$; choose such an $N\geq1$. Continuity of the finite constant-shock path provides a labor endpoint neighborhood whose constant-shock path also lies below $d$. Monotonicity of the canonical asset policy in resources and monotonicity of affine income in labor imply that any sequence of $N$ shocks in that neighborhood ends in $[e_{\min},d]$. NONDEGENERATE gives this neighborhood mass $p_->0$. A kernel-power induction, using the exact S01 pushforward kernel, proves
\[
P^N(B,[e_{\min},d])\geq p_-^N>0.
\]

For the other direction, every transition starting in the invariant interval remains there. A final shock above the labor midpoint gives effective income above $d$, regardless of prior wealth, and the invariant upper bound keeps the next state below $B$. Its mass is $p_+>0$ by upper-endpoint nondegeneracy. Since $N\geq1$, the first $N-1$ transitions stay in the interval with probability one and the last-step kernel bound yields
\[
P^N(e_{\min},[d,B])\geq p_+.
\]
Taking $\varepsilon=\min\{p_-^N,p_+\}$ supplies both inequalities at the same horizon.

**Boundary, probability, and scope audit.** The proof uses no marginal-value object and in particular never evaluates `rightMarginalValue m 0`; all zero-boundary reasoning remains inside accepted S02. Kernel powers, rather than an assumed infinite product, encode the finite iid shock sequence. Every measure in the conclusion is a probability-kernel value, and no real-valued expectation or new integrability claim occurs. The result is only endpoint crossing on the supplied invariant interval. It proves no invariant-law existence or uniqueness, weak or total-variation convergence, moment convergence, stationary integrability, asset supply, or equilibrium.

**Audit.** The three new public declarations are:

```text
upperEffectiveIncome
M05C_economic_crossing_condition
economic_crossing_condition
```

Each has all three required audit commands in the global audit and the dedicated M05C signature probe: `#check`, `assert_no_sorry`, and `#print axioms`. Their transitive axiom output contains only `propext`, `Classical.choice`, and `Quot.sound`.

**Adequacy note.** The implementation is kernel checked and submitted as REVIEW_READY only. No adequacy certification, GREEN status, or later-stage conclusion is self-awarded.

## S04 — Compact monotone feller stability
**Status:** GREEN. Independent Astra acceptance: `reviews/m05d_acceptance.md`. **Scope:** core. **Milestone:** 05.

**Target declaration:** `Aiyagari1994.compact_monotone_feller_stability`.  
**Module:** `Aiyagari1994/Analysis/MonotoneFeller.lean`.

**Mathematical contract.** A monotone Feller kernel on a nonempty compact real interval satisfying the common-horizon endpoint-crossing condition has exactly one invariant probability law; every initial probability law converges weakly to it. Prove endpoint invariant existence and oscillation contraction.

**Exact signature (readable form).** For real endpoints `a ≤ b`, a Markov kernel `k` on `Icc a b`, a Feller proof, and preservation of nondecreasing bounded-continuous tests, fix `d ∈ Icc a b`, `N ≥ 1`, and `0 < eps ≤ 1`. Assume the common-horizon crossing inequalities

```text
eps * f(d) + (1-eps) * f(a) ≤ T^[N] f(a)
T^[N] f(b) ≤ eps * f(d) + (1-eps) * f(b)
```

for every nondecreasing bounded-continuous `f`, where `T = testStep k hFeller`. Then there is exactly one probability law `pi` fixed by `lawStep k`; for every initial probability law `mu`, `(lawStep k)^[n] mu` tends weakly to `pi`. In addition,

```text
(T^[N])^[m] f(b) - (T^[N])^[m] f(a)
  ≤ (1-eps)^m * (f(b)-f(a)).
```

**Assumption profiles:** No economic profile. The actual premises are the Markov, Feller, stochastic-monotonicity, compact-interval, positive common-horizon, and crossing hypotheses displayed in the exact signature. The theorem does not assume an invariant law or convergence.

**Dependencies:** Primitive mathematics / installed Mathlib. **Source keys:** SLP89.

**Source locator:** SLP89 Assumption 12.1, Lemma 12.11 and Theorem 12.12, printed pp. 381-383 / PDF pp. 391-393.

**Readable proof.** `lawStep` pushes probability laws through the kernel, while `testStep` is the Feller Markov operator on bounded-continuous tests. Compactness of probability laws gives cluster points of the lower- and upper-endpoint orbits. For every continuous increasing test, endpoint integrals are respectively monotone increasing and decreasing and bounded by endpoint values. A convergent subsequence therefore identifies the limit of the full scalar sequence. Polynomial approximation proves that continuous increasing tests determine laws and that convergence on this class is weak convergence. Continuity of `lawStep` then makes both endpoint limits invariant.

Applying crossing to each block iterate gives the displayed geometric oscillation contraction. Hence the lower and upper invariant limits agree on continuous increasing tests and therefore as laws. Every initial law is sandwiched between the endpoint laws on those tests, giving weak convergence to their common limit. An invariant initial law has a constant orbit, proving uniqueness. This is weak convergence only; no total-variation or moment convergence is asserted.

**Public declarations.**

- `RealInterval`; `CI`; `lawStep`; `testStep`.
- `continuous_increasing_tests_determine`.
- `tendsto_probabilityMeasure_of_increasing_tests`.
- `M05D_compact_monotone_feller_stability`.
- `compact_monotone_feller_stability`.

**Audit.** Every public declaration has `#check`, `assert_no_sorry`, and `#print axioms` coverage in `Audit.lean` and `Probes/M05DSignatures.lean`. Each transitive axiom print contains only `propext`, `Classical.choice`, and `Quot.sound`.

**Adequacy note.** Generic mathematical theorem. The crossing premise is the test-function form of the common-horizon endpoint crossing bound; S05 must discharge it from S03 and stochastic monotonicity. The implementation is submitted as REVIEW_READY only. No GREEN status or later stationary/equilibrium conclusion is self-awarded.

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
