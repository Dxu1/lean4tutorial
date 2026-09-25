# M05D analytical audit

Accepted baseline: `e88a8734d0a4d28640797ab4d40061ef139fad64`. Assigned contract: S04 only.

| Required question | Answer and proof evidence |
|---|---|
| Is the theorem genuinely about a Markov kernel? | Yes. The signature takes `k : Kernel (Icc a b) (Icc a b)` with `IsMarkovKernel k`. `lawStep` is exactly `k ∘ₘ mu`; `testStep` is exactly integration against `k x`. |
| Is the interval nonempty and compact? | Yes. `hab : a ≤ b` supplies both endpoints of `Icc a b`; compactness is the installed compact-subtype instance. No finite-state replacement is made. |
| Is Feller continuity used? | Yes. It bundles the test operator as a bounded-continuous function and proves continuity of `lawStep` in the weak topology. That continuity makes endpoint cluster limits invariant. |
| Is stochastic monotonicity used only in its authorized form? | Yes. `hMono` preserves nondecreasing bounded-continuous real tests. It orders endpoint iterates and supplies the stochastic sandwich; it assumes no strict order or policy differentiability. |
| Is crossing common-horizon and nonvacuous? | Yes. The signature requires one `N≥1`, one `0<eps≤1`, and the two displayed endpoint bounds for every increasing test. It does not assume an invariant law or convergence. S05 must derive these bounds from S03's event crossing and S01 monotonicity. |
| Are endpoint invariant laws constructed? | Yes. Compactness supplies cluster laws. Monotone bounded endpoint test sequences converge in full, increasing tests determine laws, and Feller continuity proves that both limits are fixed by `lawStep`. |
| Is oscillation contraction explicit? | Yes. The conclusion records `osc((T^[N])^[m] f) ≤ (1-eps)^m osc(f)` for every increasing bounded-continuous `f`. |
| Is uniqueness proved rather than assumed? | Yes. Contraction identifies the two endpoint laws. Every invariant law has a constant orbit, while the all-initial-law convergence result sends that orbit to the constructed law. |
| Is convergence weak only? | Yes. Convergence is `Tendsto` in Mathlib's `ProbabilityMeasure` weak topology. The determining-class proof uses polynomial uniform approximation. There is no total-variation, unbounded-test, or moment conclusion. |
| Are later economic claims excluded? | Yes. S04 has no household primitive, stationary-moment, asset-supply, equilibrium, or full-`NNReal` conclusion. S05 remains responsible for the economic wrapper and global state-space argument. |

## Assumption and axiom conclusion

S04 is a generic mathematical theorem with no economic assumption profile. Its actual premises are exactly the compact nonempty interval, Markov, Feller, stochastic-monotonicity, positive common horizon, and test-form crossing hypotheses in the signature. All eight public declarations have `#check`, `assert_no_sorry`, and `#print axioms` coverage. Their transitive axiom output contains only `propext`, `Classical.choice`, and `Quot.sound`. There is no `sorry`, `admit`, project axiom, `native_decide`, unsafe bypass, or numerical model.

## Source and design correspondence

The proof implements Architecture §7.2 and the assigned SLP89 locator: endpoint-law construction, Feller invariance, common-horizon geometric oscillation contraction, equality of endpoint limits, stochastic sandwiching, and weak convergence through a determining class. It does not certify total-variation convergence or any later paper-level stationary/equilibrium claim.
