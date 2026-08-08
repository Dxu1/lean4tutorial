# Repository Audit: Mortensen-Pissarides (1994) Lean Formalization

Audit date: 2026-07-28  
Repository root: `/Users/davidxu/Documents/lean4tutorial`  
Audited development: `Lean4Tutorial/i002_replicate_MP` and
`Lean4Tutorial/i002_replicate_MP.lean`  
Output format: Markdown, chosen because it is plain text, compact, line-addressable,
and reliably readable by GPT classic.

## 1. Executive assessment

| Dimension | Assessment | Basis |
|---|---|---|
| **Syntactic completeness** | **Complete / high** | All five current Lean source files elaborated successfully in non-writing checks. `Results.lean` contains 31 theorem declarations and `Verification.lean` contains 31 matching `assert_no_sorry` commands (`Lean4Tutorial/i002_replicate_MP/Results.lean:27`, `Lean4Tutorial/i002_replicate_MP/Results.lean:430`, `Lean4Tutorial/i002_replicate_MP/Verification.lean:13`, `Lean4Tutorial/i002_replicate_MP/Verification.lean:46`). A source scan found no actual `sorry`, `admit`, project-defined `axiom`, metavariable hole, or TODO placeholder in the Lean files; the only occurrences of “sorry” are explanatory prose and `assert_no_sorry` (`Lean4Tutorial/i002_replicate_MP/Results.lean:11-13`, `Lean4Tutorial/i002_replicate_MP/Verification.lean:7-10`). |
| **Logical adequacy** | **Partial** | The kernel-checked theorems prove their stated implications, but the reduced equilibrium equations are normally introduced as definitions and then required as fields, not derived from the value equilibrium (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:143-165`, `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:51-66`). There is no theorem connecting `ValueEquilibrium` to `SteadyStateEquilibrium`, and no existence, uniqueness, implicit-function, or numerical-solution theorem; the existing audit also acknowledges these limits (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:571-601`). |
| **Economic fidelity** | **Partial / limited** | Many paper equations are represented with recognizable formulas, but major conclusions about aggregate and dispersion shocks are accepted as fields or hypotheses before the Lean theorems restate their flow consequences (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:87-98`, `Lean4Tutorial/i002_replicate_MP/Results.lean:307-329`, `Lean4Tutorial/i002_replicate_MP/Results.lean:378-396`). The formalization omits important distributional assumptions, derivations, dynamics, and the numerical replication described below. |

### Bottom line

This is a clean, compiling **formal interface and conditional-theorem library** for a
substantial subset of the MP1994 model. It is not yet a full formal replication of the
paper's equilibrium derivations or quantitative exercise. The strongest result is
syntactic: the current declarations elaborate and the named theorem bodies do not use
`sorryAx`. The main gap is economic/logical: several headline comparative statics are
inputs to the theorem statements rather than outputs derived from the model.

## 2. Citation and verification conventions

- Repository citations use `path:line` or `path:start-end`. Line numbers refer to the
  audited checkout on 2026-07-28.
- PDF sources have no stable source-code lines. The original paper is therefore cited by
  local PDF path, printed journal page, and equation number. The companion TeX source is
  cited by ordinary line number.
- Filesystem metadata such as byte size, PDF page count, hashes, and modification time
  has a path but no meaningful source line. Such observations are labeled explicitly.
- “Proved” means a Lean theorem derives the conclusion from its displayed inputs.
  “Assumed” means the important economic ordering or equation is a theorem hypothesis or
  structure field. “Represented” means a paper formula is encoded as a definition or
  structure field without a derivation or existence proof.
- `assert_no_sorry` rules out dependence on Lean's `sorryAx` for the named declaration;
  it is not a general claim that the theorem uses no standard Lean axioms such as
  classical choice (`Lean4Tutorial/i002_replicate_MP/Verification.lean:7-10`).

## 3. Repository tree and source materials

The audited subtree is compact and all listed files are tracked in Git.

```text
Lean4Tutorial/
├── i002_replicate_MP.lean
└── i002_replicate_MP/
    ├── Definitions.lean
    ├── Equilibrium.lean
    ├── Results.lean
    ├── Verification.lean
    ├── README.md
    ├── Mortensen-JobCreationJob-1994.pdf
    ├── mp1994_lean_formalization.tex
    └── mp1994_lean_formalization.pdf
```

The local README assigns these roles to the four modules and the entry point
(`Lean4Tutorial/i002_replicate_MP/README.md:7-16`). The companion TeX document gives the
same source map and explicitly identifies `Results.lean` as the theorem file and
`Verification.lean` as the no-sorry ledger
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:113-128`).

### 3.1 File inventory

