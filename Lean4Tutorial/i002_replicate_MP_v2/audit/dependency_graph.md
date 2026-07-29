# MP1994 Mathematical Dependency Graph

Repository root: `/Users/davidxu/Documents/lean4tutorial`

Edge labels:

- **LEAN-PROVED**: an existing Lean theorem establishes the edge.
- **STRUCTURE-FIELD**: the target fact is supplied when constructing a record.
- **THEOREM-HYPOTHESIS**: the target fact is supplied directly to a theorem.
- **MATHLIB**: standard imported mathematics can provide the edge.
- **MISSING**: the mathematical dependency has not been formalized.
- **FINITE-STATE**: the edge is specific to a concrete finite witness/calibration.

## 1. High-level graph

```mermaid
flowchart TD
    P["Primitives and probability structure"]
    V["Value equations and bargaining<br/>(1)-(8)"]
    S["Surplus representation and cutoff<br/>(9), (12), reservation rule"]
    JDJC["Job destruction and creation<br/>(10), (13), (14)"]
    EU["Steady-state existence and uniqueness"]
    CS["Comparative statics<br/>main text + Appendix"]
    TS["Two-state anticipated equilibrium<br/>(16)-(30)"]
    MK["Markov equilibrium<br/>(32)-(34)"]
    ED["Employment-distribution dynamics<br/>(35)"]
    SIM["Simulation accounting<br/>(36)-(38)"]
    CAL["Finite-state calibration<br/>(39), (40), (42), Tables I-II"]

    P -->|"STRUCTURE-FIELD + missing closures"| V
    V -->|"LEAN-PROVED for encoded (8)"| S
    S -->|"MISSING critical bridge"| JDJC
    JDJC -->|"STRUCTURE-FIELD"| EU
    EU -->|"MISSING"| CS
    CS -->|"orderings currently hypotheses"| TS
    TS -->|"MISSING specialization/derivation"| MK
    MK -->|"MISSING measure transition"| ED
    ED -->|"MISSING; algebraic (38) proved"| SIM
    MK -->|"FINITE-STATE"| CAL
    ED -->|"FINITE-STATE"| CAL
    SIM -->|"FINITE-STATE"| CAL
```

The graph's critical break is the edge from actual value surplus to the closed-form
surplus/cutoff representation. `S_cutoff` exists as a parallel definition
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:84-86`), but no theorem identifies it
with `ValueEquilibrium.S` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:18-49`).

## 2. Primitives and probability structure

### Nodes

- `Primitives`: raw scalars, measure, and meeting function
  (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:21-43`).
- `Assumptions`: signs, mass/support, CDF bounds/monotonicity, and weak matching
  monotonicity (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`).
- Missing paper law: atomless probability, mean zero, variance one, moment/integrability
  conditions.
- Missing matching technology: strict decrease, differentiability, and elasticity
  restriction.

### Edge ledger

| From | To | Label | Evidence / missing result |
|---|---|---|---|
| `dF` as `Measure ℝ` | `F` | Existing definition | `Primitives.F`, `Definitions.lean:48-50`. |
| Probability mass | `0≤F≤1`, monotone `F` | Currently **STRUCTURE-FIELD**; should be **MATHLIB/LEAN-PROVED** | Fields `Definitions.lean:265-274`; derive using measure monotonicity. |
| No atoms | cutoff endpoint equivalence | **MISSING** | Needed because hazard uses `Iic` (`Definitions.lean:48-50`, `Definitions.lean:80-82`) while cutoff is weakly acceptable (`Equilibrium.lean:48-49`). |
| Mean zero/unit variance | `σ` as standard deviation; Appendix (A11) | **MISSING** | No moment fields in `Assumptions`. |
| `q` positivity | positive worker rate | **LEAN-PROVED** | `mWorker_pos`, `Results.lean:116-119`. |
| `q` antitone | JC curve slopes down | **LEAN-PROVED** with supplied JC points | `jobCreationCurve_slopes_down`, `Results.lean:147-188`. |
| Elasticity in `(-1,0)` | strict increase of `θq(θ)` | **MISSING** | Current `mWorker_monotone` is a structure field (`Definitions.lean:279-280`). |
| Measurability/integrability | meaningful continuation and tail integrals | **MATHLIB + MISSING local lemmas** | Integrals are merely defined at `Definitions.lean:68-78`. |

