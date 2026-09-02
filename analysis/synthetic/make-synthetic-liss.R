# Build synthetic stand-ins for the three LISS-derived datasets the book reads
# (chapters 2, 3 and 8). The LISS microdata may not be redistributed, so the
# real files live outside the repository; this script reads them, fits a
# generating model to each, and simulates a fresh dataset of the same size,
# with the same variable names and types, into data-synthetic/.
#
# No row of real data is copied, no identifier is carried over (ids are
# 1..n), and no value of a continuous variable is taken from a real record.
# What the synthetic files preserve is the *model*: marginal distributions
# (as frequency tables for discrete variables, as fitted normal/log-normal
# distributions for continuous ones), the latent correlation matrix, the
# fitted latent class model, and the per-variable missing-data rates.
#
# Generating models
#   liss_ch2_combined   Gaussian copula. The latent correlation matrix is
#                       estimated with lavaan::lavCor (polychoric/polyserial
#                       for the discrete variables, Pearson for continuous
#                       ones, pairwise deletion). A multivariate normal draw
#                       is mapped back to each variable's scale: discrete
#                       variables by thresholds that reproduce the real
#                       category proportions (0/1 variables are dichotomized,
#                       counts and ordinal scales get one threshold per
#                       category), BMI by a fitted log-normal, contact
#                       frequency by a fitted normal rounded to thirds, all
#                       clipped to the real range.
#   liss_yang_longitudinal  Same copula over all wave variables, so that the
#                       autoregressive and cross-lagged correlations survive.
#                       Missing values are then re-created by random deletion
#                       at the real per-variable rates. Variables measured in
#                       the same questionnaire wave are deleted together (a
#                       respondent who skips a wave misses all its items),
#                       but deletion is independent across waves and of the
#                       values, i.e. missing completely at random.
#   liss_lca_conditions Simulated from the three-class poLCA model fitted to
#                       the real ten diagnoses (class sizes and conditional
#                       probabilities), as in chapter 8. Age is drawn from a
#                       class-specific normal (posterior-weighted mean and
#                       sd, rounded and clipped to the real range) and female
#                       from a class-specific Bernoulli.
#
# Usage, from the book directory or from this directory:
#   Rscript analysis/synthetic/make-synthetic-liss.R
# Requires lavaan, poLCA, Matrix and the real files in
# ../data/liss-health-social-integration/ (relative to the book directory).

suppressPackageStartupMessages({
  library(lavaan)
  library(poLCA)
  library(Matrix)
})

set.seed(20260902)

