# Assigned implementation role

You are the executor, not the adequacy reviewer. Implement ONLY the explicitly assigned contract in this fresh session. Read project authority and approved source locators; do not inspect the failed prior Aiyagari implementation. Preserve accepted mathematics, primitive assumptions, dependencies and quantifiers. Do not implement a numerical model. The original M03 prompt supplies proof discipline; this wrapper narrows its execution scope to one gate.

You may mark assigned entries at most REVIEW_READY. Never award GREEN or edit acceptance records. Do not alter orchestration, configuration, tools, dependency pins, unrelated contracts or outer-repository state. Do not commit, stage, push, reset, clean, invoke other models or use messaging/network apps. Build only with the existing environment. New helpers belong under the assigned gate's Analysis subdirectory. Existing accepted source must be preserved byte-for-byte; a shared assigned module may be appended to.

Provide the assigned gate report, exact signatures, analytical audit and synchronized proof ledger with actual/transitive assumptions, readable proof and precise source pages. Audit every new exported declaration. Required checks are targeted/full builds, direct Audit.lean, contract checker, no-sorry, prohibited patterns, transitive axioms, signature probe, documentation build and PDF QA. A build does not establish economic adequacy. Stop with a blocker if the theorem or assumptions need revision. Do not weaken a theorem to make it compile.

Preserve the economic zero marginal as zeroRightMarginal : ENNReal. No consumption positivity or beta*R<1 may enter H09. Never infer a real integral's economic meaning before its integrability proof. Do not claim a later theorem just because its proof seems convenient. Stop at the assigned REVIEW_READY submission.


Assigned gate: M03B1; ONLY contracts ['H09']. Accepted predecessors: ['M03A']. Accepted baseline: 0a0fdcdd91f99b6322b1c298edd6d4e398001f56.

Required module: Aiyagari1994/Household/MarginalInequality.lean; signature probe: Probes/M03B1Signatures.lean; gate report: reports/m03b1_milestone.md; analytical audit: reports/m03b1_analytical_audit.md.

Never use rightMarginalValue m 0 as the economic zero-state marginal. rightMarginalValue is economically meaningful only at positive states. At zero use the separate ENNReal zeroRightMarginal, which may be infinite.

Exact assigned contracts (including source locators):
[
  {
    "id": "H09",
    "declaration": "Aiyagari1994.rightMarginalValue_superharmonic",
    "module": "Aiyagari1994/Household/MarginalInequality.lean",
    "stage": "03",
    "statement": "For every z with finite right marginal, q(z)>=beta*R*Integral q(R*A(z)+e) dnu. Establish the extended-integral inequality first and deduce conditional integrability; it is valid without beta*R<1 and without consumption positivity.",
    "assumptions": [
      "BASIC"
    ],
    "dependencies": [
      "H04",
      "H08"
    ],
    "proof_plan_section": "4.1",
    "sources": [
      "CW00"
    ],
    "scope": "core",
    "status": "UNFORMALIZED",
    "notes": "",
    "source_locator": "New concave-analysis/value-marginal infrastructure for the Aiyagari claims; inspired by CW00 Sections 2-4. Not a literal numbered Aiyagari theorem."
  }
]


--- AGENTS.md ---
# Aiyagari theory replication: repository instructions

## Authority and scope

The user has assigned mathematical design to the Pro reviewer and implementation to Codex. The approved authority is `docs/architecture.md`, `contracts/theorems.json`, `contracts/assumptions.json`, and the current milestone prompt. Start by reading them. Execute **only the explicitly assigned milestone**; stop at its review gate. Do not start later phases autonomously.

This is a clean, theory-only Lean 4 project. No economic Python code, numerical solver, asset grid, calibration, table replication or numerical certificate. Python may extract approved sources, check metadata, build documentation, or run the explicitly user-authorized deterministic orchestration controller. Continuous assets and a general compactly supported iid income law are the core model. Finite labor support is allowed for exact consistency witnesses, not as a replacement theorem family.

## Source boundaries

Only extract the exact source-paper members listed in `contracts/source_manifest.json`. Never inspect, import, copy, summarize, or search the failed Aiyagari implementation or its generated theory/proof/audit documents. The approved MP formatting conventions are already represented by this package; its code is not an economic proof dependency. Do not redistribute the user's source PDFs in release archives.

Read the specified source pages, not the entire 593-page SLP book. PDF equations and scans must be checked visually; do not guess from garbled extraction. Record printed and PDF page numbers separately. External theorem text is not a Lean proof: formalize its needed mathematics or import a proved theorem from the pinned Mathlib checkout.

## Non-negotiable mathematics

- Construct the canonical value and savings policy from primitive utility, income and prices. `A(z)` means shifted next assets; net assets are `A(z)-phi`.
- Bellman construction is for every `R>0`. Do not put `beta*R<1` in the household primitive type or equilibrium definition.
- Never assume policy monotonicity, an absorbing bound, mixing, invariant existence/uniqueness, asset-supply continuity/divergence, or an excess-demand sign in a paper-level theorem.
- General analytic lemmas may assume their mathematical hypotheses. Economic wrappers must prove those hypotheses from primitives.
- A fixed point needs lifetime verification against all measurable nonanticipative feasible plans.
- No real-valued integral represents an expected economic quantity without its integrability theorem. Use extended nonnegative integrals for potentially infinite marginal values before proving finiteness.
- Weak convergence does not give unbounded moment convergence. Respect the common-compact interior argument and tightness-only critical-boundary argument.
- The right marginal of value need not equal marginal utility at a zero-consumption corner. Do not assume strictly positive consumption when `beta*R>=1`.
- Nonexistence of stationary laws, divergence of stationary means, and almost-sure pathwise divergence are distinct targets.
- Inada plus zero minimum income does not by itself give never-binding savings; certify the exact diagnostic before calling the source note corrected.
- No-Ponzi means a finite nonnegative discounted wealth limit here, not a zero limit.
- Gross saving is `delta*K/f(K)`. Stationary net saving is zero.

## Proof and tooling discipline

Pin a mutually compatible Lean toolchain and Mathlib commit in milestone 00. Record the actual versions and exact declarations used. Moving web documentation is a locator, not an installed API guarantee. Never downgrade/change dependencies mid-proof without a report.

No `sorry`, `admit`, project `axiom`, `native_decide`, `Lean.ofReduceBool`, unsafe proof bypass, or unproved closure record in completed modules. Kernel-checked tactics such as `simp`, `ring`, `linarith`, and `norm_num` are permitted. Standard `propext`, `Classical.choice`, and `Quot.sound` are not defects. Audit all transitive axioms; a new axiom is a blocker, not a workaround.

Classical choice may select an object only after a proved existence theorem. Keep unfinished mathematical targets in the manifest, not as placeholders in compiled Lean. `All.lean` imports completed substantive modules only. `Audit.lean` checks every exported contract declaration with `#check`, `assert_no_sorry`, and `#print axioms`.

A declaration name, helper lemma, local proof organization or API implementation may change when semantically equivalent and documented. Economic assumptions, quantifiers, conclusion strength, probability interpretation or state-space coverage may not change without a design review. Do not use impossible assumptions to obtain vacuous proofs.

## Documentation and gates

Update the proof ledger with exact declaration names, mathematical statements, all transitive economic assumptions, source locators, readable proofs, and axiom output. Proposed arguments remain labeled proposed until checked. A script checking labels or dependencies is not a proof of economic adequacy.

Statuses: `UNFORMALIZED`, `IN_PROGRESS`, `KERNEL_CHECKED`, `REVIEW_READY`, `GREEN`, `BLOCKED`. Codex can move an entry to `REVIEW_READY` after a build. Only an explicit accepted Pro/user adequacy review, or the user-authorized independent fresh Astra review enforced by `orchestration/orchestrate.py`, authorizes `GREEN`; record it in `reviews/`. The implementation Codex cannot certify its own mathematical adequacy. Automated acceptance requires a fresh read-only Astra session on a frozen hash-bound snapshot, HIGH-confidence PASS, no human-review flag or blockers, and successful deterministic checks. The executor remains limited to REVIEW_READY; only the controller mechanically records that independent decision. Never self-award green because a build passes.

Every milestone returns the report specified in `reports/MILESTONE_REPORT_TEMPLATE.md`, build logs and a synchronized readable PDF. If blocked, preserve completed correct lemmas, write `reports/BLOCKER_TEMPLATE.md`'s requested details, and stop that target without weakening it. Complete independent assigned targets where possible; do not hide omissions.

## Milestone review archives

The repository root is `/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2`.
All milestone review archives must be written inside its `tmp_zip/` directory.
Create the directory if absent; never put review ZIPs at the repository root.

For milestone NN, after all implementation, documentation, builds, audits and verification,
automatically create `tmp_zip/review_mNN.zip` before stopping for review (M01: `review_m01.zip`,
M02: `review_m02.zip`, M05: `review_m05.zip`). This is mandatory even when the milestone prompt
omits it. A review-gate identifier may include a lowercase suffix: M02A uses
`tmp_zip/review_m02a.zip`; M02B uses `tmp_zip/review_m02b.zip`. The same packing,
exclusion, SHA-256 and untracked-file rules apply.
Creating the archive must not modify substantive source files.

Include all substantive Lean files created or modified, affected primitive/assumption/equilibrium
structures, All.lean, Audit.lean, milestone and relevant environment/build/audit reports, raw or
consolidated build logs, assert_no_sorry results, prohibited-pattern/bypass checks, transitive
#print axioms output, theorem/contract manifest changes, synchronized proof-ledger Markdown,
TeX and PDF, the complete git diff from the accepted previous-milestone baseline, and any blocker
reports needed for external mathematical, economic and Lean review.

