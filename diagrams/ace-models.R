# The ACE twin model, drawn twice: (a) fraternal twins, whose genetic factors
# correlate 0.5, and (b) identical twins, whose genetic factors correlate 1.
# The two panels sit side by side on one canvas so the only difference between
# them, the number on the genetic curve, is visible at a glance.
#
# Layout: the additive genetic factors A1 and A2 sit on top, joined by the
# curved two-headed arrow; the observed trait boxes sit in the middle; the
# shared environment C sits between and below them, the unique environments
# E1 and E2 at the outer bottom corners. Latent variables are circles,
# observed variables boxes, matching the conventions of chapter 2.
#
# Requires: ggplot2, ragg, and the Fira Sans font.
# Usage:  Rscript ace-models.R   ->  writes ace.png

loc <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
if (identical(loc, "")) suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

library(ggplot2)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."

FONT   <- "Fira Sans"
FILL   <- "#ECECFF"     # mermaid's default node fill
STROKE <- "#9370DB"     # mermaid's default node stroke
INK    <- "#1f1f1f"

ARROW  <- arrow(length = unit(0.08, "in"), type = "closed", angle = 20)
ARROW2 <- arrow(length = unit(0.07, "in"), ends = "both", type = "closed",
                angle = 20)
CR <- 0.34              # radius of a latent-variable circle

# One panel of the model, everything shifted right by dx.
# rho_label is the value printed on the genetic curve: "0.5" or "1".
panel <- function(dx, rho_label, title) {
  # circles (latent) and boxes (observed), centres
  C <- data.frame(
    id    = c("A1", "A2", "C", "E1", "E2"),
    x     = dx + c(1.30, 4.30, 2.80, 0.40, 5.20),
    y     = c(4.55, 4.55, 1.05, 1.05, 1.05),
    label = c("A₁", "A₂", "C", "E₁", "E₂")
  )
  B <- data.frame(
    id    = c("y1", "y2"),
    x     = dx + c(1.30, 4.30),
    y     = c(2.80, 2.80),
    label = c("y₁ (twin 1)", "y₂ (twin 2)"),
    w     = 0.92, h = 0.34
  )
  rownames(C) <- C$id; rownames(B) <- B$id

  # effect arrows: from circle border to box border
  eff <- function(from, to, lab, f = 0.45) {
    cx <- C[from, "x"]; cy <- C[from, "y"]
    bx <- B[to, "x"];   by <- B[to, "y"]
    dxv <- bx - cx; dyv <- by - cy; L <- sqrt(dxv^2 + dyv^2)
    p1 <- c(cx + dxv / L * CR, cy + dyv / L * CR)
    tx <- if (dxv != 0) (B[to, "w"] + 0.05) / abs(dxv) else Inf
    ty <- if (dyv != 0) (B[to, "h"] + 0.05) / abs(dyv) else Inf
    t  <- min(tx, ty)
    p2 <- c(bx - dxv * t, by - dyv * t)
    data.frame(x = p1[1], y = p1[2], xend = p2[1], yend = p2[2], lab = lab,
               lx = p1[1] + f * (p2[1] - p1[1]),
               ly = p1[2] + f * (p2[2] - p1[2]))
  }
  seg <- rbind(
    eff("A1", "y1", "0.7"), eff("A2", "y2", "0.7"),
    eff("C",  "y1", "0.5"), eff("C",  "y2", "0.5"),
    eff("E1", "y1", "0.5"), eff("E2", "y2", "0.5")
  )

  circ <- do.call(rbind, lapply(seq_len(nrow(C)), function(i) {
    th <- seq(0, 2 * pi, length.out = 72)
    data.frame(id = paste0(C$id[i], dx), x = C$x[i] + CR * cos(th),
               y = C$y[i] + CR * sin(th))
  }))

  list(
    seg = seg, circ = circ, C = C, B = B,
    cov = data.frame(x = C["A1", "x"] + CR * 0.75, y = C["A1", "y"] + CR * 0.75,
                     xend = C["A2", "x"] - CR * 0.75, yend = C["A2", "y"] + CR * 0.75,
                     lab = rho_label, lx = dx + 2.80, ly = 5.45),
    title = data.frame(x = dx + 2.80, y = -0.05, lab = title)
  )
}

pa <- panel(0.0,  "0.5", "(a) fraternal twins")
pb <- panel(6.6,  "1",   "(b) identical twins")

seg   <- rbind(pa$seg, pb$seg)
circ  <- rbind(pa$circ, pb$circ)
Cs    <- rbind(pa$C, pb$C)
Bs    <- rbind(pa$B, pb$B)
covs  <- rbind(pa$cov, pb$cov)
tits  <- rbind(pa$title, pb$title)

p <- ggplot() +
  geom_segment(data = seg, aes(x, y, xend = xend, yend = yend),
               linewidth = 0.5, colour = INK, arrow = ARROW) +
  geom_curve(data = covs[1, ], aes(x, y, xend = xend, yend = yend),
             curvature = -0.55, linetype = "22", linewidth = 0.45,
             colour = INK, arrow = ARROW2) +
  geom_curve(data = covs[2, ], aes(x, y, xend = xend, yend = yend),
             curvature = -0.55, linetype = "22", linewidth = 0.45,
             colour = INK, arrow = ARROW2) +
  geom_label(data = covs, aes(lx, ly, label = lab),
             family = FONT, size = 3.8, colour = INK, fill = "white",
             label.size = 0, label.padding = unit(0.08, "lines")) +
  geom_label(data = seg, aes(lx, ly, label = lab),
             family = FONT, size = 3.6, colour = INK, fill = "white",
             label.size = 0, label.padding = unit(0.08, "lines")) +
  geom_rect(data = Bs, aes(xmin = x - w, xmax = x + w,
                           ymin = y - h, ymax = y + h),
            fill = FILL, colour = STROKE, linewidth = 0.55) +
  geom_text(data = Bs, aes(x, y, label = label), family = FONT, size = 3.9,
            colour = INK) +
  geom_polygon(data = circ, aes(x, y, group = id),
               fill = "white", colour = STROKE, linewidth = 0.5) +
  geom_text(data = Cs, aes(x, y, label = label), family = FONT, size = 3.9,
            colour = INK) +
  geom_text(data = tits, aes(x, y, label = lab), family = FONT, size = 3.9,
            colour = "grey25") +
  coord_fixed(clip = "off", xlim = c(-0.10, 12.30), ylim = c(-0.35, 5.75)) +
  theme_void()

ragg::agg_png(file.path(here, "ace.png"), width = 8.0, height = 3.95,
              units = "in", res = 300, background = "white")
print(p); invisible(dev.off())
cat("wrote ace.png\n")
