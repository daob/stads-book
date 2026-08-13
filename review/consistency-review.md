# Internal consistency review — chapters 1–5

Reviewed: `index.qmd`, chapters 01–05, `references.bib`, `_quarto.yml`.
Method: all arithmetic in prose recomputed by hand; every R chunk re-executed
(lavaan, lme4, metafor, mediation; the brms chunk was not re-run, see C-10);
all cross-references, citation keys, exercise numbers, and narrative promises
checked mechanically.

Verified-correct highlights (no action needed): tracing-rule arithmetic in ch. 2
(0.40 × −0.42 = −0.168; −0.19 − 0.168 = −0.358; −0.42 + 0.40 × −0.19 = −0.496;
ACE 0.25 + 0.245 = 0.495 and 0.25 + 0.49 = 0.74); the lavaan chi-square of 218
(recomputed: 218.32 on 1 df); plogis values 0.602/0.589, difference 1.3 pp;
reversal age 0.487/0.017 ≈ 28.6 → age 44.6/"around 45"; Exercise 2.4 logit
−0.579 → 0.36; ch. 3 simulations (identical chi-squares 0.0073; confounded
b̂ = 0.47 ≈ 0.5, spurious direct −0.25; IV estimate −0.02 ≈ 0); IV example
0.15/0.3 = 0.5, difference 0.2; Brader ACME 0.083 ≈ 0.08 (significant), ADE
0.01 (n.s.); sleepstudy (27 coefficients; day-9 = 94.2; subject range −126.9
to +33.6; SS 166,235/250,618/151,101; F 18.70/14.93; (14742.24 − 987.59)/10 =
1375.5 = 37.09²; profile CI for σ_Subject 26–53, consistent with the quoted
Bayesian 28–57); BCG meta-analysis (FE −0.434, SE 0.042; RE −0.746, SE 0.186;
τ = 0.581, τ² = 0.338 ≈ 0.34; AIC 154.0 vs 29.2; e^−0.434 = 0.648, e^−0.746 =
0.474); ch. 1 fishing probabilities (1 − .95²⁰ = .64; 1 − .95⁵⁰ = .92; 4,800
pairs → 48 at p ≤ .01); Exercise 4.1 (df 3/96, MS 400/200, F = 2.0, p = .119,
η² = .059); ch. 1 simulation bias (−1.24, "more than a full point"). Every
`@sec-`, `@fig-`, `@tbl-`, `@eq-` reference resolves; every cited `@key` exists
in `references.bib`; all exercise numbers are consecutive with no gaps or
duplicates (inline 1.1–1.6, 2.1–2.5, 3.1–3.4, 4.1–4.4, 5.1–5.3; test-yourself
N.A–N.C in all five chapters); all diagram files referenced exist in
`diagrams/`. The a/b/c notation of ch. 2 (G→F = a, F→S = b, direct G→S = c) and
ch. 3 (X→M = a, M→Y = b, direct X→Y = c) assigns the same structural roles to
the same letters and each chapter defines them at first use: compatible.

---

## A. Errors that must be fixed

### A-1. Ch. 2: "comparable to sliding the full political-interest scale" is off by a factor of two
- **File:** `02-theory-to-linear-models.qmd` (Reading the age effect below @tbl-voting)
- **Quote:** "Between a 20-year-old and a 70-year-old lie 50 years, hence $50 \times 0.017 = 0.85$ logits, comparable to sliding the full political-interest scale."
- **Problem:** The political-interest coefficient is 0.915 per unit on a 1–3 scale, so sliding the *full* scale is 2 × 0.915 = 1.83 logits. 0.85 is comparable to *one unit* of political interest (0.915), i.e. about half the full scale, not the full scale.
- **Fix:** Either "comparable to a one-point step on the political-interest scale" or "about half of sliding the full political-interest scale". (0.85 itself is correct.)

### A-2. Ch. 1: the Breathalyzer crackdown began in October 1967, not September
- **File:** `01-research-question-to-interpretation.qmd` (opening paragraph and "Research questions")
- **Quotes:** "In September 1967, the British government began a crackdown on drunk driving" and "We never get to see September 1967 without the crackdown."
- **Problem:** The Road Safety Act 1967's breath-test provisions came into force on 9 October 1967, and Ross, Campbell & Glass (1970) — the very source the footnote says the details follow — date the crackdown to October 1967. Both occurrences of "September" appear to be wrong.
- **Fix:** Change both to "October 1967" (verify once against @breathalyser1970 / @shadish2002).

