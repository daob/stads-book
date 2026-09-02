# Synthetic stand-ins for the LISS datasets

**These files are not LISS data.** They are simulated datasets that mimic
the three LISS-derived files the book reads in chapters 2, 3 and 8, so that
you can run those chapters' code without access to the LISS microdata. No
number computed from them will match the book, and nothing in them describes
a real person. Do not cite them, analyse them for research, or mistake them
for the [LISS panel](https://www.lissdata.nl/) (run by Centerdata, part of
[ODISSEI](https://odissei-data.nl)), whose microdata may not be
redistributed and are therefore not in this repository. To reproduce the
book's numbers, register with LISS and run the scripts in `analysis/liss/`.

| File | Stands in for | Used in | Rows |
|------|---------------|---------|------|
| `liss_ch2_combined_synthetic.csv` | `liss_ch2_combined.rds` | chapter 2 (regression, path model, logistic regression) | 4,158 |
| `liss_yang_longitudinal_synthetic.csv` | `liss_yang_longitudinal.rds` | chapter 3 (three-wave panel models) | 6,616 |
| `liss_lca_conditions_synthetic.csv` | `liss_lca_conditions.rds` | chapter 8 (latent class analysis) | 4,647 |

Each file has the same variables, in the same order, with the same names,
codings (0/1 dummies, integer counts, BMI in kg/m²) and value ranges as the
real file, and the same number of rows. `nomem_encr` is a fresh running
number 1..n, not a LISS identifier.

## How to use them

Every chapter chunk that reads a LISS file starts with a line such as

```r
d <- readRDS("../data/liss-health-social-integration/liss_ch2_combined.rds")
```

Replace it by the matching synthetic file, read from the book directory:

```r
d <- read.csv("data-synthetic/liss_ch2_combined_synthetic.csv")
```

and run the rest of the chunk unchanged; `liss` in chapter 3 and `d` in
chapter 8 work the same way. `read.csv()` returns integer columns where
`readRDS()` returned doubles, which makes no difference to any of the code.
`analysis/synthetic/check-synthetic-liss.R` does exactly this for every
chunk of the three chapters that uses the LISS objects and prints the
results next to the book's.

## How they were made

`analysis/synthetic/make-synthetic-liss.R` (seeded, so the files are
reproducible by anyone who holds the real data) fits a generating model to
each real file and simulates from it:

- **Chapter 2 and chapter 3 files: a Gaussian copula.** The latent
  correlation matrix of all variables (all waves, for the panel file) is
  estimated with `lavaan::lavCor()`: polychoric and polyserial correlations
  for the 0/1, count and ordinal variables, Pearson for the continuous ones,
  pairwise deletion. A multivariate normal sample is drawn and each column is
  mapped back to its own scale: discrete variables (diagnoses, disease
  counts, integration scores, self-rated health, education, sex, age in
  years) by thresholds that reproduce the real category proportions, BMI by a
  fitted log-normal, contact frequency by a fitted normal rounded to thirds,
  all clipped to the real range. Missing values are then re-created by random
  deletion at the real per-variable rates. In the panel file the variables
  of one questionnaire wave are deleted together, as when a respondent skips
  a wave, but deletion is independent across waves and independent of the
  values (missing completely at random), whereas real attrition is not.
- **Chapter 8 file: the fitted latent class model.** The three-class `poLCA`
  model of chapter 8 is fitted to the real ten diagnoses, and every synthetic
  respondent is drawn from it: a class from the estimated class sizes, then
  each diagnosis from the class's conditional probability. Age comes from a
  class-specific normal distribution (posterior-weighted mean and standard
  deviation, rounded and clipped to the real range) and sex from a
  class-specific Bernoulli.

Only summary quantities pass from the real data into the files: means,
standard deviations, frequency tables, correlation matrices, class sizes,
conditional probabilities, missing rates. No row is copied.

## What to expect

Every printed number differs from the book's, in most cases in the second
digit, sometimes more. On the files as shipped: the chapter 2 regression
gives a hypertension gap of 0.85 conditions (book: 0.82) and a BMI slope of
0.024 (0.020); the chi-square of the restricted path model is 245 (243); the
logistic coefficient on integration is −0.02 (−0.04). The chapter 3
exclusion test gives χ²(1) = 2.5, p = .11 (book: 0.36, p = .55), and the
autoregressive paths are .88 to .91 (.82 to .91). The chapter 8 BIC again
chooses three classes, of sizes 76, 20 and 4 percent (book: 78, 17 and 5),
but the log-likelihoods are about 170 lower and the drop-one-indicator
stability ranking is reordered. The panel file cannot reproduce the book's
pattern of attrition, and the age distribution in the chapter 8 file is
smoother than the real one. These are features of a simulation, not
errors: they are the sampling and modelling variability that the book's
exercises ask you to reason about.
