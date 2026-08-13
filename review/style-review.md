# Style review: chapters 0–5 (index, 01–05)

Reviewed against (1) the Pinker checklist (`sources/extracts/pinker-style-checklist.md`, esp. Section 6), (2) the author's explicit bans, (3) the voice profile (`sources/extracts/style-profile.md`). Quotes are exact; line numbers refer to the current `.qmd` files. LaTeX math and Quarto markup were not flagged.

## Em-dash density (prose only; code, YAML, and tables excluded)

| File | Em-dashes (—) | Notes |
|---|---|---|
| index.qmd | 0 | |
| 01-research-question-to-interpretation.qmd | 0 | |
| 02-theory-to-linear-models.qmd | 0 | 3 en-dashes (–), all in numeric ranges ("1–3", "1–6", "1–5"); legitimate |
| 03-identification-mediation.qmd | 0 | |
| 04-anova.qmd | 0 | |
| 05-explanation-prediction.qmd | 0 | |

No em-dash findings. One consistency note: numeric ranges use en-dashes in ch. 2 ("1–3") but hyphens elsewhere ("1948-1980", "0-1 interval") and words in ch. 2 ("aged 70 to 80"); see C-14.

## Findings

Severity A = violation of an explicit ban; B = clear Pinker-checklist violation that hurts readability; C = minor polish.

### A. Explicit bans

| # | File | Section / nearby quote | Issue type | Specific suggestion |
|---|---|---|---|---|
| A-1 | 01-...qmd (line 208) | "The honest courses of action are easy to state." | Ban: "the honest X" tic | "The remedies are easy to state." |
| A-2 | 03-...qmd (line 85, footnote) | "Randomization makes the total effect honestly estimated" | Ban: "honest" tic | "Randomization keeps the total effect unbiased" |
| A-3 | 03-...qmd (line 97) | "The constructive turn begins with honesty: draw the confounding into the model." | Ban: "honest" tic | "The constructive turn begins by drawing the confounding into the model." |
| A-4 | 03-...qmd (line 233, Answer 3.B) | "The bootstrap gives an honest interval around $ab$" | Ban: "honest" tic | "The bootstrap gives a valid interval around $ab$" |
| A-5 | 04-...qmd (line 197) | "an honest and wide interval that the fixed-effects model ... cannot even formulate" | Ban: "honest" tic | "a wide interval that the fixed-effects model ... cannot even formulate" (the width already carries the honesty point) |
| A-6 | 04-...qmd (line 236, Answer 4.B) | "the batch distribution is the only honest tool" | Ban: "honest" tic | "the batch distribution is the only defensible tool" |
| A-7 | 05-...qmd (line 33) | "are honesty devices for explainers too" | Ban: "honest" tic | "are safeguards for explainers too" |
| A-8 | 05-...qmd (line 75) | "honest evaluation always involves data the model has not touched" | Ban: "honest" tic | "evaluation always requires data the model has not touched" |
| A-9 | 05-...qmd (line 109, Answer 5.C) | "the honest position is that social science learned something painful" | Ban: "the honest X" tic | "the defensible position is that social science learned something painful" |
| A-10 | 01-...qmd (line 92) | "The threat lists are not a bureaucratic checklist to recite. They are a repertoire of rival explanations" | Ban: "X is not a Y; it is a Z" rhetoric | "Treat the threat lists as a repertoire of rival explanations rather than a checklist to recite; their practical use is the question: ..." |
| A-11 | 02-...qmd (line 48) | "The \"$\zeta$\" (zeta) terms are not an apology." | Ban: "not X" rhetoric (also Pinker §6 item 22: negates a claim no reader held) | Delete the sentence; open with "@saris1984 list exactly what lives in a disturbance: ..." |
| A-12 | 03-...qmd (line 56) | "They are identical. Not similar: identical to every decimal" | Ban: "not X, Y" near-variant | "They are identical to every decimal, in this dataset and in every dataset either model will ever meet." |
| A-13 | 03-...qmd (line 177) | "The remedy is not to abandon the how-question. It is to treat the mediation model as this book treats every model" | Ban: "X is not Y. It is Z" rhetoric | "The remedy is to keep the how-question but treat the mediation model as this book treats every model: as a set of assumptions waiting for a design." |
| A-14 | 04-...qmd (line 66) | "ANOVA and regression are not two methods. They are one fit with two summaries" | Ban: "X is not Y. It is Z" rhetoric | "ANOVA and regression are one fit with two summaries:" (the identical tables just shown already deliver the surprise) |
| A-15 | 05-...qmd (line 67) | "The relationship between explanation and prediction is not a war that one side wins; fields swing" | Ban: "X is not a Y; Z" rhetoric | "Fields swing between explanation and prediction, and the swings are instructive." |
| A-16 | 03-...qmd (line 18, footnote) | "The recipe is not our subject; what the numbers mean is." | Ban: "not X; Y is" near-variant | "Our subject is what the numbers mean, not the estimation recipe." (literal contrast, front-loaded) |
| A-17 | index.qmd (line 7) | "This book is about a way of thinking, not a list of techniques." | Ban: "not X, Y" rhetoric as standalone opener | Cut the sentence; the next paragraph (toolbox with no manual) makes the point concretely. |
| A-18 | 01-...qmd (line 188) | "comparisons *within* the data ... reaching *beyond* the data" | Ban: >1 emphasis italic per paragraph | Remove both italics; the parallel syntax carries the contrast. |
| A-19 | 01-...qmd (line 192) | "Random *assignment* supports causal comparison within the study. Random *sampling* supports generalization beyond it." | Ban: >1 emphasis italic per paragraph | Remove both italics; "Random assignment ... Random sampling ..." contrasts by position. |
| A-20 | 01-...qmd (line 105) | "removes *selection* in one stroke ... Shared *history* and *maturation* are absorbed" | Ban: >1 emphasis italic per paragraph | Set all three threat names in roman; they were introduced (italicized) in the list above. |
| A-21 | 03-...qmd (line 206) | "*if* the assumptions hold, *then* this is the mediation process" | Ban: >1 emphasis italic per paragraph | Roman both: "an if-then statement: if the assumptions hold, then this is the mediation process." |
| A-22 | 05-...qmd (line 27) | "*forecast* of rain ... a *causal* claim ... know *who*, and does not need to know *why*" | Ban: >1 emphasis italic per paragraph (four here) | Remove all four italics; "forecast"/"causal" are already contrasted by the two-sentence structure, and "who ... why" land at clause ends. |
| A-23 | 04-...qmd (line 3) | "evokes agricultural experiments, mid-century textbooks, and tables full of capital letters" | Ban: reflexive triple | Cut to two: "evokes agricultural experiments and tables full of capital letters". |
| A-24 | 05-...qmd (line 13) | "(superspreading, waning immunity, behavior change)" and "(stubbornness, homophily, distrust)" | Ban: reflexive triples (two in one paragraph) | Trim one list to two items, e.g. "(stubbornness, homophily)". |
| A-25 | 05-...qmd (line 45) | "formal grammars, hand-built linguistic knowledge, theories of meaning" | Ban: reflexive triple (asyndetic) | "formal grammars and hand-built linguistic knowledge". |