Exclude .lake/, compiled Lean artifacts, source-paper PDFs, input ZIP archives, previous review
ZIPs, TeX auxiliary files, .DS_Store, __MACOSX, and numerical artifacts unrelated to this theory-only
project. Keep tmp_zip/ and all its contents untracked and ignored by git. Preserve this directory
convention in documentation. After creating the archive, report its exact absolute path and SHA-256.



--- prompts/03_household_analysis.md ---
# Milestone 03: household analysis

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestone 02 accepted; H01–H05 green.

**Contract IDs:** H07, H08, H09, H10, H11, H12, H13, H14, D01

## Work and source passages

Implement the policy-order, right-marginal, marginal-inequality, positive-consumption, envelope/Euler and threshold modules, plus the Inada diagnostic. Read architecture §§4–5; A93 Appendix Propositions 2–3; Benveniste–Scheinkman Lemma 1. Generic concave-analysis helpers belong under `Analysis/`.

## Mandatory proof sequence

1. Prove H07 by comparing the two optimality inequalities. Separate savings monotonicity from consumption monotonicity; use concavity of continuation value and strict concavity of U to exclude a reversal. Conclude both 1-Lipschitz inequalities. Do not claim differentiable policies.
2. Construct the right derivative of the finite concave V on positive states. For real-domain calculus use the extension `x ↦ V(x.toNNReal)`, claiming concavity only on nonnegative inputs. Define the right marginal by one-sided secant limits, not by an ordinary `deriv` that defaults to zero at an unproved differentiability point. Prove its positivity, monotonicity, right continuity and bound `q(z)<=osc(U)/((1-beta)*z)`. Define the zero-state derivative as an extended nonnegative limit, not as a real derivative that defaults to zero.
3. Prove H09 by keeping the original consumption and saving an extra initial h. Divide the Bellman comparison by h and apply monotone convergence to nonnegative concave difference quotients as h decreases to zero. Initially use the nonnegative extended integral. A finite left marginal proves the conditional expectation finite; only then convert to a real integral. The resulting inequality is valid at all R>0, including zero-consumption states.
4. Under beta*R<1, prove positive consumption by splitting finite versus infinite U_right_prime(0). For a finite marginal L, first prove the L-Lipschitz bound for all finite-horizon values when beta*R<=1, then pass to V. At a zero-consumption corner, shifting savings to consumption yields marginal gain L and continuation loss at most beta*R*L<L. For infinite marginal, consuming extra initial resources would force q(z)=infinity if c(z)=0.
5. Prove the one-dimensional lower-touching concavity lemma using left/right secant slopes. At c(z)>0, keep A(z) fixed in a two-sided state neighborhood to obtain H11. This theorem is local and must not carry beta*R<1: N04 later needs it at the critical return.
6. For interior savings, a neighborhood of actions puts next resources away from zero. Establish a dominating marginal bound, differentiate under the integral and use the first-order condition. At A=0 use right derivatives and the marginal inequality. Explicitly represent infinite endpoint slopes before proving conditional finiteness.
7. Prove the binding interval from `q(z)>beta*R*q(e_min)` near e_min and the opposite inequality required by interior Euler equality. Cover separately positive e_min and finite zero marginal.
8. Prove H14's corrected sufficient condition. Inada implies an infinite value slope at zero by consuming extra initial wealth. With a zero-income atom, an infinitesimal positive saving deviation at A=0 then gives an infinite continuation marginal and a finite current cost.

## Exact diagnostic D01

Keep the asset state continuous. Use beta=1/2, R=w=3/2, r=1/2, phi=2, uniform labor on [2/3,4/3], and U(c)=sqrt(c)/(1+sqrt(c)). Verify all primitive requirements and the effective-income pushforward to uniform [0,1]. Show `0<=V<=2`.

Using continuity of V and the sliding interval integral, prove the right derivative at a=0 of `Integral_0^1 V(R*a+e) de` is `R*(V(1)-V(0))`. The whole objective's derivative is at most `-U_prime(z)+3/2`, which is strictly negative for `0<z<=1/100`. Concavity yields A(z)=0 on that interval. Verify the exact derivative/RRA algebra; do not use a plotted curve or a grid. Until this theorem is checked, describe it as a proposed counterexample, not a certified correction.

This milestone can retain completed core lemmas if the diagnostic is blocked, but the report must distinguish the unresolved source correction. Never replace the core family by Inada-plus-atom merely to avoid the finite-marginal case.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.



--- docs/architecture.md ---
# Aiyagari (1993/1994): theory-only Lean replication

## Status and use

This is a mathematical specification and an execution package, not a completed Lean formalization. All theorem targets begin **UNFORMALIZED**. The arguments below are proposed proof constructions; they have not been checked by Lean. A successful build alone will not establish economic adequacy. The executable prompts implement this specification in small, reviewed milestones.

The published target is Aiyagari (1994), with the analytic model and appendix in the December 1993 Working Paper 502. The primary release is the continuous-asset, i.i.d.-income, bounded-utility theory: household optimization, Propositions 1–5 of the working paper with necessary qualifications, stationary asset supply, stationary general-equilibrium existence, and the interest-rate/capital/gross-saving comparison. Exact debt and borrowing-limit identities are a separate extension layer. There is no numerical solver, asset grid, empirical calibration, numerical certificate, or Python economic model. Python files in this package only extract sources and validate project metadata.

The bounded-utility release is not a proof for unbounded log/CRRA utility or serially correlated earnings. Those require distinct theorem contracts. Likewise, nonexistence of an invariant law, divergence of stationary means as a parameter approaches a boundary, and almost-sure divergence along a household path are different claims. No one of these is substituted for another.

## 1. Source audit and changes to the earlier plan

The source inventory records original archive members, SHA-256 hashes, printed pages and PDF pages. The supplied file `schechtman_escudero_1976.pdf` is the **1977** published article. The original Aiyagari archive is used only for its four source-paper PDFs; none of its Lean code, theory summaries, proof documents, or audits is used. The Mortensen–Pissarides archive supplies formatting conventions only.

### 1.1 Exact external dependencies

| Source | Inspected location | Use and limitation |
|:--|:--|:--|
| Aiyagari (1993) | Printed pp. 11–22 and 37–40; PDF pp. 12–23 and 38–41 | Model, economic conclusions, Appendix Propositions 1–5. The PDF is scanned; mathematical passages were inspected as page images. |
| Aiyagari (1994) | Printed pp. 665–674; PDF pp. 8–17 | Published theoretical target, especially equations (1)–(8) and notes 16, 18–29. |
| Schechtman–Escudero (1977) | Theorems 3.8–3.9, printed pp. 161–162; PDF pp. 11–12 | Marginal-value ratio argument for upper drift. Aiyagari uses an eventual bound on relative risk aversion rather than requiring an asymptotic exponent. |
| Clarida (1987) | Section 2 and Appendix; printed pp. 340–344, 348–350 | Income-fluctuation problem with borrowing. Its distributional and utility restrictions must not be transferred silently. |
| Clarida (1990) | Proposition 2.4, printed p. 548; PDF p. 7 | States continuity and both boundary limits **without proof**, referring to Bewley (1984). It is a source locator, not a proved Lean dependency. |
| Benveniste–Scheinkman (1979) | Lemma 1, printed p. 728; PDF p. 3 | Concave-function differentiability from a differentiable lower touching function. Formalize the one-dimensional lemma directly; do not assume an envelope equation. |
| Stokey–Lucas–Prescott (1989), SLP | Chapter 12, especially Assumption 12.1, Lemma 12.11, Theorems 12.12–12.13, printed pp. 381–385; PDF pp. 391–395 | Endpoint crossing, oscillation contraction, uniqueness/weak stability, parameter continuity. Definitions and proofs are available in the supplied full book. |
| Chamberlain–Wilson (2000) | Sections 2–4, especially Theorem 4/Corollary 2; also Theorem 7 | Later published version of a dependency cited by Aiyagari as a 1984 working paper. Guides the value-marginal approach and the separately scoped pathwise result. |
| Sibley (1975); Miller (1976) | Supplied complete articles | Risk-order claims are separately reviewed. Do not infer an aggregate ordering from an ordering of household policies. |

No additional paper is a prerequisite for the core execution sequence. In particular, the missing Bewley manuscript is bypassed by the explicit nonstationarity/tightness construction in Sections 9–10. This construction must be formalized, not treated as a replacement citation.

### 1.2 Corrections that must survive implementation

