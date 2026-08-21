# CLPM and RI-CLPM for integration -> BMI -> disease count on LISS, with the
# largest equally spaced measurement intervals the two studies allow:
# 2009, 2017, 2025 (8-year lags). Hypertension is dropped; BMI is the sole
# physiological mediator.
#
# Waves: health ch09c (wave 3), ch17j (10), ch25r (18);
#        social cs09b (wave 2), cs17j (10), cs25r (18).
# Item numbering verified identical across these waves against the archive
# metadata. Variable construction as in 03-longitudinal-yang.R.
#
# Models (MLR, FIML, fixed.x = FALSE); t = 1, 2, 3 for 2009, 2017, 2025:
#   CLPM    all first-order autoregressive and cross-lagged paths among
#           S (integration), B (BMI), D (disease count); correlated errors
#           within waves 2 and 3; free wave-1 covariances; PLUS the lag-2
#           path S1 -> D3, the mediation "direct effect". A variant adds
#           the three lag-2 autoregressive paths.
#   RI-CLPM random intercepts for S, B, D (loadings 1 on all three waves),
#           the same dynamic structure among the within-person components,
#           including the within direct effect wS1 -> wD3.
#
# Effects reported (delta method):
#   indirect = (S1 -> B2) * (B2 -> D3)   through BMI change
#   direct   = S1 -> D3                  the lag-2 path
#
# Usage: Rscript 05-clpm-riclpm-bmi.R
# Writes: liss-clpm-riclpm-output.txt and (data dir) liss_bmi_3wave8yr.rds

library(lissr)
library(lavaan)

root <- Sys.getenv("LISS_ARCHIVE", "~/Documents/liss-archive")
arch <- liss_connect(root)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
data_dir <- normalizePath(file.path(here, "..", "..", "..", "data",
                                    "liss-health-social-integration"))

## ---- pull and construct ----------------------------------------------------

member_items    <- paste0("cs0", c("06", "11", "16", "21", "31", "36",
                                   "41", "46", "51", "56", "61"))
volunteer_items <- paste0("cs0", c("07", "12", "17", "42"))
involve_items   <- c(member_items, volunteer_items)
disease_items <- paste0("ch0", c("80", "81", "83", "84", "85", "86",
                                 "87", "88", "89", "90", "91", "95", "97"))

soc <- liss_long(arch, involve_items, waves = c(2, 10, 18))
hea <- liss_long(arch, c("ch016", "ch017", disease_items),
                 waves = c(3, 10, 18), background = c("geslacht", "leeftijd"))

zero_one <- function(x) { x[!x %in% c(0, 1)] <- NA; x }
sum_complete <- function(d) ifelse(rowSums(is.na(d)) == 0, rowSums(d), NA)

soc[involve_items] <- lapply(soc[involve_items], zero_one)
soc$S <- sum_complete(soc[involve_items])

height <- hea$ch016; weight <- hea$ch017
height[height < 120 | height > 220] <- NA
weight[weight < 35  | weight > 250] <- NA
hea$B <- weight / (height / 100)^2
hea$B[hea$B < 14 | hea$B > 60] <- NA
hea[disease_items] <- lapply(hea[disease_items], zero_one)
hea$D <- sum_complete(hea[disease_items])

# reshape on calendar year (wave numbers differ between the two studies)
wide_one <- function(d, vars) {
  out <- NULL
  for (yr in sort(unique(d$year))) {
    t <- match(yr, c(2009, 2017, 2025))
    piece <- d[d$year == yr, c("nomem_encr", vars)]
    names(piece)[-1] <- paste0(vars, t)
    out <- if (is.null(out)) piece else merge(out, piece, by = "nomem_encr",
                                              all = TRUE)
  }
  out
}
bg <- hea[order(hea$year), c("nomem_encr", "leeftijd", "geslacht")]
bg <- bg[!is.na(bg$leeftijd), ]
bg <- bg[!duplicated(bg$nomem_encr), ]
names(bg) <- c("nomem_encr", "age", "geslacht")
bg$female <- ifelse(bg$geslacht %in% c(1, 2), bg$geslacht - 1, NA)

d <- Reduce(function(a, b) merge(a, b, by = "nomem_encr", all = TRUE),
            list(wide_one(soc, "S"), wide_one(hea, c("B", "D")),
                 bg[c("nomem_encr", "age", "female")]))
d <- d[!is.na(d$age) & d$age >= 18, ]
saveRDS(d, file.path(data_dir, "liss_bmi_3wave8yr.rds"))

## ---- models ----------------------------------------------------------------

