# Path diagram of the general aggression model (Allen, Anderson & Bushman 2018),
# drawn for Answer 1.A of chapter 1.
#
# Mermaid, which draws the rest of the book's diagrams, cannot route this one
# legibly: six reciprocal arrows among the three internal-state variables plus a
# fan from the two inputs come out as a tangle. So the layout is set by hand
# here, following the arrangement the theory's own authors use: the three
# internal-state variables sit in one block, with the reciprocal effects drawn
# inside it. Colours and font match the mermaid diagrams so the figure does not
# look like a visitor.
#
# Requires: ggplot2, ragg, and the Fira Sans font.
# Usage:  Rscript gam-diagram.R  ->  writes ../images/gam-path-diagram.png

library(ggplot2)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
img_dir <- file.path(here, "..", "images")
dir.create(img_dir, showWarnings = FALSE)

FONT   <- "Fira Sans"
FILL   <- "#ECECFF"     # mermaid's default node fill
STROKE <- "#9370DB"     # mermaid's default node stroke
BLOCK  <- "#f7f7fc"     # the container behind the internal-state variables
INK    <- "#1f1f1f"
SOFT   <- "#6b6b6b"

node <- function(id, x, y, label, w, h = 0.26)
  data.frame(id = id, x = x, y = y, label = label, w = w, h = h)

N <- rbind(
  node("P",  0.82, 2.92, "Person\nfactors",     w = 0.62, h = 0.36),
  node("S",  0.82, 1.28, "Situation\nfactors",  w = 0.62, h = 0.36),
  node("C",  3.38, 2.95, "Cognition",           w = 0.55),
  node("A",  2.62, 1.32, "Affect",              w = 0.50),
  node("R",  4.14, 1.32, "Arousal",             w = 0.55),
  node("AP", 6.35, 2.10, "Appraisal and\ndecision processes", w = 1.15, h = 0.42),
  node("O",  9.10, 2.10, "Aggressive or\nnon-aggressive action", w = 1.30, h = 0.42)
)
rownames(N) <- N$id

# The block holding the present internal state.
BX <- c(2.02, 4.80); BY <- c(0.78, 3.42)

ARROW <- arrow(length = unit(0.075, "in"), type = "closed", angle = 20)

# One reciprocal pair: two arcs between the same two boxes, bowing opposite ways,
# each clipped short of the boxes so the arrowheads stand clear.
pair <- function(x1, y1, x2, y2, k = 0.30) {
  list(
    geom_curve(aes(x = x1, y = y1, xend = x2, yend = y2), curvature =  k,
               linewidth = 0.42, colour = INK, arrow = ARROW),
    geom_curve(aes(x = x2, y = y2, xend = x1, yend = y1), curvature =  k,
               linewidth = 0.42, colour = INK, arrow = ARROW)
  )
}

p <- ggplot() +
  # grouping bands
  annotate("rect", xmin = 0.10, xmax = 1.54, ymin = 0.78, ymax = 3.42,
           fill = NA, colour = "#cccccc", linetype = "22", linewidth = 0.3) +
  annotate("rect", xmin = BX[1], xmax = BX[2], ymin = BY[1], ymax = BY[2],
           fill = BLOCK, colour = "#c3c3d8", linewidth = 0.35) +
  annotate("text", x = 0.82, y = 3.58, label = "inputs",
           family = FONT, size = 3.3, colour = SOFT) +
  annotate("text", x = 3.41, y = 3.58, label = "present internal state",
           family = FONT, size = 3.3, colour = SOFT) +

  # association between the two exogenous variables
  geom_curve(aes(x = 0.82, y = 2.58, xend = 0.82, yend = 1.62), curvature = 0.9,
             linetype = "22", linewidth = 0.42, colour = INK,
             arrow = arrow(length = unit(0.07, "in"), ends = "both",
                           type = "closed", angle = 20)) +

  # inputs into the internal state
  geom_segment(aes(x = 1.44, y = 2.86, xend = BX[1] - 0.03, yend = 2.50),
               linewidth = 0.42, colour = INK, arrow = ARROW) +
  geom_segment(aes(x = 1.44, y = 1.34, xend = BX[1] - 0.03, yend = 1.66),
               linewidth = 0.42, colour = INK, arrow = ARROW) +

  # reciprocal effects inside the block: one lens of two arcs per pair
  pair(3.06, 2.71, 2.68, 1.62, k = 0.22) +
  pair(3.70, 2.71, 4.08, 1.62, k = 0.22) +
  pair(3.16, 1.32, 3.57, 1.32, k = 0.42) +

  # internal state into appraisal, appraisal into action
  geom_segment(aes(x = BX[2] + 0.03, y = 2.10, xend = 5.14, yend = 2.10),
               linewidth = 0.42, colour = INK, arrow = ARROW) +
  geom_segment(aes(x = 7.53, y = 2.10, xend = 7.74, yend = 2.10),
               linewidth = 0.42, colour = INK, arrow = ARROW) +

  # feedback across episodes, routed around the outside
  annotate("segment", x = 9.10, y = 1.68, xend = 9.10, yend = 0.34,
           linewidth = 0.42, colour = INK) +
  annotate("segment", x = 9.10, y = 0.34, xend = 0.82, yend = 0.34,
           linewidth = 0.42, colour = INK) +
  annotate("segment", x = 0.82, y = 0.34, xend = 0.82, yend = 0.74,
           linewidth = 0.42, colour = INK, arrow = ARROW) +
  annotate("text", x = 5.00, y = 0.52, label = "the action changes the next episode",
           family = FONT, size = 3.0, colour = SOFT) +

  geom_rect(data = N, aes(xmin = x - w, xmax = x + w, ymin = y - h, ymax = y + h),
            fill = FILL, colour = STROKE, linewidth = 0.5) +
  geom_text(data = N, aes(x, y, label = label),
            family = FONT, size = 3.7, colour = INK, lineheight = 1.05) +

  coord_fixed(clip = "off", xlim = c(0.05, 10.45), ylim = c(0.22, 3.72)) +
  theme_void()

ragg::agg_png(file.path(img_dir, "gam-path-diagram.png"),
              width = 6.4, height = 2.35, units = "in", res = 300, background = "white")
print(p); invisible(dev.off())
cat("wrote images/gam-path-diagram.png\n")