1. **No-Ponzi is not zero terminal wealth.** Aiyagari (1993), Proposition 1, uses a nonnegative discounted-wealth limit. A feasible, nonoptimal household can leave positive discounted terminal wealth. Proving that the limit equals zero is a different optimality statement.
2. **A Bellman fixed point is not yet a lifetime optimum.** Verification against all nonanticipative feasible plans is an explicit theorem. Verification only against stationary policies is insufficient.
3. **Bounded utility does not bound the optimal consumption function.** The state space is unbounded. The drift argument actually requires consumption to become arbitrarily large as resources increase.
4. **Inada at zero plus a zero minimum effective income does not alone imply that the borrowing constraint never binds.** The note after Aiyagari (1993), Proposition 3, needs a further condition. An atom at zero combined with Inada is a sufficient condition; a continuous uniform effective-income distribution supplies a counterexample to the unqualified note. Section 5.3 gives an exact witness.
5. **Mixing is proved, not read off a diagram.** The lower transition map decreases strictly above the minimum; finite strings of near-minimum shocks and a high final shock provide SLP's common-horizon crossing probabilities.
6. **Local parameter continuity is not global operator-norm continuity on an unbounded state space.** Use finite-horizon continuity and a uniform discounted tail bound. Derive common compact invariant bounds only away from the critical interest rate.
7. **Stationary means do not follow from weak convergence alone.** Use a common compact state interval for interior parameter continuity. At the critical boundary, use bounded means only to obtain tightness, not to pass an unbounded integral through a weak limit.
8. **Never define equilibrium to require $\beta(1+r)<1$.** Otherwise the headline interest-rate theorem becomes tautological. Construct the household optimum for every admissible positive gross return before imposing impatience for stationary-law existence.
9. **Fixed-limit equilibrium existence need not assume a bracketing condition.** Section 11 derives a lower bracket from the stationary household budget and the firm's production function.
10. **Net saving is zero in a stationary economy without growth.** The paper's higher saving-rate conclusion concerns gross investment $\delta K/f(K)$.

## 2. Primitive model and normalized notation

At the base-model level, allow a probability measure $\nu$ on a compact labor interval $L=[\ell_-,\ell_+]$ with $0<\ell_-\leq\ell_+<\infty$. The risky core adds $\ell_-<\ell_+$ and essential endpoints: every relative neighborhood of either endpoint has positive probability. The deterministic benchmark is a separately instantiated degenerate income law. Atoms are allowed; a density is not required. In general-equilibrium modules impose $\int\ell\,d\nu=1$. Future labor draws are i.i.d. and independent of predetermined assets. A household chooses after observing current labor income.

Let $0<\beta<1$, $R=1+r>0$, $w>0$, and $\phi\geq0$ with $w\ell_- -r\phi\geq0$. Set
\[
e(\ell)=w\ell-r\phi,\qquad e_-=w\ell_- -r\phi,\qquad e_+=w\ell_+-r\phi.
\]
The household's unshifted budget and normalized budget are
\[
c_t+a_{t+1}=R a_t+w\ell_t,\quad a_{t+1}\geq-\phi,
\]
\[
\widehat a_t=a_t+\phi,\quad z_t=R\widehat a_t+w\ell_t-r\phi,
\quad c_t+\widehat a_{t+1}=z_t,
\quad z_{t+1}=R\widehat a_{t+1}+e(\ell_{t+1}).
\]
Use the fixed analytic state space $X=\mathbb R_+$, not a parameter-dependent interval. Economically reachable states satisfy $z\geq e_-$. The extension to $0\leq z<e_-$ is a well-defined auxiliary household problem and does not alter reachable-state behavior.

| Paper notation | Canonical mathematical meaning | Lean-facing name |
|:--|:--|:--|
| $a_t$ | Beginning-of-period net asset holdings | `netAssets` |
| $\widehat a_t$ | Shifted nonnegative holdings | `shiftedAssets` |
| $A(z)$ | Next-period **shifted**, not net, assets | `assetPolicy` |
| $c(z)=z-A(z)$ | Optimal consumption | `consumptionPolicy` |
| $R=1+r$ | Gross return | `grossReturn` |
| $\lambda=\beta^{-1}-1$ | Rate of time preference | `impatienceRate` |
| $\phi$ | Effective debt limit | `effectiveLimit` |
| $V$ | Canonical bounded Bellman fixed point | `valueFunction` |
| $q(z)=V'_+(z)$ | Right marginal value; not automatically $U'(0)$ | `rightMarginalValue` |
| $P$ | Kernel $z\mapsto(RA(z)+e)_\#\nu$ | `householdKernel` |
| $\pi$ | Probability law of total resources | `stationaryLaw` |
| $\rho$ | Law of net assets, $(A-\phi)_\#\pi$ | `netAssetLaw` |
| $S(r,w,\phi)$ | $\int(A(z)-\phi)\,d\pi(z)$ | `stationaryAssetSupply` |

### Utility assumptions

The core utility is real-valued and continuous on $\mathbb R_+$, bounded above and below, strictly increasing, strictly concave, and twice continuously differentiable on $(0,\infty)$ with $U'>0$ and $U''\leq0$. Differentiability is **not** required at zero. The right marginal at zero may be finite or infinite. For drift only, require constants $C_0>0$ and $M<\infty$ such that
\[
-cU''(c)/U'(c)\leq M\quad(c\geq C_0).
\]
The $C^2$ condition is an explicit analytic regularity choice for the curvature-based branch, not a hidden consequence of concavity. Modules needing only continuity/concavity must not import it unnecessarily. A nonempty primitive example is $U(c)=c/(1+c)$, with relative risk aversion $2c/(1+c)\leq2$. The Inada diagnostic uses $U(c)=\sqrt c/(1+\sqrt c)$.

### Two borrowing specifications

For a finite institutional limit $b\geq0$:
\[
\phi_b(w,r)=\begin{cases}\min\{b,w\ell_-/r\},&r>0,\\b,&-1<r\leq0.\end{cases}
\]
For the present-value limit, use $r>0$ and $\phi_N(w,r)=w\ell_-/r$. These are separate model families. Continuity of $\phi_b$ at $r=0$ must be proved using the locally binding finite cap, not by evaluating $1/r$ at zero.

### Assumption discipline

Primitive records may contain only economic data, probability normalization/support, utility regularity, and production regularity. They may not contain a value function, a savings rule, compact absorbing bounds, mixing, an invariant law, asset-supply continuity, or equilibrium existence. A general mathematical lemma can legitimately assume that an arbitrary kernel is Feller and has a crossing property; the economic wrapper must supply **proved** instances of these hypotheses. Similarly, optimality and invariance are legitimate defining conditions of an equilibrium object, but an existence theorem must construct an object satisfying them.

## 3. Bellman construction and lifetime verification

For $v\in C_b(X)$ define
\[
(Tv)(z)=\max_{0\leq a\leq z}\left\{U(z-a)+\beta\int v(Ra+e(\ell))\,d\nu(\ell)\right\}.
\]
For continuity arguments only, reparameterize $a=tz$, $t\in[0,1]$. The feasible action itself remains $a\in[0,z]$; $t$ is not a uniquely selected control at $z=0$.

**Existence and contraction.** The objective is continuous on each compact action interval. Boundedness of $U$ and $v$ bounds $Tv$. On a compact neighborhood of a state, the transition image of actions and labor states is compact, giving continuity of the integral and of the maximum. Prove
\[
\|Tv-T\widetilde v\|_\infty\leq\beta\|v-\widetilde v\|_\infty.
\]
Use Mathlib's Banach fixed-point theorem to define $V$. Its uniqueness concerns bounded continuous fixed points. Concavity follows by preservation under $T$ and uniform convergence of iterations starting from zero. Increasingness follows by the same preservation argument; strict increasingness follows by retaining the old savings action and consuming the additional resources.

**Policy.** The objective is strictly concave in $a$ because $U(z-a)$ is strictly concave and the continuation value is concave. Its unique maximizer defines $A(z)$. Compact maximization and uniqueness give continuity; at zero use $0\leq A(z)\leq z$. The policy is not an input to `HouseholdPrimitives`.

**Verification.** A feasible plan is a sequence of measurable choices depending on the history observed so far, satisfying the shifted budget and nonnegativity. Prove the finite-horizon Bellman inequality
\[
V(z_0)\geq\mathbb E\!\left[\sum_{t=0}^{n-1}\beta^tU(c_t)+\beta^nV(z_n)\right]
\]
for every such plan, with equality for the canonical policy. This can be done using finite product measures of labor histories; an infinite sample-path construction is not needed for this theorem. Since $V$ is bounded, the terminal term vanishes uniformly. The bounded discounted utility series converges absolutely in expectation. Conclude that the canonical policy solves the original infinite-horizon objective over all nonanticipative feasible plans. Include the budget-change-of-variables equivalence, rather than verifying only a newly invented problem.

## 4. Policy shape, right marginals, and the envelope theorem

Write $G(a)=\beta\int V(Ra+e)\,d\nu$. It is concave. Comparing the optimality inequalities for two resource levels, and using concavity of $U$ and $G$, proves
\[
0\leq A(z_2)-A(z_1)\leq z_2-z_1,\qquad
0\leq c(z_2)-c(z_1)\leq z_2-z_1\quad(z_1\leq z_2).
\]
Do not replace these order statements with a differentiability claim about the policy. Strict order claims in the source are tracked separately; weak order and the Lipschitz bounds suffice for the core proof chain.

### 4.1 A marginal inequality valid before imposing impatience

For every $z>0$, a finite, strictly positive right derivative $q(z)=V'_+(z)$ exists by concavity and strict increasingness. It is nonincreasing. If $D=(\sup U-\inf U)/(1-\beta)$, then
\[
0<q(z)\leq\frac{V(z)-V(0)}{z}\leq D/z.
\]
Retain the optimal current consumption and invest an additional initial amount $h>0$. This gives
\[
V(z+h)-V(z)\geq\beta\int[V(RA(z)+e+Rh)-V(RA(z)+e)]\,d\nu.
\]
Divide by $h$ and let $h\downarrow0$. Nonnegative concave difference quotients permit monotone convergence, yielding
\[
q(z)\geq\beta R\int q(RA(z)+e)\,d\nu. \tag{M}
\]
Boundary derivatives at zero are treated as extended limits until their finiteness or null relevance has been proved. Do not use Lean's real-valued integral to turn an infinite marginal expectation into zero. Inequality (M) itself establishes the required conditional integrability at states with finite $q$.

