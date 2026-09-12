# M03B1 analytical audit

Baseline: `7f7fb35e006804b358aba144126f69bee1df0440`.

| Required question | Answer and proof evidence |
|---|---|
| Is the original-consumption/extra-saving deviation formalized? | Yes. `value_extraSaving_comparison` uses the feasible action `A(z)+h` at `z+h`, proves current consumption is unchanged, and invokes H04 Bellman maximization. |
| Is division by `h` exact? | Yes. `secant_extraSaving_comparison` divides by positive `h` and algebraically exposes the chain factor `grossReturn`. |
| Is the extended inequality first? | Yes. `secant_extraSaving_lintegral` converts only finite-h continuous nonnegative secants to `lintegral`. `extendedRightMarginalValue_superharmonic` then applies monotone convergence. |
| Is monotone convergence genuine? | Yes. `marginalStep=1/(n+1)` decreases to zero; concavity makes the resulting right secants increase. `lintegral_tendsto_of_tendsto_of_monotone` is applied to measurable secant approximants. |
| Is zero handled by the accepted boundary object? | Yes. `extendedRightMarginalValue m 0` reduces to `zeroRightMarginal m : ENNReal`. The positive branch alone uses `rightMarginalValue`; no occurrence of `rightMarginalValue m 0` is used economically. |
| Can the zero marginal remain infinite? | Yes. The unconditional extended theorem has no finiteness premise and permits infinity. The real theorem is conditional on the left extended marginal being finite. |
| Is conditional finiteness deduced rather than assumed? | Yes. Positivity of beta and `R` plus the extended inequality prove `continuationMarginal_lintegral_lt_top`. This yields continuation marginal finiteness almost everywhere. |
| Is a real integral introduced only after integrability? | Yes. `integrable_toReal_of_lintegral_ne_top` proves integrability before `integral_toReal` is used to derive the real inequality. |
| Does H09 use BASIC only? | Yes. The actual inputs are `HouseholdPrimitives`, H04 optimality, and H08 secant/boundary results. No additional record or proposition parameter appears. |
| Is impatience absent? | Yes. Only positivity of beta and gross return is used. There is no `beta*R<1` premise or proof dependency. |
| Is consumption positivity absent? | Yes. The deviation preserves the original current consumption, including a possible zero-consumption corner. No H10 declaration or premise is imported. |
| Is the labor law still general? | Yes. The theorem quantifies over the primitive compact labor subtype and its arbitrary probability law; no density, atom, finite-support, or nondegeneracy premise is added. |

## Source audit

The approved CW00 file hash is
`da7a2fb270c597cbc9ac8b827674b45316c58cbe70af7e647af01b30afbdc173`.
Rendered inspection found the motivating supermartingale/value-right-derivative inequality at
printed p. 367 / PDF p. 3 and Lemma 1(a)'s conditional inequality at printed p. 372 /
PDF p. 8.  CW00 says the proof is standard and omits it.  H09 is therefore new formal
concave-analysis infrastructure following architecture section 4.1, not a claim that CW00
contains the Lean proof or a literal numbered Aiyagari theorem.

## Assumption and axiom conclusion

H09's actual/transitive economic assumptions are exactly BASIC.  Its transitive Lean axioms
are `propext`, `Classical.choice`, and `Quot.sound`, inherited through the constructed Bellman
fixed point and canonical optimizer.  No project axiom, `sorryAx`, unsafe bypass, or closure
assumption occurs.  The contract is REVIEW_READY, not GREEN.