| File | Size / length | Role and audit finding |
|---|---:|---|
| `Lean4Tutorial/i002_replicate_MP.lean` | 20 lines | Dedicated import target. It imports all four modules (`Lean4Tutorial/i002_replicate_MP.lean:1-4`) and documents the intended targeted build command (`Lean4Tutorial/i002_replicate_MP.lean:8-19`). |
| `Lean4Tutorial/i002_replicate_MP/Definitions.lean` | 282 lines | Defines primitives, 35 named definitions, paper-numbered predicates, flows, and the maintained `Assumptions` bundle (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:21-43`, `Lean4Tutorial/i002_replicate_MP/Definitions.lean:48-247`, `Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`). |
| `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean` | 201 lines | Defines seven equilibrium/path structures, including the abstract finite-state and simulation interfaces (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:17-66`, `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:87-199`). |
| `Lean4Tutorial/i002_replicate_MP/Results.lean` | 438 lines | Contains 31 theorems, ranging from Bellman-equation algebra to conditional comparative statics and accounting identities (`Lean4Tutorial/i002_replicate_MP/Results.lean:20-438`). |
| `Lean4Tutorial/i002_replicate_MP/Verification.lean` | 46 lines | Applies one `assert_no_sorry` command to every theorem in `Results.lean` (`Lean4Tutorial/i002_replicate_MP/Verification.lean:13-46`). |
| `Lean4Tutorial/i002_replicate_MP/README.md` | 113 lines | Gives notation, a paper-to-Lean map, claimed results, build commands, and pointers to the companion mathematical audit (`Lean4Tutorial/i002_replicate_MP/README.md:18-64`, `Lean4Tutorial/i002_replicate_MP/README.md:66-113`). |
| `Lean4Tutorial/i002_replicate_MP/Mortensen-JobCreationJob-1994.pdf` | 2,481,051 bytes; 20 PDF pages | Local JSTOR copy of Mortensen and Pissarides, *Review of Economic Studies* 61 (1994), printed pages 397-415. The Lean header identifies the same article and page range (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:3-13`). |
| `Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex` | 654 lines | Existing human-readable mathematical audit. It labels definitions, structures, theorems, and proof status, and already warns that structure fields are assumptions rather than automatically derived results (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:63-88`). |
| `Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.pdf` | 326,143 bytes; 12 PDF pages | Rendered version of the 654-line TeX audit. Its metadata describes it as a “Readable Lean 4 Formalization”; the source states that it is a companion, not a replacement for the kernel check (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:55-70`). |

Filesystem observation: identical SHA-256 hashes were observed for the TeX/PDF copies in
`Lean4Tutorial/i002_replicate_MP/` and `output/pdf/`. The README's `../../output/pdf/...`
pointers are therefore valid and point to duplicate content
(`Lean4Tutorial/i002_replicate_MP/README.md:103-113`).

### 3.2 Paper coverage

The README maps paper equations (1)-(8), (10)-(15), (20), (24), (29)-(30),
(32)-(34), and (36)-(38) to Lean declarations
(`Lean4Tutorial/i002_replicate_MP/README.md:38-58`). It explicitly says that Section 5's
calibration is not rerun (`Lean4Tutorial/i002_replicate_MP/README.md:60-64`).

Important paper material not encoded as a derivation or quantitative replication includes:

- equations (9), (16)-(19), (21)-(23), (25)-(27), and (31) as distinct formal
  declarations; the implemented equation list jumps from (8) to (10), from the
  stationary definitions to (20)/(24), and from (30) to (32)
  (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:135-165`,
  `Lean4Tutorial/i002_replicate_MP/Definitions.lean:166-213`,
  `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:144-176`);
- equation (35), the employment-distribution law of motion, which is required before the
  paper defines simulated creation and destruction (local paper PDF, printed p. 410,
  equations (35)-(38)); the Lean simulation begins directly with simplified versions of
  (36)-(38) (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:232-247`);
- the three-state transition matrix (39), matching specification (40), parameter table,
  computed state solutions, and simulation statistics (local paper PDF, printed
  pp. 411-412); no concrete matrix, calibration data, solver, or numerical theorem appears
  in the seven structures (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:87-199`);
- the Appendix's implicit comparative statics and elasticity calculations (local paper
  PDF, printed pp. 413-414, equations (A1)-(A12)); Lean proves selected signs only after
  taking the relevant orderings or net-price condition as inputs
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:147-207`,
  `Lean4Tutorial/i002_replicate_MP/Results.lean:307-329`).

## 4. Build configuration and import graph

### 4.1 Toolchain and dependencies

- The repository pins Lean `v4.32.0` (`lean-toolchain:1`).
- The Lake package is named `Lean4Tutorial`, version `0.1.0`, with
  `Lean4Tutorial` as its default target (`lakefile.toml:1-4`).
- The only direct package requirement is mathlib `v4.32.0`
  (`lakefile.toml:12-15`). The manifest resolves mathlib to commit
  `81a5d257c8e410db227a6665ed08f64fea08e997`
  (`lake-manifest.json:4-13`).
- `relaxedAutoImplicit = false` prevents undeclared identifiers from becoming implicit
  variables, which strengthens syntactic checking of the model interface
  (`lakefile.toml:6-10`).
- The library target is the single Lean library `Lean4Tutorial`
  (`lakefile.toml:17-18`). The repository root module imports the MP entry point, so the
  development is part of the default library build (`Lean4Tutorial.lean:1-3`).

### 4.2 Import graph

```text
Mathlib
  └── Definitions.lean
        └── Equilibrium.lean
              └── Results.lean
                    └── Verification.lean

Definitions + Equilibrium + Results + Verification
  └── i002_replicate_MP.lean
        └── Lean4Tutorial.lean
```

Evidence:

- `Definitions.lean` imports all of `Mathlib`
  (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:1`).
- `Equilibrium.lean` imports `Definitions.lean`
  (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:1`).
- `Results.lean` imports `Equilibrium.lean`
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:1`).
- `Verification.lean` imports `Mathlib.Util.AssertNoSorry` and `Results.lean`
  (`Lean4Tutorial/i002_replicate_MP/Verification.lean:1-2`).
- The dedicated entry point redundantly imports all four modules, making the intended
  audit target explicit (`Lean4Tutorial/i002_replicate_MP.lean:1-4`).
- The root module imports the dedicated target
  (`Lean4Tutorial.lean:3`).

### 4.3 Read-only elaboration status

The following commands were run from the repository root without `-o`. Each exited with
status 0 and emitted no errors:

```sh
lake env lean Lean4Tutorial/i002_replicate_MP/Definitions.lean
lake env lean Lean4Tutorial/i002_replicate_MP/Equilibrium.lean
lake env lean Lean4Tutorial/i002_replicate_MP/Results.lean
lake env lean Lean4Tutorial/i002_replicate_MP/Verification.lean
lake env lean Lean4Tutorial/i002_replicate_MP.lean
```

These commands directly elaborate each current source file but do not write `.olean`
outputs. They are consistent with the documented dedicated build target
(`Lean4Tutorial/i002_replicate_MP.lean:11-19`,
`Lean4Tutorial/i002_replicate_MP/README.md:88-101`).

**Limitation:** this was deliberately not a fresh `lake build`. Existing `.lake` artifacts
were not deleted or regenerated, dependencies were not updated, and generated
documentation was not built. Therefore the audit establishes successful direct
elaboration against the installed pinned environment, not a from-scratch reproducible
build.

## 5. Declaration catalogue

### 5.1 Foundational structures

`Primitives` contains ten unconstrained fields: seven scalar parameters, an upper support
point, a measure, and a meeting-rate function
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:21-43`). Economic restrictions live in
the separate proposition `Assumptions P`
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`), so declarations accepting
only `P : Primitives` do not automatically receive those restrictions.

