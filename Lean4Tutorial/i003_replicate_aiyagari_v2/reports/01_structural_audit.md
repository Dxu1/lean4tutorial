# Milestone 01 primitive and adequacy audit

Status: REVIEW_READY, external M01 adequacy review pending. M00 acceptance remains GREEN for bootstrap only.

All twelve structures introduced in `Aiyagari1994/Primitives/Basic.lean` were printed by `Audit.lean` and manually inspected. The raw output is in `reports/logs/01/audit.log`.

| Structure | Authorized contents |
|---|---|
| UtilityData | Real-to-real utility function only |
| UtilityBase | Continuity, absolute boundedness, strict increase and strict concavity on nonnegative consumption |
| UtilitySmooth | C1 on positive consumption and strictly positive ordinary derivative there |
| UtilityCurvature | C2 on positive consumption, positive eventual threshold and a finite real relative-risk-aversion bound |
| IncomeData | Real labor endpoints and an arbitrary probability law on their compact interval subtype |
| IncomeSupport | Positive lower endpoint and ordered endpoints |
| IncomeNondegenerate | Distinct endpoints and positive mass in every relative endpoint neighborhood |
| LaborMeanOne | Mean normalization; general labor integrability is separately proved by `labor_integrable` |
| NormalizedPrices | Gross return, wage, intercept, positive return/wage and nonnegative effective income |
| OriginalPrices | Net rate, wage, debt limit and their primitive admissibility; gross return is derived as one plus net rate |
| HouseholdPrimitives | Discount factor in (0,1), base utility, income/support and normalized prices |
| CoreRegularity | Optional smoothness/curvature, income nondegeneracy and mean normalization, keeping the base problem broader |

No structure has a value function, Bellman existence/uniqueness, policy, policy order, Euler/envelope identity, absorbing bound, Feller/crossing/mixing condition, invariant law, asset-supply statement, equilibrium object or other later-contract conclusion. The base household does not assume beta times gross return is less than one. Neither finite marginal utility nor Inada at zero is imposed on the general utility type.

Assets and resources use NNReal. Labor lives on a real interval subtype, with no finite-state or density restriction. Only the P03 witness uses two atoms. Its exact support, endpoint masses, mean, regularity and parameter values are proved, not fields supplied as assumed conclusions. The mean calculation has explicit integrability for each finite weighted measure; generic labor integrability follows from compactness and probability mass. IID finite products, coordinate marginals, independence and the one-draw/tail decomposition are constructed uniformly for every IncomeData.

P01 has no economic premise because the normalization is a real algebraic identity. P02 needs only fixed nonnegative b, strictly positive labor floor, positive wages, and the branch-specific rate conditions. P03 has no premises: it constructs the complete specified witness in the same general structures. Exact elaborated signatures and foundational axioms are in `reports/logs/01/contract_signatures.log`.

The contract statements, assumption profiles, dependencies and scope are unchanged. The finite and natural price constructors are separate branches. The raw natural debt limit is continuous only at positive rates; its normalized intercept is exactly minus wage times the labor floor. The max-denominator identity used for finite-cap continuity is an equivalent proof device, with an additional explicit neighborhood result at zero.

Source check: A94 printed pp. 665-666 / PDF pp. 8-9 were visually inspected. Budget timing, shifted-asset meaning, piecewise effective limit, and next-resource equation agree with equations (1b), (2a)-(2b), (3a)-(4b). No claim about the No-Ponzi footnote is certified here. The exact P03 utility/labor witness is supplied by the approved design, not attributed to those pages.

Qualifications: no household optimization, Bellman work, stationary law, equilibrium theorem, infinite path-space construction or numerical model has been implemented. General primitive consistency is the limit of P03's conclusion. M00's four reviewer qualifications remain in force. P01-P03 have not been awarded GREEN.
