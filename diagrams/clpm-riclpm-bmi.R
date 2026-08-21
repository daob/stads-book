# Path diagrams for the three-wave (2009/2017/2025) integration -> BMI ->
# disease models on LISS: the cross-lagged panel model (CLPM) and the
# random-intercept CLPM. Style matches the book's other hand-drawn figures.
#
# The route that carries the indirect effect (S1 -> B2 -> D3) is drawn in
# accent colour; the lag-2 direct path S1 -> D3 is drawn dashed-solid grey
# with its own label.
#
# Usage: Rscript clpm-riclpm-bmi.R -> writes clpm-bmi.png, riclpm-bmi.png

loc <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
if (identical(loc, "")) suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

library(ggplot2)

here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."

FONT   <- "Fira Sans"
FILL   <- "#ECECFF"
STROKE <- "#9370DB"
INK    <- "#1f1f1f"
ACC    <- "#7A28CB"     # accent for the indirect route
SOFT   <- "#6b6b6b"

ARROW  <- arrow(length = unit(0.075, "in"), type = "closed", angle = 20)
ARROW2 <- arrow(length = unit(0.065, "in"), ends = "both", type = "closed",
                angle = 20)

XW <- c(1.3, 5.1, 8.9)          # wave columns
BW <- 0.44; BH <- 0.30          # box half-sizes

box_df <- function(rows_y, labs) {
  out <- NULL
  for (r in seq_along(rows_y)) for (w in 1:3)
    out <- rbind(out, data.frame(id = paste0(labs[r], w), x = XW[w],
                                 y = rows_y[r],
                                 label = paste0(labs[r], "₁₂₃"),
                                 stringsAsFactors = FALSE))
  # subscript per wave
  subs <- c("₁", "₂", "₃")
  out$label <- paste0(substr(out$id, 1, 1), subs[as.integer(substr(out$id, 2, 2))])
  rownames(out) <- out$id
  out
}

edgep <- function(N, id, ax, ay, w = BW, h = BH, pad = 0.05) {
  cx <- N[id, "x"]; cy <- N[id, "y"]
  dx <- ax - cx; dy <- ay - cy
  t <- min(if (dx != 0) (w + pad) / abs(dx) else Inf,
           if (dy != 0) (h + pad) / abs(dy) else Inf)
  c(cx + dx * t, cy + dy * t)
}

seg_between <- function(N, from, to, w1 = BW, h1 = BH, w2 = BW, h2 = BH) {
  p1 <- edgep(N, from, N[to, "x"], N[to, "y"], w1, h1)
  p2 <- edgep(N, to, N[from, "x"], N[from, "y"], w2, h2)
  data.frame(x = p1[1], y = p1[2], xend = p2[1], yend = p2[2])
}

## ================= CLPM ======================================================

rows_y <- c(S = 5.1, B = 3.0, D = 0.9)
N <- box_df(rows_y, c("S", "B", "D"))

lag1 <- expand.grid(v1 = c("S", "B", "D"), v2 = c("S", "B", "D"),
                    w = 1:2, stringsAsFactors = FALSE)
segs <- do.call(rbind, lapply(seq_len(nrow(lag1)), function(i) {
  from <- paste0(lag1$v1[i], lag1$w[i]); to <- paste0(lag1$v2[i], lag1$w[i] + 1)
  cbind(seg_between(N, from, to),
        acc = (from == "S1" & to == "B2") | (from == "B2" & to == "D3"))
}))

# lag-2 autoregressive paths, drawn as shallow arcs above/below their rows
l2 <- data.frame(v = c("S", "B", "D"), k = c(-0.18, -0.14, 0.20))

p <- ggplot() +
  geom_segment(data = segs[!segs$acc, ], aes(x, y, xend = xend, yend = yend),
               linewidth = 0.4, colour = INK, arrow = ARROW) +
  geom_segment(data = segs[segs$acc, ], aes(x, y, xend = xend, yend = yend),
               linewidth = 0.9, colour = ACC, arrow = ARROW)

for (i in 1:3) {
  v <- l2$v[i]
  p1 <- c(N[paste0(v, 1), "x"], N[paste0(v, 1), "y"] + sign(l2$k[i]) * -BH)
  p2 <- c(N[paste0(v, 3), "x"], N[paste0(v, 3), "y"] + sign(l2$k[i]) * -BH)
  p <- p + geom_curve(aes(x = x, y = y, xend = xend, yend = yend),
                      data = data.frame(x = p1[1], y = p1[2],
                                        xend = p2[1], yend = p2[2]),
                      curvature = l2$k[i], linewidth = 0.4, colour = SOFT,
                      arrow = ARROW)
}