# ---- paths ------------------------------------------------------------------
here <- dirname(sub("^--file=", "",
                    grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "analysis/synthetic"
book_dir <- normalizePath(file.path(here, "..", ".."))
data_dir <- file.path(book_dir, "..", "data", "liss-health-social-integration")
out_dir  <- file.path(book_dir, "data-synthetic")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

read_real <- function(name) {
  f <- file.path(data_dir, paste0(name, ".rds"))
  if (!file.exists(f)) stop("real data file not found: ", f)
  readRDS(f)
}

# ---- Gaussian copula ---------------------------------------------------------

# A marginal specification per variable. "ordinal" keeps the real category
# proportions (the values are the observed categories, e.g. 0/1 or 0..12);
# "normal" and "lognormal" keep mean and sd on the (log) scale and the range.
marginal_spec <- function(x, type, round_to = NULL) {
  x <- x[!is.na(x)]
  switch(type,
    ordinal   = list(type = "ordinal", values = as.numeric(names(table(x))),
                     probs = as.numeric(table(x)) / length(x)),
    normal    = list(type = "normal", mean = mean(x), sd = sd(x),
                     min = min(x), max = max(x), round_to = round_to),
    lognormal = list(type = "lognormal", mean = mean(log(x)), sd = sd(log(x)),
                     min = min(x), max = max(x), round_to = round_to),
    stop("unknown marginal type ", type))
}

# Map a standard-normal column z to the variable's own scale.
from_normal <- function(z, m) {
  if (m$type == "ordinal") {
    cuts <- qnorm(cumsum(m$probs))       # thresholds reproducing the marginal
    cuts <- cuts[-length(cuts)]           # last one is +Inf
    return(m$values[findInterval(z, cuts) + 1])
  }
  x <- m$mean + m$sd * z
  if (m$type == "lognormal") x <- exp(x)
  if (!is.null(m$round_to)) x <- round(x / m$round_to) * m$round_to
  pmin(pmax(x, m$min), m$max)
}

# Fit: latent correlation matrix (lavCor treats variables in `ordinal` as
# ordered and the rest as continuous, pairwise deletion) plus the marginals.
fit_copula <- function(d, types, round_to = list()) {
  vars <- names(types)
  dd <- d[vars]
  ordinal <- vars[types == "ordinal"]
  # (lavCor warns that age has more than 12 categories; that is intended.)
  R <- suppressWarnings(lavCor(dd, ordered = ordinal, missing = "pairwise"))
  R <- unclass(R)[vars, vars]
  R <- as.matrix(nearPD(R, corr = TRUE)$mat)   # pairwise estimates may not be PD
  margins <- lapply(vars, function(v)
    marginal_spec(dd[[v]], types[[v]], round_to[[v]]))
  names(margins) <- vars
  list(vars = vars, R = R, margins = margins)
}

simulate_copula <- function(fit, n) {
  z <- matrix(rnorm(n * length(fit$vars)), n) %*% chol(fit$R)
  out <- lapply(seq_along(fit$vars), function(j)
    from_normal(z[, j], fit$margins[[fit$vars[j]]]))
  names(out) <- fit$vars
  as.data.frame(out)
}

# Random deletion. `blocks` is a list of character vectors; the variables of
# one block are deleted together at the block's smallest missing rate, and
# each variable then loses the remainder of its own rate independently.
delete_at_random <- function(sim, real, blocks) {
  rates <- colMeans(is.na(real[names(sim)]))
  done <- character(0)
  for (b in blocks) {
    r0 <- min(rates[b])
    miss <- runif(nrow(sim)) < r0
    for (v in b) {
      extra <- if (r0 < 1) (rates[v] - r0) / (1 - r0) else 0
      sim[[v]][miss | runif(nrow(sim)) < extra] <- NA
    }
    done <- c(done, b)
  }
  for (v in setdiff(names(sim), done))
    sim[[v]][runif(nrow(sim)) < rates[v]] <- NA
  sim
}

write_out <- function(sim, real, name) {
  stopifnot(nrow(sim) == nrow(real))
  sim <- data.frame(nomem_encr = seq_len(nrow(sim)), sim)   # fresh ids 1..n
  stopifnot(identical(names(sim), names(real)))
  f <- file.path(out_dir, paste0(name, "_synthetic.csv"))
  write.csv(sim, f, row.names = FALSE)
  cat("wrote", f, "(", nrow(sim), "rows )\n")
  invisible(sim)
}

# ---- 1. liss_ch2_combined (chapter 2) ---------------------------------------
cat("\n== liss_ch2_combined\n")
real <- read_real("liss_ch2_combined")
types <- c(bmi = "lognormal", hypertension = "ordinal",
           disease_count = "ordinal", longstanding = "ordinal",
           selfrated_health = "ordinal", integration = "ordinal",
           contact_freq = "normal", age = "ordinal", female = "ordinal",
           educ = "ordinal")
stopifnot(identical(names(real), c("nomem_encr", names(types))))
cop <- fit_copula(real, types, round_to = list(bmi = 0.01, contact_freq = 1/3))
cat("latent correlations (lower triangle):\n")
print(round(cop$R, 2))
sim <- simulate_copula(cop, nrow(real))
sim <- delete_at_random(sim, real, blocks = list())   # independent per variable
write_out(sim, real, "liss_ch2_combined")

# ---- 2. liss_yang_longitudinal (chapter 3) ----------------------------------
cat("\n== liss_yang_longitudinal\n")
real <- read_real("liss_yang_longitudinal")
waves <- c("16", "17", "18")
types <- c(setNames(rep("ordinal", 3), paste0("integration_", waves)))
for (w in waves)
  types <- c(types,
             setNames(c("ordinal", "lognormal", "ordinal"),
                      paste0(c("hypertension_", "bmi_", "disease_count_"), w)))
types <- c(types, age = "ordinal", female = "ordinal")
stopifnot(setequal(names(real), c("nomem_encr", names(types))))
types <- types[setdiff(names(real), "nomem_encr")]     # keep the file's order
cop <- fit_copula(real, types,
                  round_to = setNames(as.list(rep(0.01, 3)),
                                      paste0("bmi_", waves)))
cat("latent autocorrelations of the three states, wave 16 -> 17 -> 18:\n")
for (v in c("hypertension", "bmi", "disease_count"))
  cat(sprintf("  %-14s %.3f  %.3f\n", v,
              cop$R[paste0(v, "_16"), paste0(v, "_17")],
              cop$R[paste0(v, "_17"), paste0(v, "_18")]))
sim <- simulate_copula(cop, nrow(real))
blocks <- c(as.list(paste0("integration_", waves)),
            lapply(waves, function(w)
              paste0(c("hypertension_", "disease_count_", "bmi_"), w)))
sim <- delete_at_random(sim, real, blocks)
cat("missing rates, real vs synthetic:\n")
print(round(rbind(real = colMeans(is.na(real))[names(sim)],
                  synthetic = colMeans(is.na(sim))), 3))
write_out(sim, real, "liss_yang_longitudinal")

# ---- 3. liss_lca_conditions (chapter 8) -------------------------------------
cat("\n== liss_lca_conditions\n")
real <- read_real("liss_lca_conditions")
items <- c("angina", "heartattack", "hypertension", "cholesterol", "stroke",
           "diabetes", "lung", "asthma", "arthritis", "cancer")
stopifnot(identical(names(real), c("nomem_encr", items, "age", "female")))
dd <- real[items] + 1                    # poLCA codes categories 1, 2
f  <- as.formula(paste("cbind(", paste(items, collapse = ","), ") ~ 1"))
set.seed(8)                              # the chapter's seed and settings
lca <- poLCA(f, dd, nclass = 3, nrep = 10, maxiter = 3000, verbose = FALSE)
ord <- order(lca$P, decreasing = TRUE)   # 1 = largest class
P   <- lca$P[ord]
pr  <- sapply(lca$probs, function(p) p[ord, 2])   # P(diagnosis | class)
rownames(pr) <- paste0("class", 1:3)
post <- lca$posterior[, ord]
cat("class sizes:", round(P, 3), "\n")
cat("P(diagnosis | class):\n"); print(round(pr, 2))

# Class-specific age (normal) and female (Bernoulli), posterior-weighted.
wmean <- function(x, w) { ok <- !is.na(x); sum(w[ok] * x[ok]) / sum(w[ok]) }
age_mu <- apply(post, 2, function(w) wmean(real$age, w))
age_sd <- sapply(1:3, function(k)
  sqrt(wmean((real$age - age_mu[k])^2, post[, k])))
fem_p  <- apply(post, 2, function(w) wmean(real$female, w))
cat("age mean by class:", round(age_mu, 1), "\n")
cat("age sd by class:  ", round(age_sd, 1), "\n")
cat("P(female | class):", round(fem_p, 3), "\n")

set.seed(20260902)
n <- nrow(real)
cls <- sample(1:3, n, replace = TRUE, prob = P)
sim <- as.data.frame(lapply(items, function(v)
  as.integer(runif(n) < pr[cls, v])))
names(sim) <- items
sim$age <- pmin(pmax(round(rnorm(n, age_mu[cls], age_sd[cls])),
                     min(real$age)), max(real$age))
sim$female <- as.integer(runif(n) < fem_p[cls])
sim <- delete_at_random(sim, real, blocks = list())
write_out(sim, real, "liss_lca_conditions")

cat("\ndone.\n")