### 5.2 All 35 named definitions in `Definitions.lean`

| # | Declaration | Kind / paper role |
|---:|---|---|
| 1 | `Primitives.F` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:48-50`) | CDF from `dF (Iic x)`, converted from `ENNReal` to `Real`. |
| 2 | `Primitives.θ` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:52-54`) | Market tightness `v/u`. |
| 3 | `Primitives.mWorker` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:56-58`) | Worker meeting rate `θ q(θ)`. |
| 4 | `Primitives.m` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:60-62`) | Aggregate matches `v q(v/u)`. |
| 5 | `Primitives.price` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:64-66`) | Match productivity `p + σ ε`. |
| 6 | `Primitives.optionValueIntegral` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:68-70`) | Tail integral used in (9)-(10). |
| 7 | `Primitives.tailIntegral` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:72-74`) | Bounded tail integral used in (19)-(24). |
| 8 | `Primitives.positiveContinuation` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:76-78`) | Measure integral of `max (S x) 0`. |
| 9 | `Primitives.destructionHazard` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:80-82`) | Hazard `λ F(εd)`. |
| 10 | `Primitives.S_cutoff` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:84-86`) | Closed-form surplus, paper (12). |
| 11 | `Primitives.J_cutoff` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:88-90`) | Firm's `(1-β)` surplus share. |
| 12 | `Primitives.WminusU_cutoff` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:92-94`) | Worker's `β` surplus share. |
| 13 | `Primitives.VacancyBellman` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:96-99`) | Proposition for paper (1). |
| 14 | `Primitives.FreeEntry` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:101-103`) | Proposition `rV=0`, paper (2). |
| 15 | `Primitives.SurplusIdentity` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:105-107`) | Paper (3). |
| 16 | `Primitives.NashSharing` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:109-111`) | Paper (4). |
| 17 | `Primitives.FilledJobBellman` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:113-120`) | Paper (5). |
| 18 | `Primitives.WorkerBellman` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:122-128`) | Paper (6). |
| 19 | `Primitives.UnemployedBellman` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:130-133`) | Paper (7). |
| 20 | `Primitives.SurplusBellman` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:135-141`) | Paper (8). |
| 21 | `Primitives.JobDestructionCondition` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:143-149`) | Reduced paper equation (10). |
| 22 | `Primitives.dispersionCutoffResponse` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:151-157`) | Right side of paper (11), not a derivative theorem. |
| 23 | `Primitives.JobCreationCondition` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:159-164`) | Reduced paper equation (13). |
| 24 | `Primitives.BoomDestructionCondition` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:166-179`) | Paper (20). |
| 25 | `Primitives.RecessionDestructionCondition` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:181-193`) | Paper (24). |
| 26 | `Primitives.boomSurplus` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:195-201`) | Paper (29). |
| 27 | `Primitives.BoomJobCreationCondition` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:203-212`) | Paper (30). |
| 28 | `Primitives.BeveridgeCondition` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:214-218`) | Paper (14). |
| 29 | `Primitives.creationFlow` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:220-222`) | Conditional creation flow. |
| 30 | `Primitives.destructionFlow` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:224-226`) | Conditional destruction flow. |
| 31 | `Primitives.unemploymentDrift` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:228-230`) | Paper (15). |
| 32 | `Primitives.periodCreation` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:232-234`) | Simplified paper (36). |
| 33 | `Primitives.immediateScrapping` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:236-239`) | First term of paper (37). |
| 34 | `Primitives.periodDestruction` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:241-243`) | Sum of immediate and externally supplied ongoing destruction. |
| 35 | `Primitives.nextEmployment` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:245-247`) | Accounting identity, paper (38). |

### 5.3 Seven equilibrium and path structures

| # | Structure | Content and proof status |
|---:|---|---|
| 1 | `ValueEquilibrium` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:17-49`) | Packages values and paper equations (1)-(7), plus cutoff and reservation fields. It does not contain `Assumptions P`. |
| 2 | `SteadyStateEquilibrium` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:51-66`) | Packages `(θ, εd, u)` and assumes equations (10), (13), and (14), plus simple bounds. It is not constructed from `ValueEquilibrium`. |
| 3 | `TwoStateEquilibrium` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:87-98`) | Packages two reduced equilibria and directly assumes productivity, tightness, and cutoff orderings. |
| 4 | `AnticipatedTwoStateEquilibrium` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:100-132`) | Packages explicit recession/boom scalars and assumes equations (20), (24), (13), and (30), plus state orderings. |
| 5 | `MarkovEquilibrium` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:134-142`) | For arbitrary `State : Type*`, packages a reduced steady state in each state and an infinite-sum row-stochastic kernel. It does not impose (32)-(34). |
| 6 | `GeneralMarkovValueEquilibrium` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:144-176`) | Requires `[Fintype State]` and packages state-contingent equations (32)-(34) as fields. No instance or existence theorem is supplied. |
| 7 | `SimulationPath` (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:178-199`) | Packages arbitrary sequences satisfying simplified (36)-(38). The parameter `P : Primitives` is not referenced by any field. |

## 6. Maintained assumptions

`Assumptions P` contains the following fields
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`):

| Category | Formal assumptions |
|---|---|
| Discounting and shocks | `0 < r`, `0 ≤ λ`, `0 < σ` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:253-258`). |
| Bargaining and vacancy costs | `0 < β < 1`, `0 < c` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:259-264`). |
| Distribution | Total mass one, all mass weakly below `εu`, pointwise `0 ≤ F ≤ 1`, and monotonicity of `F` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:265-274`). |
| Matching | `q(θ)>0` for positive `θ`, `q` antitone, and `θ q(θ)` monotone (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:275-280`). |

### Missing, weakened, or detached paper assumptions

1. **[High] Distribution shape and normalization are incomplete.** The paper assumes no
   mass points, finite upper support, zero mean, and unit variance for the standardized
   idiosyncratic shock (local paper PDF, printed p. 399). Lean encodes probability mass
   and an upper support point but not atomlessness, zero mean, variance one, or finite
   moments (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:265-274`). Consequently
   `σ` is only documented as a standard deviation; its formal fields do not establish that
   interpretation (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:27-28`).

2. **[High] Assumptions are not attached to equilibrium structures.** `Primitives` itself
   accepts arbitrary reals, measure, and function (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:21-43`).
   `ValueEquilibrium`, `SteadyStateEquilibrium`, and the Markov structures take only
   `P : Primitives`, not a proof of `Assumptions P`
   (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:18`,
   `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:53`,
   `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:146-147`). Individual theorems add
   `A : Assumptions P` when needed, but the structures can be inhabited by economically
   invalid parameters.

3. **[Medium] CDF properties are duplicated as fields rather than derived.** `F` is
   defined from a measure (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:48-50`),
   while its bounds and monotonicity are separately required
   (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:269-274`). The existing TeX audit
   explicitly notes this design (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:156-166`).