# the lag-2 direct path S1 -> D3, routed under the bottom row
p <- p +
  annotate("segment", x = N["S1", "x"] - BW - 0.05, y = N["S1", "y"],
           xend = 0.15, yend = N["S1", "y"], linewidth = 0.75, colour = SOFT) +
  annotate("segment", x = 0.15, y = N["S1", "y"], xend = 0.15, yend = -0.65,
           linewidth = 0.75, colour = SOFT) +
  annotate("segment", x = 0.15, y = -0.65, xend = N["D3", "x"], yend = -0.65,
           linewidth = 0.75, colour = SOFT) +
  annotate("segment", x = N["D3", "x"], y = -0.65, xend = N["D3", "x"],
           yend = N["D3", "y"] - BH - 0.05, linewidth = 0.75, colour = SOFT,
           arrow = ARROW) +
  annotate("text", x = 4.4, y = -0.44, label = "direct effect",
           family = FONT, size = 3.1, colour = SOFT)

# wave-1 exogenous covariances and correlated errors (waves 2, 3)
cov_arc <- function(w, dx = -0.62) {
  x <- XW[w] + dx
  rbind(data.frame(x = x, y = rows_y["S"] - BH - 0.04, xend = x,
                   yend = rows_y["B"] + BH + 0.04, k = 0.35 * sign(dx)),
        data.frame(x = x, y = rows_y["B"] - BH - 0.04, xend = x,
                   yend = rows_y["D"] + BH + 0.04, k = 0.35 * sign(dx)))
}
arcs <- rbind(cov_arc(1, -0.60), cov_arc(2, 0.60), cov_arc(3, 0.60))
for (i in seq_len(nrow(arcs)))
  p <- p + geom_curve(data = arcs[i, ], aes(x, y, xend = xend, yend = yend),
                      curvature = arcs$k[i], linetype = "22", linewidth = 0.4,
                      colour = INK, arrow = ARROW2)

p <- p +
  geom_rect(data = N, aes(xmin = x - BW, xmax = x + BW,
                          ymin = y - BH, ymax = y + BH),
            fill = FILL, colour = STROKE, linewidth = 0.55) +
  geom_text(data = N, aes(x, y, label = label), family = FONT, size = 4.4,
            colour = INK) +
  annotate("text", x = XW, y = 6.35, label = c("2009", "2017", "2025"),
           family = FONT, size = 4.0, colour = SOFT) +
  annotate("text", x = -0.85, y = rows_y + 0.0,
           label = c("Integration (S)", "BMI (B)", "Diseases (D)"),
           family = FONT, size = 3.4, colour = SOFT, angle = 90) +
  coord_fixed(clip = "off", xlim = c(-1.05, 9.7), ylim = c(-0.85, 6.5)) +
  theme_void()

ragg::agg_png(file.path(here, "clpm-bmi.png"), width = 7.6, height = 5.4,
              units = "in", res = 300, background = "white")
print(p); invisible(dev.off())
cat("wrote clpm-bmi.png\n")

## ================= RI-CLPM ===================================================
# Compact representation: the random intercepts point at the observed boxes;
# the dynamic paths are drawn between the boxes but connect, in the model,
# the within-person components (omitted from the drawing for legibility).

N2 <- N
subs <- c("\u2080\u2089", "\u2081\u2087", "\u2082\u2085")   # 09 17 25
N2$label <- paste0(substr(N2$id, 1, 1), subs[as.integer(substr(N2$id, 2, 2))])

RI <- data.frame(id = c("RIS", "RIB", "RID"),
                 x = c(5.1, -1.55, 5.1), y = c(7.35, 3.0, -2.15),
                 label = c("RI(S)", "RI(B)", "RI(D)"))
rownames(RI) <- RI$id
RIR <- 0.45

circ_pts <- function(cx, cy, r, id) {
  th <- seq(0, 2 * pi, length.out = 72)
  data.frame(id = id, x = cx + r * cos(th), y = cy + r * sin(th))
}

q <- ggplot() +
  geom_segment(data = segs[!segs$acc, ], aes(x, y, xend = xend, yend = yend),
               linewidth = 0.4, colour = INK, arrow = ARROW) +
  geom_segment(data = segs[segs$acc, ], aes(x, y, xend = xend, yend = yend),
               linewidth = 0.9, colour = ACC, arrow = ARROW)

# within-wave residual covariances (dashed), as in the CLPM figure
for (i in seq_len(nrow(arcs)))
  q <- q + geom_curve(data = arcs[i, ], aes(x, y, xend = xend, yend = yend),
                      curvature = arcs$k[i], linetype = "22", linewidth = 0.4,
                      colour = INK, arrow = ARROW2)