### A-3. Ch. 4: −0.745 vs −0.746 in Answer 4.A
- **File:** `04-anova.qmd` (Answer 4.A, part a)
- **Quote:** "the average of the study-specific effects multiplies the odds by $e^{-0.745} \approx 0.47$"
- **Problem:** The estimate is stated as −0.746 in the exercise itself, in the main text, and in the recomputed metafor output. One-digit typo.
- **Fix:** $e^{-0.746} \approx 0.47$.

---

## B. Genuine inconsistencies

### B-1. Interviewer example: fixed in ch. 2, random in ch. 4, near-identical surface description
- **Files:** `02-theory-to-linear-models.qmd` (Exercise 2.B(d) + Answer: "The same respondents were each also rated by three different interviewers. To control for stable differences among interviewers without generalizing beyond them … Fixed effects") vs `04-anova.qmd` ("Fixed or random?": "Each respondent rated by three interviewers from a large interviewer pool: random, since the interviewers stand in for interviewers in general").
- **Problem:** The two passages are internally coherent (the stated goals differ, and the book's own doctrine is "answer with the goal"), but the surface scenario is the same and the answers are opposite, with no acknowledgment. A student who did Exercise 2.B will read ch. 4's list as contradicting it.
- **Fix:** In ch. 4's list, add a clause such as "compare Exercise 2.B, where the same three-interviewer design got dummies because the goal was only to control, not to generalize" — turning the collision into the intended lesson.

### B-2. Ch. 3: "The previous chapter ended with a warning" — it didn't end with it
- **File:** `03-identification-mediation.qmd` (chapter intro)
- **Quote:** "The previous chapter ended with a warning that a model which fits the data is not thereby true."
- **Problem:** The warning exists in ch. 2, but mid-chapter and in a footnote ("the surviving model is not thereby true: other models fit these same three correlations exactly as well…", footnote in "Meeting data"). Ch. 2 actually ends with "Why only these models?" and the test-yourself block.
- **Fix:** Either soften ch. 3 ("The previous chapter warned that…") or promote the ch. 2 footnote into the closing text of that chapter.

### B-3. Ch. 4: promise that the predictive reading "returns in force" in ch. 5 is not kept
- **File:** `04-anova.qmd` (end of meta-analysis section)
- **Quote:** "This predictive reading of a batch distribution returns in force in @sec-explanation-prediction."
- **Problem:** Ch. 5 discusses prediction throughout but never returns to batch distributions, random effects, or predicting a new draw θ′ ~ N(μ̂, τ̂²) — not even in passing. As written the forward promise is unfulfilled.
- **Fix:** Either weaken to "the idea of prediction takes center stage in @sec-explanation-prediction", or add a sentence in ch. 5 (e.g. in "Prediction as a statement about unseen data" or "What to carry forward") explicitly linking the meta-analytic prediction interval to prediction for unseen units.

### B-4. Ch. 4: AIC (and BIC) used to carry a conclusion without any introduction
- **File:** `04-anova.qmd` (BCG section: "the model fit comparison (AIC 154 for fixed against 29 for random) is a rout"; Answer 4.A: "AIC/BIC favor the random-effects model overwhelmingly").
- **Problem:** AIC and BIC are never defined or glossed anywhere in chapters 1–5, yet a substantive model choice ("a rout") rests on them. Nothing tells the reader that lower is better, or what the number trades off. (The values themselves are correct: recomputed AIC 154.0 vs 29.2.)
- **Fix:** Add a one-sentence gloss at first use ("AIC, an index of fit penalized for parameters, lower is better; the machine-learning chapters return to it") or replace with the likelihood-ratio test / a comparison the book has already taught.

### B-5. Ch. 5: "under 6%" vs "0.03 to 0.06"
- **File:** `05-explanation-prediction.qmd` (opening: "for the other four, under 6%"; later: "and 0.03 to 0.06 for grit, eviction, caregiver layoff, and job training").
- **Problem:** 0.06 is not "under 6%"; the two passages disagree at the boundary.
- **Fix:** "about 6% or less" in the opening, or "0.03 to 0.06" → "0.03 to 0.05" if that matches @salganik2020 (check the paper's exact values).

### B-6. Ch. 3: figure chunk `weak-instrument` has a fig-cap but no `fig-` label prefix
- **File:** `03-identification-mediation.qmd` (chunk `#| label: weak-instrument` with `#| fig-cap: "Instrumental-variable estimates across 500 simulated studies…"`)
- **Problem:** Unlike `fig-confounding` (ch. 1) and `fig-anova-display` (ch. 4), this label lacks the `fig-` prefix, so Quarto will not number the figure or make it cross-referenceable; the book's figures will be inconsistently numbered. Not currently dangling (nothing references it), but inconsistent.
- **Fix:** Rename the label to `fig-weak-instrument`.

### B-7. Ch. 5: the "large evaluation" of LLM treatment-effect prediction is attributed to a position paper
- **File:** `05-explanation-prediction.qmd` ("The bitter lesson" section)
- **Quote:** "one large evaluation found a model predicting most of the variation in average treatment effects across dozens of preregistered experiments [@anthis2025]"
- **Problem:** @anthis2025 is a position paper ("Position: LLM Social Simulations Are a Promising Research Method"), not itself the evaluation. The evaluation described (GPT-4 predicting ATEs across ~70 preregistered survey experiments) is Hewitt et al. (2024), which Anthis et al. cite. As worded, the factual claim is attributed to the wrong source.
- **Fix:** Cite the primary evaluation (add Hewitt et al. 2024 to `references.bib`), or reword to "a position paper reviews evidence that models can predict much of the variation… [@anthis2025]".

### B-8. Ch. 4: "four times" for a ratio of 4.4
- **File:** `04-anova.qmd` (BCG section)
- **Quote:** "The random-effects standard error (0.186) is four times the fixed-effects one (0.042)."
- **Problem:** 0.186/0.042 = 4.4. "Four times" undersells it slightly; a careful student who divides will stumble.
- **Fix:** "more than four times" or "about 4.5 times".

---

## C. Suggestions

### C-1. State the ε vs ζ notation convention
`01-…qmd` uses $\varepsilon$ in the design-analysis regressions (never named or explained); ch. 2 introduces $\zeta$ "disturbances" with care; ch. 4 uses $\varepsilon_{ij}$ for residual noise. The implicit convention (ζ for structural equations, ε for plain regression residuals) is never stated. A footnote in ch. 1 at the first ε ("the error term, everything the model leaves out; @sec-theory-to-glm dissects it properly") would close the gap. Terms checked as consistent across chapters: "disturbance", "claims of absence", "tracing rules"/"decomposition rules" (both names introduced together in ch. 2, "tracing rules" used thereafter, including ch. 3), "batch" (ch. 4 only), standardized-variables convention (declared in both ch. 2 and ch. 3).

### C-2. `plogis()` appears in ch. 1 code before it is explained in ch. 2
`01-…qmd`, chunk `fig-confounding`: `exercise <- rbinom(n, 1, plogis(motivation))`. Harmless (the comment carries the meaning), but a code comment like `# plogis: probability increasing in motivation; see next chapter` would prevent a lookup detour.

### C-3. η² used without introduction
`04-anova.qmd`, Answer 4.1: "$\eta^2 = 1200/20400 \approx 0.06$". The symbol never appears elsewhere. Either name it ("the proportion of variance, traditionally called η²") or drop the symbol and give just the proportion.

### C-4. F1, precision, and recall only half-glossed
`05-…qmd`: the main text motivates F1 via base rates; the gloss "balances precision and recall on the positive class" appears only inside Answer 5.3(c), and precision/recall are themselves undefined. One parenthetical in the main text would do. Similarly, Cohen's kappa (Answer 5.B) is glossed only as "agreement statistics such as"; adequate, but a half-sentence ("agreement corrected for chance") would be better.

### C-5. `binomial("probit")` in the ch. 3 mediation chunk
Ch. 2 teaches the logit link only; probit appears in the Brader code without comment. Either switch the example to `binomial("logit")` (results barely change) or add a footnote that probit is a sibling link function.

### C-6. "Shrunken" estimates and the delta method are name-dropped
`04-anova.qmd` Answers 4.B/4.C ("shrunken person-level estimates", "their (shrunken) $v_{17}$") and `03-…qmd` ("lavaan's `:=` operator gives its standard error by the delta method"): neither concept is introduced. A short parenthetical gloss for each, or dropping the jargon, would keep the answers self-contained.

### C-7. Belenky study named without a citation
`04-anova.qmd` footnote: "The original study is by Belenky and colleagues". Add the Belenky et al. (2003, J. Sleep Research) entry to `references.bib` and cite it, or drop the name.

### C-8. `angrist1991` sits unused while the quarter-of-birth instrument is discussed
`03-…qmd`: "with the quarter-of-birth instrument for schooling as the canonical case [@bound1995]". @bound1995 is the critique; the instrument itself is @angrist1991, which is already in the bib but never cited. Cite both: "[@angrist1991; @bound1995]". Other unused bib entries (fine to keep, but prune if the file should stay minimal): `holland1986`, `rosenbaum2017`, `strunkwhite2000`, `pinker2014`, `leist2022`.

### C-9. `bayerl2024` key vs 2025 publication year
The bib entry (correctly) has year 2025 (Nature Human Behaviour 9:507–520), so the citation renders "Bayerl et al. (2025)" while the key says 2024. Harmless internally; rename the key to `bayerl2025` only if key-year consistency is wanted (touches ch. 2 in five places).

### C-10. Two hard-coded numbers not re-verified here
(i) `04-anova.qmd`: "The posterior for $\sigma_{\text{Subject}}$ centers near 40 ms with a 95% interval of roughly 28 to 57" — the brms chunk was not re-run (MCMC + compilation); the frequentist profile interval is 26–53, so the Bayesian claim is plausible, and the chunk is seeded, but the prose should be checked against the rendered output once. (ii) `02-…qmd`: the Bayerl coefficients (0.40, −0.19, −0.42, n = 1,172) are taken from the paper and flagged as rounded in a footnote; internally consistent everywhere they are used, but worth one check against the published SEM table.

### C-11. Ch. 3: figure @fig-iv shows the no-direct-path model, then the text counts parameters "with the direct path included"
`03-…qmd`: the figure (caption: "There is no direct path from X to Y") appears before the counting argument that momentarily includes $c$ ("the unknowns are $a$, $b$, $c$, and $\rho$: four parameters"). Consider a caption note ("the direct path considered in the text is omitted here") or reorder so the counting comes first. Also cosmetic: the label `fig-iv` on a figure titled "The confounded mediation model" is fine but slightly opaque.

### C-12. Narrative promises — full audit (all others kept)
Verdicts on every forward/backward promise found:
- index → chapter descriptions: **accurate** for all five chapters.
- ch. 1 "Chapter 5 (@sec-explanation-prediction) returns to the boundary … at length": **kept**.
- ch. 1 "a claim we will learn to call 'non-additivity' in @sec-theory-to-glm": **kept** (ch. 2 defines additivity/non-additivity, TPB example reused).
- ch. 1 case-control "a logistic regression (@sec-theory-to-glm)": **kept** (forward reference present at first use, so no pedagogical-dependency problem).
- ch. 1 closing "The next chapter takes the step this one glossed over": **kept**.
- ch. 1 Answers 1.B/1.C "@sec-identification develops [instruments] in detail": **kept**.
- ch. 2 footnote "a problem so consequential it gets its own chapter (@sec-identification)": **kept** (equivalent-models problem is ch. 3's Failure One).
- ch. 2 "@sec-anova develops this machinery properly" (block F-test): **kept**; ch. 4 explicitly redeems it ("the block test we promised in @sec-theory-to-glm").
- ch. 2 footnote "a wrinkle we return to later in the chapter" (binary outcome): **kept** (logistic section + Exercise 2.C(c)).
- ch. 3 "the fifth checklist question of @sec-rq-to-interpretation": **kept**, though the paraphrase ("which feature of the design put the answer into the data") is looser than ch. 1's "does the design warrant the assumptions?" — acceptable.
- ch. 4 opening "and, at the end of this chapter, to meta-analysis": **kept**.
- ch. 4 closing "The next chapter changes register…": **kept**.
- ch. 5 "The previous four chapters were about models whose parameters we interpret: effects, mechanisms, variance components": **accurate**.
- ch. 5 "the next chapter's subject" (bias-variance; overfitting/cross-validation) and ch. 2 "flexible methods of the later chapters": **not checkable** — chapter 6 is outside this draft; keep on a watchlist.
- Exceptions: B-2 (ch. 3 "ended with a warning") and B-3 (ch. 4 "returns in force").