### B. Pinker-checklist violations

| # | File | Section / nearby quote | Issue type | Specific suggestion |
|---|---|---|---|---|
| B-1 | 01-...qmd (line 96) | "a compact notation for designs which I will modernize slightly" | Punctuation / garden path (supplementary clause unmarked) | "a compact notation for designs, which I will modernize slightly" |
| B-2 | 01-...qmd (line 96) | "The value of a design lies in which threats it removes, and the analysis of a design is a regression equation whose coefficients answer the research question, given the assumptions the design supports." | Two points in one sentence; heavy right clause | Split after "removes.": "The value of a design lies in which threats it removes. Its analysis is a regression equation whose coefficients answer the research question, given the assumptions the design supports." |
| B-3 | 01-...qmd (line 137) | "what remains is selection combined with maturation, groups changing at different rates for their own reasons, and selection combined with regression artifacts, as when schools adopt a policy" | List items contain commas; boundaries unparseable (checklist §5: use semicolons) | "what remains is selection combined with maturation (groups changing at different rates for their own reasons); and selection combined with regression artifacts, as when schools adopt a policy ..." |
| B-4 | 01-...qmd (line 90) | "The threats are all of the form \"the effect depends on something this study held fixed\"." | Abstract claim without concrete example (checklist item 7); the other three validity families all get one | Append an example: "..held fixed\", as when a drug tested on healthy volunteers meets elderly patients." |
| B-5 | 03-...qmd (line 3) | "feeds a sense of injustice, and strengthens regional identification, and each of these in turn pushes people" | Serial list followed by a second "and"-clause; parse hiccup | "...and strengthens regional identification; each of these in turn pushes people toward a protest vote" |
| B-6 | 05-...qmd (line 55) | "Two data sources compete: the LISS panel, survey data \"wide\" in variables (over 30,000, ...) but with roughly 1,400 outcome-labeled cases, against the Dutch population registers, \"long\" in cases (...) but limited to objective variables." | Center-heavy sentence; "against" arrives ~30 words after its anchor | Split: "Two data sources compete. The LISS panel is \"wide\" in variables: over 30,000, including stated fertility intentions, the kind of subjective variable registers never contain, but with roughly 1,400 outcome-labeled cases. The Dutch population registers are \"long\" in cases: millions, 1995 through 2023, even the full kinship network, but limited to objective variables." |
| B-7 | 05-...qmd (line 33) | "What researchers miss he calls predictive consciousness" | Inverted syntax; momentary garden path; "he" leans on a citation key two sentences back | "He calls the missing ingredient predictive consciousness" (or at minimum "What researchers miss, he calls ...") |
| B-8 | 02-...qmd (lines 151, 187) | "Categorical predictors enter as 0/1 variables" ... later "except the female dummy" | Jargon ("dummy") used before it is glossed (checklist item 6) | At line 151: "enter as 0/1 variables ('dummies')", then line 187 stands. |
| B-9 | 02-...qmd (lines 171, 185) | "$P(y=1) = 1/(1 + e^{-\text{logit}})$" ... "hence $50 \times 0.017 = 0.85$ logits" | Term "logit" never glossed; appears in table header, formula, and as a unit | At line 161 (log-odds paragraph) add: "the log-odds, also called the 'logit'". |
| B-10 | 04-...qmd (line 195) | "the model fit comparison (AIC 154 for fixed against 29 for random) is a rout" | Abbreviation AIC never spelled out or glossed (checklist item 8); BIC likewise in Answer 4.A | "(AIC, a fit index in which lower is better: 154 for fixed against 29 for random)" |
| B-11 | 05-...qmd (line 55) | "The headline metric is F1, chosen because with about one in five positives, raw accuracy flatters models" | "F1" unglossed on first use; gloss exists only in Answer 5.3 | "The headline metric is F1, which balances precision and recall on the positive class, chosen because ..." |
| B-12 | 04-...qmd (lines 136–148) | `posterior::as_draws_df(fit_brm2) |> select(...) |> pivot_longer(...) |> ...` | Un-narrated code (voice profile: narrate command by command); longest pipeline in the book gets no prose | Add before or after the chunk: "The pipeline pulls the posterior draws of each standard deviation, relabels them, and draws one distribution per row." |
| B-13 | 04-...qmd (line 3) | "This chapter argues both are missing the point." | Metadiscourse (checklist item 1) | "Both are missing the point." |

