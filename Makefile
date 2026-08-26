# Build the book.
#
# Requirements:
#   - quarto (>= 1.4)
#   - for the PDF: a LaTeX distribution with the Fira fonts
#       quarto install tinytex && tlmgr install fira
#   - to re-run the analysis chunks: R and the packages reported by
#       Rscript tests/test-dependencies.R
#     (not needed otherwise: chunk output is frozen in _freeze/)
#   - mermaid-cli (`mmdc`) only when a diagrams/*.mmd file changes
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

.PHONY: all ci-build html pdf epub answers site diagrams figures test clean help

## all: html + pdf + epub + the answers-in-back PDF (what CI builds)
all: diagrams
	$(QUARTO) render --profile answers --to pdf
	@mkdir -p .build && cp $(ANSWERS_PDF) .build/answers.pdf
	$(QUARTO) render
	@cp .build/answers.pdf $(ANSWERS_PDF) && rm -rf .build
	@echo "built: _book/index.html, _book/stads-book.pdf, _book/stads-book.epub, $(ANSWERS_PDF)"

## ci-build: like `all`, but without regenerating diagrams (used by CI)
ci-build:
	$(QUARTO) render --profile answers --to pdf
	@mkdir -p .build && cp $(ANSWERS_PDF) .build/answers.pdf
	$(QUARTO) render
	@cp .build/answers.pdf $(ANSWERS_PDF) && rm -rf .build

## html: the website into _book/
html: diagrams
	$(QUARTO) render --to html

## pdf: the 6x9in print PDF
pdf: diagrams
	$(QUARTO) render --to pdf

## epub: the EPUB edition
epub: diagrams
	$(QUARTO) render --to epub

## answers: PDF with the exercise answers collected at the back
answers: diagrams
	$(QUARTO) render --profile answers --to pdf

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

## test: repository checks (structure, cross-references, citations, exercises)
test:
	@fail=0; \
	for check in tests/check_structure.py tests/check_crossrefs.py \
	             tests/check_citations.py tests/check_exercises.py \
	             tests/check_freeze.py; do \
	  $(PYTHON) $$check || fail=1; \
	done; \
	exit $$fail

## clean: remove build artefacts (keeps the generated diagram PNGs)
clean:
	rm -rf _book .quarto .build *_files

## help: list the targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  make /' | sort
