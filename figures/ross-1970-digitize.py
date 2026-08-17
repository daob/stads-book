"""Digitize two of the three curves in the Ross, Campbell & Glass (1970) figure.

Source: the scanned figure in `ross-1970-source.png`, reproduced in Shadish,
Cook & Campbell (2002, ch. 6). It plots monthly British road casualties from
January 1966 to December 1968 as three series on two y-scales: "all hours and
days" on an outer axis running 1,000 to 10,000, and "commuting hours" and
"weekend nights" together on an inner axis running 100 to 1,500. Only the two
inner-axis series are extracted here; because they share one scale, the modern
redraw needs no second axis.

Method. Every corner of each polyline is one monthly observation, so the job is
to recover the pixel coordinates of the corners and map them through the axes.

  1. Calibrate x from the 36 month ticks below the axis, cross-checked against
     the 36 month letters (the two independent fits agree to about 1 px).
  2. Calibrate y by least squares on the 15 inner-axis tick marks (1500 down to
     100), which reproduces the labelled values to within 3 units.
  3. Trace each curve column by column. Adjacent columns of a continuous line
     always overlap in y, which both follows steep segments and keeps the
     tracer off the neighbouring curve and off the in-plot text labels.
     The figure dashes each line across the intervention, so each unbroken
     stretch of ink gets its own trace.
  4. Read a value at each month tick. At a corner the ink run spans both limbs
     of the angle, so the run centre sits inside the corner; a second pass
     compares each month with its neighbours and takes the extreme edge of the
     run wherever the month is a local maximum or minimum.

Checked by drawing the recovered points back onto the scan: every corner of
both curves is hit. Reading error is about +/- 10 casualties, set by the line
width (2 px, and 100 casualties is 25 px).

Usage:  python3 ross-1970-digitize.py   ->  writes ross-1970-data.csv
"""
from PIL import Image
import csv
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "ross-1970-source.png")
OUT = os.path.join(HERE, "ross-1970-data.csv")

THR = 175                       # ink threshold on the 0-255 grey scale
M, C = -4.011390, 2241.159      # value = M*y_pixel + C   (inner axis)
X0, DX = 85.6, 12.556           # x pixel of month k, k = 0 is January 1966

im = Image.open(SRC).convert("L")
W, H = im.size
PX = im.load()


def runs(x, ylo, yhi):
    """Vertical runs of ink in column x, between rows ylo and yhi."""
    out, start = [], None
    for y in range(ylo, yhi):
        if PX[x, y] < THR:
            if start is None:
                start = y
        elif start is not None:
            out.append((start, y - 1))
            start = None
    if start is not None:
        out.append((start, yhi - 1))
    return out


def trace(xa, xb, seed, ylo, yhi, tol=3):
    """Follow one unbroken stretch of a polyline from xa to xb.

    `seed` is a (top, bottom) ink run known to belong to the curve at xa. A
    column is accepted only if one of its runs overlaps the previous run,
    which is what makes the tracer immune to the other curve and to the text.
    """
    lo, hi = seed
    path, step = {}, (1 if xb >= xa else -1)
    for x in range(xa, xb + step, step):
        cand = [r for r in runs(x, ylo, yhi) if r[1] >= lo - tol and r[0] <= hi + tol]
        if not cand:
            break
        lo, hi = max(cand, key=lambda r: min(r[1], hi + tol) - max(r[0], lo - tol))
        path[x] = (lo + hi) / 2.0
    return path


def series(segments):
    path = {}
    for seg in segments:
        path.update(trace(*seg))
    return path


# Seeds are ink runs read off the scan at the start of each unbroken stretch.
commuting = series([
    (98, 336, (246, 251), 150, 300),    # Jan 1966 - Sep 1967, rightward
    (98, 87, (246, 251), 150, 300),     #   and leftward, to the first corner
    (348, 349, (222, 224), 150, 300),   # the Oct 1967 corner, among the dashes
    (351, 528, (228, 230), 150, 300),   # Nov 1967 - Dec 1968
])
weekend = series([
    (98, 336, (325, 328), 292, 545),    # Jan 1966 - Sep 1967
    (98, 87, (325, 328), 292, 545),
    (350, 515, (471, 475), 292, 545),   # Oct 1967 - Nov 1968
])


def extract(path, kfirst, klast):
    """Value at each month tick, with corners taken at the edge of the run."""
    prov, wins = {}, {}
    for k in range(kfirst, klast + 1):
        xk = X0 + DX * k
        win = {x: path[x] for x in range(round(xk) - 4, round(xk) + 5) if x in path}
        if not win:
            continue
        wins[k] = win
        prov[k] = win[min(win, key=lambda x: abs(x - xk))]
    out = {}
    for k, y in prov.items():
        v = M * y + C
        nb = [M * prov[j] + C for j in (k - 1, k + 1) if j in prov]
        if nb and all(v >= q for q in nb):
            y = min(wins[k].values())          # a local maximum in value
        elif nb and all(v <= q for q in nb):
            y = max(wins[k].values())          # a local minimum in value
        out[k] = M * y + C
    return out


com = extract(commuting, 0, 35)
wke = extract(weekend, 0, 34)   # the weekend curve is drawn only to Nov 1968

with open(OUT, "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["year", "month", "date", "commuting_hours", "weekend_nights"])
    for k in range(36):
        year, month = 1966 + k // 12, k % 12 + 1
        w.writerow([year, month, "%d-%02d-01" % (year, month),
                    "" if k not in com else round(com[k]),
                    "" if k not in wke else round(wke[k])])

pre_w = [wke[k] for k in range(21) if k in wke]
post_w = [wke[k] for k in range(21, 36) if k in wke]
pre_c = [com[k] for k in range(21) if k in com]
post_c = [com[k] for k in range(21, 36) if k in com]
mean = lambda v: sum(v) / len(v)
print("wrote", OUT)
print("weekend nights  pre %.0f  post %.0f  (%+.1f%%)"
      % (mean(pre_w), mean(post_w), 100 * (mean(post_w) / mean(pre_w) - 1)))
print("commuting hours pre %.0f  post %.0f  (%+.1f%%)"
      % (mean(pre_c), mean(post_c), 100 * (mean(post_c) / mean(pre_c) - 1)))