# the within direct effect wS1 -> wD3, routed under the bottom row
q <- q +
  annotate("segment", x = N["S1", "x"] - BW - 0.05, y = N["S1", "y"],
           xend = 0.05, yend = N["S1", "y"], linewidth = 0.75, colour = SOFT) +
  annotate("segment", x = 0.05, y = N["S1", "y"], xend = 0.05, yend = -0.75,
           linewidth = 0.75, colour = SOFT) +
  annotate("segment", x = 0.05, y = -0.75, xend = N["D3", "x"], yend = -0.75,
           linewidth = 0.75, colour = SOFT) +
  annotate("segment", x = N["D3", "x"], y = -0.75, xend = N["D3", "x"],
           yend = N["D3", "y"] - BH - 0.05, linewidth = 0.75, colour = SOFT,
           arrow = ARROW) +
  annotate("text", x = 2.9, y = -0.55, label = "direct effect",
           family = FONT, size = 3.0, colour = SOFT)

# random intercepts -> their three boxes
ri_edges <- NULL
for (v in c("S", "B", "D")) for (w in 1:3) {
  ri <- paste0("RI", v); bid <- paste0(v, w)
  rx <- RI[ri, "x"]; ry <- RI[ri, "y"]
  bx <- N[bid, "x"]; by <- N[bid, "y"]
  d2 <- sqrt((bx - rx)^2 + (by - ry)^2)
  p1 <- c(rx + (bx - rx) / d2 * RIR, ry + (by - ry) / d2 * RIR)
  if (v == "B" && w > 1) {
    # curve under the B row so the arrows do not run through B1 or the AR path
    q <- q + geom_curve(data = data.frame(x = rx + RIR * 0.7,
                                          y = ry - RIR * 0.7,
                                          xend = bx - 0.1, yend = by - BH - 0.05),
                        aes(x, y, xend = xend, yend = yend), curvature = 0.16,
                        linewidth = 0.4, colour = SOFT, arrow = ARROW)
  } else {
    p2 <- edgep(N, bid, rx, ry)
    q <- q + annotate("segment", x = p1[1], y = p1[2], xend = p2[1],
                      yend = p2[2], linewidth = 0.4, colour = SOFT,
                      arrow = ARROW)
  }
}

# random-intercept covariances, routed along the margins as dashed polylines
poly_cov <- function(q, pts) {
  n <- nrow(pts)
  for (i in seq_len(n - 1)) {
    ar <- if (i == 1) arrow(length = unit(0.065, "in"), ends = "first",
                            type = "closed", angle = 20)
          else if (i == n - 1) arrow(length = unit(0.065, "in"), ends = "last",
                                     type = "closed", angle = 20)
          else NULL
    q <- q + annotate("segment", x = pts$x[i], y = pts$y[i],
                      xend = pts$x[i + 1], yend = pts$y[i + 1],
                      linetype = "22", linewidth = 0.4, colour = SOFT,
                      arrow = ar)
  }
  q
}
q <- poly_cov(q, data.frame(
  x = c(RI["RIS", "x"] - RIR - 0.05, RI["RIB", "x"], RI["RIB", "x"]),
  y = c(RI["RIS", "y"], RI["RIS", "y"], RI["RIB", "y"] + RIR + 0.05)))
q <- poly_cov(q, data.frame(
  x = c(RI["RIB", "x"], RI["RIB", "x"], RI["RID", "x"] - RIR - 0.05),
  y = c(RI["RIB", "y"] - RIR - 0.05, RI["RID", "y"], RI["RID", "y"])))
q <- poly_cov(q, data.frame(
  x = c(RI["RIS", "x"] + RIR + 0.05, 10.45, 10.45, RI["RID", "x"] + RIR + 0.05),
  y = c(RI["RIS", "y"], RI["RIS", "y"], RI["RID", "y"], RI["RID", "y"])))

rc <- do.call(rbind, lapply(1:3, function(i)
  circ_pts(RI$x[i], RI$y[i], RIR, RI$id[i])))
q <- q +
  geom_rect(data = N2, aes(xmin = x - BW, xmax = x + BW,
                           ymin = y - BH, ymax = y + BH),
            fill = FILL, colour = STROKE, linewidth = 0.55) +
  geom_text(data = N2, aes(x, y, label = label), family = FONT, size = 4.0,
            colour = INK) +
  geom_polygon(data = rc, aes(x, y, group = id), fill = "white",
               colour = STROKE, linewidth = 0.5) +
  geom_text(data = RI, aes(x, y, label = label), family = FONT, size = 3.4,
            colour = INK) +
  annotate("text", x = -0.85, y = c(5.75, 0.25),
           label = c("Integration (S)", "Diseases (D)"),
           family = FONT, size = 3.2, colour = SOFT, hjust = 0) +
  annotate("text", x = 0.0, y = 3.62, label = "BMI (B)",
           family = FONT, size = 3.2, colour = SOFT) +
  coord_fixed(clip = "off", xlim = c(-2.15, 10.55), ylim = c(-2.7, 7.9)) +
  theme_void()

ragg::agg_png(file.path(here, "riclpm-bmi.png"), width = 7.9, height = 7.1,
              units = "in", res = 300, background = "white")
print(q); invisible(dev.off())
cat("wrote riclpm-bmi.png\n")
