# Contributing

Thanks for reading closely enough to want to change something.

## Reporting a problem

Open an [issue](https://github.com/daob/stads-book/issues). For an error in the
text, the quickest route is the **"Edit this page"** link in the right-hand
margin of any page of the book: it opens the chapter's source at the right spot
and turns your change into a pull request.

## Getting set up

| Tool | Needed for | Notes |
|------|-----------|-------|
| [Quarto](https://quarto.org) ≥ 1.4 | everything | `quarto check` should pass |
| R ≥ 4.2 | re-running analysis chunks | not needed to render the text (see *Freezing* below) |
| LaTeX + Fira | the PDF | `quarto install tinytex` then `tlmgr install fira` |
| [`mermaid-cli`](https://github.com/mermaid-js/mermaid-cli) | rebuilding `diagrams/*.png` | only when a `.mmd` file changes |

R packages used by the analysis chunks are checked by
`Rscript tests/test-dependencies.R`, which lists anything missing.

## The build

```sh
make html      # website into _book/
make pdf       # 6×9in print PDF
make epub      # EPUB
make answers   # PDF with the answers collected at the back
make all       # everything, in the order CI uses
make diagrams  # regenerate diagrams/*.png from diagrams/*.mmd
make figures   # regenerate the R-drawn figures
make test      # repository checks
make clean     # remove build artefacts (keeps diagram PNGs)
```

## Freezing: why `_freeze/` is committed

The analysis chunks need the LISS microdata, which cannot be redistributed, and
a dozen R packages. To keep the book buildable by anyone — and by CI — the
rendered output of every chunk is committed in `_freeze/`. Quarto uses it
instead of re-running R, so `quarto render` works on a machine with no data and
no R packages at all.

CI installs Quarto, TinyTeX and base R — Quarto looks for the R engine before
it consults the freeze — but installs no R package and has no access to the
data.

The rule that follows: **whenever you change code inside a chunk, re-render
locally and commit the resulting `_freeze/` changes along with the source.**
`freeze: auto` re-executes only the documents whose code actually changed. Prose
edits never touch `_freeze/`. If a chapter's figures look stale, delete that
chapter's directory under `_freeze/` and render it again.

Each output format keeps its own frozen results — `html.json`, `tex.json` and
`epub.json` — so after changing a chunk run `make all`, not just `make html`, or
the other editions will be built from stale output. `tests/check_freeze.py`
fails the build when a chapter is missing one of the three.

## Tests

`make test` runs the checks in `tests/`: cross-references and citations resolve,
every exercise has an answer, no editing markers or microdata are left in the
tree, and the chapter list matches the files on disk. CI runs the same checks on
every push and pull request, then renders the book, so a failing render is
caught before it can reach the website. See [`tests/README.md`](tests/README.md).

## Style conventions

- **Prose**: normal academic register, no imperative openers, no metaphors that
  are dropped as soon as they are introduced, no exaggeration for effect.
- **Notation**: LISREL conventions (ξ, η, γ, β, ζ, ψ) for structural models,
  introduced in chapter 2 and kept consistent afterwards.
- **Exercises**: an inline `Exercise n.k` callout is always followed by a
  collapsible `Answer n.k`; end-of-chapter exercises use letters (`8.A`). The
  numbering is checked by `tests/test-exercises.R`.
- **Figures**: R-drawn figures use Fira Sans and the book's palette
  (`#ECECFF` fill, `#9370DB` stroke, `#7A28CB` accent); diagrams that are
  easier to express as graphs live in `diagrams/*.mmd`.
- **Comments in the source**: `<!-- DO: … -->` is an instruction to whoever
  next works on the chapter, `<!-- OPEN(who): … -->` a question that is
  genuinely open. Both are reported by `make test`; `TODO`, `FIXME` and `XXX`
  fail it.
- **Data**: never commit microdata. Derived datasets are rebuilt by the scripts
  in `analysis/liss/` and written outside the repository.

## Commit conventions

Commits are attributed to whoever wrote the change: the author's own edits under
his name, machine-generated changes under the assistant's, with a
`Co-Authored-By` trailer. Please keep that property when you push work that was
drafted for you by a tool.

Subject lines are short and specific, prefixed with the area they touch
(`ch7: …`, `analysis: …`, `ci: …`).
