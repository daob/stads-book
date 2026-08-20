# Fit the chapter 2 model to the LISS wave-18 data prepared by
# 01-prepare-liss.R.
#
# The model is the chapter's final model with the variables the data offer:
# social integration (S) affects blood pressure (B, diagnosed hypertension)
# and central adiposity (A, BMI); both affect chronic disease burden (the
# outcome standing in for mortality); the disturbances of the two
# physiological states may covary; and there is no direct path from
# integration to disease. That absent path is the model's one testable
# restriction (six correlations, five parameters, one degree of freedom),
# exactly as in the chapter. Inflammation is not measured in LISS, so the
# theory's three physiological states shrink to two here.
#
# Estimation: maximum likelihood with robust (Huber-White) standard errors
# and full-information treatment of the scattered item missingness. Two of
# the four variables are not continuous (hypertension is binary, the disease
# count takes small integers), so the linear model is an approximation; the
# robust standard errors address the resulting heteroskedasticity but not
# the linearity assumption itself.
#
# Usage:  Rscript 02-fit-liss-sem.R
# Writes: liss-sem-output.txt (full lavaan output, next to this script)

library(lavaan)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
DATA <- normalizePath(file.path(here, "..", "..", "..", "data",
                                "liss-health-social-integration"))
d <- readRDS(file.path(DATA, "liss_ch2_combined.rds"))

sink(file.path(here, "liss-sem-output.txt"), split = TRUE)
cat("LISS wave 18, chapter 2 model. N =", nrow(d), "adults\n")
cat("Fitted", format(Sys.time(), "%Y-%m-%d"), "\n\n")

cat("Observed correlations (pairwise complete):\n")
print(round(cor(d[, c("integration", "hypertension", "bmi", "disease_count")],
                use = "pairwise.complete.obs"), 3))

## ---- Model 1: the chapter's final model ------------------------------------
m1 <- "
  hypertension  ~ a2 * integration
  bmi           ~ a3 * integration
  disease_count ~ c2 * hypertension + c3 * bmi
  hypertension ~~ psi * bmi
"
fit1 <- sem(m1, data = d, estimator = "MLR", missing = "fiml", fixed.x = FALSE)
cat("\n================ Model 1: no direct path from integration ============\n")
summary(fit1, standardized = TRUE, fit.measures = TRUE)

## ---- Model 2: free the direct path (saturated) -----------------------------
m2 <- paste(m1, "\n  disease_count ~ c1 * integration\n")
fit2 <- sem(m2, data = d, estimator = "MLR", missing = "fiml", fixed.x = FALSE)
cat("\n================ Model 2: direct path freed (saturated) ==============\n")
summary(fit2, standardized = TRUE)
cat("\nLikelihood-ratio test of the exclusion (Model 1 vs Model 2):\n")
print(lavTestLRT(fit1, fit2))

## ---- Model 3: age and gender as background covariates ----------------------
m3 <- "
  hypertension  ~ a2 * integration + age + female
  bmi           ~ a3 * integration + age + female
  disease_count ~ c2 * hypertension + c3 * bmi + age + female
  hypertension ~~ psi * bmi
"
fit3 <- sem(m3, data = d, estimator = "MLR", missing = "fiml", fixed.x = FALSE)
cat("\n================ Model 3: adjusted for age and gender ================\n")
summary(fit3, standardized = TRUE, fit.measures = TRUE)

sink()
cat("\nwrote liss-sem-output.txt\n")