## 3. Value equations and bargaining

```mermaid
flowchart LR
    E1["(1) Vacancy Bellman"]
    E2["(2) Free entry"]
    E3["(3) Surplus identity"]
    E4["(4) Nash sharing"]
    E5["(5) Firm Bellman"]
    E6["(6) Worker Bellman"]
    E7["(7) Unemployment Bellman"]
    E8["(8) Surplus Bellman"]
    ZP["q(theta) J(epsU) = c"]
    J0["J(epsD)=0"]

    E1 -->|"LEAN-PROVED with r>0"| ZP
    E2 -->|"LEAN-PROVED with r>0"| ZP
    E3 -->|"LEAN-PROVED"| E8
    E4 -->|"LEAN-PROVED"| E8
    E5 -->|"LEAN-PROVED"| E8
    E6 -->|"LEAN-PROVED"| E8
    E7 -->|"LEAN-PROVED"| E8
    E3 -->|"LEAN-PROVED with cutoff_zero"| J0
    E4 -->|"LEAN-PROVED with cutoff_zero"| J0
```

All seven equations are `ValueEquilibrium` fields
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:37-49`). The aggregation edge to (8)
is proved (`Lean4Tutorial/i002_replicate_MP/Results.lean:24-38`), as are zero cutoff firm
value and the free-entry value equation (`Lean4Tutorial/i002_replicate_MP/Results.lean:40-62`).

Qualification: paper equivalence of (5)-(6) requires probability mass one, but
`ValueEquilibrium` does not carry `Assumptions P`
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:18-49`).

## 4. Surplus representation and cutoff

```mermaid
flowchart TD
    E8["Actual surplus Bellman (8)"]
    DIFF["Subtract equations at two shock values"]
    AFF["Affine surplus difference (12)"]
    MONO["Strict surplus monotonicity"]
    CROSS["Endpoint crossing"]
    CUT["Unique cutoff + reservation rule"]
    TAIL["Tail-expectation identity"]
    E9["Integrated equation (9)"]
    FORM["Existing S_cutoff formula"]

    E8 -->|"MISSING for actual S"| DIFF
    DIFF -->|"MISSING"| AFF
    FORM -->|"LEAN-PROVED algebra only"| AFF
    AFF -->|"MISSING bridge + signs"| MONO
    MONO -->|"MISSING"| CUT
    CROSS -->|"MISSING"| CUT
    CUT -->|"currently STRUCTURE-FIELD"| E8
    AFF -->|"MISSING"| TAIL
    CUT -->|"MISSING"| TAIL
    TAIL -->|"MISSING"| E9
```

Current circularity is structural rather than logical inconsistency:
`ValueEquilibrium` asks for `cutoff_zero` and the reservation rule
(`Equilibrium.lean:48-49`), while the paper derives them from increasing surplus. The
closed-form function is separately defined (`Definitions.lean:84-94`) and only its
elementary algebra is proved (`Results.lean:70-102`).

Required edge labels:

| Edge | Label now | Required proof |
|---|---|---|
| (8) -> surplus difference for actual `E.S` | **MISSING** | Subtract the Bellman equation at `ε1,ε2`; cancel state-independent continuation/search terms. |
| difference -> exact (12) | **MISSING** | Divide by `r+λ>0` and use `S εd=0`. |
| (12) -> strict monotonicity | **MISSING**, though elementary | `σ/(r+λ)>0`. |
| monotonicity + crossing -> unique cutoff | **MISSING** | Strict-monotone zero uniqueness and IVT/existence. |
| affine positive part -> tail integral | **MATHLIB + MISSING specialization** | Layer-cake/Stieltjes identity under support/atomless/integrability assumptions. |
| tail identity -> (9) | **MISSING** | Substitute into (8). |

## 5. Job destruction, job creation, and Beveridge equations