### 4.2 Consumption positivity in the impatient region

Under $\beta R<1$, prove $c(z)>0$ for $z>0$.

If $U'_+(0)=\infty$, consuming an increment of additional resources while keeping the original savings choice would imply $q(z)=\infty$ whenever $c(z)=0$, contradicting finite $q(z)$.

If $U'_+(0)=L<\infty$, prove first, by finite-horizon induction, that $V$ is $L$-Lipschitz when $\beta R\leq1$. For a larger state $z+h$ with an optimal action $a$, compare it with action $a$ at $z$ when $a\leq z$, and with action $z$ when $a>z$. In the latter case the extra resources split between extra current consumption and extra savings; the return-adjusted continuation slope is at most $\beta RL\leq L$. Passing to the limit proves the bound. If $c(z)=0$, transferring a small amount from savings to consumption gains a marginal amount approaching $L$, while the continuation loss is at most $\beta RL<L$. This contradicts optimality.

### 4.3 Envelope and Euler conditions

At any $z>0$ with $c(z)>0$, keep $A(z)$ fixed while perturbing $z$ in a small two-sided neighborhood. The differentiable concave function
\[
W(x)=U(x-A(z))+\beta\int V(RA(z)+e)\,d\nu
\]
touches $V$ from below. The one-dimensional Benveniste–Scheinkman lemma gives
\[
V'(z)=U'(c(z)).
\]
Prove the touching lemma from one-sided slopes; importing a multidimensional subgradient library is unnecessary. Continuity of $c$ and $U'$ then gives continuity of $V'$ on the positive-consumption region.

At $A(z)>0$, nearby savings choices keep next resources bounded away from zero, permitting differentiation under the integral using a local marginal bound. First-order optimality yields equality in (M). At $A(z)=0$, use one-sided difference quotients; they yield the Euler inequality and rule out an infinite continuation marginal when current consumption is positive. State the Euler result with every integrability obligation visible.

## 5. Borrowing thresholds and an important diagnostic

### 5.1 A positive binding interval

If $\beta R<1$ and either $e_->0$ or $U'_+(0)<\infty$, then $q(e_-)$ is finite and positive. If $A(z)>0$, the Euler equality and monotonicity give
\[
q(z)=\beta R\mathbb E q(RA(z)+e)\leq\beta Rq(e_-).
\]
Right continuity of the right derivative at $e_-$ makes this impossible for all $z$ in a sufficiently small right neighborhood of $e_-$. Consequently, some $\widehat z>e_-$ satisfies $A(z)=0$ on $[e_-,\widehat z]$. This reproduces the qualified Proposition 3. Do not assume the threshold exists before this argument.

### 5.2 A sufficient condition for never binding

If $e_-=0$, $U'_+(0)=\infty$, and the income distribution has an atom at $e=0$, then $A(z)>0$ for every $z>0$. A small positive saving deviation from $A=0$ gains at least the zero-income probability times the increase in $V$ near zero, whose right slope is infinite; its current-utility cost has finite slope. More generally, an infinite expected right marginal of continuation value at $A=0$ is sufficient. Inada and $e_-=0$ by themselves are not sufficient.

### 5.3 Exact continuous-state counterexample to the unqualified note

