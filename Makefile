# Build the book.
#
# Requirements:
#   - quarto
#   - R with the lavaan package (code chunks execute during render)
#   - mermaid-cli (`mmdc`) to regenerate the diagrams from diagrams/*.mmd
#   - for the PDF: a LaTeX distribution (e.g. `quarto install tinytex`,
#     then `tlmgr install fira` or otherwise make the Fira Sans and
#     Fira Code fonts available to fontspec/fontconfig)
#
# Targets:
#   make all       html + pdf + answers-in-back pdf (default)
#   make html      render the HTML book into _book/
#   make pdf       render the print PDF into _book/stads-book.pdf
#   make diagrams  re-render diagrams/*.png from diagrams/*.mmd
#   make clean     remove build artifacts (keeps diagram PNGs)

QUARTO ?= quarto
MMDC   ?= mmdc
# Scale factor for diagram PNGs (4x for print-quality raster)
MMDC_FLAGS ?= -s 4 -b white

MMD := $(wildcard diagrams/*.mmd)
PNG := $(MMD:.mmd=.png)

.PHONY: all html pdf diagrams clean

# `quarto render` with no --to renders every format listed in _quarto.yml
# into _book/ in one pass. Rendering one format at a time clears _book/ first,
# so `make html` followed by `make pdf` leaves only the PDF.
all: diagrams
	$(QUARTO) render --profile answers --to pdf
	cp _book/stads-book-answers-in-back.pdf /tmp/stads-answers.pdf
	$(QUARTO) render
	cp /tmp/stads-answers.pdf _book/stads-book-answers-in-back.pdf

# PDF with the exercise answers gathered at the back (answers-in-back.lua)
answers: diagrams
	$(QUARTO) render --profile answers --to pdf

html: diagrams
	$(QUARTO) render --to html

pdf: diagrams
	$(QUARTO) render --to pdf

diagrams: $(PNG)

diagrams/%.png: diagrams/%.mmd
	$(MMDC) -i $< -o $@ $(MMDC_FLAGS)

clean:
	rm -rf _book .quarto *_files