```mermaid
flowchart LR
    E1E2["(1)-(2)"]
    E4["(4)"]
    E9["(9)"]
    E12["(12)"]
    E10["(10) JD"]
    E13["(13) JC"]
    FLOW["Zero unemployment drift"]
    E14["(14) Beveridge"]
    RED["SteadyStateEquilibrium"]

    E1E2 -->|"MISSING full derivation"| E10
    E4 -->|"MISSING full derivation"| E10
    E9 -->|"MISSING"| E10
    E1E2 -->|"MISSING bridge"| E13
    E4 -->|"MISSING bridge"| E13
    E12 -->|"MISSING bridge"| E13
    FLOW -->|"MISSING converse/solve"| E14
    E10 -->|"STRUCTURE-FIELD"| RED
    E13 -->|"STRUCTURE-FIELD"| RED
    E14 -->|"STRUCTURE-FIELD"| RED
```

- (10), (13), and (14) are definitions/predicates
  (`Definitions.lean:143-165`, `Definitions.lean:214-218`).
- A reduced equilibrium stores them as fields
  (`Equilibrium.lean:53-66`).
- Equation (13) is equivalent to zero profit only for the separately defined
  `J_cutoff` (`Results.lean:121-145`).
- Given (14), flow balance and zero drift are **LEAN-PROVED**
  (`Results.lean:337-360`).
- The reverse direction, deriving (14) from zero drift using denominator positivity, is
  **MISSING** but elementary; denominator positivity is already proved
  (`Results.lean:284-289`).

## 6. Steady-state existence and uniqueness

```mermaid
flowchart TD
    JD["JD residual / curve"]
    JC["JC residual / curve"]
    JDM["JD strict monotonicity"]
    JCM["JC slopes down"]
    BND["Boundary crossing/coercivity"]
    EX["Existence"]
    UNIQ["Uniqueness"]
    EQ["Constructed SteadyStateEquilibrium"]

    JD -->|"MISSING"| JDM
    JC -->|"LEAN-PROVED conditionally"| JCM
    JDM -->|"MISSING"| UNIQ
    JCM -->|"MISSING joint argument"| UNIQ
    BND -->|"MISSING"| EX
    JD -->|"MISSING"| EX
    JC -->|"MISSING"| EX
    EX -->|"MISSING"| EQ
    UNIQ -->|"MISSING"| EQ
```

The current record is a solution specification, not a witness
(`Equilibrium.lean:53-66`). There is no declaration returning
`Nonempty (SteadyStateEquilibrium P)` or proving equality of two equilibria.

Critical missing choices that must be made explicitly:

- economic domain for `θ` and `εd`;
- continuity of residuals;
- boundary signs or coercivity;
- whether global uniqueness follows from monotone curves or only local uniqueness from a
  nonsingular Jacobian.

## 7. Comparative statics

| Comparative static | Current incoming edge | Current proof edge | Missing faithful edge |
|---|---|---|---|
| Higher `p` -> higher `θ`, lower `εd` | `hθ,hε` supplied | **THEOREM-HYPOTHESIS** to `aggregateShock_flow_orders`, `Results.lean:310-317` | Paired equilibrium theorem controlling all other primitives. |
| Higher `σ` -> higher `θ`, usually higher `εd` | `hθ,hε` supplied | **THEOREM-HYPOTHESIS** to `dispersionShock_flow_orders`, `Results.lean:322-329` | Appendix A9-A12 or monotone-comparison proof. |
| Higher cutoff -> higher hazard | `F_monotone` | **LEAN-PROVED**, `Results.lean:109-114` | Atomless/strictness only if a strict hazard result is required. |
| Worker rate order -> creation order | rate order supplied | **LEAN-PROVED**, `Results.lean:291-297` | Derive rate order from `θ` and strict worker-rate monotonicity. |
| Cutoff order -> destruction order | cutoff order supplied | **LEAN-PROVED**, `Results.lean:299-305` | Derive cutoff order from equilibrium. |
| Aggregate negative co-movement | strict flow orders supplied | **CIRCULAR THEOREM-HYPOTHESIS**, `Results.lean:378-386` | Compose genuine paired-equilibrium and strict-flow theorems. |
| Dispersion positive co-movement | strict flow orders supplied | **CIRCULAR THEOREM-HYPOTHESIS**, `Results.lean:388-396` | Same. |
| Fixed-`θ` equation (11) sign | net-price condition supplied | RHS sign **LEAN-PROVED**, `Results.lean:190-207` | IFT/FTC edge equating RHS to the derivative. |

Mathematical route:

