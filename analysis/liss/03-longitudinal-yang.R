# Longitudinal (2-wave and 3-wave) versions of the chapter 2 "full Yang model"
# on LISS panel data, built through the lissr package from a local LISS
# archive (see https://www.dataarchive.lissdata.nl; data may not be
# redistributed, so nothing here ships with the book).
#
# Waves used (core studies Health = ch, Social Integration & Leisure = cs):
#   wave 16 = 2023 (ch23p / cs23p)
#   wave 17 = 2024 (ch24q / cs24q)
#   wave 18 = 2025 (ch25r / cs25r)
#
# Variable construction repeats analysis/liss/01-prepare-liss.R per wave:
#   - social integration: number of organizational involvements (0-15):
#     membership of eleven organization types + voluntary work for four
#     (all 0/1; index NA if any item missing)
#   - blood pressure: reported diagnosis of hypertension (0/1, ch082)
#   - central adiposity: BMI from self-reported height and weight, with
#     hand plausibility windows (height 120-220 cm, weight 35-250 kg,
#     BMI 14-60) because these items carry NO documented missing codes
#   - disease burden: count of thirteen diagnosed conditions (excluding
#     hypertension itself), NA if any item missing
#   - age (leeftijd) and sex (geslacht; female = 2) from the background
#     variables of the baseline year
#
# Models (lavaan, estimator MLR, FIML for attrition, fixed.x = FALSE):
#   M2  two-wave Yang model:   integration(2024) -> {hypertension, BMI}(2025)
#                              -> disease count(2025), psi between mediator
#                              disturbances, no direct integration -> disease
#   M2d same, direct path freed (saturated; Wald test of the exclusion)
#   M3  three-wave Yang model: integration(2023) -> {hypertension, BMI}(2024)
#                              -> disease count(2025)
#   M3d same, direct path freed
#   M3ar three-wave with autoregressive controls (Cole & Maxwell 2003):
#        each 2024 mediator controls its 2023 value, and the 2025 outcome
#        controls the 2023 disease count
#
# Usage: Rscript 03-longitudinal-yang.R
#   Set LISS_ARCHIVE to the archive root (default ~/Documents/liss-archive).
# Writes: liss-longitudinal-output.txt (full lavaan output, next to this
#         script) and the analysis file
#         ../../../data/liss-health-social-integration/liss_yang_longitudinal.rds

library(lissr)
library(lavaan)

root <- Sys.getenv("LISS_ARCHIVE", "~/Documents/liss-archive")
arch <- liss_connect(root)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
data_dir <- normalizePath(file.path(here, "..", "..", "..", "data",
                                    "liss-health-social-integration"))

## ---- pull the items through lissr ------------------------------------------

member_items    <- paste0("cs0", c("06", "11", "16", "21", "31", "36",
                                   "41", "46", "51", "56", "61"))
volunteer_items <- paste0("cs0", c("07", "12", "17", "42"))
involve_items   <- c(member_items, volunteer_items)

disease_items <- paste0("ch0", c("80", "81", "83", "84", "85", "86",
                                 "87", "88", "89", "90", "91", "95", "97"))
health_items  <- c("ch016", "ch017", "ch082", disease_items)

soc <- liss_long(arch, involve_items, waves = 16:18)
hea <- liss_long(arch, health_items, waves = 16:18,
                 background = c("geslacht", "leeftijd"))

## ---- construct the model variables per wave --------------------------------

zero_one <- function(x) { x[!x %in% c(0, 1)] <- NA; x }
sum_complete <- function(d) ifelse(rowSums(is.na(d)) == 0, rowSums(d), NA)

soc[involve_items] <- lapply(soc[involve_items], zero_one)
soc$integration <- sum_complete(soc[involve_items])

height <- hea$ch016; weight <- hea$ch017
height[height < 120 | height > 220] <- NA
weight[weight < 35  | weight > 250] <- NA
hea$bmi <- weight / (height / 100)^2
hea$bmi[hea$bmi < 14 | hea$bmi > 60] <- NA
hea$hypertension <- zero_one(hea$ch082)
hea[disease_items] <- lapply(hea[disease_items], zero_one)
hea$disease_count <- sum_complete(hea[disease_items])

## ---- reshape to one row per panel member -----------------------------------

wide_one <- function(d, vars) {
  out <- NULL
  for (w in sort(unique(d$wave))) {
    piece <- d[d$wave == w, c("nomem_encr", vars)]
    names(piece)[-1] <- paste0(vars, "_", w)
    out <- if (is.null(out)) piece else merge(out, piece, by = "nomem_encr",
                                              all = TRUE)
  }
  out
}
w_soc <- wide_one(soc, "integration")
w_hea <- wide_one(hea, c("hypertension", "bmi", "disease_count"))

