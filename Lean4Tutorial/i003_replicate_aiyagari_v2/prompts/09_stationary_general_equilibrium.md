# Milestone 09: stationary general equilibrium

Recommended reasoning: **Extra-high**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** Milestones 01–08 accepted; both boundary limits and all household optimality/invariance constructions are green.

**Contract IDs:** A04, A05, F01, F02, G01, G02, G03, G04, G05, G06, G07, G08

## Work

Implement architecture §11. Files: `Firms/Neoclassical.lean`, `Equilibrium/{Definition,LowerBracket,Existence,CertaintyBenchmark,MainTheorem,Saving}.lean`.

## Firm construction and an equilibrium type that does not assume its result

Construct K(r) as the unique positive solution to f_prime(K)=r+delta for every r>-delta. Derive existence from Inada/end limits and strict derivative decrease; derive continuity of the inverse, strict decrease of K, wage positivity and wage continuity. Verify competitive profit maximization under the constant-returns technology, rather than merely defining prices by unexplained equations.

Define stationary equilibrium using the canonical lifetime-optimal policy, firm conditions, invariant law, first moments needed for clearing and capital clearing. The type allows every r>-delta. It must NOT contain r<lambda, beta*R<1, a monotone asset-supply assumption or equilibrium uniqueness. Prove the resource versus net-asset/current-labor equivalence with the cross-sectional bridge. For a general integrable invariant law, derive the budget identity directly or identify it with the canonical law after proving it is subcritical.

Also verify the explicit production witness `f(K)=sqrt(K), delta=1/2`, and combine it with P03 to demonstrate that the full equilibrium primitive class is nonempty.

## Fixed-cap existence with a derived lower bracket

Prove f(K)/K→0 at infinity: for a fixed K0, concavity gives `f(K)<=f(K0)+f_prime(K0)*(K-K0)`, and f_prime(K0) can be made arbitrarily small. Choose K_L large with f_prime(K_L)<delta and f(K_L)<delta*K_L. Set r_L=f_prime(K_L)-delta in (-delta,0), and w_L=f(K_L)-K_L*f_prime(K_L)>0.

Use the canonical subcritical stationary budget and nonnegative consumption:
`S(r_L)<=w_L/(-r_L)<K_L`.
Prove the last inequality by rearranging f(K_L)<delta*K_L. It is valid for every finite institutional b; do not assume a lower-end excess-supply sign.

Along the firm wage schedule, the finite effective debt limit tends to a finite value as r approaches lambda below. B02 makes supply diverge while K(r) has a finite positive limit. Choose an upper endpoint with positive excess supply and apply the IVT using A03/P02 and firm continuity. Construct the full equilibrium object, not only a root of an arbitrary supply curve. Its rate can be negative; uniqueness is not claimed.

## Natural-limit existence

As r→0+, K(r) and w(r) tend to finite positive values because delta>0. B03 yields negative excess supply; B02 supplies the positive upper sign. Obtain an equilibrium with 0<r<lambda and construct all components.

## Partial-equilibrium certainty comparison (A04–A05)

Instantiate the base household with deterministic labor equal to the risky labor mean. Use its correct certainty debt limit: for positive r, min(b,w*meanLabor/r) in the finite-cap family and w*meanLabor/r in the natural family. The base income type must permit a degenerate law; nondegeneracy is a separate risky-model hypothesis.

At beta*R<1, its deterministic resource map h(z)=R*A(z)+eBar satisfies h(eBar)=eBar and h(z)<z above eBar by S02. Monotone iteration from every finite initial state tends to eBar. For arbitrary initial laws use bounded-test dominated convergence; any invariant law must therefore be the point mass at eBar. Shifted saving is zero there, hence certainty mean net assets are minus the certainty effective limit. No curvature or mixing hypothesis is needed for this deterministic result.

The risky effective debt limit is weakly below the certainty limit, since minimum labor is no larger than mean labor. Nonnegative shifted saving gives risky S>=-phiRisk>=-phiCertainty. Finally B02 makes risky S strictly positive for all r sufficiently close to lambda below, while certainty assets remain nonpositive. This gives the qualified strict comparison without convex marginal utility. Do not confuse it with an ordering across two nondegenerate risky income distributions.

## Universal headline result and benchmark

For ANY equilibrium of the unrestricted type, invariance plus N07 implies beta*R<1 and hence r<lambda. This quantification must not be limited to the equilibria just constructed.

For deterministic mean labor one, verify the stationary benchmark r=lambda, K_FI=K(lambda), c_FI=f(K_FI)-delta*K_FI>0. Use the global utility supporting-line inequality and the deterministic present-value budget to prove optimality of constant consumption from the benchmark asset level. Euler equality alone is insufficient. The certainty natural debt limit uses mean income, not the risky l_min, but positive benchmark K is feasible.

Strictly decreasing K(r) gives K>K_FI. Derive that delta*K/f(K) increases strictly using its derivative `delta*(f(K)-K*f_prime(K))/f(K)^2>0`. State the conclusion for gross saving/investment; do not label it positive stationary net saving. Finally derive E c+delta*K=f(K) from stationary budgets and factor payments.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
