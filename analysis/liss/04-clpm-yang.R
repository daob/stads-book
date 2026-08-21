# Three-wave cross-lagged panel model (CLPM) for the Yang variables on LISS
# waves 16-18 (2023-2025), with correlated errors.
#
# All four variables at all three waves: social integration (S), hypertension
# (H), BMI (B), disease count (D). First-order lags only: every wave-17
# variable is regressed on all four wave-16 variables, every wave-18 variable
# on all four wave-17 variables. Correlated errors: the four disturbances
# within each of waves 17 and 18 covary freely, as do the four exogenous
# wave-16 variables. The 16 omitted lag-2 paths give the model 16 df.
#
# Indirect effect of integration (2023) on disease count (2025): in a CLPM
# the two-step products through each intermediate variable. The theory's
# quantity is the part through the physiological states,
#   ind_body = (S16 -> H17)(H17 -> D18) + (S16 -> B17)(B17 -> D18),
# reported alongside the other two-step components (through integration
# stability and through prior disease) and their sum, the total lag-2
# effect implied by the model. Delta-method z via lavaan's := operator.
#
# Usage: Rscript 04-clpm-yang.R   (expects liss_yang_longitudinal.rds,
#        built by 03-longitudinal-yang.R)

library(lavaan)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
data_dir <- normalizePath(file.path(here, "..", "..", "..", "data",
                                    "liss-health-social-integration"))
d <- readRDS(file.path(data_dir, "liss_yang_longitudinal.rds"))

v <- c("integration", "hypertension", "bmi", "disease_count")
old <- c(t(outer(v, 16:18, paste, sep = "_")))
new <- c(t(outer(c("S", "H", "B", "D"), 16:18, paste0)))
for (i in seq_along(old)) names(d)[names(d) == old[i]] <- new[i]

clpm <- "
  # wave 16 -> wave 17 (autoregressive + cross-lagged)
  S17 ~ ss1*S16 + hs1*H16 + bs1*B16 + ds1*D16
  H17 ~ sh1*S16 + hh1*H16 + bh1*B16 + dh1*D16
  B17 ~ sb1*S16 + hb1*H16 + bb1*B16 + db1*D16
  D17 ~ sd1*S16 + hd1*H16 + bd1*B16 + dd1*D16

  # wave 17 -> wave 18
  S18 ~ ss2*S17 + hs2*H17 + bs2*B17 + ds2*D17
  H18 ~ sh2*S17 + hh2*H17 + bh2*B17 + dh2*D17
  B18 ~ sb2*S17 + hb2*H17 + bb2*B17 + db2*D17
  D18 ~ sd2*S17 + hd2*H17 + bd2*B17 + dd2*D17

  # correlated errors within waves 17 and 18
  S17 ~~ H17 + B17 + D17
  H17 ~~ B17 + D17
  B17 ~~ D17
  S18 ~~ H18 + B18 + D18
  H18 ~~ B18 + D18
  B18 ~~ D18

  # two-step effects of integration (2023) on disease count (2025)
  ind_hyp   := sh1 * hd2      # through hypertension change
  ind_bmi   := sb1 * bd2      # through BMI change
  ind_body  := sh1*hd2 + sb1*bd2
  ind_selfS := ss1 * sd2      # through later integration
  ind_prevD := sd1 * dd2      # through earlier disease
  tot_lag2  := sh1*hd2 + sb1*bd2 + ss1*sd2 + sd1*dd2
"

fit <- sem(clpm, data = d, estimator = "MLR", missing = "fiml",
           fixed.x = FALSE)

# The pure first-order model is rejected (the data want second-order
# autoregressive paths, as expected for stock variables measured with
# error), so the reported version adds the four lag-2 AR paths.
clpm2 <- paste(clpm, "\n  S18 ~ S16\n  H18 ~ H16\n  B18 ~ B16\n  D18 ~ D16")
fit2 <- sem(clpm2, data = d, estimator = "MLR", missing = "fiml",
            fixed.x = FALSE)

sink(file.path(here, "liss-clpm-output.txt"))
cat("Three-wave CLPM, Yang variables, LISS 2023-2025.",
    format(Sys.time(), "%Y-%m-%d"), "\n\n")
cat("Base model (first-order lags only):\n")
print(fitMeasures(fit, c("ntotal", "chisq.scaled", "df.scaled",
                         "pvalue.scaled", "cfi.robust", "rmsea.robust",
                         "srmr")))
cat("\nWith lag-2 autoregressive paths (reported version):\n")
print(fitMeasures(fit2, c("ntotal", "chisq.scaled", "df.scaled",
                          "pvalue.scaled", "cfi.robust", "rmsea.robust",
                          "srmr")))
cat("\nStructural paths and defined effects (standardized, lag-2 model):\n")
s <- standardizedSolution(fit2)
print(s[s$op %in% c("~", ":="),
        c("lhs", "op", "rhs", "label", "est.std", "se", "z", "pvalue")],
      digits = 3)
cat("\nDefined effects (unstandardized, delta method, lag-2 model):\n")
p <- parameterEstimates(fit2)
p <- p[p$op == ":=", c("label", "est", "se", "z", "pvalue", "ci.lower",
                       "ci.upper")]
p[, -1] <- signif(p[, -1], 3)
print(p, digits = 3)
sink()
cat("wrote liss-clpm-output.txt\n")