4. **[High] Cutoff convention conflicts with possible atoms.** Lean defines
   `F(εd)=dF((−∞,εd])` and destruction hazard `λF(εd)`
   (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:48-50`,
   `Lean4Tutorial/i002_replicate_MP/Definitions.lean:80-82`), while
   `ValueEquilibrium` declares `S(εd)=0` and treats the cutoff as weakly acceptable
   through `0 ≤ S(ε) ↔ εd ≤ ε`
   (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:48-49`). If `dF` has an atom at
   `εd`, the hazard counts cutoff jobs as destroyed even though the reservation rule
   classifies their surplus as nonnegative. The paper's no-mass-points assumption makes
   `≤` versus `<` immaterial; Lean omits that assumption.

5. **[Medium] Matching restrictions are weaker and domains are broader.** The paper
   states that `q` is strictly decreasing with elasticity strictly between `-1` and `0`
   (local paper PDF, printed p. 400). Lean assumes only weak `Antitone q` and weak
   monotonicity of `θq(θ)` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:275-280`).
   Definitions accept all real vacancy, unemployment, and tightness values
   (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:52-62`); only equilibrium `θ` is
   constrained positive (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:35`,
   `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:60`).

6. **[Medium] Analytic regularity is not part of the interface.** The interval and
   continuation integrals are defined without explicit measurability, continuity, or
   integrability fields for `F`, `S`, or the employment density
   (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:68-78`,
   `Lean4Tutorial/i002_replicate_MP/Definitions.lean:236-239`). This is sufficient to
   form Lean terms but not to justify the paper's integration-by-parts and
   differentiation arguments.

## 7. Theorem dependency ledger

Status labels:

- **Proved:** the economically meaningful conclusion is derived from lower-level model
  equations or assumptions.
- **Conditional:** the proof is valid, but an important ordering or regularity premise is
  supplied.
- **Algebraic:** the result is primarily unfolding/ring/order arithmetic.
- **Representational:** the result establishes consistency of an encoded formula rather
  than the paper's full derivation.

