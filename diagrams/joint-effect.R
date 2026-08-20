# The joint effect illustrated: three stories on the left (X1 causes X2, X2
# causes X1, the two share an unnamed common cause), one diagram on the right
# in which the relationship is left unspecified as a curved two-headed arrow.
# Whichever story is true, the implied correlations among the three observed
# variables are identical once phi = gamma1 = gamma2 = lambda1*lambda2, so the
# curve can stand for all three, and its contribution to the correlation of
# X1 with Y is the joint effect phi*beta.
#
# Drawn in R because mermaid cannot lay this out; style matches the book's
# other diagrams. All text is Fira Sans, using Unicode Greek and subscript
# glyphs rather than plotmath so no math font intrudes.
#
# Requires: ggplot2, ragg, and the Fira Sans font.
# Usage:  Rscript joint-effect.R   ->  writes diagrams/joint-effect.png

library(ggplot2)

# The labels use Unicode Greek and subscript glyphs, so the C locale (common in
# containers) must be upgraded to UTF-8 or they render as replacement marks.
loc <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
if (identical(loc, "")) suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."

FONT <- "Fira Sans"; FILL <- "#ECECFF"; STROKE <- "#9370DB"
INK  <- "#1f1f1f";   SOFT <- "#6b6b6b"
ARROW  <- arrow(length = unit(0.08, "in"), type = "closed", angle = 20)
ARROW2 <- arrow(length = unit(0.07, "in"), ends = "both", type = "closed", angle = 20)

node <- function(id, x, y, l, w = 0.34, h = 0.26) data.frame(id = id, x = x, y = y, l = l, w = w, h = h)
ep <- function(N, id, ax, ay, pad = 0.05) {
  cx <- N[id, "x"]; cy <- N[id, "y"]; w <- N[id, "w"] + pad; h <- N[id, "h"] + pad
  dx <- ax - cx; dy <- ay - cy
  t <- min(if (dx != 0) w / abs(dx) else Inf, if (dy != 0) h / abs(dy) else Inf)
  c(cx + dx * t, cy + dy * t)
}
epc <- function(cx, cy, r, ax, ay) { dx <- ax - cx; dy <- ay - cy; L <- sqrt(dx^2 + dy^2)
  c(cx + dx / L * r, cy + dy / L * r) }

layers <- list()
add <- function(...) layers[[length(layers) + 1]] <<- list(...)
seg <- function(p1, p2, lab, off) add(
  geom_segment(aes(x = p1[1], y = p1[2], xend = p2[1], yend = p2[2]),
               linewidth = 0.45, colour = INK, arrow = ARROW),
  annotate("text", x = (p1[1] + p2[1]) / 2 + off[1], y = (p1[2] + p2[2]) / 2 + off[2],
           label = lab, family = FONT, size = 4.1, colour = INK))
eff <- function(N, f, t, lab, off = c(0, 0.22))
  seg(ep(N, f, N[t, "x"], N[t, "y"]), ep(N, t, N[f, "x"], N[f, "y"]), lab, off)
boxes <- function(N) add(
  geom_rect(data = N, aes(xmin = x - w, xmax = x + w, ymin = y - h, ymax = y + h),
            fill = FILL, colour = STROKE, linewidth = 0.5),
  geom_text(data = N, aes(x, y, label = l), family = FONT, size = 4.7, colour = INK))
cap <- function(x, y, txt) add(
  annotate("text", x = x, y = y, label = txt, family = FONT, size = 3.9,
           colour = SOFT, hjust = 0))

row_nodes <- function(y) {
  N <- rbind(node("X1", 0.55, y, "X₁"), node("X2", 2.55, y, "X₂"),
             node("Y", 4.15, y, "Y"))
  rownames(N) <- N$id; N
}

## left column, three stories -------------------------------------------------
NA_ <- row_nodes(5.45)                              # X1 causes X2
cap(0.21, 6.15, "X₁ causes X₂")
eff(NA_, "X1", "X2", "γ₁"); eff(NA_, "X2", "Y", "β"); boxes(NA_)

NB <- row_nodes(3.65)                               # X2 causes X1
cap(0.21, 4.35, "X₂ causes X₁")
eff(NB, "X2", "X1", "γ₂"); eff(NB, "X2", "Y", "β"); boxes(NB)

NC <- row_nodes(0.45)                               # unnamed common cause
cap(0.21, 2.55, "X₁ and X₂ share common cause")
CX <- 1.55; CY <- 1.75; R <- 0.28
th <- seq(0, 2 * pi, length.out = 90)
circ <- data.frame(x = CX + R * cos(th), y = CY + R * sin(th))
seg(epc(CX, CY, R + 0.04, NC["X1", "x"], NC["X1", "y"]), ep(NC, "X1", CX, CY),
    "λ₁", c(-0.34, 0.05))
seg(epc(CX, CY, R + 0.04, NC["X2", "x"], NC["X2", "y"]), ep(NC, "X2", CX, CY),
    "λ₂", c(0.34, 0.05))
eff(NC, "X2", "Y", "β")
add(geom_polygon(data = circ, aes(x, y), fill = "white", colour = STROKE, linewidth = 0.5))
boxes(NC)

## right, the one diagram that stands for all three ---------------------------
DX <- 6.30
ND <- rbind(node("X1", 0.55 + DX, 2.60, "X₁"), node("X2", 2.55 + DX, 2.60, "X₂"),
            node("Y", 4.15 + DX, 2.60, "Y"))
rownames(ND) <- ND$id
add(geom_curve(aes(x = 0.55 + DX, y = 2.91, xend = 2.55 + DX, yend = 2.91),
               curvature = -0.45, linetype = "22", linewidth = 0.45,
               colour = INK, arrow = ARROW2),
    annotate("text", x = 1.55 + DX, y = 3.77, label = "φ",
             family = FONT, size = 4.4, colour = INK))
eff(ND, "X2", "Y", "β")
boxes(ND)
add(annotate("text", x = 2.35 + DX, y = 1.55,
             label = "φ = γ₁ = γ₂ = λ₁λ₂",
             family = FONT, size = 4.0, colour = SOFT))

g <- ggplot()
for (ly in layers) for (e in ly) g <- g + e
g <- g + coord_fixed(clip = "off", xlim = c(0.05, 10.85), ylim = c(0.02, 6.45)) + theme_void()

ragg::agg_png(file.path(here, "joint-effect.png"), width = 7.6, height = 4.5,
              units = "in", res = 300, background = "white")
print(g); invisible(dev.off())
cat("wrote diagrams/joint-effect.png\n")
