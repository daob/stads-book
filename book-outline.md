# Statistics and Data Analysis: a broad perspective for social and health scientists

## Preface

This is an outline for a book. This book is initially intended mainly for students in the course "Statistics and Data Analysis: a broad perspective", in the Research Master https://www.uu.nl/en/masters/methodology-and-statistics-behavioural-biomedical-and-social-sciences. The purpose of my course is to introduce students to the other courses in their master's from "broad perspective". These topics will then be covered more in-depth in those other courses. The topics they will encounter are: 
 - Bayesian statistics (particularly how to model things in stan, what are the advantages)
 - Causal inference (potential outcomes, something baout impact research and econometric designs)
 - Machine learning (general ML course in which they will learn to use R/python to predict things and pick the best model using cross-validation etc.)
 - "Fundamentals of statistics" - this is a more mathematically oriented course about mathematical statistics, point estimation, sampling distributions, consistency, bias, etc.
 - Statistical programming in R
 - Sampling estimation and inference (this is mostly about complex sampling adjustments and designs in surveys and a little bit about other approaches for nonprobability samples such as multiple imputaiton, weighting, mr.P etc.)
 - "Processing complex data" (this is a hands-on course on how to deal with difficult data types such as location data, text, images, etc.
 - Multilevel modeling (a classic social science-type course about multilevel modeling (random effects))
 - Structural equation modeling (more mainstream SEM course)
 - Psychometrics (classical test theory, IRT)
 - Introduction to biomedical statistics (mostly about GLM, survival, and a little bit about administrative data in hospital records). 
But it is ultimately intended to be of much broader interest. So this specific course and the other courses in the Master should not be mentioned. It is there for your background information.

Throughout, examples should be taken from both the social and health sciences. This includes but is not limited to, psychology, economics, epidemiology, clinical data science, sociology, political science, computational social science. Prefer examples that are impactful and interesting, or were published in high-impact journals, made the news, use modern data sources and techniques, and/or are recent. It is okay to refer to classical examples if they are more illustrative or appropriate for some reason. Try to vary the examples so it is interesting to an audiene consisting of a mix of backgrounds from these different fields.

The setup of the book should be as follows: the different topics are discussed in short chapters. Each chapter contains inline exercises that help the reader digest the material. These exercises can be practical (doing something in software such as R or Python) or more theoretical (answering a question, working something out on "paper"). The electronic version of the book should allow the reader to reveal the answers immediately. At the end of each chapter should follow more challenging exercises which are intended to test the reader's knowledge. In the context of the course, these exercises should be as similar as possible to exam questions (only perhaps slightly harder).  The chapters should be concise and not verbose.Avoid LLM-isms: overuse of em-dashes, using italics to explain everything, "it's not a x, it's a y"-type facetious language, talking about "the honest xyz", and the obsession with making all lists lists of three (it's okay to have three things if there really are three!). 

Note that old-exams will contain some relevant questions, but is not 1-1 mappable to the new course, as these are materials for an older version of the course. Where relevant you can try to work some of these questions into the main text (or harder versions at the end of the chapter). The exercises and exam questions, where relevant, should also be used to determine the content of the chapter. For example, if there is an exam question that asks people to derive an implied correlation from a model then the chapter should explain how to do this; or, if there is a question applying fixed and random effects models to a meta-analysis then the chapter should explain these models in sufficient detail.

The style of the book should be relatively informal. Avoid too-familiar colloquialisms as well as highly technical jargon. Most of the book should be understandable by a smart person with little to no background knowledge.  It should explain the key points in clear language. Apply the concepts laid out in Steven Pinker's book _Sense of Style_: After each paragraph, you should consider the cognitive load on the reader. Minimize it by improving sentence structure to follow Pinker's guidelines. Then consider the internal consistency of the paragraph and whether the move from one sentence to the next puts an unnecessary cognitive burden on the reader, for example by having sentences that use reference words to refer to concepts in earlier sentences or by burying the main point in later sentences. Employ "classic style" (the window onto the world). You can find a copy of this book under literature/.

I would like it to be very clear from the git commit logs what I have written myself and what has been gnerated by LLM. 

