# Repository checks

Fast, dependency-free checks that catch the mistakes this book is prone to:
a chapter added to the folder but not to the book, a cross-reference to a
figure that no longer exists, a citation key that never made it into
`references.bib`, an exercise whose answer was lost in an edit, a drafting
comment left in the text, or microdata about to be committed.

Run them all with:

```sh
make test
```

or individually:

| Check | What it verifies |
|-------|------------------|
| `check_structure.py` | chapter list in `_quarto.yml` matches the files on disk; required files present; no `DO:`/`TODO`/`FIXME` markers left in the text; no microdata tracked |
| `check_crossrefs.py` | every `@sec-`, `@fig-`, `@tbl-`, `@eq-` reference resolves to a label; reports labels nothing points at |
| `check_citations.py` | every citation key exists in `references.bib`; reports uncited entries |
| `check_exercises.py` | every exercise has a collapsible answer with the same number, and the numbering runs 1, 2, 3 … / A, B, C … within each chapter |
| `check_divs.py` | every `::: {.callout-…}` is closed, so a missing fence cannot silently wrap the rest of a chapter in a callout box |
| `test-dependencies.R` | lists the R packages the chunks and scripts use, and which are missing locally |

The `check_*.py` scripts use only the Python standard library, so they run
on any machine and in CI without installing anything. Each prints a one-line
summary, then `FAIL` lines for problems and `note` lines for things worth
knowing, and exits non-zero only on a failure.

`test-dependencies.R` is the exception: it needs R, and it is deliberately not
part of CI, which renders from the frozen output in `_freeze/` and therefore
installs only `knitr` and `rmarkdown`, not the analysis packages. Run it
locally before re-executing chunks.

## Comments that are meant to be there

Two comment conventions are part of how this book gets written, so
`check_structure.py` reports them and moves on:

| In the source | Means |
|---------------|-------|
| `<!-- DO: … -->` | an instruction from the author, waiting to be acted on |
| `<!-- OPEN(who): … -->` | a question that is genuinely open, such as a citation still owed |

Anything else that looks like a drafting leftover — `TODO`, `FIXME`, `XXX` —
fails the check, so it cannot quietly reach the published book.

## What CI adds

The workflows in `.github/workflows/` run these checks on every push and pull
request, and then render the whole book to HTML, PDF and EPUB. A render that
fails, a broken reference, or a missing answer stops the change before it can
reach the published site.
