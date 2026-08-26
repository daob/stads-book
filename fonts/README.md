# Fonts

The book sets its text in **Fira Sans** and its code in **Fira Code**, in every
edition, so that the website, the PDF and the figures agree.

| Path | Format | Used by |
|------|--------|---------|
| `*.woff2` | web fonts | the HTML edition and the EPUB, via `fonts.css` |
| `print/*.ttf` | desktop fonts | the PDF (xelatex) and the R-drawn figures |
| `fonts.css` | stylesheet | `@font-face` declarations plus the body and code font stacks |

## Why they are committed

The `cosmo` theme pulls Source Sans Pro from Google Fonts with `display=swap`.
When that request is slow or blocked, a page renders permanently in the fallback
font, so chapters differed in text size and position depending on the network at
load time. Self-hosting the book's own faces fixes that, and makes the HTML
identical offline.

The desktop `.ttf` files in `print/` serve the same purpose for the print build:
continuous integration installs them from this directory before rendering the
PDF, so the typeset output does not depend on which fonts a build machine
happens to have.

## License

Fira Sans © 2012–2015 The Mozilla Foundation and Telefonica S.A.; Fira Code
© 2014–2023 The Fira Code Project Authors. Both are licensed under the SIL Open
Font License 1.1, reproduced in [`OFL.txt`](OFL.txt). The license permits this
redistribution; it does not extend to the book's own text, which is licensed
separately (see [`../LICENSE`](../LICENSE)).