| # | Theorem and no-sorry check | Explicit inputs / structure fields used | Direct theorem dependencies; downstream consumers | Audit status |
|---:|---|---|---|---|
| 1 | `ValueEquilibrium.surplus_bellman` (`Lean4Tutorial/i002_replicate_MP/Results.lean:24-38`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:13`) | `filled_job_bellman`, `worker_bellman`, `unemployed_bellman`, `surplus_identity`, and `nash_sharing` from `ValueEquilibrium`. | No prior project theorem; no later theorem directly invokes it. | **Proved:** equations (3)-(7) imply the encoded equation (8). |
| 2 | `ValueEquilibrium.J_cutoff_eq_zero` (`Lean4Tutorial/i002_replicate_MP/Results.lean:40-47`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:14`) | `surplus_identity`, `nash_sharing`, and `cutoff_zero`. The documented `reservation_rule` is not used. | No prior or downstream project theorem. | **Proved/algebraic:** firm value is zero at the supplied zero-surplus cutoff. |
| 3 | `ValueEquilibrium.vacancy_free_entry_value` (`Lean4Tutorial/i002_replicate_MP/Results.lean:49-62`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:15`) | `A.r_pos`, `E.free_entry`, and `E.vacancy_bellman`. | No prior or downstream project theorem. | **Proved:** encoded (1)-(2) yield the zero-profit value equation. |
| 4 | `Primitives.S_cutoff_self` (`Lean4Tutorial/i002_replicate_MP/Results.lean:70-72`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:17`) | Definition `S_cutoff`. | No project theorem dependencies or consumers. | **Algebraic.** |
| 5 | `Primitives.surplus_difference` (`Lean4Tutorial/i002_replicate_MP/Results.lean:74-79`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:18`) | Definition `S_cutoff`. | No project theorem dependencies or consumers. | **Algebraic/representational:** matches the slope formula but does not show that an equilibrium's `S` equals `S_cutoff`. |
| 6 | `Primitives.nash_shares_exhaust_surplus` (`Lean4Tutorial/i002_replicate_MP/Results.lean:81-86`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:19`) | Definitions `J_cutoff`, `WminusU_cutoff`, and `S_cutoff`. | No project theorem dependencies or consumers. | **Algebraic.** |
| 7 | `Primitives.surplus_nonneg` (`Lean4Tutorial/i002_replicate_MP/Results.lean:88-95`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:20`) | `A.r_pos`, `A.λ_nonneg`, `A.σ_pos`, and `εd ≤ ε`. | Used by `J_cutoff_nonneg` (`Lean4Tutorial/i002_replicate_MP/Results.lean:97-102`). | **Proved conditional sign result.** |
| 8 | `Primitives.J_cutoff_nonneg` (`Lean4Tutorial/i002_replicate_MP/Results.lean:97-102`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:21`) | `A.β_lt_one`, `εd ≤ ε`, and theorem `surplus_nonneg`. | Depends on theorem #7; no downstream consumer. | **Proved conditional sign result.** |
| 9 | `Primitives.destructionHazard_nonneg` (`Lean4Tutorial/i002_replicate_MP/Results.lean:104-107`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:22`) | `A.λ_nonneg` and `A.F_nonneg`. | Used by `beveridge_denominator_pos` (`Lean4Tutorial/i002_replicate_MP/Results.lean:285-289`). | **Proved from maintained assumptions.** |
| 10 | `Primitives.destructionHazard_mono` (`Lean4Tutorial/i002_replicate_MP/Results.lean:109-114`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:23`) | `A.F_monotone` and `A.λ_nonneg`. | Used by `destructionFlow_mono` (`Lean4Tutorial/i002_replicate_MP/Results.lean:300-305`). | **Proved from maintained assumptions.** |
| 11 | `Primitives.mWorker_pos` (`Lean4Tutorial/i002_replicate_MP/Results.lean:116-119`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:24`) | Positive `θ` and `A.q_pos`. | Used by `beveridge_denominator_pos` (`Lean4Tutorial/i002_replicate_MP/Results.lean:285-289`). | **Proved from maintained assumptions.** |
| 12 | `Primitives.jobCreation_iff_freeEntryValue` (`Lean4Tutorial/i002_replicate_MP/Results.lean:121-145`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:25`) | `A.β_lt_one`, `A.σ_pos`, `A.r_pos`, `A.λ_nonneg`, cutoff gap, and definitions (12)-(13). | No prior project theorem; no downstream consumer. | **Representational algebra:** proves equivalence for the separately defined closed-form firm value, not a bridge from `ValueEquilibrium.J`. |
| 13 | `Primitives.jobCreationCurve_slopes_down` (`Lean4Tutorial/i002_replicate_MP/Results.lean:147-188`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:26`) | Two supplied solutions of (13), ordered cutoffs, cutoff bounds, and `A.q_antitone` plus sign assumptions. | No prior project theorem; no downstream consumer. | **Proved conditional locus result:** genuine inference from equation (13), but not a joint equilibrium comparative static. |
| 14 | `Primitives.dispersionCutoffResponse_pos` (`Lean4Tutorial/i002_replicate_MP/Results.lean:190-207`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:27`) | `A.r_pos`, `A.λ_nonneg`, `A.σ_pos`, `A.F_nonneg`, and supplied net-price inequality. | No prior project theorem; no downstream consumer. | **Representational:** proves positivity of the defined right side of (11), not that an implicit derivative exists or equals it. |
| 15 | `Primitives.boomJobCreation_zero_transition_iff` (`Lean4Tutorial/i002_replicate_MP/Results.lean:209-220`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:28`) | Definitions (30) and (13); no assumptions. | No prior or downstream project theorem. | **Algebraic consistency check.** |
| 16 | `Primitives.anticipation_reduces_boom_tightness` (`Lean4Tutorial/i002_replicate_MP/Results.lean:222-282`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:29`) | Positive transition rate, ordered cutoffs, positive anticipated denominator, supplied solutions of (13)/(30), and sign/antitonicity assumptions. | No prior project theorem; no downstream consumer. | **Proved conditional result:** fixed-cutoff comparison only; cutoff responses to anticipation are supplied rather than solved. |
| 17 | `Primitives.beveridge_denominator_pos` (`Lean4Tutorial/i002_replicate_MP/Results.lean:284-289`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:30`) | Positive `θ`, theorem #9, and theorem #11. | Depends on #9/#11; used by `gross_flows_balance` (`Lean4Tutorial/i002_replicate_MP/Results.lean:339-351`). | **Proved.** |
| 18 | `Primitives.creationFlow_mono` (`Lean4Tutorial/i002_replicate_MP/Results.lean:291-297`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:31`) | `u ≥ 0` and a supplied ordering of worker meeting rates. | Used by `aggregateShock_flow_orders` and `dispersionShock_flow_orders` (`Lean4Tutorial/i002_replicate_MP/Results.lean:315-329`). | **Conditional/algebraic.** |
| 19 | `Primitives.destructionFlow_mono` (`Lean4Tutorial/i002_replicate_MP/Results.lean:299-305`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:32`) | `A`, `u ≤ 1`, cutoff ordering, and theorem #10. | Depends on #10; used by both flow-order theorems (`Lean4Tutorial/i002_replicate_MP/Results.lean:317`, `Lean4Tutorial/i002_replicate_MP/Results.lean:329`). | **Proved conditional monotonicity.** |
| 20 | `Primitives.aggregateShock_flow_orders` (`Lean4Tutorial/i002_replicate_MP/Results.lean:307-317`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:33`) | Same `P`, same `u`, bounds on `u`, and supplied `θ₀≤θ₁`, `εd₁≤εd₀`; uses `A.mWorker_monotone`. | Depends on #18/#19; no downstream theorem. | **Assumption-heavy:** it does not compare two primitives with different `p` or derive either equilibrium ordering. |
| 21 | `Primitives.dispersionShock_flow_orders` (`Lean4Tutorial/i002_replicate_MP/Results.lean:319-329`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:34`) | Same `P`, same `u`, bounds on `u`, and supplied `θ₀≤θ₁`, `εd₀≤εd₁`. | Depends on #18/#19; no downstream theorem. | **Assumption-heavy:** `σ` does not vary in the theorem's type; only the expected cutoff/tightness orderings vary. |
| 22 | `SteadyStateEquilibrium.gross_flows_balance` (`Lean4Tutorial/i002_replicate_MP/Results.lean:337-351`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:36`) | `A`, an `E : SteadyStateEquilibrium P`, its supplied Beveridge equation, and theorem #17. | Depends on #17; used by `unemploymentDrift_eq_zero` (`Lean4Tutorial/i002_replicate_MP/Results.lean:354-360`). | **Proved accounting consequence of assumed equation (14).** |
| 23 | `SteadyStateEquilibrium.unemploymentDrift_eq_zero` (`Lean4Tutorial/i002_replicate_MP/Results.lean:353-360`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:37`) | `A`, steady-state object, and theorem #22. | Depends on #22; no downstream consumer. | **Proved accounting consequence.** |
| 24 | `SteadyStateEquilibrium.v_eq_θ_mul_u` (`Lean4Tutorial/i002_replicate_MP/Results.lean:362-365`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:38`) | Definition `SteadyStateEquilibrium.v`. | No project theorem dependency or consumer. | **Definitional/reflexive.** |
| 25 | `aggregateShock_negative_comovement` (`Lean4Tutorial/i002_replicate_MP/Results.lean:378-386`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:40`) | Arbitrary real flows plus supplied strict inequalities `C₀<C₁` and `D₁<D₀`. | No model theorem dependency or downstream consumer. | **Algebraic restatement:** the claimed economic conclusion is already fully present in the hypotheses. |
| 26 | `dispersionShock_positive_comovement` (`Lean4Tutorial/i002_replicate_MP/Results.lean:388-396`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:41`) | Arbitrary real flows plus supplied strict inequalities `C₀<C₁` and `D₀<D₁`. | No model theorem dependency or downstream consumer. | **Algebraic restatement:** the claimed economic conclusion is already fully present in the hypotheses. |
| 27 | `unemploymentDrift_pos_iff` (`Lean4Tutorial/i002_replicate_MP/Results.lean:398-405`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:42`) | Arbitrary `P, θ, εd, u`; unfolds the drift definition. | No project theorem dependency or consumer. | **Algebraic identity.** |
| 28 | `employment_change_identity` (`Lean4Tutorial/i002_replicate_MP/Results.lean:407-412`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:43`) | Arbitrary real `N, C, D`; unfolds `nextEmployment`. | No project theorem dependency or direct consumer. | **Algebraic identity.** |
| 29 | `downturn_destruction_exceeds_ongoing` (`Lean4Tutorial/i002_replicate_MP/Results.lean:414-421`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:44`) | Arbitrary destruction terms and supplied positivity of immediate destruction. | No model theorem dependency or consumer. | **Algebraic restatement:** positivity is not derived from the scrapping integral or a downturn. |
| 30 | `boom_without_scrapping` (`Lean4Tutorial/i002_replicate_MP/Results.lean:423-427`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:45`) | Arbitrary ongoing destruction with the immediate term set definitionally to zero. | No project theorem dependency or consumer. | **Algebraic identity:** no boom-state model forces the zero term. |
| 31 | `SimulationPath.employment_change` (`Lean4Tutorial/i002_replicate_MP/Results.lean:429-436`; `Lean4Tutorial/i002_replicate_MP/Verification.lean:46`) | A supplied `SimulationPath` and its `employment_law` field. | No prior theorem; no downstream consumer. | **Proved from a structure field that already assumes equation (38).** |

