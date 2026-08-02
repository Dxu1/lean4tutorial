# M9.2 cutoff-ordering analysis

This note is a proof-planning and adequacy artifact. It is not an assumption
source.

## Exact target

The target is the strict paper ordering

\[
d_B < d_R,
\]

where `d_B` and `d_R` are the unique zeros of boom and recession surplus,
respectively.

## Available assumptions and results

The attempted proof may use only:

- `T.pHigh > P.p`;
- `T.aggregateArrival > 0`;
- `CoreEconomicAssumptions P`;
- `ShockAssumptions P`;
- `MatchingAssumptions P`;
- a supplied `TwoStateValueEquilibrium P T`;
- derived strict monotonicity, continuity, unique statewise cutoffs, and
  statewise free entry.

The paper motivates the ordering by saying that the static analysis “leads us
to expect” it; it does not supply a separate general proof under exactly this
primitive assumption set.

## Candidate proof routes

1. Assume the reverse weak order `d_R ≤ d_B` and seek a contradiction from the
   coupled surplus system.
2. Establish cross-state surplus comparison region by region from the two
   possible cutoff geometries.
3. Combine upper-support surplus comparison with statewise free entry to infer
   a market-tightness order.
4. Compare regional slopes and evaluate the statewise equations at their
   cutoffs.

## Initial failed route

The reverse-order geometry implies that recession surplus is weakly above boom
surplus and, at the upper support, strictly above it. Statewise free entry then
implies the opposite ordering of vacancy meeting rates and hence a tightness
ordering. This does **not** yield a contradiction from the current equations.

After subtracting the two coupled surplus equations, the remaining terms have
competing signs:

- the boom productivity gap `T.pHigh - P.p` is positive;
- the difference of statewise active-surplus integrals has the opposite sign
  under the reverse geometry;
- the statewise search-gain difference depends on endogenous tightness;
- the aggregate-transition positive-part gap has a further signed contribution.

Neither matching monotonicity nor free entry bounds the magnitude of the
endogenous search-gain term relative to the productivity and continuation
terms. Thus the needed implication from the available hypotheses to
`d_B < d_R` is not currently derivable. A counterexample appears possible by
varying the matching schedule and the induced tightness/search-gain gap while
preserving all current sign and monotonicity assumptions.

The weakest plausible additional condition is a cross-state restriction that
controls the outside-option/search-gain response—equivalently, a sufficient
bound on the boom-versus-recession tightness-weighted search gain relative to
the productivity gap and continuation-value difference. A stronger but more
transparent candidate would be an independently justified cross-state surplus
ordering. No such condition is introduced in Lean pending a separate economic
review.

This was the initial obstruction report. It is retained as historical context;
human review subsequently identified a stronger route that does not require a
new assumption.

## Review-discovered maximum-principle route

Under the contrary weak order `d_R ≤ d_B`, the reviewed plan is:

1. prove `S_B(eps) ≤ S_R(eps)` in the three regions below `d_R`, between the
   cutoffs, and above `d_B`;
2. obtain the same weak order at `epsUpper` and use statewise free entry to
   prove `theta_B ≤ theta_R`;
3. write `D_u = S_B(epsUpper) - S_R(epsUpper) ≤ 0`;
4. prove pointwise
   `D_u ≤ S_B⁺(x) - S_R⁺(x)` and integrate it to
   `D_u ≤ I_B - I_R`;
5. subtract the coupled surplus equations at `epsUpper`, eliminate search
   gains with free entry, and prove

   \[
   (r+\lambda+2\mu)D_u
   =(p^*-p)+\lambda(I_B-I_R)
     +\frac{\beta c}{1-\beta}(\theta_R-\theta_B);
   \]

6. lower-bound the right side by `(pHigh - p) + lambda * D_u`, yielding
   `(r + 2*mu) * D_u ≥ pHigh - p > 0`, contrary to `D_u ≤ 0`.

M9.2B is therefore no longer classified as mathematically blocked. Before
implementation it is **NOT STARTED — REVIEWED PROOF ROUTE AVAILABLE**. The
route must still be checked in Lean, and no cutoff-order, surplus-order,
tightness-order, or search-gain assumption may be added.
