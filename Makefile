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
#   make figures   re-render the R-drawn figures into images/
#   make clean     remove build artifacts (keeps diagram PNGs)

QUARTO ?= quarto
MMDC   ?= mmdc
# Scale factor for diagram PNGs (4x for print-quality raster). The config and
# stylesheet set the diagram font to Fira Sans, to match the rest of the book;
# Fira Sans must therefore be installed where the headless browser can find it.
MMDC_CFG   := diagrams/mermaid-config.json
MMDC_CSS   := diagrams/mermaid.css
MMDC_FLAGS ?= -s 4 -b white -c $(MMDC_CFG) -C $(MMDC_CSS)

MMD := $(wildcard diagrams/*.mmd)
PNG := $(MMD:.mmd=.png)

.PHONY: all html pdf diagrams figures clean

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

# Figures drawn in R rather than mermaid: the Ross et al. time series and the
# general aggression model path diagram. Both need ggplot2, ragg and Fira Sans.
figures: images/ross-1970-breathalyser.png images/gam-path-diagram.png

images/ross-1970-breathalyser.png: figures/ross-1970-figure.R figures/ross-1970-data.csv
	Rscript $<

images/gam-path-diagram.png: figures/gam-diagram.R
	Rscript $<

diagrams/%.png: diagrams/%.mmd $(MMDC_CFG) $(MMDC_CSS)
	$(MMDC) -i $< -o $@ $(MMDC_FLAGS)

clean:
	rm -rf _book .quarto *_files
