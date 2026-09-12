# Milestone 00: bootstrap

Recommended reasoning: **High**.

You are the implementation agent for this clean Aiyagari theory-only Lean repository. Read `AGENTS.md`, `docs/architecture.md`, `docs/lean_interfaces.md`, and the relevant entries of `contracts/theorems.json` before editing. Execute **this milestone only**. The Pro reviewer has supplied the mathematical design; do not redesign or weaken it to obtain a build.

**Prerequisite gate:** None. Work in a new directory containing this package, not the failed project.

**Contract IDs:** Environment and source verification only; no economic theorem claimed.

## Work to execute

1. Inspect the package's existing files without inspecting the failed implementation. Locate the two read-only input archives `i003_replicate_aiyagari.zip` and `citations.zip` in the explicitly available workspace. Use only the approved extractor and exact whitelist:

```sh
python3 tools/check_contracts.py
python3 tools/extract_sources.py --aiyagari /resolved/path/i003_replicate_aiyagari.zip \
  --citations /resolved/path/citations.zip --output sources/papers
```

Replace the two paths by actual located files. Do not scan all source-code files inside the old archive. If inputs are not mounted, report the missing local files and continue independent environment setup; do not ask for papers already present or pretend they were read. No economic proof depends on the MP implementation; the formatting conventions are already in this package.

2. Initialize a clean Lean 4 package using namespace/package `Aiyagari1994`. Preserve this package's docs, contracts and prompts. If the setup command expects an empty directory, initialize in a temporary sibling directory and transfer only the new package configuration and root files after inspection. Determine a compatible Lean release and Mathlib commit from the actual dependency metadata; pin both. Do not guess a version number or copy the old project's dependencies. Create `lean-toolchain`, `lakefile.lean` or `lakefile.toml`, and the lock/manifest file. Record commit hashes and package versions in `reports/00_environment.md`.

3. Obtain the Mathlib cache if the pinned checkout supports it. Compile an actual `Probes/Core.lean` (or several small probe files) that checks and demonstrates:
   - bounded continuous functions and their complete sup-metric;
   - a Banach contraction fixed point with the exact available theorem names;
   - `NNReal` as a measurable, complete separable metric state space;
   - `ProbabilityMeasure`, a pushforward and one bounded-test integral identity;
   - probability Markov kernels, composition, and measure transport;
   - weak topology, compactness of probability laws on a compact interval, and the tight-family/Prokhorov API;
   - `assert_no_sorry` and `#print axioms` on a genuinely proved example.

Each probe must contain a small proved example, not only a list of imports. `contracts/api_sources.json` identifies official module locators; the actual checkout determines signatures. Search Mathlib source for the precise declarations instead of inventing them. Do not attempt to prove the whole SLP theorem in this milestone.

4. Create the clean build surface: root `Aiyagari1994.lean`, `All.lean`, and `Audit.lean`. Initially these may import only proved probe/basic infrastructure files. Do not create empty paper theorems or placeholder axioms. Add a `.gitignore` for build caches, source PDFs, temporary renders, and TeX intermediates; retain source hashes and paper locators in version control.

5. Produce `reports/00_api_inventory.md`: requirement; installed declaration/type; imported module; verified example; unresolved API infrastructure. In particular distinguish a weak-topology API from a ready-made invariant-law theorem. If Mathlib lacks our desired monotone-Feller theorem, that is planned mathematical work in milestone 05, not justification to assume it.

## Architecture preflight

Before coding economics, confirm that the chosen representations support the three sensitive points: an unbounded resource state with bounded value functions; extended right marginals at zero; and normalized price coordinates whose intercept remains bounded as the natural debt limit diverges. Flag any type-level incompatibility, but do not silently change the mathematical model.

No economic theorem becomes green at this stage. The review gate evaluates the environment, source inventory and API evidence.

## Verification, deliverables and stop

Run the targeted Lean build and then the full substantive build. Update `All.lean` only for completed modules. Check every new exported contract declaration in `Audit.lean` using `#check`, `assert_no_sorry`, and `#print axioms`, and record the actual outputs. Run `python3 tools/check_contracts.py`. No test here replaces economic adequacy review.

Update the theorem manifest without changing statements or assumptions silently. Write the readable proofs and exact signatures in the proof ledger, with all transitive economic hypotheses, source locators, explicit integrability facts and the argument actually formalized. Rebuild the PDF and inspect affected pages. Record unrun checks honestly.

Return `reports/MILESTONE_REPORT_TEMPLATE.md` completed for this milestone, the changed files, build/axiom logs and ledger/PDF. Successful implementation may be labeled `REVIEW_READY`; only the external acceptance record permits `GREEN`. If an assigned theorem is blocked, preserve correct independent work and provide the smallest missing statement and attempted proof in a blocker report. Never insert the blocked conclusion as an assumption. Stop at this gate; do not execute the next prompt.
