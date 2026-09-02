# Smoke test for the synthetic LISS stand-ins in data-synthetic/.
#
# Extracts the R chunks of chapters 2, 3 and 8 that use the LISS objects,
# re-points their readRDS() line at the synthetic CSVs (the one change the
# book's footnote tells a reader to make), runs them in order, and prints
# the key outputs next to the real-data numbers printed in the book. They
# should be in the same ballpark; they will not match exactly.
#
# Usage, from anywhere:
#   Rscript analysis/synthetic/check-synthetic-liss.R          # ~3 minutes
#   Rscript analysis/synthetic/check-synthetic-liss.R --full   # ~6 minutes:
#         also chapter 8's stability and underidentification chunks (another
#         hundred-odd poLCA fits)
# Needs lavaan, poLCA and mclust (chapter 8 loads mclust in an earlier chunk).

full <- "--full" %in% commandArgs(trailingOnly = TRUE)

here <- dirname(sub("^--file=", "",
                    grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "analysis/synthetic"
book_dir <- normalizePath(file.path(here, "..", ".."))
setwd(book_dir)    # the chapters' code uses paths relative to the book dir

# ---- chunk extraction --------------------------------------------------------

# Returns a named list label -> code (without the #| option lines) for every
# labelled R chunk of a .qmd file.
read_chunks <- function(qmd) {
  lines <- readLines(qmd, warn = FALSE)
  open  <- grep("^```\\{r\\}", lines)
  close <- grep("^```\\s*$", lines)
  out <- list()
  for (o in open) {
    cl <- close[close > o][1]
    body <- lines[(o + 1):(cl - 1)]
    lab <- sub("^#\\|\\s*label:\\s*", "", grep("^#\\|\\s*label:", body,
                                               value = TRUE))[1]
    if (is.na(lab)) next
    out[[lab]] <- body[!grepl("^#\\|", body)]
  }
  out
}

# The one edit a student makes: readRDS("../data/.../<name>.rds") becomes
# read.csv("data-synthetic/<name>_synthetic.csv").
repoint <- function(code) {
  sub('readRDS\\("\\.\\./data/liss-health-social-integration/([A-Za-z0-9_]+)\\.rds"\\)',
      'read.csv("data-synthetic/\\1_synthetic.csv")', code)
}

# Run the listed chunks of one chapter in a fresh environment, echoing each
# chunk's code and printing its output as knitr would; `hooks` is a list of
# functions, keyed by chunk label, that pull numbers out of the environment
# after that chunk has run.
run_chapter <- function(qmd, labels, hooks = list(), env = new.env()) {
  chunks <- read_chunks(qmd)
  missing <- setdiff(labels, names(chunks))
  if (length(missing))
    stop("chunk(s) not found in ", qmd, ": ", paste(missing, collapse = ", "))
  got <- list()
  for (lab in labels) {
    code <- repoint(chunks[[lab]])
    cat("\n----- ", basename(qmd), " / ", lab, " -----\n", sep = "")
    cat(code, sep = "\n"); cat("\n")
    tf <- tempfile(fileext = ".R"); writeLines(code, tf)
    source(tf, local = env, print.eval = TRUE, echo = FALSE)
    if (!is.null(hooks[[lab]])) got <- c(got, hooks[[lab]](env))
  }
  got
}

stopifnot(file.exists("data-synthetic/liss_ch2_combined_synthetic.csv"),
          file.exists("data-synthetic/liss_yang_longitudinal_synthetic.csv"),
          file.exists("data-synthetic/liss_lca_conditions_synthetic.csv"))

pdf(NULL)   # chapter 8 draws a figure; do not leave an Rplots.pdf behind
res <- list()

# ---- chapter 2 ---------------------------------------------------------------
res$ch2 <- run_chapter(
  "02-theory-to-linear-models.qmd",
  c("liss-lm", "liss-std", "liss-sem-cor", "liss-sem-hand",
    "liss-sem-lavaan", "liss-sem-test-hand", "liss-sem-test",
    "liss-glm", "liss-glm-predict"),
  hooks = list(
    "liss-lm" = function(e) {
      b <- coef(e$fit)
      list("lm: intercept" = b[[1]], "lm: hypertension" = b[["hypertension"]],
           "lm: bmi" = b[["bmi"]])
    },
    "liss-std" = function(e) list(
      "std. coef of bmi" = coef(e$fit)[["bmi"]] * sd(e$d$bmi, na.rm = TRUE) /
        sd(e$d$disease_count, na.rm = TRUE)),
    "liss-sem-cor" = function(e) {
      r <- cor(e$liss)
      list("n (complete cases)" = nrow(e$liss),
           "r(age, hypertension)" = r["age", "hypertension"],
           "r(age, disease_count)" = r["age", "disease_count"],
           "r(hypertension, disease_count)" = r["hypertension", "disease_count"])
    },
    "liss-sem-hand" = function(e) list(
      "gamma1 (hand)" = e$gamma1, "beta (hand)" = e$beta,
      "gamma2 (hand)" = e$gamma2),
    "liss-sem-lavaan" = function(e) list(
      "z of gamma2 (lavaan)" = lavaan::parameterEstimates(e$fit)$z[3]),
    "liss-sem-test-hand" = function(e) list(
      "chi-square, hand" = e$chisq_hand),
    "liss-sem-test" = function(e) list(
      "chi-square, lavaan (df 1)" =
        unname(lavaan::fitMeasures(e$fit0, "chisq"))),
    "liss-glm" = function(e) {
      b <- coef(e$fit_ht)
      setNames(as.list(b), paste("glm:", names(b)))
    },
    "liss-glm-predict" = function(e) {
      p <- predict(e$fit_ht, newdata = e$women, type = "response")
      list("P(hypertension), woman 60, BMI 25" = p[[1]],
           "P(hypertension), woman 60, BMI 35" = p[[2]])
    }))

# ---- chapter 3 ---------------------------------------------------------------
res$ch3 <- run_chapter(
  "03-identification-mediation.qmd",
  c("liss-long-m3", "liss-long-m3ar"),
  hooks = list(
    "liss-long-m3" = function(e) {
      fm <- lavaan::fitMeasures(e$fit3, c("ntotal", "chisq.scaled",
                                          "pvalue.scaled"))
      s <- lavaan::standardizedSolution(e$fit3)
      list("m3: ntotal" = fm[[1]], "m3: scaled chi-square (df 1)" = fm[[2]],
           "m3: p-value" = fm[[3]],
           "m3: integration_16 -> hypertension_17 (std)" = s$est.std[1],
           "m3: integration_16 -> bmi_17 (std)" = s$est.std[2],
           "m3: hypertension_17 -> disease_count_18 (std)" = s$est.std[3],
           "m3: bmi_17 -> disease_count_18 (std)" = s$est.std[4],
           "m3: hypertension_17 ~~ bmi_17 (std)" = s$est.std[5])
    },
    "liss-long-m3ar" = function(e) {
      s <- e$s[e$s$op == "~", ]
      setNames(as.list(s$est.std),
               paste0("m3ar: ", s$rhs, " -> ", s$lhs, " (std)"))
    }))

# ---- chapter 8 ---------------------------------------------------------------
env8 <- new.env()
suppressPackageStartupMessages(library(mclust, quietly = TRUE))   # chunk at line ~161
labels8 <- c("lca-fits", "lca-table", "fig-lca-profile", "ext-vars")
if (full) labels8 <- c(labels8, "stab-features", "underidentification")
res$ch8 <- run_chapter(
  "08-unsupervised-clustering-mixtures.qmd", labels8, env = env8,
  hooks = list(
    "lca-table" = function(e) {
      bic <- sapply(e$fits, function(m) m$bic)
      ll  <- sapply(e$fits, function(m) m$llik)
      c(setNames(as.list(bic), paste0("BIC, K = ", 1:5)),
        setNames(as.list(ll), paste0("log-likelihood, K = ", 1:5)),
        list("K chosen by BIC" = which.min(bic)))
    },
    "fig-lca-profile" = function(e)
      setNames(as.list(e$sizes), paste0("class size ", 1:3, " (by size)")),
    "ext-vars" = function(e) {
      tab <- t(sapply(split(e$ext, e$ext$class), function(s)
        c(n = nrow(s), mean_age = mean(s$age),
          pct_female = 100 * mean(s$female, na.rm = TRUE))))
      out <- list()
      for (k in 1:3) {
        out[[paste0("modal class ", k, ": n")]] <- tab[k, "n"]
        out[[paste0("modal class ", k, ": mean age")]] <- tab[k, "mean_age"]
        out[[paste0("modal class ", k, ": % female")]] <- tab[k, "pct_female"]
      }
      out
    },
    "stab-features" = function(e)
      setNames(as.list(e$ari_drop), paste0("ARI dropping ", names(e$ari_drop)))
  ))

# ---- comparison with the numbers printed in the book -------------------------
# Real-data values, copied from the chapters' frozen output (_freeze/).
real <- list(
  ch2 = c("lm: intercept" = 0.026, "lm: hypertension" = 0.823, "lm: bmi" = 0.020,
          "std. coef of bmi" = 0.095, "n (complete cases)" = 4153,
          "r(age, hypertension)" = 0.296, "r(age, disease_count)" = 0.310,
          "r(hypertension, disease_count)" = 0.316,
          "gamma1 (hand)" = 0.296, "beta (hand)" = 0.245, "gamma2 (hand)" = 0.237,
          "z of gamma2 (lavaan)" = 15.829, "chi-square, hand" = 236.29,
          "chi-square, lavaan (df 1)" = 243.277,
          "glm: (Intercept)" = -7.864, "glm: integration" = -0.044,
          "glm: age" = 0.063, "glm: female" = -0.139, "glm: bmi" = 0.092,
          "P(hypertension), woman 60, BMI 25" = 0.122,
          "P(hypertension), woman 60, BMI 35" = 0.258),
  ch3 = c("m3: ntotal" = 6467, "m3: scaled chi-square (df 1)" = 0.358,
          "m3: p-value" = 0.550,
          "m3: integration_16 -> hypertension_17 (std)" = -0.005,
          "m3: integration_16 -> bmi_17 (std)" = -0.057,
          "m3: hypertension_17 -> disease_count_18 (std)" = 0.293,
          "m3: bmi_17 -> disease_count_18 (std)" = 0.104,
          "m3: hypertension_17 ~~ bmi_17 (std)" = 0.153,
          "m3ar: integration_16 -> hypertension_17 (std)" = 0.000,
          "m3ar: hypertension_16 -> hypertension_17 (std)" = 0.900,
          "m3ar: integration_16 -> bmi_17 (std)" = -0.019,
          "m3ar: bmi_16 -> bmi_17 (std)" = 0.911,
          "m3ar: hypertension_17 -> disease_count_18 (std)" = 0.052,
          "m3ar: bmi_17 -> disease_count_18 (std)" = 0.033,
          "m3ar: disease_count_16 -> disease_count_18 (std)" = 0.824),
  ch8 = c("BIC, K = 1" = 20016.6, "BIC, K = 2" = 18899.5, "BIC, K = 3" = 18843.9,
          "BIC, K = 4" = 18870.0, "BIC, K = 5" = 18937.2,
          "log-likelihood, K = 1" = -9966.1, "log-likelihood, K = 2" = -9361.1,
          "log-likelihood, K = 3" = -9286.9, "log-likelihood, K = 4" = -9253.5,
          "log-likelihood, K = 5" = -9240.6, "K chosen by BIC" = 3,
          "class size 1 (by size)" = 0.777, "class size 2 (by size)" = 0.174,
          "class size 3 (by size)" = 0.049,
          "modal class 1: n" = 3782, "modal class 1: mean age" = 51.9,
          "modal class 1: % female" = 52.8,
          "modal class 2: n" = 723, "modal class 2: mean age" = 66.6,
          "modal class 2: % female" = 51.0,
          "modal class 3: n" = 142, "modal class 3: mean age" = 65.0,
          "modal class 3: % female" = 59.9,
          "ARI dropping hypertension" = 0.56, "ARI dropping cholesterol" = 0.62,
          "ARI dropping lung" = 0.73, "ARI dropping asthma" = 0.73,
          "ARI dropping diabetes" = 0.80, "ARI dropping cancer" = 0.83,
          "ARI dropping arthritis" = 0.90, "ARI dropping heartattack" = 0.97,
          "ARI dropping angina" = 0.97, "ARI dropping stroke" = 0.99))

cat("\n\n==== real (book) vs synthetic ====\n")
for (ch in names(real)) {
  cat("\n", switch(ch, ch2 = "Chapter 2", ch3 = "Chapter 3", ch8 = "Chapter 8"),
      "\n", sep = "")
  syn <- res[[ch]]
  rows <- names(real[[ch]])[names(real[[ch]]) %in% names(syn)]
  tab <- data.frame(real = real[[ch]][rows],
                    synthetic = sapply(syn[rows], function(x) unname(x[[1]])))
  tab$synthetic <- signif(tab$synthetic, 4)
  print(tab)
}
if (!full)
  cat("\n(chapter 8's stability and underidentification chunks skipped;",
      "rerun with --full)\n")
cat("\nAll chapter chunks ran on the synthetic files without error.\n")
