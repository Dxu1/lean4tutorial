# Static Equilibrium Existence: Current Closure Assumption and Primitive Upgrade Path

Repository milestone:
M5

Current grading:
- Uniqueness: COMPLETE — GREEN
- Existence: COMPLETE — AMBER
- Overall M5: COMPLETE — AMBER

Current committed implementation:
4d2dafe6c1c38e13875afac15c9545bbe7a6160b

Status of this document:
Documentation and future-proof design only. The proposed primitive existence
route has not yet been formalized in Lean.

## Purpose

M5 proves that the static reduced equilibrium is unique under the maintained
economic, shock, and matching assumptions. It proves existence only after
adding an explicit continuity-and-bracket bundle. This note records exactly
what that bundle assumes, why existence remains amber, and a possible route to
deriving its lower endpoint from more primitive economic conditions.

The proposed route is a design target. None of its new assumptions,
definitions, or theorems currently exists in the Lean development.

## Current M5 existence proof

The committed declaration is:

```lean
structure StaticExistenceAssumptions
    (P : Primitives) : Prop where

  q_continuousOn_pos :
    ContinuousOn P.q (Set.Ioi 0)

  lower_crossing :
    ∃ d0 : ℝ,
      d0 < P.epsUpper ∧
      0 < P.jobDestructionTheta d0 ∧
      0 < P.staticCrossingResidual d0
```

Let

\[
H(d)=\int (x-d)_+\,dF(x),
\]

where `P.shock` is the probability law and integration with respect to the
induced CDF \(F\) is represented in Lean by integration against `P.shock`.
The job-destruction equation implies market tightness

\[
\Theta_{JD}(d)=
\frac{
  p+\sigma d-b+
  \frac{\lambda\sigma}{r+\lambda}H(d)
}{
  \frac{\beta c}{1-\beta}
}.
\]

Lean calls the numerator `jobDestructionNet d` and the ratio
`jobDestructionTheta d`. Evaluating the product form of the job-creation
condition along this JD curve gives the scalar residual

\[
\Phi(d)=
q(\Theta_{JD}(d))
\frac{(1-\beta)\sigma}{r+\lambda}
(\varepsilon_u-d)-c,
\]

called `staticCrossingResidual d` in Lean.

### A. `q_continuousOn_pos`

This field supplies continuity of \(q\) on economically relevant positive
market tightness. Combined with continuity of \(\Theta_{JD}\), it makes
\(\Phi\) continuous on a bracket where \(\Theta_{JD}(d)>0\).

### B. `lower_crossing`

This field supplies a point \(d_0\) satisfying

\[
d_0<\varepsilon_u,\qquad
\Theta_{JD}(d_0)>0,\qquad
\Phi(d_0)>0.
\]

Lean independently proves

\[
\Phi(\varepsilon_u)=-c<0.
\]

Strict increase of \(\Theta_{JD}\) preserves positive tightness between
\(d_0\) and \(\varepsilon_u\). The intermediate value theorem therefore
produces an interior point \(d^*\) with

\[
\Phi(d^*)=0.
\]

The resulting cutoff and JD-implied tightness construct a
`ReducedEquilibrium`; M4 reconstruction then constructs a `ValueEquilibrium`.

`lower_crossing` is not circular. It does not assume a zero, a
`ReducedEquilibrium`, or nonemptiness of an equilibrium type. It assumes a
strictly positive residual at one endpoint of a bracket. Nevertheless, it is
an analytic closure assumption: it supplies the missing sign that guarantees
the JD and JC curves cross, and that sign is not currently derived from the
primitive model assumptions. This is why existence is COMPLETE — AMBER.

## Why uniqueness does not imply existence

M5 proves that the JD locus is strictly increasing and the JC locus is
strictly decreasing. Hence there can be at most one intersection. Opposite
slopes do not guarantee that an intersection exists.

For example, suppose \(q\) is positive, continuous, and strictly decreasing,
but bounded above. If vacancy cost \(c\) is sufficiently high, the
job-creation residual can remain negative at every admissible cutoff. The
curves then satisfy the required slope restrictions but never cross.

The paper's general setup assumes that \(q\) is decreasing and imposes an
elasticity restriction. Equations (10) and (13) are stated to uniquely
determine \(\theta\) and \(\varepsilon_D\), and Figure 1 depicts a crossing.
Figure 1's slope argument supports uniqueness, but the general setup does not
state a complete endpoint condition proving existence. In particular, the
paper does not explicitly assume an Inada condition.

