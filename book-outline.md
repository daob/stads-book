# Statistics and Data Analysis: a broad perspective for social and health scientists

## Preface

This is an outline for a book. This book is initially intended mainly for students in the course "Statistics and Data Analysis: a broad perspective", in the Research Master https://www.uu.nl/en/masters/methodology-and-statistics-behavioural-biomedical-and-social-sciences. But it is ultimately intended to be of much broader interest. So this specific course should not be mentioned. 

The setup of the book should be as follows: the different topics are discussed in short chapters. Each chapter contains inline exercises that help the reader digest the material. These exercises can be practical (doing something in software such as R or Python) or more theoretical (answering a question, working something out on "paper"). The electronic version of the book should allow the reader to reveal the answers immediately. At the end of each chapter should follow more challenging exercises which are intended to test the reader's knowledge. In the context of the course, these exercises should be as similar as possible to exam questions (only perhaps slightly harder).  The chapters should be concise and not verbose. It should explain the key points in clear language. Think about applying Strunk and White, but to the concepts as well as the sentences.

Note that old-exams will contain some relevant questions, but is not 1-1 mappable to the new course, as these are materials for an older version of the course.

The style of the book should be relatively informal. Avoid too-familiar colloquialisms as well as highly technical jargon. Most of the book should be understandable by a smart person with little to no background knowledge. For an impression of the desired style, see my book chapter on LCA (under "literature").

I would like it to be very clear from the git commit logs what I have written myself and what has been gnerated by LLM. 

## From research question to interpretation

The idea behind this chapter is to explain at a "high level" how research questions are translated into research designs + statistical analyses. The research design (data collection, purposeful or not) together which the research question motivates the statistical analysis. The analysis can be viewed as based on a model, defined as a set of assumptions that are made plausible by the research design. The purpose of a research design is to make the assumptions of the model plausible. For example, a randomized experiment is done to make the assumption of no confounders plausible; a random sample is drawn to make the assumption of sampling from a population plausible. Give further examples and follow the line set out in Shadish, Cook & Campbell (see literature). The results of the anslysis are then supposed to say something about the orginal reearch question(s), provided the assumptions hold. Sometimes we make up research questions after we already have a design and an analysis; this is called exploratory research. Exploratory research is not bad, pretending that it is confirmatory can be (because it invalidates the assumptions). Some examples of designs are: the RCT, the cross-over experiment, two-group pre/post (DiD), etc. etc. Some examples of models are linear regression, logistic regression, ANOVA, random forests, transformers, Gaussian process, hidden markov model, factor analysis, IRT, etc. etc. (try to mention things that will be discussed in the rest of coursework within the master (new version as of 2026), without mentioning this reason to keep it general.)

Readers should, for a given study:
 - be able to identify research questions, even when they're not explictly stated
 - same for research designs and models
 - be able for a given study to explain exactly how the design and model combine into an answer to the research question
 - point out which assumptions went into that mapping 
 - elaborate on the extent to which the design does or does not warrant those assumptions

## From research question to interpretation: (generalized) linear models for observational studies

The idea behind this chapter is very strongly based on the old book by Saris & Stronkhorst. The idea is that, step by step, we go from a verbal theory to a specific model that is supposed to encode that theory, and which can be estimated and tested. Just as in Saris & Stronkhorst, we choose linear models for all equations, but in addition we allow GLM models, specifically adding in logistic regression. So the chapter should achieve two things: 
    1. it should demonstrate how, step by step, we can move from a theory to a (linear) model in practice, and then the results of estimating this model say something about the world (_if_ the model is true!!! - emphasis) and tests say something about the theory (within limits that are discussed later in the chapter on identification). 
    2. It should, very naturally, (re)introduce the reader to linear regresssion and how to interpret its coefficients (a one unit increase in x, leads to a b unit increase in y), as well as logistic regression and its more difficult interpretation (a 1 unit increase in x leads to a b unit increase in the log-odds of y, explain log-odds; explain the exp(b) rule-of-thumb for odds percentage increase; explain how probabilities are calculated). 

Many reader will feel uneasy that we're not discussing nonparametric modeling here. That is a nice idea, about which there is a mostly separate literature. The basic principles of this literature (design+model-> research question, under assumptions) is the same. But it is more difficult to see that due to all the math and computaitonal violence. Also very often especially in smaller samples linear is all the data allow anyway. So that is why I am just talking about GLM here. But in larger samples and problems that require lots of nonlinearities and interactions you should know there are other methods (even though they operate on the same principles).


Readers should (see Saris & Stronkhorst):

 - Be able to distill precise statements about relationships from a given verbal theory, 
 - convert these statements correctly into linear equations, including the error term
 - Be able to derive implied correlations from a path diagram based on the tracing rules
 - Calculate a probability for given values of x from a logistic model output
 - Same for linear model Y values
 - Give the correct interpretations for regression coefficients

## The design limits the research questions (a.k.a. "identification") - using mediation as a case study

This chapter should discuss mediation. But in actuality mediation is just intended to be an excuse to talk about identification in statistics in general (and SEM in particular). Do not put any emphasis on explaining Baron-Kenny but keep the explanation within the context of the previous chapters. First we introduce mediation as an idea and show the model. Then we remember that there is a design and there are some assumptions. In the case of mediation that is no A-M confounding, no M-Y confounding, and correct causal order. Now we do an exercise where the reader fits a mediation model with arrows running in the opposite direction to the same data, so they can see that the model fit remains identical. They are challenged to explain why this is (the implied correlations they learned to calculate in the previous chapter are the same). So the direction is not identified. Sometimes X is an experiment and then X->M is believable but that does not mean we're out of the woods with M->Y.  Also if there is a hidden confounder the model can give a completely wrong answer (this should be experienced as well and then explained again afterwards). Finally an interesting fact can be noticed: if there is no direct effect X->Y then the error correlation M<->Y is identifiable so we do not need to assume no MY confounding anymore. But we can't test the absence of X->Y so we traded "no MY confoudning" for "no x->Y effect". Also if you work out the solution X->M has to be not too close to zero. In this case X is called the "instrumental variable" because you're really not that interested in X bu you're using it to estimate the effect M->Y without assuming no confounding. When is this the case? Well for example in an enouragement design, or <insert a few good examples from social and health sciences here. Include Mendelian Randomizatiuon> Also briefly discuss some of the criticisms of the aopplications of IV in economics and social science and MR in health, as well as some of the criticisms of mediation especially in psychology.


Readers should:

 - Be able to turn a research question about mediation into an analysis
 - Articulate the assumptions and the limitations of such an analysis in terms of what its results say bout the research question given the design
 - Explain instrumental variables
 - Be able to calculate direct, indirect, and total effects in a path model based on the tracing rules
 - Understand which research designs warrant IV analysis and which do not (bad IVs)

## ANOVA!

ANOVA sounds old fashioned and it is. But if you take it to mean the idea of grouping coefficients in a (generalized) linear model it becomes a highly relevant and powerful idea. It includes fixed effects and random effects models. 
