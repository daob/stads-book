# Build the book.
#
# Requirements:
#   - quarto (>= 1.4)
#   - for the PDFs: a LaTeX distribution with the Fira fonts
#       quarto install tinytex && tlmgr install fira
#     (the fonts also ship with the repository, in fonts/print/)
#   - to re-run the analysis chunks: R and the packages reported by
#       Rscript tests/test-dependencies.R
#     Otherwise no R package is needed: chunk output is frozen in _freeze/.
#   - mermaid-cli (`mmdc`) only when a diagrams/*.mmd file changes
#
# NOTE: quarto clears _book/ on every single-format render, so the targets that
# build several editions stash each output before the next render starts.
#
# Run `make help` for the target list.

QUARTO ?= quarto
MMDC   ?= mmdc
PYTHON ?= python3

# Scale factor for diagram PNGs (4x for print-quality raster). The config and
# stylesheet set the diagram font to Fira Sans, to match the rest of the book;
# Fira Sans must therefore be installed where the headless browser can find it.
MMDC_CFG   := diagrams/mermaid-config.json
MMDC_CSS   := diagrams/mermaid.css
MMDC_FLAGS ?= -s 4 -b white -c $(MMDC_CFG) -C $(MMDC_CSS)

MMD := $(wildcard diagrams/*.mmd)
PNG := $(MMD:.mmd=.png)

ANSWERS_PDF := _book/stads-book-answers-in-back.pdf
STASH       := .build

.PHONY: all ci-build html pdf epub answers a4 screen editions site \
        figures-from-freeze diagrams figures test clean help

## all: every edition the website offers (what CI publishes)
all: diagrams ci-build

# The .tex refers to <chapter>_files/figure-pdf/...; a fresh clone has no such
# directory, so put the frozen figures there before any render.
## figures-from-freeze: copy the frozen figures into the <chapter>_files/ dirs
figures-from-freeze:
	@$(PYTHON) tools/restore-freeze-figures.py

## ci-build: every edition the website offers; the exact steps CI runs
#
# Each single-format render clears _book/, so the four extra editions are built
# first and stashed, the full render (site + print PDF + EPUB) comes last, and
# the stash is copied back over it. The defaults, stads-book.pdf and
# stads-book.epub, are the answers-in-back editions.
ci-build: figures-from-freeze
	@mkdir -p $(STASH)
	$(QUARTO) render --profile answers --to pdf
	@mv $(ANSWERS_PDF) $(STASH)/stads-book-print-answers-in-back.pdf
	QUARTO_PROFILE=screen $(QUARTO) render --to pdf
	@mv _book/stads-book-screen.pdf $(STASH)/stads-book-screen-answers-inline.pdf
	# with two profiles the answers profile supplies the output name, so the
	# screen-sized, answers-in-back PDF comes out as stads-book-answers-in-back
	QUARTO_PROFILE=answers,screen $(QUARTO) render --to pdf
	@mv $(ANSWERS_PDF) $(STASH)/stads-book-screen-answers-in-back.pdf
	QUARTO_PROFILE=answers,epub $(QUARTO) render --to epub
	@mv _book/stads-book-answers-in-back.epub $(STASH)/stads-book-answers-in-back.epub
	$(QUARTO) render
	@mv _book/stads-book.pdf _book/stads-book-print-answers-inline.pdf
	@mv _book/stads-book.epub _book/stads-book-answers-inline.epub
	@cp $(STASH)/*.pdf $(STASH)/*.epub _book/
	@cp _book/stads-book-print-answers-in-back.pdf _book/stads-book.pdf
	@cp _book/stads-book-answers-in-back.epub _book/stads-book.epub
	@rm -rf $(STASH)
	@echo "built editions:" && ls -1 _book/*.pdf _book/*.epub

## html: the website into _book/
html: diagrams figures-from-freeze
	$(QUARTO) render --to html

## pdf: the 6x9in print PDF
pdf: diagrams figures-from-freeze
	$(QUARTO) render --to pdf

## epub: the EPUB that accompanies the website (answers inline)
epub: diagrams figures-from-freeze
	$(QUARTO) render --to epub

## answers: 6x9in PDF with the exercise answers collected at the back
answers: diagrams figures-from-freeze
	$(QUARTO) render --profile answers --to pdf

# ---------------------------------------------------------------- editions --
# Alternative reading editions, each driven by a profile in _quarto-*.yml.

## a4: A4 print PDF, answers in the back
a4: diagrams figures-from-freeze
	QUARTO_PROFILE=answers,a4 $(QUARTO) render --to pdf
	mv $(ANSWERS_PDF) _book/stads-book-a4-answers-in-back.pdf

## screen: 7.5x10in one-sided PDF for tablets, answers inline
screen: diagrams figures-from-freeze
	QUARTO_PROFILE=screen $(QUARTO) render --to pdf

## editions: a4 + screen + e-reader EPUB, stashed so they survive each other
editions: diagrams figures-from-freeze
	QUARTO_PROFILE=answers,a4 $(QUARTO) render --to pdf
	@mkdir -p $(STASH) && mv $(ANSWERS_PDF) $(STASH)/stads-book-a4-answers-in-back.pdf
	QUARTO_PROFILE=answers,epub $(QUARTO) render --to epub
	@mv _book/stads-book-answers-in-back.epub $(STASH)/
	QUARTO_PROFILE=screen $(QUARTO) render --to pdf
	@cp $(STASH)/* _book/ && rm -rf $(STASH)
	@echo "built: _book/stads-book-{a4-answers-in-back.pdf,answers-in-back.epub,screen.pdf}"

## site: serve the book locally with live reload
site:
	$(QUARTO) preview

## diagrams: regenerate diagrams/*.png from diagrams/*.mmd
diagrams: $(PNG)

# Figures drawn in R rather than mermaid, because mermaid cannot route them:
# the Ross et al. time series, the general aggression model, and the two
# extended versions of the Yang et al. path diagram. All need ggplot2, ragg
# and Fira Sans.
## figures: regenerate the R-drawn figures
figures: images/ross-1970-breathalyser.png images/gam-path-diagram.png \
         diagrams/yang-full.png diagrams/yang-correlated.png \
         diagrams/joint-effect.png diagrams/ace.png

images/ross-1970-breathalyser.png: figures/ross-1970-figure.R figures/ross-1970-data.csv
	Rscript $<

images/gam-path-diagram.png: figures/gam-diagram.R
	Rscript $<

# One script draws both extended versions of the Yang et al. path diagram.
diagrams/yang-full.png diagrams/yang-correlated.png: diagrams/yang-models.R
	Rscript $<

diagrams/joint-effect.png: diagrams/joint-effect.R
	Rscript $<

# The two-panel ACE twin diagram (fraternal and identical side by side).
diagrams/ace.png: diagrams/ace-models.R
	Rscript $<

diagrams/%.png: diagrams/%.mmd $(MMDC_CFG) $(MMDC_CSS)
	$(MMDC) -i $< -o $@ $(MMDC_FLAGS)

## test: repository checks (structure, references, citations, exercises, freeze)
test:
	@fail=0; \
	for check in tests/check_structure.py tests/check_crossrefs.py \
	             tests/check_citations.py tests/check_exercises.py \
	             tests/check_divs.py tests/check_freeze.py; do \
	  $(PYTHON) $$check || fail=1; \
	done; \
	exit $$fail

## clean: remove build artefacts (keeps the generated diagram PNGs)
clean:
	rm -rf _book .quarto $(STASH) *_files *_cache

## help: list the targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  make /' | sort