## Candidate matching-boundary assumption

A natural proposed strengthening is

\[
\lim_{\theta\downarrow 0}q(\theta)=+\infty.
\]

Economically, a vacancy is filled arbitrarily quickly when market tightness is
arbitrarily small. This is the usual vacancy-filling Inada property for a
Cobb–Douglas matching technology.

A Lean-oriented candidate bundle is:

```lean
structure MatchingBoundaryAssumptions
    (P : Primitives) : Prop where

  q_continuousOn_pos :
    ContinuousOn P.q (Set.Ioi 0)

  q_tendsto_at_zero :
    Tendsto P.q
      (nhdsWithin 0 (Set.Ioi 0))
      atTop
```

This structure is proposed and unimplemented. Its exact filter notation may
be adjusted during implementation, for example by using Mathlib's preferred
right-neighborhood notation. Existing matching restrictions would remain in
force: \(q(\theta)>0\) for \(\theta>0\), strict decrease of \(q\) on positive
tightness, and monotonicity of the worker meeting rate \(\theta q(\theta)\).
The new substantive addition is the right-hand Inada limit.

> **Important: the Inada condition on `q` alone cannot establish equilibrium
> existence.** The JD-implied tightness must be positive somewhere below
> `epsUpper`. If `jobDestructionNet(d)` is nonpositive for every admissible
> `d`, no behavior of `q` on positive tightness can create an equilibrium.

The separate primitive profitability condition is

\[
p+\sigma\varepsilon_u>b.
\]

A possible Lean name, not implemented in this task, is:

```lean
def Primitives.UpperJobProductivityExceedsUnemploymentIncome
    (P : Primitives) : Prop :=
  P.b < P.p + P.sigma * P.epsUpper
```

Under the almost-sure upper-bound assumption, expected excess satisfies

\[
H(\varepsilon_u)=0.
\]

Consequently,

\[
\operatorname{jobDestructionNet}(\varepsilon_u)
=p+\sigma\varepsilon_u-b.
\]

The profitability condition therefore implies
`jobDestructionTheta epsUpper > 0`, because its denominator is positive under
the core assumptions. Economically, the most productive new job has flow
productivity above unemployment income. The current
`CoreEconomicAssumptions` does not include this condition.

## Proposed proof of `lower_crossing` from primitive conditions

The proposed sufficient conditions are:

1. the existing core economic assumptions;
2. the existing shock assumptions;
3. the existing matching positivity and strict-decrease assumptions;
4. continuity of \(q\) on positive tightness;
5. \(q(\theta)\to+\infty\) as \(\theta\downarrow0\); and
6. \(p+\sigma\varepsilon_u>b\).

### Step 1: show the JD net value is negative at a sufficiently low cutoff

The M5 one-Lipschitz theorem for \(H\) gives, for \(d\le0\),

\[
H(d)\le H(0)-d.
\]

Thus

\[
\operatorname{jobDestructionNet}(d)
=p+\sigma d-b+
\frac{\lambda\sigma}{r+\lambda}H(d)
\]

is bounded above by a constant plus

\[
\frac{\sigma r}{r+\lambda}d.
\]

The coefficient is positive, so this upper bound tends to negative infinity
as \(d\to-\infty\). A finite cutoff \(d_L\) therefore exists with negative JD
net value. This argument reuses the M5 Lipschitz result and needs no new
dominated-convergence theorem.

### Step 2: show the JD net value is positive at `epsUpper`

The upper-support result gives \(H(\varepsilon_u)=0\). The primitive
profitability condition then yields

\[
\operatorname{jobDestructionNet}(\varepsilon_u)
=p+\sigma\varepsilon_u-b>0.
\]

### Step 3: obtain a zero-tightness boundary cutoff

The JD net value is continuous and strictly increasing. The two endpoint signs
therefore give a unique \(\bar d<\varepsilon_u\) satisfying

\[
\operatorname{jobDestructionNet}(\bar d)=0,
\qquad
\Theta_{JD}(\bar d)=0.
\]

For \(d\) immediately above \(\bar d\), \(\Theta_{JD}(d)>0\), and continuity
implies

\[
\Theta_{JD}(d)\to0
\quad\text{as }d\downarrow\bar d.
\]

### Step 4: use the Inada condition on `q`

Since \(q(\theta)\to+\infty\) as \(\theta\downarrow0\), while
\(\varepsilon_u-\bar d>0\),

\[
\Phi(d)\to+\infty
\quad\text{as }d\downarrow\bar d
\text{ from above}.
\]

