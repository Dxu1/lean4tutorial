# M02A structural and forward-compatibility audit

Scope: H01-H04 only, using the user-approved split of M02. M01 is externally
accepted; H05 and Milestone 03 are deferred. No economic mechanism, primitive
record, price normalization, state space, utility domain or theorem contract is
changed. The predecessor is the commit in `reports/M01_BASE`.

## Primitive boundary

All four economic wrappers take only `m : HouseholdPrimitives`. The existing
`Primitives/Basic.lean` is unchanged. Its fields supply discounting, bounded
continuous strictly increasing/strictly concave utility on nonnegative real
consumption, a probability law on the compact labor interval, and positive
normalized prices with nonnegative effective income. Optional smoothness,
curvature, income nondegeneracy, mean-one normalization and finite-history IID
results are not premises or proof dependencies of the new wrappers.

No `CoreRegularity`, beta*R<1, Inada condition, finite derivative at zero,
stationary law, asset bound, supplied value function, or supplied policy occurs
in an economic theorem premise. The generic maximum/argmax lemmas assume ordinary
mathematical continuity and compactness; Bellman and Policy discharge those
hypotheses from primitives and proved value-function properties.

## Canonical definitions and timing

`continuation m v a` integrates `v (m.prices.nextResources a l)` against the
arbitrary primitive labor law. `bellmanObjective m v z a` is current utility plus
beta times this integral. On the feasible set a<=z, `bellmanObjective_feasible`
proves exactly U(z-a)+beta*E[v(R*a+e(l))]. All actions are NNReal shifted assets;
net assets would be a-phi. No transition uses current consumption in place of
savings. The objective has a continuous truncated-consumption extension outside
its feasible set, but every maximization and economic statement restricts a<=z.
No utility evaluation at negative consumption is used.

`bellmanOperator m` is constructed as a bounded continuous self-map on the entire
NNReal state space. `valueFunction m` is the installed Banach constructor for
that operator and its proved contraction. `assetPolicy m z` is classical choice
from a proved unique optimizer theorem. Neither object is a primitive field.
`consumptionPolicy` is truncated subtraction accompanied by its exact real
subtraction identity and feasibility/budget proofs.

## Integration, compactness and limits

The transition is jointly continuous; composing any bounded continuous v keeps
it jointly continuous and uniformly bounded by ||v||. For each action, labor
integrability is proved using continuity on the compact labor subtype and the
finite probability measure. Parametric integral continuity uses Mathlib's compact
parametric integral theorem, with all labor in its compact subtype. Integral
subtraction, addition, order, and scaling have explicit integrability proofs at
their application sites. No `integral_undef` argument supplies an expectation.

The compact share space is [0,1]; the proved action/share correspondence covers
all a in [0,z], including the singleton at z=0. Compact maximum values are
continuous by the installed `IsCompact.continuous_sSup` theorem and attained by
the extreme-value theorem. The share is never the economic policy. Bounded U
and v give a global Bellman bound independent of z; no bounded-state premise is
introduced. The contraction compares maximizers with the same action under the
other candidate function; it does not interchange max and subtraction.

Banach convergence in the bounded-continuous supremum metric is explicitly
converted to uniform convergence. The zero-start iterates are concave and weakly
increasing; their inequalities pass to the limit using this proved convergence.
`NNRealConcave` quantifies over every pair of nonnegative real weights summing to
one. `NNRealConcave.real_combination` exposes the ordinary theta in [0,1] formula.
The property is neither midpoint-only nor a grid property. The strict-increase
proof keeps the lower state's saving action and consumes the additional resources.

## Policy continuity

Strict current utility concavity and weak continuation concavity establish
strict concavity in actual assets for every positive pair of convex weights.
At zero, the feasible action set is a singleton. The auxiliary share optimizer
is used only on strictly positive resources, where multiplication by the state
is injective. A reusable unique-argmax continuity theorem proves that the inverse
image of any closed set is the projection of a closed subset of the parameter
space times the compact choice space; compact projection is closed. The share
optimizer's continuity therefore implies positive-state asset continuity.
At zero, 0<=A(z)<=z gives convergence by squeezing. Value continuity alone is
never used to infer policy continuity.

## Source scope and remaining qualifications

Visually inspected A94 printed pp. 666-667 / PDF pp. 9-10: normalized budget and
transition (4), Bellman equation (5), asset choice (6) and transition (7).
Also inspected A93 printed pp. 37-38 / PDF pp. 38-39, the manifest's Appendix
Proposition 2 context. That appendix includes differentiability, envelope and
later drift statements which M02A does not claim. The analytic existence,
contraction and continuity arguments here are explicit reconstructions under
the approved bounded-utility BASIC profile.

No finite-grid or finite-labor substitution, invariant distribution, absorbing
set, differentiation of V or A, or lifetime-optimality theorem is introduced.
P03 remains a consistency witness; its two-point distribution is not used by
these proofs. H05 must still verify the canonical policy against all measurable
nonanticipative feasible plans. M02A kernel checking does not itself grant GREEN.