### C. Minor polish

| # | File | Section / nearby quote | Issue type | Specific suggestion |
|---|---|---|---|---|
| C-1 | 05-...qmd (line 47) | "Quite concrete tools, with quite concrete caveats." | Doubled intensifier; intensifiers weaken (checklist §1) | "Concrete tools, with concrete caveats." |
| C-2 | 01-...qmd (line 199) | "estimate the wrong number very precisely" | Intensifier | "estimate the wrong number precisely" |
| C-3 | 02-...qmd (line 89) | "a second, very different example" | Intensifier | "a second, different example" |
| C-4 | 04-...qmd (line 1) | "# ANOVA is still cool!" | Voice profile: the single "!" is reserved for a genuinely surprising payoff; a jokey title is not deadpan | "# ANOVA is still cool {#sec-anova}" |
| C-5 | 01-...qmd (line 5) | "is the subject of this chapter" | Metadiscourse-lite | Optional: "That gap, between a number that moved and a question that got answered, is what this chapter teaches you to see." |
| C-6 | 01-...qmd (line 15) | "so let me say it again in different words" | Metadiscourse-lite (conversational, borderline) | Trim to "so let me say it again." |
| C-7 | 01-...qmd (line 73) | "It helps to meet the whole map once, briefly, before zooming in." | Metadiscourse-lite | Optional cut; the family names that follow orient by themselves. |
| C-8 | 01-...qmd (line 157) | "Before moving on, one demonstration." | Signposting | "One demonstration." |
| C-9 | 02-...qmd (line 3) | "the gap is consistent, and it is not because women are more satisfied" | Loose "it" (a gap is not "because") | "the gap is consistent, and not because women are more satisfied" |
| C-10 | 02-...qmd (line 183) | Table caption: "LISS panel" | Abbreviation never spelled out (also used in ch. 5) | First use: "the LISS panel, a Dutch probability-based internet panel". |
| C-11 | 03-...qmd (line 191) | `family = binomial("probit")` | Narration skips "probit"; students have met only logistic | Add clause: "(a probit link, logistic regression's near-twin)". |
| C-12 | 04-...qmd (lines 236, 248) | "shrunken person-level estimates"; "(shrunken) $v_{17}$" | Jargon unglossed | First use: "shrunken (pulled toward the group mean)". |
| C-13 | 05-...qmd (line 47) | "As *measurement instruments*, ... As *simulated participants*, ... As *agents*, ..." | Three italic run-in labels in one paragraph; borderline under the italics ban (they act as labels, not emphasis) | Acceptable as-is; if trimming, set the phrases in roman. |
| C-14 | 02/04-...qmd | "1–3" vs "1948-1980" vs "0-1 interval" vs "aged 70 to 80" | Inconsistent range style | Standardize numeric ranges on the en-dash: "1948–1980", "0–1 interval". |
| C-15 | 05-...qmd (lines 5, 33) | "effects, mechanisms, variance components"; "holding out data, penalizing flexibility, insisting on out-of-sample performance" | Asyndetic triples cluster in ch. 5 (with A-24, A-25); individually defensible, jointly a rhythm | Break one or two: e.g. "holding out data and penalizing flexibility" (out-of-sample is already implied by holding out). |
| C-16 | 02-...qmd (line 159) | "Submitting a review, voting, being employed: many outcomes are binary" | Asyndetic triple opener (rhythm-adjacent; examples are content, so borderline) | Acceptable; or "Submitting a review, voting: many outcomes are binary". |
| C-17 | 01-...qmd (line 230) | "with coefficients you can estimate, interpret, and be proven wrong about" | Triple (rhythm-adjacent; echoes ch. 2's "precise enough to estimate and precise enough to be wrong") | Optional: "with coefficients you can estimate and be proven wrong about". |
| C-18 | 04/05-...qmd | (whole chapters) | Voice drift: chapters 4 and 5 contain no first-person singular; profile calls for "I" used freely (chs. 1–3 have it) | Add one natural "I" moment per chapter, e.g. in ch. 4's fixed/random advice or ch. 5's Breiman passage. |
| C-19 | 04-...qmd (line 195) | "This is not a flaw." | Near the "not X" ban, but it negates a belief the reader plausibly holds (bigger SE = worse), which Pinker sanctions as staged negation | Leave as is; listed for completeness. |

## Top 10 most important fixes

1. Purge the "honest/honesty" tic: nine occurrences across four chapters (A-1 to A-9), including two exact "the honest X" hits (01:208, 05:109).
2. Rewrite the five clearest "X is not Y. It is Z" constructions: 01:92, 03:177, 04:66, 05:67, and 03:56 (A-10, A-12 to A-15).
3. Delete "The ζ terms are not an apology." (02:48): banned rhetoric plus negation of a claim no reader held (A-11).
4. De-italicize the four-italic paragraph in ch. 5 (umbrella/rain-dance, line 27) and the paired-italic paragraphs in ch. 1 (lines 188, 192) (A-18, A-19, A-22).
5. Cut the rhythm triples in ch. 4's opener and ch. 5 (two in one paragraph at line 13) (A-23 to A-25).
6. Split the center-heavy LISS-vs-registers sentence in ch. 5 (line 55) into two sentences (B-6).
7. Semicolon the comma-riddled threat list in ch. 1 (line 137) (B-3).
8. Gloss on first use: "dummy" (02:151), "logit" (02:161), AIC (04:195), F1 (05:55) (B-8 to B-11).
9. Give external validity its concrete example in ch. 1 (line 90), matching the other three validity families (B-4).
10. Narrate the ggplot pipeline in ch. 4 (lines 136–148), the only substantial un-narrated code in the book (B-12).