Hence there is a point \(d_0\in(\bar d,\varepsilon_u)\) such that

\[
\Theta_{JD}(d_0)>0,
\qquad
\Phi(d_0)>0.
\]

This is exactly the current `lower_crossing` field.

### Step 5: reuse the existing M5 existence theorem

The derived lower crossing and continuity of \(q\) construct a
`StaticExistenceAssumptions P`. The existing theorem

```lean
reducedEquilibrium_nonempty A D X
```

then produces a reduced equilibrium. The current IVT proof need not change.

## Lean-ready future theorem targets

The following are design targets only and remain unimplemented:

```lean
theorem Primitives.jobDestructionNet_eventually_neg_atBot
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) :
    ∀ᶠ d in atBot,
      P.jobDestructionNet d < 0
```

An equivalent finite-witness interface may be easier to use initially:

```lean
theorem Primitives.exists_jobDestructionNet_neg
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) :
    ∃ d : ℝ,
      P.jobDestructionNet d < 0
```

```lean
theorem Primitives.jobDestructionNet_epsUpper_pos
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (hUpper :
      P.b < P.p + P.sigma * P.epsUpper) :
    0 < P.jobDestructionNet P.epsUpper
```

```lean
theorem exists_zero_tightness_cutoff
    ... :
    ∃ dBar < P.epsUpper,
      P.jobDestructionTheta dBar = 0
```

```lean
theorem lower_crossing_of_matching_inada
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    (B : MatchingBoundaryAssumptions P)
    (hUpper :
      P.b < P.p + P.sigma * P.epsUpper) :
    ∃ d0 : ℝ,
      d0 < P.epsUpper ∧
      0 < P.jobDestructionTheta d0 ∧
      0 < P.staticCrossingResidual d0
```

```lean
theorem staticExistenceAssumptions_of_matching_inada
    ... :
    StaticExistenceAssumptions P
```

## Standard matching-function specialization

For the vacancy-filling form

\[
q(\theta)=\kappa\theta^{-\eta},
\qquad
\kappa>0,quad 0<\eta<1,
\]

one has:

- \(q(\theta)>0\) for \(\theta>0\);
- \(q\) strictly decreases;
- \(q(\theta)\to+\infty\) as \(\theta\downarrow0\); and
- \(\theta q(\theta)=\kappa\theta^{1-\eta}\), which increases.

This is a natural future Lean-certified specialization. A possible M5b task
would:

1. define the Cobb–Douglas vacancy-filling function using `Real.rpow`;
2. prove the current matching assumptions;
3. prove the right-hand Inada condition;
4. combine it with upper-job profitability;
5. derive `StaticExistenceAssumptions`; and
6. upgrade existence from amber to green for that specification.

This specialization has not been formalized, so the current general M5
existence theorem remains amber.

## Current and proposed foundations

| Item | Current M5 status | Assumed or derived? | Economic role | Future upgrade |
|---|---|---|---|---|
| `q` continuity | In `StaticExistenceAssumptions` | Assumed | Makes the scalar residual continuous on positive tightness | Place in a matching-boundary bundle or prove for a specification |
| Lower positive crossing | `lower_crossing` | Assumed | Supplies the positive endpoint of the IVT bracket | Derive from Inada plus upper-job profitability |
| Upper residual negativity | `Phi(epsUpper) = -c < 0` | Derived | Supplies the negative endpoint of the bracket | No upgrade required |
| JD strict monotonicity | Proved | Derived | Makes the JD-implied tightness increase with the cutoff | No upgrade required |
| JC strict monotonicity | Proved on the admissible domain | Derived | Gives the downward-sloping job-creation locus | No upgrade required |
| `q` Inada condition | Absent | Proposed assumption | Makes vacancy filling explode near zero tightness | Formalize generally or for Cobb–Douglas |
| Upper-job profitability | Absent from core assumptions | Proposed separate condition | Ensures JD-implied tightness is positive near the upper state | Add an explicit theorem parameter or assumption predicate |
| Existence | COMPLETE — AMBER | Derived conditionally from `StaticExistenceAssumptions` | Guarantees one static equilibrium | Derive the existence bundle from primitive conditions |
| Uniqueness | COMPLETE — GREEN | Derived | Rules out multiple static equilibria | No upgrade required |

## Scope boundary

This note proposes a foundational refinement, M5b. It does not modify the
current M5 proof, does not prove any proposed theorem, and does not begin M6.
Equation (14), unemployment stocks, and the full steady state remain outside
this task.
