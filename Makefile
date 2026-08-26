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
#   make a4        A4 print PDF with answers in the back
#                  (_book/stads-book-a4-answers-in-back.pdf)
#   make screen    screen-reading PDF for tablets: 7.5x10in, one-sided,
#                  colored links, answers inline (_book/stads-book-screen.pdf)
#   make epub      EPUB for e-readers, answers in the back
#                  (_book/stads-book-answers-in-back.epub)
#
# NOTE: quarto clears _book/ on every single-format render, so build one
# format at a time and move the output aside, or use `make editions` which
# does this for you.
#   make diagrams  re-render diagrams/*.png from diagrams/*.mmd
#   make figures   re-render the R-drawn figures (images/ and diagrams/)
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

.PHONY: all html pdf a4 screen epub editions diagrams figures clean

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

# A4 print edition, answers in the back. The answers profile also sets the
# output name, so rename afterwards to keep the editions apart.
a4: diagrams
	QUARTO_PROFILE=answers,a4 $(QUARTO) render --to pdf
	mv _book/stads-book-answers-in-back.pdf _book/stads-book-a4-answers-in-back.pdf

# Screen-reading edition (tablets): 3:4 page, one-sided, colored links,
# answers inline below each exercise.
screen: diagrams
	QUARTO_PROFILE=screen $(QUARTO) render --to pdf

# EPUB for e-readers, answers gathered at the back like the print edition.
# First run executes the chapters once for the epub format (needs R).
epub: diagrams
	QUARTO_PROFILE=answers,epub $(QUARTO) render --to epub

# Build the three reading editions, stashing each before the next render
# clears _book/.
editions: 
	$(MAKE) a4     && cp _book/stads-book-a4-answers-in-back.pdf /tmp/
	$(MAKE) epub   && cp _book/stads-book-answers-in-back.epub /tmp/
	$(MAKE) screen
	cp /tmp/stads-book-a4-answers-in-back.pdf /tmp/stads-book-answers-in-back.epub _book/

html: diagrams
	$(QUARTO) render --to html

pdf: diagrams
	$(QUARTO) render --to pdf

diagrams: $(PNG)

# Figures drawn in R rather than mermaid, because mermaid cannot route them:
# the Ross et al. time series, the general aggression model, and the two
# extended versions of the Yang et al. path diagram. All need ggplot2, ragg
# and Fira Sans.
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

clean:
	rm -rf _book .quarto *_files
