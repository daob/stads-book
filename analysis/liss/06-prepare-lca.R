# Build the multimorbidity LCA dataset for chapter 8 from the LISS health
# module (ch25r, autumn 2025): ten binary physician-diagnosis indicators,
# plus age and gender for interpretation (not used in the model).
#
# As everywhere in this project, LISS microdata stay OUTSIDE the repository:
# the output goes to ../data/liss-health-social-integration/.
#
# Usage: Rscript 06-prepare-lca.R

library(haven)

data_dir <- "../../../data/liss-health-social-integration"
here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (!is.na(here) && nzchar(here)) data_dir <- file.path(here, data_dir)
out_dir <- data_dir

# Source files may sit at the top of the data directory or inside an
# extracted subdirectory named after the archive (as delivered by LISS).
find_dta <- function(name) {
  stem <- sub("\\.dta$", "", name)
  cands <- c(file.path(data_dir, name), file.path(data_dir, stem, name))
  hit <- cands[file.exists(cands)]
  if (length(hit) == 0)
    stop("cannot find ", name, " in ", data_dir, " (looked in ",
         paste(cands, collapse = ", "), ")")
  hit[1]
}
ch <- read_dta(find_dta("ch25r_EN_1.0p.dta"))
av <- read_dta(find_dta("avars_202501_EN_1.0p.dta"))

# Ten diagnosed conditions, 0/1. Codes follow analysis/liss/01-prepare-liss.R.
items <- c(angina      = "ch25r080",
           heartattack = "ch25r081",
           hypertension= "ch25r082",
           cholesterol = "ch25r083",
           stroke      = "ch25r084",
           diabetes    = "ch25r085",
           lung        = "ch25r086",   # chronic lung disease
           asthma      = "ch25r087",
           arthritis   = "ch25r088",   # arthritis / osteoporosis
           cancer      = "ch25r089")
stopifnot(all(items %in% names(ch)))

d <- as.data.frame(lapply(ch[items], function(x) {
  x <- as.numeric(x); x[!x %in% c(0, 1)] <- NA; x
}))
names(d) <- names(items)
d$nomem_encr <- as.numeric(ch$nomem_encr)

age    <- as.numeric(av$leeftijd)
female <- ifelse(as.numeric(av$geslacht) %in% c(1, 2),
                 as.numeric(av$geslacht) - 1, NA)
d <- merge(d, data.frame(nomem_encr = as.numeric(av$nomem_encr),
                         age = age, female = female), by = "nomem_encr")

# Complete cases on the ten indicators (the battery is missing jointly).
d <- d[rowSums(is.na(d[names(items)])) == 0, ]

cat("n =", nrow(d), "\n")
print(round(colMeans(d[names(items)]), 3))

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
saveRDS(d, file.path(out_dir, "liss_lca_conditions.rds"))
cat("wrote", file.path(out_dir, "liss_lca_conditions.rds"), "\n")
