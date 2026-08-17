# Two path diagrams of the Yang et al. verbal theory, drawn out beyond the
# three-variable version in diagrams/yang.mmd.
#
#   yang-full.png         the theory as stated: social integration acts on
#                         inflammation, blood pressure and central adiposity;
#                         each of those acts on chronic disease and on death;
#                         chronic disease acts on death. There is no direct
#                         path from integration to death, because the theory
#                         names none.
#
#   yang-correlated.png   the same theory with chronic disease removed (an
#                         intervening variable, so its removal costs no bias:
#                         c'_j = c_j + d*b_j), and with the disturbances of the
#                         three physiological variables free to covary, which
#                         withdraws the claim that they move together only
#                         because social integration moves all three.
#
# Conventions follow chapter 2: observed variables in boxes, disturbances in
# circles, single-headed straight arrow for an effect, curved two-headed dashed
# arrow for covariation the model does not explain, coefficients on the arrows.
# Mermaid draws the rest of the book's diagrams but cannot route these two
# legibly, so the geometry is set by hand. Colours and font match the mermaid
# output so the figures do not look like visitors.
#
# Requires: ggplot2, ragg, and the Fira Sans font.
# Usage:  Rscript yang-models.R   ->  writes yang-full.png, yang-correlated.png

library(ggplot2)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."

FONT   <- "Fira Sans"
FILL   <- "#ECECFF"     # mermaid's default node fill
STROKE <- "#9370DB"     # mermaid's default node stroke
INK    <- "#1f1f1f"

ARROW  <- arrow(length = unit(0.085, "in"), type = "closed", angle = 20)
ARROW2 <- arrow(length = unit(0.075, "in"), ends = "both", type = "closed",
                angle = 20)
ZR     <- 0.27          # radius of a disturbance circle

node <- function(id, x, y, label, w, h)
  data.frame(id = id, x = x, y = y, label = label, w = w, h = h)

# Circles as polygons, so the script needs no package beyond ggplot2.
circles <- function(Z, n = 72) {
  th <- seq(0, 2 * pi, length.out = n)
  do.call(rbind, lapply(seq_len(nrow(Z)), function(i)
    data.frame(id = Z$to[i], x = Z$x[i] + ZR * cos(th), y = Z$y[i] + ZR * sin(th))))
}

# Where the straight line from (ax, ay) to the centre of `id` meets its border.
edge_point <- function(N, id, ax, ay, pad = 0.05) {
  cx <- N[id, "x"]; cy <- N[id, "y"]
  w <- N[id, "w"] + pad; h <- N[id, "h"] + pad
  dx <- ax - cx; dy <- ay - cy
  t <- min(if (dx != 0) w / abs(dx) else Inf, if (dy != 0) h / abs(dy) else Inf)
  c(cx + dx * t, cy + dy * t)
}

# EDGES entries are c(from, to, label, optional label position along the arrow).
build <- function(N, Z, EDGES, COV, xlim, ylim, file, width, height) {
  rownames(N) <- N$id

  seg <- do.call(rbind, lapply(EDGES, function(e) {
    p1 <- edge_point(N, e[1], N[e[2], "x"], N[e[2], "y"])
    p2 <- edge_point(N, e[2], N[e[1], "x"], N[e[1], "y"])
    f  <- if (length(e) > 3) as.numeric(e[4]) else 0.5
    data.frame(x = p1[1], y = p1[2], xend = p2[1], yend = p2[2], lab = e[3],
               lx = p1[1] + f * (p2[1] - p1[1]),
               ly = p1[2] + f * (p2[2] - p1[2]))
  }))

  zseg <- do.call(rbind, lapply(seq_len(nrow(Z)), function(i) {
    p2 <- edge_point(N, Z$to[i], Z$x[i], Z$y[i])
    dx <- p2[1] - Z$x[i]; dy <- p2[2] - Z$y[i]; L <- sqrt(dx^2 + dy^2)
    data.frame(x = Z$x[i] + dx / L * ZR, y = Z$y[i] + dy / L * ZR,
               xend = p2[1], yend = p2[2])
  }))

  p <- ggplot() +
    geom_segment(data = seg, aes(x, y, xend = xend, yend = yend),
                 linewidth = 0.5, colour = INK, arrow = ARROW) +
    geom_segment(data = zseg, aes(x, y, xend = xend, yend = yend),
                 linewidth = 0.4, colour = INK, arrow = ARROW)

  # geom_curve takes one curvature per layer, so the arcs go in one at a time
  if (!is.null(COV)) for (i in seq_len(nrow(COV))) {
    p <- p +
      geom_curve(data = COV[i, ], aes(x = x, y = y, xend = xend, yend = yend),
                 curvature = COV$k[i], linetype = "22", linewidth = 0.45,
                 colour = INK, arrow = ARROW2) +
      geom_label(data = COV[i, ], aes(x = lx, y = ly, label = lab), parse = TRUE,
                 family = FONT, size = 3.6, colour = INK, fill = "white",
                 label.size = 0, label.padding = unit(0.08, "lines"))
  }

  p <- p +
    geom_label(data = seg, aes(lx, ly, label = lab), parse = TRUE,
               family = FONT, size = 3.9, colour = INK, fill = "white",
               label.size = 0, label.padding = unit(0.10, "lines")) +
    geom_rect(data = N, aes(xmin = x - w, xmax = x + w,
                            ymin = y - h, ymax = y + h),
              fill = FILL, colour = STROKE, linewidth = 0.55) +
    geom_text(data = N, aes(x, y, label = label), family = FONT, size = 4.1,
              colour = INK, lineheight = 1.05) +
    geom_polygon(data = circles(Z), aes(x, y, group = id),
                 fill = "white", colour = STROKE, linewidth = 0.45) +
    geom_text(data = Z, aes(x, y, label = label), parse = TRUE, family = FONT,
              size = 3.5, colour = INK) +
    coord_fixed(clip = "off", xlim = xlim, ylim = ylim) +
    theme_void()

  ragg::agg_png(file.path(here, file), width = width, height = height,
                units = "in", res = 300, background = "white")
  print(p); invisible(dev.off())
  cat("wrote", file, "\n")
}

