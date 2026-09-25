# Milestone M04A - joint household continuity before stationarity

Date: 2026-09-25. Accepted baseline: `d513a22d437ce6e9b8393fccf2e81083b84a4123`. Lean: `leanprover/lean4:v4.32.0`. Mathlib: `81a5d257c8e410db227a6665ed08f64fea08e997`. Assigned scope: H06 only.

## Results against the contract

H06, `Aiyagari1994.policy_jointly_continuous` in `Aiyagari1994/Household/ParameterContinuity.lean`: **REVIEW_READY**. With utility, the compact iid labor law, and beta fixed, it proves joint continuity of the canonical value function and shifted-asset policy in resources and every admissible normalized price triple `(R,w,k)`. The only price restrictions are `R>0`, `w>0`, and nonnegative effective income. Thus `beta*R=1` and `beta*R>1` are included.

The theorem uses BASIC only and depends on accepted H02 and H04. No smoothness, Inada, CoreRegularity, consumption positivity, bounded asset state, stationarity, or impatience premise is added. No other contract status or field changed. D02 and all later contracts remain UNFORMALIZED.

## Proof route and changes

The new helper module `Aiyagari1994/Analysis/M04A/JointContinuity.lean` defines the admissible normalized coordinate subtype and a repricing operation that changes only prices. Each finite Bellman iterate from zero is jointly continuous: normalized transitions are continuous, integration is over the fixed compact labor probability space, and the action is represented by a share in the fixed compact interval `[0,1]`.

If `|U|<=C`, the fixed-beta contraction and the uniform bound on the canonical value yield

`|T_q^n 0(z)-V_q(z)| <= beta^n*C/(1-beta)`

for every admissible price and every nonnegative resource state. Uniform convergence transfers continuity to the infinite-horizon value without assuming price continuity of the Bellman operator in global sup norm on an unbounded state space.

For positive resources, the unique maximizing share varies continuously by compact unique argmax, and multiplication by resources gives policy continuity. At zero, H04's `0<=A_q(z)<=z` bound supplies a price-uniform squeeze; the proof does not claim share uniqueness at zero.

All implementation helpers are contained in the authorized M04A helper directory. The authoritative primitive, H02 and H04 files are unchanged. `All.lean` imports the completed H06 module; `Audit.lean` and `Probes/M04ASignatures.lean` audit every new public declaration.

## Verification evidence

All required checks completed successfully in the pinned environment:

- `lake build Aiyagari1994.Household.ParameterContinuity Probes.M04ASignatures` exited 0 after 2,651 jobs.
- `lake env lean Probes/M04ASignatures.lean` exited 0. Every new public declaration passed `assert_no_sorry`; transitive axioms are exactly `propext`, `Classical.choice`, and `Quot.sound`.
- After rebuilding `All`, `lake env lean Audit.lean` exited 0 with all new public declarations covered by `#check`, `assert_no_sorry`, and `#print axioms`.
- `lake build` exited 0 after 2,811 jobs. Existing linter suggestions and one M04A style suggestion are non-errors.
- `python3 tools/check_contracts.py` exited 0: 57 contracts, 17 GREEN, H06 as the sole REVIEW_READY contract, and 39 UNFORMALIZED.
- `bash tools/build_docs.sh proof_ledger` exited 0 and rebuilt the synchronized 47-page `docs/proof_ledger.pdf`. There are no overfull boxes or undefined references; historical underfull-box warnings remain.
- Ledger PDF pages 17-18 were rendered at 130 DPI and visually inspected after adding a clean H06 section break. The status, mathematical statement, tail bound, zero-boundary argument, exact signature, axiom line, source qualifications, and transition to H07 are readable with no clipping, overlap, malformed glyphs, or footer collision.
- The prohibited-pattern scan over the new Lean files and `git diff --check` exited 0; no orchestration state or verification log was written by the executor.

The controller owns execution logs and review archives, so no manual ZIP was created.

## Adequacy audit

All 110 supplied predecessor entries remain mandatory and unsuperseded. The proof preserves the distinction between `rightMarginalValue m 0` and `zeroRightMarginal`, although neither appears in H06. It preserves continuous resources, the general compact iid labor law, normalized shifted-resource coordinates, predecessor budget limits, and the finite-history lifetime interpretation. No drift, invariant-law, asset-supply, tightness, or equilibrium statement follows from H06. Full details are in `reports/m04a_analytical_audit.md` and the synchronized proof ledger.

## Blockers and review request

No implementation blocker remains. H06 is submitted at REVIEW_READY for independent adequacy review. No GREEN status is claimed, and this capsule authorizes no advancement beyond M04A.
