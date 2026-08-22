# Two small decision diagrams for chapter 5: the umbrella decision, where the
# action does not touch the outcome, and the rain-dance decision, where it
# does. Drawn in the book's diagram style, with the hospital reminder-call
# example as labels.
#
# Usage: Rscript umbrella-raindance.R -> writes ../images/umbrella-raindance.png

loc <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
if (identical(loc, "")) suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

library(ggplot2)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
img_dir <- file.path(here, "..", "images")
dir.create(img_dir, showWarnings = FALSE)

FONT   <- "Fira Sans"
FILL   <- "#ECECFF"
STROKE <- "#9370DB"
INK    <- "#1f1f1f"
ACC    <- "#7A28CB"
SOFT   <- "#6b6b6b"
ARROW  <- arrow(length = unit(0.08, "in"), type = "closed", angle = 20)

panel <- function(dx, with_effect, title) {
  # node centres: action bottom-left, outcome top-left, payoff right
  N <- data.frame(
    id    = c("X", "Y", "P"),
    x     = dx + c(0.9, 0.9, 4.1),
    y     = c(0.7, 2.9, 1.8),
    label = c("Action X₀\n(call patient)", "Outcome Y\n(patient shows up)",
              "Payoff π\n(clinic's net benefit)"),
    w     = c(0.82, 0.82, 0.92), h = c(0.42, 0.42, 0.42)
  )
  rownames(N) <- N$id
  edge <- function(from, to) {
    p1 <- N[from, ]; p2 <- N[to, ]
    dxv <- p2$x - p1$x; dyv <- p2$y - p1$y
    t1 <- min(if (dxv != 0) (p1$w + 0.05) / abs(dxv) else Inf,
              if (dyv != 0) (p1$h + 0.05) / abs(dyv) else Inf)
    t2 <- min(if (dxv != 0) (p2$w + 0.05) / abs(dxv) else Inf,
              if (dyv != 0) (p2$h + 0.05) / abs(dyv) else Inf)
    data.frame(x = p1$x + dxv * t1, y = p1$y + dyv * t1,
               xend = p2$x - dxv * t2, yend = p2$y - dyv * t2)
  }
  list(N = N,
       eXP = edge("X", "P"), eYP = edge("Y", "P"), eXY = edge("X", "Y"),
       with_effect = with_effect,
       title = data.frame(x = dx + 2.5, y = -0.35, lab = title))
}

pa <- panel(0.0, FALSE, "(a) umbrella decision:\nthe action leaves the outcome alone")
pb <- panel(6.4, TRUE,  "(b) rain-dance decision:\nthe action changes the outcome")

p <- ggplot()
for (pn in list(pa, pb)) {
  p <- p +
    annotate("segment", x = pn$eXP$x, y = pn$eXP$y, xend = pn$eXP$xend,
             yend = pn$eXP$yend, linewidth = 0.5, colour = INK, arrow = ARROW) +
    annotate("segment", x = pn$eYP$x, y = pn$eYP$y, xend = pn$eYP$xend,
             yend = pn$eYP$yend, linewidth = 0.5, colour = INK, arrow = ARROW)
  if (pn$with_effect) {
    p <- p + annotate("segment", x = pn$eXY$x, y = pn$eXY$y,
                      xend = pn$eXY$xend, yend = pn$eXY$yend,
                      linewidth = 0.9, colour = ACC, arrow = ARROW) +
      annotate("text", x = pn$N["X", "x"] - 0.62, y = 1.8,
               label = "∂Y/∂X₀", family = FONT, size = 3.3, colour = ACC,
               angle = 90)
  }
  p <- p +
    geom_rect(data = pn$N, aes(xmin = x - w, xmax = x + w,
                               ymin = y - h, ymax = y + h),
              fill = FILL, colour = STROKE, linewidth = 0.55) +
    geom_text(data = pn$N, aes(x, y, label = label), family = FONT,
              size = 3.3, colour = INK, lineheight = 1.0) +
    geom_text(data = pn$title, aes(x, y, label = lab), family = FONT,
              size = 3.2, colour = "grey25", lineheight = 1.0)
}

p <- p + coord_fixed(clip = "off", xlim = c(-0.1, 11.6), ylim = c(-0.75, 3.5)) +
  theme_void()

ragg::agg_png(file.path(img_dir, "umbrella-raindance.png"), width = 7.8,
              height = 2.95, units = "in", res = 300, background = "white")
print(p); invisible(dev.off())
cat("wrote images/umbrella-raindance.png\n")
