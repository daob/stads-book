# Statistics and Data Analysis

*A broad perspective for social and health scientists* — by [Daniel Oberski](https://daob.nl)

**Read it: <https://daob.github.io/stads-book/>** · [PDF](https://daob.github.io/stads-book/stads-book.pdf) · [EPUB](https://daob.github.io/stads-book/stads-book.epub)

[![Publish](https://github.com/daob/stads-book/actions/workflows/publish.yml/badge.svg)](https://github.com/daob/stads-book/actions/workflows/publish.yml)
[![Checks](https://github.com/daob/stads-book/actions/workflows/checks.yml/badge.svg)](https://github.com/daob/stads-book/actions/workflows/checks.yml)

Most statistics courses teach methods one at a time and leave the student with a
well-stocked toolbox and no manual. This book starts from the other end: a
research question motivates a design, the design makes assumptions plausible,
those assumptions are the model, and the model's results answer the question to
the extent that the assumptions hold. The chapters follow that logic from
research questions through linear and generalized linear models, identification
and mediation, ANOVA and multilevel models, and on into machine learning:
prediction versus explanation, overfitting and the bias-variance tradeoff,
honest evaluation, and unsupervised learning.

> **Draft 0.7.** Provisional throughout. The text was written with substantial
> help from a large language model, working from the author's outline, notes on
> the source literature, and chapter-by-chapter comments; the git history
> records which changes came from the author and which were generated.

## Repository layout

| Path | Contents |
|------|----------|
| `index.qmd`, `01-…qmd` … `08-…qmd` | the book: preface and eight chapters |
| `references.qmd`, `references.bib`, `apa.csl` | bibliography and citation style |
| `_quarto.yml`, `_quarto-answers.yml` | book configuration and the answers-in-back profile |
| `answers-in-back.lua` | Pandoc filter that moves exercise answers to an appendix |
| `_freeze/` | frozen chunk output, committed so CI can build without the microdata (see below) |
| `analysis/liss/` | R scripts that build the LISS analysis datasets ([README](analysis/README.md)) |
| `diagrams/` | Mermaid sources and R scripts for the path diagrams, with their PNGs |
| `figures/` | R scripts and source data for hand-built figures |
| `images/`, `fonts/` | static images; self-hosted Fira Sans and Fira Code |
| `tests/` | repository checks run locally and in CI ([README](tests/README.md)) |
| `.github/workflows/` | build, check, and publish automation |

## Building the book

Requirements: [Quarto](https://quarto.org) ≥ 1.4, R ≥ 4.2, and a LaTeX
distribution with the Fira fonts for the PDF (`quarto install tinytex` then
`tlmgr install fira`). Rendering the *text* needs nothing else, because chunk
output is frozen; re-running the analysis chunks additionally needs the R
packages listed in `tests/test-dependencies.R` and the LISS data described in
[`analysis/README.md`](analysis/README.md).

```sh
make html      # website into _book/
make pdf       # 6×9in print PDF
make epub      # EPUB
make answers   # PDF with all answers collected at the back
make all       # everything the site publishes
make editions  # A4 print, tablet-sized screen PDF, e-reader EPUB
make test      # repository checks (see tests/README.md)
make help      # the full target list
```

The alternative editions are driven by the profiles in `_quarto-a4.yml`,
`_quarto-screen.yml` and `_quarto-epub.yml`, which can be combined with the
answers-in-back profile (`quarto render --profile answers,a4 --to pdf`).

## Data

The book's running examples use the [LISS panel](https://www.lissdata.nl/), which
is free for researchers but **may not be redistributed**, so no microdata are in
this repository — and none ever have been; the `.gitignore` refuses the file
types outright. `analysis/liss/*.R` rebuild every derived dataset from the
original LISS files, which you download yourself. Everything else, including
every figure and number in the text, is reproducible without them thanks to the
committed `_freeze/` directory.

## How the website updates itself

Pushing to `main` triggers `.github/workflows/publish.yml`, which renders the
site, the PDF and the EPUB, and deploys them to GitHub Pages, download links
included. The workflow switches Pages on by itself the first time it runs
(`actions/configure-pages` with `enablement: true`), so there is nothing to
configure by hand — but GitHub only serves Pages from a **public** repository
unless the account has a paid plan. It needs no R packages and no data: chunk output is read from the
committed `_freeze/` directory, so a build takes minutes and cannot be broken by
a package update. Nothing needs to be built or committed by hand. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the details and for what to do when the
frozen output needs refreshing.

## Contributing

Corrections and suggestions are welcome as
[issues](https://github.com/daob/stads-book/issues) or pull requests; every page
of the book carries an "Edit this page" link that goes straight to its source.
[CONTRIBUTING.md](CONTRIBUTING.md) describes the build, the tests, and the
conventions.

## License

The text, figures and exercises are licensed
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/); the code
in `analysis/`, `diagrams/`, `figures/`, `tests/` and the build tooling is
licensed [MIT](LICENSE-CODE). See [LICENSE](LICENSE).

## Citation

```bibtex
@book{oberski_stads,
  author    = {Oberski, Daniel L.},
  title     = {Statistics and Data Analysis: A Broad Perspective for Social and Health Scientists},
  year      = {2026},
  note      = {Draft 0.7},
  url       = {https://daob.github.io/stads-book/}
}
```
