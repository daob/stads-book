# Path diagram of the general aggression model (Allen, Anderson & Bushman 2018),
# drawn for Answer 1.A of chapter 1.
#
# Every arrow runs from one variable to another. Nothing terminates on a group
# or a container, because a group is not a variable and an arrow into a group
# says nothing about which member it reaches. So the six input effects, the six
# reciprocal effects among the internal-state variables, and the three effects
# on appraisal are all drawn individually.
#
# The layout puts affect at the left of the internal-state trio and cognition
# and arousal above and below to its right. That way the fan from the two input
# variables arrives from the left without passing through anything, the three
# arrows on to appraisal leave to the right, and the one long reciprocal pair
# (cognition with arousal) runs vertically, so the arrow from affect to
# appraisal crosses it close to square, which is the one crossing the layout
# cannot avoid.
#
# Mermaid, which draws the rest of the book's diagrams, cannot route this; the
# geometry is therefore set by hand. Colours and font match the mermaid
# diagrams so the figure does not look like a visitor.
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
INK    <- "#1f1f1f"
SOFT   <- "#6b6b6b"

node <- function(id, x, y, label, w, h)
  data.frame(id = id, x = x, y = y, label = label, w = w, h = h)

N <- rbind(
  node("P",  0.85, 3.05, "Person\nfactors",                  w = 0.64, h = 0.36),
  node("S",  0.85, 1.05, "Situation\nfactors",               w = 0.64, h = 0.36),
  node("A",  3.45, 2.05, "Affect",                           w = 0.52, h = 0.28),
  node("C",  5.05, 3.15, "Cognition",                        w = 0.60, h = 0.28),
  node("R",  5.05, 0.95, "Arousal",                          w = 0.60, h = 0.28),
  node("AP", 7.40, 2.05, "Appraisal and\ndecision processes", w = 1.25, h = 0.44),
  node("O", 10.40, 2.05, "Aggressive or\nnon-aggressive action", w = 1.45, h = 0.44)
)
rownames(N) <- N$id

ARROW <- arrow(length = unit(0.075, "in"), type = "closed", angle = 20)

# Where a straight line from (ax, ay) to the centre of `id` meets that box's
# border, so arrowheads stop on the box rather than inside it.
edge_point <- function(id, ax, ay, pad = 0.035) {
  cx <- N[id, "x"]; cy <- N[id, "y"]
  w <- N[id, "w"] + pad; h <- N[id, "h"] + pad
  dx <- ax - cx; dy <- ay - cy
  t <- min(if (dx != 0) w / abs(dx) else Inf, if (dy != 0) h / abs(dy) else Inf)
  c(cx + dx * t, cy + dy * t)
}

# A single-headed straight effect arrow between two variables.
eff <- function(from, to) {
  p1 <- edge_point(from, N[to, "x"], N[to, "y"])
  p2 <- edge_point(to,   N[from, "x"], N[from, "y"])
  geom_segment(aes(x = p1[1], y = p1[2], xend = p2[1], yend = p2[2]),
               linewidth = 0.42, colour = INK, arrow = ARROW)
}

# A reciprocal pair: the same two border points joined by two arcs bowing
# opposite ways, one arrowhead at each end. Two effects, not one association.
recip <- function(from, to, k = 0.28) {
  p1 <- edge_point(from, N[to, "x"], N[to, "y"])
  p2 <- edge_point(to,   N[from, "x"], N[from, "y"])
  list(
    geom_curve(aes(x = p1[1], y = p1[2], xend = p2[1], yend = p2[2]),
               curvature = k, linewidth = 0.42, colour = INK, arrow = ARROW),
    geom_curve(aes(x = p2[1], y = p2[2], xend = p1[1], yend = p1[2]),
               curvature = k, linewidth = 0.42, colour = INK, arrow = ARROW)
  )
}

p <- ggplot() +
  # the six effects of the input variables on the internal state
  eff("P", "A") + eff("P", "C") + eff("P", "R") +
  eff("S", "A") + eff("S", "C") + eff("S", "R") +

  # the six reciprocal effects among the internal-state variables
  recip("A", "C") + recip("A", "R") + recip("C", "R", k = 0.30) +

  # the internal state on appraisal, appraisal on the action
  eff("A", "AP") + eff("C", "AP") + eff("R", "AP") +
  eff("AP", "O") +

  # covariation between the two exogenous variables, left unexplained
  geom_curve(aes(x = 0.85, y = 2.69, xend = 0.85, yend = 1.41), curvature = -0.85,
             linetype = "22", linewidth = 0.42, colour = INK,
             arrow = arrow(length = unit(0.07, "in"), ends = "both",
                           type = "closed", angle = 20)) +

  # the action feeds back on both inputs in the next episode
  annotate("segment", x = 10.40, y = 2.53, xend = 10.40, yend = 4.05,
           linewidth = 0.42, colour = INK) +
  annotate("segment", x = 10.40, y = 4.05, xend = 0.85, yend = 4.05,
           linewidth = 0.42, colour = INK) +
  annotate("segment", x = 0.85, y = 4.05, xend = 0.85, yend = 3.45,
           linewidth = 0.42, colour = INK, arrow = ARROW) +
  annotate("segment", x = 10.40, y = 1.57, xend = 10.40, yend = 0.10,
           linewidth = 0.42, colour = INK) +
  annotate("segment", x = 10.40, y = 0.10, xend = 0.85, yend = 0.10,
           linewidth = 0.42, colour = INK) +
  annotate("segment", x = 0.85, y = 0.10, xend = 0.85, yend = 0.65,
           linewidth = 0.42, colour = INK, arrow = ARROW) +
  annotate("text", x = 5.55, y = 0.29, label = "next episode",
           family = FONT, size = 3.0, colour = SOFT) +

  geom_rect(data = N, aes(xmin = x - w, xmax = x + w, ymin = y - h, ymax = y + h),
            fill = FILL, colour = STROKE, linewidth = 0.5) +
  geom_text(data = N, aes(x, y, label = label),
            family = FONT, size = 3.7, colour = INK, lineheight = 1.05) +

  coord_fixed(clip = "off", xlim = c(0.05, 11.95), ylim = c(0.02, 4.15)) +
  theme_void()

ragg::agg_png(file.path(img_dir, "gam-path-diagram.png"),
              width = 6.6, height = 2.32, units = "in", res = 300, background = "white")
print(p); invisible(dev.off())
cat("wrote images/gam-path-diagram.png\n")
