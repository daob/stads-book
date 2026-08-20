# Prepare LISS wave-18 data for the chapter 2 example.
#
# Reads three LISS files (Stata .dta):
#   ch25r_EN_1.0p.dta   Health study, wave 18 (fieldwork Nov-Dec 2025)
#   cs25r_EN_1.0p.dta   Social Integration and Leisure, wave 18 (Oct-Nov 2025)
#   avars_202501_EN_1.0p.dta   Background variables, January 2025
#
# and writes one combined analysis file with the variables of the chapter 2
# model: social integration (S), two measurable physiological states, blood
# pressure (B, as diagnosed hypertension) and central adiposity (A, as BMI),
# and chronic disease burden (the outcome the data offer in place of death).
# Inflammation is not measured in LISS; no serum biomarkers are collected.
#
# On missing values: the .dta files encode genuinely blank answers as system
# missing, but three kinds of code survive as ordinary values and are handled
# here by hand, after checking the codebooks:
#   - height and weight are free integers (codebook range 1-300 / 1-1000)
#     with no declared missing code, so entry errors like 17 cm or 999 kg
#     arrive as data; they are removed with plausibility windows;
#   - the contact-frequency items code 8 = "don't know", 9 = "not applicable"
#     as labelled values, not as missing;
#   - background variables use negative codes (-13, -14, -15, -99) for
#     "unknown" and "prefer not to say".
#
# Usage:  Rscript 01-prepare-liss.R
# Writes: ../../../data/liss-health-social-integration/liss_ch2_combined.rds
#         ../../../data/liss-health-social-integration/liss_ch2_combined.csv

library(haven)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
DATA <- normalizePath(file.path(here, "..", "..", "..", "data",
                                "liss-health-social-integration"))

ch <- read_dta(file.path(DATA, "ch25r_EN_1.0p.dta"))
cs <- read_dta(file.path(DATA, "cs25r_EN_1.0p.dta"))
av <- read_dta(file.path(DATA, "avars_202501_EN_1.0p.dta"))
cat(sprintf("read: ch25r %d x %d, cs25r %d x %d, avars %d x %d\n",
            nrow(ch), ncol(ch), nrow(cs), ncol(cs), nrow(av), ncol(av)))

## ---- social integration (cs25r) -------------------------------------------
# Organizational involvement, following the item list suggested for this
# example: membership of eleven types of voluntary organization, plus
# voluntary work for four of them. All items are coded 0 = no, 1 = yes.
member_items <- paste0("cs25r0", c("06", "11", "16", "21", "31", "36",
                                   "41", "46", "51", "56", "61"))
volunteer_items <- paste0("cs25r0", c("07", "12", "17", "42"))
involve_items <- c(member_items, volunteer_items)

stopifnot(all(involve_items %in% names(cs)))
inv <- as.data.frame(lapply(cs[involve_items], function(x) {
  x <- as.numeric(x)
  x[!x %in% c(0, 1)] <- NA           # defensive: nothing outside {0, 1}
  x
}))
n_item_na <- sum(is.na(inv))
# The index is the number of involvements ticked, 0-15. Respondents missing
# any item (a handful) get NA rather than a deflated count.
integration <- ifelse(rowSums(is.na(inv)) == 0, rowSums(inv), NA)

# Contact frequency (not in the main model; kept for later use). Items are
# 1 = almost every day ... 7 = never, with 8 = don't know and 9 = not
# applicable as labelled values that must be recoded to missing by hand.
contact_items <- c("cs25r290", "cs25r291", "cs25r292")
con <- as.data.frame(lapply(cs[contact_items], function(x) {
  x <- as.numeric(x)
  x[x %in% c(8, 9)] <- NA
  8 - x                              # reverse: higher = more frequent contact
}))
contact_freq <- rowMeans(con, na.rm = TRUE)
contact_freq[rowSums(!is.na(con)) == 0] <- NA