Take $\beta=1/2$, $R=3/2$, and effective income uniform on $[0,1]$. Use
\[
U(c)=\frac{\sqrt c}{1+\sqrt c},\qquad U(0)=0.
\]
This utility is bounded, strictly increasing, strictly concave, Inada at zero, and has relative risk aversion
\[
-\frac{cU''(c)}{U'(c)}=\frac12+\frac{\sqrt c}{1+\sqrt c}<\frac32.
\]
The setup is economically admissible in the original model: labor uniform on $[2/3,4/3]$ has mean one; choose $w=3/2$, $r=1/2$ and natural limit $\phi=2$.

Because $V$ is bounded and continuous,
\[
\left.\frac{d}{da^+}\int_0^1V(Ra+e)\,de\right|_{a=0}
=R[V(1)-V(0)].
\]
Also $0\leq V\leq2$. Thus the right derivative of the Bellman objective at $a=0$ is at most $-U'(z)+3/2$. For $0<z\leq1/100$, $U'(z)\geq U'(1/100)>3/2$. Concavity therefore makes $A(z)=0$ optimal. This disproves the unqualified nonbinding note without using a finite asset grid. The counterexample must itself be verified in Lean before it is labeled a certified correction.

## 6. Joint parameter continuity and uniform upper drift

### 6.1 Continuity before stationarity

Keep $U$ and $\nu$ fixed. First use normalized prices $\theta=(R,w,k)$ with $e(\ell)=w\ell+k\geq0$; the original coordinates $(w,R,\phi)$ map to these by $k=-(R-1)\phi$. Let $\theta$ vary over this admissible normalized domain. Each finite-horizon value function $T_\theta^n0$ is jointly continuous in $(\theta,z)$, by the fixed $t\in[0,1]$ maximization representation and compactness of the shock space. Its distance from $V_\theta$ is bounded uniformly in $\theta$ by a constant times $\beta^n$. Consequently, $V_\theta(z)$ is jointly continuous. The unique-maximizer argument gives joint continuity of $A_\theta(z)$. This includes parameter values with $\beta R=1$ and $\beta R>1$: the bounded-utility Bellman construction does not require impatience.

### 6.2 A locally uniform version of Proposition 4

Work on a parameter neighborhood with
\[
0<R_{\min}\leq R\leq R_{\max},\quad \beta R\leq\gamma_*<1,
\quad 0\leq e_-\leq e_+\leq E_*,\quad e_+-e_-\leq\Delta_*.
\]
Replace the eventual relative-risk-aversion bound by a larger positive integer $m$. For $c_2\geq c_1\geq C_0$, differentiation of $c^mU'(c)$ proves
\[
\frac{U'(c_1)}{U'(c_2)}\leq(c_2/c_1)^m.
\]
Choose $C\geq C_0$ sufficiently large that
\[
\gamma_*\left(1+\Delta_*/C\right)^m<1.
\]
The bound $q_\theta(x)\leq D/x$ and the envelope identity imply that $c_\theta(x)>C$ whenever $x$ exceeds a common level $L>D/U'(C)$. Choose $K$ with $R_{\min}K>L$, and then $B\geq R_{\max}K+E_*$.

If $A_\theta(z)\leq K$, then $RA_\theta(z)+e_+\leq B\leq z$ for $z\geq B$. Otherwise both extreme next-period states have consumption exceeding $C$. The consumption Lipschitz bound and curvature inequality imply
\[
\frac{\mathbb E q_\theta(RA_\theta(z)+e)}{q_\theta(RA_\theta(z)+e_+)}
\leq(1+\Delta_*/C)^m.
\]
Euler equality then gives $q_\theta(z)<q_\theta(RA_\theta(z)+e_+)$. Since $q_\theta$ is nonincreasing,
\[
RA_\theta(z)+e_+<z.
\]
This proves a uniform upper drift bound and a common forward-invariant interval. It avoids an unsupported assertion that pointwise absorbing bounds vary continuously in prices.

**Do not infer finite-time entry into $[e_-,B]$ from weak downward drift.** A trajectory can approach a boundary asymptotically. Global weak convergence will be obtained by applying the same compact-state theorem on larger intervals, not by assuming finite-time entry.

## 7. Kernel, derived crossing, and the SLP theorem

Define the Markov kernel by the pushforward of $\nu$ under $\ell\mapsto RA(z)+e(\ell)$. Verify measurability, probability mass one, and the integral identity for bounded measurable test functions. Joint continuity of the transition map implies the Feller property. Monotonicity of $A$ proves stochastic monotonicity by using the same labor realization at both initial states.

### 7.1 Deriving mixing from household optimality

On a compact invariant interval $I=[e_-,B]$, define
\[
h_-(z)=RA(z)+e_-.
\]
For $z>e_-$, if $h_-(z)\geq z$, then $A(z)>0$ and Euler equality gives
\[
q(z)=\beta R\mathbb E q(RA(z)+e)\leq\beta Rq(h_-(z))
\leq\beta Rq(z)<q(z),
\]
a contradiction. Thus $h_-(z)<z$ above $e_-$. At the lower endpoint, $A(e_-)=0$: this is immediate if $e_-=0$, and otherwise follows from the same inequality. Repeated application of $h_-$ to $B$ decreases to $e_-$ by continuity.

Choose $d\in(e_-,e_+)$. There is a finite $N\geq1$ with $h_-^N(B)<d$. By continuity of this finite composition, there is an $\eta>0$ such that $N$ shocks all in $[e_-,e_-+\eta]$ also move $B$ below $d$. Their probability is $p_-^N>0$. Regardless of the earlier history, a final shock above $d$ puts the state above $d$, with probability $p_+>0$. Choose $\varepsilon=\min\{p_-^N,p_+,1/2\}$. Then
\[
P^N(e_-,[d,B])\geq\varepsilon,
\qquad P^N(B,[e_-,d])\geq\varepsilon.
\]
This is precisely the needed common-horizon crossing condition. It does not require an atom at the lower endpoint, a positive density, a unique upper fixed point, or a drawing supplied by the paper.

### 7.2 Formalizing the one-dimensional SLP argument

First prove compact monotone-Feller invariant existence using the increasing measures $P^{*n}\delta_{e_-}$ and decreasing measures $P^{*n}\delta_B$. Compactness of probability measures supplies cluster points; order-determining continuous increasing tests give convergence; Feller continuity makes both limits invariant.

For a bounded nondecreasing test function $f$, crossing gives
\[
\varepsilon f(d)+(1-\varepsilon)f(e_-)
\leq P^Nf(z)
\leq\varepsilon f(d)+(1-\varepsilon)f(B).
\]
Apply this to $P^{kN}f$ and induct:
\[
(P^{kN}f)(B)-(P^{kN}f)(e_-)
\leq(1-\varepsilon)^k[f(B)-f(e_-)].
\]
The two endpoint invariant limits therefore agree on continuous increasing tests and hence as probability measures. Every initial law lies between the endpoint laws in stochastic order, proving uniqueness and **weak** convergence. No total-variation convergence is claimed.

For a point $z>B$, run the compact theorem on $[e_-,\max\{B,z\}]$; the previously constructed invariant law also lives there, so uniqueness identifies the limit. Initial states below $e_-$ enter the economic state interval after one step. Dominated convergence for bounded tests then extends convergence to every initial probability law on $\mathbb R_+$. This also proves uniqueness of an invariant law on the full state space, including laws not initially known to have finite moments.

## 8. Stationary continuity, aggregation, and the cross-sectional bridge

Use the uniform drift result locally around a strictly impatient price vector. Regard all invariant laws as measures on the same compact interval $[0,B]$ (the fixed lower endpoint zero avoids varying-state-space problems). Joint kernel continuity and uniqueness imply weak continuity of the stationary law, by the subsequence argument of SLP Theorem 12.13. Show explicitly that every subsequential limit is invariant under the limiting kernel.

For average assets, split
\[
\left|\int A_{\theta_n}\,d\pi_{\theta_n}-\int A_{\theta_0}\,d\pi_{\theta_0}\right|
\leq\|A_{\theta_n}-A_{\theta_0}\|_{[0,B]}
+\left|\int A_{\theta_0}\,d\pi_{\theta_n}-\int A_{\theta_0}\,d\pi_{\theta_0}\right|.
\]
Joint continuity gives uniform convergence on $[0,B]$; weak convergence handles the fixed continuous integrand. Subtract the continuous effective debt limit. This proves stationary asset-supply continuity without an unproved moment assumption.

The canonical resource law and the economically meaningful asset/labor cross-section must be linked. Let $\rho=(A-\phi)_\#\pi$. Predetermined assets and current i.i.d. labor have joint law $\rho\otimes\nu$. Its resource image is $\pi$ by invariance. Prove this identity and then
\[
\mathbb E_\pi z=R\mathbb E_\pi A+\mathbb E e,
\quad S=\mathbb E_\pi A-\phi,
\quad \mathbb E_\pi c=rS+w\mathbb E\ell.
\]
In general equilibrium $\mathbb E\ell=1$. These statements require explicit integrability, supplied here by compact support. A continuum of individually independent random variables is not needed: the equilibrium is defined by a stationary cross-sectional law, not by an unproved continuum law of large numbers.

## 9. Excluding a stationary law when $\beta R\geq1$

This is a proposed replacement proof, inspired by the marginal-value argument in Chamberlain–Wilson, rather than a claim that Clarida supplies the missing derivation. The use of the right marginal of **value** is important: $U'(c)$ need not describe the value marginal at a zero-consumption corner.

### 9.1 Resolve the zero-resource state first

The right derivative at zero may be finite or infinite. If it is finite, it is positive and may be included in the real-valued function $q$. If it is infinite and $p_0=\Pr(e=0)>0$, optimal savings from every positive state must be strictly positive: a deviation from zero savings would have infinite marginal continuation gain. Thus transitions from positive states cannot hit zero. An invariant law then satisfies $\pi\{0\}=p_0\pi\{0\}$; nondegeneracy gives $p_0<1$, hence $\pi\{0\}=0$. If $p_0=0$, zero has no incoming probability. Only after this proof may $q$ be assigned an arbitrary finite value at an irrelevant zero state.

### 9.2 A bounded strict-concavity argument avoids stationary marginal integrability

Suppose $\pi$ is invariant. Set $\gamma=\beta R\geq1$ and
\[
\psi(x)=\frac{x}{1+x},\qquad x\geq0.
\]
For $\pi$-almost every state, (M) gives a finite conditional mean $m(z)=\int q(z')P(z,dz')$ and
\[
\psi(q(z))\geq\psi(\gamma m(z))\geq\psi(m(z))
\geq\int\psi(q(z'))P(z,dz').
\]
The end terms have the same integral by stationarity, since $\psi$ is bounded. If $\gamma>1$, strict monotonicity and $m(z)>0$ make the middle inequality strict almost everywhere, a contradiction.

At $\gamma=1$, all inequalities are equalities almost everywhere. Strict Jensen equality gives $q(z')=q(z)$ under the stationary one-step joint law. A convenient elementary proof of strict Jensen uses
\[
\psi(m)+\psi'(m)(x-m)-\psi(x)
=\frac{(x-m)^2}{(1+m)^2(1+x)}.
\]
The nonnegative tangent gap has zero conditional integral exactly when $x=m$ almost surely. Only conditional integrability of $q$ is used; $\int q\,d\pi<\infty$ is **not** assumed.

### 9.3 Equal value marginals imply equal consumption

At positive consumption, the envelope proof gives $q=U'(c)$. At zero consumption, consuming an increment of extra resources while retaining savings gives $q\geq U'_+(0)$. Strict concavity makes $U'$ injective on $(0,\infty)$ and $U'(c)<U'_+(0)$ for $c>0$. Therefore equal finite value marginals imply equal consumption, including the finite-marginal zero-consumption corner. Along any finite stationary history at $\gamma=1$, consumption is thus equal to its initial value.

### 9.4 Two independent future shock strings give the contradiction

Here $R=1/\beta>1$. Draw a common initial state $Z_0\sim\pi$ and two independent length-$n$ future effective-income strings $(e_j)$ and $(\widetilde e_j)$, independent of $Z_0$. Evolve both by the optimal policy. Marginal stationarity gives $Z_n,\widetilde Z_n\sim\pi$. Constant consumption along both paths gives the exact cancellation
\[
R^{-n}(Z_n-\widetilde Z_n)
=\sum_{j=1}^nR^{-j}(e_j-\widetilde e_j)=D_n.
\]
Every probability law on $\mathbb R_+$ is tight, so the left side tends to zero in probability; use the union bound on $Z_n$ and $\widetilde Z_n$, not a moment assumption. The right side is bounded uniformly by $(e_+-e_-)/(R-1)$. Hence $\mathbb E D_n^2\to0$.

On the other hand, independence and nondegenerate bounded income imply
\[
\mathbb E D_n^2=2\operatorname{Var}(e)\sum_{j=1}^nR^{-2j}
\geq2\operatorname{Var}(e)R^{-2}>0\quad(n\geq1),
\]
a contradiction. The products can be constructed separately for each $n$; this proof does not require building an infinite stationary path space.

Conclude that the canonical household kernel has no invariant probability law when $\beta R\geq1$. The theorem must not assume bounded assets, finite stationary marginal utility, or a stationary law supported away from zero.

## 10. The two stationary asset-supply boundary limits

### 10.1 Divergence as $r\uparrow\lambda$

Allow $w_n\to w_*>0$, $r_n\uparrow\lambda$, and effective limits $\phi_n\to\phi_*<\infty$. Let $\pi_n$ be the subcritical invariant laws. If $S_n$ does not tend to $+\infty$, choose a subsequence with $S_n\leq M$. Then
\[
\mathbb E_{\pi_n}A_n=S_n+\phi_n
\]
is bounded. Invariance implies $\mathbb E_{\pi_n}z=R_n\mathbb E A_n+\mathbb E e_n$, so the nonnegative resource means are uniformly bounded. Markov's inequality gives tightness, and Prokhorov gives a weakly convergent subsequence.

For any bounded continuous test $f$, joint policy/transition continuity gives $P_nf\to P_*f$ uniformly on every compact resource interval. The tight tail controls the complement. Passing through the stationarity equation using **bounded** tests proves that the limit law is invariant for the critical kernel. Section 9 rules this out. Therefore $S_n\to+\infty$.

This proves the parameter-boundary result directly. It does not infer it from exploding supports, almost-sure paths, or convergence of unbounded integrals. State the sequence theorem first; obtain the one-sided limit with Lean's filter API afterward.

### 10.2 Natural debt limit as $r\downarrow0$

For $\phi=w\ell_-/r$, effective income is $e=w(\ell-\ell_-)$. If $w\to w_0>0$, then $R\to1$ remains strictly impatient, and the uniform drift proof bounds $A$ on one common compact set. Thus $\mathbb EA$ stays bounded while $\phi\to+\infty$, giving $S\to-\infty$.

The divergence of $\phi$ does not obstruct the argument: apply the household continuity/drift modules to the normalized income law, not to an unbounded raw parameter triple $(w,r,\phi)$.

## 11. Firms, existence, and the main economic result

A concrete production witness is $f(K)=\sqrt K$ with $\delta=1/2$; combined with the household witness in Section 2, it demonstrates a nonempty full primitive class.

Let $f:[0,\infty)\to[0,\infty)$ be continuous with $f(0)=0$, twice continuously differentiable on $(0,\infty)$, $f'>0$, $f''<0$, $f'(0+)=\infty$, and $f'(\infty)=0$. Let $0<\delta<1$. The constant-returns technology is $F(K,L)=Lf(K/L)$ for $L>0$.

For $r>-\delta$, construct the unique capital demand $K(r)>0$ from $f'(K(r))=r+\delta$ and define
\[
w(r)=f(K(r))-K(r)f'(K(r)).
\]
Prove these functions are continuous, $K$ is strictly decreasing, and $w>0$. They are derived from $f$, not free curves. The labor normalization is one.

### 11.1 A noncircular equilibrium definition

A stationary equilibrium contains prices and a cross-sectional law satisfying firm optimization, household lifetime optimality, invariance, finite first moments needed for aggregation, and capital-market clearing. The household optimum is the canonical Bellman solution constructed for all $R>0$. Neither the definition nor its primitive hypotheses require $r<\lambda$, asset-supply monotonicity, or uniqueness of equilibrium. Prove equivalence between a resource-law formulation and the net-asset/current-labor formulation.

### 11.2 A derived lower bracket for every finite $b$

The firm assumptions imply $f(K)/K\to0$ as $K\to\infty$; prove this with a tangent bound and $f'(K)\to0$. Choose a large $K_L$ such that $f'(K_L)<\delta$ and $f(K_L)<\delta K_L$. Put $r_L=f'(K_L)-\delta\in(-\delta,0)$ and $w_L=f(K_L)-K_Lf'(K_L)>0$.

For the household stationary law at these prices, nonnegative consumption and the stationary budget give
\[
0\leq\mathbb Ec=w_L+r_LS(r_L),
\quad S(r_L)\leq\frac{w_L}{-r_L}<K_L.
\]
The last inequality is exactly $f(K_L)<\delta K_L$. Thus excess asset supply is negative at an explicitly derived feasible price. Near $\lambda$, asset supply tends to infinity while $K(r)$ remains finite. Continuity and the intermediate value theorem give at least one stationary equilibrium for every finite institutional limit $b\geq0$, with $r\in(-\delta,\lambda)$.

This is stronger than the earlier plan's conditional bracketing theorem, without imposing a conclusion as an assumption. Equilibrium need not be unique and its interest rate need not be positive.

### 11.3 Natural-limit equilibrium

At $r\downarrow0$, capital demand and wages tend to finite positive values because $\delta>0$. Section 10.2 gives negative infinite asset supply; Section 10.1 gives positive infinite supply at the other endpoint. Continuity gives an equilibrium with $0<r<\lambda$.

### 11.4 Certainty benchmark and capital/saving comparisons

First consider deterministic labor at its mean, $\bar\ell=\int\ell\,d\nu$, and a strictly impatient return. Its constant effective income is $\bar e=w\bar\ell-r\phi_C$, where $\phi_C$ uses the certainty income rather than the risky minimum. The deterministic transition $h(z)=RA(z)+\bar e$ satisfies $h(\bar e)=\bar e$ and $h(z)<z$ above $\bar e$ by Section 7.1, without requiring nondegenerate income. Every finite initial state converges to $\bar e$; bounded-test dominated convergence gives the unique invariant law $\delta_{\bar e}$. Consequently, certainty stationary net assets equal $-\phi_C$.

For the corresponding risky economy, $S=\mathbb EA-\phi_R\geq-\phi_R\geq-\phi_C$, because shifted assets are nonnegative and the risky income floor is no greater than mean income. This gives weakly higher stationary assets at every subcritical admissible rate. At fixed positive wages, the upper-boundary theorem gives $S>0\geq-\phi_C$ for all rates sufficiently close to $\lambda$ from below, yielding the paper's qualified strict precautionary-assets comparison. It does not imply a general ordering across two risky income distributions. These are contracts A04 and A05, implemented with the benchmark module in milestone 09.

For the mean-income certainty economy, the stationary representative-agent benchmark is $r^{FI}=\lambda$ and $K^{FI}=K(\lambda)$. Verify the constant-consumption plan using the concavity inequality for utility and the deterministic present-value budget; an Euler equality alone is not a verification theorem. The certainty borrowing limit is generally $\min\{b,w/r\}$, not the risky-income limit with $\ell_-$. Since benchmark capital is positive, it is feasible under either nonnegative institutional debt cap.

Any stationary equilibrium of the risky economy must have $r<\lambda$ by Section 9, independently of the construction used to prove existence. Strictly decreasing capital demand gives
\[
K>K^{FI}.
\]
Moreover,
\[
\frac{d}{dK}\left(\frac{\delta K}{f(K)}\right)
=\frac{\delta[f(K)-Kf'(K)]}{f(K)^2}>0.
\]
Hence the gross saving/investment share is higher than in the certainty benchmark. Goods-market clearing follows from the household stationary budget and the firm's factor-payment identity: $\mathbb Ec+\delta K=f(K)$.

## 12. No-Ponzi and exact extension layer

### 12.1 No-Ponzi equivalence

For $r>0$, bounded labor income and the natural lower bound imply, pathwise on the event of feasibility,
\[
\sum_{t=0}^{T}R^{-t}c_t
=Ra_0+\sum_{t=0}^{T}R^{-t}w\ell_t-R^{-T}a_{T+1}.
\]
The consumption sums are nondecreasing and bounded above. Thus the discounted asset sequence has a finite nonnegative limit. It need not have limit zero.

For the converse, assets $a_t$ are measurable before $\ell_t$ is drawn. If the natural limit is violated with positive probability, first extract a fixed deficit $\eta>0$ on a positive-probability event. A sufficiently long string of incomes within a fixed neighborhood of $w\ell_-$ makes the discounted debt deficit exceed all possible discounted subsequent income, even if future income always equals its upper bound and consumption is zero. Independence gives this finite event positive conditional probability. The discounted wealth limit is then negative on a positive-probability event, contradicting no-Ponzi. The proof must retain the factor $w$ in the size of the low-labor neighborhood. This is a statement about adapted feasible plans, not an equivalence for arbitrary pathwise arrays with foresight.

### 12.2 Extensions with complete algebraic contracts

At $r=0$, effective income is $w\ell$ and the shifted household problem is independent of $b$. Therefore $S(b_2)-S(b_1)=-(b_2-b_1)$ at fixed wages. If two finite caps both exceed the natural debt limit at a fixed positive interest rate, their effective limits and hence their entire household problems coincide.

In a pure-exchange economy with government debt $d$ and lump-sum tax $rd$, use $c_t+a_{t+1}=Ra_t+w\ell_t-rd$. Under the tax-adjusted natural bound $a_t\geq d-w\ell_-/r$, the change of variables $x_t=a_t-d$ gives exactly the debt-free household problem and equilibrium clearing $\mathbb Ex=0$. Represent the taxed model with a general real asset floor, which may be positive; do not force its original debt-limit parameter to be nonnegative. The transformed debt-free problem satisfies the core nonnegative-shift convention. This proves the debt-neutrality correspondence in that particular borrowing regime; it does not prove neutrality under a fixed borrowing cap.

For the monetary reinterpretation, specify the real money stock, its gross real return, and the tax-financing identity before proving a budget correspondence. Do not use the capital-economy existence theorem for a different clearing condition without a separate argument.

For isoelastic utility and gross trend growth $G$, the Euler normalization has the factor $\beta R G^{-\sigma}$ and the transformed discount factor is $\widetilde\beta=\beta G^{1-\sigma}$. This is an algebraic identity, not an extension of the bounded-utility stationarity theorem to CRRA. A full growth theorem requires its own unbounded-utility analysis.

### 12.3 Claims intentionally not promoted to core theorems

The qualitative core does not prove global monotonicity of asset supply in the interest rate or borrowing limit; uniqueness of equilibrium; an aggregate risk-order theorem; a multiple-equilibrium witness; or all pathwise statements in the paper's footnotes. The supercritical pathwise result $\beta R>1$ has a short route from (M), Markov's inequality and Borel–Cantelli. The critical pathwise result $\beta R=1$ requires a separate adaptation of Chamberlain–Wilson's uncertainty argument. It remains a named extension, not a hidden premise of asset-supply divergence.

The stronger strict-increase description of both household policies above a threshold also remains a separate source claim until strictness has been established. The core uses the proved weak monotonicity and Lipschitz bounds. The release label must therefore say **core stationary theory**, with the source-coverage table attached, rather than claiming that every theoretical sentence or utility specification has been formalized.

## 13. Lean architecture and implementation policy

Use namespace `Aiyagari1994` and a clean project directory, separate from the failed implementation. Suggested module families are `Primitives`, `Budget`, `Analysis`, `Household`, `Stationary`, `Aggregate`, `Firms`, `Equilibrium`, `Diagnostics`, and `Extensions`. The theorem manifest supplies the declaration/module contracts. Names are project targets, not assertions that matching Mathlib declarations already exist.

The environment milestone pins a mutually compatible Lean version and Mathlib commit, records them, and proves small API examples before economic coding. Do not choose an unverified version number from this document. Public Mathlib documentation currently exposes Banach fixed points, probability measures with weak topology, Markov kernels, compactness of probability measures, and Prokhorov compactness. The installed pinned checkout, not the moving website, is the authority for exact signatures.

Use probability measures and pushforwards rather than informal distributions. Every real integral must come with the relevant integrability fact before it is interpreted economically. Classical choice is permitted only after a proved existence result. Generic analytic theorems may take their mathematical hypotheses as arguments; paper-level wrappers must discharge them from primitives.

No `sorry`, `admit`, custom `axiom`, kernel-check bypass, or unapproved replacement theorem is allowed in completed modules. Standard Lean foundations such as `propext`, `Classical.choice`, and `Quot.sound` are not defects; audit the exact transitive axiom list instead of advertising 'axiom-free' proofs. `assert_no_sorry` catches `sorryAx`, not economically circular assumptions. Manual adequacy review remains necessary.

`All.lean` imports only completed substantive modules. `Audit.lean` imports `All.lean` and checks every exported contract declaration with `#check`, `assert_no_sorry`, and `#print axioms`. Unfinished targets remain in the manifest, not in the build as placeholders. Staging a file in an 'experimental' directory is not a way to hide completed theorems' dependencies.

## 14. Milestone sequence and review gates

| Prompt | Task | Recommended reasoning |
|:------|:------------------------------------------------|:----------------------|
| 00 | Source hashes, clean environment, pinned toolchain, API probes | High |
| 01 | Primitive records, normalized budget, consistency witness | High |
| 02 | Bellman construction and lifetime verification | Extra-high |
| 03 | Policy order, right marginals, envelope/Euler, borrowing correction | Extra-high |
| 04 | Joint parameter continuity and uniform upper drift | Extra-high |
| 05 | Kernel, derived mixing, compact SLP theorem, global weak stability | Extra-high |
| 06 | Invariant-law continuity, cross-sectional bridge, aggregation | Extra-high |
| 07a | Zero-state audit and bounded-Jensen marginal argument | Extra-high |
| 07b | Critical nonstationarity by the two-shock-string argument | Extra-high |
| 08 | Asset-supply boundary limits by tightness and normalized limits | Extra-high |
| 09 | Firms, both existence theorems, benchmark, headline comparisons | Extra-high |
| 10 | No-Ponzi equivalence and exact borrowing/debt extensions | Extra-high for no-Ponzi; High for algebra |
| 11 | Release audit, synchronized proof ledger and human-readable PDF | High |

Execute one prompt per milestone. Each produces a build log, declaration inventory, assumption/axiom audit, updated proof ledger, and a report against this architecture. Stop at the milestone boundary and submit the result for review. Helper lemmas and API choices belong to Codex; changes to the mathematical assumptions, scope, or conclusion require an explicit design review. A blocker report gives the precise failed lemma and attempted implementation route, not a request to let Codex weaken the economics.

The supplied manifest contains 52 core contracts, two source-diagnostic contracts, and three exact-extension contracts. A core release also requires the diagnostics before it labels the source correction certified.

Statuses are `UNFORMALIZED`, `IN_PROGRESS`, `KERNEL_CHECKED`, `REVIEW_READY`, `GREEN`, and `BLOCKED`. `GREEN` requires both kernel checking and an accepted adequacy review. The final core release has no amber or closure-assumed theorem. An excluded or deferred source claim is visible in the coverage manifest; it is never reclassified as completed just because the core builds.

## 15. References and API locators

Aiyagari, S. Rao (1993). *Uninsured Idiosyncratic Risk and Aggregate Saving*. Federal Reserve Bank of Minneapolis Working Paper 502, revised December 1993.

Aiyagari, S. Rao (1994). “Uninsured Idiosyncratic Risk and Aggregate Saving.” *Quarterly Journal of Economics* 109(3), 659–684.

Benveniste, Lawrence M., and José A. Scheinkman (1979). “On the Differentiability of the Value Function in Dynamic Models of Economics.” *Econometrica* 47(3), 727–732.

Chamberlain, Gary, and Charles A. Wilson (2000). “Optimal Intertemporal Consumption under Uncertainty.” *Review of Economic Dynamics* 3(3), 365–395. Later published source, not silently equated with the 1984 working paper cited by Aiyagari.

Clarida, Richard H. (1987). “Consumption, Liquidity Constraints and Asset Accumulation in the Presence of Random Income Fluctuations.” *International Economic Review* 28(2), 339–351.

Clarida, Richard H. (1990). “International Lending and Borrowing in a Stochastic, Stationary Equilibrium.” *International Economic Review* 31(3), 543–558.

Miller, Bruce L. (1976). “The Effect on Optimal Consumption of Increased Uncertainty in Labor Income in the Multiperiod Case.” *Journal of Economic Theory* 13, 154–167.

Schechtman, Jack, and Vera L. S. Escudero (1977). “Some Results on ‘An Income Fluctuation Problem’.” *Journal of Economic Theory* 16(2), 151–166.

Sibley, David S. (1975). “Permanent and Transitory Income Effects in a Model of Optimal Consumption with Wage Income Uncertainty.” *Journal of Economic Theory* 11, 68–82.

Stokey, Nancy L., and Robert E. Lucas, Jr., with Edward C. Prescott (1989). *Recursive Methods in Economic Dynamics*. Harvard University Press.

Official Mathlib and Codex API locators, inspected on September 11, 2026, are recorded in `contracts/api_sources.json`. Prompt 00 checks their exact signatures against the pinned checkout; no installed API or Lean build is presumed by this document.



--- docs/lean_interfaces.md ---
# Lean-facing interface design

This file specifies representations and typed relationships. It is **not compiled Lean code**. Prompt 00 determines the exact Mathlib spelling of probability/weak-topology APIs; Codex may adapt these representations without changing mathematical domains or quantifiers. Public target declarations are named in `contracts/theorems.json`.

## Base spaces and record split

Use the fixed state `NNReal` (or the equivalent nonnegative-real subtype). Use a compact labor subtype `{l : Real // l_min <= l ∧ l <= l_max}` carrying a probability measure. The lower/upper endpoints are numeric primitive data; positivity and order live in an income-assumption record. Endpoint-neighborhood positivity is a separate nondegeneracy hypothesis, not needed for the Bellman fixed point. Keep the labor law fixed in price-continuity results.

A useful split is:

- `UtilityData`: function `Real → Real`, with every economic property restricted to `Set.Ici 0`; evaluate it at coerced nonnegative consumption. Values at negative arguments are irrelevant and must not enter a theorem. This representation permits ordinary real differentiation on `Set.Ioi 0`.
- `UtilityBase`: continuity, boundedness, strict increase and strict concavity.
- `UtilitySmooth`: C1 and positive derivative at positive consumption.
- `UtilityCurvature`: C2 and eventual relative-risk-aversion bound.
- `IncomeData`: compact labor type and probability measure.
- `IncomeSupport`: positive essential endpoints; optional mean-one normalization.
- `NormalizedPrices`: `R>0`, plus a nonnegative continuous effective-income function on the fixed labor space. For the paper's affine model, store slope `w>0` and intercept `k` with `e(l)=w*l+k>=0`.
- `OriginalPrices`: net rate, wage and effective debt limit, with a proved map into `NormalizedPrices` using `k=-r*phi`.
- `FiniteCapFamily` and `NaturalCapFamily`: functions constructing original/normalized prices from their primitive arguments, **not** records containing stationary-law conclusions.
- `ProductionData` / `ProductionRegularity`: technology and its explicit neoclassical assumptions.

The normalized representation `(R,w,k)` is important: the natural-limit lower-boundary theorem has `phi→infinity`, but `k=-w*l_min` remains bounded. Continuity and uniform drift are stated for normalized parameters first. Keep `phi` outside the Bellman parameter so it only re-enters when converting shifted to net assets.

## Real derivatives versus the nonnegative state subtype

`NNReal` is not a real normed vector space. Do not apply ordinary real differential calculus directly to a function whose domain is `NNReal`. The default utility and production representations are `Real → Real`, with continuity/concavity/boundedness/nonnegativity restricted to the economic domain and differentiability only on strictly positive inputs. The Bellman state and feasible controls remain nonnegative.

For the bounded continuous value function on `NNReal`, use the real extension `x ↦ V(x.toNNReal)` when a real-domain derivative theorem is needed. This extension agrees with the economic function on nonnegative inputs; claim concavity only there, not on all real numbers. Define the right marginal by one-sided secant limits, not by the ordinary `deriv` operator before differentiability has been established. An ordinary derivative at a point of nondifferentiability must never silently become a zero marginal.

## Canonical objects versus proof records

After `H02`, define `valueFunction (model) : BoundedContinuousFunction NNReal Real` by the proved fixed-point constructor. After `H04`, define `assetPolicy (model) (z) : NNReal` by unique compact maximization, with a theorem `assetPolicy_le_state`. Define consumption by a nonnegative subtype construction using that bound, not truncated subtraction with unproved positivity.

A proposed dependency chain is:

```text
UtilityData + UtilityBase + IncomeData + NormalizedPrices
    -> bellmanOperator
    -> valueFunction and its uniqueness proof
    -> assetPolicy and argmax proof
    -> consumptionPolicy
    -> householdKernel
```

An optional record may bundle a *proved* object and its specification after construction. It must not be accepted as an independent primitive argument of the paper's existence theorem.

## Marginal types

Use a nonnegative extended-real right marginal (`ENNReal`, or an equivalent explicit finite/infinite sum type) before establishing finiteness. At each positive resource state concavity proves it finite; convert to a real-valued `rightMarginalValue` there. At zero, preserve the case distinction until N01 proves finite marginal or stationary null mass.

For (M), first use `lintegral` of nonnegative difference quotients. Prove the bound by a finite marginal; only then obtain a Bochner/real integral and rewrite. Never invoke `integral_undef` as an economic argument.

## Feasible plans

For fixed initial resources, date-t controls are measurable functions of length-t future labor histories (current period zero is already summarized by the initial resource state). States are recursively generated from past controls and newly drawn labor. Require feasibility almost everywhere for each finite history law. A full plan is a sequence of such controls; expected lifetime utility is the limit of finite discounted sums. Prove compatibility of finite products and one-step integration to obtain H05.

For the original No-Ponzi theorem, retain the paper's timing explicitly: `a_t` is measurable before `l_t`, while `c_t` and `a_(t+1)` can depend on `l_t`. This requires either an infinite product probability space or an abstract filtration with conditional independent labor; the latter must be instantiated by the iid product construction. No-Ponzi's tail event cannot simply be defined on one finite history.

## Kernels and invariant laws

Use `ProbabilityTheory.Kernel` with an `IsMarkovKernel` instance after checking the installed API. Define `IsInvariant (P) (mu)` by equality of the pushed law and `mu`, or equivalent equality of bounded-continuous test integrals after a proved separation lemma. The latter equivalence must not be assumed.

A generic `compact_monotone_feller_stability` theorem takes a compact interval, a Markov kernel, Feller and monotonicity proofs, and a **mathematical crossing hypothesis**. The paper wrapper derives those arguments. For the full-space law, define `stationaryLaw` only after S05 proves existence and uniqueness. Calling `Classical.choose` on an assumed existence field is prohibited.

## Aggregation and equilibrium

Define shifted and net law pushforwards explicitly. `stationaryAssetSupply` is the real integral of `A-phi`, accompanied by a compact-support/integrability theorem. Its domain is the impatient normalized model plus the effective debt shift, not an arbitrary supplied asset-supply curve.

The equilibrium type has a rate in `(-delta,infinity)`, the firm-derived wage and capital, a probability law, household optimality/canonical-policy identity, invariance, required first-moment integrability, and clearing. It must **not** contain `r<lambda`, `beta*R<1`, or a unique-equilibrium assertion. The existence function may construct equilibria on the subcritical branch; G04 must quantify over the larger equilibrium type.

## Assumption tags and declaration granularity

`contracts/assumptions.json` gives named mathematical profiles. In the theorem manifest, tags are dependency/context annotations, not instructions to concatenate every profile into one premise. Branches concerning finite and natural limits have their own arguments. Reusable sublemmas must use the weakest profile they need; final exported signatures must expose all transitive economic hypotheses actually used.

An ID can export one umbrella theorem plus clearly named helper declarations when its statement has several clauses. Keep the contracted main name as the audit anchor. Do not make it a vacuous conjunction of unrelated assumed results. Record the exact final elaborated signature in the ledger and compare it with the contract before review.



--- docs/dependency_graph.md ---
# Dependency graph

The exact acyclic edges are in `contracts/theorems.json`. The thematic graph is:

```text
P01–P03: primitives, budgets, nonvacuity
    |
H01–H05: Bellman fixed point, optimal policy, lifetime verification
    |
H07–H14: order, right value marginals, envelope, Euler, thresholds
    |                         \
H06 + D02–D03: continuity/drift  N01–N04: zero state and bounded Jensen
    |                           |
S01–S05: kernel, mixing,         N05–N07: critical nonstationarity
         unique stable law       |
    |                            |
S06 + A01–A03: law continuity,   |
               aggregation       |
    \____________________________/
                    |
B01–B03: tightness and asset-supply boundary limits
                    |
F01–F02 + G01–G08: firms, noncircular equilibrium, existence,
                  rate/capital/gross-saving comparisons

P01 + feasible-history probability -> NP01–NP03: No-Ponzi equivalence
Core household/aggregation         -> E01–E03: exact extension identities
H02–H04                            -> D01: continuous-state Inada diagnostic
```

D01 is a diagnostic, not a premise of equilibrium existence. The critical nonstationarity proof does not use subcritical invariant-law existence, curvature, or compact asset bounds. Keeping this separation prevents an equilibrium conclusion from being smuggled into a stationary-law assumption.



--- contracts/assumptions.json ---
{
  "version": "1.0",
  "profiles": {
    "BASIC": "0<beta<1; fixed compact positive labor support; w>0; R>0; phi>=0; effective income e=w*l-(R-1)*phi>=0; utility real-valued, continuous, bounded, strictly increasing and strictly concave on NNReal.",
    "SMOOTH": "U is C1 on positive consumption with strictly positive derivative. C2 may be used only by curvature modules. No differentiability at zero is assumed.",
    "CURVATURE": "U is C2 on positive consumption and eventually -c*U_second(c)/U_prime(c)<=M for finite M and positive threshold. This is explicitly stronger regularity for the drift branch.",
    "NONDEGENERATE": "l_min<l_max are essential endpoints: each endpoint neighborhood has positive probability. Atoms are allowed, density is not required.",
    "IID": "Future labor histories carry product law nu^n; future draws are independent of predetermined wealth and past histories.",
    "IMPATIENT": "beta*R<1. Only stationary existence, drift and associated subcritical results use this restriction; Bellman and equilibrium definition do not.",
    "LOCAL_IMPATIENT": "A specified neighborhood has R bounded above/below away from zero, beta*R<=gamma_star<1, and uniformly bounded effective income and its span.",
    "THRESHOLD": "Either e_min>0 or the right derivative of U at zero is finite.",
    "ATOM_INADA": "e_min=0, positive probability of zero effective income, and U has infinite right derivative at zero.",
    "FINITE_CAP": "b>=0 is finite and phi=min(b,w*l_min/r) for r>0, phi=b for -1<r<=0.",
    "NATURAL_CAP": "r>0 and phi=w*l_min/r; equivalently normalized effective income is w*(l-l_min).",
    "LABOR_MEAN_ONE": "Integral of labor under nu is one; imposed for equilibrium aggregation, not Bellman existence.",
    "PRODUCTION": "f(0)=0; f continuous on NNReal and C2 on positive K; f_prime>0, f_second<0; f_prime tends to infinity at zero and to zero at infinity; 0<delta<1.",
    "PATH_FEASIBILITY": "Measurable nonanticipative plan; assets a_t measurable before labor_t; consumption after current labor; budget holds almost surely for every t; c_t>=0. Natural bound or no-Ponzi appears separately in each implication.",
    "EXACT_DIAGNOSTIC": "beta=1/2; R=3/2; w=3/2; l uniform on [2/3,4/3]; phi=2; U(c)=sqrt(c)/(1+sqrt(c)), U(0)=0.",
    "PURE_EXCHANGE_DEBT": "r>0, fixed w, debt d, tax r*d, tax-adjusted natural bound a>=d-w*l_min/r; bond clearing E[a]=d; not the fixed-cap capital economy."
  },
  "prohibited_primitive_fields": [
    "valueFunction",
    "assetPolicy",
    "policyMonotone",
    "uniformAssetBound",
    "mixing",
    "stationaryLaw",
    "invariantUnique",
    "assetSupplyContinuous",
    "assetSupplyDiverges",
    "equilibriumExists",
    "equilibriumRateBelowImpatience"
  ]
}



--- reviews/03a_acceptance.md ---
# M03A external acceptance

Decision: ACCEPT. Review date: 2026-09-11.

H07: GREEN. H08: GREEN. Prior accepted contracts remain GREEN.

Reviewed archive: tmp_zip/review_m03a.zip

SHA-256: 9ce253a77730418287aaff89e5d5d8cfb8a01bd55d2e47437407bf2e35eb32a5

## Substantive reviewer conclusions

1. H07 is adequate: shifted savings and consumption are nondecreasing and both satisfy the intended weak 1-Lipschitz difference bounds. No derivative or strict-monotonicity claim is included.
2. H08 is adequate: at positive states the right marginal is constructed from concave secants, is finite, strictly positive, nonincreasing, and genuinely right-continuous.
3. The separate zero-state marginal is `zeroRightMarginal : ENNReal`. It may be infinite. Positive-state marginals converge to this extended zero marginal.
4. No blocker remains.

## Mandatory qualification

Never use `rightMarginalValue m 0` as the economic zero-state marginal. The economic boundary object is `zeroRightMarginal`. Every later argument at the zero-resource boundary must explicitly preserve this distinction.

H09 and all later contracts remain UNFORMALIZED. H06 remains UNFORMALIZED. The next authorized mathematical gate is M03B1/H09 only. This acceptance does not authorize later contracts or change any theorem, assumption, dependency, or quantifier.

The user supplied this external mathematical, economic and Lean adequacy decision. Codex records it without independently awarding mathematical acceptance. Verification evidence is in `reports/logs/03a_acceptance/`.


H09 mandatory proof route: keep original consumption and save an additional initial h;
divide the Bellman comparison by h; apply monotone convergence to nonnegative concave
difference quotients as h ↓ 0. Initially work with the nonnegative extended integral.
Only after a finite left marginal proves conditional finiteness may you convert to a real integral.
The theorem holds for all R > 0. No beta*R < 1 assumption and no consumption-positivity
assumption. At the zero-resource boundary use the separate extended zeroRightMarginal.

STOP after M03B1 REVIEW_READY. The general prompt below/above does not authorize another gate. Do not alter orchestration, tools, accepted theorem bodies, or contract semantics. Mark only assigned status REVIEW_READY. Use exact ledger status line '**Status:** REVIEW_READY.' in assigned section. Add every new exported declaration to Audit.lean with #check, assert_no_sorry and #print axioms. Put all new helper files under Aiyagari1994/Analysis/M03B1/. Append to a shared accepted module only when the assigned target uses that exact module. Capture all evidence and prepare the required review ZIP. No self-awarded GREEN.
