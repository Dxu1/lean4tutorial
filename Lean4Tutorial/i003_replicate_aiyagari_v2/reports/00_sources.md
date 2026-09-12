# Milestone 00 source report

Status: REVIEW_READY (byte verification only). No paper mathematics was newly read or certified in this milestone.

The original ZIP files were not present directly in the project, its `reference/` directory, `Lean4Tutorial/`, or the workspace root. The exact old-directory path `../i003_replicate_aiyagari/i003_replicate_aiyagari.zip` was also absent. No recursive search of that directory, implementation, or generated proof summaries was performed.

The user's permitted alternative supplies all ten PDF files in:

```
/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2/reference
```

Each PDF's byte size and SHA-256 was checked against the immutable whitelist before constructing two **new source-only adapter archives**. These are not the original distributed ZIPs. Each contains only the original manifest member paths; no old-project content was read. Resolved extractor inputs:

```
/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2/sources/input_archives/i003_replicate_aiyagari.zip
/Users/davidxu/Documents/lean4tutorial/Lean4Tutorial/i003_replicate_aiyagari_v2/sources/input_archives/citations.zip
```

The supplied `tools/extract_sources.py` was left unchanged and run successfully against these inputs. It independently checked every size and hash before writing any PDF to `sources/papers/`. `sources/papers/extraction_report.json` and `reports/logs/00_sources.log` retain the evidence. PDFs and adapter archives are git-ignored.

## Source inventory

Printed and PDF locators below are inherited from the approved manifest, not newly verified page readings. Equation/image inspection is deferred to the milestone that uses the source; the entire SLP book was not inspected.

### A93: Uninsured Idiosyncratic Risk and Aggregate Saving (1993)

File: `Aiyagari-1993.pdf`. Verified bytes: 4333203. Manifest PDF pages: 51.

SHA-256: `274d013b62629791101cab07303aae9a7a1dd22abc0e1085d92865723e92dd80`.

Locator: Printed 11–22, 37–40; PDF 12–23, 38–41.

### A94: Uninsured Idiosyncratic Risk and Aggregate Saving (1994)

File: `Aiyagari-UninsuredIdiosyncraticRisk-1994.pdf`. Verified bytes: 1394274. Manifest PDF pages: 27.

SHA-256: `75f8b45ea02052abae0175267c491df3824cd7181e440d17a5fd76785d00d13f`.

Locator: Printed 665–674; PDF 8–17.

### BS79: On the Differentiability of the Value Function in Dynamic Models of Economics (1979)

File: `benveniste_scheinkman_1979.pdf`. Verified bytes: 292853. Manifest PDF pages: 7.

SHA-256: `f1ae50d50f4574fa6e31ab480012c4bc6e74c231eeb85c5f58ae6a6ff99a5d65`.

Locator: Lemma 1, printed 728; PDF 3.

### CW00: Optimal Intertemporal Consumption under Uncertainty (2000)

File: `chamberlain_wilson_2000.pdf`. Verified bytes: 245195. Manifest PDF pages: 31.

SHA-256: `da7a2fb270c597cbc9ac8b827674b45316c58cbe70af7e647af01b30afbdc173`.

Locator: Sections 2–4; Theorem 4 and Corollary 2; Theorem 7.

### C87: Consumption, Liquidity Constraints and Asset Accumulation in the Presence of Random Income Fluctuations (1987)

File: `clarida_1987.pdf`. Verified bytes: 1165235. Manifest PDF pages: 14.

SHA-256: `5235208476e00fce23884ee01f322f3d6cc2d308a4529350f960766232ed9683`.

Locator: Section 2 and Appendix, printed 340–344, 348–350.

### C90: International Lending and Borrowing in a Stochastic, Stationary Equilibrium (1990)

File: `clarida_1990.pdf`. Verified bytes: 479503. Manifest PDF pages: 17.

SHA-256: `f7b8b85abc657284b39aaf8edd42afc5c3a812d18b0e94967c3d4411a1bd10bc`.

Locator: Proposition 2.4, printed 548; PDF 7. Result is stated without proof..

### SE77: Some Results on ‘An Income Fluctuation Problem’ (1977)

File: `schechtman_escudero_1976.pdf`. Verified bytes: 940868. Manifest PDF pages: 16.

SHA-256: `de9496c5926b9ad60e48bc389d09d9279d97decad04327d4b9186c01e7157dbf`.

Locator: Theorems 3.8–3.9, printed 161–162; PDF 11–12. Filename year is not publication year..

### SLP89: Recursive Methods in Economic Dynamics (1989)

File: `stokey-lucas-recursive-methods-in-economic-dynamics-1989-2-pdf-free.pdf`. Verified bytes: 25981407. Manifest PDF pages: 593.

SHA-256: `9767571f8d5a6b09e4c031edec2bdb1321a2ebf0f543e5c81278361dd1d8d423`.

Locator: Chapter 12; Assumption 12.1, Lemma 12.11, Theorems 12.12–12.13; printed 381–385, PDF 391–395.

### S75: Permanent and Transitory Income Effects in a Model of Optimal Consumption with Wage Income Uncertainty (1975)

File: `sibley1975.pdf`. Verified bytes: 723539. Manifest PDF pages: 15.

SHA-256: `e9875afa2d8129fca09b848f2febce6d4229adc534a579caaa7bfb4f12ce4d82`.

Locator: Risk-order extension only; no aggregate conclusion imported.

### M76: The Effect on Optimal Consumption of Increased Uncertainty in Labor Income in the Multiperiod Case (1976)

File: `miller1976.pdf`. Verified bytes: 735990. Manifest PDF pages: 14.

SHA-256: `433fbc7e2abf84f06c0a34af954dbd2d30c1642b86497e711e6cd828b9e25a10`.

Locator: Risk-order extension only; no aggregate conclusion imported.

## Reproduction

```sh
python3 tools/extract_sources.py --aiyagari "$PWD/sources/input_archives/i003_replicate_aiyagari.zip" --citations "$PWD/sources/input_archives/citations.zip" --output sources/papers
```

Adapter ZIP SHA-256 (local reproduction provenance, not source authority):

- `citations.zip`: `da9adad910211f2c0438544dbb4ffb5dadca94e2b7069e8c369d6659bcb1881f`
- `i003_replicate_aiyagari.zip`: `2c4c4c39885880b330a53bf10e084d19750f0d056fc0b168c2f780dd174632ad`