The product should ultimately be (1) a website I can host somewhere and (2) a PDF people can print on demand. The font family should be Fira (Sans for text, code for code). Both the website and the PDF version should be written into a local directory inside stads-book/ directory.


## 1. From research question to interpretation

The idea behind this chapter is to explain at a "high level" how research questions are translated into research designs + statistical analyses. The research design (data collection, purposeful or not) together which the research question motivates the statistical analysis. The analysis can be viewed as based on a model, defined as a set of assumptions that are made plausible by the research design. The purpose of a research design is to make the assumptions of the model plausible. For example, a randomized experiment is done to make the assumption of no confounders plausible; a random sample is drawn to make the assumption of sampling from a population plausible. The same goes for matched case-control studies (but it's less convincing): if you believe the matching has done its job, though, a simple analysis answers the research question. If you're worried about history bias, you can further include a pre-post measurement (DiD in econometrics). Give further examples and follow the line set out in Shadish, Cook & Campbell (see literature): briefly explain all threats to validity and then use illustrations (nicer versions of the old-timey SCC notations such as OXO) of the designs that remove these threats and also give a regression equation that can be used to analyse that design, under the assumptions. This is great but it is not entirely general and we will not use it for the entire book but the way of thinking remains valid: the design is there to make the assumptions plausible and under these assumptions the model outcomes say something about the research question. 
 The results of the anslysis are then supposed to say something about the orginal reearch question(s), provided the assumptions hold. Sometimes we make up research questions after we already have a design and an analysis; this is called exploratory research. Exploratory research is not bad, pretending that it is confirmatory can be (because it invalidates the assumptions). Some examples of designs are: the RCT, the cross-over experiment, two-group pre/post (DiD), etc. etc. Some examples of models are linear regression, logistic regression, ANOVA, random forests, transformers, Gaussian process, hidden markov model, factor analysis, IRT, etc. etc. (try to mention things that will be discussed in the rest of coursework within the master (new version as of 2026), without mentioning this reason, to keep it general.)

So our job as methodologists includes: 
 - coming up with interesting RQs
 - evaluating designs avilable to us (data available) in terms of the assumptions they warrant
 - collecting new data or suggesting new designs to do so if the assumptions we need aren't met
 - analysing the resulting measurments based on assumptions ('modeling'), including looking at point estimates and uncertainty 
 - evaluating hwo the inevitable violation of assumptions might affect our conclusions

Readers should, for a given study:
 - be able to identify research questions, even when they're not explictly stated
 - be able to identify or infer, from a verbal theory: the "unit of analysis", the variables, the associations, the causal relationships
 - same for research designs and models
 - be able for a given study to explain exactly how the design and model combine into an answer to the research question
 - point out which assumptions went into that mapping 
 - elaborate on the extent to which the design does or does not warrant those assumptions
 - Be able to complete exercises such as the first part questions 1-6 of "weeks/Exercise week 1.docx"
 - More examples of exercises: 
    - "old-exams/Midterm exam ReMa Multivariate 2.docx": Question 1
    - "old-exams/Midterm exam ReMa Multivariate-example.docx": Question 1
    - "old-exams/Midterm exam ReMa Multivariate-resit-2025 2.docx": Question 1a-c

## 2. From research question to interpretation: (generalized) linear models for observational studies

The idea behind this chapter is very strongly based on the old book by Saris & Stronkhorst. The idea is that, step by step, we go from a verbal theory to a specific model that is supposed to encode that theory, and which can be estimated and tested. Just as in Saris & Stronkhorst, we choose linear models for all equations, but in addition we allow GLM models, specifically adding in logistic regression. So the chapter should achieve two things: 
    1. it should demonstrate how, step by step, we can move from a theory to a (linear) model in practice, and then the results of estimating this model say something about the world (_if_ the model is true!!! - emphasis) and tests say something about the theory (within limits that are discussed later in the chapter on identification). 
    2. It should, very naturally, (re)introduce the reader to linear regresssion and how to interpret its coefficients (a one unit increase in x, leads to a b unit increase in y), as well as logistic regression and its more difficult interpretation (a 1 unit increase in x leads to a b unit increase in the log-odds of y, explain log-odds; explain the exp(b) rule-of-thumb for odds percentage increase; explain how probabilities are calculated). 
Do not copy the example from S&S but use something more recent (and more interesting!), preferably from a high impact journal. The example should be from social science or health research, or, if you find occasion to use more examples, both.

Many reader will feel uneasy that we're not discussing nonparametric modeling here. Or agent-based models, which don't even specify equations at all. Those are  nice ideas, about which there is a mostly separate literature. The basic principles of this literature (design+model-> research question, under assumptions) is the same. But it is more difficult to see that due to all the math and computaitonal violence. Also very often especially in smaller samples linear is all the data allow anyway. So that is why I am just talking about GLM here. But in larger samples and problems that require lots of nonlinearities and interactions you should know there are other methods (even though they operate on the same principles).


Readers should (see Saris & Stronkhorst):

 - Be able to distill precise statements about relationships from a given verbal theory, 
 - convert these statements correctly into linear equations, including the error term
 - Be able to derive implied correlations from a path diagram based on the tracing rules
 - Calculate a probability for given values of x from a logistic model output
 - Same for linear model Y values
 - Give the correct interpretations for regression coefficients
 - Be able to complete exercises such as the one found in "weeks/Exercise week 1.docx"
 - More examples of exercises: 
    - "old-exams/Midterm exam ReMa Multivariate 2.docx": Question 2
    - "old-exams/Midterm exam ReMa Multivariate 2.docx": Question 3
    - "old-exams/Midterm exam ReMa Multivariate-example.docx": Question 2
    - "old-exams/Midterm exam ReMa Multivariate-example.docx": Question 3
    - "old-exams/Midterm exam ReMa Multivariate-resit-2025 2.docx": Question 1d-g
    - "old-exams/Midterm exam ReMa Multivariate.docx": Question 3. Note: student performance on this type of question was always low. Ensure the explanation in the chapter is sufficient to answer such questions. Perhaps include some easier inline exercises that take the reader through the calculations step by step.

## 3. The design limits the research questions (a.k.a. "identification") - using mediation as a case study

This chapter should discuss mediation. But in actuality mediation is just intended to be an excuse to talk about identification in statistics in general (and SEM in particular). Do not put any emphasis on explaining Baron-Kenny but keep the explanation within the context of the previous chapters. First we introduce mediation as an idea and show the model. Then we remember that there is a design and there are some assumptions. In the case of mediation that is no A-M confounding, no M-Y confounding, and correct causal order. Now we do an exercise where the reader fits a mediation model with arrows running in the opposite direction to the same data, so they can see that the model fit remains identical. They are challenged to explain why this is (the implied correlations they learned to calculate in the previous chapter are the same). So the direction is not identified. Sometimes X is an experiment and then X->M is believable but that does not mean we're out of the woods with M->Y.  Also if there is a hidden confounder the model can give a completely wrong answer (this should be experienced as well and then explained again afterwards). Finally an interesting fact can be noticed: if there is no direct effect X->Y then the error correlation M<->Y is identifiable so we do not need to assume no MY confounding anymore. But we can't test the absence of X->Y so we traded "no MY confoudning" for "no x->Y effect". Also if you work out the solution X->M has to be not too close to zero. In this case X is called the "instrumental variable" because you're really not that interested in X bu you're using it to estimate the effect M->Y without assuming no confounding. When is this the case? Well for example in an enouragement design, or <insert a few good examples from social and health sciences here. Include Mendelian Randomizatiuon> Also briefly discuss some of the criticisms of the aopplications of IV in economics and social science and MR in health, as well as some of the criticisms of mediation especially in psychology.

Readers should:

 - Be able to turn a research question about mediation into an analysis
 - Articulate the assumptions and the limitations of such an analysis in terms of what its results say bout the research question given the design
 - Explain instrumental variables
 - Be able to calculate direct, indirect, and total effects in a path model based on the tracing rules
 - Understand which research designs warrant IV analysis and which do not (bad IVs)
 - Further examples of exercises:
    - "old-exams/Midterm exam ReMa Multivariate-resit-2025 2.docx": Question 1h-i

You can look in week-5 for further inspiration on what to cover in this chapter, given that most of the basics are already covered in earlier chapters: slides-week-5.pdf is my usual talk, with the mediation-moderator.pdf slides used to talk about the dreaded distinction between "mediated moderation" and "moderated mediation" - which is just interprational but some people make a big deal out of. Also I'm not a big fan of introducing "moderation" and "mediation" together because in my opinion they have absolutely nothing to do with each other and this is just done to confuse students and because it is traditional. So I'd rather not mention moderation too explicitly in this chapter. Another pet peeve of mine is that I don't understand why psychologists are so obsessed with talking about bootstrapping in the context of mediation. Again they have nothing to with each other per se, and the Delta method standard errors you get from lavaan are perfectly fine. Of course bootstrapped se's are also fine, but I don't want to make it a big deal (this is illustrated in week-5-exercise-pval.R). I usually gave students literature/mediation-mackinnon-nihms173361.pdf to read. It may also be fun to refer to more nonparametric-based/epi approaches in vanderweele-mediation-annurev-publhealth-032315-021402.pdf and mediation-package-R-v59i05.pdf. This is good to show that even though mediation is "just" a SEM, when you include nonlinearity, categorical etc etc it becomes more complex and there are specialized approaches. Some analyses in the chapter could be done using mediation package to illustrate. These latter two papers will be interesting for a few students, and it is good to define NIE and NDE since these are workhorses in this literature. But both of these are expected to be too difficult for most, so the chapter should not be based on them.

## 4. ANOVA is still cool!

ANOVA sounds old fashioned and it is. But if you take it to mean the idea of grouping coefficients in a (generalized) linear model it becomes a highly relevant and powerful idea. It includes fixed effects and random effects models. This is the explanation based on literature/gelman-hill-ch22.pdf and literature/gelman-anova.pdf. But the latter paper proved to be much too complicated for students, while struck the right balance. Even so, it was still found difficult by some students, but that is okay.  

In the course, I have usually discussed students' questions about Gelman & Hill's chapter and talked them through the old-course/week-3/anova.html (or ANOVA-exercise-answer.pdf). The ideas are that they see for themselves, ideally by doing, that:
 - ANOVA is just regression (lm and aov fits give the same results to some extent but aov groups the coefficients in a convenient way)
 - If you have many coefficients, a random (here Gaussian) distribution on them may make sense. This is illustrated using lmer and the Bayesian version in brm
 - In this case the target parameters are the standard deviations (or variances) of the coefficients

They should be able to: 
 - interpret the sums/means of squares in ordinary ANOVA
 - understand the classical mathematical derivation in which we group-center observations and split variance into within and between
 - write down a simple random effects (multilevel) model
 - explain when random versus "fixed" effects is more appropriate, and what the difference is
 - interpret the "ANOVA displays" advised by Gelman & Hill (beware that the figures are missing legends!)
 - do exercises such as:
    - "old-course/old-exams/Midterm exam ReMa Multivariate-resit.docx": Question 3 (BCG)

## 5. Explanation and prediction


Relevant literature for this chapter is in literature/explanation-prediction. When I refer to literature below, look for it there.

This chapter is intended to form a slight alleviation from the technical work as well as a "caesuur" between the previous chapters which were about explanatory models in which the parameters, or functions of them (such as the product or NIE in mediation or sums of squares/Bayesian sd density plots) were of direct scientific interest, and the next few chapters, which are about prediction models. Prediction models used to have a very bad rap in much of social and health sciences but are now accepted to be useful in their own right. First the chapter should discuss what we mean by prediction (a statement about future data). It has relevance to social and health science in two ways. First, biological or social models give "predictions" about aggregate phenomena which can be comared against measures of those phenomena to "test" the model (this is the King, Keohane & Verba eplxnation of social research). FOr example, This can be fund many times in Coleman, SOcial Theory. Or you can take an example from Smaldino Modeling Social Behavior: for example the SIR model predicts a certain trend in contagion which doesn't exactly bear out for some epidemics so we need to make the model more sophisticated; the DeGroot model of opiion dynamics predicts that everybody converges to a consensus. Since this is not true, the model is false. In this sense everything we've seen before about SEM is also a form of predictions about correlations (or conditional dependencies). There is a second meaning of prediction, though: predicting specific outcomes of interest, just because having a (uncertain) prediction is better than not having one. The difference between these is disucssed in Breiman, the two cultures, and in Schmueli, ExplainPredict. And the interplay between this and more thoeyr based research is discussed in Tukey- data analysis, as well as in the three papers by Watts and his colleagues (TECSS Group 1.pdf, science.aal3856 (1).pdf, s41586-021-03659-0 (1).pdf). These papers are important and their arguments should be (briefly) explained. The arguments for looking at prediction in those papers and the ones by Mark Verhagen (verhagen-2022-a-pragmatist-s-guide-to-using-prediction-in-the-social-sciences.pdf) and Yarkoni & Westfall (yarkoni-westfall-2017-choosing-prediction-over-explanation-in-psychology-lessons-from-machine-learning.pdf) should also be discussed in some detail. 

A case in point this is not specifically social & health but affects it all the same is large language models. In the before-fore, people were trying to make very precise formal models of natural language and this got us some of the way. Just as in social an health sciences, the idea to just do statistics and an predictions on natural language was already there for a long time (Chicago school; work of Jean-Paul Benzécri in the 70s). But many dismissed this because such work was thought to not be useful for practical applications: people thought you would need the know the why in order to make good use of language models. Then came text mining, embeddings, transformers, and LLMs: the bitter lesson. We now have purely predictive models because LLMs "only" predict the next word. But with these predictive models we can do a lot of very useful things. (Then Summarize the literature found in llm-social-science/ to illustrate what LLMs could do in social and health science).

Next, the chapter should discuss two examples of large-scale prediction projects in some detail: the fragile families challenge (salganik-et-al-2020-measuring-the-predictability-of-life-outcomes-with-a-scientific-mass-collaboration.pdf) and PreFer (sivak-prefer.pdf, see also: https://stulp.gmw.rug.nl/prefer/). Both of these should receive equal attention/space and the chapter should explain what they did exactly and what we can learn from it. 

Finally A few examples of succesful (economics in the 1980s/1990s made a turn from "structural" modeling we have been discussing to pure prediction using time series models such as VAR, which turned out to be much better predictive models and led to a Nobel prize. Ironically now they are heading back to causal modeling with movements like Angrist &PIschke and the Pearl-style causal modeling crowd) and unsuccesful (google flu trends) prediction models in health(care) and social research should be given. The chapter should then prepare the reader for the upcoming chapters on supervised and unsupervised machine learning.

Here is a structured book chapter outline based on the provided material, integrating the historical evolution, philosophical rationale, practical utility, and empirical applications of prediction in the social and health sciences.

--- START EXPERIMENTAL CHAPTER OUTLINE

    # Chapter Title: Prediction in the Social and Health Sciences: Bridging Explanation, Forecasting, and Empirical Rigor

    ## Chapter Overview & Learning Objectives

    * **Overview:** This chapter explores the historical divergence between causal explanation and predictive modeling in the social and health sciences, demonstrating how re-centering predictive power enhances theoretical validity, policy decision-making, and empirical precision.
    * **Objectives:**
    1. Understand the historical context and recent resurgence of predictive paradigms.
    2. Differentiate between explanatory modeling, pure forecasting, and predictive validation.
    3. Evaluate the scientific benefits of insisting on predictive power and out-of-sample testing.
    4. Analyze why imperfect, non-causal models remain highly actionable.
    5. Examine real-world applications and the empirical limits of predictability in human and health systems.



    ---

    ## I. Historical Context: The Division of Explanation and Prediction

    * **A. Prediction as a Scientific Cornerstone**
    * Falsifiability, hypothesis generation, and Richard Feynman’s principle: theory must match empirical observation.
    * Historical success of prediction-driven explanation in the physical sciences.


    * **B. The Social & Health Sciences' Explanatory Pivot**
    * De-emphasis of prediction in favor of interpretable causal mechanisms and parameter estimation.
    * The rise of Null Hypothesis Significance Testing (NHST): over-reliance on $p$-values, statistical significance, and in-sample model fit ($R^2$) over predictive accuracy.


    * **C. The Modern Resurgence of Prediction**
    * *Data Explosion:* Availability of high-dimensional, rich datasets.
    * *Methodological Advances:* Machine learning and algorithmic approaches optimized for out-of-sample performance.
    * *The Replication Crisis:* Realization that statistically significant in-sample relationships frequently fail to generalize to unseen data.



    ---

    ## II. The Scientific Case for Predictive Power

    * **A. Grounding Theories in Empirical Reality**
    * Evaluating theories via out-of-sample generalization rather than in-sample optimization.
    * Overcoming the limitations of NHST: Moving beyond testing against a "null" to benchmarking actual explanatory power.


    * **B. The Common Task Framework (CTF) and Benchmarking**
    * Borrowing machine learning paradigms to advance social and health sciences.
    * Standardized metrics (RMSE, MAE, AUC, Precision/Recall, $F_1$, and Effect Sizes/Cohen's $d$) for objective model comparison.


    * **C. Pragmatic Virtues of Predictive Workflows**
    * Assessing individual predictive fit, subgroup variations, and severe model misspecifications.
    * Benchmarking simple parametric models against flexible, non-linear machine learning architectures.



    ---

    ## III. The Value of Imperfect and Non-Causal Predictive Models

    * **A. "Pure Forecasting" vs. "Pure Causation" Problems**
    * The Kleinberg et al. / Mullainathan & Spiess framework: Decision payoff functions where prediction of outcome $Y$ suffices without manipulating cause $X$.
    * *Analogy:* Carrying an umbrella based on rain predictions vs. performing a rain dance to alter the weather.


    * **B. Practical Policy and Clinical Applications**
    * Judicial bail decisions, targeting poverty relief, identifying high-risk youth behaviors, and early detection of disease trajectories.


    * **C. Why Imperfect Models Work**
    * The Bias-Variance Tradeoff: How a non-causal, parsimonious model can out-predict a theoretically "true" causal model that suffers from estimation variance.
    * Using available data and subject-matter heuristics when full causal mechanisms are unobservable or data are noisy.



    ---

    ## IV. The Synergy: Prediction and Causal Explanation Hand-in-Hand

    * **A. Causal Claims Inherent Prediction**
    * Counterfactuals and interventions: Saying "X causes Y" inherently predicts that altering X will change Y in unseen contexts.
    * Holding causal theories accountable to their implicit predictive claims.


    * **B. Joint Optimization in Decision-Making**
    * Combining risk prediction with causal effect estimation to maximize the marginal impact of policy/clinical interventions.


    * **C. Iterative Scientific Discovery**
    * Using predictive models to discover novel non-linearities, variable interactions, and generate robust hypotheses for future causal testing.



    ---

    ## V. Applications, Practical Limits, and Ethical Considerations

    * **A. Mass Collaborations and Limits of Predictability**
    * *Case Study:* The Fragile Families Challenge (Salganik et al.)—predicting complex life outcomes (eviction, material hardship) using rich longitudinal data.
    * *Finding:* Advanced ML algorithms only slightly outperformed simple benchmarks, highlighting inherent upper limits on predictability.


    * **B. Structural Constraints on Predictability**
    * System complexity, stochasticity, noise, measurement error, and unobserved variables.
    * *Performativity and Lucas Critique:* How human systems react to and alter predictions once published or enacted.


    * **C. Algorithmic Bias and Policy Responsibility**
    * Ensuring predictions reflect meaningful outcomes rather than proxy biases.
    * Combining predictive alerts with human oversight in policy and medical domains.



    ---

    ## Chapter Summary & Discussion Questions

    * **Summary:** Recapitulation of how integrating predictive accuracy elevates causal research, optimizes policy resource allocation, and establishes realistic limits on understanding human systems.

--- END EXPERIMENTAL CHAPTER OUTLINE


## Supervised machine learning: overfitting and bias-variance tradeoff

## Supervised machine learning: evaluation, bootstrapping, resampling

## Unsupervised learning: clustering, model selection