## 8. Finite-state and dynamic constructions

### 8.1 Two-state structures

**[High] `TwoStateEquilibrium` assumes the main comparative statics.** Its fields include
`p_order`, `θ_order`, and `εd_order`
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:90-98`). Supplying an object therefore
requires supplying the boom/recession tightness and cutoff conclusions; no constructor
theorem derives them from equations (10) and (13). The existing TeX audit correctly
warns that these are data, not conclusions
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:375-392`).

**[High] The two states are not constrained to differ only in aggregate productivity.**
`TwoStateEquilibrium` accepts independent `recession boom : Primitives` and requires only
`recession.p < boom.p`; no field equates `r`, `λ`, `σ`, `β`, `c`, `b`, `εu`, `dF`, or
`q` across states (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:90-98`). Thus an
instance could attribute its ordering to simultaneous changes in every primitive, unlike
the paper's isolated common-price experiment (local paper PDF, printed pp. 405-408).

`AnticipatedTwoStateEquilibrium` improves cross-state consistency by using a common `P`
and passing `p` and `pStar` explicitly to the destruction predicates
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:100-127`). It still takes
`p_order`, `εdStar_lt_εd`, and the four reduced equilibrium equations as fields
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:118-132`), so it represents rather
than solves the two-state equilibrium.

### 8.2 General Markov structures

`MarkovEquilibrium` permits any state type and uses an infinite sum `∑'` for row totals
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:134-142`). It packages an independent
static `SteadyStateEquilibrium` in every state, so it omits anticipation terms and does
not implement paper equations (32)-(34). The companion audit explicitly identifies this
weaker status (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:420-422`).

`GeneralMarkovValueEquilibrium` requires a finite state type and includes:

- state-dependent `θ`, cutoff, surplus, arrival rate, and kernel
  (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:146-160`);
- free entry (32) and cutoff zero (33) as fields
  (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:161-166`);
- the Markov surplus equation (34), including the next-state expectation
  (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:167-176`).

**[High] The truncated-integral equivalence is not secured.** Paper (34) integrates
current-state surplus over surviving shocks above the state cutoff (local paper PDF,
printed p. 409). Lean instead uses `positiveContinuation`, the integral of
`max(S,0)` over the whole measure
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:76-78`,
`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:174-176`). This is economically
equivalent only with an appropriate reservation-sign rule and support assumptions, but
`GeneralMarkovValueEquilibrium` includes only `S(εd s,s)=0`, not
`0≤S(ε,s) ↔ εd(s)≤ε`, and it does not carry `Assumptions (P s)`
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:156-176`).

**[Medium] The state process is more general but less tied to the paper.** Every state may
have a completely different `Primitives` object
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:146-147`), whereas
the Section 5 formulation treats aggregate productivity as the Markov state while holding
the remaining calibrated primitives fixed (local paper PDF, printed pp. 409-411).

**[High] There is no finite-state construction witness.** No declaration instantiates
`State` with `Fin 2`, `Fin 3`, or another concrete type; no declaration constructs a
row-stochastic matrix; and no theorem proves that either Markov structure is inhabited.
The file ends after the abstract structures and simulation interface
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:134-201`).

### 8.3 Simulation path

**[High] Ongoing destruction is unconstrained.** `SimulationPath` requires only
`D = D_immediate + D_ongoing`; it supplies no formula tying `D_ongoing` to
`λF(εd)`, employment, or the employment distribution
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:186-199`). The companion audit
acknowledges this (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:424-448`).

**[High] The `P` parameter is unused.** Although the structure is declared
`SimulationPath (P : Primitives)`, no field refers to `P`
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:181-199`). A path therefore has no
formal relationship to a shock distribution, matching function, equilibrium cutoff, or
aggregate state.