cs_out <- data.frame(nomem_encr = as.numeric(cs$nomem_encr),
                     integration = integration,
                     contact_freq = contact_freq)

## ---- physiological states and disease (ch25r) ------------------------------
height <- as.numeric(ch$ch25r016)    # cm, free integer, no missing code
weight <- as.numeric(ch$ch25r017)    # kg, free integer, no missing code
height[height < 120 | height > 220] <- NA
weight[weight < 35 | weight > 250] <- NA
bmi <- weight / (height / 100)^2
bmi[bmi < 14 | bmi > 60] <- NA

hypertension <- as.numeric(ch$ch25r082)         # 0 = no, 1 = yes

# Chronic disease burden: count of diagnosed conditions ever reported, from
# the physician-diagnosis battery. Hypertension (ch25r082) is excluded
# because it is a predictor in the model; the other thirteen conditions
# (angina, heart attack, high cholesterol, stroke, diabetes, chronic lung
# disease, asthma, arthritis/osteoporosis, cancer, ulcer, Parkinson's,
# dementia, other) are summed. All are coded 0/1 and are missing together
# for the few respondents who skipped the battery.
disease_items <- paste0("ch25r0", c("80", "81", "83", "84", "85", "86",
                                    "87", "88", "89", "90", "91", "95", "97"))
stopifnot(all(disease_items %in% names(ch)))
dis <- as.data.frame(lapply(ch[disease_items], function(x) {
  x <- as.numeric(x)
  x[!x %in% c(0, 1)] <- NA
  x
}))
disease_count <- ifelse(rowSums(is.na(dis)) == 0, rowSums(dis), NA)

longstanding <- ifelse(as.numeric(ch$ch25r018) %in% c(1, 2),
                       2 - as.numeric(ch$ch25r018), NA)  # 1 = yes, 0 = no
selfrated_health <- as.numeric(ch$ch25r004)              # 1 poor ... 5 excellent

ch_out <- data.frame(nomem_encr = as.numeric(ch$nomem_encr),
                     bmi = bmi, hypertension = hypertension,
                     disease_count = disease_count,
                     longstanding = longstanding,
                     selfrated_health = selfrated_health)

## ---- background (avars) ----------------------------------------------------
# Negative values are missing codes throughout this file.
age <- as.numeric(av$leeftijd);  age[age < 0] <- NA
gender <- as.numeric(av$geslacht)                 # 1 male, 2 female, 3 other
female <- ifelse(gender %in% c(1, 2), gender - 1, NA)
educ <- as.numeric(av$oplcat);  educ[educ < 0] <- NA

av_out <- data.frame(nomem_encr = as.numeric(av$nomem_encr),
                     age = age, female = female, educ = educ)

## ---- merge and write -------------------------------------------------------
d <- merge(ch_out, cs_out, by = "nomem_encr")     # both modules answered
d <- merge(d, av_out, by = "nomem_encr", all.x = TRUE)
d <- d[!is.na(d$age) & d$age >= 18, ]             # adults

cat(sprintf("merged: %d adults with both modules\n", nrow(d)))
cat(sprintf("item-level NAs recoded in involvement block: %d\n", n_item_na))
model_vars <- c("integration", "hypertension", "bmi", "disease_count")
for (v in model_vars)
  cat(sprintf("  %-14s n = %4d  mean = %6.2f  sd = %5.2f  NA = %3d\n",
              v, sum(!is.na(d[[v]])), mean(d[[v]], na.rm = TRUE),
              sd(d[[v]], na.rm = TRUE), sum(is.na(d[[v]]))))
cat(sprintf("complete cases on the model variables: %d\n",
            sum(complete.cases(d[model_vars]))))

saveRDS(d, file.path(DATA, "liss_ch2_combined.rds"))
write.csv(d, file.path(DATA, "liss_ch2_combined.csv"), row.names = FALSE)
cat("wrote liss_ch2_combined.rds and .csv to", DATA, "\n")