## ---- the theory as stated --------------------------------------------------

N_full <- rbind(
  node("S", 1.00, 2.80, "Social\nintegration", 0.80, 0.42),
  node("I", 4.40, 5.30, "Inflammation",        0.88, 0.30),
  node("B", 4.40, 2.80, "Blood\npressure",     0.88, 0.42),
  node("A", 4.40, 0.30, "Central\nadiposity",  0.88, 0.42),
  node("D", 8.60, 5.00, "Chronic\ndisease",    0.80, 0.42),
  node("M", 8.60, 0.60, "Death",               0.64, 0.30)
)
Z_full <- data.frame(
  to    = c("I", "B", "A", "D", "M"),
  x     = c(4.40, 4.40, 4.40, 10.30, 10.30),
  y     = c(6.50, 4.05, 1.55, 5.00, 0.60),
  label = c("zeta[I]", "zeta[B]", "zeta[A]", "zeta[D]", "zeta[M]")
)
E_full <- list(
  c("S", "I", "a[1]"), c("S", "B", "a[2]"), c("S", "A", "a[3]"),
  c("I", "D", "b[1]", 0.55), c("B", "D", "b[2]", 0.55), c("A", "D", "b[3]", 0.26),
  c("I", "M", "c[1]", 0.26), c("B", "M", "c[2]", 0.55), c("A", "M", "c[3]", 0.72),
  c("D", "M", "d")
)
build(N_full, Z_full, E_full, NULL,
      c(0.10, 10.70), c(-0.20, 6.90), "yang-full.png", 7.4, 4.96)

## ---- chronic disease removed, disturbances free to covary ------------------

N_cor <- rbind(
  node("S", 1.00, 2.80, "Social\nintegration", 0.80, 0.42),
  node("I", 4.40, 5.30, "Inflammation",        0.88, 0.30),
  node("B", 4.40, 2.80, "Blood\npressure",     0.88, 0.42),
  node("A", 4.40, 0.30, "Central\nadiposity",  0.88, 0.42),
  node("M", 8.20, 2.80, "Death",               0.64, 0.30)
)
Z_cor <- data.frame(
  to    = c("I", "B", "A", "M"),
  x     = c(4.40, 4.40, 4.40, 8.20),
  y     = c(6.50, 4.05, 1.55, 4.30),
  label = c("zeta[I]", "zeta[B]", "zeta[A]", "zeta[M]")
)
E_cor <- list(
  c("S", "I", "a[1]"), c("S", "B", "a[2]"), c("S", "A", "a[3]"),
  c("I", "M", "c[1]*minute"), c("B", "M", "c[2]*minute"), c("A", "M", "c[3]*minute")
)
COV <- data.frame(
  x    = c(4.62, 4.62, 4.55),
  y    = c(6.31, 3.86, 6.36),
  xend = c(4.62, 4.62, 4.55),
  yend = c(4.24, 1.79, 1.74),
  k    = c(-0.95, -0.95, -0.62),
  lab  = c("psi[IB]", "psi[BA]", "psi[IA]"),
  lx   = c(5.98, 5.98, 6.92),
  ly   = c(5.28, 2.36, 4.12)
)
build(N_cor, Z_cor, E_cor, COV,
      c(0.10, 9.00), c(-0.20, 6.90), "yang-correlated.png", 6.9, 5.50)