**[High] Immediate scrapping is not connected to a downturn.**
`immediateScrapping` is an oriented interval integral with no nonnegativity assumption on
`n` or ordering assumption on the cutoffs
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:236-239`). The corresponding theorem
begins by assuming the computed term is positive rather than deriving positivity from job
mass and a raised cutoff (`Lean4Tutorial/i002_replicate_MP/Results.lean:414-421`).

**[Medium] State bounds are absent.** `SimulationPath` does not require
`0≤N≤1`, nonnegative creation/destruction, or feasible next employment
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:181-199`). Hence the encoded laws can
hold for economically impossible paths.

## 9. Principal assumption-conclusion mismatches

### 9.1 Reduced equilibrium is assumed rather than derived

The value interface contains equations (1)-(7), the cutoff, and reservation rule
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:17-49`). The reduced interface
separately requires equations (10), (13), and (14)
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:51-66`). There is no conversion theorem
showing:

```text
ValueEquilibrium + analytic assumptions
    ⇒ closed-form S_cutoff
    ⇒ JobDestructionCondition
    ⇒ JobCreationCondition
    ⇒ SteadyStateEquilibrium.
```

The only bridge-like result proves that the separately defined equation (13) is
equivalent to zero profit using the separately defined `J_cutoff`
(`Lean4Tutorial/i002_replicate_MP/Results.lean:121-145`). It does not identify an
arbitrary `ValueEquilibrium.J` with `J_cutoff`.

### 9.2 Probability mass is required for the Bellman interpretation but not attached

The paper's continuation term in equations (5)-(6) is an expectation of
`max(S(x),0)-S(ε)` (local paper PDF, printed p. 400). Lean writes it as
`positiveContinuation S - S ε`
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:113-128`), which is the same algebra
only when `dF` has total mass one. Probability mass is a field of the separate
`Assumptions` bundle (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:265-266`), but
`ValueEquilibrium` does not contain or request that bundle
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:18-49`). The formal theorem deriving
equation (8) is internally correct for Lean's definitions, but the definitions need not
match the paper for an arbitrary `P`.

### 9.3 Equation (11) is named as a response without proving a derivative

`dispersionCutoffResponse` is simply a real-valued formula
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:151-157`). The theorem proves that
formula positive under a net-price inequality
(`Lean4Tutorial/i002_replicate_MP/Results.lean:190-207`). It does not:

- define a parameterized equilibrium cutoff;
- establish differentiability or an implicit-function theorem;
- prove the displayed formula equals `σ ∂εd/∂σ`;
- account for the equilibrium response of `θ`.

The companion audit correctly states this limitation
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:290-299`,
`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:498-500`).

### 9.4 Shock labels overstate theorem content

`aggregateShock_flow_orders` accepts cutoff and tightness orderings while keeping one
fixed `P` and one fixed unemployment level
(`Lean4Tutorial/i002_replicate_MP/Results.lean:307-317`). The scalar `p` does not occur in
its statement. Likewise, `dispersionShock_flow_orders` keeps one fixed `P`, so no two
values of `σ` occur in its type (`Lean4Tutorial/i002_replicate_MP/Results.lean:319-329`).
The theorem names and comments describe shocks, but the types prove only conditional flow
monotonicity.

The strict co-movement theorems are even farther removed: they quantify over four
arbitrary real numbers and assume exactly the strict flow inequalities needed for the
sign of their product (`Lean4Tutorial/i002_replicate_MP/Results.lean:369-396`). They do
not use `Primitives`, an equilibrium, or the earlier weak flow-order theorems.

### 9.5 Existence and uniqueness claims are not formalized

The paper states that equations (10) and (13) uniquely determine market tightness and the
destruction cutoff (local paper PDF, printed p. 402). Lean defines a
`SteadyStateEquilibrium` as any triple already satisfying the equations
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:51-66`). There is no theorem asserting
existence, uniqueness, nonemptiness, or comparative statics of the joint solution. The
existing audit accurately lists existence and uniqueness as outside current scope
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:593-601`).

### 9.6 “Replication” does not include the quantitative exercise

The paper calibrates a three-state chain, solves equations (32)-(34), simulates equations
(35)-(38), and compares moments with U.S. data (local paper PDF, printed pp. 409-412).
Lean includes abstract fields for (32)-(34) and simplified accounting definitions for
(36)-(38), but no equation (35), matrix (39), matching equation (40), parameter table,
computed solution, simulation, or moment comparison
(`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:134-199`). The README explicitly
excludes rerunning Section 5 (`Lean4Tutorial/i002_replicate_MP/README.md:60-64`).

## 10. Existing proof documentation: accuracy and omissions

### 10.1 What the companion audit does well

The TeX/PDF companion:

- distinguishes definitions, structure fields, theorems, and no-sorry checks
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:94-106`);
- gives conventional mathematical renderings of the main paper-numbered equations
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:216-373`);
- explicitly warns that the two-state orderings are data rather than derived conclusions
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:375-392`);
- states that the derivative interpretation of equation (11) is not proved
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:290-299`);
- states that the weaker Markov structure does not impose (32)-(34)
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:420-422`);
- states that ongoing destruction is supplied rather than constrained
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:445-448`);
- classifies aggregate/dispersion orderings as assumed and existence, uniqueness, and
  calibration as unproved or out of scope
  (`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:571-601`).

Its core warning is accurate: a valid implication can have the desired economic
conclusion already embedded in its hypotheses
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:605-609`).

### 10.2 Material gaps not emphasized by the companion audit

The existing audit does not prominently identify:

- the missing atomless, mean-zero, unit-variance, strict-elasticity, and analytic
  regularity assumptions relative to the paper
  (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`; local paper PDF,
  printed pp. 399-400);
- the cutoff-atom inconsistency created by `Iic`, `λF(εd)`, and weak acceptance at the
  cutoff (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:48-50`,
  `Lean4Tutorial/i002_replicate_MP/Definitions.lean:80-82`,
  `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:48-49`);
- the fact that `TwoStateEquilibrium` permits all primitives, not just `p`, to vary
  across states (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:90-98`);
- the lack of a reservation-sign rule in `GeneralMarkovValueEquilibrium`, needed to
  identify the full-support `max` integral with the paper's truncated integral
  (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:156-176`);
