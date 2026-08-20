# The chapter 2 model in LISS wave 18: report

*Prepared for internal use; nothing here is chapter text yet. Scripts:
`01-prepare-liss.R` (data), `02-fit-liss-sem.R` (models); full lavaan output
in `liss-sem-output.txt`; combined data in
`data/liss-health-social-integration/liss_ch2_combined.{rds,csv}`.*

## Data

Three LISS files were combined on the encrypted respondent number: the wave-18
Health module (`ch25r`, fieldwork November–December 2025), the wave-18 Social
Integration and Leisure module (`cs25r`, October–November 2025), and the
January 2025 background variables (`avars`). 4,240 respondents answered both
modules; restricting to adults (18+) leaves **N = 4,158**, of whom 4,128 are
complete on the model variables. The two modules are nearly contemporaneous,
so measurement timing gives the causal order no real support here, unlike in
Yang et al.'s four-cohort design.

## Variables and how they were built

**Social integration** (S) is the count, 0–15, of the suggested organizational
involvement items: membership of eleven types of voluntary organization plus
voluntary work for four of them (sports, cultural, trade union, religious).
All items are coded 0/1 in the file and are clean; respondents missing any
item (a handful) were set to missing rather than given a deflated count. The
index is strongly right-skewed: mean 1.22, sd 1.39, 39 percent score 0. A
contact-frequency variable (evenings with family, neighbours, friends;
"don't know" = 8 and "not applicable" = 9 recoded to missing by hand) is in
the combined file for later use but not in the model.

**Blood pressure** (B) is ever-diagnosed hypertension (`ch25r082`, 0/1;
16.4 percent yes).

**Central adiposity** (A) is BMI from self-reported height and weight. These
two items required hand-cleaning: the codebook defines them as free integers
(1–300 cm, 1–1000 kg) with **no declared missing code**, so entry errors such
as 17 cm and 999 kg arrive as data. Heights outside 120–220 cm, weights
outside 35–250 kg, and BMI outside 14–60 were set to missing (21 cases lost).
Mean BMI 26.1, sd 4.7.

**Chronic disease burden** (the outcome, standing in for death, which a
running panel cannot observe) is the count of thirteen ever-diagnosed
conditions from the physician-diagnosis battery: angina, heart attack, high
cholesterol, stroke, diabetes, chronic lung disease, asthma,
arthritis/osteoporosis, cancer, ulcer, Parkinson's, dementia, other.
**Hypertension is excluded from the count** because it is a predictor in the
model. Mean 0.70, sd 1.01.

**Inflammation is not measured in LISS** (no serum biomarkers), so the
theory's three physiological states shrink to two here.

The background file needed its own missing-value repair: negative codes
(−13, −14, −15, −99) for "unknown" and "prefer not to say" survive as values
in the `.dta` and were recoded by hand. So the instruction to double-check
was warranted three times over: height/weight entry errors, the 8/9 codes on
the contact items, and the negative codes in `avars`.

## Observed correlations

|              | integr. | hypert. | BMI   | disease |
|--------------|--------:|--------:|------:|--------:|
| integration  |   1     | −.011   | −.059 |  −.008  |
| hypertension |         |  1      |  .155 |   .316  |
| BMI          |         |         |  1    |   .142  |
| disease      |         |         |       |   1     |

## Model 1: the chapter's final model

As in the chapter: S affects B and A; B and A affect disease; the
disturbances of B and A covary; **no direct path from S to disease**. Six
correlations, five parameters, one degree of freedom, spent entirely on that
exclusion. Estimated by ML with robust (sandwich) standard errors and FIML
for the scattered item missingness.

| Parameter | Estimate (raw) | Std. | z | p |
|---|---:|---:|---:|---:|
| a₂ integration → hypertension | −0.003 | −.011 | −0.70 | .49 |
| a₃ integration → BMI | −0.201 | −.059 | −3.97 | <.001 |
| c₂′ hypertension → disease | 0.820 | .301 | 16.02 | <.001 |
| c₃′ BMI → disease | 0.020 | .095 | 6.39 | <.001 |
| ψ hypertension ~~ BMI | 0.270 | .154 | 9.18 | <.001 |

**Test of the overidentifying restriction:** χ²(1) = 0.004, p = .95 (robust
and standard agree). Freeing the direct path (Model 2, saturated) estimates
it at 0.001 (std .001, p = .95). The data do not refuse the claim that
integration reaches disease only through the body.

## Model 3: age and gender added

Age is a common cause candidate the chapter warns about, and it behaves like
one: it correlates positively with organizational involvement (r = .07) and
strongly with hypertension and disease. Adjusting for age and gender:

| Parameter | Estimate (raw) | Std. | p |
|---|---:|---:|---:|
| a₂ integration → hypertension | −0.009 | −.033 | .023 |
| a₃ integration → BMI | −0.225 | −.066 | <.001 |
| c₂′ hypertension → disease | 0.639 | .234 | <.001 |
| c₃′ BMI → disease | 0.018 | .085 | <.001 |
| ψ | 0.221 | .133 | <.001 |

The integration–hypertension path was suppressed in Model 1: age pushes
involvement and hypertension the same way, so leaving it out biased a₂
toward zero. With age in the model, every structural path has the
theory-consistent sign. The exclusion still passes (χ²(1) = 0.97, p = .33).

## Reading, and cautions

Substantively, the pattern is a miniature of the theory with one honest
complication. Integration relates (weakly but in the protective direction)
to the body: about −0.07 sd of BMI per organizational involvement, and,
once age is held, slightly lower odds of hypertension. The body relates
strongly to disease. And the direct integration → disease path the theory
forbids is estimated at essentially zero, so the model's one testable claim
survives.

The cautions matter as much as the estimates.

1. **Passing the test is weak evidence here.** The marginal
   integration–disease correlation is −.008; there is almost nothing to
   mediate, so the exclusion test has little to refuse. This is the
   chapter's own warning: failure to reject is not proof, and a test
   without power says little.
2. **Internal validity is bought by assumption, not design.** Both modules
   are self-report, nearly simultaneous, and observational. Reverse
   causation (illness ends club membership) and omitted common causes
   (education, income; only age and gender were checked) are live. The
   Model 1 → Model 3 shift in a₂ is a demonstration-sized example of
   exactly that.
3. **Two variables strain the linear model.** Hypertension is binary and
   the disease count takes small integers; robust standard errors patch the
   heteroskedasticity, not the linearity. A GLM treatment (chapter 2's own
   second half) is the natural upgrade.
4. **Construct gaps.** Ever-diagnosed hypertension is not blood pressure
   (diagnosis requires contact with a doctor, which integration could
   itself affect), BMI is self-reported, and the disease count weights
   dementia equal to an ulcer.