```mermaid
flowchart LR
    EXU["Existence + uniqueness"]
    RES["Differentiable JD/JC residuals"]
    JAC["Nonsingular Jacobian"]
    IFT["Local equilibrium branch"]
    DER["A1-A12 derivative formulas"]
    ORD["theta/cutoff orderings"]
    FLOWS["Creation/destruction orders"]
    COMOVE["Co-movement"]

    EXU -->|"MISSING"| IFT
    RES -->|"MATHLIB + local proofs"| IFT
    JAC -->|"MISSING"| IFT
    IFT -->|"MATHLIB implicit-function theorem"| DER
    DER -->|"MISSING sign algebra"| ORD
    ORD -->|"existing generic lemmas"| FLOWS
    FLOWS -->|"existing arithmetic lemmas"| COMOVE
```

## 8. Two-state and anticipated equilibria

`TwoStateEquilibrium` directly stores productivity, tightness, and cutoff orderings
(`Equilibrium.lean:90-98`), so the edges
`p_order -> θ_order` and `p_order -> εd_order` are **STRUCTURE-FIELD**, not proved.
It also permits every primitive to change across states.

`AnticipatedTwoStateEquilibrium` stores (20), (24), recession (13), boom (30), and cutoff
ordering (`Equilibrium.lean:103-132`). The intended derivation graph is:

```mermaid
flowchart TD
    B16["Two-state Bellman (16)"]
    B17["Survivor Bellman (17)"]
    B18["Scrapped-region Bellman (18)"]
    B19["Integrated boom formula (19)"]
    B20["Boom JD (20)"]
    B21["Derivative relation (21)"]
    B22["Integrated recession (22)"]
    B23["Cross-state value (23)"]
    B24["Recession JD (24)"]
    B25["Relation (25)"]
    B26["Relation (26)"]
    B27["Recession surplus (27)"]
    B28["Recession JC (28)"]
    B29["Boom surplus (29)"]
    B30["Boom JC (30)"]

    B16 -->|"MISSING"| B21
    B17 -->|"MISSING"| B21
    B17 -->|"MISSING"| B23
    B18 -->|"MISSING"| B23
    B18 -->|"MISSING + tail identity"| B19
    B19 -->|"MISSING"| B20
    B16 -->|"MISSING"| B22
    B21 -->|"MISSING"| B22
    B22 -->|"MISSING"| B24
    B23 -->|"MISSING"| B24
    B16 -->|"MISSING algebra"| B25
    B17 -->|"MISSING algebra"| B26
    B25 -->|"MISSING algebra"| B27
    B26 -->|"MISSING algebra"| B27
    B27 -->|"MISSING bridge"| B28
    B17 -->|"MISSING"| B29
    B18 -->|"MISSING"| B29
    B29 -->|"MISSING bridge"| B30
```

Existing nodes are representational only:

- (20), (24), (29), and (30) at
  `Definitions.lean:166-212`;
- their equilibrium fields at `Equilibrium.lean:124-132`;
- zero-transition consistency and fixed-cutoff anticipation comparison are
  **LEAN-PROVED** at `Results.lean:209-282`.

## 9. Markov equilibrium

```mermaid
flowchart TD
    ST["Statewise structural primitives"]
    K["Stochastic kernel + arrival rates"]
    R["Statewise reservation rules"]
    M32["Free entry (32)"]
    M33["Cutoff zero (33)"]
    M34["Surplus Bellman (34)"]
    SPEC["Fin 2 specialization -> (16)-(18)"]
    EXIST["Finite/general equilibrium existence"]

    ST -->|"partly raw Primitives"| M32
    ST -->|"partly raw Primitives"| M34
    K -->|"STRUCTURE-FIELD"| M34
    R -->|"MISSING"| M34
    M32 -->|"STRUCTURE-FIELD"| EXIST
    M33 -->|"STRUCTURE-FIELD"| EXIST
    M34 -->|"STRUCTURE-FIELD"| EXIST
    M34 -->|"MISSING specialization"| SPEC
```

`GeneralMarkovValueEquilibrium` packages (32)-(34)
(`Equilibrium.lean:146-176`) but does not prove existence. Its positive-continuation
integral uses `max` over the entire shock measure
(`Definitions.lean:76-78`, `Equilibrium.lean:174-176`); the paper's truncated current-state
integral requires the missing statewise reservation edge.