- the unused `P` parameter and lack of feasibility bounds in `SimulationPath`
  (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:181-199`);
- that `assert_no_sorry` is narrower than a complete axiom audit
  (`Lean4Tutorial/i002_replicate_MP/Verification.lean:7-10`).

The companion's statement that it translates the “complete mathematical interface” is
reasonable for declarations present in the Lean files
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:63-70`), but should not
be read as claiming a complete interface to every equation or argument in the paper.

## 11. Progress classification in detail

### 11.1 Syntactic completeness: **complete / high**

Completed:

- pinned Lean/mathlib environment and a dedicated entry point
  (`lean-toolchain:1`, `lakefile.toml:12-18`,
  `Lean4Tutorial/i002_replicate_MP.lean:1-19`);
- four-module import chain with all current files directly elaborating;
- 31 theorem declarations paired one-for-one with 31 `assert_no_sorry` checks
  (`Lean4Tutorial/i002_replicate_MP/Verification.lean:13-46`);
- no unfinished proof commands or project-defined axiom declarations in the audited Lean
  sources (`Lean4Tutorial/i002_replicate_MP/Results.lean:11-13`).

Qualification: the audit intentionally did not perform a clean `lake build`, so
reproducibility from an empty build cache remains untested in this read-only pass.

### 11.2 Logical adequacy: **partial**

Strongest logical content:

- value-equation aggregation and cutoff/free-entry algebra
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:24-62`);
- sign and monotonicity lemmas from explicit assumptions
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:88-119`);
- a genuine conditional proof that the JC locus slopes downward
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:147-188`);
- stationary flow balance and zero drift from the Beveridge equation
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:337-360`);
- accounting identities for period employment
  (`Lean4Tutorial/i002_replicate_MP/Results.lean:398-436`).

Main logical gaps:

- no derivation of reduced equations (10), (12), (13), or (14) from the value equilibrium;
- no bridge between `ValueEquilibrium` and `SteadyStateEquilibrium`;
- no existence, uniqueness, or comparative-statics theorem for joint equilibrium;
- no derivation of aggregate/dispersion orderings;
- no Markov equilibrium construction or solution;
- no formal link from simulated paths to equilibrium primitives.

These gaps are visible in the separation between definitions/fields
(`Lean4Tutorial/i002_replicate_MP/Definitions.lean:143-247`,
`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:51-199`) and the conditional theorem
types (`Lean4Tutorial/i002_replicate_MP/Results.lean:190-329`,
`Lean4Tutorial/i002_replicate_MP/Results.lean:378-436`).

### 11.3 Economic fidelity: **partial / limited**

Faithful representational elements:

- recognizable versions of paper equations (1)-(8), (10)-(15), (20), (24),
  (29)-(30), (32)-(34), and (36)-(38)
  (`Lean4Tutorial/i002_replicate_MP/README.md:38-58`);
- correct distinction between vacancy meeting rate `q(θ)` and worker meeting rate
  `θq(θ)` (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:56-62`);
- explicit cutoff, free-entry, Beveridge, Markov, and short-run accounting interfaces.

Fidelity limitations:

- the paper's stochastic and matching assumptions are only partially represented;
- important formula equivalences depend on assumptions not attached to the relevant
  structures;
- stationary and anticipated equilibrium conditions are packaged rather than derived;
- shock comparative statics are conditional on their main economic conclusions;
- abstract state structures replace the paper's concrete process and solution;
- the employment-distribution dynamics and entire quantitative replication are absent.

Accordingly, “formalization of selected theoretical equations and consequences” is a more
precise description of current progress than “complete replication.”

## 12. Recommended next proof milestones

These are audit recommendations, not changes made by this report.

1. **[High] Attach a paper-faithful assumptions object to equilibrium constructions.**
   Add atomlessness, moment normalization, support/regularity, economic domains, and
   strict matching properties where genuinely needed; remove redundant assumptions that
   can be proved from the measure definition
   (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:251-280`).

2. **[High] Prove the value-to-reduced-equilibrium bridge.** Derive the cutoff surplus,
   equations (10) and (13), and the zero-profit result for the actual
   `ValueEquilibrium.J`, under explicit analytic hypotheses
   (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:17-66`).

3. **[High] Formalize joint comparative statics.** State two equilibria whose primitives
   differ only in `p` or `σ`, then derive the `θ`/`εd` orderings used by the flow theorems
   (`Lean4Tutorial/i002_replicate_MP/Results.lean:307-329`).

4. **[High] Strengthen the Markov model.** Carry statewise assumptions and reservation
   rules, define a concrete finite state space and transition matrix, and construct or
   prove existence of a solution to (32)-(34)
   (`Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:134-176`).

5. **[High] Encode equation (35) and full destruction equation (37).** Tie
   `SimulationPath` to `P`, equilibrium states, cutoffs, and the employment distribution;
   derive immediate-scrapping positivity and path feasibility rather than assuming them
   (`Lean4Tutorial/i002_replicate_MP/Definitions.lean:232-247`,
   `Lean4Tutorial/i002_replicate_MP/Equilibrium.lean:178-199`).

6. **[Medium] Reproduce the Section 5 finite-state calibration.** Encode the matrix,
   parameter values, computed equilibrium, and a separately verified numerical or
   interval-arithmetic replication of the reported statistics (local paper PDF, printed
   pp. 411-412).

## 13. Final audit verdict

The repository is syntactically mature and unusually transparent about its use of
`assert_no_sorry`. Its 31 theorems are real Lean proofs of their stated propositions.
However, theorem names and prose sometimes sit at a higher economic level than the types:
“shock” results often assume the shock-induced orderings, “response” names can denote a
formula rather than a derivative, and “equilibrium” structures often package equations
without constructing solutions.

The appropriate current classification is:

```text
Syntactic completeness:  COMPLETE / HIGH
Logical adequacy:         PARTIAL
Economic fidelity:        PARTIAL / LIMITED
Full MP1994 replication:  NOT YET
```

This verdict is consistent with the existing companion audit's own scope table
(`Lean4Tutorial/i002_replicate_MP/mp1994_lean_formalization.tex:571-601`) while adding
the distributional, cutoff-atom, cross-state, Markov-integral, and simulation-parameter
issues identified above.