clpm <- "
  S2 ~ ss1*S1 + bs1*B1 + ds1*D1
  B2 ~ sb1*S1 + bb1*B1 + db1*D1
  D2 ~ sd1*S1 + bd1*B1 + dd1*D1
  S3 ~ ss2*S2 + bs2*B2 + ds2*D2
  B3 ~ sb2*S2 + bb2*B2 + db2*D2
  D3 ~ sd2*S2 + bd2*B2 + dd2*D2 + dir*S1
  S2 ~~ B2 + D2
  B2 ~~ D2
  S3 ~~ B3 + D3
  B3 ~~ D3
  indirect := sb1 * bd2
  direct   := dir
  via_S    := ss1 * sd2
  via_D    := sd1 * dd2
"
clpm_l2 <- paste(clpm, "\n  S3 ~ S1\n  B3 ~ B1\n  D3 ~ D1")

riclpm <- "
  RIS =~ 1*S1 + 1*S2 + 1*S3
  RIB =~ 1*B1 + 1*B2 + 1*B3
  RID =~ 1*D1 + 1*D2 + 1*D3
  wS1 =~ 1*S1 \n wS2 =~ 1*S2 \n wS3 =~ 1*S3
  wB1 =~ 1*B1 \n wB2 =~ 1*B2 \n wB3 =~ 1*B3
  wD1 =~ 1*D1 \n wD2 =~ 1*D2 \n wD3 =~ 1*D3
  S1 ~~ 0*S1 \n S2 ~~ 0*S2 \n S3 ~~ 0*S3
  B1 ~~ 0*B1 \n B2 ~~ 0*B2 \n B3 ~~ 0*B3
  D1 ~~ 0*D1 \n D2 ~~ 0*D2 \n D3 ~~ 0*D3

  wS2 ~ ss1*wS1 + bs1*wB1 + ds1*wD1
  wB2 ~ sb1*wS1 + bb1*wB1 + db1*wD1
  wD2 ~ sd1*wS1 + bd1*wB1 + dd1*wD1
  wS3 ~ ss2*wS2 + bs2*wB2 + ds2*wD2
  wB3 ~ sb2*wS2 + bb2*wB2 + db2*wD2
  wD3 ~ sd2*wS2 + bd2*wB2 + dd2*wD2 + dir*wS1

  wS1 ~~ wB1 + wD1
  wB1 ~~ wD1
  wS2 ~~ wB2 + wD2
  wB2 ~~ wD2
  wS3 ~~ wB3 + wD3
  wB3 ~~ wD3

  RIS ~~ RIB + RID
  RIB ~~ RID
  RIS + RIB + RID ~~ 0*wS1 + 0*wB1 + 0*wD1

  indirect := sb1 * bd2
  direct   := dir
  via_S    := ss1 * sd2
  via_D    := sd1 * dd2
"

show <- function(fit, label) {
  cat("\n============================================================\n")
  cat(label, "\n")
  cat("============================================================\n")
  print(fitMeasures(fit, c("ntotal", "chisq.scaled", "df.scaled",
                           "pvalue.scaled", "cfi.robust", "rmsea.robust",
                           "srmr")))
  s <- standardizedSolution(fit)
  cat("\nStructural paths (standardized):\n")
  print(s[s$op == "~", c("lhs", "rhs", "label", "est.std", "se", "z",
                         "pvalue")], digits = 3)
  cat("\nDefined effects (unstandardized, delta method):\n")
  p <- parameterEstimates(fit)
  p <- p[p$op == ":=", c("label", "est", "se", "z", "pvalue",
                         "ci.lower", "ci.upper")]
  p[, -1] <- signif(p[, -1], 3)
  print(p, row.names = FALSE)
  cat("\nDefined effects (standardized):\n")
  q <- s[s$op == ":=", c("label", "est.std", "se", "z", "pvalue")]
  q[, 2] <- signif(q[, 2], 3)
  print(q, row.names = FALSE, digits = 3)
  invisible(fit)
}

sink(file.path(here, "liss-clpm-riclpm-output.txt"))
cat("CLPM and RI-CLPM, integration -> BMI -> disease, LISS 2009/2017/2025.\n")
cat("Built:", format(Sys.time(), "%Y-%m-%d"), " N (adults, any wave):",
    nrow(d), "\n\nObservations per variable:\n")
print(colSums(!is.na(d[setdiff(names(d), "nomem_encr")])))

fit_c  <- show(sem(clpm, data = d, estimator = "MLR", missing = "fiml",
                   fixed.x = FALSE), "CLPM (first-order + direct S1 -> D3)")
fit_c2 <- show(sem(clpm_l2, data = d, estimator = "MLR", missing = "fiml",
                   fixed.x = FALSE), "CLPM with lag-2 autoregressive paths")
fit_r  <- show(sem(riclpm, data = d, estimator = "MLR", missing = "fiml"),
               "RI-CLPM (within-person dynamics + direct wS1 -> wD3)")
sink()
cat("wrote liss-clpm-riclpm-output.txt\n")