The separate `MarkovEquilibrium` only packages static reduced equilibria and a kernel
(`Equilibrium.lean:136-142`); it has no edge to (32)-(34).

## 10. Employment-distribution dynamics

```mermaid
flowchart TD
    EM["Employment measure n_t"]
    PATH["Aggregate-state path"]
    CUT["State cutoff path"]
    SURV["Restriction to surviving jobs"]
    REDRAW["Idiosyncratic redraw measure"]
    UPD["Employment update operator (35)"]
    MASS["Mass/accounting theorem"]
    DENS["Density form (35)"]

    EM -->|"MISSING type"| SURV
    PATH -->|"MISSING"| CUT
    CUT -->|"MISSING"| SURV
    SURV -->|"MATHLIB Measure.restrict"| UPD
    REDRAW -->|"MATHLIB Measure.map/scalar"| UPD
    UPD -->|"MISSING"| MASS
    UPD -->|"MISSING + absolute continuity"| DENS
```

No current declaration represents (35). `immediateScrapping` accepts an arbitrary real
function (`Definitions.lean:236-239`), and `SimulationPath` contains no employment
distribution (`Equilibrium.lean:181-199`).

Recommended dependency direction: define a measure update first, prove positivity and
mass accounting, and derive the paper's density formula only under absolute-continuity
hypotheses.

## 11. Simulation and calibration

| Edge | Label | Current status |
|---|---|---|
| Markov equilibrium -> state job-finding rate | **STRUCTURE-FIELD** via (32) | `Equilibrium.lean:161-164`. |
| State rate + unemployment -> creation (36) | Formula exists, path link **MISSING** | `Definitions.lean:232-234`, `Equilibrium.lean:184-195`. |
| Employment update -> immediate destruction | **MISSING** | Integral exists but is not a path law, `Definitions.lean:236-239`. |
| Hazard + surviving employment -> ongoing destruction | **MISSING** | `D_ongoing` is arbitrary, `Equilibrium.lean:188-197`. |
| Creation/destruction -> employment identity (38) | **LEAN-PROVED** algebraically | `Results.lean:407-436`. |
| Matrix (39) -> stochastic kernel | **FINITE-STATE** | No witness; Mathlib has `Matrix.IsStochastic` at `.lake/packages/mathlib/Mathlib/LinearAlgebra/Matrix/Stochastic.lean:59`. |
| Matching form (40) -> job-finding rate | **FINITE-STATE** | Missing. |
| Parameters -> equilibrium vectors (42) | **FINITE-STATE** | Missing numerical solver/certificate. |
| Equilibrium + transition operator -> Table II | **FINITE-STATE** | Missing simulation/statistics. |

## 12. Critical path for faithful replication

The critical path is ordered by logical necessity, not paper order:

1. **Probability closure:** bundled probability measure, atomlessness, upper support,
   moments, and derived CDF properties.
2. **Actual-surplus difference:** derive (12) for `ValueEquilibrium.S`.
3. **Cutoff theorem:** derive strict monotonicity, existence/uniqueness, and reservation
   rule.
4. **Tail identity:** connect positive-continuation expectation to the CDF tail integral.
5. **Reduced-equation bridge:** derive (10) and (13); derive (14) from flow balance.
6. **Steady-state existence/uniqueness:** construct the reduced equilibrium rather than
   assume one.
7. **Comparative statics:** prove JD/JC orderings, then reuse existing flow lemmas.
8. **Two-state specialization:** derive (16)-(30) instead of storing only four reduced
   formulas.
9. **Finite Markov witness:** instantiate (32)-(34) for `Fin 3`.
10. **Employment measure:** implement (35), then derive (36)-(38).
11. **Certified calibration:** prove matrix validity, residual bounds for (42), and
    reproducible statistics.

The single best first edge is step 2:

```text
ValueEquilibrium.surplus_bellman
  -> surplus difference for actual E.S
  -> E.S ε = P.S_cutoff E.εd ε.
```

It is local, algebraic, uses existing fields and sign assumptions, and unlocks the
cutoff, free-entry, and job-destruction bridges without a wholesale redesign.