# baseline age and sex: from the earliest wave in which they are observed
bg <- hea[order(hea$wave), c("nomem_encr", "leeftijd", "geslacht")]
bg <- bg[!is.na(bg$leeftijd) | !is.na(bg$geslacht), ]
bg <- bg[!duplicated(bg$nomem_encr), ]
names(bg) <- c("nomem_encr", "age", "geslacht")
bg$female <- ifelse(bg$geslacht %in% c(1, 2), bg$geslacht - 1, NA)

d <- Reduce(function(a, b) merge(a, b, by = "nomem_encr", all = TRUE),
            list(w_soc, w_hea, bg[c("nomem_encr", "age", "female")]))
d <- d[!is.na(d$age) & d$age >= 18, ]   # adults only, as in chapter 2

saveRDS(d, file.path(data_dir, "liss_yang_longitudinal.rds"))

## ---- models ----------------------------------------------------------------

sink(file.path(here, "liss-longitudinal-output.txt"))
cat("Longitudinal Yang models on LISS waves 16-18 (2023-2025)\n")
cat("Built:", format(Sys.time(), "%Y-%m-%d"), " N (adults, any wave):",
    nrow(d), "\n\n")
cat("Observations per variable:\n")
print(colSums(!is.na(d[setdiff(names(d), "nomem_encr")])))
cat("\nComplete on all three waves of all model variables:",
    sum(stats::complete.cases(d[c("integration_16", "hypertension_17",
                                  "bmi_17", "disease_count_18")])), "\n\n")

fit_show <- function(model, label, data = d) {
  fit <- sem(model, data = data, estimator = "MLR", missing = "fiml",
             fixed.x = FALSE)
  cat("\n============================================================\n")
  cat(label, "\n")
  cat("============================================================\n")
  print(fitMeasures(fit, c("ntotal", "chisq.scaled", "df.scaled",
                           "pvalue.scaled", "cfi.robust", "rmsea.robust",
                           "srmr")))
  print(standardizedSolution(fit)[, c("lhs", "op", "rhs", "est.std",
                                      "se", "pvalue")])
  invisible(fit)
}

m2 <- "
  hypertension_18  ~ g1 * integration_17
  bmi_18           ~ g2 * integration_17
  disease_count_18 ~ b1 * hypertension_18 + b2 * bmi_18
  hypertension_18 ~~ psi * bmi_18
"
fit_m2 <- fit_show(m2, "M2: two-wave Yang model (integration 2024 -> states/disease 2025)")

m2d <- paste(m2, "\n  disease_count_18 ~ gd * integration_17")
fit_m2d <- fit_show(m2d, "M2d: two-wave, direct integration -> disease path freed")

m3 <- "
  hypertension_17  ~ g1 * integration_16
  bmi_17           ~ g2 * integration_16
  disease_count_18 ~ b1 * hypertension_17 + b2 * bmi_17
  hypertension_17 ~~ psi * bmi_17
"
fit_m3 <- fit_show(m3, "M3: three-wave Yang model (2023 -> 2024 -> 2025)")

m3d <- paste(m3, "\n  disease_count_18 ~ gd * integration_16")
fit_m3d <- fit_show(m3d, "M3d: three-wave, direct path freed")

m3c <- "
  hypertension_17  ~ g1 * integration_16 + age + female
  bmi_17           ~ g2 * integration_16 + age + female
  disease_count_18 ~ b1 * hypertension_17 + b2 * bmi_17 + age + female
  hypertension_17 ~~ psi * bmi_17
"
fit_m3c <- fit_show(m3c, "M3c: three-wave model with age and sex controls")

m3ar <- "
  hypertension_17  ~ g1 * integration_16 + a1 * hypertension_16
  bmi_17           ~ g2 * integration_16 + a2 * bmi_16
  disease_count_18 ~ b1 * hypertension_17 + b2 * bmi_17 + a3 * disease_count_16
  hypertension_17 ~~ psi * bmi_17
"
fit_m3ar <- fit_show(m3ar, "M3ar: three-wave with autoregressive controls (Cole-Maxwell)")

m3ard <- paste(m3ar, "\n  disease_count_18 ~ gd * integration_16")
fit_m3ard <- fit_show(m3ard, "M3ard: autoregressive model, direct path freed")

cat("\n\nIndirect effects (standardized), delta-method z:\n")
ind <- function(fit, lab) {
  s <- standardizedSolution(fit)
  g1 <- s$est.std[s$label == "g1"]; b1 <- s$est.std[s$label == "b1"]
  g2 <- s$est.std[s$label == "g2"]; b2 <- s$est.std[s$label == "b2"]
  cat(sprintf("%-6s via hypertension: %6.4f   via BMI: %6.4f   total: %6.4f\n",
              lab, g1 * b1, g2 * b2, g1 * b1 + g2 * b2))
}
ind(fit_m2, "M2"); ind(fit_m3, "M3"); ind(fit_m3c, "M3c"); ind(fit_m3ar, "M3ar")
sink()
cat("wrote liss-longitudinal-output.txt and",
    file.path(data_dir, "liss_yang_longitudinal.rds"), "\n")
