# A modern redraw of the interrupted time series in Ross, Campbell & Glass
# (1970), using the values recovered by ross-1970-digitize.py.
#
# What changes from the original. The 1970 figure stacks three series on two
# different y-scales in one panel, so no two curves can be compared by eye.
# Commuting hours and weekend nights in fact share a single scale, so they are
# drawn here on one axis, from zero, and become directly comparable. The lines
# break at the intervention rather than being joined by a dashed segment, which
# is the modern convention: nothing is observed between the two regimes. Period
# means make the contrast explicit, and the series are labelled in place, so
# nothing depends on matching a colour to a legend key.
#
# Requires: ggplot2, ragg, systemfonts, and the Fira Sans font.
# Usage:  Rscript ross-1970-figure.R   ->  writes ../images/ross-1970-*.{png,pdf}

library(ggplot2)

here    <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]))
if (is.na(here) || !nzchar(here)) here <- "."
img_dir <- file.path(here, "..", "images")
dir.create(img_dir, showWarnings = FALSE)

# ---- data ------------------------------------------------------------------

raw <- read.csv(file.path(here, "ross-1970-data.csv"))
raw$date <- as.Date(raw$date)

ACT <- as.Date("1967-10-09")          # Road Safety Act 1967 came into force
BREAK <- as.Date("1967-09-15")        # midpoint of the last pre and first post month

long <- rbind(
  data.frame(date = raw$date, value = raw$weekend_nights,  series = "Weekend nights"),
  data.frame(date = raw$date, value = raw$commuting_hours, series = "Commuting hours")
)
long <- long[!is.na(long$value), ]
long$period <- ifelse(long$date < as.Date("1967-10-01"), "before", "after")
long$series <- factor(long$series, levels = c("Weekend nights", "Commuting hours"))

means <- do.call(rbind, lapply(split(long, list(long$series, long$period), drop = TRUE),
  function(d) data.frame(
    series = d$series[1], period = d$period[1], value = mean(d$value),
    x = if (d$period[1] == "before") min(d$date) else BREAK,
    xend = if (d$period[1] == "before") BREAK else max(d$date))))

# ---- design ----------------------------------------------------------------
# Two categorical hues, validated for colour-vision deficiency separation
# (worst adjacent pair dE 24.7 protan, 33.6 normal) and for contrast against
# the chart surface.
PAL      <- c("Weekend nights" = "#2a78d6", "Commuting hours" = "#eb6834")
INK      <- "#0b0b0b"
INK_SOFT <- "#52514e"
GRID     <- "#e6e5e1"
FONT     <- "Fira Sans"

year_lab <- function(x) ifelse(is.na(x), "",
  ifelse(format(x, "%m") == "01", format(x, "%b\n%Y"), format(x, "%b")))

p <- ggplot(long, aes(date, value, colour = series)) +
  # the intervention
  annotate("segment", x = BREAK, xend = BREAK, y = 0, yend = 1560,
           colour = INK_SOFT, linewidth = 0.3, linetype = "22") +
  annotate("text", x = BREAK + 22, y = 1585, hjust = 0, vjust = 1,
           label = "Road Safety Act\nin force, 9 Oct 1967",
           family = FONT, size = 2.7, colour = INK_SOFT, lineheight = 1.05) +
  # period means
  geom_segment(data = means, aes(x = x, xend = xend, y = value, yend = value),
               inherit.aes = FALSE, colour = PAL[as.character(means$series)],
               linewidth = 0.3, linetype = "31", alpha = 0.9) +
  # the series
  geom_line(aes(group = interaction(series, period)), linewidth = 0.5) +
  geom_point(size = 0.85, stroke = 0) +
  # In-place labels: a coloured swatch carries identity, the words carry the
  # name, and the text itself stays in ink so it clears the 4.5:1 contrast bar
  # that neither hue would meet as small text.
  annotate("segment", x = as.Date("1966-02-01"), xend = as.Date("1966-03-08"),
           y = 1520, yend = 1520, colour = PAL[["Commuting hours"]], linewidth = 0.7) +
  annotate("text", x = as.Date("1966-03-20"), y = 1520, hjust = 0,
           label = "Commuting hours", family = FONT, size = 3.1,
           fontface = "bold", colour = INK) +
  annotate("segment", x = as.Date("1966-02-01"), xend = as.Date("1966-03-08"),
           y = 690, yend = 690, colour = PAL[["Weekend nights"]], linewidth = 0.7) +
  annotate("text", x = as.Date("1966-03-20"), y = 690, hjust = 0,
           label = "Weekend nights", family = FONT, size = 3.1,
           fontface = "bold", colour = INK) +
  annotate("text", x = as.Date("1968-05-01"), y = 545, hjust = 0, vjust = 1,
           label = "period mean", family = FONT, size = 2.5, colour = INK_SOFT) +
  scale_colour_manual(values = PAL, guide = "none") +
  scale_x_date(breaks = seq(as.Date("1966-01-01"), as.Date("1968-12-01"), by = "6 months"),
               labels = year_lab, expand = expansion(mult = c(0.02, 0.04))) +
  scale_y_continuous(limits = c(0, 1600), breaks = seq(0, 1500, 300),
                     expand = expansion(mult = c(0, 0.02))) +
  labs(
    title    = "British road casualties before and after the 1967 Breathalyser law",
    subtitle = paste("Casualties on weekend nights fell by about a third and stayed down.",
                     "During commuting hours,\nwhen the pubs have been shut all night,",
                     "they did not move."),
    x = NULL, y = "Casualties per month",
    caption = paste("Monthly values digitized from the figure in Ross, Campbell & Glass (1970),",
                    "which draws both series on one\nscale. Dashed lines are period means.",
                    "The weekend-night series stops at November 1968 in the original.")
  ) +
  theme_minimal(base_family = FONT, base_size = 11) +
  theme(
    plot.title       = element_text(face = "bold", size = 11.5, colour = INK,
                                    margin = margin(b = 3)),
    plot.subtitle    = element_text(size = 9, colour = INK_SOFT, lineheight = 1.15,
                                    margin = margin(b = 11)),
    plot.caption     = element_text(size = 7.3, colour = INK_SOFT, hjust = 0,
                                    lineheight = 1.15, margin = margin(t = 9)),
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    axis.title.y     = element_text(size = 8.5, colour = INK_SOFT, hjust = 1,
                                    margin = margin(r = 5)),
    axis.text        = element_text(size = 8, colour = INK_SOFT),
    axis.text.x      = element_text(lineheight = 1.05),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(colour = GRID, linewidth = 0.3),
    axis.ticks       = element_blank(),
    plot.margin      = margin(9, 11, 7, 7)
  )

W <- 6.5; H <- 4.0
ragg::agg_png(file.path(img_dir, "ross-1970-breathalyser.png"),
              width = W, height = H, units = "in", res = 300, background = "white")
print(p); invisible(dev.off())
ggsave(file.path(img_dir, "ross-1970-breathalyser.pdf"), p,
       width = W, height = H, device = cairo_pdf)

cat("wrote images/ross-1970-breathalyser.png and .pdf\n")
for (s in levels(long$series)) {
  b <- mean(long$value[long$series == s & long$period == "before"])
  a <- mean(long$value[long$series == s & long$period == "after"])
  cat(sprintf("%-16s before %6.0f   after %6.0f   %+.1f%%\n", s, b, a, 100 * (a / b - 1)))
}
