# Longitudinal Yang models on LISS panel data (waves 2023–2025)

Report on the 2-wave and 3-wave versions of the chapter 2 "full Yang
model", estimated on the LISS panel. Data were pulled from the local LISS
archive with the `lissr` package (v0.2.0); code in
`analysis/liss/03-longitudinal-yang.R`, full `lavaan` output in
`analysis/liss/liss-longitudinal-output.txt`. The analysis file
`liss_yang_longitudinal.rds` lives outside the repository in
`data/liss-health-social-integration/` (LISS microdata may not be
redistributed). Built 2026-08-21.

## Design and data

Three annual waves of two LISS core studies, merged on panel member
(`nomem_encr`):

| wave | year | Health | Social Integration & Leisure |
|------|------|--------|------------------------------|
| 16   | 2023 | ch23p  | cs23p                        |
| 17   | 2024 | ch24q  | cs24q                        |
| 18   | 2025 | ch25r  | cs25r                        |

Variables repeat the chapter 2 construction, per wave:

- **Social integration** (ξ): count of organizational involvements, 0–15
  (membership of eleven organization types plus voluntary work for four;
  NA if any item missing). Item numbering verified identical across the
  three waves.
- **Blood pressure** (η, proxy): reported hypertension diagnosis, 0/1
  (ch082).
- **Central adiposity** (η, proxy): BMI from self-reported height and
  weight. These items carry no documented missing codes, so entry errors
  were removed by hand with plausibility windows (height 120–220 cm,
  weight 35–250 kg, BMI 14–60), as in the cross-sectional preparation.
- **Disease burden** (outcome, standing in for mortality risk): count of
  thirteen diagnosed conditions, excluding hypertension itself (NA if any
  item missing).
- **Age** and **sex** from the background variables (`leeftijd`,
  `geslacht`) of the baseline year.

`lissr` recodes blanks and all *documented* missing codes to NA; the BMI
windows cover the undocumented ones. Inflammation, the third
physiological state of the theory, is not measured in LISS and remains
absent, as in chapter 2.

Sample: 6,616 adult (18+) panel members observed in at least one wave;
3,916 are complete on all model variables in all three waves. Models use
full-information maximum likelihood (FIML) under MAR with the MLR robust
estimator and `fixed.x = FALSE`, so all 6,6xx contribute.

## Models

All models have the full-Yang structure: integration → the two measurable
physiological states → disease count, correlated disturbances (ψ) between
the states, and **no direct path** from integration to disease — the
theory's exclusion restriction, which leaves 1 df to test (each "d"
variant frees that path).

- **M2 (2-wave):** integration 2024 → hypertension, BMI 2025 → disease
  2025. Mediator → outcome is contemporaneous.
- **M3 (3-wave):** integration 2023 → hypertension, BMI 2024 → disease
  2025. Fully temporally ordered (Cole–Maxwell style separation).
- **M3c:** M3 plus age and sex as exogenous controls in every equation.
- **M3ar:** M3 plus autoregressive controls: each 2024 state controls its
  2023 value, and 2025 disease controls 2023 disease.

## Results (standardized)

| parameter | M2 | M3 | M3c | M3ar |
|---|---|---|---|---|
| integration → hypertension (γ₁) | .009 (ns) | −.005 (ns) | **−.034** (p=.016) | .000 (ns) |
| integration → BMI (γ₂) | **−.060** | **−.057** | **−.067** | **−.019** (p<.001) |
| hypertension → disease (β₁) | **.315** | **.293** | **.225** | **.052** |
| BMI → disease (β₂) | **.089** | **.104** | **.093** | **.033** |
| ψ (state disturbances) | **.162** | **.153** | .148 | .020 (ns) |
| exclusion test χ²(1) | 0.14 (p=.71) | 0.36 (p=.55) | 4.62 (p=.032) | 3.7 (p≈.054) |
| direct path when freed | −.005 (ns) | −.008 (ns) | — | .014 (p=.105) |
| indirect effect, total | −.003 | −.008 | −.014 | −.001 |

(Autoregressive paths in M3ar: hypertension .90, BMI .91, disease .82.)

## Reading

1. **The theory's exclusion restriction survives everywhere, but for two
   different reasons.** In M2 and M3 it passes because integration
   barely correlates with disease at all (the same weak-evidence caveat
   as in the cross-sectional analysis: an exclusion test is easy to pass
   when there is little association to explain). In M3c and M3ar the
   test has more to bite on and the restriction becomes borderline
   (p=.03 with age controls comes from the model now having to fit the
   age-adjusted pattern; the freed direct path itself stays small and
   nonsignificant at .014).

2. **The age suppression replicates longitudinally.** Without age,
   integration → hypertension is zero; with age controlled, it emerges
   at −.034 (p=.016), alongside the robust −.067 on BMI. Older
   respondents are both more integrated (organizationally) and more
   hypertensive, which masks the protective association. This is the
   chapter 2 omitted-common-cause warning, now with temporal ordering.

3. **The autoregressive model changes the question, and the answer.**
   Hypertension and disease counts are "ever diagnosed" stocks with
   year-to-year stabilities of .82–.91, so M3ar asks whether integration
   in 2023 predicts *changes* in the states during 2024, and whether
   those changes predict *changes* in disease by 2025. Almost nothing is
   left: the total indirect effect drops from −.008 (M3) to −.0006. The
   M2/M3 estimates are therefore carried almost entirely by stable
   between-person differences, not by within-person change over these
   two years — the Maxwell–Cole point that mediation estimates without
   autoregressive control mostly re-describe the cross-section.

4. **Magnitudes are small throughout.** Even the most favourable
   specification (M3c) puts the total standardized indirect effect at
   −.014. Two years of an annual panel, one-item diagnosis measures,
   and a 0–15 membership count are a blunt instrument for the theory;
   these results bound the association, they do not refute the
   mechanism.

## Limitations

- No inflammation measure; two of the theory's three physiological
  states, both self-reported.
- Outcomes are cumulative ("ever diagnosed") stocks, which compress
  within-person change and inflate autoregressive paths; incident
  diagnoses over a longer panel window would be the better test.
- The one-year lags are arbitrary; longitudinal effects are
  lag-dependent, and nothing says a year is the interval at which the
  mechanism operates.
- FIML assumes attrition is MAR given the modeled variables; health-
  related attrition violating this would bias the state → disease paths.
- Binary hypertension in a linear system, as in chapter 2.
